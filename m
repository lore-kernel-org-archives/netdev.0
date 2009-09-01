From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 04/18] tg3: Add support code around kernel interrupt API
Date: Tue, 1 Sep 2009 15:55:02 -0700
Message-ID: <1251867301.5923@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2622 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754165AbZIBEzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to support multiple interrupt vectors around the
kernel's interrupt API.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   73 ++++++++++++++++++++++++++++++++++++++++-------------
 drivers/net/tg3.h |    6 ++++
 2 files changed, 61 insertions(+), 18 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 14cead6..7717eae 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4729,12 +4729,15 @@ tx_recovery:
 
 static void tg3_irq_quiesce(struct tg3 *tp)
 {
+	int i;
+
 	BUG_ON(tp->irq_sync);
 
 	tp->irq_sync = 1;
 	smp_mb();
 
-	synchronize_irq(tp->pdev->irq);
+	for (i = 0; i < tp->irq_cnt; i++)
+		synchronize_irq(tp->napi[i].irq_vec);
 }
 
 static inline int tg3_irq_sync(struct tg3 *tp)
@@ -4947,9 +4950,11 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void tg3_poll_controller(struct net_device *dev)
 {
+	int i;
 	struct tg3 *tp = netdev_priv(dev);
 
-	tg3_interrupt(tp->pdev->irq, dev);
+	for (i = 0; i < tp->irq_cnt; i++)
+		tg3_interrupt(tp->napi[i].irq_vec, dev);
 }
 #endif
 
@@ -6244,7 +6249,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 {
 	u32 val;
 	void (*write_op)(struct tg3 *, u32, u32);
-	int err;
+	int i, err;
 
 	tg3_nvram_lock(tp);
 
@@ -6291,7 +6296,9 @@ static int tg3_chip_reset(struct tg3 *tp)
 	tp->napi[0].last_tag = 0;
 	tp->napi[0].last_irq_tag = 0;
 	smp_mb();
-	synchronize_irq(tp->pdev->irq);
+
+	for (i = 0; i < tp->irq_cnt; i++)
+		synchronize_irq(tp->napi[i].irq_vec);
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780) {
 		val = tr32(TG3_PCIE_LNKCTL) & ~TG3_PCIE_LNKCTL_L1_PLL_PD_EN;
@@ -7745,11 +7752,20 @@ restart_timer:
 	add_timer(&tp->timer);
 }
 
-static int tg3_request_irq(struct tg3 *tp)
+static int tg3_request_irq(struct tg3 *tp, int irq_num)
 {
 	irq_handler_t fn;
 	unsigned long flags;
-	char *name = tp->dev->name;
+	char *name;
+	struct tg3_napi *tnapi = &tp->napi[irq_num];
+
+	if (tp->irq_cnt == 1)
+		name = tp->dev->name;
+	else {
+		name = &tnapi->irq_lbl[0];
+		snprintf(name, IFNAMSIZ, "%s-%d", tp->dev->name, irq_num);
+		name[IFNAMSIZ-1] = 0;
+	}
 
 	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
 		fn = tg3_msi;
@@ -7762,7 +7778,8 @@ static int tg3_request_irq(struct tg3 *tp)
 			fn = tg3_interrupt_tagged;
 		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
 	}
-	return request_irq(tp->pdev->irq, fn, flags, name, &tp->napi[0]);
+
+	return request_irq(tnapi->irq_vec, fn, flags, name, tnapi);
 }
 
 static int tg3_test_interrupt(struct tg3 *tp)
@@ -7776,9 +7793,9 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	tg3_disable_ints(tp);
 
-	free_irq(tp->pdev->irq, tnapi);
+	free_irq(tnapi->irq_vec, tnapi);
 
-	err = request_irq(tp->pdev->irq, tg3_test_isr,
+	err = request_irq(tnapi->irq_vec, tg3_test_isr,
 			  IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, tnapi);
 	if (err)
 		return err;
@@ -7806,9 +7823,9 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	tg3_disable_ints(tp);
 
-	free_irq(tp->pdev->irq, tnapi);
+	free_irq(tnapi->irq_vec, tnapi);
 
-	err = tg3_request_irq(tp);
+	err = tg3_request_irq(tp, 0);
 
 	if (err)
 		return err;
@@ -7854,13 +7871,13 @@ static int tg3_test_msi(struct tg3 *tp)
 	       "the PCI maintainer and include system chipset information.\n",
 		       tp->dev->name);
 
-	free_irq(tp->pdev->irq, &tp->napi[0]);
+	free_irq(tp->napi[0].irq_vec, &tp->napi[0]);
 
 	pci_disable_msi(tp->pdev);
 
 	tp->tg3_flags2 &= ~TG3_FLG2_USING_MSI;
 
-	err = tg3_request_irq(tp);
+	err = tg3_request_irq(tp, 0);
 	if (err)
 		return err;
 
@@ -7875,7 +7892,7 @@ static int tg3_test_msi(struct tg3 *tp)
 	tg3_full_unlock(tp);
 
 	if (err)
-		free_irq(tp->pdev->irq, &tp->napi[0]);
+		free_irq(tp->napi[0].irq_vec, &tp->napi[0]);
 
 	return err;
 }
@@ -7928,6 +7945,9 @@ static void tg3_ints_init(struct tg3 *tp)
 			tp->tg3_flags2 |= TG3_FLG2_USING_MSI;
 		}
 	}
+
+	tp->irq_cnt = 1;
+	tp->napi[0].irq_vec = tp->pdev->irq;
 }
 
 static void tg3_ints_fini(struct tg3 *tp)
@@ -7941,7 +7961,7 @@ static void tg3_ints_fini(struct tg3 *tp)
 static int tg3_open(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
-	int err;
+	int i, err;
 
 	if (tp->fw_needed) {
 		err = tg3_request_firmware(tp);
@@ -7983,7 +8003,15 @@ static int tg3_open(struct net_device *dev)
 
 	napi_enable(&tp->napi[0].napi);
 
-	err = tg3_request_irq(tp);
+	for (i = 0; i < tp->irq_cnt; i++) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+		err = tg3_request_irq(tp, i);
+		if (err) {
+			for (i--; i >= 0; i--)
+				free_irq(tnapi->irq_vec, tnapi);
+			break;
+		}
+	}
 
 	if (err)
 		goto err_out1;
@@ -8054,7 +8082,10 @@ static int tg3_open(struct net_device *dev)
 	return 0;
 
 err_out2:
-	free_irq(tp->pdev->irq, &tp->napi[0]);
+	for (i = tp->irq_cnt - 1; i >= 0; i--) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+		free_irq(tnapi->irq_vec, tnapi);
+	}
 
 err_out1:
 	napi_disable(&tp->napi[0].napi);
@@ -8298,6 +8329,7 @@ static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *);
 
 static int tg3_close(struct net_device *dev)
 {
+	int i;
 	struct tg3 *tp = netdev_priv(dev);
 
 	napi_disable(&tp->napi[0].napi);
@@ -8320,7 +8352,10 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_full_unlock(tp);
 
-	free_irq(tp->pdev->irq, &tp->napi[0]);
+	for (i = tp->irq_cnt - 1; i >= 0; i--) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+		free_irq(tnapi->irq_vec, tnapi);
+	}
 
 	tg3_ints_fini(tp);
 
@@ -12151,6 +12186,8 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		}
 	}
 
+	tp->irq_max = 1;
+
 	if (!(tp->tg3_flags2 & TG3_FLG2_5705_PLUS) ||
 	     (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		tp->tg3_flags |= TG3_FLAG_JUMBO_CAPABLE;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 626b968..a78a0db 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2514,6 +2514,9 @@ struct tg3_napi {
 	dma_addr_t			status_mapping;
 	dma_addr_t			rx_rcb_mapping;
 	dma_addr_t			tx_desc_mapping;
+
+	char				irq_lbl[IFNAMSIZ];
+	unsigned int			irq_vec;
 };
 
 struct tg3 {
@@ -2829,6 +2832,9 @@ struct tg3 {
 
 #define SST_25VF0X0_PAGE_SIZE		4098
 
+	unsigned int			irq_max;
+	unsigned int			irq_cnt;
+
 	struct ethtool_coalesce		coal;
 
 	/* firmware info */
-- 
1.6.3.3


