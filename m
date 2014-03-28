From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 08/14] i40e: check for netdev before debugfs use
Date: Fri, 28 Mar 2014 07:08:09 -0700
Message-ID: <1396015695-25283-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:61227 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752383AbaC1OI5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2014 10:08:57 -0400
In-Reply-To: <1396015695-25283-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure the VSI has a netdev before trying to use it
in the debugfs netdev_ops commands.

Change-ID: I2d744fc0c32b3226534ce2cde171d9675c5440a6
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 35 ++++++++++++++++----------
 1 file changed, 22 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index afd43d7..3c37386 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -2087,9 +2087,13 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 		if (!vsi) {
 			dev_info(&pf->pdev->dev,
 				 "tx_timeout: VSI %d not found\n", vsi_seid);
-			goto netdev_ops_write_done;
-		}
-		if (rtnl_trylock()) {
+		} else if (!vsi->netdev) {
+			dev_info(&pf->pdev->dev, "tx_timeout: no netdev for VSI %d\n",
+				 vsi_seid);
+		} else if (test_bit(__I40E_DOWN, &vsi->state)) {
+			dev_info(&pf->pdev->dev, "tx_timeout: VSI %d not UP\n",
+				 vsi_seid);
+		} else if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_tx_timeout(vsi->netdev);
 			rtnl_unlock();
 			dev_info(&pf->pdev->dev, "tx_timeout called\n");
@@ -2108,9 +2112,10 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 		if (!vsi) {
 			dev_info(&pf->pdev->dev,
 				 "change_mtu: VSI %d not found\n", vsi_seid);
-			goto netdev_ops_write_done;
-		}
-		if (rtnl_trylock()) {
+		} else if (!vsi->netdev) {
+			dev_info(&pf->pdev->dev, "change_mtu: no netdev for VSI %d\n",
+				 vsi_seid);
+		} else if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_change_mtu(vsi->netdev,
 								mtu);
 			rtnl_unlock();
@@ -2129,9 +2134,10 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 		if (!vsi) {
 			dev_info(&pf->pdev->dev,
 				 "set_rx_mode: VSI %d not found\n", vsi_seid);
-			goto netdev_ops_write_done;
-		}
-		if (rtnl_trylock()) {
+		} else if (!vsi->netdev) {
+			dev_info(&pf->pdev->dev, "set_rx_mode: no netdev for VSI %d\n",
+				 vsi_seid);
+		} else if (rtnl_trylock()) {
 			vsi->netdev->netdev_ops->ndo_set_rx_mode(vsi->netdev);
 			rtnl_unlock();
 			dev_info(&pf->pdev->dev, "set_rx_mode called\n");
@@ -2149,11 +2155,14 @@ static ssize_t i40e_dbg_netdev_ops_write(struct file *filp,
 		if (!vsi) {
 			dev_info(&pf->pdev->dev, "napi: VSI %d not found\n",
 				 vsi_seid);
-			goto netdev_ops_write_done;
+		} else if (!vsi->netdev) {
+			dev_info(&pf->pdev->dev, "napi: no netdev for VSI %d\n",
+				 vsi_seid);
+		} else {
+			for (i = 0; i < vsi->num_q_vectors; i++)
+				napi_schedule(&vsi->q_vectors[i]->napi);
+			dev_info(&pf->pdev->dev, "napi called\n");
 		}
-		for (i = 0; i < vsi->num_q_vectors; i++)
-			napi_schedule(&vsi->q_vectors[i]->napi);
-		dev_info(&pf->pdev->dev, "napi called\n");
 	} else {
 		dev_info(&pf->pdev->dev, "unknown command '%s'\n",
 			 i40e_dbg_netdev_ops_buf);
-- 
1.9.0
