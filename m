From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/15] i40e: use configured RSS key and lookup table in i40e_vsi_config_rss
Date: Fri, 19 Aug 2016 23:19:39 -0700
Message-ID: <1471673991-117115-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:37803 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751795AbcHTGTy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:54 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

A previous refactor added support to store user configuration for VSIs,
so that extra VSIs such as for VMDq can use this information when
configuring. Unfortunately the i40e_vsi_config_rss function was missed
in this refactor, and the values were being ignored. Fix this by
checking for the fields and using those instead of always using the
default values.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 2ed1e8b..4ec9565 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8076,13 +8076,26 @@ static int i40e_vsi_config_rss(struct i40e_vsi *vsi)
 	if (!(pf->flags & I40E_FLAG_RSS_AQ_CAPABLE))
 		return 0;
 
+	if (!vsi->rss_size)
+		vsi->rss_size = min_t(int, pf->alloc_rss_size,
+				      vsi->num_queue_pairs);
+	if (!vsi->rss_size)
+		return -EINVAL;
+
 	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
 	if (!lut)
 		return -ENOMEM;
-
-	i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
-	netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
-	vsi->rss_size = min_t(int, pf->alloc_rss_size, vsi->num_queue_pairs);
+	/* Use the user configured hash keys and lookup table if there is one,
+	 * otherwise use default
+	 */
+	if (vsi->rss_lut_user)
+		memcpy(lut, vsi->rss_lut_user, vsi->rss_table_size);
+	else
+		i40e_fill_rss_lut(pf, lut, vsi->rss_table_size, vsi->rss_size);
+	if (vsi->rss_hkey_user)
+		memcpy(seed, vsi->rss_hkey_user, I40E_HKEY_ARRAY_SIZE);
+	else
+		netdev_rss_key_fill((void *)seed, I40E_HKEY_ARRAY_SIZE);
 	ret = i40e_config_rss_aq(vsi, seed, lut, vsi->rss_table_size);
 	kfree(lut);
 
-- 
2.7.4
