From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 2/6] tx_lock
Date: Mon, 2 Feb 2004 14:01:32 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402021340570.6288-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Fix race in Tx performance path with tx_lock.  Between checking
  if we're out of resources and stopping the queue, we can get
  a hard interrupt which will clean up all Tx work, and wake
  the queue.  Coming out of hard interrupt context, we stop the
  queue even though no work was queued, and all work completed
  has been cleaned up.  Scenario requires ring to be completely
  filled, which is more likely to happen with TSO, since each
  TSO send consumes multiple ring entries.

--------------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000.h netdev-2.6/drivers/net/e1000.mod/e1000.h
--- netdev-2.6/drivers/net/e1000/e1000.h	2004-02-02 12:07:15.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000.h	2004-02-02 12:07:29.000000000 -0800
@@ -202,6 +202,7 @@ struct e1000_adapter {
 
 	/* TX */
 	struct e1000_desc_ring tx_ring;
+	spinlock_t tx_lock;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
 	uint32_t tx_abs_int_delay;
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-02 12:07:15.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-02 12:08:10.000000000 -0800
@@ -674,6 +674,7 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
+	spin_lock_init(&adapter->tx_lock);
 
 	return 0;
 }
@@ -1772,6 +1773,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	struct e1000_adapter *adapter = netdev->priv;
 	unsigned int first;
 	unsigned int tx_flags = 0;
+	unsigned long flags;
 	int count;
 
 	if(skb->len <= 0) {
@@ -1779,10 +1781,13 @@ e1000_xmit_frame(struct sk_buff *skb, st
 		return 0;
 	}
 
+	spin_lock_irqsave(&adapter->tx_lock, flags);
+
 	if(adapter->hw.mac_type == e1000_82547) {
 		if(e1000_82547_fifo_workaround(adapter, skb)) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
+			spin_unlock_irqrestore(&adapter->tx_lock, flags);
 			return 1;
 		}
 	}
@@ -1803,11 +1808,14 @@ e1000_xmit_frame(struct sk_buff *skb, st
 		e1000_tx_queue(adapter, count, tx_flags);
 	else {
 		netif_stop_queue(netdev);
+		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
 	}
 
 	netdev->trans_start = jiffies;
 
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+	
 	return 0;
 }
 
@@ -2160,6 +2168,8 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	unsigned int i, eop;
 	boolean_t cleaned = FALSE;
 
+	spin_lock(&adapter->tx_lock);
+
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->buffer_info[i].next_to_watch;
 	eop_desc = E1000_TX_DESC(*tx_ring, eop);
@@ -2204,6 +2214,8 @@ e1000_clean_tx_irq(struct e1000_adapter 
 	if(cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
 		netif_wake_queue(netdev);
 
+	spin_unlock(&adapter->tx_lock);
+
 	return cleaned;
 }
 
