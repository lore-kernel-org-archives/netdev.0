From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [5/5] [IPSEC]: Handle GSO packets
Date: Thu, 22 Jun 2006 18:14:44 +1000
Message-ID: <20060622081444.GE22671@gondor.apana.org.au>
References: <20060622081211.GA22505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="Uwl7UQhJk99r8jnw"
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:19716 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932840AbWFVIOq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:14:46 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060622081211.GA22505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Uwl7UQhJk99r8jnw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

[IPSEC]: Handle GSO packets

This patch segments GSO packets received by the IPsec stack.  This can
happen when a NIC driver injects GSO packets into the stack which are
then forwarded to another host.

The primary application of this is going to be Xen where its backend
driver may inject GSO packets into dom0.

Of course this also can be used by other virtualisation schemes such as
VMWare or UML since the tap device could be modified to inject GSO packets
received through splice.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--Uwl7UQhJk99r8jnw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p5.patch"

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -9,6 +9,8 @@
  */
 
 #include <linux/compiler.h>
+#include <linux/if_ether.h>
+#include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/spinlock.h>
 #include <linux/netfilter_ipv4.h>
@@ -97,16 +99,10 @@ error_nolock:
 	goto out_exit;
 }
 
-static int xfrm4_output_finish(struct sk_buff *skb)
+static int xfrm4_output_finish2(struct sk_buff *skb)
 {
 	int err;
 
-#ifdef CONFIG_NETFILTER
-	if (!skb->dst->xfrm) {
-		IPCB(skb)->flags |= IPSKB_REROUTED;
-		return dst_output(skb);
-	}
-#endif
 	while (likely((err = xfrm4_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
@@ -119,7 +115,7 @@ static int xfrm4_output_finish(struct sk
 			return dst_output(skb);
 
 		err = nf_hook(PF_INET, NF_IP_POST_ROUTING, &skb, NULL,
-			      skb->dst->dev, xfrm4_output_finish);
+			      skb->dst->dev, xfrm4_output_finish2);
 		if (unlikely(err != 1))
 			break;
 	}
@@ -127,6 +123,48 @@ static int xfrm4_output_finish(struct sk
 	return err;
 }
 
+static int xfrm4_output_finish(struct sk_buff *skb)
+{
+	struct sk_buff *segs;
+
+#ifdef CONFIG_NETFILTER
+	if (!skb->dst->xfrm) {
+		IPCB(skb)->flags |= IPSKB_REROUTED;
+		return dst_output(skb);
+	}
+#endif
+
+	if (!skb_shinfo(skb)->gso_size)
+		return xfrm4_output_finish2(skb);
+
+	skb->protocol = htons(ETH_P_IP);
+	segs = skb_gso_segment(skb, 0);
+	kfree_skb(skb);
+	if (unlikely(IS_ERR(segs)))
+		return PTR_ERR(segs);
+
+	do {
+		struct sk_buff *nskb = segs->next;
+		int err;
+
+		segs->next = NULL;
+		err = xfrm4_output_finish2(segs);
+
+		if (unlikely(err)) {
+			while ((segs = nskb)) {
+				nskb = segs->next;
+				segs->next = NULL;
+				kfree_skb(segs);
+			}
+			return err;
+		}
+
+		segs = nskb;
+	} while (segs);
+
+	return 0;
+}
+
 int xfrm4_output(struct sk_buff *skb)
 {
 	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -94,7 +94,7 @@ error_nolock:
 	goto out_exit;
 }
 
-static int xfrm6_output_finish(struct sk_buff *skb)
+static int xfrm6_output_finish2(struct sk_buff *skb)
 {
 	int err;
 
@@ -110,7 +110,7 @@ static int xfrm6_output_finish(struct sk
 			return dst_output(skb);
 
 		err = nf_hook(PF_INET6, NF_IP6_POST_ROUTING, &skb, NULL,
-			      skb->dst->dev, xfrm6_output_finish);
+			      skb->dst->dev, xfrm6_output_finish2);
 		if (unlikely(err != 1))
 			break;
 	}
@@ -118,6 +118,41 @@ static int xfrm6_output_finish(struct sk
 	return err;
 }
 
+static int xfrm6_output_finish(struct sk_buff *skb)
+{
+	struct sk_buff *segs;
+
+	if (!skb_shinfo(skb)->gso_size)
+		return xfrm6_output_finish2(skb);
+
+	skb->protocol = htons(ETH_P_IP);
+	segs = skb_gso_segment(skb, 0);
+	kfree_skb(skb);
+	if (unlikely(IS_ERR(segs)))
+		return PTR_ERR(segs);
+
+	do {
+		struct sk_buff *nskb = segs->next;
+		int err;
+
+		segs->next = NULL;
+		err = xfrm6_output_finish2(segs);
+
+		if (unlikely(err)) {
+			while ((segs = nskb)) {
+				nskb = segs->next;
+				segs->next = NULL;
+				kfree_skb(segs);
+			}
+			return err;
+		}
+
+		segs = nskb;
+	} while (segs);
+
+	return 0;
+}
+
 int xfrm6_output(struct sk_buff *skb)
 {
 	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,

--Uwl7UQhJk99r8jnw--
