From: Ingo Oeser <ioe-lkml@rameria.de>
Subject: Re: [git patches] net driver fixes
Date: Mon, 15 Sep 2008 00:51:08 +0200
Message-ID: <200809150051.10293.ioe-lkml@rameria.de>
References: <20080913203548.GA2989@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755863AbYINWvY@vger.kernel.org>
In-Reply-To: <20080913203548.GA2989@havoc.gtf.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,


On Saturday 13 September 2008, Jeff Garzik wrote:
> Vlad Yasevich (1):
>       bonding: Do not tx-balance some IPv6 packets on ALB/TLB bonds

Regarding this change and include/linux/etherdevice.h

> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index b211486..c219262 100644
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
> @@ -1290,6 +1292,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  	u32 hash_index = 0;
>  	const u8 *hash_start = NULL;
>  	int res = 1;
> +	struct ipv6hdr *ip6hdr;
>  
>  	skb_reset_mac_header(skb);
>  	eth_data = eth_hdr(skb);
> @@ -1319,11 +1322,32 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>  	}
>  		break;
>  	case ETH_P_IPV6:
> +		/* IPv6 doesn't really use broadcast mac address, but leave
> +		 * that here just in case.
> +		 */
>  		if (memcmp(eth_data->h_dest, mac_bcast, ETH_ALEN) == 0) {

Didn't someone introduce compare_ether_addr() just for this?

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

compare_ether_addr()

Maybe fix this in a followup patch?


Best Regards

Ingo Oeser
