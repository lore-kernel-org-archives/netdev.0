From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC PATCH 2/3] igb: update to allow reading/setting mdix
Date: Wed, 17 Nov 2010 15:29:16 -0800
Message-ID: <20101117232915.3513.29988.stgit@jbrandeb-ich9b.jf.intel.com>
References: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55694 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751373Ab0KQX30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 18:29:26 -0500
Received: from jbrandeb-ich9b.jf.intel.com (localhost.localdomain [127.0.0.1])
	by jbrandeb-ich9b.jf.intel.com (8.14.4/8.14.4) with ESMTP id oAHNTGu9003574
	for <netdev@vger.kernel.org>; Wed, 17 Nov 2010 15:29:16 -0800
In-Reply-To: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
---

 drivers/net/igb/igb.h         |    1 -
 drivers/net/igb/igb_ethtool.c |   14 ++++++++++++++
 drivers/net/igb/igb_main.c    |    2 +-
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index edab9c4..04f7a05 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -120,7 +120,6 @@ struct vf_data_storage {
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IGB_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
-#define AUTO_ALL_MODES            0
 #define IGB_EEPROM_APME         0x0400
 
 #ifndef IGB_MASTER_SLAVE
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index a70e16b..bfeee01 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -191,6 +191,15 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 	}
 
 	ecmd->autoneg = hw->mac.autoneg ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 2; MDI =>1; Invalid =>0 */
+	if ((hw->phy.media_type == e1000_media_type_copper) &&
+	    netif_carrier_ok(netdev))
+		ecmd->eth_tp_mdix = hw->phy.is_mdix ? ETH_TP_MDI_X :
+		                                      ETH_TP_MDI;
+	else
+		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+
 	return 0;
 }
 
@@ -225,6 +234,11 @@ static int igb_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		}
 	}
 
+	/* MDI-X => 2; MDI =>1; Auto =>0 */
+	if ((ecmd->eth_tp_mdix != -1) &&
+	    (hw->phy.media_type == e1000_media_type_copper))
+		hw->phy.mdix = ecmd->eth_tp_mdix;
+
 	/* reset the link */
 	if (netif_running(adapter->netdev)) {
 		igb_down(adapter);
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 892d196..338825f 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1838,7 +1838,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	/* Copper options */
 	if (hw->phy.media_type == e1000_media_type_copper) {
-		hw->phy.mdix = AUTO_ALL_MODES;
+		hw->phy.mdix = ETH_TP_MDI_INVALID;
 		hw->phy.disable_polarity_correction = false;
 		hw->phy.ms_type = e1000_ms_hw_default;
 	}

