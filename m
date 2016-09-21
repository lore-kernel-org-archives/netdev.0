From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] i40e: fix "dump port" command when NPAR enabled
Date: Tue, 20 Sep 2016 20:43:42 -0700
Message-ID: <1474429432-102772-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alan Brady <alan.brady@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:8873 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754814AbcIUDn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 23:43:57 -0400
In-Reply-To: <1474429432-102772-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Brady <alan.brady@intel.com>

When using the debugfs to issue the "dump port" command
with NPAR enabled, the firmware reports back with invalid argument.

The issue occurs because the pf->mac_seid was used to perform the query.
This is fine when NPAR is disabled because the switch ID == pf->mac_seid,
however this is not the case when NPAR is enabled.  This fix instead
goes through the VSI to determine the correct ID to use in either case.

Change-ID: I0cd67913a7f2c4a2962e06d39e32e7447cc55b6a
Signed-off-by: Alan Brady <alan.brady@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 05cf9a7..8555f04 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1054,6 +1054,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			struct i40e_dcbx_config *r_cfg =
 						&pf->hw.remote_dcbx_config;
 			int i, ret;
+			u32 switch_id;
 
 			bw_data = kzalloc(sizeof(
 				    struct i40e_aqc_query_port_ets_config_resp),
@@ -1063,8 +1064,12 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				goto command_write_done;
 			}
 
+			vsi = pf->vsi[pf->lan_vsi];
+			switch_id =
+				vsi->info.switch_id & I40E_AQ_VSI_SW_ID_MASK;
+
 			ret = i40e_aq_query_port_ets_config(&pf->hw,
-							    pf->mac_seid,
+							    switch_id,
 							    bw_data, NULL);
 			if (ret) {
 				dev_info(&pf->pdev->dev,
-- 
2.7.4
