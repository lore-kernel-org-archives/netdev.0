From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH RFC net-next] net: Add GRO support for GRE tunneling of TEB packets
Date: Wed, 26 Nov 2014 17:08:24 +0200
Message-ID: <1417014504-5929-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, therbert@google.com, edumazet@google.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"H.K. Jerry Chu" <hkchu@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47401 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752064AbaKZPI2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Nov 2014 10:08:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the missing parts in the gre gro handlers when the inner protocol 
is ETH_P_TEB which is the case for OVS based GRE tunneling.

Cc: H.K. Jerry Chu <hkchu@google.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/ipv4/gre_offload.c |   57 +++++++++++++++++++++++++++++++++++++----------
 1 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index bb5947b..06ae197 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <net/protocol.h>
 #include <net/gre.h>
+#include <linux/etherdevice.h>
 
 static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
@@ -121,8 +122,9 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
 	const struct gre_base_hdr *greh;
+	struct ethhdr *eh = NULL;
 	unsigned int hlen, grehlen;
-	unsigned int off;
+	unsigned int off, off_eth = 0;
 	int flush = 1;
 	struct packet_offload *ptype;
 	__be16 type;
@@ -147,11 +149,6 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 
 	type = greh->protocol;
 
-	rcu_read_lock();
-	ptype = gro_find_receive_by_type(type);
-	if (ptype == NULL)
-		goto out_unlock;
-
 	grehlen = GRE_HEADER_SECTION;
 
 	if (greh->flags & GRE_KEY)
@@ -164,22 +161,45 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 	if (skb_gro_header_hard(skb, hlen)) {
 		greh = skb_gro_header_slow(skb, hlen, off);
 		if (unlikely(!greh))
-			goto out_unlock;
+			goto out;
 	}
 
 	/* Don't bother verifying checksum if we're going to flush anyway. */
 	if ((greh->flags & GRE_CSUM) && !NAPI_GRO_CB(skb)->flush) {
 		if (skb_gro_checksum_simple_validate(skb))
-			goto out_unlock;
+			goto out;
 
 		skb_gro_checksum_try_convert(skb, IPPROTO_GRE, 0,
 					     null_compute_pseudo);
 	}
 
+	skb_gro_pull(skb, grehlen);
+
+	/* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
+	skb_gro_postpull_rcsum(skb, greh, grehlen);
+
+	if (type == ntohs(ETH_P_TEB)) {
+		off_eth = skb_gro_offset(skb);
+		hlen = off_eth + sizeof(*eh);
+		eh   = skb_gro_header_fast(skb, off_eth);
+		if (skb_gro_header_hard(skb, hlen)) {
+			eh = skb_gro_header_slow(skb, hlen, off_eth);
+			if (unlikely(!eh))
+				goto out;
+		}
+		type = eh->h_proto;
+	}
+
+	rcu_read_lock();
+	ptype = gro_find_receive_by_type(type);
+	if (ptype == NULL)
+		goto out_unlock;
+
 	flush = 0;
 
 	for (p = *head; p; p = p->next) {
 		const struct gre_base_hdr *greh2;
+		const struct ethhdr *eh2;
 
 		if (!NAPI_GRO_CB(p)->same_flow)
 			continue;
@@ -205,13 +225,19 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 				NAPI_GRO_CB(p)->same_flow = 0;
 				continue;
 			}
+
+			eh2 = (struct ethhdr   *)(p->data + off_eth);
+			if (eh && compare_ether_header(eh, eh2)) {
+				NAPI_GRO_CB(p)->same_flow = 0;
+				continue;
+			}
 		}
 	}
 
-	skb_gro_pull(skb, grehlen);
-
-	/* Adjusted NAPI_GRO_CB(skb)->csum after skb_gro_pull()*/
-	skb_gro_postpull_rcsum(skb, greh, grehlen);
+	if (eh) {
+		skb_gro_pull(skb, sizeof(*eh)); /* pull inner eth header */
+		skb_gro_postpull_rcsum(skb, eh, sizeof(*eh));
+	}
 
 	pp = ptype->callbacks.gro_receive(head, skb);
 
@@ -229,6 +255,7 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 	struct packet_offload *ptype;
 	unsigned int grehlen = sizeof(*greh);
 	int err = -ENOENT;
+	struct ethhdr *eh;
 	__be16 type;
 
 	skb->encapsulation = 1;
@@ -241,6 +268,12 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 	if (greh->flags & GRE_CSUM)
 		grehlen += GRE_HEADER_SECTION;
 
+	if (type == ntohs(ETH_P_TEB)) {
+		eh = (struct ethhdr *)(skb->data + nhoff + grehlen);
+		type = eh->h_proto;
+		grehlen += sizeof(*eh);
+	}
+
 	rcu_read_lock();
 	ptype = gro_find_complete_by_type(type);
 	if (ptype != NULL)
-- 
1.7.1
