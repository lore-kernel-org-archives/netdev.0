From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: mpls: Fix multipath selection for LSR use case
Date: Thu, 19 Jan 2017 16:51:03 -0800
Message-ID: <1484873463-11699-1-git-send-email-dsa@cumulusnetworks.com>
Cc: rshearma@brocade.com, roopa@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33913 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753600AbdATAvK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 19:51:10 -0500
Received: by mail-pg0-f50.google.com with SMTP id 14so18423525pgg.1
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 16:51:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS multipath for LSR is broken -- always selecting the first nexthop
in the one label case. For example:

    $ ip netns exec ns1 ip -f mpls ro ls
    100
            nexthop as to 200 via inet 172.16.2.2  dev virt12
            nexthop as to 300 via inet 172.16.3.2  dev virt13
    101
            nexthop as to 201 via inet6 2000:2::2  dev virt12
            nexthop as to 301 via inet6 2000:3::2  dev virt13

In this example incoming packets have a single MPLS labels which means
BOS bit is set. The BOS bit is passed from mpls_forward down to
mpls_multipath_hash which never processes the hash loop because BOS is 1.

Removing the bos arg from mpls_multipath_hash uncovers a number of other
problems with the hash loop that processes the MPLS label stack -- from
incorrect assumptions on the skb (skb has already pulled the first mpls
label in mpls_forward yet loop assumes it is there) to incorrect
pskb_may_pull checks (label_index starts at 0 and pskb_may_pull checks
all use sizeof() * label_index).

This patch addresses all problems by moving the skb_pull in mpls_forward
after mpls_select_multipath. This allows mpls_multipath_hash to see the
skb with the entire label stack as it arrived.

>From there mpls_multipath_hash is modified to additively compute the
total mpls header length on each pass (on pass N mpls_hdr_len is
N * sizeof(mpls_shim_hdr)). When the label is found with the BOS set it
verifies the skb has sufficient header for ipv4 or ipv6, and find the
IPv4 and IPv6 header by using the last mpls_hdr pointer and adding 1 to
advance past it.

With these changes I have verified the code correctly sees the label,
BOS, IPv4 and IPv6 addresses in the network header and icmp/tcp/udp
traffic for ipv4 and ipv6 are distributed across the nexthops.

Fixes: 1c78efa8319ca ("mpls: flow-based multipath selection")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 48 +++++++++++++++++++++++++-----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 4dc81963af8f..64d3bf269a26 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -119,18 +119,19 @@ void mpls_stats_inc_outucastpkts(struct net_device *dev,
 }
 EXPORT_SYMBOL_GPL(mpls_stats_inc_outucastpkts);
 
-static u32 mpls_multipath_hash(struct mpls_route *rt,
-			       struct sk_buff *skb, bool bos)
+static u32 mpls_multipath_hash(struct mpls_route *rt, struct sk_buff *skb)
 {
 	struct mpls_entry_decoded dec;
+	unsigned int mpls_hdr_len = 0;
 	struct mpls_shim_hdr *hdr;
 	bool eli_seen = false;
 	int label_index;
 	u32 hash = 0;
 
-	for (label_index = 0; label_index < MAX_MP_SELECT_LABELS && !bos;
+	for (label_index = 0; label_index < MAX_MP_SELECT_LABELS;
 	     label_index++) {
-		if (!pskb_may_pull(skb, sizeof(*hdr) * label_index))
+		mpls_hdr_len += sizeof(*hdr);
+		if (!pskb_may_pull(skb, mpls_hdr_len))
 			break;
 
 		/* Read and decode the current label */
@@ -155,37 +156,38 @@ static u32 mpls_multipath_hash(struct mpls_route *rt,
 			eli_seen = true;
 		}
 
-		bos = dec.bos;
-		if (bos && pskb_may_pull(skb, sizeof(*hdr) * label_index +
-					 sizeof(struct iphdr))) {
+		if (!dec.bos)
+			continue;
+
+		/* found bottom label; does skb have room for a header? */
+		if (pskb_may_pull(skb, mpls_hdr_len + sizeof(struct iphdr))) {
 			const struct iphdr *v4hdr;
 
-			v4hdr = (const struct iphdr *)(mpls_hdr(skb) +
-						       label_index);
+			v4hdr = (const struct iphdr *)(hdr + 1);
 			if (v4hdr->version == 4) {
 				hash = jhash_3words(ntohl(v4hdr->saddr),
 						    ntohl(v4hdr->daddr),
 						    v4hdr->protocol, hash);
 			} else if (v4hdr->version == 6 &&
-				pskb_may_pull(skb, sizeof(*hdr) * label_index +
-					      sizeof(struct ipv6hdr))) {
+				   pskb_may_pull(skb, mpls_hdr_len +
+						 sizeof(struct ipv6hdr))) {
 				const struct ipv6hdr *v6hdr;
 
-				v6hdr = (const struct ipv6hdr *)(mpls_hdr(skb) +
-								label_index);
-
+				v6hdr = (const struct ipv6hdr *)(hdr + 1);
 				hash = __ipv6_addr_jhash(&v6hdr->saddr, hash);
 				hash = __ipv6_addr_jhash(&v6hdr->daddr, hash);
 				hash = jhash_1word(v6hdr->nexthdr, hash);
 			}
 		}
+
+		break;
 	}
 
 	return hash;
 }
 
 static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
-					     struct sk_buff *skb, bool bos)
+					     struct sk_buff *skb)
 {
 	int alive = ACCESS_ONCE(rt->rt_nhn_alive);
 	u32 hash = 0;
@@ -201,7 +203,7 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	if (alive <= 0)
 		return NULL;
 
-	hash = mpls_multipath_hash(rt, skb, bos);
+	hash = mpls_multipath_hash(rt, skb);
 	nh_index = hash % alive;
 	if (alive == rt->rt_nhn)
 		goto out;
@@ -308,22 +310,22 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	hdr = mpls_hdr(skb);
 	dec = mpls_entry_decode(hdr);
 
-	/* Pop the label */
-	skb_pull(skb, sizeof(*hdr));
-	skb_reset_network_header(skb);
-
-	skb_orphan(skb);
-
 	rt = mpls_route_input_rcu(net, dec.label);
 	if (!rt) {
 		MPLS_INC_STATS(mdev, rx_noroute);
 		goto drop;
 	}
 
-	nh = mpls_select_multipath(rt, skb, dec.bos);
+	nh = mpls_select_multipath(rt, skb);
 	if (!nh)
 		goto err;
 
+	/* Pop the label */
+	skb_pull(skb, sizeof(*hdr));
+	skb_reset_network_header(skb);
+
+	skb_orphan(skb);
+
 	if (skb_warn_if_lro(skb))
 		goto err;
 
-- 
2.1.4
