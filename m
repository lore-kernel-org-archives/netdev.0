From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 11/14] net/mlx5e: Add missing support for PTP_CLK_REQ_PPS request
Date: Thu, 27 Jul 2017 13:25:29 +0300
Message-ID: <20170727102532.2317-12-saeedm@mellanox.com>
References: <20170727102532.2317-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44995 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751445AbdG0K1O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:27:14 -0400
In-Reply-To: <20170727102532.2317-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Add the missing option to enable the PTP_CLK_PPS function.
In this case pin should be configured as 1PPS IN first and
then it will be connected to PPS mechanism.
Events will be reported as PTP_CLOCK_PPSUSR events to relevant sysfs.

Fixes: ee7f12205abc ('net/mlx5e: Implement 1PPS support')
Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 20 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  1 -
 3 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index d42826f0f0d6..0039b4725405 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -271,6 +271,7 @@ struct mlx5e_pps {
 	u8                         pin_caps[MAX_PIN_NUM];
 	struct work_struct         out_work;
 	u64                        start[MAX_PIN_NUM];
+	u8                         enabled;
 };
 
 struct mlx5e_tstamp {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 464ddd10ebbc..ba355c6b6e1f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -393,6 +393,17 @@ static int mlx5e_perout_configure(struct ptp_clock_info *ptp,
 			       MLX5E_EVENT_MODE_REPETETIVE & on);
 }
 
+static int mlx5e_pps_configure(struct ptp_clock_info *ptp,
+			       struct ptp_clock_request *rq,
+			       int on)
+{
+	struct mlx5e_tstamp *tstamp =
+		container_of(ptp, struct mlx5e_tstamp, ptp_info);
+
+	tstamp->pps_info.enabled = !!on;
+	return 0;
+}
+
 static int mlx5e_ptp_enable(struct ptp_clock_info *ptp,
 			    struct ptp_clock_request *rq,
 			    int on)
@@ -402,6 +413,8 @@ static int mlx5e_ptp_enable(struct ptp_clock_info *ptp,
 		return mlx5e_extts_configure(ptp, rq, on);
 	case PTP_CLK_REQ_PEROUT:
 		return mlx5e_perout_configure(ptp, rq, on);
+	case PTP_CLK_REQ_PPS:
+		return mlx5e_pps_configure(ptp, rq, on);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -447,6 +460,7 @@ static int mlx5e_init_pin_config(struct mlx5e_tstamp *tstamp)
 		return -ENOMEM;
 	tstamp->ptp_info.enable = mlx5e_ptp_enable;
 	tstamp->ptp_info.verify = mlx5e_ptp_verify;
+	tstamp->ptp_info.pps = 1;
 
 	for (i = 0; i < tstamp->ptp_info.n_pins; i++) {
 		snprintf(tstamp->ptp_info.pin_config[i].name,
@@ -498,6 +512,12 @@ void mlx5e_pps_event_handler(struct mlx5e_priv *priv,
 
 	switch (tstamp->ptp_info.pin_config[pin].func) {
 	case PTP_PF_EXTTS:
+		if (tstamp->pps_info.enabled) {
+			event->type = PTP_CLOCK_PPSUSR;
+			event->pps_times.ts_real = ns_to_timespec64(event->timestamp);
+		} else {
+			event->type = PTP_CLOCK_EXTTS;
+		}
 		ptp_clock_event(tstamp->ptp, event);
 		break;
 	case PTP_PF_PEROUT:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 1eac5003084f..57f31fa478ce 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -377,7 +377,6 @@ static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
 		break;
 	case MLX5_DEV_EVENT_PPS:
 		eqe = (struct mlx5_eqe *)param;
-		ptp_event.type = PTP_CLOCK_EXTTS;
 		ptp_event.index = eqe->data.pps.pin;
 		ptp_event.timestamp =
 			timecounter_cyc2time(&priv->tstamp.clock,
-- 
2.13.0
