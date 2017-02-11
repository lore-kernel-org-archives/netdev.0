From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net-next] net: rename dst_neigh_output back to neigh_output
Date: Sat, 11 Feb 2017 13:49:20 +0200
Message-ID: <1486813760-8124-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:51258 "EHLO ja.ssi.bg"
        rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753295AbdBKLuA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 11 Feb 2017 06:50:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the dst->pending_confirm flag was removed, we do not
need anymore to provide dst arg to dst_neigh_output.
So, rename it to neigh_output as before commit 5110effee8fd
("net: Do delayed neigh confirmation.").

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 drivers/net/vrf.c       |  4 ++--
 include/net/dst.h       | 12 ------------
 include/net/neighbour.h | 10 ++++++++++
 net/ipv4/ip_output.c    |  2 +-
 net/ipv6/ip6_output.c   |  2 +-
 5 files changed, 14 insertions(+), 16 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 630eafd..22379da 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -379,7 +379,7 @@ static int vrf_finish_output6(struct net *net, struct sock *sk,
 		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
 	if (!IS_ERR(neigh)) {
 		sock_confirm_neigh(skb, neigh);
-		ret = dst_neigh_output(dst, neigh, skb);
+		ret = neigh_output(neigh, skb);
 		rcu_read_unlock_bh();
 		return ret;
 	}
@@ -577,7 +577,7 @@ static int vrf_finish_output(struct net *net, struct sock *sk, struct sk_buff *s
 		neigh = __neigh_create(&arp_tbl, &nexthop, dev, false);
 	if (!IS_ERR(neigh)) {
 		sock_confirm_neigh(skb, neigh);
-		ret = dst_neigh_output(dst, neigh, skb);
+		ret = neigh_output(neigh, skb);
 	}
 
 	rcu_read_unlock_bh();
diff --git a/include/net/dst.h b/include/net/dst.h
index 84a1043..049af33 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -442,18 +442,6 @@ static inline void dst_confirm(struct dst_entry *dst)
 {
 }
 
-static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
-				   struct sk_buff *skb)
-{
-	const struct hh_cache *hh;
-
-	hh = &n->hh;
-	if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
-		return neigh_hh_output(hh, skb);
-	else
-		return n->output(n, skb);
-}
-
 static inline struct neighbour *dst_neigh_lookup(const struct dst_entry *dst, const void *daddr)
 {
 	struct neighbour *n = dst->ops->neigh_lookup(dst, NULL, daddr);
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 8b68384..5ebf694 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -468,6 +468,16 @@ static inline int neigh_hh_output(const struct hh_cache *hh, struct sk_buff *skb
 	return dev_queue_xmit(skb);
 }
 
+static inline int neigh_output(struct neighbour *n, struct sk_buff *skb)
+{
+	const struct hh_cache *hh = &n->hh;
+
+	if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
+		return neigh_hh_output(hh, skb);
+	else
+		return n->output(n, skb);
+}
+
 static inline struct neighbour *
 __neigh_lookup(struct neigh_table *tbl, const void *pkey, struct net_device *dev, int creat)
 {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 7a719f1..737ce82 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -225,7 +225,7 @@ static int ip_finish_output2(struct net *net, struct sock *sk, struct sk_buff *s
 		int res;
 
 		sock_confirm_neigh(skb, neigh);
-		res = dst_neigh_output(dst, neigh, skb);
+		res = neigh_output(neigh, skb);
 
 		rcu_read_unlock_bh();
 		return res;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d299040..a75871c 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -120,7 +120,7 @@ static int ip6_finish_output2(struct net *net, struct sock *sk, struct sk_buff *
 		neigh = __neigh_create(&nd_tbl, nexthop, dst->dev, false);
 	if (!IS_ERR(neigh)) {
 		sock_confirm_neigh(skb, neigh);
-		ret = dst_neigh_output(dst, neigh, skb);
+		ret = neigh_output(neigh, skb);
 		rcu_read_unlock_bh();
 		return ret;
 	}
-- 
1.9.3
