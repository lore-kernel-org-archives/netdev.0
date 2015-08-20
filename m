From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e: Fix ethtool offline diagnostic with netqueues
Date: Wed, 19 Aug 2015 17:57:57 -0700
Message-ID: <1440032286-30054-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25933 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751601AbbHTA6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:58:09 -0400
In-Reply-To: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Treat netqueues the same way we do virtual functions when someone wants to
run the ethtool offline diagnostic test.

Change-ID: Id48d2b933f1fd0db7be06305a93c6ebe3dc821f5
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index d6c7eb7..230d127 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1559,6 +1559,21 @@ static inline bool i40e_active_vfs(struct i40e_pf *pf)
 	return false;
 }
 
+static inline bool i40e_active_vmdqs(struct i40e_pf *pf)
+{
+	struct i40e_vsi **vsi = pf->vsi;
+	int i;
+
+	for (i = 0; i < pf->num_alloc_vsi; i++) {
+		if (!vsi[i])
+			continue;
+		if (vsi[i]->type == I40E_VSI_VMDQ2)
+			return true;
+	}
+
+	return false;
+}
+
 static void i40e_diag_test(struct net_device *netdev,
 			   struct ethtool_test *eth_test, u64 *data)
 {
@@ -1572,9 +1587,9 @@ static void i40e_diag_test(struct net_device *netdev,
 
 		set_bit(__I40E_TESTING, &pf->state);
 
-		if (i40e_active_vfs(pf)) {
+		if (i40e_active_vfs(pf) || i40e_active_vmdqs(pf)) {
 			dev_warn(&pf->pdev->dev,
-				 "Please take active VFS offline and restart the adapter before running NIC diagnostics\n");
+				 "Please take active VFs and Netqueues offline and restart the adapter before running NIC diagnostics\n");
 			data[I40E_ETH_TEST_REG]		= 1;
 			data[I40E_ETH_TEST_EEPROM]	= 1;
 			data[I40E_ETH_TEST_INTR]	= 1;
-- 
2.4.3
