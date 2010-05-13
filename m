From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 9/9] qlcnic: add idc debug registers
Date: Thu, 13 May 2010 06:07:50 -0700
Message-ID: <1273756070-7205-10-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24384 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758777Ab0EMNHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:55 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

When ever driver changes the device state, it should write
pci-func number and timestamp in debug registers.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 ++
 drivers/net/qlcnic/qlcnic_main.c |   21 +++++++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 5c89f4e..2ed34cd 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -960,6 +960,8 @@ struct qlcnic_adapter {
 
 	u8 mac_addr[ETH_ALEN];
 
+	u64 dev_rst_time;
+
 	struct qlcnic_adapter_stats stats;
 
 	struct qlcnic_recv_context recv_ctx;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index ce8118c..4bf3d62 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -84,6 +84,7 @@ static void qlcnic_remove_sysfs_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_create_diag_entries(struct qlcnic_adapter *adapter);
 static void qlcnic_remove_diag_entries(struct qlcnic_adapter *adapter);
 
+static void qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding);
 static void qlcnic_clr_all_drv_state(struct qlcnic_adapter *adapter);
 static int qlcnic_can_start_firmware(struct qlcnic_adapter *adapter);
 
@@ -621,6 +622,7 @@ wait_init:
 		goto err_out;
 
 	QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_READY);
+	qlcnic_idc_debug_info(adapter, 1);
 
 	qlcnic_check_options(adapter);
 
@@ -1057,6 +1059,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter = netdev_priv(netdev);
 	adapter->netdev  = netdev;
 	adapter->pdev    = pdev;
+	adapter->dev_rst_time = jiffies;
 	adapter->ahw.pci_func  = pci_func_id;
 
 	revision_id = pdev->revision;
@@ -1888,6 +1891,19 @@ static void qlcnic_poll_controller(struct net_device *netdev)
 }
 #endif
 
+static void
+qlcnic_idc_debug_info(struct qlcnic_adapter *adapter, u8 encoding)
+{
+	u32 val;
+
+	val = adapter->portnum & 0xf;
+	val |= encoding << 7;
+	val |= (jiffies - adapter->dev_rst_time) << 8;
+
+	QLCWR32(adapter, QLCNIC_CRB_DRV_SCRATCH, val);
+	adapter->dev_rst_time = jiffies;
+}
+
 static int
 qlcnic_set_drv_state(struct qlcnic_adapter *adapter, u8 state)
 {
@@ -2011,6 +2027,7 @@ qlcnic_can_start_firmware(struct qlcnic_adapter *adapter)
 	case QLCNIC_DEV_COLD:
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_INITIALIZING);
 		QLCWR32(adapter, QLCNIC_CRB_DRV_IDC_VER, QLCNIC_DRV_IDC_VER);
+		qlcnic_idc_debug_info(adapter, 0);
 		qlcnic_api_unlock(adapter);
 		return 1;
 
@@ -2103,6 +2120,8 @@ skip_ack_check:
 			qlcnic_schedule_work(adapter, qlcnic_fwinit_work,
 						FW_POLL_DELAY * 2);
 			QLCDB(adapter, DRV, "Quiscing the driver\n");
+			qlcnic_idc_debug_info(adapter, 0);
+
 			qlcnic_api_unlock(adapter);
 			return;
 		}
@@ -2112,6 +2131,7 @@ skip_ack_check:
 						QLCNIC_DEV_INITIALIZING);
 			set_bit(__QLCNIC_START_FW, &adapter->state);
 			QLCDB(adapter, DRV, "Restarting fw\n");
+			qlcnic_idc_debug_info(adapter, 0);
 		}
 
 		qlcnic_api_unlock(adapter);
@@ -2207,6 +2227,7 @@ qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 	if (state == QLCNIC_DEV_READY) {
 		QLCWR32(adapter, QLCNIC_CRB_DEV_STATE, QLCNIC_DEV_NEED_RESET);
 		QLCDB(adapter, DRV, "NEED_RESET state set\n");
+		qlcnic_idc_debug_info(adapter, 0);
 	}
 
 	qlcnic_api_unlock(adapter);
-- 
1.6.0.2

