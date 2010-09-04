From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] netfilter: nat: add nf_nat_csum()
Date: Sat,  4 Sep 2010 12:45:41 +0800
Message-ID: <1283575541-23101-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:38268 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750789Ab0IDEqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Sep 2010 00:46:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a static function nf_nat_csum() to replace the duplicate code in
nf_nat_mangle_udp_packet() and __nf_nat_mangle_tcp_packet().

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/netfilter/nf_nat_helper.c |   76 +++++++++++++++----------------------
 1 file changed, 31 insertions(+), 45 deletions(-)
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
