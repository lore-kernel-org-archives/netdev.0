From: Andi Kleen <ak@muc.de>
Subject: [PATCH] Add NETIF_F_LLTX to e1000 driver
Date: Tue, 31 Aug 2004 14:46:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m34qmjjx10.fsf@averell.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        cramerj@intel.com, john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch adds NETIF_F_LLTX to the e1000 driver.  With this
the driver can take one lock less in the TX path.

It will do a try lock on the tx_lock now and bail out when the lock is
already locked. I extended the use of tx_lock a bit to protect some
data structures that were previously only protected by the xmit_lock.
I also added taking of tx_lock to the set_multicast_list to
prevent any potential races here.

It requires the lltx patch I sent before to netdev applied first.

-Andi

diff -u linux-2.6.8-work/drivers/net/e1000/e1000_main.c-o linux-2.6.8-work/drivers/net/e1000/e1000_main.c
--- linux-2.6.8-work/drivers/net/e1000/e1000_main.c-o	2004-07-27 14:44:07.000000000 +0200
+++ linux-2.6.8-work/drivers/net/e1000/e1000_main.c	2004-08-31 14:43:43.000000000 +0200
@@ -486,6 +486,9 @@
 #endif
 #endif
 
+	/* hard_start_xmit is safe against parallel locking */
+	netdev->features |= NETIF_F_LLTX; 
+
 	if(pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
@@ -1259,9 +1262,12 @@
 	uint32_t rctl;
 	uint32_t hash_value;
 	int i;
+	unsigned long flags;
 
 	/* Check for Promiscuous and All Multicast modes */
 
+	spin_lock_irqsave(&adapter->tx_lock, flags);
+
 	rctl = E1000_READ_REG(hw, RCTL);
 
 	if(netdev->flags & IFF_PROMISC) {
@@ -1310,6 +1316,8 @@
 
 	if(hw->mac_type == e1000_82542_rev2_0)
 		e1000_leave_82542_rst(adapter);
+
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 }
 
 /* need to wait a few seconds after link up to get diagnostic information from the phy */
@@ -1785,7 +1793,13 @@
 	if(adapter->pcix_82544)
 		count += nr_frags;
 	
-	spin_lock_irqsave(&adapter->tx_lock, flags);
+	local_irq_save(flags); 
+	if (!spin_trylock(&adapter->tx_lock)) { 
+		/* Collision - tell upper layer to requeue */ 
+		local_irq_restore(flags); 
+		return -1; 
+	} 
+
 	/* need: count +  2 desc gap to keep tail from touching 
 	 * head, otherwise try next time */
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2 ) {
@@ -1793,11 +1807,11 @@
 		spin_unlock_irqrestore(&adapter->tx_lock, flags);
 		return 1;
 	}
-	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 
 	if(adapter->hw.mac_type == e1000_82547) {
 		if(e1000_82547_fifo_workaround(adapter, skb)) {
 			netif_stop_queue(netdev);
+			spin_unlock_irqrestore(&adapter->tx_lock, flags);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
 			return 1;
 		}
@@ -1821,6 +1835,7 @@
 
 	netdev->trans_start = jiffies;
 
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return 0;
 }
 
