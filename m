From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 1/3] [IrDA] af_irda.c cleanups
Date: Mon, 11 Sep 2006 08:46:36 +0300
Message-ID: <20060911054636.GA6368@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.pp.htv.fi ([213.243.153.37]:37263 "EHLO smtp1.pp.htv.fi")
	by vger.kernel.org with ESMTP id S932153AbWIJWcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Sep 2006 18:32:25 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

We lock the socket when both releasing and getting a disconnected
notification. In the latter case, we also ste the socket as orphan.
This fixes a potential kernel bug that can be triggered when we get the
disconnection notification before closing the socket.

Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/af_irda.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 17699ee..7b7cd5b 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -132,13 +132,14 @@ static void irda_disconnect_indication(v
 
 	/* Prevent race conditions with irda_release() and irda_shutdown() */
 	if (!sock_flag(sk, SOCK_DEAD) && sk->sk_state != TCP_CLOSE) {
+		lock_sock(sk);
 		sk->sk_state     = TCP_CLOSE;
 		sk->sk_err       = ECONNRESET;
 		sk->sk_shutdown |= SEND_SHUTDOWN;
 
 		sk->sk_state_change(sk);
-		/* Uh-oh... Should use sock_orphan ? */
-                sock_set_flag(sk, SOCK_DEAD);
+                sock_orphan(sk);
+		release_sock(sk);
 
 		/* Close our TSAP.
 		 * If we leave it open, IrLMP put it back into the list of
@@ -1212,6 +1213,7 @@ static int irda_release(struct socket *s
         if (sk == NULL)
 		return 0;
 
+	lock_sock(sk);
 	sk->sk_state       = TCP_CLOSE;
 	sk->sk_shutdown   |= SEND_SHUTDOWN;
 	sk->sk_state_change(sk);
@@ -1221,6 +1223,7 @@ static int irda_release(struct socket *s
 
 	sock_orphan(sk);
 	sock->sk   = NULL;
+	release_sock(sk);
 
 	/* Purge queues (see sock_init_data()) */
 	skb_queue_purge(&sk->sk_receive_queue);
@@ -1353,6 +1356,7 @@ static int irda_recvmsg_dgram(struct kio
 	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(!sock_error(sk), return -1;);
 
 	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
 				flags & MSG_DONTWAIT, &err);
@@ -1405,6 +1409,7 @@ static int irda_recvmsg_stream(struct ki
 	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
+	IRDA_ASSERT(!sock_error(sk), return -1;);
 
 	if (sock->flags & __SO_ACCEPTCON)
 		return(-EINVAL);
-- 
1.4.1.1

