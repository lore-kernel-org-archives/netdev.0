From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH 3/3] cnic: Fix missing ISCSI_KEVENT_IF_DOWN message
Date: Fri, 30 May 2014 16:18:43 -0700
Message-ID: <1401491923-5480-4-git-send-email-mchan@broadcom.com>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
 <1401491923-5480-2-git-send-email-mchan@broadcom.com>
 <1401491923-5480-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <nhorman@tuxdriver.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:56181 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614AbaE3V7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 17:59:15 -0400
In-Reply-To: <1401491923-5480-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iSCSI netlink message needs to be sent before the ulp_ops is cleared
as it is sent through a function pointer in the ulp_ops.  This bug
causes iscsid to not get the message when the bnx2i driver is unloaded.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 4ebab75..565fb31 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -608,6 +608,10 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 		pr_err("%s: Bad type %d\n", __func__, ulp_type);
 		return -EINVAL;
 	}
+
+	if (ulp_type == CNIC_ULP_ISCSI)
+		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+
 	mutex_lock(&cnic_lock);
 	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
 		RCU_INIT_POINTER(cp->ulp_ops[ulp_type], NULL);
@@ -620,9 +624,7 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 	}
 	mutex_unlock(&cnic_lock);
 
-	if (ulp_type == CNIC_ULP_ISCSI)
-		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
-	else if (ulp_type == CNIC_ULP_FCOE)
+	if (ulp_type == CNIC_ULP_FCOE)
 		dev->fcoe_cap = NULL;
 
 	synchronize_rcu();
-- 
1.7.1
