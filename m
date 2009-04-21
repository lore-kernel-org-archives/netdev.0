From: Ursula Braun <ursula.braun@de.ibm.com>
Subject: [patch 2/5] [PATCH] af_iucv: fix oops in iucv_sock_recvmsg() for MSG_PEEK flag
Date: Tue, 21 Apr 2009 18:04:21 +0200
Message-ID: <20090421161444.433278000@linux.vnet.ibm.com>
References: <20090421160419.971500000@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	Hendrik Brueckner <brueckner@linux.vnet.ibm.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:58948 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754095AbZDUQOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 12:14:50 -0400
Content-Disposition: inline; filename=603-af_iucv-oops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>

If iucv_sock_recvmsg() is called with MSG_PEEK flag set, the skb is enqueued
twice. If the socket is then closed, the pointer to the skb is freed twice.

Remove the skb_queue_head() call for MSG_PEEK, because the skb_recv_datagram()
function already handles MSG_PEEK (does not dequeue the skb).

Signed-off-by: Hendrik Brueckner <brueckner@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---

 net/iucv/af_iucv.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6-uschi/net/iucv/af_iucv.c
===================================================================
--- net-2.6-uschi.orig/net/iucv/af_iucv.c
+++ net-2.6-uschi/net/iucv/af_iucv.c
@@ -814,6 +814,8 @@ static int iucv_sock_recvmsg(struct kioc
 
 	target = sock_rcvlowat(sk, flags & MSG_WAITALL, len);
 
+	/* receive/dequeue next skb:
+	 * the function understands MSG_PEEK and, thus, does not dequeue skb */
 	skb = skb_recv_datagram(sk, flags, noblock, &err);
 	if (!skb) {
 		if (sk->sk_shutdown & RCV_SHUTDOWN)
@@ -861,9 +863,7 @@ static int iucv_sock_recvmsg(struct kioc
 				iucv_process_message_q(sk);
 			spin_unlock_bh(&iucv->message_q.lock);
 		}
-
-	} else
-		skb_queue_head(&sk->sk_receive_queue, skb);
+	}
 
 done:
 	return err ? : copied;

