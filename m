From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH net-next v3 1/1] net: Support for switch port configuration
Date: Thu, 18 Dec 2014 08:03:32 -0800
Message-ID: <5492FAD4.7070308@gmail.com>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD9F56@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B104AD9F56@IRSMSX108.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/18/2014 07:30 AM, Varlese, Marco wrote:
> From: Marco Varlese <marco.varlese@intel.com>
>
> Switch hardware offers a list of attributes that are configurable on a per port
> basis.
> This patch provides a mechanism to configure switch ports by adding an NDO
> for setting specific values to specific attributes.
> There will be a separate patch that adds the "get" functionality via another
> NDO and another patch that extends iproute2 to call the two new NDOs.
>
> Signed-off-by: Marco Varlese <marco.varlese@intel.com>
> ---
>   include/linux/netdevice.h    |  5 +++
>   include/uapi/linux/if_link.h | 15 +++++++++
>   net/core/rtnetlink.c         | 73 ++++++++++++++++++++++++++++++++++++++++++++
>   3 files changed, 93 insertions(+)
>
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index c31f74d..4881c7b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1027,6 +1027,9 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>    * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
>    *	Called to notify switch device port of bridge port STP
>    *	state change.
> + * int (*ndo_switch_port_set_cfg)(struct net_device *dev,
> + *                                u32 attr, u64 value);
> + *	Called to set specific switch ports attributes.
>    */
>   struct net_device_ops {
>   	int			(*ndo_init)(struct net_device *dev);
> @@ -1185,6 +1188,8 @@ struct net_device_ops {
>   							    struct netdev_phys_item_id *psid);
>   	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
>   							      u8 state);
> +	int			(*ndo_switch_port_set_cfg)(struct net_device *dev,
> +							   u32 attr, u64 value);
>   #endif
>   };
>
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index f7d0d2d..6ad9b91 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -146,6 +146,7 @@ enum {
>   	IFLA_PHYS_PORT_ID,
>   	IFLA_CARRIER_CHANGES,
>   	IFLA_PHYS_SWITCH_ID,
> +	IFLA_SWITCH_PORT_CFG,
>   	__IFLA_MAX
>   };
>
> @@ -603,4 +604,18 @@ enum {
>
>   #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
>
> +/* Switch Port Attributes section */

Could you also document the attributes. I think they are mostly
clear but what is IFLA_SW_LOOPBACK. It will help later when we
try to read the code in 6months and implement drivers.

I am thinking something like

/* Switch Port Attributes section
  * IFLA_SW_LEARNING - turns learning on in the bridge
  * IFLA_SW_LOOPBACK - does something interesting

  [...]
  */

> +
> +enum {
> +	IFLA_SW_UNSPEC,
> +	IFLA_SW_LEARNING,

Can you address Roopa's feedback. I'm also a bit confused by the
duplication.


> +	IFLA_SW_LOOPBACK,
> +	IFLA_SW_BCAST_FLOODING,
> +	IFLA_SW_UCAST_FLOODING,
> +	IFLA_SW_MCAST_FLOODING,
> +	__IFLA_SW_ATTR_MAX
> +};
> +
> +#define IFLA_SW_ATTR_MAX (__IFLA_SW_ATTR_MAX - 1)
> +
>   #endif /* _UAPI_LINUX_IF_LINK_H */
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index eaa057f..d50ca71 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1223,6 +1223,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>   	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>   	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
>   	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
> +	[IFLA_SWITCH_PORT_CFG]	= { .type = NLA_NESTED },
>   };
>
>   static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
> @@ -1265,6 +1266,14 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
>   	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
>   };
>
> +static const struct nla_policy ifla_sw_attr_policy[IFLA_SW_ATTR_MAX+1] = {
> +	[IFLA_SW_LEARNING]	= { .type = NLA_U64 },
> +	[IFLA_SW_LOOPBACK]	= { .type = NLA_U64 },
> +	[IFLA_SW_BCAST_FLOODING] = { .type = NLA_U64 },
> +	[IFLA_SW_UCAST_FLOODING] = { .type = NLA_U64 },
> +	[IFLA_SW_MCAST_FLOODING] = { .type = NLA_U64 },
> +};

Why U64 values? What would we pass in these? Are these just boolean
bits? Maybe the annotation above will help me understand this.


> +
>   static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
>   {
>   	struct net *net = sock_net(skb->sk);
> @@ -1389,6 +1398,41 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
>   	return 0;
>   }
>
> +#ifdef CONFIG_NET_SWITCHDEV
> +static int do_setswcfg(struct net_device *dev, struct nlattr *attr)
> +{
> +	int rem, err = -EINVAL;
> +	struct nlattr *v;
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +

style nit again since its an RFC after all... Its preferred to arrange
arguments like this as a loosly followed convention,

	const struct net_device_ops *ops = dev->netdev_ops;
	int rem, err = -EINVAL;
	struct nlattr *v;


> +	nla_for_each_nested(v, attr, rem) {
> +		u32 op = nla_type(v);
> +		u64 value = 0;
> +
> +		switch (op) {
> +		case IFLA_SW_LEARNING:
> +		case IFLA_SW_LOOPBACK:
> +		case IFLA_SW_BCAST_FLOODING:
> +		case IFLA_SW_UCAST_FLOODING:
> +		case IFLA_SW_MCAST_FLOODING: {
> +			value = nla_get_u64(v);

should we validate the get_u64 'value'? Are there valid ranges or
something?

> +			err = ops->ndo_switch_port_set_cfg(dev,
> +							   op,
> +							   value);
> +			break;
> +		}
> +		default:
> +			err = -EINVAL;
> +			break;
> +		}
> +		if (err)
> +			break;
> +	}
> +	return err;
> +}
> +
> +#endif
> +
>   static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
>   {
>   	int rem, err = -EINVAL;
> @@ -1740,6 +1784,35 @@ static int do_setlink(const struct sk_buff *skb,
>   			status |= DO_SETLINK_NOTIFY;
>   		}
>   	}
> +#ifdef CONFIG_NET_SWITCHDEV
> +	if (tb[IFLA_SWITCH_PORT_CFG]) {
> +		struct nlattr *attrs[IFLA_SW_ATTR_MAX+1];
> +
> +		err = -EOPNOTSUPP;
> +		if (!ops->ndo_switch_port_set_cfg)
> +			goto errout;
> +		if (!ops->ndo_switch_parent_id_get)
> +			goto errout;
> +

style nit (take it for what its worth) but I would compress the above to

		if (!ops->ndo_switch_port_set_cfg ||
		    !ops->ndo_switch_parent_id_get)
			goto errout;

I'm also wondering if we really need to check for parent_id_get() here.
I'm not sure I see why a driver would implement port_set_cfg() and not
parent_id_get() though so its mostly harmless.

> +		err = nla_parse_nested(attrs, IFLA_SW_ATTR_MAX,
> +				       tb[IFLA_SWITCH_PORT_CFG],
> +				       ifla_sw_attr_policy);
> +		if (err < 0)
> +			return err;

hmm everywhere else you use goto errout but not here?

> +
> +		err = do_setswcfg(dev, tb[IFLA_SWITCH_PORT_CFG]);
> +		if (err < 0)
> +			goto errout;
> +
> +		status |= DO_SETLINK_NOTIFY;

hmm another question if you modify the hardware from do_setswcfg()
for an attribute but then fail on a subsequent attribute shouldn't
we have DO_SETLINK_MODIFY set? Say IFLA_SW_LEARNING is set but then
the device fails on IFLA_SW_LOOPBACK.

> +	}
> +#else
> +	if (tb[IFLA_SWITCH_PORT_CFG]) {
> +		err = -EOPNOTSUPP;
> +		goto errout;
> +	}
> +#endif
> +
>   	err = 0;
>
>   errout:
>


-- 
John Fastabend         Intel Corporation
