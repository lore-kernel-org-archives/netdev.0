From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2 net-next] cnic: Fix rare race condition during iSCSI
 disconnect.
Date: Wed, 5 Dec 2012 12:10:15 -0800
Message-ID: <1354738215-6644-2-git-send-email-mchan@broadcom.com>
References: <1354738215-6644-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4973 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab2LETzE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2012 14:55:04 -0500
In-Reply-To: <1354738215-6644-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

If the initiator and target try to close the connection at about the same
time, there is a race condition in the termination sequence for bnx2x.
Fix the problem by waiting for the remote termination to complete before
deleting the Connection ID.  This will prevent the firmware assert.

Update version to 2.5.15.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/cnic.c    |   13 +++++++++++--
 drivers/net/ethernet/broadcom/cnic_if.h |    4 ++--
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
index 2c1f66d..1c2a851 100644
--- a/drivers/net/ethernet/broadcom/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -3853,12 +3853,17 @@ static int cnic_cm_abort(struct cnic_sock *csk)
 		return cnic_cm_abort_req(csk);
 
 	/* Getting here means that we haven't started connect, or
-	 * connect was not successful.
+	 * connect was not successful, or it has been reset by the target.
 	 */
 
 	cp->close_conn(csk, opcode);
-	if (csk->state != opcode)
+	if (csk->state != opcode) {
+		/* Wait for remote reset sequence to complete */
+		while (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
+			msleep(1);
+
 		return -EALREADY;
+	}
 
 	return 0;
 }
@@ -3872,6 +3877,10 @@ static int cnic_cm_close(struct cnic_sock *csk)
 		csk->state = L4_KCQE_OPCODE_VALUE_CLOSE_COMP;
 		return cnic_cm_close_req(csk);
 	} else {
+		/* Wait for remote reset sequence to complete */
+		while (test_bit(SK_F_PG_OFFLD_COMPLETE, &csk->flags))
+			msleep(1);
+
 		return -EALREADY;
 	}
 	return 0;
diff --git a/drivers/net/ethernet/broadcom/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
index 865095a..502e11e 100644
--- a/drivers/net/ethernet/broadcom/cnic_if.h
+++ b/drivers/net/ethernet/broadcom/cnic_if.h
@@ -14,8 +14,8 @@
 
 #include "bnx2x/bnx2x_mfw_req.h"
 
-#define CNIC_MODULE_VERSION	"2.5.14"
-#define CNIC_MODULE_RELDATE	"Sep 30, 2012"
+#define CNIC_MODULE_VERSION	"2.5.15"
+#define CNIC_MODULE_RELDATE	"Dec 04, 2012"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.7.1
