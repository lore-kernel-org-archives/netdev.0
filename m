From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next] bnx2: Close device if tx_timeout reset fails
Date: Fri, 15 Jul 2011 09:53:58 -0700
Message-ID: <1310748838-30877-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fbl@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3103 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753665Ab1GORsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 13:48:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original patch and description from Flavio Leitner <fbl@redhat.com>

When bnx2_reset_task() is called, it will stop,
(re)initialize and start the interface to restore
the working condition.

The bnx2_init_nic() calls bnx2_reset_nic() which will
reset the chip and then calls bnx2_free_skbs() to free
all the skbs.

The problem happens when bnx2_init_chip() fails because
bnx2_reset_nic() will just return skipping the ring
initializations at bnx2_init_all_rings(). Later, the
reset task starts the interface again and the system
crashes due a NULL pointer access (no skb in the ring).

To fix it, we call dev_close() if bnx2_init_nic() fails.
One minor wrinkle to deal with is the cancel_work_sync()
call in bnx2_close() to cancel bnx2_reset_task().  The
call will wait forever because it is trying to cancel
itself and the workqueue will be stuck.

Since bnx2_reset_task() holds the rtnl_lock() and checks
for netif_running() before proceeding, there is no need
to cancel bnx2_reset_task() in bnx2_close() even if
bnx2_close() and bnx2_reset_task() are running concurrently.
The rtnl_lock() serializes the 2 calls.

We need to move the cancel_work_sync() call to
bnx2_remove_one() to make sure it is canceled before freeing
the netdev struct.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Cc: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/bnx2.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 4816d6a..3ad9b70 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6342,6 +6342,7 @@ static void
 bnx2_reset_task(struct work_struct *work)
 {
 	struct bnx2 *bp = container_of(work, struct bnx2, reset_task);
+	int rc;
 
 	rtnl_lock();
 	if (!netif_running(bp->dev)) {
@@ -6351,7 +6352,14 @@ bnx2_reset_task(struct work_struct *work)
 
 	bnx2_netif_stop(bp, true);
 
-	bnx2_init_nic(bp, 1);
+	rc = bnx2_init_nic(bp, 1);
+	if (rc) {
+		netdev_err(bp->dev, "failed to reset NIC, closing\n");
+		bnx2_napi_enable(bp);
+		dev_close(bp->dev);
+		rtnl_unlock();
+		return;
+	}
 
 	atomic_set(&bp->intr_sem, 1);
 	bnx2_netif_start(bp, true);
@@ -6573,8 +6581,6 @@ bnx2_close(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 
-	cancel_work_sync(&bp->reset_task);
-
 	bnx2_disable_int_sync(bp);
 	bnx2_napi_disable(bp);
 	del_timer_sync(&bp->timer);
@@ -8404,6 +8410,7 @@ bnx2_remove_one(struct pci_dev *pdev)
 	unregister_netdev(dev);
 
 	del_timer_sync(&bp->timer);
+	cancel_work_sync(&bp->reset_task);
 
 	if (bp->mips_firmware)
 		release_firmware(bp->mips_firmware);
-- 
1.6.4.GIT


