From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Fix ECN encapsulation for IPv6
Date: Thu, 9 Sep 2004 12:34:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909023454.GA15407@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

While doing the ECN patch I discovered that IPsec on IPv6 wasn't
encapsulating the ECN correctly.  This patch fixes that.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/xfrm6_output.c 1.4 vs edited =====
--- 1.4/net/ipv6/xfrm6_output.c	2004-08-25 04:30:14 +10:00
+++ edited/net/ipv6/xfrm6_output.c	2004-09-09 12:27:57 +10:00
@@ -12,6 +12,7 @@
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/icmpv6.h>
+#include <net/dsfield.h>
 #include <net/inet_ecn.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
@@ -36,6 +37,7 @@
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	struct ipv6hdr *iph, *top_iph;
+	int dsfield;
 
 	skb_push(skb, x->props.header_len);
 	iph = skb->nh.ipv6h;
@@ -58,11 +60,14 @@
 
 	top_iph->version = 6;
 	top_iph->priority = iph->priority;
-	if (x->props.flags & XFRM_STATE_NOECN)
-		IP6_ECN_clear(top_iph);
 	top_iph->flow_lbl[0] = iph->flow_lbl[0];
 	top_iph->flow_lbl[1] = iph->flow_lbl[1];
 	top_iph->flow_lbl[2] = iph->flow_lbl[2];
+	dsfield = ipv6_get_dsfield(top_iph);
+	dsfield = INET_ECN_encapsulate(dsfield, dsfield);
+	if (x->props.flags & XFRM_STATE_NOECN)
+		dsfield &= ~INET_ECN_MASK;
+	ipv6_change_dsfield(top_iph, 0, dsfield);
 	top_iph->nexthdr = IPPROTO_IPV6; 
 	top_iph->hop_limit = dst_path_metric(dst, RTAX_HOPLIMIT);
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);

--vtzGhvizbBRQ85DL--
