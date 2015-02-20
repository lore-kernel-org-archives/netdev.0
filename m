From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 6/7 linux-next] wan: cosa: replace current->state by set_current_state()
Date: Fri, 20 Feb 2015 19:12:56 +0100
Message-ID: <1424455977-21903-6-git-send-email-fabf@skynet.be>
References: <1424455977-21903-1-git-send-email-fabf@skynet.be>
Cc: Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Fabian Frederick <fabf@skynet.be>,
	"Jan \"Yenya\" Kasprzak" <kas@fi.muni.cz>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424455977-21903-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use helper functions to access current->state.
Direct assignments are prone to races and therefore buggy.

current->state = TASK_RUNNING is replaced by __set_current_state()

Thanks to Peter Zijlstra for the exact definition of the problem.

Suggested-By: Peter Zijlstra <peterz@infradead.org>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/wan/cosa.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
index 83c39e2..88d121d 100644
--- a/drivers/net/wan/cosa.c
+++ b/drivers/net/wan/cosa.c
@@ -806,21 +806,21 @@ static ssize_t cosa_read(struct file *file,
 	spin_lock_irqsave(&cosa->lock, flags);
 	add_wait_queue(&chan->rxwaitq, &wait);
 	while (!chan->rx_status) {
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
 			mutex_unlock(&chan->rlock);
 			return -ERESTARTSYS;
 		}
 	}
 	remove_wait_queue(&chan->rxwaitq, &wait);
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	kbuf = chan->rxdata;
 	count = chan->rxsize;
 	spin_unlock_irqrestore(&cosa->lock, flags);
@@ -890,14 +890,14 @@ static ssize_t cosa_write(struct file *file,
 	spin_lock_irqsave(&cosa->lock, flags);
 	add_wait_queue(&chan->txwaitq, &wait);
 	while (!chan->tx_status) {
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
 			up(&chan->wsem);
@@ -905,7 +905,7 @@ static ssize_t cosa_write(struct file *file,
 		}
 	}
 	remove_wait_queue(&chan->txwaitq, &wait);
-	current->state = TASK_RUNNING;
+	__set_current_state(TASK_RUNNING);
 	up(&chan->wsem);
 	spin_unlock_irqrestore(&cosa->lock, flags);
 	kfree(kbuf);
-- 
2.1.0
