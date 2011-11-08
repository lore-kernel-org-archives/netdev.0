From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: rename sk_clone to sk_clone_lock
Date: Tue, 08 Nov 2011 23:00:08 +0100
Message-ID: <1320789608.26025.14.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49674 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899Ab1KHWAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 17:00:12 -0500
Received: by wyh15 with SMTP id 15so1008067wyh.19
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2011 14:00:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make clear that sk_clone() and inet_csk_clone() return a locked socket.

Add _lock() prefix and kerneldoc.

Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inet_connection_sock.h |    6 +++---
 include/net/sock.h                 |    4 ++--
 net/core/sock.c                    |   11 +++++++++--
 net/dccp/minisocks.c               |    2 +-
 net/ipv4/inet_connection_sock.c    |   17 +++++++++++++----
 net/ipv4/tcp_minisocks.c           |    2 +-
 6 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index e6db62e..dbf9aab 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -143,9 +143,9 @@ static inline void *inet_csk_ca(const struct sock *sk)
 	return (void *)inet_csk(sk)->icsk_ca_priv;
 }
 
-extern struct sock *inet_csk_clone(struct sock *sk,
-				   const struct request_sock *req,
-				   const gfp_t priority);
+extern struct sock *inet_csk_clone_lock(const struct sock *sk,
+					const struct request_sock *req,
+					const gfp_t priority);
 
 enum inet_csk_ack_state_t {
 	ICSK_ACK_SCHED	= 1,
diff --git a/include/net/sock.h b/include/net/sock.h
index abb6e0f..67cd458 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1089,8 +1089,8 @@ extern struct sock		*sk_alloc(struct net *net, int family,
 					  struct proto *prot);
 extern void			sk_free(struct sock *sk);
 extern void			sk_release_kernel(struct sock *sk);
-extern struct sock		*sk_clone(const struct sock *sk,
-					  const gfp_t priority);
+extern struct sock		*sk_clone_lock(const struct sock *sk,
+					       const gfp_t priority);
 
 extern struct sk_buff		*sock_wmalloc(struct sock *sk,
 					      unsigned long size, int force,
diff --git a/net/core/sock.c b/net/core/sock.c
index 4ed7b1d..e419061 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1204,7 +1204,14 @@ void sk_release_kernel(struct sock *sk)
 }
 EXPORT_SYMBOL(sk_release_kernel);
 
-struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
+/**
+ *	sk_clone_lock - clone a socket, and lock its clone
+ *	@sk: the socket to clone
+ *	@priority: for allocation (%GFP_KERNEL, %GFP_ATOMIC, etc)
+ *
+ *	Caller must unlock socket even in error path (bh_unlock_sock(newsk))
+ */
+struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
 {
 	struct sock *newsk;
 
@@ -1297,7 +1304,7 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
 out:
 	return newsk;
 }
-EXPORT_SYMBOL_GPL(sk_clone);
+EXPORT_SYMBOL_GPL(sk_clone_lock);
 
 void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
 {
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index d7041a0..563b7c7 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -100,7 +100,7 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 	 *   (* Generate a new socket and switch to that socket *)
 	 *   Set S := new socket for this port pair
 	 */
-	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
+	struct sock *newsk = inet_csk_clone_lock(sk, req, GFP_ATOMIC);
 
 	if (newsk != NULL) {
 		struct dccp_request_sock *dreq = dccp_rsk(req);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index c14d88a..a598768 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -588,10 +588,19 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 }
 EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_prune);
 
-struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
-			    const gfp_t priority)
+/**
+ *	inet_csk_clone_lock - clone an inet socket, and lock its clone
+ *	@sk: the socket to clone
+ *	@req: request_sock
+ *	@priority: for allocation (%GFP_KERNEL, %GFP_ATOMIC, etc)
+ *
+ *	Caller must unlock socket even in error path (bh_unlock_sock(newsk))
+ */
+struct sock *inet_csk_clone_lock(const struct sock *sk,
+				 const struct request_sock *req,
+				 const gfp_t priority)
 {
-	struct sock *newsk = sk_clone(sk, priority);
+	struct sock *newsk = sk_clone_lock(sk, priority);
 
 	if (newsk != NULL) {
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
@@ -615,7 +624,7 @@ struct sock *inet_csk_clone(struct sock *sk, const struct request_sock *req,
 	}
 	return newsk;
 }
-EXPORT_SYMBOL_GPL(inet_csk_clone);
+EXPORT_SYMBOL_GPL(inet_csk_clone_lock);
 
 /*
  * At this point, there should be no process reference to this
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 66363b6..0a7e339 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -425,7 +425,7 @@ static inline void TCP_ECN_openreq_child(struct tcp_sock *tp,
  */
 struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req, struct sk_buff *skb)
 {
-	struct sock *newsk = inet_csk_clone(sk, req, GFP_ATOMIC);
+	struct sock *newsk = inet_csk_clone_lock(sk, req, GFP_ATOMIC);
 
 	if (newsk != NULL) {
 		const struct inet_request_sock *ireq = inet_rsk(req);
