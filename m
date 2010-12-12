From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/9] sungem: update gp->reset_task flushing
Date: Sun, 12 Dec 2010 16:53:03 +0100
Message-ID: <1292169185-10579-8-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gp->reset_task_pending is always set right before reset_task is
scheduled and as there is no synchronization between the setting and
scheduling, busy looping on reset_task_pending before flushing
reset_task doesn't really buy anything.

Directly flush gp->reset_task on suspend and cancel on detach.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
---
 drivers/net/sungem.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4ceb3cf..9e992ca 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -2380,10 +2380,8 @@ static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 	 */
 	mutex_unlock(&gp->pm_mutex);
 
-	/* Wait for a pending reset task to complete */
-	while (gp->reset_task_pending)
-		yield();
-	flush_scheduled_work();
+	/* Wait for the pending reset task to complete */
+	flush_work_sync(&gp->reset_task);
 
 	/* Shut the PHY down eventually and setup WOL */
 	gem_stop_phy(gp, gp->asleep_wol);
@@ -2928,10 +2926,8 @@ static void gem_remove_one(struct pci_dev *pdev)
 		/* We shouldn't need any locking here */
 		gem_get_cell(gp);
 
-		/* Wait for a pending reset task to complete */
-		while (gp->reset_task_pending)
-			yield();
-		flush_scheduled_work();
+		/* Cancel reset task */
+		cancel_work_sync(&gp->reset_task);
 
 		/* Shut the PHY down */
 		gem_stop_phy(gp, 0);
-- 
1.7.1
