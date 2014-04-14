From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 6/6] qlcnic: Do not disable SR-IOV when VFs are assigned to VMs
Date: Mon, 14 Apr 2014 10:02:23 -0400
Message-ID: <1397484143-9708-7-git-send-email-shahed.shaikh@qlogic.com>
References: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:60930 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753294AbaDNOkF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:40:05 -0400
In-Reply-To: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o While disabling SR-IOV when VFs are assigned to VMs causes host crash
  so return -EPERM when user request to disable SR-IOV using pci sysfs in
  case of VFs are assigned to VMs.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 14f748c..2801379 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -461,6 +461,16 @@ static int qlcnic_pci_sriov_disable(struct qlcnic_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
+	if (pci_vfs_assigned(adapter->pdev)) {
+		netdev_err(adapter->netdev,
+			   "SR-IOV VFs belonging to port %d are assigned to VMs. SR-IOV can not be disabled on this port\n",
+			   adapter->portnum);
+		netdev_info(adapter->netdev,
+			    "Please detach SR-IOV VFs belonging to port %d from VMs, and then try to disable SR-IOV on this port\n",
+			    adapter->portnum);
+		return -EPERM;
+	}
+
 	rtnl_lock();
 	if (netif_running(netdev))
 		__qlcnic_down(adapter, netdev);
-- 
1.8.1.4
