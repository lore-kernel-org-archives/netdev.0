From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/8] netfilter: bridge: query conntrack about skb dnat
Date: Mon, 23 Mar 2015 12:36:17 +0100
Message-ID: <1427110584-5190-2-git-send-email-pablo@netfilter.org>
References: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60084 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbbCWLce (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 07:32:34 -0400
In-Reply-To: <1427110584-5190-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

ask conntrack instead of storing ipv4 address in nf_bridge_info->data.

Ths avoids the need to use ->data during NF_PRE_ROUTING.
Only two functions that need ->data remain.

These will be addressed in followup patches.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_bridge.h |    6 ------
 net/bridge/br_netfilter.c        |   27 +++++++++++++++++++++------
 2 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index bb39113..de123d7 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -54,12 +54,6 @@ static inline unsigned int nf_bridge_pad(const struct sk_buff *skb)
 	return 0;
 }
 
-struct bridge_skb_cb {
-	union {
-		__be32 ipv4;
-	} daddr;
-};
-
 static inline void br_drop_fake_rtable(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index b260a97..261fcd5 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -37,17 +37,16 @@
 #include <net/route.h>
 #include <net/netfilter/br_netfilter.h>
 
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack.h>
+#endif
+
 #include <asm/uaccess.h>
 #include "br_private.h"
 #ifdef CONFIG_SYSCTL
 #include <linux/sysctl.h>
 #endif
 
-#define skb_origaddr(skb)	 (((struct bridge_skb_cb *) \
-				 (skb->nf_bridge->data))->daddr.ipv4)
-#define store_orig_dstaddr(skb)	 (skb_origaddr(skb) = ip_hdr(skb)->daddr)
-#define dnat_took_place(skb)	 (skb_origaddr(skb) != ip_hdr(skb)->daddr)
-
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
@@ -322,6 +321,22 @@ free_skb:
 	return 0;
 }
 
+static bool dnat_took_place(const struct sk_buff *skb)
+{
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct || nf_ct_is_untracked(ct))
+		return false;
+
+	return test_bit(IPS_DST_NAT_BIT, &ct->status);
+#else
+	return false;
+#endif
+}
+
 /* This requires some explaining. If DNAT has taken place,
  * we will need to fix up the destination Ethernet address.
  *
@@ -625,7 +640,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 		return NF_DROP;
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
-	store_orig_dstaddr(skb);
+
 	skb->protocol = htons(ETH_P_IP);
 
 	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
-- 
1.7.10.4
