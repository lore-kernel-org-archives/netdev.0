From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next v2 2/6] tg3: Save stats across chip resets
Date: Thu, 8 Dec 2011 16:40:14 -0800
Message-ID: <1323391218-32241-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2667 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750836Ab1LIAjz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 19:39:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tg3 has a place to store stats, but doesn't really use it.  This patch
modifies the driver so that stats are saved across chip resets and gets
cleared across close / open calls.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   26 +++++++++++++++++---------
 1 files changed, 17 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 26eb4d4..713e37a 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -7588,8 +7588,6 @@ static int tg3_abort_hw(struct tg3 *tp, int silent)
 		if (tnapi->hw_status)
 			memset(tnapi->hw_status, 0, TG3_HW_STATUS_SIZE);
 	}
-	if (tp->hw_stats)
-		memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
 
 	return err;
 }
@@ -7905,6 +7903,11 @@ static int tg3_chip_reset(struct tg3 *tp)
 	return 0;
 }
 
+static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *,
+						 struct rtnl_link_stats64 *);
+static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *,
+						struct tg3_ethtool_stats *);
+
 /* tp->lock is held. */
 static int tg3_halt(struct tg3 *tp, int kind, int silent)
 {
@@ -7922,6 +7925,15 @@ static int tg3_halt(struct tg3 *tp, int kind, int silent)
 	tg3_write_sig_legacy(tp, kind);
 	tg3_write_sig_post_reset(tp, kind);
 
+	if (tp->hw_stats) {
+		/* Save the stats across chip resets... */
+		tg3_get_stats64(tp->dev, &tp->net_stats_prev),
+		tg3_get_estats(tp, &tp->estats_prev);
+
+		/* And make sure the next sample is new data */
+		memset(tp->hw_stats, 0, sizeof(struct tg3_hw_stats));
+	}
+
 	if (err)
 		return err;
 
@@ -9768,11 +9780,6 @@ err_out1:
 	return err;
 }
 
-static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *,
-						 struct rtnl_link_stats64 *);
-static struct tg3_ethtool_stats *tg3_get_estats(struct tg3 *,
-						struct tg3_ethtool_stats *);
-
 static int tg3_close(struct net_device *dev)
 {
 	int i;
@@ -9804,8 +9811,9 @@ static int tg3_close(struct net_device *dev)
 
 	tg3_ints_fini(tp);
 
-	tg3_get_stats64(tp->dev, &tp->net_stats_prev);
-	tg3_get_estats(tp, &tp->estats_prev);
+	/* Clear stats across close / open calls */
+	memset(&tp->net_stats_prev, 0, sizeof(tp->net_stats_prev));
+	memset(&tp->estats_prev, 0, sizeof(tp->estats_prev));
 
 	tg3_napi_fini(tp);
 
-- 
1.7.3.4
