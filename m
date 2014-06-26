From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40evf: return more useful error information
Date: Thu, 26 Jun 2014 05:13:43 -0700
Message-ID: <1403784834-23301-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10390 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756280AbaFZMO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:26 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When verifying the API version (which is the first time the driver
communicates with the firmware and thus the PF driver), there are many
ways in which a failure can occur. There may be an error from the
firmware, there may be unresponsive firmware, there may be an error from
the PF driver, etc, etc.

Make this function return more useful information, instead of just -EIO.
Propagate FW errors back to the caller, and log a message if the PF
sends an invalid reply.

Change-ID: I3e9135a2b80f7acdb855f62f12b2b2668c9a8951
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
index 2dc0bac..0ed2ad7 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_virtchnl.c
@@ -80,8 +80,9 @@ int i40evf_send_api_ver(struct i40evf_adapter *adapter)
  * @adapter: adapter structure
  *
  * Compare API versions with the PF. Must be called after admin queue is
- * initialized. Returns 0 if API versions match, -EIO if
- * they do not, or I40E_ERR_ADMIN_QUEUE_NO_WORK if the admin queue is empty.
+ * initialized. Returns 0 if API versions match, -EIO if they do not,
+ * I40E_ERR_ADMIN_QUEUE_NO_WORK if the admin queue is empty, and any errors
+ * from the firmware are propagated.
  **/
 int i40evf_verify_api_ver(struct i40evf_adapter *adapter)
 {
@@ -102,13 +103,13 @@ int i40evf_verify_api_ver(struct i40evf_adapter *adapter)
 		goto out_alloc;
 
 	err = (i40e_status)le32_to_cpu(event.desc.cookie_low);
-	if (err) {
-		err = -EIO;
+	if (err)
 		goto out_alloc;
-	}
 
 	if ((enum i40e_virtchnl_ops)le32_to_cpu(event.desc.cookie_high) !=
 	    I40E_VIRTCHNL_OP_VERSION) {
+		dev_info(&adapter->pdev->dev, "Invalid reply type %d from PF\n",
+			 le32_to_cpu(event.desc.cookie_high));
 		err = -EIO;
 		goto out_alloc;
 	}
-- 
1.9.3
