From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 2/2] netfilter: bridge: use rcu hook to resolve br_netfilter dependency
Date: Tue, 10 Mar 2015 16:46:21 +0100
Message-ID: <1426002381-20302-3-git-send-email-pablo@netfilter.org>
References: <1426002381-20302-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37557 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932095AbbCJPmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 11:42:42 -0400
In-Reply-To: <1426002381-20302-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e5de75b ("netfilter: bridge: move DNAT helper to br_netfilter") results
in the following link problem:

net/bridge/br_device.c:29: undefined reference to `br_nf_prerouting_finish_bridge`

Moreover it creates a hard dependency between br_netfilter and the
bridge core, which is what we've been trying to avoid so far.

Resolve this problem by using a hook structure so we reduce #ifdef
pollution and keep bridge netfilter specific code under br_netfilter.c
which was the original intention.

Reported-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_device.c    |    7 ++++++-
 net/bridge/br_netfilter.c |    9 +++++++--
 net/bridge/br_private.h   |   10 +++++-----
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 294cbcc..4ff77a1 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -25,6 +25,9 @@
 #define COMMON_FEATURES (NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA | \
 			 NETIF_F_GSO_MASK | NETIF_F_HW_CSUM)
 
+const struct nf_br_ops __rcu *nf_br_ops __read_mostly;
+EXPORT_SYMBOL_GPL(nf_br_ops);
+
 /* net device transmit always called with BH disabled */
 netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -33,10 +36,12 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct net_bridge_fdb_entry *dst;
 	struct net_bridge_mdb_entry *mdst;
 	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
+	const struct nf_br_ops *nf_ops;
 	u16 vid = 0;
 
 	rcu_read_lock();
-	if (br_nf_prerouting_finish_bridge(skb)) {
+	nf_ops = rcu_dereference(nf_br_ops);
+	if (nf_ops && nf_ops->br_dev_xmit_hook(skb)) {
 		rcu_read_unlock();
 		return NETDEV_TX_OK;
 	}
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index a8361c7..b260a97 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -914,7 +914,7 @@ static void br_nf_pre_routing_finish_bridge_slow(struct sk_buff *skb)
 	br_handle_frame_finish(skb);
 }
 
-int br_nf_prerouting_finish_bridge(struct sk_buff *skb)
+static int br_nf_dev_xmit(struct sk_buff *skb)
 {
 	if (skb->nf_bridge && (skb->nf_bridge->mask & BRNF_BRIDGED_DNAT)) {
 		br_nf_pre_routing_finish_bridge_slow(skb);
@@ -922,7 +922,10 @@ int br_nf_prerouting_finish_bridge(struct sk_buff *skb)
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(br_nf_prerouting_finish_bridge);
+
+static const struct nf_br_ops br_ops = {
+	.br_dev_xmit_hook =	br_nf_dev_xmit,
+};
 
 void br_netfilter_enable(void)
 {
@@ -1061,12 +1064,14 @@ static int __init br_netfilter_init(void)
 		return -ENOMEM;
 	}
 #endif
+	RCU_INIT_POINTER(nf_br_ops, &br_ops);
 	printk(KERN_NOTICE "Bridge firewalling registered\n");
 	return 0;
 }
 
 static void __exit br_netfilter_fini(void)
 {
+	RCU_INIT_POINTER(nf_br_ops, NULL);
 	nf_unregister_hooks(br_nf_ops, ARRAY_SIZE(br_nf_ops));
 #ifdef CONFIG_SYSCTL
 	unregister_net_sysctl_table(brnf_sysctl_header);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f0a0438..b46fa0c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -763,17 +763,17 @@ static inline int br_vlan_enabled(struct net_bridge *br)
 }
 #endif
 
+struct nf_br_ops {
+	int (*br_dev_xmit_hook)(struct sk_buff *skb);
+};
+extern const struct nf_br_ops __rcu *nf_br_ops;
+
 /* br_netfilter.c */
 #if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
-int br_nf_prerouting_finish_bridge(struct sk_buff *skb);
 int br_nf_core_init(void);
 void br_nf_core_fini(void);
 void br_netfilter_rtable_init(struct net_bridge *);
 #else
-static inline int br_nf_prerouting_finish_bridge(struct sk_buff *skb)
-{
-        return 0;
-}
 static inline int br_nf_core_init(void) { return 0; }
 static inline void br_nf_core_fini(void) {}
 #define br_netfilter_rtable_init(x)
-- 
1.7.10.4
