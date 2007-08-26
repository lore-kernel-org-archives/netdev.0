From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 1/3] [IrDA] MSG_NOSIGNAL support for IrDA sockets
Date: Mon, 27 Aug 2007 01:15:15 +0300
Message-ID: <20070826221927.740053374@sortiz.org>
References: <20070826221514.036436030@sortiz.org>
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:61327 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078AbXHZWTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Aug 2007 18:19:30 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2e18.orange.fr (SMTP Server) with ESMTP id 98CE170000A3
	for <netdev@vger.kernel.org>; Mon, 27 Aug 2007 00:19:28 +0200 (CEST)
Content-Disposition: inline; filename=irda_socket_msg_nosignal
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/af_irda.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

Index: net-2.6.24-quilt/net/irda/af_irda.c
===================================================================
--- net-2.6.24-quilt.orig/net/irda/af_irda.c	2007-08-25 02:41:39.000000000 +0300
+++ net-2.6.24-quilt/net/irda/af_irda.c	2007-08-25 02:41:41.000000000 +0300
@@ -1245,18 +1245,17 @@
 	struct sock *sk = sock->sk;
 	struct irda_sock *self;
 	struct sk_buff *skb;
-	int err;
+	int err = -EPIPE;
 
 	IRDA_DEBUG(4, "%s(), len=%zd\n", __FUNCTION__, len);
 
 	/* Note : socket.c set MSG_EOR on SEQPACKET sockets */
-	if (msg->msg_flags & ~(MSG_DONTWAIT|MSG_EOR|MSG_CMSG_COMPAT))
+	if (msg->msg_flags & ~(MSG_DONTWAIT | MSG_EOR | MSG_CMSG_COMPAT |
+			       MSG_NOSIGNAL))
 		return -EINVAL;
 
-	if (sk->sk_shutdown & SEND_SHUTDOWN) {
-		send_sig(SIGPIPE, current, 0);
-		return -EPIPE;
-	}
+	if (sk->sk_shutdown & SEND_SHUTDOWN)
+		goto out_err;
 
 	if (sk->sk_state != TCP_ESTABLISHED)
 		return -ENOTCONN;
@@ -1283,7 +1282,7 @@
 	skb = sock_alloc_send_skb(sk, len + self->max_header_size + 16,
 				  msg->msg_flags & MSG_DONTWAIT, &err);
 	if (!skb)
-		return -ENOBUFS;
+		goto out_err;
 
 	skb_reserve(skb, self->max_header_size + 16);
 	skb_reset_transport_header(skb);
@@ -1291,7 +1290,7 @@
 	err = memcpy_fromiovec(skb_transport_header(skb), msg->msg_iov, len);
 	if (err) {
 		kfree_skb(skb);
-		return err;
+		goto out_err;
 	}
 
 	/*
@@ -1301,10 +1300,14 @@
 	err = irttp_data_request(self->tsap, skb);
 	if (err) {
 		IRDA_DEBUG(0, "%s(), err=%d\n", __FUNCTION__, err);
-		return err;
+		goto out_err;
 	}
 	/* Tell client how much data we actually sent */
 	return len;
+
+ out_err:
+	return sk_stream_error(sk, msg->msg_flags, err);
+
 }
 
 /*

-- 

