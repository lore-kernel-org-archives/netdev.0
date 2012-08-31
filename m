From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH 04/12] qlcnic: remove 82xx specific register dump utility
Date: Fri, 31 Aug 2012 18:36:51 -0400
Message-ID: <1346452619-2129-5-git-send-email-sony.chacko@qlogic.com>
References: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:6996 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755091Ab2HaWxy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2012 18:53:54 -0400
In-Reply-To: <1346452619-2129-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

Modify 82xx driver to support new adapter - Qlogic 83XX CNA
Remove 82xx specific register dump utility

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c  |  107 +-----
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c   |  466 ----------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c   |   21 -
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    4 -
 4 files changed, 1 insertions(+), 597 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 4e57edb..12c45bf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -103,91 +103,6 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter, struct qlcnic_cmd_args *cmd)
 
 }
 
-static uint32_t qlcnic_temp_checksum(uint32_t *temp_buffer, u16 temp_size)
-{
-	uint64_t sum = 0;
-	int count = temp_size / sizeof(uint32_t);
-	while (count-- > 0)
-		sum += *temp_buffer++;
-	while (sum >> 32)
-		sum = (sum & 0xFFFFFFFF) + (sum >> 32);
-	return ~sum;
-}
-
-int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
-{
-	int err, i;
-	u16 temp_size;
-	void *tmp_addr;
-	u32 version, csum, *template, *tmp_buf;
-	struct qlcnic_cmd_args cmd;
-	struct qlcnic_hardware_context *ahw;
-	struct qlcnic_dump_template_hdr *tmpl_hdr, *tmp_tmpl;
-	dma_addr_t tmp_addr_t = 0;
-
-	ahw = adapter->ahw;
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_TEMP_SIZE;
-	memset(&cmd.rsp, 1, sizeof(struct _cdrp_cmd));
-	qlcnic_issue_cmd(adapter, &cmd);
-	if (cmd.rsp.cmd != QLCNIC_RCODE_SUCCESS) {
-		dev_info(&adapter->pdev->dev,
-			"Can't get template size %d\n", cmd.rsp.cmd);
-		err = -EIO;
-		return err;
-	}
-	temp_size = cmd.rsp.arg2;
-	version = cmd.rsp.arg3;
-	if (!temp_size)
-		return -EIO;
-
-	tmp_addr = dma_alloc_coherent(&adapter->pdev->dev, temp_size,
-			&tmp_addr_t, GFP_KERNEL);
-	if (!tmp_addr) {
-		dev_err(&adapter->pdev->dev,
-			"Can't get memory for FW dump template\n");
-		return -ENOMEM;
-	}
-	memset(&cmd.rsp, 0, sizeof(struct _cdrp_cmd));
-	cmd.req.cmd = QLCNIC_CDRP_CMD_GET_TEMP_HDR;
-	cmd.req.arg1 = LSD(tmp_addr_t);
-	cmd.req.arg2 = MSD(tmp_addr_t);
-	cmd.req.arg3 = temp_size;
-	qlcnic_issue_cmd(adapter, &cmd);
-
-	err = cmd.rsp.cmd;
-	if (err != QLCNIC_RCODE_SUCCESS) {
-		dev_err(&adapter->pdev->dev,
-			"Failed to get mini dump template header %d\n", err);
-		err = -EIO;
-		goto error;
-	}
-	tmp_tmpl = tmp_addr;
-	csum = qlcnic_temp_checksum((uint32_t *) tmp_addr, temp_size);
-	if (csum) {
-		dev_err(&adapter->pdev->dev,
-			"Template header checksum validation failed\n");
-		err = -EIO;
-		goto error;
-	}
-	ahw->fw_dump.tmpl_hdr = vzalloc(temp_size);
-	if (!ahw->fw_dump.tmpl_hdr) {
-		err = -EIO;
-		goto error;
-	}
-	tmp_buf = tmp_addr;
-	template = (u32 *) ahw->fw_dump.tmpl_hdr;
-	for (i = 0; i < temp_size/sizeof(u32); i++)
-		*template++ = __le32_to_cpu(*tmp_buf++);
-
-	tmpl_hdr = ahw->fw_dump.tmpl_hdr;
-	tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
-	ahw->fw_dump.enable = 1;
-error:
-	dma_free_coherent(&adapter->pdev->dev, temp_size, tmp_addr, tmp_addr_t);
-	return err;
-}
-
 int
 qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
 {
@@ -714,27 +629,7 @@ int qlcnic_get_nic_info(struct qlcnic_adapter *adapter,
 	qlcnic_issue_cmd(adapter, &cmd);
 	err = cmd.rsp.cmd;
 
-	if (err == QLCNIC_RCODE_SUCCESS) {
-		npar_info->pci_func = le16_to_cpu(nic_info->pci_func);
-		npar_info->op_mode = le16_to_cpu(nic_info->op_mode);
-		npar_info->phys_port = le16_to_cpu(nic_info->phys_port);
-		npar_info->switch_mode = le16_to_cpu(nic_info->switch_mode);
-		npar_info->max_tx_ques = le16_to_cpu(nic_info->max_tx_ques);
-		npar_info->max_rx_ques = le16_to_cpu(nic_info->max_rx_ques);
-		npar_info->min_tx_bw = le16_to_cpu(nic_info->min_tx_bw);
-		npar_info->max_tx_bw = le16_to_cpu(nic_info->max_tx_bw);
-		npar_info->capabilities = le32_to_cpu(nic_info->capabilities);
-		npar_info->max_mtu = le16_to_cpu(nic_info->max_mtu);
-
-		dev_info(&adapter->pdev->dev,
-			"phy port: %d switch_mode: %d,\n"
-			"\tmax_tx_q: %d max_rx_q: %d min_tx_bw: 0x%x,\n"
-			"\tmax_tx_bw: 0x%x max_mtu:0x%x, capabilities: 0x%x\n",
-			npar_info->phys_port, npar_info->switch_mode,
-			npar_info->max_tx_ques, npar_info->max_rx_ques,
-			npar_info->min_tx_bw, npar_info->max_tx_bw,
-			npar_info->max_mtu, npar_info->capabilities);
-	} else {
+	if (err) {
 		dev_err(&adapter->pdev->dev,
 			"Failed to get nic info%d\n", err);
 		err = -EIO;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index 6060461..890f25b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -1367,472 +1367,6 @@ int qlcnic_82xx_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 	return rv;
 }
 
-/* FW dump related functions */
-static u32
-qlcnic_dump_crb(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
-		u32 *buffer)
-{
-	int i;
-	u32 addr, data;
-	struct __crb *crb = &entry->region.crb;
-	void __iomem *base = adapter->ahw->pci_base0;
-
-	addr = crb->addr;
-
-	for (i = 0; i < crb->no_ops; i++) {
-		QLCNIC_RD_DUMP_REG(addr, base, &data);
-		*buffer++ = cpu_to_le32(addr);
-		*buffer++ = cpu_to_le32(data);
-		addr += crb->stride;
-	}
-	return crb->no_ops * 2 * sizeof(u32);
-}
-
-static u32
-qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
-	struct qlcnic_dump_entry *entry, u32 *buffer)
-{
-	int i, k, timeout = 0;
-	void __iomem *base = adapter->ahw->pci_base0;
-	u32 addr, data;
-	u8 opcode, no_ops;
-	struct __ctrl *ctr = &entry->region.ctrl;
-	struct qlcnic_dump_template_hdr *t_hdr = adapter->ahw->fw_dump.tmpl_hdr;
-
-	addr = ctr->addr;
-	no_ops = ctr->no_ops;
-
-	for (i = 0; i < no_ops; i++) {
-		k = 0;
-		opcode = 0;
-		for (k = 0; k < 8; k++) {
-			if (!(ctr->opcode & (1 << k)))
-				continue;
-			switch (1 << k) {
-			case QLCNIC_DUMP_WCRB:
-				QLCNIC_WR_DUMP_REG(addr, base, ctr->val1);
-				break;
-			case QLCNIC_DUMP_RWCRB:
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
-				QLCNIC_WR_DUMP_REG(addr, base, data);
-				break;
-			case QLCNIC_DUMP_ANDCRB:
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
-				QLCNIC_WR_DUMP_REG(addr, base,
-					(data & ctr->val2));
-				break;
-			case QLCNIC_DUMP_ORCRB:
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
-				QLCNIC_WR_DUMP_REG(addr, base,
-					(data | ctr->val3));
-				break;
-			case QLCNIC_DUMP_POLLCRB:
-				while (timeout <= ctr->timeout) {
-					QLCNIC_RD_DUMP_REG(addr, base, &data);
-					if ((data & ctr->val2) == ctr->val1)
-						break;
-					msleep(1);
-					timeout++;
-				}
-				if (timeout > ctr->timeout) {
-					dev_info(&adapter->pdev->dev,
-					"Timed out, aborting poll CRB\n");
-					return -EINVAL;
-				}
-				break;
-			case QLCNIC_DUMP_RD_SAVE:
-				if (ctr->index_a)
-					addr = t_hdr->saved_state[ctr->index_a];
-				QLCNIC_RD_DUMP_REG(addr, base, &data);
-				t_hdr->saved_state[ctr->index_v] = data;
-				break;
-			case QLCNIC_DUMP_WRT_SAVED:
-				if (ctr->index_v)
-					data = t_hdr->saved_state[ctr->index_v];
-				else
-					data = ctr->val1;
-				if (ctr->index_a)
-					addr = t_hdr->saved_state[ctr->index_a];
-				QLCNIC_WR_DUMP_REG(addr, base, data);
-				break;
-			case QLCNIC_DUMP_MOD_SAVE_ST:
-				data = t_hdr->saved_state[ctr->index_v];
-				data <<= ctr->shl_val;
-				data >>= ctr->shr_val;
-				if (ctr->val2)
-					data &= ctr->val2;
-				data |= ctr->val3;
-				data += ctr->val1;
-				t_hdr->saved_state[ctr->index_v] = data;
-				break;
-			default:
-				dev_info(&adapter->pdev->dev,
-					"Unknown opcode\n");
-				break;
-			}
-		}
-		addr += ctr->stride;
-	}
-	return 0;
-}
-
-static u32
-qlcnic_dump_mux(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
-	u32 *buffer)
-{
-	int loop;
-	u32 val, data = 0;
-	struct __mux *mux = &entry->region.mux;
-	void __iomem *base = adapter->ahw->pci_base0;
-
-	val = mux->val;
-	for (loop = 0; loop < mux->no_ops; loop++) {
-		QLCNIC_WR_DUMP_REG(mux->addr, base, val);
-		QLCNIC_RD_DUMP_REG(mux->read_addr, base, &data);
-		*buffer++ = cpu_to_le32(val);
-		*buffer++ = cpu_to_le32(data);
-		val += mux->val_stride;
-	}
-	return 2 * mux->no_ops * sizeof(u32);
-}
-
-static u32
-qlcnic_dump_que(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
-	u32 *buffer)
-{
-	int i, loop;
-	u32 cnt, addr, data, que_id = 0;
-	void __iomem *base = adapter->ahw->pci_base0;
-	struct __queue *que = &entry->region.que;
-
-	addr = que->read_addr;
-	cnt = que->read_addr_cnt;
-
-	for (loop = 0; loop < que->no_ops; loop++) {
-		QLCNIC_WR_DUMP_REG(que->sel_addr, base, que_id);
-		addr = que->read_addr;
-		for (i = 0; i < cnt; i++) {
-			QLCNIC_RD_DUMP_REG(addr, base, &data);
-			*buffer++ = cpu_to_le32(data);
-			addr += que->read_addr_stride;
-		}
-		que_id += que->stride;
-	}
-	return que->no_ops * cnt * sizeof(u32);
-}
-
-static u32
-qlcnic_dump_ocm(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
-	u32 *buffer)
-{
-	int i;
-	u32 data;
-	void __iomem *addr;
-	struct __ocm *ocm = &entry->region.ocm;
-
-	addr = adapter->ahw->pci_base0 + ocm->read_addr;
-	for (i = 0; i < ocm->no_ops; i++) {
-		data = readl(addr);
-		*buffer++ = cpu_to_le32(data);
-		addr += ocm->read_addr_stride;
-	}
-	return ocm->no_ops * sizeof(u32);
-}
-
-static u32
-qlcnic_read_rom(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
-	u32 *buffer)
-{
-	int i, count = 0;
-	u32 fl_addr, size, val, lck_val, addr;
-	struct __mem *rom = &entry->region.mem;
-	void __iomem *base = adapter->ahw->pci_base0;
-
-	fl_addr = rom->addr;
-	size = rom->size/4;
-lock_try:
-	lck_val = readl(base + QLCNIC_FLASH_SEM2_LK);
-	if (!lck_val && count < MAX_CTL_CHECK) {
-		msleep(10);
-		count++;
-		goto lock_try;
-	}
-	writel(adapter->ahw->pci_func, (base + QLCNIC_FLASH_LOCK_ID));
-	for (i = 0; i < size; i++) {
-		addr = fl_addr & 0xFFFF0000;
-		QLCNIC_WR_DUMP_REG(FLASH_ROM_WINDOW, base, addr);
-		addr = LSW(fl_addr) + FLASH_ROM_DATA;
-		QLCNIC_RD_DUMP_REG(addr, base, &val);
-		fl_addr += 4;
-		*buffer++ = cpu_to_le32(val);
-	}
-	readl(base + QLCNIC_FLASH_SEM2_ULK);
-	return rom->size;
-}
-
-static u32
-qlcnic_dump_l1_cache(struct qlcnic_adapter *adapter,
-	struct qlcnic_dump_entry *entry, u32 *buffer)
-{
-	int i;
-	u32 cnt, val, data, addr;
-	void __iomem *base = adapter->ahw->pci_base0;
-	struct __cache *l1 = &entry->region.cache;
-
-	val = l1->init_tag_val;
-
-	for (i = 0; i < l1->no_ops; i++) {
-		QLCNIC_WR_DUMP_REG(l1->addr, base, val);
-		QLCNIC_WR_DUMP_REG(l1->ctrl_addr, base, LSW(l1->ctrl_val));
-		addr = l1->read_addr;
-		cnt = l1->read_addr_num;
-		while (cnt) {
-			QLCNIC_RD_DUMP_REG(addr, base, &data);
-			*buffer++ = cpu_to_le32(data);
-			addr += l1->read_addr_stride;
-			cnt--;
-		}
-		val += l1->stride;
-	}
-	return l1->no_ops * l1->read_addr_num * sizeof(u32);
-}
-
-static u32
-qlcnic_dump_l2_cache(struct qlcnic_adapter *adapter,
-	struct qlcnic_dump_entry *entry, u32 *buffer)
-{
-	int i;
-	u32 cnt, val, data, addr;
-	u8 poll_mask, poll_to, time_out = 0;
-	void __iomem *base = adapter->ahw->pci_base0;
-	struct __cache *l2 = &entry->region.cache;
-
-	val = l2->init_tag_val;
-	poll_mask = LSB(MSW(l2->ctrl_val));
-	poll_to = MSB(MSW(l2->ctrl_val));
-
-	for (i = 0; i < l2->no_ops; i++) {
-		QLCNIC_WR_DUMP_REG(l2->addr, base, val);
-		if (LSW(l2->ctrl_val))
-			QLCNIC_WR_DUMP_REG(l2->ctrl_addr, base,
-				LSW(l2->ctrl_val));
-		if (!poll_mask)
-			goto skip_poll;
-		do {
-			QLCNIC_RD_DUMP_REG(l2->ctrl_addr, base, &data);
-			if (!(data & poll_mask))
-				break;
-			msleep(1);
-			time_out++;
-		} while (time_out <= poll_to);
-
-		if (time_out > poll_to) {
-			dev_err(&adapter->pdev->dev,
-				"Timeout exceeded in %s, aborting dump\n",
-				__func__);
-			return -EINVAL;
-		}
-skip_poll:
-		addr = l2->read_addr;
-		cnt = l2->read_addr_num;
-		while (cnt) {
-			QLCNIC_RD_DUMP_REG(addr, base, &data);
-			*buffer++ = cpu_to_le32(data);
-			addr += l2->read_addr_stride;
-			cnt--;
-		}
-		val += l2->stride;
-	}
-	return l2->no_ops * l2->read_addr_num * sizeof(u32);
-}
-
-static u32
-qlcnic_read_memory(struct qlcnic_adapter *adapter,
-	struct qlcnic_dump_entry *entry, u32 *buffer)
-{
-	u32 addr, data, test, ret = 0;
-	int i, reg_read;
-	struct __mem *mem = &entry->region.mem;
-	void __iomem *base = adapter->ahw->pci_base0;
-
-	reg_read = mem->size;
-	addr = mem->addr;
-	/* check for data size of multiple of 16 and 16 byte alignment */
-	if ((addr & 0xf) || (reg_read%16)) {
-		dev_info(&adapter->pdev->dev,
-			"Unaligned memory addr:0x%x size:0x%x\n",
-			addr, reg_read);
-		return -EINVAL;
-	}
-
-	mutex_lock(&adapter->ahw->mem_lock);
-
-	while (reg_read != 0) {
-		QLCNIC_WR_DUMP_REG(MIU_TEST_ADDR_LO, base, addr);
-		QLCNIC_WR_DUMP_REG(MIU_TEST_ADDR_HI, base, 0);
-		QLCNIC_WR_DUMP_REG(MIU_TEST_CTR, base,
-			TA_CTL_ENABLE | TA_CTL_START);
-
-		for (i = 0; i < MAX_CTL_CHECK; i++) {
-			QLCNIC_RD_DUMP_REG(MIU_TEST_CTR, base, &test);
-			if (!(test & TA_CTL_BUSY))
-				break;
-		}
-		if (i == MAX_CTL_CHECK) {
-			if (printk_ratelimit()) {
-				dev_err(&adapter->pdev->dev,
-					"failed to read through agent\n");
-				ret = -EINVAL;
-				goto out;
-			}
-		}
-		for (i = 0; i < 4; i++) {
-			QLCNIC_RD_DUMP_REG(MIU_TEST_READ_DATA[i], base, &data);
-			*buffer++ = cpu_to_le32(data);
-		}
-		addr += 16;
-		reg_read -= 16;
-		ret += 16;
-	}
-out:
-	mutex_unlock(&adapter->ahw->mem_lock);
-	return mem->size;
-}
-
-static u32
-qlcnic_dump_nop(struct qlcnic_adapter *adapter,
-	struct qlcnic_dump_entry *entry, u32 *buffer)
-{
-	entry->hdr.flags |= QLCNIC_DUMP_SKIP;
-	return 0;
-}
-
-struct qlcnic_dump_operations fw_dump_ops[] = {
-	{ QLCNIC_DUMP_NOP, qlcnic_dump_nop },
-	{ QLCNIC_DUMP_READ_CRB, qlcnic_dump_crb },
-	{ QLCNIC_DUMP_READ_MUX, qlcnic_dump_mux },
-	{ QLCNIC_DUMP_QUEUE, qlcnic_dump_que },
-	{ QLCNIC_DUMP_BRD_CONFIG, qlcnic_read_rom },
-	{ QLCNIC_DUMP_READ_OCM, qlcnic_dump_ocm },
-	{ QLCNIC_DUMP_PEG_REG, qlcnic_dump_ctrl },
-	{ QLCNIC_DUMP_L1_DTAG, qlcnic_dump_l1_cache },
-	{ QLCNIC_DUMP_L1_ITAG, qlcnic_dump_l1_cache },
-	{ QLCNIC_DUMP_L1_DATA, qlcnic_dump_l1_cache },
-	{ QLCNIC_DUMP_L1_INST, qlcnic_dump_l1_cache },
-	{ QLCNIC_DUMP_L2_DTAG, qlcnic_dump_l2_cache },
-	{ QLCNIC_DUMP_L2_ITAG, qlcnic_dump_l2_cache },
-	{ QLCNIC_DUMP_L2_DATA, qlcnic_dump_l2_cache },
-	{ QLCNIC_DUMP_L2_INST, qlcnic_dump_l2_cache },
-	{ QLCNIC_DUMP_READ_ROM, qlcnic_read_rom },
-	{ QLCNIC_DUMP_READ_MEM, qlcnic_read_memory },
-	{ QLCNIC_DUMP_READ_CTRL, qlcnic_dump_ctrl },
-	{ QLCNIC_DUMP_TLHDR, qlcnic_dump_nop },
-	{ QLCNIC_DUMP_RDEND, qlcnic_dump_nop },
-};
-
-/* Walk the template and collect dump for each entry in the dump template */
-static int
-qlcnic_valid_dump_entry(struct device *dev, struct qlcnic_dump_entry *entry,
-	u32 size)
-{
-	int ret = 1;
-	if (size != entry->hdr.cap_size) {
-		dev_info(dev,
-		"Invalidate dump, Type:%d\tMask:%d\tSize:%dCap_size:%d\n",
-		entry->hdr.type, entry->hdr.mask, size, entry->hdr.cap_size);
-		dev_info(dev, "Aborting further dump capture\n");
-		ret = 0;
-	}
-	return ret;
-}
-
-int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
-{
-	u32 *buffer;
-	char mesg[64];
-	char *msg[] = {mesg, NULL};
-	int i, k, ops_cnt, ops_index, dump_size = 0;
-	u32 entry_offset, dump, no_entries, buf_offset = 0;
-	struct qlcnic_dump_entry *entry;
-	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
-	struct qlcnic_dump_template_hdr *tmpl_hdr = fw_dump->tmpl_hdr;
-
-	if (fw_dump->clr) {
-		dev_info(&adapter->pdev->dev,
-			"Previous dump not cleared, not capturing dump\n");
-		return -EIO;
-	}
-	/* Calculate the size for dump data area only */
-	for (i = 2, k = 1; (i & QLCNIC_DUMP_MASK_MAX); i <<= 1, k++)
-		if (i & tmpl_hdr->drv_cap_mask)
-			dump_size += tmpl_hdr->cap_sizes[k];
-	if (!dump_size)
-		return -EIO;
-
-	fw_dump->data = vzalloc(dump_size);
-	if (!fw_dump->data) {
-		dev_info(&adapter->pdev->dev,
-			"Unable to allocate (%d KB) for fw dump\n",
-			dump_size/1024);
-		return -ENOMEM;
-	}
-	buffer = fw_dump->data;
-	fw_dump->size = dump_size;
-	no_entries = tmpl_hdr->num_entries;
-	ops_cnt = ARRAY_SIZE(fw_dump_ops);
-	entry_offset = tmpl_hdr->offset;
-	tmpl_hdr->sys_info[0] = QLCNIC_DRIVER_VERSION;
-	tmpl_hdr->sys_info[1] = adapter->fw_version;
-
-	for (i = 0; i < no_entries; i++) {
-		entry = (void *)tmpl_hdr + entry_offset;
-		if (!(entry->hdr.mask & tmpl_hdr->drv_cap_mask)) {
-			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
-			entry_offset += entry->hdr.offset;
-			continue;
-		}
-		/* Find the handler for this entry */
-		ops_index = 0;
-		while (ops_index < ops_cnt) {
-			if (entry->hdr.type == fw_dump_ops[ops_index].opcode)
-				break;
-			ops_index++;
-		}
-		if (ops_index == ops_cnt) {
-			dev_info(&adapter->pdev->dev,
-				"Invalid entry type %d, exiting dump\n",
-				entry->hdr.type);
-			goto error;
-		}
-		/* Collect dump for this entry */
-		dump = fw_dump_ops[ops_index].handler(adapter, entry, buffer);
-		if (dump && !qlcnic_valid_dump_entry(&adapter->pdev->dev, entry,
-			dump))
-			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
-		buf_offset += entry->hdr.cap_size;
-		entry_offset += entry->hdr.offset;
-		buffer = fw_dump->data + buf_offset;
-	}
-	if (dump_size != buf_offset) {
-		dev_info(&adapter->pdev->dev,
-			"Captured(%d) and expected size(%d) do not match\n",
-			buf_offset, dump_size);
-		goto error;
-	} else {
-		fw_dump->clr = 1;
-		snprintf(mesg, sizeof(mesg), "FW_DUMP=%s",
-			adapter->netdev->name);
-		dev_info(&adapter->pdev->dev, "Dump data, %d bytes captured\n",
-			fw_dump->size);
-		/* Send a udev event to notify availability of FW dump */
-		kobject_uevent_env(&adapter->pdev->dev.kobj, KOBJ_CHANGE, msg);
-		return 0;
-	}
-error:
-	vfree(fw_dump->data);
-	return -EINVAL;
-}
-
 void qlcnic_get_func_no(struct qlcnic_adapter *adapter)
 {
 	void __iomem *msix_base_addr;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index 17cbe9c..d39c86b 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1173,24 +1173,3 @@ qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 	sds_ring->consumer = consumer;
 	writel(consumer, sds_ring->crb_sts_consumer);
 }
-
-void
-qlcnic_fetch_mac(struct qlcnic_adapter *adapter, u32 off1, u32 off2,
-			u8 alt_mac, u8 *mac)
-{
-	u32 mac_low, mac_high;
-	int i;
-
-	mac_low = off1;
-	mac_high = off2;
-
-	if (alt_mac) {
-		mac_low |= (mac_low >> 16) | (mac_high << 16);
-		mac_high >>= 16;
-	}
-
-	for (i = 0; i < 2; i++)
-		mac[i] = (u8)(mac_high >> ((1 - i) * 8));
-	for (i = 2; i < 6; i++)
-		mac[i] = (u8)(mac_low >> ((5 - i) * 8));
-}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index bd70845..05a2abf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -749,9 +749,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 				adapter->fw_version > prev_fw_version) {
 			if (fw_dump->tmpl_hdr)
 				vfree(fw_dump->tmpl_hdr);
-			if (!qlcnic_fw_cmd_get_minidump_temp(adapter))
-				dev_info(&pdev->dev,
-					"Supports FW dump capability\n");
 		}
 	}
 
@@ -2410,7 +2407,6 @@ skip_ack_check:
 		if (ahw->fw_dump.enable &&
 		    (adapter->flags & QLCNIC_FW_RESET_OWNER)) {
 			QLCDB(adapter, DRV, "Take FW dump\n");
-			qlcnic_dump_fw(adapter);
 			adapter->flags |= QLCNIC_FW_HANG;
 		}
 		rtnl_unlock();
-- 
1.7.1
