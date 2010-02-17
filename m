From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 04/18] igb: ignore EEPROM APME check when
	shutting down serdes link
Date: Wed, 17 Feb 2010 03:01:40 -0800
Message-ID: <20100217110138.17723.30876.stgit@localhost.localdomain>
References: <20100217105953.17723.36633.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:34139 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754020Ab0BQLB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 06:01:57 -0500
In-Reply-To: <20100217105953.17723.36633.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

Checking the EEPROM APME state unnecessarily prevents the link from
shutting down. The standard power down routines should be
sufficient to determine whether the serdes link can power down
when going into D3.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_82575.c |   21 ++-------------------
 1 files changed, 2 insertions(+), 19 deletions(-)

diff --git a/drivers/net/igb/e1000_82575.c b/drivers/net/igb/e1000_82575.c
index c505b50..59817bc 100644
--- a/drivers/net/igb/e1000_82575.c
+++ b/drivers/net/igb/e1000_82575.c
@@ -791,27 +791,12 @@ static s32 igb_get_pcs_speed_and_duplex_82575(struct e1000_hw *hw, u16 *speed,
 void igb_shutdown_serdes_link_82575(struct e1000_hw *hw)
 {
 	u32 reg;
-	u16 eeprom_data = 0;
 
-	if (hw->phy.media_type != e1000_media_type_internal_serdes ||
+	if (hw->phy.media_type != e1000_media_type_internal_serdes &&
 	    igb_sgmii_active_82575(hw))
 		return;
 
-	if (hw->bus.func == E1000_FUNC_0)
-		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A, 1, &eeprom_data);
-	else if (hw->mac.type == e1000_82580)
-		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_A +
-		                 NVM_82580_LAN_FUNC_OFFSET(hw->bus.func), 1,
-		                 &eeprom_data);
-	else if (hw->bus.func == E1000_FUNC_1)
-		hw->nvm.ops.read(hw, NVM_INIT_CONTROL3_PORT_B, 1, &eeprom_data);
-
-	/*
-	 * If APM is not enabled in the EEPROM and management interface is
-	 * not enabled, then power down.
-	 */
-	if (!(eeprom_data & E1000_NVM_APME_82575) &&
-	    !igb_enable_mng_pass_thru(hw)) {
+	if (!igb_enable_mng_pass_thru(hw)) {
 		/* Disable PCS to turn off link */
 		reg = rd32(E1000_PCS_CFG0);
 		reg &= ~E1000_PCS_CFG_PCS_EN;
@@ -826,8 +811,6 @@ void igb_shutdown_serdes_link_82575(struct e1000_hw *hw)
 		wrfl();
 		msleep(1);
 	}
-
-	return;
 }
 
 /**

