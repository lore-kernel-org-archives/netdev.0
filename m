From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: fix up VXLAN messages
Date: Fri,  3 Apr 2015 05:04:53 -0700
Message-ID: <1428062698-16180-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:18470 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752456AbbDCMFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:35 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When the VXLAN ports are added and removed, the messaging was giving some
bogus index info, the port was always '0' for the delete, and the message
text style didn't match other messages in the driver.  Also, there was an
over-use of the tertiary statement which made reading a little harder
than necessary.

Change-ID: Ie805182a697b8b4c12024403ada87fd4e4fa2358
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 38 ++++++++++++++---------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 9e19933..15cee4d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6608,7 +6608,6 @@ static void i40e_sync_vxlan_filters_subtask(struct i40e_pf *pf)
 {
 	struct i40e_hw *hw = &pf->hw;
 	i40e_status ret;
-	u8 filter_index;
 	__be16 port;
 	int i;
 
@@ -6621,22 +6620,20 @@ static void i40e_sync_vxlan_filters_subtask(struct i40e_pf *pf)
 		if (pf->pending_vxlan_bitmap & (1 << i)) {
 			pf->pending_vxlan_bitmap &= ~(1 << i);
 			port = pf->vxlan_ports[i];
-			ret = port ?
-			      i40e_aq_add_udp_tunnel(hw, ntohs(port),
+			if (port)
+				ret = i40e_aq_add_udp_tunnel(hw, ntohs(port),
 						     I40E_AQC_TUNNEL_TYPE_VXLAN,
-						     &filter_index, NULL)
-			      : i40e_aq_del_udp_tunnel(hw, i, NULL);
+						     NULL, NULL);
+			else
+				ret = i40e_aq_del_udp_tunnel(hw, i, NULL);
 
 			if (ret) {
-				dev_info(&pf->pdev->dev, "Failed to execute AQ command for %s port %d with index %d\n",
-					 port ? "adding" : "deleting",
-					 ntohs(port), port ? i : i);
-
+				dev_info(&pf->pdev->dev,
+					 "%s vxlan port %d, index %d failed, err %d, aq_err %d\n",
+					 port ? "add" : "delete",
+					 ntohs(port), i, ret,
+					 pf->hw.aq.asq_last_status);
 				pf->vxlan_ports[i] = 0;
-			} else {
-				dev_info(&pf->pdev->dev, "%s port %d with AQ command with index %d\n",
-					 port ? "Added" : "Deleted",
-					 ntohs(port), port ? i : filter_index);
 			}
 		}
 	}
@@ -7829,7 +7826,8 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 
 	/* Check if port already exists */
 	if (idx < I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "Port %d already offloaded\n", ntohs(port));
+		netdev_info(netdev, "vxlan port %d already offloaded\n",
+			    ntohs(port));
 		return;
 	}
 
@@ -7837,7 +7835,7 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	next_idx = i40e_get_vxlan_port_idx(pf, 0);
 
 	if (next_idx == I40E_MAX_PF_UDP_OFFLOAD_PORTS) {
-		netdev_info(netdev, "Maximum number of UDP ports reached, not adding port %d\n",
+		netdev_info(netdev, "maximum number of vxlan UDP ports reached, not adding port %d\n",
 			    ntohs(port));
 		return;
 	}
@@ -7845,8 +7843,9 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	/* New port: add it and mark its index in the bitmap */
 	pf->vxlan_ports[next_idx] = port;
 	pf->pending_vxlan_bitmap |= (1 << next_idx);
-
 	pf->flags |= I40E_FLAG_VXLAN_FILTER_SYNC;
+
+	dev_info(&pf->pdev->dev, "adding vxlan port %d\n", ntohs(port));
 }
 
 /**
@@ -7874,12 +7873,13 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 		 * and make it pending
 		 */
 		pf->vxlan_ports[idx] = 0;
-
 		pf->pending_vxlan_bitmap |= (1 << idx);
-
 		pf->flags |= I40E_FLAG_VXLAN_FILTER_SYNC;
+
+		dev_info(&pf->pdev->dev, "deleting vxlan port %d\n",
+			 ntohs(port));
 	} else {
-		netdev_warn(netdev, "Port %d was not found, not deleting\n",
+		netdev_warn(netdev, "vxlan port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
 }
-- 
1.9.3
