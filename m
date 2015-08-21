From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH 2/3] net: sched: allocate a handle to default
 qdiscs
Date: Fri, 21 Aug 2015 19:08:13 +0200
Message-ID: <20150821170813.GA26535@orbit.nwl.cc>
References: <1440172688-2163-1-git-send-email-phil@nwl.cc>
 <1440172688-2163-3-git-send-email-phil@nwl.cc>
 <1440173698.6610.78.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:57896 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751428AbbHURIP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2015 13:08:15 -0400
Content-Disposition: inline
In-Reply-To: <1440173698.6610.78.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 21, 2015 at 09:14:58AM -0700, Eric Dumazet wrote:
[...]
> > diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
> > index 1fb65f9..ab614ee 100644
> > --- a/net/sched/sch_generic.c
> > +++ b/net/sched/sch_generic.c
> > @@ -634,6 +634,11 @@ struct Qdisc *qdisc_create_dflt(struct netdev_queue *dev_queue,
> >  	if (IS_ERR(sch))
> >  		goto errout;
> >  	sch->parent = parentid;
> > +#ifdef CONFIG_NET_SCHED
> > +	sch->handle = qdisc_alloc_handle(dev_queue->dev);
> > +	if (!sch->handle)
> > +		goto errout;
> > +#endif
> >  
> >  	if (!ops->init || ops->init(sch, NULL) == 0)
> >  		return sch;
> 
> This might break HTB setups with more than 32768 classes ?

Urgh. Thanks for noticing this!

> The pfifo qdisc that gets attached had no handle.

Yes, looks like I need to leave qdisc_create_dflt() alone. It is
possible, by doing the above twice in sch_generic.c (once in
attach_one_default_qdisc(), and in attach_default_qdiscs() as well).

> qdisc_alloc_handle() has a limited range.

Yes, I noticed this. Handles aren't reused in a running system either,
which might contribute to this problem in other situations.

V2 will follow, thanks again.

Cheers, Phil
