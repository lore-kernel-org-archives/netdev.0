From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: drop lltx, remove unnecessary lock
Date: Mon, 19 Jan 2009 16:17:08 -0800
Message-ID: <20090120001708.22703.8019.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Don Ash <donash4@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:49501
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764775AbZATARc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 19:17:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

LLTX is deprecated and complicated, don't use it.  It was observed by Don Ash
<donash4@gmail.com> that e1000e was acquiring this lock in the NAPI cleanup
path.  This is obviously a bug, as this is a leftover from when e1000
supported multiple tx queues and fake netdevs.

another user reported this to us and tested routing with the 2.6.27 kernel and
this patch and reported a 3.5 % improvement in packets forwarded in a
multi-port test on 82571 parts.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Don Ash <donash4@gmail.com>
---

 drivers/net/e1000e/e1000.h  |    2 --
 drivers/net/e1000e/netdev.c |   34 +++-------------------------------
 2 files changed, 3 insertions(+), 33 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index 37bcb19..28bf9a5 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -195,8 +195,6 @@ struct e1000_adapter {
 	u16 link_duplex;
 	u16 eeprom_vers;
 
-	spinlock_t tx_queue_lock; /* prevent concurrent tail updates */
-
 	/* track device up/down/testing state */
 	unsigned long state;
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 91817d0..c4fe653 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -47,7 +47,7 @@
 
 #include "e1000.h"
 
-#define DRV_VERSION "0.3.3.3-k6"
+#define DRV_VERSION "0.3.3.4-k2"
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
@@ -1698,7 +1698,6 @@ int e1000e_setup_tx_resources(struct e1000_adapter *adapter)
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-	spin_lock_init(&adapter->tx_queue_lock);
 
 	return 0;
 err:
@@ -2007,16 +2006,7 @@ static int e1000_clean(struct napi_struct *napi, int budget)
 	    !(adapter->rx_ring->ims_val & adapter->tx_ring->ims_val))
 		goto clean_rx;
 
-	/*
-	 * e1000_clean is called per-cpu.  This lock protects
-	 * tx_ring from being cleaned by multiple cpus
-	 * simultaneously.  A failure obtaining the lock means
-	 * tx_ring is currently being cleaned anyway.
-	 */
-	if (spin_trylock(&adapter->tx_queue_lock)) {
-		tx_cleaned = e1000_clean_tx_irq(adapter);
-		spin_unlock(&adapter->tx_queue_lock);
-	}
+	tx_cleaned = e1000_clean_tx_irq(adapter);
 
 clean_rx:
 	adapter->clean_rx(adapter, &work_done, budget);
@@ -2922,8 +2912,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	if (e1000_alloc_queues(adapter))
 		return -ENOMEM;
 
-	spin_lock_init(&adapter->tx_queue_lock);
-
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	e1000_irq_disable(adapter);
 
@@ -4069,7 +4057,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
 	unsigned int len = skb->len - skb->data_len;
-	unsigned long irq_flags;
 	unsigned int nr_frags;
 	unsigned int mss;
 	int count = 0;
@@ -4138,18 +4125,12 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (adapter->hw.mac.tx_pkt_filtering)
 		e1000_transfer_dhcp_info(adapter, skb);
 
-	if (!spin_trylock_irqsave(&adapter->tx_queue_lock, irq_flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-
 	/*
 	 * need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time
 	 */
-	if (e1000_maybe_stop_tx(netdev, count + 2)) {
-		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
+	if (e1000_maybe_stop_tx(netdev, count + 2))
 		return NETDEV_TX_BUSY;
-	}
 
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= E1000_TX_FLAGS_VLAN;
@@ -4161,7 +4142,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	tso = e1000_tso(adapter, skb);
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
 		return NETDEV_TX_OK;
 	}
 
@@ -4182,7 +4162,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (count < 0) {
 		/* handle pci_map_single() error in e1000_tx_map */
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
 		return NETDEV_TX_OK;
 	}
 
@@ -4193,7 +4172,6 @@ static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	/* Make sure there is space in the ring for the next send. */
 	e1000_maybe_stop_tx(netdev, MAX_SKB_FRAGS + 2);
 
-	spin_unlock_irqrestore(&adapter->tx_queue_lock, irq_flags);
 	return NETDEV_TX_OK;
 }
 
@@ -4922,12 +4900,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	/*
-	 * We should not be using LLTX anymore, but we are still Tx faster with
-	 * it.
-	 */
-	netdev->features |= NETIF_F_LLTX;
-
 	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
 

