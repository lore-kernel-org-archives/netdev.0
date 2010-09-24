From: arno@natisbad.org (Arnaud Ebalard)
Subject: [PATCH net-next-2.6 3/5] XFRM,IPv6: Add IRO src/dst address remapping XFRM types and i/o handlers
Date: Fri, 24 Sep 2010 21:24:23 +0200
Message-ID: <87vd5vq714.fsf@small.ssi.corp>
References: <87bp7nrlvy.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:55474 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757724Ab0IXTXx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Sep 2010 15:23:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add IRO source and destination remapping XFRM types and associated
input/output handlers. This allows userland to install such states
in order to support remapping of source or destination address
of packet. They basically work like existing RH2 and HAO ones; the
main difference is that output handlers do not expand the packet by
adding an extension header: they simply change the source or
destination in place. Input handlers are almost the same as RH2/HAO
version in their behavior, but they are triggered differently. RH2
and HAO handlers are triggered based on structures found in the
packet. On input, IRO states (and associated handlers) are looked
up when processing an IPsec-protected packet, when there is an
address mismatch.

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 include/net/xfrm.h       |    2 +
 net/ipv6/mip6.c          |  140 ++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_mode_ro.c |   11 +++-
 net/xfrm/xfrm_user.c     |    2 +
 4 files changed, 154 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f35bade..7ac6abe 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -35,6 +35,8 @@
 #define XFRM_PROTO_IPV6		41
 #define XFRM_PROTO_ROUTING	IPPROTO_ROUTING
 #define XFRM_PROTO_DSTOPTS	IPPROTO_DSTOPTS
+#define XFRM_PROTO_IRO_SRC      127
+#define XFRM_PROTO_IRO_DST      128
 
 #define XFRM_ALIGN8(len)	(((len) + 7) & ~7)
 #define MODULE_ALIAS_XFRM_MODE(family, encap) \
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index d6e9599..b52c651 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -477,6 +477,130 @@ static const struct xfrm_type mip6_rthdr_type =
 	.hdr_offset	= mip6_rthdr_offset,
 };
 
+/* IRO equivalent of mip6_destopt_input(): handles incoming packet with a
+ * source address different from the one expected in the SA: check that
+ * received source address is indeed the CoA we expected (or any address
+ * if the state references the unspecified address '::') */
+static int mip6_iro_src_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	int err = 1;
+
+	spin_lock(&x->lock);
+	if (!ipv6_addr_equal(&iph->saddr, (struct in6_addr *)x->coaddr) &&
+	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
+		err = -ENOENT;
+	spin_unlock(&x->lock);
+
+	return err;
+}
+
+/* IRO equivalent of mip6_destopt_output(): replaces current source address
+ * of outgoing packet by state's CoA. */
+static int mip6_iro_src_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
+	spin_lock_bh(&x->lock);
+	memcpy(&iph->saddr, x->coaddr, sizeof(iph->saddr));
+	spin_unlock_bh(&x->lock);
+
+	return 0;
+}
+
+static int mip6_iro_src_reject(struct xfrm_state *x, struct sk_buff *skb, struct flowi *fl)
+{
+	int err = 0;
+
+	/* XXX We may need some reject handler at some point but it is not
+	 * critical yet: see xfrm_secpath_reject() in net/xfrm/xfrm_policy.c
+	 * and aslo what mip6_destopt_reject() implements */
+
+	printk("XXX FIXME: mip6_iro_src_reject() called\n");
+
+	return err;
+}
+
+/* This is the IRO equivalent of mip6_rthdr_input(): handles incoming packet
+ * with a destination address different from the one expected in the SA:
+ * check that received destination address is indeed the CoA we expected
+ * (or any address if the state references the unspecified address '::') */
+static int mip6_iro_dst_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	int err = 1;
+
+	spin_lock(&x->lock);
+	if (!ipv6_addr_equal(&iph->daddr, (struct in6_addr *)x->coaddr) &&
+	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
+		err = -ENOENT;
+	spin_unlock(&x->lock);
+
+	return err;
+}
+
+/* IRO equivalent of mip6_rthdr_output(): replaces current destination
+ * address of outgoing packet with state's CoA */
+static int mip6_iro_dst_output(struct xfrm_state *x, struct sk_buff *skb)
+{
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+
+	spin_lock_bh(&x->lock);
+	memcpy(&iph->daddr, x->coaddr, sizeof(iph->daddr));
+	spin_unlock_bh(&x->lock);
+
+	return 0;
+}
+
+/* Common to iro src and dst remapping states. */
+static int mip6_iro_init_state(struct xfrm_state *x)
+{
+	if (x->id.spi) {
+		printk(KERN_INFO "%s: spi is not 0: %u\n", __func__,
+		       x->id.spi);
+		return -EINVAL;
+	}
+	if (x->props.mode != XFRM_MODE_ROUTEOPTIMIZATION) {
+		printk(KERN_INFO "%s: state's mode is not %u: %u\n",
+		       __func__, XFRM_MODE_ROUTEOPTIMIZATION,
+		       x->props.mode);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+/* Unlike common IPsec protocols, nothing to do when destroying */
+static void mip6_iro_destroy(struct xfrm_state *x)
+{
+}
+
+static const struct xfrm_type mip6_iro_src_type =
+{
+	.description	= "MIP6_IRO_SRC",
+	.owner		= THIS_MODULE,
+	.proto	     	= XFRM_PROTO_IRO_SRC,
+	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_LOCAL_COADDR,
+	.init_state	= mip6_iro_init_state,
+	.destructor	= mip6_iro_destroy,
+	.input		= mip6_iro_src_input,
+	.output		= mip6_iro_src_output,
+	.reject         = mip6_iro_src_reject,
+};
+
+
+static const struct xfrm_type mip6_iro_dst_type =
+{
+	.description	= "MIP6_IRO_DST",
+	.owner		= THIS_MODULE,
+	.proto	     	= XFRM_PROTO_IRO_DST,
+	.flags		= XFRM_TYPE_NON_FRAGMENT | XFRM_TYPE_REMOTE_COADDR,
+	.init_state	= mip6_iro_init_state,
+	.destructor	= mip6_iro_destroy,
+	.input		= mip6_iro_dst_input,
+	.output		= mip6_iro_dst_output,
+};
+
 static int __init mip6_init(void)
 {
 	printk(KERN_INFO "Mobile IPv6\n");
@@ -489,6 +613,14 @@ static int __init mip6_init(void)
 		printk(KERN_INFO "%s: can't add xfrm type(rthdr)\n", __func__);
 		goto mip6_rthdr_xfrm_fail;
 	}
+	if (xfrm_register_type(&mip6_iro_src_type, AF_INET6) < 0) {
+		printk(KERN_INFO "%s: can't add xfrm type(IRO src remap)\n", __func__);
+		goto mip6_iro_src_remap_xfrm_fail;
+	}
+	if (xfrm_register_type(&mip6_iro_dst_type, AF_INET6) < 0) {
+		printk(KERN_INFO "%s: can't add xfrm type(IRO dst remap)\n", __func__);
+		goto mip6_iro_dst_remap_xfrm_fail;
+	}
 	if (rawv6_mh_filter_register(mip6_mh_filter) < 0) {
 		printk(KERN_INFO "%s: can't add rawv6 mh filter\n", __func__);
 		goto mip6_rawv6_mh_fail;
@@ -498,6 +630,10 @@ static int __init mip6_init(void)
 	return 0;
 
  mip6_rawv6_mh_fail:
+	xfrm_unregister_type(&mip6_iro_dst_type, AF_INET6);
+ mip6_iro_dst_remap_xfrm_fail:
+	xfrm_unregister_type(&mip6_iro_src_type, AF_INET6);
+ mip6_iro_src_remap_xfrm_fail:
 	xfrm_unregister_type(&mip6_rthdr_type, AF_INET6);
  mip6_rthdr_xfrm_fail:
 	xfrm_unregister_type(&mip6_destopt_type, AF_INET6);
@@ -509,6 +645,10 @@ static void __exit mip6_fini(void)
 {
 	if (rawv6_mh_filter_unregister(mip6_mh_filter) < 0)
 		printk(KERN_INFO "%s: can't remove rawv6 mh filter\n", __func__);
+	if (xfrm_unregister_type(&mip6_iro_dst_type, AF_INET6) < 0)
+		printk(KERN_INFO "%s: can't remove xfrm type(IRO dst remap)\n", __func__);
+	if (xfrm_unregister_type(&mip6_iro_src_type, AF_INET6) < 0)
+		printk(KERN_INFO "%s: can't remove xfrm type(IRO src remap)\n", __func__);
 	if (xfrm_unregister_type(&mip6_rthdr_type, AF_INET6) < 0)
 		printk(KERN_INFO "%s: can't remove xfrm type(rthdr)\n", __func__);
 	if (xfrm_unregister_type(&mip6_destopt_type, AF_INET6) < 0)
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 63d5d49..ea33178 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -45,6 +45,15 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	u8 *prevhdr;
 	int hdr_len;
 
+	/* Unlike RH2 (IPPROTO_ROUTING) and HAO in DstOpt
+	 * (IPPROTO_DSTOPTS), IRO remapping states do not
+	 * add extension header to the packet. Source
+	 * and/or destination addresses are simply modified
+	 * in place. */
+	if (x->id.proto == XFRM_PROTO_IRO_SRC ||
+	    x->id.proto == XFRM_PROTO_IRO_DST)
+		goto out;
+
 	iph = ipv6_hdr(skb);
 
 	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
@@ -54,8 +63,8 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 	__skb_pull(skb, hdr_len);
 	memmove(ipv6_hdr(skb), iph, hdr_len);
 
+ out:
 	x->lastused = get_seconds();
-
 	return 0;
 }
 
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 8bae6b2..cc81783 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -179,6 +179,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 	case IPPROTO_DSTOPTS:
 	case IPPROTO_ROUTING:
+	case XFRM_PROTO_IRO_SRC:
+	case XFRM_PROTO_IRO_DST:
 		if (attrs[XFRMA_ALG_COMP]	||
 		    attrs[XFRMA_ALG_AUTH]	||
 		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
-- 
1.7.1


