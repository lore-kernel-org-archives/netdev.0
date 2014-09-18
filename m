From: Prashant Sreedharan <prashant@broadcom.com>
Subject: Re: [PATCH] tg3: Work around HW/FW limitations with vlan
 encapsulated frames
Date: Thu, 18 Sep 2014 16:00:21 -0700
Message-ID: <1411081221.18724.84.camel@prashant>
References: <1411050677-28147-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Vladislav Yasevich <vyasevic@redhat.com>,
	Michael Chan <mchan@broadcom.com>
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:18234 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750895AbaIRXKS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 19:10:18 -0400
In-Reply-To: <1411050677-28147-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 10:31 -0400, Vladislav Yasevich wrote:
> TG3 appears to have an issue performing TSO and checksum offloading
> correclty when the frame has been vlan encapsulated (non-accelrated).
> In these cases, tcp checksum is not correctly updated.

Yes that is true for inline vlan headers, to clarify was TSO and
checksum offload working for accelerated 802.1ad packets ? 

> This patch attempts to work around this issue.  After the patch,
> 802.1ad vlans start working correctly over tg3 devices.
> 
> CC: Prashant Sreedharan <prashant@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
> ---
>  drivers/net/ethernet/broadcom/tg3.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
> index cb77ae9..e7d3a62 100644
> --- a/drivers/net/ethernet/broadcom/tg3.c
> +++ b/drivers/net/ethernet/broadcom/tg3.c
> @@ -7914,8 +7914,6 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	entry = tnapi->tx_prod;
>  	base_flags = 0;
> -	if (skb->ip_summed == CHECKSUM_PARTIAL)
> -		base_flags |= TXD_FLAG_TCPUDP_CSUM;
>  
>  	mss = skb_shinfo(skb)->gso_size;
>  	if (mss) {
> @@ -7929,6 +7927,13 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  		hdr_len = skb_transport_offset(skb) + tcp_hdrlen(skb) - ETH_HLEN;
>  
> +		/* HW/FW can not correctly segment packets that have been
> +		 * vlan encapsulated.
> +		 */
> +		if (skb->protocol == htons(ETH_P_8021Q) ||
> +		    skb->protocol == htons(ETH_P_8021AD))
> +			return tg3_tso_bug(tp, tnapi, txq, skb);

I think skb_gso_segment() would return skbs that would still have
checksum offloaded to the chip.
 
> +
>  		if (!skb_is_gso_v6(skb)) {
>  			if (unlikely((ETH_HLEN + hdr_len) > 80) &&
>  			    tg3_flag(tp, TSO_BUG))
> @@ -7979,6 +7984,17 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  				base_flags |= tsflags << 12;
>  			}
>  		}
> +	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		/* HW/FW can not correctly checksum packets that have been
> +		 * vlan encapsulated.
> +		 */
> +		if (skb->protocol == htons(ETH_P_8021Q) ||
> +		    skb->protocol == htons(ETH_P_8021AD)) {
> +			if (skb_checksum_help(skb))
> +				goto drop;
> +		} else  {
> +			base_flags |= TXD_FLAG_TCPUDP_CSUM;
> +		}
>  	}
>  
>  	if (tg3_flag(tp, USE_JUMBO_BDFLAG) &&

Instead of the above workarounds since the chips supported by tg3 does
not support checksum offload and TSO for inline vlan headers, these
features can be disabled/cleared in dev->vlan_features. Side effect is
accelerated vlan headers will also have TSO and checksum offload
disabled.

Also as part of this review, found a problem with the receive section of
the driver it was not checking for 802.1ad vlan protocol and dropping
802.1ad vlan packets of size > mtu + ETH_HLEN

diff --git a/drivers/net/ethernet/broadcom/tg3.c
b/drivers/net/ethernet/broadcom/tg3.c
index cb77ae9..620887a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6918,7 +6918,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int
budget)
                skb->protocol = eth_type_trans(skb, tp->dev);
 
                if (len > (tp->dev->mtu + ETH_HLEN) &&
-                   skb->protocol != htons(ETH_P_8021Q)) {
+                   skb->protocol != htons(ETH_P_8021Q) &&
+                   skb->protocol != htons(ETH_P_8021AD)) {
                        dev_kfree_skb_any(skb);
                        goto drop_it_no_recycle;
                }
