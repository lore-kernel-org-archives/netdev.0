From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/10] tg3: Fix stats while interface is down
Date: Mon, 13 Feb 2012 17:20:09 -0800
Message-ID: <1329182417-28223-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3513 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758410Ab2BNBVD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 20:21:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the tg3 interface is down, the driver will return ethtool stats
uninitialized.  This patch zeroes out the destination stat buffer in
such a case.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0a765f1..4a0b9af 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10154,9 +10154,6 @@ static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *tp,
 	struct tg3_ethtool_stats *old_estats = &tp->estats_prev;
 	struct tg3_hw_stats *hw_stats = tp->hw_stats;
 
-	if (!hw_stats)
-		return old_estats;
-
 	ESTAT_ADD(rx_octets);
 	ESTAT_ADD(rx_fragments);
 	ESTAT_ADD(rx_ucast_packets);
@@ -11029,7 +11026,10 @@ static void tg3_get_ethtool_stats(struct net_device *dev,
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	tg3_get_estats(tp, (struct tg3_ethtool_stats *)tmp_stats);
+	if (tp->hw_stats)
+		tg3_get_estats(tp, (struct tg3_ethtool_stats *)tmp_stats);
+	else
+		memset(tmp_stats, 0, sizeof(struct tg3_ethtool_stats));
 }
 
 static __be32 *tg3_vpd_readblock(struct tg3 *tp, u32 *vpdlen)
-- 
1.7.3.4
