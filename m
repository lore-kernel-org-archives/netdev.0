From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH v2 net] bonding: prevent out of bound accesses
Date: Fri, 1 Jul 2016 09:09:25 +0800
Message-ID: <5775C2C5.4050603@huawei.com>
References: <1467291379.11238.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <1467296021.11238.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:62495 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751713AbcGABJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 21:09:49 -0400
In-Reply-To: <1467296021.11238.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016/6/30 22:13, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> ether_addr_equal_64bits() requires some care about its arguments,
> namely that 8 bytes might be read, even if last 2 byte values are not
> used.
> 
> KASan detected a violation with null_mac_addr and lacpdu_mcast_addr
> in bond_3ad.c
> 
> Same problem with mac_bcast[] and mac_v6_allmcast[] in bond_alb.c :
> Although the 8-byte alignment was there, KASan would detect out
> of bound accesses.
> 
> Fixes: 815117adaf5b ("bonding: use ether_addr_equal_unaligned for bond addr compare")
> Fixes: bb54e58929f3 ("bonding: Verify RX LACPDU has proper dest mac-addr")
> Fixes: 885a136c52a8 ("bonding: use compare_ether_addr_64bits() in ALB")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---
>  drivers/net/bonding/bond_3ad.c |   11 +++++++----
>  drivers/net/bonding/bond_alb.c |    7 ++-----
>  include/net/bonding.h          |    7 ++++++-
>  3 files changed, 15 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
> index ca81f46ea1aa..8ad491ab1d01 100644
> --- a/drivers/net/bonding/bond_3ad.c
> +++ b/drivers/net/bonding/bond_3ad.c
> @@ -101,11 +101,14 @@ enum ad_link_speed_type {
>  #define MAC_ADDRESS_EQUAL(A, B)	\
>  	ether_addr_equal_64bits((const u8 *)A, (const u8 *)B)
>  
> -static struct mac_addr null_mac_addr = { { 0, 0, 0, 0, 0, 0 } };
> +static const u8 null_mac_addr[ETH_ALEN + 2] __long_aligned = {
> +	0, 0, 0, 0, 0, 0
> +};
>  static u16 ad_ticks_per_sec;
>  static const int ad_delta_in_ticks = (AD_TIMER_INTERVAL * HZ) / 1000;
>  
> -static const u8 lacpdu_mcast_addr[ETH_ALEN] = MULTICAST_LACPDU_ADDR;
> +static const u8 lacpdu_mcast_addr[ETH_ALEN + 2] __long_aligned =
> +	MULTICAST_LACPDU_ADDR;
>  
>  /* ================= main 802.3ad protocol functions ================== */
>  static int ad_lacpdu_send(struct port *port);
> @@ -1739,7 +1742,7 @@ static void ad_clear_agg(struct aggregator *aggregator)
>  		aggregator->is_individual = false;
>  		aggregator->actor_admin_aggregator_key = 0;
>  		aggregator->actor_oper_aggregator_key = 0;
> -		aggregator->partner_system = null_mac_addr;
> +		eth_zero_addr(aggregator->partner_system.mac_addr_value);
>  		aggregator->partner_system_priority = 0;
>  		aggregator->partner_oper_aggregator_key = 0;
>  		aggregator->receive_state = 0;
> @@ -1761,7 +1764,7 @@ static void ad_initialize_agg(struct aggregator *aggregator)
>  	if (aggregator) {
>  		ad_clear_agg(aggregator);
>  
> -		aggregator->aggregator_mac_address = null_mac_addr;
> +		eth_zero_addr(aggregator->aggregator_mac_address.mac_addr_value);
>  		aggregator->aggregator_identifier = 0;
>  		aggregator->slave = NULL;
>  	}
> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
> index c5ac160a8ae9..551f0f8dead3 100644
> --- a/drivers/net/bonding/bond_alb.c
> +++ b/drivers/net/bonding/bond_alb.c
> @@ -42,13 +42,10 @@
>  
>  
>  
> -#ifndef __long_aligned
> -#define __long_aligned __attribute__((aligned((sizeof(long)))))
> -#endif
> -static const u8 mac_bcast[ETH_ALEN] __long_aligned = {
> +static const u8 mac_bcast[ETH_ALEN + 2] __long_aligned = {
>  	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
>  };
> -static const u8 mac_v6_allmcast[ETH_ALEN] __long_aligned = {
> +static const u8 mac_v6_allmcast[ETH_ALEN + 2] __long_aligned = {
>  	0x33, 0x33, 0x00, 0x00, 0x00, 0x01
>  };
>  static const int alb_delta_in_ticks = HZ / ALB_TIMER_TICKS_PER_SEC;
> diff --git a/include/net/bonding.h b/include/net/bonding.h
> index 791800ddd6d9..6360c259da6d 100644
> --- a/include/net/bonding.h
> +++ b/include/net/bonding.h
> @@ -34,6 +34,9 @@
>  
>  #define BOND_DEFAULT_MIIMON	100
>  
> +#ifndef __long_aligned
> +#define __long_aligned __attribute__((aligned((sizeof(long)))))
> +#endif
>  /*
>   * Less bad way to call ioctl from within the kernel; this needs to be
>   * done some other way to get the call out of interrupt context.
> @@ -138,7 +141,9 @@ struct bond_params {
>  	struct reciprocal_value reciprocal_packets_per_slave;
>  	u16 ad_actor_sys_prio;
>  	u16 ad_user_port_key;
> -	u8 ad_actor_system[ETH_ALEN];
> +
> +	/* 2 bytes of padding : see ether_addr_equal_64bits() */
> +	u8 ad_actor_system[ETH_ALEN + 2];
>  };
>  
>  struct bond_parm_tbl {
> 
> 
> 
> .
It is fine to me.

Acked-by: Ding Tianhong <dingtianhong@huawei.com>
> 
