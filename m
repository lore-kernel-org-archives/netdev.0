From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH] bridge: Enable configuration of ageing interval for
 bridges and switch devices.
Date: Mon, 17 Aug 2015 10:41:14 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9E2389@SJEXCHMB14.corp.ad.broadcom.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1E8D@SJEXCHMB14.corp.ad.broadcom.com>
 <55CD8DDB.5080001@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:39504 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754341AbbHQKlQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 06:41:16 -0400
In-Reply-To: <55CD8DDB.5080001@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Roopa,

Thank you for the comments.  Some thoughts/comments on IFLA_BR_AGEING_TIME.

1. Ageing interval using IFLA_BR_AGEING_TIME is set using 'ip link ..' command.  Shouldn't
bridge command be more appropriate for this?  The earlier patch seems to allow configuration of
other bridge related parameters using 'ip link' command.  

> ip link set dev br0 type bridge priority 10
> ip link set dev br0 type bridge ageing_time 10
> ip link set dev br0 type bridge stp_state 1

2. Another change as part of the proposed patch is to propagate the ageing interval to switchdev
devices so that hardware based aging can be setup correctly.

3. 'ip link' command doesn't seem to do any checks on the values given for ageing.  IEEE 802.1d 
Recommends that the time be between 10 sec and 1M seconds.

4. The ageing timer in kernel isn't restarted until the next expiry.  While this doesn't cause any
harm, it may be nice if the timer is restarted upon configuration change immediately.  

5. Also, similar to #3 above, the kernel doesn't check for any valid values of ageing time that 
it receives via netlink.

-Prem

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of roopa
Sent: Friday, August 14, 2015 12:13 PM
To: Premkumar Jonnala
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH] bridge: Enable configuration of ageing interval for bridges and switch devices.

On 8/13/15, 11:23 PM, Premkumar Jonnala wrote:
> Bridge devices have ageing interval used to age out MAC addresses
> from FDB.  This ageing interval was not configuratble.
>
> Enable netlink based configuration of ageing interval for bridges and
> switch devices.  The ageing interval changes the timer used to purge
> inactive FDB entries in bridges.  The ageing interval config is
> propagated to switch devices, so that platform or hardware based
> ageing works according to configuration.
>
> Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>

How is this different from netlink attribute IFLA_BR_AGEING_TIME ?
>
> ---
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 607b5f4..e3b0c45 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1053,7 +1053,16 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>    *	This function is used to pass protocol port error state information
>    *	to the switch driver. The switch driver can react to the proto_down
>    *      by doing a phys down on the associated switch port.
> - *
> + * int (*ndo_bridge_setageing)(const struct net_device *dev,
> + *			       int ageing_interval);
> + *     Called to set FDB aging interval for a given bridge device.
> + * int (*ndo_bridge_getageing_nl)(struct sk_buff *skb,
> + *				const struct net_device *dev,
> + *				struct netlink_callback *cb);
> + *     Called to return the ageing interval for the given bridge device,
> + *     in a format suitable for netlink messaging.
> + * int (*ndo_bridge_getageing)(const struct net_device *dev);
> + *     Called to retrieve the ageing interval for the given bridge device.
>    */
>   struct net_device_ops {
>   	int			(*ndo_init)(struct net_device *dev);
> @@ -1226,6 +1235,13 @@ struct net_device_ops {
>   	int			(*ndo_get_iflink)(const struct net_device *dev);
>   	int			(*ndo_change_proto_down)(struct net_device *dev,
>   							 bool proto_down);
> +	int	(*ndo_bridge_setageing)(const struct net_device *dev,
> +					int ageing_interval);
> +	int	(*ndo_bridge_getageing_nl)(struct sk_buff *skb,
> +					   const struct net_device *dev,
> +					   struct netlink_callback *cb);
> +
> +	int	(*ndo_bridge_getageing)(const struct net_device *dev);
>   };
>   
you cannot add new ndo's for each of these. It should be covered as part of
existing br_link_ops

>   /**
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 89da893..7186fea 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -129,6 +129,10 @@ int switchdev_port_attr_get(struct net_device *dev,
>   			    struct switchdev_attr *attr);
>   int switchdev_port_attr_set(struct net_device *dev,
>   			    struct switchdev_attr *attr);
> +int netdev_switch_ageing_set(struct net_device *dev, int ageing_interval);
> +int netdev_switch_ageing_get(struct sk_buff *skb,
> +			     const struct net_device *dev,
> +			     struct netlink_callback *cb);
>   int switchdev_port_obj_add(struct net_device *dev, struct switchdev_obj *obj);
>   int switchdev_port_obj_del(struct net_device *dev, struct switchdev_obj *obj);
>   int switchdev_port_obj_dump(struct net_device *dev, struct switchdev_obj *obj);
> @@ -163,6 +167,17 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
>   
>   #else
>   
> +static inline int netdev_switch_ageing_set(struct net_device *dev,
> +					int ageing_interval)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
> +static inline int netdev_switch_ageing_get(struct net_device *dev)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>   static inline int switchdev_port_attr_get(struct net_device *dev,
>   					  struct switchdev_attr *attr)
>   {
> diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
> index 3635b77..a32ab4d 100644
> --- a/include/uapi/linux/if_bridge.h
> +++ b/include/uapi/linux/if_bridge.h
> @@ -199,4 +199,23 @@ enum {
>   };
>   #define MDBA_SET_ENTRY_MAX (__MDBA_SET_ENTRY_MAX - 1)
>   
> +struct admsg {
> +	__u8 adm_family;
> +	__u8 adm_pad1;
> +	__u16 adm_pad2;
> +	__s32 adm_ifindex;
> +	__u16 adm_ageing_interval;
> +};
> +
> +/* The value of this macro is based on the value recommended by IEEE
> + * standard 802.1d.
> + */
> +#define MIN_AGEING_INTERVAL_SECS (10)
> +
> +/* The value of DEFAULT_AGEING_INTERVAL_SECS is the default ageing
> + * interval that was used in br_device.c.  This default value is also
> + * recommended by IEEE Standard 802.1d.
> + */
> +#define DEFAULT_AGEING_INTERVAL_SECS (300)
> +
>   #endif /* _UAPI_LINUX_IF_BRIDGE_H */
> diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
> index 47d24cb..9321818 100644
> --- a/include/uapi/linux/rtnetlink.h
> +++ b/include/uapi/linux/rtnetlink.h
> @@ -139,6 +139,13 @@ enum {
>   	RTM_GETNSID = 90,
>   #define RTM_GETNSID RTM_GETNSID
>   
> +	RTM_SETAGEING = 92,
> +#define RTM_SETAGEING RTM_SETAGEING
> +	RTM_SETDEFAULTAGEING = 93,
> +#define RTM_SETDEFAULTAGEING RTM_SETDEFAULTAGEING
> +	RTM_GETAGEING = 94,
> +#define RTM_GETAGEING RTM_GETAGEING
> +

you cannot add a new RTM message for a single attribute either.
>   	__RTM_MAX,
>   #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
>   };
> diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> index 4ff77a1..2c81190 100644
> --- a/net/bridge/br_device.c
> +++ b/net/bridge/br_device.c
> @@ -18,6 +18,7 @@
>   #include <linux/ethtool.h>
>   #include <linux/list.h>
>   #include <linux/netfilter_bridge.h>
> +#include <net/netlink.h>
>   
>   #include <asm/uaccess.h>
>   #include "br_private.h"
> @@ -309,6 +310,43 @@ static int br_del_slave(struct net_device *dev, struct net_device *slave_dev)
>   	return br_del_if(br, slave_dev);
>   }
>   
> +static int br_setageing(const struct net_device *dev, int ageing_interval)
> +{
> +	struct net_bridge *br = netdev_priv(dev);
> +
> +	return br_fdb_setageing(br, ageing_interval);
> +}
> +
> +static int br_getageing(const struct net_device *dev)
> +{
> +	struct net_bridge *br = netdev_priv(dev);
> +
> +	return br->ageing_time / HZ;
> +}
> +
> +static int br_getageing_nl(struct sk_buff *skb,
> +			   const struct net_device *dev,
> +			   struct netlink_callback *cb)
> +{
> +	struct nlmsghdr *nlhdr;
> +	struct admsg *amsg;
> +
> +	struct net_bridge *br = netdev_priv(dev);
> +
> +	nlhdr = nlmsg_put(skb, NETLINK_CB(cb->skb).portid,
> +			  cb->nlh->nlmsg_seq, RTM_GETAGEING, sizeof(*amsg), 0);
> +	if (!nlhdr)
> +		return -EMSGSIZE;
> +
> +	amsg = nlmsg_data(nlhdr);
> +
> +	amsg->adm_family = AF_BRIDGE;
> +	amsg->adm_ifindex = dev->ifindex;
> +	amsg->adm_ageing_interval = br->ageing_time / HZ;
> +
> +	return 0;
> +}
> +
>   static const struct ethtool_ops br_ethtool_ops = {
>   	.get_drvinfo    = br_getinfo,
>   	.get_link	= ethtool_op_get_link,
> @@ -339,6 +377,9 @@ static const struct net_device_ops br_netdev_ops = {
>   	.ndo_bridge_getlink	 = br_getlink,
>   	.ndo_bridge_setlink	 = br_setlink,
>   	.ndo_bridge_dellink	 = br_dellink,
> +	.ndo_bridge_setageing    = br_setageing,
> +	.ndo_bridge_getageing_nl = br_getageing_nl,
> +	.ndo_bridge_getageing    = br_getageing,
>   };
>   
>   static void br_dev_free(struct net_device *dev)
> @@ -391,7 +432,7 @@ void br_dev_setup(struct net_device *dev)
>   	br->bridge_max_age = br->max_age = 20 * HZ;
>   	br->bridge_hello_time = br->hello_time = 2 * HZ;
>   	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
> -	br->ageing_time = 300 * HZ;
> +	br->ageing_time = DEFAULT_AGEING_INTERVAL_SECS * HZ;
>   
>   	br_netfilter_rtable_init(br);
>   	br_stp_timer_init(br);
> diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
> index 9e9875d..c46f734 100644
> --- a/net/bridge/br_fdb.c
> +++ b/net/bridge/br_fdb.c
> @@ -283,6 +283,25 @@ out:
>   	spin_unlock_bh(&br->hash_lock);
>   }
>   
> +int br_fdb_setageing(struct net_bridge *br, int ageing_interval)
> +{
> +	unsigned long next_timer;
> +	unsigned long exp_time;
> +
> +	if (ageing_interval < MIN_AGEING_INTERVAL_SECS)
> +		return -EINVAL;
> +
> +	br->ageing_time = ageing_interval * HZ;
> +
> +	next_timer = jiffies + hold_time(br);
> +	exp_time = br->gc_timer.expires;
> +
> +	if (exp_time > next_timer)
> +		mod_timer(&br->gc_timer, round_jiffies_up(next_timer));
> +
> +	return 0;
> +}
> +
>   void br_fdb_cleanup(unsigned long _data)
>   {
>   	struct net_bridge *br = (struct net_bridge *)_data;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index 3ad1290..b745e06 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -410,6 +410,7 @@ int br_fdb_external_learn_add(struct net_bridge *br, struct net_bridge_port *p,
>   			      const unsigned char *addr, u16 vid);
>   int br_fdb_external_learn_del(struct net_bridge *br, struct net_bridge_port *p,
>   			      const unsigned char *addr, u16 vid);
> +int br_fdb_setageing(struct net_bridge *br, int ageing_interval);
>   
>   /* br_forward.c */
>   void br_deliver(const struct net_bridge_port *to, struct sk_buff *skb);
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 5fb4af2..e7c6197 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -3277,6 +3277,128 @@ out:
>   	return err;
>   }
>   
> +static int configure_ageing_interval(struct net_device  *dev, int interval)
> +{
> +	int err = -EOPNOTSUPP;
> +	int old_ageing_timer = -1;
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	if (ops->ndo_bridge_getageing)
> +		old_ageing_timer = ops->ndo_bridge_getageing(dev);
> +
> +	if (ops->ndo_bridge_setageing)
> +		err = ops->ndo_bridge_setageing(dev, interval);
> +
> +	if (!err) {
> +		err = netdev_switch_ageing_set(dev, interval);
> +
> +		if (err == -EOPNOTSUPP)
> +			return 0;
> +
> +		if (err && (old_ageing_timer >= MIN_AGEING_INTERVAL_SECS))
> +			ops->ndo_bridge_setageing(dev, old_ageing_timer);
> +	}
> +
> +	return err;
> +}
> +
> +static int rtnl_bridge_setageing(struct sk_buff *skb, struct nlmsghdr *nlh)
> +{
> +	struct net *net = sock_net(skb->sk);
> +	struct admsg *adm;
> +	struct net_device *dev;
> +	int err;
> +	struct nlattr *tb[NDA_MAX + 1];
> +
> +	err = nlmsg_parse(nlh, sizeof(*adm), tb, NDA_MAX, NULL);
> +	if (err < 0)
> +		return err;
> +
> +	adm = nlmsg_data(nlh);
> +	if (adm->adm_ifindex == 0)
> +		return -EINVAL;
> +
> +	dev = __dev_get_by_index(net, adm->adm_ifindex);
> +	if (!dev)
> +		return -ENODEV;
> +
> +	err = -EOPNOTSUPP;
> +
> +	if (!(dev->priv_flags & IFF_EBRIDGE))
> +		return err;
> +
> +	err = configure_ageing_interval(dev, adm->adm_ageing_interval);
> +
> +	return err;
> +}
> +
> +static int rtnl_bridge_setdefaultageing(struct sk_buff *skb,
> +					struct nlmsghdr *nlh)
> +{
> +	struct net *net = sock_net(skb->sk);
> +	struct admsg *adm;
> +	struct net_device *dev;
> +	int err;
> +	struct nlattr *tb[NDA_MAX + 1];
> +
> +	err = nlmsg_parse(nlh, sizeof(*adm), tb, NDA_MAX, NULL);
> +	if (err < 0)
> +		return err;
> +
> +	adm = nlmsg_data(nlh);
> +	if (adm->adm_ifindex == 0)
> +		return -EINVAL;
> +
> +	dev = __dev_get_by_index(net, adm->adm_ifindex);
> +	if (!dev)
> +		return -ENODEV;
> +
> +	err = -EOPNOTSUPP;
> +
> +	if (!(dev->priv_flags & IFF_EBRIDGE))
> +		return err;
> +
> +	err = configure_ageing_interval(dev, DEFAULT_AGEING_INTERVAL_SECS);
> +
> +	return err;
> +}
> +
> +static int rtnl_bridge_getageing(struct sk_buff *skb,
> +				 struct netlink_callback *cb)
> +{
> +	struct net *net = sock_net(skb->sk);
> +	struct admsg *adm;
> +	struct net_device *dev;
> +	int err;
> +	struct nlattr *tb[NDA_MAX + 1];
> +
> +	err = nlmsg_parse(cb->nlh, sizeof(*adm), tb, NDA_MAX, NULL);
> +	if (err < 0)
> +		return err;
> +
> +	adm = nlmsg_data(cb->nlh);
> +	if (adm->adm_ifindex == 0)
> +		return -EINVAL;
> +
> +	dev = __dev_get_by_index(net, adm->adm_ifindex);
> +	if (!dev)
> +		return -ENODEV;
> +
> +	err = -EOPNOTSUPP;
> +
> +	if (!(dev->priv_flags & IFF_EBRIDGE))
> +		return err;
> +
> +	if (dev->netdev_ops->ndo_bridge_getageing_nl)
> +		err = dev->netdev_ops->ndo_bridge_getageing_nl(skb, dev, cb);
> +
> +	if (err)
> +		return err;
> +
> +	cb->args[0] = 1;
> +	return 0;
> +}
> +
>   /* Process one rtnetlink message. */
>   
>   static int rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
> @@ -3427,5 +3549,11 @@ void __init rtnetlink_init(void)
>   	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
>   	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, NULL);
>   	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
> +	rtnl_register(PF_BRIDGE, RTM_GETAGEING, NULL,
> +		      rtnl_bridge_getageing, NULL);
> +	rtnl_register(PF_BRIDGE, RTM_SETAGEING,
> +		      rtnl_bridge_setageing, NULL, NULL);
> +	rtnl_register(PF_BRIDGE, RTM_SETDEFAULTAGEING,
> +		      rtnl_bridge_setdefaultageing, NULL, NULL);
>   }
>   
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 33bafa2..501e892 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -1142,3 +1142,34 @@ void switchdev_port_fwd_mark_set(struct net_device *dev,
>   	dev->offload_fwd_mark = mark;
>   }
>   EXPORT_SYMBOL_GPL(switchdev_port_fwd_mark_set);
> +
> +int netdev_switch_ageing_set(struct net_device *dev,
> +			     int ageing_interval)
> +{
> +	int err = 0;
> +
> +	struct net_device *pd;
> +	struct list_head *iter;
> +
> +	netdev_for_each_lower_dev(dev, pd, iter) {
> +		if (!pd || !pd->netdev_ops ||
> +		    !pd->netdev_ops->ndo_bridge_setageing)
> +			continue;
> +
> +		err = pd->netdev_ops->ndo_bridge_setageing(pd,
> +							ageing_interval);
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(netdev_switch_ageing_set);
> +
> +int netdev_switch_ageing_get(struct sk_buff *skb,
> +			     const struct net_device *dev,
> +			     struct netlink_callback *cb)
> +{
> +	return -EOPNOTSUPP;
> +}
> +EXPORT_SYMBOL_GPL(netdev_switch_ageing_get);
> diff --git a/security/selinux/nlmsgtab.c b/security/selinux/nlmsgtab.c
> index 2bbb418..e29836e 100644
> --- a/security/selinux/nlmsgtab.c
> +++ b/security/selinux/nlmsgtab.c
> @@ -154,7 +154,7 @@ int selinux_nlmsg_lookup(u16 sclass, u16 nlmsg_type, u32 *perm)
>   	switch (sclass) {
>   	case SECCLASS_NETLINK_ROUTE_SOCKET:
>   		/* RTM_MAX always point to RTM_SETxxxx, ie RTM_NEWxxx + 3 */
> -		BUILD_BUG_ON(RTM_MAX != (RTM_NEWNSID + 3));
> +		BUILD_BUG_ON(RTM_MAX != (RTM_SETAGEING + 3));
>   		err = nlmsg_perm(nlmsg_type, perm, nlmsg_route_perms,
>   				 sizeof(nlmsg_route_perms));
>   		break;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

