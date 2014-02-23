From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v6 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 24 Feb 2014 00:51:52 +0100
Message-ID: <20140223235152.GF6598@order.stressinduktion.org>
References: <1392329352-31606-1-git-send-email-fw@strlen.de> <1392329352-31606-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47870 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752484AbaBWXvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 18:51:54 -0500
Content-Disposition: inline
In-Reply-To: <1392329352-31606-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 13, 2014 at 11:09:12PM +0100, Florian Westphal wrote:
> +/* called if GSO skb needs to be fragmented on forward */
> +static int ip_forward_finish_gso(struct sk_buff *skb)
> +{
> +	struct dst_entry *dst = skb_dst(skb);
> +	netdev_features_t features;
> +	struct sk_buff *segs;
> +	int ret = 0;
> +
> +	features = netif_skb_dev_features(skb, dst->dev);
> +	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);

While reviewing the skb->encapsulation logic I noticed that some drivers
(mlx4 and i40e, i40evf) already started to set skb->encapsulation = 1 in
the receive path.

Maybe it would be helpful to reset skb->encapsulation to zero before
segmentation happens so we don't miss to update the fragmentation ids and
offsets on udp packets?

> +	if (IS_ERR(segs)) {
> +		kfree_skb(skb);
> +		return -ENOMEM;
> +	}
> +
> +	consume_skb(skb);
> +
> +	do {
> +		struct sk_buff *nskb = segs->next;
> +		int err;
> +
> +		segs->next = NULL;
> +		err = dst_output(segs);
> +
> +		if (err && ret == 0)
> +			ret = err;
> +		segs = nskb;
> +	} while (segs);
> +
> +	return ret;
> +}
> +

Bye,

  Hannes
