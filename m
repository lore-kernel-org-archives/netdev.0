From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH] netdev: Netfilters on outgoing interfamily ipsec
Date: Fri, 19 Oct 2007 14:37:38 +0300
Message-ID: <200710191437.39449.joakim.koskela@hiit.fi>
Reply-To: joakim.koskela@hiit.fi
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	"Patrick McHardy" <kaber@trash.net>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pne-smtpout3-sn1.fre.skanova.net ([81.228.11.120]:60070 "EHLO
	pne-smtpout3-sn1.fre.skanova.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754444AbXJSLlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 07:41:45 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I understand that Herbert is in midst of cleaning up the output of
interfamily transformations, but I thought I'd post a couple of
patches related to that anyway, sort of to show what we've needed to
fix to get our systems working.

This one changes how the netfilters are applied during output to be
based on the current address family of the packet instead of what it
will be transformed to.

Signed-off-by: Joakim Koskela <jookos@gmail.com>
---

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index c4a7156..8b0c6bd 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -13,6 +13,9 @@
 #include <linux/kernel.h>
 #include <linux/skbuff.h>
 #include <linux/netfilter_ipv4.h>
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+#include <linux/netfilter_ipv6.h>
+#endif
 #include <net/ip.h>
 #include <net/xfrm.h>
 #include <net/icmp.h>
@@ -139,7 +142,13 @@ static int xfrm4_output_finish(struct sk_buff *skb)
 
 int xfrm4_output(struct sk_buff *skb)
 {
-	return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
-			    xfrm4_output_finish,
-			    !(IPCB(skb)->flags & IPSKB_REROUTED));
+#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
+	if (ip_hdr(skb)->version == 6)
+		return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,
+			       xfrm4_output_finish);
+	else
+#endif
+		return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
+				    xfrm4_output_finish,
+				    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 6569767..7624613 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -14,8 +14,10 @@
 #include <linux/skbuff.h>
 #include <linux/icmpv6.h>
 #include <linux/netfilter_ipv6.h>
+#include <linux/netfilter_ipv4.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
+#include <net/ip.h>
 
 int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 			  u8 **prevhdr)
@@ -134,6 +136,11 @@ static int xfrm6_output_finish(struct sk_buff *skb)
 
 int xfrm6_output(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,
-		       xfrm6_output_finish);
+	if (ip_hdr(skb)->version == 4)
+		return NF_HOOK_COND(PF_INET, NF_IP_POST_ROUTING, skb, NULL, skb->dst->dev,
+				    xfrm6_output_finish,
+				    !(IPCB(skb)->flags & IPSKB_REROUTED));
+	else
+		return NF_HOOK(PF_INET6, NF_IP6_POST_ROUTING, skb, NULL, skb->dst->dev,
+			       xfrm6_output_finish);
 }
