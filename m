From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 2/8] batman-adv: refactor wifi interface detection
Date: Sat, 19 Nov 2016 14:35:22 +0100
Message-ID: <20161119133528.1379-3-sw@simonwunderlich.de>
References: <20161119133528.1379-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Sven Eckelmann <sven.eckelmann@open-mesh.com>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49953 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752735AbcKSNfd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:35:33 -0500
In-Reply-To: <20161119133528.1379-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

The ELP protocol requires cfg80211 to auto-detect the WiFi througput
to a given neighbor. Use batadv_is_cfg80211_netdev() to determine
whether or not an interface is eligible.

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_v_elp.c      | 29 ++++++++++++++---------------
 net/batman-adv/hard-interface.c | 26 +++++++++++++++++++++-----
 net/batman-adv/hard-interface.h |  1 +
 3 files changed, 36 insertions(+), 20 deletions(-)

diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index 54bdd41..e601def 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -90,22 +90,21 @@ static u32 batadv_v_elp_get_throughput(struct batadv_hardif_neigh_node *neigh)
 	 * cfg80211 API
 	 */
 	if (batadv_is_wifi_netdev(hard_iface->net_dev)) {
-		if (hard_iface->net_dev->ieee80211_ptr) {
-			ret = cfg80211_get_station(hard_iface->net_dev,
-						   neigh->addr, &sinfo);
-			if (ret == -ENOENT) {
-				/* Node is not associated anymore! It would be
-				 * possible to delete this neighbor. For now set
-				 * the throughput metric to 0.
-				 */
-				return 0;
-			}
-			if (!ret)
-				return sinfo.expected_throughput / 100;
+		if (!batadv_is_cfg80211_netdev(hard_iface->net_dev))
+			/* unsupported WiFi driver version */
+			goto default_throughput;
+
+		ret = cfg80211_get_station(hard_iface->net_dev,
+					   neigh->addr, &sinfo);
+		if (ret == -ENOENT) {
+			/* Node is not associated anymore! It would be
+			 * possible to delete this neighbor. For now set
+			 * the throughput metric to 0.
+			 */
+			return 0;
 		}
-
-		/* unsupported WiFi driver version */
-		goto default_throughput;
+		if (!ret)
+			return sinfo.expected_throughput / 100;
 	}
 
 	/* if not a wifi interface, check if this device provides data via
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index fdbb47e..c3fbc1b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -202,6 +202,26 @@ static bool batadv_is_valid_iface(const struct net_device *net_dev)
 }
 
 /**
+ * batadv_is_cfg80211_netdev - check if the given net_device struct is a
+ *  cfg80211 wifi interface
+ * @net_device: the device to check
+ *
+ * Return: true if the net device is a cfg80211 wireless device, false
+ *  otherwise.
+ */
+bool batadv_is_cfg80211_netdev(struct net_device *net_device)
+{
+	if (!net_device)
+		return false;
+
+	/* cfg80211 drivers have to set ieee80211_ptr */
+	if (net_device->ieee80211_ptr)
+		return true;
+
+	return false;
+}
+
+/**
  * batadv_is_wifi_netdev - check if the given net_device struct is a wifi
  *  interface
  * @net_device: the device to check
@@ -221,11 +241,7 @@ bool batadv_is_wifi_netdev(struct net_device *net_device)
 		return true;
 #endif
 
-	/* cfg80211 drivers have to set ieee80211_ptr */
-	if (net_device->ieee80211_ptr)
-		return true;
-
-	return false;
+	return batadv_is_cfg80211_netdev(net_device);
 }
 
 /**
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index a043182..7f9acab 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -65,6 +65,7 @@ enum batadv_hard_if_cleanup {
 
 extern struct notifier_block batadv_hard_if_notifier;
 
+bool batadv_is_cfg80211_netdev(struct net_device *net_device);
 bool batadv_is_wifi_netdev(struct net_device *net_device);
 bool batadv_is_wifi_iface(int ifindex);
 struct batadv_hard_iface*
-- 
2.10.2
