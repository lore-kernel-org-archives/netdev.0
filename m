From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [INET] Update ECN handling wrt RFC 3168
Date: Wed, 8 Sep 2004 13:11:02 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040908031102.GA9273@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch brings the IP ECN handling up-to-date with repsect to
RFC 3168.  Mostly this means treating ECT(1) in the same way as
ECT(0).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/inet_ecn.h 1.5 vs edited =====
--- 1.5/include/net/inet_ecn.h	2004-07-23 05:16:04 +10:00
+++ edited/include/net/inet_ecn.h	2004-09-08 12:00:01 +10:00
@@ -16,9 +16,9 @@
 	return (dsfield & INET_ECN_MASK) == INET_ECN_CE;
 }
 
-static inline int INET_ECN_is_not_ce(__u8 dsfield)
+static inline int INET_ECN_is_not_ect(__u8 dsfield)
 {
-	return (dsfield & INET_ECN_MASK) == INET_ECN_ECT_0;
+	return (dsfield & INET_ECN_MASK) == INET_ECN_NOT_ECT;
 }
 
 static inline int INET_ECN_is_capable(__u8 dsfield)
@@ -29,8 +29,7 @@
 static inline __u8 INET_ECN_encapsulate(__u8 outer, __u8 inner)
 {
 	outer &= ~INET_ECN_MASK;
-	if (INET_ECN_is_capable(inner))
-		outer |= (inner & INET_ECN_MASK);
+	outer |= (inner & INET_ECN_MASK) ?: INET_ECN_ECT_0;
 	return outer;
 }
 
@@ -50,7 +49,19 @@
 static inline void IP_ECN_set_ce(struct iphdr *iph)
 {
 	u32 check = iph->check;
-	check += __constant_htons(0xFFFE);
+
+	switch (iph->tos & INET_ECN_MASK) {
+	default:
+	case INET_ECN_NOT_ECT:
+	case INET_ECN_CE:
+		return;
+	case INET_ECN_ECT_1:
+		check += __constant_htons(0xFFFD);
+		break;
+	case INET_ECN_ECT_0:
+		check += __constant_htons(0xFFFE);
+		break;
+	}
 	iph->check = check + (check>=0xFFFF);
 	iph->tos |= INET_ECN_CE;
 }
@@ -60,10 +71,14 @@
 	iph->tos &= ~INET_ECN_MASK;
 }
 
+#define ip6_get_dsfield(iph) ((ntohs(*(u16*)(iph)) >> 4) & 0xFF)
+
 struct ipv6hdr;
 
 static inline void IP6_ECN_set_ce(struct ipv6hdr *iph)
 {
+	if (INET_ECN_is_not_ect(ip6_get_dsfield(iph)))
+		return;
 	*(u32*)iph |= htonl(INET_ECN_CE << 20);
 }
 
@@ -71,7 +86,5 @@
 {
 	*(u32*)iph &= ~htonl(INET_ECN_MASK << 20);
 }
-
-#define ip6_get_dsfield(iph) ((ntohs(*(u16*)(iph)) >> 4) & 0xFF)
 
 #endif
===== include/net/tcp_ecn.h 1.5 vs edited =====
--- 1.5/include/net/tcp_ecn.h	2003-06-05 10:57:07 +10:00
+++ edited/include/net/tcp_ecn.h	2004-09-08 11:59:33 +10:00
@@ -90,7 +90,7 @@
 		/* Funny extension: if ECT is not set on a segment,
 		 * it is surely retransmit. It is not in ECN RFC,
 		 * but Linux follows this rule. */
-		else if (!INET_ECN_is_capable((TCP_SKB_CB(skb)->flags)))
+		else if (INET_ECN_is_not_ect((TCP_SKB_CB(skb)->flags)))
 			tcp_enter_quickack_mode(tp);
 	}
 }
===== net/ipv4/ip_gre.c 1.40 vs edited =====
--- 1.40/net/ipv4/ip_gre.c	2004-06-24 11:19:28 +10:00
+++ edited/net/ipv4/ip_gre.c	2004-09-08 11:59:33 +10:00
@@ -533,11 +533,9 @@
 {
 	if (INET_ECN_is_ce(iph->tos)) {
 		if (skb->protocol == htons(ETH_P_IP)) {
-			if (INET_ECN_is_not_ce(skb->nh.iph->tos))
-				IP_ECN_set_ce(skb->nh.iph);
+			IP_ECN_set_ce(skb->nh.iph);
 		} else if (skb->protocol == htons(ETH_P_IPV6)) {
-			if (INET_ECN_is_not_ce(ip6_get_dsfield(skb->nh.ipv6h)))
-				IP6_ECN_set_ce(skb->nh.ipv6h);
+			IP6_ECN_set_ce(skb->nh.ipv6h);
 		}
 	}
 }
===== net/ipv4/ipip.c 1.42 vs edited =====
--- 1.42/net/ipv4/ipip.c	2004-06-22 07:34:06 +10:00
+++ edited/net/ipv4/ipip.c	2004-09-08 11:59:34 +10:00
@@ -461,8 +461,7 @@
 {
 	struct iphdr *inner_iph = skb->nh.iph;
 
-	if (INET_ECN_is_ce(outer_iph->tos) &&
-	    INET_ECN_is_not_ce(inner_iph->tos))
+	if (INET_ECN_is_ce(outer_iph->tos))
 		IP_ECN_set_ce(inner_iph);
 }
 
===== net/ipv4/xfrm4_input.c 1.10 vs edited =====
--- 1.10/net/ipv4/xfrm4_input.c	2004-02-14 18:06:45 +11:00
+++ edited/net/ipv4/xfrm4_input.c	2004-09-08 11:59:34 +10:00
@@ -24,8 +24,7 @@
 	struct iphdr *outer_iph = skb->nh.iph;
 	struct iphdr *inner_iph = skb->h.ipiph;
 
-	if (INET_ECN_is_ce(outer_iph->tos) &&
-	    INET_ECN_is_not_ce(inner_iph->tos))
+	if (INET_ECN_is_ce(outer_iph->tos))
 		IP_ECN_set_ce(inner_iph);
 }
 
===== net/ipv6/sit.c 1.39 vs edited =====
--- 1.39/net/ipv6/sit.c	2004-06-24 11:19:29 +10:00
+++ edited/net/ipv6/sit.c	2004-09-08 11:59:34 +10:00
@@ -360,8 +360,7 @@
 
 static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
 {
-	if (INET_ECN_is_ce(iph->tos) &&
-	    INET_ECN_is_not_ce(ip6_get_dsfield(skb->nh.ipv6h)))
+	if (INET_ECN_is_ce(iph->tos))
 		IP6_ECN_set_ce(skb->nh.ipv6h);
 }
 
===== net/ipv6/xfrm6_input.c 1.17 vs edited =====
--- 1.17/net/ipv6/xfrm6_input.c	2004-08-19 07:51:27 +10:00
+++ edited/net/ipv6/xfrm6_input.c	2004-09-08 11:59:34 +10:00
@@ -21,8 +21,7 @@
 	struct ipv6hdr *outer_iph = skb->nh.ipv6h;
 	struct ipv6hdr *inner_iph = skb->h.ipv6h;
 
-	if (INET_ECN_is_ce(ip6_get_dsfield(outer_iph)) &&
-	    INET_ECN_is_not_ce(ip6_get_dsfield(inner_iph)))
+	if (INET_ECN_is_ce(ip6_get_dsfield(outer_iph)))
 		IP6_ECN_set_ce(inner_iph);
 }
 
===== net/sched/sch_red.c 1.15 vs edited =====
--- 1.15/net/sched/sch_red.c	2004-08-05 06:39:51 +10:00
+++ edited/net/sched/sch_red.c	2004-09-08 11:59:35 +10:00
@@ -162,13 +162,12 @@
 
 	switch (skb->protocol) {
 	case __constant_htons(ETH_P_IP):
-		if (!INET_ECN_is_capable(skb->nh.iph->tos))
+		if (INET_ECN_is_not_ect(skb->nh.iph->tos))
 			return 0;
-		if (INET_ECN_is_not_ce(skb->nh.iph->tos))
-			IP_ECN_set_ce(skb->nh.iph);
+		IP_ECN_set_ce(skb->nh.iph);
 		return 1;
 	case __constant_htons(ETH_P_IPV6):
-		if (!INET_ECN_is_capable(ip6_get_dsfield(skb->nh.ipv6h)))
+		if (INET_ECN_is_not_ect(ip6_get_dsfield(skb->nh.ipv6h)))
 			return 0;
 		IP6_ECN_set_ce(skb->nh.ipv6h);
 		return 1;

--liOOAslEiF7prFVr--
