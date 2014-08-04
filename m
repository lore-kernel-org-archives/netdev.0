From: Dmitry Popov <ixaphire@qrator.net>
Subject: [PATCH net-next] tcp: md5: check md5 signature without socket lock
Date: Tue, 5 Aug 2014 02:54:52 +0400
Message-ID: <20140805025452.1a5bec4ad0d0c5a30a22a589@qrator.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since a8afca032 (tcp: md5: protects md5sig_info with RCU) tcp_md5_do_lookup
doesn't require socket lock, rcu_read_lock is enough. Therefore socket lock is
no longer required for tcp_v{4,6}_inbound_md5_hash too, so we can move these
calls (wrapped with rcu_read_{,un}lock) outside of bh_{,un}lock_sock: 
from tcp_v{4,6}_do_rcv to tcp_v{4,6}_rcv.

Signed-off-by: Dmitry Popov <ixaphire@qrator.net>
---
 net/ipv4/tcp_ipv4.c | 36 +++++++++++++++++++++++++-----------
 net/ipv6/tcp_ipv6.c | 25 +++++++++++++++++++------
 2 files changed, 44 insertions(+), 17 deletions(-)
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 77cccda..f2779b1 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1182,7 +1182,8 @@ clear_hash_noput:
 }
 EXPORT_SYMBOL(tcp_v4_md5_hash_skb);
 
-static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+static bool __tcp_v4_inbound_md5_hash(struct sock *sk,
+				      const struct sk_buff *skb)
 {
 	/*
 	 * This gets called for each TCP segment that arrives
@@ -1235,6 +1236,17 @@ static bool tcp_v4_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
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
 
 struct request_sock_ops tcp_request_sock_ops __read_mostly = {
@@ -1539,16 +1551,6 @@ static struct sock *tcp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
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
@@ -1751,6 +1753,18 @@ process:
 
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
index 229239a..226a237 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -676,7 +676,8 @@ clear_hash_noput:
 	return 1;
 }
 
-static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
+static int __tcp_v6_inbound_md5_hash(struct sock *sk,
+				     const struct sk_buff *skb)
 {
 	const __u8 *hash_location = NULL;
 	struct tcp_md5sig_key *hash_expected;
@@ -716,6 +717,18 @@ static int tcp_v6_inbound_md5_hash(struct sock *sk, const struct sk_buff *skb)
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
 
 struct request_sock_ops tcp6_request_sock_ops __read_mostly = {
@@ -1346,11 +1359,6 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	if (skb->protocol == htons(ETH_P_IP))
 		return tcp_v4_do_rcv(sk, skb);
 
-#ifdef CONFIG_TCP_MD5SIG
-	if (tcp_v6_inbound_md5_hash(sk, skb))
-		goto discard;
-#endif
-
 	if (sk_filter(sk, skb))
 		goto discard;
 
@@ -1523,6 +1531,11 @@ process:
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
+#ifdef CONFIG_TCP_MD5SIG
+	if (tcp_v6_inbound_md5_hash(sk, skb))
+		goto discard_and_relse;
+#endif
+
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
