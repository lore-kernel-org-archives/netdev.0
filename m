From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net v2] net: mpls: Fix multipath selection for LSR use case
Date: Fri, 20 Jan 2017 12:58:34 -0800
Message-ID: <1484945914-32085-1-git-send-email-dsa@cumulusnetworks.com>
Cc: rshearma@brocade.com, roopa@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34615 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753121AbdATU6l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:58:41 -0500
Received: by mail-pg0-f43.google.com with SMTP id 14so26302058pgg.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:58:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS multipath for LSR is broken -- always selecting the first nexthop
in the one label case. For example:

    $ ip -f mpls ro ls
    100
            nexthop as to 200 via inet 172.16.2.2  dev virt12
            nexthop as to 300 via inet 172.16.3.2  dev virt13
    101
            nexthop as to 201 via inet6 2000:2::2  dev virt12
            nexthop as to 301 via inet6 2000:3::2  dev virt13

In this example incoming packets have a single MPLS labels which means
BOS bit is set. The BOS bit is passed from mpls_forward down to
mpls_multipath_hash which never processes the hash loop because BOS is 1.

Update mpls_multipath_hash to process the entire label stack. mpls_hdr_len
tracks the total mpls header length on each pass (on pass N mpls_hdr_len
is N * sizeof(mpls_shim_hdr)). When the label is found with the BOS set
it verifies the skb has sufficient header for ipv4 or ipv6, and find the
IPv4 and IPv6 header by using the last mpls_hdr pointer and adding 1 to
advance past it.

With these changes I have verified the code correctly sees the label,
BOS, IPv4 and IPv6 addresses in the network header and icmp/tcp/udp
traffic for ipv4 and ipv6 are distributed across the nexthops.

Fixes: 1c78efa8319ca ("mpls: flow-based multipath selection")
Acked-by: Robert Shearman <rshearma@brocade.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- rebase against net/master; v1 was mistakenly based against net-next
- updated commit message based on Robert's comment about skipping the
  first label

 net/mpls/af_mpls.c | 48 +++++++++++++++++++++++++-----------------------
 1 file changed, 25 insertions(+), 23 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 15fe97644ffe..5b77377e5a15 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -98,18 +98,19 @@ bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
 }
 EXPORT_SYMBOL_GPL(mpls_pkt_too_big);
 
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
@@ -134,37 +135,38 @@ static u32 mpls_multipath_hash(struct mpls_route *rt,
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
@@ -180,7 +182,7 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	if (alive <= 0)
 		return NULL;
 
-	hash = mpls_multipath_hash(rt, skb, bos);
+	hash = mpls_multipath_hash(rt, skb);
 	nh_index = hash % alive;
 	if (alive == rt->rt_nhn)
 		goto out;
@@ -278,17 +280,11 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	hdr = mpls_hdr(skb);
 	dec = mpls_entry_decode(hdr);
 
-	/* Pop the label */
-	skb_pull(skb, sizeof(*hdr));
-	skb_reset_network_header(skb);
-
-	skb_orphan(skb);
-
 	rt = mpls_route_input_rcu(net, dec.label);
 	if (!rt)
 		goto drop;
 
-	nh = mpls_select_multipath(rt, skb, dec.bos);
+	nh = mpls_select_multipath(rt, skb);
 	if (!nh)
 		goto drop;
 
@@ -297,6 +293,12 @@ static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
 	if (!mpls_output_possible(out_dev))
 		goto drop;
 
+	/* Pop the label */
+	skb_pull(skb, sizeof(*hdr));
+	skb_reset_network_header(skb);
+
+	skb_orphan(skb);
+
 	if (skb_warn_if_lro(skb))
 		goto drop;
 
-- 
2.1.4
