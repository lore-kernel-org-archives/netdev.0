From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/2] netxen: fix failure cases for fw hang recovery
Date: Wed,  2 Dec 2009 17:46:19 -0800
Message-ID: <1259804779-23091-3-git-send-email-amit.salecha@qlogic.com>
References: <1259804779-23091-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com,
	Amit Kumar Salecha <amit@unm84.unmin.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:15841 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753506AbZLCBqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Dec 2009 20:46:13 -0500
In-Reply-To: <1259804779-23091-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@unm84.unmin.com>

Handle few corner cases in firmware hang detection and recovery:

o Don't mark device state as READY, till handshake with
  firmware is done.
o During probe, if start_firmware fails, restore reference
  count.
o Don't increment refernce count, if start_firmware fails
  during firmware reset.
o Clear __NX_RESETTING bit, incase of fatal error or tempeature
  reaches critical limit so that pci remove() doesn't poll on
  this bit.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |   26 +++++++++++++++-----------
 1 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 838420d..e5d187f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -819,7 +819,7 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 	if (err < 0)
 		goto err_out;
 	if (err == 0)
-		goto ready;
+		goto wait_init;
 
 	if (first_boot != 0x55555555) {
 		NXWR32(adapter, CRB_CMDPEG_STATE, 0);
@@ -862,9 +862,6 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 		| (_NETXEN_NIC_LINUX_SUBVERSION);
 	NXWR32(adapter, CRB_DRIVER_VERSION, val);
 
-ready:
-	NXWR32(adapter, NX_CRB_DEV_STATE, NX_DEV_READY);
-
 wait_init:
 	/* Handshake with the card before we register the devices. */
 	err = netxen_phantom_init(adapter, NETXEN_NIC_PEG_TUNE);
@@ -873,6 +870,8 @@ wait_init:
 		goto err_out;
 	}
 
+	NXWR32(adapter, NX_CRB_DEV_STATE, NX_DEV_READY);
+
 	nx_update_dma_mask(adapter);
 
 	netxen_check_options(adapter);
@@ -1282,7 +1281,7 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = netxen_start_firmware(adapter);
 	if (err)
-		goto err_out_iounmap;
+		goto err_out_decr_ref;
 
 	/*
 	 * See if the firmware gave us a virtual-physical port mapping.
@@ -1326,6 +1325,7 @@ err_out_disable_msi:
 
 	netxen_free_dummy_dma(adapter);
 
+err_out_decr_ref:
 	nx_decr_dev_ref_cnt(adapter);
 
 err_out_iounmap:
@@ -2189,14 +2189,13 @@ netxen_fwinit_work(struct work_struct *work)
 					netxen_fwinit_work, 2 * FW_POLL_DELAY);
 			return;
 		}
-		break;
 
 	case NX_DEV_FAILED:
 	default:
+		nx_incr_dev_ref_cnt(adapter);
 		break;
 	}
 
-	nx_incr_dev_ref_cnt(adapter);
 	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
@@ -2218,18 +2217,23 @@ netxen_detach_work(struct work_struct *work)
 
 	status = NXRD32(adapter, NETXEN_PEG_HALT_STATUS1);
 
-	ref_cnt = nx_decr_dev_ref_cnt(adapter);
-
 	if (status & NX_RCODE_FATAL_ERROR)
-		return;
+		goto err_ret;
 
 	if (adapter->temp == NX_TEMP_PANIC)
-		return;
+		goto err_ret;
+
+	ref_cnt = nx_decr_dev_ref_cnt(adapter);
 
 	delay = (ref_cnt == 0) ? 0 : (2 * FW_POLL_DELAY);
 
 	adapter->fw_wait_cnt = 0;
 	netxen_schedule_work(adapter, netxen_fwinit_work, delay);
+
+	return;
+
+err_ret:
+	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
 static int
-- 
1.6.0.2

