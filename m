From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] i40e: Fix a bug where a client close can be called before an open is complete
Date: Thu, 18 Aug 2016 14:57:23 -0700
Message-ID: <1471557456-136741-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:52025 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754607AbcHSB3u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 Aug 2016 21:29:50 -0400
In-Reply-To: <1471557456-136741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The client->open call in this path was not protected with the
client instance mutex, and hence the client->close can get initiated
before the open completes.

Change-Id: I0ed60c38868dd3f44966b6ed49a063d0e5b7edf5
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index e6b9263..8726269 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -541,6 +541,7 @@ void i40e_client_subtask(struct i40e_pf *pf)
 			 client->name, pf->hw.pf_id,
 			 pf->hw.bus.device, pf->hw.bus.func);
 
+		mutex_lock(&i40e_client_instance_mutex);
 		/* Send an Open request to the client */
 		atomic_inc(&cdev->ref_cnt);
 		if (client->ops && client->ops->open)
@@ -554,6 +555,7 @@ void i40e_client_subtask(struct i40e_pf *pf)
 			atomic_dec(&client->ref_cnt);
 			continue;
 		}
+		mutex_unlock(&i40e_client_instance_mutex);
 	}
 	mutex_unlock(&i40e_client_mutex);
 }
-- 
2.7.4
