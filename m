From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc1-mm4 1/4] r8169: miscalculation of available Tx descriptors
Date: Fri, 10 Sep 2004 00:45:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909224539.GA9629@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The count of available entries in the Tx descriptors ring is badly wrong.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-130 drivers/net/r8169.c
--- linux-2.6.9-rc1/drivers/net/r8169.c~r8169-130	2004-09-08 22:02:35.000000000 +0200
+++ linux-2.6.9-rc1-fr/drivers/net/r8169.c	2004-09-08 22:02:35.000000000 +0200
@@ -77,6 +77,9 @@ VERSION 1.6LK	<2004/04/14>
 #define dprintk(fmt, args...)	do {} while (0)
 #endif /* RTL8169_DEBUG */
 
+#define TX_BUFFS_AVAIL(tp) \
+	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
+
 #ifdef CONFIG_R8169_NAPI
 #define rtl8169_rx_skb			netif_receive_skb
 #define rtl8169_rx_hwaccel_skb		vlan_hwaccel_rx
@@ -1766,8 +1769,7 @@ static int rtl8169_start_xmit(struct sk_
 	u32 status, len;
 	u32 opts1;
 	
-	if (unlikely(tp->cur_tx - tp->dirty_tx < skb_shinfo(skb)->nr_frags)) {
-		netif_stop_queue(dev);
+	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
 		printk(KERN_ERR PFX "%s: BUG! Tx Ring full when queue awake!\n",
 		       dev->name);
 		return 1;
@@ -1816,10 +1818,10 @@ static int rtl8169_start_xmit(struct sk_
 
 	RTL_W8(TxPoll, 0x40);	//set polling bit
 
-	if (tp->cur_tx - tp->dirty_tx < MAX_SKB_FRAGS) {
+	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
 		smp_rmb();
-		if (tp->cur_tx - tp->dirty_tx >= MAX_SKB_FRAGS)
+		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
 			netif_wake_queue(dev);
 	}
 
@@ -1874,8 +1876,10 @@ rtl8169_tx_interrupt(struct net_device *
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
 		smp_wmb();
-		if (netif_queue_stopped(dev))
+		if (netif_queue_stopped(dev) &&
+		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
+		}
 	}
 }
 

_
