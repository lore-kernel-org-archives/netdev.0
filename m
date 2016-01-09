From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 04/16] batman-adv: purge bridge loop avoidance when its disabled
Date: Sat,  9 Jan 2016 21:20:09 +0800
Message-ID: <1452345621-15908-5-git-send-email-a@unstable.cc>
References: <1452345621-15908-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s1.neomailbox.net ([5.148.176.57]:8822 "EHLO s1.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755147AbcAINWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jan 2016 08:22:25 -0500
In-Reply-To: <1452345621-15908-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon@open-mesh.com>

When bridge loop avoidance is disabled through sysfs, the internal
datastructures are not disabled, but only BLA operations are disabled.
To be sure that they are removed, purge the data immediately. That is
especially useful if a firmwares network state is changed, and the BLA
wait periods should restart on the new network.

Signed-off-by: Simon Wunderlich <simon@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/bridge_loop_avoidance.c | 20 ++++++++++++++++++++
 net/batman-adv/bridge_loop_avoidance.h |  2 ++
 net/batman-adv/sysfs.c                 |  4 +++-
 3 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 99dcae316ec8..d5d71ac96c8a 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -1168,6 +1168,26 @@ void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 	}
 }
 
+/**
+ * batadv_bla_status_update - purge bla interfaces if necessary
+ * @net_dev: the soft interface net device
+ */
+void batadv_bla_status_update(struct net_device *net_dev)
+{
+	struct batadv_priv *bat_priv = netdev_priv(net_dev);
+	struct batadv_hard_iface *primary_if;
+
+	primary_if = batadv_primary_if_get_selected(bat_priv);
+	if (!primary_if)
+		return;
+
+	/* this function already purges everything when bla is disabled,
+	 * so just call that one.
+	 */
+	batadv_bla_update_orig_address(bat_priv, primary_if, primary_if);
+	batadv_hardif_free_ref(primary_if);
+}
+
 /* periodic work to do:
  *  * purge structures when they are too old
  *  * send announcements
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index 025152b34282..7ea199b8b5ab 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -22,6 +22,7 @@
 
 #include <linux/types.h>
 
+struct net_device;
 struct seq_file;
 struct sk_buff;
 
@@ -42,6 +43,7 @@ int batadv_bla_check_bcast_duplist(struct batadv_priv *bat_priv,
 void batadv_bla_update_orig_address(struct batadv_priv *bat_priv,
 				    struct batadv_hard_iface *primary_if,
 				    struct batadv_hard_iface *oldif);
+void batadv_bla_status_update(struct net_device *net_dev);
 int batadv_bla_init(struct batadv_priv *bat_priv);
 void batadv_bla_free(struct batadv_priv *bat_priv);
 
diff --git a/net/batman-adv/sysfs.c b/net/batman-adv/sysfs.c
index 9de3c8804ff4..48e2aaddda49 100644
--- a/net/batman-adv/sysfs.c
+++ b/net/batman-adv/sysfs.c
@@ -40,6 +40,7 @@
 #include "distributed-arp-table.h"
 #include "gateway_client.h"
 #include "gateway_common.h"
+#include "bridge_loop_avoidance.h"
 #include "hard-interface.h"
 #include "network-coding.h"
 #include "packet.h"
@@ -549,7 +550,8 @@ static ssize_t batadv_store_isolation_mark(struct kobject *kobj,
 BATADV_ATTR_SIF_BOOL(aggregated_ogms, S_IRUGO | S_IWUSR, NULL);
 BATADV_ATTR_SIF_BOOL(bonding, S_IRUGO | S_IWUSR, NULL);
 #ifdef CONFIG_BATMAN_ADV_BLA
-BATADV_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR, NULL);
+BATADV_ATTR_SIF_BOOL(bridge_loop_avoidance, S_IRUGO | S_IWUSR,
+		     batadv_bla_status_update);
 #endif
 #ifdef CONFIG_BATMAN_ADV_DAT
 BATADV_ATTR_SIF_BOOL(distributed_arp_table, S_IRUGO | S_IWUSR,
-- 
2.7.0
