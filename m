From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 10/34] netfilter: ipset: Add skbinfo extension support to SET target.
Date: Mon, 29 Sep 2014 14:38:59 +0200
Message-ID: <1411994363-8451-11-git-send-email-pablo@netfilter.org>
References: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1411994363-8451-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Anton Danilov <littlesmilingcloud@gmail.com>

Signed-off-by: Anton Danilov <littlesmilingcloud@gmail.com>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 include/uapi/linux/netfilter/xt_set.h |   10 +++
 net/netfilter/xt_set.c                |  155 +++++++++++++++++++++++++++++++++
 2 files changed, 165 insertions(+)

diff --git a/include/uapi/linux/netfilter/xt_set.h b/include/uapi/linux/netfilter/xt_set.h
index 964d3d4..d6a1df1 100644
--- a/include/uapi/linux/netfilter/xt_set.h
+++ b/include/uapi/linux/netfilter/xt_set.h
@@ -71,4 +71,14 @@ struct xt_set_info_match_v3 {
 	__u32 flags;
 };
 
+/* Revision 3 target */
+
+struct xt_set_info_target_v3 {
+	struct xt_set_info add_set;
+	struct xt_set_info del_set;
+	struct xt_set_info map_set;
+	__u32 flags;
+	__u32 timeout;
+};
+
 #endif /*_XT_SET_H*/
diff --git a/net/netfilter/xt_set.c b/net/netfilter/xt_set.c
index cb70f6e..5732cd6 100644
--- a/net/netfilter/xt_set.c
+++ b/net/netfilter/xt_set.c
@@ -366,6 +366,140 @@ set_target_v2(struct sk_buff *skb, const struct xt_action_param *par)
 #define set_target_v2_checkentry	set_target_v1_checkentry
 #define set_target_v2_destroy		set_target_v1_destroy
 
+/* Revision 3 target */
+
+static unsigned int
+set_target_v3(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct xt_set_info_target_v3 *info = par->targinfo;
+	ADT_OPT(add_opt, par->family, info->add_set.dim,
+		info->add_set.flags, info->flags, info->timeout);
+	ADT_OPT(del_opt, par->family, info->del_set.dim,
+		info->del_set.flags, 0, UINT_MAX);
+	ADT_OPT(map_opt, par->family, info->map_set.dim,
+		info->map_set.flags, 0, UINT_MAX);
+
+	int ret;
+
+	/* Normalize to fit into jiffies */
+	if (add_opt.ext.timeout != IPSET_NO_TIMEOUT &&
+	    add_opt.ext.timeout > UINT_MAX/MSEC_PER_SEC)
+		add_opt.ext.timeout = UINT_MAX/MSEC_PER_SEC;
+	if (info->add_set.index != IPSET_INVALID_ID)
+		ip_set_add(info->add_set.index, skb, par, &add_opt);
+	if (info->del_set.index != IPSET_INVALID_ID)
+		ip_set_del(info->del_set.index, skb, par, &del_opt);
+	if (info->map_set.index != IPSET_INVALID_ID) {
+		map_opt.cmdflags |= info->flags & (IPSET_FLAG_MAP_SKBMARK |
+						   IPSET_FLAG_MAP_SKBPRIO |
+						   IPSET_FLAG_MAP_SKBQUEUE);
+		ret = match_set(info->map_set.index, skb, par, &map_opt,
+				info->map_set.flags & IPSET_INV_MATCH);
+		if (!ret)
+			return XT_CONTINUE;
+		if (map_opt.cmdflags & IPSET_FLAG_MAP_SKBMARK)
+			skb->mark = (skb->mark & ~(map_opt.ext.skbmarkmask))
+				    ^ (map_opt.ext.skbmark);
+		if (map_opt.cmdflags & IPSET_FLAG_MAP_SKBPRIO)
+			skb->priority = map_opt.ext.skbprio;
+		if ((map_opt.cmdflags & IPSET_FLAG_MAP_SKBQUEUE) &&
+		    skb->dev &&
+		    skb->dev->real_num_tx_queues > map_opt.ext.skbqueue)
+			skb_set_queue_mapping(skb, map_opt.ext.skbqueue);
+	}
+	return XT_CONTINUE;
+}
+
+
+static int
+set_target_v3_checkentry(const struct xt_tgchk_param *par)
+{
+	const struct xt_set_info_target_v3 *info = par->targinfo;
+	ip_set_id_t index;
+
+	if (info->add_set.index != IPSET_INVALID_ID) {
+		index = ip_set_nfnl_get_byindex(par->net,
+						info->add_set.index);
+		if (index == IPSET_INVALID_ID) {
+			pr_warn("Cannot find add_set index %u as target\n",
+				info->add_set.index);
+			return -ENOENT;
+		}
+	}
+
+	if (info->del_set.index != IPSET_INVALID_ID) {
+		index = ip_set_nfnl_get_byindex(par->net,
+						info->del_set.index);
+		if (index == IPSET_INVALID_ID) {
+			pr_warn("Cannot find del_set index %u as target\n",
+				info->del_set.index);
+			if (info->add_set.index != IPSET_INVALID_ID)
+				ip_set_nfnl_put(par->net,
+						info->add_set.index);
+			return -ENOENT;
+		}
+	}
+
+	if (info->map_set.index != IPSET_INVALID_ID) {
+		if (strncmp(par->table, "mangle", 7)) {
+			pr_warn("--map-set only usable from mangle table\n");
+			return -EINVAL;
+		}
+		if (((info->flags & IPSET_FLAG_MAP_SKBPRIO) |
+		     (info->flags & IPSET_FLAG_MAP_SKBQUEUE)) &&
+		     !(par->hook_mask & (1 << NF_INET_FORWARD |
+					 1 << NF_INET_LOCAL_OUT |
+					 1 << NF_INET_POST_ROUTING))) {
+			pr_warn("mapping of prio or/and queue is allowed only"
+				"from OUTPUT/FORWARD/POSTROUTING chains\n");
+			return -EINVAL;
+		}
+		index = ip_set_nfnl_get_byindex(par->net,
+						info->map_set.index);
+		if (index == IPSET_INVALID_ID) {
+			pr_warn("Cannot find map_set index %u as target\n",
+				info->map_set.index);
+			if (info->add_set.index != IPSET_INVALID_ID)
+				ip_set_nfnl_put(par->net,
+						info->add_set.index);
+			if (info->del_set.index != IPSET_INVALID_ID)
+				ip_set_nfnl_put(par->net,
+						info->del_set.index);
+			return -ENOENT;
+		}
+	}
+
+	if (info->add_set.dim > IPSET_DIM_MAX ||
+	    info->del_set.dim > IPSET_DIM_MAX ||
+	    info->map_set.dim > IPSET_DIM_MAX) {
+		pr_warn("Protocol error: SET target dimension "
+			"is over the limit!\n");
+		if (info->add_set.index != IPSET_INVALID_ID)
+			ip_set_nfnl_put(par->net, info->add_set.index);
+		if (info->del_set.index != IPSET_INVALID_ID)
+			ip_set_nfnl_put(par->net, info->del_set.index);
+		if (info->map_set.index != IPSET_INVALID_ID)
+			ip_set_nfnl_put(par->net, info->map_set.index);
+		return -ERANGE;
+	}
+
+	return 0;
+}
+
+static void
+set_target_v3_destroy(const struct xt_tgdtor_param *par)
+{
+	const struct xt_set_info_target_v3 *info = par->targinfo;
+
+	if (info->add_set.index != IPSET_INVALID_ID)
+		ip_set_nfnl_put(par->net, info->add_set.index);
+	if (info->del_set.index != IPSET_INVALID_ID)
+		ip_set_nfnl_put(par->net, info->del_set.index);
+	if (info->map_set.index != IPSET_INVALID_ID)
+		ip_set_nfnl_put(par->net, info->map_set.index);
+}
+
+
 static struct xt_match set_matches[] __read_mostly = {
 	{
 		.name		= "set",
@@ -493,6 +627,27 @@ static struct xt_target set_targets[] __read_mostly = {
 		.destroy	= set_target_v2_destroy,
 		.me		= THIS_MODULE
 	},
+	/* --map-set support */
+	{
+		.name		= "SET",
+		.revision	= 3,
+		.family		= NFPROTO_IPV4,
+		.target		= set_target_v3,
+		.targetsize	= sizeof(struct xt_set_info_target_v3),
+		.checkentry	= set_target_v3_checkentry,
+		.destroy	= set_target_v3_destroy,
+		.me		= THIS_MODULE
+	},
+	{
+		.name		= "SET",
+		.revision	= 3,
+		.family		= NFPROTO_IPV6,
+		.target		= set_target_v3,
+		.targetsize	= sizeof(struct xt_set_info_target_v3),
+		.checkentry	= set_target_v3_checkentry,
+		.destroy	= set_target_v3_destroy,
+		.me		= THIS_MODULE
+	},
 };
 
 static int __init xt_set_init(void)
-- 
1.7.10.4

