From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 24/34] forcedeth: Cleanup MSI-X to MSI to INTx fallback code
Date: Fri, 31 Jan 2014 16:08:43 +0100
Message-ID: <41a8f04a170e110089826564893c473685eaa794.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37828 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932684AbaAaPHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Jan 2014 10:07:44 -0500
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index f4270b8..74da489 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3930,7 +3930,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 {
 	struct fe_priv *np = get_nvpriv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	int ret = 1;
+	int ret;
 	int i;
 	irqreturn_t (*handler)(int foo, void *data);
 
@@ -4010,9 +4010,10 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				writel(0, base + NvRegMSIXMap1);
 			}
 			netdev_info(dev, "MSI-X enabled\n");
+			return 0;
 		}
 	}
-	if (ret != 0 && np->msi_flags & NV_MSI_CAPABLE) {
+	if (np->msi_flags & NV_MSI_CAPABLE) {
 		ret = pci_enable_msi(np->pci_dev);
 		if (ret == 0) {
 			np->msi_flags |= NV_MSI_ENABLED;
@@ -4031,13 +4032,12 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 			/* enable msi vector 0 */
 			writel(NVREG_MSI_VECTOR_0_ENABLED, base + NvRegMSIIrqMask);
 			netdev_info(dev, "MSI enabled\n");
+			return 0;
 		}
 	}
-	if (ret != 0) {
-		if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0)
-			goto out_err;
 
-	}
+	if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0)
+		goto out_err;
 
 	return 0;
 out_free_tx:
-- 
1.7.7.6
