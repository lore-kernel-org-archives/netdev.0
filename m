From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000 - get rid of tx_lock
Date: Wed, 9 Jun 2004 14:41:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040609144120.1655eee0@dell_ss3.pdx.osdl.net>
References: <20040608102729.620dd1fc@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeb Cramer <cramerj@intel.com>, John Ronciak <john.ronciak@intel.com>,
        Ganesh Venkatesan <ganesh.venkatesan@intel.com>
In-Reply-To: <20040608102729.620dd1fc@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The e1000 driver has an tx_lock which unneeded.  It is only used to protect
the start/stop queue flags which are already handled by doing atomic bit operations.
Also netif_wake_queue uses test_and_clear_bit so testing for stopped before
calling it is unnecessary.

Surprisingly, without this change the additional overhead causes my system
to transmit timeout and never recover when using NAPI.  With the tx_lock removed,
the ring doesn't fill and lockup. 

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
--- a/drivers/net/e1000/e1000.h	2004-06-09 14:35:23 -07:00
+++ b/drivers/net/e1000/e1000.h	2004-06-09 14:35:23 -07:00
@@ -208,7 +208,6 @@
 
 	/* TX */
 	struct e1000_desc_ring tx_ring;
-	spinlock_t tx_lock;
 	uint32_t txd_cmd;
 	uint32_t tx_int_delay;
 	uint32_t tx_abs_int_delay;
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	2004-06-09 14:35:23 -07:00
+++ b/drivers/net/e1000/e1000_main.c	2004-06-09 14:35:23 -07:00
@@ -691,7 +691,6 @@
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
-	spin_lock_init(&adapter->tx_lock);
 
 	return 0;
 }
@@ -1733,7 +1732,6 @@
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
-	unsigned long flags;
 	unsigned int len = skb->len;
 	int count = 0;
 	unsigned int mss = 0;
@@ -1777,15 +1775,12 @@
 	if(adapter->pcix_82544)
 		count += nr_frags;
 	
-	spin_lock_irqsave(&adapter->tx_lock, flags);
 	/* need: count +  2 desc gap to keep tail from touching 
 	 * head, otherwise try next time */
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2 ) {
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
 	}
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 
 	if(adapter->hw.mac_type == e1000_82547) {
 		if(e1000_82547_fifo_workaround(adapter, skb)) {
@@ -2208,12 +2203,8 @@
 
 	tx_ring->next_to_clean = i;
 
-	spin_lock(&adapter->tx_lock);
-
-	if(cleaned && netif_queue_stopped(netdev) && netif_carrier_ok(netdev))
+	if(cleaned)
 		netif_wake_queue(netdev);
-
-	spin_unlock(&adapter->tx_lock);
 
 	return cleaned;
 }
