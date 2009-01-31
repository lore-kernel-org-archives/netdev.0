From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] ixgbe: Refactor MSI-X allocation mechanism
Date: Fri, 30 Jan 2009 17:05:56 -0800
Message-ID: <20090131010556.1820.28773.stgit@lost.foo-projects.org>
References: <20090131010530.1820.5846.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:53548
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753051AbZAaBGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 20:06:17 -0500
In-Reply-To: <20090131010530.1820.5846.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Our current MSI-X allocation mechanism does not support new hardware
at all.  It also isn't getting the actual number of supported MSI-X vectors
from the device.

This patch allows the number of MSI-X vectors to be specific to a device,
plus it gets the number of MSI-X vectors available from PCIe configuration
space.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h       |    9 +++++++--
 drivers/net/ixgbe/ixgbe_82598.c |   22 ++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_main.c  |    9 ++++++++-
 drivers/net/ixgbe/ixgbe_type.h  |    5 +++++
 4 files changed, 42 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 6ac361a..341d8b5 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -204,9 +204,13 @@ struct ixgbe_q_vector {
 #define OTHER_VECTOR 1
 #define NON_Q_VECTORS (OTHER_VECTOR)
 
-#define MAX_MSIX_Q_VECTORS 16
+#define MAX_MSIX_VECTORS_82598 18
+#define MAX_MSIX_Q_VECTORS_82598 16
+
+#define MAX_MSIX_Q_VECTORS MAX_MSIX_Q_VECTORS_82598
+#define MAX_MSIX_COUNT MAX_MSIX_VECTORS_82598
+
 #define MIN_MSIX_Q_VECTORS 2
-#define MAX_MSIX_COUNT (MAX_MSIX_Q_VECTORS + NON_Q_VECTORS)
 #define MIN_MSIX_COUNT (MIN_MSIX_Q_VECTORS + NON_Q_VECTORS)
 
 /* board specific private data structure */
@@ -244,6 +248,7 @@ struct ixgbe_adapter {
 	u64 hw_csum_rx_good;
 	u64 non_eop_descs;
 	int num_msix_vectors;
+	int max_msix_q_vectors;         /* true count of q_vectors for device */
 	struct ixgbe_ring_feature ring_feature[3];
 	struct msix_entry *msix_entries;
 
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index dffe7f0..7fb4b86 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -50,6 +50,27 @@ static s32 ixgbe_read_i2c_eeprom_82598(struct ixgbe_hw *hw, u8 byte_offset,
                                        u8 *eeprom_data);
 
 /**
+ *  ixgbe_get_pcie_msix_count_82598 - Gets MSI-X vector count
+ *  @hw: pointer to hardware structure
+ *
+ *  Read PCIe configuration space, and get the MSI-X vector count from
+ *  the capabilities table.
+ **/
+u16 ixgbe_get_pcie_msix_count_82598(struct ixgbe_hw *hw)
+{
+	struct ixgbe_adapter *adapter = hw->back;
+	u16 msix_count;
+	pci_read_config_word(adapter->pdev, IXGBE_PCIE_MSIX_82598_CAPS,
+	                     &msix_count);
+	msix_count &= IXGBE_PCIE_MSIX_TBL_SZ_MASK;
+
+	/* MSI-X count is zero-based in HW, so increment to give proper value */
+	msix_count++;
+
+	return msix_count;
+}
+
+/**
  */
 static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 {
@@ -106,6 +127,7 @@ static s32 ixgbe_get_invariants_82598(struct ixgbe_hw *hw)
 	mac->num_rar_entries = IXGBE_82598_RAR_ENTRIES;
 	mac->max_rx_queues = IXGBE_82598_MAX_RX_QUEUES;
 	mac->max_tx_queues = IXGBE_82598_MAX_TX_QUEUES;
+	mac->max_msix_vectors = ixgbe_get_pcie_msix_count_82598(hw);
 
 out:
 	return ret_val;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f348176..7171399 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2421,7 +2421,13 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		ixgbe_set_num_queues(adapter);
 	} else {
 		adapter->flags |= IXGBE_FLAG_MSIX_ENABLED; /* Woot! */
-		adapter->num_msix_vectors = vectors;
+		/*
+		 * Adjust for only the vectors we'll use, which is minimum
+		 * of max_msix_q_vectors + NON_Q_VECTORS, or the number of
+		 * vectors we were allocated.
+		 */
+		adapter->num_msix_vectors = min(vectors,
+		                   adapter->max_msix_q_vectors + NON_Q_VECTORS);
 	}
 }
 
@@ -2746,6 +2752,7 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
 	adapter->ring_feature[RING_F_DCB].indices = IXGBE_MAX_DCB_INDICES;
+	adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
 
 #ifdef CONFIG_IXGBE_DCB
 	/* Configure DCB traffic classes */
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 883ff82..0d1d1d2 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -821,6 +821,10 @@
 #define IXGBE_FW_PTR            0x0F
 #define IXGBE_PBANUM0_PTR       0x15
 #define IXGBE_PBANUM1_PTR       0x16
+#define IXGBE_PCIE_MSIX_82598_CAPS  0x62
+
+/* MSI-X capability fields masks */
+#define IXGBE_PCIE_MSIX_TBL_SZ_MASK     0x7FF
 
 /* Legacy EEPROM word offsets */
 #define IXGBE_ISCSI_BOOT_CAPS           0x0033
@@ -1451,6 +1455,7 @@ struct ixgbe_mac_info {
 	u32                             num_rar_entries;
 	u32                             max_tx_queues;
 	u32                             max_rx_queues;
+	u32                             max_msix_vectors;
 	u32                             link_attach_type;
 	u32                             link_mode_select;
 	bool                            link_settings_loaded;

