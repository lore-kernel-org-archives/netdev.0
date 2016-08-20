From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] i40e: Check client is open before calling client ops
Date: Fri, 19 Aug 2016 23:19:46 -0700
Message-ID: <1471673991-117115-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:6494 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752553AbcHTGT4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:56 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

We were having a race between the completion of the client open and
calls to the client ops so don't call a client op unless we are sure the
client is open.

Change-Id: I741f4f2aa4fcbfdad3e40dabbbb1b005856c396b
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 677dae5..1035f88 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -148,6 +148,11 @@ i40e_notify_client_of_vf_msg(struct i40e_vsi *vsi, u32 vf_id, u8 *msg, u16 len)
 					"Cannot locate client instance virtual channel receive routine\n");
 				continue;
 			}
+			if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED,
+				      &cdev->state)) {
+				dev_dbg(&vsi->back->pdev->dev, "Client is not open, abort virtchnl_receive\n");
+				continue;
+			}
 			cdev->client->ops->virtchnl_receive(&cdev->lan_info,
 							    cdev->client,
 							    vf_id, msg, len);
@@ -181,6 +186,11 @@ void i40e_notify_client_of_l2_param_changes(struct i40e_vsi *vsi)
 					"Cannot locate client instance l2_param_change routine\n");
 				continue;
 			}
+			if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED,
+				      &cdev->state)) {
+				dev_dbg(&vsi->back->pdev->dev, "Client is not open, abort l2 param change\n");
+				continue;
+			}
 			cdev->lan_info.params = params;
 			cdev->client->ops->l2_param_change(&cdev->lan_info,
 							   cdev->client,
@@ -298,6 +308,11 @@ void i40e_notify_client_of_vf_reset(struct i40e_pf *pf, u32 vf_id)
 					"Cannot locate client instance VF reset routine\n");
 				continue;
 			}
+			if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED,
+				      &cdev->state)) {
+				dev_dbg(&pf->pdev->dev, "Client is not open, abort vf-reset\n");
+				continue;
+			}
 			cdev->client->ops->vf_reset(&cdev->lan_info,
 						    cdev->client, vf_id);
 		}
@@ -328,6 +343,11 @@ void i40e_notify_client_of_vf_enable(struct i40e_pf *pf, u32 num_vfs)
 					"Cannot locate client instance VF enable routine\n");
 				continue;
 			}
+			if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED,
+				      &cdev->state)) {
+				dev_dbg(&pf->pdev->dev, "Client is not open, abort vf-enable\n");
+				continue;
+			}
 			cdev->client->ops->vf_enable(&cdev->lan_info,
 						     cdev->client, num_vfs);
 		}
@@ -362,6 +382,11 @@ int i40e_vf_client_capable(struct i40e_pf *pf, u32 vf_id,
 					"Cannot locate client instance VF capability routine\n");
 				continue;
 			}
+			if (!test_bit(__I40E_CLIENT_INSTANCE_OPENED,
+				      &cdev->state)) {
+				dev_dbg(&pf->pdev->dev, "Client is not open, abort vf-capable\n");
+				continue;
+			}
 			capable = cdev->client->ops->vf_capable(&cdev->lan_info,
 								cdev->client,
 								vf_id);
-- 
2.7.4
