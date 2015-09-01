From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v2 7/9] nfc: nci: Use a separate mutex for nci open and close
Date: Tue,  1 Sep 2015 17:54:26 +0300
Message-ID: <1441119268-30654-8-git-send-email-robert.dolca@intel.com>
References: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The functions were using req_lock for serialization. Doing so it
prevented the driver from calling nci_request during setup because it uses
the same mutex.

In the open and close functions __nci_request was replaced with nci_request
because it acquires req_lock.

Add test for NCI_INIT bit in nci_request to allow calling the function
during setup.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  3 +++
 net/nfc/nci/core.c         | 30 ++++++++++++++++--------------
 2 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index d28b7a3..61dcaf2 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -266,6 +266,9 @@ struct nci_dev {
 	/* stored during intf_activated_ntf */
 	__u8 remote_gb[NFC_MAX_GT_LEN];
 	__u8 remote_gb_len;
+
+	/* lock used for setup and other nci_ops serialization */
+	struct mutex op_lock;
 };
 
 /* ----- NCI Devices ----- */
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 6f173cd..5d61b6e 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -136,7 +136,8 @@ inline int nci_request(struct nci_dev *ndev,
 {
 	int rc;
 
-	if (!test_bit(NCI_UP, &ndev->flags))
+	if (!test_bit(NCI_UP, &ndev->flags) &&
+	    !test_bit(NCI_INIT, &ndev->flags))
 		return -ENETDOWN;
 
 	/* Serialize all requests */
@@ -383,7 +384,7 @@ static int nci_open_device(struct nci_dev *ndev)
 {
 	int rc = 0;
 
-	mutex_lock(&ndev->req_lock);
+	mutex_lock(&ndev->op_lock);
 
 	if (test_bit(NCI_UP, &ndev->flags)) {
 		rc = -EALREADY;
@@ -403,8 +404,8 @@ static int nci_open_device(struct nci_dev *ndev)
 		rc = ndev->ops->init(ndev);
 
 	if (!rc) {
-		rc = __nci_request(ndev, nci_reset_req, 0,
-				   msecs_to_jiffies(NCI_RESET_TIMEOUT));
+		rc = nci_request(ndev, nci_reset_req, 0,
+				 msecs_to_jiffies(NCI_RESET_TIMEOUT));
 	}
 
 	if (!rc && ndev->ops->setup) {
@@ -412,16 +413,16 @@ static int nci_open_device(struct nci_dev *ndev)
 	}
 
 	if (!rc) {
-		rc = __nci_request(ndev, nci_init_req, 0,
-				   msecs_to_jiffies(NCI_INIT_TIMEOUT));
+		rc = nci_request(ndev, nci_init_req, 0,
+				 msecs_to_jiffies(NCI_INIT_TIMEOUT));
 	}
 
 	if (!rc && ndev->ops->post_setup)
 		rc = ndev->ops->post_setup(ndev);
 
 	if (!rc) {
-		rc = __nci_request(ndev, nci_init_complete_req, 0,
-				   msecs_to_jiffies(NCI_INIT_TIMEOUT));
+		rc = nci_request(ndev, nci_init_complete_req, 0,
+				 msecs_to_jiffies(NCI_INIT_TIMEOUT));
 	}
 
 	clear_bit(NCI_INIT, &ndev->flags);
@@ -441,19 +442,19 @@ static int nci_open_device(struct nci_dev *ndev)
 	}
 
 done:
-	mutex_unlock(&ndev->req_lock);
+	mutex_unlock(&ndev->op_lock);
 	return rc;
 }
 
 static int nci_close_device(struct nci_dev *ndev)
 {
 	nci_req_cancel(ndev, ENODEV);
-	mutex_lock(&ndev->req_lock);
+	mutex_lock(&ndev->op_lock);
 
 	if (!test_and_clear_bit(NCI_UP, &ndev->flags)) {
 		del_timer_sync(&ndev->cmd_timer);
 		del_timer_sync(&ndev->data_timer);
-		mutex_unlock(&ndev->req_lock);
+		mutex_unlock(&ndev->op_lock);
 		return 0;
 	}
 
@@ -470,8 +471,8 @@ static int nci_close_device(struct nci_dev *ndev)
 	atomic_set(&ndev->cmd_cnt, 1);
 
 	set_bit(NCI_INIT, &ndev->flags);
-	__nci_request(ndev, nci_reset_req, 0,
-		      msecs_to_jiffies(NCI_RESET_TIMEOUT));
+	nci_request(ndev, nci_reset_req, 0,
+		    msecs_to_jiffies(NCI_RESET_TIMEOUT));
 
 	/* After this point our queues are empty
 	 * and no works are scheduled.
@@ -488,7 +489,7 @@ static int nci_close_device(struct nci_dev *ndev)
 	/* Clear flags */
 	ndev->flags = 0;
 
-	mutex_unlock(&ndev->req_lock);
+	mutex_unlock(&ndev->op_lock);
 
 	return 0;
 }
@@ -1123,6 +1124,7 @@ int nci_register_device(struct nci_dev *ndev)
 		    (unsigned long) ndev);
 
 	mutex_init(&ndev->req_lock);
+	mutex_init(&ndev->op_lock);
 	INIT_LIST_HEAD(&ndev->conn_info_list);
 
 	rc = nfc_register_device(ndev->nfc_dev);
-- 
1.9.1
