From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Mon, 27 Jan 2014 10:22:47 -0800
Message-ID: <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
	 <1390810971-23959-2-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:58541 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753869AbaA0SWy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 13:22:54 -0500
Received: by mail-bk0-f48.google.com with SMTP id ej10so3006580bkb.21
        for <netdev@vger.kernel.org>; Mon, 27 Jan 2014 10:22:53 -0800 (PST)
In-Reply-To: <1390810971-23959-2-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-01-27 at 09:22 +0100, Florian Westphal wrote:

> +/* called if GSO skb needs to be fragmented on forward.  */
> +static int ip_forward_finish_gso(struct sk_buff *skb)
> +{
> +	netdev_features_t features = netif_skb_features(skb);
> +	struct sk_buff *segs;
> +	int ret = 0;
> +
> +	segs = skb_gso_segment(skb, features & ~NETIF_F_GSO_MASK);
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

Its still unclear if this is the best strategy.

TCP stream not using DF flag are very unlikely to care if we adjust
their MTU (lowering gso_size) at this point ?
