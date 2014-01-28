From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Tue, 28 Jan 2014 01:27:07 +0100
Message-ID: <20140128002707.GA12308@order.stressinduktion.org>
References: <1390810971-23959-1-git-send-email-fw@strlen.de> <1390810971-23959-2-git-send-email-fw@strlen.de> <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:40994 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbaA1A1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 19:27:08 -0500
Content-Disposition: inline
In-Reply-To: <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 27, 2014 at 10:22:47AM -0800, Eric Dumazet wrote:
> On Mon, 2014-01-27 at 09:22 +0100, Florian Westphal wrote:
> 
> > +/* called if GSO skb needs to be fragmented on forward.  */
> > +static int ip_forward_finish_gso(struct sk_buff *skb)
> > +{
> > +	netdev_features_t features = netif_skb_features(skb);

netif_skb_features uses skb->dev for determination of offloading features but
we actually need rt->dst.dev, no?

> > +	struct sk_buff *segs;
> > +	int ret = 0;
> > +
> > +	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
> > +	if (IS_ERR(segs)) {
> > +		kfree_skb(skb);
> > +		return -ENOMEM;
> > +	}
> > +
> > +	consume_skb(skb);
> > +
> > +	do {
> > +		struct sk_buff *nskb = segs->next;
> > +		int err;
> > +
> > +		segs->next = NULL;
> > +		err = dst_output(segs);
> > +
> > +		if (err && ret == 0)
> > +			ret = err;
> > +		segs = nskb;
> > +	} while (segs);
> > +
> > +	return ret;
> > +}
> > +
> 
> Its still unclear if this is the best strategy.
> 
> TCP stream not using DF flag are very unlikely to care if we adjust
> their MTU (lowering gso_size) at this point ?

UDP shouldn't be a problem, too.

Greetings,

  Hannes
