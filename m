From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/8) arlan -- add spinlock
Date: Thu, 25 Sep 2003 16:00:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030925160014.1399184a.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Convert bogus test_and_set local wait, to a real spin_lock so it
has a chance of working on an SMP.  This also does the right thing
and locks out interrupts while giving commands on UP;  maybe the
comment in Kconfig was because there was never a proper mutex...

Don't have real hardware to try this, but it can't be worse than
the previous code.

diff -Nru a/drivers/net/wireless/arlan-main.c b/drivers/net/wireless/arlan-main.c
--- a/drivers/net/wireless/arlan-main.c	Thu Sep 25 15:08:01 2003
+++ b/drivers/net/wireless/arlan-main.c	Thu Sep 25 15:08:01 2003
@@ -44,7 +44,6 @@
 static int mdebug;
 #endif
 
-#if LINUX_VERSION_CODE > 0x20100
 MODULE_PARM(irq, "i");
 MODULE_PARM(mem, "i");
 MODULE_PARM(probe, "i");
@@ -87,10 +86,6 @@
 MODULE_PARM_DESC(arlan_entry_and_exit_debug, "(ignored)");
 #endif
 
-#else
-#define test_and_set_bit	set_bit
-#endif
-
 struct arlan_conf_stru arlan_conf[MAX_ARLANS];
 static int arlans_found;
 
@@ -172,6 +167,7 @@
 	int udelayed = 0;
 	int i = 0;
 	long long time_mks = arlan_time();
+	unsigned long flags;
 
 	ARLAN_DEBUG_ENTRY("arlan_command");
 
@@ -179,8 +175,8 @@
 		priv->card_polling_interval = 1;
 
 	if (arlan_debug & ARLAN_DEBUG_CHAIN_LOCKS)
-		printk(KERN_DEBUG "arlan_command, %lx lock %lx  commandByte %x waiting %x incoming %x \n",
-		jiffies, priv->command_lock, READSHMB(arlan->commandByte),
+		printk(KERN_DEBUG "arlan_command, %lx commandByte %x waiting %x incoming %x \n",
+		jiffies, READSHMB(arlan->commandByte),
 		       priv->waiting_command_mask, command_p);
 
 	priv->waiting_command_mask |= command_p;
@@ -201,13 +197,8 @@
 	}
 
 	/* Card access serializing lock */
+	spin_lock_irqsave(&priv->lock, flags);
 
-	if (test_and_set_bit(0, (void *) &priv->command_lock))
-	{
-		if (arlan_debug & ARLAN_DEBUG_CHAIN_LOCKS)
-			printk(KERN_DEBUG "arlan_command: entered when command locked \n");
-		goto command_busy_end;
-	}
 	/* Check cards status and waiting */
 
 	if (priv->waiting_command_mask & (ARLAN_COMMAND_LONG_WAIT_NOW | ARLAN_COMMAND_WAIT_NOW))
@@ -475,7 +466,7 @@
 		if (arlan_debug & ARLAN_DEBUG_CARD_STATE)
 			printk(KERN_ERR "card busy leaving command %x \n", priv->waiting_command_mask);
 
-	priv->command_lock = 0;
+	spin_unlock_irqrestore(&priv->lock, flags);
 	ARLAN_DEBUG_EXIT("arlan_command");
 	priv->last_command_buff_free_time = jiffies;
 	return 0;
@@ -486,24 +477,17 @@
 
 	if (arlan_debug & ARLAN_DEBUG_CARD_STATE)
 		printk(KERN_ERR "%s arlan_command card busy end \n", dev->name);
-	priv->command_lock = 0;
+	spin_unlock_irqrestore(&priv->lock, flags);
 	ARLAN_DEBUG_EXIT("arlan_command");
 	return 1;
 
 bad_end:
 	printk(KERN_ERR "%s arlan_command bad end \n", dev->name);
 
-	priv->command_lock = 0;
+	spin_unlock_irqrestore(&priv->lock, flags);
 	ARLAN_DEBUG_EXIT("arlan_command");
 
 	return -1;
-
-command_busy_end:
-	if (arlan_debug & ARLAN_DEBUG_CARD_STATE)
-		printk(KERN_ERR "%s arlan_command command busy end \n", dev->name);
-	ARLAN_DEBUG_EXIT("arlan_command");
-	return 2;
-
 }
 
 static inline void arlan_command_process(struct net_device *dev)
@@ -1238,7 +1222,7 @@
 	memset(dev->broadcast, 0xff, 6);
 	dev->tx_queue_len = tx_queue_len;
 	priv->interrupt_processing_active = 0;
-	priv->command_lock = 0;
+	spin_lock_init(&priv->lock);
 
 	netif_start_queue (dev);
 
diff -Nru a/drivers/net/wireless/arlan.h b/drivers/net/wireless/arlan.h
--- a/drivers/net/wireless/arlan.h	Thu Sep 25 15:08:01 2003
+++ b/drivers/net/wireless/arlan.h	Thu Sep 25 15:08:01 2003
@@ -367,7 +367,7 @@
       volatile long long tx_last_cleared;
       volatile int 	retransmissions;
       volatile int 	interrupt_ack_requested;
-      volatile long	command_lock;
+      spinlock_t lock;
       volatile int	rx_command_needed;
       volatile int	tx_command_needed;
       volatile int 	waiting_command_mask;
