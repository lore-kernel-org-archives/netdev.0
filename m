From: Jason Wang <jasowang@redhat.com>
Subject: [net-next PATCH 2/8] macvtap: do not add self to waitqueue if doing a nonblock read
Date: Thu,  6 Jun 2013 17:54:34 +0800
Message-ID: <1370512480-14272-3-git-send-email-jasowang@redhat.com>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Cc: sergei.shtylyov@cogentembedded.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27240 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932079Ab3FFKFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jun 2013 06:05:09 -0400
In-Reply-To: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no need to add self to waitqueue if doing a nonblock read. This could
help to avoid the spinlock contention.

Acked-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5e485e3..8949631 100644
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
