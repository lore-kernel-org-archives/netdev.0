From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH] cnic: Fix ISCSI_KEVENT_IF_DOWN message handling.
Date: Wed, 22 Jul 2009 20:01:55 -0700
Message-ID: <1248318115-14214-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net, James.Bottomley@HansenPartnership.com,
	michaelc@cs.wisc.edu
Return-path: <linux-scsi-owner@vger.kernel.org>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When a net device goes down or when the bnx2i driver is unloaded,
the code was not generating the ISCSI_KEVENT_IF_DOWN message
properly and this could cause the userspace driver to crash.

This is fixed by sending the message properly in the shutdown path.
cnic_uio_stop() is also added to send the message when bnx2i is
unregistering.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   23 +++++++++++++++++++++--
 1 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4d1515f..4869d77 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -227,7 +227,7 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 	}
 
 	rcu_read_lock();
-	ulp_ops = rcu_dereference(cp->ulp_ops[CNIC_ULP_ISCSI]);
+	ulp_ops = rcu_dereference(cnic_ulp_tbl[CNIC_ULP_ISCSI]);
 	if (ulp_ops)
 		ulp_ops->iscsi_nl_send_msg(cp->dev, msg_type, buf, len);
 	rcu_read_unlock();
@@ -319,6 +319,20 @@ static int cnic_abort_prep(struct cnic_sock *csk)
 	return 0;
 }
 
+static void cnic_uio_stop(void)
+{
+	struct cnic_dev *dev;
+
+	read_lock(&cnic_dev_lock);
+	list_for_each_entry(dev, &cnic_dev_list, list) {
+		struct cnic_local *cp = dev->cnic_priv;
+
+		if (cp->cnic_uinfo)
+			cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+	}
+	read_unlock(&cnic_dev_lock);
+}
+
 int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
 {
 	struct cnic_dev *dev;
@@ -390,6 +404,9 @@ int cnic_unregister_driver(int ulp_type)
 	}
 	read_unlock(&cnic_dev_lock);
 
+	if (ulp_type == CNIC_ULP_ISCSI)
+		cnic_uio_stop();
+
 	rcu_assign_pointer(cnic_ulp_tbl[ulp_type], NULL);
 
 	mutex_unlock(&cnic_lock);
@@ -632,7 +649,6 @@ static void cnic_free_resc(struct cnic_dev *dev)
 	int i = 0;
 
 	if (cp->cnic_uinfo) {
-		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
 		while (cp->uio_dev != -1 && i < 15) {
 			msleep(100);
 			i++;
@@ -1057,6 +1073,9 @@ static void cnic_ulp_stop(struct cnic_dev *dev)
 	struct cnic_local *cp = dev->cnic_priv;
 	int if_type;
 
+	if (cp->cnic_uinfo)
+		cnic_send_nlmsg(cp, ISCSI_KEVENT_IF_DOWN, NULL);
+
 	rcu_read_lock();
 	for (if_type = 0; if_type < MAX_CNIC_ULP_TYPE; if_type++) {
 		struct cnic_ulp_ops *ulp_ops;
-- 
1.5.6.GIT


