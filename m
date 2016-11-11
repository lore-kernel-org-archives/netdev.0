From: Baoquan He <bhe@redhat.com>
Subject: [PATCH 1/2] Revert "bnx2: Reset device during driver initialization"
Date: Fri, 11 Nov 2016 21:46:34 +0800
Message-ID: <1478871995-29652-2-git-send-email-bhe@redhat.com>
References: <1478871995-29652-1-git-send-email-bhe@redhat.com>
Cc: linux-kernel@vger.kernel.org, Dept-GELinuxNICDev@cavium.com,
        rasesh.mody@cavium.com, harish.patil@cavium.com,
        frank@undermydesk.org, jsr@dex.edzone.net, pmenzel@molgen.mpg.de,
        jroedel@suse.de, dyoung@redhat.com, Baoquan He <bhe@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60130 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756436AbcKKNq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Nov 2016 08:46:59 -0500
In-Reply-To: <1478871995-29652-1-git-send-email-bhe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reverts commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c.

When people build bnx2 driver into kernel, it will fail to detect
and load firmware because firmware is contained in initramfs and
initramfs has not been uncompressed yet during do_initcalls. So
revert commit 3e1be7a and work out a new way in the later patch.

Signed-off-by: Baoquan He <bhe@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index b3791b3..c557972 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6361,6 +6361,10 @@ bnx2_open(struct net_device *dev)
 	struct bnx2 *bp = netdev_priv(dev);
 	int rc;
 
+	rc = bnx2_request_firmware(bp);
+	if (rc < 0)
+		goto out;
+
 	netif_carrier_off(dev);
 
 	bnx2_disable_int(bp);
@@ -6429,6 +6433,7 @@ bnx2_open(struct net_device *dev)
 	bnx2_free_irq(bp);
 	bnx2_free_mem(bp);
 	bnx2_del_napi(bp);
+	bnx2_release_firmware(bp);
 	goto out;
 }
 
@@ -8575,12 +8580,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_drvdata(pdev, dev);
 
-	rc = bnx2_request_firmware(bp);
-	if (rc < 0)
-		goto error;
-
-
-	bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
 	memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
 
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
@@ -8613,7 +8612,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	return 0;
 
 error:
-	bnx2_release_firmware(bp);
 	pci_iounmap(pdev, bp->regview);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
-- 
2.5.5
