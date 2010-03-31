From: Jan Engelhardt <jengelh@medozas.de>
Subject: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through Xtables too
Date: Wed, 31 Mar 2010 12:38:53 +0200
Message-ID: <1270031934-15940-6-git-send-email-jengelh@medozas.de>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1270031934-15940-1-git-send-email-jengelh@medozas.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since Xtables is now reentrant/nestable, the cloned packet can also go
through Xtables and be subject to rules itself.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/ip_output.c   |    1 -
 net/ipv6/ip6_output.c  |    1 -
 net/netfilter/xt_TEE.c |   18 ++----------------
 3 files changed, 2 insertions(+), 18 deletions(-)

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
index 307d8bf..7e10f62 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -176,7 +176,6 @@ int ip6_output(struct sk_buff *skb)
 			    ip6_finish_output,
 			    !(IP6CB(skb)->flags & IPSKB_REROUTED));
 }
-EXPORT_SYMBOL_GPL(ip6_output);
 
 /*
  *	xmit an sk_buff (used by TCP)
diff --git a/net/netfilter/xt_TEE.c b/net/netfilter/xt_TEE.c
index 96dd746..70078f1 100644
--- a/net/netfilter/xt_TEE.c
+++ b/net/netfilter/xt_TEE.c
@@ -130,21 +130,8 @@ tee_tg4(struct sk_buff *skb, const struct xt_target_param *par)
 	skb->nfctinfo = IP_CT_NEW;
 	nf_conntrack_get(skb->nfct);
 #endif
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
 	if (tee_tg_route4(skb, info))
-		ip_output(skb);
+		ip_local_out(skb);
 
 	return XT_CONTINUE;
 }
@@ -199,9 +186,8 @@ tee_tg6(struct sk_buff *skb, const struct xt_target_param *par)
 		struct ipv6hdr *iph = ipv6_hdr(skb);
 		--iph->hop_limit;
 	}
-	IP6CB(skb)->flags |= IPSKB_REROUTED;
 	if (tee_tg_route6(skb, info))
-		ip6_output(skb);
+		ip6_local_out(skb);
 
 	return XT_CONTINUE;
 }
-- 
1.7.0.2

