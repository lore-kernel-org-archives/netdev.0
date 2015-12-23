From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/9] cxgb4: Update register range and SGE registers for T6 adapter
Date: Wed, 23 Dec 2015 22:47:14 +0530
Message-ID: <1450891039-17196-5-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:38243 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933052AbbLWRQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:05 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  5 +++--
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 15 +++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 16 +++++++++++-----
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |  3 +++
 4 files changed, 30 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2642593..c0dd533 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4855,8 +4855,9 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* configure SGE_STAT_CFG_A to read WC stats */
 	if (!is_t4(adapter->params.chip))
-		t4_write_reg(adapter, SGE_STAT_CFG_A,
-			     STATSOURCE_T5_V(7) | STATMODE_V(0));
+		t4_write_reg(adapter, SGE_STAT_CFG_A, STATSOURCE_T5_V(7) |
+			     (is_t5(adapter->params.chip) ? STATMODE_V(0) :
+			      T6_STATMODE_V(0)));
 
 	for_each_port(adapter, i) {
 		struct net_device *netdev;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 099b946..5829c9c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -3202,10 +3202,21 @@ int t4_sge_init(struct adapter *adap)
 	 * buffers.
 	 */
 	sge_conm_ctrl = t4_read_reg(adap, SGE_CONM_CTRL_A);
-	if (is_t4(adap->params.chip))
+	switch (CHELSIO_CHIP_VERSION(adap->params.chip)) {
+	case CHELSIO_T4:
 		egress_threshold = EGRTHRESHOLD_G(sge_conm_ctrl);
-	else
+		break;
+	case CHELSIO_T5:
 		egress_threshold = EGRTHRESHOLDPACKING_G(sge_conm_ctrl);
+		break;
+	case CHELSIO_T6:
+		egress_threshold = T6_EGRTHRESHOLDPACKING_G(sge_conm_ctrl);
+		break;
+	default:
+		dev_err(adap->pdev_dev, "Unsupported Chip version %d\n",
+			CHELSIO_CHIP_VERSION(adap->params.chip));
+		return -EINVAL;
+	}
 	s->fl_starve_thres = 2*egress_threshold + 1;
 
 	t4_idma_monitor_init(adap, &s->idma_monitor);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 42754c0..c613bd6 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1942,8 +1942,12 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x1190, 0x1194,
 		0x11a0, 0x11a4,
 		0x11b0, 0x11b4,
-		0x11fc, 0x1254,
-		0x1280, 0x133c,
+		0x11fc, 0x1258,
+		0x1280, 0x12d4,
+		0x12d9, 0x12d9,
+		0x12de, 0x12de,
+		0x12e3, 0x12e3,
+		0x12e8, 0x133c,
 		0x1800, 0x18fc,
 		0x3000, 0x302c,
 		0x3060, 0x30b0,
@@ -1973,7 +1977,7 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x5e50, 0x5e94,
 		0x5ea0, 0x5eb0,
 		0x5ec0, 0x5ec0,
-		0x5ec8, 0x5ecc,
+		0x5ec8, 0x5ed0,
 		0x6000, 0x6020,
 		0x6028, 0x6040,
 		0x6058, 0x609c,
@@ -2048,7 +2052,8 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x19150, 0x19194,
 		0x1919c, 0x191b0,
 		0x191d0, 0x191e8,
-		0x19238, 0x192b0,
+		0x19238, 0x19290,
+		0x192a4, 0x192b0,
 		0x192bc, 0x192bc,
 		0x19348, 0x1934c,
 		0x193f8, 0x19418,
@@ -2442,7 +2447,8 @@ void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size)
 		0x40280, 0x40280,
 		0x40304, 0x40304,
 		0x40330, 0x4033c,
-		0x41304, 0x413c8,
+		0x41304, 0x413b8,
+		0x413c0, 0x413c8,
 		0x413d0, 0x413dc,
 		0x413f0, 0x413f0,
 		0x41400, 0x4140c,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 91b52a2..0971cc4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -492,6 +492,9 @@
 #define STATSOURCE_T5_V(x) ((x) << STATSOURCE_T5_S)
 #define STATSOURCE_T5_G(x) (((x) >> STATSOURCE_T5_S) & STATSOURCE_T5_M)
 
+#define T6_STATMODE_S    0
+#define T6_STATMODE_V(x) ((x) << T6_STATMODE_S)
+
 #define SGE_DBFIFO_STATUS2_A 0x1118
 
 #define HP_INT_THRESH_T5_S    10
-- 
2.3.4
