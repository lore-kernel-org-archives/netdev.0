From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v2] bnx2: Reset device during driver initialization
Date: Fri,  9 Sep 2016 22:43:12 +0800
Message-ID: <1473432192-28249-1-git-send-email-bhe@redhat.com>
Cc: sony.chacko@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
        linux-kernel@vger.kernel.org, kexec@lists.infradead.org,
        joro@8bytes.org, dyoung@redhat.com, Baoquan He <bhe@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When system enters into kdump kernel because of kernel panic, it won't
shutdown devices. On-flight DMA will continue transferring data until
device driver initializes. All devices are supposed to reset during
driver initialization. And this property is used to fix the kdump
failure in system with intel iommu. Other systems with hardware iommu
should be similar. Please check commit 091d42e ("iommu/vt-d: Copy
translation tables from old kernel") and those commits around.

But bnx2 driver doesn't reset device during driver initialization. The
device resetting is deferred to net device up stage. This will cause
hardware iommu handling failure on bnx2 device. And its resetting relies
on firmware. So in this patch move the firmware requesting code to earlier
bnx2_init_one(), then next call bnx2_reset_chip to reset device.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
v1->v2:
    Forget removing bnx2_release_firmware which is used for error handling
    of bnx2_request_firmware.

 drivers/net/ethernet/broadcom/bnx2.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 8fc3f3c..505ceaf 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6356,10 +6356,6 @@ bnx2_open(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;
 
-	rc = bnx2_request_firmware(bp);
-	if (rc < 0)
-		goto out;
-
 	netif_carrier_off(dev);
 
 	bnx2_disable_int(bp);
@@ -6428,7 +6424,6 @@ open_err:
 	bnx2_free_irq(bp);
 	bnx2_free_mem(bp);
 	bnx2_del_napi(bp);
-	bnx2_release_firmware(bp);
 	goto out;
 }
 
@@ -8575,6 +8570,12 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
+	rc = bnx2_request_firmware(bp);
+	if (rc < 0)
+		goto error;
+
+
+	bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
 	memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
 
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
@@ -8607,6 +8608,7 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 error:
+	bnx2_release_firmware(bp);
 	pci_iounmap(pdev, bp->regview);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-- 
2.5.5
