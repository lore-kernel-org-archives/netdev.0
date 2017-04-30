From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] i40evf: allocate queues before we setup the interrupts and q_vectors
Date: Sun, 30 Apr 2017 06:24:50 -0700
Message-ID: <20170430132451.68494-13-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:43916 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163495AbdD3NZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:25:16 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This matches the ordering of how we free stuff during reset and remove.
It also makes logical sense because we set the interrupts based on the
number of queues. Currently this doesn't really matter in practice.
However a future patch moves the assignment of num_active_queues into
i40evf_alloc_queues, which is required by
i40evf_set_interrupt_capability.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 89035ee01679..445a97a57853 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1508,6 +1508,13 @@ int i40evf_init_interrupt_scheme(struct i40evf_adapter *adapter)
 {
 	int err;
 
+	err = i40evf_alloc_queues(adapter);
+	if (err) {
+		dev_err(&adapter->pdev->dev,
+			"Unable to allocate memory for queues\n");
+		goto err_alloc_queues;
+	}
+
 	rtnl_lock();
 	err = i40evf_set_interrupt_capability(adapter);
 	rtnl_unlock();
@@ -1524,23 +1531,16 @@ int i40evf_init_interrupt_scheme(struct i40evf_adapter *adapter)
 		goto err_alloc_q_vectors;
 	}
 
-	err = i40evf_alloc_queues(adapter);
-	if (err) {
-		dev_err(&adapter->pdev->dev,
-			"Unable to allocate memory for queues\n");
-		goto err_alloc_queues;
-	}
-
 	dev_info(&adapter->pdev->dev, "Multiqueue %s: Queue pair count = %u",
 		 (adapter->num_active_queues > 1) ? "Enabled" : "Disabled",
 		 adapter->num_active_queues);
 
 	return 0;
-err_alloc_queues:
-	i40evf_free_q_vectors(adapter);
 err_alloc_q_vectors:
 	i40evf_reset_interrupt_capability(adapter);
 err_set_interrupt:
+	i40evf_free_queues(adapter);
+err_alloc_queues:
 	return err;
 }
 
-- 
2.12.2
