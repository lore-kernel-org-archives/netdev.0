From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 6/9] cnic: Check device state before reading
 the kcq pointer in IRQ
Date: Thu, 23 Dec 2010 10:38:30 -0800
Message-ID: <1293129510-13174-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3595 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732Ab0LWTdp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Dec 2010 14:33:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the device is down, the kcq pointer may be NULL.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/cnic.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index bf4a804..1240dea 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -2352,11 +2352,12 @@ static u32 cnic_service_bnx2_queues(struct cnic_dev *dev)
 static int cnic_service_bnx2(void *data, void *status_blk)
 {
 	struct cnic_dev *dev = data;
-	struct cnic_local *cp = dev->cnic_priv;
-	u32 status_idx = *cp->kcq1.status_idx_ptr;
 
-	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags)))
-		return status_idx;
+	if (unlikely(!test_bit(CNIC_F_CNIC_UP, &dev->flags))) {
+		struct status_block *sblk = status_blk;
+
+		return sblk->status_idx;
+	}
 
 	return cnic_service_bnx2_queues(dev);
 }
@@ -2375,9 +2376,10 @@ static void cnic_service_bnx2_msix(unsigned long data)
 static void cnic_doirq(struct cnic_dev *dev)
 {
 	struct cnic_local *cp = dev->cnic_priv;
-	u16 prod = cp->kcq1.sw_prod_idx & MAX_KCQ_IDX;
 
 	if (likely(test_bit(CNIC_F_CNIC_UP, &dev->flags))) {
+		u16 prod = cp->kcq1.sw_prod_idx & MAX_KCQ_IDX;
+
 		prefetch(cp->status_blk.gen);
 		prefetch(&cp->kcq1.kcq[KCQ_PG(prod)][KCQ_IDX(prod)]);
 
-- 
1.6.4.GIT


