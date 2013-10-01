From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 1/1] qlcnic: Fix SR-IOV configuration
Date: Tue, 1 Oct 2013 02:23:48 -0400
Message-ID: <1380608628-8391-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <rajesh.borundia@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:54710 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750871Ab3JAGxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 02:53:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Interface needs to be brought down and up while configuring SR-IOV.
  Protect interface up/down using rtnl_lock()/rtnl_unlock()

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 330d9a8..686f460 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -397,6 +397,7 @@ static int qlcnic_pci_sriov_disable(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
+	rtnl_lock();
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 
@@ -407,12 +408,15 @@ static int qlcnic_pci_sriov_disable(struct qlcnic_adapter *adapter)
 	/* After disabling SRIOV re-init the driver in default mode
 	   configure opmode based on op_mode of function
 	 */
-	if (qlcnic_83xx_configure_opmode(adapter))
+	if (qlcnic_83xx_configure_opmode(adapter)) {
+		rtnl_unlock();
 		return -EIO;
+	}
 
 	if (netif_running(netdev))
 		__qlcnic_up(adapter, netdev);
 
+	rtnl_unlock();
 	return 0;
 }
 
@@ -533,6 +537,7 @@ static int qlcnic_pci_sriov_enable(struct qlcnic_adapter *adapter, int num_vfs)
 		return -EIO;
 	}
 
+	rtnl_lock();
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
 
@@ -555,6 +560,7 @@ static int qlcnic_pci_sriov_enable(struct qlcnic_adapter *adapter, int num_vfs)
 		__qlcnic_up(adapter, netdev);
 
 error:
+	rtnl_unlock();
 	return err;
 }
 
-- 
1.8.1.4
