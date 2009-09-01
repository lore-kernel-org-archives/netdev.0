From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] ixgbe: Patch to fix 82599 multispeed fiber link
	issues when driver is loaded without any cable and reconnecting
	it to 1G partner
Date: Tue, 01 Sep 2009 16:50:14 -0700
Message-ID: <20090901235014.4617.22941.stgit@localhost.localdomain>
References: <20090901234916.4617.73579.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:45636 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755362AbZIAXuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 19:50:39 -0400
In-Reply-To: <20090901234916.4617.73579.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>

In 82599 multi speed fiber case when driver is loaded without any
cable and reconnecting the cable with a 1G partner does not bring
up the link in 1Gb mode. When there is no link we first setup the link
at 10G & 1G and then try to re-establish the link at highest speed 10G
and thereby changing autoneg_advertised value to highest speed 10G.
After connecting back the cable to a 1G link partner we never try 1G
as autoneg advertised value is changed to link at 10G only. The
following patch fixes the issue by properly initializing the
autoneg_advertised value just before exiting from link setup routine.

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5ee5608..61af47e 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -421,15 +421,6 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 	hw->mac.ops.get_link_capabilities(hw, &phy_link_speed, &negotiation);
 	speed &= phy_link_speed;
 
-	 /* Set autoneg_advertised value based on input link speed */
-	hw->phy.autoneg_advertised = 0;
-
-	if (speed & IXGBE_LINK_SPEED_10GB_FULL)
-		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_10GB_FULL;
-
-	if (speed & IXGBE_LINK_SPEED_1GB_FULL)
-		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
-
 	/*
 	 * When the driver changes the link speeds that it can support,
 	 * it sets autotry_restart to true to indicate that we need to
@@ -466,7 +457,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		                               autoneg,
 		                               autoneg_wait_to_complete);
 		if (status != 0)
-			goto out;
+			return status;
 
 		/* Flap the tx laser if it has not already been done */
 		if (hw->mac.autotry_restart) {
@@ -520,7 +511,7 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		                                      autoneg,
 		                                      autoneg_wait_to_complete);
 		if (status != 0)
-			goto out;
+			return status;
 
 		/* Flap the tx laser if it has not already been done */
 		if (hw->mac.autotry_restart) {
@@ -558,6 +549,15 @@ s32 ixgbe_setup_mac_link_multispeed_fiber(struct ixgbe_hw *hw,
 		                                               autoneg_wait_to_complete);
 
 out:
+	/* Set autoneg_advertised value based on input link speed */
+	hw->phy.autoneg_advertised = 0;
+
+	if (speed & IXGBE_LINK_SPEED_10GB_FULL)
+		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_10GB_FULL;
+
+	if (speed & IXGBE_LINK_SPEED_1GB_FULL)
+		hw->phy.autoneg_advertised |= IXGBE_LINK_SPEED_1GB_FULL;
+
 	return status;
 }
 

