From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 5/6] qlcnic: Fix QLogic application/driver interface for virtual NIC configuration
Date: Mon, 14 Apr 2014 10:02:22 -0400
Message-ID: <1397484143-9708-6-git-send-email-shahed.shaikh@qlogic.com>
References: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:58065 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754234AbaDNOkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:40:03 -0400
In-Reply-To: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Application expect vNIC number as the array index but driver interface
return configuration in array index form.

o Pack the vNIC information array in the buffer such that application can
access it using vNIC number as the array index.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 31 +++++++++++++----------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 448d156..cd346e2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -354,7 +354,7 @@ int qlcnic_is_valid_nic_func(struct qlcnic_adapter *adapter, u8 pci_func)
 {
 	int i;
 
-	for (i = 0; i < adapter->ahw->max_vnic_func; i++) {
+	for (i = 0; i < adapter->ahw->total_nic_func; i++) {
 		if (adapter->npars[i].pci_func == pci_func)
 			return i;
 	}
@@ -720,6 +720,7 @@ static ssize_t qlcnic_sysfs_read_npar_config(struct file *file,
 	struct qlcnic_adapter *adapter = dev_get_drvdata(dev);
 	struct qlcnic_npar_func_cfg *np_cfg;
 	struct qlcnic_info nic_info;
+	u8 pci_func;
 	int i, ret;
 	u32 count;
 
@@ -729,26 +730,28 @@ static ssize_t qlcnic_sysfs_read_npar_config(struct file *file,
 
 	count = size / sizeof(struct qlcnic_npar_func_cfg);
 	for (i = 0; i < adapter->ahw->total_nic_func; i++) {
-		if (qlcnic_is_valid_nic_func(adapter, i) < 0)
-			continue;
 		if (adapter->npars[i].pci_func >= count) {
 			dev_dbg(dev, "%s: Total nic functions[%d], App sent function count[%d]\n",
 				__func__, adapter->ahw->total_nic_func, count);
 			continue;
 		}
-		ret = qlcnic_get_nic_info(adapter, &nic_info, i);
-		if (ret)
-			return ret;
 		if (!adapter->npars[i].eswitch_status)
 			continue;
-		np_cfg[i].pci_func = i;
-		np_cfg[i].op_mode = (u8)nic_info.op_mode;
-		np_cfg[i].port_num = nic_info.phys_port;
-		np_cfg[i].fw_capab = nic_info.capabilities;
-		np_cfg[i].min_bw = nic_info.min_tx_bw;
-		np_cfg[i].max_bw = nic_info.max_tx_bw;
-		np_cfg[i].max_tx_queues = nic_info.max_tx_ques;
-		np_cfg[i].max_rx_queues = nic_info.max_rx_ques;
+		pci_func = adapter->npars[i].pci_func;
+		if (qlcnic_is_valid_nic_func(adapter, pci_func) < 0)
+			continue;
+		ret = qlcnic_get_nic_info(adapter, &nic_info, pci_func);
+		if (ret)
+			return ret;
+
+		np_cfg[pci_func].pci_func = pci_func;
+		np_cfg[pci_func].op_mode = (u8)nic_info.op_mode;
+		np_cfg[pci_func].port_num = nic_info.phys_port;
+		np_cfg[pci_func].fw_capab = nic_info.capabilities;
+		np_cfg[pci_func].min_bw = nic_info.min_tx_bw;
+		np_cfg[pci_func].max_bw = nic_info.max_tx_bw;
+		np_cfg[pci_func].max_tx_queues = nic_info.max_tx_ques;
+		np_cfg[pci_func].max_rx_queues = nic_info.max_rx_ques;
 	}
 	return size;
 }
-- 
1.8.1.4
