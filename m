From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 4/5] cxgb3: differentiate portx and Tx channels
Date: Thu, 26 Mar 2009 19:39:24 -0700
Message-ID: <20090327023924.32137.21445.stgit@speedy5>
References: <20090327023909.32137.93884.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:31276 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755770AbZC0Cj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 22:39:27 -0400
In-Reply-To: <20090327023909.32137.93884.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Separate ports from H/W Tx channels.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    4 +++-
 drivers/net/cxgb3/cxgb3_main.c |    4 ++--
 drivers/net/cxgb3/t3_hw.c      |   35 +++++++++++++++++++----------------
 3 files changed, 24 insertions(+), 19 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 9ee021e..e508dc3 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -191,7 +191,8 @@ struct mdio_ops {
 };
 
 struct adapter_info {
-	unsigned char nports;	/* # of ports */
+	unsigned char nports0;        /* # of ports on channel 0 */
+	unsigned char nports1;        /* # of ports on channel 1 */
 	unsigned char phy_base_addr;	/* MDIO PHY base address */
 	unsigned int gpio_out;	/* GPIO output settings */
 	unsigned char gpio_intr[MAX_NPORTS]; /* GPIO PHY IRQ pins */
@@ -422,6 +423,7 @@ struct adapter_params {
 	unsigned short b_wnd[NCCTRL_WIN];
 
 	unsigned int nports;	/* # of ethernet ports */
+	unsigned int chan_map;  /* bitmap of in-use Tx channels */
 	unsigned int stats_update_period;	/* MAC stats accumulation period */
 	unsigned int linkpoll_period;	/* link poll period in 0.1s */
 	unsigned int rev;	/* chip revision */
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
old mode 100755
new mode 100644
index e2b1193..2c2aaa7
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -3086,7 +3086,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 	INIT_WORK(&adapter->fatal_error_handler_task, fatal_error_task);
 	INIT_DELAYED_WORK(&adapter->adap_check_task, t3_adap_check_task);
 
-	for (i = 0; i < ai->nports; ++i) {
+	for (i = 0; i < ai->nports0 + ai->nports1; ++i) {
 		struct net_device *netdev;
 
 		netdev = alloc_etherdev_mq(sizeof(struct port_info), SGE_QSETS);
@@ -3176,7 +3176,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 out_free_dev:
 	iounmap(adapter->regs);
-	for (i = ai->nports - 1; i >= 0; --i)
+	for (i = ai->nports0 + ai->nports1 - 1; i >= 0; --i)
 		if (adapter->port[i])
 			free_netdev(adapter->port[i]);
 
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
old mode 100755
new mode 100644
index 7d8fbae..31ed31a
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -493,20 +493,20 @@ int t3_phy_lasi_intr_handler(struct cphy *phy)
 }
 
 static const struct adapter_info t3_adap_info[] = {
-	{2, 0,
+	{1, 1, 0,
 	 F_GPIO2_OEN | F_GPIO4_OEN |
 	 F_GPIO2_OUT_VAL | F_GPIO4_OUT_VAL, { S_GPIO3, S_GPIO5 }, 0,
 	 &mi1_mdio_ops, "Chelsio PE9000"},
-	{2, 0,
+	{1, 1, 0,
 	 F_GPIO2_OEN | F_GPIO4_OEN |
 	 F_GPIO2_OUT_VAL | F_GPIO4_OUT_VAL, { S_GPIO3, S_GPIO5 }, 0,
 	 &mi1_mdio_ops, "Chelsio T302"},
-	{1, 0,
+	{1, 0, 0,
 	 F_GPIO1_OEN | F_GPIO6_OEN | F_GPIO7_OEN | F_GPIO10_OEN |
 	 F_GPIO11_OEN | F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL,
 	 { 0 }, SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
 	 &mi1_mdio_ext_ops, "Chelsio T310"},
-	{2, 0,
+	{1, 1, 0,
 	 F_GPIO1_OEN | F_GPIO2_OEN | F_GPIO4_OEN | F_GPIO5_OEN | F_GPIO6_OEN |
 	 F_GPIO7_OEN | F_GPIO10_OEN | F_GPIO11_OEN | F_GPIO1_OUT_VAL |
 	 F_GPIO5_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL,
@@ -514,7 +514,7 @@ static const struct adapter_info t3_adap_info[] = {
 	 &mi1_mdio_ext_ops, "Chelsio T320"},
 	{},
 	{},
-	{1, 0,
+	{1, 0, 0,
 	 F_GPIO1_OEN | F_GPIO2_OEN | F_GPIO4_OEN | F_GPIO6_OEN | F_GPIO7_OEN |
 	 F_GPIO10_OEN | F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL,
 	 { S_GPIO9 }, SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
@@ -3227,20 +3227,22 @@ int t3_mps_set_active_ports(struct adapter *adap, unsigned int port_mask)
 }
 
 /*
- * Perform the bits of HW initialization that are dependent on the number
- * of available ports.
+ * Perform the bits of HW initialization that are dependent on the Tx
+ * channels being used.
  */
-static void init_hw_for_avail_ports(struct adapter *adap, int nports)
+static void chan_init_hw(struct adapter *adap, unsigned int chan_map)
 {
 	int i;
 
-	if (nports == 1) {
+	if (chan_map != 3) {                                 /* one channel */
 		t3_set_reg_field(adap, A_ULPRX_CTL, F_ROUND_ROBIN, 0);
 		t3_set_reg_field(adap, A_ULPTX_CONFIG, F_CFG_RR_ARB, 0);
-		t3_write_reg(adap, A_MPS_CFG, F_TPRXPORTEN | F_TPTXPORT0EN |
-			     F_PORT0ACTIVE | F_ENFORCEPKT);
-		t3_write_reg(adap, A_PM1_TX_CFG, 0xffffffff);
-	} else {
+		t3_write_reg(adap, A_MPS_CFG, F_TPRXPORTEN | F_ENFORCEPKT |
+			     (chan_map == 1 ? F_TPTXPORT0EN | F_PORT0ACTIVE :
+					      F_TPTXPORT1EN | F_PORT1ACTIVE));
+		t3_write_reg(adap, A_PM1_TX_CFG,
+			     chan_map == 1 ? 0xffffffff : 0);
+	} else {                                             /* two channels */
 		t3_set_reg_field(adap, A_ULPRX_CTL, 0, F_ROUND_ROBIN);
 		t3_set_reg_field(adap, A_ULPTX_CONFIG, 0, F_CFG_RR_ARB);
 		t3_write_reg(adap, A_ULPTX_DMA_WEIGHT,
@@ -3548,7 +3550,7 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 	t3_write_reg(adapter, A_PM1_RX_CFG, 0xffffffff);
 	t3_write_reg(adapter, A_PM1_RX_MODE, 0);
 	t3_write_reg(adapter, A_PM1_TX_MODE, 0);
-	init_hw_for_avail_ports(adapter, adapter->params.nports);
+	chan_init_hw(adapter, adapter->params.chan_map);
 	t3_sge_init(adapter, &adapter->params.sge);
 
 	t3_write_reg(adapter, A_T3DBG_GPIO_ACT_LOW, calc_gpio_intr(adapter));
@@ -3785,7 +3787,8 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 	get_pci_mode(adapter, &adapter->params.pci);
 
 	adapter->params.info = ai;
-	adapter->params.nports = ai->nports;
+	adapter->params.nports = ai->nports0 + ai->nports1;
+	adapter->params.chan_map = !!ai->nports0 | (!!ai->nports1 << 1);
 	adapter->params.rev = t3_read_reg(adapter, A_PL_REV);
 	/*
 	 * We used to only run the "adapter check task" once a second if
@@ -3816,7 +3819,7 @@ int t3_prep_adapter(struct adapter *adapter, const struct adapter_info *ai,
 		mc7_prep(adapter, &adapter->pmtx, MC7_PMTX_BASE_ADDR, "PMTX");
 		mc7_prep(adapter, &adapter->cm, MC7_CM_BASE_ADDR, "CM");
 
-		p->nchan = ai->nports;
+		p->nchan = adapter->params.chan_map == 3 ? 2 : 1;
 		p->pmrx_size = t3_mc7_size(&adapter->pmrx);
 		p->pmtx_size = t3_mc7_size(&adapter->pmtx);
 		p->cm_size = t3_mc7_size(&adapter->cm);

