From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Stop using dst->xfrm
Date: Fri, 21 Jan 2005 21:23:19 +1100
Message-ID: <20050121102319.GA3160@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Here is a precursor to the xfrm dst consolidation that I talked about.
In order to be able to store multiple SAs in one dst, we need to stop
using dst->xfrm directly.

The following patch does that for the ->output() functions.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="xfrm.patch"

===== include/net/xfrm.h 1.73 vs edited =====
--- 1.73/include/net/xfrm.h	2004-12-28 14:49:57 +11:00
+++ edited/include/net/xfrm.h	2005-01-21 11:10:16 +11:00
@@ -212,7 +212,7 @@
 	void			(*destructor)(struct xfrm_state *);
 	int			(*input)(struct xfrm_state *, struct xfrm_decap_state *, struct sk_buff *skb);
 	int			(*post_input)(struct xfrm_state *, struct xfrm_decap_state *, struct sk_buff *skb);
-	int			(*output)(struct sk_buff *pskb);
+	int			(*output)(struct xfrm_state *, struct sk_buff *pskb);
 	/* Estimate maximal size of result of transformation of a dgram */
 	u32			(*get_max_size)(struct xfrm_state *, int size);
 };
===== net/ipv4/ah4.c 1.40 vs edited =====
--- 1.40/net/ipv4/ah4.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv4/ah4.c	2005-01-21 11:10:27 +11:00
@@ -53,11 +53,9 @@
 	return 0;
 }
 
-static int ah_output(struct sk_buff *skb)
+static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x  = dst->xfrm;
 	struct iphdr *iph, *top_iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
===== net/ipv4/esp4.c 1.54 vs edited =====
--- 1.54/net/ipv4/esp4.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv4/esp4.c	2005-01-21 11:11:30 +11:00
@@ -17,11 +17,9 @@
 	__u8		proto;
 };
 
-static int esp_output(struct sk_buff *skb)
+static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x  = dst->xfrm;
 	struct iphdr *top_iph;
 	struct ip_esp_hdr *esph;
 	struct crypto_tfm *tfm;
===== net/ipv4/ipcomp.c 1.30 vs edited =====
--- 1.30/net/ipv4/ipcomp.c	2004-09-11 07:36:51 +10:00
+++ edited/net/ipv4/ipcomp.c	2005-01-21 11:11:37 +11:00
@@ -154,11 +154,9 @@
 	return err;
 }
 
-static int ipcomp_output(struct sk_buff *skb)
+static int ipcomp_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct iphdr *iph;
 	struct ip_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
===== net/ipv4/xfrm4_output.c 1.5 vs edited =====
--- 1.5/net/ipv4/xfrm4_output.c	2004-10-26 09:10:25 +10:00
+++ edited/net/ipv4/xfrm4_output.c	2005-01-21 11:12:23 +11:00
@@ -116,7 +116,7 @@
 
 	xfrm4_encap(skb);
 
-	err = x->type->output(skb);
+	err = x->type->output(x, skb);
 	if (err)
 		goto error;
 
===== net/ipv4/xfrm4_tunnel.c 1.18 vs edited =====
--- 1.18/net/ipv4/xfrm4_tunnel.c	2004-08-21 06:54:06 +10:00
+++ edited/net/ipv4/xfrm4_tunnel.c	2005-01-21 11:12:43 +11:00
@@ -9,7 +9,7 @@
 #include <net/ip.h>
 #include <net/protocol.h>
 
-static int ipip_output(struct sk_buff *skb)
+static int ipip_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct iphdr *iph;
 	
===== net/ipv6/ah6.c 1.41 vs edited =====
--- 1.41/net/ipv6/ah6.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv6/ah6.c	2005-01-21 11:14:03 +11:00
@@ -154,12 +154,10 @@
 	return 0;
 }
 
-static int ah6_output(struct sk_buff *skb)
+static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
 	int extlen;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x  = dst->xfrm;
 	struct ipv6hdr *top_iph;
 	struct ip_auth_hdr *ah;
 	struct ah_data *ahp;
===== net/ipv6/esp6.c 1.37 vs edited =====
--- 1.37/net/ipv6/esp6.c	2004-08-22 15:00:07 +10:00
+++ edited/net/ipv6/esp6.c	2005-01-21 11:14:13 +11:00
@@ -37,12 +37,10 @@
 #include <net/ipv6.h>
 #include <linux/icmpv6.h>
 
-static int esp6_output(struct sk_buff *skb)
+static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
 	int hdr_len;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x  = dst->xfrm;
 	struct ipv6hdr *top_iph;
 	struct ipv6_esp_hdr *esph;
 	struct crypto_tfm *tfm;
===== net/ipv6/ipcomp6.c 1.19 vs edited =====
--- 1.19/net/ipv6/ipcomp6.c	2004-09-11 07:36:51 +10:00
+++ edited/net/ipv6/ipcomp6.c	2005-01-21 11:14:29 +11:00
@@ -139,11 +139,9 @@
 	return err;
 }
 
-static int ipcomp6_output(struct sk_buff *skb)
+static int ipcomp6_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err;
-	struct dst_entry *dst = skb->dst;
-	struct xfrm_state *x = dst->xfrm;
 	struct ipv6hdr *top_iph;
 	int hdr_len;
 	struct ipv6_comp_hdr *ipch;
===== net/ipv6/xfrm6_output.c 1.7 vs edited =====
--- 1.7/net/ipv6/xfrm6_output.c	2004-11-16 13:52:34 +11:00
+++ edited/net/ipv6/xfrm6_output.c	2005-01-21 11:14:37 +11:00
@@ -116,7 +116,7 @@
 
 	xfrm6_encap(skb);
 
-	err = x->type->output(skb);
+	err = x->type->output(x, skb);
 	if (err)
 		goto error;
 
===== net/ipv6/xfrm6_tunnel.c 1.9 vs edited =====
--- 1.9/net/ipv6/xfrm6_tunnel.c	2005-01-14 15:41:06 +11:00
+++ edited/net/ipv6/xfrm6_tunnel.c	2005-01-21 11:14:47 +11:00
@@ -343,7 +343,7 @@
 
 EXPORT_SYMBOL(xfrm6_tunnel_free_spi);
 
-static int xfrm6_tunnel_output(struct sk_buff *skb)
+static int xfrm6_tunnel_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
 

--82I3+IH0IqGh5yIs--
