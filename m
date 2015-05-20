From: "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 5/7] fjes: Implement lower layer of network driver
 functionality
Date: Wed, 20 May 2015 08:21:12 +0000
Message-ID: <E86EADE93E2D054CBCD4E708C38D364A5422D874@G01JPEXMBYT01>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: "Hart, Darren" <darren.hart@intel.com>,
	"rkhan@redhat.com" <rkhan@redhat.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>
To: "platform-driver-x86@vger.kernel.org"
	<platform-driver-x86@vger.kernel.org>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
Content-Language: ja-JP
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/platform/x86/fjes/Makefile    |   2 +-
 drivers/platform/x86/fjes/fjes_hw.c   | 944 ++++++++++++++++++++++++++++++++++
 drivers/platform/x86/fjes/fjes_hw.h   | 319 ++++++++++++
 drivers/platform/x86/fjes/fjes_main.c |   8 +
 drivers/platform/x86/fjes/fjes_regs.h |  12 +
 5 files changed, 1284 insertions(+), 1 deletion(-)
 create mode 100644 drivers/platform/x86/fjes/fjes_hw.c

diff --git a/drivers/platform/x86/fjes/Makefile b/drivers/platform/x86/fjes/Makefile
index 98e59cb..a67f65d8 100644
--- a/drivers/platform/x86/fjes/Makefile
+++ b/drivers/platform/x86/fjes/Makefile
@@ -27,5 +27,5 @@
 
 obj-$(CONFIG_FUJITSU_ES) += fjes.o
 
-fjes-objs := fjes_main.o
+fjes-objs := fjes_main.o fjes_hw.o
 
diff --git a/drivers/platform/x86/fjes/fjes_hw.c b/drivers/platform/x86/fjes/fjes_hw.c
new file mode 100644
index 0000000..4431aba
--- /dev/null
+++ b/drivers/platform/x86/fjes/fjes_hw.c
@@ -0,0 +1,944 @@
+/*
+ *  FUJITSU Extended Socket Network Device driver
+ *  Copyright (c) 2015 FUJITSU LIMITED
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, see <http://www.gnu.org/licenses/>.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ */
+
+#include "fjes_hw.h"
+#include "fjes.h"
+
+u32 fjes_hw_rd32(struct fjes_hw *hw, u32 reg)
+{
+	u8 *base = hw->base;
+	u32 value = 0;
+
+	value = readl(&base[reg]);
+
+	return value;
+}
+
+static u8 *fjes_hw_iomap(struct fjes_hw *hw)
+{
+	u8 *base;
+
+	if (!request_mem_region(hw->hw_res.start, hw->hw_res.size,
+			fjes_driver_name)) {
+		pr_err("request_mem_region failed");
+		return NULL;
+	}
+
+	base = (u8 *)ioremap_nocache(hw->hw_res.start, hw->hw_res.size);
+
+	return base;
+}
+
+static void fjes_hw_iounmap(struct fjes_hw *hw)
+{
+	iounmap(hw->base);
+	release_mem_region(hw->hw_res.start, hw->hw_res.size);
+}
+
+
+int fjes_hw_reset(struct fjes_hw *hw)
+{
+
+	int timeout;
+	union REG_DCTL dctl;
+
+	dctl.Reg = 0;
+	dctl.Bits.reset = 1;
+	wr32(XSCT_DCTL, dctl.Reg);
+
+
+	timeout = FJES_DEVICE_RESET_TIMEOUT * 1000;
+	dctl.Reg = rd32(XSCT_DCTL);
+	while ((dctl.Bits.reset == 1) && (timeout > 0)) {
+		msleep(1000);
+		dctl.Reg = rd32(XSCT_DCTL);
+		timeout -= 1000;
+	}
+
+	return timeout >= 0 ? 0 : -EIO;
+
+}
+
+static int fjes_hw_get_max_epid(struct fjes_hw *hw)
+{
+	union REG_MAX_EP info;
+
+	info.Reg = rd32(XSCT_MAX_EP);
+
+	return info.Bits.maxep;
+}
+
+static int fjes_hw_get_my_epid(struct fjes_hw *hw)
+{
+	union REG_OWNER_EPID info;
+
+	info.Reg = rd32(XSCT_OWNER_EPID);
+
+	return info.Bits.epid;
+}
+
+static int fjes_hw_alloc_shared_status_region(struct fjes_hw *hw)
+{
+	size_t size;
+
+	size = sizeof(struct fjes_device_shared_info) +
+	    (sizeof(u8) * hw->max_epid);
+	hw->hw_info.share = kzalloc(size, GFP_KERNEL);
+	if (!hw->hw_info.share)
+		return -ENOMEM;
+
+	hw->hw_info.share->epnum = hw->max_epid;
+
+	return 0;
+}
+
+static void fjes_hw_free_shared_status_region(struct fjes_hw *hw)
+{
+	kfree(hw->hw_info.share);
+	hw->hw_info.share = NULL;
+}
+
+static int fjes_hw_alloc_epbuf(struct epbuf_handler *epbh)
+{
+	void *mem;
+
+	mem = vmalloc(EP_BUFFER_SIZE);
+	if (!mem)
+		return -ENOMEM;
+	memset(mem, 0, EP_BUFFER_SIZE);
+
+	epbh->buffer = mem;
+	epbh->size = EP_BUFFER_SIZE;
+
+	epbh->info = (union ep_buffer_info *)mem;
+	epbh->ring = (u8 *) (mem + sizeof(union ep_buffer_info));
+
+	return 0;
+}
+
+static void fjes_hw_free_epbuf(struct epbuf_handler *epbh)
+{
+	if (epbh->buffer)
+		vfree(epbh->buffer);
+
+	epbh->buffer = NULL;
+	epbh->size = 0;
+
+	epbh->info = NULL;
+	epbh->ring = NULL;
+}
+
+
+void fjes_hw_setup_epbuf(struct epbuf_handler *epbh, u8 *mac_addr, u32 mtu)
+{
+
+	union ep_buffer_info *info = epbh->info;
+	int i;
+	u16 vlan_id[EP_BUFFER_SUPPORT_VLAN_MAX];
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++)
+		vlan_id[i] = info->v1i.vlan_id[i];
+
+	memset((void *)info, 0, sizeof(union ep_buffer_info));
+
+	info->v1i.version = 0;  /* version 0 */
+
+	for (i = 0; i < ETH_ALEN; i++)
+		info->v1i.mac_addr[i] = mac_addr[i];
+
+	info->v1i.head = 0;
+	info->v1i.tail = 1;
+
+	info->v1i.info_size = sizeof(union ep_buffer_info);
+	info->v1i.buffer_size = epbh->size - info->v1i.info_size;
+
+	info->v1i.frame_max = FJES_MTU_TO_FRAME_SIZE(mtu);
+	info->v1i.count_max =
+	    EP_RING_NUM(info->v1i.buffer_size, info->v1i.frame_max);
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++)
+		info->v1i.vlan_id[i] = vlan_id[i];
+
+}
+
+
+void fjes_hw_init_command_registers(struct fjes_hw *hw,
+		struct fjes_device_command_param *param)
+{
+
+	/* Request Buffer length */
+	wr32(XSCT_REQBL, (__le32)(param->req_len));
+	/* Response Buffer Length */
+	wr32(XSCT_RESPBL, (__le32)(param->res_len));
+
+	/* Request Buffer Address */
+	wr32(XSCT_REQBAL,
+		(__le32)(param->req_start & GENMASK_ULL(31, 0)));
+	wr32(XSCT_REQBAH,
+		(__le32)((param->req_start & GENMASK_ULL(63, 32)) >> 32));
+
+	/* Response Buffer Address */
+	wr32(XSCT_RESPBAL,
+		(__le32)(param->res_start & GENMASK_ULL(31, 0)));
+	wr32(XSCT_RESPBAH,
+		(__le32)((param->res_start & GENMASK_ULL(63, 32)) >> 32));
+
+	/* Share status address */
+	wr32(XSCT_SHSTSAL,
+		(__le32)(param->share_start & GENMASK_ULL(31, 0)));
+	wr32(XSCT_SHSTSAH,
+		(__le32)((param->share_start & GENMASK_ULL(63, 32)) >> 32));
+}
+
+
+static int fjes_hw_setup(struct fjes_hw *hw)
+{
+	int epidx;
+	void *buf;
+	struct ep_share_mem_info *buf_pair;
+	size_t mem_size;
+	int result;
+	u8 mac[ETH_ALEN] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
+	struct fjes_device_command_param param;
+
+	hw->hw_info.max_epid = &(hw->max_epid);
+	hw->hw_info.my_epid = &(hw->my_epid);
+
+
+	mem_size = sizeof(struct ep_share_mem_info) * (hw->max_epid);
+	buf = kzalloc(mem_size, GFP_KERNEL);
+	if (!buf)
+		return -ENOMEM;
+
+	hw->ep_shm_info = (struct ep_share_mem_info *)buf;
+
+	mem_size = FJES_DEV_REQ_BUF_SIZE(hw->max_epid);
+	hw->hw_info.req_buf = kzalloc(mem_size, GFP_KERNEL);
+	if (!(hw->hw_info.req_buf))
+		return -ENOMEM;
+
+	hw->hw_info.req_buf_size = mem_size;
+
+	mem_size = FJES_DEV_RES_BUF_SIZE(hw->max_epid);
+	hw->hw_info.res_buf = kzalloc(mem_size, GFP_KERNEL);
+	if (!(hw->hw_info.res_buf))
+		return -ENOMEM;
+
+	hw->hw_info.res_buf_size = mem_size;
+
+	result = fjes_hw_alloc_shared_status_region(hw);
+	if (result)
+		return result;
+
+	hw->hw_info.buffer_share_bit = 0;
+	hw->hw_info.buffer_unshare_reserve_bit = 0;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx != hw->my_epid) {
+			buf_pair = &(hw->ep_shm_info[epidx]);
+
+			result = fjes_hw_alloc_epbuf(&(buf_pair->tx));
+			if (result)
+				return result;
+
+			result = fjes_hw_alloc_epbuf(&(buf_pair->rx));
+			if (result)
+				return result;
+
+			fjes_hw_setup_epbuf(&(buf_pair->tx), mac,
+						  fjes_support_mtu[0]);
+			fjes_hw_setup_epbuf(&(buf_pair->rx), mac,
+						  fjes_support_mtu[0]);
+		}
+	}
+
+	memset((void *)&param, 0, sizeof(param));
+
+	param.req_len = hw->hw_info.req_buf_size;
+	param.req_start = __pa(hw->hw_info.req_buf);
+	param.res_len = hw->hw_info.res_buf_size;
+	param.res_start = __pa(hw->hw_info.res_buf);
+
+	param.share_start = __pa(hw->hw_info.share->ep_status);
+
+	fjes_hw_init_command_registers(hw, &param);
+
+	return 0;
+}
+
+static void fjes_hw_cleanup(struct fjes_hw *hw)
+{
+	int epidx;
+
+	if (!hw->ep_shm_info)
+		return;
+
+	fjes_hw_free_shared_status_region(hw);
+
+	kfree(hw->hw_info.req_buf);
+	hw->hw_info.req_buf = NULL;
+
+	kfree(hw->hw_info.res_buf);
+	hw->hw_info.res_buf = NULL;
+
+	for (epidx = 0; epidx < hw->max_epid ; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+		fjes_hw_free_epbuf(&hw->ep_shm_info[epidx].tx);
+		fjes_hw_free_epbuf(&hw->ep_shm_info[epidx].rx);
+	}
+
+	kfree(hw->ep_shm_info);
+	hw->ep_shm_info = NULL;
+
+}
+
+
+int fjes_hw_init(struct fjes_hw *hw)
+{
+	int ret;
+
+	hw->base = fjes_hw_iomap(hw);
+	if (hw->base == NULL)
+		return -EIO;
+
+	ret = fjes_hw_reset(hw);
+	if (ret)
+		return ret;
+
+	fjes_hw_set_irqmask(hw, REG_ICTL_MASK_ALL, true);
+
+	mutex_init(&hw->hw_info.lock);
+
+	hw->max_epid = fjes_hw_get_max_epid(hw);
+	hw->my_epid = fjes_hw_get_my_epid(hw);
+
+	if ((hw->max_epid == 0) || (hw->my_epid >= hw->max_epid))
+		return -ENXIO;
+
+	ret = fjes_hw_setup(hw);
+
+	return ret;
+}
+
+void fjes_hw_exit(struct fjes_hw *hw)
+{
+	int ret;
+
+	if (hw->base) {
+		ret = fjes_hw_reset(hw);
+		if (ret)
+			pr_err("%s: reset error", __func__);
+
+		fjes_hw_iounmap(hw);
+		hw->base = NULL;
+	}
+
+	fjes_hw_cleanup(hw);
+}
+
+static enum fjes_dev_command_response_e fjes_hw_issue_request_command(
+	struct fjes_hw *hw, enum fjes_dev_command_request_type type)
+{
+	union REG_CR cr;
+	union REG_CS cs;
+	enum fjes_dev_command_response_e ret = FJES_CMD_STATUS_UNKNOWN;
+	int timeout;
+
+	cr.Reg = 0;
+	cr.Bits.req_start = 1;
+	cr.Bits.req_code = type;
+	wr32(XSCT_CR, cr.Reg);
+	cr.Reg = rd32(XSCT_CR);
+
+	if (cr.Bits.error == 0) {
+		timeout = FJES_COMMAND_REQ_TIMEOUT * 1000;
+		cs.Reg = rd32(XSCT_CS);
+
+		while ((cs.Bits.complete != 1) && timeout > 0) {
+			msleep(1000);
+			cs.Reg = rd32(XSCT_CS);
+			timeout -= 1000;
+		}
+
+		if (cs.Bits.complete == 1)
+			ret = FJES_CMD_STATUS_NORMAL;
+		else if (timeout <= 0)
+			ret = FJES_CMD_STATUS_TIMEOUT;
+
+	} else {
+		switch (cr.Bits.err_info) {
+		case FJES_CMD_REQ_ERR_INFO_PARAM:
+			ret = FJES_CMD_STATUS_ERROR_PARAM;
+			break;
+		case FJES_CMD_REQ_ERR_INFO_STATUS:
+			ret = FJES_CMD_STATUS_ERROR_STATUS;
+			break;
+		default:
+			ret = FJES_CMD_STATUS_UNKNOWN;
+			break;
+		}
+	}
+
+	return ret;
+}
+
+
+int fjes_hw_request_info(struct fjes_hw *hw)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int result;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->info.length = FJES_DEV_COMMAND_INFO_REQ_LEN;
+
+	res_buf->info.length = 0;
+	res_buf->info.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_INFO);
+
+	result = 0;
+
+	if (FJES_DEV_COMMAND_INFO_RES_LEN((*(hw->hw_info.max_epid))) !=
+		res_buf->info.length) {
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+
+		switch (res_buf->info.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_ERROR_STATUS:
+			result = -EPERM;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+int fjes_hw_register_buff_addr(struct fjes_hw *hw, int dest_epid,
+		struct ep_share_mem_info *buf_pair)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	enum fjes_dev_command_response_e ret;
+	int i, idx;
+	int page_count;
+	void *addr;
+	int timeout;
+	int result;
+
+	if (test_bit(dest_epid, &hw->hw_info.buffer_share_bit))
+		return 0;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->share_buffer.length =
+		FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(buf_pair->tx.size,
+				buf_pair->rx.size);
+	req_buf->share_buffer.epid = dest_epid;
+
+	idx = 0;
+	req_buf->share_buffer.buffer[idx++] = buf_pair->tx.size;
+	page_count = buf_pair->tx.size / EP_BUFFER_INFO_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)(buf_pair->tx.buffer)) +
+				(i * EP_BUFFER_INFO_SIZE);
+		req_buf->share_buffer.buffer[idx++] =
+				(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+						offset_in_page(addr));
+	}
+
+	req_buf->share_buffer.buffer[idx++] = buf_pair->rx.size;
+	page_count = buf_pair->rx.size / EP_BUFFER_INFO_SIZE;
+	for (i = 0; i < page_count; i++) {
+		addr = ((u8 *)(buf_pair->rx.buffer)) +
+				(i * EP_BUFFER_INFO_SIZE);
+		req_buf->share_buffer.buffer[idx++] =
+				(__le64)(page_to_phys(vmalloc_to_page(addr)) +
+						offset_in_page(addr));
+	}
+
+	res_buf->share_buffer.length = 0;
+	res_buf->share_buffer.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_SHARE_BUFFER);
+
+	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
+	while ((ret == FJES_CMD_STATUS_NORMAL) &&
+		   (res_buf->share_buffer.length ==
+				   FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN) &&
+		   (res_buf->share_buffer.code == FJES_CMD_REQ_RES_CODE_BUSY) &&
+		   (timeout > 0)) {
+
+			msleep(200 + hw->my_epid * 20);
+			timeout -= (200 + hw->my_epid * 20);
+
+			res_buf->share_buffer.length = 0;
+			res_buf->share_buffer.code = 0;
+
+			ret = fjes_hw_issue_request_command(hw,
+					FJES_CMD_REQ_SHARE_BUFFER);
+	}
+
+	result = 0;
+
+	if (res_buf->share_buffer.length !=
+			FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN)
+		result = -ENOMSG;
+	else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->share_buffer.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			set_bit(dest_epid, &hw->hw_info.buffer_share_bit);
+			break;
+		case FJES_CMD_REQ_RES_CODE_BUSY:
+			result = -EBUSY;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+
+int fjes_hw_unregister_buff_addr(struct fjes_hw *hw, int dest_epid)
+{
+	union fjes_device_command_req *req_buf = hw->hw_info.req_buf;
+	union fjes_device_command_res *res_buf = hw->hw_info.res_buf;
+	struct fjes_device_shared_info *share = hw->hw_info.share;
+	enum fjes_dev_command_response_e ret;
+	int result;
+	int timeout;
+
+
+	if (!hw->base)
+		return -EPERM;
+
+	if (req_buf == NULL || res_buf == NULL || share == NULL)
+		return -EPERM;
+
+	if (!test_bit(dest_epid, &hw->hw_info.buffer_share_bit))
+		return 0;
+
+	memset(req_buf, 0, hw->hw_info.req_buf_size);
+	memset(res_buf, 0, hw->hw_info.res_buf_size);
+
+	req_buf->unshare_buffer.length =
+			FJES_DEV_COMMAND_UNSHARE_BUFFER_REQ_LEN;
+	req_buf->unshare_buffer.epid = dest_epid;
+
+	res_buf->unshare_buffer.length = 0;
+	res_buf->unshare_buffer.code = 0;
+
+	ret = fjes_hw_issue_request_command(hw, FJES_CMD_REQ_UNSHARE_BUFFER);
+
+	timeout = FJES_COMMAND_REQ_BUFF_TIMEOUT * 1000;
+	while ((ret == FJES_CMD_STATUS_NORMAL) &&
+		   (res_buf->unshare_buffer.length ==
+				FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN) &&
+		   (res_buf->unshare_buffer.code ==
+				FJES_CMD_REQ_RES_CODE_BUSY) &&
+		   (timeout > 0)) {
+
+		msleep(200 + hw->my_epid * 20);
+			timeout -= (200 + hw->my_epid * 20);
+
+		res_buf->unshare_buffer.length = 0;
+		res_buf->unshare_buffer.code = 0;
+
+		ret = fjes_hw_issue_request_command(hw,
+				FJES_CMD_REQ_UNSHARE_BUFFER);
+	}
+
+	result = 0;
+
+	if (res_buf->unshare_buffer.length !=
+			FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN) {
+		result = -ENOMSG;
+	} else if (ret == FJES_CMD_STATUS_NORMAL) {
+		switch (res_buf->unshare_buffer.code) {
+		case FJES_CMD_REQ_RES_CODE_NORMAL:
+			result = 0;
+			clear_bit(dest_epid, &hw->hw_info.buffer_share_bit);
+			break;
+		case FJES_CMD_REQ_RES_CODE_BUSY:
+			result = -EBUSY;
+			break;
+		default:
+			result = -EPERM;
+			break;
+		}
+	} else {
+		switch (ret) {
+		case FJES_CMD_STATUS_UNKNOWN:
+			result = -EPERM;
+			break;
+		case FJES_CMD_STATUS_TIMEOUT:
+			result = -EBUSY;
+			break;
+		case FJES_CMD_STATUS_ERROR_PARAM:
+		case FJES_CMD_STATUS_ERROR_STATUS:
+		default:
+			result = -EPERM;
+			break;
+		}
+	}
+
+	return result;
+}
+
+
+int fjes_hw_raise_interrupt(struct fjes_hw *hw, int dest_epid,
+		enum REG_ICTL_MASK  mask)
+{
+	u32 ig = mask | dest_epid;
+
+	wr32(XSCT_IG, cpu_to_le32(ig));
+
+	return 0;
+}
+
+u32 fjes_hw_capture_interrupt_status(struct fjes_hw *hw)
+{
+	u32 cur_is;
+
+	cur_is = rd32(XSCT_IS);
+
+	return cur_is;
+}
+
+void fjes_hw_set_irqmask(struct fjes_hw *hw, enum REG_ICTL_MASK intr_mask,
+		bool mask)
+{
+	if (mask)
+		wr32(XSCT_IMS, intr_mask);
+	else
+		wr32(XSCT_IMC, intr_mask);
+}
+
+
+bool fjes_hw_epid_is_same_zone(struct fjes_hw *hw, int epid)
+{
+	if (epid >= hw->max_epid)
+		return false;
+
+	if ((hw->ep_shm_info[epid].es_status !=
+			FJES_ZONING_STATUS_ENABLE) ||
+		(hw->ep_shm_info[hw->my_epid].zone ==
+			FJES_ZONING_ZONE_TYPE_NONE))
+		return false;
+	else
+		return (hw->ep_shm_info[epid].zone ==
+				hw->ep_shm_info[hw->my_epid].zone);
+
+}
+
+
+int fjes_hw_epid_is_shared(struct fjes_device_shared_info *share,
+		int dest_epid)
+{
+	int value = false;
+
+	if (dest_epid < share->epnum)
+		value = share->ep_status[dest_epid];
+
+	return value;
+}
+
+static bool fjes_hw_epid_is_stop_requested(struct fjes_hw *hw, int src_epid)
+{
+	return test_bit(src_epid, &hw->txrx_stop_req_bit);
+}
+
+static bool fjes_hw_epid_is_stop_process_done(struct fjes_hw *hw, int src_epid)
+{
+	return (hw->ep_shm_info[src_epid].tx.info->v1i.rx_status &
+			FJES_RX_STOP_REQ_DONE);
+}
+
+enum ep_partner_status
+fjes_hw_get_partner_ep_status(struct fjes_hw *hw, int epid)
+{
+	enum ep_partner_status status;
+
+	if (fjes_hw_epid_is_shared(hw->hw_info.share, epid)) {
+		if (fjes_hw_epid_is_stop_requested(hw, epid))
+			status = EP_PARTNER_WAITING;
+		else {
+			if (fjes_hw_epid_is_stop_process_done(hw, epid))
+				status = EP_PARTNER_COMPLETE;
+			else
+				status = EP_PARTNER_SHARED;
+		}
+	} else {
+		status = EP_PARTNER_UNSHARE;
+	}
+
+	return status;
+}
+
+
+void fjes_hw_raise_epstop(struct fjes_hw *hw)
+{
+	int epidx;
+	enum ep_partner_status status;
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+
+		status = fjes_hw_get_partner_ep_status(hw, epidx);
+		switch (status) {
+		case EP_PARTNER_SHARED:
+			fjes_hw_raise_interrupt(hw, epidx,
+					REG_ICTL_MASK_TXRX_STOP_REQ);
+			break;
+		default:
+			break;
+		}
+
+		set_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit);
+		set_bit(epidx, &hw->txrx_stop_req_bit);
+
+		hw->ep_shm_info[epidx].tx.info->v1i.rx_status |=
+				FJES_RX_STOP_REQ_REQUEST;
+
+	}
+
+}
+
+int fjes_hw_wait_epstop(struct fjes_hw *hw)
+{
+	int epidx;
+	int wait_time = 0;
+	enum ep_partner_status status;
+	union ep_buffer_info *info;
+
+	while (hw->hw_info.buffer_unshare_reserve_bit &&
+		   (wait_time < FJES_COMMAND_EPSTOP_WAIT_TIMEOUT * 1000)) {
+
+		for (epidx = 0; epidx < hw->max_epid; epidx++) {
+			if (epidx == hw->my_epid)
+				continue;
+			status = fjes_hw_epid_is_shared(hw->hw_info.share,
+					epidx);
+			info = hw->ep_shm_info[epidx].rx.info;
+			if ((!status ||
+				 (info->v1i.rx_status &
+					FJES_RX_STOP_REQ_DONE)) &&
+				test_bit(epidx,
+				 &hw->hw_info.buffer_unshare_reserve_bit)) {
+				clear_bit(epidx,
+				 &hw->hw_info.buffer_unshare_reserve_bit);
+			}
+		}
+
+		msleep(100);
+		wait_time += 100;
+
+	}
+
+	for (epidx = 0; epidx < hw->max_epid; epidx++) {
+		if (epidx == hw->my_epid)
+			continue;
+		if (test_bit(epidx, &hw->hw_info.buffer_unshare_reserve_bit))
+			clear_bit(epidx,
+				&hw->hw_info.buffer_unshare_reserve_bit);
+	}
+
+	return (wait_time < FJES_COMMAND_EPSTOP_WAIT_TIMEOUT * 1000)
+			? 0 : -EBUSY;
+}
+
+
+bool fjes_hw_check_epbuf_version(struct epbuf_handler *epbh, u32 version)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	return (info->common.version == version);
+}
+
+bool fjes_hw_check_mtu(struct epbuf_handler *epbh, u32 mtu)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	return (info->v1i.frame_max == FJES_MTU_TO_FRAME_SIZE(mtu));
+}
+
+bool fjes_hw_check_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+	bool ret = false;
+
+	if (vlan_id == 0) {
+		ret = true;
+	} else {
+		for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+			if (vlan_id == info->v1i.vlan_id[i]) {
+				ret = true;
+				break;
+			}
+		}
+	}
+	return ret;
+}
+
+
+bool fjes_hw_set_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+		if (info->v1i.vlan_id[i] == 0) {
+			info->v1i.vlan_id[i] = vlan_id;
+			return true;
+		}
+	}
+	return false;
+}
+
+void fjes_hw_del_vlan_id(struct epbuf_handler *epbh, u16 vlan_id)
+{
+	union ep_buffer_info *info = epbh->info;
+	int i;
+
+	if (0 != vlan_id) {
+		for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++) {
+			if (vlan_id == info->v1i.vlan_id[i])
+				info->v1i.vlan_id[i] = 0;
+		}
+	}
+}
+
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *epbh)
+{
+	union ep_buffer_info *info;
+	static bool log_output;
+
+	info = epbh->info;
+
+	if (info->v1i.count_max == 0) {
+		if (false == log_output)
+			log_output = true;
+		return true;
+	}
+	return EP_RING_EMPTY(info->v1i.head, info->v1i.tail,
+			info->v1i.count_max);
+}
+
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *epbh,
+	size_t *psize)
+{
+	union ep_buffer_info *info = epbh->info;
+	struct esmem_frame_t *ring_frame;
+	void *frame;
+
+	ring_frame =
+	    (struct esmem_frame_t *)
+		  &(epbh->ring[EP_RING_INDEX(info->v1i.head,
+			info->v1i.count_max) *
+			info->v1i.frame_max]);
+
+	*psize = (size_t) ring_frame->frame_size;
+
+	frame = ring_frame->frame_data;
+
+	return frame;
+}
+
+void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *epbh)
+{
+	union ep_buffer_info *info = epbh->info;
+
+	if (fjes_hw_epbuf_rx_is_empty(epbh))
+		return;
+
+	EP_RING_INDEX_INC(epbh->info->v1i.head, info->v1i.count_max);
+}
+
+int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *epbh,
+		void *frame, size_t size)
+{
+	union ep_buffer_info *info = epbh->info;
+	struct esmem_frame_t *ring_frame;
+
+	if (EP_RING_FULL(info->v1i.head, info->v1i.tail, info->v1i.count_max))
+		return -ENOBUFS;
+
+	ring_frame =
+	    (struct esmem_frame_t *)&(epbh->
+				      ring[EP_RING_INDEX
+					   (info->v1i.tail - 1,
+					    info->v1i.count_max) *
+					   info->v1i.frame_max]);
+
+	ring_frame->frame_size = size;
+	memcpy((void *)(ring_frame->frame_data), (void *)frame, size);
+
+	EP_RING_INDEX_INC(epbh->info->v1i.tail, info->v1i.count_max);
+
+	return 0;
+}
+
diff --git a/drivers/platform/x86/fjes/fjes_hw.h b/drivers/platform/x86/fjes/fjes_hw.h
index c5cc4c5..3c95522 100644
--- a/drivers/platform/x86/fjes/fjes_hw.h
+++ b/drivers/platform/x86/fjes/fjes_hw.h
@@ -27,5 +27,324 @@
 
 #include "fjes_regs.h"
 
+struct fjes_hw;
+
+#define EP_BUFFER_SUPPORT_VLAN_MAX 4
+#define EP_BUFFER_INFO_SIZE 4096
+
+
+/* Frame & MTU */
+struct esmem_frame_t {
+	__le32 frame_size;
+	u8 frame_data[];
+};
+
+#define FJES_MTU_TO_BUFFER_SIZE(mtu) \
+	(ETH_HLEN + VLAN_HLEN + (mtu) + ETH_FCS_LEN)
+#define FJES_MTU_TO_FRAME_SIZE(mtu) \
+	(sizeof(struct esmem_frame_t) + FJES_MTU_TO_BUFFER_SIZE(mtu))
+#define FJES_MTU_DEFINE(size) \
+	((size) - sizeof(struct esmem_frame_t) - \
+	(ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+
+enum ep_partner_status {
+	EP_PARTNER_UNSHARE,
+	EP_PARTNER_SHARED,
+	EP_PARTNER_WAITING,
+	EP_PARTNER_COMPLETE,
+	EP_PARTNER_STATUS_MAX,
+};
+
+
+#define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
+#define FJES_COMMAND_REQ_TIMEOUT  (5 + 1) /* sec */
+#define FJES_COMMAND_REQ_BUFF_TIMEOUT	(8 * 3) /* sec */
+#define FJES_COMMAND_EPSTOP_WAIT_TIMEOUT	(1) /* sec */
+
+
+/* shared status region */
+struct fjes_device_shared_info {
+	int epnum;
+	u8 ep_status[];
+};
+
+/* structures for command control request data*/
+
+union fjes_device_command_req {
+	struct {
+		__le32 length;
+	} info;
+	struct {
+		__le32 length;
+		__le32 epid;
+		__le64 buffer[];
+	} share_buffer;
+	struct {
+		__le32 length;
+		__le32 epid;
+	} unshare_buffer;
+	struct {
+		__le32 length;
+		__le32 mode;
+		__le64 buffer_len;
+		__le64 buffer[];
+	} start_trace;
+	struct {
+		__le32 length;
+	} stop_trace;
+};
+#define FJES_DEV_COMMAND_INFO_REQ_LEN	(4)
+#define FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(txb, rxb) \
+	(24 + (8 * ((txb)/EP_BUFFER_INFO_SIZE + (rxb)/EP_BUFFER_INFO_SIZE)))
+#define FJES_DEV_COMMAND_UNSHARE_BUFFER_REQ_LEN	(8)
+
+#define FJES_DEV_REQ_BUF_SIZE(maxep) \
+	FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(EP_BUFFER_SIZE, EP_BUFFER_SIZE)
+
+
+/* structures for command control response data */
+union fjes_device_command_res {
+	struct {
+		__le32 length;
+		__le32 code;
+		struct {
+			u8 es_status;
+			u8 zone;
+		} info[];
+	} info;
+	struct {
+		__le32 length;
+		__le32 code;
+	} share_buffer;
+	struct {
+		__le32 length;
+		__le32 code;
+	} unshare_buffer;
+	struct {
+		__le32 length;
+		__le32 code;
+	} start_trace;
+	struct {
+		__le32 length;
+		__le32 code;
+	} stop_trace;
+};
+
+#define FJES_DEV_COMMAND_INFO_RES_LEN(epnum) (8 + 2*(epnum))
+#define FJES_DEV_COMMAND_SHARE_BUFFER_RES_LEN	(8)
+#define FJES_DEV_COMMAND_UNSHARE_BUFFER_RES_LEN	(8)
+#define FJES_DEV_RES_BUF_SIZE(maxep) \
+		FJES_DEV_COMMAND_INFO_RES_LEN(maxep)
+
+
+
+/* request command type */
+enum fjes_dev_command_request_type {
+	FJES_CMD_REQ_INFO			= 0x0001,
+	FJES_CMD_REQ_SHARE_BUFFER	= 0x0002,
+	FJES_CMD_REQ_UNSHARE_BUFFER = 0x0004,
+};
+
+
+/* parameter for command control */
+struct fjes_device_command_param {
+	u32 req_len;
+	phys_addr_t req_start;
+	u32 res_len;
+	phys_addr_t res_start;
+	phys_addr_t share_start;
+};
+
+/* error code for command control */
+enum fjes_dev_command_response_e {
+	FJES_CMD_STATUS_UNKNOWN,
+	FJES_CMD_STATUS_NORMAL,
+	FJES_CMD_STATUS_TIMEOUT,
+	FJES_CMD_STATUS_ERROR_PARAM,
+	FJES_CMD_STATUS_ERROR_STATUS,
+};
+
+#define FJES_CMD_REQ_ERR_INFO_PARAM  (0x0001)
+#define FJES_CMD_REQ_ERR_INFO_STATUS (0x0002)
+
+#define FJES_CMD_REQ_RES_CODE_NORMAL (0)
+#define FJES_CMD_REQ_RES_CODE_BUSY   (1)
+
+#define FJES_ZONING_STATUS_DISABLE	(0x00)
+#define FJES_ZONING_STATUS_ENABLE	(0x01)
+#define FJES_ZONING_STATUS_INVALID	(0xFF)
+
+#define FJES_ZONING_ZONE_TYPE_NONE (0xFF)
+
+#define FJES_TX_DELAY_SEND_NONE		(0)
+#define FJES_TX_DELAY_SEND_PENDING	(1)
+
+#define FJES_RX_STOP_REQ_NONE		(0x0)
+#define FJES_RX_STOP_REQ_DONE		(0x1)
+#define FJES_RX_STOP_REQ_REQUEST	(0x2)
+#define FJES_RX_POLL_WORK			(0x4)
+
+
+struct es_device_trace {
+	u32 record_num;
+	u32 current_record;
+	u32 status_flag;
+	u32 _rsv;
+
+	struct {
+			u16 epid;
+			u16 dir_offset;
+			u32 data;
+			u64 tsc;
+	} record[];
+};
+
+
+union ep_buffer_info {
+	u8 raw[EP_BUFFER_INFO_SIZE];
+
+	struct _ep_buffer_info_common_t {
+		u32 version;
+	} common;
+
+	struct _ep_buffer_info_v1_t {
+		u32 version;
+		u32 info_size;
+
+		u32 buffer_size;
+		u16 count_max;
+
+		u16 _rsv_1;
+
+		u32 frame_max;
+		u8 mac_addr[ETH_ALEN];
+
+		u16 _rsv_2;
+		u32 _rsv_3;
+
+		u16 tx_status;
+		u16 rx_status;
+
+		u32 head;
+		u32 tail;
+
+		u16 vlan_id[EP_BUFFER_SUPPORT_VLAN_MAX];
+
+	} v1i;
+
+};
+
+#define EP_BUFFER_SIZE \
+	(((sizeof(union ep_buffer_info) + (128 * (64 * 1024))) \
+		/ EP_BUFFER_INFO_SIZE) * EP_BUFFER_INFO_SIZE)
+
+#define EP_RING_NUM(buffer_size, frame_size) \
+		(u32)((buffer_size) / (frame_size))
+
+#define EP_RING_INDEX(_num, _max) (((_num) + (_max)) % (_max))
+#define EP_RING_FULL(_head, _tail, _max) \
+	(0 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
+#define EP_RING_EMPTY(_head, _tail, _max) \
+	(1 == EP_RING_INDEX(((_tail) - (_head)), (_max)))
+#define EP_RING_INDEX_INC(_num, _max) \
+	((_num) = EP_RING_INDEX((_num) + 1, (_max)))
+
+
+/* buffer pair for Extended Partition */
+struct ep_share_mem_info {
+	struct epbuf_handler {
+		void *buffer;
+		size_t size;
+		union ep_buffer_info *info;
+		u8 *ring;
+	} tx, rx;
+
+	struct rtnl_link_stats64 net_stats;
+
+	u16 tx_status_work;
+
+	u8 es_status;
+	u8 zone;
+};
+
+
+struct fjes_hw_info {
+	struct fjes_device_shared_info *share;
+	union fjes_device_command_req *req_buf;
+	u64 req_buf_size;
+	union fjes_device_command_res *res_buf;
+	u64 res_buf_size;
+
+	int *my_epid;
+	int *max_epid;
+
+	struct es_device_trace *trace;
+	u64 trace_size;
+
+	struct mutex lock;
+
+	unsigned long buffer_share_bit;
+	unsigned long buffer_unshare_reserve_bit;
+};
+
+
+struct fjes_hw {
+
+	void *back;
+
+	unsigned long txrx_stop_req_bit;
+	unsigned long epstop_req_bit;
+	struct work_struct update_zone_task;
+	struct work_struct epstop_task;
+
+	int my_epid;
+	int max_epid;
+
+	struct ep_share_mem_info *ep_shm_info;
+
+	struct fjes_hw_resource {
+		u64 start;
+		u64 size;
+		int irq;
+	} hw_res;
+
+
+	u8 *base;
+
+	struct fjes_hw_info hw_info;
+};
+
+
+int fjes_hw_init(struct fjes_hw *);
+void fjes_hw_exit(struct fjes_hw *);
+int fjes_hw_reset(struct fjes_hw *);
+int fjes_hw_request_info(struct fjes_hw *);
+int fjes_hw_register_buff_addr(struct fjes_hw *, int,
+		struct ep_share_mem_info *);
+int fjes_hw_unregister_buff_addr(struct fjes_hw *, int);
+void fjes_hw_init_command_registers(struct fjes_hw *,
+		struct fjes_device_command_param *);
+void fjes_hw_setup_epbuf(struct epbuf_handler *, u8 *, u32);
+int fjes_hw_raise_interrupt(struct fjes_hw *, int, enum REG_ICTL_MASK);
+void fjes_hw_set_irqmask(struct fjes_hw *, enum REG_ICTL_MASK, bool);
+u32 fjes_hw_capture_interrupt_status(struct fjes_hw *);
+void fjes_hw_raise_epstop(struct fjes_hw *);
+int fjes_hw_wait_epstop(struct fjes_hw *);
+enum ep_partner_status
+	fjes_hw_get_partner_ep_status(struct fjes_hw *, int);
+
+bool fjes_hw_epid_is_same_zone(struct fjes_hw *, int);
+int fjes_hw_epid_is_shared(struct fjes_device_shared_info *, int);
+bool fjes_hw_check_epbuf_version(struct epbuf_handler *, u32);
+bool fjes_hw_check_mtu(struct epbuf_handler *, u32);
+bool fjes_hw_check_vlan_id(struct epbuf_handler *, u16);
+bool fjes_hw_set_vlan_id(struct epbuf_handler *, u16);
+void fjes_hw_del_vlan_id(struct epbuf_handler *, u16);
+bool fjes_hw_epbuf_rx_is_empty(struct epbuf_handler *);
+void *fjes_hw_epbuf_rx_curpkt_get_addr(struct epbuf_handler *,
+		size_t *);
+void fjes_hw_epbuf_rx_curpkt_drop(struct epbuf_handler *);
+
+int fjes_hw_epbuf_tx_pkt_send(struct epbuf_handler *, void *, size_t);
 
 #endif /* FJES_HW_H_ */
diff --git a/drivers/platform/x86/fjes/fjes_main.c b/drivers/platform/x86/fjes/fjes_main.c
index 87057b8..80aaf4d 100644
--- a/drivers/platform/x86/fjes/fjes_main.c
+++ b/drivers/platform/x86/fjes/fjes_main.c
@@ -91,6 +91,14 @@ static struct resource fjes_resource[] = {
 	},
 };
 
+u32 fjes_support_mtu[] = {
+	FJES_MTU_DEFINE(8 * 1024),
+	FJES_MTU_DEFINE(16 * 1024),
+	FJES_MTU_DEFINE(32 * 1024),
+	FJES_MTU_DEFINE(64 * 1024),
+	0
+};
+
 
 /*
  *  fjes_init_module - Driver Registration Routine
diff --git a/drivers/platform/x86/fjes/fjes_regs.h b/drivers/platform/x86/fjes/fjes_regs.h
index 8546cb5..490737b 100644
--- a/drivers/platform/x86/fjes/fjes_regs.h
+++ b/drivers/platform/x86/fjes/fjes_regs.h
@@ -135,5 +135,17 @@ enum REG_IS_MASK {
 	REG_IS_MASK_EPID		= GENMASK(15, 0),
 };
 
+struct fjes_hw;
+
+u32 fjes_hw_rd32(struct fjes_hw *hw, u32 reg);
+
+#define wr32(reg, val) \
+do { \
+	u8 *base = hw->base; \
+	writel((val), &base[(reg)]); \
+} while (0)
+
+#define rd32(reg) (fjes_hw_rd32(hw, reg))
+
 
 #endif /* FJES_REGS_H_ */
-- 
1.8.3.1
