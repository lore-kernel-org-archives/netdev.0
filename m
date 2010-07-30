From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] nf_nat: use local variable hdrlen
Date: Fri, 30 Jul 2010 15:58:45 +0800
Message-ID: <1280476725-7637-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:60232 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097Ab0G3Pbc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jul 2010 11:31:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use local variable hdrlen instead of ip_hdrlen(skb).

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 net/ipv4/netfilter/nf_nat_core.c |   18 +++++++-----------
 1 file changed, 7 insertions(+), 11 deletions(-)
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index c7719b2..ca2e7e7 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -440,7 +440,7 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
 	if (!skb_make_writable(skb, hdrlen + sizeof(*inside)))
 		return 0;
 
-	inside = (void *)skb->data + ip_hdrlen(skb);
+	inside = (void *)skb->data + hdrlen;
 
 	/* We're actually going to mangle it beyond trivial checksum
 	   adjustment, so make sure the current checksum is correct. */
@@ -470,12 +470,10 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
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
 
@@ -484,15 +482,13 @@ int nf_nat_icmp_reply_translation(struct nf_conn *ct,
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
