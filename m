From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] pch_gbe: fix transmit races
Date: Mon, 14 May 2012 21:26:06 +0200
Message-ID: <1337023566.8512.622.camel@edumazet-glaptop>
References: <40680C535D6FE6498883F1640FACD44DDF9105@ka-exchange-1.kontronamerica.local>
	 <1336770777.31653.283.camel@edumazet-glaptop>
	 <1336774254.31653.287.camel@edumazet-glaptop>
	 <40680C535D6FE6498883F1640FACD44DDF93F1@ka-exchange-1.kontronamerica.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andy Cress <andy.cress@us.kontron.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33357 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757673Ab2ENT0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2012 15:26:11 -0400
Received: by bkcji2 with SMTP id ji2so4150147bkc.19
        for <netdev@vger.kernel.org>; Mon, 14 May 2012 12:26:10 -0700 (PDT)
In-Reply-To: <40680C535D6FE6498883F1640FACD44DDF93F1@ka-exchange-1.kontronamerica.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andy reported pch_gbe triggered "NETDEV WATCHDOG" errors.

May 11 11:06:09 kontron kernel: WARNING: at net/sched/sch_generic.c:261
dev_watchdog+0x1ec/0x200() (Not tainted)
May 11 11:06:09 kontron kernel: Hardware name: N/A
May 11 11:06:09 kontron kernel: NETDEV WATCHDOG: eth0 (pch_gbe):
transmit queue 0 timed out

It seems pch_gbe has a racy tx path (races with TX completion path)

Remove tx_queue_lock lock since it has no purpose, we must use tx_lock
instead.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Andy Cress <andy.cress@us.kontron.com>
Tested-by: Andy Cress <andy.cress@us.kontron.com>
---

patch rebased on net tree.

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h      |    2 
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |   25 ++++------
 2 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index dd14915..ba78174 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -584,7 +584,6 @@ struct pch_gbe_hw_stats {
 /**
  * struct pch_gbe_adapter - board specific private data structure
  * @stats_lock:	Spinlock structure for status
- * @tx_queue_lock:	Spinlock structure for transmit
  * @ethtool_lock:	Spinlock structure for ethtool
  * @irq_sem:		Semaphore for interrupt
  * @netdev:		Pointer of network device structure
@@ -609,7 +608,6 @@ struct pch_gbe_hw_stats {
 
 struct pch_gbe_adapter {
 	spinlock_t stats_lock;
-	spinlock_t tx_queue_lock;
 	spinlock_t ethtool_lock;
 	atomic_t irq_sem;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 8035e5f..1e38d50 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -640,14 +640,11 @@ static void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
  */
 static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter)
 {
-	int size;
-
-	size = (int)sizeof(struct pch_gbe_tx_ring);
-	adapter->tx_ring = kzalloc(size, GFP_KERNEL);
+	adapter->tx_ring = kzalloc(sizeof(*adapter->tx_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
 		return -ENOMEM;
-	size = (int)sizeof(struct pch_gbe_rx_ring);
-	adapter->rx_ring = kzalloc(size, GFP_KERNEL);
+
+	adapter->rx_ring = kzalloc(sizeof(*adapter->rx_ring), GFP_KERNEL);
 	if (!adapter->rx_ring) {
 		kfree(adapter->tx_ring);
 		return -ENOMEM;
@@ -1162,7 +1159,6 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 	struct sk_buff *tmp_skb;
 	unsigned int frame_ctrl;
 	unsigned int ring_num;
-	unsigned long flags;
 
 	/*-- Set frame control --*/
 	frame_ctrl = 0;
@@ -1211,14 +1207,14 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 			}
 		}
 	}
-	spin_lock_irqsave(&tx_ring->tx_lock, flags);
+
 	ring_num = tx_ring->next_to_use;
 	if (unlikely((ring_num + 1) == tx_ring->count))
 		tx_ring->next_to_use = 0;
 	else
 		tx_ring->next_to_use = ring_num + 1;
 
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+
 	buffer_info = &tx_ring->buffer_info[ring_num];
 	tmp_skb = buffer_info->skb;
 
@@ -1518,7 +1514,7 @@ pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
 						&rx_ring->rx_buff_pool_logic,
 						GFP_KERNEL);
 	if (!rx_ring->rx_buff_pool) {
-		pr_err("Unable to allocate memory for the receive poll buffer\n");
+		pr_err("Unable to allocate memory for the receive pool buffer\n");
 		return -ENOMEM;
 	}
 	memset(rx_ring->rx_buff_pool, 0, size);
@@ -1637,15 +1633,17 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	pr_debug("called pch_gbe_unmap_and_free_tx_resource() %d count\n",
 		 cleaned_count);
 	/* Recover from running out of Tx resources in xmit_frame */
+	spin_lock(&tx_ring->tx_lock);
 	if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev)))) {
 		netif_wake_queue(adapter->netdev);
 		adapter->stats.tx_restart_count++;
 		pr_debug("Tx wake queue\n");
 	}
-	spin_lock(&adapter->tx_queue_lock);
+
 	tx_ring->next_to_clean = i;
-	spin_unlock(&adapter->tx_queue_lock);
+
 	pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
+	spin_unlock(&tx_ring->tx_lock);
 	return cleaned;
 }
 
@@ -2037,7 +2035,6 @@ static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
 		return -ENOMEM;
 	}
 	spin_lock_init(&adapter->hw.miim_lock);
-	spin_lock_init(&adapter->tx_queue_lock);
 	spin_lock_init(&adapter->stats_lock);
 	spin_lock_init(&adapter->ethtool_lock);
 	atomic_set(&adapter->irq_sem, 0);
@@ -2142,10 +2139,10 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			 tx_ring->next_to_use, tx_ring->next_to_clean);
 		return NETDEV_TX_BUSY;
 	}
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 
 	/* CRC,ITAG no support */
 	pch_gbe_tx_queue(adapter, tx_ring, skb);
+	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
