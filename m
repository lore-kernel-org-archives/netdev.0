From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/6] e1000e: Disable Far-End LoopBack following reset on 80003ES2LAN.
Date: Fri, 27 Apr 2012 02:36:48 -0700
Message-ID: <1335519413-1892-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759871Ab2D0Jg4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:36:56 -0400
In-Reply-To: <1335519413-1892-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Vick <matthew.vick@intel.com>

80003ES2LAN has an errata such that far-end loopback may be activated by
bit errors producing a reserved symbol. In order to disable far-end
loopback quickly enough, disable it immediately following a reset.

Signed-off-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index fbc84d4..a212846 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -764,6 +764,7 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 {
 	u32 ctrl;
 	s32 ret_val;
+	u16 kum_reg_data;
 
 	/*
 	 * Prevent the PCI-E bus from sticking if there is no TLP connection
@@ -789,6 +790,13 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	ew32(CTRL, ctrl | E1000_CTRL_RST);
 	e1000_release_phy_80003es2lan(hw);
 
+	/* Disable IBIST slave mode (far-end loopback) */
+	e1000_read_kmrn_reg_80003es2lan(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
+					&kum_reg_data);
+	kum_reg_data |= E1000_KMRNCTRLSTA_IBIST_DISABLE;
+	e1000_write_kmrn_reg_80003es2lan(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
+					 kum_reg_data);
+
 	ret_val = e1000e_get_auto_rd_done(hw);
 	if (ret_val)
 		/* We don't want to continue accessing MAC registers. */
-- 
1.7.7.6
