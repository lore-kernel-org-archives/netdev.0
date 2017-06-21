From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH net] xen-netback: correctly schedule rate-limited queues
Date: Wed, 21 Jun 2017 10:21:22 +0100
Message-ID: <20170621092122.694-1-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Xen-devel <xen-devel@lists.xenproject.org>,
        Paul Durrant <Paul.Durrant@citrix.com>,
        David Miller <davem@davemloft.net>, <jean-louis@dupond.be>,
        Wei Liu <wei.liu2@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:19633 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752037AbdFUJVu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 05:21:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a flag to indicate if a queue is rate-limited. Test the flag in
NAPI poll handler and avoid rescheduling the queue if true, otherwise
we risk locking up the host. The rescheduling will be done in the
timer callback function.

Reported-by: Jean-Louis Dupond <jean-louis@dupond.be>
Signed-off-by: Wei Liu <wei.liu2@citrix.com>
Tested-by: Jean-Louis Dupond <jean-louis@dupond.be>
---
 drivers/net/xen-netback/common.h    | 1 +
 drivers/net/xen-netback/interface.c | 6 +++++-
 drivers/net/xen-netback/netback.c   | 6 +++++-
 3 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
index 530586be05b4..5b1d2e8402d9 100644
--- a/drivers/net/xen-netback/common.h
+++ b/drivers/net/xen-netback/common.h
@@ -199,6 +199,7 @@ struct xenvif_queue { /* Per-queue data for xenvif */
 	unsigned long   remaining_credit;
 	struct timer_list credit_timeout;
 	u64 credit_window_start;
+	bool rate_limited;
 
 	/* Statistics */
 	struct xenvif_stats stats;
diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
index 8397f6c92451..e322a862ddfe 100644
--- a/drivers/net/xen-netback/interface.c
+++ b/drivers/net/xen-netback/interface.c
@@ -106,7 +106,11 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
 
 	if (work_done < budget) {
 		napi_complete_done(napi, work_done);
-		xenvif_napi_schedule_or_enable_events(queue);
+		/* If the queue is rate-limited, it shall be
+		 * rescheduled in the timer callback.
+		 */
+		if (likely(!queue->rate_limited))
+			xenvif_napi_schedule_or_enable_events(queue);
 	}
 
 	return work_done;
diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 602d408fa25e..5042ff8d449a 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -180,6 +180,7 @@ static void tx_add_credit(struct xenvif_queue *queue)
 		max_credit = ULONG_MAX; /* wrapped: clamp to ULONG_MAX */
 
 	queue->remaining_credit = min(max_credit, max_burst);
+	queue->rate_limited = false;
 }
 
 void xenvif_tx_credit_callback(unsigned long data)
@@ -686,8 +687,10 @@ static bool tx_credit_exceeded(struct xenvif_queue *queue, unsigned size)
 		msecs_to_jiffies(queue->credit_usec / 1000);
 
 	/* Timer could already be pending in rare cases. */
-	if (timer_pending(&queue->credit_timeout))
+	if (timer_pending(&queue->credit_timeout)) {
+		queue->rate_limited = true;
 		return true;
+	}
 
 	/* Passed the point where we can replenish credit? */
 	if (time_after_eq64(now, next_credit)) {
@@ -702,6 +705,7 @@ static bool tx_credit_exceeded(struct xenvif_queue *queue, unsigned size)
 		mod_timer(&queue->credit_timeout,
 			  next_credit);
 		queue->credit_window_start = next_credit;
+		queue->rate_limited = true;
 
 		return true;
 	}
-- 
2.11.0
