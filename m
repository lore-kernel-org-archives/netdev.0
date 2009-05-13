From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 5/8] ixgbe: Implement FCoE Tx side offload
	features in base driver of 82599
Date: Wed, 13 May 2009 16:11:06 -0700
Message-ID: <20090513231105.11416.58577.stgit@localhost.localdomain>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090513230924.11416.68752.stgit@localhost.localdomain>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou@intel.com>

This patch implements the FCoE Tx side offload features in ixgbe_main.c
to 82599 using the Tx offload infrastructure code added in the previous
patch. This is achieved by the calling the FCoE Sequence Offload (FSO)
function ixgbe_fso() on the transmit path of ixgbe.

This patch also includes an EEPROM check to make sure the NIC we're loading
on is an offload-enabled SKU.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/Makefile      |    2 +
 drivers/net/ixgbe/ixgbe.h       |   13 +++++
 drivers/net/ixgbe/ixgbe_82599.c |    1 
 drivers/net/ixgbe/ixgbe_main.c  |  104 ++++++++++++++++++++++++++++++++-------
 drivers/net/ixgbe/ixgbe_type.h  |    1 
 5 files changed, 101 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index b3f8208..21b41f4 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -37,3 +37,5 @@ ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
+
+ixgbe-$(CONFIG_FCOE:m=y) += ixgbe_fcoe.o
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d743d0e..06859f6 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -36,6 +36,10 @@
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
 #include "ixgbe_dcb.h"
+#if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
+#define IXGBE_FCOE
+#include "ixgbe_fcoe.h"
+#endif /* CONFIG_FCOE or CONFIG_FCOE_MODULE */
 #ifdef CONFIG_IXGBE_DCA
 #include <linux/dca.h>
 #endif
@@ -84,6 +88,8 @@
 #define IXGBE_TX_FLAGS_VLAN		(u32)(1 << 1)
 #define IXGBE_TX_FLAGS_TSO		(u32)(1 << 2)
 #define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 3)
+#define IXGBE_TX_FLAGS_FCOE		(u32)(1 << 4)
+#define IXGBE_TX_FLAGS_FSO		(u32)(1 << 5)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK   0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
@@ -298,6 +304,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 25)
 #define IXGBE_FLAG_RSC_CAPABLE                  (u32)(1 << 26)
 #define IXGBE_FLAG_RSC_ENABLED                  (u32)(1 << 27)
+#define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 29)
 
 /* default to trying for four seconds */
 #define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
@@ -371,5 +378,11 @@ extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_clear_interrupt_scheme(struct ixgbe_adapter *adapter);
 extern void ixgbe_write_eitr(struct ixgbe_adapter *, int, u32);
+#ifdef IXGBE_FCOE
+extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
+extern int ixgbe_fso(struct ixgbe_adapter *adapter,
+                     struct ixgbe_ring *tx_ring, struct sk_buff *skb,
+                     u32 tx_flags, u8 *hdr_len);
+#endif /* IXGBE_FCOE */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 6038ed1..23be4db 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1294,7 +1294,6 @@ s32 ixgbe_get_device_caps_82599(struct ixgbe_hw *hw, u16 *device_caps)
 	return 0;
 }
 
-
 static struct ixgbe_mac_operations mac_ops_82599 = {
 	.init_hw                = &ixgbe_init_hw_generic,
 	.reset_hw               = &ixgbe_reset_hw_82599,
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index efb175b..ee80f6f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -39,6 +39,7 @@
 #include <net/ip6_checksum.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <scsi/fc/fc_fcoe.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -1810,6 +1811,11 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	/* Decide whether to use packet split mode or not */
 	adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
 
+#ifdef IXGBE_FCOE
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
+#endif /* IXGBE_FCOE */
+
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
 		rx_buf_len = IXGBE_RX_HDR_SIZE;
@@ -2241,6 +2247,11 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	netif_set_gso_max_size(netdev, 65536);
 #endif
 
+#ifdef IXGBE_FCOE
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+		ixgbe_configure_fcoe(adapter);
+
+#endif /* IXGBE_FCOE */
 	ixgbe_configure_tx(adapter);
 	ixgbe_configure_rx(adapter);
 	for (i = 0; i < adapter->num_rx_queues; i++)
@@ -3401,6 +3412,9 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
 		adapter->flags |= IXGBE_FLAG_RSC_CAPABLE;
 		adapter->flags |= IXGBE_FLAG_RSC_ENABLED;
+#ifdef IXGBE_FCOE
+		adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
+#endif /* IXGBE_FCOE */
 	}
 
 #ifdef CONFIG_IXGBE_DCB
@@ -4416,10 +4430,12 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 
 static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
                         struct ixgbe_ring *tx_ring,
-                        struct sk_buff *skb, unsigned int first)
+                        struct sk_buff *skb, u32 tx_flags,
+                        unsigned int first)
 {
 	struct ixgbe_tx_buffer *tx_buffer_info;
-	unsigned int len = skb_headlen(skb);
+	unsigned int len;
+	unsigned int total = skb->len;
 	unsigned int offset = 0, size, count = 0, i;
 	unsigned int nr_frags = skb_shinfo(skb)->nr_frags;
 	unsigned int f;
@@ -4434,6 +4450,11 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 
 	map = skb_shinfo(skb)->dma_maps;
 
+	if (tx_flags & IXGBE_TX_FLAGS_FCOE)
+		/* excluding fcoe_crc_eof for FCoE */
+		total -= sizeof(struct fcoe_crc_eof);
+
+	len = min(skb_headlen(skb), total);
 	while (len) {
 		tx_buffer_info = &tx_ring->tx_buffer_info[i];
 		size = min(len, (uint)IXGBE_MAX_DATA_PER_TXD);
@@ -4444,6 +4465,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 		tx_buffer_info->next_to_watch = i;
 
 		len -= size;
+		total -= size;
 		offset += size;
 		count++;
 
@@ -4458,7 +4480,7 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 		struct skb_frag_struct *frag;
 
 		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
+		len = min((unsigned int)frag->size, total);
 		offset = 0;
 
 		while (len) {
@@ -4475,9 +4497,12 @@ static int ixgbe_tx_map(struct ixgbe_adapter *adapter,
 			tx_buffer_info->next_to_watch = i;
 
 			len -= size;
+			total -= size;
 			offset += size;
 			count++;
 		}
+		if (total == 0)
+			break;
 	}
 
 	tx_ring->tx_buffer_info[i].skb = skb;
@@ -4519,6 +4544,13 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
 		                 IXGBE_ADVTXD_POPTS_SHIFT;
 
+	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
+		olinfo_status |= IXGBE_ADVTXD_CC;
+		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
+		if (tx_flags & IXGBE_TX_FLAGS_FSO)
+			cmd_type_len |= IXGBE_ADVTXD_DCMD_TSE;
+	}
+
 	olinfo_status |= ((paylen - hdr_len) << IXGBE_ADVTXD_PAYLEN_SHIFT);
 
 	i = tx_ring->next_to_use;
@@ -4615,10 +4647,16 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 	}
-	/* three things can cause us to need a context descriptor */
+
+	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	    (skb->protocol == htons(ETH_P_FCOE)))
+		tx_flags |= IXGBE_TX_FLAGS_FCOE;
+
+	/* four things can cause us to need a context descriptor */
 	if (skb_is_gso(skb) ||
 	    (skb->ip_summed == CHECKSUM_PARTIAL) ||
-	    (tx_flags & IXGBE_TX_FLAGS_VLAN))
+	    (tx_flags & IXGBE_TX_FLAGS_VLAN) ||
+	    (tx_flags & IXGBE_TX_FLAGS_FCOE))
 		count++;
 
 	count += TXD_USE_COUNT(skb_headlen(skb));
@@ -4630,23 +4668,35 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 
-	if (skb->protocol == htons(ETH_P_IP))
-		tx_flags |= IXGBE_TX_FLAGS_IPV4;
 	first = tx_ring->next_to_use;
-	tso = ixgbe_tso(adapter, tx_ring, skb, tx_flags, &hdr_len);
-	if (tso < 0) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
-	if (tso)
-		tx_flags |= IXGBE_TX_FLAGS_TSO;
-	else if (ixgbe_tx_csum(adapter, tx_ring, skb, tx_flags) &&
-	         (skb->ip_summed == CHECKSUM_PARTIAL))
-		tx_flags |= IXGBE_TX_FLAGS_CSUM;
+	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
+#ifdef IXGBE_FCOE
+		/* setup tx offload for FCoE */
+		tso = ixgbe_fso(adapter, tx_ring, skb, tx_flags, &hdr_len);
+		if (tso < 0) {
+			dev_kfree_skb_any(skb);
+			return NETDEV_TX_OK;
+		}
+		if (tso)
+			tx_flags |= IXGBE_TX_FLAGS_FSO;
+#endif /* IXGBE_FCOE */
+	} else {
+		if (skb->protocol == htons(ETH_P_IP))
+			tx_flags |= IXGBE_TX_FLAGS_IPV4;
+		tso = ixgbe_tso(adapter, tx_ring, skb, tx_flags, &hdr_len);
+		if (tso < 0) {
+			dev_kfree_skb_any(skb);
+			return NETDEV_TX_OK;
+		}
 
-	count = ixgbe_tx_map(adapter, tx_ring, skb, first);
+		if (tso)
+			tx_flags |= IXGBE_TX_FLAGS_TSO;
+		else if (ixgbe_tx_csum(adapter, tx_ring, skb, tx_flags) &&
+			 (skb->ip_summed == CHECKSUM_PARTIAL))
+			tx_flags |= IXGBE_TX_FLAGS_CSUM;
+	}
 
+	count = ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first);
 	if (count) {
 		ixgbe_tx_queue(adapter, tx_ring, tx_flags, count, skb->len,
 		               hdr_len);
@@ -4794,6 +4844,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	const struct ixgbe_info *ii = ixgbe_info_tbl[ent->driver_data];
 	static int cards_found;
 	int i, err, pci_using_dac;
+#ifdef IXGBE_FCOE
+	u16 device_caps;
+#endif
 	u32 part_num, eec;
 
 	err = pci_enable_device_mem(pdev);
@@ -4976,6 +5029,19 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->dcbnl_ops = &dcbnl_ops;
 #endif
 
+#ifdef IXGBE_FCOE
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+		if (hw->mac.ops.get_device_caps) {
+			hw->mac.ops.get_device_caps(hw, &device_caps);
+			if (!(device_caps & IXGBE_DEVICE_CAPS_FCOE_OFFLOADS)) {
+				netdev->features |= NETIF_F_FCOE_CRC;
+				netdev->features |= NETIF_F_FSO;
+			} else {
+				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
+			}
+		}
+	}
+#endif /* IXGBE_FCOE */
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c2d9ed5..b3de723 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -1483,6 +1483,7 @@
 #endif
 
 #define IXGBE_DEVICE_CAPS_ALLOW_ANY_SFP  0x1
+#define IXGBE_DEVICE_CAPS_FCOE_OFFLOADS  0x2
 
 /* PCI Bus Info */
 #define IXGBE_PCI_LINK_STATUS     0xB2

