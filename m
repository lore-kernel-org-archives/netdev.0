From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 6/6] netfilter: bridge: don't use nf_bridge storage during neigh resolution
Date: Thu, 12 Mar 2015 18:05:25 +0100
Message-ID: <1426179925-18220-7-git-send-email-fw@strlen.de>
References: <1426179925-18220-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426179925-18220-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The last user of the nf_bridge_info data area is the rare case where
we have to save original source MAC address when resolving the new
destination MAC address after ip dnat rewrite.  The neigh resolution
(re)builds new MAC header, using the bridge device source mac.

We can use skb->cb for this: We just need to make sure that we're
adding enough padding so qdiscs won't interfere with it.

This also uses the interface index of the physical dev instead of a
pointer.

Since we do not hold any reference to the physindev, so we should
at least make sure that we're not passing a stale address upon
reinject.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/skbuff.h    |  1 -
 net/bridge/br_device.c    |  2 +-
 net/bridge/br_netfilter.c | 39 +++++++++++++++++++++++++++++++++------
 net/bridge/br_private.h   |  2 +-
 4 files changed, 35 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 364c4a8..4049239 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -182,7 +182,6 @@ struct nf_bridge_info {
 	enum brnf_state	brnf_state;
 	struct net_device	*physindev;
 	struct net_device	*physoutdev;
-	unsigned long		data[32 / sizeof(unsigned long)];
 };
 #endif
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 4ff77a1..c3ec7fe 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -41,7 +41,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	rcu_read_lock();
 	nf_ops = rcu_dereference(nf_br_ops);
-	if (nf_ops && nf_ops->br_dev_xmit_hook(skb)) {
+	if (nf_ops && nf_ops->br_dev_xmit_hook(skb, dev)) {
 		rcu_read_unlock();
 		return NETDEV_TX_OK;
 	}
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 342081e..0ba697f 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -36,6 +36,7 @@
 #include <net/ipv6.h>
 #include <net/route.h>
 #include <net/netfilter/br_netfilter.h>
+#include <net/sch_generic.h>
 
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 #include <net/netfilter/nf_conntrack.h>
@@ -65,6 +66,15 @@ struct nf_bridge_skb_cb {
 
 #define BRNF_CB(skb) ((struct nf_bridge_skb_cb *)(skb)->cb)
 
+/* bridge netfilter dnat mac resolution via neigh cache */
+struct nf_bridge_dnat_skb_cb {
+	struct qdisc_skb_cb qdisc;
+	int physindev_index;
+	char dnat_orig_mac[ETH_HLEN - ETH_ALEN];
+};
+
+#define BRNF_DNAT_SKB_CB(__skb)  ((struct nf_bridge_dnat_skb_cb *)(__skb)->cb)
+
 #ifdef CONFIG_SYSCTL
 static struct ctl_table_header *brnf_sysctl_header;
 static int brnf_call_iptables __read_mostly = 1;
@@ -357,14 +367,22 @@ static int br_nf_pre_routing_finish_bridge(struct sk_buff *skb)
 			skb->dev = nf_bridge->physindev;
 			ret = br_handle_frame_finish(skb);
 		} else {
+			struct nf_bridge_dnat_skb_cb *cb;
+
+			cb = BRNF_DNAT_SKB_CB(skb);
+
+			memset(cb, 0, sizeof(*cb));
+
 			/* the neighbour function below overwrites the complete
 			 * MAC header, so we save the Ethernet source address and
 			 * protocol number.
 			 */
 			skb_copy_from_linear_data_offset(skb,
 							 -(ETH_HLEN-ETH_ALEN),
-							 skb->nf_bridge->data,
+							 cb->dnat_orig_mac,
 							 ETH_HLEN-ETH_ALEN);
+
+			cb->physindev_index = nf_bridge->physindev->ifindex;
 			/* tell br_dev_xmit to continue with forwarding */
 			nf_bridge->brnf_state = BRNF_STATE_BRIDGED_DNAT;
 			ret = neigh->output(neigh, skb);
@@ -991,24 +1009,32 @@ static unsigned int ip_sabotage_in(const struct nf_hook_ops *ops,
  * This restores the original MAC saddr of the bridged packet
  * before invoking bridge forward logic to transmit the packet.
  */
-static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
+static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb,
+						 struct net_device *dev)
 {
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
+	struct nf_bridge_dnat_skb_cb *cb = BRNF_DNAT_SKB_CB(skb);
 
 	skb_pull(skb, ETH_HLEN);
 	nf_bridge->brnf_state = BRNF_STATE_SEEN;
 
 	skb_copy_to_linear_data_offset(skb, -(ETH_HLEN-ETH_ALEN),
-				       skb->nf_bridge->data, ETH_HLEN-ETH_ALEN);
-	skb->dev = nf_bridge->physindev;
+				       cb->dnat_orig_mac, ETH_HLEN - ETH_ALEN);
+
+	skb->dev = dev_get_by_index_rcu(dev_net(dev), cb->physindev_index);
+	if (!skb->dev) {
+		kfree_skb(skb);
+		return;
+	}
+
 	br_handle_frame_finish(skb);
 }
 
-static int br_nf_dev_xmit(struct sk_buff *skb)
+static int br_nf_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (skb->nf_bridge &&
 	    skb->nf_bridge->brnf_state == BRNF_STATE_BRIDGED_DNAT) {
-		br_nf_pre_routing_finish_bridge_slow(skb);
+		br_nf_pre_routing_finish_bridge_slow(skb, dev);
 		return 1;
 	}
 	return 0;
@@ -1143,6 +1169,7 @@ static int __init br_netfilter_init(void)
 	int ret;
 
 	BUILD_BUG_ON(sizeof(struct nf_bridge_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
+	BUILD_BUG_ON(sizeof(struct nf_bridge_dnat_skb_cb) > FIELD_SIZEOF(struct sk_buff, cb));
 
 	ret = nf_register_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 	if (ret < 0)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index b46fa0c..6664141 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -764,7 +764,7 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 #endif
 
 struct nf_br_ops {
-	int (*br_dev_xmit_hook)(struct sk_buff *skb);
+	int (*br_dev_xmit_hook)(struct sk_buff *skb, struct net_device *dev);
 };
 extern const struct nf_br_ops __rcu *nf_br_ops;
 
-- 
2.0.5

