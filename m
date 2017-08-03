From: Anton Volkov <avolkov@ispras.ru>
Subject: [PATCH] hysdn: fix to a race condition in put_log_buffer
Date: Thu,  3 Aug 2017 14:33:21 +0300
Message-ID: <1501760001-22193-1-git-send-email-avolkov@ispras.ru>
References: <2f35ddaf-88d9-e848-f83b-3001b36b2883@linux-pingi.de>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org,
        khoroshilov@ispras.ru, Anton Volkov <avolkov@ispras.ru>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2f35ddaf-88d9-e848-f83b-3001b36b2883@linux-pingi.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The synchronization type that was used earlier to guard the loop that
deletes unused log buffers may lead to a situation that prevents any
thread from going through the loop.

The patch deletes previously used synchronization mechanism and moves
the loop under the spin_lock so the similar cases won't be feasible in
the future.

Found by by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Anton Volkov <avolkov@ispras.ru>
---
 drivers/isdn/hysdn/hysdn_proclog.c | 27 ++++++++++++---------------
 1 file changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/hysdn/hysdn_proclog.c b/drivers/isdn/hysdn/hysdn_proclog.c
index 7b5fd8f..b152c6c 100644
--- a/drivers/isdn/hysdn/hysdn_proclog.c
+++ b/drivers/isdn/hysdn/hysdn_proclog.c
@@ -44,7 +44,6 @@ struct procdata {
 	char log_name[15];	/* log filename */
 	struct log_data *log_head, *log_tail;	/* head and tail for queue */
 	int if_used;		/* open count for interface */
-	int volatile del_lock;	/* lock for delete operations */
 	unsigned char logtmp[LOG_MAX_LINELEN];
 	wait_queue_head_t rd_queue;
 };
@@ -102,7 +101,6 @@ put_log_buffer(hysdn_card *card, char *cp)
 {
 	struct log_data *ib;
 	struct procdata *pd = card->proclog;
-	int i;
 	unsigned long flags;
 
 	if (!pd)
@@ -126,21 +124,20 @@ put_log_buffer(hysdn_card *card, char *cp)
 	else
 		pd->log_tail->next = ib;	/* follows existing messages */
 	pd->log_tail = ib;	/* new tail */
-	i = pd->del_lock++;	/* get lock state */
-	spin_unlock_irqrestore(&card->hysdn_lock, flags);
 
 	/* delete old entrys */
-	if (!i)
-		while (pd->log_head->next) {
-			if ((pd->log_head->usage_cnt <= 0) &&
-			    (pd->log_head->next->usage_cnt <= 0)) {
-				ib = pd->log_head;
-				pd->log_head = pd->log_head->next;
-				kfree(ib);
-			} else
-				break;
-		}		/* pd->log_head->next */
-	pd->del_lock--;		/* release lock level */
+	while (pd->log_head->next) {
+		if ((pd->log_head->usage_cnt <= 0) &&
+		    (pd->log_head->next->usage_cnt <= 0)) {
+			ib = pd->log_head;
+			pd->log_head = pd->log_head->next;
+			kfree(ib);
+		} else
+			break;
+	}		/* pd->log_head->next */
+
+	spin_unlock_irqrestore(&card->hysdn_lock, flags);
+
 	wake_up_interruptible(&(pd->rd_queue));		/* announce new entry */
 }				/* put_log_buffer */
 
-- 
2.7.4
