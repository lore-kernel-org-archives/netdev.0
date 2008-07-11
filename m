From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/6] bnx2: Prevent ethtool -s from crashing
 when device is down.
Date: Thu, 10 Jul 2008 18:29:10 -0700
Message-ID: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1731 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756468AbYGKB0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 21:26:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device may be in D3-hot state and may crash if we try to
configure the speed settings by accessing the registers.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index ad61cfd..e9cfb02 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6215,6 +6215,12 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	    !(bp->phy_flags & BNX2_PHY_FLAG_REMOTE_PHY_CAP))
 		goto err_out_unlock;
 
+	/* If device is down, we can store the settings only if the user
+	 * is setting the currently active port.
+	 */
+	if (!netif_running(dev) && cmd->port != bp->phy_port)
+		goto err_out_unlock;
+
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		autoneg |= AUTONEG_SPEED;
 
@@ -6272,7 +6278,12 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	bp->req_line_speed = req_line_speed;
 	bp->req_duplex = req_duplex;
 
-	err = bnx2_setup_phy(bp, cmd->port);
+	err = 0;
+	/* If device is down, the new settings will be picked up when it is
+	 * brought up.
+	 */
+	if (netif_running(dev))
+		err = bnx2_setup_phy(bp, cmd->port);
 
 err_out_unlock:
 	spin_unlock_bh(&bp->phy_lock);
-- 
1.5.5.GIT


