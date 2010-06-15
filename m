From: kaber@trash.net
Subject: [PATCH 12/17] netfilter: nfnetlink_log: RCU conversion, part 2
Date: Tue, 15 Jun 2010 17:38:38 +0200
Message-ID: <1276616323-20880-13-git-send-email-kaber@trash.net>
References: <1276616323-20880-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1276616323-20880-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>

- must use atomic_inc_not_zero() in instance_lookup_get()

- must use hlist_add_head_rcu() instead of hlist_add_head()

- must use hlist_del_rcu() instead of hlist_del()

- Introduce NFULNL_COPY_DISABLED to stop lockless reader from using an
instance, before we do final instance_put() on it.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter/nfnetlink_log.h |    1 +
 net/netfilter/nfnetlink_log.c           |   18 ++++++++++++------
 2 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_log.h b/include/linux/netfilter/nfnetlink_log.h
index d3bab7a..1d0b84a 100644
--- a/include/linux/netfilter/nfnetlink_log.h
+++ b/include/linux/netfilter/nfnetlink_log.h
@@ -89,6 +89,7 @@ enum nfulnl_attr_config {
 #define NFULNL_COPY_NONE	0x00
 #define NFULNL_COPY_META	0x01
 #define NFULNL_COPY_PACKET	0x02
+#define NFULNL_COPY_DISABLED	0x03
 
 #define NFULNL_CFG_F_SEQ	0x0001
 #define NFULNL_CFG_F_SEQ_GLOBAL	0x0002
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index 8ec23ec..fb86a51 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -109,8 +109,8 @@ instance_lookup_get(u_int16_t group_num)
 
 	rcu_read_lock_bh();
 	inst = __instance_lookup(group_num);
-	if (inst)
-		instance_get(inst);
+	if (inst && !atomic_inc_not_zero(&inst->use))
+		inst = NULL;
 	rcu_read_unlock_bh();
 
 	return inst;
@@ -171,7 +171,7 @@ instance_create(u_int16_t group_num, int pid)
 	inst->copy_mode 	= NFULNL_COPY_PACKET;
 	inst->copy_range 	= NFULNL_COPY_RANGE_MAX;
 
-	hlist_add_head(&inst->hlist,
+	hlist_add_head_rcu(&inst->hlist,
 		       &instance_table[instance_hashfn(group_num)]);
 
 	spin_unlock_bh(&instances_lock);
@@ -185,18 +185,23 @@ out_unlock:
 
 static void __nfulnl_flush(struct nfulnl_instance *inst);
 
+/* called with BH disabled */
 static void
 __instance_destroy(struct nfulnl_instance *inst)
 {
 	/* first pull it out of the global list */
-	hlist_del(&inst->hlist);
+	hlist_del_rcu(&inst->hlist);
 
 	/* then flush all pending packets from skb */
 
-	spin_lock_bh(&inst->lock);
+	spin_lock(&inst->lock);
+
+	/* lockless readers wont be able to use us */
+	inst->copy_mode = NFULNL_COPY_DISABLED;
+
 	if (inst->skb)
 		__nfulnl_flush(inst);
-	spin_unlock_bh(&inst->lock);
+	spin_unlock(&inst->lock);
 
 	/* and finally put the refcount */
 	instance_put(inst);
@@ -624,6 +629,7 @@ nfulnl_log_packet(u_int8_t pf,
 		size += nla_total_size(data_len);
 		break;
 
+	case NFULNL_COPY_DISABLED:
 	default:
 		goto unlock_and_release;
 	}
-- 
1.7.0.4

