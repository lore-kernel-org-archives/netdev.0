From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net] xen-netback: Fix slot estimation
Date: Tue, 3 Jun 2014 13:37:12 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD038E22E@AMSPEX01CL01.citrite.net>
References: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	"linux@eikelenboom.it" <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:26803 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbaFCNhO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 09:37:14 -0400
In-Reply-To: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Zoltan Kiss
> Sent: 03 June 2014 14:32
> To: xen-devel@lists.xenproject.org; Ian Campbell; Wei Liu; Paul Durrant;
> linux@eikelenboom.it
> Cc: netdev@vger.kernel.org; David Vrabel; davem@davemloft.net; Zoltan
> Kiss
> Subject: [PATCH net] xen-netback: Fix slot estimation
> 
> A recent commit (a02eb4 "xen-netback: worse-case estimate in
> xenvif_rx_action is
> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that
> triggers
> the next BUG_ON a few lines down, as the packet consumes more slots than
> estimated.
> This patch remove that cap, and if the frontend doesn't provide enough slot,
> put back the skb to the top of the queue and caps rx_last_skb_slots. When
> the
> next try also fails, it drops the packet.
> Capping rx_last_skb_slots is needed because if the frontend never gives
> enough
> slots, the ring gets stalled.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-
> netback/netback.c
> index da85ffb..7164157 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -600,13 +600,6 @@ static void xenvif_rx_action(struct xenvif *vif)
>  							 PAGE_SIZE);
>  		}
> 
> -		/* To avoid the estimate becoming too pessimal for some
> -		 * frontends that limit posted rx requests, cap the estimate
> -		 * at MAX_SKB_FRAGS.
> -		 */
> -		if (max_slots_needed > MAX_SKB_FRAGS)
> -			max_slots_needed = MAX_SKB_FRAGS;
> -
>  		/* We may need one more slot for GSO metadata */
>  		if (skb_is_gso(skb) &&
>  		   (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4 ||
> @@ -615,9 +608,27 @@ static void xenvif_rx_action(struct xenvif *vif)
> 
>  		/* If the skb may not fit then bail out now */
>  		if (!xenvif_rx_ring_slots_available(vif, max_slots_needed)) {
> +			/* If the skb needs more than MAX_SKB_FRAGS
> slots, it
> +			 * can happen that the frontend never gives us
> enough.
> +			 * To avoid spining on that packet, first we put it back
> +			 * to the top of the queue, but if the next try fail,
> +			 * we drop it.
> +			 */
> +			if (max_slots_needed > MAX_SKB_FRAGS &&
> +			    vif->rx_last_skb_slots == MAX_SKB_FRAGS) {

Isn't it sufficient to say:

if (vif->rx_last_skb_slots != 0)

here? We should not ordinarily wake before the requisite number of slots is available.

  Paul

> +				kfree_skb(skb);
> +				vif->rx_last_skb_slots = 0;
> +				continue;
> +			}
>  			skb_queue_head(&vif->rx_queue, skb);
>  			need_to_notify = true;
> -			vif->rx_last_skb_slots = max_slots_needed;
> +			/* Cap this otherwise if the guest never gives us
> +			 * enough slot, rx_work_todo will spin
> +			 */
> +			vif->rx_last_skb_slots =
> +				max_slots_needed > MAX_SKB_FRAGS ?
> +				MAX_SKB_FRAGS :
> +				max_slots_needed;
>  			break;
>  		} else
>  			vif->rx_last_skb_slots = 0;
