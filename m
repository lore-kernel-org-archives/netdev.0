From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v4 09/24] switchdev: add new swdev bridge setlink
Date: Mon, 13 Apr 2015 21:09:28 -0700
Message-ID: <552C92F8.8030604@cumulusnetworks.com>
References: <1428905838-14920-1-git-send-email-sfeldma@gmail.com> <1428905838-14920-10-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com, andrew@lunn.ch
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33738 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbbDNEJb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 00:09:31 -0400
Received: by qkx62 with SMTP id 62so217447137qkx.0
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 21:09:30 -0700 (PDT)
In-Reply-To: <1428905838-14920-10-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/12/15, 11:17 PM, sfeldma@gmail.com wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> Add new swdev_port_bridge_setlink that can be used by drivers implementing
> .ndo_bridge_setlink to set swdev bridge attributes.  Basically turn the raw
> rtnl_bridge_setlink netlink into swdev attr sets.  Proper netlink attr policy
> checking is done on the protinfo part of the netlink msg.
>
> Currently, for protinfo, only bridge port attrs BR_LEARNING and
> BR_LEARNING_SYNC are parsed and passed to port driver.
>
> For afspec, VLAN objs are passed so swdev driver can set VLANs assigned to
> SELF.  To illustrate with iproute2 cmd, we have:
>
> 	bridge vlan add vid 10 dev sw1p1 self master
>
> To add VLAN 10 to port sw1p1 for both the bridge (master) and the device
> (self).
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>   include/net/switchdev.h   |    8 +++
>   net/switchdev/switchdev.c |  152 +++++++++++++++++++++++++++++++++++++++++++++
>   2 files changed, 160 insertions(+)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index d3cc8eb..cff53ae 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -121,6 +121,8 @@ int swdev_port_attr_get(struct net_device *dev, struct swdev_attr *attr);
>   int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
>   int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj);
>   int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj);
> +int swdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
> +			      u16 flags);
>   int register_netdev_switch_notifier(struct notifier_block *nb);
>   int unregister_netdev_switch_notifier(struct notifier_block *nb);
>   int call_netdev_switch_notifiers(unsigned long val, struct net_device *dev,
> @@ -165,6 +167,12 @@ static inline int swdev_port_obj_del(struct net_device *dev,
>   	return -EOPNOTSUPP;
>   }
>   
> +static inline int swdev_port_bridge_setlink(struct net_device *dev,
> +					    struct nlmsghdr *nlh, u16 flags)
> +{
> +	return -EOPNOTSUPP;
> +}
> +
>   static inline int register_netdev_switch_notifier(struct notifier_block *nb)
>   {
>   	return 0;
> diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
> index 05fded9..31d55e7 100644
> --- a/net/switchdev/switchdev.c
> +++ b/net/switchdev/switchdev.c
> @@ -15,6 +15,7 @@
>   #include <linux/mutex.h>
>   #include <linux/notifier.h>
>   #include <linux/netdevice.h>
> +#include <linux/if_bridge.h>
>   #include <net/ip_fib.h>
>   #include <net/switchdev.h>
>   
> @@ -395,6 +396,157 @@ int netdev_switch_port_bridge_setlink(struct net_device *dev,
>   }
>   EXPORT_SYMBOL_GPL(netdev_switch_port_bridge_setlink);
>   
> +static int swdev_port_br_setflag(struct net_device *dev, struct nlattr *nlattr,
> +				 unsigned long brport_flag)
> +{
> +	struct swdev_attr attr = {
> +		.id = SWDEV_ATTR_PORT_BRIDGE_FLAGS,
> +	};
> +	u8 flag = nla_get_u8(nlattr);
> +	int err;
> +
> +	err = swdev_port_attr_get(dev, &attr);
> +	if (err)
> +		return err;
> +
> +	if (flag)
> +		attr.brport_flags |= brport_flag;
> +	else
> +		attr.brport_flags &= ~brport_flag;
> +
> +	return swdev_port_attr_set(dev, &attr);
> +}
> +
> +static const struct nla_policy swdev_port_bridge_policy[IFLA_BRPORT_MAX + 1] = {
> +	[IFLA_BRPORT_STATE]		= { .type = NLA_U8 },
> +	[IFLA_BRPORT_COST]		= { .type = NLA_U32 },
> +	[IFLA_BRPORT_PRIORITY]		= { .type = NLA_U16 },
> +	[IFLA_BRPORT_MODE]		= { .type = NLA_U8 },
> +	[IFLA_BRPORT_GUARD]		= { .type = NLA_U8 },
> +	[IFLA_BRPORT_PROTECT]		= { .type = NLA_U8 },
> +	[IFLA_BRPORT_FAST_LEAVE]	= { .type = NLA_U8 },
> +	[IFLA_BRPORT_LEARNING]		= { .type = NLA_U8 },
> +	[IFLA_BRPORT_LEARNING_SYNC]	= { .type = NLA_U8 },
> +	[IFLA_BRPORT_UNICAST_FLOOD]	= { .type = NLA_U8 },
> +};
> +
> +static int swdev_port_br_setlink_protinfo(struct net_device *dev,
> +					  struct nlattr *protinfo)
> +{
> +	struct nlattr *attr;
> +	int rem;
> +	int err;
> +
> +	err = nla_validate_nested(protinfo, IFLA_BRPORT_MAX,
> +				  swdev_port_bridge_policy);
> +	if (err)
> +		return err;
> +
> +	nla_for_each_nested(attr, protinfo, rem) {
> +		switch (nla_type(attr)) {
> +		case IFLA_BRPORT_LEARNING:
> +			err = swdev_port_br_setflag(dev, attr,
> +						    BR_LEARNING);
> +			break;
> +		case IFLA_BRPORT_LEARNING_SYNC:
> +			err = swdev_port_br_setflag(dev, attr,
> +						    BR_LEARNING_SYNC);
> +			break;
> +		default:
> +			err = -EOPNOTSUPP;
> +			break;
> +		}
> +		if (err)
> +			return err;
> +	}
> +
> +	return 0;
> +}
> +
> +static int swdev_port_br_afspec(struct net_device *dev,
> +				struct nlattr *afspec,
> +				int (*f)(struct net_device *dev,
> +					 struct swdev_obj *obj))
> +{
> +	struct nlattr *attr;
> +	struct bridge_vlan_info *vinfo;
> +	struct swdev_obj obj = {
> +		.id = SWDEV_OBJ_PORT_VLAN,
> +	};
> +	int rem;
> +	int err;
> +
> +	nla_for_each_nested(attr, afspec, rem) {
> +		if (nla_type(attr) != IFLA_BRIDGE_VLAN_INFO)
> +			continue;
> +		if (nla_len(attr) != sizeof(struct bridge_vlan_info))
> +			return -EINVAL;
> +		vinfo = nla_data(attr);
> +		obj.vlan.flags = vinfo->flags;
> +		if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_BEGIN) {
> +			if (obj.vlan.vid_start)
> +				return -EINVAL;
> +			obj.vlan.vid_start = vinfo->vid;
> +		} else if (vinfo->flags & BRIDGE_VLAN_INFO_RANGE_END) {
> +			if (!obj.vlan.vid_start)
> +				return -EINVAL;
> +			obj.vlan.vid_end = vinfo->vid;
> +			if (obj.vlan.vid_end <= obj.vlan.vid_start)
> +				return -EINVAL;
> +			err = f(dev, &obj);
> +			if (err)
> +				return err;
> +			memset(&obj.vlan, 0, sizeof(obj.vlan));
> +		} else {
> +			if (obj.vlan.vid_start)
> +				return -EINVAL;
> +			obj.vlan.vid_start = vinfo->vid;
> +			obj.vlan.vid_end = vinfo->vid;
> +			err = f(dev, &obj);
> +			if (err)
> +				return err;
> +			memset(&obj.vlan, 0, sizeof(obj.vlan));
> +		}
> +	}
> +
> +	return 0;
> +}
> +

This seems to be duplicating code that is already there in the bridge 
driver.
