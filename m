From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] bridge: limited ethtool support
Date: Tue, 20 Dec 2005 15:19:53 -0800
Message-ID: <20051220232154.935401000@localhost.localdomain>
References: <20051220231949.772360000@localhost.localdomain>
Content-Type: multipart/mixed; boundary="===============89445137692724774=="
Cc: netdev@vger.kernel.org, bridge@osdl.org
Return-path: <bridge-bounces@lists.osdl.org>
To: David Miller <davem@davemloft.net>
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============89445137692724774==
Content-Disposition: inline; filename=br-ethtool.patch

Add limited ethtool support to bridge to allow disabling
features. 

Note: if underlying device does not support a feature (like checksum
offload), then the bridge device won't inherit it.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- br-2.6.16.orig/net/bridge/br_device.c
+++ br-2.6.16/net/bridge/br_device.c
@@ -16,6 +16,7 @@
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -106,6 +107,64 @@ static int br_set_mac_address(struct net
 	return err;
 }
 
+static void br_getinfo(struct net_device *dev, struct ethtool_drvinfo *info)
+{
+	strcpy(info->driver, "bridge");
+	strcpy(info->version, BR_VERSION);
+	strcpy(info->fw_version, "N/A");
+	strcpy(info->bus_info, "N/A");
+}
+
+static int br_set_sg(struct net_device *dev, u32 data)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	if (data)
+		br->feature_mask |= NETIF_F_SG;
+	else
+		br->feature_mask &= ~NETIF_F_SG;
+
+	br_features_recompute(br);
+	return 0;
+}
+
+static int br_set_tso(struct net_device *dev, u32 data)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	if (data)
+		br->feature_mask |= NETIF_F_TSO;
+	else
+		br->feature_mask &= ~NETIF_F_TSO;
+
+	br_features_recompute(br);
+	return 0;
+}
+
+static int br_set_tx_csum(struct net_device *dev, u32 data)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	if (data)
+		br->feature_mask |= NETIF_F_IP_CSUM;
+	else
+		br->feature_mask &= ~NETIF_F_IP_CSUM;
+
+	br_features_recompute(br);
+	return 0;
+}
+
+static struct ethtool_ops br_ethtool_ops = {
+	.get_drvinfo = br_getinfo,
+	.get_link = ethtool_op_get_link,
+	.get_sg = ethtool_op_get_sg,
+	.set_sg = br_set_sg,
+	.get_tx_csum = ethtool_op_get_tx_csum,
+	.set_tx_csum = br_set_tx_csum,
+	.get_tso = ethtool_op_get_tso,
+	.set_tso = br_set_tso,
+};
+
 void br_dev_setup(struct net_device *dev)
 {
 	memset(dev->dev_addr, 0, ETH_ALEN);
@@ -120,8 +179,12 @@ void br_dev_setup(struct net_device *dev
 	dev->change_mtu = br_change_mtu;
 	dev->destructor = free_netdev;
 	SET_MODULE_OWNER(dev);
+ 	SET_ETHTOOL_OPS(dev, &br_ethtool_ops);
 	dev->stop = br_dev_stop;
 	dev->tx_queue_len = 0;
 	dev->set_mac_address = br_set_mac_address;
 	dev->priv_flags = IFF_EBRIDGE;
+
+ 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST
+ 		| NETIF_F_HIGHDMA | NETIF_F_TSO | NETIF_F_IP_CSUM;
 }
--- br-2.6.16.orig/net/bridge/br_if.c
+++ br-2.6.16/net/bridge/br_if.c
@@ -182,6 +182,7 @@ static struct net_device *new_bridge_dev
 	br->bridge_id.prio[1] = 0x00;
 	memset(br->bridge_id.addr, 0, ETH_ALEN);
 
+	br->feature_mask = dev->features;
 	br->stp_enabled = 0;
 	br->designated_root = br->bridge_id;
 	br->root_path_cost = 0;
@@ -349,9 +350,8 @@ void br_features_recompute(struct net_br
 	struct net_bridge_port *p;
 	unsigned long features, checksum;
 
-	features = NETIF_F_SG | NETIF_F_FRAGLIST 
-		| NETIF_F_HIGHDMA | NETIF_F_TSO;
-	checksum = NETIF_F_IP_CSUM;	/* least commmon subset */
+	features = br->feature_mask &~ NETIF_F_IP_CSUM;
+	checksum = br->feature_mask & NETIF_F_IP_CSUM;
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (!(p->dev->features 
--- br-2.6.16.orig/net/bridge/br_private.h
+++ br-2.6.16/net/bridge/br_private.h
@@ -93,6 +93,7 @@ struct net_bridge
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
 	struct list_head		age_list;
+	unsigned long			feature_mask;
 
 	/* STP */
 	bridge_id			designated_root;

--
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger


--===============89445137692724774==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/bridge

--===============89445137692724774==--
