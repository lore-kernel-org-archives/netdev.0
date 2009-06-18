From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next PATCH 2/4] be2net: Use MCC queue for cmds that may be
	called in BH context
Date: Thu, 18 Jun 2009 15:35:54 +0530
Message-ID: <20090618100554.GA12685@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:13924 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751970AbZFRKGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 06:06:18 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currenlty multicast_set and promiscuous_config cmds -- that may be called in BH context -- 
use the blocking MCC mbox to post cmds.
An mbox cmd is protected via a spin_lock(cmd_lock) and not spin_lock_bh() as it is undesirable
to disable BHs while a blocking mbox cmd is in progress (and take long to finish.)
This can lockup a cmd in progress in process context.
So, these two cmds in BH context must use the MCC queue to post cmds.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_cmds.c |   69 ++++++++++++++++++++++++++++++++----------
 1 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index f1ec191..0b60508 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -17,7 +17,7 @@
 
 #include "be.h"
 
-void be_mcc_notify(struct be_ctrl_info *ctrl)
+static void be_mcc_notify(struct be_ctrl_info *ctrl)
 {
 	struct be_queue_info *mccq = &ctrl->mcc_obj.q;
 	u32 val = 0;
@@ -101,6 +101,28 @@ void be_process_mcc(struct be_ctrl_info *ctrl)
 	spin_unlock_bh(&ctrl->mcc_cq_lock);
 }
 
+/* Wait till no more pending mcc requests are present */
+static void be_mcc_wait_compl(struct be_ctrl_info *ctrl)
+{
+#define mcc_timeout		50000 /* 5s timeout */
+	int i;
+	for (i = 0; i < mcc_timeout; i++) {
+		be_process_mcc(ctrl);
+		if (atomic_read(&ctrl->mcc_obj.q.used) == 0)
+			break;
+		udelay(100);
+	}
+	if (i == mcc_timeout)
+		printk(KERN_WARNING DRV_NAME "mcc poll timed out\n");
+}
+
+/* Notify MCC requests and wait for completion */
+static void be_mcc_notify_wait(struct be_ctrl_info *ctrl)
+{
+	be_mcc_notify(ctrl);
+	be_mcc_wait_compl(ctrl);
+}
+
 static int be_mbox_db_ready_wait(void __iomem *db)
 {
 	int cnt = 0, wait = 5;
@@ -872,14 +894,18 @@ int be_cmd_vlan_config(struct be_ctrl_info *ctrl, u32 if_id, u16 *vtag_array,
 	return status;
 }
 
+/* Use MCC for this command as it may be called in BH context */
 int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
-	struct be_cmd_req_promiscuous_config *req = embedded_payload(wrb);
-	int status;
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_promiscuous_config *req;
 
-	spin_lock(&ctrl->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&ctrl->mcc_lock);
+
+	wrb = wrb_from_mcc(&ctrl->mcc_obj.q);
+	BUG_ON(!wrb);
+
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -891,21 +917,29 @@ int be_cmd_promiscuous_config(struct be_ctrl_info *ctrl, u8 port_num, bool en)
 	else
 		req->port0_promiscuous = en;
 
-	status = be_mbox_db_ring(ctrl);
+	be_mcc_notify_wait(ctrl);
 
-	spin_unlock(&ctrl->mbox_lock);
-	return status;
+	spin_unlock_bh(&ctrl->mcc_lock);
+	return 0;
 }
 
+/*
+ * Use MCC for this command as it may be called in BH context
+ * (mc == NULL) => multicast promiscous
+ */
 int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id, u8 *mac_table,
 			u32 num, bool promiscuous)
 {
-	struct be_mcc_wrb *wrb = wrb_from_mbox(&ctrl->mbox_mem);
-	struct be_cmd_req_mcast_mac_config *req = embedded_payload(wrb);
-	int status;
+#define BE_MAX_MC		32 /* set mcast promisc if > 32 */
+	struct be_mcc_wrb *wrb;
+	struct be_cmd_req_mcast_mac_config *req;
 
-	spin_lock(&ctrl->mbox_lock);
-	memset(wrb, 0, sizeof(*wrb));
+	spin_lock_bh(&ctrl->mcc_lock);
+
+	wrb = wrb_from_mcc(&ctrl->mcc_obj.q);
+	BUG_ON(!wrb);
+
+	req = embedded_payload(wrb);
 
 	be_wrb_hdr_prepare(wrb, sizeof(*req), true, 0);
 
@@ -920,10 +954,11 @@ int be_cmd_mcast_mac_set(struct be_ctrl_info *ctrl, u32 if_id, u8 *mac_table,
 			memcpy(req->mac, mac_table, ETH_ALEN * num);
 	}
 
-	status = be_mbox_db_ring(ctrl);
+	be_mcc_notify_wait(ctrl);
 
-	spin_unlock(&ctrl->mbox_lock);
-	return status;
+	spin_unlock_bh(&ctrl->mcc_lock);
+
+	return 0;
 }
 
 int be_cmd_set_flow_control(struct be_ctrl_info *ctrl, u32 tx_fc, u32 rx_fc)
-- 
1.6.0.4

