From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 3/7] ixgbe: fix for 82599 erratum on Header Splitting.
Date: Thu, 27 Jan 2011 22:18:51 -0800
Message-ID: <1296195535-2990-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com, stable@kernel.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34293 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753135Ab1A1GS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jan 2011 01:18:58 -0500
In-Reply-To: <1296195535-2990-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We have found a hardware erratum on 82599 hardware that can lead to
unpredictable behavior when Header Splitting mode is enabled.  So
we are no longer enabling this feature on affected hardware.

Please see the 82599 Specification Update for more information.

CC: stable@kernel.org
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 44a1cf0..1495b74 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3176,9 +3176,16 @@ static void ixgbe_set_rx_buffer_len(struct ixgbe_adapter *adapter)
 	u32 mhadd, hlreg0;
 
 	/* Decide whether to use packet split mode or not */
+	/* On by default */
+	 adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
+
 	/* Do not use packet split if we're in SR-IOV Mode */
-	if (!adapter->num_vfs)
-		adapter->flags |= IXGBE_FLAG_RX_PS_ENABLED;
+	if (adapter->num_vfs)
+		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
+
+	/* Disable packet split due to 82599 erratum #45 */
+	if (hw->mac.type == ixgbe_mac_82599EB)
+		adapter->flags &= ~IXGBE_FLAG_RX_PS_ENABLED;
 
 	/* Set the RX buffer length according to the mode */
 	if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
-- 
1.7.3.5

