From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net] i40e: Change some init flow for the client
Date: Wed, 24 Aug 2016 17:51:53 -0700
Message-ID: <1472086313-121437-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:12466 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751713AbcHYE1l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 00:27:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

This change makes a common flow for Client instance open during init
and reset path. The Client subtask can handle both the cases instead of
making a separate notify_client_of_open call.
Also it may fix a bug during reset where the service task was leaking
some memory and causing issues.

Change-Id: I7232a32fd52b82e863abb54266fa83122f80a0cd
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 41 ++++++++++++++++++++-------
 drivers/net/ethernet/intel/i40e/i40e_main.c   |  1 -
 2 files changed, 30 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index e1370c5..618f184 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -199,6 +199,7 @@ void i40e_notify_client_of_l2_param_changes(struct i40e_vsi *vsi)
 void i40e_notify_client_of_netdev_open(struct i40e_vsi *vsi)
 {
 	struct i40e_client_instance *cdev;
+	int ret = 0;
 
 	if (!vsi)
 		return;
@@ -211,7 +212,14 @@ void i40e_notify_client_of_netdev_open(struct i40e_vsi *vsi)
 					"Cannot locate client instance open routine\n");
 				continue;
 			}
-			cdev->client->ops->open(&cdev->lan_info, cdev->client);
+			if (!(test_bit(__I40E_CLIENT_INSTANCE_OPENED,
+				       &cdev->state))) {
+				ret = cdev->client->ops->open(&cdev->lan_info,
+							      cdev->client);
+				if (!ret)
+					set_bit(__I40E_CLIENT_INSTANCE_OPENED,
+						&cdev->state);
+			}
 		}
 	}
 	mutex_unlock(&i40e_client_instance_mutex);
@@ -407,12 +415,14 @@ struct i40e_vsi *i40e_vsi_lookup(struct i40e_pf *pf,
  * i40e_client_add_instance - add a client instance struct to the instance list
  * @pf: pointer to the board struct
  * @client: pointer to a client struct in the client list.
+ * @existing: if there was already an existing instance
  *
- * Returns cdev ptr on success, NULL on failure
+ * Returns cdev ptr on success or if already exists, NULL on failure
  **/
 static
 struct i40e_client_instance *i40e_client_add_instance(struct i40e_pf *pf,
-						      struct i40e_client *client)
+						     struct i40e_client *client,
+						     bool *existing)
 {
 	struct i40e_client_instance *cdev;
 	struct netdev_hw_addr *mac = NULL;
@@ -421,7 +431,7 @@ struct i40e_client_instance *i40e_client_add_instance(struct i40e_pf *pf,
 	mutex_lock(&i40e_client_instance_mutex);
 	list_for_each_entry(cdev, &i40e_client_instances, list) {
 		if ((cdev->lan_info.pf == pf) && (cdev->client == client)) {
-			cdev = NULL;
+			*existing = true;
 			goto out;
 		}
 	}
@@ -505,6 +515,7 @@ void i40e_client_subtask(struct i40e_pf *pf)
 {
 	struct i40e_client_instance *cdev;
 	struct i40e_client *client;
+	bool existing = false;
 	int ret = 0;
 
 	if (!(pf->flags & I40E_FLAG_SERVICE_CLIENT_REQUESTED))
@@ -528,18 +539,25 @@ void i40e_client_subtask(struct i40e_pf *pf)
 			/* check if L2 VSI is up, if not we are not ready */
 			if (test_bit(__I40E_DOWN, &pf->vsi[pf->lan_vsi]->state))
 				continue;
+		} else {
+			dev_warn(&pf->pdev->dev, "This client %s is being instanciated at probe\n",
+				 client->name);
 		}
 
 		/* Add the client instance to the instance list */
-		cdev = i40e_client_add_instance(pf, client);
+		cdev = i40e_client_add_instance(pf, client, &existing);
 		if (!cdev)
 			continue;
 
-		/* Also up the ref_cnt of no. of instances of this client */
-		atomic_inc(&client->ref_cnt);
-		dev_info(&pf->pdev->dev, "Added instance of Client %s to PF%d bus=0x%02x func=0x%02x\n",
-			 client->name, pf->hw.pf_id,
-			 pf->hw.bus.device, pf->hw.bus.func);
+		if (!existing) {
+			/* Also up the ref_cnt for no. of instances of this
+			 * client.
+			 */
+			atomic_inc(&client->ref_cnt);
+			dev_info(&pf->pdev->dev, "Added instance of Client %s to PF%d bus=0x%02x func=0x%02x\n",
+				 client->name, pf->hw.pf_id,
+				 pf->hw.bus.device, pf->hw.bus.func);
+		}
 
 		/* Send an Open request to the client */
 		atomic_inc(&cdev->ref_cnt);
@@ -588,7 +606,8 @@ int i40e_lan_add_device(struct i40e_pf *pf)
 		 pf->hw.pf_id, pf->hw.bus.device, pf->hw.bus.func);
 
 	/* Since in some cases register may have happened before a device gets
-	 * added, we can schedule a subtask to go initiate the clients.
+	 * added, we can schedule a subtask to go initiate the clients if
+	 * they can be launched at probe time.
 	 */
 	pf->flags |= I40E_FLAG_SERVICE_CLIENT_REQUESTED;
 	i40e_service_event_schedule(pf);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c6ac7a6..828ed28 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5431,7 +5431,6 @@ int i40e_open(struct net_device *netdev)
 	wr32(&pf->hw, I40E_GLLAN_TSOMSK_L, be32_to_cpu(TCP_FLAG_CWR) >> 16);
 
 	udp_tunnel_get_rx_info(netdev);
-	i40e_notify_client_of_netdev_open(vsi);
 
 	return 0;
 }
-- 
2.7.4
