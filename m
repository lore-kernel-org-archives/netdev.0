From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH 2.6] ipvs - do not use skb_checksum_help, nf_reset
Date: Sat, 11 Sep 2004 10:21:36 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0409111012030.1315@u.domain.uli>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, Wensong Zhang <wensong@linux-vs.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	Some IPVS changes for 2.6.9-rc1-bk17:

- do not use skb_checksum_help in input path as ipvs can handle
incoming CHECKSUM_HW packets

- remove useless skb_checksum_help from forwarding path

- claim that checksum is valid (CHECKSUM_NONE) when entering output
path for out->in packets

- do not reset/destroy the nfct in IP_VS_XMIT, the intention is to
reset the debugging field just to avoid log floods from nf_debug_ip_*
functions, it is known that the out->in ipvs packets traverse hooks in
non-standard way, eg. LOCAL_IN->LOCAL_OUT

Signed-off-by: Julian Anastasov <ja@ssi.bg>

diff -ur v2.6.9-rc1-bk17/linux/net/ipv4/ipvs/ip_vs_core.c linux/net/ipv4/ipvs/ip_vs_core.c
--- v2.6.9-rc1-bk17/linux/net/ipv4/ipvs/ip_vs_core.c	2004-09-11 09:35:19.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_core.c	2004-09-11 09:37:57.868509136 +0300
@@ -743,13 +743,6 @@
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
@@ -993,13 +986,6 @@
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
diff -ur v2.6.9-rc1-bk17/linux/net/ipv4/ipvs/ip_vs_xmit.c linux/net/ipv4/ipvs/ip_vs_xmit.c
--- v2.6.9-rc1-bk17/linux/net/ipv4/ipvs/ip_vs_xmit.c	2004-09-11 09:35:33.000000000 +0300
+++ linux/net/ipv4/ipvs/ip_vs_xmit.c	2004-09-11 09:42:28.497367296 +0300
@@ -124,11 +124,17 @@
 	dst_release(old_dst);
 }
 
+#ifdef CONFIG_NETFILTER_DEBUG
+#define reset_nf_debugging(skb)	do { (skb)->nf_debug = 0; } while (0)
+#else
+#define reset_nf_debugging(skb)	do { } while (0)
+#endif
 
 #define IP_VS_XMIT(skb, rt)				\
 do {							\
-	nf_reset(skb);					\
+	reset_nf_debugging(skb);			\
 	(skb)->nfcache |= NFC_IPVS_PROPERTY;		\
+	(skb)->ip_summed = CHECKSUM_NONE;		\
 	NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, (skb), NULL,	\
 		(rt)->u.dst.dev, dst_output);		\
 } while (0)
@@ -408,8 +414,6 @@
 	ip_select_ident(iph, &rt->u.dst, NULL);
 	ip_send_check(iph);
 
-	skb->ip_summed = CHECKSUM_NONE;
-
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->local_df = 1;
 
