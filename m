From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 1/3] cnic: Use proper ulp_ops for per device operations.
Date: Mon, 17 Mar 2014 19:19:06 -0800
Message-ID: <1395112748-21965-2-git-send-email-mchan@broadcom.com>
References: <1395112748-21965-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eddie.wai@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:54062 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493AbaCRCAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 22:00:16 -0400
In-Reply-To: <1395112748-21965-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For per device operations, cnic needs to dereference the RCU protected
cp->ulp_ops instead of the global cnic_ulp_tbl.  In 2 locations,
cnic_send_nlmsg() and cnic_copy_ulp_stats(), it was referencing the
global table.  If the device has been unregistered and these functions
are still being called (very unlikely scenarios), it could lead to NULL
pointer dereference.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index fcf9105..2cb2482 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -342,7 +342,7 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 	while (retry < 3) {
 		rc = 0;
 		rcu_read_lock();
-		ulp_ops = rcu_dereference(cnic_ulp_tbl[CNIC_ULP_ISCSI]);
+		ulp_ops = rcu_dereference(cp->ulp_ops[CNIC_ULP_ISCSI]);
 		if (ulp_ops)
 			rc = ulp_ops->iscsi_nl_send_msg(
 				cp->ulp_handle[CNIC_ULP_ISCSI],
@@ -3244,7 +3244,8 @@ static int cnic_copy_ulp_stats(struct cnic_dev *dev, int ulp_type)
 	int rc;
 
 	mutex_lock(&cnic_lock);
-	ulp_ops = cnic_ulp_tbl_prot(ulp_type);
+	ulp_ops = rcu_dereference_protected(cp->ulp_ops[ulp_type],
+					    lockdep_is_held(&cnic_lock));
 	if (ulp_ops && ulp_ops->cnic_get_stats)
 		rc = ulp_ops->cnic_get_stats(cp->ulp_handle[ulp_type]);
 	else
-- 
1.7.1
