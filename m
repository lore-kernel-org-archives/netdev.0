From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000 - avoid filling tx ring completely.
Date: Wed, 22 Sep 2004 16:05:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922160533.64f25d12@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeb Cramer <cramerj@intel.com>, John Ronciak <john.ronciak@intel.com>,
        Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

With the current driver and the default transmit ring size, it is easy to
get the ring to fill. When this happens the way the current e1000 driver responds
is to return TX_BUSY.  This works but is sub-optimal and requires the network
scheduler to requeue the packet.

The following patch adds a test to see if there is space left in the ring, and
stops the network queue just before it fills.  When the tx intr (or cleanup
via NAPI) occurs, then the queue is re-enabled. There is a tradeoff here,
the check causes the last 11 elements in the ring to not be used but avoids
an unnecessary send/requeue.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-09-22 14:53:16.492728880 -0700
+++ test-2.6/drivers/net/e1000/e1000_main.c	2004-09-22 14:55:09.780506520 -0700
@@ -1811,7 +1811,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
-	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
+	if(unlikely(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2)) {
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return NETDEV_TX_BUSY;
@@ -1844,6 +1844,10 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	netdev->trans_start = jiffies;
 
+	/* Make sure there is space in the ring for the next send. */
+	if (E1000_DESC_UNUSED(&adapter->tx_ring) < MAX_SKB_FRAGS + 2) 
+		netif_stop_queue(netdev);
+
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
