From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/8) arlan -- get rid of some dead wood
Date: Thu, 25 Sep 2003 15:59:34 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925155934.21697d56.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This code is littered with unused structure elements and globals.
Eliminate some of the fields set and never used.

More in later patches.

diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:32:55 2003
+++ b/drivers/net/wireless/arlan-main.c	Thu Sep 25 14:32:55 2003
@@ -16,15 +16,12 @@
 static const char *arlan_version = "C.Jennigs 97 & Elmer.Joandi@ut.ee  Oct'98, http://www.ylenurme.ee/~elmer/655/";
 
 struct net_device *arlan_device[MAX_ARLANS];
-int last_arlan;
 
 static int SID = SIDUNKNOWN;
 static int radioNodeId = radioNodeIdUNKNOWN;
 static char encryptionKey[12] = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
-static char *siteName = siteNameUNKNOWN;
 static int mem = memUNKNOWN;
 int arlan_debug = debugUNKNOWN;
-static int probe = probeUNKNOWN;
 static int numDevices = numDevicesUNKNOWN;
 static int spreadingCode = spreadingCodeUNKNOWN;
 static int channelNumber = channelNumberUNKNOWN;
@@ -34,7 +31,6 @@
 static int keyStart;
 static int tx_delay_ms;
 static int retries = 5;
-static int async = 1;
 static int tx_queue_len = 1;
 static int arlan_EEPROM_bad;
 
@@ -91,16 +87,8 @@
 MODULE_PARM_DESC(arlan_entry_and_exit_debug, "(ignored)");
 #endif
 
-//        #warning kernel 2.1.110 tested
-#define myATOMIC_INIT(a,b) atomic_set(&(a),b)
-
 #else
 #define test_and_set_bit	set_bit
-#if LINUX_VERSION_CODE != 0x20024
- //        #warning kernel  2.0.36  tested
-#endif
-#define myATOMIC_INIT(a,b) a = b;
-
 #endif
 
 struct arlan_conf_stru arlan_conf[MAX_ARLANS];
@@ -120,7 +108,6 @@
 static  void	arlan_rx_interrupt		(struct net_device * dev, u_char rxStatus, u_short, u_short);
 static  void	arlan_process_interrupt		(struct net_device * dev);
 static	void	arlan_tx_timeout		(struct net_device *dev);
-int	arlan_command(struct net_device * dev, int command);
 
 static inline long long arlan_time(void)
 {
@@ -154,32 +141,6 @@
         clearClearInterrupt(dev);\
         setClearInterrupt(dev);
 
-
-#define ARLAN_COMMAND_LOCK(dev) \
-	if (atomic_dec_and_test(&((struct arlan_private * )dev->priv)->card_users))\
-   		arlan_wait_command_complete_short(dev,__LINE__);
-#define ARLAN_COMMAND_UNLOCK(dev) \
-	atomic_inc(&((struct arlan_private * )dev->priv)->card_users);
-
-
-#define ARLAN_COMMAND_INC(dev) \
- 	{((struct arlan_private *) dev->priv)->under_command++;}
-#define ARLAN_COMMAND_ZERO(dev) \
- 	{((struct arlan_private *) dev->priv)->under_command =0;}
-#define ARLAN_UNDER_COMMAND(dev)\
-	(((struct arlan_private *) dev->priv)->under_command)
-
-#define ARLAN_COMMAND_START(dev) ARLAN_COMMAND_INC(dev)
-#define ARLAN_COMMAND_END(dev) ARLAN_COMMAND_ZERO(dev)
-#define ARLAN_TOGGLE_START(dev)\
- 	{((struct arlan_private *) dev->priv)->under_toggle++;}
-#define ARLAN_TOGGLE_END(dev)\
- 	{((struct arlan_private *) dev->priv)->under_toggle=0;}
-#define ARLAN_UNDER_TOGGLE(dev)\
- 	(((struct arlan_private *) dev->priv)->under_toggle)
-
-
-
 static inline int arlan_drop_tx(struct net_device *dev)
 {
 	struct arlan_private *priv = ((struct arlan_private *) dev->priv);
@@ -366,7 +327,6 @@
 		WRITESHM(arlan->resetFlag, 0xff, u_char);
 		clearChannelAttention(dev);
 		clearHardwareReset(dev);
-		priv->numResets++;
 		priv->card_polling_interval = HZ / 4;
 		priv->waiting_command_mask &= ~ARLAN_COMMAND_RESET;
 		priv->waiting_command_mask |= ARLAN_COMMAND_INT_RACK;
@@ -597,8 +557,6 @@
 	}
 	arlan_command(dev, ARLAN_COMMAND_TX);
 
-	priv->nof_tx++;
-
 	priv->Conf->driverRetransmissions++;
 	priv->retransmissions++;
 
@@ -796,6 +754,7 @@
 		IFDEBUG(ARLAN_DEBUG_TX_CHAIN)
 			printk(KERN_ERR "TX TAIL & HEAD full, return, tailStart %d headEnd %d\n", tailStarts, headEnds);
 	}
+
 	priv->out_bytes += length;
 	priv->out_bytes10 += length;
 	if (conf->measure_rate < 1)
@@ -833,7 +792,6 @@
 
 	priv->last_command_was_rx = 0;
 	priv->tx_last_sent = jiffies;
-	priv->nof_tx++;
 
 	IFDEBUG(ARLAN_DEBUG_TX_CHAIN) printk("%s TX Qued %d bytes \n", dev->name, length);
 
@@ -1029,7 +987,6 @@
 	conf->siteName[16] = '\0';
 	conf->retries = retries;
 	conf->tx_delay_ms = tx_delay_ms;
-	conf->async = async;
 	conf->ReTransmitPacketMaxSize = 200;
 	conf->waitReTransmitPacketMaxSize = 200;
 	conf->txAckTimeoutMs = 900;
@@ -1284,7 +1241,6 @@
 	priv->bad = 0;
 	priv->lastReset = 0;
 	priv->reset = 0;
-	priv->open_time = jiffies;
 	memcpy_fromio(dev->dev_addr, arlan->lanCardNodeId, 6);
 	memset(dev->broadcast, 0xff, 6);
 	priv->txOffset = 0;
@@ -1294,8 +1250,6 @@
 
 	netif_start_queue (dev);
 
-	init_MUTEX(&priv->card_lock);
-	myATOMIC_INIT(priv->card_users, 1);	/* damn 2.0.33 */
 	priv->registrationLostCount = 0;
 	priv->registrationLastSeen = jiffies;
 	priv->txLast = 0;
@@ -1303,8 +1257,6 @@
 	priv->rx_command_given = 0;
 	
 	priv->reRegisterExp = 1;
-	priv->nof_tx = 0;
-	priv->nof_tx_ack = 0;
 	priv->last_command_was_rx = 0;
 	priv->tx_last_sent = jiffies - 1;
 	priv->tx_last_cleared = jiffies;
@@ -1435,7 +1387,6 @@
 
 	priv->tx_last_cleared = jiffies;
 	priv->tx_command_given = 0;
-	priv->nof_tx_ack++;
 	switch (status)
 	{
 		case 1:
@@ -1876,7 +1827,6 @@
 	IFDEBUG(ARLAN_DEBUG_STARTUP)
 		printk(KERN_NOTICE "%s: Closing device\n", dev->name);
 
-	priv->open_time = 0;
 	netif_stop_queue(dev);
 	free_irq(dev->irq, dev);
 
@@ -1969,9 +1919,6 @@
 		return -ENODEV;
 
 	arlans_found++;
-
-	if (arlans_found == 1)
-		siteName = kmalloc(100, GFP_KERNEL);
 	return 0;
 }
 
@@ -2007,10 +1954,6 @@
 	numDevices = arlan_find_devices();
 	if (numDevices == 0)
 		return -ENODEV;
-
-	siteName = kmalloc(100, GFP_KERNEL);
-	if(siteName==NULL)
-		return -ENOMEM;
 
 	for (i = 0; i < numDevices && i < MAX_ARLANS; i++)
 	{
diff -Nru a/drivers/net/wireless/arlan-proc.c b/drivers/net/wireless/arlan-proc.c
--- a/drivers/net/wireless/arlan-proc.c	Thu Sep 25 14:32:55 2003
+++ b/drivers/net/wireless/arlan-proc.c	Thu Sep 25 14:32:55 2003
@@ -866,7 +866,6 @@
 	CTBLN(32,cardNo,lParameter),\
 	CTBLN(33,cardNo,_15),\
 	CTBLN(34,cardNo,headerSize),\
-	CTBLN(35,cardNo,async),\
 	CTBLN(36,cardNo,tx_delay_ms),\
 	CTBLN(37,cardNo,retries),\
 	CTBLN(38,cardNo,ReTransmitPacketMaxSize),\
diff -Nru a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
--- a/drivers/net/wireless/arlan.h	Thu Sep 25 14:32:55 2003
+++ b/drivers/net/wireless/arlan.h	Thu Sep 25 14:32:55 2003
@@ -49,7 +49,6 @@
 
 extern struct net_device *arlan_device[MAX_ARLANS];
 extern int	arlan_debug;
-extern char *	siteName;
 extern int	arlan_entry_debug;
 extern int	arlan_exit_debug;
 extern int	testMemory;
@@ -70,8 +69,6 @@
 #define channelSetUNKNOWN 0
 #define systemIdUNKNOWN -1
 #define registrationModeUNKNOWN -1
-#define siteNameUNKNOWN "LinuxSite"
-
 
 
 #define IFDEBUG( L ) if ( (L) & arlan_debug ) 
@@ -296,7 +293,6 @@
       int	lParameter;
       int	_15;
       int	headerSize;
-      int async;
       int retries;
       int tx_delay_ms;
       int waitReTransmitPacketMaxSize;
@@ -335,17 +331,10 @@
       volatile	unsigned	char scrambled;
 };
 
-struct TxRingPoint  {
-	struct TxParam txParam;
-	
-	
-};
-
 #define TX_RING_SIZE 2
 /* Information that need to be kept for each board. */
 struct arlan_private {
       struct net_device_stats stats;
-      long open_time;			/* Useless example local info. */
       struct arlan_shmem * card;
       struct arlan_shmem * conf;
       struct TxParam txParam;      
@@ -360,16 +349,9 @@
       struct timer_list tx_delay_timer;
       struct timer_list tx_retry_timer;
       struct timer_list rx_check_timer;
-      struct semaphore card_lock;
-      atomic_t 	card_users;
-      atomic_t	delay_on;
-      atomic_t  retr_on;
+
       int registrationLostCount;
       int reRegisterExp;
-      int nof_tx;
-      int nof_tx_ack;
-      int last_nof_tx;
-      int last_nof_tx_ack;
       int irq_test_done;
       int last_command_was_rx;
       struct TxParam txRing[TX_RING_SIZE];
@@ -384,7 +366,6 @@
       volatile char under_toggle;
       volatile long long tx_last_sent;
       volatile long long tx_last_cleared;
-      volatile u_char under_tx;
       volatile int 	retransmissions;
       volatile int	tx_chain_active;
       volatile int 	timer_chain_active;
@@ -395,7 +376,6 @@
       volatile int 	waiting_command_mask;
       volatile int 	card_polling_interval;
       volatile int 	last_command_buff_free_time;
-      volatile int	numResets;
       volatile int 	under_reset;
       volatile int 	under_config;
       volatile int 	rx_command_given;
