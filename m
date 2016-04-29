From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] i40e: fix misleading indentation
Date: Fri, 29 Apr 2016 19:44:05 +0200
Message-ID: <1461951855-2038011-1-git-send-email-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Newly added code in i40e_vc_config_promiscuous_mode_msg() is indented
in a way that gcc rightly complains about:

drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c: In function 'i40e_vc_config_promiscuous_mode_msg':
drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c:1543:4: error: this 'if' clause does not guard... [-Werror=misleading-indentation]
    if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
    ^~
drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c:1550:5: note: ...this statement, but the latter is misleadingly indented as if it is guarded by the 'if'
     aq_err = pf->hw.aq.asq_last_status;

>From the context, it looks like the aq_err assignment was meant to be
inside of the conditional expression, so I'm adding the appropriate
curly braces now.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: 5676a8b9cd9a ("i40e: Add VF promiscuous mode driver support")
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index c226c2dad247..30f9cc404707 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1540,7 +1540,7 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 	} else if (i40e_getnum_vf_vsi_vlan_filters(vsi)) {
 		list_for_each_entry(f, &vsi->mac_filter_list, list) {
 			aq_ret = 0;
-			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID)
+			if (f->vlan >= 0 && f->vlan <= I40E_MAX_VLANID) {
 				aq_ret =
 				i40e_aq_set_vsi_uc_promisc_on_vlan(hw,
 								   vsi->seid,
@@ -1548,6 +1548,7 @@ static int i40e_vc_config_promiscuous_mode_msg(struct i40e_vf *vf,
 								   f->vlan,
 								   NULL);
 				aq_err = pf->hw.aq.asq_last_status;
+			}
 			if (aq_ret)
 				dev_err(&pf->pdev->dev,
 					"Could not add VLAN %d to Unicast promiscuous domain err %s aq_err %s\n",
-- 
2.7.0
