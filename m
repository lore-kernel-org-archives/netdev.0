From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] net: dev: reduce both ingress hook ifdefs
Date: Tue, 19 May 2015 22:33:25 +0200
Message-ID: <3898d6056534c7fc4d43a9e6d27488bffb72b657.1432067241.git.daniel@iogearbox.net>
Cc: pablo@netfilter.org, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45888 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751117AbbESUd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:33:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce ifdef pollution slightly, no functional change. We can simply
remove the extra alternative definition of handle_ing() and nf_ingress().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/dev.c | 22 ++++------------------
 1 file changed, 4 insertions(+), 18 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 0e7afef..594163d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3627,11 +3627,11 @@ int (*br_fdb_test_addr_hook)(struct net_device *dev,
 EXPORT_SYMBOL_GPL(br_fdb_test_addr_hook);
 #endif
 
-#ifdef CONFIG_NET_CLS_ACT
 static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 					 struct packet_type **pt_prev,
 					 int *ret, struct net_device *orig_dev)
 {
+#ifdef CONFIG_NET_CLS_ACT
 	struct tcf_proto *cl = rcu_dereference_bh(skb->dev->ingress_cl_list);
 	struct tcf_result cl_res;
 
@@ -3665,17 +3665,9 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	default:
 		break;
 	}
-
-	return skb;
-}
-#else
-static inline struct sk_buff *handle_ing(struct sk_buff *skb,
-					 struct packet_type **pt_prev,
-					 int *ret, struct net_device *orig_dev)
-{
+#endif /* CONFIG_NET_CLS_ACT */
 	return skb;
 }
-#endif
 
 /**
  *	netdev_rx_handler_register - register receive handler
@@ -3748,10 +3740,10 @@ static bool skb_pfmemalloc_protocol(struct sk_buff *skb)
 	}
 }
 
-#ifdef CONFIG_NETFILTER_INGRESS
 static inline int nf_ingress(struct sk_buff *skb, struct packet_type **pt_prev,
 			     int *ret, struct net_device *orig_dev)
 {
+#ifdef CONFIG_NETFILTER_INGRESS
 	if (nf_hook_ingress_active(skb)) {
 		if (*pt_prev) {
 			*ret = deliver_skb(skb, *pt_prev, orig_dev);
@@ -3760,15 +3752,9 @@ static inline int nf_ingress(struct sk_buff *skb, struct packet_type **pt_prev,
 
 		return nf_hook_ingress(skb);
 	}
+#endif /* CONFIG_NETFILTER_INGRESS */
 	return 0;
 }
-#else
-static inline int nf_ingress(struct sk_buff *skb, struct packet_type **pt_prev,
-			     int *ret, struct net_device *orig_dev)
-{
-	return 0;
-}
-#endif
 
 static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 {
-- 
1.9.3
