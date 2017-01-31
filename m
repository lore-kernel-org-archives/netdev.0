From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCHv3 net-next 6/7] net: use dst_confirm_neigh for UDP, RAW, ICMP, L2TP
Date: Tue, 31 Jan 2017 23:57:06 +0200
Message-ID: <1485899827-5212-7-git-send-email-ja@ssi.bg>
References: <1485899827-5212-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        linux-rdma@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58179 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751153AbdAaV66 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 16:58:58 -0500
In-Reply-To: <1485899827-5212-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When same struct dst_entry can be used for many different
neighbours we can not use it for pending confirmations.

The datagram protocols can use MSG_CONFIRM to confirm the
neighbour. When used with MSG_PROBE we do not reach the
code where neighbour is confirmed, so we have to do the
same slow lookup by using the dst_confirm_neigh() helper.
When MSG_PROBE is not used, ip_append_data/ip6_append_data
will set the skb flag dst_pending_confirm.

Reported-by: YueHaibing <yuehaibing@huawei.com>
Fixes: 5110effee8fd ("net: Do delayed neigh confirmation.")
Fixes: f2bb4bedf35d ("ipv4: Cache output routes in fib_info nexthops.")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Acked-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_output.c  |  6 ++++++
 net/ipv4/ping.c       |  3 ++-
 net/ipv4/raw.c        |  6 +++++-
 net/ipv4/udp.c        |  3 ++-
 net/ipv6/ip6_output.c |  6 ++++++
 net/ipv6/raw.c        |  6 +++++-
 net/ipv6/route.c      | 27 ++++++++++++++-------------
 net/ipv6/udp.c        |  3 ++-
 net/l2tp/l2tp_ip6.c   |  3 ++-
 9 files changed, 44 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 27f1db7..ff0fcaa 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -889,6 +889,9 @@ static inline int ip_ufo_append_data(struct sock *sk,
 
 		skb->csum = 0;
 
+		if (flags & MSG_CONFIRM)
+			skb_set_dst_pending_confirm(skb, 1);
+
 		__skb_queue_tail(queue, skb);
 	} else if (skb_is_gso(skb)) {
 		goto append;
@@ -1089,6 +1092,9 @@ static int __ip_append_data(struct sock *sk,
 			exthdrlen = 0;
 			csummode = CHECKSUM_NONE;
 
+			if ((flags & MSG_CONFIRM) && !skb_prev)
+				skb_set_dst_pending_confirm(skb, 1);
+
 			/*
 			 * Put the packet on the pending queue.
 			 */
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index 592db6a..6ee792d 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -848,7 +848,8 @@ static int ping_v4_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return err;
 
 do_confirm:
-	dst_confirm(&rt->dst);
+	if (msg->msg_flags & MSG_PROBE)
+		dst_confirm_neigh(&rt->dst, &fl4.daddr);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 4e49e5c..8119e1f 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -383,6 +383,9 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	sock_tx_timestamp(sk, sockc->tsflags, &skb_shinfo(skb)->tx_flags);
 
+	if (flags & MSG_CONFIRM)
+		skb_set_dst_pending_confirm(skb, 1);
+
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
 	if (memcpy_from_msg(iph, msg, length))
@@ -666,7 +669,8 @@ static int raw_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return len;
 
 do_confirm:
-	dst_confirm(&rt->dst);
+	if (msg->msg_flags & MSG_PROBE)
+		dst_confirm_neigh(&rt->dst, &fl4.daddr);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index d6dddcf..4bdb358 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1088,7 +1088,8 @@ int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return err;
 
 do_confirm:
-	dst_confirm(&rt->dst);
+	if (msg->msg_flags & MSG_PROBE)
+		dst_confirm_neigh(&rt->dst, &fl4->daddr);
 	if (!(msg->msg_flags&MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 7d90cab..5d944c1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1145,6 +1145,9 @@ static inline int ip6_ufo_append_data(struct sock *sk,
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->csum = 0;
 
+		if (flags & MSG_CONFIRM)
+			skb_set_dst_pending_confirm(skb, 1);
+
 		__skb_queue_tail(queue, skb);
 	} else if (skb_is_gso(skb)) {
 		goto append;
@@ -1517,6 +1520,9 @@ static int __ip6_append_data(struct sock *sk,
 			exthdrlen = 0;
 			dst_exthdrlen = 0;
 
+			if ((flags & MSG_CONFIRM) && !skb_prev)
+				skb_set_dst_pending_confirm(skb, 1);
+
 			/*
 			 * Put the packet on the pending queue
 			 */
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ea89073..f174e76 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -654,6 +654,9 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 
 	skb->ip_summed = CHECKSUM_NONE;
 
+	if (flags & MSG_CONFIRM)
+		skb_set_dst_pending_confirm(skb, 1);
+
 	skb->transport_header = skb->network_header;
 	err = memcpy_from_msg(iph, msg, length);
 	if (err)
@@ -934,7 +937,8 @@ static int rawv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	txopt_put(opt_to_free);
 	return err < 0 ? err : len;
 do_confirm:
-	dst_confirm(dst);
+	if (msg->msg_flags & MSG_PROBE)
+		dst_confirm_neigh(dst, &fl6.daddr);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c876940..15e45a6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1375,6 +1375,7 @@ static bool rt6_cache_allowed_for_pmtu(const struct rt6_info *rt)
 static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 				 const struct ipv6hdr *iph, u32 mtu)
 {
+	const struct in6_addr *daddr, *saddr;
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
 	if (rt6->rt6i_flags & RTF_LOCAL)
@@ -1383,26 +1384,26 @@ static void __ip6_rt_update_pmtu(struct dst_entry *dst, const struct sock *sk,
 	if (dst_metric_locked(dst, RTAX_MTU))
 		return;
 
-	dst_confirm(dst);
+	if (iph) {
+		daddr = &iph->daddr;
+		saddr = &iph->saddr;
+	} else if (sk) {
+		daddr = &sk->sk_v6_daddr;
+		saddr = &inet6_sk(sk)->saddr;
+	} else {
+		daddr = NULL;
+		saddr = NULL;
+	}
+	dst_confirm_neigh(dst, daddr);
 	mtu = max_t(u32, mtu, IPV6_MIN_MTU);
 	if (mtu >= dst_mtu(dst))
 		return;
 
 	if (!rt6_cache_allowed_for_pmtu(rt6)) {
 		rt6_do_update_pmtu(rt6, mtu);
-	} else {
-		const struct in6_addr *daddr, *saddr;
+	} else if (daddr) {
 		struct rt6_info *nrt6;
 
-		if (iph) {
-			daddr = &iph->daddr;
-			saddr = &iph->saddr;
-		} else if (sk) {
-			daddr = &sk->sk_v6_daddr;
-			saddr = &inet6_sk(sk)->saddr;
-		} else {
-			return;
-		}
 		nrt6 = ip6_rt_cache_alloc(rt6, daddr, saddr);
 		if (nrt6) {
 			rt6_do_update_pmtu(nrt6, mtu);
@@ -2274,7 +2275,7 @@ static void rt6_do_redirect(struct dst_entry *dst, struct sock *sk, struct sk_bu
 	 * Look, redirects are sent only in response to data packets,
 	 * so that this nexthop apparently is reachable. --ANK
 	 */
-	dst_confirm(&rt->dst);
+	dst_confirm_neigh(&rt->dst, &ipv6_hdr(skb)->saddr);
 
 	neigh = __neigh_lookup(&nd_tbl, &msg->target, skb->dev, 1);
 	if (!neigh)
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 05d6932..9402f7a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1295,7 +1295,8 @@ int udpv6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return err;
 
 do_confirm:
-	dst_confirm(dst);
+	if (msg->msg_flags & MSG_PROBE)
+		dst_confirm_neigh(dst, &fl6.daddr);
 	if (!(msg->msg_flags&MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 4b06eb4..734798a 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -658,7 +658,8 @@ static int l2tp_ip6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
 	return err < 0 ? err : len;
 
 do_confirm:
-	dst_confirm(dst);
+	if (msg->msg_flags & MSG_PROBE)
+		dst_confirm_neigh(dst, &fl6.daddr);
 	if (!(msg->msg_flags & MSG_PROBE) || len)
 		goto back_from_confirm;
 	err = 0;
-- 
1.9.3
