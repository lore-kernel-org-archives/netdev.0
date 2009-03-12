From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 1/4] sctp: simplify sctp listening code
Date: Thu, 12 Mar 2009 15:49:17 -0400
Message-ID: <1236887360-1904-2-git-send-email-vladislav.yasevich@hp.com>
References: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:45289 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754410AbZCLTtZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 15:49:25 -0400
In-Reply-To: <1236887360-1904-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_inet_listen() call is split between UDP and TCP style.  Looking
at the code, the two functions are almost the same and can be
merged into a single helper.  This also fixes a bug that was
fixed in the UDP function, but missed in the TCP function.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |  152 +++++++++++++++++-----------------------------------
 1 files changed, 50 insertions(+), 102 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index bbd3cd2..5fb3a8c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5843,37 +5843,28 @@ static int sctp_get_port(struct sock *sk, unsigned short snum)
 }
 
 /*
- * 3.1.3 listen() - UDP Style Syntax
- *
- *   By default, new associations are not accepted for UDP style sockets.
- *   An application uses listen() to mark a socket as being able to
- *   accept new associations.
+ *  Move a socket to LISTENING state.
  */
-SCTP_STATIC int sctp_seqpacket_listen(struct sock *sk, int backlog)
+SCTP_STATIC int sctp_listen_start(struct sock *sk, int backlog)
 {
 	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
+	struct crypto_hash *tfm = NULL;
 
-	/* Only UDP style sockets that are not peeled off are allowed to
-	 * listen().
-	 */
-	if (!sctp_style(sk, UDP))
-		return -EINVAL;
-
-	/* If backlog is zero, disable listening. */
-	if (!backlog) {
-		if (sctp_sstate(sk, CLOSED))
-			return 0;
-
-		sctp_unhash_endpoint(ep);
-		sk->sk_state = SCTP_SS_CLOSED;
-		return 0;
+	/* Allocate HMAC for generating cookie. */
+	if (!sctp_sk(sk)->hmac && sctp_hmac_alg) {
+		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
+		if (IS_ERR(tfm)) {
+			if (net_ratelimit()) {
+				printk(KERN_INFO
+				       "SCTP: failed to load transform for %s: %ld\n",
+					sctp_hmac_alg, PTR_ERR(tfm));
+			}
+			return -ENOSYS;
+		}
+		sctp_sk(sk)->hmac = tfm;
 	}
 
-	/* Return if we are already listening. */
-	if (sctp_sstate(sk, LISTENING))
-		return 0;
-
 	/*
 	 * If a bind() or sctp_bindx() is not called prior to a listen()
 	 * call that allows new associations to be accepted, the system
@@ -5884,7 +5875,6 @@ SCTP_STATIC int sctp_seqpacket_listen(struct sock *sk, int backlog)
 	 * extensions draft, but follows the practice as seen in TCP
 	 * sockets.
 	 *
-	 * Additionally, turn off fastreuse flag since we are not listening
 	 */
 	sk->sk_state = SCTP_SS_LISTENING;
 	if (!ep->base.bind_addr.port) {
@@ -5895,113 +5885,71 @@ SCTP_STATIC int sctp_seqpacket_listen(struct sock *sk, int backlog)
 			sk->sk_state = SCTP_SS_CLOSED;
 			return -EADDRINUSE;
 		}
-		sctp_sk(sk)->bind_hash->fastreuse = 0;
 	}
 
-	sctp_hash_endpoint(ep);
-	return 0;
-}
-
-/*
- * 4.1.3 listen() - TCP Style Syntax
- *
- *   Applications uses listen() to ready the SCTP endpoint for accepting
- *   inbound associations.
- */
-SCTP_STATIC int sctp_stream_listen(struct sock *sk, int backlog)
-{
-	struct sctp_sock *sp = sctp_sk(sk);
-	struct sctp_endpoint *ep = sp->ep;
-
-	/* If backlog is zero, disable listening. */
-	if (!backlog) {
-		if (sctp_sstate(sk, CLOSED))
-			return 0;
-
-		sctp_unhash_endpoint(ep);
-		sk->sk_state = SCTP_SS_CLOSED;
-		return 0;
-	}
-
-	if (sctp_sstate(sk, LISTENING))
-		return 0;
-
-	/*
-	 * If a bind() or sctp_bindx() is not called prior to a listen()
-	 * call that allows new associations to be accepted, the system
-	 * picks an ephemeral port and will choose an address set equivalent
-	 * to binding with a wildcard address.
-	 *
-	 * This is not currently spelled out in the SCTP sockets
-	 * extensions draft, but follows the practice as seen in TCP
-	 * sockets.
-	 */
-	sk->sk_state = SCTP_SS_LISTENING;
-	if (!ep->base.bind_addr.port) {
-		if (sctp_autobind(sk))
-			return -EAGAIN;
-	} else
-		sctp_sk(sk)->bind_hash->fastreuse = 0;
-
 	sk->sk_max_ack_backlog = backlog;
 	sctp_hash_endpoint(ep);
 	return 0;
 }
 
 /*
+ * 4.1.3 / 5.1.3 listen()
+ *
+ *   By default, new associations are not accepted for UDP style sockets.
+ *   An application uses listen() to mark a socket as being able to
+ *   accept new associations.
+ *
+ *   On TCP style sockets, applications use listen() to ready the SCTP
+ *   endpoint for accepting inbound associations.
+ *
+ *   On both types of endpoints a backlog of '0' disables listening.
+ *
  *  Move a socket to LISTENING state.
  */
 int sctp_inet_listen(struct socket *sock, int backlog)
 {
 	struct sock *sk = sock->sk;
-	struct crypto_hash *tfm = NULL;
+	struct sctp_endpoint *ep = sctp_sk(sk)->ep;
 	int err = -EINVAL;
 
 	if (unlikely(backlog < 0))
-		goto out;
+		return err;
 
 	sctp_lock_sock(sk);
 
+	/* Peeled-off sockets are not allowed to listen().  */
+	if (sctp_style(sk, UDP_HIGH_BANDWIDTH))
+		goto out;
+
 	if (sock->state != SS_UNCONNECTED)
 		goto out;
 
-	/* Allocate HMAC for generating cookie. */
-	if (!sctp_sk(sk)->hmac && sctp_hmac_alg) {
-		tfm = crypto_alloc_hash(sctp_hmac_alg, 0, CRYPTO_ALG_ASYNC);
-		if (IS_ERR(tfm)) {
-			if (net_ratelimit()) {
-				printk(KERN_INFO
-				       "SCTP: failed to load transform for %s: %ld\n",
-					sctp_hmac_alg, PTR_ERR(tfm));
-			}
-			err = -ENOSYS;
+	/* If backlog is zero, disable listening. */
+	if (!backlog) {
+		if (sctp_sstate(sk, CLOSED))
 			goto out;
-		}
-	}
 
-	switch (sock->type) {
-	case SOCK_SEQPACKET:
-		err = sctp_seqpacket_listen(sk, backlog);
-		break;
-	case SOCK_STREAM:
-		err = sctp_stream_listen(sk, backlog);
-		break;
-	default:
-		break;
+		err = 0;
+		sctp_unhash_endpoint(ep);
+		sk->sk_state = SCTP_SS_CLOSED;
+		if (sk->sk_reuse)
+			sctp_sk(sk)->bind_hash->fastreuse = 1;
+		goto out;
 	}
 
-	if (err)
-		goto cleanup;
+	/* If we are already listening, just update the backlog */
+	if (sctp_sstate(sk, LISTENING))
+		sk->sk_max_ack_backlog = backlog;
+	else {
+		err = sctp_listen_start(sk, backlog);
+		if (err)
+			goto out;
+	}
 
-	/* Store away the transform reference. */
-	if (!sctp_sk(sk)->hmac)
-		sctp_sk(sk)->hmac = tfm;
+	err = 0;
 out:
 	sctp_release_sock(sk);
 	return err;
-cleanup:
-	crypto_free_hash(tfm);
-	goto out;
 }
 
 /*
-- 
1.5.4.3

