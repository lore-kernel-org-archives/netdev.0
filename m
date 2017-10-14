From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net v2 2/2] net: fec: Let fec_ptp have its own interrupt routine
Date: Fri, 13 Oct 2017 19:09:40 -0700
Message-ID: <20171014020940.32736-2-troy.kisky@boundarydevices.com>
References: <20171014020940.32736-1-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, lznuaa@gmail.com, andrew@lunn.ch,
        Troy Kisky <troy.kisky@boundarydevices.com>
To: shawn.guo@linaro.org, fugang.duan@nxp.com, netdev@vger.kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wsip-98-189-142-135.oc.oc.cox.net ([98.189.142.135]:15012 "EHLO
        office-server2" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752769AbdJNCJq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 22:09:46 -0400
In-Reply-To: <20171014020940.32736-1-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is better for code locality and should slightly
speed up normal interrupts.

This also allows PPS clock output to start working for
i.mx7. This is because i.mx7 was already using the limit
of 3 interrupts, and needed another.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

---

v2: made this change independent of any devicetree change
so that old dtbs continue to work.

Continue to register ptp clock if interrupt is not found.
---
 drivers/net/ethernet/freescale/fec.h      |  3 +-
 drivers/net/ethernet/freescale/fec_main.c | 25 ++++++----
 drivers/net/ethernet/freescale/fec_ptp.c  | 82 ++++++++++++++++++-------------
 3 files changed, 65 insertions(+), 45 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index ede1876a9a19..be56ac1f1ac4 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -582,12 +582,11 @@ struct fec_enet_private {
 	u64 ethtool_stats[0];
 };
 
-void fec_ptp_init(struct platform_device *pdev);
+void fec_ptp_init(struct platform_device *pdev, int irq_index);
 void fec_ptp_stop(struct platform_device *pdev);
 void fec_ptp_start_cyclecounter(struct net_device *ndev);
 int fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);
 int fec_ptp_get(struct net_device *ndev, struct ifreq *ifr);
-uint fec_ptp_check_pps_event(struct fec_enet_private *fep);
 
 /****************************************************************************/
 #endif /* FEC_H */
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3dc2d771a222..21afabbc560f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1602,10 +1602,6 @@ fec_enet_interrupt(int irq, void *dev_id)
 		ret = IRQ_HANDLED;
 		complete(&fep->mdio_done);
 	}
-
-	if (fep->ptp_clock)
-		if (fec_ptp_check_pps_event(fep))
-			ret = IRQ_HANDLED;
 	return ret;
 }
 
@@ -3325,6 +3321,8 @@ fec_probe(struct platform_device *pdev)
 	struct device_node *np = pdev->dev.of_node, *phy_node;
 	int num_tx_qs;
 	int num_rx_qs;
+	char irq_name[8];
+	int irq_cnt;
 
 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
 
@@ -3465,18 +3463,27 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_reset;
 
+	irq_cnt = platform_irq_count(pdev);
+	if (irq_cnt > FEC_IRQ_NUM)
+		irq_cnt = FEC_IRQ_NUM;	/* last for ptp */
+	else if (irq_cnt == 2)
+		irq_cnt = 1;	/* last for ptp */
+	else if (irq_cnt <= 0)
+		irq_cnt = 1;	/* Let the for loop fail */
+
 	if (fep->bufdesc_ex)
-		fec_ptp_init(pdev);
+		fec_ptp_init(pdev, irq_cnt);
 
 	ret = fec_enet_init(ndev);
 	if (ret)
 		goto failed_init;
 
-	for (i = 0; i < FEC_IRQ_NUM; i++) {
-		irq = platform_get_irq(pdev, i);
+	for (i = 0; i < irq_cnt; i++) {
+		sprintf(irq_name, "int%d", i);
+		irq = platform_get_irq_byname(pdev, irq_name);
+		if (irq < 0)
+			irq = platform_get_irq(pdev, i);
 		if (irq < 0) {
-			if (i)
-				break;
 			ret = irq;
 			goto failed_irq;
 		}
diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index 6ebad3fac81d..3abeee0d16dd 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -549,6 +549,37 @@ static void fec_time_keep(struct work_struct *work)
 	schedule_delayed_work(&fep->time_keep, HZ);
 }
 
+/* This function checks the pps event and reloads the timer compare counter. */
+static irqreturn_t fec_ptp_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	u32 val;
+	u8 channel = fep->pps_channel;
+	struct ptp_clock_event event;
+
+	val = readl(fep->hwp + FEC_TCSR(channel));
+	if (val & FEC_T_TF_MASK) {
+		/* Write the next next compare(not the next according the spec)
+		 * value to the register
+		 */
+		writel(fep->next_counter, fep->hwp + FEC_TCCR(channel));
+		do {
+			writel(val, fep->hwp + FEC_TCSR(channel));
+		} while (readl(fep->hwp + FEC_TCSR(channel)) & FEC_T_TF_MASK);
+
+		/* Update the counter; */
+		fep->next_counter = (fep->next_counter + fep->reload_period) &
+				fep->cc.mask;
+
+		event.type = PTP_CLOCK_PPS;
+		ptp_clock_event(fep->ptp_clock, &event);
+		return IRQ_HANDLED;
+	}
+
+	return IRQ_NONE;
+}
+
 /**
  * fec_ptp_init
  * @ndev: The FEC network adapter
@@ -558,10 +589,12 @@ static void fec_time_keep(struct work_struct *work)
  * cyclecounter init routine and exits.
  */
 
-void fec_ptp_init(struct platform_device *pdev)
+void fec_ptp_init(struct platform_device *pdev, int irq_index)
 {
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct fec_enet_private *fep = netdev_priv(ndev);
+	int irq;
+	int ret;
 
 	fep->ptp_caps.owner = THIS_MODULE;
 	snprintf(fep->ptp_caps.name, 16, "fec ptp");
@@ -587,6 +620,20 @@ void fec_ptp_init(struct platform_device *pdev)
 
 	INIT_DELAYED_WORK(&fep->time_keep, fec_time_keep);
 
+	irq = platform_get_irq_byname(pdev, "ptp");
+	if (irq < 0)
+		irq = platform_get_irq(pdev, irq_index);
+	/* Failure to get an irq is not fatal,
+	 * only the PTP_CLOCK_PPS clock events should stop
+	 */
+	if (irq >= 0) {
+		ret = devm_request_irq(&pdev->dev, irq, fec_ptp_interrupt,
+				       0, pdev->name, ndev);
+		if (ret < 0)
+			dev_warn(&pdev->dev, "request for ptp irq failed(%d)\n",
+				 ret);
+	}
+
 	fep->ptp_clock = ptp_clock_register(&fep->ptp_caps, &pdev->dev);
 	if (IS_ERR(fep->ptp_clock)) {
 		fep->ptp_clock = NULL;
@@ -605,36 +652,3 @@ void fec_ptp_stop(struct platform_device *pdev)
 	if (fep->ptp_clock)
 		ptp_clock_unregister(fep->ptp_clock);
 }
-
-/**
- * fec_ptp_check_pps_event
- * @fep: the fec_enet_private structure handle
- *
- * This function check the pps event and reload the timer compare counter.
- */
-uint fec_ptp_check_pps_event(struct fec_enet_private *fep)
-{
-	u32 val;
-	u8 channel = fep->pps_channel;
-	struct ptp_clock_event event;
-
-	val = readl(fep->hwp + FEC_TCSR(channel));
-	if (val & FEC_T_TF_MASK) {
-		/* Write the next next compare(not the next according the spec)
-		 * value to the register
-		 */
-		writel(fep->next_counter, fep->hwp + FEC_TCCR(channel));
-		do {
-			writel(val, fep->hwp + FEC_TCSR(channel));
-		} while (readl(fep->hwp + FEC_TCSR(channel)) & FEC_T_TF_MASK);
-
-		/* Update the counter; */
-		fep->next_counter = (fep->next_counter + fep->reload_period) & fep->cc.mask;
-
-		event.type = PTP_CLOCK_PPS;
-		ptp_clock_event(fep->ptp_clock, &event);
-		return 1;
-	}
-
-	return 0;
-}
-- 
2.11.0
