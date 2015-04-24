From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inet: fix possible panic in reqsk_queue_unlink()
Date: Thu, 23 Apr 2015 18:03:44 -0700
Message-ID: <1429837424.22254.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:36133 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752208AbbDXBDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2015 21:03:48 -0400
Received: by igblo3 with SMTP id lo3so3318713igb.1
        for <netdev@vger.kernel.org>; Thu, 23 Apr 2015 18:03:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

[ 3897.923145] BUG: unable to handle kernel NULL pointer dereference at
 0000000000000080
[ 3897.931025] IP: [<ffffffffa9f27686>] reqsk_timer_handler+0x1a6/0x243

There is a race when reqsk_timer_handler() and tcp_check_req() call
inet_csk_reqsk_queue_unlink() on the same req at the same time.

Before commit fa76ce7328b2 ("inet: get rid of central tcp/dccp listener
timer"), listener spinlock was held and race could not happen.

To solve this bug, we change reqsk_queue_unlink() to not assume req
must be found, and we return a status, to conditionally release a
refcount on the request sock.

This also means tcp_check_req() in non fastopen case might or not
consume req refcount, so tcp_v6_hnd_req() & tcp_v4_hnd_req() have
to properly handle this.

(Same remark for dccp_check_req() and its callers)

inet_csk_reqsk_queue_drop() is now too big to be inlined, as it is
called 4 times in tcp and 3 times in dccp.

Fixes: fa76ce7328b2 ("inet: get rid of central tcp/dccp listener timer")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Yuchung Cheng <ycheng@google.com>
---
 include/net/inet_connection_sock.h |   20 ---------------
 include/net/request_sock.h         |   18 --------------
 net/dccp/ipv4.c                    |    3 +-
 net/dccp/ipv6.c                    |    3 +-
 net/dccp/minisocks.c               |    3 --
 net/ipv4/inet_connection_sock.c    |   34 +++++++++++++++++++++++++++
 net/ipv4/tcp_ipv4.c                |    3 +-
 net/ipv4/tcp_minisocks.c           |    7 +++--
 net/ipv6/tcp_ipv6.c                |    3 +-
 9 files changed, 48 insertions(+), 46 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 7b5887cd1172..48a815823587 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -279,12 +279,6 @@ static inline void inet_csk_reqsk_queue_add(struct sock *sk,
 void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
 				   unsigned long timeout);
 
-static inline void inet_csk_reqsk_queue_removed(struct sock *sk,
-						struct request_sock *req)
-{
-	reqsk_queue_removed(&inet_csk(sk)->icsk_accept_queue, req);
-}
-
 static inline void inet_csk_reqsk_queue_added(struct sock *sk,
 					      const unsigned long timeout)
 {
@@ -306,19 +300,7 @@ static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
 	return reqsk_queue_is_full(&inet_csk(sk)->icsk_accept_queue);
 }
 
-static inline void inet_csk_reqsk_queue_unlink(struct sock *sk,
-					       struct request_sock *req)
-{
-	reqsk_queue_unlink(&inet_csk(sk)->icsk_accept_queue, req);
-}
-
-static inline void inet_csk_reqsk_queue_drop(struct sock *sk,
-					     struct request_sock *req)
-{
-	inet_csk_reqsk_queue_unlink(sk, req);
-	inet_csk_reqsk_queue_removed(sk, req);
-	reqsk_put(req);
-}
+void inet_csk_reqsk_queue_drop(struct sock *sk, struct request_sock *req);
 
 void inet_csk_destroy_sock(struct sock *sk);
 void inet_csk_prepare_forced_close(struct sock *sk);
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index fe41f3ceb008..9f4265ce8892 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -212,24 +212,6 @@ static inline int reqsk_queue_empty(struct request_sock_queue *queue)
 	return queue->rskq_accept_head == NULL;
 }
 
-static inline void reqsk_queue_unlink(struct request_sock_queue *queue,
-				      struct request_sock *req)
-{
-	struct listen_sock *lopt = queue->listen_opt;
-	struct request_sock **prev;
-
-	spin_lock(&queue->syn_wait_lock);
-
-	prev = &lopt->syn_table[req->rsk_hash];
-	while (*prev != req)
-		prev = &(*prev)->dl_next;
-	*prev = req->dl_next;
-
-	spin_unlock(&queue->syn_wait_lock);
-	if (del_timer(&req->rsk_timer))
-		reqsk_put(req);
-}
-
 static inline void reqsk_queue_add(struct request_sock_queue *queue,
 				   struct request_sock *req,
 				   struct sock *parent,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 2b4f21d34df6..ccf4c5629b3c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -453,7 +453,8 @@ static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 						       iph->saddr, iph->daddr);
 	if (req) {
 		nsk = dccp_check_req(sk, skb, req);
-		reqsk_put(req);
+		if (!nsk)
+			reqsk_put(req);
 		return nsk;
 	}
 	nsk = inet_lookup_established(sock_net(sk), &dccp_hashinfo,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9d0551092c6c..5165571f397a 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -301,7 +301,8 @@ static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 				   &iph->daddr, inet6_iif(skb));
 	if (req) {
 		nsk = dccp_check_req(sk, skb, req);
-		reqsk_put(req);
+		if (!nsk)
+			reqsk_put(req);
 		return nsk;
 	}
 	nsk = __inet6_lookup_established(sock_net(sk), &dccp_hashinfo,
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 5f566663e47f..30addee2dd03 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -186,8 +186,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (child == NULL)
 		goto listen_overflow;
 
-	inet_csk_reqsk_queue_unlink(sk, req);
-	inet_csk_reqsk_queue_removed(sk, req);
+	inet_csk_reqsk_queue_drop(sk, req);
 	inet_csk_reqsk_queue_add(sk, req, child);
 out:
 	return child;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 5c3dd6267ed3..8976ca423a07 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -564,6 +564,40 @@ int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req)
 }
 EXPORT_SYMBOL(inet_rtx_syn_ack);
 
+/* return true if req was found in the syn_table[] */
+static bool reqsk_queue_unlink(struct request_sock_queue *queue,
+			       struct request_sock *req)
+{
+	struct listen_sock *lopt = queue->listen_opt;
+	struct request_sock **prev;
+	bool found = false;
+
+	spin_lock(&queue->syn_wait_lock);
+
+	for (prev = &lopt->syn_table[req->rsk_hash]; *prev != NULL;
+	     prev = &(*prev)->dl_next) {
+		if (*prev == req) {
+			*prev = req->dl_next;
+			found = true;
+			break;
+		}
+	}
+
+	spin_unlock(&queue->syn_wait_lock);
+	if (del_timer(&req->rsk_timer))
+		reqsk_put(req);
+	return found;
+}
+
+void inet_csk_reqsk_queue_drop(struct sock *sk, struct request_sock *req)
+{
+	if (reqsk_queue_unlink(&inet_csk(sk)->icsk_accept_queue, req)) {
+		reqsk_queue_removed(&inet_csk(sk)->icsk_accept_queue, req);
+		reqsk_put(req);
+	}
+}
+EXPORT_SYMBOL(inet_csk_reqsk_queue_drop);
+
 static void reqsk_timer_handler(unsigned long data)
 {
 	struct request_sock *req = (struct request_sock *)data;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3571f2be4470..fc1c658ec6c1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1348,7 +1348,8 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 	req = inet_csk_search_req(sk, th->source, iph->saddr, iph->daddr);
 	if (req) {
 		nsk = tcp_check_req(sk, skb, req, false);
-		reqsk_put(req);
+		if (!nsk)
+			reqsk_put(req);
 		return nsk;
 	}
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 63d6311b5365..2c6abb40cf5f 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -755,10 +755,11 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (!child)
 		goto listen_overflow;
 
-	inet_csk_reqsk_queue_unlink(sk, req);
-	inet_csk_reqsk_queue_removed(sk, req);
-
+	inet_csk_reqsk_queue_drop(sk, req);
 	inet_csk_reqsk_queue_add(sk, req, child);
+	/* Warning: caller must not call reqsk_put(req);
+	 * child stole last reference on it.
+	 */
 	return child;
 
 listen_overflow:
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ad51df85aa00..b6575d665568 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -946,7 +946,8 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk, struct sk_buff *skb)
 				   &ipv6_hdr(skb)->daddr, tcp_v6_iif(skb));
 	if (req) {
 		nsk = tcp_check_req(sk, skb, req, false);
-		reqsk_put(req);
+		if (!nsk)
+			reqsk_put(req);
 		return nsk;
 	}
 	nsk = __inet6_lookup_established(sock_net(sk), &tcp_hashinfo,
