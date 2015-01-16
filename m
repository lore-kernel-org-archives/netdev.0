From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 08/12] amd-xgbe-phy: Change auto-negotiation
 logic
Date: Fri, 16 Jan 2015 12:47:00 -0600
Message-ID: <20150116184700.18809.21989.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44030 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756800AbbAPSya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:30 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The auto negotiation logic was geared to being the initiator of the
auto negotiation. This presented problems when auto negotiation was
initiated by the remote end. Change the auto negotiation logic to
make use of the auto negotiation event interrupt thus allowing the
auto negotiation state machine to function properly in either scenario.
This also removes the polling during auto-negotiation.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 .../devicetree/bindings/net/amd-xgbe-phy.txt       |    5 
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           |   27 +
 drivers/net/phy/amd-xgbe-phy.c                     |  627 ++++++++++++--------
 3 files changed, 393 insertions(+), 266 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
index 42409bf..d54fe1a 100644
--- a/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
+++ b/Documentation/devicetree/bindings/net/amd-xgbe-phy.txt
@@ -7,6 +7,9 @@ Required properties:
    - SerDes Rx/Tx registers
    - SerDes integration registers (1/2)
    - SerDes integration registers (2/2)
+- interrupt-parent: Should be the phandle for the interrupt controller
+  that services interrupts for this device
+- interrupts: Should contain the amd-xgbe-phy interrupt.
 
 Optional properties:
 - amd,speed-set: Speed capabilities of the device
@@ -19,5 +22,7 @@ Example:
 		reg = <0 0xe1240800 0 0x00400>,
 		      <0 0xe1250000 0 0x00060>,
 		      <0 0xe1250080 0 0x00004>;
+		interrupt-parent = <&gic>;
+		interrupts = <0 323 4>;
 		amd,speed-set = <0>;
 	};
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 5dff127..950ad2e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -115,6 +115,7 @@
  */
 
 #include <linux/phy.h>
+#include <linux/mdio.h>
 #include <linux/clk.h>
 #include <linux/bitrev.h>
 #include <linux/crc32.h>
@@ -673,6 +674,9 @@ static void xgbe_enable_mac_interrupts(struct xgbe_prv_data *pdata)
 
 static int xgbe_set_gmii_speed(struct xgbe_prv_data *pdata)
 {
+	if (XGMAC_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x3)
+		return 0;
+
 	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x3);
 
 	return 0;
@@ -680,6 +684,9 @@ static int xgbe_set_gmii_speed(struct xgbe_prv_data *pdata)
 
 static int xgbe_set_gmii_2500_speed(struct xgbe_prv_data *pdata)
 {
+	if (XGMAC_IOREAD_BITS(pdata, MAC_TCR, SS) == 0x2)
+		return 0;
+
 	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, SS, 0x2);
 
 	return 0;
@@ -687,6 +694,9 @@ static int xgbe_set_gmii_2500_speed(struct xgbe_prv_data *pdata)
 
 static int xgbe_set_xgmii_speed(struct xgbe_prv_data *pdata)
 {
+	if (XGMAC_IOREAD_BITS(pdata, MAC_TCR, SS) == 0)
+		return 0;
+
 	XGMAC_IOWRITE_BITS(pdata, MAC_TCR, SS, 0);
 
 	return 0;
@@ -881,6 +891,23 @@ static void xgbe_write_mmd_regs(struct xgbe_prv_data *pdata, int prtad,
 	else
 		mmd_address = (pdata->mdio_mmd << 16) | (mmd_reg & 0xffff);
 
+	/* If the PCS is changing modes, match the MAC speed to it */
+	if (((mmd_address >> 16) == MDIO_MMD_PCS) &&
+	    ((mmd_address & 0xffff) == MDIO_CTRL2)) {
+		struct phy_device *phydev = pdata->phydev;
+
+		if (mmd_data & MDIO_PCS_CTRL2_TYPE) {
+			/* KX mode */
+			if (phydev->supported & SUPPORTED_1000baseKX_Full)
+				xgbe_set_gmii_speed(pdata);
+			else
+				xgbe_set_gmii_2500_speed(pdata);
+		} else {
+			/* KR mode */
+			xgbe_set_xgmii_speed(pdata);
+		}
+	}
+
 	/* The PCS registers are accessed using mmio. The underlying APB3
 	 * management interface uses indirect addressing to access the MMD
 	 * register sets. This requires accessing of the PCS register in two
diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 5ce42e3..7fde508 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -60,6 +60,7 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/delay.h>
+#include <linux/workqueue.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
@@ -89,6 +90,7 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XGBE_AN_INT_CMPLT		0x01
 #define XGBE_AN_INC_LINK		0x02
 #define XGBE_AN_PG_RCV			0x04
+#define XGBE_AN_INT_MASK		0x07
 
 #define XNP_MCF_NULL_MESSAGE		0x001
 #define XNP_ACK_PROCESSED		BIT(12)
@@ -117,18 +119,10 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define MDIO_AN_INT			0x8002
 #endif
 
-#ifndef MDIO_AN_KR_CTRL
-#define MDIO_AN_KR_CTRL			0x8003
-#endif
-
 #ifndef MDIO_CTRL1_SPEED1G
 #define MDIO_CTRL1_SPEED1G		(MDIO_CTRL1_SPEED10G & ~BMCR_SPEED100)
 #endif
 
-#ifndef MDIO_KR_CTRL_PDETECT
-#define MDIO_KR_CTRL_PDETECT		0x01
-#endif
-
 /* SerDes integration register offsets */
 #define SIR0_KR_RT_1			0x002c
 #define SIR0_STATUS			0x0040
@@ -294,21 +288,18 @@ do {									\
 
 enum amd_xgbe_phy_an {
 	AMD_XGBE_AN_READY = 0,
-	AMD_XGBE_AN_START,
-	AMD_XGBE_AN_EVENT,
 	AMD_XGBE_AN_PAGE_RECEIVED,
 	AMD_XGBE_AN_INCOMPAT_LINK,
 	AMD_XGBE_AN_COMPLETE,
 	AMD_XGBE_AN_NO_LINK,
-	AMD_XGBE_AN_EXIT,
 	AMD_XGBE_AN_ERROR,
 };
 
 enum amd_xgbe_phy_rx {
-	AMD_XGBE_RX_READY = 0,
-	AMD_XGBE_RX_BPA,
+	AMD_XGBE_RX_BPA = 0,
 	AMD_XGBE_RX_XNP,
 	AMD_XGBE_RX_COMPLETE,
+	AMD_XGBE_RX_ERROR,
 };
 
 enum amd_xgbe_phy_mode {
@@ -337,8 +328,11 @@ struct amd_xgbe_phy_priv {
 	void __iomem *sir0_regs;	/* SerDes integration registers (1/2) */
 	void __iomem *sir1_regs;	/* SerDes integration registers (2/2) */
 
-	/* Maintain link status for re-starting auto-negotiation */
-	unsigned int link;
+	int an_irq;
+	char an_irq_name[IFNAMSIZ + 32];
+	struct work_struct an_irq_work;
+	unsigned int an_irq_allocated;
+
 	unsigned int speed_set;
 
 	/* Auto-negotiation state machine support */
@@ -349,6 +343,7 @@ struct amd_xgbe_phy_priv {
 	enum amd_xgbe_phy_rx kx_state;
 	struct work_struct an_work;
 	struct workqueue_struct *an_workqueue;
+	unsigned int an_supported;
 	unsigned int parallel_detect;
 
 	unsigned int lpm_ctrl;		/* CTRL1 for resume */
@@ -638,6 +633,38 @@ static int amd_xgbe_phy_set_mode(struct phy_device *phydev,
 	return ret;
 }
 
+static int amd_xgbe_phy_set_an(struct phy_device *phydev, bool enable,
+			       bool restart)
+{
+	int ret;
+
+	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1);
+	if (ret < 0)
+		return ret;
+
+	ret &= ~MDIO_AN_CTRL1_ENABLE;
+
+	if (enable)
+		ret |= MDIO_AN_CTRL1_ENABLE;
+
+	if (restart)
+		ret |= MDIO_AN_CTRL1_RESTART;
+
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1, ret);
+
+	return 0;
+}
+
+static int amd_xgbe_phy_restart_an(struct phy_device *phydev)
+{
+	return amd_xgbe_phy_set_an(phydev, true, true);
+}
+
+static int amd_xgbe_phy_disable_an(struct phy_device *phydev)
+{
+	return amd_xgbe_phy_set_an(phydev, false, false);
+}
+
 static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 						    enum amd_xgbe_phy_rx *state)
 {
@@ -648,7 +675,7 @@ static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 
 	/* If we're not in KR mode then we're done */
 	if (!amd_xgbe_phy_in_kr_mode(phydev))
-		return AMD_XGBE_AN_EVENT;
+		return AMD_XGBE_AN_PAGE_RECEIVED;
 
 	/* Enable/Disable FEC */
 	ad_reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2);
@@ -682,7 +709,7 @@ static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 
 	XSIR0_IOWRITE_BITS(priv, SIR0_KR_RT_1, RESET, 0);
 
-	return AMD_XGBE_AN_EVENT;
+	return AMD_XGBE_AN_PAGE_RECEIVED;
 }
 
 static enum amd_xgbe_phy_an amd_xgbe_an_tx_xnp(struct phy_device *phydev,
@@ -699,7 +726,7 @@ static enum amd_xgbe_phy_an amd_xgbe_an_tx_xnp(struct phy_device *phydev,
 	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_XNP + 1, 0);
 	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_XNP, msg);
 
-	return AMD_XGBE_AN_EVENT;
+	return AMD_XGBE_AN_PAGE_RECEIVED;
 }
 
 static enum amd_xgbe_phy_an amd_xgbe_an_rx_bpa(struct phy_device *phydev,
@@ -751,226 +778,255 @@ static enum amd_xgbe_phy_an amd_xgbe_an_rx_xnp(struct phy_device *phydev,
 	       amd_xgbe_an_tx_training(phydev, state);
 }
 
-static enum amd_xgbe_phy_an amd_xgbe_an_start(struct phy_device *phydev)
+static enum amd_xgbe_phy_an amd_xgbe_an_page_received(struct phy_device *phydev)
+{
+	struct amd_xgbe_phy_priv *priv = phydev->priv;
+	enum amd_xgbe_phy_rx *state;
+	int ret;
+
+	state = amd_xgbe_phy_in_kr_mode(phydev) ? &priv->kr_state
+						: &priv->kx_state;
+
+	switch (*state) {
+	case AMD_XGBE_RX_BPA:
+		ret = amd_xgbe_an_rx_bpa(phydev, state);
+		break;
+
+	case AMD_XGBE_RX_XNP:
+		ret = amd_xgbe_an_rx_xnp(phydev, state);
+		break;
+
+	default:
+		ret = AMD_XGBE_AN_ERROR;
+	}
+
+	return ret;
+}
+
+static enum amd_xgbe_phy_an amd_xgbe_an_incompat_link(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	int ret;
 
 	/* Be sure we aren't looping trying to negotiate */
 	if (amd_xgbe_phy_in_kr_mode(phydev)) {
-		if (priv->kr_state != AMD_XGBE_RX_READY)
+		priv->kr_state = AMD_XGBE_RX_ERROR;
+
+		if (!(phydev->supported & SUPPORTED_1000baseKX_Full) &&
+		    !(phydev->supported & SUPPORTED_2500baseX_Full))
+			return AMD_XGBE_AN_NO_LINK;
+
+		if (priv->kx_state != AMD_XGBE_RX_BPA)
 			return AMD_XGBE_AN_NO_LINK;
-		priv->kr_state = AMD_XGBE_RX_BPA;
 	} else {
-		if (priv->kx_state != AMD_XGBE_RX_READY)
+		priv->kx_state = AMD_XGBE_RX_ERROR;
+
+		if (!(phydev->supported & SUPPORTED_10000baseKR_Full))
+			return AMD_XGBE_AN_NO_LINK;
+
+		if (priv->kr_state != AMD_XGBE_RX_BPA)
 			return AMD_XGBE_AN_NO_LINK;
-		priv->kx_state = AMD_XGBE_RX_BPA;
 	}
 
-	/* Set up Advertisement register 3 first */
-	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2);
-	if (ret < 0)
+	ret = amd_xgbe_phy_disable_an(phydev);
+	if (ret)
 		return AMD_XGBE_AN_ERROR;
 
-	if (phydev->supported & SUPPORTED_10000baseR_FEC)
-		ret |= 0xc000;
-	else
-		ret &= ~0xc000;
-
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2, ret);
-
-	/* Set up Advertisement register 2 next */
-	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 1);
-	if (ret < 0)
+	ret = amd_xgbe_phy_switch_mode(phydev);
+	if (ret)
 		return AMD_XGBE_AN_ERROR;
 
-	if (phydev->supported & SUPPORTED_10000baseKR_Full)
-		ret |= 0x80;
-	else
-		ret &= ~0x80;
-
-	if ((phydev->supported & SUPPORTED_1000baseKX_Full) ||
-	    (phydev->supported & SUPPORTED_2500baseX_Full))
-		ret |= 0x20;
-	else
-		ret &= ~0x20;
-
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 1, ret);
-
-	/* Set up Advertisement register 1 last */
-	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
-	if (ret < 0)
+	ret = amd_xgbe_phy_restart_an(phydev);
+	if (ret)
 		return AMD_XGBE_AN_ERROR;
 
-	if (phydev->supported & SUPPORTED_Pause)
-		ret |= 0x400;
-	else
-		ret &= ~0x400;
+	return AMD_XGBE_AN_INCOMPAT_LINK;
+}
 
-	if (phydev->supported & SUPPORTED_Asym_Pause)
-		ret |= 0x800;
-	else
-		ret &= ~0x800;
+static irqreturn_t amd_xgbe_an_isr(int irq, void *data)
+{
+	struct amd_xgbe_phy_priv *priv = (struct amd_xgbe_phy_priv *)data;
 
-	/* We don't intend to perform XNP */
-	ret &= ~XNP_NP_EXCHANGE;
+	/* Interrupt reason must be read and cleared outside of IRQ context */
+	disable_irq_nosync(priv->an_irq);
 
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE, ret);
+	queue_work(priv->an_workqueue, &priv->an_irq_work);
 
-	/* Enable and start auto-negotiation */
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
+	return IRQ_HANDLED;
+}
 
-	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_KR_CTRL);
-	if (ret < 0)
-		return AMD_XGBE_AN_ERROR;
+static void amd_xgbe_an_irq_work(struct work_struct *work)
+{
+	struct amd_xgbe_phy_priv *priv = container_of(work,
+						      struct amd_xgbe_phy_priv,
+						      an_irq_work);
 
-	ret |= MDIO_KR_CTRL_PDETECT;
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_KR_CTRL, ret);
+	/* Avoid a race between enabling the IRQ and exiting the work by
+	 * waiting for the work to finish and then queueing it
+	 */
+	flush_work(&priv->an_work);
+	queue_work(priv->an_workqueue, &priv->an_work);
+}
 
-	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1);
-	if (ret < 0)
-		return AMD_XGBE_AN_ERROR;
+static void amd_xgbe_an_state_machine(struct work_struct *work)
+{
+	struct amd_xgbe_phy_priv *priv = container_of(work,
+						      struct amd_xgbe_phy_priv,
+						      an_work);
+	struct phy_device *phydev = priv->phydev;
+	enum amd_xgbe_phy_an cur_state = priv->an_state;
+	int int_reg, int_mask;
 
-	ret |= MDIO_AN_CTRL1_ENABLE;
-	ret |= MDIO_AN_CTRL1_RESTART;
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1, ret);
+	mutex_lock(&priv->an_mutex);
 
-	return AMD_XGBE_AN_EVENT;
-}
+	/* Read the interrupt */
+	int_reg = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT);
+	if (!int_reg)
+		goto out;
 
-static enum amd_xgbe_phy_an amd_xgbe_an_event(struct phy_device *phydev)
-{
-	enum amd_xgbe_phy_an new_state;
-	int ret;
+next_int:
+	if (int_reg < 0) {
+		priv->an_state = AMD_XGBE_AN_ERROR;
+		int_mask = XGBE_AN_INT_MASK;
+	} else if (int_reg & XGBE_AN_PG_RCV) {
+		priv->an_state = AMD_XGBE_AN_PAGE_RECEIVED;
+		int_mask = XGBE_AN_PG_RCV;
+	} else if (int_reg & XGBE_AN_INC_LINK) {
+		priv->an_state = AMD_XGBE_AN_INCOMPAT_LINK;
+		int_mask = XGBE_AN_INC_LINK;
+	} else if (int_reg & XGBE_AN_INT_CMPLT) {
+		priv->an_state = AMD_XGBE_AN_COMPLETE;
+		int_mask = XGBE_AN_INT_CMPLT;
+	} else {
+		priv->an_state = AMD_XGBE_AN_ERROR;
+		int_mask = 0;
+	}
 
-	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT);
-	if (ret < 0)
-		return AMD_XGBE_AN_ERROR;
+	/* Clear the interrupt to be processed */
+	int_reg &= ~int_mask;
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, int_reg);
 
-	new_state = AMD_XGBE_AN_EVENT;
-	if (ret & XGBE_AN_PG_RCV)
-		new_state = AMD_XGBE_AN_PAGE_RECEIVED;
-	else if (ret & XGBE_AN_INC_LINK)
-		new_state = AMD_XGBE_AN_INCOMPAT_LINK;
-	else if (ret & XGBE_AN_INT_CMPLT)
-		new_state = AMD_XGBE_AN_COMPLETE;
+	priv->an_result = priv->an_state;
 
-	if (new_state != AMD_XGBE_AN_EVENT)
-		phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
+again:
+	cur_state = priv->an_state;
 
-	return new_state;
-}
+	switch (priv->an_state) {
+	case AMD_XGBE_AN_READY:
+		priv->an_supported = 0;
+		break;
 
-static enum amd_xgbe_phy_an amd_xgbe_an_page_received(struct phy_device *phydev)
-{
-	struct amd_xgbe_phy_priv *priv = phydev->priv;
-	enum amd_xgbe_phy_rx *state;
-	int ret;
+	case AMD_XGBE_AN_PAGE_RECEIVED:
+		priv->an_state = amd_xgbe_an_page_received(phydev);
+		priv->an_supported++;
+		break;
 
-	state = amd_xgbe_phy_in_kr_mode(phydev) ? &priv->kr_state
-						: &priv->kx_state;
+	case AMD_XGBE_AN_INCOMPAT_LINK:
+		priv->an_supported = 0;
+		priv->parallel_detect = 0;
+		priv->an_state = amd_xgbe_an_incompat_link(phydev);
+		break;
 
-	switch (*state) {
-	case AMD_XGBE_RX_BPA:
-		ret = amd_xgbe_an_rx_bpa(phydev, state);
+	case AMD_XGBE_AN_COMPLETE:
+		priv->parallel_detect = priv->an_supported ? 0 : 1;
+		netdev_dbg(phydev->attached_dev, "%s successful\n",
+			   priv->an_supported ? "Auto negotiation"
+					      : "Parallel detection");
 		break;
 
-	case AMD_XGBE_RX_XNP:
-		ret = amd_xgbe_an_rx_xnp(phydev, state);
+	case AMD_XGBE_AN_NO_LINK:
 		break;
 
 	default:
-		ret = AMD_XGBE_AN_ERROR;
+		priv->an_state = AMD_XGBE_AN_ERROR;
 	}
 
-	return ret;
-}
+	if (priv->an_state == AMD_XGBE_AN_NO_LINK) {
+		int_reg = 0;
+		phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
+	} else if (priv->an_state == AMD_XGBE_AN_ERROR) {
+		netdev_err(phydev->attached_dev,
+			   "error during auto-negotiation, state=%u\n",
+			   cur_state);
 
-static enum amd_xgbe_phy_an amd_xgbe_an_incompat_link(struct phy_device *phydev)
-{
-	int ret;
+		int_reg = 0;
+		phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
+	}
 
-	ret = amd_xgbe_phy_switch_mode(phydev);
-	if (ret)
-		return AMD_XGBE_AN_ERROR;
+	if (priv->an_state >= AMD_XGBE_AN_COMPLETE) {
+		priv->an_result = priv->an_state;
+		priv->an_state = AMD_XGBE_AN_READY;
+		priv->kr_state = AMD_XGBE_RX_BPA;
+		priv->kx_state = AMD_XGBE_RX_BPA;
+	}
 
-	return AMD_XGBE_AN_START;
-}
+	if (cur_state != priv->an_state)
+		goto again;
 
-static void amd_xgbe_an_state_machine(struct work_struct *work)
-{
-	struct amd_xgbe_phy_priv *priv = container_of(work,
-						      struct amd_xgbe_phy_priv,
-						      an_work);
-	struct phy_device *phydev = priv->phydev;
-	enum amd_xgbe_phy_an cur_state;
-	int sleep;
-	unsigned int an_supported = 0;
+	if (int_reg)
+		goto next_int;
 
-	/* Start in KX mode */
-	if (amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KX))
-		priv->an_state = AMD_XGBE_AN_ERROR;
+out:
+	enable_irq(priv->an_irq);
 
-	while (1) {
-		mutex_lock(&priv->an_mutex);
+	mutex_unlock(&priv->an_mutex);
+}
 
-		cur_state = priv->an_state;
+static int amd_xgbe_an_init(struct phy_device *phydev)
+{
+	int ret;
 
-		switch (priv->an_state) {
-		case AMD_XGBE_AN_START:
-			an_supported = 0;
-			priv->parallel_detect = 0;
-			priv->an_state = amd_xgbe_an_start(phydev);
-			break;
+	/* Set up Advertisement register 3 first */
+	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2);
+	if (ret < 0)
+		return ret;
 
-		case AMD_XGBE_AN_EVENT:
-			priv->an_state = amd_xgbe_an_event(phydev);
-			break;
+	if (phydev->supported & SUPPORTED_10000baseR_FEC)
+		ret |= 0xc000;
+	else
+		ret &= ~0xc000;
 
-		case AMD_XGBE_AN_PAGE_RECEIVED:
-			priv->an_state = amd_xgbe_an_page_received(phydev);
-			an_supported++;
-			break;
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 2, ret);
 
-		case AMD_XGBE_AN_INCOMPAT_LINK:
-			priv->an_state = amd_xgbe_an_incompat_link(phydev);
-			break;
+	/* Set up Advertisement register 2 next */
+	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 1);
+	if (ret < 0)
+		return ret;
 
-		case AMD_XGBE_AN_COMPLETE:
-			priv->parallel_detect = an_supported ? 0 : 1;
-			netdev_info(phydev->attached_dev, "%s successful\n",
-				    an_supported ? "Auto negotiation"
-						 : "Parallel detection");
-			/* fall through */
+	if (phydev->supported & SUPPORTED_10000baseKR_Full)
+		ret |= 0x80;
+	else
+		ret &= ~0x80;
 
-		case AMD_XGBE_AN_NO_LINK:
-		case AMD_XGBE_AN_EXIT:
-			goto exit_unlock;
+	if ((phydev->supported & SUPPORTED_1000baseKX_Full) ||
+	    (phydev->supported & SUPPORTED_2500baseX_Full))
+		ret |= 0x20;
+	else
+		ret &= ~0x20;
 
-		default:
-			priv->an_state = AMD_XGBE_AN_ERROR;
-		}
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE + 1, ret);
 
-		if (priv->an_state == AMD_XGBE_AN_ERROR) {
-			netdev_err(phydev->attached_dev,
-				   "error during auto-negotiation, state=%u\n",
-				   cur_state);
-			goto exit_unlock;
-		}
+	/* Set up Advertisement register 1 last */
+	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE);
+	if (ret < 0)
+		return ret;
 
-		sleep = (priv->an_state == AMD_XGBE_AN_EVENT) ? 1 : 0;
+	if (phydev->supported & SUPPORTED_Pause)
+		ret |= 0x400;
+	else
+		ret &= ~0x400;
 
-		mutex_unlock(&priv->an_mutex);
+	if (phydev->supported & SUPPORTED_Asym_Pause)
+		ret |= 0x800;
+	else
+		ret &= ~0x800;
 
-		if (sleep)
-			usleep_range(20, 50);
-	}
+	/* We don't intend to perform XNP */
+	ret &= ~XNP_NP_EXCHANGE;
 
-exit_unlock:
-	priv->an_result = priv->an_state;
-	priv->an_state = AMD_XGBE_AN_READY;
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_ADVERTISE, ret);
 
-	mutex_unlock(&priv->an_mutex);
+	return 0;
 }
 
 static int amd_xgbe_phy_soft_reset(struct phy_device *phydev)
@@ -995,13 +1051,46 @@ static int amd_xgbe_phy_soft_reset(struct phy_device *phydev)
 	if (ret & MDIO_CTRL1_RESET)
 		return -ETIMEDOUT;
 
-	/* Make sure the XPCS and SerDes are in compatible states */
-	return amd_xgbe_phy_xgmii_mode(phydev);
+	/* Disable auto-negotiation for now */
+	ret = amd_xgbe_phy_disable_an(phydev);
+	if (ret < 0)
+		return ret;
+
+	/* Clear auto-negotiation interrupts */
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
+
+	return 0;
 }
 
 static int amd_xgbe_phy_config_init(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
+	struct net_device *netdev = phydev->attached_dev;
+	int ret;
+
+	if (!priv->an_irq_allocated) {
+		/* Allocate the auto-negotiation workqueue and interrupt */
+		snprintf(priv->an_irq_name, sizeof(priv->an_irq_name) - 1,
+			 "%s-pcs", netdev_name(netdev));
+
+		priv->an_workqueue =
+			create_singlethread_workqueue(priv->an_irq_name);
+		if (!priv->an_workqueue) {
+			netdev_err(netdev, "phy workqueue creation failed\n");
+			return -ENOMEM;
+		}
+
+		ret = devm_request_irq(priv->dev, priv->an_irq,
+				       amd_xgbe_an_isr, 0, priv->an_irq_name,
+				       priv);
+		if (ret) {
+			netdev_err(netdev, "phy irq request failed\n");
+			destroy_workqueue(priv->an_workqueue);
+			return ret;
+		}
+
+		priv->an_irq_allocated = 1;
+	}
 
 	/* Initialize supported features */
 	phydev->supported = SUPPORTED_Autoneg;
@@ -1019,9 +1108,27 @@ static int amd_xgbe_phy_config_init(struct phy_device *phydev)
 	}
 	phydev->advertising = phydev->supported;
 
-	/* Turn off and clear interrupts */
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INTMASK, 0);
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
+	/* Set initial mode - call the mode setting routines
+	 * directly to insure we are properly configured
+	 */
+	if (phydev->supported & SUPPORTED_10000baseKR_Full)
+		ret = amd_xgbe_phy_xgmii_mode(phydev);
+	else if (phydev->supported & SUPPORTED_1000baseKX_Full)
+		ret = amd_xgbe_phy_gmii_mode(phydev);
+	else if (phydev->supported & SUPPORTED_2500baseX_Full)
+		ret = amd_xgbe_phy_gmii_2500_mode(phydev);
+	else
+		ret = -EINVAL;
+	if (ret < 0)
+		return ret;
+
+	/* Set up advertisement registers based on current settings */
+	ret = amd_xgbe_an_init(phydev);
+	if (ret)
+		return ret;
+
+	/* Enable auto-negotiation interrupts */
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INTMASK, 0x07);
 
 	return 0;
 }
@@ -1031,25 +1138,19 @@ static int amd_xgbe_phy_setup_forced(struct phy_device *phydev)
 	int ret;
 
 	/* Disable auto-negotiation */
-	ret = phy_read_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1);
+	ret = amd_xgbe_phy_disable_an(phydev);
 	if (ret < 0)
 		return ret;
 
-	ret &= ~MDIO_AN_CTRL1_ENABLE;
-	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_CTRL1, ret);
-
 	/* Validate/Set specified speed */
 	switch (phydev->speed) {
 	case SPEED_10000:
-		ret = amd_xgbe_phy_xgmii_mode(phydev);
+		ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KR);
 		break;
 
 	case SPEED_2500:
-		ret = amd_xgbe_phy_gmii_2500_mode(phydev);
-		break;
-
 	case SPEED_1000:
-		ret = amd_xgbe_phy_gmii_mode(phydev);
+		ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KX);
 		break;
 
 	default:
@@ -1069,10 +1170,11 @@ static int amd_xgbe_phy_setup_forced(struct phy_device *phydev)
 	return 0;
 }
 
-static int amd_xgbe_phy_config_aneg(struct phy_device *phydev)
+static int __amd_xgbe_phy_config_aneg(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	u32 mmd_mask = phydev->c45_ids.devices_in_package;
+	int ret;
 
 	if (phydev->autoneg != AUTONEG_ENABLE)
 		return amd_xgbe_phy_setup_forced(phydev);
@@ -1081,56 +1183,79 @@ static int amd_xgbe_phy_config_aneg(struct phy_device *phydev)
 	if (!(mmd_mask & MDIO_DEVS_AN))
 		return -EINVAL;
 
-	/* Start/Restart the auto-negotiation state machine */
-	mutex_lock(&priv->an_mutex);
+	/* Disable auto-negotiation interrupt */
+	disable_irq(priv->an_irq);
+
+	/* Start auto-negotiation in a supported mode */
+	if (phydev->supported & SUPPORTED_10000baseKR_Full)
+		ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KR);
+	else if ((phydev->supported & SUPPORTED_1000baseKX_Full) ||
+		 (phydev->supported & SUPPORTED_2500baseX_Full))
+		ret = amd_xgbe_phy_set_mode(phydev, AMD_XGBE_MODE_KX);
+	else
+		ret = -EINVAL;
+	if (ret < 0) {
+		enable_irq(priv->an_irq);
+		return ret;
+	}
+
+	/* Disable and stop any in progress auto-negotiation */
+	ret = amd_xgbe_phy_disable_an(phydev);
+	if (ret < 0)
+		return ret;
+
+	/* Clear any auto-negotitation interrupts */
+	phy_write_mmd(phydev, MDIO_MMD_AN, MDIO_AN_INT, 0);
+
 	priv->an_result = AMD_XGBE_AN_READY;
-	priv->an_state = AMD_XGBE_AN_START;
-	priv->kr_state = AMD_XGBE_RX_READY;
-	priv->kx_state = AMD_XGBE_RX_READY;
-	mutex_unlock(&priv->an_mutex);
+	priv->an_state = AMD_XGBE_AN_READY;
+	priv->kr_state = AMD_XGBE_RX_BPA;
+	priv->kx_state = AMD_XGBE_RX_BPA;
 
-	queue_work(priv->an_workqueue, &priv->an_work);
+	/* Re-enable auto-negotiation interrupt */
+	enable_irq(priv->an_irq);
 
-	return 0;
+	/* Set up advertisement registers based on current settings */
+	ret = amd_xgbe_an_init(phydev);
+	if (ret)
+		return ret;
+
+	/* Enable and start auto-negotiation */
+	return amd_xgbe_phy_restart_an(phydev);
 }
 
-static int amd_xgbe_phy_aneg_done(struct phy_device *phydev)
+static int amd_xgbe_phy_config_aneg(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
-	enum amd_xgbe_phy_an state;
+	int ret;
 
 	mutex_lock(&priv->an_mutex);
-	state = priv->an_result;
+
+	ret = __amd_xgbe_phy_config_aneg(phydev);
+
 	mutex_unlock(&priv->an_mutex);
 
-	return (state == AMD_XGBE_AN_COMPLETE);
+	return ret;
+}
+
+static int amd_xgbe_phy_aneg_done(struct phy_device *phydev)
+{
+	struct amd_xgbe_phy_priv *priv = phydev->priv;
+
+	return (priv->an_result == AMD_XGBE_AN_COMPLETE);
 }
 
 static int amd_xgbe_phy_update_link(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
-	enum amd_xgbe_phy_an state;
-	unsigned int check_again, autoneg;
 	int ret;
 
 	/* If we're doing auto-negotiation don't report link down */
-	mutex_lock(&priv->an_mutex);
-	state = priv->an_state;
-	mutex_unlock(&priv->an_mutex);
-
-	if (state != AMD_XGBE_AN_READY) {
+	if (priv->an_state != AMD_XGBE_AN_READY) {
 		phydev->link = 1;
 		return 0;
 	}
 
-	/* Since the device can be in the wrong mode when a link is
-	 * (re-)established (cable connected after the interface is
-	 * up, etc.), the link status may report no link. If there
-	 * is no link, try switching modes and checking the status
-	 * again if auto negotiation is enabled.
-	 */
-	check_again = (phydev->autoneg == AUTONEG_ENABLE) ? 1 : 0;
-again:
 	/* Link status is latched low, so read once to clear
 	 * and then read again to get current state
 	 */
@@ -1144,25 +1269,6 @@ again:
 
 	phydev->link = (ret & MDIO_STAT1_LSTATUS) ? 1 : 0;
 
-	if (!phydev->link) {
-		if (check_again) {
-			ret = amd_xgbe_phy_switch_mode(phydev);
-			if (ret < 0)
-				return ret;
-			check_again = 0;
-			goto again;
-		}
-	}
-
-	autoneg = (phydev->link && !priv->link) ? 1 : 0;
-	priv->link = phydev->link;
-	if (autoneg) {
-		/* Link is (back) up, re-start auto-negotiation */
-		ret = amd_xgbe_phy_config_aneg(phydev);
-		if (ret < 0)
-			return ret;
-	}
-
 	return 0;
 }
 
@@ -1293,7 +1399,6 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 	struct amd_xgbe_phy_priv *priv;
 	struct platform_device *pdev;
 	struct device *dev;
-	char *wq_name;
 	const __be32 *property;
 	unsigned int speed_set;
 	int ret;
@@ -1306,21 +1411,18 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		return -EINVAL;
 	dev = &pdev->dev;
 
-	wq_name = kasprintf(GFP_KERNEL, "%s-amd-xgbe-phy", phydev->bus->name);
-	if (!wq_name) {
-		ret = -ENOMEM;
-		goto err_pdev;
-	}
-
 	priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
 	if (!priv) {
 		ret = -ENOMEM;
-		goto err_name;
+		goto err_pdev;
 	}
 
 	priv->pdev = pdev;
 	priv->dev = dev;
 	priv->phydev = phydev;
+	mutex_init(&priv->an_mutex);
+	INIT_WORK(&priv->an_irq_work, amd_xgbe_an_irq_work);
+	INIT_WORK(&priv->an_work, amd_xgbe_an_state_machine);
 
 	/* Get the device mmio areas */
 	priv->rxtx_res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
@@ -1347,6 +1449,14 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		goto err_sir0;
 	}
 
+	/* Get the auto-negotiation interrupt */
+	ret = platform_get_irq(pdev, 0);
+	if (ret < 0) {
+		dev_err(dev, "platform_get_irq failed\n");
+		goto err_sir1;
+	}
+	priv->an_irq = ret;
+
 	/* Get the device speed set property */
 	speed_set = 0;
 	property = of_get_property(dev->of_node, XGBE_PHY_SPEEDSET_PROPERTY,
@@ -1367,19 +1477,8 @@ static int amd_xgbe_phy_probe(struct phy_device *phydev)
 		goto err_sir1;
 	}
 
-	priv->link = 1;
-
-	mutex_init(&priv->an_mutex);
-	INIT_WORK(&priv->an_work, amd_xgbe_an_state_machine);
-	priv->an_workqueue = create_singlethread_workqueue(wq_name);
-	if (!priv->an_workqueue) {
-		ret = -ENOMEM;
-		goto err_sir1;
-	}
-
 	phydev->priv = priv;
 
-	kfree(wq_name);
 	of_dev_put(pdev);
 
 	return 0;
@@ -1402,9 +1501,6 @@ err_rxtx:
 err_priv:
 	devm_kfree(dev, priv);
 
-err_name:
-	kfree(wq_name);
-
 err_pdev:
 	of_dev_put(pdev);
 
@@ -1416,13 +1512,12 @@ static void amd_xgbe_phy_remove(struct phy_device *phydev)
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
 	struct device *dev = priv->dev;
 
-	/* Stop any in process auto-negotiation */
-	mutex_lock(&priv->an_mutex);
-	priv->an_state = AMD_XGBE_AN_EXIT;
-	mutex_unlock(&priv->an_mutex);
+	if (priv->an_irq_allocated) {
+		devm_free_irq(dev, priv->an_irq, priv);
 
-	flush_workqueue(priv->an_workqueue);
-	destroy_workqueue(priv->an_workqueue);
+		flush_workqueue(priv->an_workqueue);
+		destroy_workqueue(priv->an_workqueue);
+	}
 
 	/* Release resources */
 	devm_iounmap(dev, priv->sir1_regs);
