From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] ixgbe: Add semaphore access for PHY
	initialization for 82599
Date: Tue, 19 May 2009 12:18:34 -0700
Message-ID: <20090519191819.5063.28388.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.emeryville.ca.mail.comcast.net ([76.96.30.17]:43667 "EHLO
	QMTA10.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750849AbZESTSs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 15:18:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

The SFP+ NIC (device id 0x10fb) needs a semaphore to serialize
PHY access, so our PHY init code must honor that same semaphore.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 39d7b64..fef7397 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -109,6 +109,13 @@ s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 		if (ret_val != 0)
 			goto setup_sfp_out;
 
+		/* PHY config will finish before releasing the semaphore */
+		ret_val = ixgbe_acquire_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
+		if (ret_val != 0) {
+			ret_val = IXGBE_ERR_SWFW_SYNC;
+			goto setup_sfp_out;
+		}
+
 		hw->eeprom.ops.read(hw, ++data_offset, &data_value);
 		while (data_value != 0xffff) {
 			IXGBE_WRITE_REG(hw, IXGBE_CORECTL, data_value);
@@ -119,6 +126,11 @@ s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
 		IXGBE_WRITE_REG(hw, IXGBE_CORECTL, 0x00000102);
 		IXGBE_WRITE_REG(hw, IXGBE_CORECTL, 0x00000b1d);
 		IXGBE_WRITE_FLUSH(hw);
+
+		/* Release the semaphore */
+		ixgbe_release_swfw_sync(hw, IXGBE_GSSR_MAC_CSR_SM);
+		/* Delay obtaining semaphore again to allow FW access */
+		msleep(hw->eeprom.semaphore_delay);
 	}
 
 setup_sfp_out:

