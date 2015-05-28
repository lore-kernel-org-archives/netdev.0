From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] i40e: Disable offline diagnostics if VFs are enabled
Date: Thu, 28 May 2015 04:25:29 -0700
Message-ID: <1432812339-17129-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:11036 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753973AbbE1LZn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 07:25:43 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Require the user to disable virtual functions before running the device
offline diagnostics.  The offline diagnostics are intended to ensure
basic operation of the device - it is beyond the scope of the diagnostic
test to handle the additional complexity of bringing all the virtual
functions offline and then back online for each test run.

Change-ID: Ic0b854851a09fc85df0c9e82c220e45885457c30
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c     | 27 ++++++++++++++++++++++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  7 ++++++
 2 files changed, 34 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 4cbaaeb..e77b6bd 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1548,6 +1548,17 @@ static int i40e_loopback_test(struct net_device *netdev, u64 *data)
 	return *data;
 }
 
+static inline bool i40e_active_vfs(struct i40e_pf *pf)
+{
+	struct i40e_vf *vfs = pf->vf;
+	int i;
+
+	for (i = 0; i < pf->num_alloc_vfs; i++)
+		if (vfs[i].vf_states & I40E_VF_STAT_ACTIVE)
+			return true;
+	return false;
+}
+
 static void i40e_diag_test(struct net_device *netdev,
 			   struct ethtool_test *eth_test, u64 *data)
 {
@@ -1560,6 +1571,20 @@ static void i40e_diag_test(struct net_device *netdev,
 		netif_info(pf, drv, netdev, "offline testing starting\n");
 
 		set_bit(__I40E_TESTING, &pf->state);
+
+		if (i40e_active_vfs(pf)) {
+			dev_warn(&pf->pdev->dev,
+				 "Please take active VFS offline and restart the adapter before running NIC diagnostics\n");
+			data[I40E_ETH_TEST_REG]		= 1;
+			data[I40E_ETH_TEST_EEPROM]	= 1;
+			data[I40E_ETH_TEST_INTR]	= 1;
+			data[I40E_ETH_TEST_LOOPBACK]	= 1;
+			data[I40E_ETH_TEST_LINK]	= 1;
+			eth_test->flags |= ETH_TEST_FL_FAILED;
+			clear_bit(__I40E_TESTING, &pf->state);
+			goto skip_ol_tests;
+		}
+
 		/* If the device is online then take it offline */
 		if (if_running)
 			/* indicate we're in test mode */
@@ -1605,6 +1630,8 @@ static void i40e_diag_test(struct net_device *netdev,
 		data[I40E_ETH_TEST_LOOPBACK] = 0;
 	}
 
+skip_ol_tests:
+
 	netif_info(pf, drv, netdev, "testing finished\n");
 }
 
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 78d1c4f..4653b6e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -980,6 +980,13 @@ static int i40e_pci_sriov_enable(struct pci_dev *pdev, int num_vfs)
 	int pre_existing_vfs = pci_num_vf(pdev);
 	int err = 0;
 
+	if (pf->state & __I40E_TESTING) {
+		dev_warn(&pdev->dev,
+			 "Cannot enable SR-IOV virtual functions while the device is undergoing diagnostic testing\n");
+		err = -EPERM;
+		goto err_out;
+	}
+
 	dev_info(&pdev->dev, "Allocating %d VFs.\n", num_vfs);
 	if (pre_existing_vfs && pre_existing_vfs != num_vfs)
 		i40e_free_vfs(pf);
-- 
2.1.0
