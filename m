From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH] i40e: limit client interface to X722 hardware
Date: Tue,  4 Apr 2017 16:34:46 +0200
Message-ID: <20170404143446.16359-1-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40576 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752129AbdDDOfC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 10:35:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The client interface is meant for X722 iWARP support. Modprobing i40iw
on systems with X710/XL710 NICs currently may crash the system. Adding a
check which limits client interface access to the appropriate hardware.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/i40e/i40e_client.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_client.c b/drivers/net/ethernet/intel/i40e/i40e_client.c
index 191028b..6f873449 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_client.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_client.c
@@ -525,15 +525,17 @@ static void i40e_client_release(struct i40e_client *client)
 static void i40e_client_prepare(struct i40e_client *client)
 {
 	struct i40e_device *ldev;
-	struct i40e_pf *pf;
 
 	mutex_lock(&i40e_device_mutex);
 	list_for_each_entry(ldev, &i40e_devices, list) {
-		pf = ldev->pf;
-		i40e_client_add_instance(pf);
-		/* Start the client subtask */
-		pf->flags |= I40E_FLAG_SERVICE_CLIENT_REQUESTED;
-		i40e_service_event_schedule(pf);
+		struct i40e_pf *pf = ldev->pf;
+
+		if (pf->hw.mac.type == I40E_MAC_X722) {
+			i40e_client_add_instance(pf);
+			/* Start the client subtask */
+			pf->flags |= I40E_FLAG_SERVICE_CLIENT_REQUESTED;
+			i40e_service_event_schedule(pf);
+		}
 	}
 	mutex_unlock(&i40e_device_mutex);
 }
-- 
2.9.3
