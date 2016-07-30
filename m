From: fxp2001640163@gmail.com
Subject: [PATCH 2/3] netfilter: nat: snat created in route process just apply to routed traffic
Date: Sat, 30 Jul 2016 14:54:04 -0700
Message-ID: <1469915644-16861-1-git-send-email-xfan@codeaurora.org>
Cc: Xiaoping Fan <xfan@codeaurora.org>
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34159 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753010AbcG3VyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 17:54:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiaoping Fan <xfan@codeaurora.org>

In some situations, packet goes through Linux twice, one for bridging,
another for routing. If snat is created in bridging process, that means
snat rule only matches bridged traffic. If snat is created in routing
process, that means snat rule only matches routed traffic. If we apply
snat to both bridged and routed traffic, traffic will be translated
unexpectedly. So we limit snat created in bridge process to bridged
traffic, snat created in route process to routed traffic.

Signed-off-by: Xiaoping Fan <xfan@codeaurora.org>
---
 include/net/netfilter/nf_nat.h           |  9 +++++++++
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c | 15 ++++++++++++++-
 net/ipv6/netfilter/nf_nat_l3proto_ipv6.c | 15 ++++++++++++++-
 3 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index c327a43..ef6e06c 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -18,12 +18,21 @@ enum nf_nat_manip_type {
 #include <linux/netfilter/nf_conntrack_pptp.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 
+/* Check if packet is a bridged packet when do SNAT */
+#if defined(CONFIG_BRIDGE_NETFILTER)
+#define nf_nat_is_bridged_pkt(SKB) ((SKB)->nf_bridge && \
+				    ((SKB)->nf_bridge->physoutdev != NULL))
+#else
+#define nf_nat_is_bridged_pkt(SKB) 0
+#endif
+
 /* per conntrack: nat application helper private data */
 union nf_conntrack_nat_help {
 	/* insert nat helper private data here */
 #if defined(CONFIG_NF_NAT_PPTP) || defined(CONFIG_NF_NAT_PPTP_MODULE)
 	struct nf_nat_pptp nat_pptp_info;
 #endif
+	bool snat_in_bridge;
 };
 
 struct nf_conn;
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
index f8aad03..41c7992 100644
--- a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -14,6 +14,7 @@
 #include <linux/ip.h>
 #include <linux/icmp.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
 #include <net/secure_seq.h>
 #include <net/checksum.h>
@@ -277,6 +278,12 @@ nf_nat_ipv4_fn(void *priv, struct sk_buff *skb,
 	if (nat == NULL)
 		return NF_ACCEPT;
 
+	if ((maniptype == NF_NAT_MANIP_SRC) &&
+	    nf_nat_initialized(ct, maniptype) &&
+	    (nat->help.snat_in_bridge != nf_nat_is_bridged_pkt(skb))) {
+		return NF_ACCEPT;
+	}
+
 	switch (ctinfo) {
 	case IP_CT_RELATED:
 	case IP_CT_RELATED_REPLY:
@@ -299,8 +306,14 @@ nf_nat_ipv4_fn(void *priv, struct sk_buff *skb,
 			if (ret != NF_ACCEPT)
 				return ret;
 
-			if (nf_nat_initialized(ct, HOOK2MANIP(state->hook)))
+			if (nf_nat_initialized(ct, HOOK2MANIP(state->hook))) {
+				if (maniptype == NF_NAT_MANIP_SRC) {
+					nfct_nat(ct)->help.snat_in_bridge =
+						nf_nat_is_bridged_pkt(skb);
+				}
+
 				break;
+			}
 
 			ret = nf_nat_alloc_null_binding(ct, state->hook);
 			if (ret != NF_ACCEPT)
diff --git a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
index e0be97e..dc8df3a 100644
--- a/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_nat_l3proto_ipv6.c
@@ -12,6 +12,7 @@
 #include <linux/skbuff.h>
 #include <linux/ipv6.h>
 #include <linux/netfilter.h>
+#include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv6.h>
 #include <net/secure_seq.h>
 #include <net/checksum.h>
@@ -281,6 +282,12 @@ nf_nat_ipv6_fn(void *priv, struct sk_buff *skb,
 	if (nat == NULL)
 		return NF_ACCEPT;
 
+	if ((maniptype == NF_NAT_MANIP_SRC) &&
+	    nf_nat_initialized(ct, maniptype) &&
+	    (nat->help.snat_in_bridge != nf_nat_is_bridged_pkt(skb))) {
+		return NF_ACCEPT;
+	}
+
 	switch (ctinfo) {
 	case IP_CT_RELATED:
 	case IP_CT_RELATED_REPLY:
@@ -308,8 +315,14 @@ nf_nat_ipv6_fn(void *priv, struct sk_buff *skb,
 			if (ret != NF_ACCEPT)
 				return ret;
 
-			if (nf_nat_initialized(ct, HOOK2MANIP(state->hook)))
+			if (nf_nat_initialized(ct, HOOK2MANIP(state->hook))) {
+				if (maniptype == NF_NAT_MANIP_SRC) {
+					nfct_nat(ct)->help.snat_in_bridge =
+						nf_nat_is_bridged_pkt(skb);
+				}
+
 				break;
+			}
 
 			ret = nf_nat_alloc_null_binding(ct, state->hook);
 			if (ret != NF_ACCEPT)
-- 
1.9.1
