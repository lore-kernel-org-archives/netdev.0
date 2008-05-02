From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 3/3] ixgbe: Enable Data Center Bridging (DCB) support
Date: Thu, 01 May 2008 17:43:10 -0700
Message-ID: <20080502004310.14392.49606.stgit@localhost.localdomain>
References: <20080502004254.14392.7599.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50577 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439AbYEBHlz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 May 2008 03:41:55 -0400
In-Reply-To: <20080502004254.14392.7599.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables DCB support for 82598.  DCB is a technology implementing
the 802.1Qaz and 802.1Qbb IEEE standards for priority grouping and priority
pause.  The technology uses the 802.1p VLAN priority tags to identify
traffic on the network, and establish prioritization of the traffic
throughout the environment.  The 802.1Qbb priority flow control allows
MAC-level flow control on each of these priorities, creating 8 virtual
links in the network, allowing certain types of traffic to be paused while
not affecting other traffic types.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/Makefile          |    3 
 drivers/net/ixgbe/ixgbe.h           |   28 +++-
 drivers/net/ixgbe/ixgbe_dcb_82598.c |    1 
 drivers/net/ixgbe/ixgbe_ethtool.c   |   36 +++++
 drivers/net/ixgbe/ixgbe_main.c      |  267 ++++++++++++++++++++++++++++-------
 5 files changed, 275 insertions(+), 60 deletions(-)

diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index ccd83d9..2a45fa0 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -33,4 +33,5 @@
 obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
-              ixgbe_82598.o ixgbe_phy.o
+              ixgbe_82598.o ixgbe_phy.o ixgbe_dcb.o ixgbe_dcb_82598.o \
+              ixgbe_dcb_nl.o
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d981134..5098b9d 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -35,6 +35,7 @@
 
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
+#include "ixgbe_dcb.h"
 
 #ifdef CONFIG_DCA
 #include <linux/dca.h>
@@ -98,6 +99,7 @@
 #define IXGBE_TX_FLAGS_TSO		(u32)(1 << 2)
 #define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 3)
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
+#define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0x0000e000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
 /* wrapper around a pointer to a socket buffer,
@@ -144,7 +146,7 @@ struct ixgbe_ring {
 
 	u16 reg_idx; /* holds the special value that gets the hardware register
 		      * offset associated with this ring, which is different
-		      * for DCE and RSS modes */
+		      * for DCB and RSS modes */
 
 #ifdef CONFIG_DCA
 	/* cpu for tx queue */
@@ -162,8 +164,10 @@ struct ixgbe_ring {
 	u16 work_limit;                /* max work per interrupt */
 };
 
+#define RING_F_DCB  0
 #define RING_F_VMDQ 1
 #define RING_F_RSS  2
+#define IXGBE_MAX_DCB_INDICES   8
 #define IXGBE_MAX_RSS_INDICES  16
 #define IXGBE_MAX_VMDQ_INDICES 16
 struct ixgbe_ring_feature {
@@ -174,6 +178,10 @@ struct ixgbe_ring_feature {
 #define MAX_RX_QUEUES 64
 #define MAX_TX_QUEUES 32
 
+#define MAX_RX_PACKET_BUFFERS ((adapter->flags & IXGBE_FLAG_DCB_ENABLED) \
+                               ? 8 : 1)
+#define MAX_TX_PACKET_BUFFERS MAX_RX_PACKET_BUFFERS
+
 /* MAX_MSIX_Q_VECTORS of these are allocated,
  * but we only use one per queue-specific vector.
  */
@@ -226,6 +234,9 @@ struct ixgbe_adapter {
 	struct work_struct reset_task;
 	struct ixgbe_q_vector q_vector[MAX_MSIX_Q_VECTORS];
 	char name[MAX_MSIX_COUNT][IFNAMSIZ + 5];
+	struct ixgbe_dcb_config dcb_cfg;
+	struct ixgbe_dcb_config temp_dcb_cfg;
+	u8 dcb_set_bitmap;
 
 	/* Interrupt Throttle Rate */
 	u32 itr_setting;
@@ -234,6 +245,7 @@ struct ixgbe_adapter {
 
 	/* TX */
 	struct ixgbe_ring *tx_ring;	/* One per active queue */
+	int num_tx_queues;
 	u64 restart_queue;
 	u64 lsc_int;
 	u64 hw_tso_ctxt;
@@ -243,12 +255,11 @@ struct ixgbe_adapter {
 
 	/* RX */
 	struct ixgbe_ring *rx_ring;	/* One per active queue */
+	int num_rx_queues;
 	u64 hw_csum_tx_good;
 	u64 hw_csum_rx_error;
 	u64 hw_csum_rx_good;
 	u64 non_eop_descs;
-	int num_tx_queues;
-	int num_rx_queues;
 	int num_msix_vectors;
 	struct ixgbe_ring_feature ring_feature[3];
 	struct msix_entry *msix_entries;
@@ -270,6 +281,7 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_RSS_ENABLED                  (u32)(1 << 6)
 #define IXGBE_FLAG_VMDQ_ENABLED                 (u32)(1 << 7)
 #define IXGBE_FLAG_DCA_ENABLED                  (u32)(1 << 8)
+#define IXGBE_FLAG_DCB_ENABLED                  (u32)(1 << 9)
 
 	/* OS defined structs */
 	struct net_device *netdev;
@@ -314,5 +326,15 @@ extern int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 				    struct ixgbe_ring *rxdr);
 extern int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 				    struct ixgbe_ring *txdr);
+/* needed by ixgbe_dcb_nl.c */
+extern void ixgbe_configure_dcb(struct ixgbe_adapter *adapter);
+extern int ixgbe_close(struct net_device *netdev);
+extern void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter);
+extern int ixgbe_open(struct net_device *netdev);
+extern int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter);
+extern bool ixgbe_is_ixgbe(struct pci_dev *pcidev);
+
+extern int ixgbe_dcb_netlink_register(void);
+extern int ixgbe_dcb_netlink_unregister(void);
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_82598.c b/drivers/net/ixgbe/ixgbe_dcb_82598.c
index 39b63ee..3c7f187 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_82598.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_82598.c
@@ -27,6 +27,7 @@
 *******************************************************************************/
 
 
+#include "ixgbe.h"
 #include "ixgbe_type.h"
 #include "ixgbe_dcb.h"
 #include "ixgbe_dcb_82598.h"
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 4e46377..944f669 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -97,7 +97,17 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 		 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
 		 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
 #define IXGBE_GLOBAL_STATS_LEN	ARRAY_SIZE(ixgbe_gstrings_stats)
-#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
+#define IXGBE_PB_STATS_LEN ( \
+		(((struct ixgbe_adapter *)netdev->priv)->flags & \
+		 IXGBE_FLAG_DCB_ENABLED) ? \
+		 (sizeof(((struct ixgbe_adapter *)0)->stats.pxonrxc) + \
+		  sizeof(((struct ixgbe_adapter *)0)->stats.pxontxc) + \
+		  sizeof(((struct ixgbe_adapter *)0)->stats.pxoffrxc) + \
+		  sizeof(((struct ixgbe_adapter *)0)->stats.pxofftxc)) \
+		 / sizeof(u64) : 0)
+#define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + \
+		IXGBE_PB_STATS_LEN + \
+		IXGBE_QUEUE_STATS_LEN)
 
 static int ixgbe_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
@@ -806,6 +816,16 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 			data[i + k] = queue_stat[k];
 		i += k;
 	}
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		for (j = 0; j < MAX_TX_PACKET_BUFFERS; j++) {
+			data[i++] = adapter->stats.pxontxc[j];
+			data[i++] = adapter->stats.pxofftxc[j];
+		}
+		for (j = 0; j < MAX_RX_PACKET_BUFFERS; j++) {
+			data[i++] = adapter->stats.pxonrxc[j];
+			data[i++] = adapter->stats.pxoffrxc[j];
+		}
+	}
 }
 
 static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
@@ -834,6 +854,20 @@ static void ixgbe_get_strings(struct net_device *netdev, u32 stringset,
 			sprintf(p, "rx_queue_%u_bytes", i);
 			p += ETH_GSTRING_LEN;
 		}
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			for (i = 0; i < MAX_TX_PACKET_BUFFERS; i++) {
+				sprintf(p, "tx_pb_%u_pxon", i);
+				p += ETH_GSTRING_LEN;
+				sprintf(p, "tx_pb_%u_pxoff", i);
+				p += ETH_GSTRING_LEN;
+			}
+			for (i = 0; i < MAX_RX_PACKET_BUFFERS; i++) {
+				sprintf(p, "rx_pb_%u_pxon", i);
+				p += ETH_GSTRING_LEN;
+				sprintf(p, "rx_pb_%u_pxoff", i);
+				p += ETH_GSTRING_LEN;
+			}
+		}
 /*		BUG_ON(p - data != IXGBE_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 7b85922..82312d7 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   Intel 10 Gigabit PCI Express Linux driver
-  Copyright(c) 1999 - 2007 Intel Corporation.
+  Copyright(c) 1999 - 2008 Intel Corporation.
 
   This program is free software; you can redistribute it and/or modify it
   under the terms and conditions of the GNU General Public License,
@@ -48,7 +48,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "1.3.18-k2"
+#define DRV_VERSION "1.3.26-k2"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 	 "Copyright (c) 1999-2007 Intel Corporation.";
@@ -397,13 +397,13 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 			      u16 tag)
 {
 	if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
-		if (adapter->vlgrp && is_vlan)
+		if (adapter->vlgrp && is_vlan && (tag != 0))
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
 		else
 			netif_receive_skb(skb);
 	} else {
 
-		if (adapter->vlgrp && is_vlan)
+		if (adapter->vlgrp && is_vlan && (tag != 0))
 			vlan_hwaccel_rx(skb, adapter->vlgrp, tag);
 		else
 			netif_rx(skb);
@@ -545,14 +545,13 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
 	unsigned int i;
-	u32 upper_len, len, staterr;
+	u32 len, staterr;
 	u16 hdr_info, vlan_tag;
 	bool is_vlan, cleaned = false;
 	int cleaned_count = 0;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
-	upper_len = 0;
 	rx_desc = IXGBE_RX_DESC_ADV(*rx_ring, i);
 	staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	rx_buffer_info = &rx_ring->rx_buffer_info[i];
@@ -560,6 +559,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 	vlan_tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
 	while (staterr & IXGBE_RXD_STAT_DD) {
+		u32 upper_len = 0;
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
@@ -1343,7 +1343,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_configure_tx - Configure 8254x Transmit Unit after Reset
+ * ixgbe_configure_tx - Configure 8259x Transmit Unit after Reset
  * @adapter: board private structure
  *
  * Configure the Tx unit of the MAC after a reset.
@@ -1371,9 +1371,9 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		/* Disable Tx Head Writeback RO bit, since this hoses
 		 * bookkeeping if things aren't delivered in order.
 		 */
-		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(i));
+		txctrl = IXGBE_READ_REG(hw, IXGBE_DCA_TXCTRL(j));
 		txctrl &= ~IXGBE_DCA_TXCTRL_TX_WB_RO_EN;
-		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(i), txctrl);
+		IXGBE_WRITE_REG(hw, IXGBE_DCA_TXCTRL(j), txctrl);
 	}
 }
 
@@ -1382,7 +1382,7 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 
 #define IXGBE_SRRCTL_BSIZEHDRSIZE_SHIFT			2
 /**
- * ixgbe_configure_rx - Configure 8254x Receive Unit after Reset
+ * ixgbe_configure_rx - Configure 8259x Receive Unit after Reset
  * @adapter: board private structure
  *
  * Configure the Rx unit of the MAC after a reset.
@@ -1529,6 +1529,16 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 		ixgbe_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
+	/*
+	 * For a DCB driver, always enable VLAN tag stripping so we can
+	 * still receive traffic from a DCB-enabled host even if we're
+	 * not in DCB mode.
+	 */
+	ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
+	ctrl |= IXGBE_VLNCTRL_VME;
+	ctrl &= ~IXGBE_VLNCTRL_CFIEN;
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
+
 	if (grp) {
 		/* enable VLAN tag insert/strip */
 		ctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_VLNCTRL);
@@ -1672,6 +1682,42 @@ static void ixgbe_napi_disable_all(struct ixgbe_adapter *adapter)
 	}
 }
 
+/*
+ * ixgbe_configure_dcb - Configure DCB hardware
+ * @adapter: ixgbe adapter struct
+ *
+ * This is called by the driver on open to configure the DCB hardware.
+ * This is also called by the gennetlink interface when reconfiguring
+ * the DCB state.
+ */
+void ixgbe_configure_dcb(struct ixgbe_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 txdctl, vlnctrl;
+	int i, j;
+
+	ixgbe_dcb_check_config(&adapter->dcb_cfg);
+	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_TX_CONFIG);
+	ixgbe_dcb_calculate_tc_credits(&adapter->dcb_cfg, DCB_RX_CONFIG);
+
+	/* reconfigure the hardware */
+	ixgbe_dcb_hw_config(&adapter->hw, &adapter->dcb_cfg);
+
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		j = adapter->tx_ring[i].reg_idx;
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
+		/* PThresh workaround for Tx hang with DFP enabled. */
+		txdctl |= 32;
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
+	}
+	/* Enable VLAN tag insert/strip */
+	vlnctrl = IXGBE_READ_REG(hw, IXGBE_VLNCTRL);
+	vlnctrl |= IXGBE_VLNCTRL_VME | IXGBE_VLNCTRL_VFE;
+	vlnctrl &= ~IXGBE_VLNCTRL_CFIEN;
+	IXGBE_WRITE_REG(hw, IXGBE_VLNCTRL, vlnctrl);
+	ixgbe_set_vfta(hw, 0, 0, true);
+}
+
 static void ixgbe_configure(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
@@ -1680,6 +1726,12 @@ static void ixgbe_configure(struct ixgbe_adapter *adapter)
 	ixgbe_set_multi(netdev);
 
 	ixgbe_restore_vlan(adapter);
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		netif_set_gso_max_size(netdev, 32768);
+		ixgbe_configure_dcb(adapter);
+	} else {
+		netif_set_gso_max_size(netdev, 65536);
+	}
 
 	ixgbe_configure_tx(adapter);
 	ixgbe_configure_rx(adapter);
@@ -1699,6 +1751,11 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	ixgbe_get_hw_control(adapter);
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (adapter->num_tx_queues > 1)
+		netdev->features |= NETIF_F_MULTI_QUEUE;
+#endif
+
 	if ((adapter->flags & IXGBE_FLAG_MSIX_ENABLED) ||
 	    (adapter->flags & IXGBE_FLAG_MSI_ENABLED)) {
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
@@ -1943,36 +2000,44 @@ static void ixgbe_clean_all_tx_rings(struct ixgbe_adapter *adapter)
 void ixgbe_down(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct ixgbe_hw *hw = &adapter->hw;
 	u32 rxctrl;
+	u32 txdctl;
+	int i, j;
 
 	/* signal that we are down to the interrupt handler */
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	/* disable receives */
-	rxctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_RXCTRL);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_RXCTRL,
-			rxctrl & ~IXGBE_RXCTRL_RXEN);
-
-	netif_tx_disable(netdev);
-
-	/* disable transmits in the hardware */
+	rxctrl = IXGBE_READ_REG(hw, IXGBE_RXCTRL);
+	IXGBE_WRITE_REG(hw, IXGBE_RXCTRL, rxctrl & ~IXGBE_RXCTRL_RXEN);
 
-	/* flush both disables */
-	IXGBE_WRITE_FLUSH(&adapter->hw);
+	IXGBE_WRITE_FLUSH(hw);
 	msleep(10);
 
+	netif_stop_queue(netdev);
+	if (netif_is_multiqueue(netdev))
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			netif_stop_subqueue(netdev, i);
+
 	ixgbe_irq_disable(adapter);
 
 	ixgbe_napi_disable_all(adapter);
 	del_timer_sync(&adapter->watchdog_timer);
 
+	/* disable transmits in the hardware now that interrupts are off */
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		j = adapter->tx_ring[i].reg_idx;
+		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
+		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j),
+		                (txdctl & ~IXGBE_TXDCTL_ENABLE));
+	}
+
 	netif_carrier_off(netdev);
-	netif_stop_queue(netdev);
 
 	ixgbe_reset(adapter);
 	ixgbe_clean_all_tx_rings(adapter);
 	ixgbe_clean_all_rx_rings(adapter);
-
 }
 
 static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
@@ -2069,6 +2134,11 @@ static void ixgbe_reset_task(struct work_struct *work)
 	struct ixgbe_adapter *adapter;
 	adapter = container_of(work, struct ixgbe_adapter, reset_task);
 
+	/* If we're already down or resetting, just bail */
+	if (test_bit(__IXGBE_DOWN, &adapter->state) ||
+	    test_bit(__IXGBE_RESETTING, &adapter->state))
+		return;
+
 	adapter->tx_timeout_count++;
 
 	ixgbe_reinit_locked(adapter);
@@ -2112,6 +2182,7 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
+		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		adapter->num_tx_queues = 1;
 		adapter->num_rx_queues = 1;
@@ -2121,19 +2192,39 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 	}
 }
 
-static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
+static void ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 {
-	int nrq, ntq;
+	int nrq = 1, ntq = 1;
 	int feature_mask = 0, rss_i, rss_m;
+	int dcb_i, dcb_m;
 
 	/* Number of supported queues */
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82598EB:
+		dcb_i = adapter->ring_feature[RING_F_DCB].indices;
+		dcb_m = 0;
 		rss_i = adapter->ring_feature[RING_F_RSS].indices;
 		rss_m = 0;
+		feature_mask |= IXGBE_FLAG_DCB_ENABLED;
 		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
 
 		switch (adapter->flags & feature_mask) {
+		case (IXGBE_FLAG_DCB_ENABLED):
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			dcb_m = 0x7 << 3;
+			nrq = dcb_i;
+			ntq = dcb_i;
+#else
+			printk(KERN_INFO, "Kernel has no multiqueue "
+				"support, disabling DCB.\n");
+			/* Fall back onto RSS */
+			rss_m = 0xF;
+			nrq = rss_i;
+			ntq = 1;
+			dcb_m = 0;
+			dcb_i = 0;
+#endif
+			break;
 		case (IXGBE_FLAG_RSS_ENABLED):
 			rss_m = 0xF;
 			nrq = rss_i;
@@ -2145,6 +2236,8 @@ static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 			break;
 		case 0:
 		default:
+			dcb_i = 0;
+			dcb_m = 0;
 			rss_i = 0;
 			rss_m = 0;
 			nrq = 1;
@@ -2152,6 +2245,8 @@ static void __devinit ixgbe_set_num_queues(struct ixgbe_adapter *adapter)
 			break;
 		}
 
+		adapter->ring_feature[RING_F_DCB].indices = dcb_i;
+		adapter->ring_feature[RING_F_DCB].mask = dcb_m;
 		adapter->ring_feature[RING_F_RSS].indices = rss_i;
 		adapter->ring_feature[RING_F_RSS].mask = rss_m;
 		break;
@@ -2179,15 +2274,25 @@ static void __devinit ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 	 */
 	int feature_mask = 0, rss_i;
 	int i, txr_idx, rxr_idx;
+	int dcb_i;
 
 	/* Number of supported queues */
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_82598EB:
+		dcb_i = adapter->ring_feature[RING_F_DCB].indices;
 		rss_i = adapter->ring_feature[RING_F_RSS].indices;
 		txr_idx = 0;
 		rxr_idx = 0;
+		feature_mask |= IXGBE_FLAG_DCB_ENABLED;
 		feature_mask |= IXGBE_FLAG_RSS_ENABLED;
 		switch (adapter->flags & feature_mask) {
+		case (IXGBE_FLAG_DCB_ENABLED):
+			/* the number of queues is assumed to be symmetric */
+			for (i = 0; i < dcb_i; i++) {
+				adapter->rx_ring[i].reg_idx = i << 3;
+				adapter->tx_ring[i].reg_idx = i << 2;
+			}
+			break;
 		case (IXGBE_FLAG_RSS_ENABLED):
 			for (i = 0; i < adapter->num_rx_queues; i++)
 				adapter->rx_ring[i].reg_idx = i;
@@ -2212,7 +2317,7 @@ static void __devinit ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
  * number of queues at compile-time.  The polling_netdev array is
  * intended for Multiqueue, but should work fine with a single queue.
  **/
-static int __devinit ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
+static int ixgbe_alloc_queues(struct ixgbe_adapter *adapter)
 {
 	int i;
 
@@ -2252,7 +2357,7 @@ err_tx_ring_allocation:
  * Attempt to configure the interrupts using the best available
  * capabilities of the hardware and the kernel.
  **/
-static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
+static int ixgbe_set_interrupt_capability(struct ixgbe_adapter
 						    *adapter)
 {
 	int err = 0;
@@ -2281,6 +2386,7 @@ static int __devinit ixgbe_set_interrupt_capability(struct ixgbe_adapter
 	adapter->msix_entries = kcalloc(v_budget,
 					sizeof(struct msix_entry), GFP_KERNEL);
 	if (!adapter->msix_entries) {
+		adapter->flags &= ~IXGBE_FLAG_DCB_ENABLED;
 		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
 		ixgbe_set_num_queues(adapter);
 		kfree(adapter->tx_ring);
@@ -2323,7 +2429,7 @@ out:
 	return err;
 }
 
-static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
+void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
 {
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
@@ -2347,7 +2453,7 @@ static void ixgbe_reset_interrupt_capability(struct ixgbe_adapter *adapter)
  * - Hardware queue count (num_*_queues)
  *   - defined by miscellaneous hardware support/features (RSS, etc.)
  **/
-static int __devinit ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
+int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 {
 	int err;
 
@@ -2395,11 +2501,27 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	struct ixgbe_hw *hw = &adapter->hw;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned int rss;
+	int j;
+	struct tc_configuration *tc;
 
 	/* Set capability flags */
 	rss = min(IXGBE_MAX_RSS_INDICES, (int)num_online_cpus());
 	adapter->ring_feature[RING_F_RSS].indices = rss;
 	adapter->flags |= IXGBE_FLAG_RSS_ENABLED;
+	adapter->ring_feature[RING_F_DCB].indices = IXGBE_MAX_DCB_INDICES;
+	for (j = 0; j < MAX_TRAFFIC_CLASS; j++) {
+		tc = &adapter->dcb_cfg.tc_config[j];
+		tc->path[DCB_TX_CONFIG].bwg_id = 0;
+		tc->path[DCB_TX_CONFIG].bwg_percent = 12 + (j & 1);
+		tc->path[DCB_RX_CONFIG].bwg_id = 0;
+		tc->path[DCB_RX_CONFIG].bwg_percent = 12 + (j & 1);
+		tc->dcb_pfc = pfc_disabled;
+	}
+	adapter->dcb_cfg.bw_percentage[DCB_TX_CONFIG][0] = 100;
+	adapter->dcb_cfg.bw_percentage[DCB_RX_CONFIG][0] = 100;
+	adapter->dcb_cfg.rx_pba_cfg = pba_equal;
+	adapter->dcb_cfg.round_robin_enable = false;
+	adapter->dcb_set_bitmap = 0x00;
 
 	/* Enable Dynamic interrupt throttling by default */
 	adapter->rx_eitr = 1;
@@ -2681,7 +2803,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
  **/
-static int ixgbe_open(struct net_device *netdev)
+int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int err;
@@ -2736,7 +2858,7 @@ err_setup_tx:
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int ixgbe_close(struct net_device *netdev)
+int ixgbe_close(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
@@ -2769,6 +2891,18 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		adapter->stats.mpc[i] += mpc;
 		total_mpc += adapter->stats.mpc[i];
 		adapter->stats.rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+		adapter->stats.qptc[i] += IXGBE_READ_REG(hw, IXGBE_QPTC(i));
+		adapter->stats.qbtc[i] += IXGBE_READ_REG(hw, IXGBE_QBTC(i));
+		adapter->stats.qprc[i] += IXGBE_READ_REG(hw, IXGBE_QPRC(i));
+		adapter->stats.qbrc[i] += IXGBE_READ_REG(hw, IXGBE_QBRC(i));
+		adapter->stats.pxonrxc[i] += IXGBE_READ_REG(hw,
+		                                            IXGBE_PXONRXC(i));
+		adapter->stats.pxontxc[i] += IXGBE_READ_REG(hw,
+		                                            IXGBE_PXONTXC(i));
+		adapter->stats.pxoffrxc[i] += IXGBE_READ_REG(hw,
+		                                             IXGBE_PXOFFRXC(i));
+		adapter->stats.pxofftxc[i] += IXGBE_READ_REG(hw,
+		                                             IXGBE_PXOFFTXC(i));
 	}
 	adapter->stats.gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
 	/* work around hardware counting issue */
@@ -2865,10 +2999,9 @@ static void ixgbe_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
-			for (i = 0; i < adapter->num_tx_queues; i++)
-				netif_wake_subqueue(netdev, i);
-#endif
+			if (netif_is_multiqueue(netdev))
+				for (i = 0; i < adapter->num_tx_queues; i++)
+					netif_wake_subqueue(netdev, i);
 		} else {
 			/* Force detection of hung controller */
 			adapter->detect_tx_hung = true;
@@ -2878,6 +3011,9 @@ static void ixgbe_watchdog(unsigned long data)
 			DPRINTK(LINK, INFO, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
+			if (netif_is_multiqueue(netdev))
+				for (i = 0; i < adapter->num_tx_queues; i++)
+					netif_stop_subqueue(netdev, i);
 		}
 	}
 
@@ -2972,6 +3108,8 @@ static int ixgbe_tso(struct ixgbe_adapter *adapter,
 		mss_l4len_idx |=
 		    (skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT);
 		mss_l4len_idx |= (l4len << IXGBE_ADVTXD_L4LEN_SHIFT);
+		/* use index 1 for TSO */
+		mss_l4len_idx |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		context_desc->mss_l4len_idx = cpu_to_le32(mss_l4len_idx);
 
 		tx_buffer_info->time_stamp = jiffies;
@@ -3044,6 +3182,7 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 		}
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
+		/* use index zero for tx checksum offload */
 		context_desc->mss_l4len_idx = 0;
 
 		tx_buffer_info->time_stamp = jiffies;
@@ -3152,6 +3291,8 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 		olinfo_status |= IXGBE_TXD_POPTS_TXSM <<
 						IXGBE_ADVTXD_POPTS_SHIFT;
 
+		/* use index 1 context for tso */
+		olinfo_status |= (1 << IXGBE_ADVTXD_IDX_SHIFT);
 		if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 			olinfo_status |= IXGBE_TXD_POPTS_IXSM <<
 						IXGBE_ADVTXD_POPTS_SHIFT;
@@ -3195,11 +3336,11 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	netif_stop_subqueue(netdev, tx_ring->queue_index);
-#else
-	netif_stop_queue(netdev);
-#endif
+	if (netif_is_multiqueue(netdev))
+		netif_stop_subqueue(netdev, tx_ring->queue_index);
+	else
+		netif_stop_queue(netdev);
+
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -3211,11 +3352,10 @@ static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! - use start_queue because it doesn't call schedule */
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	netif_wake_subqueue(netdev, tx_ring->queue_index);
-#else
-	netif_wake_queue(netdev);
-#endif
+	if (netif_is_multiqueue(netdev))
+		netif_start_subqueue(netdev, tx_ring->queue_index);
+	else
+		netif_start_queue(netdev);
 	++adapter->restart_queue;
 	return 0;
 }
@@ -3253,6 +3393,7 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		dev_kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
+
 	mss = skb_shinfo(skb)->gso_size;
 
 	if (mss)
@@ -3269,8 +3410,21 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		return NETDEV_TX_BUSY;
 	}
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
+		tx_flags |= vlan_tx_tag_get(skb);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+			tx_flags &= ~IXGBE_TX_FLAGS_VLAN_PRIO_MASK;
+			tx_flags |= (skb->queue_mapping << 13);
+		}
+#endif
+		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
+		tx_flags |= IXGBE_TX_FLAGS_VLAN;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	} else if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
+		tx_flags |= (skb->queue_mapping << 13);
+		tx_flags <<= IXGBE_TX_FLAGS_VLAN_SHIFT;
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
-		tx_flags |= (vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT);
+#endif
 	}
 
 	if (skb->protocol == htons(ETH_P_IP))
@@ -3520,13 +3674,12 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO;
 
 	netdev->features |= NETIF_F_TSO6;
+	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
+		adapter->flags &= ~IXGBE_FLAG_RSS_ENABLED;
+
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	netdev->features |= NETIF_F_MULTI_QUEUE;
-#endif
-
 	/* make sure the EEPROM is good */
 	if (ixgbe_validate_eeprom_checksum(hw, NULL) < 0) {
 		dev_err(&pdev->dev, "The EEPROM Checksum Is Not Valid\n");
@@ -3593,10 +3746,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
-#ifdef CONFIG_NETDEVICES_MULTIQUEUE
-	for (i = 0; i < adapter->num_tx_queues; i++)
-		netif_stop_subqueue(netdev, i);
-#endif
+	if (netif_is_multiqueue(netdev))
+		for (i = 0; i < adapter->num_tx_queues; i++)
+			netif_stop_subqueue(netdev, i);
 
 	ixgbe_napi_add_all(adapter);
 
@@ -3774,6 +3926,11 @@ static struct pci_driver ixgbe_driver = {
 	.err_handler = &ixgbe_err_handler
 };
 
+bool ixgbe_is_ixgbe(struct pci_dev *pcidev)
+{
+	return (!(pci_dev_driver(pcidev) != &ixgbe_driver));
+}
+
 /**
  * ixgbe_init_module - Driver Registration Routine
  *
@@ -3782,18 +3939,17 @@ static struct pci_driver ixgbe_driver = {
  **/
 static int __init ixgbe_init_module(void)
 {
-	int ret;
 	printk(KERN_INFO "%s: %s - version %s\n", ixgbe_driver_name,
 	       ixgbe_driver_string, ixgbe_driver_version);
 
 	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
 
+	ixgbe_dcb_netlink_register();
 #ifdef CONFIG_DCA
 	dca_register_notify(&dca_notifier);
 
 #endif
-	ret = pci_register_driver(&ixgbe_driver);
-	return ret;
+	return pci_register_driver(&ixgbe_driver);
 }
 module_init(ixgbe_init_module);
 
@@ -3808,6 +3964,7 @@ static void __exit ixgbe_exit_module(void)
 #ifdef CONFIG_DCA
 	dca_unregister_notify(&dca_notifier);
 #endif
+	ixgbe_dcb_netlink_unregister();
 	pci_unregister_driver(&ixgbe_driver);
 }
 

