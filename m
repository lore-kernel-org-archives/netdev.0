From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 1/2] bnx2: Fix netpoll crash.
Date: Tue, 23 Mar 2010 15:13:11 -0800
Message-ID: <1269385992-18525-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4811 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753967Ab0CWXC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Mar 2010 19:02:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Li <benli@broadcom.com>

The bnx2 driver calls netif_napi_add() for all the NAPI structs during
->probe() time but not all of them will be used if we're not in MSI-X
mode.  This creates a problem for netpoll since it will poll all the
NAPI structs in the dev_list whether or not they are scheduled, resulting
in a crash when we access structure fields not initialized for that vector.

We fix it by moving the netif_napi_add() call to ->open() after the number
of IRQ vectors has been determined.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 381887b..417de1c 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -246,6 +246,8 @@ static const struct flash_spec flash_5709 = {
 
 MODULE_DEVICE_TABLE(pci, bnx2_pci_tbl);
 
+static void bnx2_init_napi(struct bnx2 *bp);
+
 static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 {
 	u32 diff;
@@ -6197,6 +6199,7 @@ bnx2_open(struct net_device *dev)
 	bnx2_disable_int(bp);
 
 	bnx2_setup_int_mode(bp, disable_msi);
+	bnx2_init_napi(bp);
 	bnx2_napi_enable(bp);
 	rc = bnx2_alloc_mem(bp);
 	if (rc)
@@ -8207,7 +8210,7 @@ bnx2_init_napi(struct bnx2 *bp)
 {
 	int i;
 
-	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++) {
+	for (i = 0; i < bp->irq_nvecs; i++) {
 		struct bnx2_napi *bnapi = &bp->bnx2_napi[i];
 		int (*poll)(struct napi_struct *, int);
 
@@ -8276,7 +8279,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->ethtool_ops = &bnx2_ethtool_ops;
 
 	bp = netdev_priv(dev);
-	bnx2_init_napi(bp);
 
 	pci_set_drvdata(pdev, dev);
 
-- 
1.6.4.GIT


