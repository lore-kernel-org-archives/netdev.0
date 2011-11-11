From: ddaney.cavm@gmail.com
Subject: [PATCH 8/8] staging: octeon_ethernet: Convert to use device tree.
Date: Thu, 10 Nov 2011 18:22:04 -0800
Message-ID: <1320978124-13042-9-git-send-email-ddaney.cavm@gmail.com>
References: <1320978124-13042-1-git-send-email-ddaney.cavm@gmail.com>
Cc: David Daney <david.daney@cavium.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>, devel@driverdev.osuosl.org
To: linux-mips@linux-mips.org, ralf@linux-mips.org,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320978124-13042-1-git-send-email-ddaney.cavm@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Get MAC address and PHY connection from the device tree.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: devel@driverdev.osuosl.org 
Signed-off-by: David Daney <david.daney@cavium.com>
---
 drivers/staging/octeon/ethernet-mdio.c   |   28 +++++----
 drivers/staging/octeon/ethernet.c        |   91 ++++++++++++++++++------------
 drivers/staging/octeon/octeon-ethernet.h |    3 +
 3 files changed, 72 insertions(+), 50 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging/octeon/ethernet-mdio.c
index 63800ba..f15b31b 100644
--- a/drivers/staging/octeon/ethernet-mdio.c
+++ b/drivers/staging/octeon/ethernet-mdio.c
@@ -28,6 +28,7 @@
 #include <linux/ethtool.h>
 #include <linux/phy.h>
 #include <linux/ratelimit.h>
+#include <linux/of_mdio.h>
 
 #include <net/dst.h>
 
@@ -161,22 +162,23 @@ static void cvm_oct_adjust_link(struct net_device *dev)
 int cvm_oct_phy_setup_device(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
+	struct device_node *phy_node;
 
-	int phy_addr = cvmx_helper_board_get_mii_address(priv->port);
-	if (phy_addr != -1) {
-		char phy_id[20];
+	if (!priv->of_node)
+		return 0;
 
-		snprintf(phy_id, sizeof(phy_id), PHY_ID_FMT, "0", phy_addr);
+	phy_node = of_parse_phandle(priv->of_node, "phy-handle", 0);
+	if (!phy_node)
+		return 0;
 
-		priv->phydev = phy_connect(dev, phy_id, cvm_oct_adjust_link, 0,
-					PHY_INTERFACE_MODE_GMII);
+	priv->phydev = of_phy_connect(dev, phy_node, cvm_oct_adjust_link, 0,
+				      PHY_INTERFACE_MODE_GMII);
+
+	if (priv->phydev == NULL)
+		return -ENODEV;
+
+	priv->last_link = 0;
+	phy_start_aneg(priv->phydev);
 
-		if (IS_ERR(priv->phydev)) {
-			priv->phydev = NULL;
-			return -1;
-		}
-		priv->last_link = 0;
-		phy_start_aneg(priv->phydev);
-	}
 	return 0;
 }
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 9112cd8..5e96da6 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -31,6 +31,7 @@
 #include <linux/etherdevice.h>
 #include <linux/phy.h>
 #include <linux/slab.h>
+#include <linux/of_net.h>
 
 #include <net/dst.h>
 
@@ -112,15 +113,6 @@ int rx_napi_weight = 32;
 module_param(rx_napi_weight, int, 0444);
 MODULE_PARM_DESC(rx_napi_weight, "The NAPI WEIGHT parameter.");
 
-/*
- * The offset from mac_addr_base that should be used for the next port
- * that is configured.  By convention, if any mgmt ports exist on the
- * chip, they get the first mac addresses, The ports controlled by
- * this driver are numbered sequencially following any mgmt addresses
- * that may exist.
- */
-static unsigned int cvm_oct_mac_addr_offset;
-
 /**
  * cvm_oct_poll_queue - Workqueue for polling operations.
  */
@@ -447,26 +439,16 @@ static int cvm_oct_common_set_mac_address(struct net_device *dev, void *addr)
 int cvm_oct_common_init(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
-	struct sockaddr sa;
-	u64 mac = ((u64)(octeon_bootinfo->mac_addr_base[0] & 0xff) << 40) |
-		((u64)(octeon_bootinfo->mac_addr_base[1] & 0xff) << 32) |
-		((u64)(octeon_bootinfo->mac_addr_base[2] & 0xff) << 24) |
-		((u64)(octeon_bootinfo->mac_addr_base[3] & 0xff) << 16) |
-		((u64)(octeon_bootinfo->mac_addr_base[4] & 0xff) << 8) |
-		(u64)(octeon_bootinfo->mac_addr_base[5] & 0xff);
-
-	mac += cvm_oct_mac_addr_offset;
-	sa.sa_data[0] = (mac >> 40) & 0xff;
-	sa.sa_data[1] = (mac >> 32) & 0xff;
-	sa.sa_data[2] = (mac >> 24) & 0xff;
-	sa.sa_data[3] = (mac >> 16) & 0xff;
-	sa.sa_data[4] = (mac >> 8) & 0xff;
-	sa.sa_data[5] = mac & 0xff;
-
-	if (cvm_oct_mac_addr_offset >= octeon_bootinfo->mac_addr_count)
-		printk(KERN_DEBUG "%s: Using MAC outside of the assigned range:"
-			" %pM\n", dev->name, sa.sa_data);
-	cvm_oct_mac_addr_offset++;
+	struct sockaddr sa = {0};
+	const u8 *mac = NULL;
+
+	if (priv->of_node)
+		mac = of_get_mac_address(priv->of_node);
+
+	if (mac)
+		memcpy(sa.sa_data, mac, ETH_ALEN);
+	else
+		dev_hw_addr_random(dev, sa.sa_data);
 
 	/*
 	 * Force the interface to use the POW send if always_use_pow
@@ -594,22 +576,55 @@ static const struct net_device_ops cvm_oct_pow_netdev_ops = {
 
 extern void octeon_mdiobus_force_mod_depencency(void);
 
+static struct device_node * __init cvm_oct_of_get_child(const struct device_node *parent,
+							int reg_val)
+{
+	struct device_node *node = NULL;
+	int size;
+	const __be32 *addr;
+
+	for (;;) {
+		node = of_get_next_child(parent, node);
+		if (!node)
+			break;
+		addr = of_get_property(node, "reg", &size);
+		if (addr && (be32_to_cpu(*addr) == reg_val))
+			break;
+	}
+	return node;
+}
+
+static struct device_node * __init cvm_oct_node_for_port(struct device_node *pip,
+							 int interface, int port)
+{
+	struct device_node *ni, *np;
+
+	ni = cvm_oct_of_get_child(pip, interface);
+	if (!ni)
+		return NULL;
+
+	np = cvm_oct_of_get_child(ni, port);
+	of_node_put(ni);
+
+	return np;
+}
+
 static int __init cvm_oct_init_module(void)
 {
 	int num_interfaces;
 	int interface;
 	int fau = FAU_NUM_PACKET_BUFFERS_TO_FREE;
 	int qos;
+	struct device_node *pip;
 
 	octeon_mdiobus_force_mod_depencency();
 	pr_notice("cavium-ethernet %s\n", OCTEON_ETHERNET_VERSION);
 
-	if (OCTEON_IS_MODEL(OCTEON_CN52XX))
-		cvm_oct_mac_addr_offset = 2; /* First two are the mgmt ports. */
-	else if (OCTEON_IS_MODEL(OCTEON_CN56XX))
-		cvm_oct_mac_addr_offset = 1; /* First one is the mgmt port. */
-	else
-		cvm_oct_mac_addr_offset = 0;
+	pip = of_find_node_by_path("pip");
+	if (!pip) {
+		pr_err("Error: No 'pip' in /aliases\n");
+		return -EINVAL;
+	}
 
 	cvm_oct_poll_queue = create_singlethread_workqueue("octeon-ethernet");
 	if (cvm_oct_poll_queue == NULL) {
@@ -688,10 +703,11 @@ static int __init cvm_oct_init_module(void)
 		    cvmx_helper_interface_get_mode(interface);
 		int num_ports = cvmx_helper_ports_on_interface(interface);
 		int port;
+		int port_index;
 
-		for (port = cvmx_helper_get_ipd_port(interface, 0);
+		for (port_index = 0, port = cvmx_helper_get_ipd_port(interface, 0);
 		     port < cvmx_helper_get_ipd_port(interface, num_ports);
-		     port++) {
+		     port_index++, port++) {
 			struct octeon_ethernet *priv;
 			struct net_device *dev =
 			    alloc_etherdev(sizeof(struct octeon_ethernet));
@@ -702,6 +718,7 @@ static int __init cvm_oct_init_module(void)
 
 			/* Initialize the device private structure. */
 			priv = netdev_priv(dev);
+			priv->of_node = cvm_oct_node_for_port(pip, interface, port_index);
 
 			INIT_DELAYED_WORK(&priv->port_periodic_work,
 					  cvm_oct_periodic_worker);
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index d581925..9360e22 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -31,6 +31,8 @@
 #ifndef OCTEON_ETHERNET_H
 #define OCTEON_ETHERNET_H
 
+#include <linux/of.h>
+
 /**
  * This is the definition of the Ethernet driver's private
  * driver state stored in netdev_priv(dev).
@@ -59,6 +61,7 @@ struct octeon_ethernet {
 	void (*poll) (struct net_device *dev);
 	struct delayed_work	port_periodic_work;
 	struct work_struct	port_work;	/* may be unused. */
+	struct device_node	*of_node;
 };
 
 int cvm_oct_free_work(void *work_queue_entry);
-- 
1.7.2.3
