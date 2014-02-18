From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 24/35] forcedeth: Cleanup MSI-X to MSI to INTx fallback code
Date: Tue, 18 Feb 2014 11:11:53 +0100
Message-ID: <717634ee6d507e7c868a898778d7fcd4300f9196.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
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
