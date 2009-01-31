From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 1/3] igb: Fix DCA errors and do not use context index
	for 82576
Date: Fri, 30 Jan 2009 16:53:43 -0800
Message-ID: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:58925
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752846AbZAaAyG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 19:54:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

82576 was being incorrectly flagged as needing a context index.  It does not as
each ring has it's own table of 2 contexts.

Driver was registering after registering the driver instead of the other way around.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    9 ++++-----
 drivers/net/igb/igb_main.c |   16 ++++++----------
 2 files changed, 10 insertions(+), 15 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 5a27825..aebef8e 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -300,11 +300,10 @@ struct igb_adapter {
 
 #define IGB_FLAG_HAS_MSI           (1 << 0)
 #define IGB_FLAG_MSI_ENABLE        (1 << 1)
-#define IGB_FLAG_HAS_DCA           (1 << 2)
-#define IGB_FLAG_DCA_ENABLED       (1 << 3)
-#define IGB_FLAG_IN_NETPOLL        (1 << 5)
-#define IGB_FLAG_QUAD_PORT_A       (1 << 6)
-#define IGB_FLAG_NEED_CTX_IDX      (1 << 7)
+#define IGB_FLAG_DCA_ENABLED       (1 << 2)
+#define IGB_FLAG_IN_NETPOLL        (1 << 3)
+#define IGB_FLAG_QUAD_PORT_A       (1 << 4)
+#define IGB_FLAG_NEED_CTX_IDX      (1 << 5)
 
 enum e1000_state_t {
 	__IGB_TESTING,
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index b82b0fb..cc94412 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -206,10 +206,11 @@ static int __init igb_init_module(void)
 
 	global_quad_port_a = 0;
 
-	ret = pci_register_driver(&igb_driver);
 #ifdef CONFIG_IGB_DCA
 	dca_register_notify(&dca_notifier);
 #endif
+
+	ret = pci_register_driver(&igb_driver);
 	return ret;
 }
 
@@ -1156,11 +1157,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 	/* set flags */
 	switch (hw->mac.type) {
-	case e1000_82576:
 	case e1000_82575:
-		adapter->flags |= IGB_FLAG_HAS_DCA;
 		adapter->flags |= IGB_FLAG_NEED_CTX_IDX;
 		break;
+	case e1000_82576:
 	default:
 		break;
 	}
@@ -1310,8 +1310,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		goto err_register;
 
 #ifdef CONFIG_IGB_DCA
-	if ((adapter->flags & IGB_FLAG_HAS_DCA) &&
-	    (dca_add_requester(&pdev->dev) == 0)) {
+	if (dca_add_requester(&pdev->dev) == 0) {
 		adapter->flags |= IGB_FLAG_DCA_ENABLED;
 		dev_info(&pdev->dev, "DCA enabled\n");
 		/* Always use CB2 mode, difference is masked
@@ -3473,19 +3472,16 @@ static int __igb_notify_dca(struct device *dev, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	unsigned long event = *(unsigned long *)data;
 
-	if (!(adapter->flags & IGB_FLAG_HAS_DCA))
-		goto out;
-
 	switch (event) {
 	case DCA_PROVIDER_ADD:
 		/* if already enabled, don't do it again */
 		if (adapter->flags & IGB_FLAG_DCA_ENABLED)
 			break;
-		adapter->flags |= IGB_FLAG_DCA_ENABLED;
 		/* Always use CB2 mode, difference is masked
 		 * in the CB driver. */
 		wr32(E1000_DCA_CTRL, 2);
 		if (dca_add_requester(dev) == 0) {
+			adapter->flags |= IGB_FLAG_DCA_ENABLED;
 			dev_info(&adapter->pdev->dev, "DCA enabled\n");
 			igb_setup_dca(adapter);
 			break;
@@ -3502,7 +3498,7 @@ static int __igb_notify_dca(struct device *dev, void *data)
 		}
 		break;
 	}
-out:
+
 	return 0;
 }
 

