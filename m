From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 1/5] qlcnic: Allow SR-IOV VF probe in hypervisor.
Date: Wed, 7 May 2014 13:39:34 -0400
Message-ID: <1399484378-22864-2-git-send-email-rajesh.borundia@qlogic.com>
References: <1399484378-22864-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:54160 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751533AbaEGSI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 14:08:28 -0400
In-Reply-To: <1399484378-22864-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Add support for SR-IOV VF probe in hypervisor to enable
  assignment of VFs within hypervisor.
o SR-IOV VF can be uplinked to bridge/macvtap device with this change.
o Refactor SR-IOV enable/disable code. We cannot take rtnl lock
  while enabling/disabling SR-IOV as VF probe will take an rtnl
  lock.
o Disable spoofchk by default.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    5 +--
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   |   34 +++++++++++++-------
 3 files changed, 24 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 7023d35..28ebe1b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2398,9 +2398,6 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	int err, pci_using_dac = -1;
 	char board_name[QLCNIC_MAX_BOARD_NAME_LEN + 19]; /* MAC + ": " + name */
 
-	if (pdev->is_virtfn)
-		return -ENODEV;
-
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
@@ -2680,9 +2677,9 @@ static void qlcnic_remove(struct pci_dev *pdev)
 		return;
 
 	netdev = adapter->netdev;
-	qlcnic_sriov_pf_disable(adapter);
 
 	qlcnic_cancel_idc_work(adapter);
+	qlcnic_sriov_pf_disable(adapter);
 	ahw = adapter->ahw;
 
 	unregister_netdev(netdev);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 0638c18..4eccc2b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -198,7 +198,7 @@ int qlcnic_sriov_init(struct qlcnic_adapter *adapter, int num_vfs)
 			}
 			sriov->vf_info[i].vp = vp;
 			vp->max_tx_bw = MAX_BW;
-			vp->spoofchk = true;
+			vp->spoofchk = false;
 			random_ether_addr(vp->mac);
 			dev_info(&adapter->pdev->dev,
 				 "MAC Address %pM is configured for VF %d\n",
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index c7926ce..df40908 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -472,12 +472,12 @@ static int qlcnic_pci_sriov_disable(struct qlcnic_adapter *adapter)
 		return -EPERM;
 	}
 
+	qlcnic_sriov_pf_disable(adapter);
+
 	rtnl_lock();
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 
-	qlcnic_sriov_pf_disable(adapter);
-
 	qlcnic_sriov_free_vlans(adapter);
 
 	qlcnic_sriov_pf_cleanup(adapter);
@@ -596,7 +596,6 @@ static int __qlcnic_pci_sriov_enable(struct qlcnic_adapter *adapter,
 
 	qlcnic_sriov_alloc_vlans(adapter);
 
-	err = qlcnic_sriov_pf_enable(adapter, num_vfs);
 	return err;
 
 del_flr_queue:
@@ -627,25 +626,36 @@ static int qlcnic_pci_sriov_enable(struct qlcnic_adapter *adapter, int num_vfs)
 		__qlcnic_down(adapter, netdev);
 
 	err = __qlcnic_pci_sriov_enable(adapter, num_vfs);
-	if (err) {
-		netdev_info(netdev, "Failed to enable SR-IOV on port %d\n",
-			    adapter->portnum);
+	if (err)
+		goto error;
 
-		err = -EIO;
-		if (qlcnic_83xx_configure_opmode(adapter))
-			goto error;
-	} else {
+	if (netif_running(netdev))
+		__qlcnic_up(adapter, netdev);
+
+	rtnl_unlock();
+	err = qlcnic_sriov_pf_enable(adapter, num_vfs);
+	if (!err) {
 		netdev_info(netdev,
 			    "SR-IOV is enabled successfully on port %d\n",
 			    adapter->portnum);
 		/* Return number of vfs enabled */
-		err = num_vfs;
+		return num_vfs;
 	}
+
+	rtnl_lock();
 	if (netif_running(netdev))
-		__qlcnic_up(adapter, netdev);
+		__qlcnic_down(adapter, netdev);
 
 error:
+	if (!qlcnic_83xx_configure_opmode(adapter)) {
+		if (netif_running(netdev))
+			__qlcnic_up(adapter, netdev);
+	}
+
 	rtnl_unlock();
+	netdev_info(netdev, "Failed to enable SR-IOV on port %d\n",
+		    adapter->portnum);
+
 	return err;
 }
 
-- 
1.6.3.3
