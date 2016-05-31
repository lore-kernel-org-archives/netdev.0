From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 4/7] skbuff: introduce skb_gso_validate_mtu
Date: Tue, 31 May 2016 15:55:47 -0300
Message-ID: <e88d8905cf03bac8995be6d722f8b5abfc7afcc5.1464718103.git.marcelo.leitner@gmail.com>
References: <cover.1464718103.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Xin Long <lucien.xin@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Florian Westphal <fw@strlen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42507 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755958AbcEaS4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 14:56:21 -0400
In-Reply-To: <cover.1464718103.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_gso_network_seglen is not enough for checking fragment sizes if
skb is using GSO_BY_FRAGS as we have to check frag per frag.

This patch introduces skb_gso_validate_mtu, based on the former, which
will wrap the use case inside it as all calls to skb_gso_network_seglen
were to validate if it fits on a given TMU, and improve the check.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Tested-by: Xin Long <lucien.xin@gmail.com>
---
 include/linux/skbuff.h |  1 +
 net/core/skbuff.c      | 31 +++++++++++++++++++++++++++++++
 net/ipv4/ip_forward.c  |  2 +-
 net/ipv4/ip_output.c   |  2 +-
 net/ipv6/ip6_output.c  |  2 +-
 net/mpls/af_mpls.c     |  2 +-
 6 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 1f713541cb2fc232cb0e8417232cb9942409c9fc..2109c2dc9767d454b2cd08696af039b6bcd1ace7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2992,6 +2992,7 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len);
 int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen);
 void skb_scrub_packet(struct sk_buff *skb, bool xnet);
 unsigned int skb_gso_transport_seglen(const struct sk_buff *skb);
+bool skb_gso_validate_mtu(const struct sk_buff *skb, unsigned int mtu);
 struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features);
 struct sk_buff *skb_vlan_untag(struct sk_buff *skb);
 int skb_ensure_writable(struct sk_buff *skb, int write_len);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 97c32c75e704af1f31b064e8f1e0475ff1505d67..5ca562b56ec39d39e1225d96547e242732518ffe 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4392,6 +4392,37 @@ unsigned int skb_gso_transport_seglen(const struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(skb_gso_transport_seglen);
 
+/**
+ * skb_gso_validate_mtu - Return in case such skb fits a given MTU
+ *
+ * @skb: GSO skb
+ *
+ * skb_gso_validate_mtu validates if a given skb will fit a wanted MTU
+ * once split.
+ */
+bool skb_gso_validate_mtu(const struct sk_buff *skb, unsigned int mtu)
+{
+	const struct skb_shared_info *shinfo = skb_shinfo(skb);
+	const struct sk_buff *iter;
+	unsigned int hlen;
+
+	hlen = skb_gso_network_seglen(skb);
+
+	if (shinfo->gso_size != GSO_BY_FRAGS)
+		return hlen <= mtu;
+
+	/* Undo this so we can re-use header sizes */
+	hlen -= GSO_BY_FRAGS;
+
+	skb_walk_frags(skb, iter) {
+		if (hlen + skb_headlen(iter) > mtu)
+			return false;
+	}
+
+	return true;
+}
+EXPORT_SYMBOL_GPL(skb_gso_validate_mtu);
+
 static struct sk_buff *skb_reorder_vlan_header(struct sk_buff *skb)
 {
 	if (skb_cow(skb, skb_headroom(skb)) < 0) {
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index cbfb1808fcc490b94dc0bbdab6142acb8fa37815..9f0a7b96646f368021d9cd51bc3f728ba49eed0d 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -54,7 +54,7 @@ static bool ip_exceeds_mtu(const struct sk_buff *skb, unsigned int mtu)
 	if (skb->ignore_df)
 		return false;
 
-	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+	if (skb_is_gso(skb) && skb_gso_validate_mtu(skb, mtu))
 		return false;
 
 	return true;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 124bf0a663283502deb03397343160d493a378b1..cbac493c913ac37b57a97314f9e7099b14b8246c 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -225,7 +225,7 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 
 	/* common case: locally created skb or seglen is <= mtu */
 	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
-	      skb_gso_network_seglen(skb) <= mtu)
+	      skb_gso_validate_mtu(skb, mtu))
 		return ip_finish_output2(net, sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index cbf127ae7c676650cc626cbf12cd61b6b570ea43..6b2f60a5c1de3063bb65c07b2b77c13f33890af8 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -368,7 +368,7 @@ static bool ip6_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 	if (skb->ignore_df)
 		return false;
 
-	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+	if (skb_is_gso(skb) && skb_gso_validate_mtu(skb, mtu))
 		return false;
 
 	return true;
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 0b80a7140cc494d8c39bd3efba2423272d1b8844..7a4aa3450dd71039e73516bd711ba7392493eb5e 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -91,7 +91,7 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 	if (skb->len <= mtu)
 		return false;
 
-	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+	if (skb_is_gso(skb) && skb_gso_validate_mtu(skb, mtu))
 		return false;
 
 	return true;
-- 
2.5.5
