From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] tun: don't look at current when non-blocking
Date: Sun, 6 Oct 2013 21:25:12 +0300
Message-ID: <20131006182512.GA16504@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012Ab3JFSZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Oct 2013 14:25:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We play with a wait queue even if socket is
non blocking. This is an obvious waste.
Besides, it will prevent calling the non blocking
variant when current is not valid.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/net/tun.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 807815f..7cb105c 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1293,7 +1293,8 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 	if (unlikely(!noblock))
 		add_wait_queue(&tfile->wq.wait, &wait);
 	while (len) {
-		current->state = TASK_INTERRUPTIBLE;
+		if (unlikely(!noblock))
+			current->state = TASK_INTERRUPTIBLE;
 
 		/* Read frames from the queue */
 		if (!(skb = skb_dequeue(&tfile->socket.sk->sk_receive_queue))) {
@@ -1320,9 +1321,10 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 		break;
 	}
 
-	current->state = TASK_RUNNING;
-	if (unlikely(!noblock))
+	if (unlikely(!noblock)) {
+		current->state = TASK_RUNNING;
 		remove_wait_queue(&tfile->wq.wait, &wait);
+	}
 
 	return ret;
 }
-- 
MST
