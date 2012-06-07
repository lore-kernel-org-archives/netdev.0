From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] macvtap: use prepare_to_wait/finish_wait to ensure mb
Date: Thu,  7 Jun 2012 16:36:27 +0800
Message-ID: <1339058187-6619-1-git-send-email-honkiko@gmail.com>
Cc: Hong Zhiguo <honkiko@gmail.com>, netdev@vger.kernel.org,
	arnd@arndb.de, zhiguo.hong@nsn.com, vikifang@juniper.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:56821 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755979Ab2FGIjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 04:39:20 -0400
Received: by dady13 with SMTP id y13so556326dad.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 01:39:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

instead of raw assignment to current->state

Signed-off-by: Hong Zhiguo <honkiko@gmail.com>
---
 drivers/net/macvtap.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 2ee56de..0737bd4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -847,13 +847,12 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
 			       const struct iovec *iv, unsigned long len,
 			       int noblock)
 {
-	DECLARE_WAITQUEUE(wait, current);
+	DEFINE_WAIT(wait);
 	struct sk_buff *skb;
 	ssize_t ret = 0;
 
-	add_wait_queue(sk_sleep(&q->sk), &wait);
 	while (len) {
-		current->state = TASK_INTERRUPTIBLE;
+		prepare_to_wait(sk_sleep(&q->sk), &wait, TASK_INTERRUPTIBLE);
 
 		/* Read frames from the queue */
 		skb = skb_dequeue(&q->sk.sk_receive_queue);
@@ -875,8 +874,7 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
 		break;
 	}
 
-	current->state = TASK_RUNNING;
-	remove_wait_queue(sk_sleep(&q->sk), &wait);
+	finish_wait(sk_sleep(&q->sk), &wait);
 	return ret;
 }
 
-- 
1.7.4.1
