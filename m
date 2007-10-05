From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000e: restore flow control settings properly
Date: Fri, 05 Oct 2007 15:22:02 -0700
Message-ID: <20071005222202.13513.55979.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13360 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754060AbXJEWYY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Oct 2007 18:24:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After a cable unplug the forced flow control settings were lost
accidentally and the flow control settings fell back to the default
EEPROM determined values. This breaks for people who want to
run without fc enabled - after a cable reset the driver would
refuse to run with fc disabled.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/ethtool.c |    1 +
 drivers/net/e1000e/lib.c     |   12 +++++++++---
 drivers/net/e1000e/netdev.c  |    1 +
 3 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 2e8218f..b7a7e2a 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -301,6 +301,7 @@ static int e1000_set_pauseparam(struct net_device *netdev,
 	hw->mac.original_fc = hw->mac.fc;
 
 	if (adapter->fc_autoneg == AUTONEG_ENABLE) {
+		hw->mac.fc = e1000_fc_default;
 		if (netif_running(adapter->netdev)) {
 			e1000e_down(adapter);
 			e1000e_up(adapter);
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 3bbfe60..0bdeca3 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -639,9 +639,15 @@ s32 e1000e_setup_link(struct e1000_hw *hw)
 	if (e1000_check_reset_block(hw))
 		return 0;
 
-	ret_val = e1000_set_default_fc_generic(hw);
-	if (ret_val)
-		return ret_val;
+	/*
+	 * If flow control is set to default, set flow control based on
+	 * the EEPROM flow control settings.
+	 */
+	if (mac->fc == e1000_fc_default) {
+		ret_val = e1000_set_default_fc_generic(hw);
+		if (ret_val)
+			return ret_val;
+	}
 
 	/* We want to save off the original Flow Control configuration just
 	 * in case we get disconnected and then reconnected into a different
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3a0bb2a..71c9fed 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4196,6 +4196,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* Initialize link parameters. User can change them with ethtool */
 	adapter->hw.mac.autoneg = 1;
+	adapter->fc_autoneg = 1;
 	adapter->hw.mac.original_fc = e1000_fc_default;
 	adapter->hw.mac.fc = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
