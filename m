From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 4/4] mlxsw: spectrum: Add packet sample offloading support
Date: Mon, 23 Jan 2017 11:07:11 +0100
Message-ID: <1485166031-4773-5-git-send-email-jiri@resnulli.us>
References: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com,
        mrv@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36452 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdAWKH3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 05:07:29 -0500
Received: by mail-wm0-f65.google.com with SMTP id r126so25198520wmr.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 02:07:28 -0800 (PST)
In-Reply-To: <1485166031-4773-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Using the MPSC register, add the functions that configure port-based
packet sampling in hardware and the necessary datatypes in the
mlxsw_sp_port struct. In addition, add the necessary trap for sampled
packets and integrate with matchall offloading to allow offloading of the
sample tc action.

The current offload support is for the tc command:

tc filter add dev <DEV> parent ffff: \
	  matchall skip_sw \
	  action sample rate <RATE> group <GROUP> [trunc <SIZE>]

Where only ingress qdiscs are supported, and only a combination of
matchall classifier and sample action will lead to activating hardware
packet sampling.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 111 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  10 +++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |   1 +
 3 files changed, 122 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 3dbd82e..467aa52 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -57,6 +57,7 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_mirred.h>
 #include <net/netevent.h>
+#include <net/tc_act/tc_sample.h>
 
 #include "spectrum.h"
 #include "pci.h"
@@ -469,6 +470,16 @@ static void mlxsw_sp_span_mirror_remove(struct mlxsw_sp_port *from,
 	mlxsw_sp_span_inspected_port_unbind(from, span_entry, type);
 }
 
+static int mlxsw_sp_port_sample_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				    bool enable, u32 rate)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char mpsc_pl[MLXSW_REG_MPSC_LEN];
+
+	mlxsw_reg_mpsc_pack(mpsc_pl, mlxsw_sp_port->local_port, enable, rate);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mpsc), mpsc_pl);
+}
+
 static int mlxsw_sp_port_admin_status_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					  bool is_up)
 {
@@ -1218,6 +1229,51 @@ mlxsw_sp_port_del_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
 	mlxsw_sp_span_mirror_remove(mlxsw_sp_port, to_port, span_type);
 }
 
+static int
+mlxsw_sp_port_add_cls_matchall_sample(struct mlxsw_sp_port *mlxsw_sp_port,
+				      struct tc_cls_matchall_offload *cls,
+				      const struct tc_action *a,
+				      bool ingress)
+{
+	int err;
+
+	if (!mlxsw_sp_port->sample)
+		return -EOPNOTSUPP;
+	if (rtnl_dereference(mlxsw_sp_port->sample->psample_group)) {
+		netdev_err(mlxsw_sp_port->dev, "sample already active\n");
+		return -EEXIST;
+	}
+	if (tcf_sample_rate(a) > MLXSW_REG_MPSC_RATE_MAX) {
+		netdev_err(mlxsw_sp_port->dev, "sample rate not supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	rcu_assign_pointer(mlxsw_sp_port->sample->psample_group,
+			   tcf_sample_psample_group(a));
+	mlxsw_sp_port->sample->truncate = tcf_sample_truncate(a);
+	mlxsw_sp_port->sample->trunc_size = tcf_sample_trunc_size(a);
+	mlxsw_sp_port->sample->rate = tcf_sample_rate(a);
+
+	err = mlxsw_sp_port_sample_set(mlxsw_sp_port, true, tcf_sample_rate(a));
+	if (err)
+		goto err_port_sample_set;
+	return 0;
+
+err_port_sample_set:
+	RCU_INIT_POINTER(mlxsw_sp_port->sample->psample_group, NULL);
+	return err;
+}
+
+static void
+mlxsw_sp_port_del_cls_matchall_sample(struct mlxsw_sp_port *mlxsw_sp_port)
+{
+	if (!mlxsw_sp_port->sample)
+		return;
+
+	mlxsw_sp_port_sample_set(mlxsw_sp_port, false, 1);
+	RCU_INIT_POINTER(mlxsw_sp_port->sample->psample_group, NULL);
+}
+
 static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					  __be16 protocol,
 					  struct tc_cls_matchall_offload *cls,
@@ -1248,6 +1304,10 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 		mirror = &mall_tc_entry->mirror;
 		err = mlxsw_sp_port_add_cls_matchall_mirror(mlxsw_sp_port,
 							    mirror, a, ingress);
+	} else if (is_tcf_sample(a) && protocol == htons(ETH_P_ALL)) {
+		mall_tc_entry->type = MLXSW_SP_PORT_MALL_SAMPLE;
+		err = mlxsw_sp_port_add_cls_matchall_sample(mlxsw_sp_port, cls,
+							    a, ingress);
 	} else {
 		err = -EOPNOTSUPP;
 	}
@@ -1281,6 +1341,9 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 		mlxsw_sp_port_del_cls_matchall_mirror(mlxsw_sp_port,
 						      &mall_tc_entry->mirror);
 		break;
+	case MLXSW_SP_PORT_MALL_SAMPLE:
+		mlxsw_sp_port_del_cls_matchall_sample(mlxsw_sp_port);
+		break;
 	default:
 		WARN_ON(1);
 	}
@@ -2259,6 +2322,13 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_alloc_stats;
 	}
 
+	mlxsw_sp_port->sample = kzalloc(sizeof(*mlxsw_sp_port->sample),
+					GFP_KERNEL);
+	if (!mlxsw_sp_port->sample) {
+		err = -ENOMEM;
+		goto err_alloc_sample;
+	}
+
 	mlxsw_sp_port->hw_stats.cache =
 		kzalloc(sizeof(*mlxsw_sp_port->hw_stats.cache), GFP_KERNEL);
 
@@ -2387,6 +2457,8 @@ static int __mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 err_port_swid_set:
 	kfree(mlxsw_sp_port->hw_stats.cache);
 err_alloc_hw_stats:
+	kfree(mlxsw_sp_port->sample);
+err_alloc_sample:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
 	kfree(mlxsw_sp_port->untagged_vlans);
@@ -2433,6 +2505,7 @@ static void __mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port_swid_set(mlxsw_sp_port, MLXSW_PORT_SWID_DISABLED_PORT);
 	mlxsw_sp_port_module_unmap(mlxsw_sp, mlxsw_sp_port->local_port);
 	kfree(mlxsw_sp_port->hw_stats.cache);
+	kfree(mlxsw_sp_port->sample);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
@@ -2734,6 +2807,41 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 	return mlxsw_sp_rx_listener_no_mark_func(skb, local_port, priv);
 }
 
+static void mlxsw_sp_rx_listener_sample_func(struct sk_buff *skb, u8 local_port,
+					     void *priv)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	struct psample_group *psample_group;
+	u32 size;
+
+	if (unlikely(!mlxsw_sp_port)) {
+		dev_warn_ratelimited(mlxsw_sp->bus_info->dev, "Port %d: sample skb received for non-existent port\n",
+				     local_port);
+		goto out;
+	}
+	if (unlikely(!mlxsw_sp_port->sample)) {
+		dev_warn_ratelimited(mlxsw_sp->bus_info->dev, "Port %d: sample skb received on unsupported port\n",
+				     local_port);
+		goto out;
+	}
+
+	size = mlxsw_sp_port->sample->truncate ?
+		  mlxsw_sp_port->sample->trunc_size : skb->len;
+
+	rcu_read_lock();
+	psample_group = rcu_dereference(mlxsw_sp_port->sample->psample_group);
+	if (!psample_group)
+		goto out_unlock;
+	psample_sample_packet(psample_group, skb, size,
+			      mlxsw_sp_port->dev->ifindex, 0,
+			      mlxsw_sp_port->sample->rate);
+out_unlock:
+	rcu_read_unlock();
+out:
+	consume_skb(skb);
+}
+
 #define MLXSW_SP_RXL_NO_MARK(_trap_id, _action, _trap_group, _is_ctrl)	\
 	MLXSW_RXL(mlxsw_sp_rx_listener_no_mark_func, _trap_id, _action,	\
 		  _is_ctrl, SP_##_trap_group, DISCARD)
@@ -2769,6 +2877,9 @@ static const struct mlxsw_listener mlxsw_sp_listener[] = {
 	MLXSW_SP_RXL_NO_MARK(RTR_INGRESS0, TRAP_TO_CPU, REMOTE_ROUTE, false),
 	MLXSW_SP_RXL_NO_MARK(HOST_MISS_IPV4, TRAP_TO_CPU, ARP_MISS, false),
 	MLXSW_SP_RXL_NO_MARK(BGP_IPV4, TRAP_TO_CPU, BGP_IPV4, false),
+	/* PKT Sample trap */
+	MLXSW_RXL(mlxsw_sp_rx_listener_sample_func, PKT_SAMPLE, MIRROR_TO_CPU,
+		  false, SP_IP2ME, DISCARD)
 };
 
 static int mlxsw_sp_cpu_policers_set(struct mlxsw_core *mlxsw_core)
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index cc1af19..bc3efe1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -46,6 +46,7 @@
 #include <linux/dcbnl.h>
 #include <linux/in6.h>
 #include <linux/notifier.h>
+#include <net/psample.h>
 
 #include "port.h"
 #include "core.h"
@@ -229,6 +230,7 @@ struct mlxsw_sp_span_entry {
 
 enum mlxsw_sp_port_mall_action_type {
 	MLXSW_SP_PORT_MALL_MIRROR,
+	MLXSW_SP_PORT_MALL_SAMPLE,
 };
 
 struct mlxsw_sp_port_mall_mirror_tc_entry {
@@ -315,6 +317,13 @@ struct mlxsw_sp_port_pcpu_stats {
 	u32			tx_dropped;
 };
 
+struct mlxsw_sp_port_sample {
+	struct psample_group __rcu *psample_group;
+	u32 trunc_size;
+	u32 rate;
+	bool truncate;
+};
+
 struct mlxsw_sp_port {
 	struct net_device *dev;
 	struct mlxsw_sp_port_pcpu_stats __percpu *pcpu_stats;
@@ -361,6 +370,7 @@ struct mlxsw_sp_port {
 		struct rtnl_link_stats64 *cache;
 		struct delayed_work update_dw;
 	} hw_stats;
+	struct mlxsw_sp_port_sample *sample;
 };
 
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index 7ab275d..02ea48b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/trap.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/trap.h
@@ -54,6 +54,7 @@ enum {
 	MLXSW_TRAP_ID_IGMP_V2_REPORT = 0x32,
 	MLXSW_TRAP_ID_IGMP_V2_LEAVE = 0x33,
 	MLXSW_TRAP_ID_IGMP_V3_REPORT = 0x34,
+	MLXSW_TRAP_ID_PKT_SAMPLE = 0x38,
 	MLXSW_TRAP_ID_ARPBC = 0x50,
 	MLXSW_TRAP_ID_ARPUC = 0x51,
 	MLXSW_TRAP_ID_MTUERROR = 0x52,
-- 
2.7.4
