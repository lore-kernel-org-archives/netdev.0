From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 4/7] e1000e: specify max supported frame size in
	adapter struct
Date: Tue, 02 Jun 2009 14:28:58 -0700
Message-ID: <20090602212858.24614.11135.stgit@localhost.localdomain>
References: <20090602212800.24614.45798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:36493
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbZFBV3P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:29:15 -0400
In-Reply-To: <20090602212800.24614.45798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

By putting the maximum frame size supported by the hardware into the
adapter structure, the change_mtu entry point function can be cleaned
up of checks for all the different max frame sizes supported by

different parts.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |   11 +++++++++--
 drivers/net/e1000e/e1000.h   |    4 ++++
 drivers/net/e1000e/es2lan.c  |    1 +
 drivers/net/e1000e/ich8lan.c |    8 ++++++++
 drivers/net/e1000e/netdev.c  |   27 +++++++++------------------
 5 files changed, 31 insertions(+), 20 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index 6c01a20..8203964 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -341,8 +341,10 @@ static s32 e1000_get_variants_82571(struct e1000_adapter *adapter)
 			if (e1000_read_nvm(&adapter->hw, NVM_INIT_3GIO_3, 1,
 				       &eeprom_data) < 0)
 				break;
-			if (eeprom_data & NVM_WORD1A_ASPM_MASK)
-				adapter->flags &= ~FLAG_HAS_JUMBO_FRAMES;
+			if (!(eeprom_data & NVM_WORD1A_ASPM_MASK)) {
+				adapter->flags |= FLAG_HAS_JUMBO_FRAMES;
+				adapter->max_hw_frame_size = DEFAULT_JUMBO;
+			}
 		}
 		break;
 	default:
@@ -1672,6 +1674,7 @@ struct e1000_info e1000_82571_info = {
 				  | FLAG_TARC_SPEED_MODE_BIT /* errata */
 				  | FLAG_APME_CHECK_PORT_B,
 	.pba			= 38,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_igp,
@@ -1688,6 +1691,7 @@ struct e1000_info e1000_82572_info = {
 				  | FLAG_HAS_CTRLEXT_ON_LOAD
 				  | FLAG_TARC_SPEED_MODE_BIT, /* errata */
 	.pba			= 38,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_igp,
@@ -1706,6 +1710,7 @@ struct e1000_info e1000_82573_info = {
 				  | FLAG_HAS_ERT
 				  | FLAG_HAS_SWSM_ON_LOAD,
 	.pba			= 20,
+	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_m88,
@@ -1724,6 +1729,7 @@ struct e1000_info e1000_82574_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.pba			= 20,
+	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_bm,
@@ -1740,6 +1746,7 @@ struct e1000_info e1000_82583_info = {
 				  | FLAG_HAS_AMT
 				  | FLAG_HAS_CTRLEXT_ON_LOAD,
 	.pba			= 20,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_82571,
 	.mac_ops		= &e82571_mac_ops,
 	.phy_ops		= &e82_phy_ops_bm,
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index f37360a..b9dc612 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -96,6 +96,8 @@ struct e1000_info;
 /* Number of packet split data buffers (not including the header buffer) */
 #define PS_PAGE_BUFFERS			(MAX_PS_BUFFERS - 1)
 
+#define DEFAULT_JUMBO			9234
+
 enum e1000_boards {
 	board_82571,
 	board_82572,
@@ -293,6 +295,7 @@ struct e1000_adapter {
 	u32 eeprom_wol;
 	u32 wol;
 	u32 pba;
+	u32 max_hw_frame_size;
 
 	bool fc_autoneg;
 
@@ -309,6 +312,7 @@ struct e1000_info {
 	unsigned int		flags;
 	unsigned int            flags2;
 	u32			pba;
+	u32			max_hw_frame_size;
 	s32			(*get_variants)(struct e1000_adapter *);
 	struct e1000_mac_operations *mac_ops;
 	struct e1000_phy_operations *phy_ops;
diff --git a/drivers/net/e1000e/es2lan.c b/drivers/net/e1000e/es2lan.c
index 8964838..6cc3bdf 100644
--- a/drivers/net/e1000e/es2lan.c
+++ b/drivers/net/e1000e/es2lan.c
@@ -1422,6 +1422,7 @@ struct e1000_info e1000_es2_info = {
 				  | FLAG_DISABLE_FC_PAUSE_TIME /* errata */
 				  | FLAG_TIPG_MEDIUM_FOR_80003ESLAN,
 	.pba			= 38,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_80003es2lan,
 	.mac_ops		= &es2_mac_ops,
 	.phy_ops		= &es2_phy_ops,
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 6d1aab6..b63d987 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -382,6 +382,11 @@ static s32 e1000_get_variants_ich8lan(struct e1000_adapter *adapter)
 	if (rc)
 		return rc;
 
+	if (adapter->hw.phy.type == e1000_phy_ife) {
+		adapter->flags &= ~FLAG_HAS_JUMBO_FRAMES;
+		adapter->max_hw_frame_size = ETH_FRAME_LEN + ETH_FCS_LEN;
+	}
+
 	if ((adapter->hw.mac.type == e1000_ich8lan) &&
 	    (adapter->hw.phy.type == e1000_phy_igp_3))
 		adapter->flags |= FLAG_LSC_GIG_SPEED_DROP;
@@ -2595,6 +2600,7 @@ struct e1000_info e1000_ich8_info = {
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 8,
+	.max_hw_frame_size	= ETH_FRAME_LEN + ETH_FCS_LEN,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
@@ -2613,6 +2619,7 @@ struct e1000_info e1000_ich9_info = {
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 10,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
@@ -2631,6 +2638,7 @@ struct e1000_info e1000_ich10_info = {
 				  | FLAG_HAS_FLASH
 				  | FLAG_APME_IN_WUC,
 	.pba			= 10,
+	.max_hw_frame_size	= DEFAULT_JUMBO,
 	.get_variants		= e1000_get_variants_ich8lan,
 	.mac_ops		= &ich8_mac_ops,
 	.phy_ops		= &ich8_phy_ops,
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index b7a46c5..4072fbb 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4212,27 +4212,17 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((new_mtu < ETH_ZLEN + ETH_FCS_LEN + VLAN_HLEN) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		e_err("Invalid MTU setting\n");
+	/* Jumbo frame support */
+	if ((max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) &&
+	    !(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
+		e_err("Jumbo Frames not supported.\n");
 		return -EINVAL;
 	}
 
-	/* Jumbo frame size limits */
-	if (max_frame > ETH_FRAME_LEN + ETH_FCS_LEN) {
-		if (!(adapter->flags & FLAG_HAS_JUMBO_FRAMES)) {
-			e_err("Jumbo Frames not supported.\n");
-			return -EINVAL;
-		}
-		if (adapter->hw.phy.type == e1000_phy_ife) {
-			e_err("Jumbo Frames not supported.\n");
-			return -EINVAL;
-		}
-	}
-
-#define MAX_STD_JUMBO_FRAME_SIZE 9234
-	if (max_frame > MAX_STD_JUMBO_FRAME_SIZE) {
-		e_err("MTU > 9216 not supported.\n");
+	/* Supported frame sizes */
+	if ((new_mtu < ETH_ZLEN + ETH_FCS_LEN + VLAN_HLEN) ||
+	    (max_frame > adapter->max_hw_frame_size)) {
+		e_err("Unsupported MTU setting\n");
 		return -EINVAL;
 	}
 
@@ -4848,6 +4838,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->flags2 = ei->flags2;
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
+	adapter->max_hw_frame_size = ei->max_hw_frame_size;
 	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
 
 	mmio_start = pci_resource_start(pdev, 0);

