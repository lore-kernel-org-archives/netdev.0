From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/9] cnic: Improve ->iscsi_nl_msg_send()
Date: Thu, 23 Dec 2010 09:42:58 -0800
Message-ID: <1293126184-13097-4-git-send-email-mchan@broadcom.com>
References: <1293126184-13097-1-git-send-email-mchan@broadcom.com>
 <1293126184-13097-2-git-send-email-mchan@broadcom.com>
 <1293126184-13097-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4837 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753551Ab0LWSkf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 13:40:35 -0500
In-Reply-To: <1293126184-13097-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Change first parameter from cnic_dev to ulp_handle which is the hba
pointer.  All other similar upcalls are using hba pointer.  The callee
can then directly reference the hba without conversion.

2. Change return value from void to int so that an error code can be
passed back.  This allows the operation to be retried.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c             |   21 ++++++++++++++++-----
 drivers/net/cnic_if.h          |    2 +-
 drivers/scsi/bnx2i/bnx2i_hwi.c |   14 ++++++++------
 3 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 3a7d3ce..9f80fb4 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -279,6 +279,7 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 	u32 msg_type = ISCSI_KEVENT_IF_DOWN;
 	struct cnic_ulp_ops *ulp_ops;
 	struct cnic_uio_dev *udev = cp->udev;
+	int rc = 0, retry = 0;
 
 	if (!udev || udev->uio_dev == -1)
 		return -ENODEV;
@@ -303,11 +304,21 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 		path_req.pmtu = csk->mtu;
 	}
 
-	rcu_read_lock();
-	ulp_ops = rcu_dereference(cnic_ulp_tbl[CNIC_ULP_ISCSI]);
-	if (ulp_ops)
-		ulp_ops->iscsi_nl_send_msg(cp->dev, msg_type, buf, len);
-	rcu_read_unlock();
+	while (retry < 3) {
+		rc = 0;
+		rcu_read_lock();
+		ulp_ops = rcu_dereference(cnic_ulp_tbl[CNIC_ULP_ISCSI]);
+		if (ulp_ops)
+			rc = ulp_ops->iscsi_nl_send_msg(
+				cp->ulp_handle[CNIC_ULP_ISCSI],
+				msg_type, buf, len);
+		rcu_read_unlock();
+		if (rc == 0 || msg_type != ISCSI_KEVENT_PATH_REQ)
+			break;
+
+		msleep(100);
+		retry++;
+	}
 	return 0;
 }
 
diff --git a/drivers/net/cnic_if.h b/drivers/net/cnic_if.h
index 0dbeaec..33333e7 100644
--- a/drivers/net/cnic_if.h
+++ b/drivers/net/cnic_if.h
@@ -301,7 +301,7 @@ struct cnic_ulp_ops {
 	void (*cm_abort_complete)(struct cnic_sock *);
 	void (*cm_remote_close)(struct cnic_sock *);
 	void (*cm_remote_abort)(struct cnic_sock *);
-	void (*iscsi_nl_send_msg)(struct cnic_dev *dev, u32 msg_type,
+	int (*iscsi_nl_send_msg)(void *ulp_ctx, u32 msg_type,
 				  char *data, u16 data_size);
 	struct module *owner;
 	atomic_t ref_count;
diff --git a/drivers/scsi/bnx2i/bnx2i_hwi.c b/drivers/scsi/bnx2i/bnx2i_hwi.c
index 8d9dbb3..2f9622e 100644
--- a/drivers/scsi/bnx2i/bnx2i_hwi.c
+++ b/drivers/scsi/bnx2i/bnx2i_hwi.c
@@ -2346,19 +2346,21 @@ static void bnx2i_cm_remote_abort(struct cnic_sock *cm_sk)
 }
 
 
-static void bnx2i_send_nl_mesg(struct cnic_dev *dev, u32 msg_type,
+static int bnx2i_send_nl_mesg(void *context, u32 msg_type,
 			       char *buf, u16 buflen)
 {
-	struct bnx2i_hba *hba;
+	struct bnx2i_hba *hba = context;
+	int rc;
 
-	hba = bnx2i_find_hba_for_cnic(dev);
 	if (!hba)
-		return;
+		return -ENODEV;
 
-	if (iscsi_offload_mesg(hba->shost, &bnx2i_iscsi_transport,
-				   msg_type, buf, buflen))
+	rc = iscsi_offload_mesg(hba->shost, &bnx2i_iscsi_transport,
+				msg_type, buf, buflen);
+	if (rc)
 		printk(KERN_ALERT "bnx2i: private nl message send error\n");
 
+	return rc;
 }
 
 
-- 
1.6.4.GIT


