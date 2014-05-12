From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 2/5] tcp: simplify fast open cookie processing
Date: Sun, 11 May 2014 20:22:10 -0700
Message-ID: <1399864933-28287-3-git-send-email-ycheng@google.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
Cc: longinus00@gmail.com, hkchu@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f73.google.com ([209.85.219.73]:46589 "EHLO
	mail-oa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751727AbaELDWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:22:50 -0400
Received: by mail-oa0-f73.google.com with SMTP id i4so1344431oah.4
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 20:22:50 -0700 (PDT)
In-Reply-To: <1399864933-28287-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate various cookie checking and generation code to simplify
the fast open processing. The main goal is to reduce code duplication
in tcp_v4_conn_request() for IPv6 support.

Removes two experimental sysctl flags TFO_SERVER_ALWAYS and
TFO_SERVER_COOKIE_NOT_CHKD used primarily for developmental debugging
purposes.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Daniel Lee <longinus00@gmail.com>
Signed-off-by: Jerry Chu <hkchu@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/tcp.h     |  5 ----
 include/net/tcp.h       |  9 +------
 net/ipv4/tcp_fastopen.c | 71 +++++++++++++++++++------------------------------
 net/ipv4/tcp_ipv4.c     | 10 +++----
 net/ipv4/tcp_output.c   |  2 +-
 5 files changed, 33 insertions(+), 64 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 4e37c71..bc35e47 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -366,11 +366,6 @@ static inline bool tcp_passive_fastopen(const struct sock *sk)
 		tcp_sk(sk)->fastopen_rsk != NULL);
 }
 
-static inline bool fastopen_cookie_present(struct tcp_fastopen_cookie *foc)
-{
-	return foc->len != -1;
-}
-
 extern void tcp_sock_destruct(struct sock *sk);
 
 static inline int fastopen_init_queue(struct sock *sk, int backlog)
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0122368..17d7c6a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -220,8 +220,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define	TFO_SERVER_ENABLE	2
 #define	TFO_CLIENT_NO_COOKIE	4	/* Data in SYN w/o cookie option */
 
-/* Process SYN data but skip cookie validation */
-#define	TFO_SERVER_COOKIE_NOT_CHKED	0x100
 /* Accept SYN data w/o any cookie option */
 #define	TFO_SERVER_COOKIE_NOT_REQD	0x200
 
@@ -230,10 +228,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
  */
 #define	TFO_SERVER_WO_SOCKOPT1	0x400
 #define	TFO_SERVER_WO_SOCKOPT2	0x800
-/* Always create TFO child sockets on a TFO listener even when
- * cookie/data not present. (For testing purpose!)
- */
-#define	TFO_SERVER_ALWAYS	0x1000
 
 extern struct inet_timewait_death_row tcp_death_row;
 
@@ -1335,8 +1329,7 @@ int tcp_fastopen_create_child(struct sock *sk,
 			      struct request_sock *req);
 bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
 			struct request_sock *req,
-			struct tcp_fastopen_cookie *foc,
-			struct tcp_fastopen_cookie *valid_foc);
+			struct tcp_fastopen_cookie *foc);
 void tcp_fastopen_init_key_once(bool publish);
 #define TCP_FASTOPEN_KEY_LENGTH 16
 
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 0606c91..5a98277 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -228,59 +228,44 @@ static bool tcp_fastopen_queue_check(struct sock *sk)
 	return true;
 }
 
+/* Returns true if we should perform Fast Open on the SYN. The cookie (foc)
+ * may be updated and return the client in the SYN-ACK later. E.g., Fast Open
+ * cookie request (foc->len == 0).
+ */
 bool tcp_fastopen_check(struct sock *sk, struct sk_buff *skb,
 			struct request_sock *req,
-			struct tcp_fastopen_cookie *foc,
-			struct tcp_fastopen_cookie *valid_foc)
+			struct tcp_fastopen_cookie *foc)
 {
-	bool skip_cookie = false;
-
-	if (likely(!fastopen_cookie_present(foc))) {
-		/* See include/net/tcp.h for the meaning of these knobs */
-		if ((sysctl_tcp_fastopen & TFO_SERVER_ALWAYS) ||
-		    ((sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD) &&
-		    (TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1)))
-			skip_cookie = true; /* no cookie to validate */
-		else
-			return false;
-	}
-	/* A FO option is present; bump the counter. */
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVE);
+	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
+	bool syn_data = TCP_SKB_CB(skb)->end_seq != TCP_SKB_CB(skb)->seq + 1;
 
-	if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) == 0 ||
-	    !tcp_fastopen_queue_check(sk))
+	if (!((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) &&
+	      (syn_data || foc->len >= 0) &&
+	      tcp_fastopen_queue_check(sk))) {
+		foc->len = -1;
 		return false;
-
-	if (skip_cookie) {
-		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
-		return true;
 	}
 
-	if (foc->len == TCP_FASTOPEN_COOKIE_SIZE) {
-		if ((sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_CHKED) == 0) {
-			tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
-						ip_hdr(skb)->daddr, valid_foc);
-			if ((valid_foc->len != TCP_FASTOPEN_COOKIE_SIZE) ||
-			    memcmp(&foc->val[0], &valid_foc->val[0],
-			    TCP_FASTOPEN_COOKIE_SIZE) != 0)
-				return false;
-			valid_foc->len = -1;
-		}
-		/* Acknowledge the data received from the peer. */
+	if (syn_data && (sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
+		goto fastopen;
+
+	tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
+				ip_hdr(skb)->daddr, &valid_foc);
+
+	if (foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
+	    foc->len == valid_foc.len &&
+	    !memcmp(foc->val, valid_foc.val, foc->len)) {
+fastopen:
 		tcp_rsk(req)->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+		foc->len = -1;
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVE);
 		return true;
-	} else if (foc->len == 0) { /* Client requesting a cookie */
-		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
-					ip_hdr(skb)->daddr, valid_foc);
-		NET_INC_STATS_BH(sock_net(sk),
-		    LINUX_MIB_TCPFASTOPENCOOKIEREQD);
-	} else {
-		/* Client sent a cookie with wrong size. Treat it
-		 * the same as invalid and return a valid one.
-		 */
-		tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
-					ip_hdr(skb)->daddr, valid_foc);
 	}
+
+	NET_INC_STATS_BH(sock_net(sk), foc->len ?
+			 LINUX_MIB_TCPFASTOPENPASSIVEFAIL :
+			 LINUX_MIB_TCPFASTOPENCOOKIEREQD);
+	*foc = valid_foc;
 	return false;
 }
 EXPORT_SYMBOL(tcp_fastopen_check);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 032fcae..5ea0949 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1273,7 +1273,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	bool want_cookie = false;
 	struct flowi4 fl4;
 	struct tcp_fastopen_cookie foc = { .len = -1 };
-	struct tcp_fastopen_cookie valid_foc = { .len = -1 };
 	struct sk_buff *skb_synack;
 	int do_fastopen;
 
@@ -1381,7 +1380,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		if (dst == NULL)
 			goto drop_and_free;
 	}
-	do_fastopen = tcp_fastopen_check(sk, skb, req, &foc, &valid_foc);
+	do_fastopen = !want_cookie &&
+		      tcp_fastopen_check(sk, skb, req, &foc);
 
 	/* We don't call tcp_v4_send_synack() directly because we need
 	 * to make sure a child socket can be created successfully before
@@ -1394,8 +1394,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 * latter to remove its dependency on the current implementation
 	 * of tcp_v4_send_synack()->tcp_select_initial_window().
 	 */
-	skb_synack = tcp_make_synack(sk, dst, req,
-	    fastopen_cookie_present(&valid_foc) ? &valid_foc : NULL);
+	skb_synack = tcp_make_synack(sk, dst, req, &foc);
 
 	if (skb_synack) {
 		__tcp_v4_send_check(skb_synack, ireq->ir_loc_addr, ireq->ir_rmt_addr);
@@ -1415,9 +1414,6 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		tcp_rsk(req)->listener = NULL;
 		/* Add the request_sock to the SYN table */
 		inet_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
-		if (fastopen_cookie_present(&foc) && foc.len != 0)
-			NET_INC_STATS_BH(sock_net(sk),
-			    LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
 	} else if (tcp_fastopen_create_child(sk, skb, skb_synack, req))
 		goto drop_and_release;
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 89277a3..14b7981 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -627,7 +627,7 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		if (unlikely(!ireq->tstamp_ok))
 			remaining -= TCPOLEN_SACKPERM_ALIGNED;
 	}
-	if (foc != NULL) {
+	if (foc != NULL && foc->len >= 0) {
 		u32 need = TCPOLEN_EXP_FASTOPEN_BASE + foc->len;
 		need = (need + 3) & ~3U;  /* Align to 32 bits */
 		if (remaining >= need) {
-- 
1.9.1.423.g4596e3a
