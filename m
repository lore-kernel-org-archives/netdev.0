From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: [PATCH v2 13/17] tipc_msg_build(): pass msghdr instead of its ->msg_iov
Date: Tue, 25 Nov 2014 14:02:27 +0000
Message-ID: <1416924151-28698-13-git-send-email-viro@ZenIV.linux.org.uk>
References: <20141125024018.GH7996@ZenIV.linux.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:44207 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466AbaKYOCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 09:02:34 -0500
In-Reply-To: <20141125024018.GH7996@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@zeniv.linux.org.uk>

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
 net/tipc/msg.c    |    8 ++++----
 net/tipc/msg.h    |    2 +-
 net/tipc/socket.c |    7 +++----
 3 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index ec18076..9155496 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -162,14 +162,14 @@ err:
 /**
  * tipc_msg_build - create buffer chain containing specified header and data
  * @mhdr: Message header, to be prepended to data
- * @iov: User data
+ * @m: User message
  * @offset: Posision in iov to start copying from
  * @dsz: Total length of user data
  * @pktmax: Max packet size that can be used
  * @chain: Buffer or chain of buffers to be returned to caller
  * Returns message data size or errno: -ENOMEM, -EFAULT
  */
-int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
+int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int pktmax , struct sk_buff **chain)
 {
 	int mhsz = msg_hdr_sz(mhdr);
@@ -194,7 +194,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
 		skb_copy_to_linear_data(buf, mhdr, mhsz);
 		pktpos = buf->data + mhsz;
 		TIPC_SKB_CB(buf)->chain_sz = 1;
-		if (!dsz || !memcpy_fromiovecend(pktpos, iov, offset, dsz))
+		if (!dsz || !memcpy_fromiovecend(pktpos, m->msg_iov, offset, dsz))
 			return dsz;
 		rc = -EFAULT;
 		goto error;
@@ -223,7 +223,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
 		if (drem < pktrem)
 			pktrem = drem;
 
-		if (memcpy_fromiovecend(pktpos, iov, offset, pktrem)) {
+		if (memcpy_fromiovecend(pktpos, m->msg_iov, offset, pktrem)) {
 			rc = -EFAULT;
 			goto error;
 		}
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 0ea7b69..d7d2ba2 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -743,7 +743,7 @@ bool tipc_msg_bundle(struct sk_buff *bbuf, struct sk_buff *buf, u32 mtu);
 
 bool tipc_msg_make_bundle(struct sk_buff **buf, u32 mtu, u32 dnode);
 
-int tipc_msg_build(struct tipc_msg *mhdr, struct iovec const *iov,
+int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int mtu , struct sk_buff **chain);
 
 struct sk_buff *tipc_msg_reassemble(struct sk_buff *chain);
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 2d4b2fa..b3415a7 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -727,7 +727,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
-	rc = tipc_msg_build(mhdr, msg->msg_iov, 0, dsz, mtu, &buf);
+	rc = tipc_msg_build(mhdr, msg, 0, dsz, mtu, &buf);
 	if (unlikely(rc < 0))
 		return rc;
 
@@ -905,7 +905,6 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sock *sk = sock->sk;
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct tipc_msg *mhdr = &tsk->phdr;
-	struct iovec *iov = m->msg_iov;
 	u32 dnode, dport;
 	struct sk_buff *buf;
 	struct tipc_name_seq *seq = &dest->addr.nameseq;
@@ -982,7 +981,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 
 new_mtu:
 	mtu = tipc_node_get_mtu(dnode, tsk->ref);
-	rc = tipc_msg_build(mhdr, iov, 0, dsz, mtu, &buf);
+	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &buf);
 	if (rc < 0)
 		goto exit;
 
@@ -1094,7 +1093,7 @@ static int tipc_send_stream(struct kiocb *iocb, struct socket *sock,
 next:
 	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
-	rc = tipc_msg_build(mhdr, m->msg_iov, sent, send, mtu, &buf);
+	rc = tipc_msg_build(mhdr, m, sent, send, mtu, &buf);
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
-- 
1.7.10.4
