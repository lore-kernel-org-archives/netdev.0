From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/8] bnx2: Cleanup error handling in bnx2_open().
Date: Wed, 18 Jun 2008 17:25:31 -0700
Message-ID: <1213835132-5698-8-git-send-email-mchan@broadcom.com>
References: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benli@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3945 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756376AbYFSAXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 20:23:48 -0400
In-Reply-To: <1213835132-5698-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All error handling in bnx2_open() can be consolidated.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   37 ++++++++++++++-----------------------
 1 files changed, 14 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 9a722bf..de4c85e 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5773,29 +5773,16 @@ bnx2_open(struct net_device *dev)
 	bnx2_setup_int_mode(bp, disable_msi);
 	bnx2_napi_enable(bp);
 	rc = bnx2_alloc_mem(bp);
-	if (rc) {
-		bnx2_napi_disable(bp);
-		bnx2_free_mem(bp);
-		return rc;
-	}
+	if (rc)
+		goto open_err;
 
 	rc = bnx2_request_irq(bp);
-
-	if (rc) {
-		bnx2_napi_disable(bp);
-		bnx2_free_mem(bp);
-		return rc;
-	}
+	if (rc)
+		goto open_err;
 
 	rc = bnx2_init_nic(bp, 1);
-
-	if (rc) {
-		bnx2_napi_disable(bp);
-		bnx2_free_irq(bp);
-		bnx2_free_skbs(bp);
-		bnx2_free_mem(bp);
-		return rc;
-	}
+	if (rc)
+		goto open_err;
 
 	mod_timer(&bp->timer, jiffies + bp->current_interval);
 
@@ -5825,11 +5812,8 @@ bnx2_open(struct net_device *dev)
 				rc = bnx2_request_irq(bp);
 
 			if (rc) {
-				bnx2_napi_disable(bp);
-				bnx2_free_skbs(bp);
-				bnx2_free_mem(bp);
 				del_timer_sync(&bp->timer);
-				return rc;
+				goto open_err;
 			}
 			bnx2_enable_int(bp);
 		}
@@ -5842,6 +5826,13 @@ bnx2_open(struct net_device *dev)
 	netif_start_queue(dev);
 
 	return 0;
+
+open_err:
+	bnx2_napi_disable(bp);
+	bnx2_free_skbs(bp);
+	bnx2_free_irq(bp);
+	bnx2_free_mem(bp);
+	return rc;
 }
 
 static void
-- 
1.5.5.GIT



