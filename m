From: James Morse <james.morse@arm.com>
Subject: [PATCH net-next] amd-xgbe: Reset running devices after resume from hibernate
Date: Fri, 26 Aug 2016 09:21:23 +0100
Message-ID: <1472199683-12098-1-git-send-email-james.morse@arm.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>,
        James Morse <james.morse@arm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:36355 "EHLO foss.arm.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751976AbcHZIVh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 26 Aug 2016 04:21:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After resume from hibernate on arm64, any amd-xgbe devices that were
running when we hibernated are reported as down, even when it is not.

Re-plugging the cables does not cause the interface to come back, the
link must be marked as down then up via 'ip set link' using the serial
console.

This happens because the device has been power-cycled and possibly
re-initialised by firmware, whereas the driver's memory structures have
been restored from the hibernate image and the two do not agree.

Schedule a restart of the device after powerup in case the world changed
while we were asleep.

Signed-off-by: James Morse <james.morse@arm.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index 3eee3201b58f..9de078819aa6 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -861,9 +861,15 @@ static int xgbe_resume(struct device *dev)
 	pdata->lpm_ctrl &= ~MDIO_CTRL1_LPOWER;
 	XMDIO_WRITE(pdata, MDIO_MMD_PCS, MDIO_CTRL1, pdata->lpm_ctrl);
 
-	if (netif_running(netdev))
+	if (netif_running(netdev)) {
 		ret = xgbe_powerup(netdev, XGMAC_DRIVER_CONTEXT);
 
+		/* Schedule a restart in case the link or phy state changed
+		 * while we were powered down.
+		 */
+		schedule_work(&pdata->restart_work);
+	}
+
 	DBGPR("<--xgbe_resume\n");
 
 	return ret;
-- 
2.8.0.rc3
