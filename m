From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: RFC: net: allow to propagate errors through
 ->ndo_hard_start_xmit()
Date: Tue, 10 Nov 2009 18:57:36 +0100
Message-ID: <20091110175736.GB4195@ami.dom.local>
References: <4AF87070.6020007@trash.net>
 <20091110170838.GA4195@ami.dom.local>
 <4AF9A36F.7070807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:61819 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755366AbZKJSKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 13:10:49 -0500
Received: by bwz27 with SMTP id 27so299891bwz.21
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 10:10:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4AF9A36F.7070807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 06:31:27PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
> > On Mon, Nov 09, 2009 at 08:41:36PM +0100, Patrick McHardy wrote:
> >> I've updated my patch to propagate error values (errno and NET_XMIT
> >> codes) through ndo_hard_start_xmit() and incorporated the suggestions
> >> made last time, namely:
> >>
> >> - move slightly complicated return value check to inline function and
> >>   add a few comments
> >>
> >> - fix error handling while in the middle of transmitting GSO skbs
> >>
> >> I've also audited the tree once again for invalid return values and
> >> found a single remaining instance in a Wimax driver, I'll take care
> >> of that later.
> >>
> >> Two questions remain:
> >>
> >> - I'm not sure the error handling in dev_hard_start_xmit() for GSO
> >>   skbs is optimal. When the driver returns an error, it is assumed
> >>   the current segment has been freed. The patch then frees the
> >>   entire GSO skb, including all remaining segments. Alternatively
> >>   it could try to transmit the remaining segments later.
> > 
> > Anyway, it seems this freeing should be described in the changelog,
> > if not moved to a separate patch, since it fixes another problem,
> > unless I forgot something.
> 
> What other problem are you refering to? I'm not aware of any
> problems in the existing function.

This patch is about propagating errors, so it's not clear why there
are some additional kfrees mixed with this. (But I see it's explained
below.)

> 
> >> diff --git a/net/core/dev.c b/net/core/dev.c
> >> index bf629ac..1f5752d 100644
> >> --- a/net/core/dev.c
> >> +++ b/net/core/dev.c
> >> @@ -1756,7 +1756,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
> >>  			struct netdev_queue *txq)
> >>  {
> >>  	const struct net_device_ops *ops = dev->netdev_ops;
> >> -	int rc;
> >> +	int rc = NETDEV_TX_OK;
> > 
> > Isn't it enough to add this in one place only: before this
> > "goto out_kfree_skb"?
> 
> Its only exists once in the version I sent out earlier.
> 
> >>  	if (likely(!skb->next)) {
> >>  		if (!list_empty(&ptype_all))
> >> @@ -1804,6 +1804,8 @@ gso:
> >>  		nskb->next = NULL;
> >>  		rc = ops->ndo_start_xmit(nskb, dev);
> >>  		if (unlikely(rc != NETDEV_TX_OK)) {
> >> +			if (rc & ~NETDEV_TX_MASK)
> >> +				goto out_kfree_gso_skb;
> > 
> > If e.g. (rc == NETDEV_TX_OK | NET_XMIT_CN), why exactly is this freeing
> > necessary now?
> > 
> > Is e.g. (rc == NETDEV_TX_BUSY | NET_XMIT_CN) legal? If so, there would
> > be use after kfree, I guess. Otherwise, it should be documented above
> > (and maybe checked somewhere as well).
> 
> NET_XMIT_CN is a valid return value, yes. But its not freeing the
> transmitted segment but the remaining ones. Its not strictly
> necessary, but its the easiest way to treat all errors similar.
> Otherwise you get complicated cases, f.i. when the driver returns
> NET_XMIT_CN for the first segment and NETDEV_TX_OK for the
> remaining ones.

It should be in the changelog and maybe a comment too. Even if it's
right it's a change of functionality/behavior here.

I still don't know if/why (rc == NETDEV_TX_BUSY | NET_XMIT_CN) is
OK. IMHO skb will be requeued after kfree here.

> 
> >>  			nskb->next = skb->next;
> >>  			skb->next = nskb;
> >>  			return rc;
> >> @@ -1813,11 +1815,14 @@ gso:
> >>  			return NETDEV_TX_BUSY;
> >>  	} while (skb->next);
> >>  
> >> -	skb->destructor = DEV_GSO_CB(skb)->destructor;
> >> +	rc = NETDEV_TX_OK;
> > 
> > When is (rc != NETDEV_TX_OK) possible in this place?
> 
> Its gone in the current version.

Why don't you send the current version?

Jarek P.
