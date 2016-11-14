From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 8/8] mlxsw: packet sample: Add packet sample offloading support
Date: Mon, 14 Nov 2016 16:00:38 +0100
Message-ID: <1479135638-3580-9-git-send-email-jiri@resnulli.us>
References: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        jhs@mojatatu.com, geert+renesas@glider.be,
        stephen@networkplumber.org, xiyou.wangcong@gmail.com,
        linux@roeck-us.net, roopa@cumulusnetworks.com,
        john.fastabend@gmail.com, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35543 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932945AbcKNPAv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 10:00:51 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so16111848wme.2
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2016 07:00:50 -0800 (PST)
In-Reply-To: <1479135638-3580-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Using the MPSC regiter, add the functions that configure port packets
sampling in hardware and the necessary datatypes in the mlxsw_sp_port
struct. In addition, add the necessary trap for sampled packets and
integrate with matchall offloading to allow offloading of the sample tc
action.

The current offload support is for the tc command:

tc filter add dev <DEV> parent ffff:   \
	  matchall   \
	  action sample rate <RATE> mark <MARK> [trunc <SIZE>]   \
	  		[src <SADDR>] [dst <DADDR>] [type <TYPE>]

Where only ingress qdiscs are supported, and only a combination of
matchall classifier and sample action will lead to activating hardware
packet sampling.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 120 +++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  12 +++
 drivers/net/ethernet/mellanox/mlxsw/trap.h     |   1 +
 3 files changed, 125 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index a5433e4..6cbf67c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -57,6 +57,8 @@
 #include <net/pkt_cls.h>
 #include <net/tc_act/tc_mirred.h>
 #include <net/netevent.h>
+#include <net/tc_act/tc_sample.h>
+#include <net/ife.h>
 
 #include "spectrum.h"
 #include "pci.h"
@@ -467,6 +469,16 @@ static void mlxsw_sp_span_mirror_remove(struct mlxsw_sp_port *from,
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
@@ -1221,6 +1233,49 @@ mlxsw_sp_port_add_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
 	return err;
 }
 
+static int
+mlxsw_sp_port_add_cls_matchall_sample(struct mlxsw_sp_port *mlxsw_sp_port,
+				      struct tc_cls_matchall_offload *cls,
+				      const struct tc_action *a,
+				      bool ingress)
+{
+	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
+	int sampler_id;
+	int err;
+
+	if (mlxsw_sp_port->sample.enable) {
+		netdev_err(mlxsw_sp_port->dev, "Sample already active\n");
+		return -EEXIST;
+	}
+
+	err = mlxsw_sp_port_sample_set(mlxsw_sp_port, true, tcf_sample_rate(a));
+	if (err)
+		return err;
+
+	sampler_id = tcf_sample_sampler_id(a);
+
+	mlxsw_sp_port->sample.enable = true;
+	mlxsw_sp_port->sample.mark = tcf_sample_mark(a);
+	mlxsw_sp_port->sample.truncate = tcf_sample_truncate(a);
+	mlxsw_sp_port->sample.trunc_size = tcf_sample_trunc_size(a);
+	mlxsw_sp_port->sample.eth_type = tcf_sample_eth_type(a);
+	mlxsw_sp_port->sample.sampler_id = TC_SAMPLE_HW_ID(sampler_id);
+	tcf_sample_eth_dst_addr(a, mlxsw_sp_port->sample.eth_dst);
+	tcf_sample_eth_src_addr(a, mlxsw_sp_port->sample.eth_src);
+
+	netdev_dbg(mlxsw_sp_port->dev, "Activate hardware sample\n");
+
+	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
+	if (!mall_tc_entry)
+		return -ENOMEM;
+
+	mall_tc_entry->cookie = cls->cookie;
+	mall_tc_entry->type = MLXSW_SP_PORT_MALL_SAMPLE;
+	list_add_tail(&mall_tc_entry->list, &mlxsw_sp_port->mall_tc_list);
+
+	return 0;
+}
+
 static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					  __be16 protocol,
 					  struct tc_cls_matchall_offload *cls,
@@ -1236,17 +1291,19 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 
 	tcf_exts_to_list(cls->exts, &actions);
-	list_for_each_entry(a, &actions, list) {
-		if (!is_tcf_mirred_egress_mirror(a) ||
-		    protocol != htons(ETH_P_ALL)) {
-			return -ENOTSUPP;
-		}
+	a = list_first_entry(&actions, struct tc_action, list);
 
+	if (is_tcf_mirred_egress_mirror(a) && protocol == htons(ETH_P_ALL))
 		err = mlxsw_sp_port_add_cls_matchall_mirror(mlxsw_sp_port, cls,
 							    a, ingress);
-		if (err)
-			return err;
-	}
+	else if (is_tcf_sample(a) && protocol == htons(ETH_P_ALL))
+		err = mlxsw_sp_port_add_cls_matchall_sample(mlxsw_sp_port, cls,
+							    a, ingress);
+	else
+		return -ENOTSUPP;
+
+	if (err)
+		return err;
 
 	return 0;
 }
@@ -1274,6 +1331,10 @@ static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 
 		mlxsw_sp_span_mirror_remove(mlxsw_sp_port, to_port, span_type);
 		break;
+	case MLXSW_SP_PORT_MALL_SAMPLE:
+		mlxsw_sp_port->sample.enable = false;
+		mlxsw_sp_port_sample_set(mlxsw_sp_port, false, 1);
+		break;
 	default:
 		WARN_ON(1);
 	}
@@ -2774,6 +2835,46 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 	return mlxsw_sp_rx_listener_func(skb, local_port, priv);
 }
 
+static void mlxsw_sp_rx_listener_sample_func(struct sk_buff *skb, u8 local_port,
+					     void *priv)
+{
+	struct mlxsw_sp *mlxsw_sp = priv;
+	struct mlxsw_sp_port *mlxsw_sp_port = mlxsw_sp->ports[local_port];
+	static struct ethhdr *ethhdr;
+	int orig_size;
+
+	if (unlikely(!mlxsw_sp_port)) {
+		dev_warn_ratelimited(mlxsw_sp->bus_info->dev, "Port %d: sample skb received for non-existent port\n",
+				     local_port);
+		return;
+	}
+
+	skb->dev = mlxsw_sp_port->dev;
+	skb->mac_len = skb->dev->hard_header_len;
+	skb->mark = mlxsw_sp_port->sample.mark;
+
+	orig_size = skb->len;
+
+	if (mlxsw_sp_port->sample.truncate)
+		skb_trim(skb, mlxsw_sp_port->sample.trunc_size);
+
+	ethhdr = ife_packet_info_pack(skb, orig_size, skb->dev->ifindex, 0,
+				      mlxsw_sp_port->sample.sampler_id,
+				      mlxsw_sp_port->sample.seq++);
+	if (!ethhdr)
+		return;
+
+	if (!is_zero_ether_addr(mlxsw_sp_port->sample.eth_src))
+		ether_addr_copy(ethhdr->h_source,
+				mlxsw_sp_port->sample.eth_src);
+	if (!is_zero_ether_addr(mlxsw_sp_port->sample.eth_dst))
+		ether_addr_copy(ethhdr->h_dest, mlxsw_sp_port->sample.eth_dst);
+	ethhdr->h_proto = htons(mlxsw_sp_port->sample.eth_type);
+
+	skb->protocol = eth_type_trans(skb, skb->dev);
+	netif_receive_skb(skb);
+}
+
 #define MLXSW_SP_RXL(_func, _trap_id, _action)			\
 	{							\
 		.func = _func,					\
@@ -2784,6 +2885,9 @@ static void mlxsw_sp_rx_listener_mark_func(struct sk_buff *skb, u8 local_port,
 
 static const struct mlxsw_rx_listener mlxsw_sp_rx_listener[] = {
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, FDB_MC, TRAP_TO_CPU),
+	MLXSW_SP_RXL(mlxsw_sp_rx_listener_sample_func, PKT_SAMPLE,
+		     MIRROR_TO_CPU),
+
 	/* Traps for specific L2 packet types, not trapped as FDB MC */
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, STP, TRAP_TO_CPU),
 	MLXSW_SP_RXL(mlxsw_sp_rx_listener_func, LACP, TRAP_TO_CPU),
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 04a2bc7..7f2e6fc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -229,6 +229,7 @@ struct mlxsw_sp_span_entry {
 
 enum mlxsw_sp_port_mall_action_type {
 	MLXSW_SP_PORT_MALL_MIRROR,
+	MLXSW_SP_PORT_MALL_SAMPLE,
 };
 
 struct mlxsw_sp_port_mall_mirror_tc_entry {
@@ -361,6 +362,17 @@ struct mlxsw_sp_port {
 		struct rtnl_link_stats64 *cache;
 		struct delayed_work update_dw;
 	} hw_stats;
+	struct {
+		bool enable;
+		u32 mark;
+		bool truncate;
+		u32 trunc_size;
+		u8 eth_src[ETH_ALEN];
+		u8 eth_dst[ETH_ALEN];
+		u16 eth_type;
+		u32 sampler_id;
+		u32 seq;
+	} sample;
 };
 
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/trap.h b/drivers/net/ethernet/mellanox/mlxsw/trap.h
index ed8e301..eebd135 100644
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
