From: Vlad Dogaru <ddvlad@rosedu.org>
Subject: [PATCH v3 1/2] net_device: add support for network device groups
Date: Fri, 14 Jan 2011 11:38:30 +0200
Message-ID: <1294997911-13866-2-git-send-email-ddvlad@rosedu.org>
References: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
Cc: Vlad Dogaru <ddvlad@rosedu.org>, jamal <hadi@cyberus.ca>,
	Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [141.85.37.41] ([141.85.37.41]:39246 "EHLO swarm.cs.pub.ro"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751729Ab1ANJih (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jan 2011 04:38:37 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1294997911-13866-1-git-send-email-ddvlad@rosedu.org>
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Net devices can now be grouped, enabling simpler manipulation from
userspace. This patch adds a group field to the net_device structure, as
well as rtnetlink support to query and modify it.

Signed-off-by: Vlad Dogaru <ddvlad@rosedu.org>
---
 include/linux/if_link.h   |    1 +
 include/linux/netdevice.h |    7 +++++++
 net/core/dev.c            |   12 ++++++++++++
 net/core/rtnetlink.c      |    6 ++++++
 4 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 6485d2a..f4a2e6b 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -135,6 +135,7 @@ enum {
 	IFLA_VF_PORTS,
 	IFLA_PORT_SELF,
 	IFLA_AF_SPEC,
+	IFLA_GROUP,		/* Group the device belongs to */
 	__IFLA_MAX
 };
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0f6b1c9..2a3e1da 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -75,6 +75,9 @@ struct wireless_dev;
 #define NET_RX_SUCCESS		0	/* keep 'em coming, baby */
 #define NET_RX_DROP		1	/* packet dropped */
 
+/* Initial net device group. All devices belong to group 0 by default. */
+#define INIT_NETDEV_GROUP	0
+
 /*
  * Transmit return codes: transmit return codes originate from three different
  * namespaces:
@@ -1156,6 +1159,9 @@ struct net_device {
 
 	/* phy device may attach itself for hardware timestamping */
 	struct phy_device *phydev;
+
+	/* group the device belongs to */
+	int group;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
@@ -1847,6 +1853,7 @@ extern int		dev_set_alias(struct net_device *, const char *, size_t);
 extern int		dev_change_net_namespace(struct net_device *,
 						 struct net *, const char *);
 extern int		dev_set_mtu(struct net_device *, int);
+extern void		dev_set_group(struct net_device *, int);
 extern int		dev_set_mac_address(struct net_device *,
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index a215269..6cf0cd2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4573,6 +4573,17 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 EXPORT_SYMBOL(dev_set_mtu);
 
 /**
+ *	dev_set_group - Change group this device belongs to
+ *	@dev: device
+ *	@new_group: group this device should belong to
+ */
+void dev_set_group(struct net_device *dev, int new_group)
+{
+	dev->group = new_group;
+}
+EXPORT_SYMBOL(dev_set_group);
+
+/**
  *	dev_set_mac_address - Change Media Access Control Address
  *	@dev: device
  *	@sa: new address
@@ -5698,6 +5709,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 	strcpy(dev->name, name);
+	dev->group = INIT_NETDEV_GROUP;
 	return dev;
 
 free_pcpu:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 750db57..012b0f0 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -868,6 +868,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		   netif_running(dev) ? dev->operstate : IF_OPER_DOWN);
 	NLA_PUT_U8(skb, IFLA_LINKMODE, dev->link_mode);
 	NLA_PUT_U32(skb, IFLA_MTU, dev->mtu);
+	NLA_PUT_U32(skb, IFLA_GROUP, dev->group);
 
 	if (dev->ifindex != dev->iflink)
 		NLA_PUT_U32(skb, IFLA_LINK, dev->iflink);
@@ -1265,6 +1266,11 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		modified = 1;
 	}
 
+	if (tb[IFLA_GROUP]) {
+		dev_set_group(dev, nla_get_u32(tb[IFLA_GROUP]));
+		modified = 1;
+	}
+
 	/*
 	 * Interface selected by interface index but interface
 	 * name provided implies that a name change has been
-- 
1.7.1

