From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (5/8) arlan -- more set never used elements
Date: Thu, 25 Sep 2003 15:59:59 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925155959.7f95e824.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Still more places state is saved and never used.

diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:55:21 2003
+++ b/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:55:21 2003
@@ -156,7 +156,6 @@
 		TXHEAD(dev).offset = 0;
 		TXTAIL(dev).offset = 0;
 		priv->txLast = 0;
-		priv->txOffset = 0;
 		priv->bad = 0;
 		if (!priv->under_reset && !priv->under_config)
 			netif_wake_queue (dev);
@@ -549,7 +548,6 @@
 		}
 		else
 			IFDEBUG(ARLAN_DEBUG_TX_CHAIN) printk(KERN_ERR "ReTransmit buff empty");
-		priv->txOffset = 0;
 		netif_wake_queue (dev);
 		return;
 
@@ -575,10 +573,6 @@
 	int bh_mark_needed = 0;
 	int next_tick = 1;
 
-
-	priv->timer_chain_active = 1;
-
-
 	if (registrationBad(dev))
 	{
 		//debug=100;
@@ -643,7 +637,6 @@
 		}
 		if (!(TXHEAD(dev).offset && TXTAIL(dev).offset))
 		{
-			priv->txOffset = 0;
 			netif_wake_queue (dev);
 		}
 		priv->tx_done_delayed = 0;
@@ -651,7 +644,6 @@
 	}
 	if (bh_mark_needed)
 	{
-		priv->txOffset = 0;
 		netif_wake_queue (dev);
 	}
 	arlan_process_interrupt(dev);
@@ -659,7 +651,6 @@
 	if (next_tick < priv->card_polling_interval)
 		next_tick = priv->card_polling_interval;
 
-	priv->timer_chain_active = 0;
 	priv->timer.expires = jiffies + next_tick;
 
 	add_timer(&priv->timer);
@@ -1245,7 +1236,6 @@
 	priv->reset = 0;
 	memcpy_fromio(dev->dev_addr, arlan->lanCardNodeId, 6);
 	memset(dev->broadcast, 0xff, 6);
-	priv->txOffset = 0;
 	dev->tx_queue_len = tx_queue_len;
 	priv->interrupt_processing_active = 0;
 	priv->command_lock = 0;
@@ -1291,7 +1281,6 @@
 
 static int arlan_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arlan_private *priv = dev->priv;
 	short length;
 	unsigned char *buf;
 
@@ -1300,7 +1289,7 @@
 	length = ETH_ZLEN < skb->len ? skb->len : ETH_ZLEN;
 	buf = skb->data;
 
-	if (priv->txOffset + length + 0x12 > 0x800) {
+	if (length + 0x12 > 0x800) {
 		printk(KERN_ERR "TX RING overflow \n");
 		netif_stop_queue (dev);
 	}
@@ -1313,13 +1302,11 @@
 	dev_kfree_skb(skb);
 
 	arlan_process_interrupt(dev);
-	priv->tx_chain_active = 0;
 	ARLAN_DEBUG_EXIT("arlan_tx");
 	return 0;
 
 bad_end:
 	arlan_process_interrupt(dev);
-	priv->tx_chain_active = 0;
 	netif_stop_queue (dev);
 	ARLAN_DEBUG_EXIT("arlan_tx");
 	return 1;
@@ -1417,7 +1404,6 @@
 				}
 				if (!TXHEAD(dev).offset || !TXTAIL(dev).offset)
 				{
-					priv->txOffset = 0;
 					netif_wake_queue (dev);
 				}
 			}
diff -Nru a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
--- a/drivers/net/wireless/arlan.h	Thu Sep 25 14:55:21 2003
+++ b/drivers/net/wireless/arlan.h	Thu Sep 25 14:55:21 2003
@@ -358,7 +358,6 @@
       char reTransmitBuff[0x800];
       volatile int txLast;
       volatile int txNew;
-      volatile int txOffset;
       volatile char ReTransmitRequested;
       volatile unsigned long tx_done_delayed;
       volatile long long registrationLastSeen;
@@ -367,8 +366,6 @@
       volatile long long tx_last_sent;
       volatile long long tx_last_cleared;
       volatile int 	retransmissions;
-      volatile int	tx_chain_active;
-      volatile int 	timer_chain_active;
       volatile int 	interrupt_ack_requested;
       volatile long	command_lock;
       volatile int	rx_command_needed;
