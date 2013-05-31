From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc V2 1/8] macvtap: do not add self to waitqueue if doing a nonblock read
Date: Fri, 31 May 2013 17:53:18 +0800
Message-ID: <1369994005-5943-2-git-send-email-jasowang@redhat.com>
References: <1369994005-5943-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369994005-5943-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no need to add self to waitqueue if doing a nonblock read. This could
help to avoid the spinlock contention.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 59e9605..2395062 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -845,7 +845,9 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
 	ssize_t ret = 0;
 
 	while (len) {
-		prepare_to_wait(sk_sleep(&q->sk), &wait, TASK_INTERRUPTIBLE);
+		if (!noblock)
+			prepare_to_wait(sk_sleep(&q->sk), &wait,
+					TASK_INTERRUPTIBLE);
 
 		/* Read frames from the queue */
 		skb = skb_dequeue(&q->sk.sk_receive_queue);
@@ -867,7 +869,8 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
 		break;
 	}
 
-	finish_wait(sk_sleep(&q->sk), &wait);
+	if (!noblock)
+		finish_wait(sk_sleep(&q->sk), &wait);
 	return ret;
 }
 
-- 
1.7.1
