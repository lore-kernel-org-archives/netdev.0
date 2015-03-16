From: sfeldma@gmail.com
Subject: [PATCH net-next v3 1/3] switchdev: add swdev ops
Date: Sun, 15 Mar 2015 21:07:14 -0700
Message-ID: <1426478836-60788-2-git-send-email-sfeldma@gmail.com>
References: <1426478836-60788-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:35107 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbbCPEG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:06:28 -0400
Received: by pdbop1 with SMTP id op1so46104028pdb.2
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 21:06:28 -0700 (PDT)
In-Reply-To: <1426478836-60788-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

As discussed at netconf, introduce swdev_ops as first step to move switchdev
ops from ndo to swdev.  This will keep switchdev from cluttering up ndo ops
space.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 include/linux/netdevice.h |    3 +++
 include/net/switchdev.h   |   38 ++++++++++++++++++++++++++++++++++++++
 2 files changed, 41 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ddab1a2..9e8a2a9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1577,6 +1577,9 @@ struct net_device {
 	const struct net_device_ops *netdev_ops;
 	const struct ethtool_ops *ethtool_ops;
 	const struct forwarding_accel_ops *fwd_ops;
+#ifdef CONFIG_NET_SWITCHDEV
+	const struct swdev_ops *swdev_ops;
+#endif
 
 	const struct header_ops *header_ops;
 
diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 1a9382f..e5de53f 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -14,6 +14,44 @@
 #include <linux/netdevice.h>
 #include <linux/notifier.h>
 
+struct fib_info;
+
+/**
+ * struct switchdev_ops - switchdev operations
+ *
+ * int (*swdev_parent_id_get)(struct net_device *dev,
+ *			      struct netdev_phys_item_id *psid);
+ *	Called to get an ID of the switch chip this port is part of.
+ *	If driver implements this, it indicates that it represents a port
+ *	of a switch chip.
+ *
+ * int (*swdev_port_stp_update)(struct net_device *dev, u8 state);
+ *	Called to notify switch device port of bridge port STP
+ *	state change.
+ *
+ * int (*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
+ *			     int dst_len, struct fib_info *fi,
+ *			     u8 tos, u8 type, u32 nlflags, u32 tb_id);
+ *	Called to add/modify IPv4 route to switch device.
+ *
+ * int (*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
+ *			     int dst_len, struct fib_info *fi,
+ *			     u8 tos, u8 type, u32 tb_id);
+ *	Called to delete IPv4 route from switch device.
+ */
+struct swdev_ops {
+	int	(*swdev_parent_id_get)(struct net_device *dev,
+				       struct netdev_phys_item_id *psid);
+	int	(*swdev_port_stp_update)(struct net_device *dev, u8 state);
+	int	(*swdev_fib_ipv4_add)(struct net_device *dev, __be32 dst,
+				      int dst_len, struct fib_info *fi,
+				      u8 tos, u8 type, u32 nlflags,
+				      u32 tb_id);
+	int	(*swdev_fib_ipv4_del)(struct net_device *dev, __be32 dst,
+				      int dst_len, struct fib_info *fi,
+				      u8 tos, u8 type, u32 tb_id);
+};
+
 enum netdev_switch_notifier_type {
 	NETDEV_SWITCH_FDB_ADD = 1,
 	NETDEV_SWITCH_FDB_DEL,
-- 
1.7.10.4
