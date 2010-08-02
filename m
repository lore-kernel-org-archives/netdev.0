From: kaber@trash.net
Subject: [PATCH 25/28] netfilter: nf_nat: use local variable hdrlen
Date: Mon,  2 Aug 2010 21:57:42 +0200
Message-ID: <1280779065-9333-26-git-send-email-kaber@trash.net>
References: <1280779065-9333-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35397 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866Ab0HBT6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 15:58:04 -0400
In-Reply-To: <1280779065-9333-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Use local variable hdrlen instead of ip_hdrlen(skb).

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_core.c |   18 +++++++-----------
 1 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 037a3a6..8c8632d 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -435,7 +435,7 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	if (!skb_make_writable(skb, hdrlen + sizeof(*inside)))
 		return 0;
 
-	inside = (void *)skb->data + ip_hdrlen(skb);
+	inside = (void *)skb->data + hdrlen;
 
 	/* We're actually going to mangle it beyond trivial checksum
 	   adjustment, so make sure the current checksum is correct. */
@@ -465,12 +465,10 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	/* rcu_read_lock()ed by nf_hook_slow */
 	l4proto = __nf_ct_l4proto_find(PF_INET, inside->ip.protocol);
 
-	if (!nf_ct_get_tuple(skb,
-			     ip_hdrlen(skb) + sizeof(struct icmphdr),
-			     (ip_hdrlen(skb) +
+	if (!nf_ct_get_tuple(skb, hdrlen + sizeof(struct icmphdr),
+			     (hdrlen +
 			      sizeof(struct icmphdr) + inside->ip.ihl * 4),
-			     (u_int16_t)AF_INET,
-			     inside->ip.protocol,
+			     (u_int16_t)AF_INET, inside->ip.protocol,
 			     &inner, l3proto, l4proto))
 		return 0;
 
@@ -479,15 +477,13 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	   pass all hooks (locally-generated ICMP).  Consider incoming
 	   packet: PREROUTING (DST manip), routing produces ICMP, goes
 	   through POSTROUTING (which must correct the DST manip). */
-	if (!manip_pkt(inside->ip.protocol, skb,
-		       ip_hdrlen(skb) + sizeof(inside->icmp),
-		       &ct->tuplehash[!dir].tuple,
-		       !manip))
+	if (!manip_pkt(inside->ip.protocol, skb, hdrlen + sizeof(inside->icmp),
+		       &ct->tuplehash[!dir].tuple, !manip))
 		return 0;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
 		/* Reloading "inside" here since manip_pkt inner. */
-		inside = (void *)skb->data + ip_hdrlen(skb);
+		inside = (void *)skb->data + hdrlen;
 		inside->icmp.checksum = 0;
 		inside->icmp.checksum =
 			csum_fold(skb_checksum(skb, hdrlen,
-- 
1.7.1

