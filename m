From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] hfsc: ensure class is added to eltree exactly once
Date: Wed, 1 Jun 2016 01:00:48 +0200
Message-ID: <20160531230048.GA26552@breakpoint.cc>
References: <1464689539-15162-1-git-send-email-fw@strlen.de>
 <1464706554.5939.105.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	Miroslav Kratochvil <exa.exa@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41893 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750885AbcEaXAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 19:00:55 -0400
Content-Disposition: inline
In-Reply-To: <1464706554.5939.105.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
> > index d783d7c..0854be3 100644
> > --- a/net/sched/sch_hfsc.c
> > +++ b/net/sched/sch_hfsc.c
> > @@ -1583,6 +1583,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> >  {
> >  	struct hfsc_class *cl;
> >  	int uninitialized_var(err);
> > +	unsigned int qlen;
> >  
> >  	cl = hfsc_classify(skb, sch, &err);
> >  	if (cl == NULL) {
> > @@ -1592,6 +1593,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> >  		return err;
> >  	}
> >  
> > +	qlen = cl->qdisc->q.qlen;
> >  	err = qdisc_enqueue(skb, cl->qdisc);
> >  	if (unlikely(err != NET_XMIT_SUCCESS)) {
> >  		if (net_xmit_drop_count(err)) {
> > @@ -1601,7 +1603,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> >  		return err;
> >  	}
> >  
> > -	if (cl->qdisc->q.qlen == 1)
> > +	if (qlen == 0)
> >  		set_active(cl, qdisc_pkt_len(skb));
> >  
> >  	sch->q.qlen++;
> 
> Well, I am not sure HFSC can deal with non work conserving qdisc
> anyway ?

As long as child qdisc dequeue() returns an skb if qlen > 0 it should
work.

> Call to set_active(cl, qdisc_pkt_len(skb)); would tell you that HFSC
> does not expect another packet than @skb being the next dequeued one.

Good point.  I'll look into it in more detail but AFAIU this "only"
means we might overshoot a defined realtime/deadline criterion,
I don't (yet) see how it could explain Miroslavs bug report.

> If you want to make HFSC generic, you would need a lot more changes.

Could you elaborate?

I'm not interested in e.g. tbf leaves (makes no sense to me), but I
think it should play nice with netem, sfq, codel, fq_codel, fq, ...

I don't see any problems with fq_codel + hfsc unless I deliberately
misconfigure fq_codel (setting extremely low mem limit, e.g. 32kbyte).
