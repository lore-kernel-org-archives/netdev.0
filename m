From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 02/14] i40e: fold the i40e_is_vsi_in_vlan check into i40e_put_mac_in_vlan
Date: Fri,  3 Feb 2017 18:56:33 -0800
Message-ID: <20170204025645.174793-3-jeffrey.t.kirsher@intel.com>
References: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64701 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753508AbdBDC4s (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 21:56:48 -0500
In-Reply-To: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Fold the check for determining when to call i40e_put_mac_in_vlan directly
into the function so that we don't need to decide which function to use
ahead of time. This allows us to just call i40e_put_mac_in_vlan directly
without having to check ahead of time.

Change-ID: Ifff526940748ac14b8418be5df5a149502eed137
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 11 ++++-------
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  8 ++------
 2 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 0b4adcc..7a11d2b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -1498,6 +1498,9 @@ struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
 		return i40e_add_filter(vsi, macaddr,
 				       le16_to_cpu(vsi->info.pvid));
 
+	if (!i40e_is_vsi_in_vlan(vsi))
+		return i40e_add_filter(vsi, macaddr, I40E_VLAN_ANY);
+
 	hash_for_each_safe(vsi->mac_filter_hash, bkt, h, f, hlist) {
 		if (f->state == I40E_FILTER_REMOVE)
 			continue;
@@ -1756,14 +1759,8 @@ static int i40e_addr_sync(struct net_device *netdev, const u8 *addr)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
-	struct i40e_mac_filter *f;
-
-	if (i40e_is_vsi_in_vlan(vsi))
-		f = i40e_put_mac_in_vlan(vsi, addr);
-	else
-		f = i40e_add_filter(vsi, addr, I40E_VLAN_ANY);
 
-	if (f)
+	if (i40e_put_mac_in_vlan(vsi, addr))
 		return 0;
 	else
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index a6198b7..0cdbdd3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1942,12 +1942,8 @@ static int i40e_vc_add_mac_addr_msg(struct i40e_vf *vf, u8 *msg, u16 msglen)
 		struct i40e_mac_filter *f;
 
 		f = i40e_find_mac(vsi, al->list[i].addr);
-		if (!f) {
-			if (i40e_is_vsi_in_vlan(vsi))
-				f = i40e_put_mac_in_vlan(vsi, al->list[i].addr);
-			else
-				f = i40e_add_filter(vsi, al->list[i].addr, -1);
-		}
+		if (!f)
+			f = i40e_put_mac_in_vlan(vsi, al->list[i].addr);
 
 		if (!f) {
 			dev_err(&pf->pdev->dev,
-- 
2.10.2
