From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 24/25] ixgb: make NAPI the only option and the default
Date: Tue, 08 Jul 2008 15:53:04 -0700
Message-ID: <20080708225303.6925.83501.stgit@localhost.localdomain>
References: <20080708224858.6925.29725.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:58387 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755015AbYGHWxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2008 18:53:07 -0400
In-Reply-To: <20080708224858.6925.29725.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

network maintainers suggest NAPI only drivers are the only way to go.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/Kconfig          |   14 -------------
 drivers/net/ixgb/ixgb_main.c |   47 +-----------------------------------------
 2 files changed, 1 insertions(+), 60 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ef733ab..b1062f8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2465,20 +2465,6 @@ config IXGB
 	  To compile this driver as a module, choose M here. The module
 	  will be called ixgb.
 
-config IXGB_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
-	depends on IXGB && EXPERIMENTAL
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config S2IO
 	tristate "S2IO 10Gbe XFrame NIC"
 	depends on PCI
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 3e857c0..5264134 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -31,12 +31,8 @@
 char ixgb_driver_name[] = "ixgb";
 static char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
 
-#ifndef CONFIG_IXGB_NAPI
-#define DRIVERNAPI
-#else
 #define DRIVERNAPI "-NAPI"
-#endif
-#define DRV_VERSION		"1.0.126-k4"DRIVERNAPI
+#define DRV_VERSION "1.0.126" DRIVERNAPI
 const char ixgb_driver_version[] = DRV_VERSION;
 static const char ixgb_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -92,12 +88,8 @@ static int ixgb_set_mac(struct net_device *netdev, void *p);
 static irqreturn_t ixgb_intr(int irq, void *data);
 static bool ixgb_clean_tx_irq(struct ixgb_adapter *adapter);
 
-#ifdef CONFIG_IXGB_NAPI
 static int ixgb_clean(struct napi_struct *, int);
 static bool ixgb_clean_rx_irq(struct ixgb_adapter *, int *, int);
-#else
-static bool ixgb_clean_rx_irq(struct ixgb_adapter *);
-#endif
 static void ixgb_alloc_rx_buffers(struct ixgb_adapter *, int);
 
 static void ixgb_tx_timeout(struct net_device *dev);
@@ -271,9 +263,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 
 	clear_bit(__IXGB_DOWN, &adapter->flags);
 
-#ifdef CONFIG_IXGB_NAPI
 	napi_enable(&adapter->napi);
-#endif
 	ixgb_irq_enable(adapter);
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
@@ -289,9 +279,7 @@ ixgb_down(struct ixgb_adapter *adapter, bool kill_watchdog)
 	/* prevent the interrupt handler from restarting watchdog */
 	set_bit(__IXGB_DOWN, &adapter->flags);
 
-#ifdef CONFIG_IXGB_NAPI
 	napi_disable(&adapter->napi);
-#endif
 	/* waiting for NAPI to complete can re-enable interrupts */
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
@@ -419,9 +407,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	ixgb_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &ixgb_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-#ifdef CONFIG_IXGB_NAPI
 	netif_napi_add(netdev, &adapter->napi, ixgb_clean, 64);
-#endif
 	netdev->vlan_rx_register = ixgb_vlan_rx_register;
 	netdev->vlan_rx_add_vid = ixgb_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = ixgb_vlan_rx_kill_vid;
@@ -1709,9 +1695,6 @@ ixgb_intr(int irq, void *data)
 	struct ixgb_adapter *adapter = netdev_priv(netdev);
 	struct ixgb_hw *hw = &adapter->hw;
 	u32 icr = IXGB_READ_REG(hw, ICR);
-#ifndef CONFIG_IXGB_NAPI
-	unsigned int i;
-#endif
 
 	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
@@ -1720,7 +1703,6 @@ ixgb_intr(int irq, void *data)
 		if (!test_bit(__IXGB_DOWN, &adapter->flags))
 			mod_timer(&adapter->watchdog_timer, jiffies);
 
-#ifdef CONFIG_IXGB_NAPI
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 
 		/* Disable interrupts and register for poll. The flush
@@ -1730,20 +1712,9 @@ ixgb_intr(int irq, void *data)
 		IXGB_WRITE_REG(&adapter->hw, IMC, ~0);
 		__netif_rx_schedule(netdev, &adapter->napi);
 	}
-#else
-	/* yes, that is actually a & and it is meant to make sure that
-	 * every pass through this for loop checks both receive and
-	 * transmit queues for completed descriptors, intended to
-	 * avoid starvation issues and assist tx/rx fairness. */
-	for (i = 0; i < IXGB_MAX_INTR; i++)
-		if (!ixgb_clean_rx_irq(adapter) &
-		   !ixgb_clean_tx_irq(adapter))
-			break;
-#endif
 	return IRQ_HANDLED;
 }
 
-#ifdef CONFIG_IXGB_NAPI
 /**
  * ixgb_clean - NAPI Rx polling callback
  * @adapter: board private structure
@@ -1768,7 +1739,6 @@ ixgb_clean(struct napi_struct *napi, int budget)
 
 	return work_done;
 }
-#endif
 
 /**
  * ixgb_clean_tx_irq - Reclaim resources after transmit completes
@@ -1901,11 +1871,7 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
  **/
 
 static bool
-#ifdef CONFIG_IXGB_NAPI
 ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
-#else
-ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
-#endif
 {
 	struct ixgb_desc_ring *rx_ring = &adapter->rx_ring;
 	struct net_device *netdev = adapter->netdev;
@@ -1925,12 +1891,10 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		struct sk_buff *skb;
 		u8 status;
 
-#ifdef CONFIG_IXGB_NAPI
 		if (*work_done >= work_to_do)
 			break;
 
 		(*work_done)++;
-#endif
 		status = rx_desc->status;
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
@@ -2005,21 +1969,12 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter)
 		ixgb_rx_checksum(adapter, rx_desc, skb);
 
 		skb->protocol = eth_type_trans(skb, netdev);
-#ifdef CONFIG_IXGB_NAPI
 		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
 			                        le16_to_cpu(rx_desc->special));
 		} else {
 			netif_receive_skb(skb);
 		}
-#else /* CONFIG_IXGB_NAPI */
-		if (adapter->vlgrp && (status & IXGB_RX_DESC_STATUS_VP)) {
-			vlan_hwaccel_rx(skb, adapter->vlgrp,
-			                le16_to_cpu(rx_desc->special));
-		} else {
-			netif_rx(skb);
-		}
-#endif /* CONFIG_IXGB_NAPI */
 		netdev->last_rx = jiffies;
 
 rxdesc_done:

