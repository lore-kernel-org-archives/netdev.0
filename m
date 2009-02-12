From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 09/41]bnx2x: BW shaper enhancements
Date: Thu, 12 Feb 2009 20:36:40 +0200
Message-ID: <1234463800.1863.141.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2951 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756983AbZBLSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 09/41]bnx2x: BW shaper enhancements
Some of the configuration can be set when loading the device and shouldn't be
re-calculated after each link up indication since it is not dependent on the
link speed

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    3 +
 drivers/net/bnx2x_hsi.h  |   25 ++--
 drivers/net/bnx2x_main.c |  314 ++++++++++++++++++++--------------------------
 3 files changed, 153 insertions(+), 189 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index b411497..b40d4f1 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -883,6 +883,9 @@ struct bnx2x {
 	struct bnx2x_common	common;
 	struct bnx2x_port	port;
 
+	struct cmng_struct_per_port cmng;
+	u32			vn_weight_sum;
+
 	u32			mf_config;
 	u16			e1hov;
 	u8			e1hmf;
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index 40061b3..a4a6039 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -2640,17 +2640,19 @@ struct ustorm_eth_rx_producers {
  */
 struct cmng_flags_per_port {
 	u8 con_number[NUM_OF_PROTOCOLS];
-#if defined(__BIG_ENDIAN)
-	u8 fairness_enable;
-	u8 rate_shaping_enable;
-	u8 cmng_protocol_enable;
-	u8 cmng_vn_enable;
-#elif defined(__LITTLE_ENDIAN)
-	u8 cmng_vn_enable;
-	u8 cmng_protocol_enable;
-	u8 rate_shaping_enable;
-	u8 fairness_enable;
-#endif
+	u32 cmng_enables;
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_VN (0x1<<0)
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_VN_SHIFT 0
+#define CMNG_FLAGS_PER_PORT_RATE_SHAPING_VN (0x1<<1)
+#define CMNG_FLAGS_PER_PORT_RATE_SHAPING_VN_SHIFT 1
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_PROTOCOL (0x1<<2)
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_PROTOCOL_SHIFT 2
+#define CMNG_FLAGS_PER_PORT_RATE_SHAPING_PROTOCOL (0x1<<3)
+#define CMNG_FLAGS_PER_PORT_RATE_SHAPING_PROTOCOL_SHIFT 3
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_COS (0x1<<4)
+#define CMNG_FLAGS_PER_PORT_FAIRNESS_COS_SHIFT 4
+#define __CMNG_FLAGS_PER_PORT_RESERVED0 (0x7FFFFFF<<5)
+#define __CMNG_FLAGS_PER_PORT_RESERVED0_SHIFT 5
 };
 
 
@@ -2803,6 +2805,7 @@ struct eth_stats_query {
  * per-vnic fairness variables
  */
 struct fairness_vars_per_vn {
+	u32 cos_credit_delta[MAX_COS_NUMBER];
 	u32 protocol_credit_delta[NUM_OF_PROTOCOLS];
 	u32 vn_credit_delta;
 	u32 __reserved0;
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 891a3fb..ce55e84 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2054,119 +2054,42 @@ static u8 bnx2x_link_test(struct bnx2x *bp)
 	return rc;
 }
 
-/* Calculates the sum of vn_min_rates.
-   It's needed for further normalizing of the min_rates.
-
-   Returns:
-     sum of vn_min_rates
-       or
-     0 - if all the min_rates are 0.
-     In the later case fairness algorithm should be deactivated.
-     If not all min_rates are zero then those that are zeroes will
-     be set to 1.
- */
-static u32 bnx2x_calc_vn_wsum(struct bnx2x *bp)
+static void bnx2x_init_port_minmax(struct bnx2x *bp)
 {
-	int i, port = BP_PORT(bp);
-	u32 wsum = 0;
-	int all_zero = 1;
+	u32 r_param = bp->link_vars.line_speed / 8;
+	u32 fair_periodic_timeout_usec;
+	u32 t_fair;
 
-	for (i = 0; i < E1HVN_MAX; i++) {
-		u32 vn_cfg =
-			SHMEM_RD(bp, mf_cfg.func_mf_config[2*i + port].config);
-		u32 vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
-				     FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
-		if (!(vn_cfg & FUNC_MF_CFG_FUNC_HIDE)) {
-			/* If min rate is zero - set it to 1 */
-			if (!vn_min_rate)
-				vn_min_rate = DEF_MIN_RATE;
-			else
-				all_zero = 0;
-
-			wsum += vn_min_rate;
-		}
-	}
+	memset(&(bp->cmng.rs_vars), 0,
+	       sizeof(struct rate_shaping_vars_per_port));
+	memset(&(bp->cmng.fair_vars), 0, sizeof(struct fairness_vars_per_port));
 
-	/* ... only if all min rates are zeros - disable FAIRNESS */
-	if (all_zero)
-		return 0;
-
-	return wsum;
-}
-
-static void bnx2x_init_port_minmax(struct bnx2x *bp,
-				   int en_fness,
-				   u16 port_rate,
-				   struct cmng_struct_per_port *m_cmng_port)
-{
-	u32 r_param = port_rate / 8;
-	int port = BP_PORT(bp);
-	int i;
-
-	memset(m_cmng_port, 0, sizeof(struct cmng_struct_per_port));
-
-	/* Enable minmax only if we are in e1hmf mode */
-	if (IS_E1HMF(bp)) {
-		u32 fair_periodic_timeout_usec;
-		u32 t_fair;
-
-		/* Enable rate shaping and fairness */
-		m_cmng_port->flags.cmng_vn_enable = 1;
-		m_cmng_port->flags.fairness_enable = en_fness ? 1 : 0;
-		m_cmng_port->flags.rate_shaping_enable = 1;
+	/* 100 usec in SDM ticks = 25 since each tick is 4 usec */
+	bp->cmng.rs_vars.rs_periodic_timeout = RS_PERIODIC_TIMEOUT_USEC / 4;
 
-		if (!en_fness)
-			DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
-			   "  fairness will be disabled\n");
-
-		/* 100 usec in SDM ticks = 25 since each tick is 4 usec */
-		m_cmng_port->rs_vars.rs_periodic_timeout =
-						RS_PERIODIC_TIMEOUT_USEC / 4;
-
-		/* this is the threshold below which no timer arming will occur
-		   1.25 coefficient is for the threshold to be a little bigger
-		   than the real time, to compensate for timer in-accuracy */
-		m_cmng_port->rs_vars.rs_threshold =
+	/* this is the threshold below which no timer arming will occur
+	   1.25 coefficient is for the threshold to be a little bigger
+	   than the real time, to compensate for timer in-accuracy */
+	bp->cmng.rs_vars.rs_threshold =
 				(RS_PERIODIC_TIMEOUT_USEC * r_param * 5) / 4;
 
-		/* resolution of fairness timer */
-		fair_periodic_timeout_usec = QM_ARB_BYTES / r_param;
-		/* for 10G it is 1000usec. for 1G it is 10000usec. */
-		t_fair = T_FAIR_COEF / port_rate;
+	/* resolution of fairness timer */
+	fair_periodic_timeout_usec = QM_ARB_BYTES / r_param;
+	/* for 10G it is 1000usec. for 1G it is 10000usec. */
+	t_fair = T_FAIR_COEF / bp->link_vars.line_speed;
 
-		/* this is the threshold below which we won't arm
-		   the timer anymore */
-		m_cmng_port->fair_vars.fair_threshold = QM_ARB_BYTES;
-
-		/* we multiply by 1e3/8 to get bytes/msec.
-		   We don't want the credits to pass a credit
-		   of the T_FAIR*FAIR_MEM (algorithm resolution) */
-		m_cmng_port->fair_vars.upper_bound =
-						r_param * t_fair * FAIR_MEM;
-		/* since each tick is 4 usec */
-		m_cmng_port->fair_vars.fairness_timeout =
-						fair_periodic_timeout_usec / 4;
-
-	} else {
-		/* Disable rate shaping and fairness */
-		m_cmng_port->flags.cmng_vn_enable = 0;
-		m_cmng_port->flags.fairness_enable = 0;
-		m_cmng_port->flags.rate_shaping_enable = 0;
+	/* this is the threshold below which we won't arm the timer anymore */
+	bp->cmng.fair_vars.fair_threshold = QM_ARB_BYTES;
 
-		DP(NETIF_MSG_IFUP,
-		   "Single function mode  minmax will be disabled\n");
-	}
-
-	/* Store it to internal memory */
-	for (i = 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
-		REG_WR(bp, BAR_XSTRORM_INTMEM +
-		       XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i * 4,
-		       ((u32 *)(m_cmng_port))[i]);
+	/* we multiply by 1e3/8 to get bytes/msec.
+	   We don't want the credits to pass a credit
+	   of the t_fair*FAIR_MEM (algorithm resolution) */
+	bp->cmng.fair_vars.upper_bound = r_param * t_fair * FAIR_MEM;
+	/* since each tick is 4 usec */
+	bp->cmng.fair_vars.fairness_timeout = fair_periodic_timeout_usec / 4;
 }
 
-static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func,
-				   u32 wsum, u16 port_rate,
-				 struct cmng_struct_per_port *m_cmng_port)
+static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func)
 {
 	struct rate_shaping_vars_per_vn m_rs_vn;
 	struct fairness_vars_per_vn m_fair_vn;
@@ -2182,17 +2105,18 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func,
 	} else {
 		vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
 				FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
-		/* If FAIRNESS is enabled (not all min rates are zeroes) and
+		/* If fairness is enabled (not all min rates are zeroes) and
 		   if current min rate is zero - set it to 1.
 		   This is a requirement of the algorithm. */
-		if ((vn_min_rate == 0) && wsum)
+		if (bp->vn_weight_sum && (vn_min_rate == 0))
 			vn_min_rate = DEF_MIN_RATE;
 		vn_max_rate = ((vn_cfg & FUNC_MF_CFG_MAX_BW_MASK) >>
 				FUNC_MF_CFG_MAX_BW_SHIFT) * 100;
 	}
 
-	DP(NETIF_MSG_IFUP, "func %d: vn_min_rate=%d  vn_max_rate=%d  "
-	   "wsum=%d\n", func, vn_min_rate, vn_max_rate, wsum);
+	DP(NETIF_MSG_IFUP,
+	   "func %d: vn_min_rate=%d  vn_max_rate=%d  vn_weight_sum=%d\n",
+	   func, vn_min_rate, vn_max_rate, bp->vn_weight_sum);
 
 	memset(&m_rs_vn, 0, sizeof(struct rate_shaping_vars_per_vn));
 	memset(&m_fair_vn, 0, sizeof(struct fairness_vars_per_vn));
@@ -2204,55 +2128,20 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func,
 	m_rs_vn.vn_counter.quota =
 				(vn_max_rate * RS_PERIODIC_TIMEOUT_USEC) / 8;
 
-#ifdef BNX2X_PER_PROT_QOS
-	/* per protocol counter */
-	for (protocol = 0; protocol < NUM_OF_PROTOCOLS; protocol++) {
-		/* maximal Mbps for this protocol */
-		m_rs_vn.protocol_counters[protocol].rate =
-						protocol_max_rate[protocol];
-		/* the quota in each timer period -
-		   number of bytes transmitted in this period */
-		m_rs_vn.protocol_counters[protocol].quota =
-			(u32)(rs_periodic_timeout_usec *
-			  ((double)m_rs_vn.
-				   protocol_counters[protocol].rate/8));
-	}
-#endif
-
-	if (wsum) {
+	if (bp->vn_weight_sum) {
 		/* credit for each period of the fairness algorithm:
 		   number of bytes in T_FAIR (the vn share the port rate).
-		   wsum should not be larger than 10000, thus
-		   T_FAIR_COEF / (8 * wsum) will always be grater than zero */
+		   vn_weight_sum should not be larger than 10000, thus
+		   T_FAIR_COEF / (8 * vn_weight_sum) will always be greater
+		   than zero */
 		m_fair_vn.vn_credit_delta =
-			max((u64)(vn_min_rate * (T_FAIR_COEF / (8 * wsum))),
-			    (u64)(m_cmng_port->fair_vars.fair_threshold * 2));
+			max((u32)(vn_min_rate * (T_FAIR_COEF /
+						 (8 * bp->vn_weight_sum))),
+			    (u32)(bp->cmng.fair_vars.fair_threshold * 2));
 		DP(NETIF_MSG_IFUP, "m_fair_vn.vn_credit_delta=%d\n",
 		   m_fair_vn.vn_credit_delta);
 	}
 
-#ifdef BNX2X_PER_PROT_QOS
-	do {
-		u32 protocolWeightSum = 0;
-
-		for (protocol = 0; protocol < NUM_OF_PROTOCOLS; protocol++)
-			protocolWeightSum +=
-					drvInit.protocol_min_rate[protocol];
-		/* per protocol counter -
-		   NOT NEEDED IF NO PER-PROTOCOL CONGESTION MANAGEMENT */
-		if (protocolWeightSum > 0) {
-			for (protocol = 0;
-			     protocol < NUM_OF_PROTOCOLS; protocol++)
-				/* credit for each period of the
-				   fairness algorithm - number of bytes in
-				   T_FAIR (the protocol share the vn rate) */
-				m_fair_vn.protocol_credit_delta[protocol] =
-					(u32)((vn_min_rate / 8) * t_fair *
-					protocol_min_rate / protocolWeightSum);
-		}
-	} while (0);
-#endif
-
 	/* Store it to internal memory */
 	for (i = 0; i < sizeof(struct rate_shaping_vars_per_vn)/4; i++)
 		REG_WR(bp, BAR_XSTRORM_INTMEM +
@@ -2265,11 +2154,10 @@ static void bnx2x_init_vn_minmax(struct bnx2x *bp, int func,
 		       ((u32 *)(&m_fair_vn))[i]);
 }
 
+
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
 {
-	int vn;
-
 	/* Make sure that we are synced with the current statistics */
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
@@ -2294,36 +2182,38 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	bnx2x_link_report(bp);
 
 	if (IS_E1HMF(bp)) {
+		int port = BP_PORT(bp);
 		int func;
+		int vn;
 
 		for (vn = VN_0; vn < E1HVN_MAX; vn++) {
 			if (vn == BP_E1HVN(bp))
 				continue;
 
-			func = ((vn << 1) | BP_PORT(bp));
+			func = ((vn << 1) | port);
 
 			/* Set the attention towards other drivers
 			   on the same port */
 			REG_WR(bp, MISC_REG_AEU_GENERAL_ATTN_0 +
 			       (LINK_SYNC_ATTENTION_BIT_FUNC_0 + func)*4, 1);
 		}
-	}
 
-	if (CHIP_IS_E1H(bp) && (bp->link_vars.line_speed > 0)) {
-		struct cmng_struct_per_port m_cmng_port;
-		u32 wsum;
-		int port = BP_PORT(bp);
+		if (bp->link_vars.link_up) {
+			int i;
+
+			/* Init rate shaping and fairness contexts */
+			bnx2x_init_port_minmax(bp);
 
-		/* Init RATE SHAPING and FAIRNESS contexts */
-		wsum = bnx2x_calc_vn_wsum(bp);
-		bnx2x_init_port_minmax(bp, (int)wsum,
-					bp->link_vars.line_speed,
-					&m_cmng_port);
-		if (IS_E1HMF(bp))
 			for (vn = VN_0; vn < E1HVN_MAX; vn++)
-				bnx2x_init_vn_minmax(bp, 2*vn + port,
-					wsum, bp->link_vars.line_speed,
-						     &m_cmng_port);
+				bnx2x_init_vn_minmax(bp, 2*vn + port);
+
+			/* Store it to internal memory */
+			for (i = 0;
+			     i < sizeof(struct cmng_struct_per_port) / 4; i++)
+				REG_WR(bp, BAR_XSTRORM_INTMEM +
+				  XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i*4,
+				       ((u32 *)(&bp->cmng))[i]);
+		}
 	}
 }
 
@@ -4848,6 +4738,47 @@ static void bnx2x_init_internal_port(struct bnx2x *bp)
 	REG_WR(bp, BAR_XSTRORM_INTMEM + XSTORM_HC_BTR_OFFSET(port), BNX2X_BTR);
 }
 
+/* Calculates the sum of vn_min_rates.
+   It's needed for further normalizing of the min_rates.
+   Returns:
+     sum of vn_min_rates.
+       or
+     0 - if all the min_rates are 0.
+     In the later case fainess algorithm should be deactivated.
+     If not all min_rates are zero then those that are zeroes will be set to 1.
+ */
+static void bnx2x_calc_vn_weight_sum(struct bnx2x *bp)
+{
+	int all_zero = 1;
+	int port = BP_PORT(bp);
+	int vn;
+
+	bp->vn_weight_sum = 0;
+	for (vn = VN_0; vn < E1HVN_MAX; vn++) {
+		int func = 2*vn + port;
+		u32 vn_cfg =
+			SHMEM_RD(bp, mf_cfg.func_mf_config[func].config);
+		u32 vn_min_rate = ((vn_cfg & FUNC_MF_CFG_MIN_BW_MASK) >>
+				   FUNC_MF_CFG_MIN_BW_SHIFT) * 100;
+
+		/* Skip hidden vns */
+		if (vn_cfg & FUNC_MF_CFG_FUNC_HIDE)
+			continue;
+
+		/* If min rate is zero - set it to 1 */
+		if (!vn_min_rate)
+			vn_min_rate = DEF_MIN_RATE;
+		else
+			all_zero = 0;
+
+		bp->vn_weight_sum += vn_min_rate;
+	}
+
+	/* ... only if all min rates are zeros - disable fairness */
+	if (all_zero)
+		bp->vn_weight_sum = 0;
+}
+
 static void bnx2x_init_internal_func(struct bnx2x *bp)
 {
 	struct tstorm_eth_function_common_config tstorm_config = {0};
@@ -4977,6 +4908,45 @@ static void bnx2x_init_internal_func(struct bnx2x *bp)
 			 USTORM_MAX_AGG_SIZE_OFFSET(port, FP_CL_ID(fp)),
 			 max_agg_size);
 	}
+
+	memset(&(bp->cmng), 0, sizeof(struct cmng_struct_per_port));
+
+	/* Init rate shaping and fairness contexts */
+	if (IS_E1HMF(bp)) {
+		int vn;
+
+		/* During init there is no active link
+		   Until link is up, set link rate to 10Gbps */
+		bp->link_vars.line_speed = SPEED_10000;
+		bnx2x_init_port_minmax(bp);
+
+		bnx2x_calc_vn_weight_sum(bp);
+
+		for (vn = VN_0; vn < E1HVN_MAX; vn++)
+			bnx2x_init_vn_minmax(bp, 2*vn + port);
+
+		/* Enable rate shaping and fairness */
+		bp->cmng.flags.cmng_enables =
+					CMNG_FLAGS_PER_PORT_RATE_SHAPING_VN;
+		if (bp->vn_weight_sum)
+			bp->cmng.flags.cmng_enables |=
+					CMNG_FLAGS_PER_PORT_FAIRNESS_VN;
+		else
+			DP(NETIF_MSG_IFUP, "All MIN values are zeroes"
+			   "  fairness will be disabled\n");
+	} else {
+		/* rate shaping and fairness are disabled */
+		DP(NETIF_MSG_IFUP,
+		   "single function mode  minmax will be disabled\n");
+	}
+
+
+	/* Store it to internal memory */
+	if (bp->port.pmf)
+		for (i = 0; i < sizeof(struct cmng_struct_per_port) / 4; i++)
+			REG_WR(bp, BAR_XSTRORM_INTMEM +
+			       XSTORM_CMNG_PER_PORT_VARS_OFFSET(port) + i * 4,
+			       ((u32 *)(&bp->cmng))[i]);
 }
 
 static void bnx2x_init_internal(struct bnx2x *bp, u32 load_code)
@@ -5780,22 +5750,10 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	REG_WR(bp, NIG_REG_XGXS_SERDES0_MODE_SEL + port*4, 1);
 
 	if (CHIP_IS_E1H(bp)) {
-		u32 wsum;
-		struct cmng_struct_per_port m_cmng_port;
-		int vn;
-
 		/* 0x2 disable e1hov, 0x1 enable */
 		REG_WR(bp, NIG_REG_LLH0_BRB1_DRV_MASK_MF + port*4,
 		       (IS_E1HMF(bp) ? 0x1 : 0x2));
 
-		/* Init RATE SHAPING and FAIRNESS contexts.
-		   Initialize as if there is 10G link. */
-		wsum = bnx2x_calc_vn_wsum(bp);
-		bnx2x_init_port_minmax(bp, (int)wsum, 10000, &m_cmng_port);
-		if (IS_E1HMF(bp))
-			for (vn = VN_0; vn < E1HVN_MAX; vn++)
-				bnx2x_init_vn_minmax(bp, 2*vn + port,
-					wsum, 10000, &m_cmng_port);
 	}
 
 	/* Port MCP comes here */
-- 
1.5.4.3




