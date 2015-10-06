From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2 2/2] mpls: flow-based multipath selection
Date: Tue,  6 Oct 2015 11:46:49 -0700
Message-ID: <1444157209-12518-3-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, ebiederm@xmission.com, rshearma@brocade.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34214 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbbJFSqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 14:46:55 -0400
Received: by padhy16 with SMTP id hy16so77619576pad.1
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 11:46:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>

Change the selection of a multipath route to use a flow-based
hash. This more suitable for traffic sensitive to reordering within a
flow (e.g. TCP, L2VPN) and whilst still allowing a good distribution
of traffic given enough flows.

Selection of the path for a multipath route is done using a hash of:
1. Label stack up to MAX_MP_SELECT_LABELS labels or up to and
   including entropy label, whichever is first.
2. 3-tuple of (L3 src, L3 dst, proto) from IPv4/IPv6 header in MPLS
   payload, if present.

Naturally, a 5-tuple hash using L4 information in addition would be
possible and be better in some scenarios, but there is a tradeoff
between looking deeper into the packet to achieve good distribution,
and packet forwarding performance, and I have erred on the side of the
latter as the default.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c | 110 ++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 76 insertions(+), 34 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index ae9e153..1bef057 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -22,9 +22,13 @@
 #include <net/nexthop.h>
 #include "internal.h"
 
+/* Maximum number of labels to look ahead at when selecting a path of
+ * a multipath route
+ */
+#define MAX_MP_SELECT_LABELS 4
+
 static int zero = 0;
 static int label_limit = (1 << 20) - 1;
-static DEFINE_SPINLOCK(mpls_multipath_lock);
 
 static void rtmsg_lfib(int event, u32 label, struct mpls_route *rt,
 		       struct nlmsghdr *nlh, struct net *net, u32 portid,
@@ -78,53 +82,91 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 }
 EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
-/* This is a cut/copy/modify from fib_select_multipath */
-static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt)
+static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
+					     struct sk_buff *skb, bool bos)
 {
+	struct mpls_entry_decoded dec;
+	struct mpls_shim_hdr *hdr;
 	struct mpls_nh *nh;
 	struct mpls_nh *ret_nh;
-	int nhsel = 0;
-	int w;
-
-	spin_lock_bh(&mpls_multipath_lock);
+	bool eli_seen = false;
+	int label_index;
+	int nh_index;
+	u32 hash = 0;
+	int nhsel;
+
+	/* No need to look further into packet if there's only
+	 * one path
+	 */
 	ret_nh = list_first_entry_or_null(&rt->rt_nhs, struct mpls_nh,
 					  nh_next);
-	if (rt->rt_power <= 0) {
-		int power = 0;
+	if (rt->rt_nhn == 1)
+		goto out;
 
-		list_for_each_entry(nh, &rt->rt_nhs, nh_next) {
-			power += nh->nh_weight;
-			nh->nh_power = nh->nh_weight;
+	for (label_index = 0; label_index < MAX_MP_SELECT_LABELS && !bos;
+	     label_index++) {
+		if (!pskb_may_pull(skb, sizeof(*hdr) * label_index))
+			break;
+
+		/* Read and decode the current label */
+		hdr = mpls_hdr(skb) + label_index;
+		dec = mpls_entry_decode(hdr);
+
+		/* RFC6790 - reserved labels MUST NOT be used as keys
+		 * for the load-balancing function
+		 */
+		if (dec.label == MPLS_LABEL_ENTROPY) {
+			eli_seen = true;
+		} else if (dec.label >= MPLS_LABEL_FIRST_UNRESERVED) {
+			hash = jhash_1word(dec.label, hash);
+
+			/* The entropy label follows the entropy label
+			 * indicator, so this means that the entropy
+			 * label was just added to the hash - no need to
+			 * go any deeper either in the label stack or in the
+			 * payload
+			 */
+			if (eli_seen)
+				break;
 		}
-		rt->rt_power = power;
-		if (power <= 0) {
-			spin_unlock_bh(&mpls_multipath_lock);
-			/* Race condition: route has just become dead. */
-			return ret_nh;
+
+		bos = dec.bos;
+		if (bos && pskb_may_pull(skb, sizeof(*hdr) * label_index +
+					 sizeof(struct iphdr))) {
+			const struct iphdr *v4hdr;
+
+			v4hdr = (const struct iphdr *)(mpls_hdr(skb) +
+						       label_index);
+			if (v4hdr->version == 4) {
+				hash = jhash_3words(ntohl(v4hdr->saddr),
+						    ntohl(v4hdr->daddr),
+						    v4hdr->protocol, hash);
+			} else if (v4hdr->version == 6 &&
+				pskb_may_pull(skb, sizeof(*hdr) * label_index +
+					      sizeof(struct ipv6hdr))) {
+				const struct ipv6hdr *v6hdr;
+
+				v6hdr = (const struct ipv6hdr *)(mpls_hdr(skb) +
+								label_index);
+
+				hash = __ipv6_addr_jhash(&v6hdr->saddr, hash);
+				hash = __ipv6_addr_jhash(&v6hdr->daddr, hash);
+				hash = jhash_1word(v6hdr->nexthdr, hash);
+			}
 		}
 	}
 
-	/* w should be random number [0..rt->rt_power-1],
-	 * it is pretty bad approximation.
-	 */
-	w = jiffies % rt->rt_power;
-
+	nh_index = hash % rt->rt_nhn;
+	nhsel = 0;
 	list_for_each_entry(nh, &rt->rt_nhs, nh_next) {
-		if (nh->nh_power) {
-			w -= nh->nh_power;
-			if (w <= 0) {
-				nh->nh_power--;
-				rt->rt_power--;
-				ret_nh = nh;
-				spin_unlock_bh(&mpls_multipath_lock);
-				return ret_nh;
-			}
+		if (nhsel == nh_index) {
+			ret_nh = nh;
+			break;
 		}
 		nhsel++;
 	}
 
-	/* Race condition: route has just become dead. */
-	spin_unlock_bh(&mpls_multipath_lock);
+out:
 	return ret_nh;
 }
 
@@ -220,7 +262,7 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	if (!rt)
 		goto drop;
 
-	nh = mpls_select_multipath(rt);
+	nh = mpls_select_multipath(rt, skb, dec.bos);
 	if (!nh)
 		goto drop;
 
-- 
1.9.1
