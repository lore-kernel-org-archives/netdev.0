From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 1/3] qlcnic: Pre-allocate DMA buffer used for minidump collection
Date: Wed, 11 Jun 2014 14:09:11 -0400
Message-ID: <1402510153-9928-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1402510153-9928-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:63011 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753542AbaFKSjU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 14:39:20 -0400
In-Reply-To: <1402510153-9928-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Pre-allocate the physically contiguous DMA buffer used for
minidump collection at driver load time, rather than at
run time, to minimize allocation failures. Driver will allocate
the buffer at load time if PEX DMA support capability is indicated
by the adapter.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h        |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   | 14 ++++++++--
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   | 32 ++++++++++------------
 3 files changed, 28 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 41abe60..d85f7e1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -441,6 +441,8 @@ struct qlcnic_82xx_dump_template_hdr {
 	u32	rsvd1[0];
 };
 
+#define QLC_PEX_DMA_READ_SIZE	(PAGE_SIZE * 16)
+
 struct qlcnic_fw_dump {
 	u8	clr;	/* flag to indicate if dump is cleared */
 	bool	enable; /* enable/disable dump */
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index f06ba90b..1c18891 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2087,12 +2087,20 @@ err_out:
 
 static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
 {
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+
 	kfree(adapter->recv_ctx);
 	adapter->recv_ctx = NULL;
 
-	if (adapter->ahw->fw_dump.tmpl_hdr) {
-		vfree(adapter->ahw->fw_dump.tmpl_hdr);
-		adapter->ahw->fw_dump.tmpl_hdr = NULL;
+	if (fw_dump->tmpl_hdr) {
+		vfree(fw_dump->tmpl_hdr);
+		fw_dump->tmpl_hdr = NULL;
+	}
+
+	if (fw_dump->dma_buffer) {
+		dma_free_coherent(&adapter->pdev->dev, QLC_PEX_DMA_READ_SIZE,
+				  fw_dump->dma_buffer, fw_dump->phys_addr);
+		fw_dump->dma_buffer = NULL;
 	}
 
 	kfree(adapter->ahw->reset.buff);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index f7694da..e46fc39 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -660,8 +660,6 @@ out:
 #define QLC_DMA_CMD_BUFF_ADDR_HI	4
 #define QLC_DMA_CMD_STATUS_CTRL		8
 
-#define QLC_PEX_DMA_READ_SIZE		(PAGE_SIZE * 16)
-
 static int qlcnic_start_pex_dma(struct qlcnic_adapter *adapter,
 				struct __mem *mem)
 {
@@ -1155,6 +1153,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 	u32 version, csum, *tmp_buf;
 	u8 use_flash_temp = 0;
 	u32 temp_size = 0;
+	void *temp_buffer;
 	int err;
 
 	ahw = adapter->ahw;
@@ -1204,6 +1203,19 @@ flash_temp:
 
 	qlcnic_cache_tmpl_hdr_values(adapter, fw_dump);
 
+	if (fw_dump->use_pex_dma) {
+		fw_dump->dma_buffer = NULL;
+		temp_buffer = dma_alloc_coherent(&adapter->pdev->dev,
+						 QLC_PEX_DMA_READ_SIZE,
+						 &fw_dump->phys_addr,
+						 GFP_KERNEL);
+		if (!temp_buffer)
+			fw_dump->use_pex_dma = false;
+		else
+			fw_dump->dma_buffer = temp_buffer;
+	}
+
+
 	dev_info(&adapter->pdev->dev,
 		 "Default minidump capture mask 0x%x\n",
 		 fw_dump->cap_mask);
@@ -1223,7 +1235,7 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	struct device *dev = &adapter->pdev->dev;
 	struct qlcnic_hardware_context *ahw;
 	struct qlcnic_dump_entry *entry;
-	void *temp_buffer, *tmpl_hdr;
+	void *tmpl_hdr;
 	u32 ocm_window;
 	__le32 *buffer;
 	char mesg[64];
@@ -1267,16 +1279,6 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	qlcnic_set_sys_info(adapter, tmpl_hdr, 0, QLCNIC_DRIVER_VERSION);
 	qlcnic_set_sys_info(adapter, tmpl_hdr, 1, adapter->fw_version);
 
-	if (fw_dump->use_pex_dma) {
-		temp_buffer = dma_alloc_coherent(dev, QLC_PEX_DMA_READ_SIZE,
-						 &fw_dump->phys_addr,
-						 GFP_KERNEL);
-		if (!temp_buffer)
-			fw_dump->use_pex_dma = false;
-		else
-			fw_dump->dma_buffer = temp_buffer;
-	}
-
 	if (qlcnic_82xx_check(adapter)) {
 		ops_cnt = ARRAY_SIZE(qlcnic_fw_dump_ops);
 		fw_dump_ops = qlcnic_fw_dump_ops;
@@ -1334,10 +1336,6 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	/* Send a udev event to notify availability of FW dump */
 	kobject_uevent_env(&dev->kobj, KOBJ_CHANGE, msg);
 
-	if (fw_dump->use_pex_dma)
-		dma_free_coherent(dev, QLC_PEX_DMA_READ_SIZE,
-				  fw_dump->dma_buffer, fw_dump->phys_addr);
-
 	return 0;
 }
 
-- 
1.8.1.4
