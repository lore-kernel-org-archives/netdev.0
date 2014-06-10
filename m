From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next 2/2] mac802154: don't deliver packets to
 devices that are down
Date: Tue, 10 Jun 2014 10:23:15 -0700
Message-ID: <1402420995.3645.435.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1402416671-30305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
	 <1402416671-30305-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:47360 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbaFJRXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 13:23:17 -0400
Received: by mail-pb0-f41.google.com with SMTP id uo5so6488855pbc.0
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 10:23:16 -0700 (PDT)
In-Reply-To: <1402416671-30305-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-10 at 18:11 +0200, Phoebe Buckheister wrote:
> Only one WPAN devices can be active at any given time, so only deliver
> packets to that one interface that is actually up. Multiple monitors may
> be up at any given time, but we don't have to deliver to monitors that
> are down either.



> diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
> index 0597b96..46440b9 100644
> --- a/net/mac802154/rx.c
> +++ b/net/mac802154/rx.c
> @@ -64,19 +64,22 @@ mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
>  
>  		if (skb->len < 2) {
>  			pr_debug("got invalid frame\n");
> -			goto out;
> +			goto fail;
>  		}
>  		crc = crc_ccitt(0, skb->data, skb->len);
>  		if (crc) {
>  			pr_debug("CRC mismatch\n");
> -			goto out;
> +			goto fail;
>  		}
>  		skb_trim(skb, skb->len - 2); /* CRC */
>  	}
>  
>  	mac802154_monitors_rx(priv, skb);
>  	mac802154_wpans_rx(priv, skb);
> -out:
> +
> +	return;
> +
> +fail:
>  	dev_kfree_skb(skb);

This should be kfree_skb(), because we drop the packet, and should be
drop_monitor friendly
