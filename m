From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/4] ixgbe: LINKS2 is not a valid register for
	82598
Date: Tue, 24 Nov 2009 20:51:48 -0800
Message-ID: <20091125045147.23932.39966.stgit@localhost.localdomain>
References: <20091125045059.23932.10997.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.westchester.pa.mail.comcast.net ([76.96.62.64]:45530
	"EHLO QMTA07.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934501AbZKYEwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2009 23:52:02 -0500
In-Reply-To: <20091125045059.23932.10997.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

82598 shouldn't try and access LINKS2 while configuring
link and flow control.  This is an 82599-only register.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_common.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index f42a954..79533e2 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1755,17 +1755,24 @@ s32 ixgbe_fc_autoneg(struct ixgbe_hw *hw)
 	/*
 	 * On backplane, bail out if
 	 * - backplane autoneg was not completed, or if
-	 * - link partner is not AN enabled
+	 * - we are 82599 and link partner is not AN enabled
 	 */
 	if (hw->phy.media_type == ixgbe_media_type_backplane) {
 		links = IXGBE_READ_REG(hw, IXGBE_LINKS);
-		links2 = IXGBE_READ_REG(hw, IXGBE_LINKS2);
-		if (((links & IXGBE_LINKS_KX_AN_COMP) == 0) ||
-		    ((links2 & IXGBE_LINKS2_AN_SUPPORTED) == 0)) {
+		if ((links & IXGBE_LINKS_KX_AN_COMP) == 0) {
 			hw->fc.fc_was_autonegged = false;
 			hw->fc.current_mode = hw->fc.requested_mode;
 			goto out;
 		}
+
+		if (hw->mac.type == ixgbe_mac_82599EB) {
+			links2 = IXGBE_READ_REG(hw, IXGBE_LINKS2);
+			if ((links2 & IXGBE_LINKS2_AN_SUPPORTED) == 0) {
+				hw->fc.fc_was_autonegged = false;
+				hw->fc.current_mode = hw->fc.requested_mode;
+				goto out;
+			}
+		}
 	}
 
 	/*

