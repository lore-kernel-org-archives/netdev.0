From: Christian Lamparter <chunkeey@googlemail.com>
Subject: Re: [PATCH] p54: add null pointer check before releasing socket buffer
Date: Mon, 10 Apr 2017 14:12:54 +0200
Message-ID: <3716717.OUypxXNBrR@debian64>
References: <1491801800-4371-1-git-send-email-mhjungk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, David Miller <davem@redhat.com>,
        linux-wireless@vger.kernel.org
To: Myungho Jung <mhjungk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36685 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753120AbdDJMM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 08:12:57 -0400
In-Reply-To: <1491801800-4371-1-git-send-email-mhjungk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Added linux-wireless, since this is a wireless driver)

On Sunday, April 9, 2017 10:23:20 PM CEST Myungho Jung wrote:
> Kernel panic is caused by trying to dereference null pointer. Check if
> the pointer is null before freeing space.
Do you have the kernel panic somewhere?
I think you have an even bigger problem: You see, in order to get EEPROM
readback and rx_stats feedback you need to sent a request to the firmware
and if the response's req_id cookies don't match, you end up filling up 
the very limited device address space.

As for adding if (!skb) checks. I think kfree, kfree_skb, dev_kfree_skb 
(aka consume_skb) all check for null pointers already. So the logical
thing to do would be to make dev_kfree_skb_irq (which would also fix
dev_kfree_skb_any) consistent with kfree, kfree_skb, dev_kfree_skb and
add the check there.

> Signed-off-by: Myungho Jung <mhjungk@gmail.com>
> ---
>  drivers/net/wireless/intersil/p54/txrx.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/wireless/intersil/p54/txrx.c b/drivers/net/wireless/intersil/p54/txrx.c
> index 1af7da0..8956061 100644
> --- a/drivers/net/wireless/intersil/p54/txrx.c
> +++ b/drivers/net/wireless/intersil/p54/txrx.c
> @@ -503,7 +503,9 @@ static void p54_rx_eeprom_readback(struct p54_common *priv,
>  
>  	priv->eeprom = NULL;
>  	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
> -	dev_kfree_skb_any(tmp);
> +	if (unlikely(!tmp))
> +		dev_kfree_skb_any(tmp);
> +
>  	complete(&priv->eeprom_comp);
>  }
>  
> @@ -597,7 +599,9 @@ static void p54_rx_stats(struct p54_common *priv, struct sk_buff *skb)
>  	}
>  
>  	tmp = p54_find_and_unlink_skb(priv, hdr->req_id);
> -	dev_kfree_skb_any(tmp);
> +	if (unlikely(!tmp))
> +		dev_kfree_skb_any(tmp);
> +
>  	complete(&priv->stat_comp);
>  }
>  
> 
