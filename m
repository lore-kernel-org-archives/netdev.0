From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [INET] Kill ip6_get_dsfield
Date: Thu, 16 Sep 2004 21:58:28 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916115827.GA29046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch kills the duplicate implementation of ip6_get_dsfield in
inet_ecn.h.  It now uses ipv6_get_dsfield from dsfield.h instead.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/inet_ecn.h 1.8 vs edited =====
--- 1.8/include/net/inet_ecn.h	2004-09-14 06:03:39 +10:00
+++ edited/include/net/inet_ecn.h	2004-09-16 21:41:34 +10:00
@@ -78,13 +78,11 @@
 	iph->tos &= ~INET_ECN_MASK;
 }
 
-#define ip6_get_dsfield(iph) ((ntohs(*(u16*)(iph)) >> 4) & 0xFF)
-
 struct ipv6hdr;
 
 static inline void IP6_ECN_set_ce(struct ipv6hdr *iph)
 {
-	if (INET_ECN_is_not_ect(ip6_get_dsfield(iph)))
+	if (INET_ECN_is_not_ect(ipv6_get_dsfield(iph)))
 		return;
 	*(u32*)iph |= htonl(INET_ECN_CE << 20);
 }
===== net/ipv4/ip_gre.c 1.42 vs edited =====
--- 1.42/net/ipv4/ip_gre.c	2004-09-14 09:04:06 +10:00
+++ edited/net/ipv4/ip_gre.c	2004-09-16 21:42:57 +10:00
@@ -36,6 +36,7 @@
 #include <net/ipip.h>
 #include <net/arp.h>
 #include <net/checksum.h>
+#include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 
@@ -547,7 +548,7 @@
 	if (skb->protocol == htons(ETH_P_IP))
 		inner = old_iph->tos;
 	else if (skb->protocol == htons(ETH_P_IPV6))
-		inner = ip6_get_dsfield((struct ipv6hdr*)old_iph);
+		inner = ipv6_get_dsfield((struct ipv6hdr *)old_iph);
 	return INET_ECN_encapsulate(tos, inner);
 }
 
===== net/ipv6/sit.c 1.40 vs edited =====
--- 1.40/net/ipv6/sit.c	2004-09-09 06:37:53 +10:00
+++ edited/net/ipv6/sit.c	2004-09-16 21:43:53 +10:00
@@ -50,6 +50,7 @@
 #include <net/ipip.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
+#include <net/dsfield.h>
 
 /*
    This version of net/ipv6/sit.c is cloned of net/ipv4/ip_gre.c
@@ -566,7 +567,7 @@
 		iph->frag_off	=	0;
 
 	iph->protocol		=	IPPROTO_IPV6;
-	iph->tos		=	INET_ECN_encapsulate(tos, ip6_get_dsfield(iph6));
+	iph->tos		=	INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 	iph->daddr		=	rt->rt_dst;
 	iph->saddr		=	rt->rt_src;
 
===== net/ipv6/tcp_ipv6.c 1.94 vs edited =====
--- 1.94/net/ipv6/tcp_ipv6.c	2004-09-08 03:00:52 +10:00
+++ edited/net/ipv6/tcp_ipv6.c	2004-09-16 21:44:44 +10:00
@@ -57,6 +57,7 @@
 #include <net/xfrm.h>
 #include <net/addrconf.h>
 #include <net/snmp.h>
+#include <net/dsfield.h>
 
 #include <asm/uaccess.h>
 
@@ -1646,7 +1647,7 @@
 				    skb->len - th->doff*4);
 	TCP_SKB_CB(skb)->ack_seq = ntohl(th->ack_seq);
 	TCP_SKB_CB(skb)->when = 0;
-	TCP_SKB_CB(skb)->flags = ip6_get_dsfield(skb->nh.ipv6h);
+	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(skb->nh.ipv6h);
 	TCP_SKB_CB(skb)->sacked = 0;
 
 	sk = __tcp_v6_lookup(&skb->nh.ipv6h->saddr, th->source,
===== net/ipv6/xfrm6_input.c 1.18 vs edited =====
--- 1.18/net/ipv6/xfrm6_input.c	2004-09-09 06:37:53 +10:00
+++ edited/net/ipv6/xfrm6_input.c	2004-09-16 21:44:59 +10:00
@@ -11,6 +11,7 @@
 
 #include <linux/module.h>
 #include <linux/string.h>
+#include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
@@ -21,7 +22,7 @@
 	struct ipv6hdr *outer_iph = skb->nh.ipv6h;
 	struct ipv6hdr *inner_iph = skb->h.ipv6h;
 
-	if (INET_ECN_is_ce(ip6_get_dsfield(outer_iph)))
+	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
 		IP6_ECN_set_ce(inner_iph);
 }
 
===== net/sched/sch_red.c 1.16 vs edited =====
--- 1.16/net/sched/sch_red.c	2004-09-09 06:37:53 +10:00
+++ edited/net/sched/sch_red.c	2004-09-16 21:45:24 +10:00
@@ -40,6 +40,7 @@
 #include <net/sock.h>
 #include <net/pkt_sched.h>
 #include <net/inet_ecn.h>
+#include <net/dsfield.h>
 
 
 /*	Random Early Detection (RED) algorithm.
@@ -167,7 +168,7 @@
 		IP_ECN_set_ce(skb->nh.iph);
 		return 1;
 	case __constant_htons(ETH_P_IPV6):
-		if (INET_ECN_is_not_ect(ip6_get_dsfield(skb->nh.ipv6h)))
+		if (INET_ECN_is_not_ect(ipv6_get_dsfield(skb->nh.ipv6h)))
 			return 0;
 		IP6_ECN_set_ce(skb->nh.ipv6h);
 		return 1;

--J2SCkAp4GZ/dPZZf--
