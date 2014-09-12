From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 3/3] bridge; Automatically filter vlans configured on top of bridge
Date: Fri, 12 Sep 2014 16:44:51 -0400
Message-ID: <1410554691-18467-4-git-send-email-vyasevic@redhat.com>
References: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
Cc: shemminger@vyatta.com, bridge@lists.linux-foundation.org,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:60928 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbaILUpE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2014 16:45:04 -0400
Received: by mail-qc0-f169.google.com with SMTP id r5so1495669qcx.14
        for <netdev@vger.kernel.org>; Fri, 12 Sep 2014 13:45:04 -0700 (PDT)
In-Reply-To: <1410554691-18467-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user configures vlan devices on top of the bridge,
automatically set up filter entries for it as long as
bridge vlan protocol matches that of the vlan.
This allows the user to atomatically receive vlan traffic
for the vlans that are convifgured.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  | 46 +++++++++++++++++++++++++++++++++++++++++++---
 net/bridge/br_private.h | 20 ++++++++++++++++++++
 2 files changed, 63 insertions(+), 3 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index af8f706..1e8caec 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -307,6 +307,45 @@ static int br_del_slave(struct net_device *dev, struct net_device *slave_dev)
 	return br_del_if(br, slave_dev);
 }
 
+static int br_vlan_rx_add_vid(struct net_device *br_dev,
+			      __be16 proto, u16 vid)
+{
+	struct net_bridge *br = netdev_priv(br_dev);
+
+	if (proto != br_vlan_protocol(br))
+		return 0;
+
+	/* vid 0 is special and will be added by the vlan layer to lower
+	 * devices.  Don't do anything here.
+	 */
+	if (vid == 0)
+		return 0;
+
+	return br_vlan_add(br, vid, 0);
+}
+
+static int br_vlan_rx_kill_vid(struct net_device *br_dev,
+			       __be16 proto, u16 vid)
+{
+	struct net_bridge *br = netdev_priv(br_dev);
+
+	if (proto != br_vlan_protocol(br))
+		return 0;
+
+	/* vid 0 is special and will be removed by the vlan layer from lower
+	 * devices.  Don't do anything here.
+	 */
+	if (vid == 0)
+		return 0;
+
+	/* Don't report error.  This will fail if the vlan was
+	 * previousely remove by some other means and we don't
+	 * wan't to polute the log/bug the user.
+	 */
+	br_vlan_delete(br, vid);
+	return 0;
+}
+
 static const struct ethtool_ops br_ethtool_ops = {
 	.get_drvinfo    = br_getinfo,
 	.get_link	= ethtool_op_get_link,
@@ -337,6 +376,8 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_bridge_getlink	 = br_getlink,
 	.ndo_bridge_setlink	 = br_setlink,
 	.ndo_bridge_dellink	 = br_dellink,
+	.ndo_vlan_rx_add_vid	 = br_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	 = br_vlan_rx_kill_vid,
 };
 
 static void br_dev_free(struct net_device *dev)
@@ -366,9 +407,8 @@ void br_dev_setup(struct net_device *dev)
 	dev->priv_flags = IFF_EBRIDGE;
 
 	dev->features = COMMON_FEATURES | NETIF_F_LLTX | NETIF_F_NETNS_LOCAL |
-			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
-	dev->hw_features = COMMON_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
-			   NETIF_F_HW_VLAN_STAG_TX;
+			BRIDGE_VLAN_FEATURES;
+	dev->hw_features = COMMON_FEATURES | BRIDGE_VLAN_FEATURES;
 	dev->vlan_features = COMMON_FEATURES;
 
 	br->dev = dev;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index bb4abdf..73a1563 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -29,6 +29,16 @@
 #define BR_MAX_PORTS	(1<<BR_PORT_BITS)
 #define BR_VLAN_BITMAP_LEN	BITS_TO_LONGS(VLAN_N_VID)
 
+#ifdef CONFIG_BRIDGE_VLAN_FILTERING
+#define BRIDGE_VLAN_FEATURES (NETIF_F_HW_VLAN_CTAG_TX | \
+			     NETIF_F_HW_VLAN_CTAG_FILTER | \
+			     NETIF_F_HW_VLAN_STAG_TX | \
+			     NETIF_F_HW_VLAN_STAG_FILTER)
+#else
+#define BRIDGE_VLAN_FEATURES (NETIF_F_HW_VLAN_CTAG_TX | \
+			     NETIF_F_HW_VLAN_STAG_TX)
+#endif
+
 #define BR_VERSION	"2.3"
 
 /* Control of forwarding link local multicast */
@@ -654,6 +664,11 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return br->vlan_enabled;
 }
+
+static inline __be16 br_vlan_protocol(struct net_bridge *br)
+{
+	return br->vlan_proto;
+}
 #else
 static inline bool br_allowed_ingress(struct net_bridge *br,
 				      struct net_port_vlans *v,
@@ -759,6 +774,11 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 {
 	return 0;
 }
+
+static inline __be16 br_vlan_protocol(struct net_bridge *br)
+{
+	return 0;
+}
 #endif
 
 /* br_netfilter.c */
-- 
1.9.3
