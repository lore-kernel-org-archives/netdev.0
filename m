From: Felipe W Damasio <felipewd@terra.com.br>
Subject: [PATCH] Memory Barriers on cosa wan driver
Date: Sun, 28 Sep 2003 23:37:57 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F779B05.4060001@terra.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010404050101070809090109"
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010404050101070809090109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

	Hi Jeff,

	Patch against 2.6.0-test6. Adds a few needed memory barriers before 
schedule_timeout, kills setting current task to TASK_RUNNING after 
schedule_timeout and uses the __set_current_state functions instead of 
current->state = TASK_RUNNING.

	I don't have the hardware, so I couldn't test it. But it looks right :)

	Please review and consider applying if it is ok.

	Thanks,

Felipe
-- 
It's most certainly GNU/Linux, not Linux. Read more at
http://www.gnu.org/gnu/why-gnu-linux.html

--------------010404050101070809090109
Content-Type: text/plain;
 name="cosa-mb.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="cosa-mb.patch"

--- linux-2.6.0-test6/drivers/net/wan/cosa.c.orig	Sun Sep 28 23:26:29 2003
+++ linux-2.6.0-test6/drivers/net/wan/cosa.c	Sun Sep 28 23:28:17 2003
@@ -516,10 +516,9 @@
 		 * FIXME: When this code is not used as module, we should
 		 * probably call udelay() instead of the interruptible sleep.
 		 */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		cosa_putstatus(cosa, SR_TX_INT_ENA);
 		schedule_timeout(30);
-		current->state = TASK_RUNNING;
 		irq = probe_irq_off(irqs);
 		/* Disable all IRQs from the card */
 		cosa_putstatus(cosa, 0);
@@ -824,21 +823,21 @@
 	spin_lock_irqsave(&cosa->lock, flags);
 	add_wait_queue(&chan->rxwaitq, &wait);
 	while(!chan->rx_status) {
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		spin_unlock_irqrestore(&cosa->lock, flags);
 		schedule();
 		spin_lock_irqsave(&cosa->lock, flags);
 		if (signal_pending(current) && chan->rx_status == 0) {
 			chan->rx_status = 1;
 			remove_wait_queue(&chan->rxwaitq, &wait);
-			current->state = TASK_RUNNING;
+			__set_current_state(TASK_RUNNING);
 			spin_unlock_irqrestore(&cosa->lock, flags);
 			up(&chan->rsem);
 			return -ERESTARTSYS;
 		}
 	}
 	remove_wait_queue(&chan->rxwaitq, &wait);
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	kbuf = chan->rxdata;
 	count = chan->rxsize;
 	spin_unlock_irqrestore(&cosa->lock, flags);
@@ -909,21 +908,21 @@
 	spin_lock_irqsave(&cosa->lock, flags);
 	add_wait_queue(&chan->txwaitq, &wait);
 	while(!chan->tx_status) {
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		spin_unlock_irqrestore(&cosa->lock, flags);
 		schedule();
 		spin_lock_irqsave(&cosa->lock, flags);
 		if (signal_pending(current) && chan->tx_status == 0) {
 			chan->tx_status = 1;
 			remove_wait_queue(&chan->txwaitq, &wait);
-			current->state = TASK_RUNNING;
+			__set_current_state(TASK_RUNNING);
 			chan->tx_status = 1;
 			spin_unlock_irqrestore(&cosa->lock, flags);
 			return -ERESTARTSYS;
 		}
 	}
 	remove_wait_queue(&chan->txwaitq, &wait);
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	up(&chan->wsem);
 	spin_unlock_irqrestore(&cosa->lock, flags);
 	kfree(kbuf);
@@ -1530,9 +1529,8 @@
 	cosa_getdata8(cosa);
 	cosa_putstatus(cosa, SR_RST);
 #ifdef MODULE
-	current->state = TASK_INTERRUPTIBLE;
+	set_current_state(TASK_INTERRUPTIBLE);
 	schedule_timeout(HZ/2);
-	current->state = TASK_RUNNING;
 #else
 	udelay(5*100000);
 #endif
@@ -1585,7 +1583,7 @@
 			return r;
 		}
 		/* sleep if not ready to read */
-		current->state = TASK_INTERRUPTIBLE;
+		set_current_state(TASK_INTERRUPTIBLE);
 		schedule_timeout(1);
 	}
 	printk(KERN_INFO "cosa: timeout in get_wait_data (status 0x%x)\n",

--------------010404050101070809090109--
