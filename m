From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC PATCH net-next 1/1] net: Support for switch port
 configuration
Date: Wed, 10 Dec 2014 17:50:18 +0100
Message-ID: <20141210165018.GG1863@nanopsycho.orion>
References: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Fastabend, John R" <john.r.fastabend@intel.com>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"sfeldma@gmail.com" <sfeldma@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Varlese, Marco" <marco.varlese@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C4896FB061E7DE4AAC93031BDCA044B104AC3257@IRSMSX108.ger.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Dec 10, 2014 at 05:23:40PM CET, marco.varlese@intel.com wrote:
>From: Marco Varlese <marco.varlese@intel.com>
>
>Switch hardware offers a list of attributes that are configurable
>on a per port basis.
>This patch provides a mechanism to configure switch ports by adding
>an NDO for setting specific values to specific attributes.
>There will be a separate patch that extends iproute2 to call the
>new NDO.


What are these attributes? Can you give some examples. I'm asking
because there is a plan to pass generic attributes to switch ports
replacing current specific ndo_switch_port_stp_update. In this case,
bridge is setting that attribute.

Is there need to set something directly from userspace or does it make
rather sense to use involved bridge/ovs/bond ? I think that both will be
needed.


>
>Signed-off-by: Marco Varlese <marco.varlese@intel.com>
>---
> include/linux/netdevice.h    |  5 +++++
> include/uapi/linux/if_link.h |  1 +
> net/core/rtnetlink.c         | 33 +++++++++++++++++++++++++++++++++
> 3 files changed, 39 insertions(+)
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
> #endif
> };
> 
>diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
>index f7d0d2d..b35c314 100644
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
>diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
>index eaa057f..e1be9ca 100644
>--- a/net/core/rtnetlink.c
>+++ b/net/core/rtnetlink.c
>@@ -1389,6 +1389,25 @@ static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
> 	return 0;
> }
> 

I believe that it would be better to move the code below to
net/switchdev/switchdev.c


>+#ifdef CONFIG_NET_SWITCHDEV
>+static int do_setswcfg(struct net_device *dev, struct nlattr *attr)
>+{
>+	int rem, err = -EINVAL;
>+	struct nlattr *v;
>+	const struct net_device_ops *ops = dev->netdev_ops;
>+
>+	nla_for_each_nested(v, attr, rem) {
>+		u32 op = nla_type(v);
>+		u64 value = nla_get_u64(v);
>+
>+		err = ops->ndo_switch_port_set_cfg(dev, op, value);
>+		if (err)
>+			break;
>+	}
>+	return err;
>+}
>+#endif
>+
> static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
> {
> 	int rem, err = -EINVAL;
>@@ -1740,6 +1759,20 @@ static int do_setlink(const struct sk_buff *skb,
> 			status |= DO_SETLINK_NOTIFY;
> 		}
> 	}
>+#ifdef CONFIG_NET_SWITCHDEV
>+	if (tb[IFLA_SWITCH_PORT_CFG]) {
>+		err = -EOPNOTSUPP;
>+		if (!ops->ndo_switch_port_set_cfg)
>+			goto errout;
>+		if (!ops->ndo_switch_parent_id_get)
>+			goto errout;
>+		err = do_setswcfg(dev, tb[IFLA_SWITCH_PORT_CFG]);
>+		if (err < 0)
>+			goto errout;
>+
>+		status |= DO_SETLINK_NOTIFY;
>+	}
>+#endif
> 	err = 0;
> 
> errout:
>-- 
>1.8.5.3
>
