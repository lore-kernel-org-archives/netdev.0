From: Ondrej Puzman <puzman@gmail.com>
Subject: [PATCH 4/4] pch_gbe: Fix: Link configuration in module parameters was ignored
Date: Thu, 28 Nov 2013 10:44:42 +0100
Message-ID: <1385631882-12827-5-git-send-email-puzman@gmail.com>
References: <20131127.203929.1379316258754767343.davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ondrej Puzman <puzman@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131127.203929.1379316258754767343.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PHY configuration set in pch_gbe_phy_init_setting() by mii_ethtool_sset() was immedeiately reset by two calls of pch_gbe_phy_sw_reset().
Result of this bug was that module parameters like AutoNeg were ignored silently.

Signed-off-by: Ondrej Puzman <puzman@gmail.com>
---
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |    4 ----
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    |   13 +------------
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |    1 -
 3 files changed, 1 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
index ff3ad70..365c202 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
@@ -77,10 +77,6 @@ static s32 pch_gbe_plat_init_hw(struct pch_gbe_hw *hw)
 		return ret_val;
 	}
 	pch_gbe_phy_init_setting(hw);
-	/* Setup Mac interface option RGMII */
-#ifdef PCH_GBE_MAC_IFOP_RGMII
-	pch_gbe_phy_set_rgmii(hw);
-#endif
 	return ret_val;
 }
 
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
index 8b7ff75..d283818 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c
@@ -249,15 +249,6 @@ void pch_gbe_phy_power_down(struct pch_gbe_hw *hw)
 }
 
 /**
- * pch_gbe_phy_set_rgmii - RGMII interface setting
- * @hw:	            Pointer to the HW structure
- */
-void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw)
-{
-	pch_gbe_phy_sw_reset(hw);
-}
-
-/**
  * pch_gbe_phy_tx_clk_delay - Setup TX clock delay via the PHY
  * @hw:	            Pointer to the HW structure
  * Returns
@@ -321,13 +312,11 @@ void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw)
 	cmd.duplex = hw->mac.link_duplex;
 	cmd.advertising = hw->phy.autoneg_advertised;
 	cmd.autoneg = hw->mac.autoneg;
-	pch_gbe_phy_write_reg_miic(hw, MII_BMCR, BMCR_RESET);
+	pch_gbe_phy_sw_reset(hw);
 	ret = mii_ethtool_sset(&adapter->mii, &cmd);
 	if (ret)
 		netdev_err(adapter->netdev, "Error: mii_ethtool_sset\n");
 
-	pch_gbe_phy_sw_reset(hw);
-
 	pch_gbe_phy_read_reg_miic(hw, PHY_PHYSP_CONTROL, &mii_reg);
 	mii_reg |= PHYSP_CTRL_ASSERT_CRS_TX;
 	pch_gbe_phy_write_reg_miic(hw, PHY_PHYSP_CONTROL, mii_reg);
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
index 0cbe692..cda223c 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
@@ -31,7 +31,6 @@ void pch_gbe_phy_sw_reset(struct pch_gbe_hw *hw);
 void pch_gbe_phy_hw_reset(struct pch_gbe_hw *hw);
 void pch_gbe_phy_power_up(struct pch_gbe_hw *hw);
 void pch_gbe_phy_power_down(struct pch_gbe_hw *hw);
-void pch_gbe_phy_set_rgmii(struct pch_gbe_hw *hw);
 void pch_gbe_phy_init_setting(struct pch_gbe_hw *hw);
 int pch_gbe_phy_disable_hibernate(struct pch_gbe_hw *hw);
 
-- 
1.7.2.3
