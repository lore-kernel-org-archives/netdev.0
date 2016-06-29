From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/15] fm10k: Remove create_workqueue
Date: Wed, 29 Jun 2016 14:32:59 -0700
Message-ID: <1467235982-55437-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42568 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839AbcF2VdI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jun 2016 17:33:08 -0400
In-Reply-To: <1467235982-55437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>

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
Acked-by: Tejun Heo <tj@kernel.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 53d02416..a9ccc1e 100644
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
-- 
2.5.5
