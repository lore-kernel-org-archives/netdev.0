From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/26] tipc: Allow receiving into iovec containing multiple entries
Date: Sun, 13 Mar 2011 17:33:49 -0400
Message-ID: <1300052054-7531-2-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49847 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754920Ab1CMVea (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:30 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhances TIPC's socket receive routines to support iovec structures
containing more than a single entry. This change leverages existing
sk_buff routines to do most of the work; the only significant change
to TIPC itself is that an sk_buff now records how much data has been
already consumed as an numeric offset, rather than as a pointer to
the first unread data byte.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/socket.c |   38 +++++++++++++++-----------------------
 1 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 125dcb0..d45a294 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -289,7 +289,7 @@ static int release(struct socket *sock)
 		if (buf == NULL)
 			break;
 		atomic_dec(&tipc_queue_size);
-		if (TIPC_SKB_CB(buf)->handle != msg_data(buf_msg(buf)))
+		if (TIPC_SKB_CB(buf)->handle != 0)
 			buf_discard(buf);
 		else {
 			if ((sock->state == SS_CONNECTING) ||
@@ -917,9 +917,6 @@ static int recv_msg(struct kiocb *iocb, struct socket *sock,
 
 	/* Catch invalid receive requests */
 
-	if (m->msg_iovlen != 1)
-		return -EOPNOTSUPP;   /* Don't do multiple iovec entries yet */
-
 	if (unlikely(!buf_len))
 		return -EINVAL;
 
@@ -991,11 +988,10 @@ restart:
 			sz = buf_len;
 			m->msg_flags |= MSG_TRUNC;
 		}
-		if (unlikely(copy_to_user(m->msg_iov->iov_base, msg_data(msg),
-					  sz))) {
-			res = -EFAULT;
+		res = skb_copy_datagram_iovec(buf, msg_hdr_sz(msg),
+					      m->msg_iov, sz);
+		if (res)
 			goto exit;
-		}
 		res = sz;
 	} else {
 		if ((sock->state == SS_READY) ||
@@ -1041,16 +1037,11 @@ static int recv_stream(struct kiocb *iocb, struct socket *sock,
 	unsigned int sz;
 	int sz_to_copy, target, needed;
 	int sz_copied = 0;
-	char __user *crs = m->msg_iov->iov_base;
-	unsigned char *buf_crs;
 	u32 err;
 	int res = 0;
 
 	/* Catch invalid receive attempts */
 
-	if (m->msg_iovlen != 1)
-		return -EOPNOTSUPP;   /* Don't do multiple iovec entries yet */
-
 	if (unlikely(!buf_len))
 		return -EINVAL;
 
@@ -1112,24 +1103,25 @@ restart:
 	/* Capture message data (if valid) & compute return value (always) */
 
 	if (!err) {
-		buf_crs = (unsigned char *)(TIPC_SKB_CB(buf)->handle);
-		sz = (unsigned char *)msg + msg_size(msg) - buf_crs;
+		u32 offset = (u32)(unsigned long)(TIPC_SKB_CB(buf)->handle);
 
+		sz -= offset;
 		needed = (buf_len - sz_copied);
 		sz_to_copy = (sz <= needed) ? sz : needed;
-		if (unlikely(copy_to_user(crs, buf_crs, sz_to_copy))) {
-			res = -EFAULT;
+
+		res = skb_copy_datagram_iovec(buf, msg_hdr_sz(msg) + offset,
+					      m->msg_iov, sz_to_copy);
+		if (res)
 			goto exit;
-		}
+
 		sz_copied += sz_to_copy;
 
 		if (sz_to_copy < sz) {
 			if (!(flags & MSG_PEEK))
-				TIPC_SKB_CB(buf)->handle = buf_crs + sz_to_copy;
+				TIPC_SKB_CB(buf)->handle =
+				(void *)(unsigned long)(offset + sz_to_copy);
 			goto exit;
 		}
-
-		crs += sz_to_copy;
 	} else {
 		if (sz_copied != 0)
 			goto exit; /* can't add error msg to valid data */
@@ -1256,7 +1248,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
 
 	/* Enqueue message (finally!) */
 
-	TIPC_SKB_CB(buf)->handle = msg_data(msg);
+	TIPC_SKB_CB(buf)->handle = 0;
 	atomic_inc(&tipc_queue_size);
 	__skb_queue_tail(&sk->sk_receive_queue, buf);
 
@@ -1608,7 +1600,7 @@ restart:
 		buf = __skb_dequeue(&sk->sk_receive_queue);
 		if (buf) {
 			atomic_dec(&tipc_queue_size);
-			if (TIPC_SKB_CB(buf)->handle != msg_data(buf_msg(buf))) {
+			if (TIPC_SKB_CB(buf)->handle != 0) {
 				buf_discard(buf);
 				goto restart;
 			}
-- 
1.7.3.3

