From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next v3 1/6] bnx2x: link report improvements
Date: Thu, 5 May 2011 12:48:23 +0300
Message-ID: <1304588903.17528.1.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3367 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751515Ab1EEJ7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 05:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>

To avoid link notification duplication

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/bnx2x/bnx2x.h      |   21 +++++++
 drivers/net/bnx2x/bnx2x_cmn.c  |  129 +++++++++++++++++++++++++++++++++-------
 drivers/net/bnx2x/bnx2x_cmn.h  |    5 +-
 drivers/net/bnx2x/bnx2x_main.c |   21 +++----
 4 files changed, 141 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 9e87417..1a005a4 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -893,6 +893,22 @@ typedef enum {
 	(&bp->def_status_blk->sp_sb.\
 	index_values[HC_SP_INDEX_EQ_CONS])
 
+/* This is a data that will be used to create a link report message.
+ * We will keep the data used for the last link report in order
+ * to prevent reporting the same link parameters twice.
+ */
+struct bnx2x_link_report_data {
+	u16 line_speed;			/* Effective line speed */
+	unsigned long link_report_flags;/* BNX2X_LINK_REPORT_XXX flags */
+};
+
+enum {
+	BNX2X_LINK_REPORT_FD,		/* Full DUPLEX */
+	BNX2X_LINK_REPORT_LINK_DOWN,
+	BNX2X_LINK_REPORT_RX_FC_ON,
+	BNX2X_LINK_REPORT_TX_FC_ON,
+};
+
 struct bnx2x {
 	/* Fields used in the tx and intr/napi performance paths
 	 * are grouped together in the beginning of the structure
@@ -1025,6 +1041,9 @@ struct bnx2x {
 
 	struct link_params	link_params;
 	struct link_vars	link_vars;
+	u32			link_cnt;
+	struct bnx2x_link_report_data last_reported_link;
+
 	struct mdio_if_info	mdio;
 
 	struct bnx2x_common	common;
@@ -1441,6 +1460,8 @@ struct bnx2x_func_init_params {
 #define WAIT_RAMROD_POLL	0x01
 #define WAIT_RAMROD_COMMON	0x02
 
+void bnx2x_read_mf_cfg(struct bnx2x *bp);
+
 /* dmae */
 void bnx2x_read_dmae(struct bnx2x *bp, u32 src_addr, u32 len32);
 void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 8729061..d168eb2 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -758,35 +758,119 @@ u16 bnx2x_get_mf_speed(struct bnx2x *bp)
 	return line_speed;
 }
 
+/**
+ * bnx2x_fill_report_data - fill link report data to report
+ *
+ * @bp:		driver handle
+ * @data:	link state to update
+ *
+ * It uses a none-atomic bit operations because is called under the mutex.
+ */
+static inline void bnx2x_fill_report_data(struct bnx2x *bp,
+					  struct bnx2x_link_report_data *data)
+{
+	u16 line_speed = bnx2x_get_mf_speed(bp);
+
+	memset(data, 0, sizeof(*data));
+
+	/* Fill the report data: efective line speed */
+	data->line_speed = line_speed;
+
+	/* Link is down */
+	if (!bp->link_vars.link_up || (bp->flags & MF_FUNC_DIS))
+		__set_bit(BNX2X_LINK_REPORT_LINK_DOWN,
+			  &data->link_report_flags);
+
+	/* Full DUPLEX */
+	if (bp->link_vars.duplex == DUPLEX_FULL)
+		__set_bit(BNX2X_LINK_REPORT_FD, &data->link_report_flags);
+
+	/* Rx Flow Control is ON */
+	if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX)
+		__set_bit(BNX2X_LINK_REPORT_RX_FC_ON, &data->link_report_flags);
+
+	/* Tx Flow Control is ON */
+	if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_TX)
+		__set_bit(BNX2X_LINK_REPORT_TX_FC_ON, &data->link_report_flags);
+}
+
+/**
+ * bnx2x_link_report - report link status to OS.
+ *
+ * @bp:		driver handle
+ *
+ * Calls the __bnx2x_link_report() under the same locking scheme
+ * as a link/PHY state managing code to ensure a consistent link
+ * reporting.
+ */
+
 void bnx2x_link_report(struct bnx2x *bp)
 {
-	if (bp->flags & MF_FUNC_DIS) {
-		netif_carrier_off(bp->dev);
-		netdev_err(bp->dev, "NIC Link is Down\n");
-		return;
-	}
+	bnx2x_acquire_phy_lock(bp);
+	__bnx2x_link_report(bp);
+	bnx2x_release_phy_lock(bp);
+}
 
-	if (bp->link_vars.link_up) {
-		u16 line_speed;
+/**
+ * __bnx2x_link_report - report link status to OS.
+ *
+ * @bp:		driver handle
+ *
+ * None atomic inmlementation.
+ * Should be called under the phy_lock.
+ */
+void __bnx2x_link_report(struct bnx2x *bp)
+{
+	struct bnx2x_link_report_data cur_data;
 
-		if (bp->state == BNX2X_STATE_OPEN)
-			netif_carrier_on(bp->dev);
-		netdev_info(bp->dev, "NIC Link is Up, ");
+	/* reread mf_cfg */
+	if (!CHIP_IS_E1(bp))
+		bnx2x_read_mf_cfg(bp);
+
+	/* Read the current link report info */
+	bnx2x_fill_report_data(bp, &cur_data);
+
+	/* Don't report link down or exactly the same link status twice */
+	if (!memcmp(&cur_data, &bp->last_reported_link, sizeof(cur_data)) ||
+	    (test_bit(BNX2X_LINK_REPORT_LINK_DOWN,
+		      &bp->last_reported_link.link_report_flags) &&
+	     test_bit(BNX2X_LINK_REPORT_LINK_DOWN,
+		      &cur_data.link_report_flags)))
+		return;
+
+	bp->link_cnt++;
 
-		line_speed = bnx2x_get_mf_speed(bp);
+	/* We are going to report a new link parameters now -
+	 * remember the current data for the next time.
+	 */
+	memcpy(&bp->last_reported_link, &cur_data, sizeof(cur_data));
 
-		pr_cont("%d Mbps ", line_speed);
+	if (test_bit(BNX2X_LINK_REPORT_LINK_DOWN,
+		     &cur_data.link_report_flags)) {
+		netif_carrier_off(bp->dev);
+		netdev_err(bp->dev, "NIC Link is Down\n");
+		return;
+	} else {
+		netif_carrier_on(bp->dev);
+		netdev_info(bp->dev, "NIC Link is Up, ");
+		pr_cont("%d Mbps ", cur_data.line_speed);
 
-		if (bp->link_vars.duplex == DUPLEX_FULL)
+		if (test_and_clear_bit(BNX2X_LINK_REPORT_FD,
+				       &cur_data.link_report_flags))
 			pr_cont("full duplex");
 		else
 			pr_cont("half duplex");
 
-		if (bp->link_vars.flow_ctrl != BNX2X_FLOW_CTRL_NONE) {
-			if (bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX) {
+		/* Handle the FC at the end so that only these flags would be
+		 * possibly set. This way we may easily check if there is no FC
+		 * enabled.
+		 */
+		if (cur_data.link_report_flags) {
+			if (test_bit(BNX2X_LINK_REPORT_RX_FC_ON,
+				     &cur_data.link_report_flags)) {
 				pr_cont(", receive ");
-				if (bp->link_vars.flow_ctrl &
-				    BNX2X_FLOW_CTRL_TX)
+				if (test_bit(BNX2X_LINK_REPORT_TX_FC_ON,
+				     &cur_data.link_report_flags))
 					pr_cont("& transmit ");
 			} else {
 				pr_cont(", transmit ");
@@ -794,10 +878,6 @@ void bnx2x_link_report(struct bnx2x *bp)
 			pr_cont("flow control ON");
 		}
 		pr_cont("\n");
-
-	} else { /* link_down */
-		netif_carrier_off(bp->dev);
-		netdev_err(bp->dev, "NIC Link is Down\n");
 	}
 }
 
@@ -1345,6 +1425,13 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	bp->state = BNX2X_STATE_OPENING_WAIT4_LOAD;
 
+	/* Set the initial link reported state to link down */
+	bnx2x_acquire_phy_lock(bp);
+	memset(&bp->last_reported_link, 0, sizeof(bp->last_reported_link));
+	__set_bit(BNX2X_LINK_REPORT_LINK_DOWN,
+		&bp->last_reported_link.link_report_flags);
+	bnx2x_release_phy_lock(bp);
+
 	/* must be called before memory allocation and HW init */
 	bnx2x_ilt_set_info(bp);
 
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 1cdab69..007f294 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -67,11 +67,12 @@ void bnx2x__link_status_update(struct bnx2x *bp);
  * Report link status to upper layer
  *
  * @param bp
- *
- * @return int
  */
 void bnx2x_link_report(struct bnx2x *bp);
 
+/* None-atomic version of bnx2x_link_report() */
+void __bnx2x_link_report(struct bnx2x *bp);
+
 /**
  * calculates MF speed according to current linespeed and MF
  * configuration
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index bfd7ac9..3f4ff41 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2036,7 +2036,7 @@ static int bnx2x_get_cmng_fns_mode(struct bnx2x *bp)
 	return CMNG_FNS_NONE;
 }
 
-static void bnx2x_read_mf_cfg(struct bnx2x *bp)
+void bnx2x_read_mf_cfg(struct bnx2x *bp)
 {
 	int vn, n = (CHIP_MODE_IS_4_PORT(bp) ? 2 : 1);
 
@@ -2123,7 +2123,6 @@ static inline void bnx2x_link_sync_notify(struct bnx2x *bp)
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
 {
-	u32 prev_link_status = bp->link_vars.link_status;
 	/* Make sure that we are synced with the current statistics */
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
@@ -2168,17 +2167,15 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 			   "single function mode without fairness\n");
 	}
 
+	__bnx2x_link_report(bp);
+
 	if (IS_MF(bp))
 		bnx2x_link_sync_notify(bp);
-
-	/* indicate link status only if link status actually changed */
-	if (prev_link_status != bp->link_vars.link_status)
-		bnx2x_link_report(bp);
 }
 
 void bnx2x__link_status_update(struct bnx2x *bp)
 {
-	if ((bp->state != BNX2X_STATE_OPEN) || (bp->flags & MF_FUNC_DIS))
+	if (bp->state != BNX2X_STATE_OPEN)
 		return;
 
 	bnx2x_link_status_update(&bp->link_params, &bp->link_vars);
@@ -2188,10 +2185,6 @@ void bnx2x__link_status_update(struct bnx2x *bp)
 	else
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
-	/* the link status update could be the result of a DCC event
-	   hence re-read the shmem mf configuration */
-	bnx2x_read_mf_cfg(bp);
-
 	/* indicate link status */
 	bnx2x_link_report(bp);
 }
@@ -3120,10 +3113,14 @@ static inline void bnx2x_attn_int_deasserted3(struct bnx2x *bp, u32 attn)
 			if (val & DRV_STATUS_SET_MF_BW)
 				bnx2x_set_mf_bw(bp);
 
-			bnx2x__link_status_update(bp);
 			if ((bp->port.pmf == 0) && (val & DRV_STATUS_PMF))
 				bnx2x_pmf_update(bp);
 
+			/* Always call it here: bnx2x_link_report() will
+			 * prevent the link indication duplication.
+			 */
+			bnx2x__link_status_update(bp);
+
 			if (bp->port.pmf &&
 			    (val & DRV_STATUS_DCBX_NEGOTIATION_RESULTS) &&
 				bp->dcbx_enabled > 0)
-- 
1.7.2.2




