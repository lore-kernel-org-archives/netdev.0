From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/10] igb: reset the PHY before reading the PHY ID
Date: Fri,  6 Jan 2017 02:48:48 -0800
Message-ID: <20170106104852.10363-7-jeffrey.t.kirsher@intel.com>
References: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Cc: Aaron Sierra <asierra@xes-inc.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        "Matwey V . Kornilov" <matwey@sai.msu.ru>,
        Chris Arges <carges@vectranetworks.com>,
        Jochen Henneberg <jh@henneberg-systemdesign.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:57006 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965735AbdAFKtY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 05:49:24 -0500
In-Reply-To: <20170106104852.10363-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Sierra <asierra@xes-inc.com>

Several people have reported firmware leaving the I210/I211 PHY's page
select register set to something other than the default of zero. This
causes the first accesses, PHY_IDx register reads, to access something
else, resulting in device probe failure:

    igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
    igb: Copyright (c) 2007-2014 Intel Corporation.
    igb: probe of 0000:01:00.0 failed with error -2

This problem began for them after a previous patch I submitted was
applied:

    commit 2a3cdead8b408351fa1e3079b220fa331480ffbc
    Author: Aaron Sierra <asierra@xes-inc.com>
    Date:   Tue Nov 3 12:37:09 2015 -0600

        igb: Remove GS40G specific defines/functions

I personally experienced this problem after attempting to PXE boot from
I210 devices using this firmware:

    Intel(R) Boot Agent GE v1.5.78
    Copyright (C) 1997-2014, Intel Corporation

Resetting the PHY before reading from it, ensures the page select
register is in its default state and doesn't make assumptions about
the PHY's register set before the PHY has been probed.

Cc: Matwey V. Kornilov <matwey@sai.msu.ru>
Cc: Chris Arges <carges@vectranetworks.com>
Cc: Jochen Henneberg <jh@henneberg-systemdesign.com>
Signed-off-by: Aaron Sierra <asierra@xes-inc.com>
Tested-by: Matwey V. Kornilov <matwey@sai.msu.ru>
Tested-by: Chris J Arges <christopherarges@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index a61447f..ee44398 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -245,6 +245,17 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 	hw->bus.func = (rd32(E1000_STATUS) & E1000_STATUS_FUNC_MASK) >>
 			E1000_STATUS_FUNC_SHIFT;
 
+	/* Make sure the PHY is in a good state. Several people have reported
+	 * firmware leaving the PHY's page select register set to something
+	 * other than the default of zero, which causes the PHY ID read to
+	 * access something other than the intended register.
+	 */
+	ret_val = hw->phy.ops.reset(hw);
+	if (ret_val) {
+		hw_dbg("Error resetting the PHY.\n");
+		goto out;
+	}
+
 	/* Set phy->phy_addr and phy->id. */
 	ret_val = igb_get_phy_id_82575(hw);
 	if (ret_val)
-- 
2.9.3
