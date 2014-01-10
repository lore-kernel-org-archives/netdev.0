From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/17] i40e: do not bail when disabling if Tx queue disable fails
Date: Fri, 10 Jan 2014 12:30:30 -0800
Message-ID: <1389385839-11996-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56384 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758196AbaAJUap (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 15:30:45 -0500
In-Reply-To: <1389385839-11996-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

Fix a bug where the driver was erroneously exiting the driver unload
path if one part of the unload failed.  Instead of the original way
the driver should always continue when disabling and be sure to disable
all queues.

Change-ID: Ib8c81c596bc87c31d8e9ca97ebf871168475279d
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 80c83eb..65c27cb 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3113,7 +3113,7 @@ static int i40e_vsi_control_rx(struct i40e_vsi *vsi, bool enable)
  **/
 int i40e_vsi_control_rings(struct i40e_vsi *vsi, bool request)
 {
-	int ret;
+	int ret = 0;
 
 	/* do rx first for enable and last for disable */
 	if (request) {
@@ -3122,10 +3122,9 @@ int i40e_vsi_control_rings(struct i40e_vsi *vsi, bool request)
 			return ret;
 		ret = i40e_vsi_control_tx(vsi, request);
 	} else {
-		ret = i40e_vsi_control_tx(vsi, request);
-		if (ret)
-			return ret;
-		ret = i40e_vsi_control_rx(vsi, request);
+		/* Ignore return value, we need to shutdown whatever we can */
+		i40e_vsi_control_tx(vsi, request);
+		i40e_vsi_control_rx(vsi, request);
 	}
 
 	return ret;
-- 
1.8.3.1
