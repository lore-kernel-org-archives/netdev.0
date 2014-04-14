From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 3/6] qlcnic: Fix max ring count calculation
Date: Mon, 14 Apr 2014 10:02:20 -0400
Message-ID: <1397484143-9708-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:15830 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753294AbaDNOj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:39:59 -0400
In-Reply-To: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Do not read max rings count from qlcnic_get_nic_info(). Use driver defined
values for 82xx adapters. In case of 83xx adapters, use minimum of firmware
provided and driver defined values.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 14 ++++++++------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c       |  2 --
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 3ca3118..ba20c72 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2139,8 +2139,6 @@ static int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *adapter)
 	ahw->max_mac_filters = nic_info.max_mac_filters;
 	ahw->max_mtu = nic_info.max_mtu;
 
-	adapter->max_tx_rings = ahw->max_tx_ques;
-	adapter->max_sds_rings = ahw->max_rx_ques;
 	/* eSwitch capability indicates vNIC mode.
 	 * vNIC and SRIOV are mutually exclusive operational modes.
 	 * If SR-IOV capability is detected, SR-IOV physical function
@@ -2161,6 +2159,7 @@ static int qlcnic_83xx_get_nic_configuration(struct qlcnic_adapter *adapter)
 int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter)
 {
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
+	u16 max_sds_rings, max_tx_rings;
 	int ret;
 
 	ret = qlcnic_83xx_get_nic_configuration(adapter);
@@ -2173,18 +2172,21 @@ int qlcnic_83xx_configure_opmode(struct qlcnic_adapter *adapter)
 		if (qlcnic_83xx_config_vnic_opmode(adapter))
 			return -EIO;
 
-		adapter->max_sds_rings = QLCNIC_MAX_VNIC_SDS_RINGS;
-		adapter->max_tx_rings = QLCNIC_MAX_VNIC_TX_RINGS;
+		max_sds_rings = QLCNIC_MAX_VNIC_SDS_RINGS;
+		max_tx_rings = QLCNIC_MAX_VNIC_TX_RINGS;
 	} else if (ret == QLC_83XX_DEFAULT_OPMODE) {
 		ahw->nic_mode = QLCNIC_DEFAULT_MODE;
 		adapter->nic_ops->init_driver = qlcnic_83xx_init_default_driver;
 		ahw->idc.state_entry = qlcnic_83xx_idc_ready_state_entry;
-		adapter->max_sds_rings = QLCNIC_MAX_SDS_RINGS;
-		adapter->max_tx_rings = QLCNIC_MAX_TX_RINGS;
+		max_sds_rings = QLCNIC_MAX_SDS_RINGS;
+		max_tx_rings = QLCNIC_MAX_TX_RINGS;
 	} else {
 		return -EIO;
 	}
 
+	adapter->max_sds_rings = min(ahw->max_rx_ques, max_sds_rings);
+	adapter->max_tx_rings = min(ahw->max_tx_ques, max_tx_rings);
+
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 64dcbf3..a81ad50 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -883,8 +883,6 @@ int qlcnic_82xx_get_nic_info(struct qlcnic_adapter *adapter,
 		npar_info->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
 		npar_info->capabilities = le32_to_cpu(nic_info->capabilities);
 		npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
-		adapter->max_tx_rings = npar_info->max_tx_ques;
-		adapter->max_sds_rings = npar_info->max_rx_ques;
 	}
 
 	qlcnic_free_mbx_args(&cmd);
-- 
1.8.1.4
