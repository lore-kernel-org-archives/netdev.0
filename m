From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 06/12] netxen: module params for ring sizes
Date: Sun, 26 Jul 2009 23:07:41 -0700
Message-ID: <1248674867-18821-7-git-send-email-dhananjay@netxen.com>
References: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:33575 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751283AbZG0GHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 02:07:48 -0400
In-Reply-To: <1248674867-18821-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add module parameters to set rx, jumbo and tx ring sizes
globally. 1GbE and 10GbE ports can have different ring
sizes.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   19 +++++--
 drivers/net/netxen/netxen_nic_ethtool.c |   21 ++++----
 drivers/net/netxen/netxen_nic_main.c    |   89 +++++++++++++++++++++++++-----
 3 files changed, 98 insertions(+), 31 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 3a4cbd5..e017827 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -200,13 +200,20 @@
 #define RCV_RING_JUMBO	1
 #define RCV_RING_LRO	2
 
-#define MAX_CMD_DESCRIPTORS		4096
-#define MAX_RCV_DESCRIPTORS		16384
-#define MAX_CMD_DESCRIPTORS_HOST	1024
-#define MAX_RCV_DESCRIPTORS_1G		2048
-#define MAX_RCV_DESCRIPTORS_10G		4096
-#define MAX_JUMBO_RCV_DESCRIPTORS	1024
+#define MIN_CMD_DESCRIPTORS		64
+#define MIN_RCV_DESCRIPTORS		64
+#define MIN_JUMBO_DESCRIPTORS		32
+
+#define MAX_CMD_DESCRIPTORS		1024
+#define MAX_RCV_DESCRIPTORS_1G		4096
+#define MAX_RCV_DESCRIPTORS_10G		8192
+#define MAX_JUMBO_RCV_DESCRIPTORS_1G	512
+#define MAX_JUMBO_RCV_DESCRIPTORS_10G	1024
 #define MAX_LRO_RCV_DESCRIPTORS		8
+
+#define DEFAULT_RCV_DESCRIPTORS_1G	2048
+#define DEFAULT_RCV_DESCRIPTORS_10G	4096
+
 #define NETXEN_CTX_SIGNATURE	0xdee0
 #define NETXEN_CTX_SIGNATURE_V2	0x0002dee0
 #define NETXEN_CTX_RESET	0xbad0
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index e16ea46..80d286d 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -494,20 +494,21 @@ netxen_nic_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ring)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
 
-	ring->rx_pending = 0;
-	ring->rx_jumbo_pending = 0;
-	ring->rx_pending += adapter->recv_ctx.
-		rds_rings[RCV_RING_NORMAL].num_desc;
-	ring->rx_jumbo_pending += adapter->recv_ctx.
-		rds_rings[RCV_RING_JUMBO].num_desc;
+	ring->rx_pending = adapter->num_rxd;
+	ring->rx_jumbo_pending = adapter->num_jumbo_rxd;
+	ring->rx_jumbo_pending += adapter->num_lro_rxd;
 	ring->tx_pending = adapter->num_txd;
 
-	if (adapter->ahw.port_type == NETXEN_NIC_GBE)
+	if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
 		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_1G;
-	else
+		ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS_1G;
+	} else {
 		ring->rx_max_pending = MAX_RCV_DESCRIPTORS_10G;
-	ring->tx_max_pending = MAX_CMD_DESCRIPTORS_HOST;
-	ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS;
+		ring->rx_jumbo_max_pending = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+	}
+
+	ring->tx_max_pending = MAX_CMD_DESCRIPTORS;
+
 	ring->rx_mini_max_pending = 0;
 	ring->rx_mini_pending = 0;
 }
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 381bd8f..3f64a10 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -58,6 +58,26 @@ static int use_msi = 1;
 
 static int use_msi_x = 1;
 
+static u32 tx_desc = MAX_CMD_DESCRIPTORS;
+module_param(tx_desc, uint, S_IRUGO);
+MODULE_PARM_DESC(tx_desc, "Transmit descriptors count");
+
+static u32 rdesc_1g = DEFAULT_RCV_DESCRIPTORS_1G;
+module_param(rdesc_1g, uint, S_IRUGO);
+MODULE_PARM_DESC(rdesc_1g, "Receive descriptors count for 1GbE");
+
+static u32 rdesc_10g = DEFAULT_RCV_DESCRIPTORS_10G;
+module_param(rdesc_10g, uint, S_IRUGO);
+MODULE_PARM_DESC(rdesc_10g, "Receive descriptors count for 10GbE");
+
+static u32 jumbo_desc_1g = MAX_JUMBO_RCV_DESCRIPTORS_1G;
+module_param(jumbo_desc_1g, uint, S_IRUGO);
+MODULE_PARM_DESC(jumbo_desc_1g, "Jumbo receive descriptors count for 1GbE");
+
+static u32 jumbo_desc_10g = MAX_JUMBO_RCV_DESCRIPTORS_10G;
+module_param(jumbo_desc_10g, uint, S_IRUGO);
+MODULE_PARM_DESC(jumbo_desc_10g, "Jumbo receive descriptors count for 10GbE");
+
 /* Local functions to NetXen NIC driver */
 static int __devinit netxen_nic_probe(struct pci_dev *pdev,
 		const struct pci_device_id *ent);
@@ -283,12 +303,16 @@ nx_update_dma_mask(struct netxen_adapter *adapter)
 	return 0;
 }
 
-static void netxen_check_options(struct netxen_adapter *adapter)
+static void
+netxen_check_options(struct netxen_adapter *adapter)
 {
-	if (adapter->ahw.port_type == NETXEN_NIC_XGBE)
-		adapter->num_rxd = MAX_RCV_DESCRIPTORS_10G;
-	else if (adapter->ahw.port_type == NETXEN_NIC_GBE)
-		adapter->num_rxd = MAX_RCV_DESCRIPTORS_1G;
+	if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
+		adapter->num_rxd = rdesc_10g;
+		adapter->num_jumbo_rxd = jumbo_desc_10g;
+	} else if (adapter->ahw.port_type == NETXEN_NIC_GBE) {
+		adapter->num_rxd = rdesc_1g;
+		adapter->num_jumbo_rxd = jumbo_desc_1g;
+	}
 
 	adapter->msix_supported = 0;
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
@@ -306,11 +330,15 @@ static void netxen_check_options(struct netxen_adapter *adapter)
 		}
 	}
 
-	adapter->num_txd = MAX_CMD_DESCRIPTORS_HOST;
-	adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS;
-	adapter->num_lro_rxd = MAX_LRO_RCV_DESCRIPTORS;
+	adapter->num_txd = tx_desc;
 
-	return;
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+		adapter->num_lro_rxd = MAX_LRO_RCV_DESCRIPTORS;
+		adapter->max_rds_rings = 3;
+	} else {
+		adapter->num_lro_rxd = 0;
+		adapter->max_rds_rings = 2;
+	}
 }
 
 static int
@@ -908,11 +936,6 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 		return -EIO;
 	}
 
-	if (adapter->fw_major < 4)
-		adapter->max_rds_rings = 3;
-	else
-		adapter->max_rds_rings = 2;
-
 	err = netxen_alloc_sw_resources(adapter);
 	if (err) {
 		printk(KERN_ERR "%s: Error in setting sw resources\n",
@@ -1923,11 +1946,47 @@ static struct pci_driver netxen_driver = {
 #endif
 };
 
-/* Driver Registration on NetXen card    */
+u32
+netxen_validate_ringparam(u32 val, u32 min, u32 max, char *r_name)
+{
+	u32 num_desc;
+	num_desc = max(val, min);
+	num_desc = min(num_desc, max);
+	num_desc = roundup_pow_of_two(num_desc);
+
+	if (val != num_desc) {
+		printk(KERN_INFO "%s: setting %s ring size %d instead of %d\n",
+		       netxen_nic_driver_name, r_name, num_desc, val);
+	}
+
+	return num_desc;
+}
+
+static void
+netxen_check_module_params(void)
+{
+	rdesc_1g = netxen_validate_ringparam(rdesc_1g,
+			MIN_RCV_DESCRIPTORS, MAX_RCV_DESCRIPTORS_1G,
+			"1GbE rx");
+	rdesc_10g = netxen_validate_ringparam(rdesc_10g,
+			MIN_RCV_DESCRIPTORS, MAX_RCV_DESCRIPTORS_10G,
+			"10GbE rx");
+	jumbo_desc_1g = netxen_validate_ringparam(jumbo_desc_1g,
+			MIN_JUMBO_DESCRIPTORS, MAX_JUMBO_RCV_DESCRIPTORS_1G,
+			"1GbE jumbo rx");
+	jumbo_desc_10g = netxen_validate_ringparam(jumbo_desc_10g,
+			MIN_JUMBO_DESCRIPTORS, MAX_JUMBO_RCV_DESCRIPTORS_10G,
+			"10GbE jumbo rx");
+	tx_desc = netxen_validate_ringparam(tx_desc,
+			MIN_CMD_DESCRIPTORS, MAX_CMD_DESCRIPTORS,
+			"10GbE jumbo rx");
+}
+
 
 static int __init netxen_init_module(void)
 {
 	printk(KERN_INFO "%s\n", netxen_nic_driver_string);
+	netxen_check_module_params();
 
 	if ((netxen_workq = create_singlethread_workqueue("netxen")) == NULL)
 		return -ENOMEM;
-- 
1.6.0.2

