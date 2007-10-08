From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/7] [IPSEC]: Move RO-specific output code into xfrm6_mode_ro.c
Date: Mon, 08 Oct 2007 19:29:44 +0800
Message-ID: <E1Ieqnw-0000oO-00@gondolin.me.apana.org.au>
References: <20071008112818.GA3010@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1743 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753359AbXJHL3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 07:29:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move RO-specific output code into xfrm6_mode_ro.c

The lastused update check in xfrm_output can be done just as well in
the mode output function which is specific to RO.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/xfrm6_mode_ro.c |    4 ++++
 net/xfrm/xfrm_output.c   |    4 ----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
index 6ad6d7a..a156373 100644
--- a/net/ipv6/xfrm6_mode_ro.c
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -29,6 +29,7 @@
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/stringify.h>
+#include <linux/time.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
@@ -57,6 +58,9 @@ static int xfrm6_ro_output(struct xfrm_state *x, struct sk_buff *skb)
 			       (prevhdr - x->props.header_len) - skb->data);
 	skb_set_transport_header(skb, hdr_len);
 	memmove(skb->data, iph, hdr_len);
+
+	x->lastused = get_seconds();
+
 	return 0;
 }
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 40d75ec..8c85211 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -14,7 +14,6 @@
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
-#include <linux/time.h>
 #include <net/dst.h>
 #include <net/xfrm.h>
 
@@ -75,9 +74,6 @@ int xfrm_output(struct sk_buff *skb)
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
 
-		if (x->props.mode == XFRM_MODE_ROUTEOPTIMIZATION)
-			x->lastused = get_seconds();
-
 		spin_unlock_bh(&x->lock);
 
 		skb_reset_network_header(skb);
