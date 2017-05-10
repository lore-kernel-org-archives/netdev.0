From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3 8/9] tap: support receiving skb from msg_control
Date: Wed, 10 May 2017 10:38:00 +0800
Message-ID: <1494383881-6811-9-git-send-email-jasowang@redhat.com>
References: <1494383881-6811-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34628 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751935AbdEJCiy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 9 May 2017 22:38:54 -0400
In-Reply-To: <1494383881-6811-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes tap_recvmsg() can receive from skb from its caller
through msg_control. Vhost_net will be the first user.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tap.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index abdaf86..9af3239 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -824,15 +824,17 @@ static ssize_t tap_put_user(struct tap_queue *q,
 
 static ssize_t tap_do_read(struct tap_queue *q,
 			   struct iov_iter *to,
-			   int noblock)
+			   int noblock, struct sk_buff *skb)
 {
 	DEFINE_WAIT(wait);
-	struct sk_buff *skb;
 	ssize_t ret = 0;
 
 	if (!iov_iter_count(to))
 		return 0;
 
+	if (skb)
+		goto put;
+
 	while (1) {
 		if (!noblock)
 			prepare_to_wait(sk_sleep(&q->sk), &wait,
@@ -856,6 +858,7 @@ static ssize_t tap_do_read(struct tap_queue *q,
 	if (!noblock)
 		finish_wait(sk_sleep(&q->sk), &wait);
 
+put:
 	if (skb) {
 		ret = tap_put_user(q, skb, to);
 		if (unlikely(ret < 0))
@@ -872,7 +875,7 @@ static ssize_t tap_read_iter(struct kiocb *iocb, struct iov_iter *to)
 	struct tap_queue *q = file->private_data;
 	ssize_t len = iov_iter_count(to), ret;
 
-	ret = tap_do_read(q, to, file->f_flags & O_NONBLOCK);
+	ret = tap_do_read(q, to, file->f_flags & O_NONBLOCK, NULL);
 	ret = min_t(ssize_t, ret, len);
 	if (ret > 0)
 		iocb->ki_pos = ret;
@@ -1155,7 +1158,8 @@ static int tap_recvmsg(struct socket *sock, struct msghdr *m,
 	int ret;
 	if (flags & ~(MSG_DONTWAIT|MSG_TRUNC))
 		return -EINVAL;
-	ret = tap_do_read(q, &m->msg_iter, flags & MSG_DONTWAIT);
+	ret = tap_do_read(q, &m->msg_iter, flags & MSG_DONTWAIT,
+			  m->msg_control);
 	if (ret > total_len) {
 		m->msg_flags |= MSG_TRUNC;
 		ret = flags & MSG_TRUNC ? ret : total_len;
-- 
2.7.4
