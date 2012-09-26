From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/7 net-next] tg3: Refactor tg3_close()
Date: Wed, 26 Sep 2012 15:32:47 -0700
Message-ID: <1348698769-760-5-git-send-email-mchan@broadcom.com>
References: <1348698769-760-1-git-send-email-mchan@broadcom.com>
 <1348698769-760-2-git-send-email-mchan@broadcom.com>
 <1348698769-760-3-git-send-email-mchan@broadcom.com>
 <1348698769-760-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4310 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752487Ab2IZWTf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2012 18:19:35 -0400
In-Reply-To: <1348698769-760-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

by introducing tg3_stop() that does the opposite of tg3_start().  This
function will be useful when adding the support for changing the numbe
of rx and tx rings.

Reviewed-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   70 +++++++++++++++++++----------------
 1 files changed, 38 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 9bd99ce..3f2197e 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10448,6 +10448,43 @@ err_out1:
 	return err;
 }
 
+static void tg3_stop(struct tg3 *tp)
+{
+	int i;
+
+	tg3_napi_disable(tp);
+	tg3_reset_task_cancel(tp);
+
+	netif_tx_disable(tp->dev);
+
+	tg3_timer_stop(tp);
+
+	tg3_hwmon_close(tp);
+
+	tg3_phy_stop(tp);
+
+	tg3_full_lock(tp, 1);
+
+	tg3_disable_ints(tp);
+
+	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
+	tg3_free_rings(tp);
+	tg3_flag_clear(tp, INIT_COMPLETE);
+
+	tg3_full_unlock(tp);
+
+	for (i = tp->irq_cnt - 1; i >= 0; i--) {
+		struct tg3_napi *tnapi = &tp->napi[i];
+		free_irq(tnapi->irq_vec, tnapi);
+	}
+
+	tg3_ints_fini(tp);
+
+	tg3_napi_fini(tp);
+
+	tg3_free_consistent(tp);
+}
+
 static int tg3_open(struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
@@ -10490,45 +10527,14 @@ static int tg3_open(struct net_device *dev)
 
 static int tg3_close(struct net_device *dev)
 {
-	int i;
 	struct tg3 *tp = netdev_priv(dev);
 
-	tg3_napi_disable(tp);
-	tg3_reset_task_cancel(tp);
-
-	netif_tx_stop_all_queues(dev);
-
-	tg3_timer_stop(tp);
-
-	tg3_hwmon_close(tp);
-
-	tg3_phy_stop(tp);
-
-	tg3_full_lock(tp, 1);
-
-	tg3_disable_ints(tp);
-
-	tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-	tg3_free_rings(tp);
-	tg3_flag_clear(tp, INIT_COMPLETE);
-
-	tg3_full_unlock(tp);
-
-	for (i = tp->irq_cnt - 1; i >= 0; i--) {
-		struct tg3_napi *tnapi = &tp->napi[i];
-		free_irq(tnapi->irq_vec, tnapi);
-	}
-
-	tg3_ints_fini(tp);
+	tg3_stop(tp);
 
 	/* Clear stats across close / open calls */
 	memset(&tp->net_stats_prev, 0, sizeof(tp->net_stats_prev));
 	memset(&tp->estats_prev, 0, sizeof(tp->estats_prev));
 
-	tg3_napi_fini(tp);
-
-	tg3_free_consistent(tp);
-
 	tg3_power_down(tp);
 
 	netif_carrier_off(tp->dev);
-- 
1.7.1
