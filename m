From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/17] i40e: Fix client interaction
Date: Sat, 29 Oct 2016 00:30:42 -0700
Message-ID: <1477726258-111563-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:10260 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751233AbcJ2HbG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:06 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes a problem in the client interface that
was causing random stack traces in RDMA driver load and
unload tests.  This patch fixes the problem by checking
for an existing client before trying to open it.  Without
this patch, there is a timing related null pointer deref.

Change-ID: Ib73d30671a27f6f9770dd53b3e5292b88d6b62da
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 29 ++++++++++++---------------
 1 file changed, 13 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 250db0b..6ffac03 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -565,7 +565,7 @@ void i40e_client_subtask(struct i40e_pf *pf)
 			if (test_bit(__I40E_DOWN, &pf->vsi[pf->lan_vsi]->state))
 				continue;
 		} else {
-			dev_warn(&pf->pdev->dev, "This client %s is being instanciated at probe\n",
+			dev_warn(&pf->pdev->dev, "This client %s is being instantiated at probe\n",
 				 client->name);
 		}
 
@@ -582,24 +582,21 @@ void i40e_client_subtask(struct i40e_pf *pf)
 			dev_info(&pf->pdev->dev, "Added instance of Client %s to PF%d bus=0x%02x func=0x%02x\n",
 				 client->name, pf->hw.pf_id,
 				 pf->hw.bus.device, pf->hw.bus.func);
-		}
-
-		mutex_lock(&i40e_client_instance_mutex);
-		/* Send an Open request to the client */
-		atomic_inc(&cdev->ref_cnt);
-		if (client->ops && client->ops->open)
-			ret = client->ops->open(&cdev->lan_info, client);
-		atomic_dec(&cdev->ref_cnt);
-		if (!ret) {
+			mutex_lock(&i40e_client_instance_mutex);
+			atomic_inc(&cdev->ref_cnt);
+			if (client->ops && client->ops->open)
+				ret = client->ops->open(&cdev->lan_info,
+							client);
+			atomic_dec(&cdev->ref_cnt);
+			if (ret < 0) {
+				mutex_unlock(&i40e_client_instance_mutex);
+				i40e_client_del_instance(pf, client);
+				atomic_dec(&client->ref_cnt);
+				continue;
+			}
 			set_bit(__I40E_CLIENT_INSTANCE_OPENED, &cdev->state);
-		} else {
-			/* remove client instance */
 			mutex_unlock(&i40e_client_instance_mutex);
-			i40e_client_del_instance(pf, client);
-			atomic_dec(&client->ref_cnt);
-			continue;
 		}
-		mutex_unlock(&i40e_client_instance_mutex);
 	}
 	mutex_unlock(&i40e_client_mutex);
 }
-- 
2.7.4
