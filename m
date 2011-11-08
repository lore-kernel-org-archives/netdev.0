From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: Re: [PATCH 5/6] [6LoWPAN] UDP header decompression
Date: Tue, 8 Nov 2011 18:40:25 +0400
Message-ID: <CALT56yOS3MWZBMTtJ4V5j+K8XGV2eLAAjsPAwD5dU7j57hLceQ@mail.gmail.com>
References: <20111102162520.GA2669@avtobot.cybertron>
	<1320251732-2934-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:56503 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754927Ab1KHOkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 09:40:33 -0500
Received: by qao25 with SMTP id 25so475390qao.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 06:40:32 -0800 (PST)
In-Reply-To: <1320251732-2934-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/11, Alexander Smirnov <alex.bluesman.smirnov@gmail.com> wrote:
> This patch provides possibility to decompress UDP headers.
> Derived from Contiki OS.

This asks to go to a separate function.

>
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---
>  net/ieee802154/6lowpan.c |   50
> +++++++++++++++++++++++++++++++++++++++++++++-
>  1 files changed, 49 insertions(+), 1 deletions(-)
>
> diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
> index 6da3357..49f42a8 100644
> --- a/net/ieee802154/6lowpan.c
> +++ b/net/ieee802154/6lowpan.c
> @@ -839,7 +839,55 @@ lowpan_process_data(struct sk_buff *skb)
>  			goto drop;
>  	}
>
> -	/* TODO: UDP header parse */
> +	/* UDP data uncompression */
> +	if (iphc0 & LOWPAN_IPHC_NH_C) {
> +		tmp = lowpan_fetch_skb_u8(skb);
> +
> +		if ((tmp & LOWPAN_NHC_UDP_MASK) == LOWPAN_NHC_UDP_ID) {
> +			struct udphdr *uh = udp_hdr(skb);
> +
> +			pr_debug("(%s): UDP header uncompression\n", __func__);
> +			switch (tmp & LOWPAN_NHC_UDP_CS_P_11) {
> +			case LOWPAN_NHC_UDP_CS_P_00:
> +				memcpy(&uh->source, &skb->data[0], 2);
> +				memcpy(&uh->dest, &skb->data[2], 2);
> +				skb_pull(skb, 4);
> +				break;
> +			case LOWPAN_NHC_UDP_CS_P_01:
> +				memcpy(&uh->source, &skb->data[0], 2);
> +				uh->dest =
> +				   skb->data[2] + LOWPAN_NHC_UDP_8BIT_PORT;
> +				skb_pull(skb, 3);
> +				break;
> +			case LOWPAN_NHC_UDP_CS_P_10:
> +				uh->source = skb->data[0] + LOWPAN_NHC_UDP_8BIT_PORT;
> +				memcpy(&uh->dest, &skb->data[1], 2);
> +				skb_pull(skb, 3);
> +				break;
> +			case LOWPAN_NHC_UDP_CS_P_11:
> +				uh->source =
> +				   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] >> 4);
> +				uh->dest =
> +				   LOWPAN_NHC_UDP_4BIT_PORT + (skb->data[0] & 0x0f);
> +				skb_pull(skb, 1);
> +				break;
> +			default:
> +				pr_debug("(%s) ERROR: unknown UDP format\n", __func__);
> +				goto drop;
> +			}
> +
> +			pr_debug("(%s): uncompressed UDP ports: src = %d, dst = %d\n",
> +					__func__, uh->source, uh->dest);
> +
> +			/* copy checksum */
> +			memcpy(&uh->check, &skb->data[0], 2);
> +			skb_pull(skb, 2);
> +		} else {
> +			pr_debug("(%s): ERROR: unsupported NH format\n",
> +								__func__);
> +			goto drop;
> +		}
> +	}
>
>  	/* Not fragmented package */
>  	hdr.payload_len = htons(skb->len);
> --
> 1.7.2.5
>
>


-- 
With best wishes
Dmitry
