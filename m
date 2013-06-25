From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v3 5/6] net: sctp: decouple cleaning some socket data from endpoint
Date: Tue, 25 Jun 2013 18:17:29 +0200
Message-ID: <1372177050-17829-6-git-send-email-dborkman@redhat.com>
References: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3697 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751261Ab3FYQRk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 12:17:40 -0400
In-Reply-To: <1372177050-17829-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather instead of having the endpoint clean the garbage from the
socket, use a sk_destruct handler sctp_destruct_sock(), that does
the job for that when there are no more references on the socket.
At least do this for our crypto transform through crypto_free_hash()
that is allocated when in listening state.

Also, perform sctp_put_port() only when sk is valid. At a later
point in time we can still determine if there's an option of
placing this into sk_prot->unhash() or sctp_endpoint_free() without
any races. For now, leave it in sctp_endpoint_destroy() though.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/endpointola.c | 19 ++++++++++---------
 net/sctp/socket.c      | 16 +++++++++++++++-
 2 files changed, 25 insertions(+), 10 deletions(-)

diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index a8b2674..b26999d 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -247,10 +247,9 @@ void sctp_endpoint_free(struct sctp_endpoint *ep)
 /* Final destructor for endpoint.  */
 static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 {
-	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
+	struct sock *sk;
 
-	/* Free up the HMAC transform. */
-	crypto_free_hash(sctp_sk(ep->base.sk)->hmac);
+	SCTP_ASSERT(ep->base.dead, "Endpoint is not dead", return);
 
 	/* Free the digest buffer */
 	kfree(ep->digest);
@@ -271,13 +270,15 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
 
 	memset(ep->secret_key, 0, sizeof(ep->secret_key));
 
-	/* Remove and free the port */
-	if (sctp_sk(ep->base.sk)->bind_hash)
-		sctp_put_port(ep->base.sk);
-
 	/* Give up our hold on the sock. */
-	if (ep->base.sk)
-		sock_put(ep->base.sk);
+	sk = ep->base.sk;
+	if (sk != NULL) {
+		/* Remove and free the port */
+		if (sctp_sk(sk)->bind_hash)
+			sctp_put_port(sk);
+
+		sock_put(sk);
+	}
 
 	kfree(ep);
 	SCTP_DBG_OBJCNT_DEC(ep);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 4c47e55..ba9359c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -93,6 +93,7 @@ static int sctp_wait_for_packet(struct sock * sk, int *err, long *timeo_p);
 static int sctp_wait_for_connect(struct sctp_association *, long *timeo_p);
 static int sctp_wait_for_accept(struct sock *sk, long timeo);
 static void sctp_wait_for_close(struct sock *sk, long timeo);
+static void sctp_destruct_sock(struct sock *sk);
 static struct sctp_af *sctp_sockaddr_af(struct sctp_sock *opt,
 					union sctp_addr *addr, int len);
 static int sctp_bindx_add(struct sock *, struct sockaddr *, int);
@@ -3966,6 +3967,8 @@ static int sctp_init_sock(struct sock *sk)
 
 	sp->hmac = NULL;
 
+	sk->sk_destruct = sctp_destruct_sock;
+
 	SCTP_DBG_OBJCNT_INC(sock);
 
 	local_bh_disable();
@@ -4008,6 +4011,17 @@ static void sctp_destroy_sock(struct sock *sk)
 	local_bh_enable();
 }
 
+/* Triggered when there are no references on the socket anymore */
+static void sctp_destruct_sock(struct sock *sk)
+{
+	struct sctp_sock *sp = sctp_sk(sk);
+
+	/* Free up the HMAC transform. */
+	crypto_free_hash(sp->hmac);
+
+	inet_sock_destruct(sk);
+}
+
 /* API 4.1.7 shutdown() - TCP Style Syntax
  *     int shutdown(int socket, int how);
  *
@@ -6848,7 +6862,7 @@ void sctp_copy_sock(struct sock *newsk, struct sock *sk,
 	newsk->sk_reuse = sk->sk_reuse;
 
 	newsk->sk_shutdown = sk->sk_shutdown;
-	newsk->sk_destruct = inet_sock_destruct;
+	newsk->sk_destruct = sctp_destruct_sock;
 	newsk->sk_family = sk->sk_family;
 	newsk->sk_protocol = IPPROTO_SCTP;
 	newsk->sk_backlog_rcv = sk->sk_prot->backlog_rcv;
-- 
1.7.11.7
