From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND] [RFC PATCH] bonding: Do not tx-balance some IPv6
 packets on ALB/TLB bonds
Date: Fri, 29 Aug 2008 14:08:06 -0700 (PDT)
Message-ID: <20080829.140806.130290207.davem@davemloft.net>
References: <48B6FEC1.7090508@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40429
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750842AbYH2VIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 17:08:11 -0400
In-Reply-To: <48B6FEC1.7090508@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 28 Aug 2008 15:38:41 -0400

> It's been more then a month and still no replies.  Is this just
> not interesting, or did this get lost in the shuffle...
> 
> Please take a look.  This patch makes ALB/TLB modes work much more
> reliably with IPv6.

Jeff, or someone, please be sure to pick this up.

Thanks.

> I've been trying to configure IPv6 on ALB and TLB bonds and have found
> that there is a 50-50 chance that IPv6 doesn't configure a global address
> on such bond.  After further investigation, it appears that DAD probes are
> tx-balanced between the bond members.  When the DAD probe is sent on the
> secondary device, it ends up arriving back on the primary, since that interface
> is also in the multicast group.  As a result, we get a false positive duplicate
> address and fail to configure a global IPv6 address.  The easy solution seems
> to be to not tx-balance DAD problems.  Also, we should probably not balance
> all-note-mulicasts as well since they are the equivalent of IPv4 broadcasts.
> 
> ---
> 
> IPv6 all-node-multicasts and DAD probes should not be tx-balanced
> on ALB/TLB bonds.  The all-node-multicast is an equivalent to IPv4
> broadcasts.  DAD probes have to be sent only on the primary so that
> we don't get false-positive detections.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> ---
>  drivers/net/bonding/bond_alb.c |   24 ++++++++++++++++++++++++
>  1 files changed, 24 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index 5a67372..684440c 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -38,6 +38,7 @@
>  #include <linux/in.h>
>  #include <net/ipx.h>
>  #include <net/arp.h>
> +#include <net/ipv6.h>
>  #include <asm/byteorder.h>
>  #include "bonding.h"
>  #include "bond_alb.h"
> @@ -81,6 +82,7 @@
>  #define RLB_PROMISC_TIMEOUT	10*ALB_TIMER_TICKS_PER_SEC
>  
>  static const u8 mac_bcast[ETH_ALEN] = {0xff,0xff,0xff,0xff,0xff,0xff};
> +static const u8 mac_v6_allmcast[ETH_ALEN] = {0x33,0x33,0x00,0x00,0x00,0x01};
>  static const int alb_delta_in_ticks = HZ / ALB_TIMER_TICKS_PER_SEC;
>  
>  #pragma pack(1)
> @@ -1288,6 +1290,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  	u32 hash_index = 0;
>  	const u8 *hash_start = NULL;
>  	int res = 1;
> +	struct ipv6hdr *ip6hdr;
>  
>  	skb_reset_mac_header(skb);
>  	eth_data = eth_hdr(skb);
> @@ -1317,11 +1320,32 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  	}
>  		break;
>  	case ETH_P_IPV6:
> +		/* IPv6 doesn't really use broadcast mac address, but leave
> +		 * that here just in case.
> +		 */
>  		if (memcmp(eth_data->h_dest, mac_bcast, ETH_ALEN) == 0) {
>  			do_tx_balance = 0;
>  			break;
>  		}
>  
> +		/* IPv6 uses all-nodes multicast as an equivalent to
> +		 * broadcasts in IPv4.
> +		 */
> +		if (memcmp(eth_data->h_dest, mac_v6_allmcast, ETH_ALEN) == 0) {
> +			do_tx_balance = 0;
> +			break;
> +		}
> +
> +		/* Additianally, DAD probes should not be tx-balanced as that
> +		 * will lead to false positives for duplicate addresses and
> +		 * prevent address configuration from working.
> +		 */
> +		ip6hdr = ipv6_hdr(skb);
> +		if (ipv6_addr_any(&ip6hdr->saddr)) {
> +			do_tx_balance = 0;
> +			break;
> +		}
> +
>  		hash_start = (char *)&(ipv6_hdr(skb)->daddr);
>  		hash_size = sizeof(ipv6_hdr(skb)->daddr);
>  		break;
> -- 
> 1.5.3.5
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
