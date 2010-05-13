From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 7/9] qlcnic: check device class
Date: Thu, 13 May 2010 06:07:48 -0700
Message-ID: <1273756070-7205-8-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7534 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758764Ab0EMNHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:55 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

pci-func class can be other than ethernet in Qlogic CNA device.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 +-
 drivers/net/qlcnic/qlcnic_init.c |   16 +++++++++++++++-
 drivers/net/qlcnic/qlcnic_main.c |    8 ++------
 3 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 8a9412f..5c89f4e 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -1037,7 +1037,7 @@ int qlcnic_need_fw_reset(struct qlcnic_adapter *adapter);
 void qlcnic_request_firmware(struct qlcnic_adapter *adapter);
 void qlcnic_release_firmware(struct qlcnic_adapter *adapter);
 int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter);
-void qlcnic_setup_idc_param(struct qlcnic_adapter *adapter);
+int qlcnic_setup_idc_param(struct qlcnic_adapter *adapter);
 
 int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, int addr, int *valp);
 int qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index c4bef57..77bfdab 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -514,10 +514,22 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
 	return 0;
 }
 
-void
+int
 qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 
 	int timeo;
+	u32 val;
+
+	val = QLCRD32(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+	val = (val >> (adapter->portnum * 4)) & 0xf;
+
+	if ((val & 0x3) != 1) {
+		dev_err(&adapter->pdev->dev, "Not an Ethernet NIC func=%u\n",
+									val);
+		return -EIO;
+	}
+
+	adapter->physical_port = (val >> 2);
 
 	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
 		timeo = 30;
@@ -528,6 +540,8 @@ qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
 		timeo = 10;
 
 	adapter->reset_ack_timeo = timeo;
+
+	return 0;
 }
 
 static int
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index e94a96d..ce57229 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1081,17 +1081,13 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out_iounmap;
 	}
 
-	qlcnic_setup_idc_param(adapter);
+	if (qlcnic_setup_idc_param(adapter))
+		goto err_out_iounmap;
 
 	err = qlcnic_start_firmware(adapter);
 	if (err)
 		goto err_out_decr_ref;
 
-	/*
-	 * See if the firmware gave us a virtual-physical port mapping.
-	 */
-	adapter->physical_port = adapter->portnum;
-
 	qlcnic_clear_stats(adapter);
 
 	qlcnic_setup_intr(adapter);
-- 
1.6.0.2

