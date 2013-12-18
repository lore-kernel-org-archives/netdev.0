From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/5] e1000e: fix compiler warning (maybe-unitialized variable)
Date: Tue, 17 Dec 2013 23:19:44 -0800
Message-ID: <1387351186-23389-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <davidx.m.ertman@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41463 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751539Ab3LRHTu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 02:19:50 -0500
In-Reply-To: <1387351186-23389-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <davidx.m.ertman@intel.com>

This patch is to fix a compiler warning of maybe-uininitialized-variable
that is generated from gcc when the -O3 flag is used.  In the function
e1000_reset_hw_80003es2lan(), the variable krmn_reg_data is first given
a value by being passed to a register read function as a
pass-by-reference parameter.  But, the return value of that read
function was never checked to see if the read failed and the variable
not given an initial value.  The compiler was smart enough to spot
this.  This patch is to check the return value for that read function
and return it, if an error occurs, without trying to utilize the value
in kmrn_reg_data.

Signed-off-by: David Ertman <davidx.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/80003es2lan.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/80003es2lan.c b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
index 895450e..ff2d806 100644
--- a/drivers/net/ethernet/intel/e1000e/80003es2lan.c
+++ b/drivers/net/ethernet/intel/e1000e/80003es2lan.c
@@ -718,8 +718,11 @@ static s32 e1000_reset_hw_80003es2lan(struct e1000_hw *hw)
 	e1000_release_phy_80003es2lan(hw);
 
 	/* Disable IBIST slave mode (far-end loopback) */
-	e1000_read_kmrn_reg_80003es2lan(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
-					&kum_reg_data);
+	ret_val =
+	    e1000_read_kmrn_reg_80003es2lan(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
+					    &kum_reg_data);
+	if (ret_val)
+		return ret_val;
 	kum_reg_data |= E1000_KMRNCTRLSTA_IBIST_DISABLE;
 	e1000_write_kmrn_reg_80003es2lan(hw, E1000_KMRNCTRLSTA_INBAND_PARAM,
 					 kum_reg_data);
-- 
1.8.3.1
