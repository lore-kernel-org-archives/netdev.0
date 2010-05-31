From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 2/2] be2net: replace udelay() with
 schedule_timeout() in mbox polling
Date: Mon, 31 May 2010 15:04:14 +0530
Message-ID: <20100531093414.GA2867@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:32174 "EHLO
	ubuntu.ubuntu-domain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751632Ab0EaLUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 07:20:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As mbox polling is done only in process context, it is better to
use schedule_timeout() instead of udelay().

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index 9d11dbf..c2bd84c 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -186,7 +186,7 @@ static int be_mcc_notify_wait(struct be_adapter *adapter)
 
 static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 {
-	int cnt = 0, wait = 5;
+	int msecs = 0;
 	u32 ready;
 
 	do {
@@ -201,15 +201,14 @@ static int be_mbox_db_ready_wait(struct be_adapter *adapter, void __iomem *db)
 		if (ready)
 			break;
 
-		if (cnt > 4000000) {
+		if (msecs > 4000) {
 			dev_err(&adapter->pdev->dev, "mbox poll timed out\n");
 			return -1;
 		}
 
-		if (cnt > 50)
-			wait = 200;
-		cnt += wait;
-		udelay(wait);
+		set_current_state(TASK_INTERRUPTIBLE);
+		schedule_timeout(msecs_to_jiffies(1));
+		msecs++;
 	} while (true);
 
 	return 0;
-- 
1.6.5.2

