From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 06/13] e1000: explicit locking for two ethtool path functions
Date: Wed, 16 Aug 2006 14:56:28 -0700
Message-ID: <20060816215628.27080.36223.stgit@gitlost.site>
References: <20060816215336.27080.56147.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:59401 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932256AbWHPVsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 17:48:40 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060816215336.27080.56147.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Explicitly lock two more ethtool entry points completely instead
of the hardware reset only to prevent a race condition.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_ethtool.c |   33 +++++++++++++++++++++++----------
 1 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 8edbc6b..2baccf8 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -183,6 +183,9 @@ e1000_set_settings(struct net_device *ne
 		return -EINVAL;
 	}
 
+	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
+		msleep(1);
+
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
 		hw->autoneg = 1;
 		if (hw->media_type == e1000_media_type_fiber)
@@ -199,16 +202,20 @@ e1000_set_settings(struct net_device *ne
 						  ADVERTISED_TP;
 		ecmd->advertising = hw->autoneg_advertised;
 	} else
-		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex))
+		if (e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex)) {
+			clear_bit(__E1000_RESETTING, &adapter->flags);
 			return -EINVAL;
+		}
 
 	/* reset the link */
 
-	if (netif_running(adapter->netdev))
-		e1000_reinit_locked(adapter);
-	else
+	if (netif_running(adapter->netdev)) {
+		e1000_down(adapter);
+		e1000_up(adapter);
+	} else
 		e1000_reset(adapter);
 
+	clear_bit(__E1000_RESETTING, &adapter->flags);
 	return 0;
 }
 
@@ -238,9 +245,13 @@ e1000_set_pauseparam(struct net_device *
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int retval = 0;
 
 	adapter->fc_autoneg = pause->autoneg;
 
+	while (test_and_set_bit(__E1000_RESETTING, &adapter->flags))
+		msleep(1);
+
 	if (pause->rx_pause && pause->tx_pause)
 		hw->fc = e1000_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
@@ -253,15 +264,17 @@ e1000_set_pauseparam(struct net_device *
 	hw->original_fc = hw->fc;
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
-		if (netif_running(adapter->netdev))
-			e1000_reinit_locked(adapter);
-		else
+		if (netif_running(adapter->netdev)) {
+			e1000_down(adapter);
+			e1000_up(adapter);
+		} else
 			e1000_reset(adapter);
 	} else
-		return ((hw->media_type == e1000_media_type_fiber) ?
-			e1000_setup_link(hw) : e1000_force_mac_fc(hw));
+		retval = ((hw->media_type == e1000_media_type_fiber) ?
+			   e1000_setup_link(hw) : e1000_force_mac_fc(hw));
 
-	return 0;
+	clear_bit(__E1000_RESETTING, &adapter->flags);
+	return retval;
 }
 
 static uint32_t



--
Auke Kok <auke-jan.h.kok@intel.com>
