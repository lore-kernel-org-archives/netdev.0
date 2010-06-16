From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 2/9] cxgb4: rearrange initialization code in preparation for EEH
Date: Wed, 16 Jun 2010 15:01:09 -0700
Message-ID: <1276725676-31514-3-git-send-email-dm@chelsio.com>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
 <1276725676-31514-2-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25992 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364Ab0FPWBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:17 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1HkA032118
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:17 -0700
In-Reply-To: <1276725676-31514-2-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Split some existing initialization code into a separate function for use
by EEH next.  No functional changes.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |  109 ++++++++++++++++++++++------------------
 1 files changed, 60 insertions(+), 49 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 58045b0..60f6ea0 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2709,6 +2709,65 @@ static void setup_memwin(struct adapter *adap)
 		     WINDOW(ilog2(MEMWIN2_APERTURE) - 10));
 }
 
+static int adap_init1(struct adapter *adap, struct fw_caps_config_cmd *c)
+{
+	u32 v;
+	int ret;
+
+	/* get device capabilities */
+	memset(c, 0, sizeof(*c));
+	c->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
+			       FW_CMD_REQUEST | FW_CMD_READ);
+	c->retval_len16 = htonl(FW_LEN16(*c));
+	ret = t4_wr_mbox(adap, 0, c, sizeof(*c), c);
+	if (ret < 0)
+		return ret;
+
+	/* select capabilities we'll be using */
+	if (c->niccaps & htons(FW_CAPS_CONFIG_NIC_VM)) {
+		if (!vf_acls)
+			c->niccaps ^= htons(FW_CAPS_CONFIG_NIC_VM);
+		else
+			c->niccaps = htons(FW_CAPS_CONFIG_NIC_VM);
+	} else if (vf_acls) {
+		dev_err(adap->pdev_dev, "virtualization ACLs not supported");
+		return ret;
+	}
+	c->op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
+			       FW_CMD_REQUEST | FW_CMD_WRITE);
+	ret = t4_wr_mbox(adap, 0, c, sizeof(*c), NULL);
+	if (ret < 0)
+		return ret;
+
+	ret = t4_config_glbl_rss(adap, 0,
+				 FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL,
+				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN |
+				 FW_RSS_GLB_CONFIG_CMD_TNLALLLKP);
+	if (ret < 0)
+		return ret;
+
+	ret = t4_cfg_pfvf(adap, 0, 0, 0, 64, 64, 64, 0, 0, 4, 0xf, 0xf, 16,
+			  FW_CMD_CAP_PF, FW_CMD_CAP_PF);
+	if (ret < 0)
+		return ret;
+
+	t4_sge_init(adap);
+
+	/* get basic stuff going */
+	ret = t4_early_init(adap, 0);
+	if (ret < 0)
+		return ret;
+
+	/* tweak some settings */
+	t4_write_reg(adap, TP_SHIFT_CNT, 0x64f8849);
+	t4_write_reg(adap, ULP_RX_TDDP_PSZ, HPZ0(PAGE_SHIFT - 12));
+	t4_write_reg(adap, TP_PIO_ADDR, TP_INGRESS_CONFIG);
+	v = t4_read_reg(adap, TP_PIO_DATA);
+	t4_write_reg(adap, TP_PIO_DATA, v & ~CSUM_HAS_PSEUDO_HDR);
+	setup_memwin(adap);
+	return 0;
+}
+
 /*
  * Max # of ATIDs.  The absolute HW max is 16K but we keep it lower.
  */
@@ -2746,43 +2805,6 @@ static int adap_init0(struct adapter *adap)
 	if (ret < 0)
 		goto bye;
 
-	/* get device capabilities */
-	memset(&c, 0, sizeof(c));
-	c.op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-			      FW_CMD_REQUEST | FW_CMD_READ);
-	c.retval_len16 = htonl(FW_LEN16(c));
-	ret = t4_wr_mbox(adap, 0, &c, sizeof(c), &c);
-	if (ret < 0)
-		goto bye;
-
-	/* select capabilities we'll be using */
-	if (c.niccaps & htons(FW_CAPS_CONFIG_NIC_VM)) {
-		if (!vf_acls)
-			c.niccaps ^= htons(FW_CAPS_CONFIG_NIC_VM);
-		else
-			c.niccaps = htons(FW_CAPS_CONFIG_NIC_VM);
-	} else if (vf_acls) {
-		dev_err(adap->pdev_dev, "virtualization ACLs not supported");
-		goto bye;
-	}
-	c.op_to_write = htonl(FW_CMD_OP(FW_CAPS_CONFIG_CMD) |
-			      FW_CMD_REQUEST | FW_CMD_WRITE);
-	ret = t4_wr_mbox(adap, 0, &c, sizeof(c), NULL);
-	if (ret < 0)
-		goto bye;
-
-	ret = t4_config_glbl_rss(adap, 0,
-				 FW_RSS_GLB_CONFIG_CMD_MODE_BASICVIRTUAL,
-				 FW_RSS_GLB_CONFIG_CMD_TNLMAPEN |
-				 FW_RSS_GLB_CONFIG_CMD_TNLALLLKP);
-	if (ret < 0)
-		goto bye;
-
-	ret = t4_cfg_pfvf(adap, 0, 0, 0, 64, 64, 64, 0, 0, 4, 0xf, 0xf, 16,
-			  FW_CMD_CAP_PF, FW_CMD_CAP_PF);
-	if (ret < 0)
-		goto bye;
-
 	for (v = 0; v < SGE_NTIMERS - 1; v++)
 		adap->sge.timer_val[v] = min(intr_holdoff[v], MAX_SGE_TIMERVAL);
 	adap->sge.timer_val[SGE_NTIMERS - 1] = MAX_SGE_TIMERVAL;
@@ -2790,10 +2812,7 @@ static int adap_init0(struct adapter *adap)
 	for (v = 1; v < SGE_NCOUNTERS; v++)
 		adap->sge.counter_val[v] = min(intr_cnt[v - 1],
 					       THRESHOLD_3_MASK);
-	t4_sge_init(adap);
-
-	/* get basic stuff going */
-	ret = t4_early_init(adap, 0);
+	ret = adap_init1(adap, &c);
 	if (ret < 0)
 		goto bye;
 
@@ -2876,14 +2895,6 @@ static int adap_init0(struct adapter *adap)
 	t4_read_mtu_tbl(adap, adap->params.mtus, NULL);
 	t4_load_mtus(adap, adap->params.mtus, adap->params.a_wnd,
 		     adap->params.b_wnd);
-
-	/* tweak some settings */
-	t4_write_reg(adap, TP_SHIFT_CNT, 0x64f8849);
-	t4_write_reg(adap, ULP_RX_TDDP_PSZ, HPZ0(PAGE_SHIFT - 12));
-	t4_write_reg(adap, TP_PIO_ADDR, TP_INGRESS_CONFIG);
-	v = t4_read_reg(adap, TP_PIO_DATA);
-	t4_write_reg(adap, TP_PIO_DATA, v & ~CSUM_HAS_PSEUDO_HDR);
-	setup_memwin(adap);
 	return 0;
 
 	/*
-- 
1.5.4

