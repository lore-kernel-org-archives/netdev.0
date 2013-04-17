From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 14/14] nfnetlink: add support for memory mapped netlink
Date: Wed, 17 Apr 2013 18:47:09 +0200
Message-ID: <1366217229-22705-15-git-send-email-kaber@trash.net>
References: <1366217229-22705-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1366217229-22705-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink.h  |  2 ++
 net/netfilter/nfnetlink.c            |  7 +++++++
 net/netfilter/nfnetlink_log.c        | 10 ++++++----
 net/netfilter/nfnetlink_queue_core.c |  3 ++-
 4 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 60b1641..cadb740 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -29,6 +29,8 @@ extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
 extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
+extern struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
+					   u32 dst_portid, gfp_t gfp_mask);
 extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
 			  unsigned int group, int echo, gfp_t flags);
 extern int nfnetlink_set_err(struct net *net, u32 portid, u32 group, int error);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 1640bd7..572d87d 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -112,6 +112,13 @@ int nfnetlink_has_listeners(struct net *net, unsigned int group)
 }
 EXPORT_SYMBOL_GPL(nfnetlink_has_listeners);
 
+struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
+				    u32 dst_portid, gfp_t gfp_mask)
+{
+	return netlink_alloc_skb(net->nfnl, size, dst_portid, gfp_mask);
+}
+EXPORT_SYMBOL_GPL(nfnetlink_alloc_skb);
+
 int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 portid,
 		   unsigned int group, int echo, gfp_t flags)
 {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 50aaf71..d4199eb 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -318,7 +318,7 @@ nfulnl_set_flags(struct nfulnl_instance *inst, u_int16_t flags)
 }
 
 static struct sk_buff *
-nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
+nfulnl_alloc_skb(u32 peer_portid, unsigned int inst_size, unsigned int pkt_size)
 {
 	struct sk_buff *skb;
 	unsigned int n;
@@ -327,13 +327,14 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 	 * message.  WARNING: has to be <= 128k due to slab restrictions */
 
 	n = max(inst_size, pkt_size);
-	skb = alloc_skb(n, GFP_ATOMIC);
+	skb = nfnetlink_alloc_skb(&init_net, n, peer_portid, GFP_ATOMIC);
 	if (!skb) {
 		if (n > pkt_size) {
 			/* try to allocate only as much as we need for current
 			 * packet */
 
-			skb = alloc_skb(pkt_size, GFP_ATOMIC);
+			skb = nfnetlink_alloc_skb(&init_net, pkt_size,
+						  peer_portid, GFP_ATOMIC);
 			if (!skb)
 				pr_err("nfnetlink_log: can't even alloc %u bytes\n",
 				       pkt_size);
@@ -696,7 +697,8 @@ nfulnl_log_packet(u_int8_t pf,
 	}
 
 	if (!inst->skb) {
-		inst->skb = nfulnl_alloc_skb(inst->nlbufsiz, size);
+		inst->skb = nfulnl_alloc_skb(inst->peer_portid, inst->nlbufsiz,
+					     size);
 		if (!inst->skb)
 			goto alloc_failure;
 	}
diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 5e280b3..ef3cdb4 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -339,7 +339,8 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	if (queue->flags & NFQA_CFG_F_CONNTRACK)
 		ct = nfqnl_ct_get(entskb, &size, &ctinfo);
 
-	skb = alloc_skb(size, GFP_ATOMIC);
+	skb = nfnetlink_alloc_skb(&init_net, size, queue->peer_portid,
+				  GFP_ATOMIC);
 	if (!skb)
 		return NULL;
 
-- 
1.8.1.4

