From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 5/5] inet: add proper refcounting to request sock
Date: Sun, 15 Mar 2015 21:12:16 -0700
Message-ID: <1426479136-15645-6-git-send-email-edumazet@google.com>
References: <1426479136-15645-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:33393 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751905AbbCPEMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 00:12:54 -0400
Received: by igjz20 with SMTP id z20so778621igj.0
        for <netdev@vger.kernel.org>; Sun, 15 Mar 2015 21:12:53 -0700 (PDT)
In-Reply-To: <1426479136-15645-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

reqsk_put() is the generic function that should be used
to release a refcount (and automatically call reqsk_free())

reqsk_free() might be called if refcount is known to be 0
or undefined.

refcnt is set to one in inet_csk_reqsk_queue_add()

As request socks are not yet in global ehash table,
I added temporary debugging checks in reqsk_put() and reqsk_free()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_connection_sock.h |  5 +++++
 include/net/inet_sock.h            |  5 +++++
 include/net/request_sock.h         | 13 +++++++------
 net/core/request_sock.c            |  4 ++--
 net/ipv4/inet_connection_sock.c    |  8 ++++----
 net/ipv4/syncookies.c              | 10 +++++-----
 net/ipv4/tcp_fastopen.c            |  2 +-
 7 files changed, 29 insertions(+), 18 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index b9a6b0a94cc6..191feec60205 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -275,6 +275,11 @@ static inline void inet_csk_reqsk_queue_add(struct sock *sk,
 					    struct sock *child)
 {
 	reqsk_queue_add(&inet_csk(sk)->icsk_accept_queue, req, sk, child);
+	/* before letting lookups find us, make sure all req fields
+	 * are committed to memory.
+	 */
+	smp_wmb();
+	atomic_set(&req->rsk_refcnt, 1);
 }
 
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b3053fdd871e..3d8c09abb097 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -255,6 +255,11 @@ static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops
 		ireq->opt = NULL;
 		atomic64_set(&ireq->ir_cookie, 0);
 		ireq->ireq_state = TCP_NEW_SYN_RECV;
+
+		/* Following is temporary. It is coupled with debugging
+		 * helpers in reqsk_put() & reqsk_free()
+		 */
+		atomic_set(&ireq->ireq_refcnt, 0);
 	}
 
 	return req;
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 3275cf31f731..56dc2faba47e 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -82,19 +82,20 @@ static inline struct request_sock *inet_reqsk(struct sock *sk)
 	return (struct request_sock *)sk;
 }
 
-static inline void __reqsk_free(struct request_sock *req)
-{
-	kmem_cache_free(req->rsk_ops->slab, req);
-}
-
 static inline void reqsk_free(struct request_sock *req)
 {
+	/* temporary debugging */
+	WARN_ON_ONCE(atomic_read(&req->rsk_refcnt) != 0);
+
 	req->rsk_ops->destructor(req);
-	__reqsk_free(req);
+	kmem_cache_free(req->rsk_ops->slab, req);
 }
 
 static inline void reqsk_put(struct request_sock *req)
 {
+	/* temporary debugging, until req sock are put into ehash table */
+	WARN_ON_ONCE(atomic_read(&req->rsk_refcnt) != 1);
+
 	if (atomic_dec_and_test(&req->rsk_refcnt))
 		reqsk_free(req);
 }
diff --git a/net/core/request_sock.c b/net/core/request_sock.c
index 04db318e6218..e910317ef6d9 100644
--- a/net/core/request_sock.c
+++ b/net/core/request_sock.c
@@ -103,7 +103,7 @@ void reqsk_queue_destroy(struct request_sock_queue *queue)
 			while ((req = lopt->syn_table[i]) != NULL) {
 				lopt->syn_table[i] = req->dl_next;
 				lopt->qlen--;
-				reqsk_free(req);
+				reqsk_put(req);
 			}
 		}
 	}
@@ -180,7 +180,7 @@ void reqsk_fastopen_remove(struct sock *sk, struct request_sock *req,
 		 */
 		spin_unlock_bh(&fastopenq->lock);
 		sock_put(lsk);
-		reqsk_free(req);
+		reqsk_put(req);
 		return;
 	}
 	/* Wait for 60secs before removing a req that has triggered RST.
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 34581f928afa..3390ba6f96b2 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -340,7 +340,7 @@ struct sock *inet_csk_accept(struct sock *sk, int flags, int *err)
 out:
 	release_sock(sk);
 	if (req)
-		__reqsk_free(req);
+		reqsk_put(req);
 	return newsk;
 out_err:
 	newsk = NULL;
@@ -635,7 +635,7 @@ void inet_csk_reqsk_queue_prune(struct sock *parent,
 				/* Drop this request */
 				inet_csk_reqsk_queue_unlink(parent, req, reqp);
 				reqsk_queue_removed(queue, req);
-				reqsk_free(req);
+				reqsk_put(req);
 				continue;
 			}
 			reqp = &req->dl_next;
@@ -837,7 +837,7 @@ void inet_csk_listen_stop(struct sock *sk)
 		sock_put(child);
 
 		sk_acceptq_removed(sk);
-		__reqsk_free(req);
+		reqsk_put(req);
 	}
 	if (queue->fastopenq != NULL) {
 		/* Free all the reqs queued in rskq_rst_head. */
@@ -847,7 +847,7 @@ void inet_csk_listen_stop(struct sock *sk)
 		spin_unlock_bh(&queue->fastopenq->lock);
 		while ((req = acc_req) != NULL) {
 			acc_req = req->dl_next;
-			__reqsk_free(req);
+			reqsk_put(req);
 		}
 	}
 	WARN_ON(sk->sk_ack_backlog);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index f17db898ed26..5ae0c49f5e2e 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -219,9 +219,9 @@ int __cookie_v4_check(const struct iphdr *iph, const struct tcphdr *th,
 }
 EXPORT_SYMBOL_GPL(__cookie_v4_check);
 
-static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
-					   struct request_sock *req,
-					   struct dst_entry *dst)
+static struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
+				    struct request_sock *req,
+				    struct dst_entry *dst)
 {
 	struct inet_connection_sock *icsk = inet_csk(sk);
 	struct sock *child;
@@ -357,7 +357,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	ireq->opt = tcp_v4_save_options(skb);
 
 	if (security_inet_conn_request(sk, skb, req)) {
-		reqsk_free(req);
+		reqsk_put(req);
 		goto out;
 	}
 
@@ -378,7 +378,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb)
 	security_req_classify_flow(req, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
 	if (IS_ERR(rt)) {
-		reqsk_free(req);
+		reqsk_put(req);
 		goto out;
 	}
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index fe77417fc137..84381319e1bc 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -253,7 +253,7 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
 		fastopenq->rskq_rst_head = req1->dl_next;
 		fastopenq->qlen--;
 		spin_unlock(&fastopenq->lock);
-		reqsk_free(req1);
+		reqsk_put(req1);
 	}
 	return true;
 }
-- 
2.2.0.rc0.207.ga3a616c
