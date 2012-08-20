From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 09/11] nfnetlink: add support for memory mapped netlink
Date: Mon, 20 Aug 2012 08:18:50 +0200
Message-ID: <1345443532-3707-10-git-send-email-kaber@trash.net>
References: <1345443532-3707-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian.Westphal@Sophos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36031 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839Ab2HTGS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2012 02:18:59 -0400
In-Reply-To: <1345443532-3707-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink.h  |    2 ++
 net/netfilter/nfnetlink.c            |    7 +++++++
 net/netfilter/nfnetlink_log.c        |    9 +++++----
 net/netfilter/nfnetlink_queue_core.c |    2 +-
 4 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 18341cd..447d1a7 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -81,6 +81,8 @@ extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
 extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
+extern struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
+					   u32 dst_pid, gfp_t gfp_mask);
 extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned int group,
 			  int echo, gfp_t flags);
 extern int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index a265033..d0aa9fc 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -111,6 +111,13 @@ int nfnetlink_has_listeners(struct net *net, unsigned int group)
 }
 EXPORT_SYMBOL_GPL(nfnetlink_has_listeners);
 
+struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
+				    u32 dst_pid, gfp_t gfp_mask)
+{
+	return netlink_alloc_skb(net->nfnl, size, dst_pid, gfp_mask);
+}
+EXPORT_SYMBOL_GPL(nfnetlink_alloc_skb);
+
 int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid,
 		   unsigned int group, int echo, gfp_t flags)
 {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 169ab59..6232ca8 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -296,7 +296,7 @@ nfulnl_set_flags(struct nfulnl_instance *inst, u_int16_t flags)
 }
 
 static struct sk_buff *
-nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
+nfulnl_alloc_skb(u32 peer_pid, unsigned int inst_size, unsigned int pkt_size)
 {
 	struct sk_buff *skb;
 	unsigned int n;
@@ -305,13 +305,14 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 	 * message.  WARNING: has to be <= 128k due to slab restrictions */
 
 	n = max(inst_size, pkt_size);
-	skb = alloc_skb(n, GFP_ATOMIC);
+	skb = nfnetlink_alloc_skb(&init_net, n, peer_pid, GFP_ATOMIC);
 	if (!skb) {
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
 			 * packet */
 
-			skb = alloc_skb(pkt_size, GFP_ATOMIC);
+			skb = nfnetlink_alloc_skb(&init_net, pkt_size, peer_pid,
+						  GFP_ATOMIC);
 			if (!skb)
 				pr_err("nfnetlink_log: can't even alloc %u bytes\n",
 				       pkt_size);
@@ -658,7 +659,7 @@ nfulnl_log_packet(u_int8_t pf,
 	}
 
 	if (!inst->skb) {
-		inst->skb = nfulnl_alloc_skb(inst->nlbufsiz, size);
+		inst->skb = nfulnl_alloc_skb(inst->peer_pid, inst->nlbufsiz, size);
 		if (!inst->skb)
 			goto alloc_failure;
 	}
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index c0496a5..6983b2e 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -272,7 +272,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (queue->flags & NFQA_CFG_F_CONNTRACK)
 		ct = nfqnl_ct_get(entskb, &size, &ctinfo);
 
-	skb = alloc_skb(size, GFP_ATOMIC);
+	skb = nfnetlink_alloc_skb(&init_net, size, queue->peer_pid, GFP_ATOMIC);
 	if (!skb)
 		return NULL;
 
-- 
1.7.7.6
