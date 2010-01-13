From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/2] e1000e: workaround link issues on busy hub in
	half duplex on 82577/82578
Date: Wed, 13 Jan 2010 03:53:08 -0800
Message-ID: <20100113115307.23394.31.stgit@localhost.localdomain>
References: <20100113115248.23394.71869.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:53108 "EHLO
	qmta10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752369Ab0AMLxZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 06:53:25 -0500
In-Reply-To: <20100113115248.23394.71869.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

This patch removes a delay in hardware after every received packet allowing
more time for transmitted packets to go out in between received packets in
half duplex.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index c2ea861..8b6ecd1 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -1122,6 +1122,7 @@ static s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw)
 static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 {
 	s32 ret_val = 0;
+	u16 phy_data;
 
 	if (hw->mac.type != e1000_pchlan)
 		return ret_val;
@@ -1165,16 +1166,32 @@ static s32 e1000_hv_phy_workarounds_ich8lan(struct e1000_hw *hw)
 
 	hw->phy.addr = 1;
 	ret_val = e1000e_write_phy_reg_mdic(hw, IGP01E1000_PHY_PAGE_SELECT, 0);
+	hw->phy.ops.release(hw);
 	if (ret_val)
 		goto out;
-	hw->phy.ops.release(hw);
 
 	/*
 	 * Configure the K1 Si workaround during phy reset assuming there is
 	 * link so that it disables K1 if link is in 1Gbps.
 	 */
 	ret_val = e1000_k1_gig_workaround_hv(hw, true);
+	if (ret_val)
+		goto out;
 
+	/* Workaround for link disconnects on a busy hub in half duplex */
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto out;
+	ret_val = hw->phy.ops.read_reg_locked(hw,
+	                                      PHY_REG(BM_PORT_CTRL_PAGE, 17),
+	                                      &phy_data);
+	if (ret_val)
+		goto release;
+	ret_val = hw->phy.ops.write_reg_locked(hw,
+	                                       PHY_REG(BM_PORT_CTRL_PAGE, 17),
+	                                       phy_data & 0x00FF);
+release:
+	hw->phy.ops.release(hw);
 out:
 	return ret_val;
 }

