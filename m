From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Subject: [PATCH] net: ethernet: intel: fm10k: Remove create_workqueue
Date: Wed, 1 Jun 2016 21:10:09 +0530
Message-ID: <20160601154009.GA31043@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tejun Heo <tj@kernel.org>, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc_workqueue replaces deprecated create_workqueue().

A dedicated workqueue has been used since the workitem (viz
fm10k_service_task, which manages and runs other subtasks) is involved in
normal device operation and requires forward progress under memory
pressure.

create_workqueue has been replaced with alloc_workqueue with max_active
as 0 since there is no need for throttling the number of active work
items.

Since network devices may be used in memory reclaim path,
WQ_MEM_RECLAIM has been set to guarantee forward progress.

flush_workqueue is unnecessary since destroy_workqueue() itself calls
drain_workqueue() which flushes repeatedly till the workqueue
becomes empty. Hence the call to flush_workqueue() has been dropped.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 0e166e9..add9166 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -56,7 +56,7 @@ static int __init fm10k_init_module(void)
 	pr_info("%s\n", fm10k_copyright);

 	/* create driver workqueue */
-	fm10k_workqueue = create_workqueue("fm10k");
+	fm10k_workqueue = alloc_workqueue("fm10k", WQ_MEM_RECLAIM, 0);

 	fm10k_dbg_init();

@@ -77,7 +77,6 @@ static void __exit fm10k_exit_module(void)
 	fm10k_dbg_exit();

 	/* destroy driver workqueue */
-	flush_workqueue(fm10k_workqueue);
 	destroy_workqueue(fm10k_workqueue);
 }
 module_exit(fm10k_exit_module);
