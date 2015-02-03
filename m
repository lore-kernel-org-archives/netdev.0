From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 01/10] net/core: Add event for a change in slave state
Date: Tue,  3 Feb 2015 16:48:29 +0200
Message-ID: <1422974919-28084-2-git-send-email-ogerlitz@mellanox.com>
References: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Roland Dreier <roland@kernel.org>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:60015 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751725AbbBCOt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 09:49:28 -0500
In-Reply-To: <1422974919-28084-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Moni Shoua <monis@mellanox.com>

Add event which provides an indication on a change in the state
of a bonding slave. The event handler should cast the pointer to the
appropriate type (struct netdev_bonding_info) in order to get the
full info about the slave.

Signed-off-by: Moni Shoua <monis@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/linux/netdevice.h |   15 +++++++++++++++
 net/core/dev.c            |   20 ++++++++++++++++++++
 net/core/rtnetlink.c      |    1 +
 3 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3d37c6e..0b13915 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -51,6 +51,7 @@
 #include <linux/netdev_features.h>
 #include <linux/neighbour.h>
 #include <uapi/linux/netdevice.h>
+#include <uapi/linux/if_bonding.h>
 
 struct netpoll_info;
 struct device;
@@ -2054,6 +2055,7 @@ struct pcpu_sw_netstats {
 #define NETDEV_RESEND_IGMP	0x0016
 #define NETDEV_PRECHANGEMTU	0x0017 /* notify before mtu change happened */
 #define NETDEV_CHANGEINFODATA	0x0018
+#define NETDEV_BONDING_INFO	0x0019
 
 int register_netdevice_notifier(struct notifier_block *nb);
 int unregister_netdevice_notifier(struct notifier_block *nb);
@@ -3477,6 +3479,19 @@ struct sk_buff *__skb_gso_segment(struct sk_buff *skb,
 struct sk_buff *skb_mac_gso_segment(struct sk_buff *skb,
 				    netdev_features_t features);
 
+struct netdev_bonding_info {
+	ifslave	slave;
+	ifbond	master;
+};
+
+struct netdev_notifier_bonding_info {
+	struct netdev_notifier_info info; /* must be first */
+	struct netdev_bonding_info  bonding_info;
+};
+
+void netdev_bonding_info_change(struct net_device *dev,
+				struct netdev_bonding_info *bonding_info);
+
 static inline
 struct sk_buff *skb_gso_segment(struct sk_buff *skb, netdev_features_t features)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index 1d564d6..ede0b16 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5355,6 +5355,26 @@ void netdev_upper_dev_unlink(struct net_device *dev,
 }
 EXPORT_SYMBOL(netdev_upper_dev_unlink);
 
+/**
+ * netdev_bonding_info_change - Dispatch event about slave change
+ * @dev: device
+ * @netdev_bonding_info: info to dispatch
+ *
+ * Send NETDEV_BONDING_INFO to netdev notifiers with info.
+ * The caller must hold the RTNL lock.
+ */
+void netdev_bonding_info_change(struct net_device *dev,
+				struct netdev_bonding_info *bonding_info)
+{
+	struct netdev_notifier_bonding_info	info;
+
+	memcpy(&info.bonding_info, bonding_info,
+	       sizeof(struct netdev_bonding_info));
+	call_netdevice_notifiers_info(NETDEV_BONDING_INFO, dev,
+				      &info.info);
+}
+EXPORT_SYMBOL(netdev_bonding_info_change);
+
 void netdev_adjacent_add_links(struct net_device *dev)
 {
 	struct netdev_adjacent *iter;
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index fedd7ab..0fb51f7 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -3178,6 +3178,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_UNREGISTER_FINAL:
 	case NETDEV_RELEASE:
 	case NETDEV_JOIN:
+	case NETDEV_BONDING_INFO:
 		break;
 	default:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
-- 
1.7.1
