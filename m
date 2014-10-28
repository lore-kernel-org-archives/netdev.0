From: Nilesh Javali <nilesh.javali@qlogic.com>
Subject: [PATCH net 1/1] cnic: Update the rcu_access_pointer() usages
Date: Tue, 28 Oct 2014 01:18:15 -0400
Message-ID: <1414473495-24790-2-git-send-email-nilesh.javali@qlogic.com>
References: <1414473495-24790-1-git-send-email-nilesh.javali@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>, <vikas.chaudhary@qlogic.com>,
	<giridhar.malavali@qlogic.com>, <tej.parkash@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:60147 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757446AbaJ1Fxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 01:53:31 -0400
In-Reply-To: <1414473495-24790-1-git-send-email-nilesh.javali@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tej Parkash <tej.parkash@qlogic.com>

1. Remove the rcu_read_lock/unlock around rcu_access_pointer
2. Replace the rcu_dereference with rcu_access_pointer

Signed-off-by: Tej Parkash <tej.parkash@qlogic.com>
---
 drivers/net/ethernet/broadcom/cnic.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 23f23c9..f05fab6 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -382,10 +382,8 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 		if (l5_cid >= MAX_CM_SK_TBL_SZ)
 			break;
 
-		rcu_read_lock();
 		if (!rcu_access_pointer(cp->ulp_ops[CNIC_ULP_L4])) {
 			rc = -ENODEV;
-			rcu_read_unlock();
 			break;
 		}
 		csk = &cp->csk_tbl[l5_cid];
@@ -414,7 +412,6 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 			}
 		}
 		csk_put(csk);
-		rcu_read_unlock();
 		rc = 0;
 	}
 	}
@@ -615,7 +612,7 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
 
 	mutex_lock(&cnic_lock);
-	if (rcu_dereference(cp->ulp_ops[ulp_type])) {
+	if (rcu_access_pointer(cp->ulp_ops[ulp_type])) {
 		RCU_INIT_POINTER(cp->ulp_ops[ulp_type], NULL);
 		cnic_put(dev);
 	} else {
-- 
1.5.6
