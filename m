From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Sun, 26 Jan 2014 10:22:28 +0100
Message-ID: <20140126092228.GF24041@breakpoint.cc>
References: <1390690127-559-1-git-send-email-fw@strlen.de>
 <1390690127-559-3-git-send-email-fw@strlen.de>
 <1390700277.27806.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:34123 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752780AbaAZJW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jan 2014 04:22:29 -0500
Content-Disposition: inline
In-Reply-To: <1390700277.27806.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > +static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
> > +{
> > +	unsigned len;
> > +
> > +	if (skb->local_df)
> > +		return false;
> > +	len = skb_is_gso(skb) ? skb_gso_network_seglen(skb) : skb->len;
> > +
> > +	return len > mtu;
> 
> The function should avoid extra computation/tests for small packets.
> 
> if (skb->len <= mtu || skb->local_df)
> 	return false;

Good idea!  Will change it as per your suggestion.

> if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
> 	return false;
> 
> return true;
> 
> > +}
> > +
> > +/* called if GSO skb needs to be fragmented on forward.  */
> > +static int ip_forward_finish_gso(struct sk_buff *skb)
> > +{
> > +	struct sk_buff *segs = skb_gso_segment(skb, 0);
> 
> 0 is very pessimistic.
> 
> Have you tried :
> 
> netdev_features_t features = netif_skb_features(skb); 
> struct sk_buff *segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);

No.  I'll see if this works for me, then include it in V2.

Thanks Eric.
