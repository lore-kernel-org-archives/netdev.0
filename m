From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/04: xt_cluster: fix use of cluster match with 32 nodes
Date: Tue,  5 May 2009 18:47:46 +0200 (MEST)
Message-ID: <20090505164746.19290.81233.sendpatchset@x2.localnet>
References: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090505164742.19290.7829.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 280f37afa2c270ff029cb420b34396aa002909c3
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Tue May 5 17:46:07 2009 +0200

    netfilter: xt_cluster: fix use of cluster match with 32 nodes
    
    This patch fixes a problem when you use 32 nodes in the cluster
    match:
    
    % iptables -I PREROUTING -t mangle -i eth0 -m cluster \
      --cluster-total-nodes  32  --cluster-local-node  32 \
      --cluster-hash-seed 0xdeadbeef -j MARK --set-mark 0xffff
    iptables: Invalid argument. Run `dmesg' for more information.
    % dmesg | tail -1
    xt_cluster: this node mask cannot be higher than the total number of nodes
    
    The problem is related to this checking:
    
    if (info->node_mask >= (1 << info->total_nodes)) {
    	printk(KERN_ERR "xt_cluster: this node mask cannot be "
    			"higher than the total number of nodes\n");
    	return false;
    }
    
    (1 << 32) is 1. Thus, the checking fails.
    
    BTW, I said this before but I insist: I have only tested the cluster
    match with 2 nodes getting ~45% extra performance in an active-active setup.
    The maximum limit of 32 nodes is still completely arbitrary. I'd really
    appreciate if people that have more nodes in their setups let me know.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/xt_cluster.h b/include/linux/netfilter/xt_cluster.h
index 5e0a0d0..8866826 100644
--- a/include/linux/netfilter/xt_cluster.h
+++ b/include/linux/netfilter/xt_cluster.h
@@ -12,4 +12,6 @@ struct xt_cluster_match_info {
 	u_int32_t		flags;
 };
 
+#define XT_CLUSTER_NODES_MAX	32
+
 #endif /* _XT_CLUSTER_MATCH_H */
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
index 6c48476..69a639f 100644
--- a/net/netfilter/xt_cluster.c
+++ b/net/netfilter/xt_cluster.c
@@ -135,7 +135,13 @@ static bool xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
 {
 	struct xt_cluster_match_info *info = par->matchinfo;
 
-	if (info->node_mask >= (1 << info->total_nodes)) {
+	if (info->total_nodes > XT_CLUSTER_NODES_MAX) {
+		printk(KERN_ERR "xt_cluster: you have exceeded the maximum "
+				"number of cluster nodes (%u > %u)\n",
+				info->total_nodes, XT_CLUSTER_NODES_MAX);
+		return false;
+	}
+	if (info->node_mask >= (1ULL << info->total_nodes)) {
 		printk(KERN_ERR "xt_cluster: this node mask cannot be "
 				"higher than the total number of nodes\n");
 		return false;
