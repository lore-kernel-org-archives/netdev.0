From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 1/2] drivers: net: xgene: fix: Derive prefetch number from irq
Date: Tue,  8 Mar 2016 21:49:36 -0800
Message-ID: <1457502577-2606-2-git-send-email-isubramanian@apm.com>
References: <1457502577-2606-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	toanle@apm.com, Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33435 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbcCIFtR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 00:49:17 -0500
Received: by mail-pf0-f182.google.com with SMTP id 124so31427123pfg.0
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2016 21:49:17 -0800 (PST)
In-Reply-To: <1457502577-2606-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prefetch buffer numbers are mapped to hardware irqs. Currently
they are statically assigned to match with firmware irqs.

If the irq on firmware changes, prefetch buffer number on the driver
also needs to be updated to match with the firmware.

This patch removes this static association between firmware and the
driver by deriving the prefetch buffer number from the Linux irq.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 19 +++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  6 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  |  9 +++------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  7 +------
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c | 12 ++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h |  4 ++++
 6 files changed, 45 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 39e081a..309bba6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -215,6 +215,24 @@ static void xgene_enet_setup_coalescing(struct xgene_enet_desc_ring *ring)
 	xgene_enet_ring_wr32(ring, CSR_THRESHOLD1_SET1, 0x80);
 }
 
+static u8 xgene_start_cpu_bufnum(struct xgene_enet_pdata *pdata)
+{
+	int hwirq, start_hwirq;
+	struct irq_desc *desc;
+
+	if (pdata->rm == RM0)
+		start_hwirq = XGENE1_RM0_START_IRQ;
+	else if (pdata->rm == RM1)
+		start_hwirq = XGENE1_RM1_START_IRQ;
+	else
+		start_hwirq = XGENE1_RM3_START_IRQ;
+
+	desc = irq_to_desc(pdata->irqs[0]);
+	hwirq = desc->irq_data.hwirq;
+
+	return hwirq - start_hwirq;
+}
+
 void xgene_enet_parse_error(struct xgene_enet_desc_ring *ring,
 			    struct xgene_enet_pdata *pdata,
 			    enum xgene_enet_err_code status)
@@ -904,4 +922,5 @@ struct xgene_ring_ops xgene_ring1_ops = {
 	.wr_cmd = xgene_enet_wr_cmd,
 	.len = xgene_enet_ring_len,
 	.coalesce = xgene_enet_setup_coalescing,
+	.start_cpu_bufnum = xgene_start_cpu_bufnum,
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index ba7da98..9fe5cd6 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -300,6 +300,12 @@ enum xgene_enet_cmd {
 	XGENE_ENET_RD_CMD = BIT(30)
 };
 
+enum xgene_enet1_rm_start_irq {
+	XGENE1_RM0_START_IRQ = 128,
+	XGENE1_RM1_START_IRQ = 192,
+	XGENE1_RM3_START_IRQ = 92,
+};
+
 enum xgene_enet_err_code {
 	HBF_READ_DATA = 3,
 	HBF_LL_READ = 4,
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 8d4c1ad..0878aec 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -981,13 +981,15 @@ static int xgene_enet_create_desc_rings(struct net_device *ndev)
 	struct xgene_enet_desc_ring *buf_pool = NULL;
 	enum xgene_ring_owner owner;
 	dma_addr_t dma_exp_bufs;
-	u8 cpu_bufnum = pdata->cpu_bufnum;
+	u8 cpu_bufnum;
 	u8 eth_bufnum = pdata->eth_bufnum;
 	u8 bp_bufnum = pdata->bp_bufnum;
 	u16 ring_num = pdata->ring_num;
 	u16 ring_id;
 	int i, ret, size;
 
+	cpu_bufnum = pdata->ring_ops->start_cpu_bufnum(pdata);
+
 	for (i = 0; i < pdata->rxq_cnt; i++) {
 		/* allocate rx descriptor ring */
 		owner = xgene_derive_ring_owner(pdata);
@@ -1446,19 +1448,16 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 	if (pdata->enet_id == XGENE_ENET1) {
 		switch (pdata->port_id) {
 		case 0:
-			pdata->cpu_bufnum = START_CPU_BUFNUM_0;
 			pdata->eth_bufnum = START_ETH_BUFNUM_0;
 			pdata->bp_bufnum = START_BP_BUFNUM_0;
 			pdata->ring_num = START_RING_NUM_0;
 			break;
 		case 1:
 			if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
-				pdata->cpu_bufnum = XG_START_CPU_BUFNUM_1;
 				pdata->eth_bufnum = XG_START_ETH_BUFNUM_1;
 				pdata->bp_bufnum = XG_START_BP_BUFNUM_1;
 				pdata->ring_num = XG_START_RING_NUM_1;
 			} else {
-				pdata->cpu_bufnum = START_CPU_BUFNUM_1;
 				pdata->eth_bufnum = START_ETH_BUFNUM_1;
 				pdata->bp_bufnum = START_BP_BUFNUM_1;
 				pdata->ring_num = START_RING_NUM_1;
@@ -1471,13 +1470,11 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 	} else {
 		switch (pdata->port_id) {
 		case 0:
-			pdata->cpu_bufnum = X2_START_CPU_BUFNUM_0;
 			pdata->eth_bufnum = X2_START_ETH_BUFNUM_0;
 			pdata->bp_bufnum = X2_START_BP_BUFNUM_0;
 			pdata->ring_num = X2_START_RING_NUM_0;
 			break;
 		case 1:
-			pdata->cpu_bufnum = X2_START_CPU_BUFNUM_1;
 			pdata->eth_bufnum = X2_START_ETH_BUFNUM_1;
 			pdata->bp_bufnum = X2_START_BP_BUFNUM_1;
 			pdata->ring_num = X2_START_RING_NUM_1;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 175d188..1ff4713 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -54,25 +54,20 @@
 #define XGENE_NUM_TX_RING	4
 #define XGENE_NUM_TXC_RING	4
 
-#define START_CPU_BUFNUM_0	0
 #define START_ETH_BUFNUM_0	2
 #define START_BP_BUFNUM_0	0x22
 #define START_RING_NUM_0	8
-#define START_CPU_BUFNUM_1	12
 #define START_ETH_BUFNUM_1	10
 #define START_BP_BUFNUM_1	0x2A
 #define START_RING_NUM_1	264
 
-#define XG_START_CPU_BUFNUM_1	12
 #define XG_START_ETH_BUFNUM_1	2
 #define XG_START_BP_BUFNUM_1	0x22
 #define XG_START_RING_NUM_1	264
 
-#define X2_START_CPU_BUFNUM_0	0
 #define X2_START_ETH_BUFNUM_0	0
 #define X2_START_BP_BUFNUM_0	0x20
 #define X2_START_RING_NUM_0	0
-#define X2_START_CPU_BUFNUM_1	0xc
 #define X2_START_ETH_BUFNUM_1	0
 #define X2_START_BP_BUFNUM_1	0x20
 #define X2_START_RING_NUM_1	256
@@ -150,6 +145,7 @@ struct xgene_ring_ops {
 	void (*wr_cmd)(struct xgene_enet_desc_ring *, int);
 	u32 (*len)(struct xgene_enet_desc_ring *);
 	void (*coalesce)(struct xgene_enet_desc_ring *);
+	u8 (*start_cpu_bufnum)(struct xgene_enet_pdata *);
 };
 
 struct xgene_cle_ops {
@@ -194,7 +190,6 @@ struct xgene_enet_pdata {
 	struct xgene_cle_ops *cle_ops;
 	struct delayed_work link_work;
 	u32 port_id;
-	u8 cpu_bufnum;
 	u8 eth_bufnum;
 	u8 bp_bufnum;
 	u16 ring_num;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c b/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
index 2b76732..026233e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.c
@@ -201,6 +201,17 @@ static void xgene_enet_setup_coalescing(struct xgene_enet_desc_ring *ring)
 	xgene_enet_ring_wr32(ring, CSR_THRESHOLD1_SET1, 0x80);
 }
 
+static u8 xgene_start_cpu_bufnum(struct xgene_enet_pdata *pdata)
+{
+	struct irq_desc *desc;
+	int hwirq;
+
+	desc = irq_to_desc(pdata->irqs[0]);
+	hwirq = desc->irq_data.hwirq;
+
+	return hwirq - XGENE2_RM0_START_IRQ;
+}
+
 struct xgene_ring_ops xgene_ring2_ops = {
 	.num_ring_config = X2_NUM_RING_CONFIG,
 	.num_ring_id_shift = 13,
@@ -209,4 +220,5 @@ struct xgene_ring_ops xgene_ring2_ops = {
 	.wr_cmd = xgene_enet_wr_cmd,
 	.len = xgene_enet_ring_len,
 	.coalesce = xgene_enet_setup_coalescing,
+	.start_cpu_bufnum = xgene_start_cpu_bufnum,
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h b/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h
index 8b235db..63afe67 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_ring2.h
@@ -44,6 +44,10 @@
 #define X2_NUMMSGSINQ_POS	0
 #define X2_NUMMSGSINQ_LEN	17
 
+enum xgene_enet2_rm_start_irq {
+	XGENE2_RM0_START_IRQ = 128,
+};
+
 extern struct xgene_ring_ops xgene_ring2_ops;
 
 #endif /* __XGENE_ENET_RING2_H__ */
-- 
1.9.1
