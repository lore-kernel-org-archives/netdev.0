From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC PATCH 3/3] e1000: configure and read mdix settings
Date: Wed, 17 Nov 2010 15:29:21 -0800
Message-ID: <20101117232921.3513.80939.stgit@jbrandeb-ich9b.jf.intel.com>
References: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:55834 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751402Ab0KQX3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 18:29:21 -0500
Received: from jbrandeb-ich9b.jf.intel.com (localhost.localdomain [127.0.0.1])
	by jbrandeb-ich9b.jf.intel.com (8.14.4/8.14.4) with ESMTP id oAHNTLEM003588
	for <netdev@vger.kernel.org>; Wed, 17 Nov 2010 15:29:21 -0800
In-Reply-To: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
---

 drivers/net/e1000/e1000.h         |    1 -
 drivers/net/e1000/e1000_ethtool.c |   13 +++++++++++++
 drivers/net/e1000/e1000_main.c    |    2 +-
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index a881dd0..e2767ab 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -130,7 +130,6 @@ struct e1000_adapter;
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define E1000_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
-#define AUTO_ALL_MODES            0
 #define E1000_EEPROM_82544_APM    0x0004
 #define E1000_EEPROM_APME         0x0400
 
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index f4d0922..5e2c83f 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -174,6 +174,14 @@ static int e1000_get_settings(struct net_device *netdev,
 
 	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
 			 hw->autoneg) ? AUTONEG_ENABLE : AUTONEG_DISABLE;
+
+	/* MDI-X => 2; MDI =>1; Invalid =>0 */
+	if ((hw->media_type == e1000_media_type_copper) &&
+	    netif_carrier_ok(netdev))
+		ecmd->eth_tp_mdix = hw->mdix;
+	else
+		ecmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
+
 	return 0;
 }
 
@@ -203,6 +211,11 @@ static int e1000_set_settings(struct net_device *netdev,
 			return -EINVAL;
 		}
 
+	/* MDI-X => 2; MDI =>1; Auto =>0 */
+	if ((ecmd->eth_tp_mdix != -1) &&
+	    (hw->media_type == e1000_media_type_copper))
+		hw->mdix = ecmd->eth_tp_mdix;
+
 	/* reset the link */
 
 	if (netif_running(adapter->netdev)) {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4686c39..0252a01 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -860,7 +860,7 @@ static int e1000_init_hw_struct(struct e1000_adapter *adapter,
 	/* Copper options */
 
 	if (hw->media_type == e1000_media_type_copper) {
-		hw->mdix = AUTO_ALL_MODES;
+		hw->mdix = ETH_TP_MDI_INVALID;
 		hw->disable_polarity_correction = false;
 		hw->master_slave = E1000_MASTER_SLAVE;
 	}

