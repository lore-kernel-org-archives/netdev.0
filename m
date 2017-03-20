From: Colin King <colin.king@canonical.com>
Subject: [PATCH] i40evf: dereference vsi after vsi has been null checked
Date: Mon, 20 Mar 2017 12:03:03 +0000
Message-ID: <20170320120303.32284-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

vsi is being dereferenced before the vsi null check; if vsi is
null we end up with a null pointer dereference.  Fix this by
performing vsi deference after the vsi null check.  Also remove
the need for using adapter by using vsi->back->cinst.

Detected by CoverityScan, CID#1419696, CID#1419697
("Dereference before null check")

Fixes: ed0e894de7c133 ("i40evf: add client interface")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_client.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_client.c b/drivers/net/ethernet/intel/i40evf/i40evf_client.c
index 5b43e5b6e2eb..a579b2a5bd37 100644
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
2.11.0
