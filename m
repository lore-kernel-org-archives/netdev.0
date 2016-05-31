From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] hfsc: ensure class is added to eltree exactly once
Date: Tue, 31 May 2016 16:33:34 -0700
Message-ID: <1464737614.5939.142.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464689539-15162-1-git-send-email-fw@strlen.de>
	 <1464706554.5939.105.camel@edumazet-glaptop3.roam.corp.google.com>
	 <20160531230048.GA26552@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Miroslav Kratochvil <exa.exa@gmail.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33786 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750750AbcEaXdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 19:33:36 -0400
Received: by mail-pf0-f194.google.com with SMTP id b124so449998pfb.0
        for <netdev@vger.kernel.org>; Tue, 31 May 2016 16:33:36 -0700 (PDT)
In-Reply-To: <20160531230048.GA26552@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-06-01 at 01:00 +0200, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
> > > index d783d7c..0854be3 100644
> > > --- a/net/sched/sch_hfsc.c
> > > +++ b/net/sched/sch_hfsc.c
> > > @@ -1583,6 +1583,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> > >  {
> > >  	struct hfsc_class *cl;
> > >  	int uninitialized_var(err);
> > > +	unsigned int qlen;
> > >  
> > >  	cl = hfsc_classify(skb, sch, &err);
> > >  	if (cl == NULL) {
> > > @@ -1592,6 +1593,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> > >  		return err;
> > >  	}
> > >  
> > > +	qlen = cl->qdisc->q.qlen;
> > >  	err = qdisc_enqueue(skb, cl->qdisc);
> > >  	if (unlikely(err != NET_XMIT_SUCCESS)) {
> > >  		if (net_xmit_drop_count(err)) {
> > > @@ -1601,7 +1603,7 @@ hfsc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
> > >  		return err;
> > >  	}
> > >  
> > > -	if (cl->qdisc->q.qlen == 1)
> > > +	if (qlen == 0)
> > >  		set_active(cl, qdisc_pkt_len(skb));
> > >  
> > >  	sch->q.qlen++;
> > 
> > Well, I am not sure HFSC can deal with non work conserving qdisc
> > anyway ?
> 
> As long as child qdisc dequeue() returns an skb if qlen > 0 it should
> work.

Generally speaking, a non work conserving qdisc could return NULL if it
decides to drop all packet(s) that were sitting in the queue.

Say we add a 'max sojourn time' on skbs, as yet another anti-bloat
features, in a Codel variant/extension.

HFSC does check this and eventually complains ( qdisc_warn_nonwc()),
but all its precise computations are probably wrong.

> > Call to set_active(cl, qdisc_pkt_len(skb)); would tell you that HFSC
> > does not expect another packet than @skb being the next dequeued one.
> 
> Good point.  I'll look into it in more detail but AFAIU this "only"
> means we might overshoot a defined realtime/deadline criterion,
> I don't (yet) see how it could explain Miroslavs bug report.


> > If you want to make HFSC generic, you would need a lot more changes.
> 
> Could you elaborate?

HFSC is based on packet lengths and realtime/deadline constraints.

With lazy packet lengths (if the attached children qdisc reorder
packets), this all becomes fuzzy. Which might be OK or not.

We are not helping users by silently making such decisions.
Maybe they prefer to be warned so that they can fix their setup. 

> 
> I'm not interested in e.g. tbf leaves (makes no sense to me), but I
> think it should play nice with netem, sfq, codel, fq_codel, fq, ...
> 
> I don't see any problems with fq_codel + hfsc unless I deliberately
> misconfigure fq_codel (setting extremely low mem limit, e.g. 32kbyte).

That is pure luck, then. I would not be surprised that HTB + nonwc qdisc
would actually crash in some cases.
