From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 04/15] net/mlx5e: Implement 1PPS support
Date: Fri, 20 Jan 2017 00:38:57 +0200
Message-ID: <20170119223908.15924-5-saeedm@mellanox.com>
References: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Eugenia Emantayev <eugenia@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59330 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751816AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
In-Reply-To: <20170119223908.15924-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

This patch enables the 1PPS IN and 1PPS OUT support according
to the advertised HCA capability. Single pin may be configured
to one of the above mutual exclusive functions via standard
Linux tools and APIs. For example, testptp open source application.

Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 218 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  12 +-
 3 files changed, 232 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0d9dd860a295..22c3d26c6d3d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -262,6 +262,7 @@ struct mlx5e_tstamp {
 	struct mlx5_core_dev      *mdev;
 	struct ptp_clock          *ptp;
 	struct ptp_clock_info      ptp_info;
+	u8                        *pps_pin_caps;
 };
 
 enum {
@@ -780,6 +781,8 @@ void mlx5e_fill_hwstamp(struct mlx5e_tstamp *clock, u64 timestamp,
 			struct skb_shared_hwtstamps *hwts);
 void mlx5e_timestamp_init(struct mlx5e_priv *priv);
 void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv);
+void mlx5e_pps_event_handler(struct mlx5e_priv *priv,
+			     struct ptp_clock_event *event);
 int mlx5e_hwstamp_set(struct net_device *dev, struct ifreq *ifr);
 int mlx5e_hwstamp_get(struct net_device *dev, struct ifreq *ifr);
 void mlx5e_modify_rx_cqe_compression(struct mlx5e_priv *priv, bool val);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
index 746a92c13644..349dc72cd2b6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
@@ -37,6 +37,22 @@ enum {
 	MLX5E_CYCLES_SHIFT	= 23
 };
 
+enum {
+	MLX5E_PIN_MODE_IN		= 0x0,
+	MLX5E_PIN_MODE_OUT		= 0x1,
+};
+
+enum {
+	MLX5E_OUT_PATTERN_PULSE		= 0x0,
+	MLX5E_OUT_PATTERN_PERIODIC	= 0x1,
+};
+
+enum {
+	MLX5E_EVENT_MODE_DISABLE	= 0x0,
+	MLX5E_EVENT_MODE_REPETETIVE	= 0x1,
+	MLX5E_EVENT_MODE_ONCE_TILL_ARM	= 0x2,
+};
+
 void mlx5e_fill_hwstamp(struct mlx5e_tstamp *tstamp, u64 timestamp,
 			struct skb_shared_hwtstamps *hwts)
 {
@@ -189,6 +205,18 @@ static int mlx5e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	int neg_adj = 0;
 	struct mlx5e_tstamp *tstamp = container_of(ptp, struct mlx5e_tstamp,
 						  ptp_info);
+	struct mlx5e_priv *priv =
+		container_of(tstamp, struct mlx5e_priv, tstamp);
+
+	if (MLX5_CAP_GEN(priv->mdev, pps_modify)) {
+		u32 in[MLX5_ST_SZ_DW(mtpps_reg)] = {0};
+
+		/* For future use need to add a loop for finding all 1PPS out pins */
+		MLX5_SET(mtpps_reg, in, pin_mode, MLX5E_PIN_MODE_OUT);
+		MLX5_SET(mtpps_reg, in, out_periodic_adjustment, delta & 0xFFFF);
+
+		mlx5_set_mtpps(priv->mdev, in, sizeof(in));
+	}
 
 	if (delta < 0) {
 		neg_adj = 1;
@@ -208,6 +236,124 @@ static int mlx5e_ptp_adjfreq(struct ptp_clock_info *ptp, s32 delta)
 	return 0;
 }
 
+static int mlx5e_extts_configure(struct ptp_clock_info *ptp,
+				 struct ptp_clock_request *rq,
+				 int on)
+{
+	struct mlx5e_tstamp *tstamp =
+		container_of(ptp, struct mlx5e_tstamp, ptp_info);
+	struct mlx5e_priv *priv =
+		container_of(tstamp, struct mlx5e_priv, tstamp);
+	u32 in[MLX5_ST_SZ_DW(mtpps_reg)] = {0};
+	u8 pattern = 0;
+	int pin = -1;
+	int err = 0;
+
+	if (!MLX5_CAP_GEN(priv->mdev, pps) ||
+	    !MLX5_CAP_GEN(priv->mdev, pps_modify))
+		return -EOPNOTSUPP;
+
+	if (rq->extts.index >= tstamp->ptp_info.n_pins)
+		return -EINVAL;
+
+	if (on) {
+		pin = ptp_find_pin(tstamp->ptp, PTP_PF_EXTTS, rq->extts.index);
+		if (pin < 0)
+			return -EBUSY;
+	}
+
+	if (rq->extts.flags & PTP_FALLING_EDGE)
+		pattern = 1;
+
+	MLX5_SET(mtpps_reg, in, pin, pin);
+	MLX5_SET(mtpps_reg, in, pin_mode, MLX5E_PIN_MODE_IN);
+	MLX5_SET(mtpps_reg, in, pattern, pattern);
+	MLX5_SET(mtpps_reg, in, enable, on);
+
+	err = mlx5_set_mtpps(priv->mdev, in, sizeof(in));
+	if (err)
+		return err;
+
+	return mlx5_set_mtppse(priv->mdev, pin, 0,
+			       MLX5E_EVENT_MODE_REPETETIVE & on);
+}
+
+static int mlx5e_perout_configure(struct ptp_clock_info *ptp,
+				  struct ptp_clock_request *rq,
+				  int on)
+{
+	struct mlx5e_tstamp *tstamp =
+		container_of(ptp, struct mlx5e_tstamp, ptp_info);
+	struct mlx5e_priv *priv =
+		container_of(tstamp, struct mlx5e_priv, tstamp);
+	u32 in[MLX5_ST_SZ_DW(mtpps_reg)] = {0};
+	u64 nsec_now, nsec_delta, time_stamp;
+	u64 cycles_now, cycles_delta;
+	struct timespec64 ts;
+	unsigned long flags;
+	int pin = -1;
+	s64 ns;
+
+	if (!MLX5_CAP_GEN(priv->mdev, pps_modify))
+		return -EOPNOTSUPP;
+
+	if (rq->perout.index >= tstamp->ptp_info.n_pins)
+		return -EINVAL;
+
+	if (on) {
+		pin = ptp_find_pin(tstamp->ptp, PTP_PF_PEROUT,
+				   rq->perout.index);
+		if (pin < 0)
+			return -EBUSY;
+	}
+
+	ts.tv_sec = rq->perout.period.sec;
+	ts.tv_nsec = rq->perout.period.nsec;
+	ns = timespec64_to_ns(&ts);
+	if (on)
+		if ((ns >> 1) != 500000000LL)
+			return -EINVAL;
+	ts.tv_sec = rq->perout.start.sec;
+	ts.tv_nsec = rq->perout.start.nsec;
+	ns = timespec64_to_ns(&ts);
+	cycles_now = mlx5_read_internal_timer(tstamp->mdev);
+	write_lock_irqsave(&tstamp->lock, flags);
+	nsec_now = timecounter_cyc2time(&tstamp->clock, cycles_now);
+	nsec_delta = ns - nsec_now;
+	cycles_delta = div64_u64(nsec_delta << tstamp->cycles.shift,
+				 tstamp->cycles.mult);
+	write_unlock_irqrestore(&tstamp->lock, flags);
+	time_stamp = cycles_now + cycles_delta;
+	MLX5_SET(mtpps_reg, in, pin, pin);
+	MLX5_SET(mtpps_reg, in, pin_mode, MLX5E_PIN_MODE_OUT);
+	MLX5_SET(mtpps_reg, in, pattern, MLX5E_OUT_PATTERN_PERIODIC);
+	MLX5_SET(mtpps_reg, in, enable, on);
+	MLX5_SET64(mtpps_reg, in, time_stamp, time_stamp);
+
+	return mlx5_set_mtpps(priv->mdev, in, sizeof(in));
+}
+
+static int mlx5e_ptp_enable(struct ptp_clock_info *ptp,
+			    struct ptp_clock_request *rq,
+			    int on)
+{
+	switch (rq->type) {
+	case PTP_CLK_REQ_EXTTS:
+		return mlx5e_extts_configure(ptp, rq, on);
+	case PTP_CLK_REQ_PEROUT:
+		return mlx5e_perout_configure(ptp, rq, on);
+	default:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+static int mlx5e_ptp_verify(struct ptp_clock_info *ptp, unsigned int pin,
+			    enum ptp_pin_function func, unsigned int chan)
+{
+	return (func == PTP_PF_PHYSYNC) ? -EOPNOTSUPP : 0;
+}
+
 static const struct ptp_clock_info mlx5e_ptp_clock_info = {
 	.owner		= THIS_MODULE,
 	.max_adj	= 100000000,
@@ -221,6 +367,7 @@ static const struct ptp_clock_info mlx5e_ptp_clock_info = {
 	.gettime64	= mlx5e_ptp_gettime,
 	.settime64	= mlx5e_ptp_settime,
 	.enable		= NULL,
+	.verify		= NULL,
 };
 
 static void mlx5e_timestamp_init_config(struct mlx5e_tstamp *tstamp)
@@ -229,6 +376,62 @@ static void mlx5e_timestamp_init_config(struct mlx5e_tstamp *tstamp)
 	tstamp->hwtstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
 }
 
+static int mlx5e_init_pin_config(struct mlx5e_tstamp *tstamp)
+{
+	int i;
+
+	tstamp->ptp_info.pin_config =
+		kzalloc(sizeof(*tstamp->ptp_info.pin_config) *
+			       tstamp->ptp_info.n_pins, GFP_KERNEL);
+	if (!tstamp->ptp_info.pin_config)
+		return -ENOMEM;
+	tstamp->ptp_info.enable = mlx5e_ptp_enable;
+	tstamp->ptp_info.verify = mlx5e_ptp_verify;
+
+	for (i = 0; i < tstamp->ptp_info.n_pins; i++) {
+		snprintf(tstamp->ptp_info.pin_config[i].name,
+			 sizeof(tstamp->ptp_info.pin_config[i].name),
+			 "mlx5_pps%d", i);
+		tstamp->ptp_info.pin_config[i].index = i;
+		tstamp->ptp_info.pin_config[i].func = PTP_PF_NONE;
+		tstamp->ptp_info.pin_config[i].chan = i;
+	}
+
+	return 0;
+}
+
+static void mlx5e_get_pps_caps(struct mlx5e_priv *priv,
+			       struct mlx5e_tstamp *tstamp)
+{
+	u32 out[MLX5_ST_SZ_DW(mtpps_reg)] = {0};
+
+	mlx5_query_mtpps(priv->mdev, out, sizeof(out));
+
+	tstamp->ptp_info.n_pins = MLX5_GET(mtpps_reg, out,
+					   cap_number_of_pps_pins);
+	tstamp->ptp_info.n_ext_ts = MLX5_GET(mtpps_reg, out,
+					     cap_max_num_of_pps_in_pins);
+	tstamp->ptp_info.n_per_out = MLX5_GET(mtpps_reg, out,
+					      cap_max_num_of_pps_out_pins);
+
+	tstamp->pps_pin_caps[0] = MLX5_GET(mtpps_reg, out, cap_pin_0_mode);
+	tstamp->pps_pin_caps[1] = MLX5_GET(mtpps_reg, out, cap_pin_1_mode);
+	tstamp->pps_pin_caps[2] = MLX5_GET(mtpps_reg, out, cap_pin_2_mode);
+	tstamp->pps_pin_caps[3] = MLX5_GET(mtpps_reg, out, cap_pin_3_mode);
+	tstamp->pps_pin_caps[4] = MLX5_GET(mtpps_reg, out, cap_pin_4_mode);
+	tstamp->pps_pin_caps[5] = MLX5_GET(mtpps_reg, out, cap_pin_5_mode);
+	tstamp->pps_pin_caps[6] = MLX5_GET(mtpps_reg, out, cap_pin_6_mode);
+	tstamp->pps_pin_caps[7] = MLX5_GET(mtpps_reg, out, cap_pin_7_mode);
+}
+
+void mlx5e_pps_event_handler(struct mlx5e_priv *priv,
+			     struct ptp_clock_event *event)
+{
+	struct mlx5e_tstamp *tstamp = &priv->tstamp;
+
+	ptp_clock_event(tstamp->ptp, event);
+}
+
 void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 {
 	struct mlx5e_tstamp *tstamp = &priv->tstamp;
@@ -272,6 +475,18 @@ void mlx5e_timestamp_init(struct mlx5e_priv *priv)
 	tstamp->ptp_info = mlx5e_ptp_clock_info;
 	snprintf(tstamp->ptp_info.name, 16, "mlx5 ptp");
 
+	/* Initialize 1PPS data structures */
+#define MAX_PIN_NUM	8
+	tstamp->pps_pin_caps = kzalloc(sizeof(u8) * MAX_PIN_NUM, GFP_KERNEL);
+	if (tstamp->pps_pin_caps) {
+		if (MLX5_CAP_GEN(priv->mdev, pps))
+			mlx5e_get_pps_caps(priv, tstamp);
+		if (tstamp->ptp_info.n_pins)
+			mlx5e_init_pin_config(tstamp);
+	} else {
+		mlx5_core_warn(priv->mdev, "1PPS initialization failed\n");
+	}
+
 	tstamp->ptp = ptp_clock_register(&tstamp->ptp_info,
 					 &priv->mdev->pdev->dev);
 	if (IS_ERR(tstamp->ptp)) {
@@ -293,5 +508,8 @@ void mlx5e_timestamp_cleanup(struct mlx5e_priv *priv)
 		priv->tstamp.ptp = NULL;
 	}
 
+	kfree(tstamp->pps_pin_caps);
+	kfree(tstamp->ptp_info.pin_config);
+
 	cancel_delayed_work_sync(&tstamp->overflow_work);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index aba3691e0919..2129fbd1d6ca 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -317,6 +317,8 @@ static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
 			      enum mlx5_dev_event event, unsigned long param)
 {
 	struct mlx5e_priv *priv = vpriv;
+	struct ptp_clock_event ptp_event;
+	struct mlx5_eqe *eqe = NULL;
 
 	if (!test_bit(MLX5E_STATE_ASYNC_EVENTS_ENABLED, &priv->state))
 		return;
@@ -326,7 +328,15 @@ static void mlx5e_async_event(struct mlx5_core_dev *mdev, void *vpriv,
 	case MLX5_DEV_EVENT_PORT_DOWN:
 		queue_work(priv->wq, &priv->update_carrier_work);
 		break;
-
+	case MLX5_DEV_EVENT_PPS:
+		eqe = (struct mlx5_eqe *)param;
+		ptp_event.type = PTP_CLOCK_EXTTS;
+		ptp_event.index = eqe->data.pps.pin;
+		ptp_event.timestamp =
+			timecounter_cyc2time(&priv->tstamp.clock,
+					     be64_to_cpu(eqe->data.pps.time_stamp));
+		mlx5e_pps_event_handler(vpriv, &ptp_event);
+		break;
 	default:
 		break;
 	}
-- 
2.11.0
