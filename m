From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net 1/1] qlcnic: Fix tunnel offload for 82xx adapters
Date: Fri, 2 Jun 2017 06:52:54 -0700
Message-ID: <20170602135254.3591-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0050.outbound.protection.outlook.com ([104.47.40.50]:54938
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751125AbdFBNxT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 09:53:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Qlogic's 82xx series adapter doesn't support
tunnel offloads, driver incorrectly assumes that it is
supported and causes firmware hang while running tunnel IO.

This patch fixes this by not advertising tunnel offloads
for 82xx adapters.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        | 26 ++++++++++++++++++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |  2 ++
 .../ethernet/qlogic/qlcnic/qlcnic_sriov_common.c   |  2 ++
 4 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 7245b10..8131292 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1824,22 +1824,44 @@ struct qlcnic_hardware_ops {
 	u32 (*get_cap_size)(void *, int);
 	void (*set_sys_info)(void *, int, u32);
 	void (*store_cap_mask)(void *, u32);
+	bool (*encap_rx_offload) (struct qlcnic_adapter *adapter);
+	bool (*encap_tx_offload) (struct qlcnic_adapter *adapter);
 };
 
 extern struct qlcnic_nic_template qlcnic_vf_ops;
 
-static inline bool qlcnic_encap_tx_offload(struct qlcnic_adapter *adapter)
+static inline bool qlcnic_83xx_encap_tx_offload(struct qlcnic_adapter *adapter)
 {
 	return adapter->ahw->extra_capability[0] &
 	       QLCNIC_83XX_FW_CAPAB_ENCAP_TX_OFFLOAD;
 }
 
-static inline bool qlcnic_encap_rx_offload(struct qlcnic_adapter *adapter)
+static inline bool qlcnic_83xx_encap_rx_offload(struct qlcnic_adapter *adapter)
 {
 	return adapter->ahw->extra_capability[0] &
 	       QLCNIC_83XX_FW_CAPAB_ENCAP_RX_OFFLOAD;
 }
 
+static inline bool qlcnic_82xx_encap_tx_offload(struct qlcnic_adapter *adapter)
+{
+	return false;
+}
+
+static inline bool qlcnic_82xx_encap_rx_offload(struct qlcnic_adapter *adapter)
+{
+        return false;
+}
+
+static inline bool qlcnic_encap_rx_offload(struct qlcnic_adapter *adapter)
+{
+        return adapter->ahw->hw_ops->encap_rx_offload(adapter);
+}
+
+static inline bool qlcnic_encap_tx_offload(struct qlcnic_adapter *adapter)
+{
+        return adapter->ahw->hw_ops->encap_tx_offload(adapter);
+}
+
 static inline int qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 {
 	return adapter->nic_ops->start_firmware(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 4fb6879..f7080d0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -242,6 +242,8 @@ static struct qlcnic_hardware_ops qlcnic_83xx_hw_ops = {
 	.get_cap_size			= qlcnic_83xx_get_cap_size,
 	.set_sys_info			= qlcnic_83xx_set_sys_info,
 	.store_cap_mask			= qlcnic_83xx_store_cap_mask,
+	.encap_rx_offload		= qlcnic_83xx_encap_rx_offload,
+	.encap_tx_offload		= qlcnic_83xx_encap_tx_offload,
 };
 
 static struct qlcnic_nic_template qlcnic_83xx_ops = {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index b6628aa..1b5f7d5 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -632,6 +632,8 @@ static struct qlcnic_hardware_ops qlcnic_hw_ops = {
 	.get_cap_size			= qlcnic_82xx_get_cap_size,
 	.set_sys_info			= qlcnic_82xx_set_sys_info,
 	.store_cap_mask			= qlcnic_82xx_store_cap_mask,
+	.encap_rx_offload               = qlcnic_82xx_encap_rx_offload,
+	.encap_tx_offload               = qlcnic_82xx_encap_tx_offload,
 };
 
 static int qlcnic_check_multi_tx_capability(struct qlcnic_adapter *adapter)
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 2f656f3..c58180f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -77,6 +77,8 @@ static struct qlcnic_hardware_ops qlcnic_sriov_vf_hw_ops = {
 	.free_mac_list			= qlcnic_sriov_vf_free_mac_list,
 	.enable_sds_intr		= qlcnic_83xx_enable_sds_intr,
 	.disable_sds_intr		= qlcnic_83xx_disable_sds_intr,
+	.encap_rx_offload               = qlcnic_83xx_encap_rx_offload,
+	.encap_tx_offload               = qlcnic_83xx_encap_tx_offload,
 };
 
 static struct qlcnic_nic_template qlcnic_sriov_vf_ops = {
-- 
2.7.2
