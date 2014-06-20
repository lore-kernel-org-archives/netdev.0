From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/13] i40e: workaround NVM GLQF_HKEY
Date: Fri, 20 Jun 2014 00:49:37 -0700
Message-ID: <1403250588-14356-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:62062 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbaFTHty (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Jun 2014 03:49:54 -0400
In-Reply-To: <1403250588-14356-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The NVM wasn't filling in the GLQF_HKEY register on
some old NVM versions.  If this is the case, fill
in some values so receive with flow rules works right.

Change-ID: Ic737888ee68f96efb4cf8a1a49d2301615e09ed2
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 374f36b..95c331a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5463,6 +5463,20 @@ static void i40e_fdir_sb_setup(struct i40e_pf *pf)
 	struct i40e_vsi *vsi;
 	int i;
 
+	/* quick workaround for an NVM issue that leaves a critical register
+	 * uninitialized
+	 */
+	if (!rd32(&pf->hw, I40E_GLQF_HKEY(0))) {
+		static const u32 hkey[] = {
+			0xe640d33f, 0xcdfe98ab, 0x73fa7161, 0x0d7a7d36,
+			0xeacb7d61, 0xaa4f05b6, 0x9c5c89ed, 0xfc425ddb,
+			0xa4654832, 0xfc7461d4, 0x8f827619, 0xf5c63c21,
+			0x95b3a76d};
+
+		for (i = 0; i <= I40E_GLQF_HKEY_MAX_INDEX; i++)
+			wr32(&pf->hw, I40E_GLQF_HKEY(i), hkey[i]);
+	}
+
 	if (!(pf->flags & I40E_FLAG_FD_SB_ENABLED))
 		return;
 
-- 
1.9.3
