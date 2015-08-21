From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH v3 02/22] fjes: Hardware initialization routine
Date: Fri, 21 Aug 2015 17:29:18 +0900
Message-ID: <1440145778-15941-2-git-send-email-izumi.taku@jp.fujitsu.com>
References: <1440145680-15851-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Cc: platform-driver-x86@vger.kernel.org, dvhart@infradead.org,
	rkhan@redhat.com, alexander.h.duyck@redhat.com,
	linux-acpi@vger.kernel.org, joe@perches.com,
	sergei.shtylyov@cogentembedded.com, stephen@networkplumber.org,
	yasu.isimatu@gmail.com, Taku Izumi <izumi.taku@jp.fujitsu.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <1440145778-15941-1-git-send-email-izumi.taku@jp.fujitsu.com>
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds hardware initialization routine to be
invoked at driver's .probe routine.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/fjes/Makefile    |   2 +-
 drivers/net/fjes/fjes.h      |   1 +
 drivers/net/fjes/fjes_hw.c   | 295 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_hw.h   | 251 ++++++++++++++++++++++++++++++++++++
 drivers/net/fjes/fjes_regs.h | 102 +++++++++++++++
 5 files changed, 650 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/fjes/fjes_hw.c
 create mode 100644 drivers/net/fjes/fjes_hw.h
 create mode 100644 drivers/net/fjes/fjes_regs.h

diff --git a/drivers/net/fjes/Makefile b/drivers/net/fjes/Makefile
index 34bccba..753d52f 100644
--- a/drivers/net/fjes/Makefile
+++ b/drivers/net/fjes/Makefile
@@ -27,4 +27,4 @@
 
 obj-$(CONFIG_FUJITSU_ES) += fjes.o
 
-fjes-objs := fjes_main.o
+fjes-objs := fjes_main.o fjes_hw.o
diff --git a/drivers/net/fjes/fjes.h b/drivers/net/fjes/fjes.h
index 52eb60b..15ded96 100644
--- a/drivers/net/fjes/fjes.h
+++ b/drivers/net/fjes/fjes.h
@@ -28,5 +28,6 @@
 
 extern char fjes_driver_name[];
 extern char fjes_driver_version[];
+extern const u32 fjes_support_mtu[];
 
 #endif /* FJES_H_ */
diff --git a/drivers/net/fjes/fjes_hw.c b/drivers/net/fjes/fjes_hw.c
new file mode 100644
index 0000000..ae26638
--- /dev/null
+++ b/drivers/net/fjes/fjes_hw.c
@@ -0,0 +1,295 @@
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
+/* supported MTU list */
+const u32 fjes_support_mtu[] = {
+	FJES_MTU_DEFINE(8 * 1024),
+	FJES_MTU_DEFINE(16 * 1024),
+	FJES_MTU_DEFINE(32 * 1024),
+	FJES_MTU_DEFINE(64 * 1024),
+	0
+};
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
+				fjes_driver_name)) {
+		pr_err("request_mem_region failed\n");
+		return NULL;
+	}
+
+	base = (u8 *)ioremap_nocache(hw->hw_res.start, hw->hw_res.size);
+
+	return base;
+}
+
+int fjes_hw_reset(struct fjes_hw *hw)
+{
+	union REG_DCTL dctl;
+	int timeout;
+
+	dctl.reg = 0;
+	dctl.bits.reset = 1;
+	wr32(XSCT_DCTL, dctl.reg);
+
+	timeout = FJES_DEVICE_RESET_TIMEOUT * 1000;
+	dctl.reg = rd32(XSCT_DCTL);
+	while ((dctl.bits.reset == 1) && (timeout > 0)) {
+		msleep(1000);
+		dctl.reg = rd32(XSCT_DCTL);
+		timeout -= 1000;
+	}
+
+	return timeout > 0 ? 0 : -EIO;
+}
+
+static int fjes_hw_get_max_epid(struct fjes_hw *hw)
+{
+	union REG_MAX_EP info;
+
+	info.reg = rd32(XSCT_MAX_EP);
+
+	return info.bits.maxep;
+}
+
+static int fjes_hw_get_my_epid(struct fjes_hw *hw)
+{
+	union REG_OWNER_EPID info;
+
+	info.reg = rd32(XSCT_OWNER_EPID);
+
+	return info.bits.epid;
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
+static int fjes_hw_alloc_epbuf(struct epbuf_handler *epbh)
+{
+	void *mem;
+
+	mem = vzalloc(EP_BUFFER_SIZE);
+	if (!mem)
+		return -ENOMEM;
+
+	epbh->buffer = mem;
+	epbh->size = EP_BUFFER_SIZE;
+
+	epbh->info = (union ep_buffer_info *)mem;
+	epbh->ring = (u8 *)(mem + sizeof(union ep_buffer_info));
+
+	return 0;
+}
+
+void fjes_hw_setup_epbuf(struct epbuf_handler *epbh, u8 *mac_addr, u32 mtu)
+{
+	union ep_buffer_info *info = epbh->info;
+	u16 vlan_id[EP_BUFFER_SUPPORT_VLAN_MAX];
+	int i;
+
+	for (i = 0; i < EP_BUFFER_SUPPORT_VLAN_MAX; i++)
+		vlan_id[i] = info->v1i.vlan_id[i];
+
+	memset(info, 0, sizeof(union ep_buffer_info));
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
+}
+
+void
+fjes_hw_init_command_registers(struct fjes_hw *hw,
+			       struct fjes_device_command_param *param)
+{
+	/* Request Buffer length */
+	wr32(XSCT_REQBL, (__le32)(param->req_len));
+	/* Response Buffer Length */
+	wr32(XSCT_RESPBL, (__le32)(param->res_len));
+
+	/* Request Buffer Address */
+	wr32(XSCT_REQBAL,
+	     (__le32)(param->req_start & GENMASK_ULL(31, 0)));
+	wr32(XSCT_REQBAH,
+	     (__le32)((param->req_start & GENMASK_ULL(63, 32)) >> 32));
+
+	/* Response Buffer Address */
+	wr32(XSCT_RESPBAL,
+	     (__le32)(param->res_start & GENMASK_ULL(31, 0)));
+	wr32(XSCT_RESPBAH,
+	     (__le32)((param->res_start & GENMASK_ULL(63, 32)) >> 32));
+
+	/* Share status address */
+	wr32(XSCT_SHSTSAL,
+	     (__le32)(param->share_start & GENMASK_ULL(31, 0)));
+	wr32(XSCT_SHSTSAH,
+	     (__le32)((param->share_start & GENMASK_ULL(63, 32)) >> 32));
+}
+
+static int fjes_hw_setup(struct fjes_hw *hw)
+{
+	u8 mac[ETH_ALEN] = { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
+	struct fjes_device_command_param param;
+	struct ep_share_mem_info *buf_pair;
+	size_t mem_size;
+	int result;
+	int epidx;
+	void *buf;
+
+	hw->hw_info.max_epid = &hw->max_epid;
+	hw->hw_info.my_epid = &hw->my_epid;
+
+	buf = kcalloc(hw->max_epid, sizeof(struct ep_share_mem_info),
+		      GFP_KERNEL);
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
+			buf_pair = &hw->ep_shm_info[epidx];
+
+			result = fjes_hw_alloc_epbuf(&buf_pair->tx);
+			if (result)
+				return result;
+
+			result = fjes_hw_alloc_epbuf(&buf_pair->rx);
+			if (result)
+				return result;
+
+			fjes_hw_setup_epbuf(&buf_pair->tx, mac,
+					    fjes_support_mtu[0]);
+			fjes_hw_setup_epbuf(&buf_pair->rx, mac,
+					    fjes_support_mtu[0]);
+		}
+	}
+
+	memset(&param, 0, sizeof(param));
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
+int fjes_hw_init(struct fjes_hw *hw)
+{
+	int ret;
+
+	hw->base = fjes_hw_iomap(hw);
+	if (!hw->base)
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
+void fjes_hw_set_irqmask(struct fjes_hw *hw,
+			 enum REG_ICTL_MASK intr_mask, bool mask)
+{
+	if (mask)
+		wr32(XSCT_IMS, intr_mask);
+	else
+		wr32(XSCT_IMC, intr_mask);
+}
diff --git a/drivers/net/fjes/fjes_hw.h b/drivers/net/fjes/fjes_hw.h
new file mode 100644
index 0000000..836ebe2
--- /dev/null
+++ b/drivers/net/fjes/fjes_hw.h
@@ -0,0 +1,251 @@
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
+#ifndef FJES_HW_H_
+#define FJES_HW_H_
+
+#include <linux/netdevice.h>
+#include <linux/if_vlan.h>
+#include <linux/vmalloc.h>
+
+#include "fjes_regs.h"
+
+struct fjes_hw;
+
+#define EP_BUFFER_SUPPORT_VLAN_MAX 4
+#define EP_BUFFER_INFO_SIZE 4096
+
+#define FJES_DEVICE_RESET_TIMEOUT  ((17 + 1) * 3) /* sec */
+
+#define EP_BUFFER_SIZE \
+	(((sizeof(union ep_buffer_info) + (128 * (64 * 1024))) \
+		/ EP_BUFFER_INFO_SIZE) * EP_BUFFER_INFO_SIZE)
+
+#define EP_RING_NUM(buffer_size, frame_size) \
+		(u32)((buffer_size) / (frame_size))
+
+#define FJES_MTU_TO_BUFFER_SIZE(mtu) \
+	(ETH_HLEN + VLAN_HLEN + (mtu) + ETH_FCS_LEN)
+#define FJES_MTU_TO_FRAME_SIZE(mtu) \
+	(sizeof(struct esmem_frame) + FJES_MTU_TO_BUFFER_SIZE(mtu))
+#define FJES_MTU_DEFINE(size) \
+	((size) - sizeof(struct esmem_frame) - \
+	(ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+
+#define FJES_DEV_COMMAND_INFO_RES_LEN(epnum) (8 + 2 * (epnum))
+#define FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(txb, rxb) \
+	(24 + (8 * ((txb) / EP_BUFFER_INFO_SIZE + (rxb) / EP_BUFFER_INFO_SIZE)))
+
+#define FJES_DEV_REQ_BUF_SIZE(maxep) \
+	FJES_DEV_COMMAND_SHARE_BUFFER_REQ_LEN(EP_BUFFER_SIZE, EP_BUFFER_SIZE)
+#define FJES_DEV_RES_BUF_SIZE(maxep) \
+	FJES_DEV_COMMAND_INFO_RES_LEN(maxep)
+
+/* Frame & MTU */
+struct esmem_frame {
+	__le32 frame_size;
+	u8 frame_data[];
+};
+
+/* shared status region */
+struct fjes_device_shared_info {
+	int epnum;
+	u8 ep_status[];
+};
+
+/* structures for command control request data*/
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
+/* parameter for command control */
+struct fjes_device_command_param {
+	u32 req_len;
+	phys_addr_t req_start;
+	u32 res_len;
+	phys_addr_t res_start;
+	phys_addr_t share_start;
+};
+
+/* EP buffer information */
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
+	struct mutex lock; /* buffer lock*/
+
+	unsigned long buffer_share_bit;
+	unsigned long buffer_unshare_reserve_bit;
+};
+
+struct fjes_hw {
+	void *back;
+
+	unsigned long txrx_stop_req_bit;
+	unsigned long epstop_req_bit;
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
+	u8 *base;
+
+	struct fjes_hw_info hw_info;
+};
+
+int fjes_hw_init(struct fjes_hw *);
+int fjes_hw_reset(struct fjes_hw *);
+
+void fjes_hw_init_command_registers(struct fjes_hw *,
+				    struct fjes_device_command_param *);
+void fjes_hw_setup_epbuf(struct epbuf_handler *, u8 *, u32);
+void fjes_hw_set_irqmask(struct fjes_hw *, enum REG_ICTL_MASK, bool);
+
+#endif /* FJES_HW_H_ */
diff --git a/drivers/net/fjes/fjes_regs.h b/drivers/net/fjes/fjes_regs.h
new file mode 100644
index 0000000..4d0e071
--- /dev/null
+++ b/drivers/net/fjes/fjes_regs.h
@@ -0,0 +1,102 @@
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
+#ifndef FJES_REGS_H_
+#define FJES_REGS_H_
+
+#include <linux/bitops.h>
+
+#define XSCT_DEVICE_REGISTER_SIZE 0x1000
+
+/* register offset */
+/* Information registers */
+#define XSCT_OWNER_EPID     0x0000  /* Owner EPID */
+#define XSCT_MAX_EP         0x0004  /* Maximum EP */
+
+/* Device Control registers */
+#define XSCT_DCTL           0x0010  /* Device Control */
+
+/* Command Control registers */
+#define XSCT_SHSTSAL        0x0028  /* Share status address Low */
+#define XSCT_SHSTSAH        0x002C  /* Share status address High */
+
+#define XSCT_REQBL          0x0034  /* Request Buffer length */
+#define XSCT_REQBAL         0x0038  /* Request Buffer Address Low */
+#define XSCT_REQBAH         0x003C  /* Request Buffer Address High */
+
+#define XSCT_RESPBL         0x0044  /* Response Buffer Length */
+#define XSCT_RESPBAL        0x0048  /* Response Buffer Address Low */
+#define XSCT_RESPBAH        0x004C  /* Response Buffer Address High */
+
+/* Interrupt Control registers */
+#define XSCT_IMS            0x0084  /* Interrupt mask set */
+#define XSCT_IMC            0x0088  /* Interrupt mask clear */
+
+/* register structure */
+/* Information registers */
+union REG_OWNER_EPID {
+	struct {
+		__le32 epid:16;
+		__le32:16;
+	} bits;
+	__le32 reg;
+};
+
+union REG_MAX_EP {
+	struct {
+		__le32 maxep:16;
+		__le32:16;
+	} bits;
+	__le32 reg;
+};
+
+/* Device Control registers */
+union REG_DCTL {
+	struct {
+		__le32 reset:1;
+		__le32 rsv0:15;
+		__le32 rsv1:16;
+	} bits;
+	__le32 reg;
+};
+
+enum REG_ICTL_MASK {
+	REG_ICTL_MASK_INFO_UPDATE     = 1 << 20,
+	REG_ICTL_MASK_DEV_STOP_REQ    = 1 << 19,
+	REG_ICTL_MASK_TXRX_STOP_REQ   = 1 << 18,
+	REG_ICTL_MASK_TXRX_STOP_DONE  = 1 << 17,
+	REG_ICTL_MASK_RX_DATA         = 1 << 16,
+	REG_ICTL_MASK_ALL             = GENMASK(20, 16),
+};
+
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
+#endif /* FJES_REGS_H_ */
-- 
1.8.3.1
