From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 5/5] tcp: IPv6 support for fastopen server
Date: Sun, 11 May 2014 20:22:13 -0700
Message-ID: <1399864933-28287-6-git-send-email-ycheng@google.com>
References: <1399864933-28287-1-git-send-email-ycheng@google.com>
Cc: longinus00@gmail.com, hkchu@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:59171 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbaELDWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 23:22:51 -0400
Received: by mail-oa0-f74.google.com with SMTP id m1so1343079oag.5
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 20:22:50 -0700 (PDT)
In-Reply-To: <1399864933-28287-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lee <longinus00@gmail.com>

After all the preparatory works, supporting IPv6 in Fast Open is now easy.
We pretty much just mirror v4 code. The only difference is how we
generate the Fast Open cookie for IPv6 sockets. Since Fast Open cookie
is 128 bits and we use AES 128, we use CBC-MAC to encrypt both the
source and destination IPv6 addresses since the cookie is a MAC tag.

Signed-off-by: Daniel Lee <longinus00@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Jerry Chu <hkchu@google.com>
---
 net/ipv4/tcp_fastopen.c | 57 +++++++++++++++++++++++++++++++++++++------------
 net/ipv6/tcp_ipv6.c     | 40 +++++++++++++++++++++++-----------
 2 files changed, 71 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 9b947a9..62e48cf 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -72,27 +72,58 @@ error:		kfree(ctx);
 	return err;
 }
 
-/* Computes the fastopen cookie for the IP path.
- * The path is a 128 bits long (pad with zeros for IPv4).
- *
- * The caller must check foc->len to determine if a valid cookie
- * has been generated successfully.
-*/
-void tcp_fastopen_cookie_gen(__be32 src, __be32 dst,
-			     struct tcp_fastopen_cookie *foc)
+static bool __tcp_fastopen_cookie_gen(const void *path,
+				      struct tcp_fastopen_cookie *foc)
 {
-	__be32 path[4] = { src, dst, 0, 0 };
 	struct tcp_fastopen_context *ctx;
+	bool ok = false;
 
 	tcp_fastopen_init_key_once(true);
 
 	rcu_read_lock();
 	ctx = rcu_dereference(tcp_fastopen_ctx);
 	if (ctx) {
-		crypto_cipher_encrypt_one(ctx->tfm, foc->val, (__u8 *)path);
+		crypto_cipher_encrypt_one(ctx->tfm, foc->val, path);
 		foc->len = TCP_FASTOPEN_COOKIE_SIZE;
+		ok = true;
 	}
 	rcu_read_unlock();
+	return ok;
+}
+
+/* Generate the fastopen cookie by doing aes128 encryption on both
+ * the source and destination addresses. Pad 0s for IPv4 or IPv4-mapped-IPv6
+ * addresses. For the longer IPv6 addresses use CBC-MAC.
+ *
+ * XXX (TFO) - refactor when TCP_FASTOPEN_COOKIE_SIZE != AES_BLOCK_SIZE.
+ */
+static bool tcp_fastopen_cookie_gen(struct request_sock *req,
+				    struct sk_buff *syn,
+				    struct tcp_fastopen_cookie *foc)
+{
+	if (req->rsk_ops->family == AF_INET) {
+		const struct iphdr *iph = ip_hdr(syn);
+
+		__be32 path[4] = { iph->saddr, iph->daddr, 0, 0 };
+		return __tcp_fastopen_cookie_gen(path, foc);
+	}
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (req->rsk_ops->family == AF_INET6) {
+		const struct ipv6hdr *ip6h = ipv6_hdr(syn);
+		struct tcp_fastopen_cookie tmp;
+
+		if (__tcp_fastopen_cookie_gen(&ip6h->saddr, &tmp)) {
+			struct in6_addr *buf = (struct in6_addr *) tmp.val;
+			int i = 4;
+
+			for (i = 0; i < 4; i++)
+				buf->s6_addr32[i] ^= ip6h->daddr.s6_addr32[i];
+			return __tcp_fastopen_cookie_gen(buf, foc);
+		}
+	}
+#endif
+	return false;
 }
 
 static bool tcp_fastopen_create_child(struct sock *sk,
@@ -234,10 +265,8 @@ bool tcp_try_fastopen(struct sock *sk, struct sk_buff *skb,
 	if (syn_data && (sysctl_tcp_fastopen & TFO_SERVER_COOKIE_NOT_REQD))
 		goto fastopen;
 
-	tcp_fastopen_cookie_gen(ip_hdr(skb)->saddr,
-				ip_hdr(skb)->daddr, &valid_foc);
-
-	if (foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
+	if (tcp_fastopen_cookie_gen(req, skb, &valid_foc) &&
+	    foc->len == TCP_FASTOPEN_COOKIE_SIZE &&
 	    foc->len == valid_foc.len &&
 	    !memcmp(foc->val, valid_foc.val, foc->len)) {
 		/* Cookie is valid. Create a (full) child socket to accept
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index a7a62ce..3a267bf 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -472,7 +472,8 @@ out:
 static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 			      struct flowi6 *fl6,
 			      struct request_sock *req,
-			      u16 queue_mapping)
+			      u16 queue_mapping,
+			      struct tcp_fastopen_cookie *foc)
 {
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -483,7 +484,7 @@ static int tcp_v6_send_synack(struct sock *sk, struct dst_entry *dst,
 	if (!dst && (dst = inet6_csk_route_req(sk, fl6, req)) == NULL)
 		goto done;
 
-	skb = tcp_make_synack(sk, dst, req, NULL);
+	skb = tcp_make_synack(sk, dst, req, foc);
 
 	if (skb) {
 		__tcp_v6_send_check(skb, &ireq->ir_v6_loc_addr,
@@ -507,7 +508,7 @@ static int tcp_v6_rtx_synack(struct sock *sk, struct request_sock *req)
 	struct flowi6 fl6;
 	int res;
 
-	res = tcp_v6_send_synack(sk, NULL, &fl6, req, 0);
+	res = tcp_v6_send_synack(sk, NULL, &fl6, req, 0, NULL);
 	if (!res) {
 		TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_RETRANSSEGS);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPSYNRETRANS);
@@ -926,7 +927,12 @@ static void tcp_v6_timewait_ack(struct sock *sk, struct sk_buff *skb)
 static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 				  struct request_sock *req)
 {
-	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1,
+	/* sk->sk_state == TCP_LISTEN -> for regular TCP_SYN_RECV
+	 * sk->sk_state == TCP_SYN_RECV -> for Fast Open.
+	 */
+	tcp_v6_send_ack(skb, (sk->sk_state == TCP_LISTEN) ?
+			tcp_rsk(req)->snt_isn + 1 : tcp_sk(sk)->snd_nxt,
+			tcp_rsk(req)->rcv_nxt,
 			req->rcv_wnd, tcp_time_stamp, req->ts_recent, sk->sk_bound_dev_if,
 			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
 			0, 0);
@@ -978,8 +984,10 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	struct tcp_sock *tp = tcp_sk(sk);
 	__u32 isn = TCP_SKB_CB(skb)->when;
 	struct dst_entry *dst = NULL;
+	struct tcp_fastopen_cookie foc = { .len = -1 };
+	bool want_cookie = false, fastopen;
 	struct flowi6 fl6;
-	bool want_cookie = false;
+	int err;
 
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_conn_request(sk, skb);
@@ -1010,7 +1018,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, 0, NULL);
+	tcp_parse_options(skb, &tmp_opt, 0, want_cookie ? NULL : &foc);
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1083,19 +1091,27 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		isn = tcp_v6_init_sequence(skb);
 	}
 have_isn:
-	tcp_rsk(req)->snt_isn = isn;
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_release;
 
-	if (tcp_v6_send_synack(sk, dst, &fl6, req,
-			       skb_get_queue_mapping(skb)) ||
-	    want_cookie)
+	if (!dst && (dst = inet6_csk_route_req(sk, &fl6, req)) == NULL)
 		goto drop_and_free;
 
+	tcp_rsk(req)->snt_isn = isn;
 	tcp_rsk(req)->snt_synack = tcp_time_stamp;
-	tcp_rsk(req)->listener = NULL;
-	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	tcp_openreq_init_rwin(req, sk, dst);
+	fastopen = !want_cookie &&
+		   tcp_try_fastopen(sk, skb, req, &foc, dst);
+	err = tcp_v6_send_synack(sk, dst, &fl6, req,
+				 skb_get_queue_mapping(skb), &foc);
+	if (!fastopen) {
+		if (err || want_cookie)
+			goto drop_and_free;
+
+		tcp_rsk(req)->listener = NULL;
+		inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
+	}
 	return 0;
 
 drop_and_release:
-- 
1.9.1.423.g4596e3a
