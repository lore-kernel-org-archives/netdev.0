From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPv6] Add option to copy DSCP in decap in ip6_tunnel
Date: Mon, 13 Sep 2004 21:19:43 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040913111943.GA26179@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bp/iNruPH9dso1Pn"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is a patch that allows the copying of the DSCP during decapsulation
for ip6_tunnel.  I've made it a separate option from the one that
determines the copying during encapsulation since the DSCP processing
may be asymmetric.  It also means that we preserve compatibility should
anyone be relying on the current behaviour.

inet_ecn.h might appear to be an odd place for ipv6_copy_dscp, but
I couldn't put it in dsfield.h since I want to use ipv6_get_dsfield
in inet_ecn.h later on.  The other alternative would be to define
INET_ECN_MASK in dsfield.h.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bp/iNruPH9dso1Pn
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/ip6_tunnel.h 1.1 vs edited =====
--- 1.1/include/linux/ip6_tunnel.h	2003-06-10 00:56:43 +10:00
+++ edited/include/linux/ip6_tunnel.h	2004-09-13 16:30:44 +10:00
@@ -16,6 +16,8 @@
 #define IP6_TNL_F_USE_ORIG_FLOWLABEL 0x4
 /* being used for Mobile IPv6 */
 #define IP6_TNL_F_MIP6_DEV 0x8
+/* copy DSCP from the outer packet */
+#define IP6_TNL_F_RCV_DSCP_COPY 0x10
 
 struct ip6_tnl_parm {
 	char name[IFNAMSIZ];	/* name of tunnel device */
===== include/net/inet_ecn.h 1.7 vs edited =====
--- 1.7/include/net/inet_ecn.h	2004-09-09 14:16:21 +10:00
+++ edited/include/net/inet_ecn.h	2004-09-13 15:55:17 +10:00
@@ -2,6 +2,7 @@
 #define _INET_ECN_H_
 
 #include <linux/ip.h>
+#include <net/dsfield.h>
 
 enum {
 	INET_ECN_NOT_ECT = 0,
@@ -91,6 +92,12 @@
 static inline void IP6_ECN_clear(struct ipv6hdr *iph)
 {
 	*(u32*)iph &= ~htonl(INET_ECN_MASK << 20);
+}
+
+static inline void ipv6_copy_dscp(struct ipv6hdr *outer, struct ipv6hdr *inner)
+{
+	u32 dscp = ipv6_get_dsfield(outer) & ~INET_ECN_MASK;
+	ipv6_change_dsfield(inner, INET_ECN_MASK, dscp);
 }
 
 #endif
===== net/ipv6/ip6_tunnel.c 1.24 vs edited =====
--- 1.24/net/ipv6/ip6_tunnel.c	2004-09-09 14:21:46 +10:00
+++ edited/net/ipv6/ip6_tunnel.c	2004-09-13 16:30:11 +10:00
@@ -542,6 +542,8 @@
 		skb->dev = t->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
+		if (t->parms.flags & IP6_TNL_F_RCV_DSCP_COPY)
+			ipv6_copy_dscp(ipv6h, skb->nh.ipv6h);
 		ip6ip6_ecn_decapsulate(ipv6h, skb);
 		t->stat.rx_packets++;
 		t->stat.rx_bytes += skb->len;

--bp/iNruPH9dso1Pn--
