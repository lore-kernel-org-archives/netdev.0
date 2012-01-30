From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [12/22] Cyclades PC300 driver: locking improvements
Date: Sun, 29 Jan 2012 18:53:49 -0800
Message-ID: <20120130025349.GM10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avoid redundant do/while in CPC_LOCK/CPC_UNLOCK macros; hold the lock during
DMA buffer writes in cpc_queue_xmit() to avert a potential race condition.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 36cf3b0..14500eb 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -243,15 +243,15 @@ static char rcsid[] =
 
 #include "pc300.h"
 
-#define	CPC_LOCK(card,flags)		\
-		do {						\
-		spin_lock_irqsave(&card->card_lock, flags);	\
-		} while (0)
+#define	CPC_LOCK(card, flags) \
+		{ \
+		    spin_lock_irqsave(&((card)->card_lock), (flags)); \
+		}
 
-#define CPC_UNLOCK(card,flags)			\
-		do {							\
-		spin_unlock_irqrestore(&card->card_lock, flags);	\
-		} while (0)
+#define CPC_UNLOCK(card, flags) \
+		{ \
+		    spin_unlock_irqrestore(&((card)->card_lock), (flags)); \
+		}
 
 #undef	PC300_DEBUG_PCI
 #undef	PC300_DEBUG_INTR
@@ -1971,8 +1971,10 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		return 0;
 	}
 
+	CPC_LOCK(card, flags);
 	/* Write buffer to DMA buffers */
 	if (dma_buf_write(card, ch, (u8 *) skb->data, skb->len) != 0) {
+		CPC_UNLOCK(card, flags);
 		printk(KERN_ERR "%s: write error. Dropping TX packet.\n",
 		       dev->name);
 #ifdef PC300_DEBUG_QUEUE
@@ -1985,7 +1987,8 @@ static int cpc_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 		stats->tx_errors++;
 		stats->tx_dropped++;
 		return 0;
-	}
+	} else
+		CPC_UNLOCK(card, flags);
 #ifdef PC300_DEBUG_TX
 	printk("%s T:", dev->name);
 	for (i = 0; i < skb->len; i++)
