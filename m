From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/14] i40e: remove WQ_UNBOUND and the task limit of our workqueue
Date: Wed, 26 Jul 2017 03:31:12 -0700
Message-ID: <20170726103123.76743-4-jeffrey.t.kirsher@intel.com>
References: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3294 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751175AbdGZKct (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Jul 2017 06:32:49 -0400
In-Reply-To: <20170726103123.76743-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

During certain events such as a CORER, multiple devices will run a work
task to handle some cleanup. This can cause issues due to
a single-threaded workqueue which can mean that a device doesn't cleanup
in time. Prevent this by removing the single-threaded restriction on the
module workqueue. This avoids the need to add more complex yielding
logic in our service task routine. This is also similar to what other
drivers such as fm10k do.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 933b8e357ee4..22e60841cb22 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -12180,12 +12180,14 @@ static int __init i40e_init_module(void)
 		i40e_driver_string, i40e_driver_version_str);
 	pr_info("%s: %s\n", i40e_driver_name, i40e_copyright);
 
-	/* we will see if single thread per module is enough for now,
-	 * it can't be any worse than using the system workqueue which
-	 * was already single threaded
+	/* There is no need to throttle the number of active tasks because
+	 * each device limits its own task using a state bit for scheduling
+	 * the service task, and the device tasks do not interfere with each
+	 * other, so we don't set a max task limit. We must set WQ_MEM_RECLAIM
+	 * since we need to be able to guarantee forward progress even under
+	 * memory pressure.
 	 */
-	i40e_wq = alloc_workqueue("%s", WQ_UNBOUND | WQ_MEM_RECLAIM, 1,
-				  i40e_driver_name);
+	i40e_wq = alloc_workqueue("%s", WQ_MEM_RECLAIM, 0, i40e_driver_name);
 	if (!i40e_wq) {
 		pr_err("%s: Failed to create workqueue\n", i40e_driver_name);
 		return -ENOMEM;
-- 
2.13.3
