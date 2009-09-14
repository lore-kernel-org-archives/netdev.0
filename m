From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Fix tx queue selection in tc_modify_qdisc
Date: Mon, 14 Sep 2009 21:03:38 +0200
Message-ID: <20090914190338.GA3065@ami.dom.local>
References: <20090914122226.GA14087@ff.dom.local>
 <4AAE85F9.2060600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:2956 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756801AbZINTDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 15:03:53 -0400
Received: by fg-out-1718.google.com with SMTP id 22so1054696fge.1
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 12:03:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4AAE85F9.2060600@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2009 at 08:05:45PM +0200, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > After the recent mq change there is the new select_queue qdisc class
> > method used in tc_modify_qdisc, but it works OK only for direct child
> > qdiscs of mq qdisc. Grandchildren always get the first tx queue, which
> > would give wrong qdisc_root etc. results (e.g. for sch_htb as child of
> > sch_prio). This patch fixes it by using parent's dev_queue for such
> > grandchildren qdiscs. The select_queue method is replaced BTW with the
> > static qdisc_select_tx_queue function (it's used only in one place).
> 
> Thanks, this looks correct. My assumption was that we shouldn't
> be using the locks of grandchildren anyways, but we do need the
> proper root lock for estimators.

Actually, in the above example I was mainly concerned with a watchdog
parameter. But of course there should more (etc.).

> > diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
> > index 88eb9de..865120c 100644
> > --- a/include/net/sch_generic.h
> > +++ b/include/net/sch_generic.h
> > @@ -81,7 +81,6 @@ struct Qdisc
> >  struct Qdisc_class_ops
> >  {
> >  	/* Child qdisc manipulation */
> > -	unsigned int		(*select_queue)(struct Qdisc *, struct tcmsg *);
> >  	int			(*graft)(struct Qdisc *, unsigned long cl,
> >  					struct Qdisc *, struct Qdisc **);
> >  	struct Qdisc *		(*leaf)(struct Qdisc *, unsigned long cl);
> > diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
> > index 3af1061..223a6bc 100644
> > --- a/net/sched/sch_api.c
> > +++ b/net/sched/sch_api.c
> > @@ -990,6 +990,24 @@ static int tc_get_qdisc(struct sk_buff *skb, struct nlmsghdr *n, void *arg)
> >  	return 0;
> >  }
> >  
> > +static struct netdev_queue *qdisc_select_tx_queue(struct net_device *dev,
> > +						  struct Qdisc *p, u32 clid)
> > +{
> > +	unsigned long ntx;
> > +
> > +	if (!p)
> > +		return netdev_get_tx_queue(dev, 0);
> > +
> > +	if (!(p->flags & TCQ_F_MQROOT))
> > +		return p->dev_queue;
> > +
> > +	ntx = TC_H_MIN(clid) - 1;
> 
> I didn't want to expose the numbering scheme used by sch_mq internally,
> but fine, I see you really don't like the callback :)

I only don't like the callback just for one exceptional qdisc. On the
other hand it would look more sensible to me if implemented at least
by all classful qdiscs to return parent's dev_queue always; so I could
re-do it like this, or simply mix this fix with the current
implementation, no problem (I don't "don't like it" too much).

Jarek P.
