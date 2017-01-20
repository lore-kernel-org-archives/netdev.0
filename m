From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH] [net-next][v2] net: qcom/emac: claim the irq only when the device is opened
Date: Fri, 20 Jan 2017 17:21:04 -0600
Message-ID: <1484954464-2622-2-git-send-email-timur@codeaurora.org>
References: <1484954464-2622-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46206 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752577AbdATXVK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 18:21:10 -0500
In-Reply-To: <1484954464-2622-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During reset, functions emac_mac_down() and emac_mac_up() are called,
so we don't want to free and claim the IRQ unnecessarily.  Move those
operations to open/close.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---

Notes:
    v2: keep synchronize_irq call where it is

 drivers/net/ethernet/qualcomm/emac/emac-mac.c | 13 -------------
 drivers/net/ethernet/qualcomm/emac/emac.c     | 11 +++++++++++
 drivers/net/ethernet/qualcomm/emac/emac.h     |  1 -
 3 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-mac.c b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
index 98570eb..e4793d7 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-mac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-mac.c
@@ -314,8 +314,6 @@ struct emac_skb_cb {
 	RX_PKT_INT2     |\
 	RX_PKT_INT3)
 
-#define EMAC_MAC_IRQ_RES                                    	"core0"
-
 void emac_mac_multicast_addr_set(struct emac_adapter *adpt, u8 *addr)
 {
 	u32 crc32, bit, reg, mta;
@@ -977,26 +975,16 @@ static void emac_adjust_link(struct net_device *netdev)
 int emac_mac_up(struct emac_adapter *adpt)
 {
 	struct net_device *netdev = adpt->netdev;
-	struct emac_irq	*irq = &adpt->irq;
 	int ret;
 
 	emac_mac_rx_tx_ring_reset_all(adpt);
 	emac_mac_config(adpt);
-
-	ret = request_irq(irq->irq, emac_isr, 0, EMAC_MAC_IRQ_RES, irq);
-	if (ret) {
-		netdev_err(adpt->netdev, "could not request %s irq\n",
-			   EMAC_MAC_IRQ_RES);
-		return ret;
-	}
-
 	emac_mac_rx_descs_refill(adpt, &adpt->rx_q);
 
 	ret = phy_connect_direct(netdev, adpt->phydev, emac_adjust_link,
 				 PHY_INTERFACE_MODE_SGMII);
 	if (ret) {
 		netdev_err(adpt->netdev, "could not connect phy\n");
-		free_irq(irq->irq, irq);
 		return ret;
 	}
 
@@ -1030,7 +1018,6 @@ void emac_mac_down(struct emac_adapter *adpt)
 	writel(DIS_INT, adpt->base + EMAC_INT_STATUS);
 	writel(0, adpt->base + EMAC_INT_MASK);
 	synchronize_irq(adpt->irq.irq);
-	free_irq(adpt->irq.irq, &adpt->irq);
 
 	phy_disconnect(adpt->phydev);
 
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.c b/drivers/net/ethernet/qualcomm/emac/emac.c
index b74ec7f..3e1be91 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac.c
@@ -256,18 +256,27 @@ static int emac_change_mtu(struct net_device *netdev, int new_mtu)
 static int emac_open(struct net_device *netdev)
 {
 	struct emac_adapter *adpt = netdev_priv(netdev);
+	struct emac_irq	*irq = &adpt->irq;
 	int ret;
 
+	ret = request_irq(irq->irq, emac_isr, 0, "emac-core0", irq);
+	if (ret) {
+		netdev_err(adpt->netdev, "could not request emac-core0 irq\n");
+		return ret;
+	}
+
 	/* allocate rx/tx dma buffer & descriptors */
 	ret = emac_mac_rx_tx_rings_alloc_all(adpt);
 	if (ret) {
 		netdev_err(adpt->netdev, "error allocating rx/tx rings\n");
+		free_irq(irq->irq, irq);
 		return ret;
 	}
 
 	ret = emac_mac_up(adpt);
 	if (ret) {
 		emac_mac_rx_tx_rings_free_all(adpt);
+		free_irq(irq->irq, irq);
 		return ret;
 	}
 
@@ -286,6 +295,8 @@ static int emac_close(struct net_device *netdev)
 	emac_mac_down(adpt);
 	emac_mac_rx_tx_rings_free_all(adpt);
 
+	free_irq(adpt->irq.irq, &adpt->irq);
+
 	mutex_unlock(&adpt->reset_lock);
 
 	return 0;
diff --git a/drivers/net/ethernet/qualcomm/emac/emac.h b/drivers/net/ethernet/qualcomm/emac/emac.h
index 1368440..2725507 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac.h
+++ b/drivers/net/ethernet/qualcomm/emac/emac.h
@@ -331,7 +331,6 @@ struct emac_adapter {
 
 int emac_reinit_locked(struct emac_adapter *adpt);
 void emac_reg_update32(void __iomem *addr, u32 mask, u32 val);
-irqreturn_t emac_isr(int irq, void *data);
 
 void emac_set_ethtool_ops(struct net_device *netdev);
 void emac_update_hw_stats(struct emac_adapter *adpt);
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
