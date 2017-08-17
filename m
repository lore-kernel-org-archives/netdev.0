From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [RFC PATCH v2 1/6] [net-next]net: sched: act_mirred: Extend
 redirect action to accept a traffic class
Date: Thu, 17 Aug 2017 03:26:50 -0700
Message-ID: <150296561068.16910.8958234153804004329.stgit@anamdev.jf.intel.com>
References: <150296538797.16910.13738130623106637990.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, kiran.patil@intel.com,
        amritha.nambiar@intel.com, netdev@vger.kernel.org,
        mitch.a.williams@intel.com, alexander.duyck@gmail.com,
        neerav.parikh@intel.com, sridhar.samudrala@intel.com,
        carolyn.wyborny@intel.com
To: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:40640 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752092AbdHQK1m (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Aug 2017 06:27:42 -0400
In-Reply-To: <150296538797.16910.13738130623106637990.stgit@anamdev.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Mirred/redirect action is extended to forward to a traffic
class on the device. The traffic class index needs to be
provided in addition to the device's ifindex.

Example:
# tc filter add dev eth0 protocol ip parent ffff: prio 1 flower\
  dst_ip 192.168.1.1/32 ip_proto udp dst_port 22\
  skip_sw action mirred ingress redirect dev eth0 tclass 1

v2: Introduced is_tcf_mirred_tc() helper function to check if
the rule is supported in current offloaders. Removed the
additional definitions for max number of TCs and its bitmask
and replaced their usages with existing defines in linux/netdevice.h.

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |    3 ++-
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |    3 ++-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   |    1 +
 drivers/net/ethernet/netronome/nfp/flower/action.c |    4 ++--
 include/net/tc_act/tc_mirred.h                     |   16 ++++++++++++++++
 include/uapi/linux/tc_act/tc_mirred.h              |    3 +++
 net/dsa/slave.c                                    |    3 ++-
 net/sched/act_mirred.c                             |   15 +++++++++++++++
 11 files changed, 46 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
index 48970ba..54a7004 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
@@ -113,7 +113,7 @@ static int fill_action_fields(struct adapter *adap,
 		}
 
 		/* Re-direct to specified port in hardware. */
-		if (is_tcf_mirred_egress_redirect(a)) {
+		if (is_tcf_mirred_egress_redirect(a) && !is_tcf_mirred_tc(a)) {
 			struct net_device *n_dev;
 			unsigned int i, index;
 			bool found = false;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 5d674f9..5b67cf0 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8995,7 +8995,7 @@ static int parse_tc_actions(struct ixgbe_adapter *adapter,
 		}
 
 		/* Redirect to a VF or a offloaded macvlan */
-		if (is_tcf_mirred_egress_redirect(a)) {
+		if (is_tcf_mirred_egress_redirect(a) && !is_tcf_mirred_tc(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 
 			err = handle_redirect_action(adapter, ifindex, queue,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
index 3b10d3d..eae02f8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tc.c
@@ -1871,7 +1871,7 @@ static int parse_tc_fdb_actions(struct mlx5e_priv *priv, struct tcf_exts *exts,
 			return -EOPNOTSUPP;
 		}
 
-		if (is_tcf_mirred_egress_redirect(a)) {
+		if (is_tcf_mirred_egress_redirect(a) && !is_tcf_mirred_tc(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev, *encap_dev = NULL;
 			struct mlx5e_priv *out_priv;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 90a95cd..ce0b114 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1639,7 +1639,8 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 	tcf_exts_to_list(f->exts, &actions);
 	a = list_first_entry(&actions, struct tc_action, list);
 
-	if (is_tcf_mirred_egress_mirror(a) && protocol == htons(ETH_P_ALL)) {
+	if (is_tcf_mirred_egress_mirror(a) && !is_tcf_mirred_tc(a) &&
+	    protocol == htons(ETH_P_ALL)) {
 		struct mlxsw_sp_port_mall_mirror_tc_entry *mirror;
 
 		mall_tc_entry->type = MLXSW_SP_PORT_MALL_MIRROR;
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
index 95428b4..8ed3a0a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_flower.c
@@ -71,7 +71,8 @@ static int mlxsw_sp_flower_parse_actions(struct mlxsw_sp *mlxsw_sp,
 			err = mlxsw_sp_acl_rulei_act_trap(rulei);
 			if (err)
 				return err;
-		} else if (is_tcf_mirred_egress_redirect(a)) {
+		} else if (is_tcf_mirred_egress_redirect(a) &&
+			   !is_tcf_mirred_tc(a)) {
 			int ifindex = tcf_mirred_ifindex(a);
 			struct net_device *out_dev;
 			struct mlxsw_sp_fid *fid;
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index a88bb5b..3b00d4b 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -131,6 +131,7 @@ nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 			return NN_ACT_TC_DROP;
 
 		if (is_tcf_mirred_egress_redirect(a) &&
+		    !is_tcf_mirred_tc(a) &&
 		    tcf_mirred_ifindex(a) == nn->dp.netdev->ifindex)
 			return NN_ACT_TC_REDIR;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/flower/action.c b/drivers/net/ethernet/netronome/nfp/flower/action.c
index db97506..7ceeaa9 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/action.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/action.c
@@ -132,7 +132,7 @@ nfp_flower_loop_action(const struct tc_action *a,
 
 	if (is_tcf_gact_shot(a)) {
 		nfp_fl->meta.shortcut = cpu_to_be32(NFP_FL_SC_ACT_DROP);
-	} else if (is_tcf_mirred_egress_redirect(a)) {
+	} else if (is_tcf_mirred_egress_redirect(a) && !is_tcf_mirred_tc(a)) {
 		if (*a_len + sizeof(struct nfp_fl_output) > NFP_FL_MAX_A_SIZ)
 			return -EOPNOTSUPP;
 
@@ -142,7 +142,7 @@ nfp_flower_loop_action(const struct tc_action *a,
 			return err;
 
 		*a_len += sizeof(struct nfp_fl_output);
-	} else if (is_tcf_mirred_egress_mirror(a)) {
+	} else if (is_tcf_mirred_egress_mirror(a) && !is_tcf_mirred_tc(a)) {
 		if (*a_len + sizeof(struct nfp_fl_output) > NFP_FL_MAX_A_SIZ)
 			return -EOPNOTSUPP;
 
diff --git a/include/net/tc_act/tc_mirred.h b/include/net/tc_act/tc_mirred.h
index 604bc31..59cb935 100644
--- a/include/net/tc_act/tc_mirred.h
+++ b/include/net/tc_act/tc_mirred.h
@@ -9,6 +9,8 @@ struct tcf_mirred {
 	int			tcfm_eaction;
 	int			tcfm_ifindex;
 	bool			tcfm_mac_header_xmit;
+	u8			tcfm_tc;
+	u32			flags;
 	struct net_device __rcu	*tcfm_dev;
 	struct list_head	tcfm_list;
 };
@@ -37,4 +39,18 @@ static inline int tcf_mirred_ifindex(const struct tc_action *a)
 	return to_mirred(a)->tcfm_ifindex;
 }
 
+static inline bool is_tcf_mirred_tc(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	if (a->ops && a->ops->type == TCA_ACT_MIRRED)
+		return to_mirred(a)->flags == MIRRED_F_TCLASS;
+#endif
+	return false;
+}
+
+static inline u8 tcf_mirred_tc(const struct tc_action *a)
+{
+	return to_mirred(a)->tcfm_tc;
+}
+
 #endif /* __NET_TC_MIR_H */
diff --git a/include/uapi/linux/tc_act/tc_mirred.h b/include/uapi/linux/tc_act/tc_mirred.h
index 3d7a2b3..ea06a47 100644
--- a/include/uapi/linux/tc_act/tc_mirred.h
+++ b/include/uapi/linux/tc_act/tc_mirred.h
@@ -9,6 +9,8 @@
 #define TCA_EGRESS_MIRROR 2 /* mirror packet to EGRESS */
 #define TCA_INGRESS_REDIR 3  /* packet redirect to INGRESS*/
 #define TCA_INGRESS_MIRROR 4 /* mirror packet to INGRESS */
+
+#define MIRRED_F_TCLASS	0x1
                                                                                 
 struct tc_mirred {
 	tc_gen;
@@ -21,6 +23,7 @@ enum {
 	TCA_MIRRED_TM,
 	TCA_MIRRED_PARMS,
 	TCA_MIRRED_PAD,
+	TCA_MIRRED_TCLASS,
 	__TCA_MIRRED_MAX
 };
 #define TCA_MIRRED_MAX (__TCA_MIRRED_MAX - 1)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 78e78a6..b056499 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -846,7 +846,8 @@ static int dsa_slave_add_cls_matchall(struct net_device *dev,
 	tcf_exts_to_list(cls->exts, &actions);
 	a = list_first_entry(&actions, struct tc_action, list);
 
-	if (is_tcf_mirred_egress_mirror(a) && protocol == htons(ETH_P_ALL)) {
+	if (is_tcf_mirred_egress_mirror(a) && !is_tcf_mirred_tc(a) &&
+	    protocol == htons(ETH_P_ALL)) {
 		struct dsa_mall_mirror_tc_entry *mirror;
 
 		ifindex = tcf_mirred_ifindex(a);
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 1b5549a..43b8896 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -67,6 +67,7 @@ static void tcf_mirred_release(struct tc_action *a, int bind)
 
 static const struct nla_policy mirred_policy[TCA_MIRRED_MAX + 1] = {
 	[TCA_MIRRED_PARMS]	= { .len = sizeof(struct tc_mirred) },
+	[TCA_MIRRED_TCLASS]	= { .type = NLA_U8 },
 };
 
 static unsigned int mirred_net_id;
@@ -83,6 +84,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	struct tcf_mirred *m;
 	struct net_device *dev;
 	bool exists = false;
+	u8 *tclass = NULL;
+	u32 flags = 0;
 	int ret;
 
 	if (nla == NULL)
@@ -92,6 +95,12 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		return ret;
 	if (tb[TCA_MIRRED_PARMS] == NULL)
 		return -EINVAL;
+	if (tb[TCA_MIRRED_TCLASS]) {
+		tclass = nla_data(tb[TCA_MIRRED_TCLASS]);
+		if (*tclass >= TC_MAX_QUEUE)
+			return -EINVAL;
+		flags |= MIRRED_F_TCLASS;
+	}
 	parm = nla_data(tb[TCA_MIRRED_PARMS]);
 
 	exists = tcf_hash_check(tn, parm->index, a, bind);
@@ -139,6 +148,7 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 	ASSERT_RTNL();
 	m->tcf_action = parm->action;
 	m->tcfm_eaction = parm->eaction;
+	m->flags = flags;
 	if (dev != NULL) {
 		m->tcfm_ifindex = parm->ifindex;
 		if (ret != ACT_P_CREATED)
@@ -146,6 +156,8 @@ static int tcf_mirred_init(struct net *net, struct nlattr *nla,
 		dev_hold(dev);
 		rcu_assign_pointer(m->tcfm_dev, dev);
 		m->tcfm_mac_header_xmit = mac_header_xmit;
+		if (flags & MIRRED_F_TCLASS)
+			m->tcfm_tc = *tclass & TC_BITMASK;
 	}
 
 	if (ret == ACT_P_CREATED) {
@@ -259,6 +271,9 @@ static int tcf_mirred_dump(struct sk_buff *skb, struct tc_action *a, int bind,
 
 	if (nla_put(skb, TCA_MIRRED_PARMS, sizeof(opt), &opt))
 		goto nla_put_failure;
+	if ((m->flags & MIRRED_F_TCLASS) &&
+	    nla_put_u8(skb, TCA_MIRRED_TCLASS, m->tcfm_tc))
+		goto nla_put_failure;
 
 	tcf_tm_dump(&t, &m->tcf_tm);
 	if (nla_put_64bit(skb, TCA_MIRRED_TM, sizeof(t), &t, TCA_MIRRED_PAD))
