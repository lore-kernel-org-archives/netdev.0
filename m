From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Re: iproute2 / tbf with large burst seems broken again
Date: Mon, 31 Aug 2009 05:30:27 +0000
Message-ID: <20090831053026.GA5005@ff.dom.local>
References: <200908251518.00762.denys@visp.net.lb> <20090826215956.GA5148@ami.dom.local> <20090830.220559.77181973.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: denys@visp.net.lb, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:58029 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752016AbZHaFab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 01:30:31 -0400
Received: by fxm17 with SMTP id 17so2558415fxm.37
        for <netdev@vger.kernel.org>; Sun, 30 Aug 2009 22:30:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090830.220559.77181973.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 30, 2009 at 10:05:59PM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 26 Aug 2009 23:59:56 +0200
> 
> > Denys Fedoryschenko wrote, On 08/25/2009 02:18 PM:
> > ...
> >> Just maybe good idea in next kernels to document this or handle overflow, that 
> >> it will give warning in kernel. Otherwise user will have non-functional qdisc 
> >> that will not pass traffic.
> > 
> > OK, if this patch works for you send your Tested-by, please.
> 
> Denys, please give Jarek's patch some testing and let us know
> if it triggers properly for you.

Actually, I think now, after 2.6.31, this patch might be a bit too
late. If people hit this problem they probably should've fixed it
until -next already, so let's forget about this patch until there are
more such reports.

Btw, I guess, Denys could submit some warnings into iproute's code
and/or documentation, as he proposed earlier.

Thanks,
Jarek P.

> > ---------------->
> > pkt_sched: Warn on tokens overflow in tbf_dequeue
> > 
> > After recent change of scheduling resolution some "extreme" configs
> > can cause token overflows with stalls. This patch warns when tokens
> > were negative before accounting for a packet length.
> > 
> > Reported-by: Denys Fedoryschenko <denys@visp.net.lb>
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > ---
> > 
> >  net/sched/sch_tbf.c |    6 ++++++
> >  1 files changed, 6 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
> > index e22dfe8..ef191c4 100644
> > --- a/net/sched/sch_tbf.c
> > +++ b/net/sched/sch_tbf.c
> > @@ -191,6 +191,12 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
> >  			return skb;
> >  		}
> >  
> > +		if (unlikely((long)(toks + L2T(q, len)) < 0 ||
> > +			     (long)(ptoks + L2T_P(q, len) < 0)))
> > +			if (net_ratelimit())
> > +				pr_warning("tbf: tokens overflow;"
> > +					   " fix limits.\n");
> > +
> >  		qdisc_watchdog_schedule(&q->watchdog,
> >  					now + max_t(long, -toks, -ptoks));
> >  
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
