From: akpm@linux-foundation.org
Subject: [patch 1/1] COSA/SRP: convert channel_data.rsem to mutex
Date: Tue, 04 Mar 2008 15:17:37 -0800
Message-ID: <200803042317.m24NHcOZ002575@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	matthias@kaehlcke.net, khc@pm.waw.pl
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37657 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934935AbYCDXSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 18:18:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthias Kaehlcke <matthias@kaehlcke.net>

COSA/SRP driver: The semaphore channel_data.rsem is used as a mutex,
convert it to the mutex API

Signed-off-by: Matthias Kaehlcke <matthias@kaehlcke.net>
Cc: Krzysztof Halasa <khc@pm.waw.pl>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/wan/cosa.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff -puN drivers/net/wan/cosa.c~cosa-srp-convert-channel_datarsem-to-mutex drivers/net/wan/cosa.c
--- a/drivers/net/wan/cosa.c~cosa-srp-convert-channel_datarsem-to-mutex
+++ a/drivers/net/wan/cosa.c
@@ -90,6 +90,7 @@
 #include <linux/ioport.h>
 #include <linux/netdevice.h>
 #include <linux/spinlock.h>
+#include <linux/mutex.h>
 #include <linux/device.h>
 
 #undef COSA_SLOW_IO	/* for testing purposes only */
@@ -127,7 +128,8 @@ struct channel_data {
 	int (*tx_done)(struct channel_data *channel, int size);
 
 	/* Character device parts */
-	struct semaphore rsem, wsem;
+	struct mutex rlock;
+	struct semaphore wsem;
 	char *rxdata;
 	int rxsize;
 	wait_queue_head_t txwaitq, rxwaitq;
@@ -807,7 +809,7 @@ static struct net_device_stats *cosa_net
 
 static void chardev_channel_init(struct channel_data *chan)
 {
-	init_MUTEX(&chan->rsem);
+	mutex_init(&chan->rlock);
 	init_MUTEX(&chan->wsem);
 }
 
@@ -825,12 +827,12 @@ static ssize_t cosa_read(struct file *fi
 			cosa->name, cosa->firmware_status);
 		return -EPERM;
 	}
-	if (down_interruptible(&chan->rsem))
+	if (mutex_lock_interruptible(&chan->rlock))
 		return -ERESTARTSYS;
 	
 	if ((chan->rxdata = kmalloc(COSA_MTU, GFP_DMA|GFP_KERNEL)) == NULL) {
 		printk(KERN_INFO "%s: cosa_read() - OOM\n", cosa->name);
-		up(&chan->rsem);
+		mutex_unlock(&chan->rlock);
 		return -ENOMEM;
 	}
 
@@ -848,7 +850,7 @@ static ssize_t cosa_read(struct file *fi
 			remove_wait_queue(&chan->rxwaitq, &wait);
 			current->state = TASK_RUNNING;
 			spin_unlock_irqrestore(&cosa->lock, flags);
-			up(&chan->rsem);
+			mutex_unlock(&chan->rlock);
 			return -ERESTARTSYS;
 		}
 	}
@@ -857,7 +859,7 @@ static ssize_t cosa_read(struct file *fi
 	kbuf = chan->rxdata;
 	count = chan->rxsize;
 	spin_unlock_irqrestore(&cosa->lock, flags);
-	up(&chan->rsem);
+	mutex_unlock(&chan->rlock);
 
 	if (copy_to_user(buf, kbuf, count)) {
 		kfree(kbuf);
_
