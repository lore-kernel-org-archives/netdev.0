From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 28/29] ixgbe: make compilation with LRO optional
Date: Thu, 11 Sep 2008 20:05:56 -0700
Message-ID: <20080912030543.6234.14136.stgit@jtkirshe-mobile.jf.intel.com>
References: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:19077 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbYILDF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2008 23:05:58 -0400
Received: by rv-out-0506.google.com with SMTP id k40so615516rvb.1
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2008 20:05:57 -0700 (PDT)
In-Reply-To: <20080912025404.6234.83037.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The current ixgbe forces LRO to always be enabled.  This patch makes this
optional due to the fact so that LRO can be disabled in cases where it is
not desirable such as routing or bridging.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig               |   11 ++++++++++-
 drivers/net/ixgbe/ixgbe.h         |   12 +++++++++---
 drivers/net/ixgbe/ixgbe_ethtool.c |    5 +++++
 drivers/net/ixgbe/ixgbe_main.c    |   19 ++++++++++++++++++-
 4 files changed, 42 insertions(+), 5 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4a11296..8831d13 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2380,7 +2380,6 @@ config EHEA
 config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI && INET
-	select INET_LRO
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -2396,6 +2395,16 @@ config IXGBE
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgbe.
 
+config IXGBE_LRO
+	bool "Use software LRO"
+	depends on IXGBE && INET
+	select INET_LRO
+	default y
+	---help---
+	  Say Y here if you want to use large receive offload.
+
+	  If in doubt, say N.
+
 config IXGB
 	tristate "Intel(R) PRO/10GbE support"
 	depends on PCI
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 63f6789..85b7a26 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -31,7 +31,12 @@
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
+
+#ifdef CONFIG_IXGBE_LRO
 #include <linux/inet_lro.h>
+#define IXGBE_MAX_LRO_AGGREGATE         32
+#define IXGBE_MAX_LRO_DESCRIPTORS       8
+#endif
 
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
@@ -86,9 +91,6 @@
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
-#define IXGBE_MAX_LRO_DESCRIPTORS       8
-#define IXGBE_MAX_LRO_AGGREGATE         32
-
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct ixgbe_tx_buffer {
@@ -140,8 +142,10 @@ struct ixgbe_ring {
 	/* cpu for tx queue */
 	int cpu;
 #endif
+#ifdef CONFIG_IXGBE_LRO
 	struct net_lro_mgr lro_mgr;
 	bool lro_used;
+#endif
 	struct ixgbe_queue_stats stats;
 	u16 v_idx; /* maps directly to the index for this ring in the hardware
 	           * vector array, can also be used for finding the bit in EICR
@@ -288,9 +292,11 @@ struct ixgbe_adapter {
 
 	unsigned long state;
 	u64 tx_busy;
+#ifndef IXGBE_NO_INET_LRO
 	u64 lro_aggregated;
 	u64 lro_flushed;
 	u64 lro_no_desc;
+#endif
 	unsigned int tx_ring_count;
 	unsigned int rx_ring_count;
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 81a9c4b..f7aefb5 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -89,8 +89,10 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_header_split", IXGBE_STAT(rx_hdr_split)},
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
+#ifdef CONFIG_IXGBE_LRO
 	{"lro_aggregated", IXGBE_STAT(lro_aggregated)},
 	{"lro_flushed", IXGBE_STAT(lro_flushed)},
+#endif
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
@@ -776,6 +778,8 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	int stat_count = sizeof(struct ixgbe_queue_stats) / sizeof(u64);
 	int j, k;
 	int i;
+
+#ifdef CONFIG_IXGBE_LRO
 	u64 aggregated = 0, flushed = 0, no_desc = 0;
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		aggregated += adapter->rx_ring[i].lro_mgr.stats.aggregated;
@@ -785,6 +789,7 @@ static void ixgbe_get_ethtool_stats(struct net_device *netdev,
 	adapter->lro_aggregated = aggregated;
 	adapter->lro_flushed = flushed;
 	adapter->lro_no_desc = no_desc;
+#endif
 
 	ixgbe_update_stats(adapter);
 	for (i = 0; i < IXGBE_GLOBAL_STATS_LEN; i++) {
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ca17af4..807be05 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -400,6 +400,7 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 	bool is_vlan = (status & IXGBE_RXD_STAT_VP);
 	u16 tag = le16_to_cpu(rx_desc->wb.upper.vlan);
 
+#ifdef CONFIG_IXGBE_LRO
 	if (adapter->netdev->features & NETIF_F_LRO &&
 	    skb->ip_summed == CHECKSUM_UNNECESSARY) {
 		if (adapter->vlgrp && is_vlan)
@@ -410,6 +411,7 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 			lro_receive_skb(&ring->lro_mgr, skb, rx_desc);
 		ring->lro_used = true;
 	} else {
+#endif
 		if (!(adapter->flags & IXGBE_FLAG_IN_NETPOLL)) {
 			if (adapter->vlgrp && is_vlan)
 				vlan_hwaccel_receive_skb(skb, adapter->vlgrp, tag);
@@ -421,7 +423,9 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 			else
 				netif_rx(skb);
 		}
+#ifdef CONFIG_IXGBE_LRO
 	}
+#endif
 }
 
 /**
@@ -684,10 +688,12 @@ next_desc:
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
 
+#ifdef CONFIG_IXGBE_LRO
 	if (rx_ring->lro_used) {
 		lro_flush_all(&rx_ring->lro_mgr);
 		rx_ring->lro_used = false;
 	}
+#endif
 
 	rx_ring->next_to_clean = i;
 	cleaned_count = IXGBE_DESC_UNUSED(rx_ring);
@@ -1532,6 +1538,7 @@ static void ixgbe_configure_srrctl(struct ixgbe_adapter *adapter, int index)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_SRRCTL(index), srrctl);
 }
 
+#ifdef CONFIG_IXGBE_LRO
 /**
  * ixgbe_get_skb_hdr - helper function for LRO header processing
  * @skb: pointer to sk_buff to be added to LRO packet
@@ -1559,6 +1566,7 @@ static int ixgbe_get_skb_hdr(struct sk_buff *skb, void **iphdr, void **tcph,
 	return 0;
 }
 
+#endif /* CONFIG_IXGBE_LRO */
 #define PAGE_USE_COUNT(S) (((S) >> PAGE_SHIFT) + \
                            (((S) & (PAGE_SIZE - 1)) ? 1 : 0))
 
@@ -1630,6 +1638,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].head = IXGBE_RDH(j);
 		adapter->rx_ring[i].tail = IXGBE_RDT(j);
 		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
+#ifdef CONFIG_IXGBE_LRO
 		/* Intitial LRO Settings */
 		adapter->rx_ring[i].lro_mgr.max_aggr = IXGBE_MAX_LRO_AGGREGATE;
 		adapter->rx_ring[i].lro_mgr.max_desc = IXGBE_MAX_LRO_DESCRIPTORS;
@@ -1640,6 +1649,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].lro_mgr.dev = adapter->netdev;
 		adapter->rx_ring[i].lro_mgr.ip_summed = CHECKSUM_UNNECESSARY;
 		adapter->rx_ring[i].lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+#endif
 
 		ixgbe_configure_srrctl(adapter, j);
 	}
@@ -2682,12 +2692,13 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	struct pci_dev *pdev = adapter->pdev;
 	int size;
 
+#ifdef CONFIG_IXGBE_LRO
 	size = sizeof(struct net_lro_desc) * IXGBE_MAX_LRO_DESCRIPTORS;
 	rx_ring->lro_mgr.lro_arr = vmalloc(size);
 	if (!rx_ring->lro_mgr.lro_arr)
 		return -ENOMEM;
 	memset(rx_ring->lro_mgr.lro_arr, 0, size);
-
+#endif
 	size = sizeof(struct ixgbe_rx_buffer) * rx_ring->count;
 	rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info) {
@@ -2716,8 +2727,10 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	return 0;
 
 alloc_failed:
+#ifdef CONFIG_IXGBE_LRO
 	vfree(rx_ring->lro_mgr.lro_arr);
 	rx_ring->lro_mgr.lro_arr = NULL;
+#endif
 	return -ENOMEM;
 }
 
@@ -2795,8 +2808,10 @@ void ixgbe_free_rx_resources(struct ixgbe_adapter *adapter,
 {
 	struct pci_dev *pdev = adapter->pdev;
 
+#ifdef CONFIG_IXGBE_LRO
 	vfree(rx_ring->lro_mgr.lro_arr);
 	rx_ring->lro_mgr.lro_arr = NULL;
+#endif
 
 	ixgbe_clean_rx_ring(adapter, rx_ring);
 
@@ -3836,7 +3851,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_IPV6_CSUM;
 	netdev->features |= NETIF_F_TSO;
 	netdev->features |= NETIF_F_TSO6;
+#ifdef CONFIG_IXGBE_LRO
 	netdev->features |= NETIF_F_LRO;
+#endif
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;

