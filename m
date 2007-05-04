From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 2/4] [SCTP] Fix the SO_REUSEADDR handling to be similar to TCP
Date: Fri,  4 May 2007 16:22:53 -0400
Message-ID: <11783101751746-git-send-email-vladislav.yasevich@hp.com>
References: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:60473 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031533AbXEDUXB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 16:23:01 -0400
In-Reply-To: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the SO_REUSEADDR handling to also check for listen state.  This
was muliple listening server sockets can't be created and they will
not steal packets from each other.
Reported by Paolo Galtieri <pgaltieri@mvista.com>

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |   32 ++++++++++++++++++++++----------
 1 files changed, 22 insertions(+), 10 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 81de560..64fb074 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5020,7 +5020,8 @@ pp_found:
 		struct hlist_node *node;
 
 		SCTP_DEBUG_PRINTK("sctp_get_port() found a possible match\n");
-		if (pp->fastreuse && sk->sk_reuse)
+		if (pp->fastreuse && sk->sk_reuse &&
+			sk->sk_state != SCTP_SS_LISTENING)
 			goto success;
 
 		/* Run through the list of sockets bound to the port
@@ -5037,7 +5038,8 @@ pp_found:
 			struct sctp_endpoint *ep2;
 			ep2 = sctp_sk(sk2)->ep;
 
-			if (reuse && sk2->sk_reuse)
+			if (reuse && sk2->sk_reuse &&
+			    sk2->sk_state != SCTP_SS_LISTENING)
 				continue;
 
 			if (sctp_bind_addr_match(&ep2->base.bind_addr, addr,
@@ -5058,9 +5060,13 @@ pp_not_found:
 	 * if sk->sk_reuse is too (that is, if the caller requested
 	 * SO_REUSEADDR on this socket -sk-).
 	 */
-	if (hlist_empty(&pp->owner))
-		pp->fastreuse = sk->sk_reuse ? 1 : 0;
-	else if (pp->fastreuse && !sk->sk_reuse)
+	if (hlist_empty(&pp->owner)) {
+		if (sk->sk_reuse && sk->sk_state != SCTP_SS_LISTENING)
+			pp->fastreuse = 1;
+		else
+			pp->fastreuse = 0;
+	} else if (pp->fastreuse &&
+		(!sk->sk_reuse || sk->sk_state == SCTP_SS_LISTENING))
 		pp->fastreuse = 0;
 
 	/* We are set, so fill up all the data in the hash table
@@ -5068,8 +5074,8 @@ pp_not_found:
 	 * sockets FIXME: Blurry, NPI (ipg).
 	 */
 success:
-	inet_sk(sk)->num = snum;
 	if (!sctp_sk(sk)->bind_hash) {
+		inet_sk(sk)->num = snum;
 		sk_add_bind_node(sk, &pp->owner);
 		sctp_sk(sk)->bind_hash = pp;
 	}
@@ -5142,12 +5148,16 @@ SCTP_STATIC int sctp_seqpacket_listen(struct sock *sk, int backlog)
 	 * This is not currently spelled out in the SCTP sockets
 	 * extensions draft, but follows the practice as seen in TCP
 	 * sockets.
+	 *
+	 * Additionally, turn off fastreuse flag since we are not listening
 	 */
+	sk->sk_state = SCTP_SS_LISTENING;
 	if (!ep->base.bind_addr.port) {
 		if (sctp_autobind(sk))
 			return -EAGAIN;
-	}
-	sk->sk_state = SCTP_SS_LISTENING;
+	} else
+		sctp_sk(sk)->bind_hash->fastreuse = 0;
+
 	sctp_hash_endpoint(ep);
 	return 0;
 }
@@ -5185,11 +5195,13 @@ SCTP_STATIC int sctp_stream_listen(struct sock *sk, int backlog)
 	 * extensions draft, but follows the practice as seen in TCP
 	 * sockets.
 	 */
+	sk->sk_state = SCTP_SS_LISTENING;
 	if (!ep->base.bind_addr.port) {
 		if (sctp_autobind(sk))
 			return -EAGAIN;
-	}
-	sk->sk_state = SCTP_SS_LISTENING;
+	} else
+		sctp_sk(sk)->bind_hash->fastreuse = 0;
+
 	sk->sk_max_ack_backlog = backlog;
 	sctp_hash_endpoint(ep);
 	return 0;
-- 
1.5.0.3.438.gc49b2

