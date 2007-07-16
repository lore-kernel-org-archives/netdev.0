From: "Alexandre Bounine" <Alexandre.Bounine@tundra.com>
Subject: [PATCH] Fix Tsi108 ethernet driver performance
Date: Mon, 16 Jul 2007 13:36:13 -0400
Message-ID: <1B5F013528140F45B5C671039279CA5701F834BB@NANUK.pc.tundra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: <jgarzik@pobox.com>, <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-class: urn:content-classes:message
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

From: Alexandre Bounine <alexandreb@tundra.com>

This patch improves performance of the Tsi108 Ethernet driver by
changing interrupt handling for frame receive path. It reduces number of
interrupts generated for received frames and therefore lowers CPU
utilization by the device driver.
   
Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>

---

diff -Nurp linux-2.6.22-hpc2/drivers/net/tsi108_eth.c
linux-2.6.22-tun/drivers/net/tsi108_eth.c
--- linux-2.6.22-hpc2/drivers/net/tsi108_eth.c	2007-07-08
19:32:17.000000000 -0400
+++ linux-2.6.22-tun/drivers/net/tsi108_eth.c	2007-07-12
16:55:50.000000000 -0400
@@ -58,6 +58,7 @@
 #define MII_READ_DELAY 10000	/* max link wait time in msec */
 
 #define TSI108_RXRING_LEN     256
+#define TSI108_RX_INT_FREQ    32
 
 /* NOTE: The driver currently does not support receiving packets
  * larger than the buffer size, so don't decrease this (unless you
@@ -69,8 +70,10 @@
 
 #define TSI108_TX_INT_FREQ    64
 
-/* Check the phy status every half a second. */
-#define CHECK_PHY_INTERVAL (HZ/2)
+/* Timer interval to check the RX queue status */
+#define CHECK_RX_INTERVAL	(HZ/50)
+/* Timer interval to check the PHY status */
+#define CHECK_PHY_INTERVAL	(CHECK_RX_INTERVAL * 10)
 
 static int tsi108_init_one(struct platform_device *pdev);
 static int tsi108_ether_remove(struct platform_device *pdev);
@@ -104,6 +107,7 @@ struct tsi108_prv_data {
 	unsigned int txfree;
 
 	unsigned int phy_ok;		/* The PHY is currently powered
on. */
+	unsigned int phy_chk_count;
 
 	/* PHY status (duplex is 1 for half, 2 for full,
 	 * so that the default 0 indicates that neither has
@@ -823,7 +827,10 @@ static int tsi108_refill_rx(struct net_d
 		 */
 
 		data->rxring[rx].blen = TSI108_RX_SKB_SIZE;
-		data->rxring[rx].misc = TSI108_RX_OWN | TSI108_RX_INT;
+		if (rx % TSI108_RX_INT_FREQ)
+			data->rxring[rx].misc = TSI108_RX_OWN;
+		else
+			data->rxring[rx].misc = TSI108_RX_OWN |
TSI108_RX_INT;
 
 		data->rxhead = (data->rxhead + 1) % TSI108_RXRING_LEN;
 		data->rxfree++;
@@ -973,24 +980,22 @@ static void tsi108_rx_int(struct net_dev
 	}
 }
 
-/* If the RX ring has run out of memory, try periodically
- * to allocate some more, as otherwise poll would never
- * get called (apart from the initial end-of-queue condition).
- *
- * This is called once per second (by default) from the thread.
+/* tsi108_check_rxring() is used to periodically check if the RX ring
has
+ * pending frames that have not been reported by RX interrupt (due to
interrupt
+ * moderation). It is called with CHECK_RX_INTERVAL timer interval.
  */
 
 static void tsi108_check_rxring(struct net_device *dev)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
+	unsigned int rx = data->rxtail;
 
-	/* A poll is scheduled, as opposed to caling tsi108_refill_rx
-	 * directly, so as to keep the receive path single-threaded
-	 * (and thus not needing a lock).
-	 */
-
-	if (netif_running(dev) && data->rxfree < TSI108_RXRING_LEN / 4)
+	/* Schedule a poll (if required) */
+	if (netif_running(dev) &&
+	    0 == (data->rxring[rx].misc & TSI108_RX_OWN)) {
+		data->rxpending = 1;
 		tsi108_rx_int(dev);
+	}
 }
 
 static void tsi108_tx_int(struct net_device *dev)
@@ -1295,6 +1300,7 @@ static void tsi108_init_phy(struct net_d
 
 	printk(KERN_DEBUG "PHY_STAT reg contains %08x\n", phyval);
 	data->phy_ok = 1;
+	data->phy_chk_count = 0;
 	data->init_media = 1;
 	spin_unlock_irqrestore(&phy_lock, flags);
 }
@@ -1664,9 +1670,12 @@ static void tsi108_timed_checker(unsigne
 	struct net_device *dev = (struct net_device *)dev_ptr;
 	struct tsi108_prv_data *data = netdev_priv(dev);
 
-	tsi108_check_phy(dev);
+	/* We assume that RX queue is checked more often than PHY status
*/
+	if (data->phy_chk_count++ == 0)
+		tsi108_check_phy(dev);
 	tsi108_check_rxring(dev);
-	mod_timer(&data->timer, jiffies + CHECK_PHY_INTERVAL);
+	data->phy_chk_count %= (CHECK_PHY_INTERVAL/CHECK_RX_INTERVAL);
+	mod_timer(&data->timer, jiffies + CHECK_RX_INTERVAL);
 }
 
 static int tsi108_ether_init(void)



---

Important Notice: This message is intended for the use of the individual to whom it is addressed and may contain information which is privileged, confidential and/or exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, or is not the employee or agent responsible for delivering the message to the intended recipient, you are hereby notified that any dissemination, distribution, or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by telephone or return e-mail and delete the original message from your systems. Thank you. 
