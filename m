From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
Date: Fri, 2 Jan 2015 11:21:33 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC3505DD313C@ORSMSX101.amr.corp.intel.com>
References: <1420169361-31767-2-git-send-email-sfeldma@gmail.com>
 <54A63186.1090807@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"jhs@mojatatu.com" <jhs@mojatatu.com>,
	"andy@greyhouse.net" <andy@greyhouse.net>
To: roopa <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52255 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761AbbABLVf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 06:21:35 -0500
In-Reply-To: <54A63186.1090807@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On
>Behalf Of roopa
>Sent: Friday, January 02, 2015 7:50 AM
>To: sfeldma@gmail.com
>Cc: netdev@vger.kernel.org; jiri@resnulli.us; john.fastabend@gmail.com;
>tgraf@suug.ch; jhs@mojatatu.com; andy@greyhouse.net
>Subject: Re: [PATCH net-next 1/3] net: add IPv4 routing FIB support for swdev
>
>On 1/1/15, 7:29 PM, sfeldma@gmail.com wrote:
>> From: Scott Feldman <sfeldma@gmail.com>
>>
>> To offload IPv4 L3 routing functions to swdev device, the swdev device
>driver
>> implements two new ndo ops (ndo_switch_fib_ipv4_add/del).  The ops are
>called
>> by the core IPv4 FIB code when installing/removing FIB entries to/from the
>> kernel FIB.  On install, the driver should return 0 if FIB entry (route) can
>be
>> installed to device for offloading, -EOPNOTSUPP if route cannot be installed
>> due to device limitations, and other negative error code on failure to
>install
>> route to device.  On failure error code, the route is not installed to
>device,
>> and not installed in kernel FIB, and the return code is propagated back to
>the
>> user-space caller (via netlink).  An -EOPNOTSUPP error code is skipped for
>the
>> device but installed in the kernel FIB.
>>
>> The FIB entry (route) nexthop list is used to find the swdev device port to
>> anchor the ndo op call.  The route's fib_dev (the first nexthop's dev) is
>used
>> find the swdev port by recursively traversing the fib_dev's lower_dev list
>> until a swdev port is found.  The ndo op is called on this swdev port.
>
>scott, I posted a similar api for bridge attribute sets. But, nobody
>supported it.
>http://marc.info/?l=linux-netdev&m=141820234410602&w=2
>
>If this is acceptable, I will be resubmitting my api as well.
>
There is certainly a need to propagate bridge and brport attributes to
switchdev driver. I believe the objections to your patch were not about that
need but about the mechanism of doing that. My understanding of the objections
on the list is that the propagation has to be delegated to intermediate master
devices (such as bond/team) in a stacked architecture instead of blindly
traverse through them to leaf switchdev ports.
An ideal traversal would allow intermediate master (or just upper) devices to
intervene or block the traversal while defaulting to the suggested transparent
traversal. This could address the objections to your patch. Maybe the traversal
requires an introduction of a new ndo.
>
>
>>
>> Since the FIB entry is "naked" when push from the kernel, the driver/device
>> is responsible for resolving the route's nexthops to neighbor MAC addresses.
>> This can be done by the driver by monitoring NETEVENT_NEIGH_UPDATE
>> netevent notifier to watch for ARP activity.  Once a nexthop is resolved to
>> neighbor MAC address, it can be installed to the device and the device will
>> do the L3 routing offload in HW, for that nexthop.
>>
>> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>   include/linux/netdevice.h |   22 +++++++++++
>>   include/net/switchdev.h   |   18 +++++++++
>>   net/ipv4/fib_trie.c       |   17 ++++++++-
>>   net/switchdev/switchdev.c |   89
>+++++++++++++++++++++++++++++++++++++++++++++
>>   4 files changed, 145 insertions(+), 1 deletion(-)
>>
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index 679e6e9..b66d22b 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -767,6 +767,8 @@ struct netdev_phys_item_id {
>>   typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>>   				       struct sk_buff *skb);
>>
>> +struct fib_info;
>> +
>>   /*
>>    * This structure defines the management hooks for network devices.
>>    * The following hooks can be defined; unless noted otherwise, they are
>> @@ -1030,6 +1032,14 @@ typedef u16 (*select_queue_fallback_t)(struct
>net_device *dev,
>>    * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
>>    *	Called to notify switch device port of bridge port STP
>>    *	state change.
>> + * int (*ndo_sw_parent_fib_ipv4_add)(struct net_device *dev, __be32 dst,
>> + *				     int dst_len, struct fib_info *fi,
>> + *				     u8 tos, u8 type, u32 tb_id);
>> + *	Called to add IPv4 route to switch device.
>> + * int (*ndo_sw_parent_fib_ipv4_del)(struct net_device *dev, __be32 dst,
>> + *				     int dst_len, struct fib_info *fi,
>> + *				     u8 tos, u8 type, u32 tb_id);
>> + *	Called to delete IPv4 route from switch device.
>>    */
>>   struct net_device_ops {
>>   	int			(*ndo_init)(struct net_device *dev);
>> @@ -1189,6 +1199,18 @@ struct net_device_ops {
>>   							    struct netdev_phys_item_id
>*psid);
>>   	int			(*ndo_switch_port_stp_update)(struct net_device
>*dev,
>>   							      u8 state);
>> +	int			(*ndo_switch_fib_ipv4_add)(struct net_device *dev,
>> +							   __be32 dst,
>> +							   int dst_len,
>> +							   struct fib_info *fi,
>> +							   u8 tos, u8 type,
>> +							   u32 tb_id);
>> +	int			(*ndo_switch_fib_ipv4_del)(struct net_device *dev,
>> +							   __be32 dst,
>> +							   int dst_len,
>> +							   struct fib_info *fi,
>> +							   u8 tos, u8 type,
>> +							   u32 tb_id);
>>   #endif
>>   };
>>
>> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>> index 8a6d164..caebc2a 100644
>> --- a/include/net/switchdev.h
>> +++ b/include/net/switchdev.h
>> @@ -17,6 +17,10 @@
>>   int netdev_switch_parent_id_get(struct net_device *dev,
>>   				struct netdev_phys_item_id *psid);
>>   int netdev_switch_port_stp_update(struct net_device *dev, u8 state);
>> +int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>> +			       u8 tos, u8 type, u32 tb_id);
>> +int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
>> +			       u8 tos, u8 type, u32 tb_id);
>>
>>   #else
>>
>> @@ -32,6 +36,20 @@ static inline int netdev_switch_port_stp_update(struct
>net_device *dev,
>>   	return -EOPNOTSUPP;
>>   }
>>
>> +static inline int netdev_switch_fib_ipv4_add(u32 dst, int dst_len,
>> +					     struct fib_info *fi,
>> +					     u8 tos, u8 type, u32 tb_id)
>> +{
>> +	return -EOPNOTSUPP;
>> +}
>> +
>> +static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
>> +					     struct fib_info *fi,
>> +					     u8 tos, u8 type, u32 tb_id)
>> +{
>> +	return -EOPNOTSUPP;
>> +}
>> +
>>   #endif
>>
>>   #endif /* _LINUX_SWITCHDEV_H_ */
>> diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
>> index 281e5e0..ea2dc17 100644
>> --- a/net/ipv4/fib_trie.c
>> +++ b/net/ipv4/fib_trie.c
>> @@ -79,6 +79,7 @@
>>   #include <net/tcp.h>
>>   #include <net/sock.h>
>>   #include <net/ip_fib.h>
>> +#include <net/switchdev.h>
>>   #include "fib_lookup.h"
>>
>>   #define MAX_STAT_DEPTH 32
>> @@ -1201,6 +1202,8 @@ int fib_table_insert(struct fib_table *tb, struct
>fib_config *cfg)
>>   			fib_release_info(fi_drop);
>>   			if (state & FA_S_ACCESSED)
>>   				rt_cache_flush(cfg->fc_nlinfo.nl_net);
>> +			netdev_switch_fib_ipv4_add(key, plen, fi, fa->fa_tos,
>> +						   cfg->fc_type, tb->tb_id);
>>   			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
>>   				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
>>
>> @@ -1229,6 +1232,13 @@ int fib_table_insert(struct fib_table *tb, struct
>fib_config *cfg)
>>   	new_fa->fa_tos = tos;
>>   	new_fa->fa_type = cfg->fc_type;
>>   	new_fa->fa_state = 0;
>> +
>> +	/* (Optionally) offload fib info to switch hardware. */
>> +	err = netdev_switch_fib_ipv4_add(key, plen, fi, tos,
>> +					 cfg->fc_type, tb->tb_id);
>> +	if (err && err != -EOPNOTSUPP)
>> +		goto out_free_new_fa;
>> +
>>   	/*
>>   	 * Insert new entry to the list.
>>   	 */
>> @@ -1237,7 +1247,7 @@ int fib_table_insert(struct fib_table *tb, struct
>fib_config *cfg)
>>   		fa_head = fib_insert_node(t, key, plen);
>>   		if (unlikely(!fa_head)) {
>>   			err = -ENOMEM;
>> -			goto out_free_new_fa;
>> +			goto out_sw_fib_del;
>>   		}
>>   	}
>>
>> @@ -1253,6 +1263,8 @@ int fib_table_insert(struct fib_table *tb, struct
>fib_config *cfg)
>>   succeeded:
>>   	return 0;
>>
>> +out_sw_fib_del:
>> +	netdev_switch_fib_ipv4_del(key, plen, fi, tos, cfg->fc_type, tb-
>>tb_id);
>>   out_free_new_fa:
>>   	kmem_cache_free(fn_alias_kmem, new_fa);
>>   out:
>> @@ -1529,6 +1541,9 @@ int fib_table_delete(struct fib_table *tb, struct
>fib_config *cfg)
>>   	rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb->tb_id,
>>   		  &cfg->fc_nlinfo, 0);
>>
>> +	netdev_switch_fib_ipv4_del(key, plen, fa->fa_info, tos,
>> +				   cfg->fc_type, tb->tb_id);
>> +
>>   	list_del_rcu(&fa->fa_list);
>>
>>   	if (!plen)
>> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>> index d162b21..211a8a0 100644
>> --- a/net/switchdev/switchdev.c
>> +++ b/net/switchdev/switchdev.c
>> @@ -12,6 +12,7 @@
>>   #include <linux/types.h>
>>   #include <linux/init.h>
>>   #include <linux/netdevice.h>
>> +#include <net/ip_fib.h>
>>   #include <net/switchdev.h>
>>
>>   /**
>> @@ -50,3 +51,91 @@ int netdev_switch_port_stp_update(struct net_device *dev,
>u8 state)
>>   	return ops->ndo_switch_port_stp_update(dev, state);
>>   }
>>   EXPORT_SYMBOL(netdev_switch_port_stp_update);
>> +
>> +static struct net_device *netdev_switch_get_by_fib_dev(struct net_device
>*dev)
>> +{
>> +	const struct net_device_ops *ops = dev->netdev_ops;
>> +	struct net_device *lower_dev;
>> +	struct net_device *port_dev;
>> +	struct list_head *iter;
>> +
>> +	/* Recusively search from fib_dev down until we find
>> +	 * a sw port dev.  (A sw port dev supports
>> +	 * ndo_switch_parent_id_get).
>> +	 */
>> +
>> +	if (ops->ndo_switch_parent_id_get)
>> +		return dev;
>> +
>> +	netdev_for_each_lower_dev(dev, lower_dev, iter) {
>> +		port_dev = netdev_switch_get_by_fib_dev(lower_dev);
>> +		if (port_dev)
>> +			return port_dev;
>> +	}
>> +
>> +	return NULL;
>> +}
>> +
>> +/**
>> + *	netdev_switch_fib_ipv4_add - Add IPv4 route entry to switch
>> + *
>> + *	@dst: route's IPv4 destination address
>> + *	@dst_len: destination address length (prefix length)
>> + *	@fi: route FIB info structure
>> + *	@tos: route TOS
>> + *	@type: route type
>> + *	@tb_id: route table ID
>> + *
>> + *	Add IPv4 route entry to switch device.
>> + */
>> +int netdev_switch_fib_ipv4_add(u32 dst, int dst_len, struct fib_info *fi,
>> +			       u8 tos, u8 type, u32 tb_id)
>> +{
>> +	struct net_device *dev;
>> +	const struct net_device_ops *ops;
>> +	int err = -EOPNOTSUPP;
>> +
>> +	dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
>> +	if (!dev)
>> +		return -EOPNOTSUPP;
>> +	ops = dev->netdev_ops;
>> +
>> +	if (ops->ndo_switch_fib_ipv4_add)
>> +		err = ops->ndo_switch_fib_ipv4_add(dev, htonl(dst), dst_len,
>> +						   fi, tos, type, tb_id);
>> +
>> +	return err;
>> +}
>> +EXPORT_SYMBOL(netdev_switch_fib_ipv4_add);
>> +
>> +/**
>> + *	netdev_switch_fib_ipv4_del - Delete IPv4 route entry from switch
>> + *
>> + *	@dst: route's IPv4 destination address
>> + *	@dst_len: destination address length (prefix length)
>> + *	@fi: route FIB info structure
>> + *	@tos: route TOS
>> + *	@type: route type
>> + *	@tb_id: route table ID
>> + *
>> + *	Delete IPv4 route entry from switch device.
>> + */
>> +int netdev_switch_fib_ipv4_del(u32 dst, int dst_len, struct fib_info *fi,
>> +			       u8 tos, u8 type, u32 tb_id)
>> +{
>> +	struct net_device *dev;
>> +	const struct net_device_ops *ops;
>> +	int err = -EOPNOTSUPP;
>> +
>> +	dev = netdev_switch_get_by_fib_dev(fi->fib_dev);
>> +	if (!dev)
>> +		return -EOPNOTSUPP;
>> +	ops = dev->netdev_ops;
>> +
>> +	if (ops->ndo_switch_fib_ipv4_del)
>> +		err = ops->ndo_switch_fib_ipv4_del(dev, htonl(dst), dst_len,
>> +						   fi, tos, type, tb_id);
>> +
>> +	return err;
>> +}
>> +EXPORT_SYMBOL(netdev_switch_fib_ipv4_del);
>
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
