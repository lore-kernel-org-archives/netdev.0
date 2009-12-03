From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/5] bnx2: Protect tx timeout reset with rtnl_lock().
Date: Thu, 3 Dec 2009 11:46:31 -0800
Message-ID: <1259869595-6450-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4592 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754633AbZLCTjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 14:39:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To prevent race conditions with other reset events.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4cae2a8..03eb51f 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6263,8 +6263,11 @@ bnx2_reset_task(struct work_struct *work)
 {
 	struct bnx2 *bp = container_of(work, struct bnx2, reset_task);
 
-	if (!netif_running(bp->dev))
+	rtnl_lock();
+	if (!netif_running(bp->dev)) {
+		rtnl_unlock();
 		return;
+	}
 
 	bnx2_netif_stop(bp);
 
@@ -6272,6 +6275,7 @@ bnx2_reset_task(struct work_struct *work)
 
 	atomic_set(&bp->intr_sem, 1);
 	bnx2_netif_start(bp);
+	rtnl_unlock();
 }
 
 static void
-- 
1.6.4.GIT


