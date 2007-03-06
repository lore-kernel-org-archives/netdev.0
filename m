From: David Miller <davem@davemloft.net>
Subject: [PATCH]: Revert accept queue backlog change.
Date: Tue, 06 Mar 2007 11:19:00 -0800 (PST)
Message-ID: <20070306.111900.41634576.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weid@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42046
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932881AbXCFTTD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 14:19:03 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Wei, I have to revert your change, it is incorrect as pointed
out by other people here on netdev.

BSD sockets basically define the 'backlog' parameter to listen()
to mean "allow backlog + 1" connections to be queued to the socket.
This allows a backlog parameter of "0" to allow 1 connection, and
there are real applications which do this.

diff --git a/include/net/sock.h b/include/net/sock.h
index 849c7df..2c7d60c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -426,7 +426,7 @@ static inline void sk_acceptq_added(struct sock *sk)
 
 static inline int sk_acceptq_is_full(struct sock *sk)
 {
-	return sk->sk_ack_backlog >= sk->sk_max_ack_backlog;
+	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
 }
 
 /*
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 51ca438..6069716 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -934,7 +934,7 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
 
 	sched = !sock_flag(other, SOCK_DEAD) &&
 		!(other->sk_shutdown & RCV_SHUTDOWN) &&
-		(skb_queue_len(&other->sk_receive_queue) >=
+		(skb_queue_len(&other->sk_receive_queue) >
 		 other->sk_max_ack_backlog);
 
 	unix_state_runlock(other);
@@ -1008,7 +1008,7 @@ restart:
 	if (other->sk_state != TCP_LISTEN)
 		goto out_unlock;
 
-	if (skb_queue_len(&other->sk_receive_queue) >=
+	if (skb_queue_len(&other->sk_receive_queue) >
 	    other->sk_max_ack_backlog) {
 		err = -EAGAIN;
 		if (!timeo)
@@ -1381,7 +1381,7 @@ restart:
 	}
 
 	if (unix_peer(other) != sk &&
-	    (skb_queue_len(&other->sk_receive_queue) >=
+	    (skb_queue_len(&other->sk_receive_queue) >
 	     other->sk_max_ack_backlog)) {
 		if (!timeo) {
 			err = -EAGAIN;
