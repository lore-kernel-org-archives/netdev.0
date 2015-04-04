From: "Arad, Ronen" <ronen.arad@intel.com>
Subject: RE: [PATCH net-next v3 19/26] switchdev: add new
 swdev_port_bridge_getlink
Date: Sat, 4 Apr 2015 16:56:12 +0000
Message-ID: <E4CD12F19ABA0C4D8729E087A761DC35067FE348@ORSMSX101.amr.corp.intel.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
 <1427962212-18411-20-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "jiri@resnulli.us" <jiri@resnulli.us>,
	"roopa@cumulusnetworks.com" <roopa@cumulusnetworks.com>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"Samudrala, Sridhar" <sridhar.samudrala@intel.com>
To: "sfeldma@gmail.com" <sfeldma@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59338 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752929AbbDDQ4O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 12:56:14 -0400
In-Reply-To: <1427962212-18411-20-git-send-email-sfeldma@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: sfeldma@gmail.com [mailto:sfeldma@gmail.com]
>Sent: Thursday, April 02, 2015 1:10 AM
>To: netdev@vger.kernel.org
>Cc: jiri@resnulli.us; roopa@cumulusnetworks.com; linux@roeck-us.net;
>f.fainelli@gmail.com; Samudrala, Sridhar; Arad, Ronen
>Subject: [PATCH net-next v3 19/26] switchdev: add new
>swdev_port_bridge_getlink
>
>From: Scott Feldman <sfeldma@gmail.com>
>
>Like bridge_setlink, add swdev wrapper to handle bridge_getlink and call into
>port driver to get port attrs.  For now, only BR_LEARNING and BR_LEARNING_SYNC
>are returned.  To add more, we'll probably want to break away from
>ndo_dflt_bridge_getlink() and build the netlink skb directly in the swdev
>code.
>
>Signed-off-by: Scott Feldman <sfeldma@gmail.com>
>---
> include/net/switchdev.h   |    9 +++++++++
> net/switchdev/switchdev.c |   27 +++++++++++++++++++++++++++
> 2 files changed, 36 insertions(+)
>
>diff --git a/include/net/switchdev.h b/include/net/switchdev.h
>index a88754c..efd7753 100644
>--- a/include/net/switchdev.h
>+++ b/include/net/switchdev.h
>@@ -115,6 +115,8 @@ int swdev_port_attr_get(struct net_device *dev, struct
>swdev_attr *attr);
> int swdev_port_attr_set(struct net_device *dev, struct swdev_attr *attr);
> int swdev_port_obj_add(struct net_device *dev, struct swdev_obj *obj);
> int swdev_port_obj_del(struct net_device *dev, struct swdev_obj *obj);
>+int swdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>+			      struct net_device *dev, u32 filter_mask);
> int swdev_port_bridge_setlink(struct net_device *dev, struct nlmsghdr *nlh,
> 			      u16 flags);
> int swdev_port_bridge_dellink(struct net_device *dev, struct nlmsghdr *nlh,
>@@ -155,6 +157,13 @@ static inline int swdev_port_obj_del(struct net_device
>*dev,
> 	return -EOPNOTSUPP;
> }
>
>+static inline int swdev_port_bridge_getlink(struct sk_buff *skb, u32 pid,
>+					    u32 seq, struct net_device *dev,
>+					    u32 filter_mask)
>+{
>+	return -EOPNOTSUPP;
>+}
>+
> static inline int swdev_port_bridge_setlink(struct net_device *dev,
> 					    struct nlmsghdr *nlh, u16 flags)
> {
>diff --git a/net/switchdev/switchdev.c b/net/switchdev/switchdev.c
>index 19936ccc..5324248 100644
>--- a/net/switchdev/switchdev.c
>+++ b/net/switchdev/switchdev.c
>@@ -317,6 +317,33 @@ int call_netdev_switch_notifiers(unsigned long val,
>struct net_device *dev,
> }
> EXPORT_SYMBOL_GPL(call_netdev_switch_notifiers);
>
>+/**
>+ *	swdev_port_bridge_getlink - Get bridge port attributes
>+ *
>+ *	@dev: port device
>+ *
>+ *	Called for SELF on rtnl_bridge_getlink to get bridge port
>+ *	attributes.
>+ */
>+int swdev_port_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
>+			      struct net_device *dev, u32 filter_mask)
>+{
>+	struct swdev_attr attr = {
>+		.id = SWDEV_ATTR_PORT_BRIDGE_FLAGS,
>+	};
>+	u16 mode = BRIDGE_MODE_UNDEF;
>+	u32 mask = BR_LEARNING | BR_LEARNING_SYNC;
>+	int err;
>+
>+	err = swdev_port_attr_get(dev, &attr);
>+	if (err)
>+		return err;
>+
>+	return ndo_dflt_bridge_getlink(skb, pid, seq, dev, mode,
>+				       attr.brport_flags, mask);
>+}
>+EXPORT_SYMBOL_GPL(swdev_port_bridge_getlink);
>+

swdev_port_bridge_getlink and the function it wraps 
ndo_dflt_bridge_getlink are only useful when all you need is to return
a set of brport attributes.
When a switchdev driver supports VLAN filtering without being enslaved
to a bridge this no longer works. ndo_dflt_bridge_getlink will end up in
a netlink RTM_NEWLINK message without the VLAN filtering info which is
maintained internally by the switchdev driver.
The driver will have to duplicate the code in ndo_dflt_bridge_getlink in
order to return a single RTM_NEWLINK message per port.
Can we break ndo_dflt_bridge_getlink to components that could be used
by such driver?
It would be useful to have one function that could fill the 
IFLA_PROTINFO and another one for the IFLA_AF_SPEC. 
 
> static int swdev_port_br_setflag(struct net_device *dev, struct nlattr
>*nlattr,
> 				 unsigned long brport_flag)
> {
>--
>1.7.10.4
