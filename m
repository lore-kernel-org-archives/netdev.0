From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: fix setting user defined RSS hash key
Date: Tue, 20 Sep 2016 20:43:41 -0700
Message-ID: <1474429432-102772-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:43488 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754793AbcIUDn4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:56 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

Previously, when using ethtool to change the RSS hash key, ethtool would
report back saying the old key was still being used and no error was
reported.  It was unclear whether it was being reported incorrectly or
being set incorrectly.  Debugging revealed 'i40e_set_rxfh()' returned
zero immediately instead of setting the key because a user defined
indirection table is not supplied when changing the hash key.

This fix instead changes it such that if an indirection table is not
supplied, then a default one is created and the hash key is now
correctly set.

Change-ID: Iddb621897ecf208650272b7ee46702cad7b69a71
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h         |  2 ++
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 12 +++++++-----
 drivers/net/ethernet/intel/i40e/i40e_main.c    |  6 ++----
 3 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 6e211f2..f531f91 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -704,6 +704,8 @@ void i40e_do_reset_safe(struct i40e_pf *pf, u32 reset_flags);
 void i40e_do_reset(struct i40e_pf *pf, u32 reset_flags);
 int i40e_config_rss(struct i40e_vsi *vsi, u8 *seed, u8 *lut, u16 lut_size);
 int i40e_get_rss(struct i40e_vsi *vsi, u8 *seed, u8 *lut, u16 lut_size);
+void i40e_fill_rss_lut(struct i40e_pf *pf, u8 *lut,
+		       u16 rss_table_size, u16 rss_size);
 struct i40e_vsi *i40e_find_vsi_from_id(struct i40e_pf *pf, u16 id);
 void i40e_update_stats(struct i40e_vsi *vsi);
 void i40e_update_eth_stats(struct i40e_vsi *vsi);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 1f3bbb05..2b2b55e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2922,15 +2922,13 @@ static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
+	struct i40e_pf *pf = vsi->back;
 	u8 *seed = NULL;
 	u16 i;
 
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
-	if (!indir)
-		return 0;
-
 	if (key) {
 		if (!vsi->rss_hkey_user) {
 			vsi->rss_hkey_user = kzalloc(I40E_HKEY_ARRAY_SIZE,
@@ -2948,8 +2946,12 @@ static int i40e_set_rxfh(struct net_device *netdev, const u32 *indir,
 	}
 
 	/* Each 32 bits pointed by 'indir' is stored with a lut entry */
-	for (i = 0; i < I40E_HLUT_ARRAY_SIZE; i++)
-		vsi->rss_lut_user[i] = (u8)(indir[i]);
+	if (indir)
+		for (i = 0; i < I40E_HLUT_ARRAY_SIZE; i++)
+			vsi->rss_lut_user[i] = (u8)(indir[i]);
+	else
+		i40e_fill_rss_lut(pf, vsi->rss_lut_user, I40E_HLUT_ARRAY_SIZE,
+				  vsi->rss_size);
 
 	return i40e_config_rss(vsi, seed, vsi->rss_lut_user,
 			       I40E_HLUT_ARRAY_SIZE);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b3e9ce4..45b9c67 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -57,8 +57,6 @@ static int i40e_setup_pf_switch(struct i40e_pf *pf, bool reinit);
 static int i40e_setup_misc_vector(struct i40e_pf *pf);
 static void i40e_determine_queue_usage(struct i40e_pf *pf);
 static int i40e_setup_pf_filter_control(struct i40e_pf *pf);
-static void i40e_fill_rss_lut(struct i40e_pf *pf, u8 *lut,
-			      u16 rss_table_size, u16 rss_size);
 static void i40e_fdir_sb_setup(struct i40e_pf *pf);
 static int i40e_veb_get_bw_info(struct i40e_veb *veb);
 
@@ -8244,8 +8242,8 @@ int i40e_get_rss(struct i40e_vsi *vsi, u8 *seed, u8 *lut, u16 lut_size)
  * @rss_table_size: Lookup table size
  * @rss_size: Range of queue number for hashing
  */
-static void i40e_fill_rss_lut(struct i40e_pf *pf, u8 *lut,
-			      u16 rss_table_size, u16 rss_size)
+void i40e_fill_rss_lut(struct i40e_pf *pf, u8 *lut,
+		       u16 rss_table_size, u16 rss_size)
 {
 	u16 i;
 
-- 
2.7.4
