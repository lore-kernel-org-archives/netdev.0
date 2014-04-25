From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 3/6] qlcnic: Allow setting TX interrupt coalescing parameters from VF.
Date: Fri, 25 Apr 2014 17:43:58 -0400
Message-ID: <1398462241-15478-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shahed.shaikh@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:5274 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751400AbaDYWWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 18:22:05 -0400
In-Reply-To: <1398462241-15478-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Tx interrupt coalescing parameters can now be set from VF.
o Added validation code in PF to validate the parameters.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 13 ++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c   | 35 ++++++++++++++++++----
 2 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index d853e31..e96ecca 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2052,6 +2052,7 @@ out:
 
 static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int err = 0;
 
 	adapter->recv_ctx = kzalloc(sizeof(struct qlcnic_recv_context),
@@ -2061,6 +2062,18 @@ static int qlcnic_alloc_adapter_resources(struct qlcnic_adapter *adapter)
 		goto err_out;
 	}
 
+	if (qlcnic_83xx_check(adapter)) {
+		ahw->coal.type = QLCNIC_INTR_COAL_TYPE_RX_TX;
+		ahw->coal.tx_time_us = QLCNIC_DEF_INTR_COALESCE_TX_TIME_US;
+		ahw->coal.tx_packets = QLCNIC_DEF_INTR_COALESCE_TX_PACKETS;
+		ahw->coal.rx_time_us = QLCNIC_DEF_INTR_COALESCE_RX_TIME_US;
+		ahw->coal.rx_packets = QLCNIC_DEF_INTR_COALESCE_RX_PACKETS;
+	} else {
+		ahw->coal.type = QLCNIC_INTR_COAL_TYPE_RX;
+		ahw->coal.rx_time_us = QLCNIC_DEF_INTR_COALESCE_RX_TIME_US;
+		ahw->coal.rx_packets = QLCNIC_DEF_INTR_COALESCE_RX_PACKETS;
+	}
+
 	/* clear stats */
 	memset(&adapter->stats, 0, sizeof(adapter->stats));
 err_out:
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
index 2801379..c7926ce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_pf.c
@@ -16,6 +16,7 @@
 #define QLC_VF_FLOOD_BIT	BIT_16
 #define QLC_FLOOD_MODE		0x5
 #define QLC_SRIOV_ALLOW_VLAN0	BIT_19
+#define QLC_INTR_COAL_TYPE_MASK	0x7
 
 static int qlcnic_sriov_pf_get_vport_handle(struct qlcnic_adapter *, u8);
 
@@ -1178,19 +1179,41 @@ static int qlcnic_sriov_validate_cfg_intrcoal(struct qlcnic_adapter *adapter,
 {
 	struct qlcnic_nic_intr_coalesce *coal = &adapter->ahw->coal;
 	u16 ctx_id, pkts, time;
+	int err = -EINVAL;
+	u8 type;
 
+	type = cmd->req.arg[1] & QLC_INTR_COAL_TYPE_MASK;
 	ctx_id = cmd->req.arg[1] >> 16;
 	pkts = cmd->req.arg[2] & 0xffff;
 	time = cmd->req.arg[2] >> 16;
 
-	if (ctx_id != vf->rx_ctx_id)
-		return -EINVAL;
-	if (pkts > coal->rx_packets)
-		return -EINVAL;
-	if (time < coal->rx_time_us)
-		return -EINVAL;
+	switch (type) {
+	case QLCNIC_INTR_COAL_TYPE_RX:
+		if (ctx_id != vf->rx_ctx_id || pkts > coal->rx_packets ||
+		    time < coal->rx_time_us)
+			goto err_label;
+		break;
+	case QLCNIC_INTR_COAL_TYPE_TX:
+		if (ctx_id != vf->tx_ctx_id || pkts > coal->tx_packets ||
+		    time < coal->tx_time_us)
+			goto err_label;
+		break;
+	default:
+		netdev_err(adapter->netdev, "Invalid coalescing type 0x%x received\n",
+			   type);
+		return err;
+	}
 
 	return 0;
+
+err_label:
+	netdev_err(adapter->netdev, "Expected: rx_ctx_id 0x%x rx_packets 0x%x rx_time_us 0x%x tx_ctx_id 0x%x tx_packets 0x%x tx_time_us 0x%x\n",
+		   vf->rx_ctx_id, coal->rx_packets, coal->rx_time_us,
+		   vf->tx_ctx_id, coal->tx_packets, coal->tx_time_us);
+	netdev_err(adapter->netdev, "Received: ctx_id 0x%x packets 0x%x time_us 0x%x type 0x%x\n",
+		   ctx_id, pkts, time, type);
+
+	return err;
 }
 
 static int qlcnic_sriov_pf_cfg_intrcoal_cmd(struct qlcnic_bc_trans *tran,
-- 
1.8.1.4
