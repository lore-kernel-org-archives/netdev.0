From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 2/3] net: set and query VEB/VEPA bridge mode via
	PF_BRIDGE
Date: Wed, 24 Oct 2012 11:13:03 -0700
Message-ID: <20121024181303.14378.78253.stgit@jf-dev1-dcblab>
References: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, chrisw@redhat.com, krkumar2@in.ibm.com,
	samudrala@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, gregory.v.rose@intel.com,
	eilong@broadcom.com
To: shemminger@vyatta.com, buytenh@wantstofly.org, davem@davemloft.net,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:51619 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161041Ab2JXSaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 14:30:20 -0400
In-Reply-To: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware switches may support enabling and disabling the
loopback switch which puts the device in a VEPA mode defined
in the IEEE 802.1Qbg specification. In this mode frames are
not switched in the hardware but sent directly to the switch.
SR-IOV capable NICs will likely support this mode I am
aware of at least two such devices. Also I am told (but don't
have any of this hardware available) that there are devices
that only support VEPA modes. In these cases it is important
at a minimum to be able to query these attributes.

This patch adds an additional IFLA_BRIDGE_MODE attribute that can be
set and dumped via the PF_BRIDGE:{SET|GET}LINK operations. Also
anticipating bridge attributes that may be common for both embedded
bridges and software bridges this adds a flags attribute
IFLA_BRIDGE_FLAGS currently used to determine if the command or event
is being generated to/from an embedded bridge or software bridge.
Finally, the event generation is pulled out of the bridge module and
into rtnetlink proper.

For example using the macvlan driver in VEPA mode on top of
an embedded switch requires putting the embedded switch into
a VEPA mode to get the expected results.

	--------  --------
        | VEPA |  | VEPA |       <-- macvlan vepa edge relays
        --------  --------
           |        |
           |        |
        ------------------
        |      VEPA      |       <-- embedded switch in NIC
        ------------------
                |
                |
        -------------------
        | external switch |      <-- shiny new physical
	-------------------          switch with VEPA support

A packet sent from the macvlan VEPA at the top could be
loopbacked on the embedded switch and never seen by the
external switch. So in order for this to work the embedded
switch needs to be set in the VEPA state via the above
described commands.

By making these attributes nested in IFLA_AF_SPEC we allow
future extensions to be made as needed.

CC: Lennert Buytenhek <buytenh@wantstofly.org>
CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/uapi/linux/if_bridge.h |   18 ++++++++
 net/bridge/br_netlink.c        |    2 -
 net/bridge/br_private.h        |    4 +-
 net/core/rtnetlink.c           |   85 ++++++++++++++++++++++++++++++++++++++--
 4 files changed, 102 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index a8fe954..b388579 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -97,5 +97,23 @@ struct __fdb_entry {
 	__u16 unused;
 };
 
+/* Bridge Flags */
+#define BRIDGE_FLAGS_MASTER	1	/* Bridge command to/from master */
+#define BRIDGE_FLAGS_SELF	2	/* Bridge command to/from lowerdev */
 
+#define BRIDGE_MODE_VEB		0	/* Default loopback mode */
+#define BRIDGE_MODE_VEPA	1	/* 802.1Qbg defined VEPA mode */
+
+/* Bridge management nested attributes
+ * [IFLA_AF_SPEC] = {
+ *     [IFLA_BRIDGE_FLAGS]
+ *     [IFLA_BRIDGE_MODE]
+ * }
+ */
+enum {
+	IFLA_BRIDGE_FLAGS,
+	IFLA_BRIDGE_MODE,
+	__IFLA_BRIDGE_MAX,
+};
+#define IFLA_BRIDGE_MAX (__IFLA_BRIDGE_MAX - 1)
 #endif /* _UAPI_LINUX_IF_BRIDGE_H */
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 743511b..14b065c 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -166,8 +166,6 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 	br_port_state_selection(p->br);
 	spin_unlock_bh(&p->br->lock);
 
-	br_ifinfo_notify(RTM_NEWLINK, p);
-
 	return 0;
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index fdcd5f6..6f40c14 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -158,7 +158,9 @@ struct net_bridge_port
 
 static inline struct net_bridge_port *br_port_get_rcu(const struct net_device *dev)
 {
-	struct net_bridge_port *port = rcu_dereference(dev->rx_handler_data);
+	struct net_bridge_port *port =
+			rcu_dereference_rtnl(dev->rx_handler_data);
+
 	return br_port_exists(dev) ? port : NULL;
 }
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a068666..8d2af0f 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2295,13 +2295,60 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+static inline size_t bridge_nlmsg_size(void)
+{
+	return NLMSG_ALIGN(sizeof(struct ifinfomsg))
+		+ nla_total_size(IFNAMSIZ)	/* IFLA_IFNAME */
+		+ nla_total_size(MAX_ADDR_LEN)	/* IFLA_ADDRESS */
+		+ nla_total_size(sizeof(u32))	/* IFLA_MASTER */
+		+ nla_total_size(sizeof(u32))	/* IFLA_MTU */
+		+ nla_total_size(sizeof(u32))	/* IFLA_LINK */
+		+ nla_total_size(sizeof(u32))	/* IFLA_OPERSTATE */
+		+ nla_total_size(sizeof(u8))	/* IFLA_PROTINFO */
+		+ nla_total_size(sizeof(struct nlattr))	/* IFLA_AF_SPEC */
+		+ nla_total_size(sizeof(u16))	/* IFLA_BRIDGE_FLAGS */
+		+ nla_total_size(sizeof(u16));	/* IFLA_BRIDGE_MODE */
+}
+
+static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
+{
+	struct net *net = dev_net(dev);
+	struct net_device *master = dev->master;
+	struct sk_buff *skb;
+	int err = -EOPNOTSUPP;
+
+	skb = nlmsg_new(bridge_nlmsg_size(), GFP_ATOMIC);
+	if (!skb) {
+		err = -ENOMEM;
+		goto errout;
+	}
+
+	if (!flags && master && master->netdev_ops->ndo_bridge_getlink)
+		err = master->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+	else if (dev->netdev_ops->ndo_bridge_getlink)
+		err = dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+
+	if (err < 0)
+		goto errout;
+
+	rtnl_notify(skb, net, 0, RTNLGRP_LINK, NULL, GFP_ATOMIC);
+	return 0;
+errout:
+	WARN_ON(err == -EMSGSIZE);
+	kfree_skb(skb);
+	rtnl_set_sk_err(net, RTNLGRP_LINK, err);
+	return err;
+}
+
 static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 			       void *arg)
 {
 	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
 	struct net_device *dev;
-	int err = -EINVAL;
+	struct nlattr *br_spec, *attr = NULL;
+	int rem, err = -EOPNOTSUPP;
+	u16 flags = 0;
 
 	if (nlmsg_len(nlh) < sizeof(*ifm))
 		return -EINVAL;
@@ -2316,15 +2363,45 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 		return -ENODEV;
 	}
 
-	if (dev->master && dev->master->netdev_ops->ndo_bridge_setlink) {
+	br_spec = nlmsg_find_attr(nlh, sizeof(struct ifinfomsg), IFLA_AF_SPEC);
+	if (br_spec) {
+		nla_for_each_nested(attr, br_spec, rem) {
+			if (nla_type(attr) == IFLA_BRIDGE_FLAGS) {
+				flags = nla_get_u16(attr);
+				break;
+			}
+		}
+	}
+
+	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
+		if (!dev->master ||
+		    !dev->master->netdev_ops->ndo_bridge_setlink) {
+			err = -EOPNOTSUPP;
+			goto out;
+		}
+
 		err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
 		if (err)
 			goto out;
+
+		flags &= ~BRIDGE_FLAGS_MASTER;
 	}
 
-	if (dev->netdev_ops->ndo_bridge_setlink)
-		err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+	if ((flags & BRIDGE_FLAGS_SELF)) {
+		if (!dev->netdev_ops->ndo_bridge_setlink)
+			err = -EOPNOTSUPP;
+		else
+			err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+
+		if (!err)
+			flags &= ~BRIDGE_FLAGS_SELF;
+	}
 
+	if (attr && nla_type(attr) == IFLA_BRIDGE_FLAGS)
+		memcpy(nla_data(attr), &flags, sizeof(flags));
+	/* Generate event to notify upper layer of bridge change */
+	if (!err)
+		err = rtnl_bridge_notify(dev, flags);
 out:
 	return err;
 }
