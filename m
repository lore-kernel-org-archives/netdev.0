From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 10/18] tg3: Enable NAPI instances for other int vectors
Date: Tue, 1 Sep 2009 16:10:19 -0700
Message-ID: <1251867308.5941@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3813 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142AbZIBEz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 00:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds code to enable and disable the rest of the NAPI
instances.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |   32 +++++++++++++++++++++++---------
 1 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 2e0f4a5..ad0fc5d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -694,25 +694,39 @@ static void tg3_int_reenable(struct tg3_napi *tnapi)
 		     HOSTCC_MODE_ENABLE | tnapi->coal_now);
 }
 
+static void tg3_napi_disable(struct tg3 *tp)
+{
+	int i;
+
+	for (i = tp->irq_cnt - 1; i >= 0; i--)
+		napi_disable(&tp->napi[i].napi);
+}
+
+static void tg3_napi_enable(struct tg3 *tp)
+{
+	int i;
+
+	for (i = 0; i < tp->irq_cnt; i++)
+		napi_enable(&tp->napi[i].napi);
+}
+
 static inline void tg3_netif_stop(struct tg3 *tp)
 {
 	tp->dev->trans_start = jiffies;	/* prevent tx timeout */
-	napi_disable(&tp->napi[0].napi);
+	tg3_napi_disable(tp);
 	netif_tx_disable(tp->dev);
 }
 
 static inline void tg3_netif_start(struct tg3 *tp)
 {
-	struct tg3_napi *tnapi = &tp->napi[0];
-
 	/* NOTE: unconditional netif_tx_wake_all_queues is only
 	 * appropriate so long as all callers are assured to
 	 * have free tx slots (such as after tg3_init_hw)
 	 */
 	netif_tx_wake_all_queues(tp->dev);
 
-	napi_enable(&tnapi->napi);
-	tnapi->hw_status->status |= SD_STATUS_UPDATED;
+	tg3_napi_enable(tp);
+	tp->napi[0].hw_status->status |= SD_STATUS_UPDATED;
 	tg3_enable_ints(tp);
 }
 
@@ -4958,7 +4972,7 @@ static int tg3_restart_hw(struct tg3 *tp, int reset_phy)
 		tg3_full_unlock(tp);
 		del_timer_sync(&tp->timer);
 		tp->irq_sync = 0;
-		napi_enable(&tp->napi[0].napi);
+		tg3_napi_enable(tp);
 		dev_close(tp->dev);
 		tg3_full_lock(tp, 0);
 	}
@@ -8153,7 +8167,7 @@ static int tg3_open(struct net_device *dev)
 	if (err)
 		goto err_out1;
 
-	napi_enable(&tp->napi[0].napi);
+	tg3_napi_enable(tp);
 
 	for (i = 0; i < tp->irq_cnt; i++) {
 		struct tg3_napi *tnapi = &tp->napi[i];
@@ -8240,7 +8254,7 @@ err_out3:
 	}
 
 err_out2:
-	napi_disable(&tp->napi[0].napi);
+	tg3_napi_disable(tp);
 	tg3_free_consistent(tp);
 
 err_out1:
@@ -8486,7 +8500,7 @@ static int tg3_close(struct net_device *dev)
 	int i;
 	struct tg3 *tp = netdev_priv(dev);
 
-	napi_disable(&tp->napi[0].napi);
+	tg3_napi_disable(tp);
 	cancel_work_sync(&tp->reset_task);
 
 	netif_tx_stop_all_queues(dev);
-- 
1.6.3.3


