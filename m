From: divy@chelsio.com
Subject: [PATCH 2.6.21 2/4] cxgb3 - detect NIC only adapters
Date: Sat, 31 Mar 2007 00:23:19 -0700
Message-ID: <20070331072319.4712.39031.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:20269 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267AbXCaHXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Mar 2007 03:23:23 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Differentiate NIC only adapters from RNICs.
Initialize offload capabilities for RNICs only.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h     |    6 +++---
 drivers/net/cxgb3/cxgb3_main.c |    8 ++++----
 drivers/net/cxgb3/mc5.c        |    3 +++
 drivers/net/cxgb3/sge.c        |    2 +-
 drivers/net/cxgb3/t3_hw.c      |   24 ++++++++++++++++++------
 5 files changed, 29 insertions(+), 14 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 38a0565..97128d8 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -112,8 +112,7 @@ enum {
 };
 
 enum {
-	SUPPORTED_OFFLOAD = 1 << 24,
-	SUPPORTED_IRQ = 1 << 25
+	SUPPORTED_IRQ      = 1 << 24
 };
 
 enum {				/* adapter interrupt-maintained statistics */
@@ -405,6 +404,7 @@ struct adapter_params {
 	unsigned int stats_update_period;	/* MAC stats accumulation period */
 	unsigned int linkpoll_period;	/* link poll period in 0.1s */
 	unsigned int rev;	/* chip revision */
+	unsigned int offload;
 };
 
 enum {					    /* chip revisions */
@@ -605,7 +605,7 @@ static inline int is_10G(const struct ad
 
 static inline int is_offload(const struct adapter *adap)
 {
-	return adapter_info(adap)->caps & SUPPORTED_OFFLOAD;
+	return adap->params.offload;
 }
 
 static inline unsigned int core_ticks_per_usec(const struct adapter *adap)
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index b82544e..145b67c 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -407,7 +407,7 @@ static void quiesce_rx(struct adapter *a
 static int setup_sge_qsets(struct adapter *adap)
 {
 	int i, j, err, irq_idx = 0, qset_idx = 0, dummy_dev_idx = 0;
-	unsigned int ntxq = is_offload(adap) ? SGE_TXQ_PER_SET : 1;
+	unsigned int ntxq = SGE_TXQ_PER_SET;
 
 	if (adap->params.rev > 0 && !(adap->flags & USING_MSI))
 		irq_idx = -1;
@@ -922,7 +922,7 @@ static int cxgb_open(struct net_device *
 		return err;
 
 	set_bit(pi->port_id, &adapter->open_device_map);
-	if (!ofld_disable) {
+	if (is_offload(adapter) && !ofld_disable) {
 		err = offload_open(dev);
 		if (err)
 			printk(KERN_WARNING
@@ -2270,9 +2270,9 @@ static void __devinit print_port_info(st
 
 		if (!test_bit(i, &adap->registered_device_map))
 			continue;
-		printk(KERN_INFO "%s: %s %s RNIC (rev %d) %s%s\n",
+		printk(KERN_INFO "%s: %s %s %sNIC (rev %d) %s%s\n",
 		       dev->name, ai->desc, pi->port_type->desc,
-		       adap->params.rev, buf,
+		       is_offload(adap) ? "R" : "", adap->params.rev, buf,
 		       (adap->flags & USING_MSIX) ? " MSI-X" :
 		       (adap->flags & USING_MSI) ? " MSI" : "");
 		if (adap->name == dev->name && adap->params.vpd.mclk)
diff --git a/drivers/net/cxgb3/mc5.c b/drivers/net/cxgb3/mc5.c
index 644d62e..84c1ffa 100644
--- a/drivers/net/cxgb3/mc5.c
+++ b/drivers/net/cxgb3/mc5.c
@@ -328,6 +328,9 @@ int t3_mc5_init(struct mc5 *mc5, unsigne
 	unsigned int tcam_size = mc5->tcam_size;
 	struct adapter *adap = mc5->adapter;
 
+	if (!tcam_size)
+		return 0;
+
 	if (nroutes > MAX_ROUTES || nroutes + nservers + nfilters > tcam_size)
 		return -EINVAL;
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c237834..027ab2c 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2631,7 +2631,7 @@ int t3_sge_alloc_qset(struct adapter *ad
 	q->txq[TXQ_ETH].stop_thres = nports *
 	    flits_to_desc(sgl_len(MAX_SKB_FRAGS + 1) + 3);
 
-	if (ntxq == 1) {
+	if (!is_offload(adapter)) {
 #ifdef USE_RX_PAGE
 		q->fl[0].buf_size = RX_PAGE_SIZE;
 #else
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 791ed6d..d83f075 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -438,23 +438,23 @@ static const struct adapter_info t3_adap
 	{2, 0, 0, 0,
 	 F_GPIO2_OEN | F_GPIO4_OEN |
 	 F_GPIO2_OUT_VAL | F_GPIO4_OUT_VAL, F_GPIO3 | F_GPIO5,
-	 SUPPORTED_OFFLOAD,
+	 0,
 	 &mi1_mdio_ops, "Chelsio PE9000"},
 	{2, 0, 0, 0,
 	 F_GPIO2_OEN | F_GPIO4_OEN |
 	 F_GPIO2_OUT_VAL | F_GPIO4_OUT_VAL, F_GPIO3 | F_GPIO5,
-	 SUPPORTED_OFFLOAD,
+	 0,
 	 &mi1_mdio_ops, "Chelsio T302"},
 	{1, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO6_OEN | F_GPIO7_OEN | F_GPIO10_OEN |
 	 F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL, 0,
-	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_OFFLOAD,
+	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
 	 &mi1_mdio_ext_ops, "Chelsio T310"},
 	{2, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO2_OEN | F_GPIO4_OEN | F_GPIO5_OEN | F_GPIO6_OEN |
 	 F_GPIO7_OEN | F_GPIO10_OEN | F_GPIO11_OEN | F_GPIO1_OUT_VAL |
 	 F_GPIO5_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL, 0,
-	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_OFFLOAD,
+	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
 	 &mi1_mdio_ext_ops, "Chelsio T320"},
 };
 
@@ -2900,6 +2900,9 @@ static int mc7_init(struct mc7 *mc7, uns
 	struct adapter *adapter = mc7->adapter;
 	const struct mc7_timing_params *p = &mc7_timings[mem_type];
 
+	if (!mc7->size)
+		return 0;
+
 	val = t3_read_reg(adapter, mc7->offset + A_MC7_CFG);
 	slow = val & F_SLOW;
 	width = G_WIDTH(val);
@@ -3100,8 +3103,10 @@ int t3_init_hw(struct adapter *adapter,
 	do {			/* wait for uP to initialize */
 		msleep(20);
 	} while (t3_read_reg(adapter, A_CIM_HOST_ACC_DATA) && --attempts);
-	if (!attempts)
+	if (!attempts) {
+		CH_ERR(adapter, "uP initialization timed out\n");
 		goto out_err;
+	}
 
 	err = 0;
 out_err:
@@ -3201,7 +3206,7 @@ static void __devinit mc7_prep(struct ad
 	mc7->name = name;
 	mc7->offset = base_addr - MC7_PMRX_BASE_ADDR;
 	cfg = t3_read_reg(adapter, mc7->offset + A_MC7_CFG);
-	mc7->size = mc7_calc_size(cfg);
+	mc7->size = mc7->size = G_DEN(cfg) == M_DEN ? 0 : mc7_calc_size(cfg);
 	mc7->width = G_WIDTH(cfg);
 }
 
@@ -3228,6 +3233,7 @@ void early_hw_init(struct adapter *adapt
 		     V_I2C_CLKDIV(adapter->params.vpd.cclk / 80 - 1));
 	t3_write_reg(adapter, A_T3DBG_GPIO_EN,
 		     ai->gpio_out | F_GPIO0_OEN | F_GPIO0_OUT_VAL);
+	t3_write_reg(adapter, A_MC5_DB_SERVER_INDEX, 0);
 
 	if (adapter->params.rev == 0 || !uses_xaui(adapter))
 		val |= F_ENRGMII;
@@ -3326,7 +3332,13 @@ int __devinit t3_prep_adapter(struct ada
 		p->tx_num_pgs = pm_num_pages(p->chan_tx_size, p->tx_pg_size);
 		p->ntimer_qs = p->cm_size >= (128 << 20) ||
 		    adapter->params.rev > 0 ? 12 : 6;
+	}
+
+	adapter->params.offload = t3_mc7_size(&adapter->pmrx) &&
+				  t3_mc7_size(&adapter->pmtx) &&
+				  t3_mc7_size(&adapter->cm);
 
+	if (is_offload(adapter)) {
 		adapter->params.mc5.nservers = DEFAULT_NSERVERS;
 		adapter->params.mc5.nfilters = adapter->params.rev > 0 ?
 		    DEFAULT_NFILTERS : 0;
