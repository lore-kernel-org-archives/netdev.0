From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 net-next 6/7] tap: support receiving skb from msg_control
Date: Thu, 30 Mar 2017 15:22:29 +0800
Message-ID: <1490858550-7763-7-git-send-email-jasowang@redhat.com>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes tap_recvmsg() can receive from skb from its caller
through msg_control. Vhost_net will be the first user.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tap.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index abdaf86..07d9174 100644
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
+		goto done;
+
 	while (1) {
 		if (!noblock)
 			prepare_to_wait(sk_sleep(&q->sk), &wait,
@@ -856,6 +858,7 @@ static ssize_t tap_do_read(struct tap_queue *q,
 	if (!noblock)
 		finish_wait(sk_sleep(&q->sk), &wait);
 
+done:
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
