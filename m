From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 7/9] mlxsw: spectrum: Collect tclass related stats periodically
Date: Mon, 30 Oct 2017 09:56:11 +0100
Message-ID: <20171030085613.8697-8-jiri@resnulli.us>
References: <20171030085613.8697-1-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        saeedm@mellanox.com, matanb@mellanox.com, leonro@mellanox.com,
        idosch@mellanox.com, jakub.kicinski@netronome.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com,
        ogerlitz@mellanox.com, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:56183 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752683AbdJ3I4W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:22 -0400
Received: by mail-wm0-f66.google.com with SMTP id y83so14653870wmc.4
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:21 -0700 (PDT)
In-Reply-To: <20171030085613.8697-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add more statistics to be collected from the HW periodically. These stats
are tclass based (beside ECN marked packet, that exist only port based).
They are needed to expose RED qdisc stats and xstats correctly.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 34 ++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  9 +++++++
 2 files changed, 43 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index fab0bb2..584216a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1324,6 +1324,38 @@ static int mlxsw_sp_port_get_hw_stats(struct net_device *dev,
 	return err;
 }
 
+static void
+mlxsw_sp_port_get_hw_xstats(struct net_device *dev,
+			    struct mlxsw_sp_port_xstats *xstats)
+{
+	char ppcnt_pl[MLXSW_REG_PPCNT_LEN];
+	int err, i;
+
+	err = mlxsw_sp_port_get_stats_raw(dev, MLXSW_REG_PPCNT_EXT_CNT, 0,
+					  ppcnt_pl);
+	if (!err)
+		xstats->ecn = mlxsw_reg_ppcnt_ecn_marked_get(ppcnt_pl);
+
+	for (i = 0; i < TC_MAX_QUEUE; i++) {
+		err = mlxsw_sp_port_get_stats_raw(dev,
+						  MLXSW_REG_PPCNT_TC_CONG_TC,
+						  i, ppcnt_pl);
+		if (!err)
+			xstats->wred_drop[i] =
+				mlxsw_reg_ppcnt_wred_discard_get(ppcnt_pl);
+
+		err = mlxsw_sp_port_get_stats_raw(dev, MLXSW_REG_PPCNT_TC_CNT,
+						  i, ppcnt_pl);
+		if (err)
+			continue;
+
+		xstats->backlog[i] =
+			mlxsw_reg_ppcnt_tc_transmit_queue_get(ppcnt_pl);
+		xstats->tail_drop[i] =
+			mlxsw_reg_ppcnt_tc_no_buffer_discard_uc_get(ppcnt_pl);
+	}
+}
+
 static void update_stats_cache(struct work_struct *work)
 {
 	struct mlxsw_sp_port *mlxsw_sp_port =
@@ -1335,6 +1367,8 @@ static void update_stats_cache(struct work_struct *work)
 
 	mlxsw_sp_port_get_hw_stats(mlxsw_sp_port->dev,
 				   &mlxsw_sp_port->periodic_hw_stats.stats);
+	mlxsw_sp_port_get_hw_xstats(mlxsw_sp_port->dev,
+				    &mlxsw_sp_port->periodic_hw_stats.xstats);
 
 out:
 	mlxsw_core_schedule_dw(&mlxsw_sp_port->periodic_hw_stats.update_dw,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 8810c1a..de81e9c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -213,6 +213,14 @@ struct mlxsw_sp_qdisc {
 	enum mlxsw_sp_qdisc_type type;
 };
 
+/* No need an internal lock; At worse - miss a single periodic iteration */
+struct mlxsw_sp_port_xstats {
+	u64 ecn;
+	u64 wred_drop[TC_MAX_QUEUE];
+	u64 tail_drop[TC_MAX_QUEUE];
+	u64 backlog[TC_MAX_QUEUE];
+};
+
 struct mlxsw_sp_port {
 	struct net_device *dev;
 	struct mlxsw_sp_port_pcpu_stats __percpu *pcpu_stats;
@@ -242,6 +250,7 @@ struct mlxsw_sp_port {
 	struct {
 		#define MLXSW_HW_STATS_UPDATE_TIME HZ
 		struct rtnl_link_stats64 stats;
+		struct mlxsw_sp_port_xstats xstats;
 		struct delayed_work update_dw;
 	} periodic_hw_stats;
 	struct mlxsw_sp_port_sample *sample;
-- 
2.9.5
