From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 4/6] netfilter: nf_tables: fix nf_trace always-on with XT_TRACE=n
Date: Wed, 19 Feb 2014 12:41:40 +0100
Message-ID: <1392810102-13877-5-git-send-email-pablo@netfilter.org>
References: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:44993 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752905AbaBSLl4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 06:41:56 -0500
In-Reply-To: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

When using nftables with CONFIG_NETFILTER_XT_TARGET_TRACE=n, we get
lots of "TRACE: filter:output:policy:1 IN=..." warnings as several
places will leave skb->nf_trace uninitialised.

Unlike iptables tracing functionality is not conditional in nftables,
so always copy/zero nf_trace setting when nftables is enabled.

Move this into __nf_copy() helper.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/skbuff.h |    5 ++++-
 net/core/skbuff.c      |    3 ---
 net/ipv4/ip_output.c   |    3 ---
 net/ipv6/ip6_output.c  |    3 ---
 4 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f589c9a..d40d40b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2725,7 +2725,7 @@ static inline void nf_reset(struct sk_buff *skb)
 
 static inline void nf_reset_trace(struct sk_buff *skb)
 {
-#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE) || defined(CONFIG_NF_TABLES)
 	skb->nf_trace = 0;
 #endif
 }
@@ -2742,6 +2742,9 @@ static inline void __nf_copy(struct sk_buff *dst, const struct sk_buff *src)
 	dst->nf_bridge  = src->nf_bridge;
 	nf_bridge_get(src->nf_bridge);
 #endif
+#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE) || defined(CONFIG_NF_TABLES)
+	dst->nf_trace = src->nf_trace;
+#endif
 }
 
 static inline void nf_copy(struct sk_buff *dst, const struct sk_buff *src)
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 5976ef0..5d6236d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -707,9 +707,6 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 	new->mark		= old->mark;
 	new->skb_iif		= old->skb_iif;
 	__nf_copy(new, old);
-#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
-	new->nf_trace		= old->nf_trace;
-#endif
 #ifdef CONFIG_NET_SCHED
 	new->tc_index		= old->tc_index;
 #ifdef CONFIG_NET_CLS_ACT
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8971780..73c6b63 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -422,9 +422,6 @@ static void ip_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->tc_index = from->tc_index;
 #endif
 	nf_copy(to, from);
-#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
-	to->nf_trace = from->nf_trace;
-#endif
 #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
 	to->ipvs_property = from->ipvs_property;
 #endif
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ef02b26..4cfbe0f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -517,9 +517,6 @@ static void ip6_copy_metadata(struct sk_buff *to, struct sk_buff *from)
 	to->tc_index = from->tc_index;
 #endif
 	nf_copy(to, from);
-#if IS_ENABLED(CONFIG_NETFILTER_XT_TARGET_TRACE)
-	to->nf_trace = from->nf_trace;
-#endif
 	skb_copy_secmark(to, from);
 }
 
-- 
1.7.10.4
