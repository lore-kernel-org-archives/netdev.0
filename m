From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next v2 1/9] qlcnic: Print informational messages only once during driver load.
Date: Fri, 11 Oct 2013 14:42:27 -0400
Message-ID: <8a3b95951fa6a48a8fa52975a567ead4c692a153.1381538863.git.himanshu.madhani@qlogic.com>
References: <cover.1381538863.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:9147 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752684Ab3JKTNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 15:13:00 -0400
In-Reply-To: <cover.1381538863.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  1 +
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    | 12 -----------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  | 25 ++++++++++++++++++----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  1 +
 4 files changed, 23 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 81bf836..a3c4379 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1199,6 +1199,7 @@ struct qlcnic_npar_info {
 	u8	promisc_mode;
 	u8	offload_flags;
 	u8      pci_func;
+	u8      mac[ETH_ALEN];
 };
 
 struct qlcnic_eswitch {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 3ca00e0..66e94dc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -2321,19 +2321,7 @@ int qlcnic_83xx_get_pci_info(struct qlcnic_adapter *adapter,
 			i++;
 			memcpy(pci_info->mac + sizeof(u32), &cmd.rsp.arg[i], 2);
 			i = i + 3;
-			if (ahw->op_mode == QLCNIC_MGMT_FUNC)
-				dev_info(dev, "id = %d active = %d type = %d\n"
-					 "\tport = %d min bw = %d max bw = %d\n"
-					 "\tmac_addr =  %pM\n", pci_info->id,
-					 pci_info->active, pci_info->type,
-					 pci_info->default_port,
-					 pci_info->tx_min_bw,
-					 pci_info->tx_max_bw, pci_info->mac);
 		}
-		if (ahw->op_mode == QLCNIC_MGMT_FUNC)
-			dev_info(dev, "Max functions = %d, active functions = %d\n",
-				 ahw->max_pci_func, ahw->act_pci_func);
-
 	} else {
 		dev_err(dev, "Failed to get PCI Info, error = %d\n", err);
 		err = -EIO;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index 0248a4c..63cdddf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -94,13 +94,30 @@ qlcnic_83xx_config_vnic_buff_descriptors(struct qlcnic_adapter *adapter)
  **/
 static int qlcnic_83xx_init_mgmt_vnic(struct qlcnic_adapter *adapter)
 {
-	int err = -EIO;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	struct device *dev = &adapter->pdev->dev;
+	struct qlcnic_npar_info *npar;
+	int i, err = -EIO;
 
 	qlcnic_83xx_get_minidump_template(adapter);
+
 	if (!(adapter->flags & QLCNIC_ADAPTER_INITIALIZED)) {
 		if (qlcnic_init_pci_info(adapter))
 			return err;
 
+		npar = adapter->npars;
+
+		for (i = 0; i < ahw->act_pci_func; i++, npar++) {
+			dev_info(dev, "id = %d active = %d type = %d\n"
+				 "\tport = %d min bw = %d max bw = %d\n"
+				 "\tmac_addr =  %pM\n", npar->pci_func,
+				 npar->active, npar->type, npar->phy_port,
+				 npar->min_bw, npar->max_bw, npar->mac);
+		}
+
+		dev_info(dev, "Max functions = %d, active functions = %d\n",
+			 ahw->max_pci_func, ahw->act_pci_func);
+
 		if (qlcnic_83xx_set_vnic_opmode(adapter))
 			return err;
 
@@ -115,12 +132,12 @@ static int qlcnic_83xx_init_mgmt_vnic(struct qlcnic_adapter *adapter)
 		return err;
 
 	qlcnic_83xx_config_vnic_buff_descriptors(adapter);
-	adapter->ahw->msix_supported = !!qlcnic_use_msi_x;
+	ahw->msix_supported = qlcnic_use_msi_x ? 1 : 0;
 	adapter->flags |= QLCNIC_ADAPTER_INITIALIZED;
 	qlcnic_83xx_enable_vnic_mode(adapter, 1);
 
-	dev_info(&adapter->pdev->dev, "HAL Version: %d, Management function\n",
-		 adapter->ahw->fw_hal_version);
+	dev_info(dev, "HAL Version: %d, Management function\n",
+		 ahw->fw_hal_version);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index f07f2b0..55e8b23 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -875,6 +875,7 @@ int qlcnic_init_pci_info(struct qlcnic_adapter *adapter)
 		adapter->npars[j].min_bw = pci_info[i].tx_min_bw;
 		adapter->npars[j].max_bw = pci_info[i].tx_max_bw;
 
+		memcpy(&adapter->npars[j].mac, &pci_info[i].mac, ETH_ALEN);
 		j++;
 	}
 
-- 
1.8.1.4
