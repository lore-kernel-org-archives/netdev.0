From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH net-next v3.16]r9169:  Correct Set Vlan tag
Date: Tue, 29 Mar 2016 11:33:20 +0300
Message-ID: <1459240400-1602-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-227-26.residential.rdsnet.ro ([5.14.227.26]:50128 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbcC2JAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 05:00:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch add set Vlan tag and flush CPlusCmd register because when unset
 RxVlan and RxChkSum bit, whithout some explication , unwanted bits
 is set, PCIDAC, PCIMulRW  and others.Whithout this patch when run
 ethtool -d eth0 on "C+ Command" field missing "VLAN de-tagging"

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 21 +++------------------
 1 file changed, 3 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 2594bbb..df7ea28 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -752,7 +752,7 @@ struct rtl8169_private {
 	void *Rx_databuff[NUM_RX_DESC];	/* Rx data buffers */
 	struct ring_info tx_skb[NUM_TX_DESC];	/* Tx data buffers */
 	struct timer_list timer;
-	u16 cp_cmd;
+	int cp_cmd;
 
 	u16 event_slow;
 
@@ -1797,7 +1797,7 @@ static void __rtl8169_set_features(struct net_device *dev,
 				   netdev_features_t features)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	netdev_features_t changed = features ^ dev->features;
+	netdev_features_t changed = features & dev->features;
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	if (!(changed & (NETIF_F_RXALL | NETIF_F_RXCSUM |
@@ -1807,16 +1807,10 @@ static void __rtl8169_set_features(struct net_device *dev,
 	if (changed & (NETIF_F_RXCSUM | NETIF_F_HW_VLAN_CTAG_RX)) {
 		if (features & NETIF_F_RXCSUM)
 			tp->cp_cmd |= RxChkSum;
-		else
-			tp->cp_cmd &= ~RxChkSum;
 
 		if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
 			tp->cp_cmd |= RxVlan;
-		else
-			tp->cp_cmd &= ~RxVlan;
 
-		RTL_W16(CPlusCmd, tp->cp_cmd);
-		RTL_R16(CPlusCmd);
 	}
 	if (changed & NETIF_F_RXALL) {
 		int tmp = (RTL_R32(RxConfig) & ~(AcceptErr | AcceptRunt));
@@ -6573,8 +6567,6 @@ static int rtl_open(struct net_device *dev)
 
 	rtl8169_init_phy(dev, tp);
 
-	__rtl8169_set_features(dev, dev->features);
-
 	rtl_pll_power_up(tp);
 
 	rtl_hw_start(dev);
@@ -7060,7 +7052,7 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_mwi_2;
 	}
 
-	tp->cp_cmd = RxChkSum;
+	tp->cp_cmd = ~0xffff;
 
 	if ((sizeof(dma_addr_t) > 4) &&
 	    !pci_set_dma_mask(pdev, DMA_BIT_MASK(64)) && use_dac) {
@@ -7101,13 +7093,6 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_master(pdev);
 
-	/*
-	 * Pretend we are using VLANs; This bypasses a nasty bug where
-	 * Interrupts stop flowing on high load on 8110SCd controllers.
-	 */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		tp->cp_cmd |= RxVlan;
-
 	rtl_init_mdio_ops(tp);
 	rtl_init_pll_power_ops(tp);
 	rtl_init_jumbo_ops(tp);
-- 
2.1.4
