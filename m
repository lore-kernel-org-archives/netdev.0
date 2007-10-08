From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/7] [IPSEC]: Move common output code to xfrm_output
Date: Mon, 08 Oct 2007 19:29:39 +0800
Message-ID: <E1Ieqnr-0000o7-00@gondolin.me.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1731 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752848AbXJHL3m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:29:42 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move common output code to xfrm_output

Most of the code in xfrm4_output_one and xfrm6_output_one are identical so
this patch moves them into a common xfrm_output function which will live
in net/xfrm.

In fact this would seem to fix a bug as on IPv4 we never reset the network
header after a transform which may upset netfilter later on.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/xfrm.h      |    1 
 net/ipv4/xfrm4_output.c |   40 ++------------------------
 net/ipv6/xfrm6_output.c |   45 +++--------------------------
 net/xfrm/Makefile       |    2 -
 net/xfrm/xfrm_output.c  |   73 ++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 84 insertions(+), 77 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 760d243..f5147dd 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1016,6 +1016,7 @@ extern void xfrm_replay_notify(struct xfrm_state *x, int event);
 extern int xfrm_state_check(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm_state_mtu(struct xfrm_state *x, int mtu);
 extern int xfrm_init_state(struct xfrm_state *x);
+extern int xfrm_output(struct sk_buff *skb);
 extern int xfrm4_rcv(struct sk_buff *skb);
 extern int xfrm4_output(struct sk_buff *skb);
 extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short family);
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 44ef208..04805c7 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -12,7 +12,6 @@
 #include <linux/if_ether.h>
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
-#include <linux/spinlock.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -41,58 +40,27 @@ out:
 	return ret;
 }
 
-static int xfrm4_output_one(struct sk_buff *skb)
+static inline int xfrm4_output_one(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		err = skb_checksum_help(skb);
-		if (err)
-			goto error_nolock;
-	}
-
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = xfrm4_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
 	}
 
-	do {
-		spin_lock_bh(&x->lock);
-		err = xfrm_state_check(x, skb);
-		if (err)
-			goto error;
-
-		err = x->mode->output(x, skb);
-		if (err)
-			goto error;
-
-		err = x->type->output(x, skb);
-		if (err)
-			goto error;
-
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-
-		spin_unlock_bh(&x->lock);
-
-		if (!(skb->dst = dst_pop(dst))) {
-			err = -EHOSTUNREACH;
-			goto error_nolock;
-		}
-		dst = skb->dst;
-		x = dst->xfrm;
-	} while (x && (x->props.mode != XFRM_MODE_TUNNEL));
+	err = xfrm_output(skb);
+	if (err)
+		goto error_nolock;
 
 	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	err = 0;
 
 out_exit:
 	return err;
-error:
-	spin_unlock_bh(&x->lock);
 error_nolock:
 	kfree_skb(skb);
 	goto out_exit;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 56364a5..f21596f 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -9,9 +9,9 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <linux/if_ether.h>
 #include <linux/compiler.h>
 #include <linux/skbuff.h>
-#include <linux/spinlock.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter_ipv6.h>
 #include <net/ipv6.h>
@@ -43,62 +43,27 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 	return ret;
 }
 
-static int xfrm6_output_one(struct sk_buff *skb)
+static inline int xfrm6_output_one(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
 	struct xfrm_state *x = dst->xfrm;
 	int err;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		err = skb_checksum_help(skb);
-		if (err)
-			goto error_nolock;
-	}
-
 	if (x->props.mode == XFRM_MODE_TUNNEL) {
 		err = xfrm6_tunnel_check_size(skb);
 		if (err)
 			goto error_nolock;
 	}
 
-	do {
-		spin_lock_bh(&x->lock);
-		err = xfrm_state_check(x, skb);
-		if (err)
-			goto error;
-
-		err = x->mode->output(x, skb);
-		if (err)
-			goto error;
-
-		err = x->type->output(x, skb);
-		if (err)
-			goto error;
-
-		x->curlft.bytes += skb->len;
-		x->curlft.packets++;
-		if (x->props.mode == XFRM_MODE_ROUTEOPTIMIZATION)
-			x->lastused = get_seconds();
-
-		spin_unlock_bh(&x->lock);
-
-		skb_reset_network_header(skb);
-
-		if (!(skb->dst = dst_pop(dst))) {
-			err = -EHOSTUNREACH;
-			goto error_nolock;
-		}
-		dst = skb->dst;
-		x = dst->xfrm;
-	} while (x && (x->props.mode != XFRM_MODE_TUNNEL));
+	err = xfrm_output(skb);
+	if (err)
+		goto error_nolock;
 
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 	err = 0;
 
 out_exit:
 	return err;
-error:
-	spin_unlock_bh(&x->lock);
 error_nolock:
 	kfree_skb(skb);
 	goto out_exit;
diff --git a/net/xfrm/Makefile b/net/xfrm/Makefile
index de3c1a6..45744a3 100644
--- a/net/xfrm/Makefile
+++ b/net/xfrm/Makefile
@@ -3,6 +3,6 @@
 #
 
 obj-$(CONFIG_XFRM) := xfrm_policy.o xfrm_state.o xfrm_hash.o \
-		      xfrm_input.o xfrm_algo.o
+		      xfrm_input.o xfrm_output.o xfrm_algo.o
 obj-$(CONFIG_XFRM_USER) += xfrm_user.o
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
new file mode 100644
index 0000000..75f289b
--- /dev/null
+++ b/net/xfrm/xfrm_output.c
@@ -0,0 +1,73 @@
+/*
+ * xfrm_output.c - Common IPsec encapsulation code.
+ *
+ * Copyright (c) 2007 Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/errno.h>
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/time.h>
+#include <net/dst.h>
+#include <net/xfrm.h>
+
+int xfrm_output(struct sk_buff *skb)
+{
+	struct dst_entry *dst = skb->dst;
+	struct xfrm_state *x = dst->xfrm;
+	int err;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		err = skb_checksum_help(skb);
+		if (err)
+			goto error_nolock;
+	}
+
+	do {
+		spin_lock_bh(&x->lock);
+		err = xfrm_state_check(x, skb);
+		if (err)
+			goto error;
+
+		err = x->mode->output(x, skb);
+		if (err)
+			goto error;
+
+		err = x->type->output(x, skb);
+		if (err)
+			goto error;
+
+		x->curlft.bytes += skb->len;
+		x->curlft.packets++;
+
+		if (x->props.mode == XFRM_MODE_ROUTEOPTIMIZATION)
+			x->lastused = get_seconds();
+
+		spin_unlock_bh(&x->lock);
+
+		skb_reset_network_header(skb);
+
+		if (!(skb->dst = dst_pop(dst))) {
+			err = -EHOSTUNREACH;
+			goto error_nolock;
+		}
+		dst = skb->dst;
+		x = dst->xfrm;
+	} while (x && (x->props.mode != XFRM_MODE_TUNNEL));
+
+	err = 0;
+
+error_nolock:
+	return err;
+error:
+	spin_unlock_bh(&x->lock);
+	goto error_nolock;
+}
+EXPORT_SYMBOL_GPL(xfrm_output);
