From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/14] i40evf: fix oops in watchdog handler
Date: Fri, 28 Mar 2014 07:08:03 -0700
Message-ID: <1396015695-25283-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21084 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664AbaC1OIS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 10:08:18 -0400
In-Reply-To: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The Tx watchdog handler runs in interrupt context, so it would cause an
oops when sending an admin queue message to request a reset, because the
admin queue functions use spinlocks.

Instead, set a flag and let the reset task handle sending the request.

Change-ID: I65879470b72963d9c308edfb8f45ac4fbba2c14f
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h      |  1 +
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index ccb43d3..807807d 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -211,6 +211,7 @@ struct i40evf_adapter {
 #define I40EVF_FLAG_NEED_LINK_UPDATE             (u32)(1 << 7)
 #define I40EVF_FLAG_PF_COMMS_FAILED              (u32)(1 << 8)
 #define I40EVF_FLAG_RESET_PENDING                (u32)(1 << 9)
+#define I40EVF_FLAG_RESET_NEEDED                 (u32)(1 << 10)
 /* duplcates for common code */
 #define I40E_FLAG_FDIR_ATR_ENABLED		 0
 #define I40E_FLAG_DCB_ENABLED			 0
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index d3eafa3..51c84c1 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -169,9 +169,7 @@ static void i40evf_tx_timeout(struct net_device *netdev)
 	adapter->tx_timeout_count++;
 	dev_info(&adapter->pdev->dev, "TX timeout detected.\n");
 	if (!(adapter->flags & I40EVF_FLAG_RESET_PENDING)) {
-		dev_info(&adapter->pdev->dev, "Requesting reset from PF\n");
-		i40evf_request_reset(adapter);
-		adapter->flags |= I40EVF_FLAG_RESET_PENDING;
+		adapter->flags |= I40EVF_FLAG_RESET_NEEDED;
 		schedule_work(&adapter->reset_task);
 	}
 }
@@ -1484,6 +1482,12 @@ static void i40evf_reset_task(struct work_struct *work)
 	while (test_and_set_bit(__I40EVF_IN_CRITICAL_TASK,
 				&adapter->crit_section))
 		udelay(500);
+
+	if (adapter->flags & I40EVF_FLAG_RESET_NEEDED) {
+		dev_info(&adapter->pdev->dev, "Requesting reset from PF\n");
+		i40evf_request_reset(adapter);
+	}
+
 	/* poll until we see the reset actually happen */
 	for (i = 0; i < I40EVF_RESET_WAIT_COUNT; i++) {
 		rstat_val = rd32(hw, I40E_VFGEN_RSTAT) &
-- 
1.9.0
