From: David Miller <davem@davemloft.net>
Subject: [PATCH 11/15]: netfilter: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 05:02:24 -0700 (PDT)
Message-ID: <20090609.050224.246127309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760041AbZFIMCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 08:02:21 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 20B47C8C0F4
	for <netdev@vger.kernel.org>; Tue,  9 Jun 2009 05:02:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/netfilter/nf_nat_proto_sctp.c  |    5 +++--
 net/ipv6/netfilter/nf_conntrack_reasm.c |    4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/ipv4/netfilter/nf_nat_proto_sctp.c
index 65e470b..6983e41 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
@@ -33,6 +33,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	       enum nf_nat_manip_type maniptype)
 {
 	const struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
+	struct sk_buff *frag;
 	sctp_sctphdr_t *hdr;
 	unsigned int hdroff = iphdroff + iph->ihl*4;
 	__be32 oldip, newip;
@@ -57,8 +58,8 @@ sctp_manip_pkt(struct sk_buff *skb,
 	}
 
 	crc32 = sctp_start_cksum((u8 *)hdr, skb_headlen(skb) - hdroff);
-	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->next)
-		crc32 = sctp_update_cksum((u8 *)skb->data, skb_headlen(skb),
+	skb_walk_frags(skb, frag);
+		crc32 = sctp_update_cksum((u8 *)frag->data, skb_headlen(frag),
 					  crc32);
 	crc32 = sctp_end_cksum(crc32);
 	hdr->checksum = crc32;
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 058a5e4..f3aba25 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -409,7 +409,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 	/* If the first fragment is fragmented itself, we split
 	 * it to two chunks: the first with data and paged part
 	 * and the second, holding only fragments. */
-	if (skb_shinfo(head)->frag_list) {
+	if (skb_has_frags(head)) {
 		struct sk_buff *clone;
 		int i, plen = 0;
 
@@ -420,7 +420,7 @@ nf_ct_frag6_reasm(struct nf_ct_frag6_queue *fq, struct net_device *dev)
 		clone->next = head->next;
 		head->next = clone;
 		skb_shinfo(clone)->frag_list = skb_shinfo(head)->frag_list;
-		skb_shinfo(head)->frag_list = NULL;
+		skb_frag_list_init(head);
 		for (i=0; i<skb_shinfo(head)->nr_frags; i++)
 			plen += skb_shinfo(head)->frags[i].size;
 		clone->len = clone->data_len = head->data_len - plen;
-- 
1.6.3.2

