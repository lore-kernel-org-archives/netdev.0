From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 1/2] cnic: Put rx/tx ring allocation in
 separate function.
Date: Wed, 26 Aug 2009 12:49:22 -0700
Message-ID: <1251316163-9359-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1397 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751390AbZHZTmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 15:42:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow the 10G iSCSI code to reuse the function.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   33 ++++++++++++++++++++++-----------
 1 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 4869d77..039900c 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -742,6 +742,26 @@ static int cnic_alloc_context(struct cnic_dev *dev)
 	return 0;
 }
 
+static int cnic_alloc_l2_rings(struct cnic_dev *dev, int pages)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+
+	cp->l2_ring_size = pages * BCM_PAGE_SIZE;
+	cp->l2_ring = pci_alloc_consistent(dev->pcidev, cp->l2_ring_size,
+					   &cp->l2_ring_map);
+	if (!cp->l2_ring)
+		return -ENOMEM;
+
+	cp->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
+	cp->l2_buf_size = PAGE_ALIGN(cp->l2_buf_size);
+	cp->l2_buf = pci_alloc_consistent(dev->pcidev, cp->l2_buf_size,
+					   &cp->l2_buf_map);
+	if (!cp->l2_buf)
+		return -ENOMEM;
+
+	return 0;
+}
+
 static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
@@ -762,17 +782,8 @@ static int cnic_alloc_bnx2_resc(struct cnic_dev *dev)
 	if (ret)
 		goto error;
 
-	cp->l2_ring_size = 2 * BCM_PAGE_SIZE;
-	cp->l2_ring = pci_alloc_consistent(dev->pcidev, cp->l2_ring_size,
-					   &cp->l2_ring_map);
-	if (!cp->l2_ring)
-		goto error;
-
-	cp->l2_buf_size = (cp->l2_rx_ring_size + 1) * cp->l2_single_buf_size;
-	cp->l2_buf_size = PAGE_ALIGN(cp->l2_buf_size);
-	cp->l2_buf = pci_alloc_consistent(dev->pcidev, cp->l2_buf_size,
-					   &cp->l2_buf_map);
-	if (!cp->l2_buf)
+	ret = cnic_alloc_l2_rings(dev, 2);
+	if (ret)
 		goto error;
 
 	uinfo = kzalloc(sizeof(*uinfo), GFP_ATOMIC);
-- 
1.6.4.GIT


