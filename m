From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH 5/5] atm: Allow MSG_PEEK for atm sockets
Date: Mon, 21 Nov 2011 21:25:58 +0100
Message-ID: <1321907158-27857-6-git-send-email-jorge@dti2.net>
References: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Reply-To: jorge@dti2.net
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
To: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:56419 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754565Ab1KUU0S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 15:26:18 -0500
Received: from nikopol.intranet.dti2.net ([81.24.160.13])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019764598.msg
	for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 21:26:15 +0100
In-Reply-To: <1321907158-27857-1-git-send-email-jorge@dti2.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>

    Now that the vcc backends do the right thing with respect the receive
queue on registration, allow MSK_PEEK for atm sockets.

    This allows a userspace program to inspect the packets and decide what
backend to use to handle them.

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
 net/atm/common.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/atm/common.c b/net/atm/common.c
index 0b4c58f..b4b44db 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -522,8 +522,11 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 
 	if (sock->state != SS_CONNECTED)
 		return -ENOTCONN;
-	if (flags & ~MSG_DONTWAIT)		/* only handle MSG_DONTWAIT */
+
+	/* only handle MSG_DONTWAIT and MSG_PEEK */
+	if (flags & ~(MSG_DONTWAIT | MSG_PEEK))
 		return -EOPNOTSUPP;
+
 	vcc = ATM_SD(sock);
 	if (test_bit(ATM_VF_RELEASED, &vcc->flags) ||
 	    test_bit(ATM_VF_CLOSE, &vcc->flags) ||
@@ -544,8 +547,13 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	if (error)
 		return error;
 	sock_recv_ts_and_drops(msg, sk, skb);
-	pr_debug("%d -= %d\n", atomic_read(&sk->sk_rmem_alloc), skb->truesize);
-	atm_return(vcc, skb->truesize);
+
+	if (!(flags & MSG_PEEK)) {
+		pr_debug("%d -= %d\n", atomic_read(&sk->sk_rmem_alloc),
+			 skb->truesize);
+		atm_return(vcc, skb->truesize);
+	}
+
 	skb_free_datagram(sk, skb);
 	return copied;
 }
-- 
1.7.7.1
