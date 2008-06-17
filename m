From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Kill decent's use of SOCK_SLEEP_{PRE,POST}
Date: Tue, 17 Jun 2008 01:07:52 -0700 (PDT)
Message-ID: <20080617.010752.267137214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christine.caulfield@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46862
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753175AbYFQIHv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 04:07:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This macro has only one user, and it's been on the chopping
block for a long time.

This expansion actually fixes bugs, in that decnet now respects
the socket timeout properly.

Applied and pushed to net-next-2.6

decnet: Remove SOCK_SLEEP_{PRE,POST} usage.

Just expand the wait sequence.  And as a nice side-effect
the timeout is respected now.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/decnet/af_decnet.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index fc2efe8..931bdf9 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -1719,6 +1719,8 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 	 * See if there is data ready to read, sleep if there isn't
 	 */
 	for(;;) {
+		DEFINE_WAIT(wait);
+
 		if (sk->sk_err)
 			goto out;
 
@@ -1748,14 +1750,11 @@ static int dn_recvmsg(struct kiocb *iocb, struct socket *sock,
 			goto out;
 		}
 
-		set_bit(SOCK_ASYNC_WAITDATA, &sock->flags);
-		SOCK_SLEEP_PRE(sk)
-
-		if (!dn_data_ready(sk, queue, flags, target))
-			schedule();
-
-		SOCK_SLEEP_POST(sk)
-		clear_bit(SOCK_ASYNC_WAITDATA, &sock->flags);
+		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+		set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		sk_wait_event(sk, &timeo, dn_data_ready(sk, queue, flags, target));
+		clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+		finish_wait(sk->sk_sleep, &wait);
 	}
 
 	for(skb = queue->next; skb != (struct sk_buff *)queue; skb = nskb) {
@@ -2002,18 +2001,19 @@ static int dn_sendmsg(struct kiocb *iocb, struct socket *sock,
 		 * size.
 		 */
 		if (dn_queue_too_long(scp, queue, flags)) {
+			DEFINE_WAIT(wait);
+
 			if (flags & MSG_DONTWAIT) {
 				err = -EWOULDBLOCK;
 				goto out;
 			}
 
-			SOCK_SLEEP_PRE(sk)
-
-			if (dn_queue_too_long(scp, queue, flags))
-				schedule();
-
-			SOCK_SLEEP_POST(sk)
-
+			prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
+			set_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+			sk_wait_event(sk, &timeo,
+				      !dn_queue_too_long(scp, queue, flags));
+			clear_bit(SOCK_ASYNC_WAITDATA, &sk->sk_socket->flags);
+			finish_wait(sk->sk_sleep, &wait);
 			continue;
 		}
 
-- 
1.5.5.1.308.g1fbb5

