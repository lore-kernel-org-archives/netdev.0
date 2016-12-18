From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH RFC net-next 2/7] net: add dst_pending_confirm flag to skbuff
Date: Sun, 18 Dec 2016 22:56:31 +0200
Message-ID: <1482094596-26046-3-git-send-email-ja@ssi.bg>
References: <1482094596-26046-1-git-send-email-ja@ssi.bg>
Cc: linux-sctp@vger.kernel.org, YueHaibing <yuehaibing@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:46911 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753655AbcLRU5o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Dec 2016 15:57:44 -0500
In-Reply-To: <1482094596-26046-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new skbuff flag to allow protocols to confirm neighbour.
When same struct dst_entry can be used for many different
neighbours we can not use it for pending confirmations.

Add sock_confirm_neigh() helper to confirm the neighbour and
use it for IPv4, IPv6 and VRF before dst_neigh_output.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 drivers/net/vrf.c      |  5 ++++-
 include/linux/skbuff.h |  4 +++-
 include/net/sock.h     | 14 ++++++++++++++
 net/ipv4/ip_output.c   |  5 ++++-
 net/ipv6/ip6_output.c  |  1 +
 5 files changed, 26 insertions(+), 3 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 7532646..b118d2b 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -377,6 +377,7 @@ static int vrf_finish_output6(struct net *net, struct sock *sk,
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
 	if (!IS_ERR(neigh)) {
+		sock_confirm_neigh(skb, neigh);
 		ret = dst_neigh_output(dst, neigh, skb);
 		rcu_read_unlock_bh();
 		return ret;
@@ -573,8 +574,10 @@ static int vrf_finish_output(struct net *net, struct sock *sk, struct sk_buff *s
 	neigh = __ipv4_neigh_lookup_noref(dev, nexthop);
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
-	if (!IS_ERR(neigh))
+	if (!IS_ERR(neigh)) {
+		sock_confirm_neigh(skb, neigh);
 		ret = dst_neigh_output(dst, neigh, skb);
+	}
 
 	rcu_read_unlock_bh();
 err:
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ac7fa34..94d7c36 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -610,6 +610,7 @@ static inline bool skb_mstamp_after(const struct skb_mstamp *t1,
  *	@wifi_acked_valid: wifi_acked was set
  *	@wifi_acked: whether frame was acked on wifi or not
  *	@no_fcs:  Request NIC to treat last 4 bytes as Ethernet FCS
+ *	@dst_pending_confirm: need to confirm neighbour
   *	@napi_id: id of the NAPI struct this skb came from
  *	@secmark: security marking
  *	@mark: Generic packet mark
@@ -740,6 +741,7 @@ struct sk_buff {
 	__u8			csum_level:2;
 	__u8			csum_bad:1;
 
+	__u8			dst_pending_confirm:1;
 #ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
 #endif
@@ -749,7 +751,7 @@ struct sk_buff {
 #ifdef CONFIG_NET_SWITCHDEV
 	__u8			offload_fwd_mark:1;
 #endif
-	/* 2, 4 or 5 bit hole */
+	/* 1, 3 or 4 bit hole */
 
 #ifdef CONFIG_NET_SCHED
 	__u16			tc_index;	/* traffic control index */
diff --git a/include/net/sock.h b/include/net/sock.h
index e83bb01..bd63d4d 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1818,6 +1818,20 @@ static inline void sk_dst_confirm(struct sock *sk)
 		sk->sk_dst_pending_confirm = 1;
 }
 
+static inline void sock_confirm_neigh(struct sk_buff *skb, struct neighbour *n)
+{
+	if (unlikely(skb->dst_pending_confirm)) {
+		struct sock *sk = skb->sk;
+		unsigned long now = jiffies;
+
+		/* avoid dirtying neighbour */
+		if (n->confirmed != now)
+			n->confirmed = now;
+		if (sk && sk->sk_dst_pending_confirm)
+			sk->sk_dst_pending_confirm = 0;
+	}
+}
+
 bool sk_mc_loop(struct sock *sk);
 
 static inline bool sk_can_gso(const struct sock *sk)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 6c9615c..fbe63cc 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -222,7 +222,10 @@ static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *s
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
 	if (!IS_ERR(neigh)) {
-		int res = dst_neigh_output(dst, neigh, skb);
+		int res;
+
+		sock_confirm_neigh(skb, neigh);
+		res = dst_neigh_output(dst, neigh, skb);
 
 		rcu_read_unlock_bh();
 		return res;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 70d0de40..285aa9f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -119,6 +119,7 @@ static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *
 	if (unlikely(!neigh))
 		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
 	if (!IS_ERR(neigh)) {
+		sock_confirm_neigh(skb, neigh);
 		ret = dst_neigh_output(dst, neigh, skb);
 		rcu_read_unlock_bh();
 		return ret;
-- 
1.9.3
