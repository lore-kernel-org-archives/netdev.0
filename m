From: kaber@trash.net
Subject: [PATCH 11/11] nfnetlink: add support for memory mapped netlink
Date: Sat,  3 Sep 2011 19:26:11 +0200
Message-ID: <1315070771-18576-12-git-send-email-kaber@trash.net>
References: <1315070771-18576-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1315070771-18576-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink.h |    2 ++
 net/netfilter/nfnetlink.c           |    7 +++++++
 net/netfilter/nfnetlink_log.c       |    9 +++++----
 net/netfilter/nfnetlink_queue.c     |    2 +-
 4 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink.h b/include/linux/netfilter/nfnetlink.h
index 74d3386..07b48cf 100644
--- a/include/linux/netfilter/nfnetlink.h
+++ b/include/linux/netfilter/nfnetlink.h
@@ -78,6 +78,8 @@ extern int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n);
 extern int nfnetlink_subsys_unregister(const struct nfnetlink_subsystem *n);
 
 extern int nfnetlink_has_listeners(struct net *net, unsigned int group);
+extern struct sk_buff *nfnetlink_alloc_skb(struct net *net, unsigned int size,
+					   u32 dst_pid, gfp_t gfp_mask);
 extern int nfnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, unsigned group,
 			  int echo, gfp_t flags);
 extern int nfnetlink_set_err(struct net *net, u32 pid, u32 group, int error);
diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index 1905976..de0d9b3 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -103,6 +103,13 @@ int nfnetlink_has_listeners(struct net *net, unsigned int group)
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
 		   unsigned group, int echo, gfp_t flags)
 {
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 2d8158a..c37fb0c 100644
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
@@ -305,7 +305,7 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 	 * message.  WARNING: has to be <= 128k due to slab restrictions */
 
 	n = max(inst_size, pkt_size);
-	skb = alloc_skb(n, GFP_ATOMIC);
+	skb = nfnetlink_alloc_skb(&init_net, n, peer_pid, GFP_ATOMIC);
 	if (!skb) {
 		pr_notice("nfnetlink_log: can't alloc whole buffer (%u bytes)\n",
 			inst_size);
@@ -314,7 +314,8 @@ nfulnl_alloc_skb(unsigned int inst_size, unsigned int pkt_size)
 			/* try to allocate only as much as we need for current
 			 * packet */
 
-			skb = alloc_skb(pkt_size, GFP_ATOMIC);
+			skb = nfnetlink_alloc_skb(&init_net, pkt_size, peer_pid,
+						  GFP_ATOMIC);
 			if (!skb)
 				pr_err("nfnetlink_log: can't even alloc %u "
 				       "bytes\n", pkt_size);
@@ -642,7 +643,7 @@ nfulnl_log_packet(u_int8_t pf,
 	}
 
 	if (!inst->skb) {
-		inst->skb = nfulnl_alloc_skb(inst->nlbufsiz, size);
+		inst->skb = nfulnl_alloc_skb(inst->peer_pid, inst->nlbufsiz, size);
 		if (!inst->skb)
 			goto alloc_failure;
 	}
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queue.c
index 00bd475..2bb29a3 100644
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -266,7 +266,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	}
 
 
-	skb = alloc_skb(size, GFP_ATOMIC);
+	skb = nfnetlink_alloc_skb(&init_net, size, queue->peer_pid, GFP_ATOMIC);
 	if (!skb)
 		goto nlmsg_failure;
 
-- 
1.7.4.4

