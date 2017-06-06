From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/11] igb: Explicitly select page 0 at initialization
Date: Tue,  6 Jun 2017 01:57:59 -0700
Message-ID: <20170606085809.78571-2-jeffrey.t.kirsher@intel.com>
References: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Cc: Matwey V Kornilov <matwey@sai.msu.ru>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        stable@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:20068 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751246AbdFFI6P (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Jun 2017 04:58:15 -0400
In-Reply-To: <20170606085809.78571-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matwey V Kornilov <matwey@sai.msu.ru>

The functions igb_read_phy_reg_gs40g/igb_write_phy_reg_gs40g (which were
removed in 2a3cdea) explicitly selected the required page at every phy_reg
access. Currently, igb_get_phy_id_82575 relays on the fact that page 0 is
already selected. The assumption is not fulfilled for my Lex 3I380CW
motherboard with integrated dual i211 based gigabit ethernet. This leads to igb
initialization failure and network interfaces are not working:

    igb: Intel(R) Gigabit Ethernet Network Driver - version 5.4.0-k
    igb: Copyright (c) 2007-2014 Intel Corporation.
    igb: probe of 0000:01:00.0 failed with error -2
    igb: probe of 0000:02:00.0 failed with error -2

In order to fix it, we explicitly select page 0 before first access to phy
registers.

See also: https://bugzilla.suse.com/show_bug.cgi?id=1009911
See also: http://www.lex.com.tw/products/pdf/3I380A&3I380CW.pdf

Fixes: 2a3cdea ("igb: Remove GS40G specific defines/functions")
Cc: <stable@vger.kernel.org> # 4.5+
Signed-off-by: Matwey V Kornilov <matwey@sai.msu.ru>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index ee443985581f..4a50870e0fa7 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -257,6 +257,7 @@ static s32 igb_init_phy_params_82575(struct e1000_hw *hw)
 	}
 
 	/* Set phy->phy_addr and phy->id. */
+	igb_write_phy_reg_82580(hw, I347AT4_PAGE_SELECT, 0);
 	ret_val = igb_get_phy_id_82575(hw);
 	if (ret_val)
 		return ret_val;
-- 
2.12.2
