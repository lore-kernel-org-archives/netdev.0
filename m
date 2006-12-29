From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Subject: [RFC][PATCH][IPSEC][1/3]exporting xfrm_state_afinfo
Date: Fri, 29 Dec 2006 14:47:08 +0900
Message-ID: <20061229144708.25797388.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi004.linux-ipv6.org ([203.178.140.4]:46517 "EHLO
	miyazawa.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S964949AbWL2F4B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Dec 2006 00:56:01 -0500
To: Miika Komu <miika@iki.fi>, Diego Beltrami <Diego.Beltrami@hiit.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch exports xfrm_state_afinfo.

Signed-off-by: Miika Komu <miika@iki.fi>
Signed-off-by: Diego Beltrami <Diego.Beltrami@hiit.fi>
Signed-off-by: Kazunori Miyazawa <miyazawa@linux-ipv6.org>

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index e476541..bf91d63 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -252,10 +252,13 @@ struct xfrm_state_afinfo {
 						xfrm_address_t *daddr, xfrm_address_t *saddr);
 	int			(*tmpl_sort)(struct xfrm_tmpl **dst, struct xfrm_tmpl **src, int n);
 	int			(*state_sort)(struct xfrm_state **dst, struct xfrm_state **src, int n);
+	int			(*output)(struct sk_buff *skb);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
 extern int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
+extern struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
+extern void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
 extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 3cc3df0..93e2c06 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -51,6 +51,7 @@ static struct xfrm_state_afinfo xfrm4_st
 	.family			= AF_INET,
 	.init_flags		= xfrm4_init_flags,
 	.init_tempsel		= __xfrm4_init_tempsel,
+	.output			= xfrm4_output,
 };
 
 void __init xfrm4_state_init(void)
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index c260ea1..bad0ad9 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -166,3 +166,5 @@ int xfrm6_output(struct sk_buff *skb)
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,
 		       xfrm6_output_finish);
 }
+
+EXPORT_SYMBOL(xfrm6_output);
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index 9ddaa9d..60ad5f0 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -171,6 +171,7 @@ static struct xfrm_state_afinfo xfrm6_st
 	.init_tempsel		= __xfrm6_init_tempsel,
 	.tmpl_sort		= __xfrm6_tmpl_sort,
 	.state_sort		= __xfrm6_state_sort,
+	.output			= xfrm6_output,
 };
 
 void __init xfrm6_state_init(void)
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index fdb08d9..24f7bfd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -183,9 +183,6 @@ static DEFINE_SPINLOCK(xfrm_state_gc_loc
 
 int __xfrm_state_delete(struct xfrm_state *x);
 
-static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family);
-static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
-
 int km_query(struct xfrm_state *x, struct xfrm_tmpl *t, struct xfrm_policy *pol);
 void km_state_expired(struct xfrm_state *x, int hard, u32 pid);
 
@@ -1458,7 +1455,7 @@ int xfrm_state_unregister_afinfo(struct 
 }
 EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
 
-static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family)
+struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned short family)
 {
 	struct xfrm_state_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
@@ -1470,11 +1467,14 @@ static struct xfrm_state_afinfo *xfrm_st
 	return afinfo;
 }
 
-static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
+void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
 {
 	read_unlock(&xfrm_state_afinfo_lock);
 }
 
+EXPORT_SYMBOL(xfrm_state_get_afinfo);
+EXPORT_SYMBOL(xfrm_state_put_afinfo);
+
 /* Temporarily located here until net/xfrm/xfrm_tunnel.c is created */
 void xfrm_state_delete_tunnel(struct xfrm_state *x)
 {
