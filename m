From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 2/2] cnic: Do not call bnx2i when bnx2i is
 calling cnic_unregister_driver()
Date: Mon, 3 Jan 2011 17:21:46 -0800
Message-ID: <1294104106-9758-2-git-send-email-mchan@broadcom.com>
References: <1294104106-9758-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2510 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181Ab1ADCQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 21:16:39 -0500
In-Reply-To: <1294104106-9758-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should call bnx2i to send the iSCSI netlink message earlier in
cnic_unregister_device().  By the time cnic_unregister_driver() is
called, bnx2i may have freed data structures used by the upcalls.

Update version to 2.2.12.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c    |   19 +++----------------
 drivers/net/cnic_if.h |    6 +++---
 2 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 41957fa..6dfa564 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -426,19 +426,6 @@ static int cnic_abort_prep(struct cnic_sock *csk)
 	return 0;
 }
 
-static void cnic_uio_stop(void)
-{
-	struct cnic_dev *dev;
-
-	read_lock(&cnic_dev_lock);
-	list_for_each_entry(dev, &cnic_dev_list, list) {
-		struct cnic_local *cp = dev->cnic_priv;
-
-		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
-	}
-	read_unlock(&cnic_dev_lock);
-}
-
 int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
 {
 	struct cnic_dev *dev;
@@ -510,9 +497,6 @@ int cnic_unregister_driver(int ulp_type)
 	}
 	read_unlock(&cnic_dev_lock);
 
-	if (ulp_type == CNIC_ULP_ISCSI)
-		cnic_uio_stop();
-
 	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], NULL);
 
 	mutex_unlock(&cnic_lock);
@@ -596,6 +580,9 @@ static int cnic_unregister_device(struct cnic_dev *dev, int ulp_type)
 	}
 	mutex_unlock(&cnic_lock);
 
+	if (ulp_type == CNIC_ULP_ISCSI)
+		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+
 	synchronize_rcu();
 
 	while (test_bit(ULP_F_CALL_PENDING, &cp->ulp_flags[ulp_type]) &&
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index ccd8140..9f44e0f 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -1,6 +1,6 @@
 /* cnic_if.h: Broadcom CNIC core network driver.
  *
- * Copyright (c) 2006-2010 Broadcom Corporation
+ * Copyright (c) 2006-2011 Broadcom Corporation
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -12,8 +12,8 @@
 #ifndef CNIC_IF_H
 #define CNIC_IF_H
 
-#define CNIC_MODULE_VERSION	"2.2.11"
-#define CNIC_MODULE_RELDATE	"Dec 22, 2010"
+#define CNIC_MODULE_VERSION	"2.2.12"
+#define CNIC_MODULE_RELDATE	"Jan 03, 2011"
 
 #define CNIC_ULP_RDMA		0
 #define CNIC_ULP_ISCSI		1
-- 
1.6.4.GIT


