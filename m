From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 9/9] mlxsw: spectrum: Support general qdisc stats
Date: Mon, 30 Oct 2017 09:56:13 +0100
Message-ID: <20171030085613.8697-10-jiri@resnulli.us>
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
Received: from mail-wr0-f196.google.com ([209.85.128.196]:53590 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932087AbdJ3I4X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:23 -0400
Received: by mail-wr0-f196.google.com with SMTP id u40so11699400wrf.10
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:22 -0700 (PDT)
In-Reply-To: <20171030085613.8697-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add support for ndo_setup_tc with enum tc_setup_type value of
TC_SETUP_QDISC_STATS. This call updates the generic qdisc stats from the
cache if the handle ID that is asked for matching the root qdisc ID and
fails otherwise.
Currently doesn't support qlen and rqueues.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  5 +++
 .../net/ethernet/mellanox/mlxsw/spectrum_qdisc.c   | 51 ++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index f3cf1d1..0b0cae1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -220,6 +220,11 @@ struct mlxsw_sp_qdisc {
 			u64 wred_drop_base;
 		} red;
 	} xstats;
+
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 drops;
+	u64 overlimits;
 };
 
 /* No need an internal lock; At worse - miss a single periodic iteration */
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
index 4c941f7..0988ba5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
@@ -85,14 +85,24 @@ mlxsw_sp_setup_tc_qdisc_clean_stats(struct mlxsw_sp_port *mlxsw_sp_port,
 {
 	struct red_stats *xstats_base = &mlxsw_sp_qdisc->xstats_base;
 	struct mlxsw_sp_port_xstats *xstats;
+	struct rtnl_link_stats64 *stats;
 
 	xstats = &mlxsw_sp_port->periodic_hw_stats.xstats;
+	stats = &mlxsw_sp_port->periodic_hw_stats.stats;
+
+	mlxsw_sp_qdisc->tx_packets = stats->tx_packets;
+	mlxsw_sp_qdisc->tx_bytes = stats->tx_bytes;
 
 	switch (mlxsw_sp_qdisc->type) {
 	case MLXSW_SP_QDISC_RED:
 		xstats_base->prob_mark = xstats->ecn;
 		xstats_base->prob_drop = xstats->wred_drop[tclass_num];
 		xstats_base->pdrop = xstats->tail_drop[tclass_num];
+
+		mlxsw_sp_qdisc->overlimits = xstats_base->prob_drop +
+					     xstats_base->prob_mark;
+		mlxsw_sp_qdisc->drops = xstats_base->prob_drop +
+					xstats_base->pdrop;
 		break;
 	default:
 		break;
@@ -171,6 +181,43 @@ mlxsw_sp_qdisc_get_red_xstats(struct mlxsw_sp_port *mlxsw_sp_port, u32 handle,
 	return 0;
 }
 
+static int
+mlxsw_sp_qdisc_get_red_stats(struct mlxsw_sp_port *mlxsw_sp_port, u32 handle,
+			     struct mlxsw_sp_qdisc *mlxsw_sp_qdisc,
+			     int tclass_num,
+			     struct tc_red_qopt_offload_stats *res)
+{
+	u64 tx_bytes, tx_packets, overlimits, drops;
+	struct mlxsw_sp_port_xstats *xstats;
+	struct rtnl_link_stats64 *stats;
+
+	if (mlxsw_sp_qdisc->handle != handle ||
+	    mlxsw_sp_qdisc->type != MLXSW_SP_QDISC_RED)
+		return -EOPNOTSUPP;
+
+	xstats = &mlxsw_sp_port->periodic_hw_stats.xstats;
+	stats = &mlxsw_sp_port->periodic_hw_stats.stats;
+
+	tx_bytes = stats->tx_bytes - mlxsw_sp_qdisc->tx_bytes;
+	tx_packets = stats->tx_packets - mlxsw_sp_qdisc->tx_packets;
+	overlimits = xstats->wred_drop[tclass_num] + xstats->ecn -
+		     mlxsw_sp_qdisc->overlimits;
+	drops = xstats->wred_drop[tclass_num] + xstats->tail_drop[tclass_num] -
+		mlxsw_sp_qdisc->drops;
+
+	_bstats_update(res->bstats, tx_bytes, tx_packets);
+	res->qstats->overlimits += overlimits;
+	res->qstats->drops += drops;
+	res->qstats->backlog += mlxsw_sp_cells_bytes(mlxsw_sp_port->mlxsw_sp,
+						xstats->backlog[tclass_num]);
+
+	mlxsw_sp_qdisc->drops +=  drops;
+	mlxsw_sp_qdisc->overlimits += overlimits;
+	mlxsw_sp_qdisc->tx_bytes += tx_bytes;
+	mlxsw_sp_qdisc->tx_packets += tx_packets;
+	return 0;
+}
+
 #define MLXSW_SP_PORT_DEFAULT_TCLASS 0
 
 int mlxsw_sp_setup_tc_red(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -197,6 +244,10 @@ int mlxsw_sp_setup_tc_red(struct mlxsw_sp_port *mlxsw_sp_port,
 		return mlxsw_sp_qdisc_get_red_xstats(mlxsw_sp_port, p->handle,
 						     mlxsw_sp_qdisc, tclass_num,
 						     p->xstats);
+	case TC_RED_STATS:
+		return mlxsw_sp_qdisc_get_red_stats(mlxsw_sp_port, p->handle,
+						    mlxsw_sp_qdisc, tclass_num,
+						    &p->stats);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.5
