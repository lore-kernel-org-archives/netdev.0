From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/5 net-next] cnic: Randomize initial TCP port for iSCSI
 connections
Date: Wed, 8 Jun 2011 22:29:34 -0700
Message-ID: <1307597376-5379-3-git-send-email-mchan@broadcom.com>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
 <1307597376-5379-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Eddie Wai" <eddie.wai@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1185 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752541Ab1FIGVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2011 02:21:06 -0400
In-Reply-To: <1307597376-5379-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

This reduces the likelihood of port re-use when re-loading the driver.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index ea7245c..a529bde 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -605,11 +605,12 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 }
 EXPORT_SYMBOL(cnic_unregister_driver);
 
-static int cnic_init_id_tbl(struct cnic_id_tbl *id_tbl, u32 size, u32 start_id)
+static int cnic_init_id_tbl(struct cnic_id_tbl *id_tbl, u32 size, u32 start_id,
+			    u32 next)
 {
 	id_tbl->start = start_id;
 	id_tbl->max = size;
-	id_tbl->next = 0;
+	id_tbl->next = next;
 	spin_lock_init(&id_tbl->lock);
 	id_tbl->table = kzalloc(DIV_ROUND_UP(size, 32) * 4, GFP_KERNEL);
 	if (!id_tbl->table)
@@ -3804,14 +3805,17 @@ static void cnic_cm_free_mem(struct cnic_dev *dev)
 static int cnic_cm_alloc_mem(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
+	u32 port_id;
 
 	cp->csk_tbl = kzalloc(sizeof(struct cnic_sock) * MAX_CM_SK_TBL_SZ,
 			      GFP_KERNEL);
 	if (!cp->csk_tbl)
 		return -ENOMEM;
 
+	get_random_bytes(&port_id, sizeof(port_id));
+	port_id %= CNIC_LOCAL_PORT_RANGE;
 	if (cnic_init_id_tbl(&cp->csk_port_tbl, CNIC_LOCAL_PORT_RANGE,
-			     CNIC_LOCAL_PORT_MIN)) {
+			     CNIC_LOCAL_PORT_MIN, port_id)) {
 		cnic_cm_free_mem(dev);
 		return -ENOMEM;
 	}
@@ -4829,7 +4833,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	pfid = cp->pfid;
 
 	ret = cnic_init_id_tbl(&cp->cid_tbl, MAX_ISCSI_TBL_SZ,
-			       cp->iscsi_start_cid);
+			       cp->iscsi_start_cid, 0);
 
 	if (ret)
 		return -ENOMEM;
@@ -4837,7 +4841,7 @@ static int cnic_start_bnx2x_hw(struct cnic_dev *dev)
 	if (BNX2X_CHIP_IS_E2(cp->chip_id)) {
 		ret = cnic_init_id_tbl(&cp->fcoe_cid_tbl,
 					BNX2X_FCOE_NUM_CONNECTIONS,
-					cp->fcoe_start_cid);
+					cp->fcoe_start_cid, 0);
 
 		if (ret)
 			return -ENOMEM;
-- 
1.6.4.GIT


