From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 06/19] i40e: Blink LED on 1G BaseT boards
Date: Wed,  7 Dec 2016 14:19:05 -0800
Message-ID: <20161207221918.57932-7-jeffrey.t.kirsher@intel.com>
References: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Cc: Henry Tieman <henry.w.tieman@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:59427 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933424AbcLGWUN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 17:20:13 -0500
In-Reply-To: <20161207221918.57932-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Henry Tieman <henry.w.tieman@intel.com>

Before this patch "ethtool -p" was not blinking the LEDs on boards
with 1G BaseT PHYs.

This commit identifies 1G BaseT boards as having the LEDs connected
to the MAC. Also, renamed the flag to be more descriptive of usage.
The flag is now I40E_FLAG_PHY_CONTROLS_LEDS.

Change-ID: I4eb741da9780da7849ddf2dc4c0cb27ffa42a801
Signed-off-by: Henry Tieman <henry.w.tieman@intel.com>
Signed-off-by: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 10 +++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 06e3c23..b8f2978 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -356,7 +356,7 @@ struct i40e_pf {
 #define I40E_FLAG_NO_DCB_SUPPORT		BIT_ULL(45)
 #define I40E_FLAG_USE_SET_LLDP_MIB		BIT_ULL(46)
 #define I40E_FLAG_STOP_FW_LLDP			BIT_ULL(47)
-#define I40E_FLAG_HAVE_10GBASET_PHY		BIT_ULL(48)
+#define I40E_FLAG_PHY_CONTROLS_LEDS		BIT_ULL(48)
 #define I40E_FLAG_PF_MAC			BIT_ULL(50)
 #define I40E_FLAG_TRUE_PROMISC_SUPPORT		BIT_ULL(51)
 #define I40E_FLAG_HAVE_CRT_RETIMER		BIT_ULL(52)
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 76753e1..6ba0035 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1890,7 +1890,7 @@ static int i40e_set_phys_id(struct net_device *netdev,
 
 	switch (state) {
 	case ETHTOOL_ID_ACTIVE:
-		if (!(pf->flags & I40E_FLAG_HAVE_10GBASET_PHY)) {
+		if (!(pf->flags & I40E_FLAG_PHY_CONTROLS_LEDS)) {
 			pf->led_status = i40e_led_get(hw);
 		} else {
 			i40e_aq_set_phy_debug(hw, I40E_PHY_DEBUG_ALL, NULL);
@@ -1900,20 +1900,20 @@ static int i40e_set_phys_id(struct net_device *netdev,
 		}
 		return blink_freq;
 	case ETHTOOL_ID_ON:
-		if (!(pf->flags & I40E_FLAG_HAVE_10GBASET_PHY))
+		if (!(pf->flags & I40E_FLAG_PHY_CONTROLS_LEDS))
 			i40e_led_set(hw, 0xf, false);
 		else
 			ret = i40e_led_set_phy(hw, true, pf->led_status, 0);
 		break;
 	case ETHTOOL_ID_OFF:
-		if (!(pf->flags & I40E_FLAG_HAVE_10GBASET_PHY))
+		if (!(pf->flags & I40E_FLAG_PHY_CONTROLS_LEDS))
 			i40e_led_set(hw, 0x0, false);
 		else
 			ret = i40e_led_set_phy(hw, false, pf->led_status, 0);
 		break;
 	case ETHTOOL_ID_INACTIVE:
-		if (!(pf->flags & I40E_FLAG_HAVE_10GBASET_PHY)) {
-			i40e_led_set(hw, false, pf->led_status);
+		if (!(pf->flags & I40E_FLAG_PHY_CONTROLS_LEDS)) {
+			i40e_led_set(hw, pf->led_status, false);
 		} else {
 			ret = i40e_led_set_phy(hw, false, pf->led_status,
 					       (pf->phy_led_val |
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index ae4a2b2..dbb854b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -11380,8 +11380,8 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 						       pf->main_vsi_seid);
 
 	if ((pf->hw.device_id == I40E_DEV_ID_10G_BASE_T) ||
-	    (pf->hw.device_id == I40E_DEV_ID_10G_BASE_T4))
-		pf->flags |= I40E_FLAG_HAVE_10GBASET_PHY;
+		(pf->hw.device_id == I40E_DEV_ID_10G_BASE_T4))
+		pf->flags |= I40E_FLAG_PHY_CONTROLS_LEDS;
 	if (pf->hw.device_id == I40E_DEV_ID_SFP_I_X722)
 		pf->flags |= I40E_FLAG_HAVE_CRT_RETIMER;
 	/* print a string summarizing features */
-- 
2.9.3
