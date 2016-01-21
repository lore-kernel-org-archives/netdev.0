From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net 2/3] sctp: hold transport before we access t->asoc in
 sctp proc
Date: Thu, 21 Jan 2016 17:37:10 -0200
Message-ID: <20160121193709.GG3452@mrl.redhat.com>
References: <cover.1453398443.git.lucien.xin@gmail.com>
 <9f366422b6a8c6c0c939ccbf993548c1881a2c16.1453398443.git.lucien.xin@gmail.com>
 <4357f1f3ad90ffec1481a265d8ca198d75e25d07.1453398443.git.lucien.xin@gmail.com>
 <1453404456.1223.378.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Xin Long <lucien.xin@gmail.com>,
	network dev <netdev@vger.kernel.org>,
	linux-sctp@vger.kernel.org, Vlad Yasevich <vyasevich@gmail.com>,
	daniel@iogearbox.net, davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48940 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750905AbcAUThN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 14:37:13 -0500
Content-Disposition: inline
In-Reply-To: <1453404456.1223.378.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 21, 2016 at 11:27:36AM -0800, Eric Dumazet wrote:
> On Fri, 2016-01-22 at 01:49 +0800, Xin Long wrote:
> > Previously, before rhashtable, /proc assoc listing was done by
> > read-locking the entire hash entry and dumping all assocs at once, so we
> > were sure that the assoc wasn't freed because it wouldn't be possible to
> > remove it from the hash meanwhile.
> > 
> > Now we use rhashtable to list transports, and dump entries one by one.
> > That is, now we have to check if the assoc is still a good one, as the
> > transport we got may be being freed.
> > 
> > Signed-off-by: Xin Long <lucien.xin@gmail.com>
> > ---
> >  net/sctp/proc.c | 8 ++++++++
> >  1 file changed, 8 insertions(+)
> > 
> > diff --git a/net/sctp/proc.c b/net/sctp/proc.c
> > index 684c5b3..c74a810 100644
> > --- a/net/sctp/proc.c
> > +++ b/net/sctp/proc.c
> > @@ -380,6 +380,8 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
> >  	}
> >  
> >  	transport = (struct sctp_transport *)v;
> 
> What protects you from this structure already being freed ?

rcu, rhashtable_walk_start() at sctp_assocs_seq_start() starts an
(implicit from this POV) rcu_read_lock() for us which is unlocked only
when the walking is terminated, thus covering this _show.

> > +	if (!sctp_transport_hold(transport))
> > +		return 0;
> 
> If this is rcu, then you do not need to increment the refcount, and
> decrement it later.

It's an implicit hold on sctp asoc.

This code is using contents from asoc pointer, which is not proctected
by rcu. As transport has a hold on the asoc, it's enough to just hold
the transport and not the asoc too, as we had to do in the previous
patch.

  Marcelo
