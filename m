From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 5/8] batman-adv: retrieve B.A.T.M.A.N. V WiFi neighbor stats from real interface
Date: Sat, 19 Nov 2016 14:35:25 +0100
Message-ID: <20161119133528.1379-6-sw@simonwunderlich.de>
References: <20161119133528.1379-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Sven Eckelmann <sven.eckelmann@open-mesh.com>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49979 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752820AbcKSNfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:35:34 -0500
In-Reply-To: <20161119133528.1379-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marek Lindner <mareklindner@neomailbox.ch>

Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
[sven.eckelmann@open-mesh.com: re-add batadv_get_real_netdev to take rtnl
 semaphore for batadv_get_real_netdevice]
Signed-off-by: Sven Eckelmann <sven.eckelmann@open-mesh.com>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/bat_v_elp.c      | 10 ++++++++--
 net/batman-adv/hard-interface.c | 22 ++++++++++++++++++++++
 net/batman-adv/hard-interface.h |  1 +
 3 files changed, 31 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index 0d78689..f2fb2f0 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -75,6 +75,7 @@ static u32 batadv_v_elp_get_throughput(struct batadv_hardif_neigh_node *neigh)
 {
 	struct batadv_hard_iface *hard_iface = neigh->if_incoming;
 	struct ethtool_link_ksettings link_settings;
+	struct net_device *real_netdev;
 	struct station_info sinfo;
 	u32 throughput;
 	int ret;
@@ -94,8 +95,13 @@ static u32 batadv_v_elp_get_throughput(struct batadv_hardif_neigh_node *neigh)
 			/* unsupported WiFi driver version */
 			goto default_throughput;
 
-		ret = cfg80211_get_station(hard_iface->net_dev,
-					   neigh->addr, &sinfo);
+		real_netdev = batadv_get_real_netdev(hard_iface->net_dev);
+		if (!real_netdev)
+			goto default_throughput;
+
+		ret = cfg80211_get_station(real_netdev, neigh->addr, &sinfo);
+
+		dev_put(real_netdev);
 		if (ret == -ENOENT) {
 			/* Node is not associated anymore! It would be
 			 * possible to delete this neighbor. For now set
diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index df31f2f..ca743a5 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -206,6 +206,9 @@ static bool batadv_is_valid_iface(const struct net_device *net_dev)
  *  interface on top of another 'real' interface
  * @netdev: the device to check
  *
+ * Callers must hold the rtnl semaphore. You may want batadv_get_real_netdev()
+ * instead of this.
+ *
  * Return: the 'real' net device or the original net device and NULL in case
  *  of an error.
  */
@@ -243,6 +246,25 @@ static struct net_device *batadv_get_real_netdevice(struct net_device *netdev)
 }
 
 /**
+ * batadv_get_real_netdev - check if the given net_device struct is a virtual
+ *  interface on top of another 'real' interface
+ * @net_device: the device to check
+ *
+ * Return: the 'real' net device or the original net device and NULL in case
+ *  of an error.
+ */
+struct net_device *batadv_get_real_netdev(struct net_device *net_device)
+{
+	struct net_device *real_netdev;
+
+	rtnl_lock();
+	real_netdev = batadv_get_real_netdevice(net_device);
+	rtnl_unlock();
+
+	return real_netdev;
+}
+
+/**
  * batadv_is_wext_netdev - check if the given net_device struct is a
  *  wext wifi interface
  * @net_device: the device to check
diff --git a/net/batman-adv/hard-interface.h b/net/batman-adv/hard-interface.h
index 7281dd2..d6309a4 100644
--- a/net/batman-adv/hard-interface.h
+++ b/net/batman-adv/hard-interface.h
@@ -65,6 +65,7 @@ enum batadv_hard_if_cleanup {
 
 extern struct notifier_block batadv_hard_if_notifier;
 
+struct net_device *batadv_get_real_netdev(struct net_device *net_device);
 bool batadv_is_cfg80211_hardif(struct batadv_hard_iface *hard_iface);
 bool batadv_is_wifi_hardif(struct batadv_hard_iface *hard_iface);
 struct batadv_hard_iface*
-- 
2.10.2
