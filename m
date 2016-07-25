From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] caif-hsi: Remove deprecated create_singlethread_workqueue
Date: Mon, 25 Jul 2016 18:40:57 +0530
Message-ID: <20160725131057.GA751@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tejun Heo <tj@kernel.org>
To: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_singlethread_workqueue().

A dedicated workqueue has been used since the workitems are being used
on a packet tx/rx path. Hence, WQ_MEM_RECLAIM has been set to guarantee
forward progress under memory pressure.

An ordered workqueue has been used since workitems &cfhsi->wake_up_work
and &cfhsi->wake_down_work cannot be run concurrently.

Calls to flush_workqueue() before destroy_workqueue() have been dropped
since destroy_workqueue() itself calls drain_workqueue() which flushes
repeatedly till the workqueue becomes empty.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/caif/caif_hsi.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 615c65d..ddabce7 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -1201,7 +1201,7 @@ static int cfhsi_open(struct net_device *ndev)
 	clear_bit(CFHSI_AWAKE, &cfhsi->bits);

 	/* Create work thread. */
-	cfhsi->wq = create_singlethread_workqueue(cfhsi->ndev->name);
+	cfhsi->wq = alloc_ordered_workqueue(cfhsi->ndev->name, WQ_MEM_RECLAIM);
 	if (!cfhsi->wq) {
 		netdev_err(cfhsi->ndev, "%s: Failed to create work queue.\n",
 			__func__);
@@ -1267,9 +1267,6 @@ static int cfhsi_close(struct net_device *ndev)
 	/* going to shutdown driver */
 	set_bit(CFHSI_SHUTDOWN, &cfhsi->bits);

-	/* Flush workqueue */
-	flush_workqueue(cfhsi->wq);
-
 	/* Delete timers if pending */
 	del_timer_sync(&cfhsi->inactivity_timer);
 	del_timer_sync(&cfhsi->rx_slowpath_timer);
--
2.1.4
