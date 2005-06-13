From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [net-2.6.13 3/3] [IPSEC] Add XFRM_STATE_NOPMTUDISC flag
Date: Mon, 13 Jun 2005 17:39:55 +1000
Message-ID: <20050613073955.GC21545@gondor.apana.org.au>
References: <20050613073353.GA21454@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="pAwQNkOnpTn9IO2O"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@redhat.com>,
        Patrick McHardy <kaber@trash.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050613073353.GA21454@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--pAwQNkOnpTn9IO2O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch adds the flag XFRM_STATE_NOPMTUDISC for xfrm states.  It is
similar to the nopmtudisc on IPIP/GRE tunnels.  It only has an effect
on IPv4 tunnel mode states.  For these states, it will ensure that the
DF flag is always cleared.

This is primarily useful to work around ICMP blackholes.

In future this flag could also allow a larger MTU to be set within the
tunnel just like IPIP/GRE tunnels.  This could be useful for short haul
tunnels where temporary fragmentation outside the tunnel is desired over
smaller fragments inside the tunnel.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--pAwQNkOnpTn9IO2O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p3.patch"

diff --git a/include/linux/pfkeyv2.h b/include/linux/pfkeyv2.h
--- a/include/linux/pfkeyv2.h
+++ b/include/linux/pfkeyv2.h
@@ -245,6 +245,7 @@ struct sadb_x_nat_t_port {
 
 /* Security Association flags */
 #define SADB_SAFLAGS_PFS	1
+#define SADB_SAFLAGS_NOPMTUDISC	0x20000000
 #define SADB_SAFLAGS_DECAP_DSCP	0x40000000
 #define SADB_SAFLAGS_NOECN	0x80000000
 
diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -196,6 +196,7 @@ struct xfrm_usersa_info {
 	__u8				flags;
 #define XFRM_STATE_NOECN	1
 #define XFRM_STATE_DECAP_DSCP	2
+#define XFRM_STATE_NOPMTUDISC	4
 };
 
 struct xfrm_usersa_id {
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -33,6 +33,7 @@ static void xfrm4_encap(struct sk_buff *
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	struct iphdr *iph, *top_iph;
+	int flags;
 
 	iph = skb->nh.iph;
 	skb->h.ipiph = iph;
@@ -51,10 +52,13 @@ static void xfrm4_encap(struct sk_buff *
 
 	/* DS disclosed */
 	top_iph->tos = INET_ECN_encapsulate(iph->tos, iph->tos);
-	if (x->props.flags & XFRM_STATE_NOECN)
+
+	flags = x->props.flags;
+	if (flags & XFRM_STATE_NOECN)
 		IP_ECN_clear(top_iph);
 
-	top_iph->frag_off = iph->frag_off & htons(IP_DF);
+	top_iph->frag_off = (flags & XFRM_STATE_NOPMTUDISC) ?
+		0 : (iph->frag_off & htons(IP_DF));
 	if (!top_iph->frag_off)
 		__ip_select_ident(top_iph, dst, 0);
 
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -7,12 +7,20 @@
  *
  */
 
+#include <net/ip.h>
 #include <net/xfrm.h>
 #include <linux/pfkeyv2.h>
 #include <linux/ipsec.h>
 
 static struct xfrm_state_afinfo xfrm4_state_afinfo;
 
+static int xfrm4_init_flags(struct xfrm_state *x)
+{
+	if (ipv4_config.no_pmtu_disc)
+		x->props.flags |= XFRM_STATE_NOPMTUDISC;
+	return 0;
+}
+
 static void
 __xfrm4_init_tempsel(struct xfrm_state *x, struct flowi *fl,
 		     struct xfrm_tmpl *tmpl,
@@ -109,6 +117,7 @@ __xfrm4_find_acq(u8 mode, u32 reqid, u8 
 static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.family			= AF_INET,
 	.lock			= RW_LOCK_UNLOCKED,
+	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
 	.state_lookup		= __xfrm4_state_lookup,
 	.find_acq		= __xfrm4_find_acq,
diff --git a/net/key/af_key.c b/net/key/af_key.c
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -690,6 +690,8 @@ static struct sk_buff * pfkey_xfrm_state
 		sa->sadb_sa_flags |= SADB_SAFLAGS_NOECN;
 	if (x->props.flags & XFRM_STATE_DECAP_DSCP)
 		sa->sadb_sa_flags |= SADB_SAFLAGS_DECAP_DSCP;
+	if (x->props.flags & XFRM_STATE_NOPMTUDISC)
+		sa->sadb_sa_flags |= SADB_SAFLAGS_NOPMTUDISC;
 
 	/* hard time */
 	if (hsc & 2) {
@@ -974,6 +976,8 @@ static struct xfrm_state * pfkey_msg2xfr
 		x->props.flags |= XFRM_STATE_NOECN;
 	if (sa->sadb_sa_flags & SADB_SAFLAGS_DECAP_DSCP)
 		x->props.flags |= XFRM_STATE_DECAP_DSCP;
+	if (sa->sadb_sa_flags & SADB_SAFLAGS_NOPMTUDISC)
+		x->props.flags |= XFRM_STATE_NOPMTUDISC;
 
 	lifetime = (struct sadb_lifetime*) ext_hdrs[SADB_EXT_LIFETIME_HARD-1];
 	if (lifetime != NULL) {

--pAwQNkOnpTn9IO2O--
