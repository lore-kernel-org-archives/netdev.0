From: Andi Kleen <ak@suse.de>
Subject: [PATCH] LLTX for tg3
Date: Tue, 7 Sep 2004 14:18:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040907121841.GA4398@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Add LLTX suppor to tg3.  Locking was already safe for it, so only
trivial changes.

Depends on the LLTX patch sent earlier.

diff -u linux-2.6.8/drivers/net/tg3.c-o linux-2.6.8/drivers/net/tg3.c
--- linux-2.6.8/drivers/net/tg3.c-o	2004-09-04 13:10:46.000000000 +0000
+++ linux-2.6.8/drivers/net/tg3.c	2004-09-07 08:17:36.000000000 +0000
@@ -3036,7 +3036,11 @@
 	 * So we really do need to disable interrupts when taking
 	 * tx_lock here.
 	 */
-	spin_lock_irqsave(&tp->tx_lock, flags);
+	local_irq_save(flags);
+	if (!spin_trylock(&tp->tx_lock)) { 
+		local_irq_restore(flags);
+		return -1; 
+	} 
 
 	/* This is a hard error, log it. */
 	if (unlikely(TX_BUFFS_AVAIL(tp) <= (skb_shinfo(skb)->nr_frags + 1))) {
@@ -8255,6 +8259,7 @@
 
 	if (pci_using_dac)
 		dev->features |= NETIF_F_HIGHDMA;
+	dev->features |= NETIF_F_LLTX;
 #if TG3_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = tg3_vlan_rx_register;
