From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 1/3] sctp: fix the transport dead race check by using
 atomic_add_unless on refcnt
Date: Fri, 22 Jan 2016 15:18:12 -0200
Message-ID: <20160122171812.GI3452@mrl.redhat.com>
References: <cover.1453398443.git.lucien.xin@gmail.com>
 <9f366422b6a8c6c0c939ccbf993548c1881a2c16.1453398443.git.lucien.xin@gmail.com>
 <56A25DCC.9040207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org, daniel@iogearbox.net,
	davem@davemloft.net
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754372AbcAVRSQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jan 2016 12:18:16 -0500
Content-Disposition: inline
In-Reply-To: <56A25DCC.9040207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 22, 2016 at 11:50:20AM -0500, Vlad Yasevich wrote:
> On 01/21/2016 12:49 PM, Xin Long wrote:
> > Now when __sctp_lookup_association is running in BH, it will try to
> > check if t->dead is set, but meanwhile other CPUs may be freeing this
> > transport and this assoc and if it happens that
> > __sctp_lookup_association checked t->dead a bit too early, it may think
> > that the association is still good while it was already freed.
> > 
> > So we fix this race by using atomic_add_unless in sctp_transport_hold.
> > After we get one transport from hashtable, we will hold it only when
> > this transport's refcnt is not 0, so that we can make sure t->asoc
> > cannot be freed before we hold the asoc again.
> 
> atomic_add_unless() uses atomic_read() to check the value.  Since there
> don't appear to be any barriers, what guarantees that the value
> read will not have been modified in another thread under a proper lock?
> 

atomic_read() is used only as a starting point.  If it got changed in
between, the new current value (return of atomic_cmpxchg) will be used
then.

> > 
> > Note that sctp association is not freed using RCU so we can't use
> > atomic_add_unless() with it as it may just be too late for that either.
> > 
> > Fixes: 4f0087812648 ("sctp: apply rhashtable api to send/recv path")
> > Reported-by: Vlad Yasevich <vyasevich@gmail.com>
> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> > ---
> >  include/net/sctp/structs.h |  2 +-
> >  net/sctp/input.c           | 17 +++++++++++------
> >  net/sctp/transport.c       |  4 ++--
> >  3 files changed, 14 insertions(+), 9 deletions(-)
> > 
> > diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> > index 20e7212..344da04 100644
> > --- a/include/net/sctp/structs.h
> > +++ b/include/net/sctp/structs.h
> > @@ -955,7 +955,7 @@ void sctp_transport_route(struct sctp_transport *, union sctp_addr *,
> >  void sctp_transport_pmtu(struct sctp_transport *, struct sock *sk);
> >  void sctp_transport_free(struct sctp_transport *);
> >  void sctp_transport_reset_timers(struct sctp_transport *);
> > -void sctp_transport_hold(struct sctp_transport *);
> > +int sctp_transport_hold(struct sctp_transport *);
> >  void sctp_transport_put(struct sctp_transport *);
> >  void sctp_transport_update_rto(struct sctp_transport *, __u32);
> >  void sctp_transport_raise_cwnd(struct sctp_transport *, __u32, __u32);
> > diff --git a/net/sctp/input.c b/net/sctp/input.c
> > index bf61dfb..49d2cc7 100644
> > --- a/net/sctp/input.c
> > +++ b/net/sctp/input.c
> > @@ -935,15 +935,22 @@ static struct sctp_association *__sctp_lookup_association(
> >  					struct sctp_transport **pt)
> >  {
> >  	struct sctp_transport *t;
> > +	struct sctp_association *asoc = NULL;
> >  
> > +	rcu_read_lock();
> >  	t = sctp_addrs_lookup_transport(net, local, peer);
> > -	if (!t || t->dead)
> > -		return NULL;
> > +	if (!t || !sctp_transport_hold(t))
> > +		goto out;
> >  
> > -	sctp_association_hold(t->asoc);
> > +	asoc = t->asoc;
> > +	sctp_association_hold(asoc);
> 
> I don't think you can modify the reference count on a transport, let alone
> the association outside of a lock.

The transport memory is not freed, as it's protected by rcu_read_lock(),
so we are safe to use it yet.
atomic_ operations include an embedded lock instruction protecting the
counter itself, there shouldn't be a need to use another lock around it.

And in the code above, as we could grab a hold on the transport, means
the association was not freed yet because transports hold a ref on
assoc. That's why the dance: hold(transport) hold(assoc) put(transport)

  Marcelo

> 
> -vlad
> 
> >  	*pt = t;
> >  
> > -	return t->asoc;
> > +	sctp_transport_put(t);
> > +
> > +out:
> > +	rcu_read_unlock();
> > +	return asoc;
> >  }
> >  
> >  /* Look up an association. protected by RCU read lock */
> > @@ -955,9 +962,7 @@ struct sctp_association *sctp_lookup_association(struct net *net,
> >  {
> >  	struct sctp_association *asoc;
> >  
> > -	rcu_read_lock();
> >  	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
> > -	rcu_read_unlock();
> >  
> >  	return asoc;
> >  }
> > diff --git a/net/sctp/transport.c b/net/sctp/transport.c
> > index aab9e3f..69f3799 100644
> > --- a/net/sctp/transport.c
> > +++ b/net/sctp/transport.c
> > @@ -296,9 +296,9 @@ void sctp_transport_route(struct sctp_transport *transport,
> >  }
> >  
> >  /* Hold a reference to a transport.  */
> > -void sctp_transport_hold(struct sctp_transport *transport)
> > +int sctp_transport_hold(struct sctp_transport *transport)
> >  {
> > -	atomic_inc(&transport->refcnt);
> > +	return atomic_add_unless(&transport->refcnt, 1, 0);
> >  }
> >  
> >  /* Release a reference to a transport and clean up
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
