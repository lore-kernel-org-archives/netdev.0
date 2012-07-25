From: w90p710@gmail.com
Subject: [PATCH v0 net-next 1/1] net/pch_gpe: Cannot disable ethernet autonegation
Date: Wed, 25 Jul 2012 20:13:59 +0800
Message-ID: <1343218439-5403-1-git-send-email-w90p710@gmail.com>
Cc: netdev@vger.kernel.org, Wei Yang <w90p710@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:43216 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756529Ab2GYMPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 08:15:24 -0400
Received: by yenl2 with SMTP id l2so593643yen.19
        for <netdev@vger.kernel.org>; Wed, 25 Jul 2012 05:15:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yang <w90p710@gmail.com>

When attempting to disable ethernet autonegation via ethtool,
the pch_gpe driver will set software reset bit of PHY chip, But 
control register of PHY chip of FRI2 will reenable ethernet autonegation.

Signed-off-by: Wei Yang <w90p710@gmail.com>
---
 .../ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c    |    1 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |    4 +++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index ac4e72d..e2be4a7 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -129,7 +129,6 @@ static int pch_gbe_set_settings(struct net_device *netdev,
 	hw->mac.link_duplex = ecmd->duplex;
 	hw->phy.autoneg_advertised = ecmd->advertising;
 	hw->mac.autoneg = ecmd->autoneg;
-	pch_gbe_hal_phy_sw_reset(hw);
 
 	/* reset the link */
 	if (netif_running(adapter->netdev)) {
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3787c64..8e6d2aa 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1988,6 +1988,7 @@ int pch_gbe_up(struct pch_gbe_adapter *adapter)
 void pch_gbe_down(struct pch_gbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
 	struct pch_gbe_rx_ring *rx_ring = adapter->rx_ring;
 
 	/* signal that we're down so the interrupt handler does not
@@ -2004,7 +2005,8 @@ void pch_gbe_down(struct pch_gbe_adapter *adapter)
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
 
-	pch_gbe_reset(adapter);
+	if ((pdev->error_state) && (pdev->error_state != pci_channel_io_normal))
+		pch_gbe_reset(adapter);
 	pch_gbe_clean_tx_ring(adapter, adapter->tx_ring);
 	pch_gbe_clean_rx_ring(adapter, adapter->rx_ring);
 
-- 
1.7.9.5
