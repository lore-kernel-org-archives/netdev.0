From: Arthur Jones <ajones@riverbed.com>
Subject: [PATCH] e1000e: workaround missing power down mii control bit on
 82571
Date: Thu, 16 Dec 2010 10:28:47 -0800
Message-ID: <20101216182847.GA14985@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.riverbed.com ([208.70.196.44]:14101 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757203Ab0LPSiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 13:38:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,  Re-sending w/ proper netdev email
address.  Sorry about that...

Arthur

---

On 82571 only, AFAICT, the PHY does not seem to
store the MII control register 0 bit 11 (power
down PHY).  So that when we power down the PHY
on dev_close() and then run ethtool on the closed
dev, we end up turning the PHY back on even though
the interface is down.  This pretty easy to repro:

$ ethtool -s eth0 wol d
$ ifconfig eth0 up
$ mii-tool eth0
eth0: negotiated 100baseTx-FD, link ok
$ ifconfig eth0 down
$ mii-tool eth0
eth0: no link
$ ethtool -s eth0 autoneg on  (doesn't really matter what we do here)
$ mii-tool eth0
eth0: negotiated 100baseTx-FD, link ok (this should be: eth0: no link)

We fix this by tracking the power down bit that we
write to the PHY control register and re-inserting
it when we read it.

Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 drivers/net/e1000e/hw.h     |    1 +
 drivers/net/e1000e/netdev.c |    1 +
 drivers/net/e1000e/phy.c    |    9 +++++++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index ba302a5..34974f2 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -875,6 +875,7 @@ struct e1000_phy_info {
 	u16 cable_length;
 	u16 max_cable_length;
 	u16 min_cable_length;
+	u16 control_power_down;
 
 	u8 mdix;
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index c4ca162..ac81596 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5781,6 +5781,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	hw->mac.ops.get_bus_info(&adapter->hw);
 
 	adapter->hw.phy.autoneg_wait_to_complete = 0;
+	adapter->hw.phy.control_power_down = 0;
 
 	/* Copper options */
 	if (adapter->hw.phy.media_type == e1000_media_type_copper) {
diff --git a/drivers/net/e1000e/phy.c b/drivers/net/e1000e/phy.c
index 3d3dc0c..55b9f78 100644
--- a/drivers/net/e1000e/phy.c
+++ b/drivers/net/e1000e/phy.c
@@ -224,6 +224,11 @@ s32 e1000e_read_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 *data)
 		e_dbg("MDI Error\n");
 		return -E1000_ERR_PHY;
 	}
+
+	/* 82571 does not seem to store the power down bit (bit 11) */
+	if (offset == PHY_CONTROL && phy->type == e1000_phy_igp_2)
+		mdic |= phy->control_power_down;
+
 	*data = (u16) mdic;
 
 	return 0;
@@ -247,6 +252,10 @@ s32 e1000e_write_phy_reg_mdic(struct e1000_hw *hw, u32 offset, u16 data)
 		return -E1000_ERR_PARAM;
 	}
 
+	/* 82571 does not seem to store the power down bit (bit 11) */
+	if (offset == PHY_CONTROL && phy->type == e1000_phy_igp_2)
+		phy->control_power_down = data & MII_CR_POWER_DOWN;
+
 	/*
 	 * Set up Op-code, Phy Address, and register offset in the MDI
 	 * Control register.  The MAC will take care of interfacing with the
-- 
1.7.1
