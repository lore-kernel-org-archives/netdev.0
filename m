From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/21] batman-adv: split batadv_is_wifi_iface() into two functions
Date: Wed, 29 May 2013 02:59:26 +0200
Message-ID: <1369789186-3600-2-git-send-email-ordex@autistici.org>
References: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Matthias Schiffer <mschiffer@universe-factory.net>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from contumacia.investici.org ([178.255.144.35]:43805 "EHLO
	contumacia.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759017Ab3E2BBq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 21:01:46 -0400
In-Reply-To: <1369789186-3600-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Schiffer <mschiffer@universe-factory.net>

Previously batadv_is_wifi_iface() did two things at once: looking up a
net_device from an interface index, and determining if it is a wifi device.

The second part is useful itself when the caller already has a net_device
reference.

Signed-off-by: Matthias Schiffer <mschiffer@universe-factory.net>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/hard-interface.c | 84 +++++++++++++++++++++++++----------------
 1 file changed, 52 insertions(+), 32 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-interface.c
index b6504ea..d5ec67b 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -117,6 +117,58 @@ static int batadv_is_valid_iface(const struct net_device *net_dev)
 	return 1;
 }
 
+/**
+ * batadv_is_wifi_netdev - check if the given net_device struct is a wifi
+ *  interface
+ * @net_device: the device to check
+ *
+ * Returns true if the net device is a 802.11 wireless device, false otherwise.
+ */
+static bool batadv_is_wifi_netdev(struct net_device *net_device)
+{
+#ifdef CONFIG_WIRELESS_EXT
+	/* pre-cfg80211 drivers have to implement WEXT, so it is possible to
+	 * check for wireless_handlers != NULL
+	 */
+	if (net_device->wireless_handlers)
+		return true;
+#endif
+
+	/* cfg80211 drivers have to set ieee80211_ptr */
+	if (net_device->ieee80211_ptr)
+		return true;
+
+	return false;
+}
+
+/**
+ * batadv_is_wifi_iface - check if the given interface represented by ifindex
+ *  is a wifi interface
+ * @ifindex: interface index to check
+ *
+ * Returns true if the interface represented by ifindex is a 802.11 wireless
+ * device, false otherwise.
+ */
+bool batadv_is_wifi_iface(int ifindex)
+{
+	struct net_device *net_device = NULL;
+	bool ret = false;
+
+	if (ifindex == BATADV_NULL_IFINDEX)
+		goto out;
+
+	net_device = dev_get_by_index(&init_net, ifindex);
+	if (!net_device)
+		goto out;
+
+	ret = batadv_is_wifi_netdev(net_device);
+
+out:
+	if (net_device)
+		dev_put(net_device);
+	return ret;
+}
+
 static struct batadv_hard_iface *
 batadv_hardif_get_active(const struct net_device *soft_iface)
 {
@@ -657,38 +709,6 @@ out:
 	return NOTIFY_DONE;
 }
 
-/* This function returns true if the interface represented by ifindex is a
- * 802.11 wireless device
- */
-bool batadv_is_wifi_iface(int ifindex)
-{
-	struct net_device *net_device = NULL;
-	bool ret = false;
-
-	if (ifindex == BATADV_NULL_IFINDEX)
-		goto out;
-
-	net_device = dev_get_by_index(&init_net, ifindex);
-	if (!net_device)
-		goto out;
-
-#ifdef CONFIG_WIRELESS_EXT
-	/* pre-cfg80211 drivers have to implement WEXT, so it is possible to
-	 * check for wireless_handlers != NULL
-	 */
-	if (net_device->wireless_handlers)
-		ret = true;
-	else
-#endif
-		/* cfg80211 drivers have to set ieee80211_ptr */
-		if (net_device->ieee80211_ptr)
-			ret = true;
-out:
-	if (net_device)
-		dev_put(net_device);
-	return ret;
-}
-
 struct notifier_block batadv_hard_if_notifier = {
 	.notifier_call = batadv_hard_if_event,
 };
-- 
1.8.1.5
