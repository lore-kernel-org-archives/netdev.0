From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] i40e: abstract the close path for better netdev vsis
Date: Tue, 22 Apr 2014 05:39:26 -0700
Message-ID: <1398170371-3333-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:21423 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932544AbaDVMjl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:41 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Abstract out the vsi close actions into a single function so they
can be used correctly for both netdev and non-netdev based VSIs.

Change-ID: I59e3d115fcb20e614a09477281b7787dd340d276
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 31 +++++++++++++++--------------
 1 file changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7dda8b2..2210ab2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -3518,6 +3518,19 @@ static void i40e_napi_disable_all(struct i40e_vsi *vsi)
 }
 
 /**
+ * i40e_vsi_close - Shut down a VSI
+ * @vsi: the vsi to be quelled
+ **/
+static void i40e_vsi_close(struct i40e_vsi *vsi)
+{
+	if (!test_and_set_bit(__I40E_DOWN, &vsi->state))
+		i40e_down(vsi);
+	i40e_vsi_free_irq(vsi);
+	i40e_vsi_free_tx_resources(vsi);
+	i40e_vsi_free_rx_resources(vsi);
+}
+
+/**
  * i40e_quiesce_vsi - Pause a given VSI
  * @vsi: the VSI being paused
  **/
@@ -3530,8 +3543,7 @@ static void i40e_quiesce_vsi(struct i40e_vsi *vsi)
 	if (vsi->netdev && netif_running(vsi->netdev)) {
 		vsi->netdev->netdev_ops->ndo_stop(vsi->netdev);
 	} else {
-		set_bit(__I40E_DOWN, &vsi->state);
-		i40e_down(vsi);
+		i40e_vsi_close(vsi);
 	}
 }
 
@@ -4383,14 +4395,7 @@ static int i40e_close(struct net_device *netdev)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 
-	if (test_and_set_bit(__I40E_DOWN, &vsi->state))
-		return 0;
-
-	i40e_down(vsi);
-	i40e_vsi_free_irq(vsi);
-
-	i40e_vsi_free_tx_resources(vsi);
-	i40e_vsi_free_rx_resources(vsi);
+	i40e_vsi_close(vsi);
 
 	return 0;
 }
@@ -7075,11 +7080,7 @@ int i40e_vsi_release(struct i40e_vsi *vsi)
 				unregister_netdev(vsi->netdev);
 			}
 		} else {
-			if (!test_and_set_bit(__I40E_DOWN, &vsi->state))
-				i40e_down(vsi);
-			i40e_vsi_free_irq(vsi);
-			i40e_vsi_free_tx_resources(vsi);
-			i40e_vsi_free_rx_resources(vsi);
+			i40e_vsi_close(vsi);
 		}
 		i40e_vsi_disable_irq(vsi);
 	}
-- 
1.9.0
