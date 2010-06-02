From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-2.6] bnx2: Fix hang during rmmod bnx2.
Date: Tue, 1 Jun 2010 18:05:36 -0700
Message-ID: <1275440736-18058-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3647 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756428Ab0FBBDs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 21:03:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The regression is caused by:

commit 4327ba435a56ada13eedf3eb332e583c7a0586a9
    bnx2: Fix netpoll crash.

If ->open() and ->close() are called multiple times, the same napi structs
will be added to dev->napi_list multiple times, corrupting the dev->napi_list.
This causes free_netdev() to hang during rmmod.

We fix this by calling netif_napi_del() during ->close().

Also, bnx2_init_napi() must not be in the __devinit section since it is
called by ->open().

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 188e356..949d7a9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -247,6 +247,7 @@ static const struct flash_spec flash_5709 = {
 MODULE_DEVICE_TABLE(pci, bnx2_pci_tbl);
 
 static void bnx2_init_napi(struct bnx2 *bp);
+static void bnx2_del_napi(struct bnx2 *bp);
 
 static inline u32 bnx2_tx_avail(struct bnx2 *bp, struct bnx2_tx_ring_info *txr)
 {
@@ -6270,6 +6271,7 @@ open_err:
 	bnx2_free_skbs(bp);
 	bnx2_free_irq(bp);
 	bnx2_free_mem(bp);
+	bnx2_del_napi(bp);
 	return rc;
 }
 
@@ -6537,6 +6539,7 @@ bnx2_close(struct net_device *dev)
 	bnx2_free_irq(bp);
 	bnx2_free_skbs(bp);
 	bnx2_free_mem(bp);
+	bnx2_del_napi(bp);
 	bp->link_up = 0;
 	netif_carrier_off(bp->dev);
 	bnx2_set_power_state(bp, PCI_D3hot);
@@ -8227,7 +8230,16 @@ bnx2_bus_string(struct bnx2 *bp, char *str)
 	return str;
 }
 
-static void __devinit
+static void
+bnx2_del_napi(struct bnx2 *bp)
+{
+	int i;
+
+	for (i = 0; i < bp->irq_nvecs; i++)
+		netif_napi_del(&bp->bnx2_napi[i].napi);
+}
+
+static void
 bnx2_init_napi(struct bnx2 *bp)
 {
 	int i;
-- 
1.6.4.GIT


