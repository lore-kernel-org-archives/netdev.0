From: Sony Chacko <sony.chacko@qlogic.com>
Subject: [PATCH net-next 14/15] qlcnic: restructure file layout of combined driver
Date: Thu, 23 Aug 2012 21:07:18 -0400
Message-ID: <1345770439-30517-15-git-send-email-sony.chacko@qlogic.com>
References: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Cc: netdev@vger.kernel.org, Dept_NX_Linux_NIC_Driver@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:17220 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756177Ab2HXBYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2012 21:24:19 -0400
In-Reply-To: <1345770439-30517-1-git-send-email-sony.chacko@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

File layout of common driver for 82xx and 83xx

qlcnic_82xx_hw.c, qlcnic_82xx_init.c - 82xx adapter specific files
qlcnic_83xx_hw.c, qlcnic_83xx_init.c - 83xx adapter specicic files
qlcnic_io.c - common file for 82xx and 83xx data path routines
qlcnic_ethtool.c - common file for 82xx and 83xx ethtool interface
qlcnic_sysfs.c - common file for 82xx and 83xx sysfs interface
qlcnic_main.c - common main file for 82xx and 83xx
qlcnic_83xx_vnic.c - 83xx virtual NIC routines

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/Makefile        |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_82xx_init.c  | 1297 ++++++++++++++++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c    |  477 +-------
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h    |   44 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c  |    4 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |   34 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h    |   14 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   | 1297 --------------------
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c     |  439 +++++++
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    5 +-
 10 files changed, 1806 insertions(+), 1807 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_init.c
 delete mode 100644 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c

diff --git a/drivers/net/ethernet/qlogic/qlcnic/Makefile b/drivers/net/ethernet/qlogic/qlcnic/Makefile
index fe61793..50e0e6f 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/Makefile
+++ b/drivers/net/ethernet/qlogic/qlcnic/Makefile
@@ -4,7 +4,7 @@
 
 obj-$(CONFIG_QLCNIC) := qlcnic.o
 
-qlcnic-y := qlcnic_82xx_hw.o qlcnic_main.o qlcnic_init.o \
+qlcnic-y := qlcnic_82xx_hw.o qlcnic_main.o qlcnic_82xx_init.o \
 	qlcnic_ethtool.o qlcnic_io.o \
 	qlcnic_sysfs.o qlcnic_minidump.o qlcnic_83xx_hw.o \
 	qlcnic_83xx_init.o qlcnic_83xx_vnic.o
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_init.c
new file mode 100644
index 0000000..52020ce
--- /dev/null
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_82xx_init.c
@@ -0,0 +1,1297 @@
+/*
+ * QLogic qlcnic NIC Driver
+ * Copyright (c)  2009-2010 QLogic Corporation
+ *
+ * See LICENSE.qlcnic for copyright and licensing details.
+ */
+
+#include "qlcnic.h"
+#include "qlcnic_hw.h"
+
+struct crb_addr_pair {
+	u32 addr;
+	u32 data;
+};
+
+#define QLCNIC_MAX_CRB_XFORM 60
+static unsigned int crb_addr_xform[QLCNIC_MAX_CRB_XFORM];
+
+#define crb_addr_transform(name) \
+	(crb_addr_xform[QLCNIC_HW_PX_MAP_CRB_##name] = \
+	QLCNIC_HW_CRB_HUB_AGT_ADR_##name << 20)
+
+#define QLCNIC_ADDR_ERROR (0xffffffff)
+
+static int
+qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter);
+
+static void crb_addr_transform_setup(void)
+{
+	crb_addr_transform(XDMA);
+	crb_addr_transform(TIMR);
+	crb_addr_transform(SRE);
+	crb_addr_transform(SQN3);
+	crb_addr_transform(SQN2);
+	crb_addr_transform(SQN1);
+	crb_addr_transform(SQN0);
+	crb_addr_transform(SQS3);
+	crb_addr_transform(SQS2);
+	crb_addr_transform(SQS1);
+	crb_addr_transform(SQS0);
+	crb_addr_transform(RPMX7);
+	crb_addr_transform(RPMX6);
+	crb_addr_transform(RPMX5);
+	crb_addr_transform(RPMX4);
+	crb_addr_transform(RPMX3);
+	crb_addr_transform(RPMX2);
+	crb_addr_transform(RPMX1);
+	crb_addr_transform(RPMX0);
+	crb_addr_transform(ROMUSB);
+	crb_addr_transform(SN);
+	crb_addr_transform(QMN);
+	crb_addr_transform(QMS);
+	crb_addr_transform(PGNI);
+	crb_addr_transform(PGND);
+	crb_addr_transform(PGN3);
+	crb_addr_transform(PGN2);
+	crb_addr_transform(PGN1);
+	crb_addr_transform(PGN0);
+	crb_addr_transform(PGSI);
+	crb_addr_transform(PGSD);
+	crb_addr_transform(PGS3);
+	crb_addr_transform(PGS2);
+	crb_addr_transform(PGS1);
+	crb_addr_transform(PGS0);
+	crb_addr_transform(PS);
+	crb_addr_transform(PH);
+	crb_addr_transform(NIU);
+	crb_addr_transform(I2Q);
+	crb_addr_transform(EG);
+	crb_addr_transform(MN);
+	crb_addr_transform(MS);
+	crb_addr_transform(CAS2);
+	crb_addr_transform(CAS1);
+	crb_addr_transform(CAS0);
+	crb_addr_transform(CAM);
+	crb_addr_transform(C2C1);
+	crb_addr_transform(C2C0);
+	crb_addr_transform(SMB);
+	crb_addr_transform(OCM0);
+	crb_addr_transform(I2C0);
+}
+
+void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_rx_buffer *rx_buf;
+	int i, ring;
+
+	recv_ctx = adapter->recv_ctx;
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		for (i = 0; i < rds_ring->num_desc; ++i) {
+			rx_buf = &(rds_ring->rx_buf_arr[i]);
+			if (rx_buf->skb == NULL)
+				continue;
+
+			pci_unmap_single(adapter->pdev,
+					rx_buf->dma,
+					rds_ring->dma_size,
+					PCI_DMA_FROMDEVICE);
+
+			dev_kfree_skb_any(rx_buf->skb);
+		}
+	}
+}
+
+void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_rx_buffer *rx_buf;
+	int i, ring;
+
+	recv_ctx = adapter->recv_ctx;
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+
+		INIT_LIST_HEAD(&rds_ring->free_list);
+
+		rx_buf = rds_ring->rx_buf_arr;
+		for (i = 0; i < rds_ring->num_desc; i++) {
+			list_add_tail(&rx_buf->list,
+					&rds_ring->free_list);
+			rx_buf++;
+		}
+	}
+}
+
+void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_cmd_buffer *cmd_buf;
+	struct qlcnic_skb_frag *buffrag;
+	int i, j;
+	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
+
+	cmd_buf = tx_ring->cmd_buf_arr;
+	for (i = 0; i < tx_ring->num_desc; i++) {
+		buffrag = cmd_buf->frag_array;
+		if (buffrag->dma) {
+			pci_unmap_single(adapter->pdev, buffrag->dma,
+					 buffrag->length, PCI_DMA_TODEVICE);
+			buffrag->dma = 0ULL;
+		}
+		for (j = 0; j < cmd_buf->frag_count; j++) {
+			buffrag++;
+			if (buffrag->dma) {
+				pci_unmap_page(adapter->pdev, buffrag->dma,
+					       buffrag->length,
+					       PCI_DMA_TODEVICE);
+				buffrag->dma = 0ULL;
+			}
+		}
+		if (cmd_buf->skb) {
+			dev_kfree_skb_any(cmd_buf->skb);
+			cmd_buf->skb = NULL;
+		}
+		cmd_buf++;
+	}
+}
+
+void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	int ring;
+
+	recv_ctx = adapter->recv_ctx;
+
+	if (recv_ctx->rds_rings == NULL)
+		return;
+
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		vfree(rds_ring->rx_buf_arr);
+		rds_ring->rx_buf_arr = NULL;
+	}
+	kfree(recv_ctx->rds_rings);
+}
+
+int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_recv_context *recv_ctx;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_rx_buffer *rx_buf;
+	int ring, i, size;
+
+	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_hardware_context *ahw = adapter->ahw;
+
+	recv_ctx = adapter->recv_ctx;
+
+	size = adapter->max_rds_rings * sizeof(struct qlcnic_host_rds_ring);
+	rds_ring = kzalloc(size, GFP_KERNEL);
+	if (rds_ring == NULL) {
+		dev_err(&netdev->dev, "failed to allocate rds ring struct\n");
+		goto err_out;
+	}
+	recv_ctx->rds_rings = rds_ring;
+
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		rds_ring = &recv_ctx->rds_rings[ring];
+		switch (ring) {
+		case RCV_RING_NORMAL:
+			rds_ring->num_desc = adapter->num_rxd;
+			rds_ring->dma_size = QLCNIC_P3P_RX_BUF_MAX_LEN;
+			rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
+			break;
+
+		case RCV_RING_JUMBO:
+			rds_ring->num_desc = adapter->num_jumbo_rxd;
+			rds_ring->dma_size =
+				QLCNIC_P3P_RX_JUMBO_BUF_MAX_LEN;
+
+			if (ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+				rds_ring->dma_size += QLCNIC_LRO_BUFFER_EXTRA;
+
+			rds_ring->skb_size =
+				rds_ring->dma_size + NET_IP_ALIGN;
+			break;
+		}
+		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
+			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
+		if (rds_ring->rx_buf_arr == NULL) {
+			dev_err(&netdev->dev,
+				"Failed to allocate rx buffer ring %d\n", ring);
+			goto err_out;
+		}
+		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
+		INIT_LIST_HEAD(&rds_ring->free_list);
+		/*
+		 * Now go through all of them, set reference handles
+		 * and put them in the queues.
+		 */
+		rx_buf = rds_ring->rx_buf_arr;
+		for (i = 0; i < rds_ring->num_desc; i++) {
+			list_add_tail(&rx_buf->list,
+					&rds_ring->free_list);
+			rx_buf->ref_handle = i;
+			rx_buf++;
+		}
+		spin_lock_init(&rds_ring->lock);
+	}
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		sds_ring->irq = adapter->msix_entries[ring].vector;
+		sds_ring->adapter = adapter;
+		sds_ring->num_desc = adapter->num_rxd;
+
+		for (i = 0; i < NUM_RCV_DESC_RINGS; i++)
+			INIT_LIST_HEAD(&sds_ring->free_list[i]);
+	}
+
+	return 0;
+
+err_out:
+	qlcnic_free_sw_resources(adapter);
+	return -ENOMEM;
+}
+
+/*
+ * Utility to translate from internal Phantom CRB address
+ * to external PCI CRB address.
+ */
+static u32 qlcnic_decode_crb_addr(u32 addr)
+{
+	int i;
+	u32 base_addr, offset, pci_base;
+
+	crb_addr_transform_setup();
+
+	pci_base = QLCNIC_ADDR_ERROR;
+	base_addr = addr & 0xfff00000;
+	offset = addr & 0x000fffff;
+
+	for (i = 0; i < QLCNIC_MAX_CRB_XFORM; i++) {
+		if (crb_addr_xform[i] == base_addr) {
+			pci_base = i << 20;
+			break;
+		}
+	}
+	if (pci_base == QLCNIC_ADDR_ERROR)
+		return pci_base;
+	else
+		return pci_base + offset;
+}
+
+#define QLCNIC_MAX_ROM_WAIT_USEC	100
+
+static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
+{
+	long timeout = 0;
+	long done = 0;
+	int err;
+
+	cond_resched();
+
+	while (done == 0) {
+		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS, &err);
+		done &= 2;
+		if (++timeout >= QLCNIC_MAX_ROM_WAIT_USEC) {
+			dev_err(&adapter->pdev->dev,
+				"Timeout reached  waiting for rom done");
+			return -EIO;
+		}
+		udelay(1);
+	}
+	return 0;
+}
+
+static int do_rom_fast_read(struct qlcnic_adapter *adapter,
+			    u32 addr, u32 *valp)
+{
+	int err;
+
+	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ADDRESS, addr);
+	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
+	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 3);
+	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_INSTR_OPCODE, 0xb);
+	if (qlcnic_wait_rom_done(adapter)) {
+		dev_err(&adapter->pdev->dev, "Error waiting for rom done\n");
+		return -EIO;
+	}
+	/* reset abyte_cnt and dummy_byte_cnt */
+	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 0);
+	udelay(10);
+	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
+
+	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA, &err);
+	return 0;
+}
+
+static int do_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
+				  u8 *bytes, size_t size)
+{
+	int addridx;
+	int ret = 0;
+
+	for (addridx = addr; addridx < (addr + size); addridx += 4) {
+		int v;
+		ret = do_rom_fast_read(adapter, addridx, &v);
+		if (ret != 0)
+			break;
+		*(__le32 *)bytes = cpu_to_le32(v);
+		bytes += 4;
+	}
+
+	return ret;
+}
+
+int
+qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
+				u8 *bytes, size_t size)
+{
+	int ret;
+
+	ret = qlcnic_rom_lock(adapter);
+	if (ret < 0)
+		return ret;
+
+	ret = do_rom_fast_read_words(adapter, addr, bytes, size);
+
+	qlcnic_rom_unlock(adapter);
+	return ret;
+}
+
+int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp)
+{
+	int ret;
+
+	if (qlcnic_rom_lock(adapter) != 0)
+		return -EIO;
+
+	ret = do_rom_fast_read(adapter, addr, valp);
+	qlcnic_rom_unlock(adapter);
+	return ret;
+}
+
+int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
+{
+	int addr, val, err;
+	int i, n, init_delay;
+	struct crb_addr_pair *buf;
+	unsigned offset;
+	u32 off;
+	struct pci_dev *pdev = adapter->pdev;
+
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, 0);
+	QLCWR(adapter, QLCNIC_RCVPEG_STATE, 0);
+
+	/* Halt all the indiviual PEGs and other blocks */
+	/* disable all I2Q */
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x10, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x14, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x18, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x1c, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x20, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x24, 0x0);
+
+	/* disable all niu interrupts */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x40, 0xff);
+	/* disable xge rx/tx */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x70000, 0x00);
+	/* disable xg1 rx/tx */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x80000, 0x00);
+	/* disable sideband mac */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x90000, 0x00);
+	/* disable ap0 mac */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xa0000, 0x00);
+	/* disable ap1 mac */
+	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xb0000, 0x00);
+
+	/* halt sre */
+	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000, &err);
+	QLCWR32(adapter, QLCNIC_CRB_SRE + 0x1000, val & (~(0x1)));
+
+	/* halt epg */
+	QLCWR32(adapter, QLCNIC_CRB_EPG + 0x1300, 0x1);
+
+	/* halt timers */
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x0, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x8, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x10, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x18, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x100, 0x0);
+	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x200, 0x0);
+	/* halt pegs */
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c, 1);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c, 1);
+	usleep_range(15000, 20000);
+
+	qlcnic_rom_unlock(adapter);
+	/* big hammer don't reset CAM block on reset */
+	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0xfeffffff);
+
+	/* Init HW CRB block */
+	if (qlcnic_rom_fast_read(adapter, 0, &n) != 0 || (n != 0xcafecafe) ||
+			qlcnic_rom_fast_read(adapter, 4, &n) != 0) {
+		dev_err(&pdev->dev, "ERROR Reading crb_init area: val:%x\n", n);
+		return -EIO;
+	}
+	offset = n & 0xffffU;
+	n = (n >> 16) & 0xffffU;
+
+	if (n >= 1024) {
+		dev_err(&pdev->dev, "QLOGIC card flash not initialized.\n");
+		return -EIO;
+	}
+
+	buf = kcalloc(n, sizeof(struct crb_addr_pair), GFP_KERNEL);
+	if (buf == NULL) {
+		dev_err(&pdev->dev, "Unable to calloc memory for rom read.\n");
+		return -ENOMEM;
+	}
+
+	for (i = 0; i < n; i++) {
+		if (qlcnic_rom_fast_read(adapter, 8*i + 4*offset, &val) != 0 ||
+		qlcnic_rom_fast_read(adapter, 8*i + 4*offset + 4, &addr) != 0) {
+			kfree(buf);
+			return -EIO;
+		}
+
+		buf[i].addr = addr;
+		buf[i].data = val;
+	}
+
+	for (i = 0; i < n; i++) {
+
+		off = qlcnic_decode_crb_addr(buf[i].addr);
+		if (off == QLCNIC_ADDR_ERROR) {
+			dev_err(&pdev->dev, "CRB init value out of range %x\n",
+					buf[i].addr);
+			continue;
+		}
+		off += QLCNIC_PCI_CRBSPACE;
+
+		if (off & 1)
+			continue;
+
+		/* skipping cold reboot MAGIC */
+		if (off == QLCNIC_CAM_RAM(0x1fc))
+			continue;
+		if (off == (QLCNIC_CRB_I2C0 + 0x1c))
+			continue;
+		if (off == (ROMUSB_GLB + 0xbc)) /* do not reset PCI */
+			continue;
+		if (off == (ROMUSB_GLB + 0xa8))
+			continue;
+		if (off == (ROMUSB_GLB + 0xc8)) /* core clock */
+			continue;
+		if (off == (ROMUSB_GLB + 0x24)) /* MN clock */
+			continue;
+		if (off == (ROMUSB_GLB + 0x1c)) /* MS clock */
+			continue;
+		if ((off & 0x0ff00000) == QLCNIC_CRB_DDR_NET)
+			continue;
+		/* skip the function enable register */
+		if (off == QLCNIC_PCIE_REG(PCIE_SETUP_FUNCTION))
+			continue;
+		if (off == QLCNIC_PCIE_REG(PCIE_SETUP_FUNCTION2))
+			continue;
+		if ((off & 0x0ff00000) == QLCNIC_CRB_SMB)
+			continue;
+
+		init_delay = 1;
+		/* After writing this register, HW needs time for CRB */
+		/* to quiet down (else crb_window returns 0xffffffff) */
+		if (off == QLCNIC_ROMUSB_GLB_SW_RESET)
+			init_delay = 1000;
+
+		QLCWR32(adapter, off, buf[i].data);
+
+		msleep(init_delay);
+	}
+	kfree(buf);
+
+	/* Initialize protocol process engine */
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_D + 0xec, 0x1e);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_D + 0x4c, 8);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_I + 0x4c, 8);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x8, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0xc, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x8, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0xc, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x8, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0xc, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x8, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0xc, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x8, 0);
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
+	usleep_range(1000, 2000);
+
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
+	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
+
+	return 0;
+}
+
+static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
+{
+	u32 val;
+	int retries = QLCNIC_CMDPEG_CHECK_RETRY_COUNT;
+
+	do {
+		val = QLCRD(adapter, QLCNIC_CMDPEG_STATE);
+
+		switch (val) {
+		case PHAN_INITIALIZE_COMPLETE:
+		case PHAN_INITIALIZE_ACK:
+			return 0;
+		case PHAN_INITIALIZE_FAILED:
+			goto out_err;
+		default:
+			break;
+		}
+
+		msleep(QLCNIC_CMDPEG_CHECK_DELAY);
+
+	} while (--retries);
+
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
+
+out_err:
+	dev_err(&adapter->pdev->dev,
+			"Command Peg not ready, state: 0x%x.\n", val);
+	return -EIO;
+}
+
+static int
+qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
+{
+	u32 val;
+	int retries = QLCNIC_RCVPEG_CHECK_RETRY_COUNT;
+
+	do {
+		val = QLCRD(adapter, QLCNIC_RCVPEG_STATE);
+
+		if (val == PHAN_PEG_RCV_INITIALIZED)
+			return 0;
+
+		msleep(QLCNIC_RCVPEG_CHECK_DELAY);
+
+	} while (--retries);
+
+	if (!retries) {
+		dev_err(&adapter->pdev->dev,
+			"RX Peg not ready, state: 0x%x.\n", val);
+		return -EIO;
+	}
+
+	return 0;
+}
+
+int
+qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
+{
+	int err;
+
+	err = qlcnic_cmd_peg_ready(adapter);
+	if (err)
+		return err;
+
+	err = qlcnic_receive_peg_ready(adapter);
+	if (err)
+		return err;
+
+	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
+
+	return err;
+}
+
+int
+qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
+
+	int timeo;
+	u32 val;
+
+	val = QLCRD(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
+	val = QLC_DEV_GET_DRV(val, adapter->portnum);
+	if ((val & 0x3) != QLCNIC_TYPE_NIC) {
+		dev_err(&adapter->pdev->dev,
+			"Not an Ethernet NIC func=%u\n", val);
+		return -EIO;
+	}
+	adapter->ahw->physical_port = (val >> 2);
+	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
+		timeo = QLCNIC_INIT_TIMEOUT_SECS;
+
+	adapter->dev_init_timeo = timeo;
+
+	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DRV_RESET_TIMEOUT, &timeo))
+		timeo = QLCNIC_RESET_TIMEOUT_SECS;
+
+	adapter->reset_ack_timeo = timeo;
+
+	return 0;
+}
+
+static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
+				struct qlcnic_flt_entry *region_entry)
+{
+	struct qlcnic_flt_header flt_hdr;
+	struct qlcnic_flt_entry *flt_entry;
+	int i = 0, ret;
+	u32 entry_size;
+
+	memset(region_entry, 0, sizeof(struct qlcnic_flt_entry));
+	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION,
+					 (u8 *)&flt_hdr,
+					 sizeof(struct qlcnic_flt_header));
+	if (ret) {
+		dev_warn(&adapter->pdev->dev,
+			 "error reading flash layout header\n");
+		return -EIO;
+	}
+
+	entry_size = flt_hdr.len - sizeof(struct qlcnic_flt_header);
+	flt_entry = vmalloc(entry_size);
+	if (flt_entry == NULL) {
+		dev_err(&adapter->pdev->dev, "error allocating memory\n");
+		return -EIO;
+	}
+	memset(flt_entry, 0, entry_size);
+
+	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION +
+					 sizeof(struct qlcnic_flt_header),
+					 (u8 *)flt_entry, entry_size);
+	if (ret) {
+		dev_warn(&adapter->pdev->dev,
+			 "error reading flash layout entries\n");
+		goto err_out;
+	}
+
+	while (i < (entry_size/sizeof(struct qlcnic_flt_entry))) {
+		if (flt_entry[i].region == region)
+			break;
+		i++;
+	}
+	if (i >= (entry_size/sizeof(struct qlcnic_flt_entry))) {
+		dev_warn(&adapter->pdev->dev,
+			 "region=%x not found in %d regions\n", region, i);
+		ret = -EIO;
+		goto err_out;
+	}
+	memcpy(region_entry, &flt_entry[i], sizeof(struct qlcnic_flt_entry));
+
+err_out:
+	vfree(flt_entry);
+	return ret;
+}
+
+int
+qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
+{
+	struct qlcnic_flt_entry fw_entry;
+	u32 ver = -1, min_ver;
+	int ret;
+
+	if (adapter->ahw->revision_id == QLCNIC_P3P_C0)
+		ret = qlcnic_get_flt_entry(adapter, QLCNIC_C0_FW_IMAGE_REGION,
+						 &fw_entry);
+	else
+		ret = qlcnic_get_flt_entry(adapter, QLCNIC_B0_FW_IMAGE_REGION,
+						 &fw_entry);
+
+	if (!ret)
+		/* 0-4:-signature,  4-8:-fw version */
+		qlcnic_rom_fast_read(adapter, fw_entry.start_addr + 4,
+				     (int *)&ver);
+	else
+		qlcnic_rom_fast_read(adapter, QLCNIC_FW_VERSION_OFFSET,
+				     (int *)&ver);
+
+	ver = QLCNIC_DECODE_VERSION(ver);
+	min_ver = QLCNIC_MIN_FW_VERSION;
+
+	if (ver < min_ver) {
+		dev_err(&adapter->pdev->dev,
+			"firmware version %d.%d.%d unsupported."
+			"Min supported version %d.%d.%d\n",
+			_major(ver), _minor(ver), _build(ver),
+			_major(min_ver), _minor(min_ver), _build(min_ver));
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int
+qlcnic_has_mn(struct qlcnic_adapter *adapter)
+{
+	int err;
+	u32 capability;
+	capability = 0;
+
+	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY, &err);
+	if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
+		return 1;
+
+	return 0;
+}
+
+static
+struct uni_table_desc *qlcnic_get_table_desc(const u8 *unirom, int section)
+{
+	u32 i;
+	struct uni_table_desc *directory = (struct uni_table_desc *) &unirom[0];
+	__le32 entries = cpu_to_le32(directory->num_entries);
+
+	for (i = 0; i < entries; i++) {
+
+		__le32 offs = cpu_to_le32(directory->findex) +
+				(i * cpu_to_le32(directory->entry_size));
+		__le32 tab_type = cpu_to_le32(*((u32 *)&unirom[offs] + 8));
+
+		if (tab_type == section)
+			return (struct uni_table_desc *) &unirom[offs];
+	}
+
+	return NULL;
+}
+
+#define FILEHEADER_SIZE (14 * 4)
+
+static int
+qlcnic_validate_header(struct qlcnic_adapter *adapter)
+{
+	const u8 *unirom = adapter->fw->data;
+	struct uni_table_desc *directory = (struct uni_table_desc *) &unirom[0];
+	__le32 fw_file_size = adapter->fw->size;
+	__le32 entries;
+	__le32 entry_size;
+	__le32 tab_size;
+
+	if (fw_file_size < FILEHEADER_SIZE)
+		return -EINVAL;
+
+	entries = cpu_to_le32(directory->num_entries);
+	entry_size = cpu_to_le32(directory->entry_size);
+	tab_size = cpu_to_le32(directory->findex) + (entries * entry_size);
+
+	if (fw_file_size < tab_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int
+qlcnic_validate_bootld(struct qlcnic_adapter *adapter)
+{
+	struct uni_table_desc *tab_desc;
+	struct uni_data_desc *descr;
+	const u8 *unirom = adapter->fw->data;
+	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
+				QLCNIC_UNI_BOOTLD_IDX_OFF));
+	__le32 offs;
+	__le32 tab_size;
+	__le32 data_size;
+
+	tab_desc = qlcnic_get_table_desc(unirom, QLCNIC_UNI_DIR_SECT_BOOTLD);
+
+	if (!tab_desc)
+		return -EINVAL;
+
+	tab_size = cpu_to_le32(tab_desc->findex) +
+			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
+	offs = cpu_to_le32(tab_desc->findex) +
+		(cpu_to_le32(tab_desc->entry_size) * (idx));
+	descr = (struct uni_data_desc *)&unirom[offs];
+
+	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
+
+	if (adapter->fw->size < data_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int
+qlcnic_validate_fw(struct qlcnic_adapter *adapter)
+{
+	struct uni_table_desc *tab_desc;
+	struct uni_data_desc *descr;
+	const u8 *unirom = adapter->fw->data;
+	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
+				QLCNIC_UNI_FIRMWARE_IDX_OFF));
+	__le32 offs;
+	__le32 tab_size;
+	__le32 data_size;
+
+	tab_desc = qlcnic_get_table_desc(unirom, QLCNIC_UNI_DIR_SECT_FW);
+
+	if (!tab_desc)
+		return -EINVAL;
+
+	tab_size = cpu_to_le32(tab_desc->findex) +
+			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
+	offs = cpu_to_le32(tab_desc->findex) +
+		(cpu_to_le32(tab_desc->entry_size) * (idx));
+	descr = (struct uni_data_desc *)&unirom[offs];
+	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
+
+	if (adapter->fw->size < data_size)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int
+qlcnic_validate_product_offs(struct qlcnic_adapter *adapter)
+{
+	struct uni_table_desc *ptab_descr;
+	const u8 *unirom = adapter->fw->data;
+	int mn_present = qlcnic_has_mn(adapter);
+	__le32 entries;
+	__le32 entry_size;
+	__le32 tab_size;
+	u32 i;
+
+	ptab_descr = qlcnic_get_table_desc(unirom,
+				QLCNIC_UNI_DIR_SECT_PRODUCT_TBL);
+	if (!ptab_descr)
+		return -EINVAL;
+
+	entries = cpu_to_le32(ptab_descr->num_entries);
+	entry_size = cpu_to_le32(ptab_descr->entry_size);
+	tab_size = cpu_to_le32(ptab_descr->findex) + (entries * entry_size);
+
+	if (adapter->fw->size < tab_size)
+		return -EINVAL;
+
+nomn:
+	for (i = 0; i < entries; i++) {
+
+		__le32 flags, file_chiprev, offs;
+		u8 chiprev = adapter->ahw->revision_id;
+		u32 flagbit;
+
+		offs = cpu_to_le32(ptab_descr->findex) +
+				(i * cpu_to_le32(ptab_descr->entry_size));
+		flags = cpu_to_le32(*((int *)&unirom[offs] +
+						QLCNIC_UNI_FLAGS_OFF));
+		file_chiprev = cpu_to_le32(*((int *)&unirom[offs] +
+						QLCNIC_UNI_CHIP_REV_OFF));
+
+		flagbit = mn_present ? 1 : 2;
+
+		if ((chiprev == file_chiprev) &&
+					((1ULL << flagbit) & flags)) {
+			adapter->file_prd_off = offs;
+			return 0;
+		}
+	}
+	if (mn_present) {
+		mn_present = 0;
+		goto nomn;
+	}
+	return -EINVAL;
+}
+
+static int
+qlcnic_validate_unified_romimage(struct qlcnic_adapter *adapter)
+{
+	if (qlcnic_validate_header(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: header validation failed\n");
+		return -EINVAL;
+	}
+
+	if (qlcnic_validate_product_offs(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: product validation failed\n");
+		return -EINVAL;
+	}
+
+	if (qlcnic_validate_bootld(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: bootld validation failed\n");
+		return -EINVAL;
+	}
+
+	if (qlcnic_validate_fw(adapter)) {
+		dev_err(&adapter->pdev->dev,
+				"unified image: firmware validation failed\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static
+struct uni_data_desc *qlcnic_get_data_desc(struct qlcnic_adapter *adapter,
+			u32 section, u32 idx_offset)
+{
+	const u8 *unirom = adapter->fw->data;
+	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
+								idx_offset));
+	struct uni_table_desc *tab_desc;
+	__le32 offs;
+
+	tab_desc = qlcnic_get_table_desc(unirom, section);
+
+	if (tab_desc == NULL)
+		return NULL;
+
+	offs = cpu_to_le32(tab_desc->findex) +
+			(cpu_to_le32(tab_desc->entry_size) * idx);
+
+	return (struct uni_data_desc *)&unirom[offs];
+}
+
+static u8 *
+qlcnic_get_bootld_offs(struct qlcnic_adapter *adapter)
+{
+	u32 offs = QLCNIC_BOOTLD_START;
+
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
+					QLCNIC_UNI_DIR_SECT_BOOTLD,
+					QLCNIC_UNI_BOOTLD_IDX_OFF))->findex);
+
+	return (u8 *)&adapter->fw->data[offs];
+}
+
+static u8 *
+qlcnic_get_fw_offs(struct qlcnic_adapter *adapter)
+{
+	u32 offs = QLCNIC_IMAGE_START;
+
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
+					QLCNIC_UNI_DIR_SECT_FW,
+					QLCNIC_UNI_FIRMWARE_IDX_OFF))->findex);
+
+	return (u8 *)&adapter->fw->data[offs];
+}
+
+static __le32
+qlcnic_get_fw_size(struct qlcnic_adapter *adapter)
+{
+	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
+		return cpu_to_le32((qlcnic_get_data_desc(adapter,
+					QLCNIC_UNI_DIR_SECT_FW,
+					QLCNIC_UNI_FIRMWARE_IDX_OFF))->size);
+	else
+		return cpu_to_le32(
+			*(u32 *)&adapter->fw->data[QLCNIC_FW_SIZE_OFFSET]);
+}
+
+static __le32
+qlcnic_get_fw_version(struct qlcnic_adapter *adapter)
+{
+	struct uni_data_desc *fw_data_desc;
+	const struct firmware *fw = adapter->fw;
+	__le32 major, minor, sub;
+	const u8 *ver_str;
+	int i, ret;
+
+	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
+		return cpu_to_le32(*(u32 *)&fw->data[QLCNIC_FW_VERSION_OFFSET]);
+
+	fw_data_desc = qlcnic_get_data_desc(adapter, QLCNIC_UNI_DIR_SECT_FW,
+			QLCNIC_UNI_FIRMWARE_IDX_OFF);
+	ver_str = fw->data + cpu_to_le32(fw_data_desc->findex) +
+		cpu_to_le32(fw_data_desc->size) - 17;
+
+	for (i = 0; i < 12; i++) {
+		if (!strncmp(&ver_str[i], "REV=", 4)) {
+			ret = sscanf(&ver_str[i+4], "%u.%u.%u ",
+					&major, &minor, &sub);
+			if (ret != 3)
+				return 0;
+			else
+				return major + (minor << 8) + (sub << 16);
+		}
+	}
+
+	return 0;
+}
+
+static __le32
+qlcnic_get_bios_version(struct qlcnic_adapter *adapter)
+{
+	const struct firmware *fw = adapter->fw;
+	__le32 bios_ver, prd_off = adapter->file_prd_off;
+
+	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
+		return cpu_to_le32(
+			*(u32 *)&fw->data[QLCNIC_BIOS_VERSION_OFFSET]);
+
+	bios_ver = cpu_to_le32(*((u32 *) (&fw->data[prd_off])
+				+ QLCNIC_UNI_BIOS_VERSION_OFF));
+
+	return (bios_ver << 16) + ((bios_ver >> 8) & 0xff00) + (bios_ver >> 24);
+}
+
+static void qlcnic_rom_lock_recovery(struct qlcnic_adapter *adapter)
+{
+	if (qlcnic_pcie_sem_lock(adapter, 2, QLCNIC_ROM_LOCK_ID))
+		dev_info(&adapter->pdev->dev, "Resetting rom_lock\n");
+
+	qlcnic_pcie_sem_unlock(adapter, 2);
+}
+
+static int
+qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
+{
+	u32 heartbeat, ret = -EIO;
+	int retries = QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT;
+
+	adapter->heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+
+	do {
+		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
+		heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
+		if (heartbeat != adapter->heartbeat) {
+			ret = QLCNIC_RCODE_SUCCESS;
+			break;
+		}
+	} while (--retries);
+
+	return ret;
+}
+
+int
+qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
+{
+	if ((adapter->flags & QLCNIC_FW_HANG) ||
+			qlcnic_check_fw_hearbeat(adapter)) {
+		qlcnic_rom_lock_recovery(adapter);
+		return 1;
+	}
+
+	if (adapter->need_fw_reset)
+		return 1;
+
+	if (adapter->fw)
+		return 1;
+
+	return 0;
+}
+
+static char *fw_name[] = {
+	QLCNIC_UNIFIED_ROMIMAGE_NAME,
+	QLCNIC_FLASH_ROMIMAGE_NAME,
+};
+
+int
+qlcnic_load_firmware(struct qlcnic_adapter *adapter)
+{
+	u64 *ptr64;
+	u32 i, flashaddr, size;
+	const struct firmware *fw = adapter->fw;
+	struct pci_dev *pdev = adapter->pdev;
+
+	dev_info(&pdev->dev, "loading firmware from %s\n",
+			fw_name[adapter->ahw->fw_type]);
+
+	if (fw) {
+		__le64 data;
+
+		size = (QLCNIC_IMAGE_START - QLCNIC_BOOTLD_START) / 8;
+
+		ptr64 = (u64 *)qlcnic_get_bootld_offs(adapter);
+		flashaddr = QLCNIC_BOOTLD_START;
+
+		for (i = 0; i < size; i++) {
+			data = cpu_to_le64(ptr64[i]);
+
+			if (qlcnic_pci_mem_write_2M(adapter, flashaddr, data))
+				return -EIO;
+
+			flashaddr += 8;
+		}
+
+		size = (__force u32)qlcnic_get_fw_size(adapter) / 8;
+
+		ptr64 = (u64 *)qlcnic_get_fw_offs(adapter);
+		flashaddr = QLCNIC_IMAGE_START;
+
+		for (i = 0; i < size; i++) {
+			data = cpu_to_le64(ptr64[i]);
+
+			if (qlcnic_pci_mem_write_2M(adapter,
+						flashaddr, data))
+				return -EIO;
+
+			flashaddr += 8;
+		}
+
+		size = (__force u32)qlcnic_get_fw_size(adapter) % 8;
+		if (size) {
+			data = cpu_to_le64(ptr64[i]);
+
+			if (qlcnic_pci_mem_write_2M(adapter,
+						flashaddr, data))
+				return -EIO;
+		}
+
+	} else {
+		u64 data;
+		u32 hi, lo;
+		int ret;
+		struct qlcnic_flt_entry bootld_entry;
+
+		ret = qlcnic_get_flt_entry(adapter, QLCNIC_BOOTLD_REGION,
+					&bootld_entry);
+		if (!ret) {
+			size = bootld_entry.size / 8;
+			flashaddr = bootld_entry.start_addr;
+		} else {
+			size = (QLCNIC_IMAGE_START - QLCNIC_BOOTLD_START) / 8;
+			flashaddr = QLCNIC_BOOTLD_START;
+			dev_info(&pdev->dev,
+				"using legacy method to get flash fw region");
+		}
+
+		for (i = 0; i < size; i++) {
+			if (qlcnic_rom_fast_read(adapter,
+					flashaddr, (int *)&lo) != 0)
+				return -EIO;
+			if (qlcnic_rom_fast_read(adapter,
+					flashaddr + 4, (int *)&hi) != 0)
+				return -EIO;
+
+			data = (((u64)hi << 32) | lo);
+
+			if (qlcnic_pci_mem_write_2M(adapter,
+						flashaddr, data))
+				return -EIO;
+
+			flashaddr += 8;
+		}
+	}
+	usleep_range(1000, 2000);
+
+	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x18, 0x1020);
+	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0x80001e);
+	return 0;
+}
+
+static int
+qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
+{
+	__le32 val;
+	u32 ver, bios, min_size;
+	struct pci_dev *pdev = adapter->pdev;
+	const struct firmware *fw = adapter->fw;
+	u8 fw_type = adapter->ahw->fw_type;
+
+	if (fw_type == QLCNIC_UNIFIED_ROMIMAGE) {
+		if (qlcnic_validate_unified_romimage(adapter))
+			return -EINVAL;
+
+		min_size = QLCNIC_UNI_FW_MIN_SIZE;
+	} else {
+		val = cpu_to_le32(*(u32 *)&fw->data[QLCNIC_FW_MAGIC_OFFSET]);
+		if ((__force u32)val != QLCNIC_BDINFO_MAGIC)
+			return -EINVAL;
+
+		min_size = QLCNIC_FW_MIN_SIZE;
+	}
+
+	if (fw->size < min_size)
+		return -EINVAL;
+
+	val = qlcnic_get_fw_version(adapter);
+	ver = QLCNIC_DECODE_VERSION(val);
+
+	if (ver < QLCNIC_MIN_FW_VERSION) {
+		dev_err(&pdev->dev,
+				"%s: firmware version %d.%d.%d unsupported\n",
+		fw_name[fw_type], _major(ver), _minor(ver), _build(ver));
+		return -EINVAL;
+	}
+
+	val = qlcnic_get_bios_version(adapter);
+	qlcnic_rom_fast_read(adapter, QLCNIC_BIOS_VERSION_OFFSET, (int *)&bios);
+	if ((__force u32)val != bios) {
+		dev_err(&pdev->dev, "%s: firmware bios is incompatible\n",
+				fw_name[fw_type]);
+		return -EINVAL;
+	}
+
+	QLCWR(adapter, QLCNIC_FW_IMG_VALID, QLCNIC_BDINFO_MAGIC);
+	return 0;
+}
+
+static void
+qlcnic_get_next_fwtype(struct qlcnic_adapter *adapter)
+{
+	u8 fw_type;
+
+	switch (adapter->ahw->fw_type) {
+	case QLCNIC_UNKNOWN_ROMIMAGE:
+		fw_type = QLCNIC_UNIFIED_ROMIMAGE;
+		break;
+
+	case QLCNIC_UNIFIED_ROMIMAGE:
+	default:
+		fw_type = QLCNIC_FLASH_ROMIMAGE;
+		break;
+	}
+
+	adapter->ahw->fw_type = fw_type;
+}
+
+
+
+void qlcnic_request_firmware(struct qlcnic_adapter *adapter)
+{
+	struct pci_dev *pdev = adapter->pdev;
+	int rc;
+
+	adapter->ahw->fw_type = QLCNIC_UNKNOWN_ROMIMAGE;
+
+next:
+	qlcnic_get_next_fwtype(adapter);
+
+	if (adapter->ahw->fw_type == QLCNIC_FLASH_ROMIMAGE) {
+		adapter->fw = NULL;
+	} else {
+		rc = request_firmware(&adapter->fw,
+				fw_name[adapter->ahw->fw_type], &pdev->dev);
+		if (rc != 0)
+			goto next;
+
+		rc = qlcnic_validate_firmware(adapter);
+		if (rc != 0) {
+			release_firmware(adapter->fw);
+			usleep_range(1000, 2000);
+			goto next;
+		}
+	}
+}
+
+
+void
+qlcnic_release_firmware(struct qlcnic_adapter *adapter)
+{
+	if (adapter->fw)
+		release_firmware(adapter->fw);
+	adapter->fw = NULL;
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 118b2b2..08c2aa8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -300,9 +300,9 @@ qlcnic_83xx_setup_intr(struct qlcnic_adapter *adapter, u8 num_intr)
 		return -ENOMEM;
 	if (!(adapter->flags & QLCNIC_MSIX_ENABLED)) {
 		/* MSI-X enablement failed, use legacy interrupt */
-		adapter->tgt_status_reg = ahw->pci_base0 + QLCNIC_83XX_INTX_PTR;
-		adapter->tgt_mask_reg = ahw->pci_base0 + QLCNIC_83XX_INTX_MASK;
-		adapter->isr_int_vec = ahw->pci_base0 + QLCNIC_83XX_INTX_TRGR;
+		adapter->tgt_status_reg = ahw->pci_base0 + QLC_83XX_INTX_PTR;
+		adapter->tgt_mask_reg = ahw->pci_base0 + QLC_83XX_INTX_MASK;
+		adapter->isr_int_vec = ahw->pci_base0 + QLC_83XX_INTX_TRGR;
 		adapter->msix_entries[0].vector = adapter->pdev->irq;
 		dev_info(&adapter->pdev->dev, "using legacy interrupt\n");
 	}
@@ -349,10 +349,10 @@ irqreturn_t qlcnic_83xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
 
 	intr_val = readl(adapter->tgt_status_reg);
 
-	if (!QLCNIC_83XX_VALID_INTX_BIT31(intr_val))
+	if (!QLC_83XX_VALID_INTX_BIT31(intr_val))
 		return IRQ_NONE;
 
-	if (QLCNIC_83XX_INTX_FUNC(intr_val) != adapter->ahw->pci_func) {
+	if (QLC_83XX_INTX_FUNC(intr_val) != adapter->ahw->pci_func) {
 		dev_info(&adapter->pdev->dev,
 			"Interrupt for wrong func: 0x%x\n", intr_val);
 		return IRQ_NONE;
@@ -363,10 +363,10 @@ irqreturn_t qlcnic_83xx_clear_legacy_intr(struct qlcnic_adapter *adapter)
 	/* Legacy Workaround for A0 & B0 */
 	do {
 		intr_val = readl(adapter->tgt_status_reg);
-		if (QLCNIC_83XX_INTX_FUNC(intr_val) != ahw->pci_func)
+		if (QLC_83XX_INTX_FUNC(intr_val) != ahw->pci_func)
 			break;
 		retries++;
-	} while (QLCNIC_83XX_VALID_INTX_BIT30(intr_val) &&
+	} while (QLC_83XX_VALID_INTX_BIT30(intr_val) &&
 		(retries < QLC_83XX_LEGACY_INTX_MAX_RETRY));
 
 	if (retries == QLC_83XX_LEGACY_INTX_MAX_RETRY) {
@@ -630,445 +630,6 @@ qlcnic_83xx_unlock_driver(struct qlcnic_adapter *adapter)
 	QLCRDX(adapter->ahw, QLC_83XX_DRV_UNLOCK);
 }
 
-static struct qlcnic_rx_buffer *
-qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_sds_ring *sds_ring,
-		u8 ring, u64 sts_data[])
-{
-	struct net_device *netdev = adapter->netdev;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-	struct qlcnic_rx_buffer *buffer;
-	struct sk_buff *skb;
-	struct qlcnic_host_rds_ring *rds_ring;
-	int index, length, cksum;
-	u16 vid = 0xffff;
-
-	if (unlikely(ring >= adapter->max_rds_rings))
-		return NULL;
-
-	rds_ring = &recv_ctx->rds_rings[ring];
-
-	index = qlcnic_83xx_hndl(sts_data[0]);
-	if (unlikely(index >= rds_ring->num_desc))
-		return NULL;
-
-	buffer = &rds_ring->rx_buf_arr[index];
-
-	length = qlcnic_83xx_pktln(sts_data[0]);
-	cksum  = qlcnic_83xx_csum_status(sts_data[1]);
-	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, cksum);
-	if (!skb)
-		return buffer;
-
-	if (length > rds_ring->skb_size)
-		skb_put(skb, rds_ring->skb_size);
-	else
-		skb_put(skb, length);
-
-	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
-		adapter->stats.rxdropped++;
-		dev_kfree_skb(skb);
-		return buffer;
-	}
-
-	skb->protocol = eth_type_trans(skb, netdev);
-
-	if (vid != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vid);
-
-	napi_gro_receive(&sds_ring->napi, skb);
-
-	adapter->stats.rx_pkts++;
-	adapter->stats.rxbytes += length;
-
-	return buffer;
-}
-
-static struct qlcnic_rx_buffer *
-qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_sds_ring *sds_ring,
-		u8 ring, u64 sts_data[])
-{
-	struct net_device *netdev = adapter->netdev;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-	struct qlcnic_rx_buffer *buffer;
-	struct sk_buff *skb;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct iphdr *iph;
-	struct ipv6hdr *ipv6h;
-	struct tcphdr *th;
-	bool push;
-	int l2_hdr_offset, l4_hdr_offset;
-	int index;
-	u16 lro_length, length, data_offset;
-	u16 vid = 0xffff;
-
-	if (unlikely(ring > adapter->max_rds_rings))
-		return NULL;
-
-	rds_ring = &recv_ctx->rds_rings[ring];
-
-	index = qlcnic_83xx_hndl(sts_data[0]);
-	if (unlikely(index > rds_ring->num_desc))
-		return NULL;
-
-	buffer = &rds_ring->rx_buf_arr[index];
-
-	lro_length = qlcnic_83xx_lro_pktln(sts_data[0]);
-	l2_hdr_offset = qlcnic_83xx_l2_hdr_off(sts_data[1]);
-	l4_hdr_offset = qlcnic_83xx_l4_hdr_off(sts_data[1]);
-	push = qlcnic_83xx_is_psh_bit(sts_data[1]);
-
-	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
-	if (!skb)
-		return buffer;
-	if (qlcnic_83xx_is_tstamp(sts_data[1]))
-		data_offset = l4_hdr_offset + QLC_TCP_TS_HDR_SIZE;
-	else
-		data_offset = l4_hdr_offset + QLC_TCP_HDR_SIZE;
-
-	skb_put(skb, lro_length + data_offset);
-
-	skb_pull(skb, l2_hdr_offset);
-
-	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
-		adapter->stats.rxdropped++;
-		dev_kfree_skb(skb);
-		return buffer;
-	}
-
-	skb->protocol = eth_type_trans(skb, netdev);
-
-	if (htons(skb->protocol) == ETH_P_IPV6) {
-		ipv6h = (struct ipv6hdr *)skb->data;
-		th = (struct tcphdr *)(skb->data + sizeof(struct ipv6hdr));
-
-		length = (th->doff << 2) + lro_length;
-		ipv6h->payload_len = htons(length);
-	} else {
-		iph = (struct iphdr *)skb->data;
-		th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
-
-		length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
-		iph->tot_len = htons(length);
-		iph->check = 0;
-		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
-	}
-
-
-	th->psh = push;
-
-	length = skb->len;
-
-	if (vid != 0xffff)
-		__vlan_hwaccel_put_tag(skb, vid);
-	netif_receive_skb(skb);
-
-	adapter->stats.lro_pkts++;
-	adapter->stats.lrobytes += length;
-	return buffer;
-}
-
-static int
-qlcnic_83xx_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
-{
-	struct qlcnic_adapter *adapter = sds_ring->adapter;
-	struct list_head *cur;
-	struct status_desc *desc;
-	struct qlcnic_rx_buffer *rxbuf = NULL;
-	u64 sts_data[2];
-
-	int count = 0, opcode;
-	u8 ring;
-	u32 consumer = sds_ring->consumer;
-
-	while (count < max) {
-		desc = &sds_ring->desc_head[consumer];
-		sts_data[1] = le64_to_cpu(desc->status_desc_data[1]);
-		opcode = qlcnic_83xx_opcode(sts_data[1]);
-		if (!opcode)
-			break;
-		sts_data[0] = le64_to_cpu(desc->status_desc_data[0]);
-		ring = QLCNIC_FETCH_RING_ID(sts_data[0]);
-
-		switch (opcode) {
-		case QLCNIC_83XX_REG_DESC:
-			rxbuf = qlcnic_83xx_process_rcv(adapter, sds_ring,
-					ring, sts_data);
-			break;
-		case QLCNIC_83XX_LRO_DESC:
-			rxbuf = qlcnic_83xx_process_lro(adapter, sds_ring,
-					ring, sts_data);
-			break;
-		default:
-			dev_info(&adapter->pdev->dev,
-				"Unkonwn opcode: 0x%x\n", opcode);
-			goto skip;
-		}
-
-		if (likely(rxbuf))
-			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
-		else
-			adapter->stats.null_rxbuf++;
-
-skip:
-		desc = &sds_ring->desc_head[consumer];
-		/* Reset the descriptor */
-		desc->status_desc_data[1] = 0;
-		consumer = get_next_index(consumer, sds_ring->num_desc);
-		count++;
-	}
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		struct qlcnic_host_rds_ring *rds_ring =
-			&adapter->recv_ctx->rds_rings[ring];
-
-		if (!list_empty(&sds_ring->free_list[ring])) {
-			list_for_each(cur, &sds_ring->free_list[ring]) {
-				rxbuf = list_entry(cur,
-						struct qlcnic_rx_buffer, list);
-				qlcnic_alloc_rx_skb(adapter, rds_ring, rxbuf);
-			}
-			spin_lock(&rds_ring->lock);
-			list_splice_tail_init(&sds_ring->free_list[ring],
-						&rds_ring->free_list);
-			spin_unlock(&rds_ring->lock);
-		}
-
-		qlcnic_post_rx_buffers_nodb(adapter, rds_ring, ring);
-	}
-
-	if (count) {
-		sds_ring->consumer = consumer;
-		writel(consumer, sds_ring->crb_sts_consumer);
-	}
-	return count;
-}
-
-static int qlcnic_83xx_poll(struct napi_struct *napi, int budget)
-{
-	struct qlcnic_host_sds_ring *sds_ring =
-		container_of(napi, struct qlcnic_host_sds_ring, napi);
-
-	struct qlcnic_adapter *adapter = sds_ring->adapter;
-
-	/* there is only 1 tx ring in this path */
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
-
-	int tx_complete;
-	int work_done;
-
-	if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
-		qlcnic_83xx_process_aen(adapter);
-
-	tx_complete = qlcnic_process_cmd_ring(adapter, tx_ring, budget);
-
-	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
-
-	if ((work_done < budget) && tx_complete) {
-		napi_complete(&sds_ring->napi);
-		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
-			qlcnic_83xx_enable_intr(adapter, sds_ring);
-	}
-
-	return work_done;
-}
-
-static int qlcnic_83xx_msix_tx_poll(struct napi_struct *napi, int budget)
-{
-	struct qlcnic_host_tx_ring *tx_ring =
-		container_of(napi, struct qlcnic_host_tx_ring, napi);
-
-	struct qlcnic_adapter *adapter = tx_ring->adapter;
-	int work_done;
-
-	work_done = qlcnic_process_cmd_ring(adapter, tx_ring,
-				 QLCNIC_TX_POLL_BUDGET);
-
-	if (work_done) {
-		napi_complete(&tx_ring->napi);
-		if (test_bit(__QLCNIC_DEV_UP , &adapter->state))
-			qlcnic_83xx_enable_tx_intr(adapter, tx_ring);
-	}
-
-	return work_done;
-}
-
-static int qlcnic_83xx_rx_poll(struct napi_struct *napi, int budget)
-{
-	struct qlcnic_host_sds_ring *sds_ring =
-		container_of(napi, struct qlcnic_host_sds_ring, napi);
-
-	struct qlcnic_adapter *adapter = sds_ring->adapter;
-	int work_done;
-
-	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
-
-	if (work_done < budget) {
-		napi_complete(&sds_ring->napi);
-		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
-			qlcnic_83xx_enable_intr(adapter, sds_ring);
-	}
-
-	return work_done;
-}
-
-void
-qlcnic_83xx_napi_enable(struct qlcnic_adapter *adapter)
-{
-	int ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
-		return;
-
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		napi_enable(&sds_ring->napi);
-		qlcnic_83xx_enable_intr(adapter, sds_ring);
-	}
-
-	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
-		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
-			tx_ring = &adapter->tx_ring[ring];
-			napi_enable(&tx_ring->napi);
-			qlcnic_83xx_enable_tx_intr(adapter, tx_ring);
-		}
-	}
-}
-
-void
-qlcnic_83xx_napi_disable(struct qlcnic_adapter *adapter)
-{
-	int ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-	struct qlcnic_host_tx_ring *tx_ring;
-
-	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
-		return;
-
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		writel(1, sds_ring->crb_intr_mask);
-		napi_synchronize(&sds_ring->napi);
-		napi_disable(&sds_ring->napi);
-	}
-
-	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
-		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
-			tx_ring = &adapter->tx_ring[ring];
-			qlcnic_83xx_disable_tx_intr(adapter, tx_ring);
-			napi_synchronize(&tx_ring->napi);
-			napi_disable(&tx_ring->napi);
-		}
-	}
-}
-
-int
-qlcnic_83xx_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
-{
-	int ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_host_tx_ring *tx_ring;
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-
-	if (qlcnic_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
-		return -ENOMEM;
-
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		if (adapter->flags & QLCNIC_MSIX_ENABLED)
-			netif_napi_add(netdev, &sds_ring->napi,
-			    qlcnic_83xx_rx_poll, QLCNIC_NETDEV_WEIGHT * 2);
-		else
-			netif_napi_add(netdev, &sds_ring->napi,
-			    qlcnic_83xx_poll,
-				QLCNIC_NETDEV_WEIGHT/adapter->max_sds_rings);
-	}
-
-	if (qlcnic_alloc_tx_rings(adapter, netdev)) {
-		qlcnic_free_sds_rings(recv_ctx);
-		return -ENOMEM;
-	}
-
-	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
-		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
-			tx_ring = &adapter->tx_ring[ring];
-			netif_napi_add(netdev, &tx_ring->napi,
-				qlcnic_83xx_msix_tx_poll,
-				QLCNIC_NETDEV_WEIGHT);
-		}
-	}
-
-	return 0;
-}
-
-void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *adapter,
-		struct qlcnic_host_sds_ring *sds_ring,
-		int ring, u64 sts_data[])
-{
-	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
-	struct sk_buff *skb;
-	struct qlcnic_host_rds_ring *rds_ring;
-	int index, length, cksum;
-
-	if (unlikely(ring >= adapter->max_rds_rings))
-		return;
-
-	rds_ring = &recv_ctx->rds_rings[ring];
-	index = qlcnic_83xx_hndl(sts_data[0]);
-	if (unlikely(index >= rds_ring->num_desc))
-		return;
-
-	length = qlcnic_83xx_pktln(sts_data[0]);
-	cksum  = qlcnic_83xx_csum_status(sts_data[0]);
-	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
-	if (!skb)
-		return;
-
-	if (length > rds_ring->skb_size)
-		skb_put(skb, rds_ring->skb_size);
-	else
-		skb_put(skb, length);
-
-	if (!qlcnic_check_loopback_buff(skb->data, adapter->mac_addr))
-		adapter->ahw->diag_cnt++;
-	else
-		dump_skb(skb, adapter);
-
-	dev_kfree_skb_any(skb);
-	return;
-}
-
-void qlcnic_83xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
-{
-	struct qlcnic_adapter *adapter = sds_ring->adapter;
-	struct status_desc *desc;
-	u64 sts_data[2];
-	int ring, opcode;
-
-	u32 consumer = sds_ring->consumer;
-
-	desc = &sds_ring->desc_head[consumer];
-	sts_data[0] = le64_to_cpu(desc->status_desc_data[0]);
-	sts_data[1] = le64_to_cpu(desc->status_desc_data[1]);
-	opcode = qlcnic_83xx_opcode(sts_data[1]);
-	if (!opcode)
-		return;
-
-	ring = QLCNIC_FETCH_RING_ID(qlcnic_83xx_hndl(sts_data[0]));
-	qlcnic_83xx_process_rcv_diag(adapter, sds_ring, ring, sts_data);
-
-	desc = &sds_ring->desc_head[consumer];
-	desc->status_desc_data[0] = cpu_to_le64(STATUS_OWNER_PHANTOM);
-	consumer = get_next_index(consumer, sds_ring->num_desc);
-
-	sds_ring->consumer = consumer;
-	writel(consumer, sds_ring->crb_sts_consumer);
-}
-
 int qlcnic_83xx_get_port_info(struct qlcnic_adapter *adapter)
 {
 	int status;
@@ -1215,7 +776,7 @@ qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,
 	}
 	total_regs = cmd->rsp.num;
 	switch (type) {
-	case QLCNIC_83XX_STAT_MAC:
+	case QLC_83XX_STAT_MAC:
 		/* fill in MAC tx counters */
 		for (k = 2; k < 28; k += 2)
 			data = qlcnic_83xx_copy_stats(cmd, data, k);
@@ -1228,7 +789,7 @@ qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,
 		for (k += 6; k < 80; k += 2)
 			data = qlcnic_83xx_copy_stats(cmd, data, k);
 		break;
-	case QLCNIC_83XX_STAT_RX:
+	case QLC_83XX_STAT_RX:
 		for (k = 2; k < 8; k += 2)
 			data = qlcnic_83xx_copy_stats(cmd, data, k);
 		/* skip 8 bytes of reserved data */
@@ -1238,7 +799,7 @@ qlcnic_83xx_fill_stats(struct qlcnic_adapter *adapter,
 		for (k += 2; k < total_regs; k += 2)
 			data = qlcnic_83xx_copy_stats(cmd, data, k);
 		break;
-	case QLCNIC_83XX_STAT_TX:
+	case QLC_83XX_STAT_TX:
 		for (k = 2; k < 10; k += 2)
 			data = qlcnic_83xx_copy_stats(cmd, data, k);
 		/* skip 8 bytes of reserved data */
@@ -1265,9 +826,9 @@ qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter,
 	if (adapter->is_up == QLCNIC_ADAPTER_UP_MAGIC) {
 		cmd.req.arg[1] = cpu_to_le32(BIT_1 |
 			(adapter->tx_ring->ctx_id << 16));
-		cmd.rsp.num = QLCNIC_83XX_TX_STAT_REGS;
+		cmd.rsp.num = QLC_83XX_TX_STAT_REGS;
 		data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
-			QLCNIC_83XX_STAT_TX, &ret);
+			QLC_83XX_STAT_TX, &ret);
 		if (ret) {
 			dev_info(&adapter->pdev->dev,
 				"Error getting MAC stats\n");
@@ -1275,10 +836,10 @@ qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter,
 		}
 		/* Get MAC stats */
 		cmd.req.arg[1] = cpu_to_le32(BIT_2 | (adapter->portnum << 16));
-		cmd.rsp.num = QLCNIC_83XX_MAC_STAT_REGS;
+		cmd.rsp.num = QLC_83XX_MAC_STAT_REGS;
 		memset(cmd.rsp.arg, 0, sizeof(u32) * cmd.rsp.num);
 		data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
-			QLCNIC_83XX_STAT_MAC, &ret);
+			QLC_83XX_STAT_MAC, &ret);
 		if (ret) {
 				dev_info(&adapter->pdev->dev,
 				"Error getting Rx stats\n");
@@ -1287,10 +848,10 @@ qlcnic_83xx_get_stats(struct qlcnic_adapter *adapter,
 		/* Get Rx stats */
 		cmd.req.arg[1] =
 			cpu_to_le32(adapter->recv_ctx->context_id << 16);
-		cmd.rsp.num = QLCNIC_83XX_RX_STAT_REGS;
+		cmd.rsp.num = QLC_83XX_RX_STAT_REGS;
 		memset(cmd.rsp.arg, 0, sizeof(u32) * cmd.rsp.num);
 		data = qlcnic_83xx_fill_stats(adapter, &cmd, data,
-			QLCNIC_83XX_STAT_RX, &ret);
+			QLC_83XX_STAT_RX, &ret);
 		if (ret)
 			dev_info(&adapter->pdev->dev,
 				"Error in getting Tx stats\n");
@@ -1964,15 +1525,15 @@ void qlcnic_83xx_config_led(struct qlcnic_adapter *adapter, u32 val, u32 beacon)
 		mbreg4 = cmd.rsp.arg[4];
 	}
 	/* Set LED Configuration */
-	mbx_in = (LSW(QLCNIC_83XX_LED_CONFIG) << 16) |
-			LSW(QLCNIC_83XX_LED_CONFIG);
+	mbx_in = (LSW(QLC_83XX_LED_CONFIG) << 16) |
+			LSW(QLC_83XX_LED_CONFIG);
 	adapter->ahw->hw_ops->alloc_mbx_args(&cmd, adapter,
 					QLCNIC_CMD_SET_LED_CONFIG);
 	cmd.req.arg[1] = cpu_to_le32(mbx_in);
 	cmd.req.arg[2] = cpu_to_le32(mbx_in);
 	cmd.req.arg[3] = cpu_to_le32(mbx_in);
 	if (beacon)
-		cmd.req.arg[4] = QLCNIC_83XX_ENABLE_BEACON;
+		cmd.req.arg[4] = QLC_83XX_ENABLE_BEACON;
 	status = adapter->ahw->hw_ops->mbx_cmd(adapter, &cmd);
 	if (status)
 		dev_info(&adapter->pdev->dev, "Set led config failed.\n");
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index c725b07..ed4f548 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -5,7 +5,7 @@
 #include <linux/etherdevice.h>
 #include "qlcnic_hw.h"
 
-#define IS_QLCNIC_83XX_USED(a, b, c)	\
+#define IS_QLC_83XX_USED(a, b, c)	\
 	(((1 << a->portnum) & b) || ((c >> 6) & 0x1))
 
 /* Directly mapped registers */
@@ -19,9 +19,9 @@
 #define QLC_83XX_LINK_SPEED(f)		(0x36E0+(((f) >> 2) * 4))
 #define QLC_83XX_LINK_SPEED_FACTOR	10
 #define QLC_83xx_FUNC_VAL(v, f)	((v) & (1 << (f * 4)))
-#define QLCNIC_83XX_INTX_PTR		0x38C0
-#define QLCNIC_83XX_INTX_TRGR		0x38C4
-#define QLCNIC_83XX_INTX_MASK		0x38C8
+#define QLC_83XX_INTX_PTR		0x38C0
+#define QLC_83XX_INTX_TRGR		0x38C4
+#define QLC_83XX_INTX_MASK		0x38C8
 
 /* Indirectly mapped registers */
 #define QLC_83XX_FLASH_SPI_STATUS	0x2808E010
@@ -138,20 +138,20 @@
 #define qlcnic_83xx_has_vlan_tag(sts)	\
 	(((sts) >> 47) & 1)
 
-#define QLCNIC_83XX_VALID_INTX_BIT30(val)	\
+#define QLC_83XX_VALID_INTX_BIT30(val)	\
 		((val) & BIT_30)
 
-#define QLCNIC_83XX_VALID_INTX_BIT31(val)	\
+#define QLC_83XX_VALID_INTX_BIT31(val)	\
 		((val) & BIT_31)
-#define QLCNIC_83XX_INTX_FUNC(val)	\
+#define QLC_83XX_INTX_FUNC(val)	\
 	((val) & 0xFF)
 
 #define QLC_83XX_LEGACY_INTX_MAX_RETRY	100
 #define QLC_83XX_LEGACY_INTX_DELAY	4
 
-#define QLCNIC_83XX_REG_DESC	1
-#define QLCNIC_83XX_LRO_DESC	2
-#define QLCNIC_83XX_CTRL_DESC	3
+#define QLC_83XX_REG_DESC	1
+#define QLC_83XX_LRO_DESC	2
+#define QLC_83XX_CTRL_DESC	3
 
 #define QLCNIC_FW_83XX_CAPABILITY_TSO	BIT_6
 
@@ -390,26 +390,26 @@ struct qlcnic_83xx_idc {
 #define QLC_83XX_CFG_LOOPBACK_EXT (4 << 1)	/* External Loopback Mode */
 
 /* LED configuration settings */
-#define QLCNIC_83XX_ENABLE_BEACON 0xe
-#define QLCNIC_83XX_LED_RATE 0xff
-#define QLCNIC_83XX_LED_ACT (1 << 10)
-#define QLCNIC_83XX_LED_MOD (0 << 13)
-#define QLCNIC_83XX_LED_CONFIG (QLCNIC_83XX_LED_RATE | QLCNIC_83XX_LED_ACT |\
-				QLCNIC_83XX_LED_MOD)
+#define QLC_83XX_ENABLE_BEACON 0xe
+#define QLC_83XX_LED_RATE 0xff
+#define QLC_83XX_LED_ACT (1 << 10)
+#define QLC_83XX_LED_MOD (0 << 13)
+#define QLC_83XX_LED_CONFIG (QLC_83XX_LED_RATE | QLC_83XX_LED_ACT |\
+				QLC_83XX_LED_MOD)
 
 #define QLC_83XX_10M_LINK	1
 #define QLC_83XX_100M_LINK	2
 #define QLC_83XX_1G_LINK	3
 #define QLC_83XX_10G_LINK	4
 
-#define QLCNIC_83XX_STAT_TX	3
-#define QLCNIC_83XX_STAT_RX	2
+#define QLC_83XX_STAT_TX	3
+#define QLC_83XX_STAT_RX	2
 
-#define QLCNIC_83XX_STAT_MAC	1
+#define QLC_83XX_STAT_MAC	1
 
-#define QLCNIC_83XX_TX_STAT_REGS	14
-#define QLCNIC_83XX_RX_STAT_REGS	40
-#define QLCNIC_83XX_MAC_STAT_REGS	80
+#define QLC_83XX_TX_STAT_REGS	14
+#define QLC_83XX_RX_STAT_REGS	40
+#define QLC_83XX_MAC_STAT_REGS	80
 
 #define QLC_83XX_GET_FUNC_PRIVILEGE_LEVEL(VAL, FN) (0x3 & ((VAL) >> (FN * 2)))
 #define QLC_83XX_SET_FUNC_OPMODE(VAL, FN)   ((VAL) << (FN * 2))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index ffd1028..a6eef3c 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -18,7 +18,7 @@ static const char * const qlcnic_83xx_idc_states[] =  {
 };
 
 /* IDC Device States */
-enum qlc_83xx_states {
+enum qlcnic_83xx_states {
 	QLC_83XX_IDC_DEV_UNKNOWN,
 	QLC_83XX_IDC_DEV_COLD,
 	QLC_83XX_IDC_DEV_INIT,
@@ -1946,7 +1946,7 @@ qlcnic_83xx_clear_function_resources(struct qlcnic_adapter *adapter)
 	presence_mask = QLCRDX(adapter->ahw, QLC_83XX_IDC_DRV_PRESENCE);
 	audit_mask = QLCRDX(adapter->ahw, QLC_83XX_IDC_DRV_AUDIT);
 
-	if (IS_QLCNIC_83XX_USED(adapter, presence_mask, audit_mask)) {
+	if (IS_QLC_83XX_USED(adapter, presence_mask, audit_mask)) {
 		qlcnic_alloc_mbx_args(&cmd, adapter, QLCNIC_CMD_STOP_NIC_FUNC);
 		cmd.req.arg[1] = cpu_to_le32(0 | BIT_31);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 1f21c39..4a72b93 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -82,7 +82,7 @@ static const char qlcnic_device_gstrings_stats[][ETH_GSTRING_LEN] = {
 	"tx numbytes",
 };
 
-static const char qlc_83xx_tx_stats_strings[][ETH_GSTRING_LEN] = {
+static const char qlcnic_83xx_tx_stats_strings[][ETH_GSTRING_LEN] = {
 	"ctx_tx_bytes",
 	"ctx_tx_pkts",
 	"ctx_tx_errors",
@@ -90,7 +90,7 @@ static const char qlc_83xx_tx_stats_strings[][ETH_GSTRING_LEN] = {
 	"ctx_tx_num_buffers",
 };
 
-static const char qlc_83xx_mac_stats_strings[][ETH_GSTRING_LEN] = {
+static const char qlcnic_83xx_mac_stats_strings[][ETH_GSTRING_LEN] = {
 	"mac_tx_frames",
 	"mac_tx_bytes",
 	"mac_tx_mcast_pkts",
@@ -126,7 +126,7 @@ static const char qlc_83xx_mac_stats_strings[][ETH_GSTRING_LEN] = {
 	"mac_align_error",
 };
 
-static const char qlc_83xx_rx_stats_strings[][ETH_GSTRING_LEN] = {
+static const char qlcnic_83xx_rx_stats_strings[][ETH_GSTRING_LEN] = {
 	"ctx_rx_bytes",
 	"ctx_rx_pkts",
 	"ctx_lro_pkt_cnt",
@@ -146,17 +146,17 @@ static const char qlc_83xx_rx_stats_strings[][ETH_GSTRING_LEN] = {
 };
 
 #define QLCNIC_STATS_LEN ARRAY_SIZE(qlcnic_gstrings_stats)
-#define QLCNIC_83XX_STATS (ARRAY_SIZE(qlc_83xx_tx_stats_strings)	\
-			+ ARRAY_SIZE(qlc_83xx_mac_stats_strings)	\
-			+ ARRAY_SIZE(qlc_83xx_rx_stats_strings))
+#define QLC_83XX_STATS (ARRAY_SIZE(qlcnic_83xx_tx_stats_strings)	\
+			+ ARRAY_SIZE(qlcnic_83xx_mac_stats_strings)	\
+			+ ARRAY_SIZE(qlcnic_83xx_rx_stats_strings))
 
 #define QLCNIC_82XX_STATS (QLCNIC_STATS_LEN \
-			+ ARRAY_SIZE(qlc_83xx_mac_stats_strings))
+			+ ARRAY_SIZE(qlcnic_83xx_mac_stats_strings))
 
 #define QLCNIC_DEVICE_STATS_LEN(adapter)	\
 	(QLCNIC_IS_83XX(adapter) ?	\
-	QLCNIC_83XX_STATS :\
-	(ARRAY_SIZE(qlc_83xx_mac_stats_strings)	\
+	QLC_83XX_STATS :\
+	(ARRAY_SIZE(qlcnic_83xx_mac_stats_strings)	\
 	+ ARRAY_SIZE(qlcnic_device_gstrings_stats)))
 
 #define QLCNIC_STATS_LEN ARRAY_SIZE(qlcnic_gstrings_stats)
@@ -1014,27 +1014,27 @@ qlcnic_get_strings(struct net_device *dev, u32 stringset, u8 *data)
 			       ETH_GSTRING_LEN);
 		}
 		if (QLCNIC_IS_83XX(adapter)) {
-			num_stats = ARRAY_SIZE(qlc_83xx_tx_stats_strings);
+			num_stats = ARRAY_SIZE(qlcnic_83xx_tx_stats_strings);
 			for (i = 0; i < num_stats; i++, index++)
 				memcpy(data + index * ETH_GSTRING_LEN,
-					qlc_83xx_tx_stats_strings[i],
+					qlcnic_83xx_tx_stats_strings[i],
 					ETH_GSTRING_LEN);
-			num_stats = ARRAY_SIZE(qlc_83xx_mac_stats_strings);
+			num_stats = ARRAY_SIZE(qlcnic_83xx_mac_stats_strings);
 			for (i = 0; i < num_stats; i++, index++)
 				memcpy(data + index * ETH_GSTRING_LEN,
-					qlc_83xx_mac_stats_strings[i],
+					qlcnic_83xx_mac_stats_strings[i],
 					ETH_GSTRING_LEN);
-			num_stats = ARRAY_SIZE(qlc_83xx_rx_stats_strings);
+			num_stats = ARRAY_SIZE(qlcnic_83xx_rx_stats_strings);
 			for (i = 0; i < num_stats; i++, index++)
 				memcpy(data + index * ETH_GSTRING_LEN,
-					qlc_83xx_rx_stats_strings[i],
+					qlcnic_83xx_rx_stats_strings[i],
 					ETH_GSTRING_LEN);
 			return;
 		} else {
-			num_stats = ARRAY_SIZE(qlc_83xx_mac_stats_strings);
+			num_stats = ARRAY_SIZE(qlcnic_83xx_mac_stats_strings);
 			for (i = 0; i < num_stats; i++, index++)
 				memcpy(data + index * ETH_GSTRING_LEN,
-					qlc_83xx_mac_stats_strings[i],
+					qlcnic_83xx_mac_stats_strings[i],
 					ETH_GSTRING_LEN);
 		}
 		if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED))
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
index ece5825..5f013fa 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hdr.h
@@ -509,9 +509,6 @@ enum {
 #define QLCNIC_MS_RDDATA_ULO       0x410000B8
 #define QLCNIC_MS_RDDATA_UHI       0x410000BC
 
-static const u32 QLCNIC_MS_READ_DATA[] = {
-	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
-
 #define QLC_TA_WRITE_ENABLE (TA_CTL_ENABLE | TA_CTL_WRITE)
 #define QLC_TA_WRITE_START (TA_CTL_START | TA_CTL_ENABLE | TA_CTL_WRITE)
 #define QLC_TA_START_ENABLE (TA_CTL_START | TA_CTL_ENABLE)
@@ -723,15 +720,14 @@ struct qlcnic_legacy_intr_set {
 #define QLCNIC_MAX_PCI_FUNC	8
 #define QLCNIC_MAX_VLAN_FILTERS	64
 
-/* FW dump defines */
 #define FLASH_ROM_WINDOW	0x42110030
 #define FLASH_ROM_DATA		0x42150000
 
-#define QLCNIC_CRB_WINDOW_2M		0x00130060
-#define QLCNIC_INDIRECT_MEM_START	0x001e0000
-#define QLCNIC_FLASH_SEM2_LK	0x0013C010
-#define QLCNIC_FLASH_SEM2_ULK	0x0013C014
-#define QLCNIC_FLASH_LOCK_ID	0x001B2100
+#define QLCNIC_CRB_WINDOW_2M           0x00130060
+#define QLCNIC_INDIRECT_MEM_START      0x001e0000
+#define QLCNIC_FLASH_SEM2_LK           0x0013C010
+#define QLCNIC_FLASH_SEM2_ULK          0x0013C014
+#define QLCNIC_FLASH_LOCK_ID           0x001B2100
 
 /* PCI function operational mode */
 enum {
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
deleted file mode 100644
index 3b10acc..0000000
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ /dev/null
@@ -1,1297 +0,0 @@
-/*
- * QLogic qlcnic NIC Driver
- * Copyright (c)  2009-2010 QLogic Corporation
- *
- * See LICENSE.qlcnic for copyright and licensing details.
- */
-
-#include "qlcnic.h"
-#include "qlcnic_hw.h"
-
-struct crb_addr_pair {
-	u32 addr;
-	u32 data;
-};
-
-#define QLCNIC_MAX_CRB_XFORM 60
-static unsigned int crb_addr_xform[QLCNIC_MAX_CRB_XFORM];
-
-#define crb_addr_transform(name) \
-	(crb_addr_xform[QLCNIC_HW_PX_MAP_CRB_##name] = \
-	QLCNIC_HW_CRB_HUB_AGT_ADR_##name << 20)
-
-#define QLCNIC_ADDR_ERROR (0xffffffff)
-
-static int
-qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter);
-
-static void crb_addr_transform_setup(void)
-{
-	crb_addr_transform(XDMA);
-	crb_addr_transform(TIMR);
-	crb_addr_transform(SRE);
-	crb_addr_transform(SQN3);
-	crb_addr_transform(SQN2);
-	crb_addr_transform(SQN1);
-	crb_addr_transform(SQN0);
-	crb_addr_transform(SQS3);
-	crb_addr_transform(SQS2);
-	crb_addr_transform(SQS1);
-	crb_addr_transform(SQS0);
-	crb_addr_transform(RPMX7);
-	crb_addr_transform(RPMX6);
-	crb_addr_transform(RPMX5);
-	crb_addr_transform(RPMX4);
-	crb_addr_transform(RPMX3);
-	crb_addr_transform(RPMX2);
-	crb_addr_transform(RPMX1);
-	crb_addr_transform(RPMX0);
-	crb_addr_transform(ROMUSB);
-	crb_addr_transform(SN);
-	crb_addr_transform(QMN);
-	crb_addr_transform(QMS);
-	crb_addr_transform(PGNI);
-	crb_addr_transform(PGND);
-	crb_addr_transform(PGN3);
-	crb_addr_transform(PGN2);
-	crb_addr_transform(PGN1);
-	crb_addr_transform(PGN0);
-	crb_addr_transform(PGSI);
-	crb_addr_transform(PGSD);
-	crb_addr_transform(PGS3);
-	crb_addr_transform(PGS2);
-	crb_addr_transform(PGS1);
-	crb_addr_transform(PGS0);
-	crb_addr_transform(PS);
-	crb_addr_transform(PH);
-	crb_addr_transform(NIU);
-	crb_addr_transform(I2Q);
-	crb_addr_transform(EG);
-	crb_addr_transform(MN);
-	crb_addr_transform(MS);
-	crb_addr_transform(CAS2);
-	crb_addr_transform(CAS1);
-	crb_addr_transform(CAS0);
-	crb_addr_transform(CAM);
-	crb_addr_transform(C2C1);
-	crb_addr_transform(C2C0);
-	crb_addr_transform(SMB);
-	crb_addr_transform(OCM0);
-	crb_addr_transform(I2C0);
-}
-
-void qlcnic_release_rx_buffers(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_recv_context *recv_ctx;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_rx_buffer *rx_buf;
-	int i, ring;
-
-	recv_ctx = adapter->recv_ctx;
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &recv_ctx->rds_rings[ring];
-		for (i = 0; i < rds_ring->num_desc; ++i) {
-			rx_buf = &(rds_ring->rx_buf_arr[i]);
-			if (rx_buf->skb == NULL)
-				continue;
-
-			pci_unmap_single(adapter->pdev,
-					rx_buf->dma,
-					rds_ring->dma_size,
-					PCI_DMA_FROMDEVICE);
-
-			dev_kfree_skb_any(rx_buf->skb);
-		}
-	}
-}
-
-void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_recv_context *recv_ctx;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_rx_buffer *rx_buf;
-	int i, ring;
-
-	recv_ctx = adapter->recv_ctx;
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &recv_ctx->rds_rings[ring];
-
-		INIT_LIST_HEAD(&rds_ring->free_list);
-
-		rx_buf = rds_ring->rx_buf_arr;
-		for (i = 0; i < rds_ring->num_desc; i++) {
-			list_add_tail(&rx_buf->list,
-					&rds_ring->free_list);
-			rx_buf++;
-		}
-	}
-}
-
-void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_cmd_buffer *cmd_buf;
-	struct qlcnic_skb_frag *buffrag;
-	int i, j;
-	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
-
-	cmd_buf = tx_ring->cmd_buf_arr;
-	for (i = 0; i < tx_ring->num_desc; i++) {
-		buffrag = cmd_buf->frag_array;
-		if (buffrag->dma) {
-			pci_unmap_single(adapter->pdev, buffrag->dma,
-					 buffrag->length, PCI_DMA_TODEVICE);
-			buffrag->dma = 0ULL;
-		}
-		for (j = 0; j < cmd_buf->frag_count; j++) {
-			buffrag++;
-			if (buffrag->dma) {
-				pci_unmap_page(adapter->pdev, buffrag->dma,
-					       buffrag->length,
-					       PCI_DMA_TODEVICE);
-				buffrag->dma = 0ULL;
-			}
-		}
-		if (cmd_buf->skb) {
-			dev_kfree_skb_any(cmd_buf->skb);
-			cmd_buf->skb = NULL;
-		}
-		cmd_buf++;
-	}
-}
-
-void qlcnic_free_sw_resources(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_recv_context *recv_ctx;
-	struct qlcnic_host_rds_ring *rds_ring;
-	int ring;
-
-	recv_ctx = adapter->recv_ctx;
-
-	if (recv_ctx->rds_rings == NULL)
-		return;
-
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &recv_ctx->rds_rings[ring];
-		vfree(rds_ring->rx_buf_arr);
-		rds_ring->rx_buf_arr = NULL;
-	}
-	kfree(recv_ctx->rds_rings);
-}
-
-int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_recv_context *recv_ctx;
-	struct qlcnic_host_rds_ring *rds_ring;
-	struct qlcnic_host_sds_ring *sds_ring;
-	struct qlcnic_rx_buffer *rx_buf;
-	int ring, i, size;
-
-	struct net_device *netdev = adapter->netdev;
-	struct qlcnic_hardware_context *ahw = adapter->ahw;
-
-	recv_ctx = adapter->recv_ctx;
-
-	size = adapter->max_rds_rings * sizeof(struct qlcnic_host_rds_ring);
-	rds_ring = kzalloc(size, GFP_KERNEL);
-	if (rds_ring == NULL) {
-		dev_err(&netdev->dev, "failed to allocate rds ring struct\n");
-		goto err_out;
-	}
-	recv_ctx->rds_rings = rds_ring;
-
-	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
-		rds_ring = &recv_ctx->rds_rings[ring];
-		switch (ring) {
-		case RCV_RING_NORMAL:
-			rds_ring->num_desc = adapter->num_rxd;
-			rds_ring->dma_size = QLCNIC_P3P_RX_BUF_MAX_LEN;
-			rds_ring->skb_size = rds_ring->dma_size + NET_IP_ALIGN;
-			break;
-
-		case RCV_RING_JUMBO:
-			rds_ring->num_desc = adapter->num_jumbo_rxd;
-			rds_ring->dma_size =
-				QLCNIC_P3P_RX_JUMBO_BUF_MAX_LEN;
-
-			if (ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
-				rds_ring->dma_size += QLCNIC_LRO_BUFFER_EXTRA;
-
-			rds_ring->skb_size =
-				rds_ring->dma_size + NET_IP_ALIGN;
-			break;
-		}
-		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
-			vmalloc(RCV_BUFF_RINGSIZE(rds_ring));
-		if (rds_ring->rx_buf_arr == NULL) {
-			dev_err(&netdev->dev,
-				"Failed to allocate rx buffer ring %d\n", ring);
-			goto err_out;
-		}
-		memset(rds_ring->rx_buf_arr, 0, RCV_BUFF_RINGSIZE(rds_ring));
-		INIT_LIST_HEAD(&rds_ring->free_list);
-		/*
-		 * Now go through all of them, set reference handles
-		 * and put them in the queues.
-		 */
-		rx_buf = rds_ring->rx_buf_arr;
-		for (i = 0; i < rds_ring->num_desc; i++) {
-			list_add_tail(&rx_buf->list,
-					&rds_ring->free_list);
-			rx_buf->ref_handle = i;
-			rx_buf++;
-		}
-		spin_lock_init(&rds_ring->lock);
-	}
-
-	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
-		sds_ring = &recv_ctx->sds_rings[ring];
-		sds_ring->irq = adapter->msix_entries[ring].vector;
-		sds_ring->adapter = adapter;
-		sds_ring->num_desc = adapter->num_rxd;
-
-		for (i = 0; i < NUM_RCV_DESC_RINGS; i++)
-			INIT_LIST_HEAD(&sds_ring->free_list[i]);
-	}
-
-	return 0;
-
-err_out:
-	qlcnic_free_sw_resources(adapter);
-	return -ENOMEM;
-}
-
-/*
- * Utility to translate from internal Phantom CRB address
- * to external PCI CRB address.
- */
-static u32 qlcnic_decode_crb_addr(u32 addr)
-{
-	int i;
-	u32 base_addr, offset, pci_base;
-
-	crb_addr_transform_setup();
-
-	pci_base = QLCNIC_ADDR_ERROR;
-	base_addr = addr & 0xfff00000;
-	offset = addr & 0x000fffff;
-
-	for (i = 0; i < QLCNIC_MAX_CRB_XFORM; i++) {
-		if (crb_addr_xform[i] == base_addr) {
-			pci_base = i << 20;
-			break;
-		}
-	}
-	if (pci_base == QLCNIC_ADDR_ERROR)
-		return pci_base;
-	else
-		return pci_base + offset;
-}
-
-#define QLCNIC_MAX_ROM_WAIT_USEC	100
-
-static int qlcnic_wait_rom_done(struct qlcnic_adapter *adapter)
-{
-	long timeout = 0;
-	long done = 0;
-	int err;
-
-	cond_resched();
-
-	while (done == 0) {
-		done = QLCRD32(adapter, QLCNIC_ROMUSB_GLB_STATUS, &err);
-		done &= 2;
-		if (++timeout >= QLCNIC_MAX_ROM_WAIT_USEC) {
-			dev_err(&adapter->pdev->dev,
-				"Timeout reached  waiting for rom done");
-			return -EIO;
-		}
-		udelay(1);
-	}
-	return 0;
-}
-
-static int do_rom_fast_read(struct qlcnic_adapter *adapter,
-			    u32 addr, u32 *valp)
-{
-	int err;
-
-	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ADDRESS, addr);
-	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
-	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 3);
-	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_INSTR_OPCODE, 0xb);
-	if (qlcnic_wait_rom_done(adapter)) {
-		dev_err(&adapter->pdev->dev, "Error waiting for rom done\n");
-		return -EIO;
-	}
-	/* reset abyte_cnt and dummy_byte_cnt */
-	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_ABYTE_CNT, 0);
-	udelay(10);
-	QLCWR32(adapter, QLCNIC_ROMUSB_ROM_DUMMY_BYTE_CNT, 0);
-
-	*valp = QLCRD32(adapter, QLCNIC_ROMUSB_ROM_RDATA, &err);
-	return 0;
-}
-
-static int do_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
-				  u8 *bytes, size_t size)
-{
-	int addridx;
-	int ret = 0;
-
-	for (addridx = addr; addridx < (addr + size); addridx += 4) {
-		int v;
-		ret = do_rom_fast_read(adapter, addridx, &v);
-		if (ret != 0)
-			break;
-		*(__le32 *)bytes = cpu_to_le32(v);
-		bytes += 4;
-	}
-
-	return ret;
-}
-
-int
-qlcnic_rom_fast_read_words(struct qlcnic_adapter *adapter, int addr,
-				u8 *bytes, size_t size)
-{
-	int ret;
-
-	ret = qlcnic_rom_lock(adapter);
-	if (ret < 0)
-		return ret;
-
-	ret = do_rom_fast_read_words(adapter, addr, bytes, size);
-
-	qlcnic_rom_unlock(adapter);
-	return ret;
-}
-
-int qlcnic_rom_fast_read(struct qlcnic_adapter *adapter, u32 addr, u32 *valp)
-{
-	int ret;
-
-	if (qlcnic_rom_lock(adapter) != 0)
-		return -EIO;
-
-	ret = do_rom_fast_read(adapter, addr, valp);
-	qlcnic_rom_unlock(adapter);
-	return ret;
-}
-
-int qlcnic_pinit_from_rom(struct qlcnic_adapter *adapter)
-{
-	int addr, val, err;
-	int i, n, init_delay;
-	struct crb_addr_pair *buf;
-	unsigned offset;
-	u32 off;
-	struct pci_dev *pdev = adapter->pdev;
-
-	QLCWR(adapter, QLCNIC_CMDPEG_STATE, 0);
-	QLCWR(adapter, QLCNIC_RCVPEG_STATE, 0);
-
-	/* Halt all the indiviual PEGs and other blocks */
-	/* disable all I2Q */
-	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x10, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x14, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x18, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x1c, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x20, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_I2Q + 0x24, 0x0);
-
-	/* disable all niu interrupts */
-	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x40, 0xff);
-	/* disable xge rx/tx */
-	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x70000, 0x00);
-	/* disable xg1 rx/tx */
-	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x80000, 0x00);
-	/* disable sideband mac */
-	QLCWR32(adapter, QLCNIC_CRB_NIU + 0x90000, 0x00);
-	/* disable ap0 mac */
-	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xa0000, 0x00);
-	/* disable ap1 mac */
-	QLCWR32(adapter, QLCNIC_CRB_NIU + 0xb0000, 0x00);
-
-	/* halt sre */
-	val = QLCRD32(adapter, QLCNIC_CRB_SRE + 0x1000, &err);
-	QLCWR32(adapter, QLCNIC_CRB_SRE + 0x1000, val & (~(0x1)));
-
-	/* halt epg */
-	QLCWR32(adapter, QLCNIC_CRB_EPG + 0x1300, 0x1);
-
-	/* halt timers */
-	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x0, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x8, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x10, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x18, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x100, 0x0);
-	QLCWR32(adapter, QLCNIC_CRB_TIMER + 0x200, 0x0);
-	/* halt pegs */
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x3c, 1);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x3c, 1);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x3c, 1);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x3c, 1);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x3c, 1);
-	msleep(20);
-
-	qlcnic_rom_unlock(adapter);
-	/* big hammer don't reset CAM block on reset */
-	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0xfeffffff);
-
-	/* Init HW CRB block */
-	if (qlcnic_rom_fast_read(adapter, 0, &n) != 0 || (n != 0xcafecafe) ||
-			qlcnic_rom_fast_read(adapter, 4, &n) != 0) {
-		dev_err(&pdev->dev, "ERROR Reading crb_init area: val:%x\n", n);
-		return -EIO;
-	}
-	offset = n & 0xffffU;
-	n = (n >> 16) & 0xffffU;
-
-	if (n >= 1024) {
-		dev_err(&pdev->dev, "QLOGIC card flash not initialized.\n");
-		return -EIO;
-	}
-
-	buf = kcalloc(n, sizeof(struct crb_addr_pair), GFP_KERNEL);
-	if (buf == NULL) {
-		dev_err(&pdev->dev, "Unable to calloc memory for rom read.\n");
-		return -ENOMEM;
-	}
-
-	for (i = 0; i < n; i++) {
-		if (qlcnic_rom_fast_read(adapter, 8*i + 4*offset, &val) != 0 ||
-		qlcnic_rom_fast_read(adapter, 8*i + 4*offset + 4, &addr) != 0) {
-			kfree(buf);
-			return -EIO;
-		}
-
-		buf[i].addr = addr;
-		buf[i].data = val;
-	}
-
-	for (i = 0; i < n; i++) {
-
-		off = qlcnic_decode_crb_addr(buf[i].addr);
-		if (off == QLCNIC_ADDR_ERROR) {
-			dev_err(&pdev->dev, "CRB init value out of range %x\n",
-					buf[i].addr);
-			continue;
-		}
-		off += QLCNIC_PCI_CRBSPACE;
-
-		if (off & 1)
-			continue;
-
-		/* skipping cold reboot MAGIC */
-		if (off == QLCNIC_CAM_RAM(0x1fc))
-			continue;
-		if (off == (QLCNIC_CRB_I2C0 + 0x1c))
-			continue;
-		if (off == (ROMUSB_GLB + 0xbc)) /* do not reset PCI */
-			continue;
-		if (off == (ROMUSB_GLB + 0xa8))
-			continue;
-		if (off == (ROMUSB_GLB + 0xc8)) /* core clock */
-			continue;
-		if (off == (ROMUSB_GLB + 0x24)) /* MN clock */
-			continue;
-		if (off == (ROMUSB_GLB + 0x1c)) /* MS clock */
-			continue;
-		if ((off & 0x0ff00000) == QLCNIC_CRB_DDR_NET)
-			continue;
-		/* skip the function enable register */
-		if (off == QLCNIC_PCIE_REG(PCIE_SETUP_FUNCTION))
-			continue;
-		if (off == QLCNIC_PCIE_REG(PCIE_SETUP_FUNCTION2))
-			continue;
-		if ((off & 0x0ff00000) == QLCNIC_CRB_SMB)
-			continue;
-
-		init_delay = 1;
-		/* After writing this register, HW needs time for CRB */
-		/* to quiet down (else crb_window returns 0xffffffff) */
-		if (off == QLCNIC_ROMUSB_GLB_SW_RESET)
-			init_delay = 1000;
-
-		QLCWR32(adapter, off, buf[i].data);
-
-		msleep(init_delay);
-	}
-	kfree(buf);
-
-	/* Initialize protocol process engine */
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_D + 0xec, 0x1e);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_D + 0x4c, 8);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_I + 0x4c, 8);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x8, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0xc, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0x8, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_1 + 0xc, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0x8, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_2 + 0xc, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0x8, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_3 + 0xc, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0x8, 0);
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_4 + 0xc, 0);
-	msleep(1);
-
-	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
-	QLCWR(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
-
-	return 0;
-}
-
-static int qlcnic_cmd_peg_ready(struct qlcnic_adapter *adapter)
-{
-	u32 val;
-	int retries = QLCNIC_CMDPEG_CHECK_RETRY_COUNT;
-
-	do {
-		val = QLCRD(adapter, QLCNIC_CMDPEG_STATE);
-
-		switch (val) {
-		case PHAN_INITIALIZE_COMPLETE:
-		case PHAN_INITIALIZE_ACK:
-			return 0;
-		case PHAN_INITIALIZE_FAILED:
-			goto out_err;
-		default:
-			break;
-		}
-
-		msleep(QLCNIC_CMDPEG_CHECK_DELAY);
-
-	} while (--retries);
-
-	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_FAILED);
-
-out_err:
-	dev_err(&adapter->pdev->dev, "Command Peg initialization not "
-		      "complete, state: 0x%x.\n", val);
-	return -EIO;
-}
-
-static int
-qlcnic_receive_peg_ready(struct qlcnic_adapter *adapter)
-{
-	u32 val;
-	int retries = QLCNIC_RCVPEG_CHECK_RETRY_COUNT;
-
-	do {
-		val = QLCRD(adapter, QLCNIC_RCVPEG_STATE);
-
-		if (val == PHAN_PEG_RCV_INITIALIZED)
-			return 0;
-
-		msleep(QLCNIC_RCVPEG_CHECK_DELAY);
-
-	} while (--retries);
-
-	if (!retries) {
-		dev_err(&adapter->pdev->dev, "Receive Peg initialization not "
-			      "complete, state: 0x%x.\n", val);
-		return -EIO;
-	}
-
-	return 0;
-}
-
-int
-qlcnic_check_fw_status(struct qlcnic_adapter *adapter)
-{
-	int err;
-
-	err = qlcnic_cmd_peg_ready(adapter);
-	if (err)
-		return err;
-
-	err = qlcnic_receive_peg_ready(adapter);
-	if (err)
-		return err;
-
-	QLCWR(adapter, QLCNIC_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
-
-	return err;
-}
-
-int
-qlcnic_setup_idc_param(struct qlcnic_adapter *adapter) {
-
-	int timeo;
-	u32 val;
-
-	val = QLCRD(adapter, QLCNIC_CRB_DEV_PARTITION_INFO);
-	val = QLC_DEV_GET_DRV(val, adapter->portnum);
-	if ((val & 0x3) != QLCNIC_TYPE_NIC) {
-		dev_err(&adapter->pdev->dev,
-			"Not an Ethernet NIC func=%u\n", val);
-		return -EIO;
-	}
-	adapter->ahw->physical_port = (val >> 2);
-	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DEV_INIT_TIMEOUT, &timeo))
-		timeo = QLCNIC_INIT_TIMEOUT_SECS;
-
-	adapter->dev_init_timeo = timeo;
-
-	if (qlcnic_rom_fast_read(adapter, QLCNIC_ROM_DRV_RESET_TIMEOUT, &timeo))
-		timeo = QLCNIC_RESET_TIMEOUT_SECS;
-
-	adapter->reset_ack_timeo = timeo;
-
-	return 0;
-}
-
-static int qlcnic_get_flt_entry(struct qlcnic_adapter *adapter, u8 region,
-				struct qlcnic_flt_entry *region_entry)
-{
-	struct qlcnic_flt_header flt_hdr;
-	struct qlcnic_flt_entry *flt_entry;
-	int i = 0, ret;
-	u32 entry_size;
-
-	memset(region_entry, 0, sizeof(struct qlcnic_flt_entry));
-	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION,
-					 (u8 *)&flt_hdr,
-					 sizeof(struct qlcnic_flt_header));
-	if (ret) {
-		dev_warn(&adapter->pdev->dev,
-			 "error reading flash layout header\n");
-		return -EIO;
-	}
-
-	entry_size = flt_hdr.len - sizeof(struct qlcnic_flt_header);
-	flt_entry = vmalloc(entry_size);
-	if (flt_entry == NULL) {
-		dev_err(&adapter->pdev->dev, "error allocating memory\n");
-		return -EIO;
-	}
-	memset(flt_entry, 0, entry_size);
-
-	ret = qlcnic_rom_fast_read_words(adapter, QLCNIC_FLT_LOCATION +
-					 sizeof(struct qlcnic_flt_header),
-					 (u8 *)flt_entry, entry_size);
-	if (ret) {
-		dev_warn(&adapter->pdev->dev,
-			 "error reading flash layout entries\n");
-		goto err_out;
-	}
-
-	while (i < (entry_size/sizeof(struct qlcnic_flt_entry))) {
-		if (flt_entry[i].region == region)
-			break;
-		i++;
-	}
-	if (i >= (entry_size/sizeof(struct qlcnic_flt_entry))) {
-		dev_warn(&adapter->pdev->dev,
-			 "region=%x not found in %d regions\n", region, i);
-		ret = -EIO;
-		goto err_out;
-	}
-	memcpy(region_entry, &flt_entry[i], sizeof(struct qlcnic_flt_entry));
-
-err_out:
-	vfree(flt_entry);
-	return ret;
-}
-
-int
-qlcnic_check_flash_fw_ver(struct qlcnic_adapter *adapter)
-{
-	struct qlcnic_flt_entry fw_entry;
-	u32 ver = -1, min_ver;
-	int ret;
-
-	if (adapter->ahw->revision_id == QLCNIC_P3P_C0)
-		ret = qlcnic_get_flt_entry(adapter, QLCNIC_C0_FW_IMAGE_REGION,
-						 &fw_entry);
-	else
-		ret = qlcnic_get_flt_entry(adapter, QLCNIC_B0_FW_IMAGE_REGION,
-						 &fw_entry);
-
-	if (!ret)
-		/* 0-4:-signature,  4-8:-fw version */
-		qlcnic_rom_fast_read(adapter, fw_entry.start_addr + 4,
-				     (int *)&ver);
-	else
-		qlcnic_rom_fast_read(adapter, QLCNIC_FW_VERSION_OFFSET,
-				     (int *)&ver);
-
-	ver = QLCNIC_DECODE_VERSION(ver);
-	min_ver = QLCNIC_MIN_FW_VERSION;
-
-	if (ver < min_ver) {
-		dev_err(&adapter->pdev->dev,
-			"firmware version %d.%d.%d unsupported."
-			"Min supported version %d.%d.%d\n",
-			_major(ver), _minor(ver), _build(ver),
-			_major(min_ver), _minor(min_ver), _build(min_ver));
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static int
-qlcnic_has_mn(struct qlcnic_adapter *adapter)
-{
-	int err;
-	u32 capability;
-	capability = 0;
-
-	capability = QLCRD32(adapter, QLCNIC_PEG_TUNE_CAPABILITY, &err);
-	if (capability & QLCNIC_PEG_TUNE_MN_PRESENT)
-		return 1;
-
-	return 0;
-}
-
-static
-struct uni_table_desc *qlcnic_get_table_desc(const u8 *unirom, int section)
-{
-	u32 i;
-	struct uni_table_desc *directory = (struct uni_table_desc *) &unirom[0];
-	__le32 entries = cpu_to_le32(directory->num_entries);
-
-	for (i = 0; i < entries; i++) {
-
-		__le32 offs = cpu_to_le32(directory->findex) +
-				(i * cpu_to_le32(directory->entry_size));
-		__le32 tab_type = cpu_to_le32(*((u32 *)&unirom[offs] + 8));
-
-		if (tab_type == section)
-			return (struct uni_table_desc *) &unirom[offs];
-	}
-
-	return NULL;
-}
-
-#define FILEHEADER_SIZE (14 * 4)
-
-static int
-qlcnic_validate_header(struct qlcnic_adapter *adapter)
-{
-	const u8 *unirom = adapter->fw->data;
-	struct uni_table_desc *directory = (struct uni_table_desc *) &unirom[0];
-	__le32 fw_file_size = adapter->fw->size;
-	__le32 entries;
-	__le32 entry_size;
-	__le32 tab_size;
-
-	if (fw_file_size < FILEHEADER_SIZE)
-		return -EINVAL;
-
-	entries = cpu_to_le32(directory->num_entries);
-	entry_size = cpu_to_le32(directory->entry_size);
-	tab_size = cpu_to_le32(directory->findex) + (entries * entry_size);
-
-	if (fw_file_size < tab_size)
-		return -EINVAL;
-
-	return 0;
-}
-
-static int
-qlcnic_validate_bootld(struct qlcnic_adapter *adapter)
-{
-	struct uni_table_desc *tab_desc;
-	struct uni_data_desc *descr;
-	const u8 *unirom = adapter->fw->data;
-	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
-				QLCNIC_UNI_BOOTLD_IDX_OFF));
-	__le32 offs;
-	__le32 tab_size;
-	__le32 data_size;
-
-	tab_desc = qlcnic_get_table_desc(unirom, QLCNIC_UNI_DIR_SECT_BOOTLD);
-
-	if (!tab_desc)
-		return -EINVAL;
-
-	tab_size = cpu_to_le32(tab_desc->findex) +
-			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
-
-	if (adapter->fw->size < tab_size)
-		return -EINVAL;
-
-	offs = cpu_to_le32(tab_desc->findex) +
-		(cpu_to_le32(tab_desc->entry_size) * (idx));
-	descr = (struct uni_data_desc *)&unirom[offs];
-
-	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
-
-	if (adapter->fw->size < data_size)
-		return -EINVAL;
-
-	return 0;
-}
-
-static int
-qlcnic_validate_fw(struct qlcnic_adapter *adapter)
-{
-	struct uni_table_desc *tab_desc;
-	struct uni_data_desc *descr;
-	const u8 *unirom = adapter->fw->data;
-	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
-				QLCNIC_UNI_FIRMWARE_IDX_OFF));
-	__le32 offs;
-	__le32 tab_size;
-	__le32 data_size;
-
-	tab_desc = qlcnic_get_table_desc(unirom, QLCNIC_UNI_DIR_SECT_FW);
-
-	if (!tab_desc)
-		return -EINVAL;
-
-	tab_size = cpu_to_le32(tab_desc->findex) +
-			(cpu_to_le32(tab_desc->entry_size) * (idx + 1));
-
-	if (adapter->fw->size < tab_size)
-		return -EINVAL;
-
-	offs = cpu_to_le32(tab_desc->findex) +
-		(cpu_to_le32(tab_desc->entry_size) * (idx));
-	descr = (struct uni_data_desc *)&unirom[offs];
-	data_size = cpu_to_le32(descr->findex) + cpu_to_le32(descr->size);
-
-	if (adapter->fw->size < data_size)
-		return -EINVAL;
-
-	return 0;
-}
-
-static int
-qlcnic_validate_product_offs(struct qlcnic_adapter *adapter)
-{
-	struct uni_table_desc *ptab_descr;
-	const u8 *unirom = adapter->fw->data;
-	int mn_present = qlcnic_has_mn(adapter);
-	__le32 entries;
-	__le32 entry_size;
-	__le32 tab_size;
-	u32 i;
-
-	ptab_descr = qlcnic_get_table_desc(unirom,
-				QLCNIC_UNI_DIR_SECT_PRODUCT_TBL);
-	if (!ptab_descr)
-		return -EINVAL;
-
-	entries = cpu_to_le32(ptab_descr->num_entries);
-	entry_size = cpu_to_le32(ptab_descr->entry_size);
-	tab_size = cpu_to_le32(ptab_descr->findex) + (entries * entry_size);
-
-	if (adapter->fw->size < tab_size)
-		return -EINVAL;
-
-nomn:
-	for (i = 0; i < entries; i++) {
-
-		__le32 flags, file_chiprev, offs;
-		u8 chiprev = adapter->ahw->revision_id;
-		u32 flagbit;
-
-		offs = cpu_to_le32(ptab_descr->findex) +
-				(i * cpu_to_le32(ptab_descr->entry_size));
-		flags = cpu_to_le32(*((int *)&unirom[offs] +
-						QLCNIC_UNI_FLAGS_OFF));
-		file_chiprev = cpu_to_le32(*((int *)&unirom[offs] +
-						QLCNIC_UNI_CHIP_REV_OFF));
-
-		flagbit = mn_present ? 1 : 2;
-
-		if ((chiprev == file_chiprev) &&
-					((1ULL << flagbit) & flags)) {
-			adapter->file_prd_off = offs;
-			return 0;
-		}
-	}
-	if (mn_present) {
-		mn_present = 0;
-		goto nomn;
-	}
-	return -EINVAL;
-}
-
-static int
-qlcnic_validate_unified_romimage(struct qlcnic_adapter *adapter)
-{
-	if (qlcnic_validate_header(adapter)) {
-		dev_err(&adapter->pdev->dev,
-				"unified image: header validation failed\n");
-		return -EINVAL;
-	}
-
-	if (qlcnic_validate_product_offs(adapter)) {
-		dev_err(&adapter->pdev->dev,
-				"unified image: product validation failed\n");
-		return -EINVAL;
-	}
-
-	if (qlcnic_validate_bootld(adapter)) {
-		dev_err(&adapter->pdev->dev,
-				"unified image: bootld validation failed\n");
-		return -EINVAL;
-	}
-
-	if (qlcnic_validate_fw(adapter)) {
-		dev_err(&adapter->pdev->dev,
-				"unified image: firmware validation failed\n");
-		return -EINVAL;
-	}
-
-	return 0;
-}
-
-static
-struct uni_data_desc *qlcnic_get_data_desc(struct qlcnic_adapter *adapter,
-			u32 section, u32 idx_offset)
-{
-	const u8 *unirom = adapter->fw->data;
-	int idx = cpu_to_le32(*((int *)&unirom[adapter->file_prd_off] +
-								idx_offset));
-	struct uni_table_desc *tab_desc;
-	__le32 offs;
-
-	tab_desc = qlcnic_get_table_desc(unirom, section);
-
-	if (tab_desc == NULL)
-		return NULL;
-
-	offs = cpu_to_le32(tab_desc->findex) +
-			(cpu_to_le32(tab_desc->entry_size) * idx);
-
-	return (struct uni_data_desc *)&unirom[offs];
-}
-
-static u8 *
-qlcnic_get_bootld_offs(struct qlcnic_adapter *adapter)
-{
-	u32 offs = QLCNIC_BOOTLD_START;
-
-	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
-		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
-					QLCNIC_UNI_DIR_SECT_BOOTLD,
-					QLCNIC_UNI_BOOTLD_IDX_OFF))->findex);
-
-	return (u8 *)&adapter->fw->data[offs];
-}
-
-static u8 *
-qlcnic_get_fw_offs(struct qlcnic_adapter *adapter)
-{
-	u32 offs = QLCNIC_IMAGE_START;
-
-	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
-		offs = cpu_to_le32((qlcnic_get_data_desc(adapter,
-					QLCNIC_UNI_DIR_SECT_FW,
-					QLCNIC_UNI_FIRMWARE_IDX_OFF))->findex);
-
-	return (u8 *)&adapter->fw->data[offs];
-}
-
-static __le32
-qlcnic_get_fw_size(struct qlcnic_adapter *adapter)
-{
-	if (adapter->ahw->fw_type == QLCNIC_UNIFIED_ROMIMAGE)
-		return cpu_to_le32((qlcnic_get_data_desc(adapter,
-					QLCNIC_UNI_DIR_SECT_FW,
-					QLCNIC_UNI_FIRMWARE_IDX_OFF))->size);
-	else
-		return cpu_to_le32(
-			*(u32 *)&adapter->fw->data[QLCNIC_FW_SIZE_OFFSET]);
-}
-
-static __le32
-qlcnic_get_fw_version(struct qlcnic_adapter *adapter)
-{
-	struct uni_data_desc *fw_data_desc;
-	const struct firmware *fw = adapter->fw;
-	__le32 major, minor, sub;
-	const u8 *ver_str;
-	int i, ret;
-
-	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
-		return cpu_to_le32(*(u32 *)&fw->data[QLCNIC_FW_VERSION_OFFSET]);
-
-	fw_data_desc = qlcnic_get_data_desc(adapter, QLCNIC_UNI_DIR_SECT_FW,
-			QLCNIC_UNI_FIRMWARE_IDX_OFF);
-	ver_str = fw->data + cpu_to_le32(fw_data_desc->findex) +
-		cpu_to_le32(fw_data_desc->size) - 17;
-
-	for (i = 0; i < 12; i++) {
-		if (!strncmp(&ver_str[i], "REV=", 4)) {
-			ret = sscanf(&ver_str[i+4], "%u.%u.%u ",
-					&major, &minor, &sub);
-			if (ret != 3)
-				return 0;
-			else
-				return major + (minor << 8) + (sub << 16);
-		}
-	}
-
-	return 0;
-}
-
-static __le32
-qlcnic_get_bios_version(struct qlcnic_adapter *adapter)
-{
-	const struct firmware *fw = adapter->fw;
-	__le32 bios_ver, prd_off = adapter->file_prd_off;
-
-	if (adapter->ahw->fw_type != QLCNIC_UNIFIED_ROMIMAGE)
-		return cpu_to_le32(
-			*(u32 *)&fw->data[QLCNIC_BIOS_VERSION_OFFSET]);
-
-	bios_ver = cpu_to_le32(*((u32 *) (&fw->data[prd_off])
-				+ QLCNIC_UNI_BIOS_VERSION_OFF));
-
-	return (bios_ver << 16) + ((bios_ver >> 8) & 0xff00) + (bios_ver >> 24);
-}
-
-static void qlcnic_rom_lock_recovery(struct qlcnic_adapter *adapter)
-{
-	if (qlcnic_pcie_sem_lock(adapter, 2, QLCNIC_ROM_LOCK_ID))
-		dev_info(&adapter->pdev->dev, "Resetting rom_lock\n");
-
-	qlcnic_pcie_sem_unlock(adapter, 2);
-}
-
-static int
-qlcnic_check_fw_hearbeat(struct qlcnic_adapter *adapter)
-{
-	u32 heartbeat, ret = -EIO;
-	int retries = QLCNIC_HEARTBEAT_CHECK_RETRY_COUNT;
-
-	adapter->heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
-
-	do {
-		msleep(QLCNIC_HEARTBEAT_PERIOD_MSECS);
-		heartbeat = QLCRD(adapter, QLCNIC_PEG_ALIVE_COUNTER);
-		if (heartbeat != adapter->heartbeat) {
-			ret = QLCNIC_RCODE_SUCCESS;
-			break;
-		}
-	} while (--retries);
-
-	return ret;
-}
-
-int
-qlcnic_need_fw_reset(struct qlcnic_adapter *adapter)
-{
-	if ((adapter->flags & QLCNIC_FW_HANG) ||
-			qlcnic_check_fw_hearbeat(adapter)) {
-		qlcnic_rom_lock_recovery(adapter);
-		return 1;
-	}
-
-	if (adapter->need_fw_reset)
-		return 1;
-
-	if (adapter->fw)
-		return 1;
-
-	return 0;
-}
-
-static const char *fw_name[] = {
-	QLCNIC_UNIFIED_ROMIMAGE_NAME,
-	QLCNIC_FLASH_ROMIMAGE_NAME,
-};
-
-int
-qlcnic_load_firmware(struct qlcnic_adapter *adapter)
-{
-	u64 *ptr64;
-	u32 i, flashaddr, size;
-	const struct firmware *fw = adapter->fw;
-	struct pci_dev *pdev = adapter->pdev;
-
-	dev_info(&pdev->dev, "loading firmware from %s\n",
-			fw_name[adapter->ahw->fw_type]);
-
-	if (fw) {
-		__le64 data;
-
-		size = (QLCNIC_IMAGE_START - QLCNIC_BOOTLD_START) / 8;
-
-		ptr64 = (u64 *)qlcnic_get_bootld_offs(adapter);
-		flashaddr = QLCNIC_BOOTLD_START;
-
-		for (i = 0; i < size; i++) {
-			data = cpu_to_le64(ptr64[i]);
-
-			if (qlcnic_pci_mem_write_2M(adapter, flashaddr, data))
-				return -EIO;
-
-			flashaddr += 8;
-		}
-
-		size = (__force u32)qlcnic_get_fw_size(adapter) / 8;
-
-		ptr64 = (u64 *)qlcnic_get_fw_offs(adapter);
-		flashaddr = QLCNIC_IMAGE_START;
-
-		for (i = 0; i < size; i++) {
-			data = cpu_to_le64(ptr64[i]);
-
-			if (qlcnic_pci_mem_write_2M(adapter,
-						flashaddr, data))
-				return -EIO;
-
-			flashaddr += 8;
-		}
-
-		size = (__force u32)qlcnic_get_fw_size(adapter) % 8;
-		if (size) {
-			data = cpu_to_le64(ptr64[i]);
-
-			if (qlcnic_pci_mem_write_2M(adapter,
-						flashaddr, data))
-				return -EIO;
-		}
-
-	} else {
-		u64 data;
-		u32 hi, lo;
-		int ret;
-		struct qlcnic_flt_entry bootld_entry;
-
-		ret = qlcnic_get_flt_entry(adapter, QLCNIC_BOOTLD_REGION,
-					&bootld_entry);
-		if (!ret) {
-			size = bootld_entry.size / 8;
-			flashaddr = bootld_entry.start_addr;
-		} else {
-			size = (QLCNIC_IMAGE_START - QLCNIC_BOOTLD_START) / 8;
-			flashaddr = QLCNIC_BOOTLD_START;
-			dev_info(&pdev->dev,
-				"using legacy method to get flash fw region");
-		}
-
-		for (i = 0; i < size; i++) {
-			if (qlcnic_rom_fast_read(adapter,
-					flashaddr, (int *)&lo) != 0)
-				return -EIO;
-			if (qlcnic_rom_fast_read(adapter,
-					flashaddr + 4, (int *)&hi) != 0)
-				return -EIO;
-
-			data = (((u64)hi << 32) | lo);
-
-			if (qlcnic_pci_mem_write_2M(adapter,
-						flashaddr, data))
-				return -EIO;
-
-			flashaddr += 8;
-		}
-	}
-	msleep(1);
-
-	QLCWR32(adapter, QLCNIC_CRB_PEG_NET_0 + 0x18, 0x1020);
-	QLCWR32(adapter, QLCNIC_ROMUSB_GLB_SW_RESET, 0x80001e);
-	return 0;
-}
-
-static int
-qlcnic_validate_firmware(struct qlcnic_adapter *adapter)
-{
-	__le32 val;
-	u32 ver, bios, min_size;
-	struct pci_dev *pdev = adapter->pdev;
-	const struct firmware *fw = adapter->fw;
-	u8 fw_type = adapter->ahw->fw_type;
-
-	if (fw_type == QLCNIC_UNIFIED_ROMIMAGE) {
-		if (qlcnic_validate_unified_romimage(adapter))
-			return -EINVAL;
-
-		min_size = QLCNIC_UNI_FW_MIN_SIZE;
-	} else {
-		val = cpu_to_le32(*(u32 *)&fw->data[QLCNIC_FW_MAGIC_OFFSET]);
-		if ((__force u32)val != QLCNIC_BDINFO_MAGIC)
-			return -EINVAL;
-
-		min_size = QLCNIC_FW_MIN_SIZE;
-	}
-
-	if (fw->size < min_size)
-		return -EINVAL;
-
-	val = qlcnic_get_fw_version(adapter);
-	ver = QLCNIC_DECODE_VERSION(val);
-
-	if (ver < QLCNIC_MIN_FW_VERSION) {
-		dev_err(&pdev->dev,
-				"%s: firmware version %d.%d.%d unsupported\n",
-		fw_name[fw_type], _major(ver), _minor(ver), _build(ver));
-		return -EINVAL;
-	}
-
-	val = qlcnic_get_bios_version(adapter);
-	qlcnic_rom_fast_read(adapter, QLCNIC_BIOS_VERSION_OFFSET, (int *)&bios);
-	if ((__force u32)val != bios) {
-		dev_err(&pdev->dev, "%s: firmware bios is incompatible\n",
-				fw_name[fw_type]);
-		return -EINVAL;
-	}
-
-	QLCWR(adapter, QLCNIC_FW_IMG_VALID, QLCNIC_BDINFO_MAGIC);
-	return 0;
-}
-
-static void
-qlcnic_get_next_fwtype(struct qlcnic_adapter *adapter)
-{
-	u8 fw_type;
-
-	switch (adapter->ahw->fw_type) {
-	case QLCNIC_UNKNOWN_ROMIMAGE:
-		fw_type = QLCNIC_UNIFIED_ROMIMAGE;
-		break;
-
-	case QLCNIC_UNIFIED_ROMIMAGE:
-	default:
-		fw_type = QLCNIC_FLASH_ROMIMAGE;
-		break;
-	}
-
-	adapter->ahw->fw_type = fw_type;
-}
-
-
-
-void qlcnic_request_firmware(struct qlcnic_adapter *adapter)
-{
-	struct pci_dev *pdev = adapter->pdev;
-	int rc;
-
-	adapter->ahw->fw_type = QLCNIC_UNKNOWN_ROMIMAGE;
-
-next:
-	qlcnic_get_next_fwtype(adapter);
-
-	if (adapter->ahw->fw_type == QLCNIC_FLASH_ROMIMAGE) {
-		adapter->fw = NULL;
-	} else {
-		rc = request_firmware(&adapter->fw,
-				fw_name[adapter->ahw->fw_type], &pdev->dev);
-		if (rc != 0)
-			goto next;
-
-		rc = qlcnic_validate_firmware(adapter);
-		if (rc != 0) {
-			release_firmware(adapter->fw);
-			msleep(1);
-			goto next;
-		}
-	}
-}
-
-
-void
-qlcnic_release_firmware(struct qlcnic_adapter *adapter)
-{
-	if (adapter->fw)
-		release_firmware(adapter->fw);
-	adapter->fw = NULL;
-}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
index ce8a4e0..165d596 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_io.c
@@ -1167,3 +1167,442 @@ qlcnic_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
 	sds_ring->consumer = consumer;
 	writel(consumer, sds_ring->crb_sts_consumer);
 }
+
+static struct qlcnic_rx_buffer *
+qlcnic_83xx_process_rcv(struct qlcnic_adapter *adapter,
+		struct qlcnic_host_sds_ring *sds_ring,
+		u8 ring, u64 sts_data[])
+{
+	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_rx_buffer *buffer;
+	struct sk_buff *skb;
+	struct qlcnic_host_rds_ring *rds_ring;
+	int index, length, cksum;
+	u16 vid = 0xffff;
+
+	if (unlikely(ring >= adapter->max_rds_rings))
+		return NULL;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+
+	index = qlcnic_83xx_hndl(sts_data[0]);
+	if (unlikely(index >= rds_ring->num_desc))
+		return NULL;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+
+	length = qlcnic_83xx_pktln(sts_data[0]);
+	cksum  = qlcnic_83xx_csum_status(sts_data[1]);
+	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, cksum);
+	if (!skb)
+		return buffer;
+
+	if (length > rds_ring->skb_size)
+		skb_put(skb, rds_ring->skb_size);
+	else
+		skb_put(skb, length);
+
+	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+		adapter->stats.rxdropped++;
+		dev_kfree_skb(skb);
+		return buffer;
+	}
+
+	skb->protocol = eth_type_trans(skb, netdev);
+
+	if (vid != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vid);
+
+	napi_gro_receive(&sds_ring->napi, skb);
+
+	adapter->stats.rx_pkts++;
+	adapter->stats.rxbytes += length;
+
+	return buffer;
+}
+
+static struct qlcnic_rx_buffer *
+qlcnic_83xx_process_lro(struct qlcnic_adapter *adapter,
+		struct qlcnic_host_sds_ring *sds_ring,
+		u8 ring, u64 sts_data[])
+{
+	struct net_device *netdev = adapter->netdev;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_rx_buffer *buffer;
+	struct sk_buff *skb;
+	struct qlcnic_host_rds_ring *rds_ring;
+	struct iphdr *iph;
+	struct ipv6hdr *ipv6h;
+	struct tcphdr *th;
+	bool push;
+	int l2_hdr_offset, l4_hdr_offset;
+	int index;
+	u16 lro_length, length, data_offset;
+	u16 vid = 0xffff;
+
+	if (unlikely(ring > adapter->max_rds_rings))
+		return NULL;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+
+	index = qlcnic_83xx_hndl(sts_data[0]);
+	if (unlikely(index > rds_ring->num_desc))
+		return NULL;
+
+	buffer = &rds_ring->rx_buf_arr[index];
+
+	lro_length = qlcnic_83xx_lro_pktln(sts_data[0]);
+	l2_hdr_offset = qlcnic_83xx_l2_hdr_off(sts_data[1]);
+	l4_hdr_offset = qlcnic_83xx_l4_hdr_off(sts_data[1]);
+	push = qlcnic_83xx_is_psh_bit(sts_data[1]);
+
+	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
+	if (!skb)
+		return buffer;
+	if (qlcnic_83xx_is_tstamp(sts_data[1]))
+		data_offset = l4_hdr_offset + QLC_TCP_TS_HDR_SIZE;
+	else
+		data_offset = l4_hdr_offset + QLC_TCP_HDR_SIZE;
+
+	skb_put(skb, lro_length + data_offset);
+
+	skb_pull(skb, l2_hdr_offset);
+
+	if (unlikely(qlcnic_check_rx_tagging(adapter, skb, &vid))) {
+		adapter->stats.rxdropped++;
+		dev_kfree_skb(skb);
+		return buffer;
+	}
+
+	skb->protocol = eth_type_trans(skb, netdev);
+
+	if (htons(skb->protocol) == ETH_P_IPV6) {
+		ipv6h = (struct ipv6hdr *)skb->data;
+		th = (struct tcphdr *)(skb->data + sizeof(struct ipv6hdr));
+
+		length = (th->doff << 2) + lro_length;
+		ipv6h->payload_len = htons(length);
+	} else {
+		iph = (struct iphdr *)skb->data;
+		th = (struct tcphdr *)(skb->data + (iph->ihl << 2));
+
+		length = (iph->ihl << 2) + (th->doff << 2) + lro_length;
+		iph->tot_len = htons(length);
+		iph->check = 0;
+		iph->check = ip_fast_csum((unsigned char *)iph, iph->ihl);
+	}
+
+
+	th->psh = push;
+
+	length = skb->len;
+
+	if (vid != 0xffff)
+		__vlan_hwaccel_put_tag(skb, vid);
+	netif_receive_skb(skb);
+
+	adapter->stats.lro_pkts++;
+	adapter->stats.lrobytes += length;
+	return buffer;
+}
+
+static int
+qlcnic_83xx_process_rcv_ring(struct qlcnic_host_sds_ring *sds_ring, int max)
+{
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+	struct list_head *cur;
+	struct status_desc *desc;
+	struct qlcnic_rx_buffer *rxbuf = NULL;
+	u64 sts_data[2];
+
+	int count = 0, opcode;
+	u8 ring;
+	u32 consumer = sds_ring->consumer;
+
+	while (count < max) {
+		desc = &sds_ring->desc_head[consumer];
+		sts_data[1] = le64_to_cpu(desc->status_desc_data[1]);
+		opcode = qlcnic_83xx_opcode(sts_data[1]);
+		if (!opcode)
+			break;
+		sts_data[0] = le64_to_cpu(desc->status_desc_data[0]);
+		ring = QLCNIC_FETCH_RING_ID(sts_data[0]);
+
+		switch (opcode) {
+		case QLC_83XX_REG_DESC:
+			rxbuf = qlcnic_83xx_process_rcv(adapter, sds_ring,
+					ring, sts_data);
+			break;
+		case QLC_83XX_LRO_DESC:
+			rxbuf = qlcnic_83xx_process_lro(adapter, sds_ring,
+					ring, sts_data);
+			break;
+		default:
+			dev_info(&adapter->pdev->dev,
+				"Unkonwn opcode: 0x%x\n", opcode);
+			goto skip;
+		}
+
+		if (likely(rxbuf))
+			list_add_tail(&rxbuf->list, &sds_ring->free_list[ring]);
+		else
+			adapter->stats.null_rxbuf++;
+
+skip:
+		desc = &sds_ring->desc_head[consumer];
+		/* Reset the descriptor */
+		desc->status_desc_data[1] = 0;
+		consumer = get_next_index(consumer, sds_ring->num_desc);
+		count++;
+	}
+	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
+		struct qlcnic_host_rds_ring *rds_ring =
+			&adapter->recv_ctx->rds_rings[ring];
+
+		if (!list_empty(&sds_ring->free_list[ring])) {
+			list_for_each(cur, &sds_ring->free_list[ring]) {
+				rxbuf = list_entry(cur,
+						struct qlcnic_rx_buffer, list);
+				qlcnic_alloc_rx_skb(adapter, rds_ring, rxbuf);
+			}
+			spin_lock(&rds_ring->lock);
+			list_splice_tail_init(&sds_ring->free_list[ring],
+						&rds_ring->free_list);
+			spin_unlock(&rds_ring->lock);
+		}
+
+		qlcnic_post_rx_buffers_nodb(adapter, rds_ring, ring);
+	}
+
+	if (count) {
+		sds_ring->consumer = consumer;
+		writel(consumer, sds_ring->crb_sts_consumer);
+	}
+	return count;
+}
+
+static int qlcnic_83xx_poll(struct napi_struct *napi, int budget)
+{
+	struct qlcnic_host_sds_ring *sds_ring =
+		container_of(napi, struct qlcnic_host_sds_ring, napi);
+
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+
+	/* there is only 1 tx ring in this path */
+	struct qlcnic_host_tx_ring *tx_ring = adapter->tx_ring;
+
+	int tx_complete;
+	int work_done;
+
+	if (!(adapter->flags & QLCNIC_MSIX_ENABLED))
+		qlcnic_83xx_process_aen(adapter);
+
+	tx_complete = qlcnic_process_cmd_ring(adapter, tx_ring, budget);
+
+	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
+
+	if ((work_done < budget) && tx_complete) {
+		napi_complete(&sds_ring->napi);
+		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
+			qlcnic_83xx_enable_intr(adapter, sds_ring);
+	}
+
+	return work_done;
+}
+
+static int qlcnic_83xx_msix_tx_poll(struct napi_struct *napi, int budget)
+{
+	struct qlcnic_host_tx_ring *tx_ring =
+		container_of(napi, struct qlcnic_host_tx_ring, napi);
+
+	struct qlcnic_adapter *adapter = tx_ring->adapter;
+	int work_done;
+
+	work_done = qlcnic_process_cmd_ring(adapter, tx_ring,
+				 QLCNIC_TX_POLL_BUDGET);
+
+	if (work_done) {
+		napi_complete(&tx_ring->napi);
+		if (test_bit(__QLCNIC_DEV_UP , &adapter->state))
+			qlcnic_83xx_enable_tx_intr(adapter, tx_ring);
+	}
+
+	return work_done;
+}
+
+static int qlcnic_83xx_rx_poll(struct napi_struct *napi, int budget)
+{
+	struct qlcnic_host_sds_ring *sds_ring =
+		container_of(napi, struct qlcnic_host_sds_ring, napi);
+
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+	int work_done;
+
+	work_done = qlcnic_83xx_process_rcv_ring(sds_ring, budget);
+
+	if (work_done < budget) {
+		napi_complete(&sds_ring->napi);
+		if (test_bit(__QLCNIC_DEV_UP, &adapter->state))
+			qlcnic_83xx_enable_intr(adapter, sds_ring);
+	}
+
+	return work_done;
+}
+
+void
+qlcnic_83xx_napi_enable(struct qlcnic_adapter *adapter)
+{
+	int ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		napi_enable(&sds_ring->napi);
+		qlcnic_83xx_enable_intr(adapter, sds_ring);
+	}
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			napi_enable(&tx_ring->napi);
+			qlcnic_83xx_enable_tx_intr(adapter, tx_ring);
+		}
+	}
+}
+
+void
+qlcnic_83xx_napi_disable(struct qlcnic_adapter *adapter)
+{
+	int ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct qlcnic_host_tx_ring *tx_ring;
+
+	if (adapter->is_up != QLCNIC_ADAPTER_UP_MAGIC)
+		return;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		writel(1, sds_ring->crb_intr_mask);
+		napi_synchronize(&sds_ring->napi);
+		napi_disable(&sds_ring->napi);
+	}
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			qlcnic_83xx_disable_tx_intr(adapter, tx_ring);
+			napi_synchronize(&tx_ring->napi);
+			napi_disable(&tx_ring->napi);
+		}
+	}
+}
+
+int
+qlcnic_83xx_napi_add(struct qlcnic_adapter *adapter, struct net_device *netdev)
+{
+	int ring;
+	struct qlcnic_host_sds_ring *sds_ring;
+	struct qlcnic_host_tx_ring *tx_ring;
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+
+	if (qlcnic_alloc_sds_rings(recv_ctx, adapter->max_sds_rings))
+		return -ENOMEM;
+
+	for (ring = 0; ring < adapter->max_sds_rings; ring++) {
+		sds_ring = &recv_ctx->sds_rings[ring];
+		if (adapter->flags & QLCNIC_MSIX_ENABLED)
+			netif_napi_add(netdev, &sds_ring->napi,
+			    qlcnic_83xx_rx_poll, QLCNIC_NETDEV_WEIGHT * 2);
+		else
+			netif_napi_add(netdev, &sds_ring->napi,
+			    qlcnic_83xx_poll,
+				QLCNIC_NETDEV_WEIGHT/adapter->max_sds_rings);
+	}
+
+	if (qlcnic_alloc_tx_rings(adapter, netdev)) {
+		qlcnic_free_sds_rings(recv_ctx);
+		return -ENOMEM;
+	}
+
+	if (adapter->flags & QLCNIC_MSIX_ENABLED) {
+		for (ring = 0; ring < adapter->max_drv_tx_rings; ring++) {
+			tx_ring = &adapter->tx_ring[ring];
+			netif_napi_add(netdev, &tx_ring->napi,
+				qlcnic_83xx_msix_tx_poll,
+				QLCNIC_NETDEV_WEIGHT);
+		}
+	}
+
+	return 0;
+}
+
+void qlcnic_83xx_process_rcv_diag(struct qlcnic_adapter *adapter,
+		struct qlcnic_host_sds_ring *sds_ring,
+		int ring, u64 sts_data[])
+{
+	struct qlcnic_recv_context *recv_ctx = adapter->recv_ctx;
+	struct sk_buff *skb;
+	struct qlcnic_host_rds_ring *rds_ring;
+	int index, length, cksum;
+
+	if (unlikely(ring >= adapter->max_rds_rings))
+		return;
+
+	rds_ring = &recv_ctx->rds_rings[ring];
+	index = qlcnic_83xx_hndl(sts_data[0]);
+	if (unlikely(index >= rds_ring->num_desc))
+		return;
+
+	length = qlcnic_83xx_pktln(sts_data[0]);
+	cksum  = qlcnic_83xx_csum_status(sts_data[0]);
+	skb = qlcnic_process_rxbuf(adapter, rds_ring, index, STATUS_CKSUM_OK);
+	if (!skb)
+		return;
+
+	if (length > rds_ring->skb_size)
+		skb_put(skb, rds_ring->skb_size);
+	else
+		skb_put(skb, length);
+
+	if (!qlcnic_check_loopback_buff(skb->data, adapter->mac_addr))
+		adapter->ahw->diag_cnt++;
+	else
+		dump_skb(skb, adapter);
+
+	dev_kfree_skb_any(skb);
+	return;
+}
+
+void qlcnic_83xx_process_rcv_ring_diag(struct qlcnic_host_sds_ring *sds_ring)
+{
+	struct qlcnic_adapter *adapter = sds_ring->adapter;
+	struct status_desc *desc;
+	u64 sts_data[2];
+	int ring, opcode;
+
+	u32 consumer = sds_ring->consumer;
+
+	desc = &sds_ring->desc_head[consumer];
+	sts_data[0] = le64_to_cpu(desc->status_desc_data[0]);
+	sts_data[1] = le64_to_cpu(desc->status_desc_data[1]);
+	opcode = qlcnic_83xx_opcode(sts_data[1]);
+	if (!opcode)
+		return;
+
+	ring = QLCNIC_FETCH_RING_ID(qlcnic_83xx_hndl(sts_data[0]));
+	qlcnic_83xx_process_rcv_diag(adapter, sds_ring, ring, sts_data);
+
+	desc = &sds_ring->desc_head[consumer];
+	desc->status_desc_data[0] = cpu_to_le64(STATUS_OWNER_PHANTOM);
+	consumer = get_next_index(consumer, sds_ring->num_desc);
+
+	sds_ring->consumer = consumer;
+	writel(consumer, sds_ring->crb_sts_consumer);
+}
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index 1720afc..49ef8bb 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -10,6 +10,9 @@
 #define QLC_83XX_OCM_INDEX			3
 #define QLC_83XX_PCI_INDEX			0
 
+static const u32 qlcnic_ms_read_data[] = {
+	0x410000A8, 0x410000AC, 0x410000B8, 0x410000BC, };
+
 static u32
 qlcnic_dump_crb(struct qlcnic_adapter *adapter, struct qlcnic_dump_entry *entry,
 		u32 *buffer)
@@ -318,7 +321,7 @@ qlcnic_read_memory(struct qlcnic_adapter *adapter,
 			goto out;
 		}
 		for (i = 0; i < 4; i++) {
-			data = qlcnic_ind_rd(adapter, QLCNIC_MS_READ_DATA[i]);
+			data = qlcnic_ind_rd(adapter, qlcnic_ms_read_data[i]);
 			*buffer++ = cpu_to_le32(data);
 		}
 		addr += 16;
-- 
1.7.1
