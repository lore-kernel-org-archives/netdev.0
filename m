From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 6/8] tg3: Relocate tg3_find_peer
Date: Mon, 13 Feb 2012 12:20:10 -0800
Message-ID: <1329164412-24566-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1930 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757858Ab2BMUU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:20:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch relocates tg3_find_peer to eliminate a prototype.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   58 +++++++++++++++++------------------
 1 files changed, 28 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index bbe1394..cc09217 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13847,8 +13847,6 @@ done:
 	tp->fw_ver[TG3_VER_SIZE - 1] = 0;
 }
 
-static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
-
 static inline u32 tg3_rx_ret_ring_size(struct tg3 *tp)
 {
 	if (tg3_flag(tp, LRG_PROD_RING_CAP))
@@ -13866,6 +13864,34 @@ static DEFINE_PCI_DEVICE_TABLE(tg3_write_reorder_chipsets) = {
 	{ },
 };
 
+static struct pci_dev * __devinit tg3_find_peer(struct tg3 *tp)
+{
+	struct pci_dev *peer;
+	unsigned int func, devnr = tp->pdev->devfn & ~7;
+
+	for (func = 0; func < 8; func++) {
+		peer = pci_get_slot(tp->pdev->bus, devnr | func);
+		if (peer && peer != tp->pdev)
+			break;
+		pci_dev_put(peer);
+	}
+	/* 5704 can be configured in single-port mode, set peer to
+	 * tp->pdev in that case.
+	 */
+	if (!peer) {
+		peer = tp->pdev;
+		return peer;
+	}
+
+	/*
+	 * We don't need to keep the refcount elevated; there's no way
+	 * to remove one half of this device without removing the other
+	 */
+	pci_dev_put(peer);
+
+	return peer;
+}
+
 static int __devinit tg3_get_invariants(struct tg3 *tp)
 {
 	u32 misc_ctrl_reg;
@@ -15364,34 +15390,6 @@ static char * __devinit tg3_bus_string(struct tg3 *tp, char *str)
 	return str;
 }
 
-static struct pci_dev * __devinit tg3_find_peer(struct tg3 *tp)
-{
-	struct pci_dev *peer;
-	unsigned int func, devnr = tp->pdev->devfn & ~7;
-
-	for (func = 0; func < 8; func++) {
-		peer = pci_get_slot(tp->pdev->bus, devnr | func);
-		if (peer && peer != tp->pdev)
-			break;
-		pci_dev_put(peer);
-	}
-	/* 5704 can be configured in single-port mode, set peer to
-	 * tp->pdev in that case.
-	 */
-	if (!peer) {
-		peer = tp->pdev;
-		return peer;
-	}
-
-	/*
-	 * We don't need to keep the refcount elevated; there's no way
-	 * to remove one half of this device without removing the other
-	 */
-	pci_dev_put(peer);
-
-	return peer;
-}
-
 static void __devinit tg3_init_coal(struct tg3 *tp)
 {
 	struct ethtool_coalesce *ec = &tp->coal;
-- 
1.7.3.4
