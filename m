From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 20/20] i40e: don't allow i40e_vsi_(add|kill)_vlan to operate when VID<1
Date: Tue,  6 Dec 2016 23:33:54 -0800
Message-ID: <20161207073354.88568-21-jeffrey.t.kirsher@intel.com>
References: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34826 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753185AbcLGHew (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 02:34:52 -0500
In-Reply-To: <20161207073354.88568-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Now that we have the separate i40e_(add|rm)_vlan_all_mac functions, we
should not be using the i40e_vsi_kill_vlan or i40e_vsi_add_vlan
functions when PVID is set or when VID is less than 1. This allows us to
remove some checks in i40e_vsi_add_vlan and ensures that callers which
need to handle VID=0 or VID=-1 don't accidentally invoke the VLAN mode
handling used to convert filters when entering VLAN mode. We also update
the functions to take u16 instead of s16 as well since they no longer
expect to be called with VID=I40E_VLAN_ANY.

Change-ID: Ibddf44a8bb840dde8ceef2a4fdb92fd953b05a57
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++----
 2 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ba8d309..7f208f4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -853,9 +853,9 @@ int i40e_close(struct net_device *netdev);
 int i40e_vsi_open(struct i40e_vsi *vsi);
 void i40e_vlan_stripping_disable(struct i40e_vsi *vsi);
 int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid);
-int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid);
+int i40e_vsi_add_vlan(struct i40e_vsi *vsi, u16 vid);
 void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid);
-void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid);
+void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, u16 vid);
 struct i40e_mac_filter *i40e_put_mac_in_vlan(struct i40e_vsi *vsi,
 					     const u8 *macaddr);
 int i40e_del_mac_all_vlan(struct i40e_vsi *vsi, const u8 *macaddr);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index da4cbe3..148a678 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -2575,12 +2575,15 @@ int i40e_add_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
 /**
  * i40e_vsi_add_vlan - Add VSI membership for given VLAN
  * @vsi: the VSI being configured
- * @vid: VLAN id to be added (0 = untagged only , -1 = any)
+ * @vid: VLAN id to be added
  **/
-int i40e_vsi_add_vlan(struct i40e_vsi *vsi, s16 vid)
+int i40e_vsi_add_vlan(struct i40e_vsi *vsi, u16 vid)
 {
 	int err;
 
+	if (!(vid > 0) || vsi->info.pvid)
+		return -EINVAL;
+
 	/* Locked once because all functions invoked below iterates list*/
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
 	err = i40e_add_vlan_all_mac(vsi, vid);
@@ -2623,10 +2626,13 @@ void i40e_rm_vlan_all_mac(struct i40e_vsi *vsi, s16 vid)
 /**
  * i40e_vsi_kill_vlan - Remove VSI membership for given VLAN
  * @vsi: the VSI being configured
- * @vid: VLAN id to be removed (0 = untagged only , -1 = any)
+ * @vid: VLAN id to be removed
  **/
-void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, s16 vid)
+void i40e_vsi_kill_vlan(struct i40e_vsi *vsi, u16 vid)
 {
+	if (!(vid > 0) || vsi->info.pvid)
+		return;
+
 	spin_lock_bh(&vsi->mac_filter_hash_lock);
 	i40e_rm_vlan_all_mac(vsi, vid);
 	spin_unlock_bh(&vsi->mac_filter_hash_lock);
-- 
2.9.3
