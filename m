From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/16] i40e: prep vsi_open logic for non-netdev cases
Date: Tue, 22 Apr 2014 05:39:25 -0700
Message-ID: <1398170371-3333-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27100 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932614AbaDVMjk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:40 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Rearrange the "if netdev" logic slightly to get ready for handling
non-netdev VSIs.

Change-ID: Ia0bfe13d4c994a2351a3c31fe725b75caeb397ee
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 33 ++++++++++++++++-------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7beef10..7dda8b2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -4306,24 +4306,27 @@ int i40e_vsi_open(struct i40e_vsi *vsi)
 	if (err)
 		goto err_setup_rx;
 
-	if (!vsi->netdev) {
+	if (vsi->netdev) {
+		snprintf(int_name, sizeof(int_name) - 1, "%s-%s",
+			 dev_driver_string(&pf->pdev->dev), vsi->netdev->name);
+		err = i40e_vsi_request_irq(vsi, int_name);
+		if (err)
+			goto err_setup_rx;
+
+		/* Notify the stack of the actual queue counts. */
+		err = netif_set_real_num_tx_queues(vsi->netdev,
+						   vsi->num_queue_pairs);
+		if (err)
+			goto err_set_queues;
+
+		err = netif_set_real_num_rx_queues(vsi->netdev,
+						   vsi->num_queue_pairs);
+		if (err)
+			goto err_set_queues;
+	} else {
 		err = EINVAL;
 		goto err_setup_rx;
 	}
-	snprintf(int_name, sizeof(int_name) - 1, "%s-%s",
-		 dev_driver_string(&pf->pdev->dev), vsi->netdev->name);
-	err = i40e_vsi_request_irq(vsi, int_name);
-	if (err)
-		goto err_setup_rx;
-
-	/* Notify the stack of the actual queue counts. */
-	err = netif_set_real_num_tx_queues(vsi->netdev, vsi->num_queue_pairs);
-	if (err)
-		goto err_set_queues;
-
-	err = netif_set_real_num_rx_queues(vsi->netdev, vsi->num_queue_pairs);
-	if (err)
-		goto err_set_queues;
 
 	err = i40e_up_complete(vsi);
 	if (err)
-- 
1.9.0
