From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 6/8] netfilter: bridge: query conntrack about skb dnat
Date: Thu,  5 Mar 2015 00:52:38 +0100
Message-ID: <1425513160-496-7-git-send-email-fw@strlen.de>
References: <1425513160-496-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1425513160-496-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ask conntrack instead of remembering ipv4 address in nf_bridge_info->data.

Ths avoids the need to use ->data during NF_PRE_ROUTING.
Only two use cases that need ->data remain.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h |  6 ------
 net/bridge/br_netfilter.c        | 20 ++++++++++++++------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index 3b5e539..ab06213 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -38,12 +38,6 @@ static inline unsigned int nf_bridge_encap_header_len(const struct sk_buff *skb)
 
 int br_handle_frame_finish(struct sk_buff *skb);
 
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
index cf4e93f..6ff7ed5 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -36,6 +36,7 @@
 #include <net/ipv6.h>
 #include <net/route.h>
 #include <net/netfilter/br_netfilter.h>
+#include <net/netfilter/nf_conntrack.h>
 
 #include <asm/uaccess.h>
 #include "br_private.h"
@@ -43,11 +44,6 @@
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
@@ -322,6 +318,18 @@ free_skb:
 	return 0;
 }
 
+static bool dnat_took_place(const struct sk_buff *skb)
+{
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (!ct || nf_ct_is_untracked(ct))
+		return false;
+
+	return test_bit(IPS_DST_NAT_BIT, &ct->status);
+}
+
 /* This requires some explaining. If DNAT has taken place,
  * we will need to fix up the destination Ethernet address.
  *
@@ -625,7 +633,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 		return NF_DROP;
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
-	store_orig_dstaddr(skb);
+
 	skb->protocol = htons(ETH_P_IP);
 
 	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
-- 
2.0.5

