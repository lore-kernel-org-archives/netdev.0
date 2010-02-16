From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 4/6] bnx2: Allow user-specified multiple
 advertisement speed values.
Date: Mon, 15 Feb 2010 21:42:10 -0800
Message-ID: <1266298932-28129-4-git-send-email-mchan@broadcom.com>
References: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
 <1266298932-28129-2-git-send-email-mchan@broadcom.com>
 <1266298932-28129-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3641 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751246Ab0BPFdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 00:33:01 -0500
In-Reply-To: <1266298932-28129-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unnecessary code that works around older versions of ethtool
that can pass down invalid advertisement speed values.  This old
code prevents the user from specifying multiple advertisement values.
The new code uses simple masking to mask out invalid advertisment bits.

Reported-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   33 ++++++++-------------------------
 1 files changed, 8 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 54d43d8..2c75fd7 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6751,32 +6751,15 @@ bnx2_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (cmd->autoneg == AUTONEG_ENABLE) {
 		autoneg |= AUTONEG_SPEED;
 
-		cmd->advertising &= ETHTOOL_ALL_COPPER_SPEED;
-
-		/* allow advertising 1 speed */
-		if ((cmd->advertising == ADVERTISED_10baseT_Half) ||
-			(cmd->advertising == ADVERTISED_10baseT_Full) ||
-			(cmd->advertising == ADVERTISED_100baseT_Half) ||
-			(cmd->advertising == ADVERTISED_100baseT_Full)) {
-
-			if (cmd->port == PORT_FIBRE)
-				goto err_out_unlock;
-
-			advertising = cmd->advertising;
-
-		} else if (cmd->advertising == ADVERTISED_2500baseX_Full) {
-			if (!(bp->phy_flags & BNX2_PHY_FLAG_2_5G_CAPABLE) ||
-			    (cmd->port == PORT_TP))
-				goto err_out_unlock;
-		} else if (cmd->advertising == ADVERTISED_1000baseT_Full)
-			advertising = cmd->advertising;
-		else if (cmd->advertising == ADVERTISED_1000baseT_Half)
-			goto err_out_unlock;
-		else {
-			if (cmd->port == PORT_FIBRE)
-				advertising = ETHTOOL_ALL_FIBRE_SPEED;
-			else
+		advertising = cmd->advertising;
+		if (cmd->port == PORT_TP) {
+			advertising &= ETHTOOL_ALL_COPPER_SPEED;
+			if (!advertising)
 				advertising = ETHTOOL_ALL_COPPER_SPEED;
+		} else {
+			advertising &= ETHTOOL_ALL_FIBRE_SPEED;
+			if (!advertising)
+				advertising = ETHTOOL_ALL_FIBRE_SPEED;
 		}
 		advertising |= ADVERTISED_Autoneg;
 	}
-- 
1.6.4.GIT


