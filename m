From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/4] ixgbe: fix regression on some 82598 adapters
Date: Thu, 02 Jul 2009 15:50:31 -0700
Message-ID: <20090702225031.22746.74206.stgit@localhost.localdomain>
References: <20090702225012.22746.57218.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:51584
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751049AbZGBWur (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 18:50:47 -0400
In-Reply-To: <20090702225012.22746.57218.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The change to check the SFP+ module again on open() was
causing the XFP (non-SFP+) adapters to be rejected. We
only want to try and re-identify the SFP+ module if the
original probe found that this device was an SFP+ device.
So for this code path (driver loaded with SFP module, module
inserted, ifconfig up of the device) the type will be
ixgbe_phy_unknown for an unidentified SFP+ module.  So we
only check if that is the case.

This problem also shows up on Copper devices.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   24 ++++++++++++++----------
 1 files changed, 14 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index aaf482c..cf39f5a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2697,19 +2697,23 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 	/*
 	 * For hot-pluggable SFP+ devices, a new SFP+ module may have
-	 * arrived before interrupts were enabled.  We need to kick off
-	 * the SFP+ module setup first, then try to bring up link.
+	 * arrived before interrupts were enabled but after probe.  Such
+	 * devices wouldn't have their type identified yet. We need to
+	 * kick off the SFP+ module setup first, then try to bring up link.
 	 * If we're not hot-pluggable SFP+, we just need to configure link
 	 * and bring it up.
 	 */
-	err = hw->phy.ops.identify(hw);
-	if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
-		dev_err(&adapter->pdev->dev, "failed to initialize because "
-			"an unsupported SFP+ module type was detected.\n"
-			"Reload the driver after installing a supported "
-			"module.\n");
-		ixgbe_down(adapter);
-		return err;
+	if (hw->phy.type == ixgbe_phy_unknown) {
+		err = hw->phy.ops.identify(hw);
+		if (err == IXGBE_ERR_SFP_NOT_SUPPORTED) {
+			dev_err(&adapter->pdev->dev, "failed to initialize "
+				"because an unsupported SFP+ module type "
+				"was detected.\n"
+				"Reload the driver after installing a "
+				"supported module.\n");
+			ixgbe_down(adapter);
+			return err;
+		}
 	}
 
 	if (ixgbe_is_sfp(hw)) {

