From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 8/10] [IPVS]: Replace local version of skb_make_writable
Date: Sun, 14 Oct 2007 12:27:46 +0800
Message-ID: <E1Igv4s-000310-00@gondolin.me.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1422 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751832AbXJNE2K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 00:28:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPVS]: Replace local version of skb_make_writable

This patch removes the IPVS-specific version of skb_make_writable and
replaces it with the netfilter one.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/ip_vs.h             |    1 
 net/ipv4/ipvs/ip_vs_app.c       |    5 ++--
 net/ipv4/ipvs/ip_vs_core.c      |   42 +---------------------------------------
 net/ipv4/ipvs/ip_vs_ftp.c       |    5 ++--
 net/ipv4/ipvs/ip_vs_proto_tcp.c |    5 ++--
 net/ipv4/ipvs/ip_vs_proto_udp.c |    5 ++--
 net/ipv4/ipvs/ip_vs_xmit.c      |    4 +--
 7 files changed, 16 insertions(+), 51 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 672564e..5da3b4a 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -984,7 +984,6 @@ static inline char ip_vs_fwd_tag(struct ip_vs_conn *cp)
 	return fwd;
 }
 
-extern int ip_vs_make_skb_writable(struct sk_buff **pskb, int len);
 extern void ip_vs_nat_icmp(struct sk_buff *skb, struct ip_vs_protocol *pp,
 		struct ip_vs_conn *cp, int dir);
 
diff --git a/net/ipv4/ipvs/ip_vs_app.c b/net/ipv4/ipvs/ip_vs_app.c
index 341474e..8ca5f48 100644
--- a/net/ipv4/ipvs/ip_vs_app.c
+++ b/net/ipv4/ipvs/ip_vs_app.c
@@ -25,6 +25,7 @@
 #include <linux/skbuff.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#include <linux/netfilter.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
 #include <net/tcp.h>
@@ -336,7 +337,7 @@ static inline int app_tcp_pkt_out(struct ip_vs_conn *cp, struct sk_buff **pskb,
 	struct tcphdr *th;
 	__u32 seq;
 
-	if (!ip_vs_make_skb_writable(pskb, tcp_offset + sizeof(*th)))
+	if (!skb_make_writable(*pskb, tcp_offset + sizeof(*th)))
 		return 0;
 
 	th = (struct tcphdr *)(skb_network_header(*pskb) + tcp_offset);
@@ -411,7 +412,7 @@ static inline int app_tcp_pkt_in(struct ip_vs_conn *cp, struct sk_buff **pskb,
 	struct tcphdr *th;
 	__u32 seq;
 
-	if (!ip_vs_make_skb_writable(pskb, tcp_offset + sizeof(*th)))
+	if (!skb_make_writable(*pskb, tcp_offset + sizeof(*th)))
 		return 0;
 
 	th = (struct tcphdr *)(skb_network_header(*pskb) + tcp_offset);
diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 3487337..09cac38 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -58,7 +58,6 @@ EXPORT_SYMBOL(ip_vs_conn_put);
 #ifdef CONFIG_IP_VS_DEBUG
 EXPORT_SYMBOL(ip_vs_get_debug_level);
 #endif
-EXPORT_SYMBOL(ip_vs_make_skb_writable);
 
 
 /* ID used in ICMP lookups */
@@ -163,42 +162,6 @@ ip_vs_set_state(struct ip_vs_conn *cp, int direction,
 }
 
 
-int ip_vs_make_skb_writable(struct sk_buff **pskb, int writable_len)
-{
-	struct sk_buff *skb = *pskb;
-
-	/* skb is already used, better copy skb and its payload */
-	if (unlikely(skb_shared(skb) || skb->sk))
-		goto copy_skb;
-
-	/* skb data is already used, copy it */
-	if (unlikely(skb_cloned(skb)))
-		goto copy_data;
-
-	return pskb_may_pull(skb, writable_len);
-
-  copy_data:
-	if (unlikely(writable_len > skb->len))
-		return 0;
-	return !pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-
-  copy_skb:
-	if (unlikely(writable_len > skb->len))
-		return 0;
-	skb = skb_copy(skb, GFP_ATOMIC);
-	if (!skb)
-		return 0;
-	BUG_ON(skb_is_nonlinear(skb));
-
-	/* Rest of kernel will get very unhappy if we pass it a
-	   suddenly-orphaned skbuff */
-	if ((*pskb)->sk)
-		skb_set_owner_w(skb, (*pskb)->sk);
-	kfree_skb(*pskb);
-	*pskb = skb;
-	return 1;
-}
-
 /*
  *  IPVS persistent scheduling function
  *  It creates a connection entry according to its template if exists,
@@ -689,9 +652,8 @@ static int ip_vs_out_icmp(struct sk_buff **pskb, int *related)
 
 	if (IPPROTO_TCP == cih->protocol || IPPROTO_UDP == cih->protocol)
 		offset += 2 * sizeof(__u16);
-	if (!ip_vs_make_skb_writable(pskb, offset))
+	if (!skb_make_writable(skb, offset))
 		goto out;
-	skb = *pskb;
 
 	ip_vs_nat_icmp(skb, pp, cp, 1);
 
@@ -799,7 +761,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff **pskb,
 
 	IP_VS_DBG_PKT(11, pp, skb, 0, "Outgoing packet");
 
-	if (!ip_vs_make_skb_writable(pskb, ihl))
+	if (!skb_make_writable(skb, ihl))
 		goto drop;
 
 	/* mangle the packet */
diff --git a/net/ipv4/ipvs/ip_vs_ftp.c b/net/ipv4/ipvs/ip_vs_ftp.c
index 344ddbb..4167d41 100644
--- a/net/ipv4/ipvs/ip_vs_ftp.c
+++ b/net/ipv4/ipvs/ip_vs_ftp.c
@@ -30,6 +30,7 @@
 #include <linux/skbuff.h>
 #include <linux/in.h>
 #include <linux/ip.h>
+#include <linux/netfilter.h>
 #include <net/protocol.h>
 #include <net/tcp.h>
 #include <asm/unaligned.h>
@@ -155,7 +156,7 @@ static int ip_vs_ftp_out(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		return 1;
 
 	/* Linear packets are much easier to deal with. */
-	if (!ip_vs_make_skb_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return 0;
 
 	if (cp->app_data == &ip_vs_ftp_pasv) {
@@ -256,7 +257,7 @@ static int ip_vs_ftp_in(struct ip_vs_app *app, struct ip_vs_conn *cp,
 		return 1;
 
 	/* Linear packets are much easier to deal with. */
-	if (!ip_vs_make_skb_writable(pskb, (*pskb)->len))
+	if (!skb_make_writable(*pskb, (*pskb)->len))
 		return 0;
 
 	/*
diff --git a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
index e65577a..b65b1a3 100644
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c
@@ -20,6 +20,7 @@
 #include <linux/tcp.h>                  /* for tcphdr */
 #include <net/ip.h>
 #include <net/tcp.h>                    /* for csum_tcpudp_magic */
+#include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
 #include <net/ip_vs.h>
@@ -129,7 +130,7 @@ tcp_snat_handler(struct sk_buff **pskb,
 	const unsigned int tcphoff = ip_hdrlen(*pskb);
 
 	/* csum_check requires unshared skb */
-	if (!ip_vs_make_skb_writable(pskb, tcphoff+sizeof(*tcph)))
+	if (!skb_make_writable(*pskb, tcphoff+sizeof(*tcph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
@@ -177,7 +178,7 @@ tcp_dnat_handler(struct sk_buff **pskb,
 	const unsigned int tcphoff = ip_hdrlen(*pskb);
 
 	/* csum_check requires unshared skb */
-	if (!ip_vs_make_skb_writable(pskb, tcphoff+sizeof(*tcph)))
+	if (!skb_make_writable(*pskb, tcphoff+sizeof(*tcph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
diff --git a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
index 8ee5fe6..c70aa40 100644
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c
@@ -18,6 +18,7 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/kernel.h>
+#include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/udp.h>
 
@@ -136,7 +137,7 @@ udp_snat_handler(struct sk_buff **pskb,
 	const unsigned int udphoff = ip_hdrlen(*pskb);
 
 	/* csum_check requires unshared skb */
-	if (!ip_vs_make_skb_writable(pskb, udphoff+sizeof(*udph)))
+	if (!skb_make_writable(*pskb, udphoff+sizeof(*udph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
@@ -190,7 +191,7 @@ udp_dnat_handler(struct sk_buff **pskb,
 	unsigned int udphoff = ip_hdrlen(*pskb);
 
 	/* csum_check requires unshared skb */
-	if (!ip_vs_make_skb_writable(pskb, udphoff+sizeof(*udph)))
+	if (!skb_make_writable(*pskb, udphoff+sizeof(*udph)))
 		return 0;
 
 	if (unlikely(cp->app != NULL)) {
diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 666e080..afd90d4 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -253,7 +253,7 @@ ip_vs_nat_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (!ip_vs_make_skb_writable(&skb, sizeof(struct iphdr)))
+	if (!skb_make_writable(skb, sizeof(struct iphdr)))
 		goto tx_error_put;
 
 	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
@@ -529,7 +529,7 @@ ip_vs_icmp_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	}
 
 	/* copy-on-write the packet before mangling it */
-	if (!ip_vs_make_skb_writable(&skb, offset))
+	if (!skb_make_writable(skb, offset))
 		goto tx_error_put;
 
 	if (skb_cow(skb, rt->u.dst.dev->hard_header_len))
