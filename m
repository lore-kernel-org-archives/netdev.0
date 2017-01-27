From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 5/5] [net-next] net: qcom/emac: add an error interrupt handler for the sgmii
Date: Fri, 27 Jan 2017 16:43:48 -0600
Message-ID: <1485557028-32510-7-git-send-email-timur@codeaurora.org>
References: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:57206 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750710AbdA0Wzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 17:55:35 -0500
In-Reply-To: <1485557028-32510-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SGMII (internal PHY) can report decode errors via an interrupt.  It
can also report autonegotiation status changes, but we don't need to track
those.  The SGMII can recover automatically from most decode errors, so
we only reset the interface if we get multiple consecutive errors.

It's possible for bogus decode errors to be reported while the link is
being brought up.  The interrupt is registered when the interface is
opened, and it's enabled after the link is up.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-mac.c   |   8 +-
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c | 126 +++++++++++++++++++++++-
 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h |  16 ++-
 drivers/net/ethernet/qualcomm/emac/emac.c       |  10 ++
 4 files changed, 153 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 33d7ff1..b991219 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -951,12 +951,16 @@ static void emac_mac_rx_descs_refill(struct emac_adapter *adpt,
 static void emac_adjust_link(struct net_device *netdev)
 {
 	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_sgmii *sgmii = &adpt->phy;
 	struct phy_device *phydev = netdev->phydev;
 
-	if (phydev->link)
+	if (phydev->link) {
 		emac_mac_start(adpt);
-	else
+		sgmii->link_up(adpt);
+	} else {
+		sgmii->link_down(adpt);
 		emac_mac_stop(adpt);
+	}
 
 	phy_print_status(phydev);
 }
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
index b5269c4..040b289 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
@@ -25,7 +25,9 @@
 #define EMAC_SGMII_PHY_SPEED_CFG1		0x0074
 #define EMAC_SGMII_PHY_IRQ_CMD			0x00ac
 #define EMAC_SGMII_PHY_INTERRUPT_CLEAR		0x00b0
+#define EMAC_SGMII_PHY_INTERRUPT_MASK		0x00b4
 #define EMAC_SGMII_PHY_INTERRUPT_STATUS		0x00b8
+#define EMAC_SGMII_PHY_RX_CHK_STATUS		0x00d4
 
 #define FORCE_AN_TX_CFG				BIT(5)
 #define FORCE_AN_RX_CFG				BIT(4)
@@ -36,6 +38,8 @@
 #define SPDMODE_100				BIT(0)
 #define SPDMODE_10				0
 
+#define CDR_ALIGN_DET				BIT(6)
+
 #define IRQ_GLOBAL_CLEAR			BIT(0)
 
 #define DECODE_CODE_ERR				BIT(7)
@@ -44,6 +48,7 @@
 #define SGMII_PHY_IRQ_CLR_WAIT_TIME		10
 
 #define SGMII_PHY_INTERRUPT_ERR		(DECODE_CODE_ERR | DECODE_DISP_ERR)
+#define SGMII_ISR_MASK  		(SGMII_PHY_INTERRUPT_ERR)
 
 #define SERDES_START_WAIT_TIMES			100
 
@@ -96,6 +101,51 @@ static int emac_sgmii_irq_clear(struct emac_adapter *adpt, u32 irq_bits)
 	return 0;
 }
 
+/* The number of decode errors that triggers a reset */
+#define DECODE_ERROR_LIMIT	2
+
+static irqreturn_t emac_sgmii_interrupt(int irq, void *data)
+{
+	struct emac_adapter *adpt = data;
+	struct emac_sgmii *phy = &adpt->phy;
+	u32 status;
+
+	status = readl(phy->base + EMAC_SGMII_PHY_INTERRUPT_STATUS);
+	status &= SGMII_ISR_MASK;
+	if (!status)
+		return IRQ_HANDLED;
+
+	/* If we get a decoding error and CDR is not locked, then try
+	 * resetting the internal PHY.  The internal PHY uses an embedded
+	 * clock with Clock and Data Recovery (CDR) to recover the
+	 * clock and data.
+	 */
+	if (status & SGMII_PHY_INTERRUPT_ERR) {
+		int count;
+
+		/* The SGMII is capable of recovering from some decode
+		 * errors automatically.  However, if we get multiple
+		 * decode errors in a row, then assume that something
+		 * is wrong and reset the interface.
+		 */
+		count = atomic_inc_return(&phy->decode_error_count);
+		if (count == DECODE_ERROR_LIMIT) {
+			schedule_work(&adpt->work_thread);
+			atomic_set(&phy->decode_error_count, 0);
+		}
+	} else {
+		/* We only care about consecutive decode errors. */
+		atomic_set(&phy->decode_error_count, 0);
+	}
+
+	if (emac_sgmii_irq_clear(adpt, status)) {
+		netdev_warn(adpt->netdev, "failed to clear SGMII interrupt\n");
+		schedule_work(&adpt->work_thread);
+	}
+
+	return IRQ_HANDLED;
+}
+
 static void emac_sgmii_reset_prepare(struct emac_adapter *adpt)
 {
 	struct emac_sgmii *phy = &adpt->phy;
@@ -129,6 +179,68 @@ void emac_sgmii_reset(struct emac_adapter *adpt)
 			   ret);
 }
 
+static int emac_sgmii_open(struct emac_adapter *adpt)
+{
+	struct emac_sgmii *sgmii = &adpt->phy;
+	int ret;
+
+	if (sgmii->irq) {
+		/* Make sure interrupts are cleared and disabled first */
+		ret = emac_sgmii_irq_clear(adpt, 0xff);
+		if (ret)
+			return ret;
+		writel(0, sgmii->base + EMAC_SGMII_PHY_INTERRUPT_MASK);
+
+		ret = request_irq(sgmii->irq, emac_sgmii_interrupt, 0,
+				  "emac-sgmii", adpt);
+		if (ret) {
+			netdev_err(adpt->netdev,
+				   "could not register handler for internal PHY\n");
+			return ret;
+		}
+	}
+
+	return 0;
+}
+
+static int emac_sgmii_close(struct emac_adapter *adpt)
+{
+	struct emac_sgmii *sgmii = &adpt->phy;
+
+	/* Make sure interrupts are disabled */
+	writel(0, sgmii->base + EMAC_SGMII_PHY_INTERRUPT_MASK);
+	free_irq(sgmii->irq, adpt);
+
+	return 0;
+}
+
+/* The error interrupts are only valid after the link is up */
+static int emac_sgmii_link_up(struct emac_adapter *adpt)
+{
+	struct emac_sgmii *sgmii = &adpt->phy;
+	int ret;
+
+	/* Clear and enable interrupts */
+	ret = emac_sgmii_irq_clear(adpt, 0xff);
+	if (ret)
+		return ret;
+
+	writel(SGMII_ISR_MASK, sgmii->base + EMAC_SGMII_PHY_INTERRUPT_MASK);
+
+	return 0;
+}
+
+static int emac_sgmii_link_down(struct emac_adapter *adpt)
+{
+	struct emac_sgmii *sgmii = &adpt->phy;
+
+	/* Disable interrupts */
+	writel(0, sgmii->base + EMAC_SGMII_PHY_INTERRUPT_MASK);
+	synchronize_irq(sgmii->irq);
+
+	return 0;
+}
+
 static int emac_sgmii_acpi_match(struct device *dev, void *data)
 {
 #ifdef CONFIG_ACPI
@@ -139,7 +251,7 @@ static int emac_sgmii_acpi_match(struct device *dev, void *data)
 		{}
 	};
 	const struct acpi_device_id *id = acpi_match_device(match_table, dev);
-	emac_sgmii_initialize *initialize = data;
+	emac_sgmii_function *initialize = data;
 
 	if (id) {
 		acpi_handle handle = ACPI_HANDLE(dev);
@@ -226,9 +338,14 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 			goto error_put_device;
 		}
 
-		phy->initialize = (emac_sgmii_initialize)match->data;
+		phy->initialize = (emac_sgmii_function)match->data;
 	}
 
+	phy->open = emac_sgmii_open;
+	phy->close = emac_sgmii_close;
+	phy->link_up = emac_sgmii_link_up;
+	phy->link_down = emac_sgmii_link_down;
+
 	/* Base address is the first address */
 	res = platform_get_resource(sgmii_pdev, IORESOURCE_MEM, 0);
 	if (!res) {
@@ -256,9 +373,12 @@ int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt)
 	if (ret)
 		goto error;
 
-	emac_sgmii_irq_clear(adpt, SGMII_PHY_INTERRUPT_ERR);
 	emac_sgmii_link_init(adpt);
 
+	ret = platform_get_irq(sgmii_pdev, 0);
+	if (ret > 0)
+		phy->irq = ret;
+
 	/* We've remapped the addresses, so we don't need the device any
 	 * more.  of_find_device_by_node() says we should release it.
 	 */
diff --git a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
index 4a8f6b1..e7c0c3b 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
@@ -16,17 +16,29 @@
 struct emac_adapter;
 struct platform_device;
 
-typedef int (*emac_sgmii_initialize)(struct emac_adapter *adpt);
+typedef int (*emac_sgmii_function)(struct emac_adapter *adpt);
 
 /** emac_sgmii - internal emac phy
  * @base base address
  * @digital per-lane digital block
+ * @irq the interrupt number
+ * @decode_error_count reference count of consecutive decode errors
  * @initialize initialization function
+ * @open called when the driver is opened
+ * @close called when the driver is closed
+ * @link_up called when the link comes up
+ * @link_down called when the link comes down
  */
 struct emac_sgmii {
 	void __iomem		*base;
 	void __iomem		*digital;
-	emac_sgmii_initialize	initialize;
+	unsigned int		irq;
+	atomic_t		decode_error_count;
+	emac_sgmii_function	initialize;
+	emac_sgmii_function	open;
+	emac_sgmii_function	close;
+	emac_sgmii_function	link_up;
+	emac_sgmii_function	link_down;
 };
 
 int emac_sgmii_config(struct platform_device *pdev, struct emac_adapter *adpt);
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index 75305ad..f519351 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -280,6 +280,14 @@ static int emac_open(struct net_device *netdev)
 		return ret;
 	}
 
+	ret = adpt->phy.open(adpt);
+	if (ret) {
+		emac_mac_down(adpt);
+		emac_mac_rx_tx_rings_free_all(adpt);
+		free_irq(irq->irq, irq);
+		return ret;
+	}
+
 	return 0;
 }
 
@@ -290,6 +298,7 @@ static int emac_close(struct net_device *netdev)
 
 	mutex_lock(&adpt->reset_lock);
 
+	adpt->phy.close(adpt);
 	emac_mac_down(adpt);
 	emac_mac_rx_tx_rings_free_all(adpt);
 
@@ -645,6 +654,7 @@ static int emac_probe(struct platform_device *pdev)
 	adpt->msg_enable = EMAC_MSG_DEFAULT;
 
 	phy = &adpt->phy;
+	atomic_set(&phy->decode_error_count, 0);
 
 	mutex_init(&adpt->reset_lock);
 	spin_lock_init(&adpt->stats.lock);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
