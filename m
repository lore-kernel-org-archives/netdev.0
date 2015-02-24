From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 4/8] NFC: NCI: Add a special nci_request for driver
Date: Tue, 24 Feb 2015 12:01:48 +0200
Message-ID: <1424772112-27399-5-git-send-email-robert.dolca@intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds nci_request_driver and nci_req_complete_driver
as a wrapper for __nci_request. When nci_req_complete_driver is
called it also sets cmd_cnt to 1. This is done because the response is not
sent to the NFC subsystem so cmd_cnt is not decremented there.

nci_send_cmd was previously exported in order to send commands to
the device from the driver. It shouldn't be used without
nci_req_complete_driver because cmd_cnt will have the wrong value.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci_core.h |  4 ++++
 net/nfc/nci/core.c         | 19 +++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/include/net/nfc/nci_core.h b/include/net/nfc/nci_core.h
index 4358d0a..42ec342 100644
--- a/include/net/nfc/nci_core.h
+++ b/include/net/nfc/nci_core.h
@@ -333,6 +333,10 @@ void nci_clear_target_list(struct nci_dev *ndev);
 #define NCI_REQ_CANCELED	2
 
 void nci_req_complete(struct nci_dev *ndev, int result);
+int nci_request_driver(struct nci_dev *ndev,
+		       void (*req)(struct nci_dev *ndev, unsigned long opt),
+		       unsigned long opt, __u32 timeout);
+void nci_req_complete_driver(struct nci_dev *ndev, int result);
 struct nci_conn_info *nci_get_conn_info_by_conn_id(struct nci_dev *ndev,
 						   int conn_id);
 
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 317b94b..1a449ac 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -74,6 +74,17 @@ void nci_req_complete(struct nci_dev *ndev, int result)
 	}
 }
 
+void nci_req_complete_driver(struct nci_dev *ndev, int result)
+{
+	nci_req_complete(ndev, result);
+
+	/* trigger the next cmd */
+	atomic_set(&ndev->cmd_cnt, 1);
+	if (!skb_queue_empty(&ndev->cmd_q))
+		queue_work(ndev->cmd_wq, &ndev->cmd_work);
+}
+EXPORT_SYMBOL(nci_req_complete_driver);
+
 static void nci_req_cancel(struct nci_dev *ndev, int err)
 {
 	if (ndev->req_status == NCI_REQ_PEND) {
@@ -127,6 +138,14 @@ static int __nci_request(struct nci_dev *ndev,
 	return rc;
 }
 
+int nci_request_driver(struct nci_dev *ndev,
+		       void (*req)(struct nci_dev *ndev, unsigned long opt),
+		       unsigned long opt, __u32 timeout)
+{
+	return __nci_request(ndev, req, opt, timeout);
+}
+EXPORT_SYMBOL(nci_request_driver);
+
 inline int nci_request(struct nci_dev *ndev,
 		       void (*req)(struct nci_dev *ndev,
 				   unsigned long opt),
-- 
1.9.1
