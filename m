From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 2/5] be2net: release mcc-lock in a failure case in be_cmd_notify_wait()
Date: Mon, 12 Oct 2015 03:47:18 -0400
Message-ID: <1444636041-4727-3-git-send-email-sathya.perla@avagotech.com>
References: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50637 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751872AbbJLH5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 03:57:23 -0400
In-Reply-To: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@avagotech.com>

The mcc/mbox lock is not being released when be_cmd_copy() returns
an error.

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index eb32391..9dc5ce1 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -851,8 +851,10 @@ static int be_cmd_notify_wait(struct be_adapter *adapter,
 		return status;
 
 	dest_wrb = be_cmd_copy(adapter, wrb);
-	if (!dest_wrb)
-		return -EBUSY;
+	if (!dest_wrb) {
+		status = -EBUSY;
+		goto unlock;
+	}
 
 	if (use_mcc(adapter))
 		status = be_mcc_notify_wait(adapter);
@@ -862,6 +864,7 @@ static int be_cmd_notify_wait(struct be_adapter *adapter,
 	if (!status)
 		memcpy(wrb, dest_wrb, sizeof(*wrb));
 
+unlock:
 	be_cmd_unlock(adapter);
 	return status;
 }
-- 
2.4.1
