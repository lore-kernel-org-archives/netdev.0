From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH 18/25] switch l2cap ->memcpy_fromiovec() to msghdr
Date: Tue,  9 Dec 2014 22:50:31 +0000
Message-ID: <1418165438-2205-18-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141209224928.GL22149@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141209224928.GL22149@ZenIV.linux.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Al Viro <viro@zeniv.linux.org.uk>

it'll die soon enough - now that kvec-backed iov_iter works regardless
of set_fs(), both instances will become copy_from_iter() as soon as
we introduce ->msg_iter...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 include/net/bluetooth/l2cap.h | 6 +++---
 net/bluetooth/l2cap_core.c    | 4 ++--
 net/bluetooth/l2cap_sock.c    | 4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 061e648..4e23674 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -608,7 +608,7 @@ struct l2cap_ops {
 					       unsigned long len, int nb);
 	int			(*memcpy_fromiovec) (struct l2cap_chan *chan,
 						     unsigned char *kdata,
-						     struct iovec *iov,
+						     struct msghdr *msg,
 						     int len);
 };
 
@@ -905,13 +905,13 @@ static inline long l2cap_chan_no_get_sndtimeo(struct l2cap_chan *chan)
 
 static inline int l2cap_chan_no_memcpy_fromiovec(struct l2cap_chan *chan,
 						 unsigned char *kdata,
-						 struct iovec *iov,
+						 struct msghdr *msg,
 						 int len)
 {
 	/* Following is safe since for compiler definitions of kvec and
 	 * iovec are identical, yielding the same in-core layout and alignment
 	 */
-	struct kvec *vec = (struct kvec *)iov;
+	struct kvec *vec = (struct kvec *)msg->msg_iov;
 
 	while (len > 0) {
 		if (vec->iov_len) {
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 8e12731..5201d61 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -2097,7 +2097,7 @@ static inline int l2cap_skbuff_fromiovec(struct l2cap_chan *chan,
 	int sent = 0;
 
 	if (chan->ops->memcpy_fromiovec(chan, skb_put(skb, count),
-					msg->msg_iov, count))
+					msg, count))
 		return -EFAULT;
 
 	sent += count;
@@ -2118,7 +2118,7 @@ static inline int l2cap_skbuff_fromiovec(struct l2cap_chan *chan,
 		*frag = tmp;
 
 		if (chan->ops->memcpy_fromiovec(chan, skb_put(*frag, count),
-						msg->msg_iov, count))
+						msg, count))
 			return -EFAULT;
 
 		sent += count;
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index b0efb72..205b298 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -1338,9 +1338,9 @@ static struct sk_buff *l2cap_sock_alloc_skb_cb(struct l2cap_chan *chan,
 
 static int l2cap_sock_memcpy_fromiovec_cb(struct l2cap_chan *chan,
 					  unsigned char *kdata,
-					  struct iovec *iov, int len)
+					  struct msghdr *msg, int len)
 {
-	return memcpy_fromiovec(kdata, iov, len);
+	return memcpy_from_msg(kdata, msg, len);
 }
 
 static void l2cap_sock_ready_cb(struct l2cap_chan *chan)
-- 
2.1.3
