From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 1/2] qlcnic: fix unused variable warnings
Date: Tue, 18 Dec 2012 12:59:50 -0500
Message-ID: <1355853591-29917-2-git-send-email-sony.chacko@qlogic.com>
References: <1355853591-29917-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:31889 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1750929Ab2LRSTE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Dec 2012 13:19:04 -0500
In-Reply-To: <1355853591-29917-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

qlcnic_hw.c:370: warning: variable cmd_desc set but not used
qlcnic_hw.c:368: warning: variable consumer set but not used
qlcnic_main.c:448: warning: variable ref_count set but not used
qlcnic_main.c:534: warning: variable mem_base set but not used
qlcnic_ctx.c:137: warning: variable tmp_tmpl set but not used
qlcnic_ctx.c:133: warning: variable version set but not used
qlcnic_minidump.c:200: warning: variable opcode set but not used

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c    |    5 +++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c     |    5 ++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c   |    5 -----
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    3 +--
 4 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 58f094c..b14b8f0 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -134,7 +134,7 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 	__le32 *tmp_buf;
 	struct qlcnic_cmd_args cmd;
 	struct qlcnic_hardware_context *ahw;
-	struct qlcnic_dump_template_hdr *tmpl_hdr, *tmp_tmpl;
+	struct qlcnic_dump_template_hdr *tmpl_hdr;
 	dma_addr_t tmp_addr_t = 0;
 
 	ahw = adapter->ahw;
@@ -150,6 +150,8 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 	}
 	temp_size = cmd.rsp.arg2;
 	version = cmd.rsp.arg3;
+	dev_info(&adapter->pdev->dev,
+		 "minidump template version = 0x%x", version);
 	if (!temp_size)
 		return -EIO;
 
@@ -174,7 +176,6 @@ int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
 		err = -EIO;
 		goto error;
 	}
-	tmp_tmpl = tmp_addr;
 	ahw->fw_dump.tmpl_hdr = vzalloc(temp_size);
 	if (!ahw->fw_dump.tmpl_hdr) {
 		err = -EIO;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index fc48e00..7a6d5eb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -365,7 +365,7 @@ static int
 qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 		struct cmd_desc_type0 *cmd_desc_arr, int nr_desc)
 {
-	u32 i, producer, consumer;
+	u32 i, producer;
 	struct qlcnic_cmd_buffer *pbuf;
 	struct cmd_desc_type0 *cmd_desc;
 	struct qlcnic_host_tx_ring *tx_ring;
@@ -379,7 +379,6 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 	__netif_tx_lock_bh(tx_ring->txq);
 
 	producer = tx_ring->producer;
-	consumer = tx_ring->sw_consumer;
 
 	if (nr_desc >= qlcnic_tx_avail(tx_ring)) {
 		netif_tx_stop_queue(tx_ring->txq);
@@ -402,7 +401,7 @@ qlcnic_send_cmd_descs(struct qlcnic_adapter *adapter,
 		pbuf->frag_count = 0;
 
 		memcpy(&tx_ring->desc_head[producer],
-			&cmd_desc_arr[i], sizeof(struct cmd_desc_type0));
+		       cmd_desc, sizeof(struct cmd_desc_type0));
 
 		producer = get_next_index(producer, tx_ring->num_desc);
 		i++;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index a7554d9..d833f59 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -445,13 +445,10 @@ static int
 qlcnic_set_function_modes(struct qlcnic_adapter *adapter)
 {
 	u8 id;
-	u32 ref_count;
 	int i, ret = 1;
 	u32 data = QLCNIC_MGMT_FUNC;
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 
-	/* If other drivers are not in use set their privilege level */
-	ref_count = QLCRD32(adapter, QLCNIC_CRB_DRV_ACTIVE);
 	ret = qlcnic_api_lock(adapter);
 	if (ret)
 		goto err_lock;
@@ -531,11 +528,9 @@ static int qlcnic_setup_pci_map(struct pci_dev *pdev,
 {
 	u32 offset;
 	void __iomem *mem_ptr0 = NULL;
-	resource_size_t mem_base;
 	unsigned long mem_len, pci_len0 = 0, bar0_len;
 
 	/* remap phys address */
-	mem_base = pci_resource_start(pdev, 0);	/* 0 is for BAR 0 */
 	mem_len = pci_resource_len(pdev, 0);
 
 	qlcnic_get_bar_length(pdev->device, &bar0_len);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 12ff292..0b8d862 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -197,7 +197,7 @@ static u32 qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 	int i, k, timeout = 0;
 	void __iomem *base = adapter->ahw->pci_base0;
 	u32 addr, data;
-	u8 opcode, no_ops;
+	u8 no_ops;
 	struct __ctrl *ctr = &entry->region.ctrl;
 	struct qlcnic_dump_template_hdr *t_hdr = adapter->ahw->fw_dump.tmpl_hdr;
 
@@ -206,7 +206,6 @@ static u32 qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
 
 	for (i = 0; i < no_ops; i++) {
 		k = 0;
-		opcode = 0;
 		for (k = 0; k < 8; k++) {
 			if (!(ctr->opcode & (1 << k)))
 				continue;
-- 
1.7.1
