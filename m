From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] xen-netback: Fix slot estimation
Date: Tue, 3 Jun 2014 13:52:32 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1725674B@AcuExch.aculab.com>
References: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"david.vrabel@citrix.com" <david.vrabel@citrix.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: 'Zoltan Kiss' <zoltan.kiss@citrix.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	"ian.campbell@citrix.com" <ian.campbell@citrix.com>,
	"wei.liu2@citrix.com" <wei.liu2@citrix.com>,
	"paul.durrant@citrix.com" <paul.durrant@citrix.com>,
	"linux@eikelenboom.it" <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36891 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753862AbaFCNwy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 09:52:54 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 13863-02 for <netdev@vger.kernel.org>;
 Tue,  3 Jun 2014 14:52:46 +0100 (BST)
In-Reply-To: <1401802336-25182-1-git-send-email-zoltan.kiss@citrix.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: netdev-owner@vger.kernel.org
> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
> the next BUG_ON a few lines down, as the packet consumes more slots than
> estimated.
> This patch remove that cap, and if the frontend doesn't provide enough slot,
> put back the skb to the top of the queue and caps rx_last_skb_slots. When the
> next try also fails, it drops the packet.
> Capping rx_last_skb_slots is needed because if the frontend never gives enough
> slots, the ring gets stalled.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> Cc: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
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
> +			/* If the skb needs more than MAX_SKB_FRAGS slots, it
> +			 * can happen that the frontend never gives us enough.
> +			 * To avoid spining on that packet, first we put it back
> +			 * to the top of the queue, but if the next try fail,
> +			 * we drop it.
> +			 */
> +			if (max_slots_needed > MAX_SKB_FRAGS &&
> +			    vif->rx_last_skb_slots == MAX_SKB_FRAGS) {
> +				kfree_skb(skb);
> +				vif->rx_last_skb_slots = 0;
> +				continue;
> +			}

A silent discard here doesn't seem right at all.
While it stops the kernel crashing, or the entire interface locking
up; it is likely to leave one connection 'stuck' - a TCP retransmission
is likely to include the same fragments.
>From a user point of view this as almost as bad.

	David

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
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
