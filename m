From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2.6.8] ipvs - do not use skb_checksum_help
Date: Mon, 16 Aug 2004 10:05:54 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0408160948390.1323@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wensong Zhang <wensong@linux-vs.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	The skb_checksum_help calls are not appropriate for
IPVS. There is already code to check and alter the ip_summed
field on packet mangling and the only thing that is needed is
to ensure ip_summed is valid for output path if the packet is
not mangled. In such case we do not validate checksum and
forward the packet claiming it is with valid checksum.
Apply after ack from Wensong.

Signed-off-by: Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.8/linux/net/ipv4/ipvs/ip_vs_core.c linux/net/ipv4/ipvs/ip_vs_core.c
--- v2.6.8/linux/net/ipv4/ipvs/ip_vs_core.c	2004-06-16 23:54:06.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_core.c	2004-08-16 09:35:01.317806616 +0300
@@ -735,13 +735,6 @@
 	if (skb->nfcache & NFC_IPVS_PROPERTY)
 		return NF_ACCEPT;
 
-	if (skb->ip_summed == CHECKSUM_HW) {
-		if (skb_checksum_help(pskb, (out == NULL)))
-			return NF_DROP;
-		if (skb != *pskb)
-			skb = *pskb;
-	}
-
 	iph = skb->nh.iph;
 	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
 		int related, verdict = ip_vs_out_icmp(pskb, &related);
@@ -981,13 +974,6 @@
 		return NF_ACCEPT;
 	}
 
-	if (skb->ip_summed == CHECKSUM_HW) {
-		if (skb_checksum_help(pskb, (out == NULL)))
-			return NF_DROP;
-		if (skb != *pskb)
-			skb = *pskb;
-	}
-
 	iph = skb->nh.iph;
 	if (unlikely(iph->protocol == IPPROTO_ICMP)) {
 		int related, verdict = ip_vs_in_icmp(pskb, &related);
diff -ur v2.6.8/linux/net/ipv4/ipvs/ip_vs_xmit.c linux/net/ipv4/ipvs/ip_vs_xmit.c
--- v2.6.8/linux/net/ipv4/ipvs/ip_vs_xmit.c	2004-08-14 11:08:13.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_xmit.c	2004-08-16 09:37:26.024807808 +0300
@@ -128,6 +128,7 @@
 #define IP_VS_XMIT(skb, rt)				\
 do {							\
 	(skb)->nfcache |= NFC_IPVS_PROPERTY;		\
+	(skb)->ip_summed = CHECKSUM_NONE;		\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
 } while (0)
@@ -412,8 +413,6 @@
 	ip_select_ident(iph, &rt->u.dst, NULL);
 	ip_send_check(iph);
 
-	skb->ip_summed = CHECKSUM_NONE;
-
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
