From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 5/6] amd-xgbe: Change destination address filtering
 support
Date: Tue, 24 Jun 2014 16:19:29 -0500
Message-ID: <20140624211929.20681.24673.stgit@tlendack-t1.amdoffice.net>
References: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [207.46.163.236] ([207.46.163.236]:53463 "EHLO
	na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751365AbaFXVTo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jun 2014 17:19:44 -0400
In-Reply-To: <20140624211900.20681.46554.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the driver makes use of the additional mac address
registers in the hardware to provide perfect filtering.  The
hardware can also have a set of hash table registers that can
be used for imperfect filtering.  By using imperfect filtering
the additional mac address registers can be used for layer 2
filtering support.  Use the hash table registers if the device
has them.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/Kconfig            |    1 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h |   10 +-
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c    |  141 +++++++++++++++++----------
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c    |   27 +++--
 drivers/net/ethernet/amd/xgbe/xgbe-main.c   |    2 
 drivers/net/ethernet/amd/xgbe/xgbe.h        |    4 +
 6 files changed, 116 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 8e83e4c..6e314db 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -183,6 +183,7 @@ config AMD_XGBE
 	select PHYLIB
 	select AMD_XGBE_PHY
 	select BITREVERSE
+	select CRC32
 	---help---
 	  This driver supports the AMD 10GbE Ethernet device found on an
 	  AMD SoC.
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 1de9d0f..ccbceba 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -276,13 +276,6 @@
 #define MAC_PFR				0x0008
 #define MAC_WTR				0x000c
 #define MAC_HTR0			0x0010
-#define MAC_HTR1			0x0014
-#define MAC_HTR2			0x0018
-#define MAC_HTR3			0x001c
-#define MAC_HTR4			0x0020
-#define MAC_HTR5			0x0024
-#define MAC_HTR6			0x0028
-#define MAC_HTR7			0x002c
 #define MAC_VLANTR			0x0050
 #define MAC_VLANHTR			0x0058
 #define MAC_VLANIR			0x0060
@@ -315,6 +308,7 @@
 
 #define MAC_QTFCR_INC			4
 #define MAC_MACA_INC			4
+#define MAC_HTR_INC			4
 
 /* MAC register entry bit positions and sizes */
 #define MAC_HWF0R_ADDMACADRSEL_INDEX	18
@@ -387,6 +381,8 @@
 #define MAC_MACA1HR_AE_WIDTH		1
 #define MAC_PFR_HMC_INDEX		2
 #define MAC_PFR_HMC_WIDTH		1
+#define MAC_PFR_HPF_INDEX		10
+#define MAC_PFR_HPF_WIDTH		1
 #define MAC_PFR_HUC_INDEX		1
 #define MAC_PFR_HUC_WIDTH		1
 #define MAC_PFR_PM_INDEX		4
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 2c7d582..a56069c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -117,6 +117,7 @@
 #include <linux/phy.h>
 #include <linux/clk.h>
 #include <linux/bitrev.h>
+#include <linux/crc32.h>
 
 #include "xgbe.h"
 #include "xgbe-common.h"
@@ -548,24 +549,16 @@ static int xgbe_set_all_multicast_mode(struct xgbe_prv_data *pdata,
 	return 0;
 }
 
-static int xgbe_set_addn_mac_addrs(struct xgbe_prv_data *pdata,
-				   unsigned int am_mode)
+static void xgbe_set_mac_reg(struct xgbe_prv_data *pdata,
+			     struct netdev_hw_addr *ha, unsigned int *mac_reg)
 {
-	struct netdev_hw_addr *ha;
-	unsigned int mac_reg;
 	unsigned int mac_addr_hi, mac_addr_lo;
 	u8 *mac_addr;
-	unsigned int i;
 
-	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, HUC, 0);
-	XGMAC_IOWRITE_BITS(pdata, MAC_PFR, HMC, 0);
-
-	i = 0;
-	mac_reg = MAC_MACA1HR;
+	mac_addr_lo = 0;
+	mac_addr_hi = 0;
 
-	netdev_for_each_uc_addr(ha, pdata->netdev) {
-		mac_addr_lo = 0;
-		mac_addr_hi = 0;
+	if (ha) {
 		mac_addr = (u8 *)&mac_addr_lo;
 		mac_addr[0] = ha->addr[0];
 		mac_addr[1] = ha->addr[1];
@@ -575,54 +568,93 @@ static int xgbe_set_addn_mac_addrs(struct xgbe_prv_data *pdata,
 		mac_addr[0] = ha->addr[4];
 		mac_addr[1] = ha->addr[5];
 
-		DBGPR("  adding unicast address %pM at 0x%04x\n",
-		      ha->addr, mac_reg);
+		DBGPR("  adding mac address %pM at 0x%04x\n", ha->addr,
+		      *mac_reg);
 
 		XGMAC_SET_BITS(mac_addr_hi, MAC_MACA1HR, AE, 1);
+	}
 
-		XGMAC_IOWRITE(pdata, mac_reg, mac_addr_hi);
-		mac_reg += MAC_MACA_INC;
-		XGMAC_IOWRITE(pdata, mac_reg, mac_addr_lo);
-		mac_reg += MAC_MACA_INC;
+	XGMAC_IOWRITE(pdata, *mac_reg, mac_addr_hi);
+	*mac_reg += MAC_MACA_INC;
+	XGMAC_IOWRITE(pdata, *mac_reg, mac_addr_lo);
+	*mac_reg += MAC_MACA_INC;
+}
 
-		i++;
-	}
+static void xgbe_set_mac_addn_addrs(struct xgbe_prv_data *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_hw_addr *ha;
+	unsigned int mac_reg;
+	unsigned int addn_macs;
+
+	mac_reg = MAC_MACA1HR;
+	addn_macs = pdata->hw_feat.addn_mac;
 
-	if (!am_mode) {
-		netdev_for_each_mc_addr(ha, pdata->netdev) {
-			mac_addr_lo = 0;
-			mac_addr_hi = 0;
-			mac_addr = (u8 *)&mac_addr_lo;
-			mac_addr[0] = ha->addr[0];
-			mac_addr[1] = ha->addr[1];
-			mac_addr[2] = ha->addr[2];
-			mac_addr[3] = ha->addr[3];
-			mac_addr = (u8 *)&mac_addr_hi;
-			mac_addr[0] = ha->addr[4];
-			mac_addr[1] = ha->addr[5];
-
-			DBGPR("  adding multicast address %pM at 0x%04x\n",
-			      ha->addr, mac_reg);
-
-			XGMAC_SET_BITS(mac_addr_hi, MAC_MACA1HR, AE, 1);
-
-			XGMAC_IOWRITE(pdata, mac_reg, mac_addr_hi);
-			mac_reg += MAC_MACA_INC;
-			XGMAC_IOWRITE(pdata, mac_reg, mac_addr_lo);
-			mac_reg += MAC_MACA_INC;
-
-			i++;
+	if (netdev_uc_count(netdev) > addn_macs) {
+		xgbe_set_promiscuous_mode(pdata, 1);
+	} else {
+		netdev_for_each_uc_addr(ha, netdev) {
+			xgbe_set_mac_reg(pdata, ha, &mac_reg);
+			addn_macs--;
+		}
+
+		if (netdev_mc_count(netdev) > addn_macs) {
+			xgbe_set_all_multicast_mode(pdata, 1);
+		} else {
+			netdev_for_each_mc_addr(ha, netdev) {
+				xgbe_set_mac_reg(pdata, ha, &mac_reg);
+				addn_macs--;
+			}
 		}
 	}
 
 	/* Clear remaining additional MAC address entries */
-	for (; i < pdata->hw_feat.addn_mac; i++) {
-		XGMAC_IOWRITE(pdata, mac_reg, 0);
-		mac_reg += MAC_MACA_INC;
-		XGMAC_IOWRITE(pdata, mac_reg, 0);
-		mac_reg += MAC_MACA_INC;
+	while (addn_macs--)
+		xgbe_set_mac_reg(pdata, NULL, &mac_reg);
+}
+
+static void xgbe_set_mac_hash_table(struct xgbe_prv_data *pdata)
+{
+	struct net_device *netdev = pdata->netdev;
+	struct netdev_hw_addr *ha;
+	unsigned int hash_reg;
+	unsigned int hash_table_shift, hash_table_count;
+	u32 hash_table[XGBE_MAC_HASH_TABLE_SIZE];
+	u32 crc;
+	unsigned int i;
+
+	hash_table_shift = 26 - (pdata->hw_feat.hash_table_size >> 7);
+	hash_table_count = pdata->hw_feat.hash_table_size / 32;
+	memset(hash_table, 0, sizeof(hash_table));
+
+	/* Build the MAC Hash Table register values */
+	netdev_for_each_uc_addr(ha, netdev) {
+		crc = bitrev32(~crc32_le(~0, ha->addr, ETH_ALEN));
+		crc >>= hash_table_shift;
+		hash_table[crc >> 5] |= (1 << (crc & 0x1f));
+	}
+
+	netdev_for_each_mc_addr(ha, netdev) {
+		crc = bitrev32(~crc32_le(~0, ha->addr, ETH_ALEN));
+		crc >>= hash_table_shift;
+		hash_table[crc >> 5] |= (1 << (crc & 0x1f));
 	}
 
+	/* Set the MAC Hash Table registers */
+	hash_reg = MAC_HTR0;
+	for (i = 0; i < hash_table_count; i++) {
+		XGMAC_IOWRITE(pdata, hash_reg, hash_table[i]);
+		hash_reg += MAC_HTR_INC;
+	}
+}
+
+static int xgbe_add_mac_addresses(struct xgbe_prv_data *pdata)
+{
+	if (pdata->hw_feat.hash_table_size)
+		xgbe_set_mac_hash_table(pdata);
+	else
+		xgbe_set_mac_addn_addrs(pdata);
+
 	return 0;
 }
 
@@ -1606,6 +1638,13 @@ static void xgbe_config_flow_control_threshold(struct xgbe_prv_data *pdata)
 static void xgbe_config_mac_address(struct xgbe_prv_data *pdata)
 {
 	xgbe_set_mac_address(pdata, pdata->netdev->dev_addr);
+
+	/* Filtering is done using perfect filtering and hash filtering */
+	if (pdata->hw_feat.hash_table_size) {
+		XGMAC_IOWRITE_BITS(pdata, MAC_PFR, HPF, 1);
+		XGMAC_IOWRITE_BITS(pdata, MAC_PFR, HUC, 1);
+		XGMAC_IOWRITE_BITS(pdata, MAC_PFR, HMC, 1);
+	}
 }
 
 static void xgbe_config_jumbo_enable(struct xgbe_prv_data *pdata)
@@ -2202,7 +2241,7 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 
 	hw_if->set_promiscuous_mode = xgbe_set_promiscuous_mode;
 	hw_if->set_all_multicast_mode = xgbe_set_all_multicast_mode;
-	hw_if->set_addn_mac_addrs = xgbe_set_addn_mac_addrs;
+	hw_if->add_mac_addresses = xgbe_add_mac_addresses;
 	hw_if->set_mac_address = xgbe_set_mac_address;
 
 	hw_if->enable_rx_csum = xgbe_enable_rx_csum;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2acc37c..72dd611 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -378,6 +378,21 @@ void xgbe_get_all_hw_features(struct xgbe_prv_data *pdata)
 	hw_feat->pps_out_num  = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, PPSOUTNUM);
 	hw_feat->aux_snap_num = XGMAC_GET_BITS(mac_hfr2, MAC_HWF2R, AUXSNAPNUM);
 
+	/* Translate the Hash Table size into actual number */
+	switch (hw_feat->hash_table_size) {
+	case 0:
+		break;
+	case 1:
+		hw_feat->hash_table_size = 64;
+		break;
+	case 2:
+		hw_feat->hash_table_size = 128;
+		break;
+	case 3:
+		hw_feat->hash_table_size = 256;
+		break;
+	}
+
 	/* The Queue and Channel counts are zero based so increment them
 	 * to get the actual number
 	 */
@@ -912,18 +927,10 @@ static void xgbe_set_rx_mode(struct net_device *netdev)
 	pr_mode = ((netdev->flags & IFF_PROMISC) != 0);
 	am_mode = ((netdev->flags & IFF_ALLMULTI) != 0);
 
-	if (netdev_uc_count(netdev) > pdata->hw_feat.addn_mac)
-		pr_mode = 1;
-	if (netdev_mc_count(netdev) > pdata->hw_feat.addn_mac)
-		am_mode = 1;
-	if ((netdev_uc_count(netdev) + netdev_mc_count(netdev)) >
-	     pdata->hw_feat.addn_mac)
-		pr_mode = 1;
-
 	hw_if->set_promiscuous_mode(pdata, pr_mode);
 	hw_if->set_all_multicast_mode(pdata, am_mode);
-	if (!pr_mode)
-		hw_if->set_addn_mac_addrs(pdata, am_mode);
+
+	hw_if->add_mac_addresses(pdata);
 
 	DBGPR("<--xgbe_set_rx_mode\n");
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index c3a48b7..b411ac5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -397,6 +397,8 @@ static int xgbe_probe(struct platform_device *pdev)
 	netdev->features |= netdev->hw_features;
 	pdata->netdev_features = netdev->features;
 
+	netdev->priv_flags |= IFF_UNICAST_FLT;
+
 	xgbe_init_rx_coalesce(pdata);
 	xgbe_init_tx_coalesce(pdata);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 3cb911f..a2d5f5f 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -191,6 +191,8 @@
 /* Flow control queue count */
 #define XGMAC_MAX_FLOW_CONTROL_QUEUES	8
 
+/* Maximum MAC address hash table size (256 bits = 8 bytes) */
+#define XGBE_MAC_HASH_TABLE_SIZE	8
 
 struct xgbe_prv_data;
 
@@ -387,7 +389,7 @@ struct xgbe_hw_if {
 
 	int (*set_promiscuous_mode)(struct xgbe_prv_data *, unsigned int);
 	int (*set_all_multicast_mode)(struct xgbe_prv_data *, unsigned int);
-	int (*set_addn_mac_addrs)(struct xgbe_prv_data *, unsigned int);
+	int (*add_mac_addresses)(struct xgbe_prv_data *);
 	int (*set_mac_address)(struct xgbe_prv_data *, u8 *addr);
 
 	int (*enable_rx_csum)(struct xgbe_prv_data *);
