From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 7/8] [PATCH] af_iucv: cleanup and refactor recvmsg() EFAULT handling
Date: Wed, 22 Apr 2009 11:26:26 +0200
Message-ID: <20090422093430.589516000@linux.vnet.ibm.com>
References: <20090422092619.451973000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:50248 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753475AbZDVJec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 05:34:32 -0400
Content-Disposition: inline; filename=611-af_iucv-recvmsg.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

If the skb cannot be copied to user iovec, always return -EFAULT.
The skb is enqueued again, except MSG_PEEK flag is set, to allow user space
applications to correct its iovec pointer.

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |   10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

Index: net-next-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-next-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-next-2.6-uschi/net/iucv/af_iucv.c
@@ -965,7 +965,6 @@ static int iucv_sock_recvmsg(struct kioc
 	int noblock = flags & MSG_DONTWAIT;
 	struct sock *sk = sock->sk;
 	struct iucv_sock *iucv = iucv_sk(sk);
-	int target;
 	unsigned int copied, rlen;
 	struct sk_buff *skb, *rskb, *cskb;
 	int err = 0;
@@ -979,8 +978,6 @@ static int iucv_sock_recvmsg(struct kioc
 	if (flags & (MSG_OOB))
 		return -EOPNOTSUPP;
 
-	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);
-
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb) {
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
@@ -993,10 +990,9 @@ static int iucv_sock_recvmsg(struct kioc
 
 	cskb = skb;
 	if (memcpy_toiovec(msg->msg_iov, cskb->data, copied)) {
-		skb_queue_head(&sk->sk_receive_queue, skb);
-		if (copied == 0)
-			return -EFAULT;
-		goto done;
+		if (!(flags & MSG_PEEK))
+			skb_queue_head(&sk->sk_receive_queue, skb);
+		return -EFAULT;
 	}
 
 	/* SOCK_SEQPACKET: set MSG_TRUNC if recv buf size is too small */

