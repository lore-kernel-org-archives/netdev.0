From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next v3 1/1] net: Support for switch port
 configuration
Date: Thu, 18 Dec 2014 17:30:04 +0100
Message-ID: <20141218163004.GB1879@nanopsycho.orion>
References: <C4896FB061E7DE4AAC93031BDCA044B104AD9F56@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B104AD9F56@IRSMSX108.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Dec 18, 2014 at 04:30:00PM CET, marco.varlese@intel.com wrote:
>From: Marco Varlese <marco.varlese@intel.com>
> 
>Switch hardware offers a list of attributes that are configurable on a per port
>basis.
>This patch provides a mechanism to configure switch ports by adding an NDO
>for setting specific values to specific attributes.
>There will be a separate patch that adds the "get" functionality via another
>NDO and another patch that extends iproute2 to call the two new NDOs.
>
>Signed-off-by: Marco Varlese <marco.varlese@intel.com>
>---
> include/linux/netdevice.h    |  5 +++
> include/uapi/linux/if_link.h | 15 +++++++++
> net/core/rtnetlink.c         | 73 ++++++++++++++++++++++++++++++++++++++++++++
> 3 files changed, 93 insertions(+)
>
>diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>index c31f74d..4881c7b 100644
>--- a/include/linux/netdevice.h
>+++ b/include/linux/netdevice.h
>@@ -1027,6 +1027,9 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>  * int (*ndo_switch_port_stp_update)(struct net_device *dev, u8 state);
>  *	Called to notify switch device port of bridge port STP
>  *	state change.
>+ * int (*ndo_switch_port_set_cfg)(struct net_device *dev,
>+ *                                u32 attr, u64 value);
>+ *	Called to set specific switch ports attributes.
>  */
> struct net_device_ops {
> 	int			(*ndo_init)(struct net_device *dev);
>@@ -1185,6 +1188,8 @@ struct net_device_ops {
> 							    struct netdev_phys_item_id *psid);
> 	int			(*ndo_switch_port_stp_update)(struct net_device *dev,
> 							      u8 state);
>+	int			(*ndo_switch_port_set_cfg)(struct net_device *dev,
>+							   u32 attr, u64 value);

How about get? Userspace should be able to read the values as well.

> #endif
> };
> 
>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>index f7d0d2d..6ad9b91 100644
>--- a/include/uapi/linux/if_link.h
>+++ b/include/uapi/linux/if_link.h
>@@ -146,6 +146,7 @@ enum {
> 	IFLA_PHYS_PORT_ID,
> 	IFLA_CARRIER_CHANGES,
> 	IFLA_PHYS_SWITCH_ID,
>+	IFLA_SWITCH_PORT_CFG,
> 	__IFLA_MAX
> };
> 
>@@ -603,4 +604,18 @@ enum {
> 
> #define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
> 
>+/* Switch Port Attributes section */
>+
>+enum {
>+	IFLA_SW_UNSPEC,
>+	IFLA_SW_LEARNING,
>+	IFLA_SW_LOOPBACK,
>+	IFLA_SW_BCAST_FLOODING,
>+	IFLA_SW_UCAST_FLOODING,
>+	IFLA_SW_MCAST_FLOODING,
>+	__IFLA_SW_ATTR_MAX
>+};
>+
>+#define IFLA_SW_ATTR_MAX (__IFLA_SW_ATTR_MAX - 1)
>+
> #endif /* _UAPI_LINUX_IF_LINK_H */
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index eaa057f..d50ca71 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -1223,6 +1223,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
> 	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
> 	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
> 	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>+	[IFLA_SWITCH_PORT_CFG]	= { .type = NLA_NESTED },
> };
> 
> static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
>@@ -1265,6 +1266,14 @@ static const struct nla_policy ifla_port_policy[IFLA_PORT_MAX+1] = {
> 	[IFLA_PORT_RESPONSE]	= { .type = NLA_U16, },
> };
> 
>+static const struct nla_policy ifla_sw_attr_policy[IFLA_SW_ATTR_MAX+1] = {
>+	[IFLA_SW_LEARNING]	= { .type = NLA_U64 },
>+	[IFLA_SW_LOOPBACK]	= { .type = NLA_U64 },
>+	[IFLA_SW_BCAST_FLOODING] = { .type = NLA_U64 },
>+	[IFLA_SW_UCAST_FLOODING] = { .type = NLA_U64 },
>+	[IFLA_SW_MCAST_FLOODING] = { .type = NLA_U64 },

Please maintain namespaces. Use IFLA_SWITCH_PORT_LEARNING for example.
That gives us place for possible future whole-switch-cfg.


>+};
>+
> static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
> {
> 	struct net *net = sock_net(skb->sk);
>@@ -1389,6 +1398,41 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
> 	return 0;
> }
> 
>+#ifdef CONFIG_NET_SWITCHDEV
>+static int do_setswcfg(struct net_device *dev, struct nlattr *attr)
>+{
>+	int rem, err = -EINVAL;
>+	struct nlattr *v;
>+	const struct net_device_ops *ops = dev->netdev_ops;
>+
>+	nla_for_each_nested(v, attr, rem) {
>+		u32 op = nla_type(v);
>+		u64 value = 0;
>+
>+		switch (op) {
>+		case IFLA_SW_LEARNING:
>+		case IFLA_SW_LOOPBACK:
>+		case IFLA_SW_BCAST_FLOODING:
>+		case IFLA_SW_UCAST_FLOODING:
>+		case IFLA_SW_MCAST_FLOODING: {
>+			value = nla_get_u64(v);
>+			err = ops->ndo_switch_port_set_cfg(dev,
>+							   op,
>+							   value);
>+			break;
>+		}
>+		default:
>+			err = -EINVAL;
>+			break;
>+		}
>+		if (err)
>+			break;
>+	}
>+	return err;
>+}
>+
>+#endif
>+
> static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
> {
> 	int rem, err = -EINVAL;
>@@ -1740,6 +1784,35 @@ static int do_setlink(const struct sk_buff *skb,
> 			status |= DO_SETLINK_NOTIFY;
> 		}
> 	}
>+#ifdef CONFIG_NET_SWITCHDEV
>+	if (tb[IFLA_SWITCH_PORT_CFG]) {
>+		struct nlattr *attrs[IFLA_SW_ATTR_MAX+1];
>+
>+		err = -EOPNOTSUPP;
>+		if (!ops->ndo_switch_port_set_cfg)
>+			goto errout;
>+		if (!ops->ndo_switch_parent_id_get)
>+			goto errout;
>+
>+		err = nla_parse_nested(attrs, IFLA_SW_ATTR_MAX,
>+				       tb[IFLA_SWITCH_PORT_CFG],
>+				       ifla_sw_attr_policy);
>+		if (err < 0)
>+			return err;
>+
>+		err = do_setswcfg(dev, tb[IFLA_SWITCH_PORT_CFG]);
>+		if (err < 0)
>+			goto errout;
>+


Would make sense to me to move this including do_setswcfg into
net/switchdev/switchdev.c


>+		status |= DO_SETLINK_NOTIFY;
>+	}
>+#else
>+	if (tb[IFLA_SWITCH_PORT_CFG]) {
>+		err = -EOPNOTSUPP;
>+		goto errout;
>+	}
>+#endif
>+
> 	err = 0;
> 
> errout:
>-- 
>1.8.5.3
>
