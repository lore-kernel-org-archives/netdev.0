From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH net-next v3] tcp: md5: check md5 signature without socket
 lock
Date: Thu, 7 Aug 2014 02:38:22 +0400
Message-ID: <20140807023822.dc786be51bcb7c22577f66e1@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f45.google.com ([209.85.215.45]:43704 "EHLO
	mail-la0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753533AbaHFWi1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 18:38:27 -0400
Received: by mail-la0-f45.google.com with SMTP id ty20so2860493lab.4
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 15:38:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since a8afca032 (tcp: md5: protects md5sig_info with RCU) tcp_md5_do_lookup
doesn't require socket lock, rcu_read_lock is enough. Therefore socket lock is
no longer required for tcp_v{4,6}_inbound_md5_hash too, so we can move these
calls (wrapped with rcu_read_{,un}lock) before bh_lock_sock:
from tcp_v{4,6}_do_rcv to tcp_v{4,6}_rcv.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 net/ipv4/tcp_ipv4.c | 36 +++++++++++++++++++++++++-----------
 net/ipv6/tcp_ipv6.c | 25 +++++++++++++++++++------
 2 files changed, 44 insertions(+), 17 deletions(-)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 992a1f9..dceff5f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1167,7 +1167,8 @@ clear_hash_noput:
 }
 EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
-static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+static bool __tcp_v4_inbound_md5_hash(struct sock *sk,
+				      const struct sk_buff *skb)
 {
 	/*
 	 * This gets called for each TCP segment that arrives
@@ -1220,6 +1221,17 @@ static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 	return false;
 }
 
+static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+{
+	bool ret;
+
+	rcu_read_lock();
+	ret = __tcp_v4_inbound_md5_hash(sk, skb);
+	rcu_read_unlock();
+
+	return ret;
+}
+
 #endif
 
 static void tcp_v4_init_req(struct request_sock *req, struct sock *sk,
@@ -1432,16 +1444,6 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct sock *rsk;
-#ifdef CONFIG_TCP_MD5SIG
-	/*
-	 * We really want to reject the packet as early as possible
-	 * if:
-	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
-	 *  o There is an MD5 option and we're not expecting one
-	 */
-	if (tcp_v4_inbound_md5_hash(sk, skb))
-		goto discard;
-#endif
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		struct dst_entry *dst = sk->sk_rx_dst;
@@ -1644,6 +1646,18 @@ process:
 
 	if (!xfrm4_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
+
+#ifdef CONFIG_TCP_MD5SIG
+	/*
+	 * We really want to reject the packet as early as possible
+	 * if:
+	 *  o We're expecting an MD5'd packet and this is no MD5 tcp option
+	 *  o There is an MD5 option and we're not expecting one
+	 */
+	if (tcp_v4_inbound_md5_hash(sk, skb))
+		goto discard_and_relse;
+#endif
+
 	nf_reset(skb);
 
 	if (sk_filter(sk, skb))
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 22055b0..f2ce955 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -667,7 +667,8 @@ clear_hash_noput:
 	return 1;
 }
 
-static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+static int __tcp_v6_inbound_md5_hash(struct sock *sk,
+				     const struct sk_buff *skb)
 {
 	const __u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
@@ -707,6 +708,18 @@ static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
 	}
 	return 0;
 }
+
+static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+{
+	int ret;
+
+	rcu_read_lock();
+	ret = __tcp_v6_inbound_md5_hash(sk, skb);
+	rcu_read_unlock();
+
+	return ret;
+}
+
 #endif
 
 static void tcp_v6_init_req(struct request_sock *req, struct sock *sk,
@@ -1247,11 +1260,6 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-#ifdef CONFIG_TCP_MD5SIG
-	if (tcp_v6_inbound_md5_hash(sk, skb))
-		goto discard;
-#endif
-
 	if (sk_filter(sk, skb))
 		goto discard;
 
@@ -1424,6 +1432,11 @@ process:
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (tcp_v6_inbound_md5_hash(sk, skb))
+		goto discard_and_relse;
+#endif
+
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
