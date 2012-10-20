From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 08/14] be2net: Fix issues in error recovery due to wrong queue state
Date: Sat, 20 Oct 2012 21:33:25 +0530
Message-ID: <e7aff796-eb02-4248-a238-c32547afce25@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:40024 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058Ab2JTQEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:04:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During recovery from a FW error, destroy queue operation may fail.
Queue should be marked as destroyed so that recovery code can recreate
the queue. Also fix queue created state not getting checked at one instance.

Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 9d602f4..15202d0 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -681,6 +681,9 @@ static struct be_mcc_wrb *wrb_from_mccq(struct be_adapter *adapter)
 	struct be_queue_info *mccq = &adapter->mcc_obj.q;
 	struct be_mcc_wrb *wrb;
 
+	if (!mccq->created)
+		return NULL;
+
 	if (atomic_read(&mccq->used) >= mccq->len) {
 		dev_err(&adapter->pdev->dev, "Out of MCCQ wrbs\n");
 		return NULL;
@@ -1235,8 +1238,7 @@ int be_cmd_q_destroy(struct be_adapter *adapter, struct be_queue_info *q,
 	req->id = cpu_to_le16(q->id);
 
 	status = be_mbox_notify_wait(adapter);
-	if (!status)
-		q->created = false;
+	q->created = false;
 
 	mutex_unlock(&adapter->mbox_lock);
 	return status;
@@ -1263,8 +1265,7 @@ int be_cmd_rxq_destroy(struct be_adapter *adapter, struct be_queue_info *q)
 	req->id = cpu_to_le16(q->id);
 
 	status = be_mcc_notify_wait(adapter);
-	if (!status)
-		q->created = false;
+	q->created = false;
 
 err:
 	spin_unlock_bh(&adapter->mcc_lock);
-- 
1.6.0.2
