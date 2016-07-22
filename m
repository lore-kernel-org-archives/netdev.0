From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] i40e: Move the mutex lock in i40e_client_unregister
Date: Fri, 22 Jul 2016 00:36:37 -0700
Message-ID: <1469172999-8969-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59075 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbcGVHgt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jul 2016 03:36:49 -0400
In-Reply-To: <1469172999-8969-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

We need to lock the client list around the i40e_client_release call to
prevent the release from interrupting the client instances while they are
being added.

Change-Id: I99993f20179aaf8730207833e7d0869d2ccffa1d
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 0e6ac84..e1370c5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -980,13 +980,13 @@ int i40e_unregister_client(struct i40e_client *client)
 	 * a close for each of the client instances that were opened.
 	 * client_release function is called to handle this.
 	 */
+	mutex_lock(&i40e_client_mutex);
 	if (!client || i40e_client_release(client)) {
 		ret = -EIO;
 		goto out;
 	}
 
 	/* TODO: check if device is in reset, or if that matters? */
-	mutex_lock(&i40e_client_mutex);
 	if (!i40e_client_is_registered(client)) {
 		pr_info("i40e: Client %s has not been registered\n",
 			client->name);
@@ -1005,8 +1005,8 @@ int i40e_unregister_client(struct i40e_client *client)
 		       client->name);
 	}
 
-	mutex_unlock(&i40e_client_mutex);
 out:
+	mutex_unlock(&i40e_client_mutex);
 	return ret;
 }
 EXPORT_SYMBOL(i40e_unregister_client);
-- 
2.5.5
