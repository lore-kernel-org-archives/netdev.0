From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next] bridge: Remove unnecessary vlan_put_tag in br_handle_vlan
Date: Wed, 22 Jan 2014 10:22:59 -0500
Message-ID: <52DFE253.80003@redhat.com>
References: <1390350577-4122-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29081 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755223AbaAVPXG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 10:23:06 -0500
In-Reply-To: <1390350577-4122-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/21/2014 07:29 PM, Toshiaki Makita wrote:
> br_handle_vlan() pushes HW accelerated vlan tag into skbuff when outgoing
> port is the bridge device.
> This is unnecessary because __netif_receive_skb_core() can handle skbs
> with HW accelerated vlan tag. In current implementation,
> __netif_receive_skb_core() needs to extract the vlan tag embedded in skb
> data. This could cause low network performance especially when receiving
> frames at a high frame rate on the bridge device.
> 
> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>

Acked-by: Vlad Yasevich <vyasevic@redhat.com>

-vlad

> ---
>  net/bridge/br_vlan.c | 21 ---------------------
>  1 file changed, 21 deletions(-)
> 
> diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
> index 7ffc801..4ca4d0a 100644
> --- a/net/bridge/br_vlan.c
> +++ b/net/bridge/br_vlan.c
> @@ -151,27 +151,6 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
>  	br_vlan_get_tag(skb, &vid);
>  	if (test_bit(vid, pv->untagged_bitmap))
>  		skb = br_vlan_untag(skb);
> -	else {
> -		/* Egress policy says "send tagged".  If output device
> -		 * is the  bridge, we need to add the VLAN header
> -		 * ourselves since we'll be going through the RX path.
> -		 * Sending to ports puts the frame on the TX path and
> -		 * we let dev_hard_start_xmit() add the header.
> -		 */
> -		if (skb->protocol != htons(ETH_P_8021Q) &&
> -		    pv->port_idx == 0) {
> -			/* vlan_put_tag expects skb->data to point to
> -			 * mac header.
> -			 */
> -			skb_push(skb, ETH_HLEN);
> -			skb = __vlan_put_tag(skb, skb->vlan_proto, skb->vlan_tci);
> -			if (!skb)
> -				goto out;
> -			/* put skb->data back to where it was */
> -			skb_pull(skb, ETH_HLEN);
> -			skb->vlan_tci = 0;
> -		}
> -	}
>  
>  out:
>  	return skb;
> 
