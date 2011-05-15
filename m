From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 04/13] ixgbe: force unlock on timeout
Date: Sat, 14 May 2011 18:23:38 -0700
Message-ID: <1305422627-9583-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1031 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759488Ab1EOBXv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 21:23:51 -0400
In-Reply-To: <1305422627-9583-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The semaphore can be in locked state upon driver load, particularly
on 82598 if a machine is rebooted due to panic and the semaphore was
acquired just prior to the panic.

This patch unlocks the semaphore if it times out.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_common.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_common.c b/drivers/net/ixgbe/ixgbe_common.c
index c4730cd..b894b42 100644
--- a/drivers/net/ixgbe/ixgbe_common.c
+++ b/drivers/net/ixgbe/ixgbe_common.c
@@ -1189,6 +1189,28 @@ static s32 ixgbe_get_eeprom_semaphore(struct ixgbe_hw *hw)
 		udelay(50);
 	}
 
+	if (i == timeout) {
+		hw_dbg(hw, "Driver can't access the Eeprom - SMBI Semaphore "
+		       "not granted.\n");
+		/*
+		 * this release is particularly important because our attempts
+		 * above to get the semaphore may have succeeded, and if there
+		 * was a timeout, we should unconditionally clear the semaphore
+		 * bits to free the driver to make progress
+		 */
+		ixgbe_release_eeprom_semaphore(hw);
+
+		udelay(50);
+		/*
+		 * one last try
+		 * If the SMBI bit is 0 when we read it, then the bit will be
+		 * set and we have the semaphore
+		 */
+		swsm = IXGBE_READ_REG(hw, IXGBE_SWSM);
+		if (!(swsm & IXGBE_SWSM_SMBI))
+			status = 0;
+	}
+
 	/* Now get the semaphore between SW/FW through the SWESMBI bit */
 	if (status == 0) {
 		for (i = 0; i < timeout; i++) {
-- 
1.7.4.4

