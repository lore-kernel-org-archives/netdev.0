From: James Chapman <jchapman@katalix.com>
Subject: [PATCH net-2.6] L2TP: Fix potential memory corruption in pppol2tp_recvmsg()
Date: Tue, 10 Jun 2008 13:34:24 +0100
Message-ID: <200806101234.m5ACYOI4004732@quickie.katalix.com>
Cc: ilja@netric.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:50708 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753137AbYFJMfn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jun 2008 08:35:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a potential memory corruption in
pppol2tp_recvmsg(). If skb->len is bigger than the caller's buffer
length, memcpy_toiovec() will go into unintialized data on the kernel
heap, interpret it as an iovec and start modifying memory.

The fix is to change the memcpy_toiovec() call to
skb_copy_datagram_iovec() so that paged packets (rare for PPPOL2TP)
are handled properly. Also check that the caller's buffer is big
enough for the data and set the MSG_TRUNC flag if it is not so.

Reported-by: Ilja <ilja@netric.org>
Signed-off-by: James Chapman <jchapman@katalix.com>

--

A candidate for -stable?

Index: net-2.6/drivers/net/pppol2tp.c
===================================================================
--- net-2.6.orig/drivers/net/pppol2tp.c
+++ net-2.6/drivers/net/pppol2tp.c
@@ -783,14 +783,18 @@ static int pppol2tp_recvmsg(struct kiocb
 	err = 0;
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &err);
-	if (skb) {
-		err = memcpy_toiovec(msg->msg_iov, (unsigned char *) skb->data,
-				     skb->len);
-		if (err < 0)
-			goto do_skb_free;
-		err = skb->len;
-	}
-do_skb_free:
+	if (!skb)
+		goto end;
+
+	if (len > skb->len)
+		len = skb->len;
+	else if (len < skb->len)
+		msg->msg_flags |= MSG_TRUNC;
+
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, len);
+	if (likely(err == 0))
+		err = len;
+
 	kfree_skb(skb);
 end:
 	return err;
