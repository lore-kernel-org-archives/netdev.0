From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 1/2] net_sched/mqprio: add support for different
 pgroup types
Date: Tue, 08 May 2012 23:36:07 -0700
Message-ID: <4FAA1057.6020709@intel.com>
References: <1336287910-12010-1-git-send-email-amirv@mellanox.com> <1336287910-12010-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Oren Duer <oren@mellanox.com>, Liran Liss <liranl@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43706 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452Ab2EIGgI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 02:36:08 -0400
In-Reply-To: <1336287910-12010-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/6/2012 12:05 AM, Amir Vadai wrote:
> Currently, HW based QoS mechanisms use the framework and means introduced in
> commits 4f57c087d "net: implement mechanism for HW based QOS" and b8970f0bfc
> "net_sched: implement a root container qdisc sch_mqprio".
> 
> The approach present in these patches is strongly orientated to the extended
> transmission selection (ETS) algorithm traffic classes (TC).
> 

I would argue the strongly orientated part per our other thread [0/2]

> This patch enhances the current scheme to allow for these mechanisms to be used
> also with hardware who has queues per UP - user priority (Linux has well
> established mechanisms to set UP for both tagged and untagged traffic).
> 

also per other thread I think this is only needed if you have many different
egress map configurations on vlans.

> Now, __skb_tx_hash() will direct a flow to a tx ring from a range of tx rings.
> This range is defined by the admin through the mqprio scheduler for the
> specific HW. For TC based queues, the range is by TC number and for UP based
> queues, the range is by UP.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>  include/linux/netdevice.h |   27 +++++++++++++++++++++++++++
>  include/linux/pkt_sched.h |    3 ++-
>  net/core/dev.c            |   12 +++++++++---
>  net/sched/sch_mqprio.c    |   11 +++++++++--
>  4 files changed, 47 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 7f377fb..ecdd953 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -835,6 +835,9 @@ struct netdev_fcoe_hbainfo {
>   * 	is always called from the stack with the rtnl lock held and netif tx
>   * 	queues stopped. This allows the netdevice to perform queue management
>   * 	safely.
> + * int (*ndo_set_pg_type)(struct net_device *dev, u8 pg_type)
> + *	Called to setup 'tc' type. According to this type, traffic is
> + *	distributed across tx rings. If not set, ETS TC is in use.
>   *
>   *	Fiber Channel over Ethernet (FCoE) offload functions.
>   * int (*ndo_fcoe_enable)(struct net_device *dev);
> @@ -973,6 +976,8 @@ struct net_device_ops {
>  	int			(*ndo_get_vf_port)(struct net_device *dev,
>  						   int vf, struct sk_buff *skb);
>  	int			(*ndo_setup_tc)(struct net_device *dev, u8 tc);
> +	int			(*ndo_set_pg_type)(struct net_device *dev,
> +						   u8 pg_type);

expand ndo_setup_tc() to take either another parameter 'pg_type' or just
start passing in the entire tc_mqprio_opt that way we get the number of
queues as well. I would prefer passing tc_mpqrio_opt to adding more parameters.

This avoids adding another ndo op.


>  #if IS_ENABLED(CONFIG_FCOE)
>  	int			(*ndo_fcoe_enable)(struct net_device *dev);
>  	int			(*ndo_fcoe_disable)(struct net_device *dev);
> @@ -1307,6 +1312,11 @@ struct net_device {
>  	/* Data Center Bridging netlink ops */
>  	const struct dcbnl_rtnl_ops *dcbnl_ops;
>  #endif
> +	enum {
> +		PGROUP_TC,
> +		PGROUP_UP,
> +		PGROUP_MAX,
> +	} pg_type:8;
>  	u8 num_tc;
>  	struct netdev_tc_txq tc_to_txq[TC_MAX_QUEUE];
>  	u8 prio_tc_map[TC_BITMASK + 1];
> @@ -1329,6 +1339,23 @@ struct net_device {
>  #define	NETDEV_ALIGN		32
>  
>  static inline
> +int netdev_get_pg_type(const struct net_device *dev)
> +{
> +	return dev->pg_type;
> +}
> +
> +static inline
> +int netdev_set_pg_type(struct net_device *dev, u8 pg_type)
> +{
> +	if (pg_type >= PGROUP_MAX)
> +		return -EINVAL;
> +
> +	dev->pg_type = pg_type;
> +
> +	return 0;
> +}
> +
> +static inline
>  int netdev_get_prio_tc_map(const struct net_device *dev, u32 prio)
>  {
>  	return dev->prio_tc_map[prio & TC_BITMASK];
> diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
> index ffe975c..1ae7d3c 100644
> --- a/include/linux/pkt_sched.h
> +++ b/include/linux/pkt_sched.h
> @@ -596,7 +596,8 @@ struct tc_drr_stats {
>  struct tc_mqprio_qopt {
>  	__u8	num_tc;
>  	__u8	prio_tc_map[TC_QOPT_BITMASK + 1];
> -	__u8	hw;
> +	__u8	hw;	/* bit 0: hw owned, bits 1-7: hw queuing type.
> +			 * valid types: 0 - ETS TC, 1 - UP */
>  	__u16	count[TC_QOPT_MAX_QUEUE];
>  	__u16	offset[TC_QOPT_MAX_QUEUE];
>  };
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 09024fd..72ac4bf 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2325,9 +2325,15 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
>  	}
>  
>  	if (dev->num_tc) {
> -		u8 tc = netdev_get_prio_tc_map(dev, skb->priority);
> -		qoffset = dev->tc_to_txq[tc].offset;
> -		qcount = dev->tc_to_txq[tc].count;
> +		u8 pgroup;
> +
> +		if (dev->pg_type == PGROUP_TC || !vlan_tx_tag_present(skb))
> +			pgroup = netdev_get_prio_tc_map(dev, skb->priority);
> +		else
> +			pgroup = (vlan_tx_tag_get(skb) >> 13);
> +
> +		qoffset = dev->tc_to_txq[pgroup].offset;
> +		qcount = dev->tc_to_txq[pgroup].count;
>  	}
>  
>  	if (skb->sk && skb->sk->sk_hash)
> diff --git a/net/sched/sch_mqprio.c b/net/sched/sch_mqprio.c
> index d1831ca..2149cbb 100644
> --- a/net/sched/sch_mqprio.c
> +++ b/net/sched/sch_mqprio.c
> @@ -134,11 +134,18 @@ static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
>  		priv->qdiscs[i] = qdisc;
>  	}
>  
> +	if (dev->netdev_ops->ndo_set_pg_type)
> +		err = dev->netdev_ops->ndo_set_pg_type(dev, qopt->hw >> 1);
> +	else
> +		err = netdev_set_pg_type(dev, PGROUP_TC);

Software should still be allowed to set PGROUP_UP even though hardware may
not support it.

> +	if (err)
> +		goto err;
> +
>  	/* If the mqprio options indicate that hardware should own
>  	 * the queue mapping then run ndo_setup_tc otherwise use the
>  	 * supplied and verified mapping
>  	 */
> -	if (qopt->hw) {
> +	if (qopt->hw & 1) {
>  		priv->hw_owned = 1;
>  		err = dev->netdev_ops->ndo_setup_tc(dev, qopt->num_tc);
>  		if (err)
