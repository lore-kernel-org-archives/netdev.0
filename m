From: Aaron Conole <aconole@bytheb.org>
Subject: [RFC nf-next 1/3] netfilter: bridge: add and use br_nf_hook_thresh
Date: Wed, 22 Jun 2016 17:34:29 -0400
Message-ID: <1466631271-10737-2-git-send-email-aconole@bytheb.org>
References: <1466631271-10737-1-git-send-email-aconole@bytheb.org>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1466631271-10737-1-git-send-email-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

This replaces the last uses of NF_HOOK_THRESH().
Followup patch will remove it and rename nf_hook_thresh.

The reason is that inet (non-bridge) netfilter no longer invokes the
hooks from hooks, so we do no longer need the thresh value to skip hooks
with a lower priority.

The bridge netfilter however may need to do this. br_nf_hook_thresh is a
wrapper that is supposed to do this, i.e. only call hooks with a
priority that exceeds NF_BR_PRI_BRNF.

It's used only in the recursion cases of br_netfilter.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Aaron Conole <aconole@redhat.com>
---
 include/net/netfilter/br_netfilter.h |  6 ++++
 net/bridge/br_netfilter_hooks.c      | 57 ++++++++++++++++++++++++++++++------
 net/bridge/br_netfilter_ipv6.c       | 12 ++++----
 3 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/include/net/netfilter/br_netfilter.h b/include/net/netfilter/br_netfilter.h
index e8d1448..0b0c35c 100644
--- a/include/net/netfilter/br_netfilter.h
+++ b/include/net/netfilter/br_netfilter.h
@@ -15,6 +15,12 @@ static inline struct nf_bridge_info *nf_bridge_alloc(struct sk_buff *skb)
 
 void nf_bridge_update_protocol(struct sk_buff *skb);
 
+int br_nf_hook_thresh(unsigned int hook, struct net *net, struct sock *sk,
+		      struct sk_buff *skb, struct net_device *indev,
+		      struct net_device *outdev,
+		      int (*okfn)(struct net *, struct sock *,
+				  struct sk_buff *));
+
 static inline struct nf_bridge_info *
 nf_bridge_info_get(const struct sk_buff *skb)
 {
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index 2d25979..19f230c 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -30,6 +30,7 @@
 #include <linux/netfilter_ipv6.h>
 #include <linux/netfilter_arp.h>
 #include <linux/in_route.h>
+#include <linux/rculist.h>
 #include <linux/inetdevice.h>
 
 #include <net/ip.h>
@@ -395,11 +396,10 @@ bridged_dnat:
 				skb->dev = nf_bridge->physindev;
 				nf_bridge_update_protocol(skb);
 				nf_bridge_push_encap_header(skb);
-				NF_HOOK_THRESH(NFPROTO_BRIDGE,
-					       NF_BR_PRE_ROUTING,
-					       net, sk, skb, skb->dev, NULL,
-					       br_nf_pre_routing_finish_bridge,
-					       1);
+				br_nf_hook_thresh(NF_BR_PRE_ROUTING,
+						  net, sk, skb, skb->dev,
+						  NULL,
+						  br_nf_pre_routing_finish);
 				return 0;
 			}
 			ether_addr_copy(eth_hdr(skb)->h_dest, dev->dev_addr);
@@ -417,10 +417,8 @@ bridged_dnat:
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, net, sk, skb,
-		       skb->dev, NULL,
-		       br_handle_frame_finish, 1);
-
+	br_nf_hook_thresh(NF_BR_PRE_ROUTING, net, sk, skb, skb->dev, NULL,
+			  br_handle_frame_finish);
 	return 0;
 }
 
@@ -992,6 +990,47 @@ static struct notifier_block brnf_notifier __read_mostly = {
 	.notifier_call = brnf_device_event,
 };
 
+/* recursively invokes nf_hook_slow (again), skipping already-called
+ * hooks (< NF_BR_PRI_BRNF).
+ *
+ * Called with rcu read lock held.
+ */
+int br_nf_hook_thresh(unsigned int hook, struct net *net,
+		      struct sock *sk, struct sk_buff *skb,
+		      struct net_device *indev,
+		      struct net_device *outdev,
+		      int (*okfn)(struct net *, struct sock *,
+				  struct sk_buf *))
+{
+	struct nf_hook_ops *elem;
+	struct nf_hook_state state;
+	struct list_head *head;
+	int ret;
+
+	head = &net->nf.hooks[NFPROTO_BRIDGE][hook];
+
+	list_for_each_entry_rcu(elem, head, list) {
+		struct nf_hook_ops *next;
+
+		next = list_entry_rcu(list_next_rcu(&elem->list),
+				      struct nf_hook_ops, list);
+		if (next->priority <= NF_BR_PRI_BRNF)
+			continue;
+	}
+
+	if (&elem->list == head)
+		return okfn(net, sk, skb);
+
+	nf_hook_state_init(&state, head, hook, NF_BR_PRI_BRNF + 1,
+			   NFPROTO_BRIDGE, indev, outdev, sk, net, okfn);
+
+	ret = nf_hook_slow(skb, &state);
+	if (ret == 1)
+		ret = okfn(net, sk, skb);
+
+	return ret;
+}
+
 #ifdef CONFIG_SYSCTL
 static
 int brnf_sysctl_call_tables(struct ctl_table *ctl, int write,
diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 5e59a84..5989661 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -187,10 +187,9 @@ static int br_nf_pre_routing_finish_ipv6(struct net *net, struct sock *sk, struc
 			skb->dev = nf_bridge->physindev;
 			nf_bridge_update_protocol(skb);
 			nf_bridge_push_encap_header(skb);
-			NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING,
-				       net, sk, skb, skb->dev, NULL,
-				       br_nf_pre_routing_finish_bridge,
-				       1);
+			br_nf_hook_thresh(NF_BR_PRE_ROUTING,
+					  net, sk, skb, skb->dev, NULL,
+					  br_nf_pre_routing_finish_bridge);
 			return 0;
 		}
 		ether_addr_copy(eth_hdr(skb)->h_dest, dev->dev_addr);
@@ -207,9 +206,8 @@ static int br_nf_pre_routing_finish_ipv6(struct net *net, struct sock *sk, struc
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, net, sk, skb,
-		       skb->dev, NULL,
-		       br_handle_frame_finish, 1);
+	br_nf_hook_thresh(NF_BR_PRE_ROUTING, net, sk, skb,
+			  skb->dev, NULL, br_handle_frame_finish);
 
 	return 0;
 }
-- 
2.5.5

