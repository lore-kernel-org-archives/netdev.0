From: kaber@trash.net
Subject: [PATCH 01/72] netfilter: nf_nat: add nf_nat_csum()
Date: Thu, 21 Oct 2010 17:18:48 +0200
Message-ID: <1287674399-31455-2-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119Ab0JUPUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:02 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Add a static function nf_nat_csum() to replace the duplicate code in
nf_nat_mangle_udp_packet() and __nf_nat_mangle_tcp_packet().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_helper.c |   76 +++++++++++++++---------------------
 1 files changed, 31 insertions(+), 45 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/ipv4/netfilter/nf_nat_helper.c
index 4a0c6b5..31427fb 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/ipv4/netfilter/nf_nat_helper.c
@@ -153,6 +153,35 @@ void nf_nat_set_seq_adjust(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 }
 EXPORT_SYMBOL_GPL(nf_nat_set_seq_adjust);
 
+static void nf_nat_csum(struct sk_buff *skb, struct iphdr *iph, void *data,
+			int datalen, __sum16 *check, int oldlen)
+{
+	struct rtable *rt = skb_rtable(skb);
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		if (!(rt->rt_flags & RTCF_LOCAL) &&
+		    skb->dev->features & NETIF_F_V4_CSUM) {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_headroom(skb) +
+					  skb_network_offset(skb) +
+					  iph->ihl * 4;
+			skb->csum_offset = (void *)check - data;
+			*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+						    datalen, iph->protocol, 0);
+		} else {
+			*check = 0;
+			*check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+						   datalen, iph->protocol,
+						   csum_partial(data, datalen,
+								0));
+			if (iph->protocol == IPPROTO_UDP && !*check)
+				*check = CSUM_MANGLED_0;
+		}
+	} else
+		inet_proto_csum_replace2(check, skb,
+					 htons(oldlen), htons(datalen), 1);
+}
+
 /* Generic function for mangling variable-length address changes inside
  * NATed TCP connections (like the PORT XXX,XXX,XXX,XXX,XXX,XXX
  * command in FTP).
@@ -169,7 +198,6 @@ int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 			       const char *rep_buffer,
 			       unsigned int rep_len, bool adjust)
 {
-	struct rtable *rt = skb_rtable(skb);
 	struct iphdr *iph;
 	struct tcphdr *tcph;
 	int oldlen, datalen;
@@ -192,26 +220,7 @@ int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 			match_offset, match_len, rep_buffer, rep_len);
 
 	datalen = skb->len - iph->ihl*4;
-	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    skb->dev->features & NETIF_F_V4_CSUM) {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_headroom(skb) +
-					  skb_network_offset(skb) +
-					  iph->ihl * 4;
-			skb->csum_offset = offsetof(struct tcphdr, check);
-			tcph->check = ~tcp_v4_check(datalen,
-						    iph->saddr, iph->daddr, 0);
-		} else {
-			tcph->check = 0;
-			tcph->check = tcp_v4_check(datalen,
-						   iph->saddr, iph->daddr,
-						   csum_partial(tcph,
-								datalen, 0));
-		}
-	} else
-		inet_proto_csum_replace2(&tcph->check, skb,
-					 htons(oldlen), htons(datalen), 1);
+	nf_nat_csum(skb, iph, tcph, datalen, &tcph->check, oldlen);
 
 	if (adjust && rep_len != match_len)
 		nf_nat_set_seq_adjust(ct, ctinfo, tcph->seq,
@@ -240,7 +249,6 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct rtable *rt = skb_rtable(skb);
 	struct iphdr *iph;
 	struct udphdr *udph;
 	int datalen, oldlen;
@@ -274,29 +282,7 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 	if (!udph->check && skb->ip_summed != CHECKSUM_PARTIAL)
 		return 1;
 
-	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    skb->dev->features & NETIF_F_V4_CSUM) {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_headroom(skb) +
-					  skb_network_offset(skb) +
-					  iph->ihl * 4;
-			skb->csum_offset = offsetof(struct udphdr, check);
-			udph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-							 datalen, IPPROTO_UDP,
-							 0);
-		} else {
-			udph->check = 0;
-			udph->check = csum_tcpudp_magic(iph->saddr, iph->daddr,
-							datalen, IPPROTO_UDP,
-							csum_partial(udph,
-								     datalen, 0));
-			if (!udph->check)
-				udph->check = CSUM_MANGLED_0;
-		}
-	} else
-		inet_proto_csum_replace2(&udph->check, skb,
-					 htons(oldlen), htons(datalen), 1);
+	nf_nat_csum(skb, iph, udph, datalen, &udph->check, oldlen);
 
 	return 1;
 }
-- 
1.7.1

