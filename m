From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/17] i40evf: don't give up
Date: Fri, 16 Oct 2015 22:28:19 -0700
Message-ID: <1445059711-45992-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63385 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751661AbbJQF2l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2015 01:28:41 -0400
In-Reply-To: <1445059711-45992-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When the VF driver is unable to communicate with the PF, it just gives
up and never tries again. Aside from the obvious character flaw that
this shows, it's also a lousy user experience.

When PF communications fail, wait five seconds, and try again. And
again. Don't give up, little VF driver! Your prince will come!

Change-ID: Ia1378a39879883563b8faffce819f375821f9585
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 1dd5245..ce99790 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2357,9 +2357,12 @@ err_alloc:
 err:
 	/* Things went into the weeds, so try again later */
 	if (++adapter->aq_wait_count > I40EVF_AQ_MAX_ERR) {
-		dev_err(&pdev->dev, "Failed to communicate with PF; giving up\n");
+		dev_err(&pdev->dev, "Failed to communicate with PF; waiting before retry\n");
 		adapter->flags |= I40EVF_FLAG_PF_COMMS_FAILED;
-		return; /* do not reschedule */
+		i40evf_shutdown_adminq(hw);
+		adapter->state = __I40EVF_STARTUP;
+		schedule_delayed_work(&adapter->init_task, HZ * 5);
+		return;
 	}
 	schedule_delayed_work(&adapter->init_task, HZ);
 }
-- 
2.4.3
