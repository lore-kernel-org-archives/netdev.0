From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 4/9] Neterion: New driver: Hardware init &
	configuration
Date: 01 Apr 2009 20:14:40 -0800
Message-ID: <1238645673.18544.224.camel@flash>
References: <1238194467.5516.383.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	Ramkrishna Vepa <ram.vepa@neterion.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:33641 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762591AbZDBDdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 23:33:09 -0400
In-Reply-To: <1238194467.5516.383.camel@flash>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes care of Initialization and configuration steps of
Neterion Inc's X3100 Series 10GbE PCIe I/O Virtualized Server Adapter.
- Device Initialization.
- Verification and setting of device config parameters.
- Allocation of Tx FIFO and Rx Ring descriptors (DTR).
- APIs to get various type of hw stats
- APIs to configure RTS (Receive Traffic Steering)

- Changes in this submission -
        - Include vmalloc header without which a compilation error occured
          on sparc64, ppc64 and IA64 plaforms.
	- Fixed compilation warning in register_poll, write32_upper,
          write32_lower and the special write64 functions on ppc64.
        - General cleanup - removed redundant includes and defines.

- Changes in previous submissions -
        - Add readq/writeq implementation for the driver for 32 bit systems -
          reported by Dave Miller.
- Incorporated following comments from Ben Hutchings
        - Start a comment with "/**" to make it a kernel-doc comment.
        - Use prefix, "__vxge" in front of hw functions to make them globally
          unique.
        - Fixed unnecessary clearing members of *channel just before freeing
        - Use backslashes only for macro definitions and not in multi-line
          statements.
        - Used pci_find_capability instead of redefining it.
        - Used device and revision ids that are already in pdev - no need to
          read them again.
        - Used pci_save_state() and pci_restore_state() around resets.
        - Used udelay and mdelay directly instead of wrapper.
        - In __vxge_hw_device_register_poll() reset i to 0 after the
          microsecond delay loop to commence the millisecond delay loop.
        - Corrected spelling "sapper" - should be "swapper"
        - Remove too much vertical whitespace.
        - Replaced magic numbers with appropriate macros
- Incorporated following comments from Andi Kleen [andi@firstfloor.org]
        - Reduced the arguments in functions or refactored them into smaller
        functions.
        - Allocate page sized memories used in slow path with vmalloc.
        - Use asserts where necessary.
        - Use macros instead of magic numbers.
        - Use the pci layer code instead of defining own functions
        - Remove driver wrappers such as xge_hw_device_private_set().
        - Fixed sparse warnings.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_3/drivers/net/vxge/vxge-config.c patch_4/drivers/net/vxge/vxge-config.c
--- patch_3/drivers/net/vxge/vxge-config.c	1969-12-31 16:00:00.000000000 -0800
+++ patch_4/drivers/net/vxge/vxge-config.c	2009-04-01 12:19:30.000000000 -0700
@@ -0,0 +1,5264 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ *
+ * vxge-config.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *                Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#include <linux/vmalloc.h>
+#include <linux/etherdevice.h>
+#include <linux/pci.h>
+#include <linux/pci_hotplug.h>
+
+#include "vxge-traffic.h"
+#include "vxge-config.h"
+
+/*
+ * __vxge_hw_channel_allocate - Allocate memory for channel
+ * This function allocates required memory for the channel and various arrays
+ * in the channel
+ */
+struct __vxge_hw_channel*
+__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
+			   enum __vxge_hw_channel_type type,
+	u32 length, u32 per_dtr_space, void *userdata)
+{
+	struct __vxge_hw_channel *channel;
+	struct __vxge_hw_device *hldev;
+	int size = 0;
+	u32 vp_id;
+
+	hldev = vph->vpath->hldev;
+	vp_id = vph->vpath->vp_id;
+
+	switch (type) {
+	case VXGE_HW_CHANNEL_TYPE_FIFO:
+		size = sizeof(struct __vxge_hw_fifo);
+		break;
+	case VXGE_HW_CHANNEL_TYPE_RING:
+		size = sizeof(struct __vxge_hw_ring);
+		break;
+	default:
+		break;
+	}
+
+	channel = kzalloc(size, GFP_KERNEL);
+	if (channel == NULL)
+		goto exit0;
+	INIT_LIST_HEAD(&channel->item);
+
+	channel->common_reg = hldev->common_reg;
+	channel->first_vp_id = hldev->first_vp_id;
+	channel->type = type;
+	channel->devh = hldev;
+	channel->vph = vph;
+	channel->userdata = userdata;
+	channel->per_dtr_space = per_dtr_space;
+	channel->length = length;
+	channel->vp_id = vp_id;
+
+	channel->work_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	if (channel->work_arr == NULL)
+		goto exit1;
+
+	channel->free_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	if (channel->free_arr == NULL)
+		goto exit1;
+	channel->free_ptr = length;
+
+	channel->reserve_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	if (channel->reserve_arr == NULL)
+		goto exit1;
+	channel->reserve_ptr = length;
+	channel->reserve_top = 0;
+
+	channel->orig_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+	if (channel->orig_arr == NULL)
+		goto exit1;
+
+	return channel;
+exit1:
+	__vxge_hw_channel_free(channel);
+
+exit0:
+	return NULL;
+}
+
+/*
+ * __vxge_hw_channel_free - Free memory allocated for channel
+ * This function deallocates memory from the channel and various arrays
+ * in the channel
+ */
+void __vxge_hw_channel_free(struct __vxge_hw_channel *channel)
+{
+	kfree(channel->work_arr);
+	kfree(channel->free_arr);
+	kfree(channel->reserve_arr);
+	kfree(channel->orig_arr);
+	kfree(channel);
+}
+
+/*
+ * __vxge_hw_channel_initialize - Initialize a channel
+ * This function initializes a channel by properly setting the
+ * various references
+ */
+enum vxge_hw_status
+__vxge_hw_channel_initialize(struct __vxge_hw_channel *channel)
+{
+	u32 i;
+	struct __vxge_hw_virtualpath *vpath;
+
+	vpath = channel->vph->vpath;
+
+	if ((channel->reserve_arr != NULL) && (channel->orig_arr != NULL)) {
+		for (i = 0; i < channel->length; i++)
+			channel->orig_arr[i] = channel->reserve_arr[i];
+	}
+
+	switch (channel->type) {
+	case VXGE_HW_CHANNEL_TYPE_FIFO:
+		vpath->fifoh = (struct __vxge_hw_fifo *)channel;
+		channel->stats = &((struct __vxge_hw_fifo *)
+				channel)->stats->common_stats;
+		break;
+	case VXGE_HW_CHANNEL_TYPE_RING:
+		vpath->ringh = (struct __vxge_hw_ring *)channel;
+		channel->stats = &((struct __vxge_hw_ring *)
+				channel)->stats->common_stats;
+		break;
+	default:
+		break;
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_channel_reset - Resets a channel
+ * This function resets a channel by properly setting the various references
+ */
+enum vxge_hw_status
+__vxge_hw_channel_reset(struct __vxge_hw_channel *channel)
+{
+	u32 i;
+
+	for (i = 0; i < channel->length; i++) {
+		if (channel->reserve_arr != NULL)
+			channel->reserve_arr[i] = channel->orig_arr[i];
+		if (channel->free_arr != NULL)
+			channel->free_arr[i] = NULL;
+		if (channel->work_arr != NULL)
+			channel->work_arr[i] = NULL;
+	}
+	channel->free_ptr = channel->length;
+	channel->reserve_ptr = channel->length;
+	channel->reserve_top = 0;
+	channel->post_index = 0;
+	channel->compl_index = 0;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_pci_e_init
+ * Initialize certain PCI/PCI-X configuration registers
+ * with recommended values. Save config space for future hw resets.
+ */
+void
+__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
+{
+	u16 cmd = 0;
+
+	/* Set the PErr Repconse bit and SERR in PCI command register. */
+	pci_read_config_word(hldev->pdev, PCI_COMMAND, &cmd);
+	cmd |= 0x140;
+	pci_write_config_word(hldev->pdev, PCI_COMMAND, cmd);
+
+	pci_save_state(hldev->pdev);
+
+	return;
+}
+
+/*
+ * __vxge_hw_device_register_poll
+ * Will poll certain register for specified amount of time.
+ * Will poll until masked bit is not cleared.
+ */
+enum vxge_hw_status
+__vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
+{
+	u64 val64;
+	u32 i = 0;
+	enum vxge_hw_status ret = VXGE_HW_FAIL;
+
+	udelay(10);
+
+	do {
+		val64 = readq(reg);
+		if (!(val64 & mask))
+			return VXGE_HW_OK;
+		udelay(100);
+	} while (++i <= 9);
+
+	i = 0;
+	do {
+		val64 = readq(reg);
+		if (!(val64 & mask))
+			return VXGE_HW_OK;
+		mdelay(1);
+	} while (++i <= max_millis);
+
+	return ret;
+}
+
+ /* __vxge_hw_device_vpath_reset_in_prog_check - Check if vpath reset
+ * in progress
+ * This routine checks the vpath reset in progress register is turned zero
+ */
+enum vxge_hw_status
+__vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog)
+{
+	enum vxge_hw_status status;
+	status = __vxge_hw_device_register_poll(vpath_rst_in_prog,
+			VXGE_HW_VPATH_RST_IN_PROG_VPATH_RST_IN_PROG(0x1ffff),
+			VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+	return status;
+}
+
+/*
+ * __vxge_hw_device_toc_get
+ * This routine sets the swapper and reads the toc pointer and returns the
+ * memory mapped address of the toc
+ */
+struct vxge_hw_toc_reg __iomem *
+__vxge_hw_device_toc_get(void __iomem *bar0)
+{
+	u64 val64;
+	struct vxge_hw_toc_reg __iomem *toc = NULL;
+	enum vxge_hw_status status;
+
+	struct vxge_hw_legacy_reg __iomem *legacy_reg =
+		(struct vxge_hw_legacy_reg __iomem *)bar0;
+
+	status = __vxge_hw_legacy_swapper_set(legacy_reg);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 =	readq(&legacy_reg->toc_first_pointer);
+	toc = (struct vxge_hw_toc_reg __iomem *)(bar0+val64);
+exit:
+	return toc;
+}
+
+/*
+ * __vxge_hw_device_reg_addr_get
+ * This routine sets the swapper and reads the toc pointer and initializes the
+ * register location pointers in the device object. It waits until the ric is
+ * completed initializing registers.
+ */
+enum vxge_hw_status
+__vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev)
+{
+	u64 val64;
+	u32 i;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	hldev->legacy_reg = (struct vxge_hw_legacy_reg __iomem *)hldev->bar0;
+
+	hldev->toc_reg = __vxge_hw_device_toc_get(hldev->bar0);
+	if (hldev->toc_reg  == NULL) {
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	val64 = readq(&hldev->toc_reg->toc_common_pointer);
+	hldev->common_reg =
+	(struct vxge_hw_common_reg __iomem *)(hldev->bar0 + val64);
+
+	val64 = readq(&hldev->toc_reg->toc_mrpcim_pointer);
+	hldev->mrpcim_reg =
+		(struct vxge_hw_mrpcim_reg __iomem *)(hldev->bar0 + val64);
+
+	for (i = 0; i < VXGE_HW_TITAN_SRPCIM_REG_SPACES; i++) {
+		val64 = readq(&hldev->toc_reg->toc_srpcim_pointer[i]);
+		hldev->srpcim_reg[i] =
+			(struct vxge_hw_srpcim_reg __iomem *)
+				(hldev->bar0 + val64);
+	}
+
+	for (i = 0; i < VXGE_HW_TITAN_VPMGMT_REG_SPACES; i++) {
+		val64 = readq(&hldev->toc_reg->toc_vpmgmt_pointer[i]);
+		hldev->vpmgmt_reg[i] =
+		(struct vxge_hw_vpmgmt_reg __iomem *)(hldev->bar0 + val64);
+	}
+
+	for (i = 0; i < VXGE_HW_TITAN_VPATH_REG_SPACES; i++) {
+		val64 = readq(&hldev->toc_reg->toc_vpath_pointer[i]);
+		hldev->vpath_reg[i] =
+			(struct vxge_hw_vpath_reg __iomem *)
+				(hldev->bar0 + val64);
+	}
+
+	val64 = readq(&hldev->toc_reg->toc_kdfc);
+
+	switch (VXGE_HW_TOC_GET_KDFC_INITIAL_BIR(val64)) {
+	case 0:
+		hldev->kdfc = (u8 __iomem *)(hldev->bar0 +
+			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64));
+		break;
+	case 2:
+		hldev->kdfc = (u8 __iomem *)(hldev->bar1 +
+			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64));
+		break;
+	case 4:
+		hldev->kdfc = (u8 __iomem *)(hldev->bar2 +
+			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64));
+		break;
+	default:
+		break;
+	}
+
+	status = __vxge_hw_device_vpath_reset_in_prog_check(
+			(u64 __iomem *)&hldev->common_reg->vpath_rst_in_prog);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_device_id_get
+ * This routine returns sets the device id and revision numbers into the device
+ * structure
+ */
+void __vxge_hw_device_id_get(struct __vxge_hw_device *hldev)
+{
+	u64 val64;
+
+	val64 = readq(&hldev->common_reg->titan_asic_id);
+	hldev->device_id =
+		(u16)VXGE_HW_TITAN_ASIC_ID_GET_INITIAL_DEVICE_ID(val64);
+
+	hldev->major_revision =
+		(u8)VXGE_HW_TITAN_ASIC_ID_GET_INITIAL_MAJOR_REVISION(val64);
+
+	hldev->minor_revision =
+		(u8)VXGE_HW_TITAN_ASIC_ID_GET_INITIAL_MINOR_REVISION(val64);
+
+	return;
+}
+
+/*
+ * __vxge_hw_device_access_rights_get: Get Access Rights of the driver
+ * This routine returns the Access Rights of the driver
+ */
+static u32
+__vxge_hw_device_access_rights_get(u32 host_type, u32 func_id)
+{
+	u32 access_rights = VXGE_HW_DEVICE_ACCESS_RIGHT_VPATH;
+
+	switch (host_type) {
+	case VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION:
+		if (func_id == 0) {
+			access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
+					VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
+		}
+		break;
+	case VXGE_HW_MR_NO_SR_VH0_BASE_FUNCTION:
+		access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
+				VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
+		break;
+	case VXGE_HW_NO_MR_SR_VH0_FUNCTION0:
+		access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM |
+				VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
+		break;
+	case VXGE_HW_NO_MR_SR_VH0_VIRTUAL_FUNCTION:
+	case VXGE_HW_SR_VH_VIRTUAL_FUNCTION:
+	case VXGE_HW_MR_SR_VH0_INVALID_CONFIG:
+		break;
+	case VXGE_HW_SR_VH_FUNCTION0:
+	case VXGE_HW_VH_NORMAL_FUNCTION:
+		access_rights |= VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM;
+		break;
+	}
+
+	return access_rights;
+}
+/*
+ * __vxge_hw_device_host_info_get
+ * This routine returns the host type assignments
+ */
+void __vxge_hw_device_host_info_get(struct __vxge_hw_device *hldev)
+{
+	u64 val64;
+	u32 i;
+
+	val64 = readq(&hldev->common_reg->host_type_assignments);
+
+	hldev->host_type =
+	   (u32)VXGE_HW_HOST_TYPE_ASSIGNMENTS_GET_HOST_TYPE_ASSIGNMENTS(val64);
+
+	hldev->vpath_assignments = readq(&hldev->common_reg->vpath_assignments);
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!(hldev->vpath_assignments & vxge_mBIT(i)))
+			continue;
+
+		hldev->func_id =
+			__vxge_hw_vpath_func_id_get(i, hldev->vpmgmt_reg[i]);
+
+		hldev->access_rights = __vxge_hw_device_access_rights_get(
+			hldev->host_type, hldev->func_id);
+
+		hldev->first_vp_id = i;
+		break;
+	}
+
+	return;
+}
+
+/*
+ * __vxge_hw_verify_pci_e_info - Validate the pci-e link parameters such as
+ * link width and signalling rate.
+ */
+static enum vxge_hw_status
+__vxge_hw_verify_pci_e_info(struct __vxge_hw_device *hldev)
+{
+	int exp_cap;
+	u16 lnk;
+
+	/* Get the negotiated link width and speed from PCI config space */
+	exp_cap = pci_find_capability(hldev->pdev, PCI_CAP_ID_EXP);
+	pci_read_config_word(hldev->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
+
+	if ((lnk & PCI_EXP_LNKSTA_CLS) != 1)
+		return VXGE_HW_ERR_INVALID_PCI_INFO;
+
+	switch ((lnk & PCI_EXP_LNKSTA_NLW) >> 4) {
+	case PCIE_LNK_WIDTH_RESRV:
+	case PCIE_LNK_X1:
+	case PCIE_LNK_X2:
+	case PCIE_LNK_X4:
+	case PCIE_LNK_X8:
+		break;
+	default:
+		return VXGE_HW_ERR_INVALID_PCI_INFO;
+	}
+
+	return VXGE_HW_OK;
+}
+
+static enum vxge_hw_status
+__vxge_hw_device_is_privilaged(struct __vxge_hw_device *hldev)
+{
+	if ((hldev->host_type == VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION ||
+	hldev->host_type == VXGE_HW_MR_NO_SR_VH0_BASE_FUNCTION ||
+	hldev->host_type == VXGE_HW_NO_MR_SR_VH0_FUNCTION0) &&
+	(hldev->func_id == 0))
+		return VXGE_HW_OK;
+	else
+		return VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+}
+
+/*
+ * vxge_hw_wrr_rebalance - Rebalance the RX_WRR and KDFC_WRR calandars.
+ * Rebalance the RX_WRR and KDFC_WRR calandars.
+ */
+static enum
+vxge_hw_status vxge_hw_wrr_rebalance(struct __vxge_hw_device *hldev)
+{
+	u64 val64;
+	u32 wrr_states[VXGE_HW_WEIGHTED_RR_SERVICE_STATES];
+	u32 i, j, how_often = 1;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	status = __vxge_hw_device_is_privilaged(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	/* Reset the priorities assigned to the WRR arbitration
+	phases for the receive traffic */
+	for (i = 0; i < VXGE_HW_WRR_RING_COUNT; i++)
+		writeq(0, ((&hldev->mrpcim_reg->rx_w_round_robin_0) + i));
+
+	/* Reset the transmit FIFO servicing calendar for FIFOs */
+	for (i = 0; i < VXGE_HW_WRR_FIFO_COUNT; i++) {
+		writeq(0, ((&hldev->mrpcim_reg->kdfc_w_round_robin_0) + i));
+		writeq(0, ((&hldev->mrpcim_reg->kdfc_w_round_robin_20) + i));
+	}
+
+	/* Assign WRR priority  0 for all FIFOs */
+	for (i = 1; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		writeq(VXGE_HW_KDFC_FIFO_0_CTRL_WRR_NUMBER(0),
+				((&hldev->mrpcim_reg->kdfc_fifo_0_ctrl)  + i));
+
+		writeq(VXGE_HW_KDFC_FIFO_17_CTRL_WRR_NUMBER(0),
+			((&hldev->mrpcim_reg->kdfc_fifo_17_ctrl) + i));
+	}
+
+	/* Reset to service non-offload doorbells */
+	writeq(0, &hldev->mrpcim_reg->kdfc_entry_type_sel_0);
+	writeq(0, &hldev->mrpcim_reg->kdfc_entry_type_sel_1);
+
+	/* Set priority 0 to all receive queues */
+	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_0);
+	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_1);
+	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_2);
+
+	/* Initialize all the slots as unused */
+	for (i = 0; i < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; i++)
+		wrr_states[i] = -1;
+
+	/* Prepare the Fifo service states */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!hldev->config.vp_config[i].min_bandwidth)
+			continue;
+
+		how_often = VXGE_HW_VPATH_BANDWIDTH_MAX /
+				hldev->config.vp_config[i].min_bandwidth;
+		if (how_often) {
+
+			for (j = 0; j < VXGE_HW_WRR_FIFO_SERVICE_STATES;) {
+				if (wrr_states[j] == -1) {
+					wrr_states[j] = i;
+					/* Make sure each fifo is serviced
+					 * atleast once */
+					if (i == j)
+						j += VXGE_HW_MAX_VIRTUAL_PATHS;
+					else
+						j += how_often;
+				} else
+					j++;
+			}
+		}
+	}
+
+	/* Fill the unused slots with 0 */
+	for (j = 0; j < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; j++) {
+		if (wrr_states[j] == -1)
+			wrr_states[j] = 0;
+	}
+
+	/* Assign WRR priority number for FIFOs */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		writeq(VXGE_HW_KDFC_FIFO_0_CTRL_WRR_NUMBER(i),
+				((&hldev->mrpcim_reg->kdfc_fifo_0_ctrl) + i));
+
+		writeq(VXGE_HW_KDFC_FIFO_17_CTRL_WRR_NUMBER(i),
+			((&hldev->mrpcim_reg->kdfc_fifo_17_ctrl) + i));
+	}
+
+	/* Modify the servicing algorithm applied to the 3 types of doorbells.
+	i.e, none-offload, message and offload */
+	writeq(VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_0(0) |
+				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_1(0) |
+				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_2(0) |
+				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_3(0) |
+				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_4(1) |
+				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_5(0) |
+				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_6(0) |
+				VXGE_HW_KDFC_ENTRY_TYPE_SEL_0_NUMBER_7(0),
+				&hldev->mrpcim_reg->kdfc_entry_type_sel_0);
+
+	writeq(VXGE_HW_KDFC_ENTRY_TYPE_SEL_1_NUMBER_8(1),
+				&hldev->mrpcim_reg->kdfc_entry_type_sel_1);
+
+	for (i = 0, j = 0; i < VXGE_HW_WRR_FIFO_COUNT; i++) {
+
+		val64 = VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_0(wrr_states[j++]);
+		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_1(wrr_states[j++]);
+		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_2(wrr_states[j++]);
+		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_3(wrr_states[j++]);
+		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_4(wrr_states[j++]);
+		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_5(wrr_states[j++]);
+		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_6(wrr_states[j++]);
+		val64 |= VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_7(wrr_states[j++]);
+
+		writeq(val64, (&hldev->mrpcim_reg->kdfc_w_round_robin_0 + i));
+		writeq(val64, (&hldev->mrpcim_reg->kdfc_w_round_robin_20 + i));
+	}
+
+	/* Set up the priorities assigned to receive queues */
+	writeq(VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_0(0) |
+			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_1(1) |
+			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_2(2) |
+			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_3(3) |
+			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_4(4) |
+			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_5(5) |
+			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_6(6) |
+			VXGE_HW_RX_QUEUE_PRIORITY_0_RX_Q_NUMBER_7(7),
+			&hldev->mrpcim_reg->rx_queue_priority_0);
+
+	writeq(VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_8(8) |
+			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_9(9) |
+			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_10(10) |
+			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_11(11) |
+			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_12(12) |
+			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_13(13) |
+			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_14(14) |
+			VXGE_HW_RX_QUEUE_PRIORITY_1_RX_Q_NUMBER_15(15),
+			&hldev->mrpcim_reg->rx_queue_priority_1);
+
+	writeq(VXGE_HW_RX_QUEUE_PRIORITY_2_RX_Q_NUMBER_16(16),
+				&hldev->mrpcim_reg->rx_queue_priority_2);
+
+	/* Initialize all the slots as unused */
+	for (i = 0; i < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; i++)
+		wrr_states[i] = -1;
+
+	/* Prepare the Ring service states */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!hldev->config.vp_config[i].min_bandwidth)
+			continue;
+
+		how_often = VXGE_HW_VPATH_BANDWIDTH_MAX /
+				hldev->config.vp_config[i].min_bandwidth;
+
+		if (how_often) {
+			for (j = 0; j < VXGE_HW_WRR_RING_SERVICE_STATES;) {
+				if (wrr_states[j] == -1) {
+					wrr_states[j] = i;
+					/* Make sure each ring is
+					 * serviced atleast once */
+					if (i == j)
+						j += VXGE_HW_MAX_VIRTUAL_PATHS;
+					else
+						j += how_often;
+				} else
+					j++;
+			}
+		}
+	}
+
+	/* Fill the unused slots with 0 */
+	for (j = 0; j < VXGE_HW_WEIGHTED_RR_SERVICE_STATES; j++) {
+		if (wrr_states[j] == -1)
+			wrr_states[j] = 0;
+	}
+
+	for (i = 0, j = 0; i < VXGE_HW_WRR_RING_COUNT; i++) {
+		val64 =  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_0(
+				wrr_states[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_1(
+				wrr_states[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_2(
+				wrr_states[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_3(
+				wrr_states[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_4(
+				wrr_states[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_5(
+				wrr_states[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_6(
+				wrr_states[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_7(
+				wrr_states[j++]);
+
+		writeq(val64, ((&hldev->mrpcim_reg->rx_w_round_robin_0) + i));
+	}
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_device_initialize
+ * Initialize Titan-V hardware.
+ */
+enum vxge_hw_status __vxge_hw_device_initialize(struct __vxge_hw_device *hldev)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	/* Validate the pci-e link width and speed */
+	status = __vxge_hw_verify_pci_e_info(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	vxge_hw_wrr_rebalance(hldev);
+exit:
+	return status;
+}
+
+/**
+ * vxge_hw_device_hw_info_get - Get the hw information
+ * Returns the vpath mask that has the bits set for each vpath allocated
+ * for the driver, FW version information and the first mac addresse for
+ * each vpath
+ */
+enum vxge_hw_status __devinit
+vxge_hw_device_hw_info_get(void __iomem *bar0,
+			   struct vxge_hw_device_hw_info *hw_info)
+{
+	u32 i;
+	u64 val64;
+	struct vxge_hw_toc_reg __iomem *toc;
+	struct vxge_hw_mrpcim_reg __iomem *mrpcim_reg;
+	struct vxge_hw_common_reg __iomem *common_reg;
+	struct vxge_hw_vpath_reg __iomem *vpath_reg;
+	struct vxge_hw_vpmgmt_reg __iomem *vpmgmt_reg;
+	enum vxge_hw_status status;
+
+	memset(hw_info, 0, sizeof(struct vxge_hw_device_hw_info));
+
+	toc = __vxge_hw_device_toc_get(bar0);
+	if (toc == NULL) {
+		status = VXGE_HW_ERR_CRITICAL;
+		goto exit;
+	}
+
+	val64 = readq(&toc->toc_common_pointer);
+	common_reg = (struct vxge_hw_common_reg __iomem *)(bar0 + val64);
+
+	status = __vxge_hw_device_vpath_reset_in_prog_check(
+		(u64 __iomem *)&common_reg->vpath_rst_in_prog);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	hw_info->vpath_mask = readq(&common_reg->vpath_assignments);
+
+	val64 = readq(&common_reg->host_type_assignments);
+
+	hw_info->host_type =
+	   (u32)VXGE_HW_HOST_TYPE_ASSIGNMENTS_GET_HOST_TYPE_ASSIGNMENTS(val64);
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!((hw_info->vpath_mask) & vxge_mBIT(i)))
+			continue;
+
+		val64 = readq(&toc->toc_vpmgmt_pointer[i]);
+
+		vpmgmt_reg = (struct vxge_hw_vpmgmt_reg __iomem *)
+				(bar0 + val64);
+
+		hw_info->func_id = __vxge_hw_vpath_func_id_get(i, vpmgmt_reg);
+		if (__vxge_hw_device_access_rights_get(hw_info->host_type,
+			hw_info->func_id) &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM) {
+
+			val64 = readq(&toc->toc_mrpcim_pointer);
+
+			mrpcim_reg = (struct vxge_hw_mrpcim_reg __iomem *)
+					(bar0 + val64);
+
+			writeq(0, &mrpcim_reg->xgmac_gen_fw_memo_mask);
+			wmb();
+		}
+
+		val64 = readq(&toc->toc_vpath_pointer[i]);
+
+		vpath_reg = (struct vxge_hw_vpath_reg __iomem *)(bar0 + val64);
+
+		hw_info->function_mode =
+			__vxge_hw_vpath_pci_func_mode_get(i, vpath_reg);
+
+		status = __vxge_hw_vpath_fw_ver_get(i, vpath_reg, hw_info);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		status = __vxge_hw_vpath_card_info_get(i, vpath_reg, hw_info);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		break;
+	}
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!((hw_info->vpath_mask) & vxge_mBIT(i)))
+			continue;
+
+		val64 = readq(&toc->toc_vpath_pointer[i]);
+		vpath_reg = (struct vxge_hw_vpath_reg __iomem *)(bar0 + val64);
+
+		status =  __vxge_hw_vpath_addr_get(i, vpath_reg,
+				hw_info->mac_addrs[i],
+				hw_info->mac_addr_masks[i]);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_device_initialize - Initialize Titan device.
+ * Initialize Titan device. Note that all the arguments of this public API
+ * are 'IN', including @hldev. Driver cooperates with
+ * OS to find new Titan device, locate its PCI and memory spaces.
+ *
+ * When done, the driver allocates sizeof(struct __vxge_hw_device) bytes for HW
+ * to enable the latter to perform Titan hardware initialization.
+ */
+enum vxge_hw_status __devinit
+vxge_hw_device_initialize(
+	struct __vxge_hw_device **devh,
+	struct vxge_hw_device_attr *attr,
+	struct vxge_hw_device_config *device_config)
+{
+	u32 i;
+	u32 nblocks = 0;
+	struct __vxge_hw_device *hldev = NULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	status = __vxge_hw_device_config_check(device_config);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	hldev = (struct __vxge_hw_device *)
+			vmalloc(sizeof(struct __vxge_hw_device));
+	if (hldev == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	memset(hldev, 0, sizeof(struct __vxge_hw_device));
+	hldev->magic = VXGE_HW_DEVICE_MAGIC;
+
+	vxge_hw_device_debug_set(hldev, VXGE_ERR, VXGE_COMPONENT_ALL);
+
+	/* apply config */
+	memcpy(&hldev->config, device_config,
+		sizeof(struct vxge_hw_device_config));
+
+	hldev->bar0 = attr->bar0;
+	hldev->bar1 = attr->bar1;
+	hldev->bar2 = attr->bar2;
+	hldev->pdev = attr->pdev;
+
+	hldev->uld_callbacks.link_up = attr->uld_callbacks.link_up;
+	hldev->uld_callbacks.link_down = attr->uld_callbacks.link_down;
+	hldev->uld_callbacks.crit_err = attr->uld_callbacks.crit_err;
+
+	__vxge_hw_device_pci_e_init(hldev);
+
+	status = __vxge_hw_device_reg_addr_get(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+	__vxge_hw_device_id_get(hldev);
+
+	__vxge_hw_device_host_info_get(hldev);
+
+	/* Incrementing for stats blocks */
+	nblocks++;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!(hldev->vpath_assignments & vxge_mBIT(i)))
+			continue;
+
+		if (device_config->vp_config[i].ring.enable ==
+			VXGE_HW_RING_ENABLE)
+			nblocks += device_config->vp_config[i].ring.ring_blocks;
+
+		if (device_config->vp_config[i].fifo.enable ==
+			VXGE_HW_FIFO_ENABLE)
+			nblocks += device_config->vp_config[i].fifo.fifo_blocks;
+		nblocks++;
+	}
+
+	if (__vxge_hw_blockpool_create(hldev,
+		&hldev->block_pool,
+		device_config->dma_blockpool_initial + nblocks,
+		device_config->dma_blockpool_max + nblocks) != VXGE_HW_OK) {
+
+		vxge_hw_device_terminate(hldev);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	status = __vxge_hw_device_initialize(hldev);
+
+	if (status != VXGE_HW_OK) {
+		vxge_hw_device_terminate(hldev);
+		goto exit;
+	}
+
+	*devh = hldev;
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_device_terminate - Terminate Titan device.
+ * Terminate HW device.
+ */
+void
+vxge_hw_device_terminate(struct __vxge_hw_device *hldev)
+{
+	vxge_assert(hldev->magic == VXGE_HW_DEVICE_MAGIC);
+
+	hldev->magic = VXGE_HW_DEVICE_DEAD;
+	__vxge_hw_blockpool_destroy(&hldev->block_pool);
+	vfree(hldev);
+}
+
+/*
+ * vxge_hw_device_stats_get - Get the device hw statistics.
+ * Returns the vpath h/w stats for the device.
+ */
+enum vxge_hw_status
+vxge_hw_device_stats_get(struct __vxge_hw_device *hldev,
+			struct vxge_hw_device_stats_hw_info *hw_stats)
+{
+	u32 i;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!(hldev->vpaths_deployed & vxge_mBIT(i)) ||
+			(hldev->virtual_paths[i].vp_open ==
+				VXGE_HW_VP_NOT_OPEN))
+			continue;
+
+		memcpy(hldev->virtual_paths[i].hw_stats_sav,
+				hldev->virtual_paths[i].hw_stats,
+				sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+		status = __vxge_hw_vpath_stats_get(
+			&hldev->virtual_paths[i],
+			hldev->virtual_paths[i].hw_stats);
+	}
+
+	memcpy(hw_stats, &hldev->stats.hw_dev_info_stats,
+			sizeof(struct vxge_hw_device_stats_hw_info));
+
+	return status;
+}
+
+/*
+ * vxge_hw_driver_stats_get - Get the device sw statistics.
+ * Returns the vpath s/w stats for the device.
+ */
+enum vxge_hw_status vxge_hw_driver_stats_get(
+			struct __vxge_hw_device *hldev,
+			struct vxge_hw_device_stats_sw_info *sw_stats)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	memcpy(sw_stats, &hldev->stats.sw_dev_info_stats,
+		sizeof(struct vxge_hw_device_stats_sw_info));
+
+	return status;
+}
+
+/*
+ * vxge_hw_mrpcim_stats_access - Access the statistics from the given location
+ *                           and offset and perform an operation
+ * Get the statistics from the given location and offset.
+ */
+enum vxge_hw_status
+vxge_hw_mrpcim_stats_access(struct __vxge_hw_device *hldev,
+			    u32 operation, u32 location, u32 offset, u64 *stat)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	status = __vxge_hw_device_is_privilaged(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = VXGE_HW_XMAC_STATS_SYS_CMD_OP(operation) |
+		VXGE_HW_XMAC_STATS_SYS_CMD_STROBE |
+		VXGE_HW_XMAC_STATS_SYS_CMD_LOC_SEL(location) |
+		VXGE_HW_XMAC_STATS_SYS_CMD_OFFSET_SEL(offset);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&hldev->mrpcim_reg->xmac_stats_sys_cmd,
+				VXGE_HW_XMAC_STATS_SYS_CMD_STROBE,
+				hldev->config.device_poll_millis);
+
+	if ((status == VXGE_HW_OK) && (operation == VXGE_HW_STATS_OP_READ))
+		*stat = readq(&hldev->mrpcim_reg->xmac_stats_sys_data);
+	else
+		*stat = 0;
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_device_xmac_aggr_stats_get - Get the Statistics on aggregate port
+ * Get the Statistics on aggregate port
+ */
+enum vxge_hw_status
+vxge_hw_device_xmac_aggr_stats_get(struct __vxge_hw_device *hldev, u32 port,
+				   struct vxge_hw_xmac_aggr_stats *aggr_stats)
+{
+	u64 *val64;
+	int i;
+	u32 offset = VXGE_HW_STATS_AGGRn_OFFSET;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	val64 = (u64 *)aggr_stats;
+
+	status = __vxge_hw_device_is_privilaged(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_aggr_stats) / 8; i++) {
+		status = vxge_hw_mrpcim_stats_access(hldev,
+					VXGE_HW_STATS_OP_READ,
+					VXGE_HW_STATS_LOC_AGGR,
+					((offset + (104 * port)) >> 3), val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		offset += 8;
+		val64++;
+	}
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_device_xmac_port_stats_get - Get the Statistics on a port
+ * Get the Statistics on port
+ */
+enum vxge_hw_status
+vxge_hw_device_xmac_port_stats_get(struct __vxge_hw_device *hldev, u32 port,
+				   struct vxge_hw_xmac_port_stats *port_stats)
+{
+	u64 *val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	int i;
+	u32 offset = 0x0;
+	val64 = (u64 *) port_stats;
+
+	status = __vxge_hw_device_is_privilaged(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_port_stats) / 8; i++) {
+		status = vxge_hw_mrpcim_stats_access(hldev,
+					VXGE_HW_STATS_OP_READ,
+					VXGE_HW_STATS_LOC_AGGR,
+					((offset + (608 * port)) >> 3), val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		offset += 8;
+		val64++;
+	}
+
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_device_xmac_stats_get - Get the XMAC Statistics
+ * Get the XMAC Statistics
+ */
+enum vxge_hw_status
+vxge_hw_device_xmac_stats_get(struct __vxge_hw_device *hldev,
+			      struct vxge_hw_xmac_stats *xmac_stats)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u32 i;
+
+	status = vxge_hw_device_xmac_aggr_stats_get(hldev,
+					0, &xmac_stats->aggr_stats[0]);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = vxge_hw_device_xmac_aggr_stats_get(hldev,
+				1, &xmac_stats->aggr_stats[1]);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	for (i = 0; i <= VXGE_HW_MAC_MAX_MAC_PORT_ID; i++) {
+
+		status = vxge_hw_device_xmac_port_stats_get(hldev,
+					i, &xmac_stats->port_stats[i]);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!(hldev->vpaths_deployed & vxge_mBIT(i)))
+			continue;
+
+		status = __vxge_hw_vpath_xmac_tx_stats_get(
+					&hldev->virtual_paths[i],
+					&xmac_stats->vpath_tx_stats[i]);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		status = __vxge_hw_vpath_xmac_rx_stats_get(
+					&hldev->virtual_paths[i],
+					&xmac_stats->vpath_rx_stats[i]);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_device_debug_set - Set the debug module, level and timestamp
+ * This routine is used to dynamically change the debug output
+ */
+void vxge_hw_device_debug_set(struct __vxge_hw_device *hldev,
+			      enum vxge_debug_level level, u32 mask)
+{
+	if (hldev == NULL)
+		return;
+
+#if defined(VXGE_DEBUG_TRACE_MASK) || \
+	defined(VXGE_DEBUG_ERR_MASK)
+	hldev->debug_module_mask = mask;
+	hldev->debug_level = level;
+#endif
+
+#if defined(VXGE_DEBUG_ERR_MASK)
+	hldev->level_err = level & VXGE_ERR;
+#endif
+
+#if defined(VXGE_DEBUG_TRACE_MASK)
+	hldev->level_trace = level & VXGE_TRACE;
+#endif
+}
+
+/*
+ * vxge_hw_device_error_level_get - Get the error level
+ * This routine returns the current error level set
+ */
+u32 vxge_hw_device_error_level_get(struct __vxge_hw_device *hldev)
+{
+#if defined(VXGE_DEBUG_ERR_MASK)
+	if (hldev == NULL)
+		return VXGE_ERR;
+	else
+		return hldev->level_err;
+#else
+	return 0;
+#endif
+}
+
+/*
+ * vxge_hw_device_trace_level_get - Get the trace level
+ * This routine returns the current trace level set
+ */
+u32 vxge_hw_device_trace_level_get(struct __vxge_hw_device *hldev)
+{
+#if defined(VXGE_DEBUG_TRACE_MASK)
+	if (hldev == NULL)
+		return VXGE_TRACE;
+	else
+		return hldev->level_trace;
+#else
+	return 0;
+#endif
+}
+/*
+ * vxge_hw_device_debug_mask_get - Get the debug mask
+ * This routine returns the current debug mask set
+ */
+u32 vxge_hw_device_debug_mask_get(struct __vxge_hw_device *hldev)
+{
+#if defined(VXGE_DEBUG_TRACE_MASK) || defined(VXGE_DEBUG_ERR_MASK)
+	if (hldev == NULL)
+		return 0;
+	return hldev->debug_module_mask;
+#else
+	return 0;
+#endif
+}
+
+/*
+ * vxge_hw_getpause_data -Pause frame frame generation and reception.
+ * Returns the Pause frame generation and reception capability of the NIC.
+ */
+enum vxge_hw_status vxge_hw_device_getpause_data(struct __vxge_hw_device *hldev,
+						 u32 port, u32 *tx, u32 *rx)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC)) {
+		status = VXGE_HW_ERR_INVALID_DEVICE;
+		goto exit;
+	}
+
+	if (port > VXGE_HW_MAC_MAX_MAC_PORT_ID) {
+		status = VXGE_HW_ERR_INVALID_PORT;
+		goto exit;
+	}
+
+	if (!(hldev->access_rights & VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+		status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+		goto exit;
+	}
+
+	val64 = readq(&hldev->mrpcim_reg->rxmac_pause_cfg_port[port]);
+	if (val64 & VXGE_HW_RXMAC_PAUSE_CFG_PORT_GEN_EN)
+		*tx = 1;
+	if (val64 & VXGE_HW_RXMAC_PAUSE_CFG_PORT_RCV_EN)
+		*rx = 1;
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_device_setpause_data -  set/reset pause frame generation.
+ * It can be used to set or reset Pause frame generation or reception
+ * support of the NIC.
+ */
+
+enum vxge_hw_status vxge_hw_device_setpause_data(struct __vxge_hw_device *hldev,
+						 u32 port, u32 tx, u32 rx)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC)) {
+		status = VXGE_HW_ERR_INVALID_DEVICE;
+		goto exit;
+	}
+
+	if (port > VXGE_HW_MAC_MAX_MAC_PORT_ID) {
+		status = VXGE_HW_ERR_INVALID_PORT;
+		goto exit;
+	}
+
+	status = __vxge_hw_device_is_privilaged(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&hldev->mrpcim_reg->rxmac_pause_cfg_port[port]);
+	if (tx)
+		val64 |= VXGE_HW_RXMAC_PAUSE_CFG_PORT_GEN_EN;
+	else
+		val64 &= ~VXGE_HW_RXMAC_PAUSE_CFG_PORT_GEN_EN;
+	if (rx)
+		val64 |= VXGE_HW_RXMAC_PAUSE_CFG_PORT_RCV_EN;
+	else
+		val64 &= ~VXGE_HW_RXMAC_PAUSE_CFG_PORT_RCV_EN;
+
+	writeq(val64, &hldev->mrpcim_reg->rxmac_pause_cfg_port[port]);
+exit:
+	return status;
+}
+
+u16 vxge_hw_device_link_width_get(struct __vxge_hw_device *hldev)
+{
+	int link_width, exp_cap;
+	u16 lnk;
+
+	exp_cap = pci_find_capability(hldev->pdev, PCI_CAP_ID_EXP);
+	pci_read_config_word(hldev->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
+	link_width = (lnk & VXGE_HW_PCI_EXP_LNKCAP_LNK_WIDTH) >> 4;
+	return link_width;
+}
+
+/*
+ * __vxge_hw_ring_block_memblock_idx - Return the memblock index
+ * This function returns the index of memory block
+ */
+static inline u32
+__vxge_hw_ring_block_memblock_idx(u8 *block)
+{
+	return (u32)*((u64 *)(block + VXGE_HW_RING_MEMBLOCK_IDX_OFFSET));
+}
+
+/*
+ * __vxge_hw_ring_block_memblock_idx_set - Sets the memblock index
+ * This function sets index to a memory block
+ */
+static inline void
+__vxge_hw_ring_block_memblock_idx_set(u8 *block, u32 memblock_idx)
+{
+	*((u64 *)(block + VXGE_HW_RING_MEMBLOCK_IDX_OFFSET)) = memblock_idx;
+}
+
+/*
+ * __vxge_hw_ring_block_next_pointer_set - Sets the next block pointer
+ * in RxD block
+ * Sets the next block pointer in RxD block
+ */
+static inline void
+__vxge_hw_ring_block_next_pointer_set(u8 *block, dma_addr_t dma_next)
+{
+	*((u64 *)(block + VXGE_HW_RING_NEXT_BLOCK_POINTER_OFFSET)) = dma_next;
+}
+
+/*
+ * __vxge_hw_ring_first_block_address_get - Returns the dma address of the
+ *             first block
+ * Returns the dma address of the first RxD block
+ */
+u64 __vxge_hw_ring_first_block_address_get(struct __vxge_hw_ring *ring)
+{
+	struct vxge_hw_mempool_dma *dma_object;
+
+	dma_object = ring->mempool->memblocks_dma_arr;
+	vxge_assert(dma_object != NULL);
+
+	return dma_object->addr;
+}
+
+/*
+ * __vxge_hw_ring_item_dma_addr - Return the dma address of an item
+ * This function returns the dma address of a given item
+ */
+static dma_addr_t __vxge_hw_ring_item_dma_addr(struct vxge_hw_mempool *mempoolh,
+					       void *item)
+{
+	u32 memblock_idx;
+	void *memblock;
+	struct vxge_hw_mempool_dma *memblock_dma_object;
+	ptrdiff_t dma_item_offset;
+
+	/* get owner memblock index */
+	memblock_idx = __vxge_hw_ring_block_memblock_idx(item);
+
+	/* get owner memblock by memblock index */
+	memblock = mempoolh->memblocks_arr[memblock_idx];
+
+	/* get memblock DMA object by memblock index */
+	memblock_dma_object = mempoolh->memblocks_dma_arr + memblock_idx;
+
+	/* calculate offset in the memblock of this item */
+	dma_item_offset = (u8 *)item - (u8 *)memblock;
+
+	return memblock_dma_object->addr + dma_item_offset;
+}
+
+/*
+ * __vxge_hw_ring_rxdblock_link - Link the RxD blocks
+ * This function returns the dma address of a given item
+ */
+static void __vxge_hw_ring_rxdblock_link(struct vxge_hw_mempool *mempoolh,
+					 struct __vxge_hw_ring *ring, u32 from,
+					 u32 to)
+{
+	u8 *to_item , *from_item;
+	dma_addr_t to_dma;
+
+	/* get "from" RxD block */
+	from_item = mempoolh->items_arr[from];
+	vxge_assert(from_item);
+
+	/* get "to" RxD block */
+	to_item = mempoolh->items_arr[to];
+	vxge_assert(to_item);
+
+	/* return address of the beginning of previous RxD block */
+	to_dma = __vxge_hw_ring_item_dma_addr(mempoolh, to_item);
+
+	/* set next pointer for this RxD block to point on
+	 * previous item's DMA start address */
+	__vxge_hw_ring_block_next_pointer_set(from_item, to_dma);
+}
+
+/*
+ * __vxge_hw_ring_mempool_item_alloc - Allocate List blocks for RxD
+ * block callback
+ * This function is callback passed to __vxge_hw_mempool_create to create memory
+ * pool for RxD block
+ */
+static void
+__vxge_hw_ring_mempool_item_alloc(struct vxge_hw_mempool *mempoolh,
+				  u32 memblock_index,
+				  struct vxge_hw_mempool_dma *dma_object,
+				  u32 index, u32 is_last)
+{
+	u32 i;
+	void *item = mempoolh->items_arr[index];
+	struct __vxge_hw_ring *ring =
+		(struct __vxge_hw_ring *)mempoolh->userdata;
+
+	/* format rxds array */
+	for (i = 0; i < ring->rxds_per_block; i++) {
+		void *rxdblock_priv;
+		void *uld_priv;
+		struct vxge_hw_ring_rxd_1 *rxdp;
+
+		u32 reserve_index = ring->channel.reserve_ptr -
+				(index * ring->rxds_per_block + i + 1);
+		u32 memblock_item_idx;
+
+		ring->channel.reserve_arr[reserve_index] = ((u8 *)item) +
+						i * ring->rxd_size;
+
+		/* Note: memblock_item_idx is index of the item within
+		 *       the memblock. For instance, in case of three RxD-blocks
+		 *       per memblock this value can be 0, 1 or 2. */
+		rxdblock_priv = __vxge_hw_mempool_item_priv(mempoolh,
+					memblock_index, item,
+					&memblock_item_idx);
+
+		rxdp = (struct vxge_hw_ring_rxd_1 *)
+				ring->channel.reserve_arr[reserve_index];
+
+		uld_priv = ((u8 *)rxdblock_priv + ring->rxd_priv_size * i);
+
+		/* pre-format Host_Control */
+		rxdp->host_control = (u64)(size_t)uld_priv;
+	}
+
+	__vxge_hw_ring_block_memblock_idx_set(item, memblock_index);
+
+	if (is_last) {
+		/* link last one with first one */
+		__vxge_hw_ring_rxdblock_link(mempoolh, ring, index, 0);
+	}
+
+	if (index > 0) {
+		/* link this RxD block with previous one */
+		__vxge_hw_ring_rxdblock_link(mempoolh, ring, index - 1, index);
+	}
+
+	return;
+}
+
+/*
+ * __vxge_hw_ring_initial_replenish - Initial replenish of RxDs
+ * This function replenishes the RxDs from reserve array to work array
+ */
+enum vxge_hw_status
+vxge_hw_ring_replenish(struct __vxge_hw_ring *ring, u16 min_flag)
+{
+	void *rxd;
+	int i = 0;
+	struct __vxge_hw_channel *channel;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	channel = &ring->channel;
+
+	while (vxge_hw_channel_dtr_count(channel) > 0) {
+
+		status = vxge_hw_ring_rxd_reserve(ring, &rxd);
+
+		vxge_assert(status == VXGE_HW_OK);
+
+		if (ring->rxd_init) {
+			status = ring->rxd_init(rxd, channel->userdata);
+			if (status != VXGE_HW_OK) {
+				vxge_hw_ring_rxd_free(ring, rxd);
+				goto exit;
+			}
+		}
+
+		vxge_hw_ring_rxd_post(ring, rxd);
+		if (min_flag) {
+			i++;
+			if (i == VXGE_HW_RING_MIN_BUFF_ALLOCATION)
+				break;
+		}
+	}
+	status = VXGE_HW_OK;
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_ring_create - Create a Ring
+ * This function creates Ring and initializes it.
+ *
+ */
+enum vxge_hw_status
+__vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
+		      struct vxge_hw_ring_attr *attr)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_ring *ring;
+	u32 ring_length;
+	struct vxge_hw_ring_config *config;
+	struct __vxge_hw_device *hldev;
+	u32 vp_id;
+	struct vxge_hw_mempool_cbs ring_mp_callback;
+
+	if ((vp == NULL) || (attr == NULL)) {
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	hldev = vp->vpath->hldev;
+	vp_id = vp->vpath->vp_id;
+
+	config = &hldev->config.vp_config[vp_id].ring;
+
+	ring_length = config->ring_blocks *
+			vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+
+	ring = (struct __vxge_hw_ring *)__vxge_hw_channel_allocate(vp,
+						VXGE_HW_CHANNEL_TYPE_RING,
+						ring_length,
+						attr->per_rxd_space,
+						attr->userdata);
+
+	if (ring == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	vp->vpath->ringh = ring;
+	ring->vp_id = vp_id;
+	ring->vp_reg = vp->vpath->vp_reg;
+	ring->common_reg = hldev->common_reg;
+	ring->stats = &vp->vpath->sw_stats->ring_stats;
+	ring->config = config;
+	ring->callback = attr->callback;
+	ring->rxd_init = attr->rxd_init;
+	ring->rxd_term = attr->rxd_term;
+	ring->buffer_mode = config->buffer_mode;
+	ring->rxds_limit = config->rxds_limit;
+
+	ring->rxd_size = vxge_hw_ring_rxd_size_get(config->buffer_mode);
+	ring->rxd_priv_size =
+		sizeof(struct __vxge_hw_ring_rxd_priv) + attr->per_rxd_space;
+	ring->per_rxd_space = attr->per_rxd_space;
+
+	ring->rxd_priv_size =
+		((ring->rxd_priv_size + VXGE_CACHE_LINE_SIZE - 1) /
+		VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
+
+	/* how many RxDs can fit into one block. Depends on configured
+	 * buffer_mode. */
+	ring->rxds_per_block =
+		vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+
+	/* calculate actual RxD block private size */
+	ring->rxdblock_priv_size = ring->rxd_priv_size * ring->rxds_per_block;
+	ring_mp_callback.item_func_alloc = __vxge_hw_ring_mempool_item_alloc;
+	ring->mempool = __vxge_hw_mempool_create(hldev,
+				VXGE_HW_BLOCK_SIZE,
+				VXGE_HW_BLOCK_SIZE,
+				ring->rxdblock_priv_size,
+				ring->config->ring_blocks,
+				ring->config->ring_blocks,
+				&ring_mp_callback,
+				ring);
+
+	if (ring->mempool == NULL) {
+		__vxge_hw_ring_delete(vp);
+		return VXGE_HW_ERR_OUT_OF_MEMORY;
+	}
+
+	status = __vxge_hw_channel_initialize(&ring->channel);
+	if (status != VXGE_HW_OK) {
+		__vxge_hw_ring_delete(vp);
+		goto exit;
+	}
+
+	/* Note:
+	 * Specifying rxd_init callback means two things:
+	 * 1) rxds need to be initialized by driver at channel-open time;
+	 * 2) rxds need to be posted at channel-open time
+	 *    (that's what the initial_replenish() below does)
+	 * Currently we don't have a case when the 1) is done without the 2).
+	 */
+	if (ring->rxd_init) {
+		status = vxge_hw_ring_replenish(ring, 1);
+		if (status != VXGE_HW_OK) {
+			__vxge_hw_ring_delete(vp);
+			goto exit;
+		}
+	}
+
+	/* initial replenish will increment the counter in its post() routine,
+	 * we have to reset it */
+	ring->stats->common_stats.usage_cnt = 0;
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_ring_abort - Returns the RxD
+ * This function terminates the RxDs of ring
+ */
+enum vxge_hw_status __vxge_hw_ring_abort(struct __vxge_hw_ring *ring)
+{
+	void *rxdh;
+	struct __vxge_hw_channel *channel;
+
+	channel = &ring->channel;
+
+	for (;;) {
+		vxge_hw_channel_dtr_try_complete(channel, &rxdh);
+
+		if (rxdh == NULL)
+			break;
+
+		vxge_hw_channel_dtr_complete(channel);
+
+		if (ring->rxd_term)
+			ring->rxd_term(rxdh, VXGE_HW_RXD_STATE_POSTED,
+				channel->userdata);
+
+		vxge_hw_channel_dtr_free(channel, rxdh);
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_ring_reset - Resets the ring
+ * This function resets the ring during vpath reset operation
+ */
+enum vxge_hw_status __vxge_hw_ring_reset(struct __vxge_hw_ring *ring)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_channel *channel;
+
+	channel = &ring->channel;
+
+	__vxge_hw_ring_abort(ring);
+
+	status = __vxge_hw_channel_reset(channel);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	if (ring->rxd_init) {
+		status = vxge_hw_ring_replenish(ring, 1);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_ring_delete - Removes the ring
+ * This function freeup the memory pool and removes the ring
+ */
+enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp)
+{
+	struct __vxge_hw_ring *ring = vp->vpath->ringh;
+
+	__vxge_hw_ring_abort(ring);
+
+	if (ring->mempool)
+		__vxge_hw_mempool_destroy(ring->mempool);
+
+	vp->vpath->ringh = NULL;
+	__vxge_hw_channel_free(&ring->channel);
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_mempool_grow
+ * Will resize mempool up to %num_allocate value.
+ */
+enum vxge_hw_status
+__vxge_hw_mempool_grow(struct vxge_hw_mempool *mempool, u32 num_allocate,
+		       u32 *num_allocated)
+{
+	u32 i, first_time = mempool->memblocks_allocated == 0 ? 1 : 0;
+	u32 n_items = mempool->items_per_memblock;
+	u32 start_block_idx = mempool->memblocks_allocated;
+	u32 end_block_idx = mempool->memblocks_allocated + num_allocate;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	*num_allocated = 0;
+
+	if (end_block_idx > mempool->memblocks_max) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	for (i = start_block_idx; i < end_block_idx; i++) {
+		u32 j;
+		u32 is_last = ((end_block_idx - 1) == i);
+		struct vxge_hw_mempool_dma *dma_object =
+			mempool->memblocks_dma_arr + i;
+		void *the_memblock;
+
+		/* allocate memblock's private part. Each DMA memblock
+		 * has a space allocated for item's private usage upon
+		 * mempool's user request. Each time mempool grows, it will
+		 * allocate new memblock and its private part at once.
+		 * This helps to minimize memory usage a lot. */
+		mempool->memblocks_priv_arr[i] =
+				vmalloc(mempool->items_priv_size * n_items);
+		if (mempool->memblocks_priv_arr[i] == NULL) {
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+		memset(mempool->memblocks_priv_arr[i], 0,
+			     mempool->items_priv_size * n_items);
+
+		/* allocate DMA-capable memblock */
+		mempool->memblocks_arr[i] =
+			__vxge_hw_blockpool_malloc(mempool->devh,
+				mempool->memblock_size, dma_object);
+		if (mempool->memblocks_arr[i] == NULL) {
+			vfree(mempool->memblocks_priv_arr[i]);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+		(*num_allocated)++;
+		mempool->memblocks_allocated++;
+
+		memset(mempool->memblocks_arr[i], 0, mempool->memblock_size);
+
+		the_memblock = mempool->memblocks_arr[i];
+
+		/* fill the items hash array */
+		for (j = 0; j < n_items; j++) {
+			u32 index = i * n_items + j;
+
+			if (first_time && index >= mempool->items_initial)
+				break;
+
+			mempool->items_arr[index] =
+				((char *)the_memblock + j*mempool->item_size);
+
+			/* let caller to do more job on each item */
+			if (mempool->item_func_alloc != NULL)
+				mempool->item_func_alloc(mempool, i,
+					dma_object, index, is_last);
+
+			mempool->items_current = index + 1;
+		}
+
+		if (first_time && mempool->items_current ==
+					mempool->items_initial)
+			break;
+	}
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_mempool_create
+ * This function will create memory pool object. Pool may grow but will
+ * never shrink. Pool consists of number of dynamically allocated blocks
+ * with size enough to hold %items_initial number of items. Memory is
+ * DMA-able but client must map/unmap before interoperating with the device.
+ */
+struct vxge_hw_mempool*
+__vxge_hw_mempool_create(
+	struct __vxge_hw_device *devh,
+	u32 memblock_size,
+	u32 item_size,
+	u32 items_priv_size,
+	u32 items_initial,
+	u32 items_max,
+	struct vxge_hw_mempool_cbs *mp_callback,
+	void *userdata)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u32 memblocks_to_allocate;
+	struct vxge_hw_mempool *mempool = NULL;
+	u32 allocated;
+
+	if (memblock_size < item_size) {
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	mempool = (struct vxge_hw_mempool *)
+			vmalloc(sizeof(struct vxge_hw_mempool));
+	if (mempool == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+	memset(mempool, 0, sizeof(struct vxge_hw_mempool));
+
+	mempool->devh			= devh;
+	mempool->memblock_size		= memblock_size;
+	mempool->items_max		= items_max;
+	mempool->items_initial		= items_initial;
+	mempool->item_size		= item_size;
+	mempool->items_priv_size	= items_priv_size;
+	mempool->item_func_alloc	= mp_callback->item_func_alloc;
+	mempool->userdata		= userdata;
+
+	mempool->memblocks_allocated = 0;
+
+	mempool->items_per_memblock = memblock_size / item_size;
+
+	mempool->memblocks_max = (items_max + mempool->items_per_memblock - 1) /
+					mempool->items_per_memblock;
+
+	/* allocate array of memblocks */
+	mempool->memblocks_arr =
+		(void **) vmalloc(sizeof(void *) * mempool->memblocks_max);
+	if (mempool->memblocks_arr == NULL) {
+		__vxge_hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+	memset(mempool->memblocks_arr, 0,
+		sizeof(void *) * mempool->memblocks_max);
+
+	/* allocate array of private parts of items per memblocks */
+	mempool->memblocks_priv_arr =
+		(void **) vmalloc(sizeof(void *) * mempool->memblocks_max);
+	if (mempool->memblocks_priv_arr == NULL) {
+		__vxge_hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+	memset(mempool->memblocks_priv_arr, 0,
+		    sizeof(void *) * mempool->memblocks_max);
+
+	/* allocate array of memblocks DMA objects */
+	mempool->memblocks_dma_arr = (struct vxge_hw_mempool_dma *)
+		vmalloc(sizeof(struct vxge_hw_mempool_dma) *
+			mempool->memblocks_max);
+
+	if (mempool->memblocks_dma_arr == NULL) {
+		__vxge_hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+	memset(mempool->memblocks_dma_arr, 0,
+			sizeof(struct vxge_hw_mempool_dma) *
+			mempool->memblocks_max);
+
+	/* allocate hash array of items */
+	mempool->items_arr =
+		(void **) vmalloc(sizeof(void *) * mempool->items_max);
+	if (mempool->items_arr == NULL) {
+		__vxge_hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+	memset(mempool->items_arr, 0, sizeof(void *) * mempool->items_max);
+
+	/* calculate initial number of memblocks */
+	memblocks_to_allocate = (mempool->items_initial +
+				 mempool->items_per_memblock - 1) /
+						mempool->items_per_memblock;
+
+	/* pre-allocate the mempool */
+	status = __vxge_hw_mempool_grow(mempool, memblocks_to_allocate,
+					&allocated);
+	if (status != VXGE_HW_OK) {
+		__vxge_hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+
+exit:
+	return mempool;
+}
+
+/*
+ * vxge_hw_mempool_destroy
+ */
+void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
+{
+	u32 i, j;
+	struct __vxge_hw_device *devh = mempool->devh;
+
+	for (i = 0; i < mempool->memblocks_allocated; i++) {
+		struct vxge_hw_mempool_dma *dma_object;
+
+		vxge_assert(mempool->memblocks_arr[i]);
+		vxge_assert(mempool->memblocks_dma_arr + i);
+
+		dma_object = mempool->memblocks_dma_arr + i;
+
+		for (j = 0; j < mempool->items_per_memblock; j++) {
+			u32 index = i * mempool->items_per_memblock + j;
+
+			/* to skip last partially filled(if any) memblock */
+			if (index >= mempool->items_current)
+				break;
+		}
+
+		vfree(mempool->memblocks_priv_arr[i]);
+
+		__vxge_hw_blockpool_free(devh, mempool->memblocks_arr[i],
+				mempool->memblock_size, dma_object);
+	}
+
+	if (mempool->items_arr)
+		vfree(mempool->items_arr);
+
+	if (mempool->memblocks_dma_arr)
+		vfree(mempool->memblocks_dma_arr);
+
+	if (mempool->memblocks_priv_arr)
+		vfree(mempool->memblocks_priv_arr);
+
+	if (mempool->memblocks_arr)
+		vfree(mempool->memblocks_arr);
+
+	vfree(mempool);
+}
+
+/*
+ * __vxge_hw_device_fifo_config_check - Check fifo configuration.
+ * Check the fifo configuration
+ */
+enum vxge_hw_status
+__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config)
+{
+	if ((fifo_config->fifo_blocks < VXGE_HW_MIN_FIFO_BLOCKS) ||
+	     (fifo_config->fifo_blocks > VXGE_HW_MAX_FIFO_BLOCKS))
+		return VXGE_HW_BADCFG_FIFO_BLOCKS;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_vpath_config_check - Check vpath configuration.
+ * Check the vpath configuration
+ */
+enum vxge_hw_status
+__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
+{
+	enum vxge_hw_status status;
+
+	if ((vp_config->min_bandwidth < VXGE_HW_VPATH_BANDWIDTH_MIN) ||
+		(vp_config->min_bandwidth >
+					VXGE_HW_VPATH_BANDWIDTH_MAX))
+		return VXGE_HW_BADCFG_VPATH_MIN_BANDWIDTH;
+
+	status = __vxge_hw_device_fifo_config_check(&vp_config->fifo);
+	if (status != VXGE_HW_OK)
+		return status;
+
+	if ((vp_config->mtu != VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU) &&
+		((vp_config->mtu < VXGE_HW_VPATH_MIN_INITIAL_MTU) ||
+		(vp_config->mtu > VXGE_HW_VPATH_MAX_INITIAL_MTU)))
+		return VXGE_HW_BADCFG_VPATH_MTU;
+
+	if ((vp_config->rpa_strip_vlan_tag !=
+		VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT) &&
+		(vp_config->rpa_strip_vlan_tag !=
+		VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE) &&
+		(vp_config->rpa_strip_vlan_tag !=
+		VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_DISABLE))
+		return VXGE_HW_BADCFG_VPATH_RPA_STRIP_VLAN_TAG;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_config_check - Check device configuration.
+ * Check the device configuration
+ */
+enum vxge_hw_status
+__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
+{
+	u32 i;
+	enum vxge_hw_status status;
+
+	if ((new_config->intr_mode != VXGE_HW_INTR_MODE_IRQLINE) &&
+	   (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX) &&
+	   (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) &&
+	   (new_config->intr_mode != VXGE_HW_INTR_MODE_DEF))
+		return VXGE_HW_BADCFG_INTR_MODE;
+
+	if ((new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE) &&
+	   (new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE))
+		return VXGE_HW_BADCFG_RTS_MAC_EN;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		status = __vxge_hw_device_vpath_config_check(
+				&new_config->vp_config[i]);
+		if (status != VXGE_HW_OK)
+			return status;
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * vxge_hw_device_config_default_get - Initialize device config with defaults.
+ * Initialize Titan device config with default values.
+ */
+enum vxge_hw_status __devinit
+vxge_hw_device_config_default_get(struct vxge_hw_device_config *device_config)
+{
+	u32 i;
+
+	device_config->dma_blockpool_initial =
+					VXGE_HW_INITIAL_DMA_BLOCK_POOL_SIZE;
+	device_config->dma_blockpool_max = VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE;
+	device_config->intr_mode = VXGE_HW_INTR_MODE_DEF;
+	device_config->rth_en = VXGE_HW_RTH_DEFAULT;
+	device_config->rth_it_type = VXGE_HW_RTH_IT_TYPE_DEFAULT;
+	device_config->device_poll_millis =  VXGE_HW_DEF_DEVICE_POLL_MILLIS;
+	device_config->rts_mac_en =  VXGE_HW_RTS_MAC_DEFAULT;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		device_config->vp_config[i].vp_id = i;
+
+		device_config->vp_config[i].min_bandwidth =
+				VXGE_HW_VPATH_BANDWIDTH_DEFAULT;
+
+		device_config->vp_config[i].ring.enable = VXGE_HW_RING_DEFAULT;
+
+		device_config->vp_config[i].ring.ring_blocks =
+				VXGE_HW_DEF_RING_BLOCKS;
+
+		device_config->vp_config[i].ring.buffer_mode =
+				VXGE_HW_RING_RXD_BUFFER_MODE_DEFAULT;
+
+		device_config->vp_config[i].ring.scatter_mode =
+				VXGE_HW_RING_SCATTER_MODE_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].ring.rxds_limit =
+				VXGE_HW_DEF_RING_RXDS_LIMIT;
+
+		device_config->vp_config[i].fifo.enable = VXGE_HW_FIFO_ENABLE;
+
+		device_config->vp_config[i].fifo.fifo_blocks =
+				VXGE_HW_MIN_FIFO_BLOCKS;
+
+		device_config->vp_config[i].fifo.max_frags =
+				VXGE_HW_MAX_FIFO_FRAGS;
+
+		device_config->vp_config[i].fifo.memblock_size =
+				VXGE_HW_DEF_FIFO_MEMBLOCK_SIZE;
+
+		device_config->vp_config[i].fifo.alignment_size =
+				VXGE_HW_DEF_FIFO_ALIGNMENT_SIZE;
+
+		device_config->vp_config[i].fifo.intr =
+				VXGE_HW_FIFO_QUEUE_INTR_DEFAULT;
+
+		device_config->vp_config[i].fifo.no_snoop_bits =
+				VXGE_HW_FIFO_NO_SNOOP_DEFAULT;
+		device_config->vp_config[i].tti.intr_enable =
+				VXGE_HW_TIM_INTR_DEFAULT;
+
+		device_config->vp_config[i].tti.btimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.timer_ac_en =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.timer_ci_en =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.timer_ri_en =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.rtimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.util_sel =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.ltimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.urange_a =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.uec_a =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.urange_b =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.uec_b =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.urange_c =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.uec_c =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.uec_d =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.intr_enable =
+				VXGE_HW_TIM_INTR_DEFAULT;
+
+		device_config->vp_config[i].rti.btimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.timer_ac_en =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.timer_ci_en =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.timer_ri_en =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.rtimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.util_sel =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.ltimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.urange_a =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.uec_a =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.urange_b =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.uec_b =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.urange_c =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.uec_c =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.uec_d =
+				VXGE_HW_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].mtu =
+				VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU;
+
+		device_config->vp_config[i].rpa_strip_vlan_tag =
+			VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT;
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * _hw_legacy_swapper_set - Set the swapper bits for the legacy secion.
+ * Set the swapper bits appropriately for the lagacy section.
+ */
+enum vxge_hw_status
+__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	val64 = readq(&legacy_reg->toc_swapper_fb);
+
+	wmb();
+
+	switch (val64) {
+
+	case VXGE_HW_SWAPPER_INITIAL_VALUE:
+		return status;
+
+	case VXGE_HW_SWAPPER_BYTE_SWAPPED_BIT_FLIPPED:
+		writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
+			&legacy_reg->pifm_rd_swap_en);
+		writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
+			&legacy_reg->pifm_rd_flip_en);
+		writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
+			&legacy_reg->pifm_wr_swap_en);
+		writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
+			&legacy_reg->pifm_wr_flip_en);
+		break;
+
+	case VXGE_HW_SWAPPER_BYTE_SWAPPED:
+		writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
+			&legacy_reg->pifm_rd_swap_en);
+		writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
+			&legacy_reg->pifm_wr_swap_en);
+		break;
+
+	case VXGE_HW_SWAPPER_BIT_FLIPPED:
+		writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
+			&legacy_reg->pifm_rd_flip_en);
+		writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
+			&legacy_reg->pifm_wr_flip_en);
+		break;
+	}
+
+	wmb();
+
+	val64 = readq(&legacy_reg->toc_swapper_fb);
+
+	if (val64 != VXGE_HW_SWAPPER_INITIAL_VALUE)
+		status = VXGE_HW_ERR_SWAPPER_CTRL;
+
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_swapper_set - Set the swapper bits for the vpath.
+ * Set the swapper bits appropriately for the vpath.
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg)
+{
+#ifndef __BIG_ENDIAN
+	u64 val64;
+
+	val64 = readq(&vpath_reg->vpath_general_cfg1);
+	wmb();
+	val64 |= VXGE_HW_VPATH_GENERAL_CFG1_CTL_BYTE_SWAPEN;
+	writeq(val64, &vpath_reg->vpath_general_cfg1);
+	wmb();
+#endif
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_kdfc_swapper_set - Set the swapper bits for the kdfc.
+ * Set the swapper bits appropriately for the vpath.
+ */
+enum vxge_hw_status
+__vxge_hw_kdfc_swapper_set(
+	struct vxge_hw_legacy_reg __iomem *legacy_reg,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg)
+{
+	u64 val64;
+
+	val64 = readq(&legacy_reg->pifm_wr_swap_en);
+
+	if (val64 == VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE) {
+		val64 = readq(&vpath_reg->kdfcctl_cfg0);
+		wmb();
+
+		val64 |= VXGE_HW_KDFCCTL_CFG0_BYTE_SWAPEN_FIFO0	|
+			VXGE_HW_KDFCCTL_CFG0_BYTE_SWAPEN_FIFO1	|
+			VXGE_HW_KDFCCTL_CFG0_BYTE_SWAPEN_FIFO2;
+
+		writeq(val64, &vpath_reg->kdfcctl_cfg0);
+		wmb();
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * vxge_hw_mgmt_device_config - Retrieve device configuration.
+ * Get device configuration. Permits to retrieve at run-time configuration
+ * values that were used to initialize and configure the device.
+ */
+enum vxge_hw_status
+vxge_hw_mgmt_device_config(struct __vxge_hw_device *hldev,
+			   struct vxge_hw_device_config *dev_config, int size)
+{
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC))
+		return VXGE_HW_ERR_INVALID_DEVICE;
+
+	if (size != sizeof(struct vxge_hw_device_config))
+		return VXGE_HW_ERR_VERSION_CONFLICT;
+
+	memcpy(dev_config, &hldev->config,
+		sizeof(struct vxge_hw_device_config));
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * vxge_hw_mgmt_reg_read - Read Titan register.
+ */
+enum vxge_hw_status
+vxge_hw_mgmt_reg_read(struct __vxge_hw_device *hldev,
+		      enum vxge_hw_mgmt_reg_type type,
+		      u32 index, u32 offset, u64 *value)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC)) {
+		status = VXGE_HW_ERR_INVALID_DEVICE;
+		goto exit;
+	}
+
+	switch (type) {
+	case vxge_hw_mgmt_reg_type_legacy:
+		if (offset > sizeof(struct vxge_hw_legacy_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void __iomem *)hldev->legacy_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_toc:
+		if (offset > sizeof(struct vxge_hw_toc_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void __iomem *)hldev->toc_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_common:
+		if (offset > sizeof(struct vxge_hw_common_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void __iomem *)hldev->common_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_mrpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_mrpcim_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void __iomem *)hldev->mrpcim_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_srpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_SRPCIM_REG_SPACES - 1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_srpcim_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void __iomem *)hldev->srpcim_reg[index] +
+				offset);
+		break;
+	case vxge_hw_mgmt_reg_type_vpmgmt:
+		if ((index > VXGE_HW_TITAN_VPMGMT_REG_SPACES - 1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpmgmt_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void __iomem *)hldev->vpmgmt_reg[index] +
+				offset);
+		break;
+	case vxge_hw_mgmt_reg_type_vpath:
+		if ((index > VXGE_HW_TITAN_VPATH_REG_SPACES - 1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_VPATH_REG_SPACES - 1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpath_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void __iomem *)hldev->vpath_reg[index] +
+				offset);
+		break;
+	default:
+		status = VXGE_HW_ERR_INVALID_TYPE;
+		break;
+	}
+
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_mgmt_reg_Write - Write Titan register.
+ */
+enum vxge_hw_status
+vxge_hw_mgmt_reg_write(struct __vxge_hw_device *hldev,
+		      enum vxge_hw_mgmt_reg_type type,
+		      u32 index, u32 offset, u64 value)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC)) {
+		status = VXGE_HW_ERR_INVALID_DEVICE;
+		goto exit;
+	}
+
+	switch (type) {
+	case vxge_hw_mgmt_reg_type_legacy:
+		if (offset > sizeof(struct vxge_hw_legacy_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void __iomem *)hldev->legacy_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_toc:
+		if (offset > sizeof(struct vxge_hw_toc_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void __iomem *)hldev->toc_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_common:
+		if (offset > sizeof(struct vxge_hw_common_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void __iomem *)hldev->common_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_mrpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_mrpcim_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void __iomem *)hldev->mrpcim_reg + offset);
+		break;
+	case vxge_hw_mgmt_reg_type_srpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_SRPCIM_REG_SPACES - 1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_srpcim_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void __iomem *)hldev->srpcim_reg[index] +
+			offset);
+
+		break;
+	case vxge_hw_mgmt_reg_type_vpmgmt:
+		if ((index > VXGE_HW_TITAN_VPMGMT_REG_SPACES - 1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpmgmt_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void __iomem *)hldev->vpmgmt_reg[index] +
+			offset);
+		break;
+	case vxge_hw_mgmt_reg_type_vpath:
+		if ((index > VXGE_HW_TITAN_VPATH_REG_SPACES-1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpath_reg) - 8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void __iomem *)hldev->vpath_reg[index] +
+			offset);
+		break;
+	default:
+		status = VXGE_HW_ERR_INVALID_TYPE;
+		break;
+	}
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_fifo_mempool_item_alloc - Allocate List blocks for TxD
+ * list callback
+ * This function is callback passed to __vxge_hw_mempool_create to create memory
+ * pool for TxD list
+ */
+static void
+__vxge_hw_fifo_mempool_item_alloc(
+	struct vxge_hw_mempool *mempoolh,
+	u32 memblock_index, struct vxge_hw_mempool_dma *dma_object,
+	u32 index, u32 is_last)
+{
+	u32 memblock_item_idx;
+	struct __vxge_hw_fifo_txdl_priv *txdl_priv;
+	struct vxge_hw_fifo_txd *txdp =
+		(struct vxge_hw_fifo_txd *)mempoolh->items_arr[index];
+	struct __vxge_hw_fifo *fifo =
+			(struct __vxge_hw_fifo *)mempoolh->userdata;
+	void *memblock = mempoolh->memblocks_arr[memblock_index];
+
+	vxge_assert(txdp);
+
+	txdp->host_control = (u64) (size_t)
+	__vxge_hw_mempool_item_priv(mempoolh, memblock_index, txdp,
+					&memblock_item_idx);
+
+	txdl_priv = __vxge_hw_fifo_txdl_priv(fifo, txdp);
+
+	vxge_assert(txdl_priv);
+
+	fifo->channel.reserve_arr[fifo->channel.reserve_ptr - 1 - index] = txdp;
+
+	/* pre-format HW's TxDL's private */
+	txdl_priv->dma_offset = (char *)txdp - (char *)memblock;
+	txdl_priv->dma_addr = dma_object->addr + txdl_priv->dma_offset;
+	txdl_priv->dma_handle = dma_object->handle;
+	txdl_priv->memblock   = memblock;
+	txdl_priv->first_txdp = txdp;
+	txdl_priv->next_txdl_priv = NULL;
+	txdl_priv->alloc_frags = 0;
+
+	return;
+}
+
+/*
+ * __vxge_hw_fifo_create - Create a FIFO
+ * This function creates FIFO and initializes it.
+ */
+enum vxge_hw_status
+__vxge_hw_fifo_create(struct __vxge_hw_vpath_handle *vp,
+		      struct vxge_hw_fifo_attr *attr)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_fifo *fifo;
+	struct vxge_hw_fifo_config *config;
+	u32 txdl_size, txdl_per_memblock;
+	struct vxge_hw_mempool_cbs fifo_mp_callback;
+	struct __vxge_hw_virtualpath *vpath;
+
+	if ((vp == NULL) || (attr == NULL)) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+	vpath = vp->vpath;
+	config = &vpath->hldev->config.vp_config[vpath->vp_id].fifo;
+
+	txdl_size = config->max_frags * sizeof(struct vxge_hw_fifo_txd);
+
+	txdl_per_memblock = config->memblock_size / txdl_size;
+
+	fifo = (struct __vxge_hw_fifo *)__vxge_hw_channel_allocate(vp,
+					VXGE_HW_CHANNEL_TYPE_FIFO,
+					config->fifo_blocks * txdl_per_memblock,
+					attr->per_txdl_space, attr->userdata);
+
+	if (fifo == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	vpath->fifoh = fifo;
+	fifo->nofl_db = vpath->nofl_db;
+
+	fifo->vp_id = vpath->vp_id;
+	fifo->vp_reg = vpath->vp_reg;
+	fifo->stats = &vpath->sw_stats->fifo_stats;
+
+	fifo->config = config;
+
+	/* apply "interrupts per txdl" attribute */
+	fifo->interrupt_type = VXGE_HW_FIFO_TXD_INT_TYPE_UTILZ;
+
+	if (fifo->config->intr)
+		fifo->interrupt_type = VXGE_HW_FIFO_TXD_INT_TYPE_PER_LIST;
+
+	fifo->no_snoop_bits = config->no_snoop_bits;
+
+	/*
+	 * FIFO memory management strategy:
+	 *
+	 * TxDL split into three independent parts:
+	 *	- set of TxD's
+	 *	- TxD HW private part
+	 *	- driver private part
+	 *
+	 * Adaptative memory allocation used. i.e. Memory allocated on
+	 * demand with the size which will fit into one memory block.
+	 * One memory block may contain more than one TxDL.
+	 *
+	 * During "reserve" operations more memory can be allocated on demand
+	 * for example due to FIFO full condition.
+	 *
+	 * Pool of memory memblocks never shrinks except in __vxge_hw_fifo_close
+	 * routine which will essentially stop the channel and free resources.
+	 */
+
+	/* TxDL common private size == TxDL private  +  driver private */
+	fifo->priv_size =
+		sizeof(struct __vxge_hw_fifo_txdl_priv) + attr->per_txdl_space;
+	fifo->priv_size = ((fifo->priv_size  +  VXGE_CACHE_LINE_SIZE - 1) /
+			VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
+
+	fifo->per_txdl_space = attr->per_txdl_space;
+
+	/* recompute txdl size to be cacheline aligned */
+	fifo->txdl_size = txdl_size;
+	fifo->txdl_per_memblock = txdl_per_memblock;
+
+	fifo->txdl_term = attr->txdl_term;
+	fifo->callback = attr->callback;
+
+	if (fifo->txdl_per_memblock == 0) {
+		__vxge_hw_fifo_delete(vp);
+		status = VXGE_HW_ERR_INVALID_BLOCK_SIZE;
+		goto exit;
+	}
+
+	fifo_mp_callback.item_func_alloc = __vxge_hw_fifo_mempool_item_alloc;
+
+	fifo->mempool =
+		__vxge_hw_mempool_create(vpath->hldev,
+			fifo->config->memblock_size,
+			fifo->txdl_size,
+			fifo->priv_size,
+			(fifo->config->fifo_blocks * fifo->txdl_per_memblock),
+			(fifo->config->fifo_blocks * fifo->txdl_per_memblock),
+			&fifo_mp_callback,
+			fifo);
+
+	if (fifo->mempool == NULL) {
+		__vxge_hw_fifo_delete(vp);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	status = __vxge_hw_channel_initialize(&fifo->channel);
+	if (status != VXGE_HW_OK) {
+		__vxge_hw_fifo_delete(vp);
+		goto exit;
+	}
+
+	vxge_assert(fifo->channel.reserve_ptr);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_fifo_abort - Returns the TxD
+ * This function terminates the TxDs of fifo
+ */
+enum vxge_hw_status __vxge_hw_fifo_abort(struct __vxge_hw_fifo *fifo)
+{
+	void *txdlh;
+
+	for (;;) {
+		vxge_hw_channel_dtr_try_complete(&fifo->channel, &txdlh);
+
+		if (txdlh == NULL)
+			break;
+
+		vxge_hw_channel_dtr_complete(&fifo->channel);
+
+		if (fifo->txdl_term) {
+			fifo->txdl_term(txdlh,
+			VXGE_HW_TXDL_STATE_POSTED,
+			fifo->channel.userdata);
+		}
+
+		vxge_hw_channel_dtr_free(&fifo->channel, txdlh);
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_fifo_reset - Resets the fifo
+ * This function resets the fifo during vpath reset operation
+ */
+enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	__vxge_hw_fifo_abort(fifo);
+	status = __vxge_hw_channel_reset(&fifo->channel);
+
+	return status;
+}
+
+/*
+ * __vxge_hw_fifo_delete - Removes the FIFO
+ * This function freeup the memory pool and removes the FIFO
+ */
+enum vxge_hw_status __vxge_hw_fifo_delete(struct __vxge_hw_vpath_handle *vp)
+{
+	struct __vxge_hw_fifo *fifo = vp->vpath->fifoh;
+
+	__vxge_hw_fifo_abort(fifo);
+
+	if (fifo->mempool)
+		__vxge_hw_mempool_destroy(fifo->mempool);
+
+	vp->vpath->fifoh = NULL;
+
+	__vxge_hw_channel_free(&fifo->channel);
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_vpath_pci_read - Read the content of given address
+ *                          in pci config space.
+ * Read from the vpath pci config space.
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_pci_read(struct __vxge_hw_virtualpath *vpath,
+			 u32 phy_func_0, u32 offset, u32 *val)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_hw_vpath_reg __iomem *vp_reg = vpath->vp_reg;
+
+	val64 =	VXGE_HW_PCI_CONFIG_ACCESS_CFG1_ADDRESS(offset);
+
+	if (phy_func_0)
+		val64 |= VXGE_HW_PCI_CONFIG_ACCESS_CFG1_SEL_FUNC0;
+
+	writeq(val64, &vp_reg->pci_config_access_cfg1);
+	wmb();
+	writeq(VXGE_HW_PCI_CONFIG_ACCESS_CFG2_REQ,
+			&vp_reg->pci_config_access_cfg2);
+	wmb();
+
+	status = __vxge_hw_device_register_poll(
+			&vp_reg->pci_config_access_cfg2,
+			VXGE_HW_INTR_MASK_ALL, VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vp_reg->pci_config_access_status);
+
+	if (val64 & VXGE_HW_PCI_CONFIG_ACCESS_STATUS_ACCESS_ERR) {
+		status = VXGE_HW_FAIL;
+		*val = 0;
+	} else
+		*val = (u32)vxge_bVALn(val64, 32, 32);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_func_id_get - Get the function id of the vpath.
+ * Returns the function number of the vpath.
+ */
+u32
+__vxge_hw_vpath_func_id_get(u32 vp_id,
+	struct vxge_hw_vpmgmt_reg __iomem *vpmgmt_reg)
+{
+	u64 val64;
+
+	val64 = readq(&vpmgmt_reg->vpath_to_func_map_cfg1);
+
+	return
+	 (u32)VXGE_HW_VPATH_TO_FUNC_MAP_CFG1_GET_VPATH_TO_FUNC_MAP_CFG1(val64);
+}
+
+/*
+ * __vxge_hw_read_rts_ds - Program RTS steering critieria
+ */
+static inline void
+__vxge_hw_read_rts_ds(struct vxge_hw_vpath_reg __iomem *vpath_reg,
+		      u64 dta_struct_sel)
+{
+	writeq(0, &vpath_reg->rts_access_steer_ctrl);
+	wmb();
+	writeq(dta_struct_sel, &vpath_reg->rts_access_steer_data0);
+	writeq(0, &vpath_reg->rts_access_steer_data1);
+	wmb();
+	return;
+}
+
+
+/*
+ * __vxge_hw_vpath_card_info_get - Get the serial numbers,
+ * part number and product description.
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_card_info_get(
+	u32 vp_id,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg,
+	struct vxge_hw_device_hw_info *hw_info)
+{
+	u32 i, j;
+	u64 val64;
+	u64 data1 = 0ULL;
+	u64 data2 = 0ULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u8 *serial_number = hw_info->serial_number;
+	u8 *part_number = hw_info->part_number;
+	u8 *product_desc = hw_info->product_desc;
+
+	__vxge_hw_read_rts_ds(vpath_reg,
+		VXGE_HW_RTS_ACCESS_STEER_DATA0_MEMO_ITEM_SERIAL_NUMBER);
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_MEMO_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vpath_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		return status;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+		((u64 *)serial_number)[0] = be64_to_cpu(data1);
+
+		data2 = readq(&vpath_reg->rts_access_steer_data1);
+		((u64 *)serial_number)[1] = be64_to_cpu(data2);
+		status = VXGE_HW_OK;
+	} else
+		*serial_number = 0;
+
+	__vxge_hw_read_rts_ds(vpath_reg,
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_MEMO_ITEM_PART_NUMBER);
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_MEMO_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vpath_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		return status;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+		((u64 *)part_number)[0] = be64_to_cpu(data1);
+
+		data2 = readq(&vpath_reg->rts_access_steer_data1);
+		((u64 *)part_number)[1] = be64_to_cpu(data2);
+
+		status = VXGE_HW_OK;
+
+	} else
+		*part_number = 0;
+
+	j = 0;
+
+	for (i = VXGE_HW_RTS_ACCESS_STEER_DATA0_MEMO_ITEM_DESC_0;
+	     i <= VXGE_HW_RTS_ACCESS_STEER_DATA0_MEMO_ITEM_DESC_3; i++) {
+
+		__vxge_hw_read_rts_ds(vpath_reg, i);
+
+		val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_MEMO_ENTRY) |
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+		status = __vxge_hw_pio_mem_write64(val64,
+				&vpath_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+		if (status != VXGE_HW_OK)
+			return status;
+
+		val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+		if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+			data1 = readq(&vpath_reg->rts_access_steer_data0);
+			((u64 *)product_desc)[j++] = be64_to_cpu(data1);
+
+			data2 = readq(&vpath_reg->rts_access_steer_data1);
+			((u64 *)product_desc)[j++] = be64_to_cpu(data2);
+
+			status = VXGE_HW_OK;
+		} else
+			*product_desc = 0;
+	}
+
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_fw_ver_get - Get the fw version
+ * Returns FW Version
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_fw_ver_get(
+	u32 vp_id,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg,
+	struct vxge_hw_device_hw_info *hw_info)
+{
+	u64 val64;
+	u64 data1 = 0ULL;
+	u64 data2 = 0ULL;
+	struct vxge_hw_device_version *fw_version = &hw_info->fw_version;
+	struct vxge_hw_device_date *fw_date = &hw_info->fw_date;
+	struct vxge_hw_device_version *flash_version = &hw_info->flash_version;
+	struct vxge_hw_device_date *flash_date = &hw_info->flash_date;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vpath_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+		data2 = readq(&vpath_reg->rts_access_steer_data1);
+
+		fw_date->day =
+			(u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_DAY(
+						data1);
+		fw_date->month =
+			(u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_MONTH(
+						data1);
+		fw_date->year =
+			(u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_YEAR(
+						data1);
+
+		snprintf(fw_date->date, VXGE_HW_FW_STRLEN, "%2.2d/%2.2d/%4.4d",
+			fw_date->month, fw_date->day, fw_date->year);
+
+		fw_version->major =
+		    (u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_MAJOR(data1);
+		fw_version->minor =
+		    (u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_MINOR(data1);
+		fw_version->build =
+		    (u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_BUILD(data1);
+
+		snprintf(fw_version->version, VXGE_HW_FW_STRLEN, "%d.%d.%d",
+		    fw_version->major, fw_version->minor, fw_version->build);
+
+		flash_date->day =
+		  (u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_DAY(data2);
+		flash_date->month =
+		 (u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_MONTH(data2);
+		flash_date->year =
+		 (u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_YEAR(data2);
+
+		snprintf(flash_date->date, VXGE_HW_FW_STRLEN,
+			"%2.2d/%2.2d/%4.4d",
+			flash_date->month, flash_date->day, flash_date->year);
+
+		flash_version->major =
+		 (u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_MAJOR(data2);
+		flash_version->minor =
+		 (u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_MINOR(data2);
+		flash_version->build =
+		 (u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_BUILD(data2);
+
+		snprintf(flash_version->version, VXGE_HW_FW_STRLEN, "%d.%d.%d",
+			flash_version->major, flash_version->minor,
+			flash_version->build);
+
+		status = VXGE_HW_OK;
+
+	} else
+		status = VXGE_HW_FAIL;
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_pci_func_mode_get - Get the pci mode
+ * Returns pci function mode
+ */
+u64
+__vxge_hw_vpath_pci_func_mode_get(
+	u32  vp_id,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg)
+{
+	u64 val64;
+	u64 data1 = 0ULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	__vxge_hw_read_rts_ds(vpath_reg,
+		VXGE_HW_RTS_ACCESS_STEER_DATA0_MEMO_ITEM_PCI_MODE);
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_MEMO_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vpath_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+		status = VXGE_HW_OK;
+	} else {
+		data1 = 0;
+		status = VXGE_HW_FAIL;
+	}
+exit:
+	return data1;
+}
+
+/**
+ * vxge_hw_device_flick_link_led - Flick (blink) link LED.
+ * @hldev: HW device.
+ * @on_off: TRUE if flickering to be on, FALSE to be off
+ *
+ * Flicker the link LED.
+ */
+enum vxge_hw_status
+vxge_hw_device_flick_link_led(struct __vxge_hw_device *hldev,
+			       u64 on_off)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	if (hldev == NULL) {
+		status = VXGE_HW_ERR_INVALID_DEVICE;
+		goto exit;
+	}
+
+	vp_reg = hldev->vpath_reg[hldev->first_vp_id];
+
+	writeq(0, &vp_reg->rts_access_steer_ctrl);
+	wmb();
+	writeq(on_off, &vp_reg->rts_access_steer_data0);
+	writeq(0, &vp_reg->rts_access_steer_data1);
+	wmb();
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_LED_CONTROL) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vp_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_rts_table_get - Get the entries from RTS access tables
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_rts_table_get(
+	struct __vxge_hw_vpath_handle *vp,
+	u32 action, u32 rts_table, u32 offset, u64 *data1, u64 *data2)
+{
+	u64 val64;
+	struct __vxge_hw_virtualpath *vpath;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	vpath = vp->vpath;
+	vp_reg = vpath->vp_reg;
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(action) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(rts_table) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(offset);
+
+	if ((rts_table ==
+		VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_SOLO_IT) ||
+	    (rts_table ==
+		VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT) ||
+	    (rts_table ==
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MASK) ||
+	    (rts_table ==
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_KEY)) {
+		val64 = val64 |	VXGE_HW_RTS_ACCESS_STEER_CTRL_TABLE_SEL;
+	}
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vp_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				vpath->hldev->config.device_poll_millis);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vp_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		*data1 = readq(&vp_reg->rts_access_steer_data0);
+
+		if ((rts_table ==
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) ||
+		(rts_table ==
+		VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT)) {
+			*data2 = readq(&vp_reg->rts_access_steer_data1);
+		}
+		status = VXGE_HW_OK;
+	} else
+		status = VXGE_HW_FAIL;
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_rts_table_set - Set the entries of RTS access tables
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_rts_table_set(
+	struct __vxge_hw_vpath_handle *vp, u32 action, u32 rts_table,
+	u32 offset, u64 data1, u64 data2)
+{
+	u64 val64;
+	struct __vxge_hw_virtualpath *vpath;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	vpath = vp->vpath;
+	vp_reg = vpath->vp_reg;
+
+	writeq(data1, &vp_reg->rts_access_steer_data0);
+	wmb();
+
+	if ((rts_table == VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) ||
+	    (rts_table ==
+		VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT)) {
+		writeq(data2, &vp_reg->rts_access_steer_data1);
+		wmb();
+	}
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(action) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(rts_table) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(offset);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vp_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				vpath->hldev->config.device_poll_millis);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vp_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS)
+		status = VXGE_HW_OK;
+	else
+		status = VXGE_HW_FAIL;
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_addr_get - Get the hw address entry for this vpath
+ *               from MAC address table.
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_addr_get(
+	u32 vp_id, struct vxge_hw_vpath_reg __iomem *vpath_reg,
+	u8 (macaddr)[ETH_ALEN], u8 (macaddr_mask)[ETH_ALEN])
+{
+	u32 i;
+	u64 val64;
+	u64 data1 = 0ULL;
+	u64 data2 = 0ULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_LIST_FIRST_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vpath_reg->rts_access_steer_ctrl,
+				VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+				VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+		data2 = readq(&vpath_reg->rts_access_steer_data1);
+
+		data1 = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_DA_MAC_ADDR(data1);
+		data2 = VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_DA_MAC_ADDR_MASK(
+							data2);
+
+		for (i = ETH_ALEN; i > 0; i--) {
+			macaddr[i-1] = (u8)(data1 & 0xFF);
+			data1 >>= 8;
+
+			macaddr_mask[i-1] = (u8)(data2 & 0xFF);
+			data2 >>= 8;
+		}
+		status = VXGE_HW_OK;
+	} else
+		status = VXGE_HW_FAIL;
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_vpath_rts_rth_set - Set/configure RTS hashing.
+ */
+enum vxge_hw_status vxge_hw_vpath_rts_rth_set(
+			struct __vxge_hw_vpath_handle *vp,
+			enum vxge_hw_rth_algoritms algorithm,
+			struct vxge_hw_rth_hash_types *hash_type,
+			u16 bucket_size)
+{
+	u64 data0, data1;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	status = __vxge_hw_vpath_rts_table_get(vp,
+		     VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_ENTRY,
+		     VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_GEN_CFG,
+			0, &data0, &data1);
+
+	data0 &= ~(VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_BUCKET_SIZE(0xf) |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_ALG_SEL(0x3));
+
+	data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_EN |
+	VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_BUCKET_SIZE(bucket_size) |
+	VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_ALG_SEL(algorithm);
+
+	if (hash_type->hash_type_tcpipv4_en)
+		data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_TCP_IPV4_EN;
+
+	if (hash_type->hash_type_ipv4_en)
+		data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_IPV4_EN;
+
+	if (hash_type->hash_type_tcpipv6_en)
+		data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_TCP_IPV6_EN;
+
+	if (hash_type->hash_type_ipv6_en)
+		data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_IPV6_EN;
+
+	if (hash_type->hash_type_tcpipv6ex_en)
+		data0 |=
+		VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_TCP_IPV6_EX_EN;
+
+	if (hash_type->hash_type_ipv6ex_en)
+		data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_IPV6_EX_EN;
+
+	if (VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_RTH_GEN_ACTIVE_TABLE(data0))
+		data0 &= ~VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_ACTIVE_TABLE;
+	else
+		data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_ACTIVE_TABLE;
+
+	status = __vxge_hw_vpath_rts_table_set(vp,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_WRITE_ENTRY,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_GEN_CFG,
+		0, data0, 0);
+exit:
+	return status;
+}
+
+static void
+vxge_hw_rts_rth_data0_data1_get(u32 j, u64 *data0, u64 *data1,
+				u16 flag, u8 *itable)
+{
+	switch (flag) {
+	case 1:
+		*data0 = VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_ITEM0_BUCKET_NUM(j)|
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_ITEM0_ENTRY_EN |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_ITEM0_BUCKET_DATA(
+			itable[j]);
+	case 2:
+		*data0 |=
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_ITEM1_BUCKET_NUM(j)|
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_ITEM1_ENTRY_EN |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_ITEM1_BUCKET_DATA(
+			itable[j]);
+	case 3:
+		*data1 = VXGE_HW_RTS_ACCESS_STEER_DATA1_RTH_ITEM0_BUCKET_NUM(j)|
+			VXGE_HW_RTS_ACCESS_STEER_DATA1_RTH_ITEM0_ENTRY_EN |
+			VXGE_HW_RTS_ACCESS_STEER_DATA1_RTH_ITEM0_BUCKET_DATA(
+			itable[j]);
+	case 4:
+		*data1 |=
+			VXGE_HW_RTS_ACCESS_STEER_DATA1_RTH_ITEM1_BUCKET_NUM(j)|
+			VXGE_HW_RTS_ACCESS_STEER_DATA1_RTH_ITEM1_ENTRY_EN |
+			VXGE_HW_RTS_ACCESS_STEER_DATA1_RTH_ITEM1_BUCKET_DATA(
+			itable[j]);
+	default:
+		return;
+	}
+}
+/*
+ * vxge_hw_vpath_rts_rth_itable_set - Set/configure indirection table (IT).
+ */
+enum vxge_hw_status vxge_hw_vpath_rts_rth_itable_set(
+			struct __vxge_hw_vpath_handle **vpath_handles,
+			u32 vpath_count,
+			u8 *mtable,
+			u8 *itable,
+			u32 itable_size)
+{
+	u32 i, j, action, rts_table;
+	u64 data0;
+	u64 data1;
+	u32 max_entries;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_vpath_handle *vp = vpath_handles[0];
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	max_entries = (((u32)1) << itable_size);
+
+	if (vp->vpath->hldev->config.rth_it_type
+				== VXGE_HW_RTH_IT_TYPE_SOLO_IT) {
+		action = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_WRITE_ENTRY;
+		rts_table =
+			VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_SOLO_IT;
+
+		for (j = 0; j < max_entries; j++) {
+
+			data1 = 0;
+
+			data0 =
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_SOLO_IT_BUCKET_DATA(
+				itable[j]);
+
+			status = __vxge_hw_vpath_rts_table_set(vpath_handles[0],
+				action, rts_table, j, data0, data1);
+
+			if (status != VXGE_HW_OK)
+				goto exit;
+		}
+
+		for (j = 0; j < max_entries; j++) {
+
+			data1 = 0;
+
+			data0 =
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_SOLO_IT_ENTRY_EN |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_SOLO_IT_BUCKET_DATA(
+				itable[j]);
+
+			status = __vxge_hw_vpath_rts_table_set(
+				vpath_handles[mtable[itable[j]]], action,
+				rts_table, j, data0, data1);
+
+			if (status != VXGE_HW_OK)
+				goto exit;
+		}
+	} else {
+		action = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_WRITE_ENTRY;
+		rts_table =
+			VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT;
+		for (i = 0; i < vpath_count; i++) {
+
+			for (j = 0; j < max_entries;) {
+
+				data0 = 0;
+				data1 = 0;
+
+				while (j < max_entries) {
+					if (mtable[itable[j]] != i) {
+						j++;
+						continue;
+					}
+					vxge_hw_rts_rth_data0_data1_get(j,
+						&data0, &data1, 1, itable);
+					j++;
+					break;
+				}
+
+				while (j < max_entries) {
+					if (mtable[itable[j]] != i) {
+						j++;
+						continue;
+					}
+					vxge_hw_rts_rth_data0_data1_get(j,
+						&data0, &data1, 2, itable);
+					j++;
+					break;
+				}
+
+				while (j < max_entries) {
+					if (mtable[itable[j]] != i) {
+						j++;
+						continue;
+					}
+					vxge_hw_rts_rth_data0_data1_get(j,
+						&data0, &data1, 3, itable);
+					j++;
+					break;
+				}
+
+				while (j < max_entries) {
+					if (mtable[itable[j]] != i) {
+						j++;
+						continue;
+					}
+					vxge_hw_rts_rth_data0_data1_get(j,
+						&data0, &data1, 4, itable);
+					j++;
+					break;
+				}
+
+				if (data0 != 0) {
+					status = __vxge_hw_vpath_rts_table_set(
+							vpath_handles[i],
+							action, rts_table,
+							0, data0, data1);
+
+					if (status != VXGE_HW_OK)
+						goto exit;
+				}
+			}
+		}
+	}
+exit:
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_check_leak - Check for memory leak
+ * @ringh: Handle to the ring object used for receive
+ *
+ * If PRC_RXD_DOORBELL_VPn.NEW_QW_CNT is larger or equal to
+ * PRC_CFG6_VPn.RXD_SPAT then a leak has occurred.
+ * Returns: VXGE_HW_FAIL, if leak has occurred.
+ *
+ */
+enum vxge_hw_status
+vxge_hw_vpath_check_leak(struct __vxge_hw_ring *ring)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u64 rxd_new_count, rxd_spat;
+
+	if (ring == NULL)
+		return status;
+
+	rxd_new_count = readl(&ring->vp_reg->prc_rxd_doorbell);
+	rxd_spat = readq(&ring->vp_reg->prc_cfg6);
+	rxd_spat = VXGE_HW_PRC_CFG6_RXD_SPAT(rxd_spat);
+
+	if (rxd_new_count >= rxd_spat)
+		status = VXGE_HW_FAIL;
+
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_mgmt_read
+ * This routine reads the vpath_mgmt registers
+ */
+static enum vxge_hw_status
+__vxge_hw_vpath_mgmt_read(
+	struct __vxge_hw_device *hldev,
+	struct __vxge_hw_virtualpath *vpath)
+{
+	u32 i, mtu = 0, max_pyld = 0;
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	for (i = 0; i < VXGE_HW_MAC_MAX_MAC_PORT_ID; i++) {
+
+		val64 = readq(&vpath->vpmgmt_reg->
+				rxmac_cfg0_port_vpmgmt_clone[i]);
+		max_pyld =
+			(u32)
+			VXGE_HW_RXMAC_CFG0_PORT_VPMGMT_CLONE_GET_MAX_PYLD_LEN
+			(val64);
+		if (mtu < max_pyld)
+			mtu = max_pyld;
+	}
+
+	vpath->max_mtu = mtu + VXGE_HW_MAC_HEADER_MAX_SIZE;
+
+	val64 = readq(&vpath->vpmgmt_reg->xmac_vsport_choices_vp);
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		if (val64 & vxge_mBIT(i))
+			vpath->vsport_number = i;
+	}
+
+	val64 = readq(&vpath->vpmgmt_reg->xgmac_gen_status_vpmgmt_clone);
+
+	if (val64 & VXGE_HW_XGMAC_GEN_STATUS_VPMGMT_CLONE_XMACJ_NTWK_OK)
+		VXGE_HW_DEVICE_LINK_STATE_SET(vpath->hldev, VXGE_HW_LINK_UP);
+	else
+		VXGE_HW_DEVICE_LINK_STATE_SET(vpath->hldev, VXGE_HW_LINK_DOWN);
+
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_reset_check - Check if resetting the vpath completed
+ * This routine checks the vpath_rst_in_prog register to see if
+ * adapter completed the reset process for the vpath
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath)
+{
+	enum vxge_hw_status status;
+
+	status = __vxge_hw_device_register_poll(
+			&vpath->hldev->common_reg->vpath_rst_in_prog,
+			VXGE_HW_VPATH_RST_IN_PROG_VPATH_RST_IN_PROG(
+				1 << (16 - vpath->vp_id)),
+			vpath->hldev->config.device_poll_millis);
+
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_reset
+ * This routine resets the vpath on the device
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_reset(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	val64 = VXGE_HW_CMN_RSTHDLR_CFG0_SW_RESET_VPATH(1 << (16 - vp_id));
+
+	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32),
+				&hldev->common_reg->cmn_rsthdlr_cfg0);
+
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_sw_reset
+ * This routine resets the vpath structures
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_sw_reset(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_virtualpath *vpath;
+
+	vpath = (struct __vxge_hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	if (vpath->ringh) {
+		status = __vxge_hw_ring_reset(vpath->ringh);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+
+	if (vpath->fifoh)
+		status = __vxge_hw_fifo_reset(vpath->fifoh);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_prc_configure
+ * This routine configures the prc registers of virtual path using the config
+ * passed
+ */
+void
+__vxge_hw_vpath_prc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	struct __vxge_hw_virtualpath *vpath;
+	struct vxge_hw_vp_config *vp_config;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	vpath = &hldev->virtual_paths[vp_id];
+	vp_reg = vpath->vp_reg;
+	vp_config = vpath->vp_config;
+
+	if (vp_config->ring.enable == VXGE_HW_RING_DISABLE)
+		return;
+
+	val64 = readq(&vp_reg->prc_cfg1);
+	val64 |= VXGE_HW_PRC_CFG1_RTI_TINT_DISABLE;
+	writeq(val64, &vp_reg->prc_cfg1);
+
+	val64 = readq(&vpath->vp_reg->prc_cfg6);
+	val64 |= VXGE_HW_PRC_CFG6_DOORBELL_MODE_EN;
+	writeq(val64, &vpath->vp_reg->prc_cfg6);
+
+	val64 = readq(&vp_reg->prc_cfg7);
+
+	if (vpath->vp_config->ring.scatter_mode !=
+		VXGE_HW_RING_SCATTER_MODE_USE_FLASH_DEFAULT) {
+
+		val64 &= ~VXGE_HW_PRC_CFG7_SCATTER_MODE(0x3);
+
+		switch (vpath->vp_config->ring.scatter_mode) {
+		case VXGE_HW_RING_SCATTER_MODE_A:
+			val64 |= VXGE_HW_PRC_CFG7_SCATTER_MODE(
+					VXGE_HW_PRC_CFG7_SCATTER_MODE_A);
+			break;
+		case VXGE_HW_RING_SCATTER_MODE_B:
+			val64 |= VXGE_HW_PRC_CFG7_SCATTER_MODE(
+					VXGE_HW_PRC_CFG7_SCATTER_MODE_B);
+			break;
+		case VXGE_HW_RING_SCATTER_MODE_C:
+			val64 |= VXGE_HW_PRC_CFG7_SCATTER_MODE(
+					VXGE_HW_PRC_CFG7_SCATTER_MODE_C);
+			break;
+		}
+	}
+
+	writeq(val64, &vp_reg->prc_cfg7);
+
+	writeq(VXGE_HW_PRC_CFG5_RXD0_ADD(
+				__vxge_hw_ring_first_block_address_get(
+					vpath->ringh) >> 3), &vp_reg->prc_cfg5);
+
+	val64 = readq(&vp_reg->prc_cfg4);
+	val64 |= VXGE_HW_PRC_CFG4_IN_SVC;
+	val64 &= ~VXGE_HW_PRC_CFG4_RING_MODE(0x3);
+
+	val64 |= VXGE_HW_PRC_CFG4_RING_MODE(
+			VXGE_HW_PRC_CFG4_RING_MODE_ONE_BUFFER);
+
+	if (hldev->config.rth_en == VXGE_HW_RTH_DISABLE)
+		val64 |= VXGE_HW_PRC_CFG4_RTH_DISABLE;
+	else
+		val64 &= ~VXGE_HW_PRC_CFG4_RTH_DISABLE;
+
+	writeq(val64, &vp_reg->prc_cfg4);
+	return;
+}
+
+/*
+ * __vxge_hw_vpath_kdfc_configure
+ * This routine configures the kdfc registers of virtual path using the
+ * config passed
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_kdfc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	u64 vpath_stride;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_virtualpath *vpath;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	vpath = &hldev->virtual_paths[vp_id];
+	vp_reg = vpath->vp_reg;
+	status = __vxge_hw_kdfc_swapper_set(hldev->legacy_reg, vp_reg);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vp_reg->kdfc_drbl_triplet_total);
+
+	vpath->max_kdfc_db =
+		(u32)VXGE_HW_KDFC_DRBL_TRIPLET_TOTAL_GET_KDFC_MAX_SIZE(
+			val64+1)/2;
+
+	if (vpath->vp_config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
+
+		vpath->max_nofl_db = vpath->max_kdfc_db;
+
+		if (vpath->max_nofl_db <
+			((vpath->vp_config->fifo.memblock_size /
+			(vpath->vp_config->fifo.max_frags *
+			sizeof(struct vxge_hw_fifo_txd))) *
+			vpath->vp_config->fifo.fifo_blocks)) {
+
+			return VXGE_HW_BADCFG_FIFO_BLOCKS;
+		}
+		val64 = VXGE_HW_KDFC_FIFO_TRPL_PARTITION_LENGTH_0(
+				(vpath->max_nofl_db*2)-1);
+	}
+
+	writeq(val64, &vp_reg->kdfc_fifo_trpl_partition);
+
+	writeq(VXGE_HW_KDFC_FIFO_TRPL_CTRL_TRIPLET_ENABLE,
+		&vp_reg->kdfc_fifo_trpl_ctrl);
+
+	val64 = readq(&vp_reg->kdfc_trpl_fifo_0_ctrl);
+
+	val64 &= ~(VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_MODE(0x3) |
+		   VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_SELECT(0xFF));
+
+	val64 |= VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_MODE(
+		 VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_MODE_NON_OFFLOAD_ONLY) |
+#ifndef __BIG_ENDIAN
+		 VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_SWAP_EN |
+#endif
+		 VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_SELECT(0);
+
+	writeq(val64, &vp_reg->kdfc_trpl_fifo_0_ctrl);
+	writeq((u64)0, &vp_reg->kdfc_trpl_fifo_0_wb_address);
+	wmb();
+	vpath_stride = readq(&hldev->toc_reg->toc_kdfc_vpath_stride);
+
+	vpath->nofl_db =
+		(struct __vxge_hw_non_offload_db_wrapper __iomem *)
+		(hldev->kdfc + (vp_id *
+		VXGE_HW_TOC_KDFC_VPATH_STRIDE_GET_TOC_KDFC_VPATH_STRIDE(
+					vpath_stride)));
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_mac_configure
+ * This routine configures the mac of virtual path using the config passed
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_mac_configure(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_virtualpath *vpath;
+	struct vxge_hw_vp_config *vp_config;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	vpath = &hldev->virtual_paths[vp_id];
+	vp_reg = vpath->vp_reg;
+	vp_config = vpath->vp_config;
+
+	writeq(VXGE_HW_XMAC_VSPORT_CHOICE_VSPORT_NUMBER(
+			vpath->vsport_number), &vp_reg->xmac_vsport_choice);
+
+	if (vp_config->ring.enable == VXGE_HW_RING_ENABLE) {
+
+		val64 = readq(&vp_reg->xmac_rpa_vcfg);
+
+		if (vp_config->rpa_strip_vlan_tag !=
+			VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT) {
+			if (vp_config->rpa_strip_vlan_tag)
+				val64 |= VXGE_HW_XMAC_RPA_VCFG_STRIP_VLAN_TAG;
+			else
+				val64 &= ~VXGE_HW_XMAC_RPA_VCFG_STRIP_VLAN_TAG;
+		}
+
+		writeq(val64, &vp_reg->xmac_rpa_vcfg);
+		val64 = readq(&vp_reg->rxmac_vcfg0);
+
+		if (vp_config->mtu !=
+				VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU) {
+			val64 &= ~VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(0x3fff);
+			if ((vp_config->mtu  +
+				VXGE_HW_MAC_HEADER_MAX_SIZE) < vpath->max_mtu)
+				val64 |= VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(
+					vp_config->mtu  +
+					VXGE_HW_MAC_HEADER_MAX_SIZE);
+			else
+				val64 |= VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(
+					vpath->max_mtu);
+		}
+
+		writeq(val64, &vp_reg->rxmac_vcfg0);
+
+		val64 = readq(&vp_reg->rxmac_vcfg1);
+
+		val64 &= ~(VXGE_HW_RXMAC_VCFG1_RTS_RTH_MULTI_IT_BD_MODE(0x3) |
+			VXGE_HW_RXMAC_VCFG1_RTS_RTH_MULTI_IT_EN_MODE);
+
+		if (hldev->config.rth_it_type ==
+				VXGE_HW_RTH_IT_TYPE_MULTI_IT) {
+			val64 |= VXGE_HW_RXMAC_VCFG1_RTS_RTH_MULTI_IT_BD_MODE(
+				0x2) |
+				VXGE_HW_RXMAC_VCFG1_RTS_RTH_MULTI_IT_EN_MODE;
+		}
+
+		writeq(val64, &vp_reg->rxmac_vcfg1);
+	}
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_tim_configure
+ * This routine configures the tim registers of virtual path using the config
+ * passed
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_virtualpath *vpath;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+	struct vxge_hw_vp_config *config;
+
+	vpath = &hldev->virtual_paths[vp_id];
+	vp_reg = vpath->vp_reg;
+	config = vpath->vp_config;
+
+	writeq((u64)0, &vp_reg->tim_dest_addr);
+	writeq((u64)0, &vp_reg->tim_vpath_map);
+	writeq((u64)0, &vp_reg->tim_bitmap);
+	writeq((u64)0, &vp_reg->tim_remap);
+
+	if (config->ring.enable == VXGE_HW_RING_ENABLE)
+		writeq(VXGE_HW_TIM_RING_ASSN_INT_NUM(
+			(vp_id * VXGE_HW_MAX_INTR_PER_VP) +
+			VXGE_HW_VPATH_INTR_RX), &vp_reg->tim_ring_assn);
+
+	val64 = readq(&vp_reg->tim_pci_cfg);
+	val64 |= VXGE_HW_TIM_PCI_CFG_ADD_PAD;
+	writeq(val64, &vp_reg->tim_pci_cfg);
+
+	if (config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
+
+		val64 = readq(&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
+
+		if (config->tti.btimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+				0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+					config->tti.btimer_val);
+		}
+
+		val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BITMP_EN;
+
+		if (config->tti.timer_ac_en != VXGE_HW_USE_FLASH_DEFAULT) {
+			if (config->tti.timer_ac_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+		}
+
+		if (config->tti.timer_ci_en != VXGE_HW_USE_FLASH_DEFAULT) {
+			if (config->tti.timer_ci_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+		}
+
+		if (config->tti.urange_a != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(
+					config->tti.urange_a);
+		}
+
+		if (config->tti.urange_b != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(
+					config->tti.urange_b);
+		}
+
+		if (config->tti.urange_c != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(
+					config->tti.urange_c);
+		}
+
+		writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
+		val64 = readq(&vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_TX]);
+
+		if (config->tti.uec_a != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(
+						config->tti.uec_a);
+		}
+
+		if (config->tti.uec_b != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(
+						config->tti.uec_b);
+		}
+
+		if (config->tti.uec_c != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(
+						config->tti.uec_c);
+		}
+
+		if (config->tti.uec_d != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(
+						config->tti.uec_d);
+		}
+
+		writeq(val64, &vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_TX]);
+		val64 = readq(&vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_TX]);
+
+		if (config->tti.timer_ri_en != VXGE_HW_USE_FLASH_DEFAULT) {
+			if (config->tti.timer_ri_en)
+				val64 |= VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+		}
+
+		if (config->tti.rtimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					config->tti.rtimer_val);
+		}
+
+		if (config->tti.util_sel != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(0x3f);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(
+					config->tti.util_sel);
+		}
+
+		if (config->tti.ltimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					config->tti.ltimer_val);
+		}
+
+		writeq(val64, &vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_TX]);
+	}
+
+	if (config->ring.enable == VXGE_HW_RING_ENABLE) {
+
+		val64 = readq(&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_RX]);
+
+		if (config->rti.btimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+					config->rti.btimer_val);
+		}
+
+		val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BITMP_EN;
+
+		if (config->rti.timer_ac_en != VXGE_HW_USE_FLASH_DEFAULT) {
+			if (config->rti.timer_ac_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+		}
+
+		if (config->rti.timer_ci_en != VXGE_HW_USE_FLASH_DEFAULT) {
+			if (config->rti.timer_ci_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+		}
+
+		if (config->rti.urange_a != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(
+					config->rti.urange_a);
+		}
+
+		if (config->rti.urange_b != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(
+					config->rti.urange_b);
+		}
+
+		if (config->rti.urange_c != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(
+					config->rti.urange_c);
+		}
+
+		writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_RX]);
+		val64 = readq(&vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_RX]);
+
+		if (config->rti.uec_a != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(
+						config->rti.uec_a);
+		}
+
+		if (config->rti.uec_b != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(
+						config->rti.uec_b);
+		}
+
+		if (config->rti.uec_c != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(
+						config->rti.uec_c);
+		}
+
+		if (config->rti.uec_d != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(
+						config->rti.uec_d);
+		}
+
+		writeq(val64, &vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_RX]);
+		val64 = readq(&vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_RX]);
+
+		if (config->rti.timer_ri_en != VXGE_HW_USE_FLASH_DEFAULT) {
+			if (config->rti.timer_ri_en)
+				val64 |= VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+		}
+
+		if (config->rti.rtimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					config->rti.rtimer_val);
+		}
+
+		if (config->rti.util_sel != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(0x3f);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(
+					config->rti.util_sel);
+		}
+
+		if (config->rti.ltimer_val != VXGE_HW_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					config->rti.ltimer_val);
+		}
+
+		writeq(val64, &vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_RX]);
+	}
+
+	val64 = 0;
+	writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_EINTA]);
+	writeq(val64, &vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_EINTA]);
+	writeq(val64, &vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_EINTA]);
+	writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_BMAP]);
+	writeq(val64, &vp_reg->tim_cfg2_int_num[VXGE_HW_VPATH_INTR_BMAP]);
+	writeq(val64, &vp_reg->tim_cfg3_int_num[VXGE_HW_VPATH_INTR_BMAP]);
+
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_initialize
+ * This routine is the final phase of init which initializes the
+ * registers of the vpath using the configuration passed.
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_initialize(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	u32 val32;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_virtualpath *vpath;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	vpath = &hldev->virtual_paths[vp_id];
+
+	if (!(hldev->vpath_assignments & vxge_mBIT(vp_id))) {
+		status = VXGE_HW_ERR_VPATH_NOT_AVAILABLE;
+		goto exit;
+	}
+	vp_reg = vpath->vp_reg;
+
+	status =  __vxge_hw_vpath_swapper_set(vpath->vp_reg);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status =  __vxge_hw_vpath_mac_configure(hldev, vp_id);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status =  __vxge_hw_vpath_kdfc_configure(hldev, vp_id);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __vxge_hw_vpath_tim_configure(hldev, vp_id);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	writeq(0, &vp_reg->gendma_int);
+
+	val64 = readq(&vp_reg->rtdma_rd_optimization_ctrl);
+
+	/* Get MRRS value from device control */
+	status  = __vxge_hw_vpath_pci_read(vpath, 1, 0x78, &val32);
+
+	if (status == VXGE_HW_OK) {
+		val32 = (val32 & VXGE_HW_PCI_EXP_DEVCTL_READRQ) >> 12;
+		val64 &=
+		    ~(VXGE_HW_RTDMA_RD_OPTIMIZATION_CTRL_FB_FILL_THRESH(7));
+		val64 |=
+		    VXGE_HW_RTDMA_RD_OPTIMIZATION_CTRL_FB_FILL_THRESH(val32);
+
+		val64 |= VXGE_HW_RTDMA_RD_OPTIMIZATION_CTRL_FB_WAIT_FOR_SPACE;
+	}
+
+	val64 &= ~(VXGE_HW_RTDMA_RD_OPTIMIZATION_CTRL_FB_ADDR_BDRY(7));
+	val64 |=
+	    VXGE_HW_RTDMA_RD_OPTIMIZATION_CTRL_FB_ADDR_BDRY(
+		    VXGE_HW_MAX_PAYLOAD_SIZE_512);
+
+	val64 |= VXGE_HW_RTDMA_RD_OPTIMIZATION_CTRL_FB_ADDR_BDRY_EN;
+	writeq(val64, &vp_reg->rtdma_rd_optimization_ctrl);
+
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vp_initialize - Initialize Virtual Path structure
+ * This routine is the initial phase of init which resets the vpath and
+ * initializes the software support structures.
+ */
+enum vxge_hw_status
+__vxge_hw_vp_initialize(struct __vxge_hw_device *hldev, u32 vp_id,
+			struct vxge_hw_vp_config *config)
+{
+	struct __vxge_hw_virtualpath *vpath;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if (!(hldev->vpath_assignments & vxge_mBIT(vp_id))) {
+		status = VXGE_HW_ERR_VPATH_NOT_AVAILABLE;
+		goto exit;
+	}
+
+	vpath = &hldev->virtual_paths[vp_id];
+
+	vpath->vp_id = vp_id;
+	vpath->vp_open = VXGE_HW_VP_OPEN;
+	vpath->hldev = hldev;
+	vpath->vp_config = config;
+	vpath->vp_reg = hldev->vpath_reg[vp_id];
+	vpath->vpmgmt_reg = hldev->vpmgmt_reg[vp_id];
+
+	__vxge_hw_vpath_reset(hldev, vp_id);
+
+	status = __vxge_hw_vpath_reset_check(vpath);
+
+	if (status != VXGE_HW_OK) {
+		memset(vpath, 0, sizeof(struct __vxge_hw_virtualpath));
+		goto exit;
+	}
+
+	status = __vxge_hw_vpath_mgmt_read(hldev, vpath);
+
+	if (status != VXGE_HW_OK) {
+		memset(vpath, 0, sizeof(struct __vxge_hw_virtualpath));
+		goto exit;
+	}
+
+	INIT_LIST_HEAD(&vpath->vpath_handles);
+
+	vpath->sw_stats = &hldev->stats.sw_dev_info_stats.vpath_info[vp_id];
+
+	VXGE_HW_DEVICE_TIM_INT_MASK_SET(hldev->tim_int_mask0,
+		hldev->tim_int_mask1, vp_id);
+
+	status = __vxge_hw_vpath_initialize(hldev, vp_id);
+
+	if (status != VXGE_HW_OK)
+		__vxge_hw_vp_terminate(hldev, vp_id);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vp_terminate - Terminate Virtual Path structure
+ * This routine closes all channels it opened and freeup memory
+ */
+void
+__vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+	struct __vxge_hw_virtualpath *vpath;
+
+	vpath = &hldev->virtual_paths[vp_id];
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN)
+		goto exit;
+
+	VXGE_HW_DEVICE_TIM_INT_MASK_RESET(vpath->hldev->tim_int_mask0,
+		vpath->hldev->tim_int_mask1, vpath->vp_id);
+	hldev->stats.hw_dev_info_stats.vpath_info[vpath->vp_id] = NULL;
+
+	memset(vpath, 0, sizeof(struct __vxge_hw_virtualpath));
+exit:
+	return;
+}
+
+/*
+ * vxge_hw_vpath_mtu_set - Set MTU.
+ * Set new MTU value. Example, to use jumbo frames:
+ * vxge_hw_vpath_mtu_set(my_device, 9600);
+ */
+enum vxge_hw_status
+vxge_hw_vpath_mtu_set(struct __vxge_hw_vpath_handle *vp, u32 new_mtu)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_virtualpath *vpath;
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+	vpath = vp->vpath;
+
+	new_mtu += VXGE_HW_MAC_HEADER_MAX_SIZE;
+
+	if ((new_mtu < VXGE_HW_MIN_MTU) || (new_mtu > vpath->max_mtu))
+		status = VXGE_HW_ERR_INVALID_MTU_SIZE;
+
+	val64 = readq(&vpath->vp_reg->rxmac_vcfg0);
+
+	val64 &= ~VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(0x3fff);
+	val64 |= VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(new_mtu);
+
+	writeq(val64, &vpath->vp_reg->rxmac_vcfg0);
+
+	vpath->vp_config->mtu = new_mtu - VXGE_HW_MAC_HEADER_MAX_SIZE;
+
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_vpath_open - Open a virtual path on a given adapter
+ * This function is used to open access to virtual path of an
+ * adapter for offload, GRO operations. This function returns
+ * synchronously.
+ */
+enum vxge_hw_status
+vxge_hw_vpath_open(struct __vxge_hw_device *hldev,
+		   struct vxge_hw_vpath_attr *attr,
+		   struct __vxge_hw_vpath_handle **vpath_handle)
+{
+	struct __vxge_hw_virtualpath *vpath;
+	struct __vxge_hw_vpath_handle *vp;
+	enum vxge_hw_status status;
+
+	vpath = &hldev->virtual_paths[attr->vp_id];
+
+	if (vpath->vp_open == VXGE_HW_VP_OPEN) {
+		status = VXGE_HW_ERR_INVALID_STATE;
+		goto vpath_open_exit1;
+	}
+
+	status = __vxge_hw_vp_initialize(hldev, attr->vp_id,
+			&hldev->config.vp_config[attr->vp_id]);
+
+	if (status != VXGE_HW_OK)
+		goto vpath_open_exit1;
+
+	vp = (struct __vxge_hw_vpath_handle *)
+		vmalloc(sizeof(struct __vxge_hw_vpath_handle));
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto vpath_open_exit2;
+	}
+
+	memset(vp, 0, sizeof(struct __vxge_hw_vpath_handle));
+
+	vp->vpath = vpath;
+
+	if (vpath->vp_config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
+		status = __vxge_hw_fifo_create(vp, &attr->fifo_attr);
+		if (status != VXGE_HW_OK)
+			goto vpath_open_exit6;
+	}
+
+	if (vpath->vp_config->ring.enable == VXGE_HW_RING_ENABLE) {
+		status = __vxge_hw_ring_create(vp, &attr->ring_attr);
+		if (status != VXGE_HW_OK)
+			goto vpath_open_exit7;
+
+		__vxge_hw_vpath_prc_configure(hldev, attr->vp_id);
+	}
+
+	vpath->fifoh->tx_intr_num =
+		(attr->vp_id * VXGE_HW_MAX_INTR_PER_VP)  +
+			VXGE_HW_VPATH_INTR_TX;
+
+	vpath->stats_block = __vxge_hw_blockpool_block_allocate(hldev,
+				VXGE_HW_BLOCK_SIZE);
+
+	if (vpath->stats_block == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto vpath_open_exit8;
+	}
+
+	vpath->hw_stats = (struct vxge_hw_vpath_stats_hw_info *)vpath->
+			stats_block->memblock;
+	memset(vpath->hw_stats, 0,
+		sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	hldev->stats.hw_dev_info_stats.vpath_info[attr->vp_id] =
+						vpath->hw_stats;
+
+	vpath->hw_stats_sav =
+		&hldev->stats.hw_dev_info_stats.vpath_info_sav[attr->vp_id];
+	memset(vpath->hw_stats_sav, 0,
+			sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	writeq(vpath->stats_block->dma_addr, &vpath->vp_reg->stats_cfg);
+
+	status = vxge_hw_vpath_stats_enable(vp);
+	if (status != VXGE_HW_OK)
+		goto vpath_open_exit8;
+
+	list_add(&vp->item, &vpath->vpath_handles);
+
+	hldev->vpaths_deployed |= vxge_mBIT(vpath->vp_id);
+
+	*vpath_handle = vp;
+
+	attr->fifo_attr.userdata = vpath->fifoh;
+	attr->ring_attr.userdata = vpath->ringh;
+
+	return VXGE_HW_OK;
+
+vpath_open_exit8:
+	if (vpath->ringh != NULL)
+		__vxge_hw_ring_delete(vp);
+vpath_open_exit7:
+	if (vpath->fifoh != NULL)
+		__vxge_hw_fifo_delete(vp);
+vpath_open_exit6:
+	vfree(vp);
+vpath_open_exit2:
+	__vxge_hw_vp_terminate(hldev, attr->vp_id);
+vpath_open_exit1:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_rx_doorbell_post - Close the handle got from previous vpath
+ * (vpath) open
+ * @vp: Handle got from previous vpath open
+ *
+ * This function is used to close access to virtual path opened
+ * earlier.
+ */
+void
+vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp)
+{
+	struct __vxge_hw_virtualpath *vpath = NULL;
+	u64 new_count, val64, val164;
+	struct __vxge_hw_ring *ring;
+
+	vpath = vp->vpath;
+	ring = vpath->ringh;
+
+	new_count = readq(&vpath->vp_reg->rxdmem_size);
+	new_count &= 0x1fff;
+	val164 = (VXGE_HW_RXDMEM_SIZE_PRC_RXDMEM_SIZE(new_count));
+
+	writeq(VXGE_HW_PRC_RXD_DOORBELL_NEW_QW_CNT(val164),
+		&vpath->vp_reg->prc_rxd_doorbell);
+	readl(&vpath->vp_reg->prc_rxd_doorbell);
+
+	val164 /= 2;
+	val64 = readq(&vpath->vp_reg->prc_cfg6);
+	val64 = VXGE_HW_PRC_CFG6_RXD_SPAT(val64);
+	val64 &= 0x1ff;
+
+	/*
+	 * Each RxD is of 4 qwords
+	 */
+	new_count -= (val64 + 1);
+	val64 = min(val164, new_count) / 4;
+
+	ring->rxds_limit = min(ring->rxds_limit, val64);
+	if (ring->rxds_limit < 4)
+		ring->rxds_limit = 4;
+}
+
+/*
+ * vxge_hw_vpath_close - Close the handle got from previous vpath (vpath) open
+ * This function is used to close access to virtual path opened
+ * earlier.
+ */
+enum vxge_hw_status vxge_hw_vpath_close(struct __vxge_hw_vpath_handle *vp)
+{
+	struct __vxge_hw_virtualpath *vpath = NULL;
+	struct __vxge_hw_device *devh = NULL;
+	u32 vp_id = vp->vpath->vp_id;
+	u32 is_empty = TRUE;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vpath = vp->vpath;
+	devh = vpath->hldev;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto vpath_close_exit;
+	}
+
+	list_del(&vp->item);
+
+	if (!list_empty(&vpath->vpath_handles)) {
+		list_add(&vp->item, &vpath->vpath_handles);
+		is_empty = FALSE;
+	}
+
+	if (!is_empty) {
+		status = VXGE_HW_FAIL;
+		goto vpath_close_exit;
+	}
+
+	devh->vpaths_deployed &= ~vxge_mBIT(vp_id);
+
+	if (vpath->ringh != NULL)
+		__vxge_hw_ring_delete(vp);
+
+	if (vpath->fifoh != NULL)
+		__vxge_hw_fifo_delete(vp);
+
+	if (vpath->stats_block != NULL)
+		__vxge_hw_blockpool_block_free(devh, vpath->stats_block);
+
+	vfree(vp);
+
+	__vxge_hw_vp_terminate(devh, vp_id);
+
+	vpath->vp_open = VXGE_HW_VP_NOT_OPEN;
+
+vpath_close_exit:
+	return status;
+}
+
+/*
+ * vxge_hw_vpath_reset - Resets vpath
+ * This function is used to request a reset of vpath
+ */
+enum vxge_hw_status vxge_hw_vpath_reset(struct __vxge_hw_vpath_handle *vp)
+{
+	enum vxge_hw_status status;
+	u32 vp_id;
+	struct __vxge_hw_virtualpath *vpath = vp->vpath;
+
+	vp_id = vpath->vp_id;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	status = __vxge_hw_vpath_reset(vpath->hldev, vp_id);
+	if (status == VXGE_HW_OK)
+		vpath->sw_stats->soft_reset_cnt++;
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_vpath_recover_from_reset - Poll for reset complete and re-initialize.
+ * This function poll's for the vpath reset completion and re initializes
+ * the vpath.
+ */
+enum vxge_hw_status
+vxge_hw_vpath_recover_from_reset(struct __vxge_hw_vpath_handle *vp)
+{
+	struct __vxge_hw_virtualpath *vpath = NULL;
+	enum vxge_hw_status status;
+	struct __vxge_hw_device *hldev;
+	u32 vp_id;
+
+	vp_id = vp->vpath->vp_id;
+	vpath = vp->vpath;
+	hldev = vpath->hldev;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	status = __vxge_hw_vpath_reset_check(vpath);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __vxge_hw_vpath_sw_reset(hldev, vp_id);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __vxge_hw_vpath_initialize(hldev, vp_id);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	if (vpath->ringh != NULL)
+		__vxge_hw_vpath_prc_configure(hldev, vp_id);
+
+	memset(vpath->hw_stats, 0,
+		sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	memset(vpath->hw_stats_sav, 0,
+		sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	writeq(vpath->stats_block->dma_addr,
+		&vpath->vp_reg->stats_cfg);
+
+	status = vxge_hw_vpath_stats_enable(vp);
+
+exit:
+	return status;
+}
+
+/*
+ * vxge_hw_vpath_enable - Enable vpath.
+ * This routine clears the vpath reset thereby enabling a vpath
+ * to start forwarding frames and generating interrupts.
+ */
+void
+vxge_hw_vpath_enable(struct __vxge_hw_vpath_handle *vp)
+{
+	struct __vxge_hw_device *hldev;
+	u64 val64;
+
+	hldev = vp->vpath->hldev;
+
+	val64 = VXGE_HW_CMN_RSTHDLR_CFG1_CLR_VPATH_RESET(
+		1 << (16 - vp->vpath->vp_id));
+
+	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32),
+		&hldev->common_reg->cmn_rsthdlr_cfg1);
+}
+
+/*
+ * vxge_hw_vpath_stats_enable - Enable vpath h/wstatistics.
+ * Enable the DMA vpath statistics. The function is to be called to re-enable
+ * the adapter to update stats into the host memory
+ */
+enum vxge_hw_status
+vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vp)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_virtualpath *vpath;
+
+	vpath = vp->vpath;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	memcpy(vpath->hw_stats_sav, vpath->hw_stats,
+			sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	status = __vxge_hw_vpath_stats_get(vpath, vpath->hw_stats);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_stats_access - Get the statistics from the given location
+ *                           and offset and perform an operation
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_stats_access(struct __vxge_hw_virtualpath *vpath,
+			     u32 operation, u32 offset, u64 *stat)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto vpath_stats_access_exit;
+	}
+
+	vp_reg = vpath->vp_reg;
+
+	val64 =  VXGE_HW_XMAC_STATS_ACCESS_CMD_OP(operation) |
+		 VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE |
+		 VXGE_HW_XMAC_STATS_ACCESS_CMD_OFFSET_SEL(offset);
+
+	status = __vxge_hw_pio_mem_write64(val64,
+				&vp_reg->xmac_stats_access_cmd,
+				VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE,
+				vpath->hldev->config.device_poll_millis);
+
+	if ((status == VXGE_HW_OK) && (operation == VXGE_HW_STATS_OP_READ))
+		*stat = readq(&vp_reg->xmac_stats_access_data);
+	else
+		*stat = 0;
+
+vpath_stats_access_exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_xmac_tx_stats_get - Get the TX Statistics of a vpath
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_xmac_tx_stats_get(
+	struct __vxge_hw_virtualpath *vpath,
+	struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats)
+{
+	u64 *val64;
+	int i;
+	u32 offset = VXGE_HW_STATS_VPATH_TX_OFFSET;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	val64 = (u64 *) vpath_tx_stats;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_tx_stats) / 8; i++) {
+		status = __vxge_hw_vpath_stats_access(vpath,
+					VXGE_HW_STATS_OP_READ,
+					offset, val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+		offset++;
+		val64++;
+	}
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_xmac_rx_stats_get - Get the RX Statistics of a vpath
+ */
+enum vxge_hw_status
+__vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath *vpath,
+			struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats)
+{
+	u64 *val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	int i;
+	u32 offset = VXGE_HW_STATS_VPATH_RX_OFFSET;
+	val64 = (u64 *) vpath_rx_stats;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_rx_stats) / 8; i++) {
+		status = __vxge_hw_vpath_stats_access(vpath,
+					VXGE_HW_STATS_OP_READ,
+					offset >> 3, val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		offset += 8;
+		val64++;
+	}
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_vpath_stats_get - Get the vpath hw statistics.
+ */
+enum vxge_hw_status __vxge_hw_vpath_stats_get(
+			struct __vxge_hw_virtualpath *vpath,
+			struct vxge_hw_vpath_stats_hw_info *hw_stats)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+	vp_reg = vpath->vp_reg;
+
+	val64 = readq(&vp_reg->vpath_debug_stats0);
+	hw_stats->ini_num_mwr_sent =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS0_GET_INI_NUM_MWR_SENT(val64);
+
+	val64 = readq(&vp_reg->vpath_debug_stats1);
+	hw_stats->ini_num_mrd_sent =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS1_GET_INI_NUM_MRD_SENT(val64);
+
+	val64 = readq(&vp_reg->vpath_debug_stats2);
+	hw_stats->ini_num_cpl_rcvd =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS2_GET_INI_NUM_CPL_RCVD(val64);
+
+	val64 = readq(&vp_reg->vpath_debug_stats3);
+	hw_stats->ini_num_mwr_byte_sent =
+		VXGE_HW_VPATH_DEBUG_STATS3_GET_INI_NUM_MWR_BYTE_SENT(val64);
+
+	val64 = readq(&vp_reg->vpath_debug_stats4);
+	hw_stats->ini_num_cpl_byte_rcvd =
+		VXGE_HW_VPATH_DEBUG_STATS4_GET_INI_NUM_CPL_BYTE_RCVD(val64);
+
+	val64 = readq(&vp_reg->vpath_debug_stats5);
+	hw_stats->wrcrdtarb_xoff =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS5_GET_WRCRDTARB_XOFF(val64);
+
+	val64 = readq(&vp_reg->vpath_debug_stats6);
+	hw_stats->rdcrdtarb_xoff =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS6_GET_RDCRDTARB_XOFF(val64);
+
+	val64 = readq(&vp_reg->vpath_genstats_count01);
+	hw_stats->vpath_genstats_count0 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT0(
+		val64);
+
+	val64 = readq(&vp_reg->vpath_genstats_count01);
+	hw_stats->vpath_genstats_count1 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT1(
+		val64);
+
+	val64 = readq(&vp_reg->vpath_genstats_count23);
+	hw_stats->vpath_genstats_count2 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT2(
+		val64);
+
+	val64 = readq(&vp_reg->vpath_genstats_count01);
+	hw_stats->vpath_genstats_count3 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT3(
+		val64);
+
+	val64 = readq(&vp_reg->vpath_genstats_count4);
+	hw_stats->vpath_genstats_count4 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT4_GET_PPIF_VPATH_GENSTATS_COUNT4(
+		val64);
+
+	val64 = readq(&vp_reg->vpath_genstats_count5);
+	hw_stats->vpath_genstats_count5 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT5_GET_PPIF_VPATH_GENSTATS_COUNT5(
+		val64);
+
+	status = __vxge_hw_vpath_xmac_tx_stats_get(vpath, &hw_stats->tx_stats);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __vxge_hw_vpath_xmac_rx_stats_get(vpath, &hw_stats->rx_stats);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	VXGE_HW_VPATH_STATS_PIO_READ(
+		VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM0_OFFSET);
+
+	hw_stats->prog_event_vnum0 =
+			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM0(val64);
+
+	hw_stats->prog_event_vnum1 =
+			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM1(val64);
+
+	VXGE_HW_VPATH_STATS_PIO_READ(
+		VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM2_OFFSET);
+
+	hw_stats->prog_event_vnum2 =
+			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM2(val64);
+
+	hw_stats->prog_event_vnum3 =
+			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM3(val64);
+
+	val64 = readq(&vp_reg->rx_multi_cast_stats);
+	hw_stats->rx_multi_cast_frame_discard =
+		(u16)VXGE_HW_RX_MULTI_CAST_STATS_GET_FRAME_DISCARD(val64);
+
+	val64 = readq(&vp_reg->rx_frm_transferred);
+	hw_stats->rx_frm_transferred =
+		(u32)VXGE_HW_RX_FRM_TRANSFERRED_GET_RX_FRM_TRANSFERRED(val64);
+
+	val64 = readq(&vp_reg->rxd_returned);
+	hw_stats->rxd_returned =
+		(u16)VXGE_HW_RXD_RETURNED_GET_RXD_RETURNED(val64);
+
+	val64 = readq(&vp_reg->dbg_stats_rx_mpa);
+	hw_stats->rx_mpa_len_fail_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_LEN_FAIL_FRMS(val64);
+	hw_stats->rx_mpa_mrk_fail_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_MRK_FAIL_FRMS(val64);
+	hw_stats->rx_mpa_crc_fail_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_CRC_FAIL_FRMS(val64);
+
+	val64 = readq(&vp_reg->dbg_stats_rx_fau);
+	hw_stats->rx_permitted_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_PERMITTED_FRMS(val64);
+	hw_stats->rx_vp_reset_discarded_frms =
+	(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_VP_RESET_DISCARDED_FRMS(val64);
+	hw_stats->rx_wol_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_WOL_FRMS(val64);
+
+	val64 = readq(&vp_reg->tx_vp_reset_discarded_frms);
+	hw_stats->tx_vp_reset_discarded_frms =
+	(u16)VXGE_HW_TX_VP_RESET_DISCARDED_FRMS_GET_TX_VP_RESET_DISCARDED_FRMS(
+		val64);
+exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_blockpool_create - Create block pool
+ */
+
+enum vxge_hw_status
+__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
+			   struct __vxge_hw_blockpool *blockpool,
+			   u32 pool_size,
+			   u32 pool_max)
+{
+	u32 i;
+	struct __vxge_hw_blockpool_entry *entry = NULL;
+	void *memblock;
+	dma_addr_t dma_addr;
+	struct pci_dev *dma_handle;
+	struct pci_dev *acc_handle;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if (blockpool == NULL) {
+		status = VXGE_HW_FAIL;
+		goto blockpool_create_exit;
+	}
+
+	blockpool->hldev = hldev;
+	blockpool->block_size = VXGE_HW_BLOCK_SIZE;
+	blockpool->pool_size = 0;
+	blockpool->pool_max = pool_max;
+	blockpool->req_out = 0;
+
+	INIT_LIST_HEAD(&blockpool->free_block_list);
+	INIT_LIST_HEAD(&blockpool->free_entry_list);
+
+	for (i = 0; i < pool_size + pool_max; i++) {
+		entry = kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
+				GFP_KERNEL);
+		if (entry == NULL) {
+			__vxge_hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+		list_add(&entry->item, &blockpool->free_entry_list);
+	}
+
+	for (i = 0; i < pool_size; i++) {
+
+		memblock = vxge_os_dma_malloc(
+				hldev->pdev,
+				VXGE_HW_BLOCK_SIZE,
+				&dma_handle,
+				&acc_handle);
+
+		if (memblock == NULL) {
+			__vxge_hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+
+		dma_addr = pci_map_single(hldev->pdev, memblock,
+				VXGE_HW_BLOCK_SIZE, PCI_DMA_BIDIRECTIONAL);
+
+		if (unlikely(pci_dma_mapping_error(hldev->pdev,
+				dma_addr))) {
+
+			vxge_os_dma_free(hldev->pdev, memblock, &acc_handle);
+			__vxge_hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+
+		if (!list_empty(&blockpool->free_entry_list))
+			entry = (struct __vxge_hw_blockpool_entry *)
+				list_first_entry(&blockpool->free_entry_list,
+					struct __vxge_hw_blockpool_entry,
+					item);
+
+		if (entry == NULL)
+			entry =
+			    kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
+					GFP_KERNEL);
+		if (entry != NULL) {
+			list_del(&entry->item);
+			entry->length = VXGE_HW_BLOCK_SIZE;
+			entry->memblock = memblock;
+			entry->dma_addr = dma_addr;
+			entry->acc_handle = acc_handle;
+			entry->dma_handle = dma_handle;
+			list_add(&entry->item,
+					  &blockpool->free_block_list);
+			blockpool->pool_size++;
+		} else {
+			__vxge_hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+	}
+
+blockpool_create_exit:
+	return status;
+}
+
+/*
+ * __vxge_hw_blockpool_destroy - Deallocates the block pool
+ */
+
+void __vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool *blockpool)
+{
+
+	struct __vxge_hw_device *hldev;
+	struct list_head *p, *n;
+	u16 ret;
+
+	if (blockpool == NULL) {
+		ret = 1;
+		goto exit;
+	}
+
+	hldev = blockpool->hldev;
+
+	list_for_each_safe(p, n, &blockpool->free_block_list) {
+
+		pci_unmap_single(hldev->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
+			((struct __vxge_hw_blockpool_entry *)p)->length,
+			PCI_DMA_BIDIRECTIONAL);
+
+		vxge_os_dma_free(hldev->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->memblock,
+			&((struct __vxge_hw_blockpool_entry *) p)->acc_handle);
+
+		list_del(
+			&((struct __vxge_hw_blockpool_entry *)p)->item);
+		kfree(p);
+		blockpool->pool_size--;
+	}
+
+	list_for_each_safe(p, n, &blockpool->free_entry_list) {
+		list_del(
+			&((struct __vxge_hw_blockpool_entry *)p)->item);
+		kfree((void *)p);
+	}
+	ret = 0;
+exit:
+	return;
+}
+
+/*
+ * __vxge_hw_blockpool_blocks_add - Request additional blocks
+ */
+static
+void __vxge_hw_blockpool_blocks_add(struct __vxge_hw_blockpool *blockpool)
+{
+	u32 nreq = 0, i;
+
+	if ((blockpool->pool_size  +  blockpool->req_out) <
+		VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE) {
+		nreq = VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE;
+		blockpool->req_out += nreq;
+	}
+
+	for (i = 0; i < nreq; i++)
+		vxge_os_dma_malloc_async(
+			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			blockpool->hldev, VXGE_HW_BLOCK_SIZE);
+}
+
+/*
+ * __vxge_hw_blockpool_blocks_remove - Free additional blocks
+ */
+static
+void __vxge_hw_blockpool_blocks_remove(struct __vxge_hw_blockpool *blockpool)
+{
+	struct list_head *p, *n;
+
+	list_for_each_safe(p, n, &blockpool->free_block_list) {
+
+		if (blockpool->pool_size < blockpool->pool_max)
+			break;
+
+		pci_unmap_single(
+			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
+			((struct __vxge_hw_blockpool_entry *)p)->length,
+			PCI_DMA_BIDIRECTIONAL);
+
+		vxge_os_dma_free(
+			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->memblock,
+			&((struct __vxge_hw_blockpool_entry *)p)->acc_handle);
+
+		list_del(&((struct __vxge_hw_blockpool_entry *)p)->item);
+
+		list_add(p, &blockpool->free_entry_list);
+
+		blockpool->pool_size--;
+
+	}
+}
+
+/*
+ * vxge_hw_blockpool_block_add - callback for vxge_os_dma_malloc_async
+ * Adds a block to block pool
+ */
+void vxge_hw_blockpool_block_add(
+			struct __vxge_hw_device *devh,
+			void *block_addr,
+			u32 length,
+			struct pci_dev *dma_h,
+			struct pci_dev *acc_handle)
+{
+	struct __vxge_hw_blockpool  *blockpool;
+	struct __vxge_hw_blockpool_entry  *entry = NULL;
+	dma_addr_t dma_addr;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u32 req_out;
+
+	blockpool = &devh->block_pool;
+
+	if (block_addr == NULL) {
+		blockpool->req_out--;
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	dma_addr = pci_map_single(devh->pdev, block_addr, length,
+				PCI_DMA_BIDIRECTIONAL);
+
+	if (unlikely(pci_dma_mapping_error(devh->pdev, dma_addr))) {
+
+		vxge_os_dma_free(devh->pdev, block_addr, &acc_handle);
+		blockpool->req_out--;
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+
+	if (!list_empty(&blockpool->free_entry_list))
+		entry = (struct __vxge_hw_blockpool_entry *)
+			list_first_entry(&blockpool->free_entry_list,
+				struct __vxge_hw_blockpool_entry,
+				item);
+
+	if (entry == NULL)
+		entry = (struct __vxge_hw_blockpool_entry *)
+			vmalloc(sizeof(struct __vxge_hw_blockpool_entry));
+	else
+		list_del(&entry->item);
+
+	if (entry != NULL) {
+		entry->length = length;
+		entry->memblock = block_addr;
+		entry->dma_addr = dma_addr;
+		entry->acc_handle = acc_handle;
+		entry->dma_handle = dma_h;
+		list_add(&entry->item, &blockpool->free_block_list);
+		blockpool->pool_size++;
+		status = VXGE_HW_OK;
+	} else
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+
+	blockpool->req_out--;
+
+	req_out = blockpool->req_out;
+exit:
+	return;
+}
+
+/*
+ * __vxge_hw_blockpool_malloc - Allocate a memory block from pool
+ * Allocates a block of memory of given size, either from block pool
+ * or by calling vxge_os_dma_malloc()
+ */
+void *
+__vxge_hw_blockpool_malloc(struct __vxge_hw_device *devh, u32 size,
+				struct vxge_hw_mempool_dma *dma_object)
+{
+	struct __vxge_hw_blockpool_entry *entry = NULL;
+	struct __vxge_hw_blockpool  *blockpool;
+	void *memblock = NULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	blockpool = &devh->block_pool;
+
+	if (size != blockpool->block_size) {
+
+		memblock = vxge_os_dma_malloc(devh->pdev, size,
+						&dma_object->handle,
+						&dma_object->acc_handle);
+
+		if (memblock == NULL) {
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+		dma_object->addr = pci_map_single(devh->pdev, memblock, size,
+					PCI_DMA_BIDIRECTIONAL);
+
+		if (unlikely(pci_dma_mapping_error(devh->pdev,
+				dma_object->addr))) {
+			vxge_os_dma_free(devh->pdev, memblock,
+				&dma_object->acc_handle);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+	} else {
+
+		if (!list_empty(&blockpool->free_block_list))
+			entry = (struct __vxge_hw_blockpool_entry *)
+				list_first_entry(&blockpool->free_block_list,
+					struct __vxge_hw_blockpool_entry,
+					item);
+
+		if (entry != NULL) {
+			list_del(&entry->item);
+			dma_object->addr = entry->dma_addr;
+			dma_object->handle = entry->dma_handle;
+			dma_object->acc_handle = entry->acc_handle;
+			memblock = entry->memblock;
+
+			list_add(&entry->item,
+				&blockpool->free_entry_list);
+			blockpool->pool_size--;
+		}
+
+		if (memblock != NULL)
+			__vxge_hw_blockpool_blocks_add(blockpool);
+	}
+exit:
+	return memblock;
+}
+
+/*
+ * __vxge_hw_blockpool_free - Frees the memory allcoated with
+				__vxge_hw_blockpool_malloc
+ */
+void
+__vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
+			void *memblock, u32 size,
+			struct vxge_hw_mempool_dma *dma_object)
+{
+	struct __vxge_hw_blockpool_entry *entry = NULL;
+	struct __vxge_hw_blockpool  *blockpool;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	blockpool = &devh->block_pool;
+
+	if (size != blockpool->block_size) {
+		pci_unmap_single(devh->pdev, dma_object->addr, size,
+			PCI_DMA_BIDIRECTIONAL);
+		vxge_os_dma_free(devh->pdev, memblock, &dma_object->acc_handle);
+	} else {
+
+		if (!list_empty(&blockpool->free_entry_list))
+			entry = (struct __vxge_hw_blockpool_entry *)
+				list_first_entry(&blockpool->free_entry_list,
+					struct __vxge_hw_blockpool_entry,
+					item);
+
+		if (entry == NULL)
+			entry = (struct __vxge_hw_blockpool_entry *)
+				vmalloc(sizeof(
+					struct __vxge_hw_blockpool_entry));
+		else
+			list_del(&entry->item);
+
+		if (entry != NULL) {
+			entry->length = size;
+			entry->memblock = memblock;
+			entry->dma_addr = dma_object->addr;
+			entry->acc_handle = dma_object->acc_handle;
+			entry->dma_handle = dma_object->handle;
+			list_add(&entry->item,
+					&blockpool->free_block_list);
+			blockpool->pool_size++;
+			status = VXGE_HW_OK;
+		} else
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+
+		if (status == VXGE_HW_OK)
+			__vxge_hw_blockpool_blocks_remove(blockpool);
+	}
+
+	return;
+}
+
+/*
+ * __vxge_hw_blockpool_block_allocate - Allocates a block from block pool
+ * This function allocates a block from block pool or from the system
+ */
+struct __vxge_hw_blockpool_entry *
+__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *devh, u32 size)
+{
+	struct __vxge_hw_blockpool_entry *entry = NULL;
+	struct __vxge_hw_blockpool  *blockpool;
+
+	blockpool = &devh->block_pool;
+
+	if (size == blockpool->block_size) {
+
+		if (!list_empty(&blockpool->free_block_list))
+			entry = (struct __vxge_hw_blockpool_entry *)
+				list_first_entry(&blockpool->free_block_list,
+					struct __vxge_hw_blockpool_entry,
+					item);
+
+		if (entry != NULL) {
+			list_del(&entry->item);
+			blockpool->pool_size--;
+		}
+	}
+
+	if (entry != NULL)
+		__vxge_hw_blockpool_blocks_add(blockpool);
+
+	return entry;
+}
+
+/*
+ * __vxge_hw_blockpool_block_free - Frees a block from block pool
+ * @devh: Hal device
+ * @entry: Entry of block to be freed
+ *
+ * This function frees a block from block pool
+ */
+void
+__vxge_hw_blockpool_block_free(struct __vxge_hw_device *devh,
+			struct __vxge_hw_blockpool_entry *entry)
+{
+	struct __vxge_hw_blockpool  *blockpool;
+
+	blockpool = &devh->block_pool;
+
+	if (entry->length == blockpool->block_size) {
+		list_add(&entry->item, &blockpool->free_block_list);
+		blockpool->pool_size++;
+	}
+
+	__vxge_hw_blockpool_blocks_remove(blockpool);
+
+	return;
+}
diff -urpN patch_3/drivers/net/vxge/vxge-config.h patch_4/drivers/net/vxge/vxge-config.h
--- patch_3/drivers/net/vxge/vxge-config.h	1969-12-31 16:00:00.000000000 -0800
+++ patch_4/drivers/net/vxge/vxge-config.h	2009-04-01 13:27:01.000000000 -0700
@@ -0,0 +1,2259 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ *
+ * vxge-config.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *                Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#ifndef VXGE_CONFIG_H
+#define VXGE_CONFIG_H
+#include <linux/list.h>
+
+#ifndef VXGE_CACHE_LINE_SIZE
+#define VXGE_CACHE_LINE_SIZE 128
+#endif
+
+#define vxge_os_vaprintf(level, mask, fmt, ...) { \
+	char buff[255]; \
+		snprintf(buff, 255, fmt, __VA_ARGS__); \
+		printk(buff); \
+		printk("\n"); \
+}
+
+#ifndef VXGE_ALIGN
+#define VXGE_ALIGN(adrs, size) \
+	(((size) - (((u64)adrs) & ((size)-1))) & ((size)-1))
+#endif
+
+#define VXGE_HW_MIN_MTU				68
+#define VXGE_HW_MAX_MTU				9600
+#define VXGE_HW_DEFAULT_MTU			1500
+
+#ifdef VXGE_DEBUG_ASSERT
+
+/**
+ * vxge_assert
+ * @test: C-condition to check
+ * @fmt: printf like format string
+ *
+ * This function implements traditional assert. By default assertions
+ * are enabled. It can be disabled by undefining VXGE_DEBUG_ASSERT macro in
+ * compilation
+ * time.
+ */
+#define vxge_assert(test) { \
+	if (!(test)) \
+		vxge_os_bug("bad cond: "#test" at %s:%d\n", \
+				__FILE__, __LINE__); }
+#else
+#define vxge_assert(test)
+#endif /* end of VXGE_DEBUG_ASSERT */
+
+/**
+ * enum enum vxge_debug_level
+ * @VXGE_NONE: debug disabled
+ * @VXGE_ERR: all errors going to be logged out
+ * @VXGE_TRACE: all errors plus all kind of verbose tracing print outs
+ *                 going to be logged out. Very noisy.
+ *
+ * This enumeration going to be used to switch between different
+ * debug levels during runtime if DEBUG macro defined during
+ * compilation. If DEBUG macro not defined than code will be
+ * compiled out.
+ */
+enum vxge_debug_level {
+	VXGE_NONE   = 0,
+	VXGE_TRACE  = 1,
+	VXGE_ERR    = 2
+};
+
+#define NULL_VPID					0xFFFFFFFF
+#ifdef CONFIG_VXGE_DEBUG_TRACE_ALL
+#define VXGE_DEBUG_MODULE_MASK  0xffffffff
+#define VXGE_DEBUG_TRACE_MASK   0xffffffff
+#define VXGE_DEBUG_ERR_MASK     0xffffffff
+#define VXGE_DEBUG_MASK         0x000001ff
+#else
+#define VXGE_DEBUG_MODULE_MASK  0x20000000
+#define VXGE_DEBUG_TRACE_MASK   0x20000000
+#define VXGE_DEBUG_ERR_MASK     0x20000000
+#define VXGE_DEBUG_MASK         0x00000001
+#endif
+
+/*
+ * @VXGE_COMPONENT_LL: do debug for vxge link layer module
+ * @VXGE_COMPONENT_ALL: activate debug for all modules with no exceptions
+ *
+ * This enumeration going to be used to distinguish modules
+ * or libraries during compilation and runtime.  Makefile must declare
+ * VXGE_DEBUG_MODULE_MASK macro and set it to proper value.
+ */
+#define	VXGE_COMPONENT_LL				0x20000000
+#define	VXGE_COMPONENT_ALL				0xffffffff
+
+#define VXGE_HW_BASE_INF	100
+#define VXGE_HW_BASE_ERR	200
+#define VXGE_HW_BASE_BADCFG	300
+
+enum vxge_hw_status {
+	VXGE_HW_OK				  = 0,
+	VXGE_HW_FAIL				  = 1,
+	VXGE_HW_PENDING				  = 2,
+	VXGE_HW_COMPLETIONS_REMAIN		  = 3,
+
+	VXGE_HW_INF_NO_MORE_COMPLETED_DESCRIPTORS = VXGE_HW_BASE_INF + 1,
+	VXGE_HW_INF_OUT_OF_DESCRIPTORS		  = VXGE_HW_BASE_INF + 2,
+
+	VXGE_HW_ERR_INVALID_HANDLE		  = VXGE_HW_BASE_ERR + 1,
+	VXGE_HW_ERR_OUT_OF_MEMORY		  = VXGE_HW_BASE_ERR + 2,
+	VXGE_HW_ERR_VPATH_NOT_AVAILABLE	  	  = VXGE_HW_BASE_ERR + 3,
+	VXGE_HW_ERR_VPATH_NOT_OPEN		  = VXGE_HW_BASE_ERR + 4,
+	VXGE_HW_ERR_WRONG_IRQ			  = VXGE_HW_BASE_ERR + 5,
+	VXGE_HW_ERR_SWAPPER_CTRL		  = VXGE_HW_BASE_ERR + 6,
+	VXGE_HW_ERR_INVALID_MTU_SIZE		  = VXGE_HW_BASE_ERR + 7,
+	VXGE_HW_ERR_INVALID_INDEX		  = VXGE_HW_BASE_ERR + 8,
+	VXGE_HW_ERR_INVALID_TYPE		  = VXGE_HW_BASE_ERR + 9,
+	VXGE_HW_ERR_INVALID_OFFSET		  = VXGE_HW_BASE_ERR + 10,
+	VXGE_HW_ERR_INVALID_DEVICE		  = VXGE_HW_BASE_ERR + 11,
+	VXGE_HW_ERR_VERSION_CONFLICT		  = VXGE_HW_BASE_ERR + 12,
+	VXGE_HW_ERR_INVALID_PCI_INFO		  = VXGE_HW_BASE_ERR + 13,
+	VXGE_HW_ERR_INVALID_TCODE 		  = VXGE_HW_BASE_ERR + 14,
+	VXGE_HW_ERR_INVALID_BLOCK_SIZE		  = VXGE_HW_BASE_ERR + 15,
+	VXGE_HW_ERR_INVALID_STATE		  = VXGE_HW_BASE_ERR + 16,
+	VXGE_HW_ERR_PRIVILAGED_OPEARATION	  = VXGE_HW_BASE_ERR + 17,
+	VXGE_HW_ERR_INVALID_PORT 		  = VXGE_HW_BASE_ERR + 18,
+	VXGE_HW_ERR_FIFO		 	  = VXGE_HW_BASE_ERR + 19,
+	VXGE_HW_ERR_VPATH			  = VXGE_HW_BASE_ERR + 20,
+	VXGE_HW_ERR_CRITICAL			  = VXGE_HW_BASE_ERR + 21,
+	VXGE_HW_ERR_SLOT_FREEZE 		  = VXGE_HW_BASE_ERR + 22,
+
+	VXGE_HW_BADCFG_RING_INDICATE_MAX_PKTS	  = VXGE_HW_BASE_BADCFG + 1,
+	VXGE_HW_BADCFG_FIFO_BLOCKS		  = VXGE_HW_BASE_BADCFG + 2,
+	VXGE_HW_BADCFG_VPATH_MTU		  = VXGE_HW_BASE_BADCFG + 3,
+	VXGE_HW_BADCFG_VPATH_RPA_STRIP_VLAN_TAG	  = VXGE_HW_BASE_BADCFG + 4,
+	VXGE_HW_BADCFG_VPATH_MIN_BANDWIDTH	  = VXGE_HW_BASE_BADCFG + 5,
+	VXGE_HW_BADCFG_INTR_MODE		  = VXGE_HW_BASE_BADCFG + 6,
+	VXGE_HW_BADCFG_RTS_MAC_EN		  = VXGE_HW_BASE_BADCFG + 7,
+
+	VXGE_HW_EOF_TRACE_BUF			  = -1
+};
+
+/**
+ * enum enum vxge_hw_device_link_state - Link state enumeration.
+ * @VXGE_HW_LINK_NONE: Invalid link state.
+ * @VXGE_HW_LINK_DOWN: Link is down.
+ * @VXGE_HW_LINK_UP: Link is up.
+ *
+ */
+enum vxge_hw_device_link_state {
+	VXGE_HW_LINK_NONE,
+	VXGE_HW_LINK_DOWN,
+	VXGE_HW_LINK_UP
+};
+
+/**
+ * struct vxge_hw_device_date - Date Format
+ * @day: Day
+ * @month: Month
+ * @year: Year
+ * @date: Date in string format
+ *
+ * Structure for returning date
+ */
+
+#define VXGE_HW_FW_STRLEN	32
+struct vxge_hw_device_date {
+	u32     day;
+	u32     month;
+	u32     year;
+	char    date[VXGE_HW_FW_STRLEN];
+};
+
+struct vxge_hw_device_version {
+	u32     major;
+	u32     minor;
+	u32     build;
+	char    version[VXGE_HW_FW_STRLEN];
+};
+
+u64
+__vxge_hw_vpath_pci_func_mode_get(
+	u32 vp_id,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg);
+
+/**
+ * struct vxge_hw_fifo_config - Configuration of fifo.
+ * @enable: Is this fifo to be commissioned
+ * @fifo_blocks: Numbers of TxDL (that is, lists of Tx descriptors)
+ * 		blocks per queue.
+ * @max_frags: Max number of Tx buffers per TxDL (that is, per single
+ *             transmit operation).
+ *             No more than 256 transmit buffers can be specified.
+ * @memblock_size: Fifo descriptors are allocated in blocks of @mem_block_size
+ *             bytes. Setting @memblock_size to page size ensures
+ *             by-page allocation of descriptors. 128K bytes is the
+ *             maximum supported block size.
+ * @alignment_size: per Tx fragment DMA-able memory used to align transmit data
+ *             (e.g., to align on a cache line).
+ * @intr: Boolean. Use 1 to generate interrupt for each completed TxDL.
+ *             Use 0 otherwise.
+ * @no_snoop_bits: If non-zero, specifies no-snoop PCI operation,
+ *             which generally improves latency of the host bridge operation
+ *             (see PCI specification). For valid values please refer
+ *             to struct vxge_hw_fifo_config{} in the driver sources.
+ * Configuration of all Titan fifos.
+ * Note: Valid (min, max) range for each attribute is specified in the body of
+ * the struct vxge_hw_fifo_config{} structure.
+ */
+struct vxge_hw_fifo_config {
+	u32				enable;
+#define VXGE_HW_FIFO_ENABLE				1
+#define VXGE_HW_FIFO_DISABLE				0
+
+	u32				fifo_blocks;
+#define VXGE_HW_MIN_FIFO_BLOCKS				2
+#define VXGE_HW_MAX_FIFO_BLOCKS				128
+
+	u32				max_frags;
+#define VXGE_HW_MIN_FIFO_FRAGS				1
+#define VXGE_HW_MAX_FIFO_FRAGS				256
+
+	u32				memblock_size;
+#define VXGE_HW_MIN_FIFO_MEMBLOCK_SIZE			VXGE_HW_BLOCK_SIZE
+#define VXGE_HW_MAX_FIFO_MEMBLOCK_SIZE			131072
+#define VXGE_HW_DEF_FIFO_MEMBLOCK_SIZE			8096
+
+	u32		                alignment_size;
+#define VXGE_HW_MIN_FIFO_ALIGNMENT_SIZE		0
+#define VXGE_HW_MAX_FIFO_ALIGNMENT_SIZE		65536
+#define VXGE_HW_DEF_FIFO_ALIGNMENT_SIZE		VXGE_CACHE_LINE_SIZE
+
+	u32		                intr;
+#define VXGE_HW_FIFO_QUEUE_INTR_ENABLE			1
+#define VXGE_HW_FIFO_QUEUE_INTR_DISABLE			0
+#define VXGE_HW_FIFO_QUEUE_INTR_DEFAULT			0
+
+	u32				no_snoop_bits;
+#define VXGE_HW_FIFO_NO_SNOOP_DISABLED			0
+#define VXGE_HW_FIFO_NO_SNOOP_TXD			1
+#define VXGE_HW_FIFO_NO_SNOOP_FRM			2
+#define VXGE_HW_FIFO_NO_SNOOP_ALL			3
+#define VXGE_HW_FIFO_NO_SNOOP_DEFAULT			0
+
+};
+/**
+ * struct vxge_hw_ring_config - Ring configurations.
+ * @enable: Is this ring to be commissioned
+ * @ring_blocks: Numbers of RxD blocks in the ring
+ * @buffer_mode: Receive buffer mode (1, 2, 3, or 5); for details please refer
+ *             to Titan User Guide.
+ * @scatter_mode: Titan supports two receive scatter modes: A and B.
+ *             For details please refer to Titan User Guide.
+ * @rx_timer_val: The number of 32ns periods that would be counted between two
+ *             timer interrupts.
+ * @greedy_return: If Set it forces the device to return absolutely all RxD
+ *             that are consumed and still on board when a timer interrupt
+ *             triggers. If Clear, then if the device has already returned
+ *             RxD before current timer interrupt trigerred and after the
+ *             previous timer interrupt triggered, then the device is not
+ *             forced to returned the rest of the consumed RxD that it has
+ *             on board which account for a byte count less than the one
+ *             programmed into PRC_CFG6.RXD_CRXDT field
+ * @rx_timer_ci: TBD
+ * @backoff_interval_us: Time (in microseconds), after which Titan
+ *             tries to download RxDs posted by the host.
+ *             Note that the "backoff" does not happen if host posts receive
+ *             descriptors in the timely fashion.
+ * Ring configuration.
+ */
+struct vxge_hw_ring_config {
+	u32				enable;
+#define VXGE_HW_RING_ENABLE					1
+#define VXGE_HW_RING_DISABLE					0
+#define VXGE_HW_RING_DEFAULT					1
+
+	u32				ring_blocks;
+#define VXGE_HW_MIN_RING_BLOCKS				1
+#define VXGE_HW_MAX_RING_BLOCKS				128
+#define VXGE_HW_DEF_RING_BLOCKS				2
+
+	u32				buffer_mode;
+#define VXGE_HW_RING_RXD_BUFFER_MODE_1				1
+#define VXGE_HW_RING_RXD_BUFFER_MODE_3				3
+#define VXGE_HW_RING_RXD_BUFFER_MODE_5				5
+#define VXGE_HW_RING_RXD_BUFFER_MODE_DEFAULT			1
+
+	u32				scatter_mode;
+#define VXGE_HW_RING_SCATTER_MODE_A				0
+#define VXGE_HW_RING_SCATTER_MODE_B				1
+#define VXGE_HW_RING_SCATTER_MODE_C				2
+#define VXGE_HW_RING_SCATTER_MODE_USE_FLASH_DEFAULT		0xffffffff
+
+	u64				rxds_limit;
+#define VXGE_HW_DEF_RING_RXDS_LIMIT				44
+};
+
+/**
+ * struct vxge_hw_vp_config - Configuration of virtual path
+ * @vp_id: Virtual Path Id
+ * @min_bandwidth: Minimum Guaranteed bandwidth
+ * @ring: See struct vxge_hw_ring_config{}.
+ * @fifo: See struct vxge_hw_fifo_config{}.
+ * @tti: Configuration of interrupt associated with Transmit.
+ *             see struct vxge_hw_tim_intr_config();
+ * @rti: Configuration of interrupt associated with Receive.
+ *              see struct vxge_hw_tim_intr_config();
+ * @mtu: mtu size used on this port.
+ * @rpa_strip_vlan_tag: Strip VLAN Tag enable/disable. Instructs the device to
+ *             remove the VLAN tag from all received tagged frames that are not
+ *             replicated at the internal L2 switch.
+ *             0 - Do not strip the VLAN tag.
+ *             1 - Strip the VLAN tag. Regardless of this setting, VLAN tags are
+ *                 always placed into the RxDMA descriptor.
+ *
+ * This structure is used by the driver to pass the configuration parameters to
+ * configure Virtual Path.
+ */
+struct vxge_hw_vp_config {
+	u32				vp_id;
+
+#define	VXGE_HW_VPATH_PRIORITY_MIN			0
+#define	VXGE_HW_VPATH_PRIORITY_MAX			16
+#define	VXGE_HW_VPATH_PRIORITY_DEFAULT			0
+
+	u32				min_bandwidth;
+#define	VXGE_HW_VPATH_BANDWIDTH_MIN			0
+#define	VXGE_HW_VPATH_BANDWIDTH_MAX			100
+#define	VXGE_HW_VPATH_BANDWIDTH_DEFAULT			0
+
+	struct vxge_hw_ring_config		ring;
+	struct vxge_hw_fifo_config		fifo;
+	struct vxge_hw_tim_intr_config	tti;
+	struct vxge_hw_tim_intr_config	rti;
+
+	u32				mtu;
+#define VXGE_HW_VPATH_MIN_INITIAL_MTU			VXGE_HW_MIN_MTU
+#define VXGE_HW_VPATH_MAX_INITIAL_MTU			VXGE_HW_MAX_MTU
+#define VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU	0xffffffff
+
+	u32				rpa_strip_vlan_tag;
+#define VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE			1
+#define VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_DISABLE		0
+#define VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT	0xffffffff
+
+};
+/**
+ * struct vxge_hw_device_config - Device configuration.
+ * @dma_blockpool_initial: Initial size of DMA Pool
+ * @dma_blockpool_max: Maximum blocks in DMA pool
+ * @intr_mode: Line, or MSI-X interrupt.
+ *
+ * @rth_en: Enable Receive Traffic Hashing(RTH) using IT(Indirection Table).
+ * @rth_it_type: RTH IT table programming type
+ * @rts_mac_en: Enable Receive Traffic Steering using MAC destination address
+ * @vp_config: Configuration for virtual paths
+ * @device_poll_millis: Specify the interval (in mulliseconds)
+ * 			to wait for register reads
+ *
+ * Titan configuration.
+ * Contains per-device configuration parameters, including:
+ * - stats sampling interval, etc.
+ *
+ * In addition, struct vxge_hw_device_config{} includes "subordinate"
+ * configurations, including:
+ * - fifos and rings;
+ * - MAC (done at firmware level).
+ *
+ * See Titan User Guide for more details.
+ * Note: Valid (min, max) range for each attribute is specified in the body of
+ * the struct vxge_hw_device_config{} structure. Please refer to the
+ * corresponding include file.
+ * See also: struct vxge_hw_tim_intr_config{}.
+ */
+struct vxge_hw_device_config {
+	u32				dma_blockpool_initial;
+	u32				dma_blockpool_max;
+#define VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE			0
+#define VXGE_HW_INITIAL_DMA_BLOCK_POOL_SIZE		0
+#define VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE		4
+#define VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE			4096
+
+#define        VXGE_HW_MAX_PAYLOAD_SIZE_512		2
+
+	u32				intr_mode;
+#define VXGE_HW_INTR_MODE_IRQLINE			0
+#define VXGE_HW_INTR_MODE_MSIX				1
+#define VXGE_HW_INTR_MODE_MSIX_ONE_SHOT			2
+
+#define VXGE_HW_INTR_MODE_DEF				0
+
+	u32				rth_en;
+#define VXGE_HW_RTH_DISABLE				0
+#define VXGE_HW_RTH_ENABLE				1
+#define VXGE_HW_RTH_DEFAULT				0
+
+	u32				rth_it_type;
+#define VXGE_HW_RTH_IT_TYPE_SOLO_IT			0
+#define VXGE_HW_RTH_IT_TYPE_MULTI_IT			1
+#define VXGE_HW_RTH_IT_TYPE_DEFAULT			0
+
+	u32				rts_mac_en;
+#define VXGE_HW_RTS_MAC_DISABLE			0
+#define VXGE_HW_RTS_MAC_ENABLE			1
+#define VXGE_HW_RTS_MAC_DEFAULT			0
+
+	struct vxge_hw_vp_config	vp_config[VXGE_HW_MAX_VIRTUAL_PATHS];
+
+	u32				device_poll_millis;
+#define VXGE_HW_MIN_DEVICE_POLL_MILLIS			1
+#define VXGE_HW_MAX_DEVICE_POLL_MILLIS			100000
+#define VXGE_HW_DEF_DEVICE_POLL_MILLIS			1000
+
+};
+
+/**
+ * function vxge_uld_link_up_f - Link-Up callback provided by driver.
+ * @devh: HW device handle.
+ * Link-up notification callback provided by the driver.
+ * This is one of the per-driver callbacks, see struct vxge_hw_uld_cbs{}.
+ *
+ * See also: struct vxge_hw_uld_cbs{}, vxge_uld_link_down_f{},
+ * vxge_hw_driver_initialize().
+ */
+
+/**
+ * function vxge_uld_link_down_f - Link-Down callback provided by
+ * driver.
+ * @devh: HW device handle.
+ *
+ * Link-Down notification callback provided by the driver.
+ * This is one of the per-driver callbacks, see struct vxge_hw_uld_cbs{}.
+ *
+ * See also: struct vxge_hw_uld_cbs{}, vxge_uld_link_up_f{},
+ * vxge_hw_driver_initialize().
+ */
+
+/**
+ * function vxge_uld_crit_err_f - Critical Error notification callback.
+ * @devh: HW device handle.
+ * (typically - at HW device iinitialization time).
+ * @type: Enumerated hw error, e.g.: double ECC.
+ * @serr_data: Titan status.
+ * @ext_data: Extended data. The contents depends on the @type.
+ *
+ * Link-Down notification callback provided by the driver.
+ * This is one of the per-driver callbacks, see struct vxge_hw_uld_cbs{}.
+ *
+ * See also: struct vxge_hw_uld_cbs{}, enum vxge_hw_event{},
+ * vxge_hw_driver_initialize().
+ */
+
+/**
+ * struct vxge_hw_uld_cbs - driver "slow-path" callbacks.
+ * @link_up: See vxge_uld_link_up_f{}.
+ * @link_down: See vxge_uld_link_down_f{}.
+ * @crit_err: See vxge_uld_crit_err_f{}.
+ *
+ * Driver slow-path (per-driver) callbacks.
+ * Implemented by driver and provided to HW via
+ * vxge_hw_driver_initialize().
+ * Note that these callbacks are not mandatory: HW will not invoke
+ * a callback if NULL is specified.
+ *
+ * See also: vxge_hw_driver_initialize().
+ */
+struct vxge_hw_uld_cbs {
+
+	void (*link_up)(struct __vxge_hw_device *devh);
+	void (*link_down)(struct __vxge_hw_device *devh);
+	void (*crit_err)(struct __vxge_hw_device *devh,
+			enum vxge_hw_event type, u64 ext_data);
+};
+
+/*
+ * struct __vxge_hw_blockpool_entry - Block private data structure
+ * @item: List header used to link.
+ * @length: Length of the block
+ * @memblock: Virtual address block
+ * @dma_addr: DMA Address of the block.
+ * @dma_handle: DMA handle of the block.
+ * @acc_handle: DMA acc handle
+ *
+ * Block is allocated with a header to put the blocks into list.
+ *
+ */
+struct __vxge_hw_blockpool_entry {
+	struct list_head	item;
+	u32			length;
+	void			*memblock;
+	dma_addr_t		dma_addr;
+	struct pci_dev 		*dma_handle;
+	struct pci_dev 		*acc_handle;
+};
+
+/*
+ * struct __vxge_hw_blockpool - Block Pool
+ * @hldev: HW device
+ * @block_size: size of each block.
+ * @Pool_size: Number of blocks in the pool
+ * @pool_max: Maximum number of blocks above which to free additional blocks
+ * @req_out: Number of block requests with OS out standing
+ * @free_block_list: List of free blocks
+ *
+ * Block pool contains the DMA blocks preallocated.
+ *
+ */
+struct __vxge_hw_blockpool {
+	struct __vxge_hw_device *hldev;
+	u32				block_size;
+	u32				pool_size;
+	u32				pool_max;
+	u32				req_out;
+	struct list_head		free_block_list;
+	struct list_head		free_entry_list;
+};
+
+/*
+ * enum enum __vxge_hw_channel_type - Enumerated channel types.
+ * @VXGE_HW_CHANNEL_TYPE_UNKNOWN: Unknown channel.
+ * @VXGE_HW_CHANNEL_TYPE_FIFO: fifo.
+ * @VXGE_HW_CHANNEL_TYPE_RING: ring.
+ * @VXGE_HW_CHANNEL_TYPE_MAX: Maximum number of HW-supported
+ * (and recognized) channel types. Currently: 2.
+ *
+ * Enumerated channel types. Currently there are only two link-layer
+ * channels - Titan fifo and Titan ring. In the future the list will grow.
+ */
+enum __vxge_hw_channel_type {
+	VXGE_HW_CHANNEL_TYPE_UNKNOWN			= 0,
+	VXGE_HW_CHANNEL_TYPE_FIFO			= 1,
+	VXGE_HW_CHANNEL_TYPE_RING			= 2,
+	VXGE_HW_CHANNEL_TYPE_MAX			= 3
+};
+
+/*
+ * struct __vxge_hw_channel
+ * @item: List item; used to maintain a list of open channels.
+ * @type: Channel type. See enum vxge_hw_channel_type{}.
+ * @devh: Device handle. HW device object that contains _this_ channel.
+ * @vph: Virtual path handle. Virtual Path Object that contains _this_ channel.
+ * @length: Channel length. Currently allocated number of descriptors.
+ *          The channel length "grows" when more descriptors get allocated.
+ *          See _hw_mempool_grow.
+ * @reserve_arr: Reserve array. Contains descriptors that can be reserved
+ *               by driver for the subsequent send or receive operation.
+ *               See vxge_hw_fifo_txdl_reserve(),
+ *               vxge_hw_ring_rxd_reserve().
+ * @reserve_ptr: Current pointer in the resrve array
+ * @reserve_top: Reserve top gives the maximum number of dtrs available in
+ *          reserve array.
+ * @work_arr: Work array. Contains descriptors posted to the channel.
+ *            Note that at any point in time @work_arr contains 3 types of
+ *            descriptors:
+ *            1) posted but not yet consumed by Titan device;
+ *            2) consumed but not yet completed;
+ *            3) completed but not yet freed
+ *            (via vxge_hw_fifo_txdl_free() or vxge_hw_ring_rxd_free())
+ * @post_index: Post index. At any point in time points on the
+ *              position in the channel, which'll contain next to-be-posted
+ *              descriptor.
+ * @compl_index: Completion index. At any point in time points on the
+ *               position in the channel, which will contain next
+ *               to-be-completed descriptor.
+ * @free_arr: Free array. Contains completed descriptors that were freed
+ *            (i.e., handed over back to HW) by driver.
+ *            See vxge_hw_fifo_txdl_free(), vxge_hw_ring_rxd_free().
+ * @free_ptr: current pointer in free array
+ * @per_dtr_space: Per-descriptor space (in bytes) that channel user can utilize
+ *                 to store per-operation control information.
+ * @stats: Pointer to common statistics
+ * @userdata: Per-channel opaque (void*) user-defined context, which may be
+ *            driver object, ULP connection, etc.
+ *            Once channel is open, @userdata is passed back to user via
+ *            vxge_hw_channel_callback_f.
+ *
+ * HW channel object.
+ *
+ * See also: enum vxge_hw_channel_type{}, enum vxge_hw_channel_flag
+ */
+struct __vxge_hw_channel {
+	struct list_head		item;
+	enum __vxge_hw_channel_type	type;
+	struct __vxge_hw_device 	*devh;
+	struct __vxge_hw_vpath_handle 	*vph;
+	u32			length;
+	u32			vp_id;
+	void		**reserve_arr;
+	u32			reserve_ptr;
+	u32			reserve_top;
+	void		**work_arr;
+	u32			post_index ____cacheline_aligned;
+	u32			compl_index ____cacheline_aligned;
+	void		**free_arr;
+	u32			free_ptr;
+	void		**orig_arr;
+	u32			per_dtr_space;
+	void		*userdata;
+	struct vxge_hw_common_reg	__iomem *common_reg;
+	u32			first_vp_id;
+	struct vxge_hw_vpath_stats_sw_common_info *stats;
+
+} ____cacheline_aligned;
+
+/*
+ * struct __vxge_hw_virtualpath - Virtual Path
+ *
+ * @vp_id: Virtual path id
+ * @vp_open: This flag specifies if vxge_hw_vp_open is called from LL Driver
+ * @hldev: Hal device
+ * @vp_config: Virtual Path Config
+ * @vp_reg: VPATH Register map address in BAR0
+ * @vpmgmt_reg: VPATH_MGMT register map address
+ * @max_mtu: Max mtu that can be supported
+ * @vsport_number: vsport attached to this vpath
+ * @max_kdfc_db: Maximum kernel mode doorbells
+ * @max_nofl_db: Maximum non offload doorbells
+ * @tx_intr_num: Interrupt Number associated with the TX
+
+ * @ringh: Ring Queue
+ * @fifoh: FIFO Queue
+ * @vpath_handles: Virtual Path handles list
+ * @stats_block: Memory for DMAing stats
+ * @stats: Vpath statistics
+ *
+ * Virtual path structure to encapsulate the data related to a virtual path.
+ * Virtual paths are allocated by the HW upon getting configuration from the
+ * driver and inserted into the list of virtual paths.
+ */
+struct __vxge_hw_virtualpath {
+	u32				vp_id;
+
+	u32				vp_open;
+#define VXGE_HW_VP_NOT_OPEN	0
+#define	VXGE_HW_VP_OPEN		1
+
+	struct __vxge_hw_device		*hldev;
+	struct vxge_hw_vp_config	*vp_config;
+	struct vxge_hw_vpath_reg	__iomem *vp_reg;
+	struct vxge_hw_vpmgmt_reg	__iomem *vpmgmt_reg;
+	struct __vxge_hw_non_offload_db_wrapper	__iomem *nofl_db;
+
+	u32				max_mtu;
+	u32				vsport_number;
+	u32				max_kdfc_db;
+	u32				max_nofl_db;
+
+	struct __vxge_hw_ring *____cacheline_aligned ringh;
+	struct __vxge_hw_fifo *____cacheline_aligned fifoh;
+	struct list_head		vpath_handles;
+	struct __vxge_hw_blockpool_entry		*stats_block;
+	struct vxge_hw_vpath_stats_hw_info	*hw_stats;
+	struct vxge_hw_vpath_stats_hw_info	*hw_stats_sav;
+	struct vxge_hw_vpath_stats_sw_info	*sw_stats;
+};
+
+/*
+ * struct __vxge_hw_vpath_handle - List item to store callback information
+ * @item: List head to keep the item in linked list
+ * @vpath: Virtual path to which this item belongs
+ *
+ * This structure is used to store the callback information.
+ */
+struct __vxge_hw_vpath_handle{
+	struct list_head	item;
+	struct __vxge_hw_virtualpath	*vpath;
+};
+
+/*
+ * struct __vxge_hw_device
+ *
+ * HW device object.
+ */
+/**
+ * struct __vxge_hw_device  - Hal device object
+ * @magic: Magic Number
+ * @device_id: PCI Device Id of the adapter
+ * @major_revision: PCI Device major revision
+ * @minor_revision: PCI Device minor revision
+ * @bar0: BAR0 virtual address.
+ * @bar1: BAR1 virtual address.
+ * @bar2: BAR2 virtual address.
+ * @pdev: Physical device handle
+ * @config: Confguration passed by the LL driver at initialization
+ * @link_state: Link state
+ *
+ * HW device object. Represents Titan adapter
+ */
+struct __vxge_hw_device {
+	u32				magic;
+#define VXGE_HW_DEVICE_MAGIC		0x12345678
+#define VXGE_HW_DEVICE_DEAD		0xDEADDEAD
+	u16				device_id;
+	u8				major_revision;
+	u8				minor_revision;
+	void __iomem			*bar0;
+	void __iomem			*bar1;
+	void __iomem			*bar2;
+	struct pci_dev			*pdev;
+	struct net_device		*ndev;
+	struct vxge_hw_device_config	config;
+	enum vxge_hw_device_link_state	link_state;
+
+	struct vxge_hw_uld_cbs		uld_callbacks;
+
+	u32				host_type;
+	u32				func_id;
+	u32				access_rights;
+#define VXGE_HW_DEVICE_ACCESS_RIGHT_VPATH      0x1
+#define VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM     0x2
+#define VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM     0x4
+	struct vxge_hw_legacy_reg	__iomem *legacy_reg;
+	struct vxge_hw_toc_reg		__iomem *toc_reg;
+	struct vxge_hw_common_reg	__iomem *common_reg;
+	struct vxge_hw_mrpcim_reg	__iomem *mrpcim_reg;
+	struct vxge_hw_srpcim_reg	__iomem *srpcim_reg \
+					[VXGE_HW_TITAN_SRPCIM_REG_SPACES];
+	struct vxge_hw_vpmgmt_reg	__iomem *vpmgmt_reg \
+					[VXGE_HW_TITAN_VPMGMT_REG_SPACES];
+	struct vxge_hw_vpath_reg	__iomem *vpath_reg \
+					[VXGE_HW_TITAN_VPATH_REG_SPACES];
+	u8				__iomem *kdfc;
+	u8				__iomem *usdc;
+	struct __vxge_hw_virtualpath	virtual_paths \
+					[VXGE_HW_MAX_VIRTUAL_PATHS];
+	u64				vpath_assignments;
+	u64				vpaths_deployed;
+	u32				first_vp_id;
+	u64				tim_int_mask0[4];
+	u32				tim_int_mask1[4];
+
+	struct __vxge_hw_blockpool	block_pool;
+	struct vxge_hw_device_stats	stats;
+	u32				debug_module_mask;
+	u32				debug_level;
+	u32				level_err;
+	u32				level_trace;
+};
+
+#define VXGE_HW_INFO_LEN	64
+/**
+ * struct vxge_hw_device_hw_info - Device information
+ * @host_type: Host Type
+ * @func_id: Function Id
+ * @vpath_mask: vpath bit mask
+ * @fw_version: Firmware version
+ * @fw_date: Firmware Date
+ * @flash_version: Firmware version
+ * @flash_date: Firmware Date
+ * @mac_addrs: Mac addresses for each vpath
+ * @mac_addr_masks: Mac address masks for each vpath
+ *
+ * Returns the vpath mask that has the bits set for each vpath allocated
+ * for the driver and the first mac address for each vpath
+ */
+struct vxge_hw_device_hw_info {
+	u32		host_type;
+#define VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION			0
+#define VXGE_HW_MR_NO_SR_VH0_BASE_FUNCTION			1
+#define VXGE_HW_NO_MR_SR_VH0_FUNCTION0				2
+#define VXGE_HW_NO_MR_SR_VH0_VIRTUAL_FUNCTION			3
+#define VXGE_HW_MR_SR_VH0_INVALID_CONFIG			4
+#define VXGE_HW_SR_VH_FUNCTION0					5
+#define VXGE_HW_SR_VH_VIRTUAL_FUNCTION				6
+#define VXGE_HW_VH_NORMAL_FUNCTION				7
+	u64		function_mode;
+#define VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION			0
+#define VXGE_HW_FUNCTION_MODE_SINGLE_FUNCTION			1
+#define VXGE_HW_FUNCTION_MODE_SRIOV				2
+#define VXGE_HW_FUNCTION_MODE_MRIOV				3
+	u32		func_id;
+	u64		vpath_mask;
+	struct vxge_hw_device_version fw_version;
+	struct vxge_hw_device_date    fw_date;
+	struct vxge_hw_device_version flash_version;
+	struct vxge_hw_device_date    flash_date;
+	u8		serial_number[VXGE_HW_INFO_LEN];
+	u8		part_number[VXGE_HW_INFO_LEN];
+	u8		product_desc[VXGE_HW_INFO_LEN];
+	u8 (mac_addrs)[VXGE_HW_MAX_VIRTUAL_PATHS][ETH_ALEN];
+	u8 (mac_addr_masks)[VXGE_HW_MAX_VIRTUAL_PATHS][ETH_ALEN];
+};
+
+/**
+ * struct vxge_hw_device_attr - Device memory spaces.
+ * @bar0: BAR0 virtual address.
+ * @bar1: BAR1 virtual address.
+ * @bar2: BAR2 virtual address.
+ * @pdev: PCI device object.
+ *
+ * Device memory spaces. Includes configuration, BAR0, BAR1, etc. per device
+ * mapped memories. Also, includes a pointer to OS-specific PCI device object.
+ */
+struct vxge_hw_device_attr {
+	void __iomem		*bar0;
+	void __iomem		*bar1;
+	void __iomem		*bar2;
+	struct pci_dev 		*pdev;
+	struct vxge_hw_uld_cbs	uld_callbacks;
+};
+
+#define VXGE_HW_DEVICE_LINK_STATE_SET(hldev, ls)	(hldev->link_state = ls)
+
+#define VXGE_HW_DEVICE_TIM_INT_MASK_SET(m0, m1, i) {	\
+	if (i < 16) {				\
+		m0[0] |= vxge_vBIT(0x8, (i*4), 4);	\
+		m0[1] |= vxge_vBIT(0x4, (i*4), 4);	\
+	}			       		\
+	else {					\
+		m1[0] = 0x80000000;		\
+		m1[1] = 0x40000000;		\
+	}					\
+}
+
+#define VXGE_HW_DEVICE_TIM_INT_MASK_RESET(m0, m1, i) {	\
+	if (i < 16) {					\
+		m0[0] &= ~vxge_vBIT(0x8, (i*4), 4);		\
+		m0[1] &= ~vxge_vBIT(0x4, (i*4), 4);		\
+	}						\
+	else {						\
+		m1[0] = 0;				\
+		m1[1] = 0;				\
+	}						\
+}
+
+#define VXGE_HW_DEVICE_STATS_PIO_READ(loc, offset) {		\
+	status = vxge_hw_mrpcim_stats_access(hldev, \
+				VXGE_HW_STATS_OP_READ, \
+				loc, \
+				offset, \
+				&val64);			\
+								\
+	if (status != VXGE_HW_OK)				\
+		return status;						\
+}
+
+#define VXGE_HW_VPATH_STATS_PIO_READ(offset) {				\
+	status = __vxge_hw_vpath_stats_access(vpath, \
+			VXGE_HW_STATS_OP_READ, \
+			offset, \
+			&val64);					\
+	if (status != VXGE_HW_OK)					\
+		return status;						\
+}
+
+/*
+ * struct __vxge_hw_ring - Ring channel.
+ * @channel: Channel "base" of this ring, the common part of all HW
+ *           channels.
+ * @mempool: Memory pool, the pool from which descriptors get allocated.
+ *           (See vxge_hw_mm.h).
+ * @config: Ring configuration, part of device configuration
+ *          (see struct vxge_hw_device_config{}).
+ * @ring_length: Length of the ring
+ * @buffer_mode: 1, 3, or 5. The value specifies a receive buffer mode,
+ *          as per Titan User Guide.
+ * @rxd_size: RxD sizes for 1-, 3- or 5- buffer modes. As per Titan spec,
+ *            1-buffer mode descriptor is 32 byte long, etc.
+ * @rxd_priv_size: Per RxD size reserved (by HW) for driver to keep
+ *                 per-descriptor data (e.g., DMA handle for Solaris)
+ * @per_rxd_space: Per rxd space requested by driver
+ * @rxds_per_block: Number of descriptors per hardware-defined RxD
+ *                  block. Depends on the (1-, 3-, 5-) buffer mode.
+ * @rxdblock_priv_size: Reserved at the end of each RxD block. HW internal
+ *                      usage. Not to confuse with @rxd_priv_size.
+ * @cmpl_cnt: Completion counter. Is reset to zero upon entering the ISR.
+ * @callback: Channel completion callback. HW invokes the callback when there
+ *            are new completions on that channel. In many implementations
+ *            the @callback executes in the hw interrupt context.
+ * @rxd_init: Channel's descriptor-initialize callback.
+ *            See vxge_hw_ring_rxd_init_f{}.
+ *            If not NULL, HW invokes the callback when opening
+ *            the ring.
+ * @rxd_term: Channel's descriptor-terminate callback. If not NULL,
+ *          HW invokes the callback when closing the corresponding channel.
+ *          See also vxge_hw_channel_rxd_term_f{}.
+ * @stats: Statistics for ring
+ * Ring channel.
+ *
+ * Note: The structure is cache line aligned to better utilize
+ *       CPU cache performance.
+ */
+struct __vxge_hw_ring {
+	struct __vxge_hw_channel		channel;
+	struct vxge_hw_mempool			*mempool;
+	struct vxge_hw_vpath_reg		__iomem	*vp_reg;
+	struct vxge_hw_common_reg		__iomem	*common_reg;
+	u32					ring_length;
+	u32					buffer_mode;
+	u32					rxd_size;
+	u32					rxd_priv_size;
+	u32					per_rxd_space;
+	u32					rxds_per_block;
+	u32					rxdblock_priv_size;
+	u32					cmpl_cnt;
+	u32					vp_id;
+	u32					doorbell_cnt;
+	u32					total_db_cnt;
+	u64					rxds_limit;
+
+	enum vxge_hw_status (*callback)(
+			struct __vxge_hw_ring *ringh,
+			void *rxdh,
+			u8 t_code,
+			void *userdata);
+
+	enum vxge_hw_status (*rxd_init)(
+			void *rxdh,
+			void *userdata);
+
+	void (*rxd_term)(
+			void *rxdh,
+			enum vxge_hw_rxd_state state,
+			void *userdata);
+
+	struct vxge_hw_vpath_stats_sw_ring_info *stats	____cacheline_aligned;
+	struct vxge_hw_ring_config		*config;
+} ____cacheline_aligned;
+
+/**
+ * enum enum vxge_hw_txdl_state - Descriptor (TXDL) state.
+ * @VXGE_HW_TXDL_STATE_NONE: Invalid state.
+ * @VXGE_HW_TXDL_STATE_AVAIL: Descriptor is available for reservation.
+ * @VXGE_HW_TXDL_STATE_POSTED: Descriptor is posted for processing by the
+ * device.
+ * @VXGE_HW_TXDL_STATE_FREED: Descriptor is free and can be reused for
+ * filling-in and posting later.
+ *
+ * Titan/HW descriptor states.
+ *
+ */
+enum vxge_hw_txdl_state {
+	VXGE_HW_TXDL_STATE_NONE	= 0,
+	VXGE_HW_TXDL_STATE_AVAIL	= 1,
+	VXGE_HW_TXDL_STATE_POSTED	= 2,
+	VXGE_HW_TXDL_STATE_FREED	= 3
+};
+/*
+ * struct __vxge_hw_fifo - Fifo.
+ * @channel: Channel "base" of this fifo, the common part of all HW
+ *             channels.
+ * @mempool: Memory pool, from which descriptors get allocated.
+ * @config: Fifo configuration, part of device configuration
+ *             (see struct vxge_hw_device_config{}).
+ * @interrupt_type: Interrupt type to be used
+ * @no_snoop_bits: See struct vxge_hw_fifo_config{}.
+ * @txdl_per_memblock: Number of TxDLs (TxD lists) per memblock.
+ *             on TxDL please refer to Titan UG.
+ * @txdl_size: Configured TxDL size (i.e., number of TxDs in a list), plus
+ *             per-TxDL HW private space (struct __vxge_hw_fifo_txdl_priv).
+ * @priv_size: Per-Tx descriptor space reserved for driver
+ *             usage.
+ * @per_txdl_space: Per txdl private space for the driver
+ * @callback: Fifo completion callback. HW invokes the callback when there
+ *             are new completions on that fifo. In many implementations
+ *             the @callback executes in the hw interrupt context.
+ * @txdl_term: Fifo's descriptor-terminate callback. If not NULL,
+ *             HW invokes the callback when closing the corresponding fifo.
+ *             See also vxge_hw_fifo_txdl_term_f{}.
+ * @stats: Statistics of this fifo
+ *
+ * Fifo channel.
+ * Note: The structure is cache line aligned.
+ */
+struct __vxge_hw_fifo {
+	struct __vxge_hw_channel		channel;
+	struct vxge_hw_mempool			*mempool;
+	struct vxge_hw_fifo_config		*config;
+	struct vxge_hw_vpath_reg		__iomem *vp_reg;
+	struct __vxge_hw_non_offload_db_wrapper	__iomem *nofl_db;
+	u64					interrupt_type;
+	u32					no_snoop_bits;
+	u32					txdl_per_memblock;
+	u32					txdl_size;
+	u32					priv_size;
+	u32					per_txdl_space;
+	u32					vp_id;
+	u32					tx_intr_num;
+
+	enum vxge_hw_status (*callback)(
+			struct __vxge_hw_fifo *fifo_handle,
+			void *txdlh,
+			enum vxge_hw_fifo_tcode t_code,
+			void *userdata,
+			void **skb_ptr);
+
+	void (*txdl_term)(
+			void *txdlh,
+			enum vxge_hw_txdl_state state,
+			void *userdata);
+
+	struct vxge_hw_vpath_stats_sw_fifo_info *stats ____cacheline_aligned;
+} ____cacheline_aligned;
+
+/*
+ * struct __vxge_hw_fifo_txdl_priv - Transmit descriptor HW-private data.
+ * @dma_addr: DMA (mapped) address of _this_ descriptor.
+ * @dma_handle: DMA handle used to map the descriptor onto device.
+ * @dma_offset: Descriptor's offset in the memory block. HW allocates
+ *	 descriptors in memory blocks (see struct vxge_hw_fifo_config{})
+ *             Each memblock is a contiguous block of DMA-able memory.
+ * @frags: Total number of fragments (that is, contiguous data buffers)
+ * carried by this TxDL.
+ * @align_vaddr_start: Aligned virtual address start
+ * @align_vaddr: Virtual address of the per-TxDL area in memory used for
+ *             alignement. Used to place one or more mis-aligned fragments
+ * @align_dma_addr: DMA address translated from the @align_vaddr.
+ * @align_dma_handle: DMA handle that corresponds to @align_dma_addr.
+ * @align_dma_acch: DMA access handle corresponds to @align_dma_addr.
+ * @align_dma_offset: The current offset into the @align_vaddr area.
+ * Grows while filling the descriptor, gets reset.
+ * @align_used_frags: Number of fragments used.
+ * @alloc_frags: Total number of fragments allocated.
+ * @unused: TODO
+ * @next_txdl_priv: (TODO).
+ * @first_txdp: (TODO).
+ * @linked_txdl_priv: Pointer to any linked TxDL for creating contiguous
+ *             TxDL list.
+ * @txdlh: Corresponding txdlh to this TxDL.
+ * @memblock: Pointer to the TxDL memory block or memory page.
+ *             on the next send operation.
+ * @dma_object: DMA address and handle of the memory block that contains
+ *             the descriptor. This member is used only in the "checked"
+ *             version of the HW (to enforce certain assertions);
+ *             otherwise it gets compiled out.
+ * @allocated: True if the descriptor is reserved, 0 otherwise. Internal usage.
+ *
+ * Per-transmit decsriptor HW-private data. HW uses the space to keep DMA
+ * information associated with the descriptor. Note that driver can ask HW
+ * to allocate additional per-descriptor space for its own (driver-specific)
+ * purposes.
+ *
+ * See also: struct vxge_hw_ring_rxd_priv{}.
+ */
+struct __vxge_hw_fifo_txdl_priv {
+	dma_addr_t		dma_addr;
+	struct pci_dev	*dma_handle;
+	ptrdiff_t		dma_offset;
+	u32				frags;
+	u8				*align_vaddr_start;
+	u8				*align_vaddr;
+	dma_addr_t		align_dma_addr;
+	struct pci_dev 	*align_dma_handle;
+	struct pci_dev	*align_dma_acch;
+	ptrdiff_t		align_dma_offset;
+	u32				align_used_frags;
+	u32				alloc_frags;
+	u32				unused;
+	struct __vxge_hw_fifo_txdl_priv	*next_txdl_priv;
+	struct vxge_hw_fifo_txd		*first_txdp;
+	void			*memblock;
+};
+
+/*
+ * struct __vxge_hw_non_offload_db_wrapper - Non-offload Doorbell Wrapper
+ * @control_0: Bits 0 to 7 - Doorbell type.
+ *             Bits 8 to 31 - Reserved.
+ *             Bits 32 to 39 - The highest TxD in this TxDL.
+ *             Bits 40 to 47 - Reserved.
+	*	       Bits 48 to 55 - Reserved.
+ *             Bits 56 to 63 - No snoop flags.
+ * @txdl_ptr:  The starting location of the TxDL in host memory.
+ *
+ * Created by the host and written to the adapter via PIO to a Kernel Doorbell
+ * FIFO. All non-offload doorbell wrapper fields must be written by the host as
+ * part of a doorbell write. Consumed by the adapter but is not written by the
+ * adapter.
+ */
+struct __vxge_hw_non_offload_db_wrapper {
+	u64		control_0;
+#define	VXGE_HW_NODBW_GET_TYPE(ctrl0)			vxge_bVALn(ctrl0, 0, 8)
+#define VXGE_HW_NODBW_TYPE(val) vxge_vBIT(val, 0, 8)
+#define	VXGE_HW_NODBW_TYPE_NODBW				0
+
+#define	VXGE_HW_NODBW_GET_LAST_TXD_NUMBER(ctrl0)	vxge_bVALn(ctrl0, 32, 8)
+#define VXGE_HW_NODBW_LAST_TXD_NUMBER(val) vxge_vBIT(val, 32, 8)
+
+#define	VXGE_HW_NODBW_GET_NO_SNOOP(ctrl0)		vxge_bVALn(ctrl0, 56, 8)
+#define VXGE_HW_NODBW_LIST_NO_SNOOP(val) vxge_vBIT(val, 56, 8)
+#define	VXGE_HW_NODBW_LIST_NO_SNOOP_TXD_READ_TXD0_WRITE		0x2
+#define	VXGE_HW_NODBW_LIST_NO_SNOOP_TX_FRAME_DATA_READ		0x1
+
+	u64		txdl_ptr;
+};
+
+/*
+ * TX Descriptor
+ */
+
+/**
+ * struct vxge_hw_fifo_txd - Transmit Descriptor
+ * @control_0: Bits 0 to 6 - Reserved.
+ *             Bit 7 - List Ownership. This field should be initialized
+ *             to '1' by the driver before the transmit list pointer is
+ *             written to the adapter. This field will be set to '0' by the
+ *             adapter once it has completed transmitting the frame or frames in
+ *             the list. Note - This field is only valid in TxD0. Additionally,
+ *             for multi-list sequences, the driver should not release any
+ *             buffers until the ownership of the last list in the multi-list
+ *             sequence has been returned to the host.
+ *             Bits 8 to 11 - Reserved
+ *             Bits 12 to 15 - Transfer_Code. This field is only valid in
+ *             TxD0. It is used to describe the status of the transmit data
+ *             buffer transfer. This field is always overwritten by the
+ *             adapter, so this field may be initialized to any value.
+ *             Bits 16 to 17 - Host steering. This field allows the host to
+ *             override the selection of the physical transmit port.
+ *             Attention:
+ *             Normal sounds as if learned from the switch rather than from
+ *             the aggregation algorythms.
+ *             00: Normal. Use Destination/MAC Address
+ *             lookup to determine the transmit port.
+ *             01: Send on physical Port1.
+ *             10: Send on physical Port0.
+	*	       11: Send on both ports.
+ *             Bits 18 to 21 - Reserved
+ *             Bits 22 to 23 - Gather_Code. This field is set by the host and
+ *             is used to describe how individual buffers comprise a frame.
+ *             10: First descriptor of a frame.
+ *             00: Middle of a multi-descriptor frame.
+ *             01: Last descriptor of a frame.
+ *             11: First and last descriptor of a frame (the entire frame
+ *             resides in a single buffer).
+ *             For multi-descriptor frames, the only valid gather code sequence
+ *             is {10, [00], 01}. In other words, the descriptors must be placed
+ *             in the list in the correct order.
+ *             Bits 24 to 27 - Reserved
+ *             Bits 28 to 29 - LSO_Frm_Encap. LSO Frame Encapsulation
+ *             definition. Only valid in TxD0. This field allows the host to
+ *             indicate the Ethernet encapsulation of an outbound LSO packet.
+ *             00 - classic mode (best guess)
+ *             01 - LLC
+ *             10 - SNAP
+ *             11 - DIX
+ *             If "classic mode" is selected, the adapter will attempt to
+ *             decode the frame's Ethernet encapsulation by examining the L/T
+ *             field as follows:
+ *             <= 0x05DC LLC/SNAP encoding; must examine DSAP/SSAP to determine
+ *             if packet is IPv4 or IPv6.
+ *             0x8870 Jumbo-SNAP encoding.
+ *             0x0800 IPv4 DIX encoding
+ *             0x86DD IPv6 DIX encoding
+ *             others illegal encapsulation
+ *             Bits 30 - LSO_ Flag. Large Send Offload (LSO) flag.
+ *             Set to 1 to perform segmentation offload for TCP/UDP.
+ *             This field is valid only in TxD0.
+ *             Bits 31 to 33 - Reserved.
+ *             Bits 34 to 47 - LSO_MSS. TCP/UDP LSO Maximum Segment Size
+ *             This field is meaningful only when LSO_Control is non-zero.
+ *             When LSO_Control is set to TCP_LSO, the single (possibly large)
+ *             TCP segment described by this TxDL will be sent as a series of
+ *             TCP segments each of which contains no more than LSO_MSS
+ *             payload bytes.
+ *             When LSO_Control is set to UDP_LSO, the single (possibly large)
+ *             UDP datagram described by this TxDL will be sent as a series of
+ *             UDP datagrams each of which contains no more than LSO_MSS
+ *             payload bytes.
+ *             All outgoing frames from this TxDL will have LSO_MSS bytes of UDP
+ *             or TCP payload, with the exception of the last, which will have
+ *             <= LSO_MSS bytes of payload.
+ *             Bits 48 to 63 - Buffer_Size. Number of valid bytes in the
+ *             buffer to be read by the adapter. This field is written by the
+ *             host. A value of 0 is illegal.
+ *	       Bits 32 to 63 - This value is written by the adapter upon
+ *	       completion of a UDP or TCP LSO operation and indicates the number
+ *             of UDP or TCP payload bytes that were transmitted. 0x0000 will be
+ *             returned for any non-LSO operation.
+ * @control_1: Bits 0 to 4 - Reserved.
+ *             Bit 5 - Tx_CKO_IPv4 Set to a '1' to enable IPv4 header checksum
+ *             offload. This field is only valid in the first TxD of a frame.
+ *             Bit 6 - Tx_CKO_TCP Set to a '1' to enable TCP checksum offload.
+ *             This field is only valid in the first TxD of a frame (the TxD's
+ *             gather code must be 10 or 11). The driver should only set this
+ *             bit if it can guarantee that TCP is present.
+ *             Bit 7 - Tx_CKO_UDP Set to a '1' to enable UDP checksum offload.
+ *             This field is only valid in the first TxD of a frame (the TxD's
+ *             gather code must be 10 or 11). The driver should only set this
+ *             bit if it can guarantee that UDP is present.
+ *             Bits 8 to 14 - Reserved.
+ *             Bit 15 - Tx_VLAN_Enable VLAN tag insertion flag. Set to a '1' to
+ *             instruct the adapter to insert the VLAN tag specified by the
+ *             Tx_VLAN_Tag field. This field is only valid in the first TxD of
+ *             a frame.
+ *             Bits 16 to 31 - Tx_VLAN_Tag. Variable portion of the VLAN tag
+ *             to be inserted into the frame by the adapter (the first two bytes
+ *             of a VLAN tag are always 0x8100). This field is only valid if the
+ *             Tx_VLAN_Enable field is set to '1'.
+ *             Bits 32 to 33 - Reserved.
+ *             Bits 34 to 39 - Tx_Int_Number. Indicates which Tx interrupt
+ *             number the frame associated with. This field is written by the
+ *             host. It is only valid in the first TxD of a frame.
+ *             Bits 40 to 42 - Reserved.
+ *             Bit 43 - Set to 1 to exclude the frame from bandwidth metering
+ *             functions. This field is valid only in the first TxD
+ *             of a frame.
+ *             Bits 44 to 45 - Reserved.
+ *             Bit 46 - Tx_Int_Per_List Set to a '1' to instruct the adapter to
+ *             generate an interrupt as soon as all of the frames in the list
+ *             have been transmitted. In order to have per-frame interrupts,
+ *             the driver should place a maximum of one frame per list. This
+ *             field is only valid in the first TxD of a frame.
+ *             Bit 47 - Tx_Int_Utilization Set to a '1' to instruct the adapter
+ *             to count the frame toward the utilization interrupt specified in
+ *             the Tx_Int_Number field. This field is only valid in the first
+ *             TxD of a frame.
+ *             Bits 48 to 63 - Reserved.
+ * @buffer_pointer: Buffer start address.
+ * @host_control: Host_Control.Opaque 64bit data stored by driver inside the
+ *            Titan descriptor prior to posting the latter on the fifo
+ *            via vxge_hw_fifo_txdl_post().The %host_control is returned as is
+ *            to the driver with each completed descriptor.
+ *
+ * Transmit descriptor (TxD).Fifo descriptor contains configured number
+ * (list) of TxDs. * For more details please refer to Titan User Guide,
+ * Section 5.4.2 "Transmit Descriptor (TxD) Format".
+ */
+struct vxge_hw_fifo_txd {
+	u64 control_0;
+#define VXGE_HW_FIFO_TXD_LIST_OWN_ADAPTER		vxge_mBIT(7)
+
+#define VXGE_HW_FIFO_TXD_T_CODE_GET(ctrl0)		vxge_bVALn(ctrl0, 12, 4)
+#define VXGE_HW_FIFO_TXD_T_CODE(val) 			vxge_vBIT(val, 12, 4)
+#define VXGE_HW_FIFO_TXD_T_CODE_UNUSED		VXGE_HW_FIFO_T_CODE_UNUSED
+
+
+#define VXGE_HW_FIFO_TXD_GATHER_CODE(val) 		vxge_vBIT(val, 22, 2)
+#define VXGE_HW_FIFO_TXD_GATHER_CODE_FIRST	VXGE_HW_FIFO_GATHER_CODE_FIRST
+#define VXGE_HW_FIFO_TXD_GATHER_CODE_LAST	VXGE_HW_FIFO_GATHER_CODE_LAST
+
+
+#define VXGE_HW_FIFO_TXD_LSO_EN				vxge_mBIT(30)
+
+#define VXGE_HW_FIFO_TXD_LSO_MSS(val) 			vxge_vBIT(val, 34, 14)
+
+#define VXGE_HW_FIFO_TXD_BUFFER_SIZE(val) 		vxge_vBIT(val, 48, 16)
+
+	u64 control_1;
+#define VXGE_HW_FIFO_TXD_TX_CKO_IPV4_EN			vxge_mBIT(5)
+#define VXGE_HW_FIFO_TXD_TX_CKO_TCP_EN			vxge_mBIT(6)
+#define VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN			vxge_mBIT(7)
+#define VXGE_HW_FIFO_TXD_VLAN_ENABLE			vxge_mBIT(15)
+
+#define VXGE_HW_FIFO_TXD_VLAN_TAG(val) 			vxge_vBIT(val, 16, 16)
+
+#define VXGE_HW_FIFO_TXD_INT_NUMBER(val) 		vxge_vBIT(val, 34, 6)
+
+#define VXGE_HW_FIFO_TXD_INT_TYPE_PER_LIST		vxge_mBIT(46)
+#define VXGE_HW_FIFO_TXD_INT_TYPE_UTILZ			vxge_mBIT(47)
+
+	u64 buffer_pointer;
+
+	u64 host_control;
+};
+
+/**
+ * struct vxge_hw_ring_rxd_1 - One buffer mode RxD for ring
+ * @host_control: This field is exclusively for host use and is "readonly"
+ *             from the adapter's perspective.
+ * @control_0:Bits 0 to 6 - RTH_Bucket get
+ *	      Bit 7 - Own Descriptor ownership bit. This bit is set to 1
+ *            by the host, and is set to 0 by the adapter.
+ *	      0 - Host owns RxD and buffer.
+ *	      1 - The adapter owns RxD and buffer.
+ *	      Bit 8 - Fast_Path_Eligible When set, indicates that the
+ *            received frame meets all of the criteria for fast path processing.
+ *            The required criteria are as follows:
+ *            !SYN &
+ *            (Transfer_Code == "Transfer OK") &
+ *            (!Is_IP_Fragment) &
+ *            ((Is_IPv4 & computed_L3_checksum == 0xFFFF) |
+ *            (Is_IPv6)) &
+ *            ((Is_TCP & computed_L4_checksum == 0xFFFF) |
+ *            (Is_UDP & (computed_L4_checksum == 0xFFFF |
+ *            computed _L4_checksum == 0x0000)))
+ *            (same meaning for all RxD buffer modes)
+ *	      Bit 9 - L3 Checksum Correct
+ *	      Bit 10 - L4 Checksum Correct
+ *	      Bit 11 - Reserved
+ *	      Bit 12 to 15 - This field is written by the adapter. It is
+ *            used to report the status of the frame transfer to the host.
+ *	      0x0 - Transfer OK
+ *	      0x4 - RDA Failure During Transfer
+ *	      0x5 - Unparseable Packet, such as unknown IPv6 header.
+ *	      0x6 - Frame integrity error (FCS or ECC).
+ *	      0x7 - Buffer Size Error. The provided buffer(s) were not
+ *                  appropriately sized and data loss occurred.
+ *	      0x8 - Internal ECC Error. RxD corrupted.
+ *	      0x9 - IPv4 Checksum error
+ *	      0xA - TCP/UDP Checksum error
+ *	      0xF - Unknown Error or Multiple Error. Indicates an
+ *               unknown problem or that more than one of transfer codes is set.
+ *	      Bit 16 - SYN The adapter sets this field to indicate that
+ *                the incoming frame contained a TCP segment with its SYN bit
+ *	          set and its ACK bit NOT set. (same meaning for all RxD buffer
+ *                modes)
+ *	      Bit 17 - Is ICMP
+ *	      Bit 18 - RTH_SPDM_HIT Set to 1 if there was a match in the
+ *                Socket Pair Direct Match Table and the frame was steered based
+ *                on SPDM.
+ *	      Bit 19 - RTH_IT_HIT Set to 1 if there was a match in the
+ *            Indirection Table and the frame was steered based on hash
+ *            indirection.
+ *	      Bit 20 to 23 - RTH_HASH_TYPE Indicates the function (hash
+ *	          type) that was used to calculate the hash.
+ *	      Bit 19 - IS_VLAN Set to '1' if the frame was/is VLAN
+ *	          tagged.
+ *	      Bit 25 to 26 - ETHER_ENCAP Reflects the Ethernet encapsulation
+ *                of the received frame.
+ *	      0x0 - Ethernet DIX
+ *	      0x1 - LLC
+ *	      0x2 - SNAP (includes Jumbo-SNAP)
+ *	      0x3 - IPX
+ *	      Bit 27 - IS_IPV4 Set to '1' if the frame contains an IPv4	packet.
+ *	      Bit 28 - IS_IPV6 Set to '1' if the frame contains an IPv6 packet.
+ *	      Bit 29 - IS_IP_FRAG Set to '1' if the frame contains a fragmented
+ *            IP packet.
+ *	      Bit 30 - IS_TCP Set to '1' if the frame contains a TCP segment.
+ *	      Bit 31 - IS_UDP Set to '1' if the frame contains a UDP message.
+ *	      Bit 32 to 47 - L3_Checksum[0:15] The IPv4 checksum value 	that
+ *            arrived with the frame. If the resulting computed IPv4 header
+ *            checksum for the frame did not produce the expected 0xFFFF value,
+ *            then the transfer code would be set to 0x9.
+ *	      Bit 48 to 63 - L4_Checksum[0:15] The TCP/UDP checksum value that
+ *            arrived with the frame. If the resulting computed TCP/UDP checksum
+ *            for the frame did not produce the expected 0xFFFF value, then the
+ *            transfer code would be set to 0xA.
+ * @control_1:Bits 0 to 1 - Reserved
+ *            Bits 2 to 15 - Buffer0_Size.This field is set by the host and
+ *            eventually overwritten by the adapter. The host writes the
+ *            available buffer size in bytes when it passes the descriptor to
+ *            the adapter. When a frame is delivered the host, the adapter
+ *            populates this field with the number of bytes written into the
+ *            buffer. The largest supported buffer is 16, 383 bytes.
+ *	      Bit 16 to 47 - RTH Hash Value 32-bit RTH hash value. Only valid if
+ *	      RTH_HASH_TYPE (Control_0, bits 20:23) is nonzero.
+ *	      Bit 48 to 63 - VLAN_Tag[0:15] The contents of the variable portion
+ *            of the VLAN tag, if one was detected by the adapter. This field is
+ *            populated even if VLAN-tag stripping is enabled.
+ * @buffer0_ptr: Pointer to buffer. This field is populated by the driver.
+ *
+ * One buffer mode RxD for ring structure
+ */
+struct vxge_hw_ring_rxd_1 {
+	u64 host_control;
+	u64 control_0;
+#define VXGE_HW_RING_RXD_RTH_BUCKET_GET(ctrl0)		vxge_bVALn(ctrl0, 0, 7)
+
+#define VXGE_HW_RING_RXD_LIST_OWN_ADAPTER		vxge_mBIT(7)
+
+#define VXGE_HW_RING_RXD_FAST_PATH_ELIGIBLE_GET(ctrl0)	vxge_bVALn(ctrl0, 8, 1)
+
+#define VXGE_HW_RING_RXD_L3_CKSUM_CORRECT_GET(ctrl0)	vxge_bVALn(ctrl0, 9, 1)
+
+#define VXGE_HW_RING_RXD_L4_CKSUM_CORRECT_GET(ctrl0)	vxge_bVALn(ctrl0, 10, 1)
+
+#define VXGE_HW_RING_RXD_T_CODE_GET(ctrl0)		vxge_bVALn(ctrl0, 12, 4)
+#define VXGE_HW_RING_RXD_T_CODE(val) 			vxge_vBIT(val, 12, 4)
+
+#define VXGE_HW_RING_RXD_T_CODE_UNUSED		VXGE_HW_RING_T_CODE_UNUSED
+
+#define VXGE_HW_RING_RXD_SYN_GET(ctrl0)		vxge_bVALn(ctrl0, 16, 1)
+
+#define VXGE_HW_RING_RXD_IS_ICMP_GET(ctrl0)		vxge_bVALn(ctrl0, 17, 1)
+
+#define VXGE_HW_RING_RXD_RTH_SPDM_HIT_GET(ctrl0)	vxge_bVALn(ctrl0, 18, 1)
+
+#define VXGE_HW_RING_RXD_RTH_IT_HIT_GET(ctrl0)		vxge_bVALn(ctrl0, 19, 1)
+
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_GET(ctrl0)	vxge_bVALn(ctrl0, 20, 4)
+
+#define VXGE_HW_RING_RXD_IS_VLAN_GET(ctrl0)		vxge_bVALn(ctrl0, 24, 1)
+
+#define VXGE_HW_RING_RXD_ETHER_ENCAP_GET(ctrl0)		vxge_bVALn(ctrl0, 25, 2)
+
+#define VXGE_HW_RING_RXD_FRAME_PROTO_GET(ctrl0)		vxge_bVALn(ctrl0, 27, 5)
+
+#define VXGE_HW_RING_RXD_L3_CKSUM_GET(ctrl0)	vxge_bVALn(ctrl0, 32, 16)
+
+#define VXGE_HW_RING_RXD_L4_CKSUM_GET(ctrl0)	vxge_bVALn(ctrl0, 48, 16)
+
+	u64 control_1;
+
+#define VXGE_HW_RING_RXD_1_BUFFER0_SIZE_GET(ctrl1)	vxge_bVALn(ctrl1, 2, 14)
+#define VXGE_HW_RING_RXD_1_BUFFER0_SIZE(val) vxge_vBIT(val, 2, 14)
+#define VXGE_HW_RING_RXD_1_BUFFER0_SIZE_MASK		vxge_vBIT(0x3FFF, 2, 14)
+
+#define VXGE_HW_RING_RXD_1_RTH_HASH_VAL_GET(ctrl1)    vxge_bVALn(ctrl1, 16, 32)
+
+#define VXGE_HW_RING_RXD_VLAN_TAG_GET(ctrl1)	vxge_bVALn(ctrl1, 48, 16)
+
+	u64 buffer0_ptr;
+};
+
+enum vxge_hw_rth_algoritms {
+	RTH_ALG_JENKINS = 0,
+	RTH_ALG_MS_RSS	= 1,
+	RTH_ALG_CRC32C	= 2
+};
+
+/**
+ * struct vxge_hw_rth_hash_types - RTH hash types.
+ * @hash_type_tcpipv4_en: Enables RTH field type HashTypeTcpIPv4
+ * @hash_type_ipv4_en: Enables RTH field type HashTypeIPv4
+ * @hash_type_tcpipv6_en: Enables RTH field type HashTypeTcpIPv6
+ * @hash_type_ipv6_en: Enables RTH field type HashTypeIPv6
+ * @hash_type_tcpipv6ex_en: Enables RTH field type HashTypeTcpIPv6Ex
+ * @hash_type_ipv6ex_en: Enables RTH field type HashTypeIPv6Ex
+ *
+ * Used to pass RTH hash types to rts_rts_set.
+ *
+ * See also: vxge_hw_vpath_rts_rth_set(), vxge_hw_vpath_rts_rth_get().
+ */
+struct vxge_hw_rth_hash_types {
+	u8 hash_type_tcpipv4_en;
+	u8 hash_type_ipv4_en;
+	u8 hash_type_tcpipv6_en;
+	u8 hash_type_ipv6_en;
+	u8 hash_type_tcpipv6ex_en;
+	u8 hash_type_ipv6ex_en;
+};
+
+u32
+vxge_hw_device_debug_mask_get(struct __vxge_hw_device *devh);
+
+void vxge_hw_device_debug_set(
+	struct __vxge_hw_device *devh,
+	enum vxge_debug_level level,
+	u32 mask);
+
+u32
+vxge_hw_device_error_level_get(struct __vxge_hw_device *devh);
+
+u32
+vxge_hw_device_trace_level_get(struct __vxge_hw_device *devh);
+
+u32
+vxge_hw_device_debug_mask_get(struct __vxge_hw_device *devh);
+
+/**
+ * vxge_hw_ring_rxd_size_get	- Get the size of ring descriptor.
+ * @buf_mode: Buffer mode (1, 3 or 5)
+ *
+ * This function returns the size of RxD for given buffer mode
+ */
+static inline u32 vxge_hw_ring_rxd_size_get(u32 buf_mode)
+{
+	return sizeof(struct vxge_hw_ring_rxd_1);
+}
+
+/**
+ * vxge_hw_ring_rxds_per_block_get - Get the number of rxds per block.
+ * @buf_mode: Buffer mode (1 buffer mode only)
+ *
+ * This function returns the number of RxD for RxD block for given buffer mode
+ */
+static inline u32 vxge_hw_ring_rxds_per_block_get(u32 buf_mode)
+{
+	return (u32)((VXGE_HW_BLOCK_SIZE-16) /
+		sizeof(struct vxge_hw_ring_rxd_1));
+}
+
+/**
+ * vxge_hw_ring_rxd_1b_set - Prepare 1-buffer-mode descriptor.
+ * @rxdh: Descriptor handle.
+ * @dma_pointer: DMA address of	a single receive buffer	this descriptor
+ * should carry. Note that by the time vxge_hw_ring_rxd_1b_set is called,
+ * the receive buffer should be already mapped to the device
+ * @size: Size of the receive @dma_pointer buffer.
+ *
+ * Prepare 1-buffer-mode Rx	descriptor for posting
+ * (via	vxge_hw_ring_rxd_post()).
+ *
+ * This	inline helper-function does not	return any parameters and always
+ * succeeds.
+ *
+ */
+static inline
+void vxge_hw_ring_rxd_1b_set(
+	void *rxdh,
+	dma_addr_t dma_pointer,
+	u32 size)
+{
+	struct vxge_hw_ring_rxd_1 *rxdp = (struct vxge_hw_ring_rxd_1 *)rxdh;
+	rxdp->buffer0_ptr = dma_pointer;
+	rxdp->control_1	&= ~VXGE_HW_RING_RXD_1_BUFFER0_SIZE_MASK;
+	rxdp->control_1	|= VXGE_HW_RING_RXD_1_BUFFER0_SIZE(size);
+}
+
+/**
+ * vxge_hw_ring_rxd_1b_get - Get data from the completed 1-buf
+ * descriptor.
+ * @vpath_handle: Virtual Path handle.
+ * @rxdh: Descriptor handle.
+ * @dma_pointer: DMA address of	a single receive buffer	this descriptor
+ * carries. Returned by HW.
+ * @pkt_length:	Length (in bytes) of the data in the buffer pointed by
+ *
+ * Retrieve protocol data from the completed 1-buffer-mode Rx descriptor.
+ * This	inline helper-function uses completed descriptor to populate receive
+ * buffer pointer and other "out" parameters. The function always succeeds.
+ *
+ */
+static inline
+void vxge_hw_ring_rxd_1b_get(
+	struct __vxge_hw_ring *ring_handle,
+	void *rxdh,
+	u32 *pkt_length)
+{
+	struct vxge_hw_ring_rxd_1 *rxdp = (struct vxge_hw_ring_rxd_1 *)rxdh;
+
+	*pkt_length =
+		(u32)VXGE_HW_RING_RXD_1_BUFFER0_SIZE_GET(rxdp->control_1);
+}
+
+/**
+ * vxge_hw_ring_rxd_1b_info_get - Get extended information associated with
+ * a completed receive descriptor for 1b mode.
+ * @vpath_handle: Virtual Path handle.
+ * @rxdh: Descriptor handle.
+ * @rxd_info: Descriptor information
+ *
+ * Retrieve extended information associated with a completed receive descriptor.
+ *
+ */
+static inline
+void vxge_hw_ring_rxd_1b_info_get(
+	struct __vxge_hw_ring *ring_handle,
+	void *rxdh,
+	struct vxge_hw_ring_rxd_info *rxd_info)
+{
+
+	struct vxge_hw_ring_rxd_1 *rxdp = (struct vxge_hw_ring_rxd_1 *)rxdh;
+	rxd_info->syn_flag =
+		(u32)VXGE_HW_RING_RXD_SYN_GET(rxdp->control_0);
+	rxd_info->is_icmp =
+		(u32)VXGE_HW_RING_RXD_IS_ICMP_GET(rxdp->control_0);
+	rxd_info->fast_path_eligible =
+		(u32)VXGE_HW_RING_RXD_FAST_PATH_ELIGIBLE_GET(rxdp->control_0);
+	rxd_info->l3_cksum_valid =
+		(u32)VXGE_HW_RING_RXD_L3_CKSUM_CORRECT_GET(rxdp->control_0);
+	rxd_info->l3_cksum =
+		(u32)VXGE_HW_RING_RXD_L3_CKSUM_GET(rxdp->control_0);
+	rxd_info->l4_cksum_valid =
+		(u32)VXGE_HW_RING_RXD_L4_CKSUM_CORRECT_GET(rxdp->control_0);
+	rxd_info->l4_cksum =
+		(u32)VXGE_HW_RING_RXD_L4_CKSUM_GET(rxdp->control_0);;
+	rxd_info->frame =
+		(u32)VXGE_HW_RING_RXD_ETHER_ENCAP_GET(rxdp->control_0);
+	rxd_info->proto =
+		(u32)VXGE_HW_RING_RXD_FRAME_PROTO_GET(rxdp->control_0);
+	rxd_info->is_vlan =
+		(u32)VXGE_HW_RING_RXD_IS_VLAN_GET(rxdp->control_0);
+	rxd_info->vlan =
+		(u32)VXGE_HW_RING_RXD_VLAN_TAG_GET(rxdp->control_1);
+	rxd_info->rth_bucket =
+		(u32)VXGE_HW_RING_RXD_RTH_BUCKET_GET(rxdp->control_0);
+	rxd_info->rth_it_hit =
+		(u32)VXGE_HW_RING_RXD_RTH_IT_HIT_GET(rxdp->control_0);
+	rxd_info->rth_spdm_hit =
+		(u32)VXGE_HW_RING_RXD_RTH_SPDM_HIT_GET(rxdp->control_0);
+	rxd_info->rth_hash_type =
+		(u32)VXGE_HW_RING_RXD_RTH_HASH_TYPE_GET(rxdp->control_0);
+	rxd_info->rth_value =
+		(u32)VXGE_HW_RING_RXD_1_RTH_HASH_VAL_GET(rxdp->control_1);
+}
+
+/**
+ * vxge_hw_ring_rxd_private_get - Get driver private per-descriptor data
+ *                      of 1b mode 3b mode ring.
+ * @rxdh: Descriptor handle.
+ *
+ * Returns: private driver	info associated	with the descriptor.
+ * driver requests	per-descriptor space via vxge_hw_ring_attr.
+ *
+ */
+static inline void *vxge_hw_ring_rxd_private_get(void *rxdh)
+{
+	struct vxge_hw_ring_rxd_1 *rxdp = (struct vxge_hw_ring_rxd_1 *)rxdh;
+	return (void *)(size_t)rxdp->host_control;
+}
+
+/**
+ * vxge_hw_fifo_txdl_cksum_set_bits - Offload checksum.
+ * @txdlh: Descriptor handle.
+ * @cksum_bits: Specifies which checksums are to be offloaded: IPv4,
+ *              and/or TCP and/or UDP.
+ *
+ * Ask Titan to calculate IPv4 & transport checksums for _this_ transmit
+ * descriptor.
+ * This API is part of the preparation of the transmit descriptor for posting
+ * (via vxge_hw_fifo_txdl_post()). The related "preparation" APIs include
+ * vxge_hw_fifo_txdl_mss_set(), vxge_hw_fifo_txdl_buffer_set_aligned(),
+ * and vxge_hw_fifo_txdl_buffer_set().
+ * All these APIs fill in the fields of the fifo descriptor,
+ * in accordance with the Titan specification.
+ *
+ */
+static inline void vxge_hw_fifo_txdl_cksum_set_bits(void *txdlh, u64 cksum_bits)
+{
+	struct vxge_hw_fifo_txd *txdp = (struct vxge_hw_fifo_txd *)txdlh;
+	txdp->control_1 |= cksum_bits;
+}
+
+/**
+ * vxge_hw_fifo_txdl_mss_set - Set MSS.
+ * @txdlh: Descriptor handle.
+ * @mss: MSS size for _this_ TCP connection. Passed by TCP stack down to the
+ *       driver, which in turn inserts the MSS into the @txdlh.
+ *
+ * This API is part of the preparation of the transmit descriptor for posting
+ * (via vxge_hw_fifo_txdl_post()). The related "preparation" APIs include
+ * vxge_hw_fifo_txdl_buffer_set(), vxge_hw_fifo_txdl_buffer_set_aligned(),
+ * and vxge_hw_fifo_txdl_cksum_set_bits().
+ * All these APIs fill in the fields of the fifo descriptor,
+ * in accordance with the Titan specification.
+ *
+ */
+static inline void vxge_hw_fifo_txdl_mss_set(void *txdlh, int mss)
+{
+	struct vxge_hw_fifo_txd *txdp = (struct vxge_hw_fifo_txd *)txdlh;
+
+	txdp->control_0 |= VXGE_HW_FIFO_TXD_LSO_EN;
+	txdp->control_0 |= VXGE_HW_FIFO_TXD_LSO_MSS(mss);
+}
+
+/**
+ * vxge_hw_fifo_txdl_vlan_set - Set VLAN tag.
+ * @txdlh: Descriptor handle.
+ * @vlan_tag: 16bit VLAN tag.
+ *
+ * Insert VLAN tag into specified transmit descriptor.
+ * The actual insertion of the tag into outgoing frame is done by the hardware.
+ */
+static inline void vxge_hw_fifo_txdl_vlan_set(void *txdlh, u16 vlan_tag)
+{
+	struct vxge_hw_fifo_txd *txdp = (struct vxge_hw_fifo_txd *)txdlh;
+
+	txdp->control_1 |= VXGE_HW_FIFO_TXD_VLAN_ENABLE;
+	txdp->control_1 |= VXGE_HW_FIFO_TXD_VLAN_TAG(vlan_tag);
+}
+
+/**
+ * vxge_hw_fifo_txdl_private_get - Retrieve per-descriptor private data.
+ * @txdlh: Descriptor handle.
+ *
+ * Retrieve per-descriptor private data.
+ * Note that driver requests per-descriptor space via
+ * struct vxge_hw_fifo_attr passed to
+ * vxge_hw_vpath_open().
+ *
+ * Returns: private driver data associated with the descriptor.
+ */
+static inline void *vxge_hw_fifo_txdl_private_get(void *txdlh)
+{
+	struct vxge_hw_fifo_txd *txdp  = (struct vxge_hw_fifo_txd *)txdlh;
+
+	return (void *)(size_t)txdp->host_control;
+}
+
+/**
+ * struct vxge_hw_ring_attr - Ring open "template".
+ * @callback: Ring completion callback. HW invokes the callback when there
+ *            are new completions on that ring. In many implementations
+ *            the @callback executes in the hw interrupt context.
+ * @rxd_init: Ring's descriptor-initialize callback.
+ *            See vxge_hw_ring_rxd_init_f{}.
+ *            If not NULL, HW invokes the callback when opening
+ *            the ring.
+ * @rxd_term: Ring's descriptor-terminate callback. If not NULL,
+ *          HW invokes the callback when closing the corresponding ring.
+ *          See also vxge_hw_ring_rxd_term_f{}.
+ * @userdata: User-defined "context" of _that_ ring. Passed back to the
+ *            user as one of the @callback, @rxd_init, and @rxd_term arguments.
+ * @per_rxd_space: If specified (i.e., greater than zero): extra space
+ *              reserved by HW per each receive descriptor.
+ *              Can be used to store
+ *              and retrieve on completion, information specific
+ *              to the driver.
+ *
+ * Ring open "template". User fills the structure with ring
+ * attributes and passes it to vxge_hw_vpath_open().
+ */
+struct vxge_hw_ring_attr {
+	enum vxge_hw_status (*callback)(
+			struct __vxge_hw_ring *ringh,
+			void *rxdh,
+			u8 t_code,
+			void *userdata);
+
+	enum vxge_hw_status (*rxd_init)(
+			void *rxdh,
+			void *userdata);
+
+	void (*rxd_term)(
+			void *rxdh,
+			enum vxge_hw_rxd_state state,
+			void *userdata);
+
+	void		*userdata;
+	u32		per_rxd_space;
+};
+
+/**
+ * function vxge_hw_fifo_callback_f - FIFO callback.
+ * @vpath_handle: Virtual path whose Fifo "containing" 1 or more completed
+ *             descriptors.
+ * @txdlh: First completed descriptor.
+ * @txdl_priv: Pointer to per txdl space allocated
+ * @t_code: Transfer code, as per Titan User Guide.
+ *          Returned by HW.
+ * @host_control: Opaque 64bit data stored by driver inside the Titan
+ *            descriptor prior to posting the latter on the fifo
+ *            via vxge_hw_fifo_txdl_post(). The @host_control is returned
+ *            as is to the driver with each completed descriptor.
+ * @userdata: Opaque per-fifo data specified at fifo open
+ *            time, via vxge_hw_vpath_open().
+ *
+ * Fifo completion callback (type declaration). A single per-fifo
+ * callback is specified at fifo open time, via
+ * vxge_hw_vpath_open(). Typically gets called as part of the processing
+ * of the Interrupt Service Routine.
+ *
+ * Fifo callback gets called by HW if, and only if, there is at least
+ * one new completion on a given fifo. Upon processing the first @txdlh driver
+ * is _supposed_ to continue consuming completions using:
+ *    - vxge_hw_fifo_txdl_next_completed()
+ *
+ * Note that failure to process new completions in a timely fashion
+ * leads to VXGE_HW_INF_OUT_OF_DESCRIPTORS condition.
+ *
+ * Non-zero @t_code means failure to process transmit descriptor.
+ *
+ * In the "transmit" case the failure could happen, for instance, when the
+ * link is down, in which case Titan completes the descriptor because it
+ * is not able to send the data out.
+ *
+ * For details please refer to Titan User Guide.
+ *
+ * See also: vxge_hw_fifo_txdl_next_completed(), vxge_hw_fifo_txdl_term_f{}.
+ */
+/**
+ * function vxge_hw_fifo_txdl_term_f - Terminate descriptor callback.
+ * @txdlh: First completed descriptor.
+ * @txdl_priv: Pointer to per txdl space allocated
+ * @state: One of the enum vxge_hw_txdl_state{} enumerated states.
+ * @userdata: Per-fifo user data (a.k.a. context) specified at
+ * fifo open time, via vxge_hw_vpath_open().
+ *
+ * Terminate descriptor callback. Unless NULL is specified in the
+ * struct vxge_hw_fifo_attr{} structure passed to vxge_hw_vpath_open()),
+ * HW invokes the callback as part of closing fifo, prior to
+ * de-allocating the ring and associated data structures
+ * (including descriptors).
+ * driver should utilize the callback to (for instance) unmap
+ * and free DMA data buffers associated with the posted (state =
+ * VXGE_HW_TXDL_STATE_POSTED) descriptors,
+ * as well as other relevant cleanup functions.
+ *
+ * See also: struct vxge_hw_fifo_attr{}
+ */
+/**
+ * struct vxge_hw_fifo_attr - Fifo open "template".
+ * @callback: Fifo completion callback. HW invokes the callback when there
+ *            are new completions on that fifo. In many implementations
+ *            the @callback executes in the hw interrupt context.
+ * @txdl_term: Fifo's descriptor-terminate callback. If not NULL,
+ *          HW invokes the callback when closing the corresponding fifo.
+ *          See also vxge_hw_fifo_txdl_term_f{}.
+ * @userdata: User-defined "context" of _that_ fifo. Passed back to the
+ *            user as one of the @callback, and @txdl_term arguments.
+ * @per_txdl_space: If specified (i.e., greater than zero): extra space
+ *              reserved by HW per each transmit descriptor. Can be used to
+ *              store, and retrieve on completion, information specific
+ *              to the driver.
+ *
+ * Fifo open "template". User fills the structure with fifo
+ * attributes and passes it to vxge_hw_vpath_open().
+ */
+struct vxge_hw_fifo_attr {
+
+	enum vxge_hw_status (*callback)(
+			struct __vxge_hw_fifo *fifo_handle,
+			void *txdlh,
+			enum vxge_hw_fifo_tcode t_code,
+			void *userdata,
+			void **skb_ptr);
+
+	void (*txdl_term)(
+			void *txdlh,
+			enum vxge_hw_txdl_state state,
+			void *userdata);
+
+	void		*userdata;
+	u32		per_txdl_space;
+};
+
+/**
+ * struct vxge_hw_vpath_attr - Attributes of virtual path
+ * @vp_id: Identifier of Virtual Path
+ * @ring_attr: Attributes of ring for non-offload receive
+ * @fifo_attr: Attributes of fifo for non-offload transmit
+ *
+ * Attributes of virtual path.  This structure is passed as parameter
+ * to the vxge_hw_vpath_open() routine to set the attributes of ring and fifo.
+ */
+struct vxge_hw_vpath_attr {
+	u32				vp_id;
+	struct vxge_hw_ring_attr	ring_attr;
+	struct vxge_hw_fifo_attr	fifo_attr;
+};
+
+enum vxge_hw_status
+__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
+			struct __vxge_hw_blockpool  *blockpool,
+			u32 pool_size,
+			u32 pool_max);
+
+void
+__vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool  *blockpool);
+
+struct __vxge_hw_blockpool_entry *
+__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *hldev,
+			u32 size);
+
+void
+__vxge_hw_blockpool_block_free(struct __vxge_hw_device *hldev,
+			struct __vxge_hw_blockpool_entry *entry);
+
+void *
+__vxge_hw_blockpool_malloc(struct __vxge_hw_device *hldev,
+			u32 size,
+			struct vxge_hw_mempool_dma *dma_object);
+
+void
+__vxge_hw_blockpool_free(struct __vxge_hw_device *hldev,
+			void *memblock,
+			u32 size,
+			struct vxge_hw_mempool_dma *dma_object);
+
+enum vxge_hw_status
+__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config);
+
+enum vxge_hw_status
+__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config);
+
+enum vxge_hw_status
+vxge_hw_mgmt_device_config(struct __vxge_hw_device *devh,
+		struct vxge_hw_device_config	*dev_config, int size);
+
+enum vxge_hw_status __devinit vxge_hw_device_hw_info_get(
+	void __iomem *bar0,
+	struct vxge_hw_device_hw_info *hw_info);
+
+enum vxge_hw_status
+__vxge_hw_vpath_fw_ver_get(
+	u32	vp_id,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg,
+	struct vxge_hw_device_hw_info *hw_info);
+
+enum vxge_hw_status
+__vxge_hw_vpath_card_info_get(
+	u32 vp_id,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg,
+	struct vxge_hw_device_hw_info *hw_info);
+
+enum vxge_hw_status __devinit vxge_hw_device_config_default_get(
+	struct vxge_hw_device_config *device_config);
+
+/**
+ * vxge_hw_device_link_state_get - Get link state.
+ * @devh: HW device handle.
+ *
+ * Get link state.
+ * Returns: link state.
+ */
+static inline
+enum vxge_hw_device_link_state vxge_hw_device_link_state_get(
+	struct __vxge_hw_device *devh)
+{
+	return devh->link_state;
+}
+
+void vxge_hw_device_terminate(struct __vxge_hw_device *devh);
+
+const u8 *
+vxge_hw_device_serial_number_get(struct __vxge_hw_device *devh);
+
+u16 vxge_hw_device_link_width_get(struct __vxge_hw_device *devh);
+
+const u8 *
+vxge_hw_device_product_name_get(struct __vxge_hw_device *devh);
+
+enum vxge_hw_status __devinit vxge_hw_device_initialize(
+	struct __vxge_hw_device **devh,
+	struct vxge_hw_device_attr *attr,
+	struct vxge_hw_device_config *device_config);
+
+enum vxge_hw_status vxge_hw_device_getpause_data(
+	 struct __vxge_hw_device *devh,
+	 u32 port,
+	 u32 *tx,
+	 u32 *rx);
+
+enum vxge_hw_status vxge_hw_device_setpause_data(
+	struct __vxge_hw_device *devh,
+	u32 port,
+	u32 tx,
+	u32 rx);
+
+static inline void *vxge_os_dma_malloc(struct pci_dev *pdev,
+			unsigned long size,
+			struct pci_dev **p_dmah,
+			struct pci_dev **p_dma_acch)
+{
+	gfp_t flags;
+	void *vaddr;
+	unsigned long misaligned = 0;
+	*p_dma_acch = *p_dmah = NULL;
+
+	if (in_interrupt())
+		flags = GFP_ATOMIC | GFP_DMA;
+	else
+		flags = GFP_KERNEL | GFP_DMA;
+
+	size += VXGE_CACHE_LINE_SIZE;
+
+	vaddr = kmalloc((size), flags);
+	if (vaddr == NULL)
+		return vaddr;
+	misaligned = (unsigned long)VXGE_ALIGN(*((u64 *)&vaddr),
+				VXGE_CACHE_LINE_SIZE);
+	*(unsigned long *)p_dma_acch = misaligned;
+	vaddr = (void *)((u8 *)vaddr + misaligned);
+	return vaddr;
+}
+
+extern void vxge_hw_blockpool_block_add(
+			struct __vxge_hw_device *devh,
+			void *block_addr,
+			u32 length,
+			struct pci_dev *dma_h,
+			struct pci_dev *acc_handle);
+
+static inline void vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh,
+					unsigned long size)
+{
+	gfp_t flags;
+	void *vaddr;
+
+	if (in_interrupt())
+		flags = GFP_ATOMIC | GFP_DMA;
+	else
+		flags = GFP_KERNEL | GFP_DMA;
+
+	vaddr = kmalloc((size), flags);
+
+	vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
+}
+
+static inline void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
+			struct pci_dev **p_dma_acch)
+{
+	unsigned long misaligned = *(unsigned long *)p_dma_acch;
+	u8 *tmp = (u8 *)vaddr;
+	tmp -= misaligned;
+	kfree((void *)tmp);
+}
+
+/*
+ * __vxge_hw_mempool_item_priv - will return pointer on per item private space
+ */
+static inline void*
+__vxge_hw_mempool_item_priv(
+	struct vxge_hw_mempool *mempool,
+	u32 memblock_idx,
+	void *item,
+	u32 *memblock_item_idx)
+{
+	ptrdiff_t offset;
+	void *memblock = mempool->memblocks_arr[memblock_idx];
+
+
+	offset = (u32)((u8 *)item - (u8 *)memblock);
+	vxge_assert(offset >= 0 && (u32)offset < mempool->memblock_size);
+
+	(*memblock_item_idx) = (u32) offset / mempool->item_size;
+	vxge_assert((*memblock_item_idx) < mempool->items_per_memblock);
+
+	return (u8 *)mempool->memblocks_priv_arr[memblock_idx] +
+			    (*memblock_item_idx) * mempool->items_priv_size;
+}
+
+enum vxge_hw_status
+__vxge_hw_mempool_grow(
+	struct vxge_hw_mempool *mempool,
+	u32 num_allocate,
+	u32 *num_allocated);
+
+struct vxge_hw_mempool*
+__vxge_hw_mempool_create(
+	struct __vxge_hw_device *devh,
+	u32 memblock_size,
+	u32 item_size,
+	u32 private_size,
+	u32 items_initial,
+	u32 items_max,
+	struct vxge_hw_mempool_cbs *mp_callback,
+	void *userdata);
+
+struct __vxge_hw_channel*
+__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
+			enum __vxge_hw_channel_type type, u32 length,
+			u32 per_dtr_space, void *userdata);
+
+void
+__vxge_hw_channel_free(
+	struct __vxge_hw_channel *channel);
+
+enum vxge_hw_status
+__vxge_hw_channel_initialize(
+	struct __vxge_hw_channel *channel);
+
+enum vxge_hw_status
+__vxge_hw_channel_reset(
+	struct __vxge_hw_channel *channel);
+
+/*
+ * __vxge_hw_fifo_txdl_priv - Return the max fragments allocated
+ * for the fifo.
+ * @fifo: Fifo
+ * @txdp: Poniter to a TxD
+ */
+static inline struct __vxge_hw_fifo_txdl_priv *
+__vxge_hw_fifo_txdl_priv(
+	struct __vxge_hw_fifo *fifo,
+	struct vxge_hw_fifo_txd *txdp)
+{
+	return (struct __vxge_hw_fifo_txdl_priv *)
+			(((char *)((ulong)txdp->host_control)) +
+				fifo->per_txdl_space);
+}
+
+enum vxge_hw_status vxge_hw_vpath_open(
+	struct __vxge_hw_device *devh,
+	struct vxge_hw_vpath_attr *attr,
+	struct __vxge_hw_vpath_handle **vpath_handle);
+
+enum vxge_hw_status
+__vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog);
+
+enum vxge_hw_status vxge_hw_vpath_close(
+	struct __vxge_hw_vpath_handle *vpath_handle);
+
+enum vxge_hw_status
+vxge_hw_vpath_reset(
+	struct __vxge_hw_vpath_handle *vpath_handle);
+
+enum vxge_hw_status
+vxge_hw_vpath_recover_from_reset(
+	struct __vxge_hw_vpath_handle *vpath_handle);
+
+void
+vxge_hw_vpath_enable(struct __vxge_hw_vpath_handle *vp);
+
+enum vxge_hw_status
+vxge_hw_vpath_check_leak(struct __vxge_hw_ring *ringh);
+
+enum vxge_hw_status vxge_hw_vpath_mtu_set(
+	struct __vxge_hw_vpath_handle *vpath_handle,
+	u32 new_mtu);
+
+enum vxge_hw_status vxge_hw_vpath_stats_enable(
+	struct __vxge_hw_vpath_handle *vpath_handle);
+
+enum vxge_hw_status
+__vxge_hw_vpath_stats_access(
+	struct __vxge_hw_virtualpath	*vpath,
+	u32			operation,
+	u32			offset,
+	u64			*stat);
+
+enum vxge_hw_status
+__vxge_hw_vpath_xmac_tx_stats_get(
+	struct __vxge_hw_virtualpath	*vpath,
+	struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats);
+
+enum vxge_hw_status
+__vxge_hw_vpath_xmac_rx_stats_get(
+	struct __vxge_hw_virtualpath	*vpath,
+	struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats);
+
+enum vxge_hw_status
+__vxge_hw_vpath_stats_get(
+	struct __vxge_hw_virtualpath *vpath,
+	struct vxge_hw_vpath_stats_hw_info *hw_stats);
+
+void
+vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp);
+
+enum vxge_hw_status
+__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config);
+
+void
+__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev);
+
+enum vxge_hw_status
+__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg);
+
+enum vxge_hw_status
+__vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg);
+
+enum vxge_hw_status
+__vxge_hw_kdfc_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg);
+
+enum vxge_hw_status
+__vxge_hw_device_register_poll(
+	void __iomem	*reg,
+	u64 mask, u32 max_millis);
+
+#ifndef readq
+static inline u64 readq(void __iomem *addr)
+{
+	u64 ret = 0;
+	ret = readl(addr + 4);
+	ret <<= 32;
+	ret |= readl(addr);
+
+	return ret;
+}
+#endif
+
+#ifndef writeq
+static inline void writeq(u64 val, void __iomem *addr)
+{
+	writel((u32) (val), addr);
+	writel((u32) (val >> 32), (addr + 4));
+}
+#endif
+
+static inline void __vxge_hw_pio_mem_write32_upper(u32 val, void __iomem *addr)
+{
+	writel(val, addr + 4);
+}
+
+static inline void __vxge_hw_pio_mem_write32_lower(u32 val, void __iomem *addr)
+{
+	writel(val, addr);
+}
+
+static inline enum vxge_hw_status
+__vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
+			  u64 mask, u32 max_millis)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	__vxge_hw_pio_mem_write32_lower((u32)vxge_bVALn(val64, 32, 32), addr);
+	wmb();
+	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32), addr);
+	wmb();
+
+	status = __vxge_hw_device_register_poll(addr, mask, max_millis);
+	return status;
+}
+
+struct vxge_hw_toc_reg __iomem *
+__vxge_hw_device_toc_get(void __iomem *bar0);
+
+enum vxge_hw_status
+__vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev);
+
+void
+__vxge_hw_device_id_get(struct __vxge_hw_device *hldev);
+
+void
+__vxge_hw_device_host_info_get(struct __vxge_hw_device *hldev);
+
+enum vxge_hw_status
+vxge_hw_device_flick_link_led(struct __vxge_hw_device *devh, u64 on_off);
+
+enum vxge_hw_status
+__vxge_hw_device_initialize(struct __vxge_hw_device *hldev);
+
+enum vxge_hw_status
+__vxge_hw_vpath_pci_read(
+	struct __vxge_hw_virtualpath	*vpath,
+	u32			phy_func_0,
+	u32			offset,
+	u32			*val);
+
+enum vxge_hw_status
+__vxge_hw_vpath_addr_get(
+	u32 vp_id,
+	struct vxge_hw_vpath_reg __iomem *vpath_reg,
+	u8 (macaddr)[ETH_ALEN],
+	u8 (macaddr_mask)[ETH_ALEN]);
+
+u32
+__vxge_hw_vpath_func_id_get(
+	u32 vp_id, struct vxge_hw_vpmgmt_reg __iomem *vpmgmt_reg);
+
+enum vxge_hw_status
+__vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
+
+/**
+ * vxge_debug
+ * @level: level of debug verbosity.
+ * @mask: mask for the debug
+ * @buf: Circular buffer for tracing
+ * @fmt: printf like format string
+ *
+ * Provides logging facilities. Can be customized on per-module
+ * basis or/and with debug levels. Input parameters, except
+ * module and level, are the same as posix printf. This function
+ * may be compiled out if DEBUG macro was never defined.
+ * See also: enum vxge_debug_level{}.
+ */
+
+#define vxge_trace_aux(level, mask, fmt, ...) \
+{\
+		vxge_os_vaprintf(level, mask, fmt, __VA_ARGS__);\
+}
+
+#define vxge_debug(module, level, mask, fmt, ...) { \
+if ((level >= VXGE_TRACE && ((module & VXGE_DEBUG_TRACE_MASK) == module)) || \
+	(level >= VXGE_ERR && ((module & VXGE_DEBUG_ERR_MASK) == module))) {\
+	if ((mask & VXGE_DEBUG_MASK) == mask)\
+		vxge_trace_aux(level, mask, fmt, __VA_ARGS__); \
+} \
+}
+
+#if (VXGE_COMPONENT_LL & VXGE_DEBUG_MODULE_MASK)
+#define vxge_debug_ll(level, mask, fmt, ...) \
+{\
+	vxge_debug(VXGE_COMPONENT_LL, level, mask, fmt, __VA_ARGS__);\
+}
+
+#else
+#define vxge_debug_ll(level, mask, fmt, ...)
+#endif
+
+enum vxge_hw_status vxge_hw_vpath_rts_rth_itable_set(
+			struct __vxge_hw_vpath_handle **vpath_handles,
+			u32 vpath_count,
+			u8 *mtable,
+			u8 *itable,
+			u32 itable_size);
+
+enum vxge_hw_status vxge_hw_vpath_rts_rth_set(
+	struct __vxge_hw_vpath_handle *vpath_handle,
+	enum vxge_hw_rth_algoritms algorithm,
+	struct vxge_hw_rth_hash_types *hash_type,
+	u16 bucket_size);
+
+#endif



