From: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Subject: [PATCHv3 net-next-2.6 1/3] qlcnic: FW dump support
Date: Wed, 11 May 2011 15:54:06 -0700
Message-ID: <1305154448-9687-3-git-send-email-anirban.chakraborty@qlogic.com>
References: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vpn.pathscale.com ([198.186.3.75]:60149 "HELO mx.mv.qlogic.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1754235Ab1EKXA2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 19:00:28 -0400
In-Reply-To: <1305154448-9687-1-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added code to take FW dump.
o Driver queries FW at the init time and gets the dump template
o It takes FW dump as per the dump template
o Level of FW dump (and its size) is configured via dump flag

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |  176 +++++++++++++++-
 drivers/net/qlcnic/qlcnic_ctx.c  |   91 ++++++++
 drivers/net/qlcnic/qlcnic_hdr.h  |   40 +++-
 drivers/net/qlcnic/qlcnic_hw.c   |  459 ++++++++++++++++++++++++++++++++++++++
 drivers/net/qlcnic/qlcnic_init.c |    4 +-
 drivers/net/qlcnic/qlcnic_main.c |   13 +-
 6 files changed, 774 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index f729363..689adea 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -411,6 +411,29 @@ struct qlcnic_nic_intr_coalesce {
 	u32	timer_out;
 };
 
+struct qlcnic_dump_template_hdr {
+	__le32	type;
+	__le32	offset;
+	__le32	size;
+	__le32	cap_mask;
+	__le32	num_entries;
+	__le32	version;
+	__le32	timestamp;
+	__le32	checksum;
+	__le32	drv_cap_mask;
+	__le32	sys_info[3];
+	__le32	saved_state[16];
+	__le32	cap_sizes[8];
+	__le32	rsvd[0];
+};
+
+struct qlcnic_fw_dump {
+	u8	clr;	/* flag to indicate if dump is cleared */
+	u32	size;	/* total size of the dump */
+	void	*data;	/* dump data area */
+	struct	qlcnic_dump_template_hdr *tmpl_hdr;
+};
+
 /*
  * One hardware_context{} per adapter
  * contains interrupt info as well shared hardware info.
@@ -431,6 +454,7 @@ struct qlcnic_hardware_context {
 	u16 board_type;
 
 	struct qlcnic_nic_intr_coalesce coal;
+	struct qlcnic_fw_dump fw_dump;
 };
 
 struct qlcnic_adapter_stats {
@@ -574,6 +598,8 @@ struct qlcnic_recv_context {
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_PORT_CONFIG	0x00000029
 #define QLCNIC_CDRP_CMD_GET_ESWITCH_STATS	0x0000002a
 #define QLCNIC_CDRP_CMD_CONFIG_PORT		0x0000002E
+#define QLCNIC_CDRP_CMD_TEMP_SIZE		0x0000002f
+#define QLCNIC_CDRP_CMD_GET_TEMP_HDR		0x00000030
 
 #define QLCNIC_RCODE_SUCCESS		0
 #define QLCNIC_RCODE_NOT_SUPPORTED	9
@@ -1157,6 +1183,152 @@ struct qlcnic_esw_statistics {
 	struct __qlcnic_esw_statistics tx;
 };
 
+struct qlcnic_common_entry_hdr {
+	__le32	type;
+	__le32	offset;
+	__le32	cap_size;
+	u8	mask;
+	u8	rsvd[2];
+	u8	flags;
+} __packed;
+
+struct __crb {
+	__le32	addr;
+	u8	stride;
+	u8	rsvd1[3];
+	__le32	data_size;
+	__le32	no_ops;
+	__le32	rsvd2[4];
+} __packed;
+
+struct __ctrl {
+	__le32	addr;
+	u8	stride;
+	u8	index_a;
+	__le16	timeout;
+	__le32	data_size;
+	__le32	no_ops;
+	u8	opcode;
+	u8	index_v;
+	u8	shl_val;
+	u8	shr_val;
+	__le32	val1;
+	__le32	val2;
+	__le32	val3;
+} __packed;
+
+struct __cache {
+	__le32	addr;
+	u8	stride;
+	u8	rsvd;
+	__le16	init_tag_val;
+	__le32	size;
+	__le32	no_ops;
+	__le32	ctrl_addr;
+	__le32	ctrl_val;
+	__le32	read_addr;
+	u8	read_addr_stride;
+	u8	read_addr_num;
+	u8	rsvd1[2];
+} __packed;
+
+struct __ocm {
+	u8	rsvd[8];
+	__le32	size;
+	__le32	no_ops;
+	u8	rsvd1[8];
+	__le32	read_addr;
+	__le32	read_addr_stride;
+} __packed;
+
+struct __mem {
+	u8	rsvd[24];
+	__le32	addr;
+	__le32	size;
+} __packed;
+
+struct __mux {
+	__le32	addr;
+	u8	rsvd[4];
+	__le32	size;
+	__le32	no_ops;
+	__le32	val;
+	__le32	val_stride;
+	__le32	read_addr;
+	u8	rsvd2[4];
+} __packed;
+
+struct __queue {
+	__le32	sel_addr;
+	__le16	stride;
+	u8	rsvd[2];
+	__le32	size;
+	__le32	no_ops;
+	u8	rsvd2[8];
+	__le32	read_addr;
+	u8	read_addr_stride;
+	u8	read_addr_cnt;
+	u8	rsvd3[2];
+} __packed;
+
+struct qlcnic_dump_entry {
+	struct qlcnic_common_entry_hdr hdr;
+	union {
+		struct __crb	crb;
+		struct __cache	cache;
+		struct __ocm	ocm;
+		struct __mem	mem;
+		struct __mux	mux;
+		struct __queue	que;
+		struct __ctrl	ctrl;
+	} region;
+} __packed;
+
+enum op_codes {
+	QLCNIC_DUMP_NOP		= 0,
+	QLCNIC_DUMP_READ_CRB	= 1,
+	QLCNIC_DUMP_READ_MUX	= 2,
+	QLCNIC_DUMP_QUEUE	= 3,
+	QLCNIC_DUMP_BRD_CONFIG	= 4,
+	QLCNIC_DUMP_READ_OCM	= 6,
+	QLCNIC_DUMP_PEG_REG	= 7,
+	QLCNIC_DUMP_L1_DTAG	= 8,
+	QLCNIC_DUMP_L1_ITAG	= 9,
+	QLCNIC_DUMP_L1_DATA	= 11,
+	QLCNIC_DUMP_L1_INST	= 12,
+	QLCNIC_DUMP_L2_DTAG	= 21,
+	QLCNIC_DUMP_L2_ITAG	= 22,
+	QLCNIC_DUMP_L2_DATA	= 23,
+	QLCNIC_DUMP_L2_INST	= 24,
+	QLCNIC_DUMP_READ_ROM	= 71,
+	QLCNIC_DUMP_READ_MEM	= 72,
+	QLCNIC_DUMP_READ_CTRL	= 98,
+	QLCNIC_DUMP_TLHDR	= 99,
+	QLCNIC_DUMP_RDEND	= 255
+};
+
+#define QLCNIC_DUMP_WCRB	BIT_0
+#define QLCNIC_DUMP_RWCRB	BIT_1
+#define QLCNIC_DUMP_ANDCRB	BIT_2
+#define QLCNIC_DUMP_ORCRB	BIT_3
+#define QLCNIC_DUMP_POLLCRB	BIT_4
+#define QLCNIC_DUMP_RD_SAVE	BIT_5
+#define QLCNIC_DUMP_WRT_SAVED	BIT_6
+#define QLCNIC_DUMP_MOD_SAVE_ST	BIT_7
+#define QLCNIC_DUMP_SKIP	BIT_7
+
+#define QLCNIC_DUMP_MASK_MIN		3
+#define QLCNIC_DUMP_MASK_DEF		0x0f
+#define QLCNIC_DUMP_MASK_MAX		0xff
+#define QLCNIC_FORCE_FW_DUMP_KEY	0xdeadfeed
+
+struct qlcnic_dump_operations {
+	enum op_codes opcode;
+	u32 (*handler)(struct qlcnic_adapter *,
+			struct qlcnic_dump_entry *, u32 *);
+};
+
+int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter);
 int qlcnic_fw_cmd_set_port(struct qlcnic_adapter *adapter, u32 config);
 
 u32 qlcnic_hw_read_wx_2M(struct qlcnic_adapter *adapter, ulong off);
@@ -1203,6 +1375,7 @@ int qlcnic_wol_supported(struct qlcnic_adapter *adapter);
 int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate);
 void qlcnic_prune_lb_filters(struct qlcnic_adapter *adapter);
 void qlcnic_delete_lb_filters(struct qlcnic_adapter *adapter);
+int qlcnic_dump_fw(struct qlcnic_adapter *);
 
 /* Functions from qlcnic_init.c */
 int qlcnic_load_firmware(struct qlcnic_adapter *adapter);
@@ -1213,7 +1386,7 @@ int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter);
 int qlcnic_setup_idc_param(struct qlcnic_adapter *adapter);
 int qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter);
 
-int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, int addr, int *valp);
+int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp);
 int qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
 				u8 *bytes, size_t size);
 int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter);
@@ -1265,6 +1438,7 @@ int qlcnic_diag_alloc_res(struct net_device *netdev, int test);
 netdev_tx_t qlcnic_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
 int qlcnic_validate_max_rss(struct net_device *netdev, u8 max_hw, u8 val);
 int qlcnic_set_max_rss(struct qlcnic_adapter *adapter, u8 data);
+void qlcnic_dev_request_reset(struct qlcnic_adapter *);
 
 /* Management functions */
 int qlcnic_get_mac_address(struct qlcnic_adapter *, u8*);
diff --git a/drivers/net/qlcnic/qlcnic_ctx.c b/drivers/net/qlcnic/qlcnic_ctx.c
index 3a99886..bab041a 100644
--- a/drivers/net/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/qlcnic/qlcnic_ctx.c
@@ -64,6 +64,97 @@ qlcnic_issue_cmd(struct qlcnic_adapter *adapter,
 	return rcode;
 }
 
+static uint32_t qlcnic_temp_checksum(uint32_t *temp_buffer, u16 temp_size)
+{
+	uint64_t sum = 0;
+	int count = temp_size / sizeof(uint32_t);
+	while (count-- > 0)
+		sum += *temp_buffer++;
+	while (sum >> 32)
+		sum = (sum & 0xFFFFFFFF) + (sum >> 32);
+	return ~sum;
+}
+
+int qlcnic_fw_cmd_get_minidump_temp(struct qlcnic_adapter *adapter)
+{
+	int err, i;
+	u16 temp_size;
+	void *tmp_addr;
+	u32 version, csum, *template, *tmp_buf;
+	struct qlcnic_hardware_context *ahw;
+	struct qlcnic_dump_template_hdr *tmpl_hdr, *tmp_tmpl;
+	dma_addr_t tmp_addr_t = 0;
+
+	ahw = adapter->ahw;
+	err = qlcnic_issue_cmd(adapter,
+			adapter->ahw->pci_func,
+			adapter->fw_hal_version,
+			0,
+			0,
+			0,
+			QLCNIC_CDRP_CMD_TEMP_SIZE);
+	if (err != QLCNIC_RCODE_SUCCESS) {
+		err = QLCRD32(adapter, QLCNIC_ARG1_CRB_OFFSET);
+		dev_err(&adapter->pdev->dev,
+			"Failed to get template size %d\n", err);
+		err = -EIO;
+		return err;
+	}
+	version = QLCRD32(adapter, QLCNIC_ARG3_CRB_OFFSET);
+	temp_size = QLCRD32(adapter, QLCNIC_ARG2_CRB_OFFSET);
+	if (!temp_size)
+		return -EIO;
+
+	tmp_addr = dma_alloc_coherent(&adapter->pdev->dev, temp_size,
+			&tmp_addr_t, GFP_KERNEL);
+	if (!tmp_addr) {
+		dev_err(&adapter->pdev->dev,
+			"Can't get memory for FW dump template\n");
+		return -ENOMEM;
+	}
+	err = qlcnic_issue_cmd(adapter,
+		adapter->ahw->pci_func,
+		adapter->fw_hal_version,
+		LSD(tmp_addr_t),
+		MSD(tmp_addr_t),
+		temp_size,
+		QLCNIC_CDRP_CMD_GET_TEMP_HDR);
+
+	if (err != QLCNIC_RCODE_SUCCESS) {
+		dev_err(&adapter->pdev->dev,
+			"Failed to get mini dump template header %d\n", err);
+		err = -EIO;
+		goto error;
+	}
+	tmp_tmpl = (struct qlcnic_dump_template_hdr *) tmp_addr;
+	csum = qlcnic_temp_checksum((uint32_t *) tmp_addr, temp_size);
+	if (csum) {
+		dev_err(&adapter->pdev->dev,
+			"Template header checksum validation failed\n");
+		err = -EIO;
+		goto error;
+	}
+	ahw->fw_dump.tmpl_hdr = vzalloc(temp_size);
+	if (!ahw->fw_dump.tmpl_hdr) {
+		err = -EIO;
+		goto error;
+	}
+	tmp_buf = (u32 *) tmp_addr;
+	template = (u32 *) ahw->fw_dump.tmpl_hdr;
+	for (i = 0; i < temp_size/sizeof(u32); i++)
+		*template++ = __le32_to_cpu(*tmp_buf++);
+
+	tmpl_hdr = ahw->fw_dump.tmpl_hdr;
+	if (tmpl_hdr->cap_mask > QLCNIC_DUMP_MASK_DEF &&
+		tmpl_hdr->cap_mask <= QLCNIC_DUMP_MASK_MAX)
+		tmpl_hdr->drv_cap_mask = tmpl_hdr->cap_mask;
+	else
+		tmpl_hdr->drv_cap_mask = QLCNIC_DUMP_MASK_DEF;
+error:
+	dma_free_coherent(&adapter->pdev->dev, temp_size, tmp_addr, tmp_addr_t);
+	return err;
+}
+
 int
 qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu)
 {
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 726ef55..d14506f 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -492,10 +492,10 @@ enum {
 
 #define TEST_AGT_CTRL	(0x00)
 
-#define TA_CTL_START	1
-#define TA_CTL_ENABLE	2
-#define TA_CTL_WRITE	4
-#define TA_CTL_BUSY	8
+#define TA_CTL_START	BIT_0
+#define TA_CTL_ENABLE	BIT_1
+#define TA_CTL_WRITE	BIT_2
+#define TA_CTL_BUSY	BIT_3
 
 /*
  *   Register offsets for MN
@@ -765,6 +765,38 @@ struct qlcnic_legacy_intr_set {
 #define QLCNIC_MAX_PCI_FUNC	8
 #define QLCNIC_MAX_VLAN_FILTERS	64
 
+/* FW dump defines */
+#define MIU_TEST_CTR		0x41000090
+#define MIU_TEST_ADDR_LO	0x41000094
+#define MIU_TEST_ADDR_HI	0x41000098
+#define FLASH_ROM_WINDOW	0x42110030
+#define FLASH_ROM_DATA		0x42150000
+
+static const u32 MIU_TEST_READ_DATA[] = {
+	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
+
+#define QLCNIC_FW_DUMP_REG1	0x00130060
+#define QLCNIC_FW_DUMP_REG2	0x001e0000
+#define QLCNIC_FLASH_SEM2_LK	0x0013C010
+#define QLCNIC_FLASH_SEM2_ULK	0x0013C014
+#define QLCNIC_FLASH_LOCK_ID	0x001B2100
+
+#define QLCNIC_RD_DUMP_REG(addr, bar0, data) do {			\
+	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
+		QLCNIC_FW_DUMP_REG1));					\
+	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
+	*data = readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 +		\
+		LSW(addr)));						\
+} while (0)
+
+#define QLCNIC_WR_DUMP_REG(addr, bar0, data) do {			\
+	writel((addr & 0xFFFF0000), (void *) (bar0 +			\
+		QLCNIC_FW_DUMP_REG1));					\
+	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG1));			\
+	writel(data, (void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));\
+	readl((void *) (bar0 + QLCNIC_FW_DUMP_REG2 + LSW(addr)));	\
+} while (0)
+
 /* PCI function operational mode */
 enum {
 	QLCNIC_MGMT_FUNC	= 0,
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index cbb27f2..e965661 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -9,6 +9,7 @@
 
 #include <linux/slab.h>
 #include <net/ip.h>
+#include <linux/bitops.h>
 
 #define MASK(n) ((1ULL<<(n))-1)
 #define OCM_WIN_P3P(addr) (addr & 0xffc0000)
@@ -1261,3 +1262,461 @@ int qlcnic_config_led(struct qlcnic_adapter *adapter, u32 state, u32 rate)
 
 	return rv;
 }
+
+/* FW dump related functions */
+static u32
+qlcnic_dump_crb(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+		u32 *buffer)
+{
+	int i;
+	u32 addr, data;
+	struct __crb *crb = &entry->region.crb;
+	void __iomem *base = adapter->ahw->pci_base0;
+
+	addr = crb->addr;
+
+	for (i = 0; i < crb->no_ops; i++) {
+		QLCNIC_RD_DUMP_REG(addr, base, &data);
+		*buffer++ = cpu_to_le32(addr);
+		*buffer++ = cpu_to_le32(data);
+		addr += crb->stride;
+	}
+	return crb->no_ops * 2 * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_ctrl(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	int i, k, timeout = 0;
+	void __iomem *base = adapter->ahw->pci_base0;
+	u32 addr, data;
+	u8 opcode, no_ops;
+	struct __ctrl *ctr = &entry->region.ctrl;
+	struct qlcnic_dump_template_hdr *t_hdr = adapter->ahw->fw_dump.tmpl_hdr;
+
+	addr = ctr->addr;
+	no_ops = ctr->no_ops;
+
+	for (i = 0; i < no_ops; i++) {
+		k = 0;
+		opcode = 0;
+		for (k = 0; k < 8; k++) {
+			if (!(ctr->opcode & (1 << k)))
+				continue;
+			switch (1 << k) {
+			case QLCNIC_DUMP_WCRB:
+				QLCNIC_WR_DUMP_REG(addr, base, ctr->val1);
+				break;
+			case QLCNIC_DUMP_RWCRB:
+				QLCNIC_RD_DUMP_REG(addr, base, &data);
+				QLCNIC_WR_DUMP_REG(addr, base, data);
+				break;
+			case QLCNIC_DUMP_ANDCRB:
+				QLCNIC_RD_DUMP_REG(addr, base, &data);
+				QLCNIC_WR_DUMP_REG(addr, base,
+					(data & ctr->val2));
+				break;
+			case QLCNIC_DUMP_ORCRB:
+				QLCNIC_RD_DUMP_REG(addr, base, &data);
+				QLCNIC_WR_DUMP_REG(addr, base,
+					(data | ctr->val3));
+				break;
+			case QLCNIC_DUMP_POLLCRB:
+				while (timeout <= ctr->timeout) {
+					QLCNIC_RD_DUMP_REG(addr, base, &data);
+					if ((data & ctr->val2) == ctr->val1)
+						break;
+					msleep(1);
+					timeout++;
+				}
+				if (timeout > ctr->timeout) {
+					dev_info(&adapter->pdev->dev,
+					"Timed out, aborting poll CRB\n");
+					return -EINVAL;
+				}
+				break;
+			case QLCNIC_DUMP_RD_SAVE:
+				if (ctr->index_a)
+					addr = t_hdr->saved_state[ctr->index_a];
+				QLCNIC_RD_DUMP_REG(addr, base, &data);
+				t_hdr->saved_state[ctr->index_v] = data;
+				break;
+			case QLCNIC_DUMP_WRT_SAVED:
+				if (ctr->index_v)
+					data = t_hdr->saved_state[ctr->index_v];
+				else
+					data = ctr->val1;
+				if (ctr->index_a)
+					addr = t_hdr->saved_state[ctr->index_a];
+				QLCNIC_WR_DUMP_REG(addr, base, data);
+				break;
+			case QLCNIC_DUMP_MOD_SAVE_ST:
+				data = t_hdr->saved_state[ctr->index_v];
+				data <<= ctr->shl_val;
+				data >>= ctr->shr_val;
+				if (ctr->val2)
+					data &= ctr->val2;
+				data |= ctr->val3;
+				data += ctr->val1;
+				t_hdr->saved_state[ctr->index_v] = data;
+				break;
+			default:
+				dev_info(&adapter->pdev->dev,
+					"Unknown opcode\n");
+				break;
+			}
+		}
+		addr += ctr->stride;
+	}
+	return 0;
+}
+
+static u32
+qlcnic_dump_mux(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int loop;
+	u32 val, data = 0;
+	struct __mux *mux = &entry->region.mux;
+	void __iomem *base = adapter->ahw->pci_base0;
+
+	val = mux->val;
+	for (loop = 0; loop < mux->no_ops; loop++) {
+		QLCNIC_WR_DUMP_REG(mux->addr, base, val);
+		QLCNIC_RD_DUMP_REG(mux->read_addr, base, &data);
+		*buffer++ = cpu_to_le32(val);
+		*buffer++ = cpu_to_le32(data);
+		val += mux->val_stride;
+	}
+	return 2 * mux->no_ops * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_que(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int i, loop;
+	u32 cnt, addr, data, que_id = 0;
+	void __iomem *base = adapter->ahw->pci_base0;
+	struct __queue *que = &entry->region.que;
+
+	addr = que->read_addr;
+	cnt = que->read_addr_cnt;
+
+	for (loop = 0; loop < que->no_ops; loop++) {
+		QLCNIC_WR_DUMP_REG(que->sel_addr, base, que_id);
+		for (i = 0; i < cnt; i++) {
+			QLCNIC_RD_DUMP_REG(addr, base, &data);
+			*buffer++ = cpu_to_le32(data);
+			addr += que->read_addr_stride;
+		}
+		que_id += que->stride;
+	}
+	return que->no_ops * cnt * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_ocm(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int i;
+	u32 data;
+	void __iomem *addr;
+	struct __ocm *ocm = &entry->region.ocm;
+
+	addr = adapter->ahw->pci_base0 + ocm->read_addr;
+	for (i = 0; i < ocm->no_ops; i++) {
+		data = readl(addr);
+		*buffer++ = cpu_to_le32(data);
+		addr += ocm->read_addr_stride;
+	}
+	return ocm->no_ops * sizeof(u32);
+}
+
+static u32
+qlcnic_read_rom(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
+	u32 *buffer)
+{
+	int i, count = 0;
+	u32 fl_addr, size, val, lck_val, addr;
+	struct __mem *rom = &entry->region.mem;
+	void __iomem *base = adapter->ahw->pci_base0;
+
+	fl_addr = rom->addr;
+	size = rom->size/4;
+lock_try:
+	lck_val = readl(base + QLCNIC_FLASH_SEM2_LK);
+	if (!lck_val && count < MAX_CTL_CHECK) {
+		msleep(10);
+		count++;
+		goto lock_try;
+	}
+	writel(adapter->ahw->pci_func, (base + QLCNIC_FLASH_LOCK_ID));
+	for (i = 0; i < size; i++) {
+		addr = fl_addr & 0xFFFF0000;
+		QLCNIC_WR_DUMP_REG(FLASH_ROM_WINDOW, base, addr);
+		addr = LSW(fl_addr) + FLASH_ROM_DATA;
+		QLCNIC_RD_DUMP_REG(addr, base, &val);
+		fl_addr += 4;
+		*buffer++ = cpu_to_le32(val);
+	}
+	readl(base + QLCNIC_FLASH_SEM2_ULK);
+	return rom->size;
+}
+
+static u32
+qlcnic_dump_l1_cache(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	int i;
+	u32 cnt, val, data, addr;
+	void __iomem *base = adapter->ahw->pci_base0;
+	struct __cache *l1 = &entry->region.cache;
+
+	val = l1->init_tag_val;
+
+	for (i = 0; i < l1->no_ops; i++) {
+		QLCNIC_WR_DUMP_REG(l1->addr, base, val);
+		QLCNIC_WR_DUMP_REG(l1->ctrl_addr, base, LSW(l1->ctrl_val));
+		addr = l1->read_addr;
+		cnt = l1->read_addr_num;
+		while (cnt) {
+			QLCNIC_RD_DUMP_REG(addr, base, &data);
+			*buffer++ = cpu_to_le32(data);
+			addr += l1->read_addr_stride;
+			cnt--;
+		}
+		val += l1->stride;
+	}
+	return l1->no_ops * l1->read_addr_num * sizeof(u32);
+}
+
+static u32
+qlcnic_dump_l2_cache(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	int i;
+	u32 cnt, val, data, addr;
+	u8 poll_mask, poll_to, time_out = 0;
+	void __iomem *base = adapter->ahw->pci_base0;
+	struct __cache *l2 = &entry->region.cache;
+
+	val = l2->init_tag_val;
+	poll_mask = LSB(MSW(l2->ctrl_val));
+	poll_to = MSB(MSW(l2->ctrl_val));
+
+	for (i = 0; i < l2->no_ops; i++) {
+		QLCNIC_WR_DUMP_REG(l2->addr, base, val);
+		do {
+			QLCNIC_WR_DUMP_REG(l2->ctrl_addr, base,
+				LSW(l2->ctrl_val));
+			QLCNIC_RD_DUMP_REG(l2->ctrl_addr, base, &data);
+			if (!(data & poll_mask))
+				break;
+			msleep(1);
+			time_out++;
+		} while (time_out <= poll_to);
+		if (time_out > poll_to)
+			return -EINVAL;
+
+		addr = l2->read_addr;
+		cnt = l2->read_addr_num;
+		while (cnt) {
+			QLCNIC_RD_DUMP_REG(addr, base, &data);
+			*buffer++ = cpu_to_le32(data);
+			addr += l2->read_addr_stride;
+			cnt--;
+		}
+		val += l2->stride;
+	}
+	return l2->no_ops * l2->read_addr_num * sizeof(u32);
+}
+
+static u32
+qlcnic_read_memory(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	u32 addr, data, test, ret = 0;
+	int i, reg_read;
+	struct __mem *mem = &entry->region.mem;
+	void __iomem *base = adapter->ahw->pci_base0;
+
+	reg_read = mem->size;
+	addr = mem->addr;
+	/* check for data size of multiple of 16 and 16 byte alignment */
+	if ((addr & 0xf) || (reg_read%16)) {
+		dev_info(&adapter->pdev->dev,
+			"Unaligned memory addr:0x%x size:0x%x\n",
+			addr, reg_read);
+		return -EINVAL;
+	}
+
+	mutex_lock(&adapter->ahw->mem_lock);
+
+	while (reg_read != 0) {
+		QLCNIC_WR_DUMP_REG(MIU_TEST_ADDR_LO, base, addr);
+		QLCNIC_WR_DUMP_REG(MIU_TEST_ADDR_HI, base, 0);
+		QLCNIC_WR_DUMP_REG(MIU_TEST_CTR, base,
+			TA_CTL_ENABLE | TA_CTL_START);
+
+		for (i = 0; i < MAX_CTL_CHECK; i++) {
+			QLCNIC_RD_DUMP_REG(MIU_TEST_CTR, base, &test);
+			if (!(test & TA_CTL_BUSY))
+				break;
+		}
+		if (i == MAX_CTL_CHECK) {
+			if (printk_ratelimit()) {
+				dev_err(&adapter->pdev->dev,
+					"failed to read through agent\n");
+				ret = -EINVAL;
+				goto out;
+			}
+		}
+		for (i = 0; i < 4; i++) {
+			QLCNIC_RD_DUMP_REG(MIU_TEST_READ_DATA[i], base, &data);
+			*buffer++ = cpu_to_le32(data);
+		}
+		addr += 16;
+		reg_read -= 16;
+		ret += 16;
+	}
+out:
+	mutex_unlock(&adapter->ahw->mem_lock);
+	return mem->size;
+}
+
+static u32
+qlcnic_dump_nop(struct qlcnic_adapter *adapter,
+	struct qlcnic_dump_entry *entry, u32 *buffer)
+{
+	entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+	return 0;
+}
+
+struct qlcnic_dump_operations fw_dump_ops[] = {
+	{ QLCNIC_DUMP_NOP, qlcnic_dump_nop },
+	{ QLCNIC_DUMP_READ_CRB, qlcnic_dump_crb },
+	{ QLCNIC_DUMP_READ_MUX, qlcnic_dump_mux },
+	{ QLCNIC_DUMP_QUEUE, qlcnic_dump_que },
+	{ QLCNIC_DUMP_BRD_CONFIG, qlcnic_read_rom },
+	{ QLCNIC_DUMP_READ_OCM, qlcnic_dump_ocm },
+	{ QLCNIC_DUMP_PEG_REG, qlcnic_dump_ctrl },
+	{ QLCNIC_DUMP_L1_DTAG, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_ITAG, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_DATA, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L1_INST, qlcnic_dump_l1_cache },
+	{ QLCNIC_DUMP_L2_DTAG, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_ITAG, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_DATA, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_L2_INST, qlcnic_dump_l2_cache },
+	{ QLCNIC_DUMP_READ_ROM, qlcnic_read_rom },
+	{ QLCNIC_DUMP_READ_MEM, qlcnic_read_memory },
+	{ QLCNIC_DUMP_READ_CTRL, qlcnic_dump_ctrl },
+	{ QLCNIC_DUMP_TLHDR, qlcnic_dump_nop },
+	{ QLCNIC_DUMP_RDEND, qlcnic_dump_nop },
+};
+
+/* Walk the template and collect dump for each entry in the dump template */
+static int
+qlcnic_valid_dump_entry(struct device *dev, struct qlcnic_dump_entry *entry,
+	u32 size)
+{
+	int ret = 1;
+	if (size != entry->hdr.cap_size) {
+		dev_info(dev,
+		"Invalidate dump, Type:%d\tMask:%d\tSize:%dCap_size:%d\n",
+		entry->hdr.type, entry->hdr.mask, size, entry->hdr.cap_size);
+		dev_info(dev, "Aborting further dump capture\n");
+		ret = 0;
+	}
+	return ret;
+}
+
+int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
+{
+	u32 *buffer;
+	char mesg[64];
+	char *msg[] = {mesg, NULL};
+	int i, k, ops_cnt, ops_index, dump_size = 0;
+	u32 entry_offset, dump, no_entries, buf_offset = 0;
+	struct qlcnic_dump_entry *entry;
+	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
+	struct qlcnic_dump_template_hdr *tmpl_hdr = fw_dump->tmpl_hdr;
+
+	if (fw_dump->clr) {
+		dev_info(&adapter->pdev->dev,
+			"Previous dump not cleared, not capturing dump\n");
+		return -EIO;
+	}
+	/* Calculate the size for dump data area only */
+	for (i = 2, k = 1; (i & QLCNIC_DUMP_MASK_MAX); i <<= 1, k++)
+		if (i & tmpl_hdr->drv_cap_mask)
+			dump_size += tmpl_hdr->cap_sizes[k];
+	if (!dump_size)
+		return -EIO;
+
+	fw_dump->data = vzalloc(dump_size);
+	if (!fw_dump->data) {
+		dev_info(&adapter->pdev->dev,
+			"Unable to allocate (%d KB) for fw dump\n",
+			dump_size/1024);
+		return -ENOMEM;
+	}
+	buffer = fw_dump->data;
+	fw_dump->size = dump_size;
+	no_entries = tmpl_hdr->num_entries;
+	ops_cnt = ARRAY_SIZE(fw_dump_ops);
+	entry_offset = tmpl_hdr->offset;
+	tmpl_hdr->sys_info[0] = QLCNIC_DRIVER_VERSION;
+	tmpl_hdr->sys_info[1] = adapter->fw_version;
+
+	for (i = 0; i < no_entries; i++) {
+		entry = (struct qlcnic_dump_entry *) ((void *) tmpl_hdr +
+			entry_offset);
+		if (!(entry->hdr.mask & tmpl_hdr->drv_cap_mask)) {
+			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+			entry_offset += entry->hdr.offset;
+			continue;
+		}
+		/* Find the handler for this entry */
+		ops_index = 0;
+		while (ops_index < ops_cnt) {
+			if (entry->hdr.type == fw_dump_ops[ops_index].opcode)
+				break;
+			ops_index++;
+		}
+		if (ops_index == ops_cnt) {
+			dev_info(&adapter->pdev->dev,
+				"Invalid entry type %d, exiting dump\n",
+				entry->hdr.type);
+			goto error;
+		}
+		/* Collect dump for this entry */
+		dump = fw_dump_ops[ops_index].handler(adapter, entry, buffer);
+		if (dump && !qlcnic_valid_dump_entry(&adapter->pdev->dev, entry,
+			dump))
+			entry->hdr.flags |= QLCNIC_DUMP_SKIP;
+		buf_offset += entry->hdr.cap_size;
+		entry_offset += entry->hdr.offset;
+		buffer = fw_dump->data + buf_offset;
+	}
+	if (dump_size != buf_offset) {
+		dev_info(&adapter->pdev->dev,
+			"Captured(%d) and expected size(%d) do not match\n",
+			buf_offset, dump_size);
+		goto error;
+	} else {
+		fw_dump->clr = 1;
+		snprintf(mesg, sizeof(mesg), "FW dump for device: %d\n",
+			adapter->pdev->devfn);
+		dev_info(&adapter->pdev->dev, "Dump data, %d bytes captured\n",
+			fw_dump->size);
+		/* Send a udev event to notify availability of FW dump */
+		kobject_uevent_env(&adapter->pdev->dev.kobj, KOBJ_CHANGE, msg);
+		return 0;
+	}
+error:
+	vfree(fw_dump->data);
+	return -EINVAL;
+}
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index d0f338b..5b8bbcf 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -345,7 +345,7 @@ static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
 }
 
 static int do_rom_fast_read(struct qlcnic_adapter *adapter,
-			    int addr, int *valp)
+			    u32 addr, u32 *valp)
 {
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ADDRESS, addr);
 	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
@@ -398,7 +398,7 @@ qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
 	return ret;
 }
 
-int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, int addr, int *valp)
+int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp)
 {
 	int ret;
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index d6cc4d4..3ab7d2c 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -1343,6 +1343,10 @@ static void qlcnic_free_adapter_resources(struct qlcnic_adapter *adapter)
 	kfree(adapter->recv_ctx);
 	adapter->recv_ctx = NULL;
 
+	if (adapter->ahw->fw_dump.tmpl_hdr) {
+		vfree(adapter->ahw->fw_dump.tmpl_hdr);
+		adapter->ahw->fw_dump.tmpl_hdr = NULL;
+	}
 	kfree(adapter->ahw);
 	adapter->ahw = NULL;
 }
@@ -1586,6 +1590,10 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* This will be reset for mezz cards  */
 	adapter->portnum = adapter->ahw->pci_func;
 
+	/* Get FW dump template and store it */
+	if (adapter->op_mode != QLCNIC_NON_PRIV_FUNC)
+		qlcnic_fw_cmd_get_minidump_temp(adapter);
+
 	err = qlcnic_get_board_info(adapter);
 	if (err) {
 		dev_err(&pdev->dev, "Error getting board config info.\n");
@@ -2825,6 +2833,8 @@ skip_ack_check:
 			set_bit(__QLCNIC_START_FW, &adapter->state);
 			QLCDB(adapter, DRV, "Restarting fw\n");
 			qlcnic_idc_debug_info(adapter, 0);
+			QLCDB(adapter, DRV, "Take FW dump\n");
+			qlcnic_dump_fw(adapter);
 		}
 
 		qlcnic_api_unlock(adapter);
@@ -2923,7 +2933,7 @@ qlcnic_set_npar_non_operational(struct qlcnic_adapter *adapter)
 }
 
 /*Transit to RESET state from READY state only */
-static void
+void
 qlcnic_dev_request_reset(struct qlcnic_adapter *adapter)
 {
 	u32 state;
@@ -3515,7 +3525,6 @@ qlcnic_sysfs_write_mem(struct file *filp, struct kobject *kobj,
 	return size;
 }
 
-
 static struct bin_attribute bin_attr_crb = {
 	.attr = {.name = "crb", .mode = (S_IRUGO | S_IWUSR)},
 	.size = 0,
-- 
1.7.4.1

