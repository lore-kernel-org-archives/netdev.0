From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Fri, 14 Jan 2011 12:10:27 -0800
Message-ID: <4D30ADB3.7010509@intel.com>
References: <20110114190714.GA11655@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:33714 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751276Ab1ANUKw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 15:10:52 -0500
In-Reply-To: <20110114190714.GA11655@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/14/2011 11:07 AM, Oleg V. Ukhno wrote:
> Patch introduces new hashing policy for 802.3ad bonding mode.
> This hashing policy can be used(was tested) only for round-robin
> balancing of ISCSI traffic(single TCP session is balanced (per-packet)
> over all slave interfaces. 
> General requirements for this hashing policy usage are:
> 1) switch must be configured with src-dst-mac or src-mac hashing policy 
> 2) number of bond slaves on sending and receiving machine should be equal
> and preferrably even; or simply even, otherwise you may get asymmetric 
> load on receiving machine
> 3) hashing policy must not be used when round trip time between source 
> and destination machines for slaves in same bond is expected to be 
> significanly different (it works fine when all slaves are plugged into
> single switch)
> 
> Signed-off-by: Oleg V. Ukhno <olegu@yandex-team.ru>
> ---

I think you want this patch against net-next not 2.6.37.

> 
>  Documentation/networking/bonding.txt |   27 +++++++++++++++++++++++++++
>  drivers/net/bonding/bond_3ad.c       |    6 ++++++
>  drivers/net/bonding/bond_main.c      |   18 +++++++++++++++++-
>  include/linux/if_bonding.h           |    1 +
>  4 files changed, 51 insertions(+), 1 deletion(-)
> 
> diff -uprN -X linux-2.6.37-vanilla/Documentation/dontdiff linux-2.6.37-vanilla/Documentation/networking/bonding.txt linux-2.6.37.my/Documentation/networking/bonding.txt
> --- linux-2.6.37-vanilla/Documentation/networking/bonding.txt	2011-01-05 03:50:19.000000000 +0300
> +++ linux-2.6.37.my/Documentation/networking/bonding.txt	2011-01-14 21:34:46.635268000 +0300
> @@ -759,6 +759,33 @@ xmit_hash_policy
>  		most UDP traffic is not involved in extended
>  		conversations.  Other implementations of 802.3ad may
>  		or may not tolerate this noncompliance.
> +
> +	simple-rr or 3
> +		This policy simply sends every next packet via "next"
> +		slave interface. When sending, it resets mac-address
> +		within packet to real mac-address of the slave interface.
> +
> +		When switch is configured properly, and receiving machine
> +		has even and equal number of interfaces, this guarantees
> +		quite precise rx/tx load balancing for any single TCP
> +		session. Typical use-case for this mode is ISCSI(and patch was
> +		developed for), because it ises single TCP session to
> +		transmit data.

Oleg, sorry but I don't follow. If this is simply sending every next packet
via "next" slave interface how are packets not going to get out of order? If
the links have different RTT this would seem problematic.

Have you considered using multipath at the block layer? This is how I generally
handle load balancing over iSCSI/FCoE and it works reasonably well.

see ./drivers/md/dm-mpath.c

> +
> +		It is important to remember, that all slaves should be
> +		plugged into single switch to avoid out-of-order packets
> +		It is recommended to have equal and even number of slave
> +		interfaces in sending and receviving machines bond's,
> +		otherwise you will get asymmetric load on receiving host.
> +		Another caveat is that hashing policy must not be used when
> +		round trip time between source and destination machines for
> +		slaves in same bond is expected to be significanly different
> +		(it works fine when all slaves are plugged into single switch)
> +
> +		For correct load baalncing on the receiving side you must
> +		configure switch for using src-dst-mac or src-mac hashing
> +		mode.
> +
>  
>  	The default value is layer2.  This option was added in bonding
>  	version 2.6.3.  In earlier versions of bonding, this parameter
> diff -uprN -X linux-2.6.37-vanilla/Documentation/dontdiff linux-2.6.37-vanilla/drivers/net/bonding/bond_3ad.c linux-2.6.37.my/drivers/net/bonding/bond_3ad.c
> --- linux-2.6.37-vanilla/drivers/net/bonding/bond_3ad.c	2011-01-14 19:39:05.575268000 +0300
> +++ linux-2.6.37.my/drivers/net/bonding/bond_3ad.c	2011-01-14 19:47:03.815268000 +0300
> @@ -2395,6 +2395,7 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
>  	int i;
>  	struct ad_info ad_info;
>  	int res = 1;
> +	struct ethhdr *eth_data;
>  
>  	/* make sure that the slaves list will
>  	 * not change during tx
> @@ -2447,6 +2448,11 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
>  			slave_agg_id = agg->aggregator_identifier;
>  
>  		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
> +			if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYERRR && ntohs(skb->protocol) == ETH_P_IP) {
> +				skb_reset_mac_header(skb);
> +				eth_data = eth_hdr(skb);
> +				memcpy(eth_data->h_source, slave->perm_hwaddr, ETH_ALEN);
> +			}
>  			res = bond_dev_queue_xmit(bond, skb, slave->dev);
>  			break;
>  		}
> diff -uprN -X linux-2.6.37-vanilla/Documentation/dontdiff linux-2.6.37-vanilla/drivers/net/bonding/bond_main.c linux-2.6.37.my/drivers/net/bonding/bond_main.c
> --- linux-2.6.37-vanilla/drivers/net/bonding/bond_main.c	2011-01-14 19:39:05.575268000 +0300
> +++ linux-2.6.37.my/drivers/net/bonding/bond_main.c	2011-01-14 19:47:55.835268001 +0300
> @@ -152,7 +152,9 @@ module_param(ad_select, charp, 0);
>  MODULE_PARM_DESC(ad_select, "803.ad aggregation selection logic: stable (0, default), bandwidth (1), count (2)");
>  module_param(xmit_hash_policy, charp, 0);
>  MODULE_PARM_DESC(xmit_hash_policy, "XOR hashing method: 0 for layer 2 (default)"
> -				   ", 1 for layer 3+4");
> +				   ", 1 for layer 3+4"
> +				   ", 2 for layer 2+3"
> +				   ", 3 for round-robin");
>  module_param(arp_interval, int, 0);
>  MODULE_PARM_DESC(arp_interval, "arp interval in milliseconds");
>  module_param_array(arp_ip_target, charp, NULL, 0);
> @@ -206,6 +208,7 @@ const struct bond_parm_tbl xmit_hashtype
>  {	"layer2",		BOND_XMIT_POLICY_LAYER2},
>  {	"layer3+4",		BOND_XMIT_POLICY_LAYER34},
>  {	"layer2+3",		BOND_XMIT_POLICY_LAYER23},
> +{	"simple-rr",		BOND_XMIT_POLICY_LAYERRR},
>  {	NULL,			-1},
>  };
>  
> @@ -3762,6 +3765,16 @@ static int bond_xmit_hash_policy_l2(stru
>  	return (data->h_dest[5] ^ data->h_source[5]) % count;
>  }
>  
> +/*
> + * simply round robin
> + */
> +static int bond_xmit_hash_policy_rr(struct sk_buff *skb,
> +				   struct net_device *bond_dev, int count)

Here's one reason why this won't work on net-next-2.6.

int      (*xmit_hash_policy)(struct sk_buff *, int);


Thanks,
John
