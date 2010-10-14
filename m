From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/8 net-next] cnic: Add cnic_free_uio()
Date: Wed, 13 Oct 2010 17:06:48 -0700
Message-ID: <1287014811-10979-6-git-send-email-mchan@broadcom.com>
References: <1287014811-10979-1-git-send-email-mchan@broadcom.com>
 <1287014811-10979-2-git-send-email-mchan@broadcom.com>
 <1287014811-10979-3-git-send-email-mchan@broadcom.com>
 <1287014811-10979-4-git-send-email-mchan@broadcom.com>
 <1287014811-10979-5-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1654 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066Ab0JNBEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Oct 2010 21:04:01 -0400
In-Reply-To: <1287014811-10979-5-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

to free all UIO related structures.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   37 +++++++++++++++++++++++++++----------
 1 files changed, 27 insertions(+), 10 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index b12bba7..739ffcb 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -770,20 +770,15 @@ static void cnic_free_context(struct cnic_dev *dev)
 	}
 }
 
-static void cnic_free_resc(struct cnic_dev *dev)
+static void __cnic_free_uio(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	int i = 0;
 
-	if (cp->cnic_uinfo) {
-		while (cp->uio_dev != -1 && i < 15) {
-			msleep(100);
-			i++;
-		}
+	if (cp->cnic_uinfo)
 		uio_unregister_device(cp->cnic_uinfo);
-		kfree(cp->cnic_uinfo);
-		cp->cnic_uinfo = NULL;
-	}
+
+	kfree(cp->cnic_uinfo);
+	cp->cnic_uinfo = NULL;
 
 	if (cp->l2_buf) {
 		dma_free_coherent(&dev->pcidev->dev, cp->l2_buf_size,
@@ -796,6 +791,28 @@ static void cnic_free_resc(struct cnic_dev *dev)
 				  cp->l2_ring, cp->l2_ring_map);
 		cp->l2_ring = NULL;
 	}
+}
+
+static void cnic_free_uio(struct cnic_dev *dev)
+{
+	if (!dev)
+		return;
+
+	__cnic_free_uio(dev);
+}
+
+static void cnic_free_resc(struct cnic_dev *dev)
+{
+	struct cnic_local *cp = dev->cnic_priv;
+	int i = 0;
+
+	if (cp->cnic_uinfo) {
+		while (cp->uio_dev != -1 && i < 15) {
+			msleep(100);
+			i++;
+		}
+		cnic_free_uio(dev);
+	}
 
 	cnic_free_context(dev);
 	kfree(cp->ctx_arr);
-- 
1.6.4.GIT


