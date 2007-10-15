From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: don't poke PHY registers to retreive link status
Date: Mon, 15 Oct 2007 14:30:59 -0700
Message-ID: <20071015213059.27110.43589.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, auke-jan.h.kok@intel.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10128 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752367AbXJOVbD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 17:31:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Apparently poking the link status registers when autonegotiation
is running on the PHY might botch the PHY link on 80003es2lan
devices. While this is a very rare condition we can completely
avoid it alltogether by just using the MAC link bits to provide
the proper information to ethtool.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index b7a7e2a..983b031 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -110,6 +110,7 @@ static int e1000_get_settings(struct net_device *netdev,
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	u32 status;
 
 	if (hw->media_type == e1000_media_type_copper) {
 
@@ -147,16 +148,16 @@ static int e1000_get_settings(struct net_device *netdev,
 		ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	if (er32(STATUS) & E1000_STATUS_LU) {
-
-		adapter->hw.mac.ops.get_link_up_info(hw, &adapter->link_speed,
-						  &adapter->link_duplex);
-		ecmd->speed = adapter->link_speed;
-
-		/* unfortunately FULL_DUPLEX != DUPLEX_FULL
-		 *	  and HALF_DUPLEX != DUPLEX_HALF */
+	status = er32(STATUS);
+	if (status & E1000_STATUS_LU) {
+		if (status & E1000_STATUS_SPEED_1000)
+			ecmd->speed = 1000;
+		else if (status & E1000_STATUS_SPEED_100)
+			ecmd->speed = 100;
+		else
+			ecmd->speed = 10;
 
-		if (adapter->link_duplex == FULL_DUPLEX)
+		if (status & E1000_STATUS_FD)
 			ecmd->duplex = DUPLEX_FULL;
 		else
 			ecmd->duplex = DUPLEX_HALF;
@@ -170,6 +171,16 @@ static int e1000_get_settings(struct net_device *netdev,
 	return 0;
 }
 
+static u32 e1000_get_link(struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 status;
+	
+	status = er32(STATUS);
+	return (status & E1000_STATUS_LU);
+}
+
 static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 {
 	struct e1000_mac_info *mac = &adapter->hw.mac;
@@ -1751,7 +1762,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_msglevel		= e1000_get_msglevel,
 	.set_msglevel		= e1000_set_msglevel,
 	.nway_reset		= e1000_nway_reset,
-	.get_link		= ethtool_op_get_link,
+	.get_link		= e1000_get_link,
 	.get_eeprom_len		= e1000_get_eeprom_len,
 	.get_eeprom		= e1000_get_eeprom,
 	.set_eeprom		= e1000_set_eeprom,
