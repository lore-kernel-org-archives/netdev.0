From: Florian Westphal <fw@strlen.de>
Subject: [PATCH v2 nf-next 3/6] netfilter: bridge: use skb->cb to track otherhost mangling
Date: Thu, 12 Mar 2015 18:05:22 +0100
Message-ID: <1426179925-18220-4-git-send-email-fw@strlen.de>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426179925-18220-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nf_bridge_info->mask is used for several things, for example to remember
if skb->pkt_type was set to OTHER_HOST.

For a bridge, OTHER_HOST is expected case. For ip forward its a
non-starter though -- routing expects PACKET_HOST.

Bridge netfilter thus changes OTHER_HOST to PACKET_HOST
before hook invocation and then un-does it after hook traversal.

For this, cb[] can be used since the skb will never be used outside
(fake inet) bridge forwarding while in 'fake PACKET_HOST' state.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter_bridge.h |  1 -
 net/bridge/br_netfilter.c        | 71 ++++++++++++++++++++++++++--------------
 2 files changed, 47 insertions(+), 25 deletions(-)

diff --git a/include/linux/netfilter_bridge.h b/include/linux/netfilter_bridge.h
index b131613..05437f8 100644
--- a/include/linux/netfilter_bridge.h
+++ b/include/linux/netfilter_bridge.h
@@ -17,7 +17,6 @@ enum nf_br_hook_priorities {
 
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
 
-#define BRNF_PKT_TYPE			0x01
 #define BRNF_BRIDGED_DNAT		0x02
 #define BRNF_NF_BRIDGE_PREROUTING	0x08
 #define BRNF_8021Q			0x10
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 669b4fa..8649ef5 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -47,6 +47,17 @@
 #include <linux/sysctl.h>
 #endif
 
+struct nf_bridge_skb_cb {
+	union {
+		struct inet_skb_parm i;
+		struct inet6_skb_parm i6;
+	} u;
+
+	u8 packet_otherhost:1;
+};
+
+#define BRNF_CB(skb) ((struct nf_bridge_skb_cb *)(skb)->cb)
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
@@ -259,6 +270,29 @@ static void nf_bridge_update_protocol(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_PPP_SES);
 }
 
+static void nf_bridge_restore_otherhost(struct sk_buff *skb)
+{
+	struct nf_bridge_skb_cb *cb = BRNF_CB(skb);
+
+	if (cb->packet_otherhost) {
+		cb->packet_otherhost = 0;
+		skb->pkt_type = PACKET_OTHERHOST;
+	}
+}
+
+static void nf_bridge_save_otherhost(struct sk_buff *skb)
+{
+	struct nf_bridge_skb_cb *cb;
+
+	if (skb->pkt_type != PACKET_OTHERHOST)
+		return;
+
+	cb = BRNF_CB(skb);
+
+	cb->packet_otherhost = 1;
+	skb->pkt_type = PACKET_HOST;
+}
+
 /* PF_BRIDGE/PRE_ROUTING *********************************************/
 /* Undo the changes made for ip6tables PREROUTING and continue the
  * bridge PRE_ROUTING hook. */
@@ -267,10 +301,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct rtable *rt;
 
-	if (nf_bridge->mask & BRNF_PKT_TYPE) {
-		skb->pkt_type = PACKET_OTHERHOST;
-		nf_bridge->mask ^= BRNF_PKT_TYPE;
-	}
+	nf_bridge_restore_otherhost(skb);
+
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 
 	rt = bridge_parent_rtable(nf_bridge->physindev);
@@ -400,10 +432,7 @@ static int br_nf_pre_routing_finish(struct sk_buff *skb)
 	frag_max_size = IPCB(skb)->frag_max_size;
 	BR_INPUT_SKB_CB(skb)->frag_max_size = frag_max_size;
 
-	if (nf_bridge->mask & BRNF_PKT_TYPE) {
-		skb->pkt_type = PACKET_OTHERHOST;
-		nf_bridge->mask ^= BRNF_PKT_TYPE;
-	}
+	nf_bridge_restore_otherhost(skb);
 	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
 	if (dnat_took_place(skb)) {
 		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, dev))) {
@@ -485,11 +514,10 @@ static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct
 static struct net_device *setup_pre_routing(struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_skb_cb *cb = BRNF_CB(skb);
 
-	if (skb->pkt_type == PACKET_OTHERHOST) {
-		skb->pkt_type = PACKET_HOST;
-		nf_bridge->mask |= BRNF_PKT_TYPE;
-	}
+	cb->packet_otherhost = 0;
+	nf_bridge_save_otherhost(skb);
 
 	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
@@ -687,11 +715,8 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	struct net_device *in;
 
 	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
+		nf_bridge_restore_otherhost(skb);
 		in = nf_bridge->physindev;
-		if (nf_bridge->mask & BRNF_PKT_TYPE) {
-			skb->pkt_type = PACKET_OTHERHOST;
-			nf_bridge->mask ^= BRNF_PKT_TYPE;
-		}
 		nf_bridge_update_protocol(skb);
 	} else {
 		in = *((struct net_device **)(skb->cb));
@@ -741,10 +766,8 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	nf_bridge_pull_encap_header(skb);
 
 	nf_bridge = skb->nf_bridge;
-	if (skb->pkt_type == PACKET_OTHERHOST) {
-		skb->pkt_type = PACKET_HOST;
-		nf_bridge->mask |= BRNF_PKT_TYPE;
-	}
+
+	nf_bridge_save_otherhost(skb);
 
 	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
 		return NF_DROP;
@@ -911,10 +934,8 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 
 	/* We assume any code from br_dev_queue_push_xmit onwards doesn't care
 	 * about the value of skb->pkt_type. */
-	if (skb->pkt_type == PACKET_OTHERHOST) {
-		skb->pkt_type = PACKET_HOST;
-		nf_bridge->mask |= BRNF_PKT_TYPE;
-	}
+
+	nf_bridge_save_otherhost(skb);
 
 	nf_bridge_pull_encap_header(skb);
 	if (pf == NFPROTO_IPV4)
@@ -1104,6 +1125,8 @@ static int __init br_netfilter_init(void)
 {
 	int ret;
 
+	BUILD_BUG_ON(sizeof(struct nf_bridge_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
+
 	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 	if (ret < 0)
 		return ret;
-- 
2.0.5

