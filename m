From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (7/8) arlan -- more dead wood removal
Date: Thu, 25 Sep 2003 15:59:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925155907.21c314ee.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Still more driver data which was updated but never used.


diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Thu Sep 25 15:48:19 2003
+++ b/drivers/net/wireless/arlan-main.c	Thu Sep 25 15:48:19 2003
@@ -411,7 +411,6 @@
 				WRITESHMB(arlan->commandByte, ARLAN_COM_TX_ENABLE | ARLAN_COM_INT);
 				memcpy_toio((void *) arlan->commandParameter, &TXLAST(dev), 14);
 //				for ( i=1 ; i < 15 ; i++) printk("%02x:",READSHMB(arlan->commandParameter[i]));
-				priv->last_command_was_rx = 0;
 				priv->tx_last_sent = jiffies;
 				arlan_interrupt_lancpu(dev);
 				priv->last_tx_time = arlan_time();
@@ -765,7 +764,6 @@
 
 	arlan_command(dev, ARLAN_COMMAND_TX);
 
-	priv->last_command_was_rx = 0;
 	priv->tx_last_sent = jiffies;
 
 	IFDEBUG(ARLAN_DEBUG_TX_CHAIN) printk("%s TX Qued %d bytes \n", dev->name, length);
@@ -1233,7 +1231,6 @@
 	priv->rx_command_given = 0;
 	
 	priv->reRegisterExp = 1;
-	priv->last_command_was_rx = 0;
 	priv->tx_last_sent = jiffies - 1;
 	priv->tx_last_cleared = jiffies;
 	priv->Conf->writeEEPROM = 0;
@@ -1680,7 +1677,6 @@
 
 		if (rxStatus == 0 && txStatus == 0)
 		{
-			priv->last_command_was_rx = 0;
 			if (priv->irq_test_done)
 			{
 				if (!registrationBad(dev))
@@ -1707,7 +1703,6 @@
 		}
 		if (rxStatus > 2 && rxStatus < 0xff)
 		{
-			priv->last_command_was_rx = 0;
 			WRITESHMB(arlan->rxStatus, 0x00);
 			printk(KERN_ERR "%s unknown rxStatus reason tx %d rx %d ",
 				dev->name, txStatus, rxStatus);
@@ -1715,7 +1710,6 @@
 		}
 		if (rxStatus == 0xff)
 		{
-			priv->last_command_was_rx = 0;
 			WRITESHMB(arlan->rxStatus, 0x00);
 			arlan_command(dev, ARLAN_COMMAND_RX);
 			if (registrationBad(dev))
diff -Nru a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
--- a/drivers/net/wireless/arlan.h	Thu Sep 25 15:48:19 2003
+++ b/drivers/net/wireless/arlan.h	Thu Sep 25 15:48:19 2003
@@ -337,10 +337,7 @@
       struct net_device_stats stats;
       struct arlan_shmem * card;
       struct arlan_shmem * conf;
-      struct TxParam txParam;      
-      int multicastLength;
-      char  multicastList[ARLAN_MAX_MULTICAST_ADDRS][6];
-      int promiscModeEnabled;
+
       struct arlan_conf_stru * Conf;	     
       int	bad;
       int 	reset;
@@ -353,16 +350,13 @@
       int registrationLostCount;
       int reRegisterExp;
       int irq_test_done;
-      int last_command_was_rx;
+
       struct TxParam txRing[TX_RING_SIZE];
       char reTransmitBuff[0x800];
       volatile int txLast;
-      volatile int txNew;
       volatile char ReTransmitRequested;
       volatile unsigned long tx_done_delayed;
       volatile long long registrationLastSeen;
-      volatile char under_command;
-      volatile char under_toggle;
       volatile long long tx_last_sent;
       volatile long long tx_last_cleared;
       volatile int 	retransmissions;
@@ -477,13 +471,11 @@
 #define arlan_interrupt_lancpu(dev) {\
    int cr;   \
    \
-   priv->under_toggle++;   \
    cr = readControlRegister(dev);\
    if (cr & ARLAN_CHANNEL_ATTENTION){ \
       writeControlRegister(dev, (cr & ~ARLAN_CHANNEL_ATTENTION));\
    }else  \
       writeControlRegister(dev, (cr | ARLAN_CHANNEL_ATTENTION));\
-   priv->under_toggle=0;     \
 }
 
 #define clearChannelAttention(dev){ \
