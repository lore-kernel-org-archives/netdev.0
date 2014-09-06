From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH 3/9] net: Move main gso loop out of
 dev_hard_start_xmit() into helper.
Date: Sat, 6 Sep 2014 17:38:08 +0300
Message-ID: <20140906173808.049f18ed@halley>
References: <20140901.152450.815155429225102019.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:48613 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352AbaIFOiW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2014 10:38:22 -0400
Received: by mail-wg0-f46.google.com with SMTP id n12so1926134wgh.29
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 07:38:20 -0700 (PDT)
In-Reply-To: <20140901.152450.815155429225102019.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 01 Sep 2014 15:24:50 -0700 (PDT) David Miller <davem@davemloft.net> wrote:
> @@ -2681,25 +2709,7 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
>  	}
>  
>  gso:
> -	do {
> -		struct sk_buff *nskb = skb->next;
> -
> -		skb->next = nskb->next;
> -		nskb->next = NULL;
> -
> -		rc = xmit_one(nskb, dev, txq);
> -		if (unlikely(rc != NETDEV_TX_OK)) {
> -			if (rc & ~NETDEV_TX_MASK)
> -				goto out_kfree_gso_skb;
> -			nskb->next = skb->next;
> -			skb->next = nskb;
> -			return rc;
> -		}
> -		if (unlikely(netif_xmit_stopped(txq) && skb->next))
> -			return NETDEV_TX_BUSY;
> -	} while (skb->next);
> -
> -out_kfree_gso_skb:
> +	skb->next = xmit_list(skb->next, dev, txq, &rc);
>  	if (likely(skb->next == NULL)) {
>  		skb->destructor = DEV_GSO_CB(skb)->destructor;
>  		consume_skb(skb);
> 	}
> out_kfree_skb:
> 	kfree_skb(skb);

Formely, if 'netif_xmit_stopped(txq) && skb->next', NETDEV_TX_BUSY was
returned, but the head 'skb' wasn't freed;
Currently, if 'xmit_list' returns non-NULL due to same reason, head skb
gets freed in out_kfree_skb.

I'm not certain, but it looks like an oversight that got fixed later in
the patchset:
In net-next ce93718fb "net: Don't keep around original SKB when we
software segment GSO frames." the 'kfree_skb(skb)' in
'dev_hard_start_xmit' got relocated into validate_xmit_skb's gso
segmentation part, making the issue disappear.

Am I right? Didn't we miss anything else here?
