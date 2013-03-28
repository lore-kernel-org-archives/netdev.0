From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 04/11] batman-adv: Don't always delete softif when last slave was removed
Date: Thu, 28 Mar 2013 08:50:24 +0100
Message-ID: <1364457031-3194-5-git-send-email-ordex@autistici.org>
References: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:33303 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756654Ab3C1HwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 03:52:09 -0400
In-Reply-To: <1364457031-3194-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

batman-adv has an unusual way to manage softinterfaces. These will be created
automatically when a user writes to the batman-adv/mesh_iface file in sysfs and
removed when no slave device exists anymore.

This behaviour cannot be changed without breaking compatibility with existing
code. Instead other interfaces should be able to slightly reduce this behaviour
and provide a more common reaction to a removal of a slave interface.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Antonio Quartulli <ordex@autistici.org>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c |  8 +++++---
 net/batman-adv/hard-interface.h | 13 ++++++++++++-
 net/batman-adv/sysfs.c          |  6 ++++--
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index da000e9..74e3ec2f 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -408,7 +408,8 @@ err:
 	return ret;
 }
 
-void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface)
+void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
+				     enum batadv_hard_if_cleanup autodel)
 {
 	struct batadv_priv *bat_priv = netdev_priv(hard_iface->soft_iface);
 	struct batadv_hard_iface *primary_if = NULL;
@@ -446,7 +447,7 @@ void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface)
 	dev_put(hard_iface->soft_iface);
 
 	/* nobody uses this interface anymore */
-	if (!bat_priv->num_ifaces)
+	if (!bat_priv->num_ifaces && autodel == BATADV_IF_CLEANUP_AUTO)
 		batadv_softif_destroy(hard_iface->soft_iface);
 
 	hard_iface->soft_iface = NULL;
@@ -533,7 +534,8 @@ static void batadv_hardif_remove_interface(struct batadv_hard_iface *hard_iface)
 
 	/* first deactivate interface */
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
-		batadv_hardif_disable_interface(hard_iface);
+		batadv_hardif_disable_interface(hard_iface,
+						BATADV_IF_CLEANUP_AUTO);
 
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
 		return;
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 308437d..4989288 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -29,13 +29,24 @@ enum batadv_hard_if_state {
 	BATADV_IF_I_WANT_YOU,
 };
 
+/**
+ * enum batadv_hard_if_cleanup - Cleanup modi for soft_iface after slave removal
+ * @BATADV_IF_CLEANUP_KEEP: Don't automatically delete soft-interface
+ * @BATADV_IF_CLEANUP_AUTO: Delete soft-interface after last slave was removed
+ */
+enum batadv_hard_if_cleanup {
+	BATADV_IF_CLEANUP_KEEP,
+	BATADV_IF_CLEANUP_AUTO,
+};
+
 extern struct notifier_block batadv_hard_if_notifier;
 
 struct batadv_hard_iface*
 batadv_hardif_get_by_netdev(const struct net_device *net_dev);
 int batadv_hardif_enable_interface(struct batadv_hard_iface *hard_iface,
 				   const char *iface_name);
-void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface);
+void batadv_hardif_disable_interface(struct batadv_hard_iface *hard_iface,
+				     enum batadv_hard_if_cleanup autodel);
 void batadv_hardif_remove_interfaces(void);
 int batadv_hardif_min_mtu(struct net_device *soft_iface);
 void batadv_update_min_mtu(struct net_device *soft_iface);
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index ce39f62..15a22ef 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -588,13 +588,15 @@ static ssize_t batadv_store_mesh_iface(struct kobject *kobj,
 	}
 
 	if (status_tmp == BATADV_IF_NOT_IN_USE) {
-		batadv_hardif_disable_interface(hard_iface);
+		batadv_hardif_disable_interface(hard_iface,
+						BATADV_IF_CLEANUP_AUTO);
 		goto unlock;
 	}
 
 	/* if the interface already is in use */
 	if (hard_iface->if_status != BATADV_IF_NOT_IN_USE)
-		batadv_hardif_disable_interface(hard_iface);
+		batadv_hardif_disable_interface(hard_iface,
+						BATADV_IF_CLEANUP_AUTO);
 
 	ret = batadv_hardif_enable_interface(hard_iface, buff);
 
-- 
1.8.1.5
