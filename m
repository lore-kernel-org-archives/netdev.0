From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 7/9] net/mlx5: E-Switch, Support VLAN actions in the offloads mode
Date: Thu, 22 Sep 2016 20:01:47 +0300
Message-ID: <1474563709-17943-8-git-send-email-saeedm@mellanox.com>
References: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>,
        John Fastabend <john.r.fastabend@intel.com>,
        Amir Vadai <amirv@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49042 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S964999AbcIVRCR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 13:02:17 -0400
In-Reply-To: <1474563709-17943-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Many virtualization systems use a policy under which a vlan tag is
pushed to packets sent by guests, and popped before the packet is
forwarded to the VM.

The current generation of the mlx5 HW doesn't fully support that on
a per flow level. As such, we are addressing the above common use
case with the SRIOV e-Switch abilities to push vlan into packets
sent by VFs and pop vlan from packets forwarded to VFs.

The HW can match on the correct vlan being present in packets
forwarded to VFs (eSwitch steering is done before stripping
the tag), so this part is offloaded as is.

A common practice for vlans is to avoid both push vlan and pop vlan
for inter-host VM/VM (east-west) communication because in this case,
push on egress cancels out with pop on ingress.

For supporting that, we use a global eswitch vlan pop policy, hence
allowing guest A to communicate with both remote VM B and local VM C.
This works since the HW pops the vlan only if it exists (e.g for
C --> A packets but not for B --> A packets).

On the slow path, when a VF vport has an offloaded flow which involves
pushing vlans, wheres another flow is not currently offloaded, the
packets from the 2nd flow seen by the VF representor on the host have
vlan. The VF rep driver removes such vlan before calling into the host
networking stack.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  21 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  33 ++++
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  15 ++
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 180 +++++++++++++++++++++
 5 files changed, 249 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 3460154..460363b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -869,6 +869,7 @@ void mlx5e_nic_rep_unload(struct mlx5_eswitch *esw,
 int mlx5e_add_sqs_fwd_rules(struct mlx5e_priv *priv);
 void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv);
 int mlx5e_attr_get(struct net_device *dev, struct switchdev_attr *attr);
+void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe);
 
 int mlx5e_create_direct_rqts(struct mlx5e_priv *priv);
 void mlx5e_destroy_rqt(struct mlx5e_priv *priv, struct mlx5e_rqt *rqt);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b309e7c..c127923 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -446,6 +446,16 @@ static void mlx5e_rq_free_mpwqe_info(struct mlx5e_rq *rq)
 	kfree(rq->mpwqe.info);
 }
 
+static bool mlx5e_is_vf_vport_rep(struct mlx5e_priv *priv)
+{
+	struct mlx5_eswitch_rep *rep = (struct mlx5_eswitch_rep *)priv->ppriv;
+
+	if (rep && rep->vport != FDB_UPLINK_VPORT)
+		return true;
+
+	return false;
+}
+
 static int mlx5e_create_rq(struct mlx5e_channel *c,
 			   struct mlx5e_rq_param *param,
 			   struct mlx5e_rq *rq)
@@ -487,6 +497,11 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 
 	switch (priv->params.rq_wq_type) {
 	case MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ:
+		if (mlx5e_is_vf_vport_rep(priv)) {
+			err = -EINVAL;
+			goto err_rq_wq_destroy;
+		}
+
 		rq->handle_rx_cqe = mlx5e_handle_rx_cqe_mpwrq;
 		rq->alloc_wqe = mlx5e_alloc_rx_mpwqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_mpwqe;
@@ -512,7 +527,11 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 			goto err_rq_wq_destroy;
 		}
 
-		rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
+		if (mlx5e_is_vf_vport_rep(priv))
+			rq->handle_rx_cqe = mlx5e_handle_rx_cqe_rep;
+		else
+			rq->handle_rx_cqe = mlx5e_handle_rx_cqe;
+
 		rq->alloc_wqe = mlx5e_alloc_rx_wqe;
 		rq->dealloc_wqe = mlx5e_dealloc_rx_wqe;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index e836e47..c6de6fb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -36,6 +36,7 @@
 #include <net/busy_poll.h>
 #include "en.h"
 #include "en_tc.h"
+#include "eswitch.h"
 
 static inline bool mlx5e_rx_hw_stamp(struct mlx5e_tstamp *tstamp)
 {
@@ -803,6 +804,38 @@ wq_ll_pop:
 		       &wqe->next.next_wqe_index);
 }
 
+void mlx5e_handle_rx_cqe_rep(struct mlx5e_rq *rq, struct mlx5_cqe64 *cqe)
+{
+	struct net_device *netdev = rq->netdev;
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5_eswitch_rep *rep = priv->ppriv;
+	struct mlx5e_rx_wqe *wqe;
+	struct sk_buff *skb;
+	__be16 wqe_counter_be;
+	u16 wqe_counter;
+	u32 cqe_bcnt;
+
+	wqe_counter_be = cqe->wqe_counter;
+	wqe_counter    = be16_to_cpu(wqe_counter_be);
+	wqe            = mlx5_wq_ll_get_wqe(&rq->wq, wqe_counter);
+	cqe_bcnt       = be32_to_cpu(cqe->byte_cnt);
+
+	skb = skb_from_cqe(rq, cqe, wqe_counter, cqe_bcnt);
+	if (!skb)
+		goto wq_ll_pop;
+
+	mlx5e_complete_rx_cqe(rq, cqe, cqe_bcnt, skb);
+
+	if (rep->vlan && skb_vlan_tag_present(skb))
+		skb_vlan_pop(skb);
+
+	napi_gro_receive(rq->cq.napi, skb);
+
+wq_ll_pop:
+	mlx5_wq_ll_pop(&rq->wq, wqe_counter_be,
+		       &wqe->next.next_wqe_index);
+}
+
 static inline void mlx5e_mpwqe_fill_rx_skb(struct mlx5e_rq *rq,
 					   struct mlx5_cqe64 *cqe,
 					   struct mlx5e_mpw_info *wi,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
index eeeeadc..2e2938e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch.h
@@ -157,6 +157,7 @@ struct mlx5_eswitch_fdb {
 			struct mlx5_flow_group *send_to_vport_grp;
 			struct mlx5_flow_group *miss_grp;
 			struct mlx5_flow_rule  *miss_rule;
+			int vlan_push_pop_refcount;
 		} offloads;
 	};
 };
@@ -183,6 +184,8 @@ struct mlx5_eswitch_rep {
 
 	struct mlx5_flow_rule *vport_rx_rule;
 	struct list_head       vport_sqs_list;
+	u16		       vlan;
+	u32		       vlan_refcount;
 	bool		       valid;
 };
 
@@ -252,11 +255,16 @@ enum {
 	SET_VLAN_INSERT	= BIT(1)
 };
 
+#define MLX5_FLOW_CONTEXT_ACTION_VLAN_POP  0x40
+#define MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH 0x80
+
 struct mlx5_esw_flow_attr {
 	struct mlx5_eswitch_rep *in_rep;
 	struct mlx5_eswitch_rep *out_rep;
 
 	int	action;
+	u16	vlan;
+	bool	vlan_handled;
 };
 
 int mlx5_eswitch_sqs2vport_start(struct mlx5_eswitch *esw,
@@ -273,6 +281,13 @@ void mlx5_eswitch_register_vport_rep(struct mlx5_eswitch *esw,
 void mlx5_eswitch_unregister_vport_rep(struct mlx5_eswitch *esw,
 				       int vport_index);
 
+int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
+				 struct mlx5_esw_flow_attr *attr);
+int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
+				 struct mlx5_esw_flow_attr *attr);
+int __mlx5_eswitch_set_vport_vlan(struct mlx5_eswitch *esw,
+				  int vport, u16 vlan, u8 qos, u8 set_flags);
+
 #define MLX5_DEBUG_ESWITCH_MASK BIT(3)
 
 #define esw_info(dev, format, ...)				\
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
index c0d9d1a..c910858 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
@@ -89,6 +89,186 @@ mlx5_eswitch_add_offloaded_rule(struct mlx5_eswitch *esw,
 	return rule;
 }
 
+static int esw_set_global_vlan_pop(struct mlx5_eswitch *esw, u8 val)
+{
+	struct mlx5_eswitch_rep *rep;
+	int vf_vport, err = 0;
+
+	esw_debug(esw->dev, "%s applying global %s policy\n", __func__, val ? "pop" : "none");
+	for (vf_vport = 1; vf_vport < esw->enabled_vports; vf_vport++) {
+		rep = &esw->offloads.vport_reps[vf_vport];
+		if (!rep->valid)
+			continue;
+
+		err = __mlx5_eswitch_set_vport_vlan(esw, rep->vport, 0, 0, val);
+		if (err)
+			goto out;
+	}
+
+out:
+	return err;
+}
+
+static struct mlx5_eswitch_rep *
+esw_vlan_action_get_vport(struct mlx5_esw_flow_attr *attr, bool push, bool pop)
+{
+	struct mlx5_eswitch_rep *in_rep, *out_rep, *vport = NULL;
+
+	in_rep  = attr->in_rep;
+	out_rep = attr->out_rep;
+
+	if (push)
+		vport = in_rep;
+	else if (pop)
+		vport = out_rep;
+	else
+		vport = in_rep;
+
+	return vport;
+}
+
+static int esw_add_vlan_action_check(struct mlx5_esw_flow_attr *attr,
+				     bool push, bool pop, bool fwd)
+{
+	struct mlx5_eswitch_rep *in_rep, *out_rep;
+
+	if ((push || pop) && !fwd)
+		goto out_notsupp;
+
+	in_rep  = attr->in_rep;
+	out_rep = attr->out_rep;
+
+	if (push && in_rep->vport == FDB_UPLINK_VPORT)
+		goto out_notsupp;
+
+	if (pop && out_rep->vport == FDB_UPLINK_VPORT)
+		goto out_notsupp;
+
+	/* vport has vlan push configured, can't offload VF --> wire rules w.o it */
+	if (!push && !pop && fwd)
+		if (in_rep->vlan && out_rep->vport == FDB_UPLINK_VPORT)
+			goto out_notsupp;
+
+	/* protects against (1) setting rules with different vlans to push and
+	 * (2) setting rules w.o vlans (attr->vlan = 0) && w. vlans to push (!= 0)
+	 */
+	if (push && in_rep->vlan_refcount && (in_rep->vlan != attr->vlan))
+		goto out_notsupp;
+
+	return 0;
+
+out_notsupp:
+	return -ENOTSUPP;
+}
+
+int mlx5_eswitch_add_vlan_action(struct mlx5_eswitch *esw,
+				 struct mlx5_esw_flow_attr *attr)
+{
+	struct offloads_fdb *offloads = &esw->fdb_table.offloads;
+	struct mlx5_eswitch_rep *vport = NULL;
+	bool push, pop, fwd;
+	int err = 0;
+
+	push = !!(attr->action & MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH);
+	pop  = !!(attr->action & MLX5_FLOW_CONTEXT_ACTION_VLAN_POP);
+	fwd  = !!(attr->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST);
+
+	err = esw_add_vlan_action_check(attr, push, pop, fwd);
+	if (err)
+		return err;
+
+	attr->vlan_handled = false;
+
+	vport = esw_vlan_action_get_vport(attr, push, pop);
+
+	if (!push && !pop && fwd) {
+		/* tracks VF --> wire rules without vlan push action */
+		if (attr->out_rep->vport == FDB_UPLINK_VPORT) {
+			vport->vlan_refcount++;
+			attr->vlan_handled = true;
+		}
+
+		return 0;
+	}
+
+	if (!push && !pop)
+		return 0;
+
+	if (!(offloads->vlan_push_pop_refcount)) {
+		/* it's the 1st vlan rule, apply global vlan pop policy */
+		err = esw_set_global_vlan_pop(esw, SET_VLAN_STRIP);
+		if (err)
+			goto out;
+	}
+	offloads->vlan_push_pop_refcount++;
+
+	if (push) {
+		if (vport->vlan_refcount)
+			goto skip_set_push;
+
+		err = __mlx5_eswitch_set_vport_vlan(esw, vport->vport, attr->vlan, 0,
+						    SET_VLAN_INSERT | SET_VLAN_STRIP);
+		if (err)
+			goto out;
+		vport->vlan = attr->vlan;
+skip_set_push:
+		vport->vlan_refcount++;
+	}
+out:
+	if (!err)
+		attr->vlan_handled = true;
+	return err;
+}
+
+int mlx5_eswitch_del_vlan_action(struct mlx5_eswitch *esw,
+				 struct mlx5_esw_flow_attr *attr)
+{
+	struct offloads_fdb *offloads = &esw->fdb_table.offloads;
+	struct mlx5_eswitch_rep *vport = NULL;
+	bool push, pop, fwd;
+	int err = 0;
+
+	if (!attr->vlan_handled)
+		return 0;
+
+	push = !!(attr->action & MLX5_FLOW_CONTEXT_ACTION_VLAN_PUSH);
+	pop  = !!(attr->action & MLX5_FLOW_CONTEXT_ACTION_VLAN_POP);
+	fwd  = !!(attr->action & MLX5_FLOW_CONTEXT_ACTION_FWD_DEST);
+
+	vport = esw_vlan_action_get_vport(attr, push, pop);
+
+	if (!push && !pop && fwd) {
+		/* tracks VF --> wire rules without vlan push action */
+		if (attr->out_rep->vport == FDB_UPLINK_VPORT)
+			vport->vlan_refcount--;
+
+		return 0;
+	}
+
+	if (push) {
+		vport->vlan_refcount--;
+		if (vport->vlan_refcount)
+			goto skip_unset_push;
+
+		vport->vlan = 0;
+		err = __mlx5_eswitch_set_vport_vlan(esw, vport->vport,
+						    0, 0, SET_VLAN_STRIP);
+		if (err)
+			goto out;
+	}
+
+skip_unset_push:
+	offloads->vlan_push_pop_refcount--;
+	if (offloads->vlan_push_pop_refcount)
+		return 0;
+
+	/* no more vlan rules, stop global vlan pop policy */
+	err = esw_set_global_vlan_pop(esw, 0);
+
+out:
+	return err;
+}
+
 static struct mlx5_flow_rule *
 mlx5_eswitch_add_send_to_vport_rule(struct mlx5_eswitch *esw, int vport, u32 sqn)
 {
-- 
2.7.4
