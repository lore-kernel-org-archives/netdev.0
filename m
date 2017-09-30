From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: prevent service task from running while we're suspended
Date: Fri, 29 Sep 2017 17:45:03 -0700
Message-ID: <20170930004507.20072-12-jeffrey.t.kirsher@intel.com>
References: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23279 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752674AbdI3Apw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 29 Sep 2017 20:45:52 -0400
In-Reply-To: <20170930004507.20072-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Although the service task does check the suspended status before
running, it might already be part way through running when we go to
suspend. Lets ensure that the service task is stopped and will not be
restarted again until we finish resuming. This ensures that service task
code does not cause strange interactions with the suspend/resume
handlers.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 494cafde6b26..368373459ad5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -12065,6 +12065,10 @@ static int i40e_suspend(struct device *dev)
 
 	set_bit(__I40E_DOWN, pf->state);
 
+	/* Ensure service task will not be running */
+	del_timer_sync(&pf->service_timer);
+	cancel_work_sync(&pf->service_task);
+
 	if (pf->wol_en && (pf->hw_features & I40E_HW_WOL_MC_MAGIC_PKT_WAKE))
 		i40e_enable_mc_magic_wake(pf);
 
@@ -12097,6 +12101,10 @@ static int i40e_resume(struct device *dev)
 	/* Clear suspended state last after everything is recovered */
 	clear_bit(__I40E_SUSPENDED, pf->state);
 
+	/* Restart the service task */
+	mod_timer(&pf->service_timer,
+		  round_jiffies(jiffies + pf->service_timer_period));
+
 	return 0;
 }
 
-- 
2.14.1
