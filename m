From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Implement DSCP decapsulation
Date: Thu, 16 Sep 2004 22:39:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916123939.GA3403@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="BXVAT5kNtrzKuDFl"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        James Morris <jmorris@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch adds DSCP decapsulation for IPsec.  This is enabled by
a per-state flag which is off by default.  Leaving it off by default
maintains compatibility and is also good for performance reasons.

I decided to not implement a toggle on the output path since not
encapsulating the DSCP can and should be done by netfilter.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--BXVAT5kNtrzKuDFl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/linux/pfkeyv2.h 1.10 vs edited =====
--- 1.10/include/linux/pfkeyv2.h	2004-04-20 04:42:38 +10:00
+++ edited/include/linux/pfkeyv2.h	2004-09-16 21:58:42 +10:00
@@ -245,6 +245,7 @@
 
 /* Security Association flags */
 #define SADB_SAFLAGS_PFS	1
+#define SADB_SAFLAGS_DECAP_DSCP	0x40000000
 #define SADB_SAFLAGS_NOECN	0x80000000
 
 /* Security Association states */
===== include/linux/xfrm.h 1.25 vs edited =====
--- 1.25/include/linux/xfrm.h	2004-07-12 20:00:21 +10:00
+++ edited/include/linux/xfrm.h	2004-09-16 21:58:42 +10:00
@@ -190,6 +190,7 @@
 	__u8				replay_window;
 	__u8				flags;
 #define XFRM_STATE_NOECN	1
+#define XFRM_STATE_DECAP_DSCP	2
 };
 
 struct xfrm_usersa_id {
===== include/net/inet_ecn.h 1.11 vs edited =====
--- 1.11/include/net/inet_ecn.h	2004-09-16 21:58:08 +10:00
+++ edited/include/net/inet_ecn.h	2004-09-16 22:32:25 +10:00
@@ -78,6 +78,12 @@
 	iph->tos &= ~INET_ECN_MASK;
 }
 
+static inline void ipv4_copy_dscp(struct iphdr *outer, struct iphdr *inner)
+{
+	u32 dscp = ipv4_get_dsfield(outer) & ~INET_ECN_MASK;
+	ipv4_change_dsfield(inner, INET_ECN_MASK, dscp);
+}
+
 struct ipv6hdr;
 
 static inline void IP6_ECN_set_ce(struct ipv6hdr *iph)
===== net/ipv4/xfrm4_input.c 1.12 vs edited =====
--- 1.12/net/ipv4/xfrm4_input.c	2004-09-09 21:48:58 +10:00
+++ edited/net/ipv4/xfrm4_input.c	2004-09-16 22:03:27 +10:00
@@ -101,6 +101,8 @@
 			if (skb_cloned(skb) &&
 			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 				goto drop;
+			if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+				ipv4_copy_dscp(iph, skb->h.ipiph);
 			if (!(x->props.flags & XFRM_STATE_NOECN))
 				ipip_ecn_decapsulate(skb);
 			skb->mac.raw = memmove(skb->data - skb->mac_len,
===== net/ipv6/xfrm6_input.c 1.22 vs edited =====
--- 1.22/net/ipv6/xfrm6_input.c	2004-09-16 21:58:08 +10:00
+++ edited/net/ipv6/xfrm6_input.c	2004-09-16 22:03:04 +10:00
@@ -88,6 +88,8 @@
 			if (skb_cloned(skb) &&
 			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 				goto drop;
+			if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+				ipv6_copy_dscp(skb->nh.ipv6h, skb->h.ipv6h);
 			if (!(x->props.flags & XFRM_STATE_NOECN))
 				ipip6_ecn_decapsulate(skb);
 			skb->mac.raw = memmove(skb->data - skb->mac_len,
===== net/key/af_key.c 1.69 vs edited =====
--- 1.69/net/key/af_key.c	2004-09-12 21:51:42 +10:00
+++ edited/net/key/af_key.c	2004-09-16 21:58:43 +10:00
@@ -683,6 +683,8 @@
 	sa->sadb_sa_flags = 0;
 	if (x->props.flags & XFRM_STATE_NOECN)
 		sa->sadb_sa_flags |= SADB_SAFLAGS_NOECN;
+	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
+		sa->sadb_sa_flags |= SADB_SAFLAGS_DECAP_DSCP;
 
 	/* hard time */
 	if (hsc & 2) {
@@ -965,6 +967,8 @@
 	x->props.replay_window = sa->sadb_sa_replay;
 	if (sa->sadb_sa_flags & SADB_SAFLAGS_NOECN)
 		x->props.flags |= XFRM_STATE_NOECN;
+	if (sa->sadb_sa_flags & SADB_SAFLAGS_DECAP_DSCP)
+		x->props.flags |= XFRM_STATE_DECAP_DSCP;
 
 	lifetime = (struct sadb_lifetime*) ext_hdrs[SADB_EXT_LIFETIME_HARD-1];
 	if (lifetime != NULL) {

--BXVAT5kNtrzKuDFl--
