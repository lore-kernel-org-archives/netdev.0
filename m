From: kaber@trash.net
Subject: [PATCH 74/84] netfilter: xt_TEE: have cloned packet travel through Xtables too
Date: Mon, 10 May 2010 22:18:45 +0200
Message-ID: <1273522735-24672-75-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54521 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756944Ab0EJUT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:28 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

Since Xtables is now reentrant/nestable, the cloned packet can also go
through Xtables and be subject to rules itself.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/ip_output.c   |    1 -
 net/ipv6/ip6_output.c  |    1 -
 net/netfilter/xt_TEE.c |   40 ++++++++++++++++++----------------------
 3 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0abfdde..f09135e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -309,7 +309,6 @@ int ip_output(struct sk_buff *skb)
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
-EXPORT_SYMBOL_GPL(ip_output);
 
 int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d09be7f..c10a38a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -176,7 +176,6 @@ int ip6_output(struct sk_buff *skb)
 			    ip6_finish_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
-EXPORT_SYMBOL_GPL(ip6_output);
 
 /*
  *	xmit an sk_buff (used by TCP)
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index b3d7301..842e701 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -12,6 +12,7 @@
  */
 #include <linux/ip.h>
 #include <linux/module.h>
+#include <linux/percpu.h>
 #include <linux/route.h>
 #include <linux/skbuff.h>
 #include <net/checksum.h>
@@ -32,6 +33,7 @@
 #endif
 
 static const union nf_inet_addr tee_zero_address;
+static DEFINE_PER_CPU(bool, tee_active);
 
 static struct net *pick_net(struct sk_buff *skb)
 {
@@ -91,6 +93,8 @@ tee_tg4(struct sk_buff *skb, const struct xt_target_param *par)
 	const struct xt_tee_tginfo *info = par->targinfo;
 	struct iphdr *iph;
 
+	if (percpu_read(tee_active))
+		return XT_CONTINUE;
 	/*
 	 * Copy the skb, and route the copy. Will later return %XT_CONTINUE for
 	 * the original skb, which should continue on its way as if nothing has
@@ -125,24 +129,13 @@ tee_tg4(struct sk_buff *skb, const struct xt_target_param *par)
 		--iph->ttl;
 	ip_send_check(iph);
 
-	/*
-	 * Xtables is not reentrant currently, so a choice has to be made:
-	 * 1. return absolute verdict for the original and let the cloned
-	 *    packet travel through the chains
-	 * 2. let the original continue travelling and not pass the clone
-	 *    to Xtables.
-	 * #2 is chosen. Normally, we would use ip_local_out for the clone.
-	 * Because iph->check is already correct and we don't pass it to
-	 * Xtables anyway, a shortcut to dst_output [forwards to ip_output] can
-	 * be taken. %IPSKB_REROUTED needs to be set so that ip_output does not
-	 * invoke POSTROUTING on the cloned packet.
-	 */
-	IPCB(skb)->flags |= IPSKB_REROUTED;
-	if (tee_tg_route4(skb, info))
-		ip_output(skb);
-	else
+	if (tee_tg_route4(skb, info)) {
+		percpu_write(tee_active, true);
+		ip_local_out(skb);
+		percpu_write(tee_active, false);
+	} else {
 		kfree_skb(skb);
-
+	}
 	return XT_CONTINUE;
 }
 
@@ -177,6 +170,8 @@ tee_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	const struct xt_tee_tginfo *info = par->targinfo;
 
+	if (percpu_read(tee_active))
+		return XT_CONTINUE;
 	skb = pskb_copy(skb, GFP_ATOMIC);
 	if (skb == NULL)
 		return XT_CONTINUE;
@@ -192,12 +187,13 @@ tee_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 		--iph->hop_limit;
 	}
-	IP6CB(skb)->flags |= IP6SKB_REROUTED;
-	if (tee_tg_route6(skb, info))
-		ip6_output(skb);
-	else
+	if (tee_tg_route6(skb, info)) {
+		percpu_write(tee_active, true);
+		ip6_local_out(skb);
+		percpu_write(tee_active, false);
+	} else {
 		kfree_skb(skb);
-
+	}
 	return XT_CONTINUE;
 }
 #endif /* WITH_IPV6 */
-- 
1.7.0.4

