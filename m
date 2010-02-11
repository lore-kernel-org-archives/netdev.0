From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/2] ixgbe: Fix - Do not allow Rx FC on 82598 at 1G
	due to errata
Date: Thu, 11 Feb 2010 06:13:49 -0800
Message-ID: <20100211141319.25672.3041.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta14.emeryville.ca.mail.comcast.net ([76.96.27.212]:56620
	"EHLO qmta14.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753054Ab0BKOOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 09:14:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

The 82598 has an erratum that receipt of pause frames at 1G
could lead to a Tx Hang.  To avoid this this patch disables
Rx FC while at 1G speed for all 82598 parts.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82598.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 3103f41..35a06b4 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -357,12 +357,34 @@ static s32 ixgbe_fc_enable_82598(struct ixgbe_hw *hw, s32 packetbuf_num)
 	u32 fctrl_reg;
 	u32 rmcs_reg;
 	u32 reg;
+	u32 link_speed = 0;
+	bool link_up;
 
 #ifdef CONFIG_DCB
 	if (hw->fc.requested_mode == ixgbe_fc_pfc)
 		goto out;
 
 #endif /* CONFIG_DCB */
+	/*
+	 * On 82598 having Rx FC on causes resets while doing 1G
+	 * so if it's on turn it off once we know link_speed. For
+	 * more details see 82598 Specification update.
+	 */
+	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
+	if (link_up && link_speed == IXGBE_LINK_SPEED_1GB_FULL) {
+		switch (hw->fc.requested_mode) {
+		case ixgbe_fc_full:
+			hw->fc.requested_mode = ixgbe_fc_tx_pause;
+			break;
+		case ixgbe_fc_rx_pause:
+			hw->fc.requested_mode = ixgbe_fc_none;
+			break;
+		default:
+			/* no change */
+			break;
+		}
+	}
+
 	/* Negotiate the fc mode to use */
 	ret_val = ixgbe_fc_autoneg(hw);
 	if (ret_val)

