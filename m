From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/13] i40e: rework exit flow of i40e_add_fdir_ethtool
Date: Mon, 20 Mar 2017 16:47:04 -0700
Message-ID: <20170320234712.84157-6-jeffrey.t.kirsher@intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:49349 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755902AbdCTXrU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Mar 2017 19:47:20 -0400
In-Reply-To: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Refactor the exit flow of the i40e_add_fdir_ethtool function. Move the
input_label to the end of the function, removing the dependency on
having a non-zero return value. Add a comment explaining why it is ok
not to free the fdir data structure, because the structure is now stored
in the fdir_filter_list.

Change-Id: I723342181d59cd0c9f3b31140c37961ba37bb242
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7a22b473dbdd..d16a5a6b24fc 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -2828,12 +2828,19 @@ static int i40e_add_fdir_ethtool(struct i40e_vsi *vsi,
 	}
 
 	ret = i40e_add_del_fdir(vsi, input, true);
-free_input:
 	if (ret)
-		kfree(input);
-	else
-		i40e_update_ethtool_fdir_entry(vsi, input, fsp->location, NULL);
+		goto free_input;
+
+	/* Add the input filter to the fdir_input_list, possibly replacing
+	 * a previous filter. Do not free the input structure after adding it
+	 * to the list as this would cause a use-after-free bug.
+	 */
+	i40e_update_ethtool_fdir_entry(vsi, input, fsp->location, NULL);
 
+	return 0;
+
+free_input:
+	kfree(input);
 	return ret;
 }
 
-- 
2.12.0
