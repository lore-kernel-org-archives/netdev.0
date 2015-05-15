From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next 2/3] net: sched: remove AT INGRESS/EGRESS
Date: Fri, 15 May 2015 19:21:15 +0200
Message-ID: <20150515172115.GK6179@breakpoint.cc>
References: <1431679850-31896-1-git-send-email-fw@strlen.de>
 <1431679850-31896-3-git-send-email-fw@strlen.de>
 <20150515162319.GA8234@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	jhs@mojatatu.com, daniel@iogearbox.net
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:49143 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752969AbbEORVS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 13:21:18 -0400
Content-Disposition: inline
In-Reply-To: <20150515162319.GA8234@Alexeis-MBP.westell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <alexei.starovoitov@gmail.com> wrote:
> > diff --git a/net/core/dev.c b/net/core/dev.c
> > index 0e7afef..802b9b9 100644
> > --- a/net/core/dev.c
> > +++ b/net/core/dev.c
> > @@ -3071,9 +3071,6 @@ static int __dev_queue_xmit(struct sk_buff *skb, void *accel_priv)
> >  	txq = netdev_pick_tx(dev, skb, accel_priv);
> >  	q = rcu_dereference_bh(txq->qdisc);
> >  
> > -#ifdef CONFIG_NET_CLS_ACT
> > -	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_EGRESS);
> > -#endif
> 
> I don't think it's a good change.
> Squeezing 4 bits into 2 by losing AT_STACK condition, imo, is wrong.

Its right, IMO.

> Before ifb could differentiate AT_STACK and AT_EGRESS, but when
> they're aliased we lose this information.

IFB refuses to work with skbs that did not come in via mirred.
So, from ifb point of view it makes no difference, G_TC_FROM+AT_STACK
causes skb to be dropped and IFB doesn't care about G_TC_AT() at all.

So the change is compatible: zero state == "mirred did not see this skb"
-> drop

> I think we shmuld keep AT_STACK, AT_INGRESS, AT_EGRESS.

We have dozens of combinations that either cannot happen
from concept point of view (skb is AT_EGRESS or its coming in,
it can't be both logically) or because no code path uses/sets it.

For G_TC_AT(), we only have two cases: egress (since
everything is attached to qdisc / coming in via dev_queue_xmit thats
the "normal case", and the special ingress one, which is what the new
TC_AT_INGRESS state is for.  The ingress case is also "special" because
it can only turn back to 0 (no mirred action attached to ingress) or
change to TC_FROM_INGRESS (when mirred grabs it).

The existing G_TC_AT is is irrelevant for IFB since ifb is reachable only
called via ndo_start_xmit so its always at egress.

skb_tc_state enum just tells us what do to with the skb --
back to ingress or transmit via device.

AT_STACK cannot even happen for the G_TC_AT case from looking at the
code since dev_queue_xmit forces AT_EGRESS & rx sets AT_INGRESS.

And for FROM its only relevant in ifb to detect skb that wasn't seen by
mirred.  And we keep this functionality via 0 skb_tc_state.

I did a test patch with Jamals suggestion (continue using macros, just
close holes), but I see no gain: we get 5 bits that are used for
automaton that only has/cares about 4 possible (distinct) skb states.
