From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 8/9] e1000: delete non NAPI code from the driver
Date: Fri, 11 Jul 2008 15:17:38 -0700
Message-ID: <20080711221738.3255.6056.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:51567 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756536AbYGKWRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:40 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Compile-tested only.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 Documentation/networking/e1000.txt |   14 ---
 drivers/net/Kconfig                |   14 ---
 drivers/net/e1000/e1000.h          |   10 --
 drivers/net/e1000/e1000_main.c     |  151 +++---------------------------------
 4 files changed, 16 insertions(+), 173 deletions(-)

diff --git a/Documentation/networking/e1000.txt b/Documentation/networking/e1000.txt
index 61b171c..2df7186 100644
--- a/Documentation/networking/e1000.txt
+++ b/Documentation/networking/e1000.txt
@@ -513,21 +513,11 @@ Additional Configurations
   Intel(R) PRO/1000 PT Dual Port Server Connection
   Intel(R) PRO/1000 PT Dual Port Server Adapter
   Intel(R) PRO/1000 PF Dual Port Server Adapter
-  Intel(R) PRO/1000 PT Quad Port Server Adapter 
+  Intel(R) PRO/1000 PT Quad Port Server Adapter
 
   NAPI
   ----
-  NAPI (Rx polling mode) is supported in the e1000 driver.  NAPI is enabled
-  or disabled based on the configuration of the kernel.  To override
-  the default, use the following compile-time flags.
-
-  To enable NAPI, compile the driver module, passing in a configuration option:
-
-       make CFLAGS_EXTRA=-DE1000_NAPI install
-
-  To disable NAPI, compile the driver module, passing in a configuration option:
-
-       make CFLAGS_EXTRA=-DE1000_NO_NAPI install
+  NAPI (Rx polling mode) is enabled in the e1000 driver.
 
   See www.cyberus.ca/~hadi/usenix-paper.tgz for more information on NAPI.
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ef733ab..0d39cb3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1964,20 +1964,6 @@ config E1000
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000.
 
-config E1000_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on E1000
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
 config E1000_DISABLE_PACKET_SPLIT
 	bool "Disable Packet Split for PCI express adapters"
 	depends on E1000
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 3aeba93..583b823 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -253,9 +253,7 @@ struct e1000_adapter {
 	u16 link_speed;
 	u16 link_duplex;
 	spinlock_t stats_lock;
-#ifdef CONFIG_E1000_NAPI
 	spinlock_t tx_queue_lock;
-#endif
 	unsigned int total_tx_bytes;
 	unsigned int total_tx_packets;
 	unsigned int total_rx_bytes;
@@ -293,22 +291,16 @@ struct e1000_adapter {
 	bool detect_tx_hung;
 
 	/* RX */
-#ifdef CONFIG_E1000_NAPI
 	bool (*clean_rx)(struct e1000_adapter *adapter,
 			 struct e1000_rx_ring *rx_ring,
 			 int *work_done, int work_to_do);
-#else
-	bool (*clean_rx)(struct e1000_adapter *adapter,
-			 struct e1000_rx_ring *rx_ring);
-#endif
 	void (*alloc_rx_buf)(struct e1000_adapter *adapter,
 			     struct e1000_rx_ring *rx_ring,
 			     int cleaned_count);
 	struct e1000_rx_ring *rx_ring;      /* One per active queue */
-#ifdef CONFIG_E1000_NAPI
 	struct napi_struct napi;
 	struct net_device *polling_netdev;  /* One per active queue */
-#endif
+
 	int num_tx_queues;
 	int num_rx_queues;
 
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 28d14ae..19ac606 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -31,12 +31,7 @@
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-#ifndef CONFIG_E1000_NAPI
-#define DRIVERNAPI
-#else
-#define DRIVERNAPI "-NAPI"
-#endif
-#define DRV_VERSION "7.3.20-k2"DRIVERNAPI
+#define DRV_VERSION "7.3.20-k3-NAPI"
 const char e1000_driver_version[] = DRV_VERSION;
 static const char e1000_copyright[] = "Copyright (c) 1999-2006 Intel Corporation.";
 
@@ -138,7 +133,6 @@ static irqreturn_t e1000_intr(int irq, void *data);
 static irqreturn_t e1000_intr_msi(int irq, void *data);
 static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			       struct e1000_tx_ring *tx_ring);
-#ifdef CONFIG_E1000_NAPI
 static int e1000_clean(struct napi_struct *napi, int budget);
 static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
@@ -146,12 +140,6 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 				  struct e1000_rx_ring *rx_ring,
 				  int *work_done, int work_to_do);
-#else
-static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
-			       struct e1000_rx_ring *rx_ring);
-static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-				  struct e1000_rx_ring *rx_ring);
-#endif
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
                                    struct e1000_rx_ring *rx_ring,
 				   int cleaned_count);
@@ -512,9 +500,8 @@ int e1000_up(struct e1000_adapter *adapter)
 
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-#ifdef CONFIG_E1000_NAPI
 	napi_enable(&adapter->napi);
-#endif
+
 	e1000_irq_enable(adapter);
 
 	/* fire a link change interrupt to start the watchdog */
@@ -602,9 +589,8 @@ void e1000_down(struct e1000_adapter *adapter)
 	 * reschedule our watchdog timer */
 	set_bit(__E1000_DOWN, &adapter->flags);
 
-#ifdef CONFIG_E1000_NAPI
 	napi_disable(&adapter->napi);
-#endif
+
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->tx_fifo_stall_timer);
@@ -966,9 +952,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	e1000_set_ethtool_ops(netdev);
 	netdev->tx_timeout = &e1000_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
-#ifdef CONFIG_E1000_NAPI
 	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
-#endif
 	netdev->vlan_rx_register = e1000_vlan_rx_register;
 	netdev->vlan_rx_add_vid = e1000_vlan_rx_add_vid;
 	netdev->vlan_rx_kill_vid = e1000_vlan_rx_kill_vid;
@@ -1207,16 +1191,12 @@ err_eeprom:
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
 err_flashmap:
-#ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		dev_put(&adapter->polling_netdev[i]);
-#endif
 
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
-#ifdef CONFIG_E1000_NAPI
 	kfree(adapter->polling_netdev);
-#endif
 err_sw_init:
 	iounmap(hw->hw_addr);
 err_ioremap:
@@ -1244,9 +1224,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-#ifdef CONFIG_E1000_NAPI
 	int i;
-#endif
 
 	cancel_work_sync(&adapter->reset_task);
 
@@ -1256,10 +1234,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	 * would have already happened in close and is redundant. */
 	e1000_release_hw_control(adapter);
 
-#ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		dev_put(&adapter->polling_netdev[i]);
-#endif
 
 	unregister_netdev(netdev);
 
@@ -1268,9 +1244,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
-#ifdef CONFIG_E1000_NAPI
 	kfree(adapter->polling_netdev);
-#endif
 
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
@@ -1296,9 +1270,7 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
-#ifdef CONFIG_E1000_NAPI
 	int i;
-#endif
 
 	/* PCI config space info */
 
@@ -1356,14 +1328,12 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 		return -ENOMEM;
 	}
 
-#ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		adapter->polling_netdev[i].priv = adapter;
 		dev_hold(&adapter->polling_netdev[i]);
 		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
 	}
 	spin_lock_init(&adapter->tx_queue_lock);
-#endif
 
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	e1000_irq_disable(adapter);
@@ -1398,7 +1368,6 @@ static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
 		return -ENOMEM;
 	}
 
-#ifdef CONFIG_E1000_NAPI
 	adapter->polling_netdev = kcalloc(adapter->num_rx_queues,
 	                                  sizeof(struct net_device),
 	                                  GFP_KERNEL);
@@ -1407,7 +1376,6 @@ static int __devinit e1000_alloc_queues(struct e1000_adapter *adapter)
 		kfree(adapter->rx_ring);
 		return -ENOMEM;
 	}
-#endif
 
 	return E1000_SUCCESS;
 }
@@ -1472,9 +1440,7 @@ static int e1000_open(struct net_device *netdev)
 	/* From here on the code is the same as e1000_up() */
 	clear_bit(__E1000_DOWN, &adapter->flags);
 
-#ifdef CONFIG_E1000_NAPI
 	napi_enable(&adapter->napi);
-#endif
 
 	e1000_irq_enable(adapter);
 
@@ -2067,11 +2033,9 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 		ctrl_ext = er32(CTRL_EXT);
 		/* Reset delay timers after every interrupt */
 		ctrl_ext |= E1000_CTRL_EXT_INT_TIMER_CLR;
-#ifdef CONFIG_E1000_NAPI
 		/* Auto-Mask interrupts upon ICR access */
 		ctrl_ext |= E1000_CTRL_EXT_IAME;
 		ew32(IAM, 0xffffffff);
-#endif
 		ew32(CTRL_EXT, ctrl_ext);
 		E1000_WRITE_FLUSH();
 	}
@@ -3770,9 +3734,6 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 	struct net_device *netdev = data;
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-#ifndef CONFIG_E1000_NAPI
-	int i;
-#endif
 	u32 icr = er32(ICR);
 
 	/* in NAPI mode read ICR disables interrupts using IAM */
@@ -3793,7 +3754,6 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-#ifdef CONFIG_E1000_NAPI
 	if (likely(netif_rx_schedule_prep(netdev, &adapter->napi))) {
 		adapter->total_tx_bytes = 0;
 		adapter->total_tx_packets = 0;
@@ -3802,20 +3762,6 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 		__netif_rx_schedule(netdev, &adapter->napi);
 	} else
 		e1000_irq_enable(adapter);
-#else
-	adapter->total_tx_bytes = 0;
-	adapter->total_rx_bytes = 0;
-	adapter->total_tx_packets = 0;
-	adapter->total_rx_packets = 0;
-
-	for (i = 0; i < E1000_MAX_INTR; i++)
-		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
-			break;
-
-	if (likely(adapter->itr_setting & 3))
-		e1000_set_itr(adapter);
-#endif
 
 	return IRQ_HANDLED;
 }
@@ -3832,13 +3778,10 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rctl, icr = er32(ICR);
-#ifndef CONFIG_E1000_NAPI
-	int i;
-#endif
+
 	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
 
-#ifdef CONFIG_E1000_NAPI
 	/* IMS will not auto-mask if INT_ASSERTED is not set, and if it is
 	 * not set, then the adapter didn't send an interrupt */
 	if (unlikely(hw->mac_type >= e1000_82571 &&
@@ -3847,7 +3790,6 @@ static irqreturn_t e1000_intr(int irq, void *data)
 
 	/* Interrupt Auto-Mask...upon reading ICR, interrupts are masked.  No
 	 * need for the IMC write */
-#endif
 
 	if (unlikely(icr & (E1000_ICR_RXSEQ | E1000_ICR_LSC))) {
 		hw->get_link_status = 1;
@@ -3867,7 +3809,6 @@ static irqreturn_t e1000_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-#ifdef CONFIG_E1000_NAPI
 	if (unlikely(hw->mac_type < e1000_82571)) {
 		/* disable interrupts, without the synchronize_irq bit */
 		ew32(IMC, ~0);
@@ -3883,46 +3824,14 @@ static irqreturn_t e1000_intr(int irq, void *data)
 		/* this really should not happen! if it does it is basically a
 		 * bug, but not a hard error, so enable ints and continue */
 		e1000_irq_enable(adapter);
-#else
-	/* Writing IMC and IMS is needed for 82547.
-	 * Due to Hub Link bus being occupied, an interrupt
-	 * de-assertion message is not able to be sent.
-	 * When an interrupt assertion message is generated later,
-	 * two messages are re-ordered and sent out.
-	 * That causes APIC to think 82547 is in de-assertion
-	 * state, while 82547 is in assertion state, resulting
-	 * in dead lock. Writing IMC forces 82547 into
-	 * de-assertion state.
-	 */
-	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
-		ew32(IMC, ~0);
-
-	adapter->total_tx_bytes = 0;
-	adapter->total_rx_bytes = 0;
-	adapter->total_tx_packets = 0;
-	adapter->total_rx_packets = 0;
-
-	for (i = 0; i < E1000_MAX_INTR; i++)
-		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   !e1000_clean_tx_irq(adapter, adapter->tx_ring)))
-			break;
 
-	if (likely(adapter->itr_setting & 3))
-		e1000_set_itr(adapter);
-
-	if (hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
-		e1000_irq_enable(adapter);
-
-#endif
 	return IRQ_HANDLED;
 }
 
-#ifdef CONFIG_E1000_NAPI
 /**
  * e1000_clean - NAPI Rx polling callback
  * @adapter: board private structure
  **/
-
 static int e1000_clean(struct napi_struct *napi, int budget)
 {
 	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
@@ -3959,12 +3868,10 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	return work_done;
 }
 
-#endif
 /**
  * e1000_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
  **/
-
 static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			       struct e1000_tx_ring *tx_ring)
 {
@@ -3973,9 +3880,7 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 	struct e1000_tx_desc *tx_desc, *eop_desc;
 	struct e1000_buffer *buffer_info;
 	unsigned int i, eop;
-#ifdef CONFIG_E1000_NAPI
 	unsigned int count = 0;
-#endif
 	bool cleaned = false;
 	unsigned int total_tx_bytes=0, total_tx_packets=0;
 
@@ -4007,11 +3912,10 @@ static bool e1000_clean_tx_irq(struct e1000_adapter *adapter,
 
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
-#ifdef CONFIG_E1000_NAPI
 #define E1000_TX_WEIGHT 64
 		/* weight of a sort for tx, to avoid endless transmit cleanup */
-		if (count++ == E1000_TX_WEIGHT) break;
-#endif
+		if (count++ == E1000_TX_WEIGHT)
+			break;
 	}
 
 	tx_ring->next_to_clean = i;
@@ -4124,14 +4028,9 @@ static void e1000_rx_checksum(struct e1000_adapter *adapter, u32 status_err,
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
  **/
-#ifdef CONFIG_E1000_NAPI
 static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
 			       int *work_done, int work_to_do)
-#else
-static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
-			       struct e1000_rx_ring *rx_ring)
-#endif
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
@@ -4154,11 +4053,10 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		struct sk_buff *skb;
 		u8 status;
 
-#ifdef CONFIG_E1000_NAPI
 		if (*work_done >= work_to_do)
 			break;
 		(*work_done)++;
-#endif
+
 		status = rx_desc->status;
 		skb = buffer_info->skb;
 		buffer_info->skb = NULL;
@@ -4244,7 +4142,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 				  le16_to_cpu(rx_desc->csum), skb);
 
 		skb->protocol = eth_type_trans(skb, netdev);
-#ifdef CONFIG_E1000_NAPI
+
 		if (unlikely(adapter->vlgrp &&
 			    (status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
@@ -4252,15 +4150,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		} else {
 			netif_receive_skb(skb);
 		}
-#else /* CONFIG_E1000_NAPI */
-		if (unlikely(adapter->vlgrp &&
-			    (status & E1000_RXD_STAT_VP))) {
-			vlan_hwaccel_rx(skb, adapter->vlgrp,
-					le16_to_cpu(rx_desc->special));
-		} else {
-			netif_rx(skb);
-		}
-#endif /* CONFIG_E1000_NAPI */
+
 		netdev->last_rx = jiffies;
 
 next_desc:
@@ -4294,14 +4184,9 @@ next_desc:
  * @adapter: board private structure
  **/
 
-#ifdef CONFIG_E1000_NAPI
 static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 				  struct e1000_rx_ring *rx_ring,
 				  int *work_done, int work_to_do)
-#else
-static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-				  struct e1000_rx_ring *rx_ring)
-#endif
 {
 	union e1000_rx_desc_packet_split *rx_desc, *next_rxd;
 	struct net_device *netdev = adapter->netdev;
@@ -4324,11 +4209,11 @@ static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 	while (staterr & E1000_RXD_STAT_DD) {
 		ps_page = &rx_ring->ps_page[i];
 		ps_page_dma = &rx_ring->ps_page_dma[i];
-#ifdef CONFIG_E1000_NAPI
+
 		if (unlikely(*work_done >= work_to_do))
 			break;
 		(*work_done)++;
-#endif
+
 		skb = buffer_info->skb;
 
 		/* in the packet split case this is header only */
@@ -4430,21 +4315,14 @@ copydone:
 		if (likely(rx_desc->wb.upper.header_status &
 			   cpu_to_le16(E1000_RXDPS_HDRSTAT_HDRSP)))
 			adapter->rx_hdr_split++;
-#ifdef CONFIG_E1000_NAPI
+
 		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
 				le16_to_cpu(rx_desc->wb.middle.vlan));
 		} else {
 			netif_receive_skb(skb);
 		}
-#else /* CONFIG_E1000_NAPI */
-		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
-			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->wb.middle.vlan));
-		} else {
-			netif_rx(skb);
-		}
-#endif /* CONFIG_E1000_NAPI */
+
 		netdev->last_rx = jiffies;
 
 next_desc:
@@ -5216,9 +5094,6 @@ static void e1000_netpoll(struct net_device *netdev)
 
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
-#ifndef CONFIG_E1000_NAPI
-	adapter->clean_rx(adapter, adapter->rx_ring);
-#endif
 	enable_irq(adapter->pdev->irq);
 }
 #endif

