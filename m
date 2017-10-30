From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 8/9] mlxsw: spectrum: Support RED xstats
Date: Mon, 30 Oct 2017 09:56:12 +0100
Message-ID: <20171030085613.8697-9-jiri@resnulli.us>
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
Received: from mail-wr0-f194.google.com ([209.85.128.194]:57244 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752686AbdJ3I4W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 04:56:22 -0400
Received: by mail-wr0-f194.google.com with SMTP id r79so11696970wrb.13
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 01:56:22 -0700 (PDT)
In-Reply-To: <20171030085613.8697-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add support for ndo_setup_tc with enum tc_setup_type value of
TC_SETUP_RED_XSTATS. This call returns the RED qdisc xstats from the cache
if the handle ID that is asked for matching the root qdisc ID and fails
otherwise.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  9 ++++
 .../net/ethernet/mellanox/mlxsw/spectrum_qdisc.c   | 51 ++++++++++++++++++++++
 2 files changed, 60 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index de81e9c..f3cf1d1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -48,6 +48,7 @@
 #include <linux/notifier.h>
 #include <net/psample.h>
 #include <net/pkt_cls.h>
+#include <net/red.h>
 
 #include "port.h"
 #include "core.h"
@@ -211,6 +212,14 @@ enum mlxsw_sp_qdisc_type {
 struct mlxsw_sp_qdisc {
 	u32 handle;
 	enum mlxsw_sp_qdisc_type type;
+	struct red_stats xstats_base;
+	union {
+		struct {
+			u64 tail_drop_base;
+			u64 ecn_base;
+			u64 wred_drop_base;
+		} red;
+	} xstats;
 };
 
 /* No need an internal lock; At worse - miss a single periodic iteration */
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
index e9d289e..4c941f7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_qdisc.c
@@ -36,6 +36,7 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <net/pkt_cls.h>
+#include <net/red.h>
 
 #include "spectrum.h"
 #include "reg.h"
@@ -77,6 +78,27 @@ mlxsw_sp_tclass_congestion_disable(struct mlxsw_sp_port *mlxsw_sp_port,
 	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(cwtpm), cwtpm_cmd);
 }
 
+static void
+mlxsw_sp_setup_tc_qdisc_clean_stats(struct mlxsw_sp_port *mlxsw_sp_port,
+				    struct mlxsw_sp_qdisc *mlxsw_sp_qdisc,
+				    int tclass_num)
+{
+	struct red_stats *xstats_base = &mlxsw_sp_qdisc->xstats_base;
+	struct mlxsw_sp_port_xstats *xstats;
+
+	xstats = &mlxsw_sp_port->periodic_hw_stats.xstats;
+
+	switch (mlxsw_sp_qdisc->type) {
+	case MLXSW_SP_QDISC_RED:
+		xstats_base->prob_mark = xstats->ecn;
+		xstats_base->prob_drop = xstats->wred_drop[tclass_num];
+		xstats_base->pdrop = xstats->tail_drop[tclass_num];
+		break;
+	default:
+		break;
+	}
+}
+
 static int
 mlxsw_sp_qdisc_red_replace(struct mlxsw_sp_port *mlxsw_sp_port, u32 handle,
 			   struct mlxsw_sp_qdisc *mlxsw_sp_qdisc,
@@ -101,6 +123,11 @@ mlxsw_sp_qdisc_red_replace(struct mlxsw_sp_port *mlxsw_sp_port, u32 handle,
 		goto out;
 
 	mlxsw_sp_qdisc->type = MLXSW_SP_QDISC_RED;
+	if (mlxsw_sp_qdisc->handle != handle)
+		mlxsw_sp_setup_tc_qdisc_clean_stats(mlxsw_sp_port,
+						    mlxsw_sp_qdisc,
+						    tclass_num);
+
 	mlxsw_sp_qdisc->handle = handle;
 
 out:
@@ -124,6 +151,26 @@ mlxsw_sp_qdisc_red_destroy(struct mlxsw_sp_port *mlxsw_sp_port, u32 handle,
 	return err;
 }
 
+static int
+mlxsw_sp_qdisc_get_red_xstats(struct mlxsw_sp_port *mlxsw_sp_port, u32 handle,
+			      struct mlxsw_sp_qdisc *mlxsw_sp_qdisc,
+			      int tclass_num, struct red_stats *res)
+{
+	struct red_stats *xstats_base = &mlxsw_sp_qdisc->xstats_base;
+	struct mlxsw_sp_port_xstats *xstats;
+
+	if (mlxsw_sp_qdisc->handle != handle ||
+	    mlxsw_sp_qdisc->type != MLXSW_SP_QDISC_RED)
+		return -EOPNOTSUPP;
+
+	xstats = &mlxsw_sp_port->periodic_hw_stats.xstats;
+
+	res->prob_drop = xstats->wred_drop[tclass_num] - xstats_base->prob_drop;
+	res->prob_mark = xstats->ecn - xstats_base->prob_mark;
+	res->pdrop = xstats->tail_drop[tclass_num] - xstats_base->pdrop;
+	return 0;
+}
+
 #define MLXSW_SP_PORT_DEFAULT_TCLASS 0
 
 int mlxsw_sp_setup_tc_red(struct mlxsw_sp_port *mlxsw_sp_port,
@@ -146,6 +193,10 @@ int mlxsw_sp_setup_tc_red(struct mlxsw_sp_port *mlxsw_sp_port,
 	case TC_RED_DESTROY:
 		return mlxsw_sp_qdisc_red_destroy(mlxsw_sp_port, p->handle,
 						  mlxsw_sp_qdisc, tclass_num);
+	case TC_RED_XSTATS:
+		return mlxsw_sp_qdisc_get_red_xstats(mlxsw_sp_port, p->handle,
+						     mlxsw_sp_qdisc, tclass_num,
+						     p->xstats);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.5
