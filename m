From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/6] cnic: Fix panic in
 cnic_iscsi_nl_msg_recv() when device is down.
Date: Wed, 24 Feb 2010 16:42:06 -0800
Message-ID: <1267058529-18454-3-git-send-email-mchan@broadcom.com>
References: <1267058529-18454-1-git-send-email-mchan@broadcom.com>
 <1267058529-18454-2-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2836 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758670Ab0BYAcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 19:32:43 -0500
In-Reply-To: <1267058529-18454-2-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some data structures are freed when the device is down and it will
crash if an ISCSI netlink message is received.  Add RCU protection
to prevent this.  In the shutdown path, ulp_ops[CNIC_ULP_L4] is
assigned NULL and rcu_synchronized before freeing the data
structures.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 40865aa..4558444 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -327,6 +327,12 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 		if (l5_cid >= MAX_CM_SK_TBL_SZ)
 			break;
 
+		rcu_read_lock();
+		if (!rcu_dereference(cp->ulp_ops[CNIC_ULP_L4])) {
+			rc = -ENODEV;
+			rcu_read_unlock();
+			break;
+		}
 		csk = &cp->csk_tbl[l5_cid];
 		csk_hold(csk);
 		if (cnic_in_use(csk)) {
@@ -341,6 +347,7 @@ static int cnic_iscsi_nl_msg_recv(struct cnic_dev *dev, u32 msg_type,
 				cnic_cm_set_pg(csk);
 		}
 		csk_put(csk);
+		rcu_read_unlock();
 		rc = 0;
 	}
 	}
-- 
1.6.4.GIT


