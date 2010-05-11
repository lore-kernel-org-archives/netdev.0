From: Pete Zaitcev <zaitcev@redhat.com>
Subject: e1000e fails probe
Date: Mon, 10 May 2010 18:50:18 -0600
Message-ID: <20100510185018.3478bcae@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: zaitcev@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41714 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755754Ab0EKAuL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 20:50:11 -0400
Received: from int-mx08.intmail.prod.int.phx2.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o4B0oB6A000597
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 20:50:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear All:

I have a box where e1000e would refuse to probe the onboard interface
with the following in dmesg:

e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
e1000e 0000:00:19.0: setting latency timer to 64
e1000e 0000:00:19.0: irq 34 for MSI/MSI-X
0000:00:19.0: 0000:00:19.0: MDI Error
e1000e 0000:00:19.0: PCI INT A disabled
e1000e: probe of 0000:00:19.0 failed with error -2

The "MDI Error" seems to indicate a hardware failure, so I paid it no
mind until I noticed that RHEL 5 works. So, I diffed the drivers
between Linus' 2.6.34-rc5 and RHEL's 2.6.18-180.el5, with the following
minimal patch working for me:

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8b5e157..b97cd9f 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -276,19 +276,21 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 
 	phy->id = e1000_phy_unknown;
 	ret_val = e1000e_get_phy_id(hw);
-	if (ret_val)
-		goto out;
-	if ((phy->id == 0) || (phy->id == PHY_REVISION_MASK)) {
+/* P3 */ printk("get_phy_id.fast ret %d id %d\n", ret_val, phy->id);
+	if (ret_val || (phy->id == 0) || (phy->id == PHY_REVISION_MASK)) {
 		/*
 		 * In case the PHY needs to be in mdio slow mode (eg. 82577),
 		 * set slow mode and try to get the PHY id again.
 		 */
 		ret_val = e1000_set_mdio_slow_mode_hv(hw);
-		if (ret_val)
-			goto out;
-		ret_val = e1000e_get_phy_id(hw);
-		if (ret_val)
-			goto out;
+		if (ret_val) {
+/* P3 */ printk("failed to set mdio slow mode %d\n", ret_val);
+			phy->id = e1000_phy_unknown;
+		} else {
+			ret_val = e1000e_get_phy_id(hw);
+/* P3 */ printk("get_phy_id.slow ret %d id %d\n", ret_val, phy->id);
+		}
+		ret_val = 0; /* P3 */
 	}
 	phy->type = e1000e_get_phy_type_from_id(phy->id);
 
@@ -307,11 +309,10 @@ static s32 e1000_init_phy_params_pchlan(struct e1000_hw *hw)
 		phy->ops.get_info = e1000e_get_phy_info_m88;
 		break;
 	default:
-		ret_val = -E1000_ERR_PHY;
+/* P3 */ printk("not doing anything for phy type %d\n", phy->type);
 		break;
 	}
 
-out:
 	return ret_val;
 }
 
@@ -354,7 +355,10 @@ static s32 e1000_init_phy_params_ich8lan(struct e1000_hw *hw)
 		msleep(1);
 		ret_val = e1000e_get_phy_id(hw);
 		if (ret_val)
+{
+/* P3 */ printk("get_phy_id for params ret %d id %d\n", ret_val, phy->id);
 			return ret_val;
+}
 	}
 
 	/* Verify phy id */
@@ -777,6 +781,77 @@ static s32 e1000_check_reset_block_ich8lan(struct e1000_hw *hw)
 }
 
 /**
+ *  e1000_phy_force_speed_duplex_ich8lan - Force PHY speed & duplex
+ *  @hw: pointer to the HW structure
+ *
+ *  Forces the speed and duplex settings of the PHY.
+ *  This is a function pointer entry point only called by
+ *  PHY setup routines.
+ **/
+static s32 e1000_phy_force_speed_duplex_ich8lan(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data;
+	bool link;
+
+	if (phy->type != e1000_phy_ife) {
+		ret_val = e1000e_phy_force_speed_duplex_igp(hw);
+		return ret_val;
+	}
+
+	ret_val = e1e_rphy(hw, PHY_CONTROL, &data);
+	if (ret_val)
+		return ret_val;
+
+	e1000e_phy_force_speed_duplex_setup(hw, &data);
+
+	ret_val = e1e_wphy(hw, PHY_CONTROL, data);
+	if (ret_val)
+		return ret_val;
+
+	/* Disable MDI-X support for 10/100 */
+	ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &data);
+	if (ret_val)
+		return ret_val;
+
+	data &= ~IFE_PMC_AUTO_MDIX;
+	data &= ~IFE_PMC_FORCE_MDIX;
+
+	ret_val = e1e_wphy(hw, IFE_PHY_MDIX_CONTROL, data);
+	if (ret_val)
+		return ret_val;
+
+	e_dbg("IFE PMC: %X\n", data);
+
+	udelay(1);
+
+	if (phy->autoneg_wait_to_complete) {
+		e_dbg("Waiting for forced speed/duplex link on IFE phy.\n");
+
+		ret_val = e1000e_phy_has_link_generic(hw,
+						     PHY_FORCE_LIMIT,
+						     100000,
+						     &link);
+		if (ret_val)
+			return ret_val;
+
+		if (!link)
+			e_dbg("Link taking longer than expected.\n");
+
+		/* Try once more */
+		ret_val = e1000e_phy_has_link_generic(hw,
+						     PHY_FORCE_LIMIT,
+						     100000,
+						     &link);
+		if (ret_val)
+			return ret_val;
+	}
+
+	return 0;
+}
+
+/**
  *  e1000_sw_lcd_config_ich8lan - SW-based LCD Configuration
  *  @hw:   pointer to the HW structure
  *
@@ -1273,6 +1348,87 @@ out:
 }
 
 /**
+ *  e1000_get_phy_info_ife_ich8lan - Retrieves various IFE PHY states
+ *  @hw: pointer to the HW structure
+ *
+ *  Populates "phy" structure with various feature states.
+ *  This function is only called by other family-specific
+ *  routines.
+ **/
+static s32 e1000_get_phy_info_ife_ich8lan(struct e1000_hw *hw)
+{
+	struct e1000_phy_info *phy = &hw->phy;
+	s32 ret_val;
+	u16 data;
+	bool link;
+
+	ret_val = e1000e_phy_has_link_generic(hw, 1, 0, &link);
+	if (ret_val)
+		return ret_val;
+
+	if (!link) {
+		e_dbg("Phy info is only valid if link is up\n");
+		return -E1000_ERR_CONFIG;
+	}
+
+	ret_val = e1e_rphy(hw, IFE_PHY_SPECIAL_CONTROL, &data);
+	if (ret_val)
+		return ret_val;
+	phy->polarity_correction = (!(data & IFE_PSC_AUTO_POLARITY_DISABLE));
+
+	if (phy->polarity_correction) {
+		ret_val = phy->ops.check_polarity(hw);
+		if (ret_val)
+			return ret_val;
+	} else {
+		/* Polarity is forced */
+		phy->cable_polarity = (data & IFE_PSC_FORCE_POLARITY)
+				      ? e1000_rev_polarity_reversed
+				      : e1000_rev_polarity_normal;
+	}
+
+	ret_val = e1e_rphy(hw, IFE_PHY_MDIX_CONTROL, &data);
+	if (ret_val)
+		return ret_val;
+
+	phy->is_mdix = (data & IFE_PMC_MDIX_STATUS);
+
+	/* The following parameters are undefined for 10/100 operation. */
+	phy->cable_length = E1000_CABLE_LENGTH_UNDEFINED;
+	phy->local_rx = e1000_1000t_rx_status_undefined;
+	phy->remote_rx = e1000_1000t_rx_status_undefined;
+
+	return 0;
+}
+
+/**
+ *  e1000_get_phy_info_ich8lan - Calls appropriate PHY type get_info
+ *  @hw: pointer to the HW structure
+ *
+ *  Wrapper for calling the get_info routines for the appropriate phy type.
+ *  This is a function pointer entry point called by drivers
+ *  or other shared routines.
+ **/
+static s32 e1000_get_phy_info_ich8lan(struct e1000_hw *hw)
+{
+	switch (hw->phy.type) {
+	case e1000_phy_ife:
+		return e1000_get_phy_info_ife_ich8lan(hw);
+		break;
+	case e1000_phy_igp_3:
+	case e1000_phy_bm:
+	case e1000_phy_82578:
+	case e1000_phy_82577:
+		return e1000e_get_phy_info_igp(hw);
+		break;
+	default:
+		break;
+	}
+
+	return -E1000_ERR_PHY_TYPE;
+}
+
+/**
  *  e1000_set_lplu_state_pchlan - Set Low Power Link Up state
  *  @hw: pointer to the HW structure
  *  @active: true to enable LPLU, false to disable
@@ -3394,8 +3550,10 @@ static struct e1000_phy_operations ich8_phy_ops = {
 	.acquire		= e1000_acquire_swflag_ich8lan,
 	.check_reset_block	= e1000_check_reset_block_ich8lan,
 	.commit			= NULL,
+	.force_speed_duplex	= e1000_phy_force_speed_duplex_ich8lan,
 	.get_cfg_done		= e1000_get_cfg_done_ich8lan,
 	.get_cable_length	= e1000e_get_cable_length_igp_2,
+	.get_info		= e1000_get_phy_info_ich8lan,
 	.read_reg		= e1000e_read_phy_reg_igp,
 	.release		= e1000_release_swflag_ich8lan,
 	.reset			= e1000_phy_hw_reset_ich8lan,

What seems to be happening here is a persistent failure of
e1000e_get_phy_id, in both "slow" and "fast" MDI modes. However,
in RHEL 5, this failure triggers a chain of workaround and adjustments
that bring up the interface with some default parameters... which
appear to work with my 1Gbit/s Netgear switch. So the hardware is
not dead, or not completely dead.

Could someone come up with a fix here, please? I have no clue where
to start even.

Greetings,
-- Pete
