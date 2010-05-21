From: sjur.brandeland@stericsson.com
Subject: [PATCH net-2.6 6/6] caif: Bugfix - use MSG_TRUNC in receive
Date: Fri, 21 May 2010 14:16:12 +0200
Message-ID: <1274444172-31969-6-git-send-email-sjur.brandeland@stericsson.com>
References: <1274444172-31969-1-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-2-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-3-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-4-git-send-email-sjur.brandeland@stericsson.com>
 <1274444172-31969-5-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: 7BIT
Cc: sjurbr@gmail.com, linus.walleij@stericsson.com,
	marcel@holtmann.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:44152 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215Ab0EUMQt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 08:16:49 -0400
Received: from ignis-smin.broadpark.no ([unknown] [80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R003U2RFBK140@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:23 +0200 (CEST)
Received: from localhost.localdomain ([unknown] [84.49.77.207])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-12.01 64bit (built Oct 15 2009))
 with ESMTP id <0L2R006WURF8S590@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Fri, 21 May 2010 14:16:23 +0200 (CEST)
In-reply-to: <1274444172-31969-5-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sjur Braendeland <sjur.brandeland@stericsson.com>

Fixed handling when skb don't fit in user buffer,
instead of returning -EMSGSIZE, the buffer is truncated (just
as unix seqpakcet does).

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
 net/caif/caif_socket.c |   47 ++++++++++++++++++-----------------------------
 1 files changed, 18 insertions(+), 29 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 691a571..3d0e095 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -292,53 +292,42 @@ static void caif_check_flow_release(struct sock *sk)
 			caif_flow_ctrl(sk, CAIF_MODEMCMD_FLOW_ON_REQ);
 	}
 }
+
 /*
- * Copied from sock.c:sock_queue_rcv_skb(), and added check that user buffer
- * has sufficient size.
+ * Copied from unix_dgram_recvmsg, but removed credit checks,
+ * changed locking, address handling and added MSG_TRUNC.
  */
-
 static int caif_seqpkt_recvmsg(struct kiocb *iocb, struct socket *sock,
-				struct msghdr *m, size_t buf_len, int flags)
+				struct msghdr *m, size_t len, int flags)
 
 {
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
-	int ret = 0;
-	int len;
+	int ret;
+	int copylen;
 
-	if (unlikely(!buf_len))
-		return -EINVAL;
+	ret = -EOPNOTSUPP;
+	if (m->msg_flags&MSG_OOB)
+		goto read_error;
 
 	skb = skb_recv_datagram(sk, flags, 0 , &ret);
 	if (!skb)
 		goto read_error;
-
-	len = skb->len;
-
-	if (skb && skb->len > buf_len && !(flags & MSG_PEEK)) {
-		len = buf_len;
-		/*
-		 * Push skb back on receive queue if buffer too small.
-		 * This has a built-in race where multi-threaded receive
-		 * may get packet in wrong order, but multiple read does
-		 * not really guarantee ordered delivery anyway.
-		 * Let's optimize for speed without taking locks.
-		 */
-
-		skb_queue_head(&sk->sk_receive_queue, skb);
-		ret = -EMSGSIZE;
-		goto read_error;
+	copylen = skb->len;
+	if (len < copylen) {
+		m->msg_flags |= MSG_TRUNC;
+		copylen = len;
 	}
 
-	ret = skb_copy_datagram_iovec(skb, 0, m->msg_iov, len);
+	ret = skb_copy_datagram_iovec(skb, 0, m->msg_iov, copylen);
 	if (ret)
-		goto read_error;
+		goto out_free;
 
+	ret = (flags & MSG_TRUNC) ? skb->len : copylen;
+out_free:
 	skb_free_datagram(sk, skb);
-
 	caif_check_flow_release(sk);
-
-	return len;
+	return ret;
 
 read_error:
 	return ret;
-- 
1.6.3.3

