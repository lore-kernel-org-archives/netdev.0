From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vlan: propogate ethtool speed values
Date: Tue, 28 Oct 2008 17:53:08 -0700
Message-ID: <20081028175308.07202283@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39366 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751365AbYJ2AxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 20:53:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This enables more ethtool information. The speed and settings of the
underlying device are propagated up. This makes services like SNMP that
use ethtool to get speed setting, work when managing a vlan, without adding
silly heurtistics into SNMP daemon.

For the driver info, just use existing driver strings.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/8021q/vlan.c	2008-10-28 17:39:54.000000000 -0700
+++ b/net/8021q/vlan.c	2008-10-28 17:40:48.000000000 -0700
@@ -46,10 +46,10 @@ int vlan_net_id;
 /* Our listing of VLAN group(s) */
 static struct hlist_head vlan_group_hash[VLAN_GRP_HASH_SIZE];
 
-static char vlan_fullname[] = "802.1Q VLAN Support";
-static char vlan_version[] = DRV_VERSION;
-static char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
-static char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
+const char vlan_fullname[] = "802.1Q VLAN Support";
+const char vlan_version[] = DRV_VERSION;
+static const char vlan_copyright[] = "Ben Greear <greearb@candelatech.com>";
+static const char vlan_buggyright[] = "David S. Miller <davem@redhat.com>";
 
 static struct packet_type vlan_packet_type = {
 	.type = __constant_htons(ETH_P_8021Q),
--- a/net/8021q/vlan.h	2008-10-28 17:40:58.000000000 -0700
+++ b/net/8021q/vlan.h	2008-10-28 17:43:36.000000000 -0700
@@ -108,8 +108,10 @@ static inline int vlan_gvrp_init(void) {
 static inline void vlan_gvrp_uninit(void) {}
 #endif
 
-int vlan_netlink_init(void);
-void vlan_netlink_fini(void);
+extern const char vlan_fullname[];
+extern const char vlan_version[];
+extern int vlan_netlink_init(void);
+extern void vlan_netlink_fini(void);
 
 extern struct rtnl_link_ops vlan_link_ops;
 
--- a/net/8021q/vlan_dev.c	2008-10-28 17:33:55.000000000 -0700
+++ b/net/8021q/vlan_dev.c	2008-10-28 17:45:42.000000000 -0700
@@ -648,6 +648,26 @@ static void vlan_dev_uninit(struct net_d
 	}
 }
 
+static int vlan_ethtool_get_settings(struct net_device *dev,
+				     struct ethtool_cmd *cmd)
+{
+	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	struct net_device *real_dev = vlan->real_dev;
+
+	if (!real_dev->ethtool_ops->get_settings)
+		return -EOPNOTSUPP;
+
+	return real_dev->ethtool_ops->get_settings(real_dev, cmd);
+}
+
+static void vlan_ethtool_get_drvinfo(struct net_device *dev,
+				     struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, vlan_fullname);
+	strcpy(info->version, vlan_version);
+	strcpy(info->fw_version, "N/A");
+}
+
 static u32 vlan_ethtool_get_rx_csum(struct net_device *dev)
 {
 	const struct vlan_dev_info *vlan = vlan_dev_info(dev);
@@ -672,6 +692,8 @@ static u32 vlan_ethtool_get_flags(struct
 }
 
 static const struct ethtool_ops vlan_ethtool_ops = {
+	.get_settings	        = vlan_ethtool_get_settings,
+	.get_drvinfo	        = vlan_ethtool_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_rx_csum		= vlan_ethtool_get_rx_csum,
 	.get_flags		= vlan_ethtool_get_flags,
