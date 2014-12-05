From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 08/12] first fruits - kill l2cap ->memcpy_fromiovec()
Date: Fri,  5 Dec 2014 05:58:49 +0000
Message-ID: <1417759133-18370-8-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141205055623.GQ29748@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

Just use copy_from_iter().  That's what this method is trying to do
in all cases, in a very convoluted fashion.

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/bluetooth/l2cap.h | 29 -----------------------------
 net/bluetooth/6lowpan.c       |  3 +--
 net/bluetooth/a2mp.c          |  3 +--
 net/bluetooth/l2cap_core.c    |  7 +++----
 net/bluetooth/l2cap_sock.c    |  8 --------
 net/bluetooth/smp.c           |  4 +---
 6 files changed, 6 insertions(+), 48 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index bca6fc0..692f786 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -606,10 +606,6 @@ struct l2cap_ops {
 	struct sk_buff		*(*alloc_skb) (struct l2cap_chan *chan,
 					       unsigned long hdr_len,
 					       unsigned long len, int nb);
-	int			(*memcpy_fromiovec) (struct l2cap_chan *chan,
-						     unsigned char *kdata,
-						     struct msghdr *msg,
-						     int len);
 };
 
 struct l2cap_conn {
@@ -903,31 +899,6 @@ static inline long l2cap_chan_no_get_sndtimeo(struct l2cap_chan *chan)
 	return 0;
 }
 
-static inline int l2cap_chan_no_memcpy_fromiovec(struct l2cap_chan *chan,
-						 unsigned char *kdata,
-						 struct msghdr *msg,
-						 int len)
-{
-	/* Following is safe since for compiler definitions of kvec and
-	 * iovec are identical, yielding the same in-core layout and alignment
-	 */
-	struct kvec *vec = (struct kvec *)msg->msg_iter.iov;
-
-	while (len > 0) {
-		if (vec->iov_len) {
-			int copy = min_t(unsigned int, len, vec->iov_len);
-			memcpy(kdata, vec->iov_base, copy);
-			len -= copy;
-			kdata += copy;
-			vec->iov_base += copy;
-			vec->iov_len -= copy;
-		}
-		vec++;
-	}
-
-	return 0;
-}
-
 extern bool disable_ertm;
 
 int l2cap_init_sockets(void);
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index d8c67a5..76617be 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -541,7 +541,7 @@ static int send_pkt(struct l2cap_chan *chan, struct sk_buff *skb,
 	iv.iov_len = skb->len;
 
 	memset(&msg, 0, sizeof(msg));
-	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *) &iv, 1, skb->len);
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, &iv, 1, skb->len);
 
 	err = l2cap_chan_send(chan, &msg, skb->len);
 	if (err > 0) {
@@ -1050,7 +1050,6 @@ static const struct l2cap_ops bt_6lowpan_chan_ops = {
 	.suspend		= chan_suspend_cb,
 	.get_sndtimeo		= chan_get_sndtimeo_cb,
 	.alloc_skb		= chan_alloc_skb_cb,
-	.memcpy_fromiovec	= l2cap_chan_no_memcpy_fromiovec,
 
 	.teardown		= l2cap_chan_no_teardown,
 	.defer			= l2cap_chan_no_defer,
diff --git a/net/bluetooth/a2mp.c b/net/bluetooth/a2mp.c
index 716d2a3..cedfbda 100644
--- a/net/bluetooth/a2mp.c
+++ b/net/bluetooth/a2mp.c
@@ -60,7 +60,7 @@ void a2mp_send(struct amp_mgr *mgr, u8 code, u8 ident, u16 len, void *data)
 
 	memset(&msg, 0, sizeof(msg));
 
-	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *)&iv, 1, total_len);
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, &iv, 1, total_len);
 
 	l2cap_chan_send(chan, &msg, total_len);
 
@@ -719,7 +719,6 @@ static const struct l2cap_ops a2mp_chan_ops = {
 	.resume = l2cap_chan_no_resume,
 	.set_shutdown = l2cap_chan_no_set_shutdown,
 	.get_sndtimeo = l2cap_chan_no_get_sndtimeo,
-	.memcpy_fromiovec = l2cap_chan_no_memcpy_fromiovec,
 };
 
 static struct l2cap_chan *a2mp_chan_open(struct l2cap_conn *conn, bool locked)
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 5201d61..1754040 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2096,8 +2096,7 @@ static inline int l2cap_skbuff_fromiovec(struct l2cap_chan *chan,
 	struct sk_buff **frag;
 	int sent = 0;
 
-	if (chan->ops->memcpy_fromiovec(chan, skb_put(skb, count),
-					msg, count))
+	if (copy_from_iter(skb_put(skb, count), count, &msg->msg_iter) != count)
 		return -EFAULT;
 
 	sent += count;
@@ -2117,8 +2116,8 @@ static inline int l2cap_skbuff_fromiovec(struct l2cap_chan *chan,
 
 		*frag = tmp;
 
-		if (chan->ops->memcpy_fromiovec(chan, skb_put(*frag, count),
-						msg, count))
+		if (copy_from_iter(skb_put(*frag, count), count,
+				   &msg->msg_iter) != count)
 			return -EFAULT;
 
 		sent += count;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index 205b298..f65caf4 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1336,13 +1336,6 @@ static struct sk_buff *l2cap_sock_alloc_skb_cb(struct l2cap_chan *chan,
 	return skb;
 }
 
-static int l2cap_sock_memcpy_fromiovec_cb(struct l2cap_chan *chan,
-					  unsigned char *kdata,
-					  struct msghdr *msg, int len)
-{
-	return memcpy_from_msg(kdata, msg, len);
-}
-
 static void l2cap_sock_ready_cb(struct l2cap_chan *chan)
 {
 	struct sock *sk = chan->data;
@@ -1427,7 +1420,6 @@ static const struct l2cap_ops l2cap_chan_ops = {
 	.set_shutdown		= l2cap_sock_set_shutdown_cb,
 	.get_sndtimeo		= l2cap_sock_get_sndtimeo_cb,
 	.alloc_skb		= l2cap_sock_alloc_skb_cb,
-	.memcpy_fromiovec	= l2cap_sock_memcpy_fromiovec_cb,
 };
 
 static void l2cap_sock_destruct(struct sock *sk)
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index 21f555b..de7dc75 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -268,7 +268,7 @@ static void smp_send_cmd(struct l2cap_conn *conn, u8 code, u16 len, void *data)
 
 	memset(&msg, 0, sizeof(msg));
 
-	iov_iter_init(&msg.msg_iter, WRITE, (struct iovec *)iv, 2, 1 + len);
+	iov_iter_kvec(&msg.msg_iter, WRITE | ITER_KVEC, iv, 2, 1 + len);
 
 	l2cap_chan_send(chan, &msg, 1 + len);
 
@@ -1629,7 +1629,6 @@ static const struct l2cap_ops smp_chan_ops = {
 	.suspend		= l2cap_chan_no_suspend,
 	.set_shutdown		= l2cap_chan_no_set_shutdown,
 	.get_sndtimeo		= l2cap_chan_no_get_sndtimeo,
-	.memcpy_fromiovec	= l2cap_chan_no_memcpy_fromiovec,
 };
 
 static inline struct l2cap_chan *smp_new_conn_cb(struct l2cap_chan *pchan)
@@ -1678,7 +1677,6 @@ static const struct l2cap_ops smp_root_chan_ops = {
 	.resume			= l2cap_chan_no_resume,
 	.set_shutdown		= l2cap_chan_no_set_shutdown,
 	.get_sndtimeo		= l2cap_chan_no_get_sndtimeo,
-	.memcpy_fromiovec	= l2cap_chan_no_memcpy_fromiovec,
 };
 
 int smp_register(struct hci_dev *hdev)
-- 
2.1.3
