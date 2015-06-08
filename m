From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 1/2] sctp: rcu-ify addr_waitq
Date: Mon, 08 Jun 2015 17:37:05 +0200
Message-ID: <1433777825.13489.16.camel@stressinduktion.org>
References: <20150604142710.GD24585@hmsreliant.think-freely.org>
	 <9ebea428aa10e30e4b6c92aa95c56fc5cbc9cd98.1433524062.git.marcelo.leitner@gmail.com>
	 <1433774798.3152487.289784457.4E5FCE86@webmail.messagingengine.com>
	 <1433775558.3155807.289796417.0EFF401F@webmail.messagingengine.com>
	 <20150608151955.GE7616@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mleitner@redhat.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Michio Honda <micchie@sfc.wide.ad.jp>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:59454 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751570AbbFHPhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Jun 2015 11:37:08 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id EC7E020C83
	for <netdev@vger.kernel.org>; Mon,  8 Jun 2015 11:37:07 -0400 (EDT)
In-Reply-To: <20150608151955.GE7616@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mo, 2015-06-08 at 11:19 -0400, Neil Horman wrote:
> On Mon, Jun 08, 2015 at 04:59:18PM +0200, Hannes Frederic Sowa wrote:
> > On Mon, Jun 8, 2015, at 16:46, Hannes Frederic Sowa wrote:
> > > Hi Marcelo,
> > > 
> > > a few hints on rcuification, sorry I reviewed the code so late:
> > > 
> > > On Fri, Jun 5, 2015, at 19:08, mleitner@redhat.com wrote:
> > > > From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> > > > 
> > > > That's needed for the next patch, so we break the lock 
> > > > inversion between
> > > > netns_sctp->addr_wq_lock and socket lock on
> > > > sctp_addr_wq_timeout_handler(). With this, we can traverse 
> > > > addr_waitq
> > > > without taking addr_wq_lock, taking it just for the write 
> > > > operations.
> > > > 
> > > > Signed-off-by: Marcelo Ricardo Leitner <
> > > > marcelo.leitner@gmail.com>
> > > > ---
> > > > 
> > > > Notes:
> > > >     v2->v3:
> > > >       placed break statement on sctp_free_addr_wq_entry()
> > > >       removed unnecessary spin_lock noticed by Neil
> > > > 
> > > >  include/net/netns/sctp.h |  2 +-
> > > >  net/sctp/protocol.c      | 80
> > > >  +++++++++++++++++++++++++++++-------------------
> > > >  2 files changed, 49 insertions(+), 33 deletions(-)
> > > > 
> > > > diff --git a/include/net/netns/sctp.h 
> > > > b/include/net/netns/sctp.h
> > > > index
> > > > 3573a81815ad9e0efb6ceb721eb066d3726419f0..9e53412c4ed829e8e4577
> > > > 7a6d95406d490dbaa75
> > > > 100644
> > > > --- a/include/net/netns/sctp.h
> > > > +++ b/include/net/netns/sctp.h
> > > > @@ -28,7 +28,7 @@ struct netns_sctp {
> > > >          * It is a list of sctp_sockaddr_entry.
> > > >          */
> > > >         struct list_head local_addr_list;
> > > > -       struct list_head addr_waitq;
> > > > +       struct list_head __rcu addr_waitq;
> > > >         struct timer_list addr_wq_timer;
> > > >         struct list_head auto_asconf_splist;
> > > >         spinlock_t addr_wq_lock;
> > > > diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> > > > index
> > > > 53b7acde9aa37bf3d4029c459421564d5270f4c0..9954fb8c9a9455d5ad7a6
> > > > 27e2d7f9a1fef861fc2
> > > > 100644
> > > > --- a/net/sctp/protocol.c
> > > > +++ b/net/sctp/protocol.c
> > > > @@ -593,15 +593,47 @@ static void sctp_v4_ecn_capable(struct 
> > > > sock *sk)
> > > >         INET_ECN_xmit(sk);
> > > >  }
> > > >  
> > > > +static void sctp_free_addr_wq(struct net *net)
> > > > +{
> > > > +       struct sctp_sockaddr_entry *addrw;
> > > > +
> > > > +       spin_lock_bh(&net->sctp.addr_wq_lock);
> > > 
> > > Instead of holding spin_lock_bh you need to hold 
> > > rcu_read_lock_bh, so
> > > kfree_rcu does not call free function at once (in theory ;) ).
> > > 
> > > > +       del_timer(&net->sctp.addr_wq_timer);
> > > > +       list_for_each_entry_rcu(addrw, &net->sctp.addr_waitq, 
> > > > list) {
> > > > +               list_del_rcu(&addrw->list);
> > > > +               kfree_rcu(addrw, rcu);
> > > > +       }
> > > > +       spin_unlock_bh(&net->sctp.addr_wq_lock);
> > > > +}
> > > > +
> > > > +/* As there is no refcnt on sctp_sockaddr_entry, we must check 
> > > > inside
> > > > + * the lock if it wasn't removed from addr_waitq already, 
> > > > otherwise we
> > > > + * could double-free it.
> > > > + */
> > > > +static void sctp_free_addr_wq_entry(struct net *net,
> > > > +                                   struct sctp_sockaddr_entry 
> > > > *addrw)
> > > > +{
> > > > +       struct sctp_sockaddr_entry *temp;
> > > > +
> > > > +       spin_lock_bh(&net->sctp.addr_wq_lock);
> > > 
> > > I don't think this spin_lock operation is needed. The del_timer
> > > functions do synchronize themselves.
> > > 
> > 
> > Sorry, those above two locks are needed, they are not implied by 
> > other
> > locks.
> > 
> What makes you say that? Multiple contexts can issue mod_timer calls 
> on the
> same timer safely no, because of the internal locking?

That's true for timer handling but not to protect net->sctp.addr_waitq
list (Marcelo just explained it to me off-list). Looking at the patch
only in patchworks lost quite a lot of context you were already
discussing. ;)

We are currently checking if the double iteration can be avoided by
splicing addr_waitq on the local stack while holding the spin_lock and
later on notifying the sockets.

Bye,
Hannes
