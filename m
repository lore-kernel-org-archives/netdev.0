From: Flavio Leitner <fbl@redhat.com>
Subject: [PATCH] bnx2: do not start the interface if reset fails
Date: Wed, 13 Jul 2011 14:54:50 -0300
Message-ID: <1310579690-24622-1-git-send-email-fbl@redhat.com>
Cc: Flavio Leitner <fbl@redhat.com>
To: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932320Ab1GMRzF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 13:55:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bnx2_reset_task() is called, it will stop,
(re)initialize and start the interface to restore
the working condition.

The bnx2_init_nic() calls bnx2_reset_nic() which will
reset the chip and then call bnx2_free_skbs() to free
all the skbs.

The problem happens when bnx2_init_chip() fails because
bnx2_reset_nic() will just return skipping the ring
initializations at bnx2_init_all_rings(). Later, the
reset task starts the interface again and the system
crashes due a NULL pointer access (no skb in the ring).

This patch just check the return code and if an error is
reported, warn the user and abort. It's better to have a
non working interface than a crash.

Signed-off-by: Flavio Leitner <fbl@redhat.com>
---
 drivers/net/bnx2.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 7915d14..7fb71fc 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -6296,6 +6296,7 @@ static void
 bnx2_reset_task(struct work_struct *work)
 {
 	struct bnx2 *bp = container_of(work, struct bnx2, reset_task);
+	int rc;
 
 	rtnl_lock();
 	if (!netif_running(bp->dev)) {
@@ -6305,10 +6306,15 @@ bnx2_reset_task(struct work_struct *work)
 
 	bnx2_netif_stop(bp, true);
 
-	bnx2_init_nic(bp, 1);
+	rc = bnx2_init_nic(bp, 1);
+	if (rc) {
+		netdev_err(bp->dev, "failed to reset the NIC, aborting\n");
+		goto out;
+	}
 
 	atomic_set(&bp->intr_sem, 1);
 	bnx2_netif_start(bp, true);
+out:
 	rtnl_unlock();
 }
 
-- 
1.7.6

