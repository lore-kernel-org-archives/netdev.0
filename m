From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] i40evf: dereference VSI after VSI has been null checked
Date: Sat, 25 Mar 2017 01:13:04 -0700
Message-ID: <20170325081305.31835-11-jeffrey.t.kirsher@intel.com>
References: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Cc: Colin Ian King <colin.king@canonical.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:23525 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751132AbdCYINL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 25 Mar 2017 04:13:11 -0400
In-Reply-To: <20170325081305.31835-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

VSI is being dereferenced before the VSI null check; if VSI is
null we end up with a null pointer dereference.  Fix this by
performing VSI deference after the VSI null check.  Also remove
the need for using adapter by using vsi->back->cinst.

Detected by CoverityScan, CID#1419696, CID#1419697
("Dereference before null check")

Fixes: ed0e894de7c133 ("i40evf: add client interface")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_client.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_client.c b/drivers/net/ethernet/intel/i40evf/i40evf_client.c
index 5b43e5b6e2eb..ee737680a0e9 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_client.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_client.c
@@ -34,12 +34,12 @@ static struct i40e_ops i40evf_lan_ops = {
  **/
 void i40evf_notify_client_message(struct i40e_vsi *vsi, u8 *msg, u16 len)
 {
-	struct i40evf_adapter *adapter = vsi->back;
-	struct i40e_client_instance *cinst = adapter->cinst;
+	struct i40e_client_instance *cinst;
 
 	if (!vsi)
 		return;
 
+	cinst = vsi->back->cinst;
 	if (!cinst || !cinst->client || !cinst->client->ops ||
 	    !cinst->client->ops->virtchnl_receive) {
 		dev_dbg(&vsi->back->pdev->dev,
@@ -58,12 +58,13 @@ void i40evf_notify_client_message(struct i40e_vsi *vsi, u8 *msg, u16 len)
  **/
 void i40evf_notify_client_l2_params(struct i40e_vsi *vsi)
 {
-	struct i40evf_adapter *adapter = vsi->back;
-	struct i40e_client_instance *cinst = adapter->cinst;
+	struct i40e_client_instance *cinst;
 	struct i40e_params params;
 
 	if (!vsi)
 		return;
+
+	cinst = vsi->back->cinst;
 	memset(&params, 0, sizeof(params));
 	params.mtu = vsi->netdev->mtu;
 	params.link_up = vsi->back->link_up;
-- 
2.12.0
