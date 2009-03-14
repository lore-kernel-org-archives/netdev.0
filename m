From: Ramkrishna Vepa <ram.vepa@neterion.com>
Subject: [net-2.6 PATCH 6/10] Neterion: New driver: Hardware init &
	configuration
Date: 14 Mar 2009 00:21:44 -0800
Message-ID: <1237018885.4966.431.camel@flash>
Reply-To: ram.vepa@neterion.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ramkrishna Vepa <ram.vepa@neterion.com>
To: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60416 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753248AbZCNHxY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2009 03:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch takes care of Initialization and configuration steps of
Neterion Inc's X3100 Series 10GbE PCIe I/O Virtualized Server Adapter.
- Device Initialization.
- Verification and setting of device config parameters.
- Allocation of Tx FIFO and Rx Ring descriptors (DTR).
- APIs to get various type of hw stats
- APIs to configure RTS (Receive Traffic Steering)

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Rastapur Santosh <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_5/drivers/net/vxge/vxge-config.c patch_6/drivers/net/vxge/vxge-config.c
--- patch_5/drivers/net/vxge/vxge-config.c	1969-12-31 16:00:00.000000000 -0800
+++ patch_6/drivers/net/vxge/vxge-config.c	2009-03-13 00:11:27.000000000 -0700
@@ -0,0 +1,7576 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ ******************************************************************************/
+/*******************************************************************************
+ * vxge-config.c: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *                Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#include <linux/version.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/pci.h>
+#include <linux/delay.h>
+
+#include "vxge-traffic.h"
+#include "vxge-config.h"
+
+/*
+ * __hw_channel_allocate - Allocate memory for channel
+ * @devh: Handle to the device object
+ * @vph: Handle to Virtual Path
+ * @type: Type of channel
+ * @length: Lengths of arrays
+ * @alloc_work_array: Flag to specify if work array is required
+ * @alloc_free_array: Flag to specify if free array is required
+ * @alloc_reserve_array: Flag to specify if reserve array is required
+ * @per_dtr_space: driver requested per dtr space to be allocated in priv
+ * @userdata: User data to be passed back in the callback
+ *
+ * This function allocates required memory for the channel and various arrays
+ * in the channel
+ */
+struct __hw_channel*
+__hw_channel_allocate(
+	struct __hw_device *hldev,
+	struct __hw_vpath_handle *vph,
+	enum __hw_channel_type type,
+	u32 length,
+	u32 alloc_work_array,
+	u32 alloc_free_array,
+	u32 alloc_reserve_array,
+	u32 per_dtr_space,
+	void *userdata)
+{
+	struct __hw_channel *channel;
+	int size = 0;
+	u32 vp_id;
+
+	vxge_assert((hldev != NULL) && (vph != NULL));
+
+	vp_id = ((struct __hw_vpath_handle *)vph)->vpath->vp_id;
+
+	switch (type) {
+	case VXGE_HW_CHANNEL_TYPE_FIFO:
+		size = sizeof(struct __hw_fifo);
+		break;
+	case VXGE_HW_CHANNEL_TYPE_RING:
+		size = sizeof(struct __hw_ring);
+		break;
+	default:
+		vxge_assert(size);
+		break;
+
+	}
+
+	channel = (struct __hw_channel *) vmalloc(size);
+	if (channel == NULL)
+		goto exit0;
+	memset(channel, 0, size);
+	vxge_list_init(&channel->item);
+
+	channel->common_reg = hldev->common_reg;
+	channel->first_vp_id = hldev->first_vp_id;
+	channel->type		= type;
+	channel->devh		= hldev;
+	channel->vph		= vph;
+
+	channel->userdata = userdata;
+	channel->per_dtr_space = per_dtr_space;
+
+	channel->length = length;
+	channel->vp_id	= vp_id;
+
+	if (alloc_work_array) {
+		channel->work_arr = (void **) vmalloc(sizeof(void *)*length);
+		if (channel->work_arr == NULL)
+			goto exit1;
+		memset(channel->work_arr, 0, sizeof(void *)*length);
+	}
+
+	channel->post_index = 0;
+	channel->compl_index = 0;
+
+	if (alloc_free_array) {
+		channel->free_arr = (void **) vmalloc(sizeof(void *)*length);
+		if (channel->free_arr == NULL)
+			goto exit1;
+		memset(channel->free_arr, 0, sizeof(void *)*length);
+	}
+
+	channel->free_ptr = length;
+
+	if (alloc_reserve_array) {
+		channel->reserve_arr =
+			(void **) vmalloc(sizeof(void *)*length);
+		if (channel->reserve_arr == NULL)
+			goto exit1;
+
+		memset(channel->reserve_arr, 0, sizeof(void *)*length);
+	}
+
+	channel->reserve_ptr = length;
+	channel->reserve_top = 0;
+
+	if (alloc_reserve_array) {
+		channel->orig_arr = (void **) vmalloc(sizeof(void *) * length);
+		if (channel->orig_arr == NULL)
+			goto exit1;
+
+		memset(channel->orig_arr, 0, sizeof(void *)*length);
+	}
+
+	channel->level_err = vxge_hw_device_error_level_get(hldev);
+	channel->level_trace = vxge_hw_device_trace_level_get(hldev);
+
+	return channel;
+exit1:
+	__hw_channel_free(channel);
+
+exit0:
+
+	return NULL;
+}
+
+/*
+ * __hw_channel_free - Free memory allocated for channel
+ * @channel: channel to be freed
+ *
+ * This function deallocates memory from the channel and various arrays
+ * in the channel
+ */
+void
+__hw_channel_free(
+	struct __hw_channel *channel)
+{
+	u32	vp_id = 0;
+	struct __hw_device  *hldev;
+
+	vxge_assert(channel != NULL);
+
+	hldev = (struct __hw_device  *)channel->devh;
+
+	vp_id = ((struct __hw_vpath_handle *)channel->vph)->vpath->vp_id;
+
+	if (channel->work_arr) {
+		vfree(channel->work_arr);
+		channel->work_arr = NULL;
+	}
+
+	if (channel->free_arr) {
+		vfree(channel->free_arr);
+		channel->free_arr = NULL;
+	}
+
+	if (channel->reserve_arr) {
+		vfree(channel->reserve_arr);
+		channel->reserve_arr = NULL;
+	}
+
+	if (channel->orig_arr) {
+		vfree(channel->orig_arr);
+		channel->orig_arr = NULL;
+	}
+
+	vfree(channel);
+
+}
+
+/*
+ * __hw_channel_initialize - Initialize a channel
+ * @channel: channel to be initialized
+ *
+ * This function initializes a channel by properly setting the
+ * various references
+ */
+enum vxge_hw_status
+__hw_channel_initialize(
+	struct __hw_channel *channel)
+{
+	u32 i;
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(channel != NULL);
+
+	vpath = (struct __hw_virtualpath *)((struct __hw_vpath_handle *) \
+						channel->vph)->vpath;
+	vxge_assert(vpath != NULL);
+
+	if ((channel->reserve_arr != NULL) && (channel->orig_arr != NULL)) {
+		for (i = 0; i < channel->length; i++)
+			channel->orig_arr[i] = channel->reserve_arr[i];
+	}
+
+	switch (channel->type) {
+	case VXGE_HW_CHANNEL_TYPE_FIFO:
+		vpath->fifoh = (struct __hw_fifo *)channel;
+		channel->stats = &((struct __hw_fifo *) \
+				channel)->stats->common_stats;
+		break;
+	case VXGE_HW_CHANNEL_TYPE_RING:
+		vpath->ringh = (struct __hw_ring *)channel;
+		channel->stats = &((struct __hw_ring *) \
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
+ * __hw_channel_reset - Resets a channel
+ * @channel: channel to be reset
+ *
+ * This function resets a channel by properly setting the various references
+ */
+enum vxge_hw_status
+__hw_channel_reset(
+	struct __hw_channel *channel)
+{
+	u32 i;
+	struct __hw_device *hldev;
+
+	vxge_assert(channel != NULL);
+
+	hldev = (struct __hw_device *)channel->devh;
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
+ * __hw_device_pci_caps_list_process
+ * @hldev: HW device handle.
+ *
+ * Process PCI capabilities and initialize the offsets
+ */
+void
+__hw_device_pci_caps_list_process(struct __hw_device *hldev)
+{
+	u8 cap_id;
+	u16 next_ptr;
+	struct vxge_hw_pci_config *pci_config = &hldev->pci_config_space_bios;
+
+	vxge_assert(hldev != NULL);
+
+	next_ptr = pci_config->capabilities_pointer;
+
+	while (next_ptr != 0) {
+
+		cap_id = VXGE_HW_PCI_CAP_ID((((u8 *)pci_config)  +  next_ptr));
+
+		switch (cap_id) {
+
+		case VXGE_HW_PCI_CAP_ID_PM:
+			hldev->pci_caps.pm_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_VPD:
+			hldev->pci_caps.vpd_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_SLOTID:
+			hldev->pci_caps.sid_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_MSI:
+			hldev->pci_caps.msi_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_VS:
+			hldev->pci_caps.vs_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_SHPC:
+			hldev->pci_caps.shpc_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_PCIE:
+			hldev->pci_e_caps = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_MSIX:
+			hldev->pci_caps.msix_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_CAP_ID_AGP:
+		case VXGE_HW_PCI_CAP_ID_CHSWP:
+		case VXGE_HW_PCI_CAP_ID_PCIX:
+		case VXGE_HW_PCI_CAP_ID_HT:
+		case VXGE_HW_PCI_CAP_ID_DBGPORT:
+		case VXGE_HW_PCI_CAP_ID_CPCICSR:
+		case VXGE_HW_PCI_CAP_ID_PCIBSVID:
+		case VXGE_HW_PCI_CAP_ID_AGP8X:
+		case VXGE_HW_PCI_CAP_ID_SECDEV:
+
+			break;
+		default:
+
+			break;
+		}
+
+		next_ptr =
+			VXGE_HW_PCI_CAP_NEXT((((u8 *)pci_config)  +  next_ptr));
+
+	}
+
+	if (VXGE_HW_PCI_CONFIG_SPACE_SIZE <= 0x100)
+		goto exit;
+
+	next_ptr = 0x100;
+
+	while (next_ptr != 0) {
+
+		cap_id = (u8)VXGE_HW_PCI_EXT_CAP_ID(
+				*(u32 *)(((u8 *)pci_config)  +  next_ptr));
+
+		switch (cap_id) {
+
+		case VXGE_HW_PCI_EXT_CAP_ID_ERR:
+			hldev->pci_e_ext_caps.err_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_EXT_CAP_ID_VC:
+			hldev->pci_e_ext_caps.vc_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_EXT_CAP_ID_DSN:
+			hldev->pci_e_ext_caps.dsn_cap_offset = next_ptr;
+			break;
+		case VXGE_HW_PCI_EXT_CAP_ID_PWR:
+			hldev->pci_e_ext_caps.pwr_budget_cap_offset = next_ptr;
+			break;
+
+		default:
+
+			break;
+		}
+
+		next_ptr = (u16)VXGE_HW_PCI_EXT_CAP_NEXT(
+				*(u32 *)(((u8 *)pci_config)  +  next_ptr));
+
+	}
+exit:
+
+	return;
+}
+
+/*
+ * __hw_device_pci_e_init
+ * @hldev: HW device handle.
+ *
+ * Initialize certain PCI/PCI-X configuration registers
+ * with recommended values. Save config space for future hw resets.
+ */
+void
+__hw_device_pci_e_init(struct __hw_device *hldev)
+{
+	int i;
+	u16 cmd = 0;
+	u16 device_id;
+	u8  revision;
+
+	vxge_assert(hldev != NULL);
+
+	/* Store PCI device ID and revision for future references where in we
+	 * decide Xena revision using PCI sub system ID */
+	pci_read_config_word(hldev->pdev,
+			vxge_offsetof(struct vxge_hw_pci_config_le, device_id),
+			&device_id);
+
+	pci_read_config_byte(hldev->pdev, vxge_offsetof(
+				struct vxge_hw_pci_config_le, revision),
+				&revision);
+
+	/* save original PCI config space to restore it on device_terminate() */
+	for (i = 0; i < VXGE_HW_PCI_CONFIG_SPACE_SIZE/4; i++) {
+		pci_read_config_dword(hldev->pdev, i * 4,
+				(u32 *)&hldev->pci_config_space_bios  +  i);
+	}
+
+	__hw_device_pci_caps_list_process(hldev);
+
+	/* Set the PErr Repconse bit and SERR in PCI command register. */
+	pci_read_config_word(hldev->pdev,
+			vxge_offsetof(struct vxge_hw_pci_config_le, command),
+			&cmd);
+	cmd |= 0x140;
+	pci_write_config_word(hldev->pdev,
+			vxge_offsetof(struct vxge_hw_pci_config_le, command),
+			cmd);
+
+	/* save PCI config space for future resets */
+	for (i = 0; i < VXGE_HW_PCI_CONFIG_SPACE_SIZE/4; i++) {
+		pci_read_config_dword(hldev->pdev, i * 4,
+					(u32 *)&hldev->pci_config_space  +  i);
+	}
+
+	return;
+}
+
+/*
+ * __hw_device_register_poll
+ * @reg: register to poll for
+ * @op: 0 - bit reset, 1 - bit set
+ * @mask: mask for logical "and" condition based on %op
+ * @max_millis: maximum time to try to poll in milliseconds
+ *
+ * Will poll certain register for specified amount of time.
+ * Will poll until masked bit is not cleared.
+ */
+enum vxge_hw_status
+__hw_device_register_poll(u64		*reg,
+			u32		op,
+			u64		mask,
+			u32		max_millis)
+{
+	u64 val64;
+	u32 i = 0;
+	enum vxge_hw_status ret = VXGE_HW_FAIL;
+
+	vxge_os_udelay(10);
+
+	do {
+		val64 = readq(reg);
+		if (op == 0 && !(val64 & mask))
+			return VXGE_HW_OK;
+		else if (op == 1 && (val64 & mask) == mask)
+			return VXGE_HW_OK;
+		vxge_os_udelay(100);
+	} while (++i <= 9);
+
+	do {
+		val64 = readq(reg);
+		if (op == 0 && !(val64 & mask))
+			return VXGE_HW_OK;
+		else if (op == 1 && (val64 & mask) == mask)
+			return VXGE_HW_OK;
+		vxge_os_udelay(1000);
+	} while (++i < max_millis);
+
+	return ret;
+}
+
+/*
+ * __hw_device_vpath_reset_in_prog_check - Check if vpath reset in progress
+ *
+ * @vpath_rst_in_prog: Address of vpath reset in progress register
+ *
+ * This routine checks the vpath reset in progress register is turned zero
+ */
+enum vxge_hw_status
+__hw_device_vpath_reset_in_prog_check(u64 *vpath_rst_in_prog)
+{
+	enum vxge_hw_status status;
+
+	status = __hw_device_register_poll(vpath_rst_in_prog, 0,
+			VXGE_HW_VPATH_RST_IN_PROG_VPATH_RST_IN_PROG(0x1ffff),
+			VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	return status;
+}
+
+/*
+ * __hw_device_toc_get
+ * @bar0: Address of BAR0 in PCI config
+ *
+ * This routine sets the sapper and reads the toc pointer and returns the
+ * memory mapped address of the toc
+ */
+struct vxge_hw_toc_reg *
+__hw_device_toc_get(u8 *bar0)
+{
+	u64 val64;
+	struct vxge_hw_toc_reg *toc = NULL;
+	enum vxge_hw_status status;
+	struct vxge_hw_legacy_reg *legacy_reg =
+		(struct vxge_hw_legacy_reg *)bar0;
+
+	status = __hw_legacy_swapper_set(legacy_reg);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 =	readq(&legacy_reg->toc_first_pointer);
+
+	toc = (struct vxge_hw_toc_reg *)(bar0+val64);
+
+exit:
+
+	return toc;
+}
+
+/*
+ * __hw_device_reg_addr_get
+ * @hldev: HW Device object.
+ *
+ * This routine sets the swapper and reads the toc pointer and initializes the
+ * register location pointers in the device object. It waits until the ric is
+ * completed initializing registers.
+ */
+enum vxge_hw_status
+__hw_device_reg_addr_get(struct __hw_device *hldev)
+{
+	u64 val64;
+	u32 i;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(hldev);
+
+	hldev->legacy_reg = (struct vxge_hw_legacy_reg *)hldev->bar0;
+
+	hldev->toc_reg = __hw_device_toc_get(hldev->bar0);
+	if (hldev->toc_reg  == NULL) {
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	val64 = readq(&hldev->toc_reg->toc_common_pointer);
+
+	hldev->common_reg =
+		(struct vxge_hw_common_reg *)(hldev->bar0  +  val64);
+
+	val64 = readq(&hldev->toc_reg->toc_memrepair_pointer);
+
+	hldev->memrepair_reg =
+		(struct vxge_hw_memrepair_reg *)(hldev->bar0  +  val64);
+
+	for (i = 0; i < VXGE_HW_TITAN_PCICFGMGMT_REG_SPACES; i++) {
+
+		val64 = readq(&hldev->toc_reg->toc_pcicfgmgmt_pointer[i]);
+
+		hldev->pcicfgmgmt_reg[i] = (struct vxge_hw_pcicfgmgmt_reg *) \
+						(hldev->bar0  +  val64);
+
+	}
+
+	val64 = readq(&hldev->toc_reg->toc_mrpcim_pointer);
+
+	hldev->mrpcim_reg =
+		(struct vxge_hw_mrpcim_reg *)(hldev->bar0  +  val64);
+
+	for (i = 0; i < VXGE_HW_TITAN_SRPCIM_REG_SPACES; i++) {
+
+		val64 = readq(&hldev->toc_reg->toc_srpcim_pointer[i]);
+
+		hldev->srpcim_reg[i] =
+			(struct vxge_hw_srpcim_reg *)(hldev->bar0  +  val64);
+
+	}
+
+	for (i = 0; i < VXGE_HW_TITAN_VPMGMT_REG_SPACES; i++) {
+
+		val64 = readq(&hldev->toc_reg->toc_vpmgmt_pointer[i]);
+
+		hldev->vpmgmt_reg[i] =
+			(struct vxge_hw_vpmgmt_reg *)(hldev->bar0  +  val64);
+
+	}
+
+	for (i = 0; i < VXGE_HW_TITAN_VPATH_REG_SPACES; i++) {
+
+		val64 = readq(&hldev->toc_reg->toc_vpath_pointer[i]);
+
+		hldev->vpath_reg[i] =
+			(struct vxge_hw_vpath_reg *)(hldev->bar0  +  val64);
+
+	}
+
+	val64 = readq(&hldev->toc_reg->toc_kdfc);
+
+	switch (VXGE_HW_TOC_GET_KDFC_INITIAL_BIR(val64)) {
+	case 0:
+		hldev->kdfc = hldev->bar0  +
+			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64);
+		break;
+	case 2:
+		hldev->kdfc = hldev->bar1  +
+			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64);
+		break;
+	case 4:
+		hldev->kdfc = hldev->bar2  +
+			VXGE_HW_TOC_GET_KDFC_INITIAL_OFFSET(val64);
+		break;
+	default:
+
+		break;
+	}
+
+	val64 = readq(&hldev->toc_reg->toc_usdc);
+
+	switch (VXGE_HW_TOC_GET_USDC_INITIAL_BIR(val64)) {
+	case 0:
+		hldev->usdc = hldev->bar0  +
+			VXGE_HW_TOC_GET_USDC_INITIAL_OFFSET(val64);
+		break;
+	case 2:
+		hldev->usdc = hldev->bar1  +
+			VXGE_HW_TOC_GET_USDC_INITIAL_OFFSET(val64);
+		break;
+	case 4:
+		hldev->usdc = hldev->bar2  +
+			VXGE_HW_TOC_GET_USDC_INITIAL_OFFSET(val64);
+		break;
+	default:
+
+		break;
+	}
+
+	status = __hw_device_vpath_reset_in_prog_check(
+			(u64 *)&hldev->common_reg->vpath_rst_in_prog);
+
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_device_id_get
+ * @hldev: HW Device object.
+ *
+ * This routine returns sets the device id and revision numbers into the device
+ * structure
+ */
+void
+__hw_device_id_get(struct __hw_device *hldev)
+{
+	u64 val64;
+
+	vxge_assert(hldev);
+
+	val64 = readq(&hldev->common_reg->titan_asic_id);
+
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
+ * __hw_device_access_rights_get: Get Access Rights of the driver
+ * @host_type: Host type.
+ * @func_id: Function Id
+ *
+ * This routine returns the Access Rights of the driver
+ */
+u32
+__hw_device_access_rights_get(u32 host_type, u32 func_id)
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
+		break;
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
+ * __hw_device_host_info_get
+ * @hldev: HW Device object.
+ *
+ * This routine returns the host type assignments
+ */
+void
+__hw_device_host_info_get(struct __hw_device *hldev)
+{
+	u64 val64;
+	u32 i;
+
+	vxge_assert(hldev);
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
+		hldev->func_id = __hw_vpath_func_id_get(i,
+					hldev->vpmgmt_reg[i]);
+
+		hldev->access_rights = __hw_device_access_rights_get(
+			hldev->host_type, hldev->func_id);
+
+		hldev->first_vp_id = i;
+
+		break;
+
+	}
+
+	return;
+}
+
+/*
+ * __hw_device_pci_e_info_get - Get PCI_E bus informations such as link_width
+	*and signalling rate
+ * @hldev: HW device.
+ * @signalling_rate:	pointer to a variable of enumerated type
+	*			enum vxge_hw_pci_e_signalling_rate{}.
+ * @link_width:		pointer to a variable of enumerated type
+	*			enum vxge_hw_pci_e_link_width{}.
+ *
+ * Get pci-e signalling rate and link width.
+ *
+ * Returns: one of the enum vxge_hw_status{} enumerated types.
+ * VXGE_HW_OK- for success.
+ * VXGE_HW_ERR_INVALID_PCI_INFO - for invalid PCI information from the card.
+ * VXGE_HW_ERR_BAD_DEVICE_ID - for invalid card.
+ *
+ */
+static enum vxge_hw_status
+__hw_device_pci_e_info_get(
+	struct __hw_device *hldev,
+	enum vxge_hw_pci_e_signalling_rate *signalling_rate,
+	enum vxge_hw_pci_e_link_width *link_width)
+
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_hw_pci_e_capability *pci_e_caps;
+
+	vxge_assert((hldev != NULL) && (signalling_rate != NULL) &&
+		(link_width != NULL));
+
+	pci_e_caps = (struct vxge_hw_pci_e_capability *)
+		(((u8 *)&hldev->pci_config_space_bios)  +  hldev->pci_e_caps);
+
+	switch (pci_e_caps->pci_e_lnkcap & VXGE_HW_PCI_EXP_LNKCAP_LNK_SPEED) {
+	case VXGE_HW_PCI_EXP_LNKCAP_LS_2_5:
+		*signalling_rate = VXGE_HW_PCI_E_SIGNALLING_RATE_2_5GB;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LS_5:
+		*signalling_rate = VXGE_HW_PCI_E_SIGNALLING_RATE_5GB;
+		break;
+	default:
+		*signalling_rate = VXGE_HW_PCI_E_SIGNALLING_RATE_UNKNOWN;
+		break;
+	}
+
+	switch ((pci_e_caps->pci_e_lnkcap &
+		VXGE_HW_PCI_EXP_LNKCAP_LNK_WIDTH) >> 4) {
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_X1:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_X1;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_X2:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_X2;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_X4:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_X4;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_X8:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_X8;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_X12:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_X12;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_X16:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_X16;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_X32:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_X32;
+		break;
+	case VXGE_HW_PCI_EXP_LNKCAP_LW_RES:
+	default:
+		*link_width = VXGE_HW_PCI_E_LINK_WIDTH_UNKNOWN;
+		break;
+	}
+
+	if ((*signalling_rate == VXGE_HW_PCI_E_SIGNALLING_RATE_UNKNOWN) ||
+		(*link_width == VXGE_HW_PCI_E_LINK_WIDTH_UNKNOWN))
+		status = VXGE_HW_ERR_INVALID_PCI_INFO;
+
+	return status;
+}
+
+/**
+ * __hw_device_get_vpd_data - Getting vpd_data.
+ *
+ *   @hldev: HW device handle.
+ *
+ *   Getting  product name and serial number from vpd capabilites structure
+ *
+ */
+void
+__hw_device_get_vpd_data(struct __hw_device *hldev)
+{
+	u8   *vpd_data;
+	u16  data;
+	u32  data32;
+	u32  index = 0, i, count, fail = 0;
+	u32  addr_offset;
+	u32  data_offset;
+	u32  max_count = hldev->config.device_poll_millis * 10;
+
+	vxge_assert(hldev);
+
+	addr_offset = hldev->pci_caps.vpd_cap_offset  +
+		vxge_offsetof(struct vxge_hw_vpid_capability_le, vpd_address);
+
+	data_offset = hldev->pci_caps.vpd_cap_offset  +
+		vxge_offsetof(struct vxge_hw_vpid_capability_le, vpd_data);
+	strcpy((char *) hldev->vpd_data.product_name,
+		"10 Gigabit Ethernet Adapter");
+
+	strcpy((char *) hldev->vpd_data.serial_num, "not available");
+
+	if ((hldev->host_type != VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) ||
+			(hldev->func_id != 0)) {
+		strcpy((char *) hldev->vpd_data.serial_num,
+				"not supported");
+		strcpy((char *) hldev->vpd_data.product_name,
+				"not supported");
+		return;
+	}
+	vpd_data = (u8 *) vmalloc(VXGE_HW_VPD_BUFFER_SIZE  +  16);
+	if (vpd_data == 0)
+		return;
+	for (index = 0; index < VXGE_HW_VPD_BUFFER_SIZE; index += 4) {
+		pci_write_config_word(hldev->pdev,
+				addr_offset, (u16)index);
+		for (count = 0; count < max_count; count++) {
+			vxge_os_udelay(100);
+			pci_read_config_word(hldev->pdev,
+					addr_offset, &data);
+			if (data & VXGE_HW_PCI_VPID_COMPL_FALG)
+				break;
+		}
+
+		if (count >= max_count) {
+
+			fail = 1;
+			break;
+		}
+
+		pci_read_config_dword(hldev->pdev,
+				data_offset, &data32);
+
+		for (i = 0; i < 4; i++) {
+			vpd_data[index+i] = (u8)(data32 & 0xff);
+			data32 >>= 8;
+		}
+	}
+
+	if (!fail) {
+
+		/* read serial number of adapter */
+		for (count = 0; count < VXGE_HW_VPD_BUFFER_SIZE; count++) {
+			if ((vpd_data[count] == 'S')     &&
+			    (vpd_data[count  +  1] == 'N') &&
+			    (vpd_data[count  +  2] < VXGE_HW_VPD_LENGTH)) {
+				memset(hldev->vpd_data.serial_num, 0,
+					VXGE_HW_VPD_LENGTH);
+				memcpy(hldev->vpd_data.serial_num,
+					&vpd_data[count  +  3],
+					vpd_data[count  +  2]);
+				break;
+			}
+		}
+
+		if (vpd_data[1] < VXGE_HW_VPD_LENGTH) {
+			memset(hldev->vpd_data.product_name, 0, vpd_data[1]);
+			memcpy(hldev->vpd_data.product_name, &vpd_data[3],
+				vpd_data[1]);
+		}
+	}
+
+	vfree(vpd_data);
+
+	return;
+}
+
+/*
+ * vxge_hw_wrr_rebalance - Rebalance the RX_WRR and KDFC_WRR calandars.
+ * @devh: HW device handle.
+ *
+ * Rebalance the RX_WRR and KDFC_WRR calandars.
+ *
+ */
+enum vxge_hw_status vxge_hw_wrr_rebalance(struct __hw_device *hldev)
+{
+	u64 val64;
+	u32 calender[176];
+	u32 i, j, how_often = 1;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(hldev != NULL);
+
+	if ((hldev->host_type != VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) ||
+			(hldev->func_id != 0)) {
+		status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+		goto exit;
+	}
+
+	/* Reset the priorities assigned to the WRR arbitration
+	phases for the receive traffic */
+	for (i = 0; i < 22; i++)
+		writeq(0, ((&hldev->mrpcim_reg->rx_w_round_robin_0) + i));
+
+	/* Reset the transmit FIFO servicing calendar for FIFOs */
+	for (i = 0; i < 20; i++) {
+		writeq(0, ((&hldev->mrpcim_reg->
+				kdfc_w_round_robin_0) + i));
+
+		writeq(0, ((&hldev->mrpcim_reg->
+				kdfc_w_round_robin_20) + i));
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
+
+	writeq(0, &hldev->mrpcim_reg->kdfc_entry_type_sel_1);
+
+	/* Set priority 0 to all receive queues */
+	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_0);
+
+	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_1);
+
+	writeq(0, &hldev->mrpcim_reg->rx_queue_priority_2);
+
+	/* Initialize all the slots as unused */
+	for (i = 0; i < 176; i++)
+		calender[i] = -1;
+
+	/* Prepare the Fifo service states */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!hldev->config.vp_config[i].min_bandwidth)
+			continue;
+
+		how_often = 100 / hldev->config.
+				vp_config[i].min_bandwidth;
+		if (how_often) {
+
+			for (j = 0; j < 153;) {
+				if (calender[j] == -1) {
+					calender[j] = i;
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
+	for (j = 0; j < 176; j++) {
+		if (calender[j] == -1)
+			calender[j] = 0;
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
+	for (i = 0, j = 0; i < 20; i++) {
+
+		val64 = 0;
+
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_0(calender[j++]);
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_1(calender[j++]);
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_2(calender[j++]);
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_3(calender[j++]);
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_4(calender[j++]);
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_5(calender[j++]);
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_6(calender[j++]);
+		val64 |=  VXGE_HW_KDFC_W_ROUND_ROBIN_0_NUMBER_7(calender[j++]);
+
+		writeq(val64, ((&hldev->mrpcim_reg->
+				kdfc_w_round_robin_0)  +  i));
+
+		writeq(val64, ((&hldev->mrpcim_reg->
+				kdfc_w_round_robin_20)  +  i));
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
+	for (i = 0; i < 176; i++)
+		calender[i] = -1;
+
+	/* Prepare the Ring service states */
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!hldev->config.vp_config[i].min_bandwidth)
+			continue;
+
+		how_often = 100 / hldev->
+				config.vp_config[i].min_bandwidth;
+		if (how_often) {
+
+			for (j = 0; j < 171;) {
+				if (calender[j] == -1) {
+					calender[j] = i;
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
+	for (j = 0; j < 176; j++) {
+		if (calender[j] == -1)
+			calender[j] = 0;
+	}
+
+	for (i = 0, j = 0; i < 22; i++) {
+		val64 = 0;
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_0(
+				calender[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_1(
+				calender[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_2(
+				calender[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_3(
+				calender[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_4(
+				calender[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_5(
+				calender[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_6(
+				calender[j++]);
+		val64 |=  VXGE_HW_RX_W_ROUND_ROBIN_0_RX_W_PRIORITY_SS_7(
+				calender[j++]);
+
+		writeq(val64, ((&hldev->mrpcim_reg->rx_w_round_robin_0)  +  i));
+	}
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_device_initialize
+ * @hldev: HW device handle.
+ *
+ * Initialize Titan-V hardware.
+ */
+enum vxge_hw_status
+__hw_device_initialize(struct __hw_device *hldev)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(hldev);
+
+	/* Get the pci-e link width and speed */
+	status = __hw_device_pci_e_info_get(hldev,
+		&hldev->signalling_rate,
+		&hldev->link_width);
+	if (status != VXGE_HW_OK) {
+		hldev->signalling_rate =
+				VXGE_HW_PCI_E_SIGNALLING_RATE_UNKNOWN;
+		hldev->link_width = VXGE_HW_PCI_E_LINK_WIDTH_UNKNOWN;
+		goto exit;
+	}
+
+	if ((hldev->host_type == VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) &&
+			(hldev->func_id == 0)) {
+
+		hldev->mrpcim_stats_block =
+			__hw_blockpool_block_allocate(hldev,
+			VXGE_HW_BLOCK_SIZE);
+
+		if (hldev->mrpcim_stats_block == NULL) {
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+		hldev->mrpcim_stats =
+			(struct vxge_hw_device_stats_mrpcim_info *) \
+				hldev->mrpcim_stats_block->memblock;
+
+		memset(hldev->mrpcim_stats, 0,
+			sizeof(struct vxge_hw_device_stats_mrpcim_info));
+
+		hldev->stats.hw_dev_info_stats.mrpcim_info =
+						hldev->mrpcim_stats;
+
+		hldev->mrpcim_stats_sav =
+			&hldev->stats.hw_dev_info_stats.mrpcim_info_sav;
+
+		memset(hldev->mrpcim_stats_sav, 0,
+			sizeof(struct vxge_hw_device_stats_mrpcim_info));
+
+		writeq(hldev->mrpcim_stats_block->dma_addr,
+			&hldev->mrpcim_reg->mrpcim_stats_start_host_addr);
+	}
+
+	vxge_hw_wrr_rebalance(hldev);
+
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_hw_info_get - Get the hw information
+ * @bar0: Address of BAR0 in PCI config
+ * @hw_info: Buffer to return struct vxge_hw_device_hw_info{} structure
+ *
+ * Returns the vpath mask that has the bits set for each vpath allocated
+ * for the driver, FW version information and the first mac addresse for
+ * each vpath
+ */
+enum vxge_hw_status vxge_hw_device_hw_info_get(u8 *bar0,
+				struct vxge_hw_device_hw_info *hw_info)
+{
+	u32 i;
+	u64 val64;
+	struct vxge_hw_toc_reg *toc;
+	struct vxge_hw_mrpcim_reg *mrpcim_reg;
+	struct vxge_hw_common_reg *common_reg;
+	struct vxge_hw_vpath_reg *vpath_reg;
+	struct vxge_hw_vpmgmt_reg *vpmgmt_reg;
+	enum vxge_hw_status status;
+
+	vxge_assert((bar0 != NULL) && (hw_info != NULL));
+
+	memset(hw_info, 0, sizeof(struct vxge_hw_device_hw_info));
+
+	toc = __hw_device_toc_get(bar0);
+	if (toc == NULL) {
+		status = VXGE_HW_ERR_CRITICAL;
+		goto exit;
+	}
+
+	val64 = readq(&toc->toc_common_pointer);
+
+	common_reg = (struct vxge_hw_common_reg *)(bar0  +  val64);
+
+	status = __hw_device_vpath_reset_in_prog_check(
+		(u64 *)&common_reg->vpath_rst_in_prog);
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
+		vpmgmt_reg = (struct vxge_hw_vpmgmt_reg *)(bar0  +  val64);
+
+		hw_info->func_id = __hw_vpath_func_id_get(i, vpmgmt_reg);
+		if (__hw_device_access_rights_get(hw_info->host_type,
+			hw_info->func_id) &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM) {
+
+			val64 = readq(&toc->toc_mrpcim_pointer);
+
+			mrpcim_reg =
+				(struct vxge_hw_mrpcim_reg *)(bar0 + val64);
+
+			writeq(0, &mrpcim_reg->xgmac_gen_fw_memo_mask);
+			wmb();
+		}
+
+		val64 = readq(&toc->toc_vpath_pointer[i]);
+
+		vpath_reg = (struct vxge_hw_vpath_reg *)(bar0  +  val64);
+
+		hw_info->function_mode =
+			__hw_vpath_pci_func_mode_get(i, vpath_reg);
+
+		__hw_vpath_fw_flash_ver_get(i, vpath_reg,
+			&hw_info->fw_version,
+			&hw_info->fw_date,
+			&hw_info->flash_version,
+			&hw_info->flash_date);
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
+
+		vpath_reg = (struct vxge_hw_vpath_reg *)(bar0  +  val64);
+
+		status =  __hw_vpath_addr_get(i, vpath_reg,
+				hw_info->mac_addrs[i],
+				hw_info->mac_addr_masks[i]);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_initialize - Initialize Titan device.
+ * @hldev: HW device handle.
+ * @attr: pointer to struct vxge_hw_device_attr structure
+ * @device_config: Configuration to be _applied_ to the device,
+ *                 For the Titan configuration "knobs" please
+ *                 refer to struct vxge_hw_device_config and Titan
+ *                 User Guide.
+ *
+ * Initialize Titan device. Note that all the arguments of this public API
+ * are 'IN', including @hldev. Driver cooperates with
+ * OS to find new Titan device, locate its PCI and memory spaces.
+ *
+ * When done, the driver allocates sizeof(struct __hw_device) bytes for HW
+ * to enable the latter to perform Titan hardware initialization.
+ *
+ * Returns: VXGE_HW_OK - success.
+ * VXGE_HW_ERR_DRIVER_NOT_INITIALIZED - Driver is not initialized.
+ * VXGE_HW_ERR_BAD_DEVICE_CONFIG - Device configuration params are not
+ * valid.
+ * VXGE_HW_ERR_OUT_OF_MEMORY - Memory allocation failed.
+ * VXGE_HW_ERR_BAD_SUBSYSTEM_ID - Device subsystem id is invalid.
+ * VXGE_HW_ERR_INVALID_MAC_ADDRESS - Device mac address in not valid.
+ * VXGE_HW_INF_MEM_STROBE_CMD_EXECUTING - Failed to retrieve the mac
+ * address within the time(timeout) or TTI/RTI initialization failed.
+ * VXGE_HW_ERR_SWAPPER_CTRL - Failed to configure swapper control.
+ *
+ * See also: __hw_device_terminate(), enum vxge_hw_status{}
+ * struct vxge_hw_device_attr{}.
+ */
+enum vxge_hw_status
+vxge_hw_device_initialize(
+	struct __hw_device **devh,
+	struct vxge_hw_device_attr *attr,
+	struct vxge_hw_device_config *device_config)
+{
+	u32 i;
+	u32 nblocks = 0;
+	struct __hw_device *hldev = NULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u64 value = 0;
+
+	vxge_assert((devh != NULL) && (attr != NULL) &&
+		(device_config != NULL));
+
+	status = __hw_device_config_check(device_config);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	hldev = (struct __hw_device *)vmalloc(sizeof(struct __hw_device));
+	if (hldev == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	memset(hldev, 0, sizeof(struct __hw_device));
+
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
+	hldev->uld_callbacks.sched_timer =
+		attr->uld_callbacks.sched_timer;
+	hldev->uld_callbacks.xpak_alarm_log =
+		attr->uld_callbacks.xpak_alarm_log;
+
+	__hw_device_pci_e_init(hldev);
+
+	status = __hw_device_reg_addr_get(hldev);
+	if (status != VXGE_HW_OK)
+		goto exit;
+	__hw_device_id_get(hldev);
+
+	__hw_device_host_info_get(hldev);
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
+
+	}
+
+	if (__hw_blockpool_create(hldev,
+		&hldev->block_pool,
+		device_config->dma_blockpool_initial  +  nblocks,
+		device_config->dma_blockpool_incr,
+		device_config->dma_blockpool_min,
+		device_config->dma_blockpool_max  +  nblocks) !=
+			VXGE_HW_OK) {
+
+		vxge_hw_device_terminate(hldev);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	status = __hw_device_initialize(hldev);
+
+	if (status != VXGE_HW_OK) {
+
+		vxge_hw_device_terminate(hldev);
+		goto exit;
+	}
+
+	__hw_device_get_vpd_data(hldev);
+
+	/* Redundant as it is already set in __hw_device_hw_initialzie. */
+	hldev->is_initialized = 1;
+
+	*devh = hldev;
+
+	if (hldev->access_rights & VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM) {
+		/* debounce configuration for PORT0 */
+		value = VXGE_HW_XGMAC_DEBOUNCE_PORT_PERIOD_LINK_UP(0xD) |
+			VXGE_HW_XGMAC_DEBOUNCE_PORT_PERIOD_LINK_DOWN(0xD) |
+			VXGE_HW_XGMAC_DEBOUNCE_PORT_PERIOD_PORT_UP(0xD) |
+			VXGE_HW_XGMAC_DEBOUNCE_PORT_PERIOD_PORT_DOWN(0xD);
+
+		writeq(value, &hldev->mrpcim_reg->xgmac_debounce_port[0]);
+
+		/* debounce configuration for PORT1 */
+		writeq(value, &hldev->mrpcim_reg->xgmac_debounce_port[1]);
+	}
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_terminate - Terminate Titan device.
+ * @hldev: HW device handle.
+ *
+ * Terminate HW device.
+ *
+ * See also: vxge_hw_device_initialize().
+ */
+void
+vxge_hw_device_terminate(struct __hw_device *hldev)
+{
+	vxge_assert(hldev != NULL);
+	vxge_assert(hldev->magic == VXGE_HW_DEVICE_MAGIC);
+
+	hldev->is_initialized = 0;
+	hldev->magic = VXGE_HW_DEVICE_DEAD;
+
+	if (hldev->mrpcim_stats_block != NULL) {
+		__hw_blockpool_block_free(hldev, hldev->mrpcim_stats_block);
+		hldev->mrpcim_stats_block = NULL;
+	}
+
+	__hw_blockpool_destroy(&hldev->block_pool);
+
+	vfree(hldev);
+
+}
+
+/**
+ * vxge_hw_device_hw_stats_enable - Enable device h/w statistics.
+ * @hldev: HW Device.
+ *
+ * Enable the DMA vpath statistics for the device. The function is to be called
+ * to re-enable the adapter to update stats into the host memory
+ *
+ */
+enum vxge_hw_status vxge_hw_device_hw_stats_enable(struct __hw_device *hldev)
+{
+	u32 i;
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(hldev != NULL);
+
+	val64 = readq(&hldev->common_reg->stats_cfg0);
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
+		if (hldev->config.stats_read_method ==
+					VXGE_HW_STATS_READ_METHOD_DMA) {
+			val64 |= VXGE_HW_STATS_CFG0_STATS_ENABLE(
+							(1 << (16 - i)));
+		} else {
+			status = __hw_vpath_stats_get(
+				&hldev->virtual_paths[i],
+				hldev->virtual_paths[i].hw_stats);
+		}
+
+	}
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+				&hldev->common_reg->stats_cfg0);
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_stats_get - Get the device hw statistics.
+ * @hldev: HW Device.
+ * @hw_stats: Hardware stats
+ *
+ * Returns the vpath h/w stats for the device.
+ *
+ * See also: vxge_hw_device_hw_stats_enable(),
+ * vxge_hw_device_hw_stats_disable()
+ */
+enum vxge_hw_status vxge_hw_device_stats_get(
+	struct __hw_device *hldev,
+	struct vxge_hw_device_stats_hw_info *hw_stats)
+{
+	u32 i;
+	u64 val64 = 0;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((hldev != NULL) && (hw_stats != NULL));
+
+	if (hldev->config.stats_read_method ==
+			VXGE_HW_STATS_READ_METHOD_DMA) {
+
+		for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+			if (!(hldev->vpaths_deployed & vxge_mBIT(i)))
+				continue;
+
+			val64 |= VXGE_HW_STATS_CFG0_STATS_ENABLE(
+							(1 << (16 - i)));
+
+		}
+
+		status = __hw_device_register_poll(
+				(u64 *)&hldev->common_reg->stats_cfg0,
+				0,
+				val64,
+				hldev->config.device_poll_millis);
+
+	}
+
+	if (status == VXGE_HW_OK) {
+		memcpy(hw_stats,
+				&hldev->stats.hw_dev_info_stats,
+				sizeof(struct vxge_hw_device_stats_hw_info));
+	}
+
+	return status;
+}
+
+/**
+ * vxge_hw_driver_stats_get - Get the device sw statistics.
+ * @hldev: HW Device.
+ * @sw_stats: Software stats
+ *
+ * Returns the vpath s/w stats for the device.
+ *
+ * See also: vxge_hw_device_stats_get()
+ */
+enum vxge_hw_status vxge_hw_driver_stats_get(
+			struct __hw_device *hldev,
+			struct vxge_hw_device_stats_sw_info *sw_stats)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((hldev != NULL) && (sw_stats != NULL));
+
+	memcpy(sw_stats,
+		&hldev->stats.sw_dev_info_stats,
+		sizeof(struct vxge_hw_device_stats_sw_info));
+
+	return status;
+}
+
+/**
+ * vxge_hw_mrpcim_stats_access - Access the statistics from the given location
+ *                           and offset and perform an operation
+ * @hldev: HW Device handle.
+ * @operation: Operation to be performed
+ * @location: Location (one of vpath id, aggregate or port)
+ * @offset: Offset with in the location
+ * @stat: Pointer to a buffer to return the value
+ *
+ * Get the statistics from the given location and offset.
+ *
+ */
+enum vxge_hw_status
+vxge_hw_mrpcim_stats_access(
+	struct __hw_device *hldev,
+	u32 operation,
+	u32 location,
+	u32 offset,
+	u64 *stat)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((hldev != NULL) && (stat != NULL));
+
+	if ((hldev->host_type != VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) ||
+	   (hldev->func_id != 0)) {
+		status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+		goto exit;
+	}
+
+	val64 = VXGE_HW_XMAC_STATS_SYS_CMD_OP(operation) |
+		VXGE_HW_XMAC_STATS_SYS_CMD_STROBE |
+		VXGE_HW_XMAC_STATS_SYS_CMD_LOC_SEL(location) |
+		VXGE_HW_XMAC_STATS_SYS_CMD_OFFSET_SEL(offset);
+
+	__hw_pio_mem_write32_lower((u32)bVAL32(val64, 32),
+			&hldev->mrpcim_reg->xmac_stats_sys_cmd);
+
+	wmb();
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+			&hldev->mrpcim_reg->xmac_stats_sys_cmd);
+
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&hldev->mrpcim_reg->xmac_stats_sys_cmd,
+			0,
+			VXGE_HW_XMAC_STATS_SYS_CMD_STROBE,
+			hldev->config.device_poll_millis);
+
+	if ((status == VXGE_HW_OK) && (operation == VXGE_HW_STATS_OP_READ))
+		*stat = readq(&hldev->mrpcim_reg->xmac_stats_sys_data);
+	else
+		*stat = 0;
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_xmac_aggr_stats_get - Get the Statistics on aggregate port
+ * @hldev: HW device handle.
+ * @port: Number of the port (0 or 1)
+ * @aggr_stats: Buffer to return Statistics on aggregate port.
+ *
+ * Get the Statistics on aggregate port
+ *
+ */
+enum vxge_hw_status
+vxge_hw_device_xmac_aggr_stats_get(struct __hw_device *hldev,
+				u32 port,
+				struct vxge_hw_xmac_aggr_stats *aggr_stats)
+{
+	u64 *val64;
+	int i;
+	u32 offset = VXGE_HW_STATS_AGGRn_OFFSET;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((hldev != NULL) && (aggr_stats != NULL));
+	val64 = (u64 *)aggr_stats;
+
+	if ((hldev->host_type != VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) ||
+	   (hldev->func_id != 0)) {
+		status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+		goto exit;
+	}
+
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_aggr_stats) / 8; i++) {
+		status = vxge_hw_mrpcim_stats_access(hldev,
+					VXGE_HW_STATS_OP_READ,
+					VXGE_HW_STATS_LOC_AGGR,
+					((offset + (104 * port)) >> 3), val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		offset = offset + 8;
+		val64++;
+	}
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_xmac_port_stats_get - Get the Statistics on a port
+ * @hldev: HW device handle.
+ * @port: Number of the port (wire 0, wire 1 or LAG)
+ * @port_stats: Buffer to return Statistics on a port.
+ *
+ * Get the Statistics on port
+ *
+ */
+enum vxge_hw_status
+vxge_hw_device_xmac_port_stats_get(struct __hw_device *hldev,
+				u32 port,
+				struct vxge_hw_xmac_port_stats *port_stats)
+{
+	u64 *val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	int i;
+	u32 offset = 0x0;
+	vxge_assert((hldev != NULL) && (port_stats != NULL));
+	val64 = (u64 *) port_stats;
+
+	if ((hldev->host_type != VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) ||
+	   (hldev->func_id != 0)) {
+		status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+		goto exit;
+	}
+
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_port_stats) / 8; i++) {
+		status = vxge_hw_mrpcim_stats_access(hldev,
+					VXGE_HW_STATS_OP_READ,
+					VXGE_HW_STATS_LOC_AGGR,
+					((offset + (608 * port)) >> 3), val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		offset = offset + 8;
+		val64++;
+	}
+
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_xmac_stats_get - Get the XMAC Statistics
+ * @hldev: HW device handle.
+ * @xmac_stats: Buffer to return XMAC Statistics.
+ *
+ * Get the XMAC Statistics
+ *
+ */
+enum vxge_hw_status
+vxge_hw_device_xmac_stats_get(struct __hw_device *hldev,
+				struct vxge_hw_xmac_stats *xmac_stats)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u32 i;
+
+	vxge_assert((hldev != NULL) && (xmac_stats != NULL));
+
+	status = vxge_hw_device_xmac_aggr_stats_get(hldev,
+				      0,
+				      &xmac_stats->aggr_stats[0]);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = vxge_hw_device_xmac_aggr_stats_get(hldev,
+				      1,
+				      &xmac_stats->aggr_stats[1]);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	for (i = 0; i <= VXGE_HW_MAC_MAX_MAC_PORT_ID; i++) {
+
+		status = vxge_hw_device_xmac_port_stats_get(hldev,
+					i,
+					&xmac_stats->port_stats[i]);
+
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+	}
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (!(hldev->vpaths_deployed & vxge_mBIT(i)))
+			continue;
+
+		status = __hw_vpath_xmac_tx_stats_get(&hldev->virtual_paths[i],
+					&xmac_stats->vpath_tx_stats[i]);
+
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		status = __hw_vpath_xmac_rx_stats_get(&hldev->virtual_paths[i],
+					&xmac_stats->vpath_rx_stats[i]);
+
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+	}
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_debug_set - Set the debug module, level and timestamp
+ * @hldev: Hal device object
+ * @level: Debug level as defined in enum enum vxge_debug_level
+ * @module masks: An or value of component masks as defined in vxge_debug.h
+ *
+ * This routine is used to dynamically change the debug output
+ */
+void vxge_hw_device_debug_set(
+	struct __hw_device *hldev,
+	enum vxge_debug_level level,
+	u32 mask)
+{
+
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
+
+}
+
+/**
+ * vxge_hw_device_debug_level_get - Get the debug level
+ * @hldev: Hal device object
+ *
+ * This routine returns the current debug level set
+ */
+u32
+vxge_hw_device_debug_level_get(struct __hw_device *hldev)
+{
+#if defined(VXGE_DEBUG_TRACE_MASK) || defined(VXGE_DEBUG_ERR_MASK)
+	if (hldev == NULL)
+		return 0;
+	return hldev->debug_level;
+#else
+	return 0;
+#endif
+
+}
+
+/**
+ * vxge_hw_device_error_level_get - Get the error level
+ * @hldev: Hal device object
+ *
+ * This routine returns the current error level set
+ */
+u32
+vxge_hw_device_error_level_get(struct __hw_device *hldev)
+{
+#if defined(VXGE_DEBUG_ERR_MASK)
+	if (hldev == NULL)
+		return VXGE_ERR;
+	else
+		return hldev->level_err;
+#else
+	return 0;
+#endif
+
+}
+/**
+ * vxge_hw_device_trace_level_get - Get the trace level
+ * @hldev: Hal device object
+ *
+ * This routine returns the current trace level set
+ */
+u32
+vxge_hw_device_trace_level_get(struct __hw_device *hldev)
+{
+#if defined(VXGE_DEBUG_TRACE_MASK)
+	if (hldev == NULL)
+		return VXGE_TRACE;
+	else
+		return hldev->level_trace;
+#else
+	return 0;
+#endif
+
+}
+/**
+ * vxge_hw_device_debug_mask_get - Get the debug mask
+ * @hldev: Hal device object
+ *
+ * This routine returns the current debug mask set
+ */
+u32
+vxge_hw_device_debug_mask_get(struct __hw_device *hldev)
+{
+#if defined(VXGE_DEBUG_TRACE_MASK) || defined(VXGE_DEBUG_ERR_MASK)
+	if (hldev == NULL)
+		return 0;
+	return hldev->debug_module_mask;
+#else
+	return 0;
+#endif
+
+}
+
+/**
+ * vxge_hw_getpause_data -Pause frame frame generation and reception.
+ * @hldev: HW device handle.
+ * @port : Port number 0, 1, or 2
+ * @tx : A field to return the pause generation capability of the NIC.
+ * @rx : A field to return the pause reception capability of the NIC.
+ *
+ * Returns the Pause frame generation and reception capability of the NIC.
+ * Return value:
+ *  status
+ */
+enum vxge_hw_status vxge_hw_device_getpause_data(
+	 struct __hw_device *hldev,
+	 u32 port,
+	 u32 *tx,
+	 u32 *rx)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	vxge_assert(hldev != NULL);
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
+
+	if (val64 & VXGE_HW_RXMAC_PAUSE_CFG_PORT_GEN_EN)
+		*tx = 1;
+
+	if (val64 & VXGE_HW_RXMAC_PAUSE_CFG_PORT_RCV_EN)
+		*rx = 1;
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_setpause_data -  set/reset pause frame generation.
+ * @hldev: HW device handle.
+ * @port : Port number 0, 1, or 2
+ * @tx: A field that indicates the pause generation capability to be
+ * set on the NIC.
+ * @rx: A field that indicates the pause reception capability to be
+ * set on the NIC.
+ *
+ * It can be used to set or reset Pause frame generation or reception
+ * support of the NIC.
+ * Return value:
+ * int, returns 0 on Success
+ */
+
+enum vxge_hw_status vxge_hw_device_setpause_data(
+				struct __hw_device *hldev,
+				u32 port,
+				u32 tx,
+				u32 rx)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	vxge_assert(hldev != NULL);
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
+	if ((hldev->host_type != VXGE_HW_NO_MR_NO_SR_NORMAL_FUNCTION) ||
+				(hldev->func_id != 0)) {
+		status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+		goto exit;
+	}
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
+
+	return status;
+}
+
+/**
+ * vxge_hw_device_private_set - Set driver context.
+ * @hldev: HW device handle.
+ * @data: pointer to driver context
+ *
+ * Use HW device to set driver context.
+ *
+ * See also: vxge_hw_device_private_get()
+ */
+void vxge_hw_device_private_set(struct __hw_device *hldev, void *data)
+{
+	hldev->upper_layer_data = data;
+}
+
+/**
+ * vxge_hw_device_private_get - Get driver context.
+ * @hldev: HW device handle.
+ *
+ * Use HW device to set driver context.
+ *
+ * See also: vxge_hw_device_private_get()
+ */
+void *vxge_hw_device_private_get(struct __hw_device *hldev)
+{
+	return hldev->upper_layer_data;
+}
+
+/*
+ * vxge_hw_device_serial_number_get - Returns the serial number
+ * @hldev: HW device handle.
+ *
+ * Return the serial number
+ */
+const u8 *
+vxge_hw_device_serial_number_get(struct __hw_device *hldev)
+{
+
+	vxge_assert(hldev);
+
+	return hldev->vpd_data.serial_num;
+}
+
+/*
+ * vxge_hw_device_product_name_get - Returns the product name
+ * @hldev: HW device handle.
+ *
+ * Return the product name
+ */
+const u8 *
+vxge_hw_device_product_name_get(struct __hw_device *hldev)
+{
+
+	vxge_assert(hldev);
+
+	return hldev->vpd_data.product_name;
+}
+
+u8
+vxge_hw_device_link_width_get(struct __hw_device *hldev)
+{
+	struct vxge_hw_pci_e_capability *pci_e_caps;
+
+	vxge_assert(hldev);
+
+	pci_e_caps = (struct vxge_hw_pci_e_capability *)
+		(((u8 *)&hldev->pci_config_space_bios)  +  hldev->pci_e_caps);
+
+	return (pci_e_caps->pci_e_lnksta &
+		VXGE_HW_PCI_EXP_LNKCAP_LNK_WIDTH) >> 4;
+}
+
+#ifdef VXGE_HW_INTERNAL_COMPILER_ERROR
+
+#pragma optimize("", off)
+
+#endif
+
+/*
+ * __hw_ring_block_memblock_idx - Return the memblock index
+ * @block: Virtual address of memory block
+ *
+ * This function returns the index of memory block
+ */
+static inline u32
+__hw_ring_block_memblock_idx(
+	u8 (block)[VXGE_HW_BLOCK_SIZE])
+{
+	return (u32)*((u64 *)((u8 *)block  +
+		VXGE_HW_RING_MEMBLOCK_IDX_OFFSET));
+}
+
+/*
+ * __hw_ring_block_memblock_idx_set - Sets the memblock index
+ * @block: Virtual address of memory block
+ * @memblock_idx: Index of memory block
+ *
+ * This function sets index to a memory block
+ */
+static inline void
+__hw_ring_block_memblock_idx_set(
+	u8 (block)[VXGE_HW_BLOCK_SIZE],
+	u32 memblock_idx)
+{
+	*((u64 *)((u8 *)block  +   VXGE_HW_RING_MEMBLOCK_IDX_OFFSET)) =
+					   memblock_idx;
+}
+
+/*
+ * __hw_ring_block_next_pointer - Returns the dma address of next block
+ * @block: RxD block
+ *
+ * Returns the dma address of next block stored in the RxD block
+ */
+static inline dma_addr_t
+__hw_ring_block_next_pointer(
+	u8 (*block)[VXGE_HW_BLOCK_SIZE])
+{
+	return (dma_addr_t)*((u64 *)((u8 *)block  +
+			VXGE_HW_RING_NEXT_BLOCK_POINTER_OFFSET));
+}
+
+/*
+ * __hw_ring_block_next_pointer_set - Sets the next block pointer in RxD block
+ * @block: RxD block
+ * @dma_next: dma address of next block
+ *
+ * Sets the next block pointer in RxD block
+ */
+static inline void
+__hw_ring_block_next_pointer_set(
+	u8 (*block)[VXGE_HW_BLOCK_SIZE],
+	dma_addr_t dma_next)
+{
+	*((u64 *)((u8 *)block  +  VXGE_HW_RING_NEXT_BLOCK_POINTER_OFFSET)) =
+							dma_next;
+}
+
+/*
+ * __hw_ring_first_block_address_get - Returns the dma address of the
+ *             first block
+ * @ringh: Handle to the ring
+ *
+ * Returns the dma address of the first RxD block
+ */
+u64
+__hw_ring_first_block_address_get(struct __hw_ring *ringh)
+{
+	struct __hw_ring *ring = (struct __hw_ring *)ringh;
+	struct vxge_hw_mempool_dma *dma_object;
+
+	dma_object = __hw_mempool_memblock_dma(ring->mempool, 0);
+
+	vxge_assert(dma_object != NULL);
+
+	return dma_object->addr;
+}
+
+/*
+ * __hw_ring_item_dma_addr - Return the dma address of an item
+ * @mempoolh: Handle to the memory pool of the ring
+ * @item: Item for which to get the dma offset
+ * @dma_handle: dma handle
+ *
+ * This function returns the dma address of a given item
+ */
+static dma_addr_t
+__hw_ring_item_dma_addr(
+	struct vxge_hw_mempool *mempoolh,
+	void *item,
+	struct pci_dev **dma_handle)
+{
+	u32 memblock_idx;
+	void *memblock;
+	struct vxge_hw_mempool_dma *memblock_dma_object;
+#if (VXGE_COMPONENT_HW_POOL & VXGE_DEBUG_MODULE_MASK)
+	struct vxge_hw_mempool *mempool = (struct vxge_hw_mempool *)mempoolh;
+#endif
+
+	ptrdiff_t dma_item_offset;
+
+	vxge_assert((mempoolh != NULL) && (item != NULL) &&
+			(dma_handle != NULL));
+
+	/* get owner memblock index */
+	memblock_idx = __hw_ring_block_memblock_idx(item);
+
+	/* get owner memblock by memblock index */
+	memblock = __hw_mempool_memblock(
+		(struct vxge_hw_mempool *) mempoolh, memblock_idx);
+
+	/* get memblock DMA object by memblock index */
+	memblock_dma_object = __hw_mempool_memblock_dma(
+		(struct vxge_hw_mempool *) mempoolh, memblock_idx);
+
+	/* calculate offset in the memblock of this item */
+	dma_item_offset = (u8 *)item - (u8 *)memblock;
+
+	*dma_handle = memblock_dma_object->handle;
+
+	return memblock_dma_object->addr  +  dma_item_offset;
+}
+
+/*
+ * __hw_ring_rxdblock_link - Link the RxD blocks
+ * @mempoolh: Handle to the memory pool of the ring
+ * @ringh: Handle to the ring object used for receive
+ * @from: RxD block from which to link
+ * @to: RxD block to which to link to
+ *
+ * This function returns the dma address of a given item
+ */
+static void
+__hw_ring_rxdblock_link(
+	struct vxge_hw_mempool *mempoolh,
+	struct __hw_ring *ring,
+	u32 from,
+	u32 to)
+{
+	u8 (*to_item)[VXGE_HW_BLOCK_SIZE], (*from_item)[VXGE_HW_BLOCK_SIZE];
+	dma_addr_t to_dma, from_dma;
+	struct pci_dev *to_dma_handle, *from_dma_handle;
+
+	vxge_assert((mempoolh != NULL) && (ring != NULL));
+
+	/* get "from" RxD block */
+	from_item = __hw_mempool_item(
+			(struct vxge_hw_mempool *) mempoolh, from);
+	vxge_assert(from_item);
+
+	/* get "to" RxD block */
+	to_item = __hw_mempool_item(
+			(struct vxge_hw_mempool *) mempoolh, to);
+	vxge_assert(to_item);
+
+	/* return address of the beginning of previous RxD block */
+	to_dma = __hw_ring_item_dma_addr(mempoolh, to_item, &to_dma_handle);
+
+	/* set next pointer for this RxD block to point on
+	 * previous item's DMA start address */
+	__hw_ring_block_next_pointer_set(from_item, to_dma);
+
+	/* return "from" RxD block's DMA start address */
+	from_dma = __hw_ring_item_dma_addr(
+			mempoolh, from_item, &from_dma_handle);
+
+}
+
+/*
+ * __hw_ring_mempool_item_alloc - Allocate List blocks for RxD block callback
+ * @mempoolh: Handle to memory pool
+ * @memblock: Address of this memory block
+ * @memblock_index: Index of this memory block
+ * @dma_object: dma object for this block
+ * @item: Pointer to this item
+ * @index: Index of this item in memory block
+ * @is_last: If this is last item in the block
+ * @userdata: Specific data of user
+ *
+ * This function is callback passed to __hw_mempool_create to create memory
+ * pool for RxD block
+ */
+static enum vxge_hw_status
+__hw_ring_mempool_item_alloc(
+	struct vxge_hw_mempool *mempoolh,
+	void *memblock,
+	u32 memblock_index,
+	struct vxge_hw_mempool_dma *dma_object,
+	void *item,
+	u32 index,
+	u32 is_last,
+	void *userdata)
+{
+	u32 i;
+	struct __hw_ring *ring = (struct __hw_ring *)userdata;
+
+	vxge_assert((item != NULL) && (ring != NULL));
+
+	/* format rxds array */
+	for (i = 0; i < ring->rxds_per_block; i++) {
+		void *rxdblock_priv;
+		void *uld_priv;
+		struct vxge_hw_ring_rxd_1 *rxdp;
+
+		u32 reserve_index = ring->channel.reserve_ptr -
+				(index * ring->rxds_per_block  +  i  +  1);
+		u32 memblock_item_idx;
+
+		ring->channel.reserve_arr[reserve_index] = ((u8 *)item)  +
+						i * ring->rxd_size;
+
+		/* Note: memblock_item_idx is index of the item within
+		 *       the memblock. For instance, in case of three RxD-blocks
+		 *       per memblock this value can be 0, 1 or 2. */
+		rxdblock_priv = __hw_mempool_item_priv(
+					(struct vxge_hw_mempool *)mempoolh,
+					memblock_index, item,
+					&memblock_item_idx);
+
+		rxdp = (struct vxge_hw_ring_rxd_1 *)
+				ring->channel.reserve_arr[reserve_index];
+
+		uld_priv = ((u8 *)rxdblock_priv  +  ring->rxd_priv_size * i);
+
+		/* pre-format Host_Control */
+		rxdp->host_control = (u64)(ptr_t)uld_priv;
+	}
+
+	__hw_ring_block_memblock_idx_set(item, memblock_index);
+
+	if (is_last) {
+		/* link last one with first one */
+		__hw_ring_rxdblock_link(mempoolh, ring, index, 0);
+	}
+
+	if (index > 0) {
+		/* link this RxD block with previous one */
+		__hw_ring_rxdblock_link(mempoolh, ring, index-1, index);
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_ring_initial_replenish - Initial replenish of RxDs
+ * @ringh: Handle to the ring object used for receive
+ * @reopen: Flag to denote if it is open or repopen
+ *
+ * This function replenishes the RxDs from reserve array to work array
+ */
+enum vxge_hw_status
+vxge_hw_ring_replenish(
+	struct __hw_ring *ring,
+	enum vxge_hw_reopen reopen, u16 min_flag)
+{
+	void *rxd;
+	int i = 0;
+	struct __hw_channel *channel;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(ring != NULL);
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
+			status = ring->rxd_init(rxd,
+					channel->reserve_ptr,
+					channel->userdata,
+					reopen);
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
+
+	return status;
+}
+
+/**
+ * __hw_ring_create - Create a Ring
+ * @vpath_handle: Handle returned by virtual path open
+ * @attr: Ring configuration parameters structure
+ *
+ * This function creates Ring and initializes it.
+ *
+ */
+enum vxge_hw_status
+__hw_ring_create(
+	struct __hw_vpath_handle *vp,
+	struct vxge_hw_ring_attr *attr)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_ring *ring;
+	u32 ring_length;
+	struct vxge_hw_ring_config *config;
+	struct __hw_device *hldev;
+	u32 vp_id;
+	struct vxge_hw_mempool_cbs ring_mp_callback;
+	vxge_assert((vp != NULL) && (attr != NULL));
+
+	hldev = vp->vpath->hldev;
+	vp_id = vp->vpath->vp_id;
+
+	if ((vp == NULL) || (attr == NULL)) {
+
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	config = &hldev->config.vp_config[vp_id].ring;
+
+	ring_length = config->ring_blocks *
+			vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+
+	ring = (struct __hw_ring *)__hw_channel_allocate(
+					(struct __hw_device *)hldev,
+					vp,
+					VXGE_HW_CHANNEL_TYPE_RING,
+					ring_length,
+					TRUE,
+					TRUE,
+					TRUE,
+					attr->per_rxd_space,
+					attr->userdata);
+
+	if (ring == NULL) {
+
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	vp->vpath->ringh = (struct __hw_ring *)ring;
+
+	ring->rpa_strip_vlan_tag = vp->vpath->vp_config->rpa_strip_vlan_tag;
+
+	ring->vp_id = vp_id;
+	ring->vp_reg = vp->vpath->vp_reg;
+	ring->common_reg = hldev->common_reg;
+	ring->stats = &vp->vpath->sw_stats->ring_stats;
+	ring->config = config;
+	ring->callback = attr->callback;
+	ring->rxd_init = attr->rxd_init;
+	ring->rxd_term = attr->rxd_term;
+
+	ring->indicate_max_pkts = config->indicate_max_pkts;
+	ring->buffer_mode = config->buffer_mode;
+
+	ring->rxd_size = vxge_hw_ring_rxd_size_get(config->buffer_mode);
+	ring->rxd_priv_size =
+		sizeof(struct __hw_ring_rxd_priv)  +  attr->per_rxd_space;
+	ring->per_rxd_space = attr->per_rxd_space;
+
+	ring->rxd_priv_size =
+		((ring->rxd_priv_size  +  VXGE_CACHE_LINE_SIZE - 1) /
+		VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
+
+	/* how many RxDs can fit into one block. Depends on configured
+	 * buffer_mode. */
+	ring->rxds_per_block =
+		vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+
+	/* calculate actual RxD block private size */
+	ring->rxdblock_priv_size = ring->rxd_priv_size * ring->rxds_per_block;
+	ring_mp_callback.item_func_alloc = __hw_ring_mempool_item_alloc;
+	ring_mp_callback.item_func_free = NULL;
+	ring->mempool = __hw_mempool_create(
+				(struct __hw_device *)hldev,
+				VXGE_HW_BLOCK_SIZE,
+				VXGE_HW_BLOCK_SIZE,
+				ring->rxdblock_priv_size,
+				ring->config->ring_blocks,
+				ring->config->ring_blocks,
+				&ring_mp_callback,
+				ring);
+
+	if (ring->mempool == NULL) {
+		__hw_ring_delete(vp);
+
+		return VXGE_HW_ERR_OUT_OF_MEMORY;
+	}
+
+	status = __hw_channel_initialize(&ring->channel);
+	if (status != VXGE_HW_OK) {
+		__hw_ring_delete(vp);
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
+		status = vxge_hw_ring_replenish(ring, VXGE_HW_OPEN_NORMAL, 1);
+		if (status != VXGE_HW_OK) {
+			__hw_ring_delete(vp);
+			goto exit;
+		}
+	}
+
+	/* initial replenish will increment the counter in its post() routine,
+	 * we have to reset it */
+	ring->stats->common_stats.usage_cnt = 0;
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_ring_abort - Returns the RxD
+ * @ringh: Ring to be reset
+ * @reopen: See  enum vxge_hw_reopen{}.
+ *
+ * This function terminates the RxDs of ring
+ */
+enum vxge_hw_status
+__hw_ring_abort(
+	struct __hw_ring *ringh,
+	enum vxge_hw_reopen reopen)
+{
+	struct __hw_ring *ring = (struct __hw_ring *)ringh;
+	void *rxdh;
+	struct __hw_channel *channel;
+
+	vxge_assert(ringh != NULL);
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
+		if (ring->rxd_term) {
+			ring->rxd_term(rxdh,
+				VXGE_HW_RXD_STATE_POSTED,
+				channel->userdata,
+				reopen);
+		}
+
+		vxge_hw_channel_dtr_free(channel, rxdh);
+
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_ring_reset - Resets the ring
+ * @ringh: Ring to be reset
+ *
+ * This function resets the ring during vpath reset operation
+ */
+enum vxge_hw_status
+__hw_ring_reset(
+	struct __hw_ring *ringh)
+{
+	struct __hw_ring *ring = (struct __hw_ring *)ringh;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_channel *channel;
+
+	vxge_assert(ringh != NULL);
+
+	channel = &ring->channel;
+
+	__hw_ring_abort(ringh, VXGE_HW_RESET_ONLY);
+
+	status = __hw_channel_reset(channel);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	if (ring->rxd_init) {
+		status = vxge_hw_ring_replenish(ring, VXGE_HW_RESET_ONLY, 1);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_ring_delete - Removes the ring
+ * @vp: Virtual path handle to which this queue belongs
+ *
+ * This function freeup the memory pool and removes the ring
+ */
+enum vxge_hw_status
+__hw_ring_delete(
+	struct __hw_vpath_handle *vp)
+{
+	struct __hw_ring *ring;
+	struct __hw_channel *channel;
+	struct __hw_device *hldev;
+
+	vxge_assert(vp != NULL);
+
+	hldev = vp->vpath->hldev;
+	ring = (struct __hw_ring *)vp->vpath->ringh;
+
+	vxge_assert(ring != NULL);
+
+	channel = &ring->channel;
+
+	__hw_ring_abort(ring, VXGE_HW_OPEN_NORMAL);
+
+	if (ring->mempool)
+		__hw_mempool_destroy(ring->mempool);
+
+	vp->vpath->ringh = NULL;
+
+	__hw_channel_free(channel);
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_mempool_grow
+ *
+ * Will resize mempool up to %num_allocate value.
+ */
+enum vxge_hw_status
+__hw_mempool_grow(
+	struct vxge_hw_mempool *mempool,
+	u32 num_allocate,
+	u32 *num_allocated)
+{
+	u32 i, first_time = mempool->memblocks_allocated == 0 ? 1 : 0;
+	u32 n_items = mempool->items_per_memblock;
+	u32 start_block_idx = mempool->memblocks_allocated;
+	u32 end_block_idx = mempool->memblocks_allocated  +  num_allocate;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	vxge_assert(mempool != NULL);
+
+	*num_allocated = 0;
+
+	if (end_block_idx > mempool->memblocks_max) {
+
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	for (i = start_block_idx; i < end_block_idx; i++) {
+		u32 j;
+		u32 is_last = ((end_block_idx-1) == i);
+		struct vxge_hw_mempool_dma *dma_object =
+			mempool->memblocks_dma_arr  +  i;
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
+
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+
+		}
+
+		memset(mempool->memblocks_priv_arr[i], 0,
+			     mempool->items_priv_size * n_items);
+
+		/* allocate DMA-capable memblock */
+		mempool->memblocks_arr[i] =
+			__hw_blockpool_malloc(mempool->devh,
+				mempool->memblock_size,
+				&dma_object->addr,
+				&dma_object->handle,
+				&dma_object->acc_handle);
+		if (mempool->memblocks_arr[i] == NULL) {
+			vfree(mempool->memblocks_priv_arr[i]);
+
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+		(*num_allocated)++;
+		mempool->memblocks_allocated++;
+
+		memset(mempool->memblocks_arr[i], 0,
+				mempool->memblock_size);
+
+		the_memblock = mempool->memblocks_arr[i];
+
+		/* fill the items hash array */
+		for (j = 0; j < n_items; j++) {
+			u32 index = i*n_items  +  j;
+
+			if (first_time && index >= mempool->items_initial)
+				break;
+
+			mempool->items_arr[index] =
+				((char *)the_memblock  +  j*mempool->item_size);
+
+			/* let caller to do more job on each item */
+			if (mempool->item_func_alloc != NULL) {
+				enum vxge_hw_status status;
+
+				status = mempool->item_func_alloc(
+					mempool,
+					the_memblock,
+					i,
+					dma_object,
+					mempool->items_arr[index],
+					index,
+					is_last,
+					mempool->userdata);
+			       if (status != VXGE_HW_OK) {
+
+					if (mempool->item_func_free != NULL) {
+						u32 k;
+
+						for (k = 0; k < j; k++) {
+							index = i * n_items + k;
+							(void)mempool->
+								item_func_free(
+							mempool, the_memblock,
+							i, dma_object,
+							mempool->
+							items_arr[index],
+							index, is_last,
+							mempool->userdata);
+						}
+					}
+
+					vfree(mempool->memblocks_priv_arr[i]);
+
+					__hw_blockpool_free(mempool->devh,
+					     the_memblock,
+					     mempool->memblock_size,
+					     &dma_object->addr,
+					     &dma_object->handle,
+					     &dma_object->acc_handle);
+
+					(*num_allocated)--;
+					mempool->memblocks_allocated--;
+					goto exit;
+				}
+			}
+
+			mempool->items_current = index  +  1;
+		}
+
+		if (first_time && mempool->items_current ==
+					mempool->items_initial)
+			break;
+	}
+exit:
+
+	return status;
+}
+
+/*
+ * vxge_hw_mempool_create
+ * @memblock_size:
+ * @items_initial:
+ * @items_max:
+ * @item_size:
+ * @item_func:
+ *
+ * This function will create memory pool object. Pool may grow but will
+ * never shrink. Pool consists of number of dynamically allocated blocks
+ * with size enough to hold %items_initial number of items. Memory is
+ * DMA-able but client must map/unmap before interoperating with the device.
+ * See also: vxge_os_dma_map(), vxge_hw_dma_unmap(), enum vxge_hw_status{}.
+ */
+struct vxge_hw_mempool*
+__hw_mempool_create(
+	struct __hw_device *devh,
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
+	vxge_assert(devh != NULL);
+
+	if (memblock_size < item_size) {
+
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	mempool = (struct vxge_hw_mempool *) \
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
+	mempool->item_func_free		= mp_callback->item_func_free;
+	mempool->userdata		= userdata;
+
+	mempool->memblocks_allocated = 0;
+
+	if (memblock_size != VXGE_HW_BLOCK_SIZE)
+		mempool->dma_flags = VXGE_OS_DMA_CACHELINE_ALIGNED;
+
+#ifdef VXGE_HW_DMA_CONSISTENT
+	mempool->dma_flags |= VXGE_OS_DMA_CONSISTENT;
+#else
+	mempool->dma_flags |= VXGE_OS_DMA_STREAMING;
+#endif
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
+		__hw_mempool_destroy(mempool);
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
+		__hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+	memset(mempool->memblocks_priv_arr, 0,
+		    sizeof(void *) * mempool->memblocks_max);
+
+	/* allocate array of memblocks DMA objects */
+	mempool->memblocks_dma_arr = (struct vxge_hw_mempool_dma *)\
+		vmalloc(sizeof(struct vxge_hw_mempool_dma) *\
+			mempool->memblocks_max);
+
+	if (mempool->memblocks_dma_arr == NULL) {
+		__hw_mempool_destroy(mempool);
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
+		__hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+	memset(mempool->items_arr, 0, sizeof(void *) * mempool->items_max);
+
+	mempool->shadow_items_arr =
+		(void **) vmalloc(sizeof(void *) *  mempool->items_max);
+	if (mempool->shadow_items_arr == NULL) {
+		__hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+	memset(mempool->shadow_items_arr, 0,
+		     sizeof(void *) * mempool->items_max);
+
+	/* calculate initial number of memblocks */
+	memblocks_to_allocate = (mempool->items_initial  +
+				 mempool->items_per_memblock - 1) /
+						mempool->items_per_memblock;
+
+	/* pre-allocate the mempool */
+	status = __hw_mempool_grow(mempool, memblocks_to_allocate, &allocated);
+	memcpy(mempool->shadow_items_arr, mempool->items_arr,
+		    sizeof(void *) * mempool->items_max);
+	if (status != VXGE_HW_OK) {
+		__hw_mempool_destroy(mempool);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		mempool = NULL;
+		goto exit;
+	}
+
+exit:
+
+	return mempool;
+}
+
+/*
+ * vxge_hw_mempool_destroy
+ */
+void
+__hw_mempool_destroy(
+	struct vxge_hw_mempool *mempool)
+{
+	u32 i, j;
+	struct __hw_device *devh;
+
+	vxge_assert(mempool != NULL);
+
+	devh = (struct __hw_device *)mempool->devh;
+
+	for (i = 0; i < mempool->memblocks_allocated; i++) {
+		struct vxge_hw_mempool_dma *dma_object;
+
+		vxge_assert(mempool->memblocks_arr[i]);
+		vxge_assert(mempool->memblocks_dma_arr  +  i);
+
+		dma_object = mempool->memblocks_dma_arr  +  i;
+
+		for (j = 0; j < mempool->items_per_memblock; j++) {
+			u32 index = i*mempool->items_per_memblock  +  j;
+
+			/* to skip last partially filled(if any) memblock */
+			if (index >= mempool->items_current)
+				break;
+
+			/* let caller to do more job on each item */
+			if (mempool->item_func_free != NULL) {
+
+				mempool->item_func_free(mempool,
+					mempool->memblocks_arr[i],
+					i, dma_object,
+					mempool->shadow_items_arr[index],
+					index, /* unused */ -1,
+					mempool->userdata);
+			}
+		}
+
+		vfree(mempool->memblocks_priv_arr[i]);
+
+		__hw_blockpool_free(devh,
+				mempool->memblocks_arr[i],
+				mempool->memblock_size,
+				&dma_object->addr,
+				&dma_object->handle,
+				&dma_object->acc_handle);
+	}
+
+	if (mempool->items_arr)
+		vfree(mempool->items_arr);
+
+	if (mempool->shadow_items_arr)
+		vfree(mempool->shadow_items_arr);
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
+
+}
+
+/*
+ * __hw_device_ring_config_check - Check ring configuration.
+ * @ring_config: Device configuration information
+ *
+ * Check the ring configuration
+ *
+ * Returns: VXGE_HW_OK - success,
+ * otherwise one of the enum vxge_hw_status{} enumerated error codes.
+ *
+ */
+enum vxge_hw_status
+__hw_device_ring_config_check(struct vxge_hw_ring_config *ring_config)
+{
+	if ((ring_config->enable != VXGE_HW_RING_ENABLE) &&
+	   (ring_config->enable != VXGE_HW_RING_DISABLE))
+		return VXGE_HW_BADCFG_RING_ENABLE;
+
+	if ((ring_config->ring_blocks < VXGE_HW_MIN_RING_BLOCKS) ||
+	    (ring_config->ring_blocks > VXGE_HW_MAX_RING_BLOCKS))
+		return VXGE_HW_BADCFG_RING_BLOCKS;
+
+	if ((ring_config->buffer_mode < VXGE_HW_RING_RXD_BUFFER_MODE_1) ||
+	   (ring_config->buffer_mode > VXGE_HW_RING_RXD_BUFFER_MODE_5))
+		return VXGE_HW_BADCFG_RING_RXD_BUFFER_MODE;
+
+	if ((ring_config->scatter_mode != VXGE_HW_RING_SCATTER_MODE_A) &&
+	    (ring_config->scatter_mode != VXGE_HW_RING_SCATTER_MODE_B) &&
+	    (ring_config->scatter_mode != VXGE_HW_RING_SCATTER_MODE_C) &&
+	    (ring_config->scatter_mode !=
+				VXGE_HW_RING_SCATTER_MODE_USE_FLASH_DEFAULT))
+		return VXGE_HW_BADCFG_RING_SCATTER_MODE;
+
+	if ((ring_config->indicate_max_pkts <
+				VXGE_HW_MIN_RING_INDICATE_MAX_PKTS) ||
+				(ring_config->indicate_max_pkts >
+				VXGE_HW_MAX_RING_INDICATE_MAX_PKTS))
+		return VXGE_HW_BADCFG_RING_INDICATE_MAX_PKTS;
+
+	if ((ring_config->sw_lro_sessions < VXGE_HW_SW_LRO_MIN_SESSIONS) ||
+	   (ring_config->sw_lro_sessions > VXGE_HW_SW_LRO_MAX_SESSIONS))
+		return VXGE_HW_BADCFG_SW_LRO_SESSIONS;
+
+	if ((ring_config->sw_lro_sg_size < VXGE_HW_SW_LRO_MIN_SG_SIZE) ||
+	   (ring_config->sw_lro_sg_size > VXGE_HW_SW_LRO_MAX_SG_SIZE))
+		return VXGE_HW_BADCFG_SW_LRO_SG_SIZE;
+
+	if ((ring_config->sw_lro_frm_len < VXGE_HW_SW_LRO_MIN_FRM_LEN) ||
+	   (ring_config->sw_lro_frm_len > VXGE_HW_SW_LRO_MAX_FRM_LEN))
+		return VXGE_HW_BADCFG_SW_LRO_FRM_LEN;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_device_fifo_config_check - Check fifo configuration.
+ * @fifo_config: Fifo configuration information
+ *
+ * Check the fifo configuration
+ *
+ * Returns: VXGE_HW_OK - success,
+ * otherwise one of the enum vxge_hw_status{} enumerated error codes.
+ *
+ */
+enum vxge_hw_status
+__hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config)
+{
+	if ((fifo_config->enable != VXGE_HW_FIFO_ENABLE) &&
+	   (fifo_config->enable != VXGE_HW_FIFO_DISABLE))
+		return VXGE_HW_BADCFG_FIFO_ENABLE;
+
+	if ((fifo_config->fifo_blocks < VXGE_HW_MIN_FIFO_BLOCKS) ||
+	     (fifo_config->fifo_blocks > VXGE_HW_MAX_FIFO_BLOCKS))
+		return VXGE_HW_BADCFG_FIFO_BLOCKS;
+
+	if ((fifo_config->max_frags < VXGE_HW_MIN_FIFO_FRAGS) ||
+	   (fifo_config->max_frags > VXGE_HW_MAX_FIFO_FRAGS))
+		return VXGE_HW_BADCFG_FIFO_FRAGS;
+
+	if ((fifo_config->memblock_size < VXGE_HW_MIN_FIFO_MEMBLOCK_SIZE) ||
+	   (fifo_config->memblock_size > VXGE_HW_MAX_FIFO_MEMBLOCK_SIZE))
+		return VXGE_HW_BADCFG_FIFO_MEMBLOCK_SIZE;
+
+	if (fifo_config->alignment_size > VXGE_HW_MAX_FIFO_ALIGNMENT_SIZE)
+		return VXGE_HW_BADCFG_FIFO_ALIGNMENT_SIZE;
+
+	if (fifo_config->max_aligned_frags > fifo_config->max_frags)
+		return VXGE_HW_BADCFG_FIFO_MAX_FRAGS;
+
+	if ((fifo_config->intr != VXGE_HW_FIFO_QUEUE_INTR_ENABLE) &&
+	   (fifo_config->intr != VXGE_HW_FIFO_QUEUE_INTR_DISABLE))
+		return VXGE_HW_BADCFG_FIFO_QUEUE_INTR;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_device_tim_intr_config_check - Check tim intr configuration.
+ * @tim_intr_config: tim intr configuration information
+ *
+ * Check the tim intr configuration
+ *
+ * Returns: VXGE_HW_OK - success,
+ * otherwise one of the enum vxge_hw_status{} enumerated error codes.
+ *
+ */
+enum vxge_hw_status
+__hw_device_tim_intr_config_check(struct vxge_hw_tim_intr_config
+		*tim_intr_config)
+{
+	if ((tim_intr_config->intr_enable != VXGE_HW_TIM_INTR_ENABLE) &&
+		(tim_intr_config->intr_enable != VXGE_HW_TIM_INTR_DISABLE))
+		return VXGE_HW_BADCFG_TIM_INTR_ENABLE;
+
+	if ((tim_intr_config->btimer_val > VXGE_HW_MAX_TIM_BTIMER_VAL) &&
+	    (tim_intr_config->btimer_val !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_BTIMER_VAL))
+		return VXGE_HW_BADCFG_TIM_BTIMER_VAL;
+
+	if ((tim_intr_config->timer_ac_en != VXGE_HW_TIM_TIMER_AC_ENABLE) &&
+	    (tim_intr_config->timer_ac_en != VXGE_HW_TIM_TIMER_AC_DISABLE) &&
+	    (tim_intr_config->timer_ac_en !=
+				VXGE_HW_TIM_TIMER_AC_USE_FLASH_DEFAULT))
+		return VXGE_HW_BADCFG_TIM_TIMER_AC_EN;
+
+	if ((tim_intr_config->timer_ci_en != VXGE_HW_TIM_TIMER_CI_ENABLE) &&
+	    (tim_intr_config->timer_ci_en != VXGE_HW_TIM_TIMER_CI_DISABLE) &&
+	    (tim_intr_config->timer_ci_en !=
+				VXGE_HW_TIM_TIMER_CI_USE_FLASH_DEFAULT))
+		return VXGE_HW_BADCFG_TIM_TIMER_CI_EN;
+
+	if ((tim_intr_config->timer_ri_en != VXGE_HW_TIM_TIMER_RI_ENABLE) &&
+	    (tim_intr_config->timer_ri_en != VXGE_HW_TIM_TIMER_RI_DISABLE) &&
+	    (tim_intr_config->timer_ri_en !=
+				VXGE_HW_TIM_TIMER_RI_USE_FLASH_DEFAULT))
+		return VXGE_HW_BADCFG_TIM_TIMER_RI_EN;
+
+	if ((tim_intr_config->rtimer_val > VXGE_HW_MAX_TIM_RTIMER_VAL) &&
+	    (tim_intr_config->rtimer_val !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_RTIMER_VAL))
+		return VXGE_HW_BADCFG_TIM_RTIMER_VAL;
+
+	if ((((tim_intr_config->util_sel > 19) &&
+		(tim_intr_config->util_sel < 32)) ||
+		(tim_intr_config->util_sel > 48)) &&
+		(tim_intr_config->util_sel !=
+				VXGE_HW_TIM_UTIL_SEL_USE_FLASH_DEFAULT))
+		return VXGE_HW_BADCFG_TIM_UTIL_SEL;
+
+	if ((tim_intr_config->ltimer_val > VXGE_HW_MAX_TIM_LTIMER_VAL) &&
+	    (tim_intr_config->ltimer_val !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_LTIMER_VAL))
+		return VXGE_HW_BADCFG_TIM_LTIMER_VAL;
+
+	if ((tim_intr_config->urange_a > VXGE_HW_MAX_TIM_URANGE_A) &&
+	    (tim_intr_config->urange_a !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_A))
+		return VXGE_HW_BADCFG_TIM_URANGE_A;
+
+	if ((tim_intr_config->uec_a > VXGE_HW_MAX_TIM_UEC_A) &&
+	    (tim_intr_config->uec_a != VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_A))
+		return VXGE_HW_BADCFG_TIM_UEC_A;
+
+	if ((tim_intr_config->urange_b > VXGE_HW_MAX_TIM_URANGE_B) &&
+	    (tim_intr_config->urange_b !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_B))
+		return VXGE_HW_BADCFG_TIM_URANGE_B;
+
+	if ((tim_intr_config->uec_b > VXGE_HW_MAX_TIM_UEC_B) &&
+	    (tim_intr_config->uec_b != VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_B))
+		return VXGE_HW_BADCFG_TIM_UEC_B;
+
+	if ((tim_intr_config->urange_c > VXGE_HW_MAX_TIM_URANGE_C) &&
+	    (tim_intr_config->urange_c !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_C))
+		return VXGE_HW_BADCFG_TIM_URANGE_C;
+
+	if ((tim_intr_config->uec_c > VXGE_HW_MAX_TIM_UEC_C) &&
+	    (tim_intr_config->uec_c != VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_C))
+		return VXGE_HW_BADCFG_TIM_UEC_C;
+
+	if ((tim_intr_config->uec_d > VXGE_HW_MAX_TIM_UEC_D) &&
+	    (tim_intr_config->uec_d != VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_D))
+		return VXGE_HW_BADCFG_TIM_UEC_D;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_device_vpath_config_check - Check vpath configuration.
+ * @vp_config: Vpath configuration information
+ *
+ * Check the vpath configuration
+ *
+ * Returns: VXGE_HW_OK - success,
+ * otherwise one of the enum vxge_hw_status{} enumerated error codes.
+ *
+ */
+enum vxge_hw_status
+__hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
+{
+	enum vxge_hw_status status;
+
+	if (vp_config->vp_id > VXGE_HW_MAX_VIRTUAL_PATHS)
+		return VXGE_HW_BADCFG_VPATH_ID;
+
+	if ((vp_config->min_bandwidth < VXGE_HW_VPATH_BANDWIDTH_MIN) ||
+		(vp_config->min_bandwidth >
+					VXGE_HW_VPATH_BANDWIDTH_MAX))
+		return VXGE_HW_BADCFG_VPATH_MIN_BANDWIDTH;
+
+	status = __hw_device_ring_config_check(&vp_config->ring);
+	if (status != VXGE_HW_OK)
+		return status;
+
+	status = __hw_device_fifo_config_check(&vp_config->fifo);
+	if (status != VXGE_HW_OK)
+		return status;
+
+	status = __hw_device_tim_intr_config_check(&vp_config->tti);
+	if (status != VXGE_HW_OK)
+		return status;
+
+	status = __hw_device_tim_intr_config_check(&vp_config->rti);
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
+	if ((vp_config->aggr_ack != VXGE_HW_VPATH_AGGR_ACK_ENABLE) &&
+		(vp_config->aggr_ack != VXGE_HW_VPATH_AGGR_ACK_DISABLE) &&
+		(vp_config->aggr_ack != VXGE_HW_VPATH_AGGR_ACK_DEFAULT))
+		return VXGE_HW_BADCFG_VPATH_AGGR_ACK;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_device_config_check - Check device configuration.
+ * @new_config: Device configuration information
+ *
+ * Check the device configuration
+ *
+ * Returns: VXGE_HW_OK - success,
+ * otherwise one of the enum vxge_hw_status{} enumerated error codes.
+ *
+ */
+enum vxge_hw_status
+__hw_device_config_check(struct vxge_hw_device_config *new_config)
+{
+	u32 i;
+	enum vxge_hw_status status;
+
+	if (new_config->dma_blockpool_incr <
+				VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE)
+		return VXGE_HW_BADCFG_BLOCKPOOL_INCR;
+
+	if (new_config->dma_blockpool_max <
+				VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE)
+		return VXGE_HW_BADCFG_BLOCKPOOL_MAX;
+
+	if (
+
+	   (new_config->intr_mode != VXGE_HW_INTR_MODE_IRQLINE) &&
+	   (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX) &&
+	   (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) &&
+	   (new_config->intr_mode != VXGE_HW_INTR_MODE_DEF))
+		return VXGE_HW_BADCFG_INTR_MODE;
+
+	if ((new_config->rth_en != VXGE_HW_RTH_DISABLE) &&
+	   (new_config->rth_en != VXGE_HW_RTH_ENABLE))
+		return VXGE_HW_BADCFG_RTH_EN;
+
+	if ((new_config->rth_it_type != VXGE_HW_RTH_IT_TYPE_SOLO_IT) &&
+	   (new_config->rth_it_type != VXGE_HW_RTH_IT_TYPE_MULTI_IT))
+		return VXGE_HW_BADCFG_RTH_IT_TYPE;
+
+	if ((new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE) &&
+	   (new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE))
+		return VXGE_HW_BADCFG_RTS_MAC_EN;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+		status = __hw_device_vpath_config_check(
+				&new_config->vp_config[i]);
+		if (status != VXGE_HW_OK)
+			return status;
+	}
+
+	if ((new_config->stats_read_method != VXGE_HW_STATS_READ_METHOD_DMA) &&
+	   (new_config->stats_read_method != VXGE_HW_STATS_READ_METHOD_PIO))
+		return VXGE_HW_BADCFG_STATS_READ_METHOD;
+
+	if ((new_config->device_poll_millis <
+	   VXGE_HW_MIN_DEVICE_POLL_MILLIS) ||
+	   (new_config->device_poll_millis > VXGE_HW_MAX_DEVICE_POLL_MILLIS))
+		return VXGE_HW_BADCFG_DEVICE_POLL_MILLIS;
+
+	return VXGE_HW_OK;
+}
+
+/**
+ * vxge_hw_device_config_default_get - Initialize device config with defaults.
+ * @device_config: Configuration structure to be initialized,
+ *                 For the Titan configuration "knobs" please
+ *                 refer to struct vxge_hw_device_config and Titan
+ *                 User Guide.
+ *
+ * Initialize Titan device config with default values.
+ *
+ * See also: vxge_hw_device_initialize(), vxge_hw_device_terminate(),
+ * enum vxge_hw_status{} struct vxge_hw_device_attr{}.
+ */
+enum vxge_hw_status vxge_hw_device_config_default_get(
+			struct vxge_hw_device_config *device_config)
+{
+	u32 i;
+
+	device_config->dma_blockpool_min = VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE;
+	device_config->dma_blockpool_initial =
+					VXGE_HW_INITIAL_DMA_BLOCK_POOL_SIZE;
+	device_config->dma_blockpool_incr = VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE;
+	device_config->dma_blockpool_max = VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE;
+
+	device_config->intr_mode = VXGE_HW_INTR_MODE_DEF;
+
+	device_config->rth_en = VXGE_HW_RTH_DEFAULT;
+
+	device_config->rth_it_type = VXGE_HW_RTH_IT_TYPE_DEFAULT;
+
+	device_config->device_poll_millis =  VXGE_HW_DEF_DEVICE_POLL_MILLIS;
+
+	device_config->rts_mac_en =  VXGE_HW_RTS_MAC_DEFAULT;
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		device_config->vp_config[i].vp_id = i;
+
+		device_config->vp_config[i].min_bandwidth =
+				VXGE_HW_VPATH_BANDWIDTH_DEFAULT;
+
+		device_config->vp_config[i].ring.enable =
+				VXGE_HW_RING_DEFAULT;
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
+		device_config->vp_config[i].ring.indicate_max_pkts =
+				VXGE_HW_DEF_RING_INDICATE_MAX_PKTS;
+
+		device_config->vp_config[i].ring.sw_lro_sessions =
+				VXGE_HW_SW_LRO_DEFAULT_SESSIONS;
+
+		device_config->vp_config[i].ring.sw_lro_sg_size =
+				VXGE_HW_SW_LRO_MAX_SG_SIZE;
+
+		device_config->vp_config[i].ring.sw_lro_frm_len =
+				VXGE_HW_SW_LRO_MAX_FRM_LEN;
+
+		device_config->vp_config[i].fifo.enable =
+				VXGE_HW_FIFO_DEFAULT;
+
+		device_config->vp_config[i].fifo.fifo_blocks =
+				VXGE_HW_DEF_FIFO_BLOCKS;
+
+		device_config->vp_config[i].fifo.max_frags =
+				VXGE_HW_DEF_FIFO_FRAGS;
+
+		device_config->vp_config[i].fifo.memblock_size =
+				VXGE_HW_DEF_FIFO_MEMBLOCK_SIZE;
+
+		device_config->vp_config[i].fifo.alignment_size =
+				VXGE_HW_DEF_FIFO_ALIGNMENT_SIZE;
+
+		device_config->vp_config[i].fifo.max_aligned_frags = 0;
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
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_BTIMER_VAL;
+
+		device_config->vp_config[i].tti.timer_ac_en =
+				VXGE_HW_TIM_TIMER_AC_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.timer_ci_en =
+				VXGE_HW_TIM_TIMER_CI_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.timer_ri_en =
+				VXGE_HW_TIM_TIMER_RI_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.rtimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_RTIMER_VAL;
+
+		device_config->vp_config[i].tti.util_sel =
+				VXGE_HW_TIM_UTIL_SEL_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].tti.ltimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_LTIMER_VAL;
+
+		device_config->vp_config[i].tti.urange_a =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_A;
+
+		device_config->vp_config[i].tti.uec_a =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_A;
+
+		device_config->vp_config[i].tti.urange_b =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_B;
+
+		device_config->vp_config[i].tti.uec_b =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_B;
+
+		device_config->vp_config[i].tti.urange_c =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_C;
+
+		device_config->vp_config[i].tti.uec_c =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_C;
+
+		device_config->vp_config[i].tti.uec_d =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_D;
+
+		device_config->vp_config[i].rti.intr_enable =
+				VXGE_HW_TIM_INTR_DEFAULT;
+
+		device_config->vp_config[i].rti.btimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_BTIMER_VAL;
+
+		device_config->vp_config[i].rti.timer_ac_en =
+				VXGE_HW_TIM_TIMER_AC_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.timer_ci_en =
+				VXGE_HW_TIM_TIMER_CI_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.timer_ri_en =
+				VXGE_HW_TIM_TIMER_RI_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.rtimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_RTIMER_VAL;
+
+		device_config->vp_config[i].rti.util_sel =
+				VXGE_HW_TIM_UTIL_SEL_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].rti.ltimer_val =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_LTIMER_VAL;
+
+		device_config->vp_config[i].rti.urange_a =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_A;
+
+		device_config->vp_config[i].rti.uec_a =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_A;
+
+		device_config->vp_config[i].rti.urange_b =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_B;
+
+		device_config->vp_config[i].rti.uec_b =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_B;
+
+		device_config->vp_config[i].rti.urange_c =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_C;
+
+		device_config->vp_config[i].rti.uec_c =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_C;
+
+		device_config->vp_config[i].rti.uec_d =
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_D;
+
+		device_config->vp_config[i].mtu =
+				VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU;
+
+		device_config->vp_config[i].rpa_strip_vlan_tag =
+			VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT;
+
+		device_config->vp_config[i].aggr_ack =
+				VXGE_HW_VPATH_AGGR_ACK_DEFAULT;
+
+	}
+
+	device_config->stats_read_method = VXGE_HW_STATS_READ_METHOD_DEFAULT;
+
+	device_config->tracebuf_size = VXGE_HW_DEF_CIRCULAR_ARR;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * _hw_legacy_swapper_set - Set the swapper bits for the legacy secion.
+ * @legacy_reg: Address of the legacy register space.
+ *
+ * Set the swapper bits appropriately for the lagacy section.
+ *
+ * Returns:  VXGE_HW_OK - success.
+ * VXGE_HW_ERR_SWAPPER_CTRL - failed.
+ *
+ * See also: enum vxge_hw_status{}.
+ */
+enum vxge_hw_status
+__hw_legacy_swapper_set(struct vxge_hw_legacy_reg	*legacy_reg)
+{
+	u64 val64;
+	enum vxge_hw_status status;
+
+	vxge_assert(legacy_reg != NULL);
+
+	val64 = readq(&legacy_reg->toc_swapper_fb);
+
+	wmb();
+
+	switch (val64) {
+
+	case VXGE_HW_SWAPPER_INITIAL_VALUE:
+		return VXGE_HW_OK;
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
+
+	}
+
+	wmb();
+
+	val64 = readq(&legacy_reg->toc_swapper_fb);
+
+	if (val64 == VXGE_HW_SWAPPER_INITIAL_VALUE)
+		status = VXGE_HW_OK;
+	else
+		status = VXGE_HW_ERR_SWAPPER_CTRL;
+
+	return status;
+}
+
+/*
+ * __hw_vpath_swapper_set - Set the swapper bits for the vpath.
+ * @vpath_reg: Address of the vpath register space.
+ *
+ * Set the swapper bits appropriately for the vpath.
+ *
+ * Returns:  VXGE_HW_OK - success.
+ * VXGE_HW_ERR_SWAPPER_CTRL - failed.
+ *
+ * See also: enum vxge_hw_status{}.
+ */
+enum vxge_hw_status
+__hw_vpath_swapper_set(struct vxge_hw_vpath_reg	*vpath_reg) {
+#if !defined(VXGE_OS_HOST_BIG_ENDIAN)
+	u64 val64;
+
+	vxge_assert(vpath_reg != NULL);
+
+	val64 = readq(&vpath_reg->vpath_general_cfg1);
+
+	wmb();
+
+	val64 |= VXGE_HW_VPATH_GENERAL_CFG1_CTL_BYTE_SWAPEN;
+
+	writeq(val64, &vpath_reg->vpath_general_cfg1);
+	wmb();
+
+#endif
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_kdfc_swapper_set - Set the swapper bits for the kdfc.
+ * @legacy_reg: Address of the legacy register space.
+ * @vpath_reg: Address of the vpath register space.
+ *
+ * Set the swapper bits appropriately for the vpath.
+ *
+ * Returns:  VXGE_HW_OK - success.
+ * VXGE_HW_ERR_SWAPPER_CTRL - failed.
+ *
+ * See also: enum vxge_hw_status{}.
+ */
+enum vxge_hw_status
+__hw_kdfc_swapper_set(struct vxge_hw_legacy_reg	*legacy_reg,
+			struct vxge_hw_vpath_reg	*vpath_reg)
+{
+	u64 val64;
+
+	vxge_assert(vpath_reg != NULL);
+
+	val64 = readq(&legacy_reg->pifm_wr_swap_en);
+
+	if (val64 == VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE) {
+
+		val64 = readq(&vpath_reg->kdfcctl_cfg0);
+
+		wmb();
+
+		val64 |= VXGE_HW_KDFCCTL_CFG0_BYTE_SWAPEN_FIFO0	|
+			VXGE_HW_KDFCCTL_CFG0_BYTE_SWAPEN_FIFO1	|
+			VXGE_HW_KDFCCTL_CFG0_BYTE_SWAPEN_FIFO2;
+
+		writeq(val64, &vpath_reg->kdfcctl_cfg0);
+		wmb();
+
+	}
+
+	return VXGE_HW_OK;
+}
+
+/**
+ * vxge_read_pci_config - Retrieve PCI configuration.
+ * @hldev: HW device handle.
+ * @pci_config: 256 byte long buffer for PCI configuration space.
+ * @size: Size of the @ buffer. HW will return an error
+ * if the size is smaller than sizeof(struct vxge_hw_pci_config).
+ *
+ * Get PCI configuration. Permits to retrieve at run-time configuration
+ * values that were used to configure the device at load-time.
+ *
+ * Returns: VXGE_HW_OK - success.
+ * VXGE_HW_ERR_INVALID_DEVICE - Device is not valid.
+ * VXGE_HW_ERR_VERSION_CONFLICT - Version it not maching.
+ *
+ */
+enum vxge_hw_status
+vxge_read_pci_config(struct __hw_device *hldev, u8 *buffer, u32 size)
+{
+	int i;
+	struct vxge_hw_pci_config *pci_config =
+		(struct vxge_hw_pci_config *)buffer;
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC))
+		return VXGE_HW_ERR_INVALID_DEVICE;
+
+	if (size != sizeof(struct vxge_hw_pci_config))
+		return VXGE_HW_ERR_VERSION_CONFLICT;
+
+	/* refresh PCI config space */
+	for (i = 0; i < 0x68/4+1; i++) {
+		pci_read_config_dword(hldev->pdev, i * 4,
+					(u32 *)&hldev->pci_config_space  +  i);
+	}
+
+	memcpy(pci_config, &hldev->pci_config_space,
+		    sizeof(struct vxge_hw_pci_config));
+
+	return VXGE_HW_OK;
+}
+
+/**
+ * vxge_hw_mgmt_device_config - Retrieve device configuration.
+ * @hldev: HW device handle.
+ * @dev_config: Device configuration, see struct vxge_hw_device_config{}.
+ * @size: Size of the @dev_config buffer. HW will return an error
+ * if the size is smaller than sizeof(struct vxge_hw_device_config).
+ *
+ * Get device configuration. Permits to retrieve at run-time configuration
+ * values that were used to initialize and configure the device.
+ *
+ * Returns: VXGE_HW_OK - success.
+ * VXGE_HW_ERR_INVALID_DEVICE - Device is not valid.
+ * VXGE_HW_ERR_VERSION_CONFLICT - Version it not maching.
+ *
+ * See also: struct vxge_hw_device_config{}.
+ */
+enum vxge_hw_status
+vxge_hw_mgmt_device_config(struct __hw_device *hldev,
+		struct vxge_hw_device_config	*dev_config, int size)
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
+/**
+ * vxge_hw_mgmt_reg_read - Read Titan register.
+ * @hldev: HW device handle.
+ * @type: Register types as defined in enum enum vxge_hw_mgmt_reg_type{}
+ * @Index: For pcicfgmgmt, srpcim, vpmgmt, vpath this gives the Index
+ *             ignored for others
+ * @offset: Register offset in the reguster space qualified by the type and
+ *             index.
+ * @value: Register value. Returned by HW.
+ * Read Titan register.
+ *
+ * Returns: VXGE_HW_OK - success.
+ * VXGE_HW_ERR_INVALID_DEVICE - Device is not valid.
+ * VXGE_HW_ERR_INVALID_TYPE - Type is not valid.
+ * VXGE_HW_ERR_INVALID_INDEX - Index is not valid.
+ * VXGE_HW_ERR_INVALID_OFFSET - Register offset in the space is not valid.
+ *
+ */
+enum vxge_hw_status
+vxge_hw_mgmt_reg_read(struct __hw_device *hldev,
+		      enum vxge_hw_mgmt_reg_type type,
+		      u32 index,
+		      u32 offset,
+		      u64 *value)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(hldev != NULL);
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC)) {
+		status = VXGE_HW_ERR_INVALID_DEVICE;
+		goto exit;
+	}
+
+	switch (type) {
+	case vxge_hw_mgmt_reg_type_legacy:
+		if (offset > sizeof(struct vxge_hw_legacy_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->legacy_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_toc:
+		if (offset > sizeof(struct vxge_hw_toc_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->toc_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_common:
+		if (offset > sizeof(struct vxge_hw_common_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->common_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_memrepair:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_memrepair_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value =
+		    readq((void *)(((ptr_t)hldev->memrepair_reg) + offset));
+		break;
+	case vxge_hw_mgmt_reg_type_pcicfgmgmt:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_PCICFGMGMT_REG_SPACES-1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_pcicfgmgmt_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->pcicfgmgmt_reg[index])
+						 +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_mrpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_mrpcim_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->mrpcim_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_srpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_SRPCIM_REG_SPACES-1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_srpcim_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->srpcim_reg[index])
+								 +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_vpmgmt:
+		if ((index > VXGE_HW_TITAN_VPMGMT_REG_SPACES-1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpmgmt_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->vpmgmt_reg[index])
+								 +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_vpath:
+		if ((index > VXGE_HW_TITAN_VPATH_REG_SPACES-1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_VPATH_REG_SPACES-1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpath_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		*value = readq((void *)(((ptr_t)hldev->vpath_reg[index])
+								 +  offset));
+		break;
+	default:
+		status = VXGE_HW_ERR_INVALID_TYPE;
+		break;
+	}
+
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_mgmt_reg_Write - Write Titan register.
+ * @hldev: HW device handle.
+ * @type: Register types as defined in enum enum vxge_hw_mgmt_reg_type{}
+ * @index: For pcicfgmgmt, srpcim, vpmgmt, vpath this gives the Index
+ *             ignored for others
+ * @offset: Register offset in the reguster space qualified by the type and
+ *             index.
+ * @value: Register value to be written.
+ * Write Titan register.
+ *
+ * Returns: VXGE_HW_OK - success.
+ * VXGE_HW_ERR_INVALID_DEVICE - Device is not valid.
+ * VXGE_HW_ERR_INVALID_TYPE - Type is not valid.
+ * VXGE_HW_ERR_INVALID_INDEX - Index is not valid.
+ * VXGE_HW_ERR_INVALID_OFFSET - Register offset in the space is not valid.
+ *
+ */
+enum vxge_hw_status
+vxge_hw_mgmt_reg_write(struct __hw_device *hldev,
+		      enum vxge_hw_mgmt_reg_type type,
+		      u32 index,
+		      u32 offset,
+		      u64 value)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(hldev != NULL);
+
+	if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC)) {
+		status = VXGE_HW_ERR_INVALID_DEVICE;
+		goto exit;
+	}
+
+	switch (type) {
+	case vxge_hw_mgmt_reg_type_legacy:
+		if (offset > sizeof(struct vxge_hw_legacy_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value,
+			(void *)(((ptr_t)hldev->legacy_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_toc:
+		if (offset > sizeof(struct vxge_hw_toc_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void *)(((ptr_t)hldev->toc_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_common:
+		if (offset > sizeof(struct vxge_hw_common_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void *)(((ptr_t)hldev->common_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_memrepair:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_memrepair_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value,
+			(void *)(((ptr_t)hldev->memrepair_reg) + offset));
+		break;
+	case vxge_hw_mgmt_reg_type_pcicfgmgmt:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_PCICFGMGMT_REG_SPACES-1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_pcicfgmgmt_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void *)(((ptr_t)hldev->pcicfgmgmt_reg[index])  +
+								offset));
+		break;
+	case vxge_hw_mgmt_reg_type_mrpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_mrpcim_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void *)(((ptr_t)hldev->mrpcim_reg)  +  offset));
+		break;
+	case vxge_hw_mgmt_reg_type_srpcim:
+		if (!(hldev->access_rights &
+			VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM)) {
+			status = VXGE_HW_ERR_PRIVILAGED_OPEARATION;
+			break;
+		}
+		if (index > VXGE_HW_TITAN_SRPCIM_REG_SPACES-1) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_srpcim_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void *)(((ptr_t)hldev->srpcim_reg[index])  +
+				offset));
+		break;
+	case vxge_hw_mgmt_reg_type_vpmgmt:
+		if ((index > VXGE_HW_TITAN_VPMGMT_REG_SPACES-1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpmgmt_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value, (void *)(((ptr_t)hldev->vpmgmt_reg[index])  +
+					offset));
+		break;
+	case vxge_hw_mgmt_reg_type_vpath:
+		if ((index > VXGE_HW_TITAN_VPATH_REG_SPACES-1) ||
+			(!(hldev->vpath_assignments & vxge_mBIT(index)))) {
+			status = VXGE_HW_ERR_INVALID_INDEX;
+			break;
+		}
+		if (offset > sizeof(struct vxge_hw_vpath_reg)-8) {
+			status = VXGE_HW_ERR_INVALID_OFFSET;
+			break;
+		}
+		writeq(value,
+			(void *)(((ptr_t)hldev->vpath_reg[index])  +  offset));
+		break;
+	default:
+		status = VXGE_HW_ERR_INVALID_TYPE;
+		break;
+	}
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_fifo_mempool_item_alloc - Allocate List blocks for TxD list callback
+ * @mempoolh: Handle to memory pool
+ * @memblock: Address of this memory block
+ * @memblock_index: Index of this memory block
+ * @dma_object: dma object for this block
+ * @item: Pointer to this item
+ * @index: Index of this item in memory block
+ * @is_last: If this is last item in the block
+ * @userdata: Specific data of user
+ *
+ * This function is callback passed to __hw_mempool_create to create memory
+ * pool for TxD list
+ */
+static enum vxge_hw_status
+__hw_fifo_mempool_item_alloc(
+	struct vxge_hw_mempool *mempoolh,
+	 void *memblock,
+	u32 memblock_index,
+	struct vxge_hw_mempool_dma *dma_object,
+	void *item,
+	u32 index,
+	u32 is_last,
+	void *userdata)
+{
+	u32 memblock_item_idx;
+	struct __hw_fifo_txdl_priv *txdl_priv;
+	struct vxge_hw_fifo_txd *txdp = (struct vxge_hw_fifo_txd *)item;
+	struct __hw_fifo *fifo = (struct __hw_fifo *)userdata;
+
+	vxge_assert(fifo != NULL);
+
+	vxge_assert(item);
+
+	txdp->host_control = (u64) (ptr_t)
+	__hw_mempool_item_priv((struct vxge_hw_mempool *) mempoolh,
+					memblock_index,
+					item,
+					&memblock_item_idx);
+
+	txdl_priv = __hw_fifo_txdl_priv(fifo, txdp);
+
+	vxge_assert(txdl_priv);
+
+	fifo->channel.reserve_arr[fifo->channel.reserve_ptr - 1 - index] = item;
+
+	/* pre-format HW's TxDL's private */
+	txdl_priv->dma_offset = (char *)item - (char *)memblock;
+	txdl_priv->dma_addr = dma_object->addr  +  txdl_priv->dma_offset;
+	txdl_priv->dma_handle = dma_object->handle;
+	txdl_priv->memblock   = memblock;
+	txdl_priv->first_txdp = (struct vxge_hw_fifo_txd *)item;
+	txdl_priv->next_txdl_priv = NULL;
+	txdl_priv->dang_txdl = NULL;
+	txdl_priv->dang_frags = 0;
+	txdl_priv->alloc_frags = 0;
+
+#ifdef VXGE_DEBUG_ASSERT
+	txdl_priv->dma_object = dma_object;
+#endif
+
+	if (fifo->txdl_init) {
+		fifo->txdl_init(fifo->channel.vph, (void *)txdp,
+			(void *)(ptr_t)txdp->host_control, index,
+			fifo->channel.userdata, VXGE_HW_OPEN_NORMAL);
+	}
+
+	return VXGE_HW_OK;
+}
+
+/**
+ * __hw_fifo_create - Create a FIFO
+ * @vpath_handle: Handle returned by virtual path open
+ * @attr: FIFO configuration parameters structure
+ *
+ * This function creates FIFO and initializes it.
+ *
+ */
+enum vxge_hw_status
+__hw_fifo_create(struct __hw_vpath_handle *vp, struct vxge_hw_fifo_attr *attr)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_fifo *fifo;
+	struct vxge_hw_fifo_config *config;
+	u32 txdl_size, txdl_per_memblock;
+	struct vxge_hw_mempool_cbs fifo_mp_callback;
+	vxge_assert((vp != NULL) && (attr != NULL));
+
+	if ((vp == NULL) || (attr == NULL)) {
+
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	config = &vp->vpath->hldev->config.vp_config[vp->vpath->vp_id] \
+									.fifo;
+
+	txdl_size = config->max_frags * sizeof(struct vxge_hw_fifo_txd);
+
+	txdl_per_memblock = config->memblock_size / txdl_size;
+
+	fifo = (struct __hw_fifo *)__hw_channel_allocate(
+					(struct __hw_device *)vp->vpath->hldev,
+					vp,
+					VXGE_HW_CHANNEL_TYPE_FIFO,
+					config->fifo_blocks*txdl_per_memblock,
+					TRUE,
+					TRUE,
+					TRUE,
+					attr->per_txdl_space,
+					attr->userdata);
+
+	if (fifo == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	vp->vpath->fifoh = fifo;
+	fifo->nofl_db = vp->vpath->nofl_db;
+
+	fifo->vp_id = vp->vpath->vp_id;
+	fifo->vp_reg = vp->vpath->vp_reg;
+	fifo->stats = &vp->vpath->sw_stats->fifo_stats;
+
+	fifo->config = config;
+
+	fifo->align_size =
+		fifo->config->alignment_size * fifo->config->max_aligned_frags;
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
+	 * TxDL splitted into three independent parts:
+	 *	- set of TxD's
+	 *	- TxD HW private part
+	 *	- driver private part
+	 *
+	 * Adaptative memory allocation used. i.e. Memory allocated on
+	 * demand with the size which will fit into one memory block.
+	 * One memory block may contain more than one TxDL. In simple case
+	 * memory block size can be equal to CPU page size. On more
+	 * sophisticated OS's memory block can be contigious across
+	 * several pages.
+	 *
+	 * During "reserve" operations more memory can be allocated on demand
+	 * for example due to FIFO full condition.
+	 *
+	 * Pool of memory memblocks never shrinks except __hw_fifo_close
+	 * routine which will essentially stop channel and free the resources.
+	 */
+
+	/* TxDL common private size == TxDL private  +  driver private */
+	fifo->priv_size =
+		sizeof(struct __hw_fifo_txdl_priv) + attr->per_txdl_space;
+	fifo->priv_size = ((fifo->priv_size  +  VXGE_CACHE_LINE_SIZE - 1) /
+			VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
+
+	fifo->per_txdl_space = attr->per_txdl_space;
+
+	/* recompute txdl size to be cacheline aligned */
+	fifo->txdl_size = txdl_size;
+	fifo->txdl_per_memblock = txdl_per_memblock;
+
+	/* since txdl_init() callback will be called from item_alloc(),
+	 * the same way channels userdata might be used prior to
+	 * channel_initialize() */
+	fifo->txdl_init = attr->txdl_init;
+	fifo->txdl_term = attr->txdl_term;
+	fifo->callback = attr->callback;
+
+	if (fifo->txdl_per_memblock == 0) {
+		__hw_fifo_delete(vp);
+		status = VXGE_HW_ERR_INVALID_BLOCK_SIZE;
+		goto exit;
+	}
+
+	fifo_mp_callback.item_func_alloc = __hw_fifo_mempool_item_alloc;
+	fifo_mp_callback.item_func_free = NULL;
+
+	fifo->mempool = __hw_mempool_create(
+					(struct __hw_device *)vp->vpath->hldev,
+					fifo->config->memblock_size,
+					fifo->txdl_size,
+					fifo->priv_size,
+					(fifo->config->fifo_blocks *
+					fifo->txdl_per_memblock),
+					(fifo->config->fifo_blocks *
+					fifo->txdl_per_memblock),
+					&fifo_mp_callback,
+					fifo);
+
+	if (fifo->mempool == NULL) {
+		__hw_fifo_delete(vp);
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
+
+	status = __hw_channel_initialize(&fifo->channel);
+	if (status != VXGE_HW_OK) {
+		__hw_fifo_delete(vp);
+		goto exit;
+	}
+
+	vxge_assert(fifo->channel.reserve_ptr);
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_fifo_abort - Returns the TxD
+ * @fifoh: Fifo to be reset
+ * @reopen: See  enum vxge_hw_reopen{}.
+ *
+ * This function terminates the TxDs of fifo
+ */
+enum vxge_hw_status
+__hw_fifo_abort(struct __hw_fifo *fifoh, enum vxge_hw_reopen reopen)
+{
+	struct __hw_fifo *fifo = (struct __hw_fifo *)fifoh;
+	void *txdlh;
+
+	vxge_assert(fifoh != NULL);
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
+			(void *)(ptr_t)((struct vxge_hw_fifo_txd *)txdlh)->
+			host_control, VXGE_HW_TXDL_STATE_POSTED,
+			fifo->channel.userdata, reopen);
+		}
+
+		vxge_hw_channel_dtr_free(&fifo->channel, txdlh);
+
+	}
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_fifo_reset - Resets the fifo
+ * @fifoh: Fifo to be reset
+ *
+ * This function resets the fifo during vpath reset operation
+ */
+enum vxge_hw_status
+__hw_fifo_reset(struct __hw_fifo *fifoh)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_fifo *fifo = (struct __hw_fifo *)fifoh;
+
+	vxge_assert(fifoh != NULL);
+
+	__hw_fifo_abort(fifoh, VXGE_HW_RESET_ONLY);
+
+	status = __hw_channel_reset(&fifo->channel);
+
+	return status;
+}
+
+/*
+ * __hw_fifo_delete - Removes the FIFO
+ * @vp: Virtual path handle to which this queue belongs
+ *
+ * This function freeup the memory pool and removes the FIFO
+ */
+enum vxge_hw_status
+__hw_fifo_delete(struct __hw_vpath_handle *vp)
+{
+	struct __hw_fifo *fifo;
+
+	vxge_assert(vp != NULL);
+
+	fifo = (struct __hw_fifo *)vp->vpath->fifoh;
+
+	vxge_assert(fifo != NULL);
+
+	__hw_fifo_abort(vp->vpath->fifoh, VXGE_HW_OPEN_NORMAL);
+
+	if (fifo->mempool)
+		__hw_mempool_destroy(fifo->mempool);
+
+	vp->vpath->fifoh = NULL;
+
+	__hw_channel_free(&fifo->channel);
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __hw_vpath_pci_read - Read the content of given address
+ *                          in pci config space.
+ * @vpath: Virtual Path object.
+ * @phy_func_0: If 1 read from Physical function 0, 0 from default
+ * @offset: Configuration address(offset)to read from
+ * @val: Pointer to a buffer to return the content of the address
+ *
+ * Read from the vpath pci config space.
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_pci_read(
+	struct __hw_virtualpath	*vpath,
+	u32			phy_func_0,
+	u32			offset,
+	u32			*val)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((vpath != NULL) && (val != NULL));
+
+	val64 =	VXGE_HW_PCI_CONFIG_ACCESS_CFG1_ADDRESS(offset);
+
+	if (phy_func_0)
+		val64 |= VXGE_HW_PCI_CONFIG_ACCESS_CFG1_SEL_FUNC0;
+
+	writeq(val64, &vpath->vp_reg->pci_config_access_cfg1);
+
+	wmb();
+
+	writeq(VXGE_HW_PCI_CONFIG_ACCESS_CFG2_REQ,
+			&vpath->vp_reg->pci_config_access_cfg2);
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath->vp_reg->pci_config_access_cfg2, 0,
+			VXGE_HW_INTR_MASK_ALL,
+			VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath->vp_reg->pci_config_access_status);
+
+	if (val64 & VXGE_HW_PCI_CONFIG_ACCESS_STATUS_ACCESS_ERR) {
+		status = VXGE_HW_FAIL;
+		*val = 0;
+	} else
+		*val = (u32)bVAL32(val64, 32);
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_func_id_get - Get the function id of the vpath.
+ * @vp_id: Vpath id
+ * @vpmgmt_reg: Pointer to vpath management registers
+ *
+ * Returns the function number of the vpath.
+ *
+ */
+u32
+__hw_vpath_func_id_get(u32 vp_id, struct vxge_hw_vpmgmt_reg *vpmgmt_reg)
+{
+	u64 val64;
+
+	vxge_assert(vpmgmt_reg != NULL);
+
+	val64 = readq(&vpmgmt_reg->vpath_to_func_map_cfg1);
+
+	return
+	 (u32)VXGE_HW_VPATH_TO_FUNC_MAP_CFG1_GET_VPATH_TO_FUNC_MAP_CFG1(val64);
+}
+
+/*
+ * __hw_vpath_fw_flash_ver_get - Get the fw version
+ * @vp_id: Vpath id
+ * @vpath_reg: Pointer to vpath registers
+ * @fw_version: Buffer to return FW Version (Major)
+ * @fw_date: Buffer to return FW Version (date)
+ * @flash_version: Buffer to return FW Version (Major)
+ * @flash_date: Buffer to return FW Version (date)
+ *
+ * Returns FW Version
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_fw_flash_ver_get(
+	u32			  vp_id,
+	struct vxge_hw_vpath_reg	  *vpath_reg,
+	struct vxge_hw_device_version *fw_version,
+	struct vxge_hw_device_date	  *fw_date,
+	struct vxge_hw_device_version *flash_version,
+	struct vxge_hw_device_date	  *flash_date)
+{
+	u64 val64;
+	u64 data1 = 0ULL;
+	u64 data2 = 0ULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((vpath_reg != NULL) && (fw_version != NULL) &&
+		(fw_date != NULL) && (flash_version != NULL) &&
+		(flash_date != NULL));
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	__hw_pio_mem_write32_lower((u32)bVAL32(val64, 32),
+				&vpath_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+				&vpath_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath_reg->rts_access_steer_ctrl, 0,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+			WAIT_FACTOR * VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+
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
+		sprintf(fw_date->date, "%2.2d/%2.2d/%4.4d",
+			fw_date->month, fw_date->day, fw_date->year);
+
+		fw_version->major =
+			(u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_MAJOR(
+						data1);
+		fw_version->monor =
+			(u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_MINOR(
+						data1);
+		fw_version->build =
+			(u32)VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_FW_VER_BUILD(
+						data1);
+
+		sprintf(fw_version->version, "%d.%d.%d",
+			fw_version->major, fw_version->monor,
+			fw_version->build);
+
+		flash_date->day =
+			(u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_DAY(
+						data2);
+		flash_date->month =
+		(u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_MONTH(data2);
+		flash_date->year =
+		(u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_YEAR(data2);
+
+		sprintf(flash_date->date, "%2.2d/%2.2d/%4.4d",
+			flash_date->month, flash_date->day, flash_date->year);
+
+		flash_version->major =
+		(u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_MAJOR(data2);
+		flash_version->monor =
+		(u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_MINOR(data2);
+		flash_version->build =
+		(u32)VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_FLASH_VER_BUILD(data2);
+
+		sprintf(flash_version->version, "%d.%d.%d",
+			flash_version->major, flash_version->monor,
+			flash_version->build);
+
+		status = VXGE_HW_OK;
+
+	} else
+		status = VXGE_HW_FAIL;
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_pci_func_mode_get - Get the pci mode
+ * @vp_id: Vpath id
+ * @vpath_reg: Pointer to vpath registers
+ *
+ * Returns pci function mode
+ *
+ */
+u64
+__hw_vpath_pci_func_mode_get(
+	u32			  vp_id,
+	struct vxge_hw_vpath_reg	  *vpath_reg)
+{
+	u64 val64;
+	u64 data1 = 0ULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(vpath_reg != NULL);
+
+	writeq(0, &vpath_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	writeq(VXGE_HW_RTS_ACCESS_STEER_DATA0_MEMO_ITEM_PCI_MODE,
+				&vpath_reg->rts_access_steer_data0);
+
+	writeq(0, &vpath_reg->rts_access_steer_data1);
+
+	wmb();
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_MEMO_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_FW_MEMO) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	__hw_pio_mem_write32_lower((u32)bVAL32(val64, 32),
+				&vpath_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+				&vpath_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath_reg->rts_access_steer_ctrl, 0,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+			WAIT_FACTOR * VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+
+		status = VXGE_HW_OK;
+
+	} else {
+
+		data1 = 0;
+
+		status = VXGE_HW_FAIL;
+	}
+exit:
+
+	return data1;
+}
+
+/*
+ * __hw_vpath_rts_table_get - Get the entries from RTS access tables
+ * @vp: Vpath handle.
+ * @action: Identifies the action to take on the specified entry. The
+ *             interpretation of this field depends on the DATA_STRUCT_SEL field
+ *             DA, VID, ETYPE, PN, RANGE_PN:
+ *	       8'd0 - ADD_ENTRY (Add an entry to the table. This command may be
+ *                    rejected by management/administration).
+ *             8'd1 - DELETE_ENTRY (Add an entry to the table. This command may
+ *                    be rejected by management/administration)
+ *             8'd2 - LIST_FIRST_ENTRY
+ *             8'd3 - LIST_NEXT_ENTRY
+ *             RTH_GEN_CFG, RTH_IT, RTH_JHASH_CFG, RTH_MASK, RTH_KEY, QOS, DS:
+ *             8'd0 - READ_ENTRY
+ *	       8'd1 - WRITE_ENTRY
+ *             Note: This field is updated by the H/W during an operation and
+ *             is used to report additional TBD status information back to the
+ *             host.
+ * @rts_table: Identifies the RTS data structure (i.e. lookup table) to access.
+ *             0; DA; Destination Address 1; VID; VLAN ID 2; ETYPE; Ethertype
+ *             3; PN; Layer 4 Port Number 4; Reserved 5; RTH_GEN_CFG; Receive
+ *             Traffic Hashing General Configuration 6; RTH_IT; Receive Traffic
+ *             Hashing Indirection Table 7; RTH_JHASH_CFG; Receive-Traffic
+ *             Hashing Jenkins Hash Configuration 8; RTH_MASK; Receive Traffic
+ *             Hashing Mask 9; RTH_KEY; Receive-Traffic Hashing Key 10; QOS;
+ *             VLAN Quality of Service 11; DS; IP Differentiated Services
+ * @offset: Applies to RTH_IT, RTH_MASK, RTH_KEY, QOS, DS structures only.
+ *             The interpretation of this field depends on the DATA_STRUCT_SEL
+ *             field:
+ *             RTH_IT - {BUCKET_NUM[0:7]} (Bucket Number)
+ *             RTH_MASK - {5'b0,
+ *             INDEX_8BYTE} (8-byte Index)
+ *             RTH_KEY - {5'b0, INDEX_8BYTE} (8-byte Index)
+ *             QOS - {5'b0, PRI} (Priority)
+ *             DS - {5'b0, CP} (Codepoint)
+ * @data1: Pointer to the data 1 to be read from the table
+ * @data2: Pointer to the data 2 to be read from the table
+ *
+ * Read from the RTS table
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_rts_table_get(
+	struct __hw_vpath_handle *vp,
+	u32			action,
+	u32			rts_table,
+	u32			offset,
+	u64			*data1,
+	u64			*data2)
+{
+	u64 val64;
+	struct __hw_virtualpath *vpath;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((vp != NULL) && (data1 != NULL) &&
+			(data2 != NULL));
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	vpath = (struct __hw_virtualpath *)vp->vpath;
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
+	__hw_pio_mem_write32_lower((u32)bVAL32(val64, 32),
+				&vpath->vp_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+				&vpath->vp_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath->vp_reg->rts_access_steer_ctrl, 0,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+			WAIT_FACTOR *
+			vp->vpath->hldev->config.device_poll_millis);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath->vp_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		*data1 = readq(&vpath->vp_reg->rts_access_steer_data0);
+
+		if ((rts_table ==
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) ||
+		(rts_table ==
+		VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT)) {
+			*data2 = readq(&vpath->vp_reg->rts_access_steer_data1);
+		}
+
+		status = VXGE_HW_OK;
+
+	} else
+		status = VXGE_HW_FAIL;
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_rts_table_set - Set the entries of RTS access tables
+ * @vp: Vpath handle.
+ * @action: Identifies the action to take on the specified entry. The
+ *             interpretation of this field depends on the DATA_STRUCT_SEL field
+ *             DA, VID, ETYPE, PN, RANGE_PN:
+ *	       8'd0 - ADD_ENTRY (Add an entry to the table. This command
+ *	       may be rejected by management/administration).
+ *             8'd1 - DELETE_ENTRY (Add an entry to the table. This command may
+ *                    be rejected by management/administration)
+ *             8'd2 - LIST_FIRST_ENTRY
+ *             8'd3 - LIST_NEXT_ENTRY
+ *             RTH_GEN_CFG, RTH_IT, RTH_JHASH_CFG, RTH_MASK, RTH_KEY, QOS, DS:
+ *             8'd0 - READ_ENTRY
+ *	       8'd1 - WRITE_ENTRY
+ *             Note: This field is updated by the H/W during an operation and
+ *             is used to report additional TBD status information back to the
+ *             host.
+ * @rts_table: Identifies the RTS data structure (i.e. lookup table) to access.
+ *             0; DA; Destination Address 1; VID; VLAN ID 2; ETYPE; Ethertype
+ *             3; PN; Layer 4 Port Number 4; Reserved 5; RTH_GEN_CFG; Receive
+ *             Traffic Hashing General Configuration 6; RTH_IT; Receive Traffic
+ *             Hashing Indirection Table 7; RTH_JHASH_CFG; Receive-Traffic
+ *             Hashing Jenkins Hash Configuration 8; RTH_MASK; Receive Traffic
+ *             Hashing Mask 9; RTH_KEY; Receive-Traffic Hashing Key 10; QOS;
+ *             VLAN Quality of Service 11; DS; IP Differentiated Services
+ * @offset: Applies to RTH_IT, RTH_MASK, RTH_KEY, QOS, DS structures only.
+ *             The interpretation of this field depends on the DATA_STRUCT_SEL
+ *             field:
+ *             RTH_IT - {BUCKET_NUM[0:7]} (Bucket Number)
+ *             RTH_MASK - {5'b0,
+ *             INDEX_8BYTE} (8-byte Index)
+ *             RTH_KEY - {5'b0, INDEX_8BYTE} (8-byte Index)
+ *             QOS - {5'b0, PRI} (Priority)
+ *             DS - {5'b0, CP} (Codepoint)
+ * @data1: data 1 to be written to the table
+ * @data2: data 2 to be written to the table
+ *
+ * Read from the RTS table
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_rts_table_set(
+	struct __hw_vpath_handle *vp,
+	u32			action,
+	u32			rts_table,
+	u32			offset,
+	u64			data1,
+	u64			data2)
+{
+	u64 val64;
+	struct __hw_virtualpath *vpath;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(vp != NULL);
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	vpath = (struct __hw_virtualpath *)vp->vpath;
+
+	writeq(data1, &vpath->vp_reg->rts_access_steer_data0);
+	wmb();
+
+	if ((rts_table == VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) ||
+	    (rts_table ==
+		VXGE_HW_RTS_ACS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MULTI_IT)) {
+		writeq(data2, &vpath->vp_reg->rts_access_steer_data1);
+		wmb();
+
+	}
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(action) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(rts_table) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(offset);
+
+	__hw_pio_mem_write32_lower((u32)bVAL32(val64, 32),
+				&vpath->vp_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+				&vpath->vp_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath->vp_reg->rts_access_steer_ctrl, 0,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+			WAIT_FACTOR *
+			vp->vpath->hldev->config.device_poll_millis);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath->vp_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS)
+		status = VXGE_HW_OK;
+	else
+		status = VXGE_HW_FAIL;
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_addr_get - Get the hw address entry for this vpath
+ *               from MAC address table.
+ * @vp_id: Vpath id
+ * @vpath_reg: Pointer to vpath registers
+ * @macaddr: First MAC address entry for this vpath in the list
+ * @macaddr_mask: MAC address mask for macaddr
+ *
+ * Returns the first mac address and mac address mask in the list for this
+ * vpath.
+ * see also: vxge_hw_vpath_mac_addr_get_next
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_addr_get(
+	u32				vp_id,
+	struct vxge_hw_vpath_reg	*vpath_reg,
+	u8 (macaddr)[ETH_ALEN],
+	u8 (macaddr_mask)[ETH_ALEN])
+{
+	u32 i;
+	u64 val64;
+	u64 data1 = 0ULL;
+	u64 data2 = 0ULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((vpath_reg != NULL) && (macaddr != NULL) &&
+		(macaddr_mask != NULL));
+
+	val64 = VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_LIST_FIRST_ENTRY) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL(
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_DA) |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE |
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_OFFSET(0);
+
+	__hw_pio_mem_write32_lower((u32)bVAL32(val64, 32),
+		&vpath_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+		&vpath_reg->rts_access_steer_ctrl);
+
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath_reg->rts_access_steer_ctrl, 0,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_STROBE,
+			WAIT_FACTOR * VXGE_HW_DEF_DEVICE_POLL_MILLIS);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath_reg->rts_access_steer_ctrl);
+
+	if (val64 & VXGE_HW_RTS_ACCESS_STEER_CTRL_RMACJ_STATUS) {
+
+		data1 = readq(&vpath_reg->rts_access_steer_data0);
+
+		data2 = readq(&vpath_reg->rts_access_steer_data1);
+
+		data1 = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_DA_MAC_ADDR(data1);
+
+		data2 = VXGE_HW_RTS_ACCESS_STEER_DATA1_GET_DA_MAC_ADDR_MASK(
+							data2);
+
+		for (i = ETH_ALEN; i > 0; i--) {
+			macaddr[i-1] = (u8)(data1 & 0xFF);
+			data1 >>= 8;
+		}
+
+		for (i = ETH_ALEN; i > 0; i--) {
+			macaddr_mask[i-1] = (u8)(data2 & 0xFF);
+			data2 >>= 8;
+		}
+
+		status = VXGE_HW_OK;
+
+	} else
+		status = VXGE_HW_FAIL;
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_rts_rth_set - Set/configure RTS hashing.
+ * @vp: Virtual Path handle.
+ * @algorithm: Algorithm Select
+ * @hash_type: Hash Type
+ * @bucket_size: no of least significant bits to be used for hashing.
+ *
+ * Used to set/configure all RTS hashing related stuff.
+ *
+ * See also: vxge_hw_vpath_rts_rth_itable_set().
+ */
+enum vxge_hw_status vxge_hw_vpath_rts_rth_set(
+			struct __hw_vpath_handle *vp,
+			enum vxge_hw_rth_algoritms algorithm,
+			struct vxge_hw_rth_hash_types *hash_type,
+			u16 bucket_size)
+{
+	u64 data0, data1;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((vp != NULL) && (hash_type != NULL));
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	status = __hw_vpath_rts_table_get(vp,
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
+		data0 |=
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_TCP_IPV4_EN;
+
+	if (hash_type->hash_type_ipv4_en)
+		data0 |= VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_IPV4_EN;
+
+	if (hash_type->hash_type_tcpipv6_en)
+		data0 |=
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_GEN_RTH_TCP_IPV6_EN;
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
+	status = __hw_vpath_rts_table_set(vp,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_WRITE_ENTRY,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_GEN_CFG,
+		0, data0, 0);
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_rts_rth_jhash_cfg_set - Configure JHASH algorithm
+ *
+ * @vp: Virtual Path ahandle.
+ * @golden_ratio: Golden ratio
+ * @init_value: Initial value
+ * This function configures JENKIN's HASH algorithm
+ *
+ * See also: vxge_hw_vpath_rts_rth_set().
+ */
+enum vxge_hw_status  vxge_hw_vpath_rts_rth_jhash_cfg_set(
+	struct __hw_vpath_handle *vp,
+	u32 golden_ratio,
+	u32 init_value)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(vp != NULL);
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	status = __hw_vpath_rts_table_set(vp,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_WRITE_ENTRY,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_JHASH_CFG,
+		0,
+		VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_JHASH_CFG_GOLDEN_RATIO(
+		golden_ratio) |
+		VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_JHASH_CFG_INIT_VALUE(\
+		init_value), 0);
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_rts_rth_jhash_cfg_get - Read JHASH algorithm
+ *
+ * @vp: Virtual Path ahandle.
+ * @golden_ratio: Buffer to return Golden ratio
+ * @init_value: Buffer to return Initial value
+ * This function reads JENKIN's HASH algorithm
+ *
+ * See also: vxge_hw_vpath_rts_rth_set(), vxge_hw_vpath_rts_rth_jhash_cfg_set()
+ */
+enum vxge_hw_status  vxge_hw_vpath_rts_rth_jhash_cfg_get(
+			struct __hw_vpath_handle *vp,
+			u32 *golden_ratio,
+			u32 *init_value)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(vp != NULL);
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	status = __hw_vpath_rts_table_get(vp,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_READ_ENTRY,
+		VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_JHASH_CFG,
+		0, &val64, NULL);
+
+	if (status == VXGE_HW_OK) {
+		*golden_ratio =
+		(u32)
+		VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_RTH_JHASH_CFG_GOLDEN_RATIO(
+				val64);
+		*init_value =
+		(u32)
+		VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_RTH_JHASH_CFG_INIT_VALUE(
+				val64);
+	}
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_rts_rth_mask_set - Set/configure JHASH mask.
+ * @vp: Virtual Path ahandle.
+ * @table_size: Size of the mask table
+ * @hash_mask_ipv6sa: IPv6SA Hash Mask
+ * @hash_mask_ipv6da: IPv6DA Hash Mask
+ * @hash_mask_ipv4sa: IPv4SA Hash Mask
+ * @hash_mask_ipv4da: IPv4DA Hash Mask
+ * @hash_mask_l4sp: L4SP Hash Mask
+ * @hash_mask_l4dp: L4DP Hash Mask
+ *
+ * Used to set/configure indirection table.
+ * It enables the required no of entries in the IT.
+ * It adds entries to the IT.
+ *
+ * See also: vxge_hw_vpath_rts_rth_set()
+ */
+enum vxge_hw_status vxge_hw_vpath_rts_rth_mask_set(
+			struct __hw_vpath_handle *vp,
+			u32 table_size,
+			u32 *hash_mask_ipv6sa,
+			u32 *hash_mask_ipv6da,
+			u32 *hash_mask_ipv4sa,
+			u32 *hash_mask_ipv4da,
+			u32 *hash_mask_l4sp,
+			u32 *hash_mask_l4dp)
+{
+	u32 i;
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	vxge_assert((vp != NULL) && (hash_mask_ipv6sa != NULL) &&
+		(hash_mask_ipv6da != NULL) && (hash_mask_ipv4sa != NULL) &&
+		(hash_mask_ipv4da != NULL) && (hash_mask_l4sp != NULL) &&
+		(hash_mask_l4dp != NULL));
+
+	for (i = 0; i < table_size; i++) {
+
+		val64 = VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_MASK_IPV6_SA_MASK(
+				*hash_mask_ipv6sa++) |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_MASK_IPV6_DA_MASK(
+				*hash_mask_ipv6da++) |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_MASK_IPV4_SA_MASK(
+				*hash_mask_ipv4sa++) |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_MASK_IPV4_DA_MASK(
+				*hash_mask_ipv4da++) |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_MASK_L4SP_MASK(
+				*hash_mask_l4sp++) |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_MASK_L4DP_MASK(
+				*hash_mask_l4dp++);
+
+		status = __hw_vpath_rts_table_set(vp,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_WRITE_ENTRY,
+			VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_RTH_MASK,
+			i, val64, 0);
+
+		if (status != VXGE_HW_OK)
+			break;
+	}
+exit:
+
+	return status;
+}
+
+void
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
+/**
+ * vxge_hw_vpath_rts_rth_itable_set - Set/configure indirection table (IT).
+ * @vpath_handles: Virtual Path handles.
+ * @vpath_count: Number of vpath handles passed in vpath_handles
+ * @mtable: Pointer to cpu to vpath mapping table
+ * @itable: Pointer to indirection table
+ * @itable_size: no of least significant bits to be used for hashing
+ *
+ * Used to set/configure indirection table.
+ * It enables the required no of entries in the IT.
+ * It adds entries to the IT.
+ *
+ */
+enum vxge_hw_status vxge_hw_vpath_rts_rth_itable_set(
+			struct __hw_vpath_handle **vpath_handles,
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
+	struct __hw_vpath_handle *vp =
+		(struct __hw_vpath_handle *)vpath_handles[0];
+
+	vxge_assert((vpath_handles != NULL) && (mtable != NULL) &&
+			(itable != NULL));
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
+			data0 = 0;
+			data1 = 0;
+
+			data0 =
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_SOLO_IT_BUCKET_DATA(\
+			itable[j]);
+
+			status = __hw_vpath_rts_table_set(vpath_handles[0],
+			action, rts_table, j, data0, data1);
+
+			if (status != VXGE_HW_OK)
+				goto exit;
+
+		}
+
+		for (j = 0; j < max_entries; j++) {
+
+			data0 = 0;
+			data1 = 0;
+
+			data0 =
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_SOLO_IT_ENTRY_EN |
+			VXGE_HW_RTS_ACCESS_STEER_DATA0_RTH_SOLO_IT_BUCKET_DATA(\
+			itable[j]);
+
+			status = __hw_vpath_rts_table_set(
+			vpath_handles[mtable[itable[j]]], action, rts_table,
+			j, data0, data1);
+
+			if (status != VXGE_HW_OK)
+				goto exit;
+
+		}
+
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
+
+					status = __hw_vpath_rts_table_set(
+							vpath_handles[i],
+							action, rts_table,
+							0, data0, data1);
+
+					if (status != VXGE_HW_OK) {
+#if (VXGE_COMPONENT_HW_VPATH & VXGE_DEBUG_MODULE_MASK)
+						struct __hw_vpath_handle *vp =
+						(struct __hw_vpath_handle *)
+						vpath_handles[i];
+#endif
+						goto exit;
+					}
+
+				}
+			}
+		}
+	}
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_mgmt_read
+ * @hldev: HW device
+ * @vpath: Virtual path structure
+ *
+ * This routine reads the vpath_mgmt registers
+ */
+enum vxge_hw_status
+__hw_vpath_mgmt_read(
+	struct __hw_device *hldev,
+	struct __hw_virtualpath *vpath)
+{
+	u32 i, mtu, max_pyld = 0;
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((hldev != NULL) && (vpath != NULL));
+
+	val64 = readq(&vpath->vpmgmt_reg->vpath_is_first);
+
+	vpath->is_first_vpath =
+		(u32)VXGE_HW_VPATH_IS_FIRST_GET_VPATH_IS_FIRST(val64);
+
+	val64 = readq(&vpath->vpmgmt_reg->tim_vpath_assignment);
+
+	vpath->bmap_root_assigned =
+		(u32)VXGE_HW_TIM_VPATH_ASSIGNMENT_GET_BMAP_ROOT(val64);
+
+	mtu = 0;
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
+	vpath->max_mtu = mtu  +  VXGE_HW_MAC_HEADER_MAX_SIZE;
+
+	val64 = readq(&vpath->vpmgmt_reg->xmac_vsport_choices_vp);
+
+	vpath->vsport_choices =
+		(u32)VXGE_HW_XMAC_VSPORT_CHOICES_VP_GET_VSPORT_VECTOR(val64);
+
+	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+
+		if (val64 & vxge_mBIT(i))
+			vpath->vsport_number = i;
+
+	}
+
+	val64 = readq(&vpath->vpmgmt_reg->
+				xgmac_gen_status_vpmgmt_clone);
+
+	if (val64 & VXGE_HW_XGMAC_GEN_STATUS_VPMGMT_CLONE_XMACJ_NTWK_OK) {
+		VXGE_HW_DEVICE_LINK_STATE_SET(vpath->hldev,
+					VXGE_HW_LINK_UP);
+	} else
+		VXGE_HW_DEVICE_LINK_STATE_SET(vpath->hldev, VXGE_HW_LINK_DOWN);
+
+	if (val64 &
+		VXGE_HW_XGMAC_GEN_STATUS_VPMGMT_CLONE_XMACJ_NTWK_DATA_RATE) {
+		VXGE_HW_DEVICE_DATA_RATE_SET(vpath->hldev,
+			VXGE_HW_DATA_RATE_10G);
+	} else {
+		VXGE_HW_DEVICE_DATA_RATE_SET(vpath->hldev,
+			VXGE_HW_DATA_RATE_1G);
+	}
+
+	return status;
+}
+
+/*
+ * __hw_vpath_reset_check - Check if resetting the vpath completed
+ *
+ * @vpath: Virtual Path
+ *
+ * This routine checks the vpath_rst_in_prog register to see if
+ * adapter completed the reset process for the vpath
+ */
+enum vxge_hw_status
+__hw_vpath_reset_check(
+	struct __hw_virtualpath *vpath)
+{
+	enum vxge_hw_status status;
+
+	vxge_assert(vpath != NULL);
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath->hldev->common_reg->vpath_rst_in_prog,
+			0,
+			VXGE_HW_VPATH_RST_IN_PROG_VPATH_RST_IN_PROG(
+			1 << (16 - vpath->vp_id)),
+			WAIT_FACTOR * vpath->hldev->config.device_poll_millis);
+
+	return status;
+}
+
+/*
+ * __hw_vpath_reset
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine resets the vpath on the device
+ */
+enum vxge_hw_status
+__hw_vpath_reset(
+		struct __hw_device *hldev,
+		u32 vp_id)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	val64 = VXGE_HW_CMN_RSTHDLR_CFG0_SW_RESET_VPATH(1 << (16 - vp_id));
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+				&hldev->common_reg->cmn_rsthdlr_cfg0);
+
+	return status;
+}
+
+/*
+ * __hw_vpath_sw_reset
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine resets the vpath structures
+ */
+enum vxge_hw_status
+__hw_vpath_sw_reset(
+		struct __hw_device *hldev,
+		u32 vp_id)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	if (vpath->ringh) {
+
+		status = __hw_ring_reset(vpath->ringh);
+
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+
+	if (vpath->fifoh)
+		status = __hw_fifo_reset(vpath->fifoh);
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_prc_configure
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine configures the prc registers of virtual path using the config
+ * passed
+ */
+void
+__hw_vpath_prc_configure(
+		struct __hw_device *hldev,
+		u32 vp_id)
+{
+	u64 val64;
+	struct __hw_virtualpath *vpath;
+	struct vxge_hw_vp_config *vp_config;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	vp_config = vpath->vp_config;
+
+	if (vp_config->ring.enable == VXGE_HW_RING_DISABLE)
+		return;
+
+	val64 = readq(&vpath->vp_reg->prc_cfg1);
+
+	val64 |= VXGE_HW_PRC_CFG1_RTI_TINT_DISABLE;
+
+	writeq(val64, &vpath->vp_reg->prc_cfg1);
+
+	val64 = readq(&vpath->vp_reg->prc_cfg7);
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
+	writeq(val64, &vpath->vp_reg->prc_cfg7);
+
+	writeq(VXGE_HW_PRC_CFG5_RXD0_ADD(
+				__hw_ring_first_block_address_get(
+					vpath->ringh) >> 3),
+					&vpath->vp_reg->prc_cfg5);
+
+	val64 = readq(&vpath->vp_reg->prc_cfg4);
+
+	val64 |= VXGE_HW_PRC_CFG4_IN_SVC;
+
+	val64 &= ~VXGE_HW_PRC_CFG4_RING_MODE(0x3);
+
+	if (vp_config->ring.buffer_mode == VXGE_HW_RING_RXD_BUFFER_MODE_1) {
+		val64 |= VXGE_HW_PRC_CFG4_RING_MODE(
+				VXGE_HW_PRC_CFG4_RING_MODE_ONE_BUFFER);
+	} else {
+		if (vp_config->ring.buffer_mode ==
+				VXGE_HW_RING_RXD_BUFFER_MODE_3) {
+			val64 |= VXGE_HW_PRC_CFG4_RING_MODE(
+				VXGE_HW_PRC_CFG4_RING_MODE_THREE_BUFFER);
+		} else {
+			val64 |= VXGE_HW_PRC_CFG4_RING_MODE(
+				VXGE_HW_PRC_CFG4_RING_MODE_FIVE_BUFFER);
+		}
+	}
+
+	if (hldev->config.rth_en == VXGE_HW_RTH_DISABLE)
+		val64 |= VXGE_HW_PRC_CFG4_RTH_DISABLE;
+	else
+		val64 &= ~VXGE_HW_PRC_CFG4_RTH_DISABLE;
+
+	val64 |= VXGE_HW_PRC_CFG4_SIGNAL_BENIGN_OVFLW;
+
+	val64 |= VXGE_HW_PRC_CFG4_BIMODAL_INTERRUPT;
+
+	writeq(val64, &vpath->vp_reg->prc_cfg4);
+	return;
+}
+
+/*
+ * __hw_vpath_kdfc_configure
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine configures the kdfc registers of virtual path using the
+ * config passed
+ */
+enum vxge_hw_status
+__hw_vpath_kdfc_configure(
+		struct __hw_device *hldev,
+		u32 vp_id)
+{
+	u64 val64;
+	u64 vpath_stride;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	status = __hw_kdfc_swapper_set(hldev->legacy_reg, vpath->vp_reg);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	val64 = readq(&vpath->vp_reg->kdfc_drbl_triplet_total);
+
+	vpath->max_kdfc_db =
+		(u32)VXGE_HW_KDFC_DRBL_TRIPLET_TOTAL_GET_KDFC_MAX_SIZE(
+			val64+1)/2;
+
+	vpath->max_ofl_db = 0;
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
+	writeq(val64, &vpath->vp_reg->kdfc_fifo_trpl_partition);
+
+	writeq(VXGE_HW_KDFC_FIFO_TRPL_CTRL_TRIPLET_ENABLE,
+		&vpath->vp_reg->kdfc_fifo_trpl_ctrl);
+
+	val64 = readq(&vpath->vp_reg->kdfc_trpl_fifo_0_ctrl);
+
+	val64 &= ~(VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_MODE(0x3) |
+		   VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_SELECT(0xFF));
+
+	val64 |= VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_MODE(
+		 VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_MODE_NON_OFFLOAD_ONLY) |
+#if !defined(VXGE_OS_HOST_BIG_ENDIAN)
+		 VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_SWAP_EN |
+#endif
+		 VXGE_HW_KDFC_TRPL_FIFO_0_CTRL_SELECT(0);
+
+	writeq(val64, &vpath->vp_reg->kdfc_trpl_fifo_0_ctrl);
+	writeq((u64)0, &vpath->vp_reg->kdfc_trpl_fifo_0_wb_address);
+
+	wmb();
+
+	vpath_stride = readq(&hldev->toc_reg->toc_kdfc_vpath_stride);
+
+	vpath->nofl_db = (struct __hw_non_offload_db_wrapper *)(hldev->kdfc  +
+		(vp_id *
+		VXGE_HW_TOC_KDFC_VPATH_STRIDE_GET_TOC_KDFC_VPATH_STRIDE(
+					vpath_stride)));
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_mac_configure
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine configures the mac of virtual path using the config passed
+ */
+enum vxge_hw_status
+__hw_vpath_mac_configure(
+		struct __hw_device *hldev,
+		u32 vp_id)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_virtualpath *vpath;
+	struct vxge_hw_vp_config *vp_config;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	vp_config = vpath->vp_config;
+
+	writeq(VXGE_HW_XMAC_VSPORT_CHOICE_VSPORT_NUMBER(
+			vpath->vsport_number),
+			&vpath->vp_reg->xmac_vsport_choice);
+
+	if (vp_config->ring.enable == VXGE_HW_RING_ENABLE) {
+
+		val64 = readq(&vpath->vp_reg->xmac_rpa_vcfg);
+
+		if (vp_config->rpa_strip_vlan_tag !=
+			VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT) {
+			if (vp_config->rpa_strip_vlan_tag)
+				val64 |= VXGE_HW_XMAC_RPA_VCFG_STRIP_VLAN_TAG;
+			else
+				val64 &= ~VXGE_HW_XMAC_RPA_VCFG_STRIP_VLAN_TAG;
+		}
+
+		writeq(val64, &vpath->vp_reg->xmac_rpa_vcfg);
+
+		val64 = readq(&vpath->vp_reg->rxmac_vcfg0);
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
+		writeq(val64, &vpath->vp_reg->rxmac_vcfg0);
+
+		val64 = readq(&vpath->vp_reg->rxmac_vcfg1);
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
+		writeq(val64, &vpath->vp_reg->rxmac_vcfg1);
+
+	}
+
+	return status;
+}
+
+/*
+ * __hw_vpath_tim_configure
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine configures the tim registers of virtual path using the config
+ * passed
+ */
+enum vxge_hw_status
+__hw_vpath_tim_configure(struct __hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	writeq((u64)0, &vpath->vp_reg->tim_dest_addr);
+
+	writeq((u64)0, &vpath->vp_reg->tim_vpath_map);
+
+	writeq((u64)0, &vpath->vp_reg->tim_bitmap);
+
+	writeq((u64)0, &vpath->vp_reg->tim_remap);
+
+	if (vpath->vp_config->ring.enable == VXGE_HW_RING_ENABLE)
+		writeq(VXGE_HW_TIM_RING_ASSN_INT_NUM(
+			(vp_id * VXGE_HW_MAX_INTR_PER_VP)  +
+			VXGE_HW_VPATH_INTR_RX),
+			&vpath->vp_reg->tim_ring_assn);
+
+	val64 = readq(&vpath->vp_reg->tim_pci_cfg);
+
+	val64 |= VXGE_HW_TIM_PCI_CFG_ADD_PAD;
+
+	writeq(val64, &vpath->vp_reg->tim_pci_cfg);
+
+	if (vpath->vp_config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
+
+		val64 = readq(&vpath->vp_reg->tim_cfg1_int_num[
+						VXGE_HW_VPATH_INTR_TX]);
+
+		if (vpath->vp_config->tti.btimer_val !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_BTIMER_VAL) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+				0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+					vpath->vp_config->tti.btimer_val);
+		}
+
+		val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BITMP_EN;
+
+		if (vpath->vp_config->tti.timer_ac_en !=
+			VXGE_HW_TIM_TIMER_AC_USE_FLASH_DEFAULT) {
+			if (vpath->vp_config->tti.timer_ac_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+		}
+
+		if (vpath->vp_config->tti.timer_ci_en !=
+			VXGE_HW_TIM_TIMER_CI_USE_FLASH_DEFAULT) {
+			if (vpath->vp_config->tti.timer_ci_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+		}
+
+		if (vpath->vp_config->tti.urange_a !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_A) {
+			val64 &=  ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(0x3f);
+			val64 |=  VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(
+					vpath->vp_config->tti.urange_a);
+		}
+
+		if (vpath->vp_config->tti.urange_b !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_B) {
+			val64 &=  ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(0x3f);
+			val64 |=  VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(
+					vpath->vp_config->tti.urange_b);
+		}
+
+		if (vpath->vp_config->tti.urange_c !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_C) {
+			val64 &=  ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(0x3f);
+			val64 |=  VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(
+					vpath->vp_config->tti.urange_c);
+		}
+
+		writeq(val64, &vpath->vp_reg->tim_cfg1_int_num[
+						VXGE_HW_VPATH_INTR_TX]);
+
+		val64 = readq(&vpath->vp_reg->tim_cfg2_int_num[
+					VXGE_HW_VPATH_INTR_TX]);
+
+		if (vpath->vp_config->tti.uec_a !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_A) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(
+						vpath->vp_config->tti.uec_a);
+		}
+
+		if (vpath->vp_config->tti.uec_b !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_B) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(
+						vpath->vp_config->tti.uec_b);
+		}
+
+		if (vpath->vp_config->tti.uec_c !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_C) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(
+						vpath->vp_config->tti.uec_c);
+		}
+
+		if (vpath->vp_config->tti.uec_d !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_D) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(
+						vpath->vp_config->tti.uec_d);
+		}
+
+		writeq(val64, &vpath->vp_reg->tim_cfg2_int_num[
+					VXGE_HW_VPATH_INTR_TX]);
+
+		val64 = readq(&vpath->vp_reg->tim_cfg3_int_num[
+					VXGE_HW_VPATH_INTR_TX]);
+
+		if (vpath->vp_config->tti.timer_ri_en !=
+			VXGE_HW_TIM_TIMER_RI_USE_FLASH_DEFAULT) {
+			if (vpath->vp_config->tti.timer_ri_en)
+				val64 |= VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+		}
+
+		if (vpath->vp_config->tti.rtimer_val !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_RTIMER_VAL) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					vpath->vp_config->tti.rtimer_val);
+		}
+
+		if (vpath->vp_config->tti.util_sel !=
+			VXGE_HW_TIM_UTIL_SEL_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(0x3f);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(
+					vpath->vp_config->tti.util_sel);
+		}
+
+		if (vpath->vp_config->tti.ltimer_val !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_LTIMER_VAL) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					vpath->vp_config->tti.ltimer_val);
+		}
+
+		writeq(val64, &vpath->vp_reg->tim_cfg3_int_num[
+					VXGE_HW_VPATH_INTR_TX]);
+
+	}
+
+	if (vpath->vp_config->ring.enable == VXGE_HW_RING_ENABLE) {
+
+		val64 = readq(&vpath->vp_reg->tim_cfg1_int_num[
+					VXGE_HW_VPATH_INTR_RX]);
+
+		if (vpath->vp_config->rti.btimer_val !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_BTIMER_VAL) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_BTIMER_VAL(
+					vpath->vp_config->rti.btimer_val);
+		}
+
+		val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_BITMP_EN;
+
+		if (vpath->vp_config->rti.timer_ac_en !=
+			VXGE_HW_TIM_TIMER_AC_USE_FLASH_DEFAULT) {
+			if (vpath->vp_config->rti.timer_ac_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_AC;
+		}
+
+		if (vpath->vp_config->rti.timer_ci_en !=
+			VXGE_HW_TIM_TIMER_CI_USE_FLASH_DEFAULT) {
+			if (vpath->vp_config->rti.timer_ci_en)
+				val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+		}
+
+		if (vpath->vp_config->rti.urange_a !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_A) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_A(
+					vpath->vp_config->rti.urange_a);
+		}
+
+		if (vpath->vp_config->rti.urange_b !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_B) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_B(
+					vpath->vp_config->rti.urange_b);
+		}
+
+		if (vpath->vp_config->rti.urange_c !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_URANGE_C) {
+			val64 &= ~VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(0x3f);
+			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_URNG_C(
+					vpath->vp_config->rti.urange_c);
+		}
+
+		writeq(val64, &vpath->vp_reg->tim_cfg1_int_num[
+					VXGE_HW_VPATH_INTR_RX]);
+
+		val64 = readq(&vpath->vp_reg->tim_cfg2_int_num[
+					VXGE_HW_VPATH_INTR_RX]);
+
+		if (vpath->vp_config->rti.uec_a !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_A) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_A(
+						vpath->vp_config->rti.uec_a);
+		}
+
+		if (vpath->vp_config->rti.uec_b !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_B) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_B(
+						vpath->vp_config->rti.uec_b);
+		}
+
+		if (vpath->vp_config->rti.uec_c !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_C) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_C(
+						vpath->vp_config->rti.uec_c);
+		}
+
+		if (vpath->vp_config->rti.uec_d !=
+				VXGE_HW_USE_FLASH_DEFAULT_TIM_UEC_D) {
+			val64 &= ~VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(0xffff);
+			val64 |= VXGE_HW_TIM_CFG2_INT_NUM_UEC_D(
+						vpath->vp_config->rti.uec_d);
+		}
+
+		writeq(val64, &vpath->vp_reg->tim_cfg2_int_num[
+					VXGE_HW_VPATH_INTR_RX]);
+
+		val64 = readq(&vpath->vp_reg->tim_cfg3_int_num[
+					VXGE_HW_VPATH_INTR_RX]);
+
+		if (vpath->vp_config->rti.timer_ri_en !=
+			VXGE_HW_TIM_TIMER_RI_USE_FLASH_DEFAULT) {
+			if (vpath->vp_config->rti.timer_ri_en)
+				val64 |= VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+			else
+				val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_TIMER_RI;
+		}
+
+		if (vpath->vp_config->rti.rtimer_val !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_RTIMER_VAL) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_RTIMER_VAL(
+					vpath->vp_config->rti.rtimer_val);
+		}
+
+		if (vpath->vp_config->rti.util_sel !=
+			VXGE_HW_TIM_UTIL_SEL_USE_FLASH_DEFAULT) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(0x3f);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_UTIL_SEL(
+					vpath->vp_config->rti.util_sel);
+		}
+
+		if (vpath->vp_config->rti.ltimer_val !=
+			VXGE_HW_USE_FLASH_DEFAULT_TIM_LTIMER_VAL) {
+			val64 &= ~VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					0x3ffffff);
+			val64 |= VXGE_HW_TIM_CFG3_INT_NUM_LTIMER_VAL(
+					vpath->vp_config->rti.ltimer_val);
+		}
+
+		writeq(val64, &vpath->vp_reg->tim_cfg3_int_num[
+					VXGE_HW_VPATH_INTR_RX]);
+
+	}
+
+	val64 = 0;
+
+	writeq(val64, &vpath->vp_reg->tim_cfg1_int_num[
+						VXGE_HW_VPATH_INTR_EINTA]);
+
+	writeq((u64)0, &vpath->vp_reg->tim_cfg2_int_num[
+						VXGE_HW_VPATH_INTR_EINTA]);
+
+	writeq((u64)0, &vpath->vp_reg->tim_cfg3_int_num[
+						VXGE_HW_VPATH_INTR_EINTA]);
+
+	writeq((u64)0, &vpath->vp_reg->tim_cfg1_int_num[
+						VXGE_HW_VPATH_INTR_BMAP]);
+
+	writeq((u64)0, &vpath->vp_reg->tim_cfg2_int_num[
+						VXGE_HW_VPATH_INTR_BMAP]);
+
+	writeq((u64)0, &vpath->vp_reg->tim_cfg3_int_num[
+						VXGE_HW_VPATH_INTR_BMAP]);
+
+	return status;
+}
+
+/*
+ * __hw_vpath_initialize
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine is the final phase of init which initializes the
+ * registers of the vpath using the configuration passed.
+ */
+enum vxge_hw_status
+__hw_vpath_initialize(struct __hw_device *hldev, u32 vp_id)
+{
+	u64 val64;
+	u32 val32;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	if (!(hldev->vpath_assignments & vxge_mBIT(vp_id))) {
+		status = VXGE_HW_ERR_VPATH_NOT_AVAILABLE;
+		goto exit;
+	}
+
+	status =  __hw_vpath_swapper_set(vpath->vp_reg);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status =  __hw_vpath_mac_configure(hldev, vp_id);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status =  __hw_vpath_kdfc_configure(hldev, vp_id);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __hw_vpath_tim_configure(hldev, vp_id);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	writeq(0, &vpath->vp_reg->gendma_int);
+
+	val64 = readq(&vpath->vp_reg->rtdma_rd_optimization_ctrl);
+
+	/* Get MRRS value from device control */
+	status  = __hw_vpath_pci_read(vpath, 1, 0x78, &val32);
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
+	writeq(val64, &vpath->vp_reg->rtdma_rd_optimization_ctrl);
+
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vp_initialize - Initialize Virtual Path structure
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ * @config: Configuration for the virtual path
+ *
+ * This routine is the initial phase of init which resets the vpath and
+ * initializes the software support structures.
+ */
+enum vxge_hw_status
+__hw_vp_initialize(struct __hw_device *hldev, u32 vp_id,
+			struct vxge_hw_vp_config *config)
+{
+	struct __hw_virtualpath *vpath;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((hldev != NULL) && (config != NULL));
+
+	if (!(hldev->vpath_assignments & vxge_mBIT(vp_id))) {
+		status = VXGE_HW_ERR_VPATH_NOT_AVAILABLE;
+		goto exit;
+	}
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	vpath->vp_id = vp_id;
+
+	vpath->vp_open = VXGE_HW_VP_OPEN;
+
+	vpath->hldev = (struct __hw_device *)hldev;
+
+	vpath->vp_config = config;
+
+	vpath->vp_reg = hldev->vpath_reg[vp_id];
+
+	vpath->vpmgmt_reg = hldev->vpmgmt_reg[vp_id];
+
+	__hw_vpath_reset(hldev, vp_id);
+
+	status = __hw_vpath_reset_check(vpath);
+
+	if (status != VXGE_HW_OK) {
+		memset(vpath, 0, sizeof(struct __hw_virtualpath));
+		goto exit;
+	}
+
+	status = __hw_vpath_mgmt_read(hldev, vpath);
+
+	if (status != VXGE_HW_OK) {
+		memset(vpath, 0, sizeof(struct __hw_virtualpath));
+		goto exit;
+	}
+
+	vxge_list_init(&vpath->vpath_handles);
+
+	vpath->sw_stats = &hldev->stats.sw_dev_info_stats.vpath_info[vp_id];
+
+	VXGE_HW_DEVICE_TIM_INT_MASK_SET(vpath->hldev->tim_int_mask0,
+		vpath->hldev->tim_int_mask1,
+		vpath->vp_id);
+
+	status = __hw_vpath_initialize(vpath->hldev, vpath->vp_id);
+
+	if (status != VXGE_HW_OK)
+		__hw_vp_terminate(hldev, vp_id);
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vp_terminate - Terminate Virtual Path structure
+ * @hldev: Handle to the device object
+ * @vp_id: Virtual Path Id
+ *
+ * This routine closes all channels it opened and freeup memory
+ */
+void
+__hw_vp_terminate(struct __hw_device *hldev, u32 vp_id)
+{
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(hldev != NULL);
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[vp_id];
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN)
+		goto exit;
+
+	VXGE_HW_DEVICE_TIM_INT_MASK_RESET(vpath->hldev->tim_int_mask0,
+		vpath->hldev->tim_int_mask1,
+		vpath->vp_id);
+	hldev->stats.hw_dev_info_stats.vpath_info[vpath->vp_id] = NULL;
+
+	memset(vpath, 0, sizeof(struct __hw_virtualpath));
+exit:
+
+	return;
+}
+
+/**
+ * vxge_hw_vpath_mtu_set - Set MTU.
+ * @vp: Virtal path handle
+ * @new_mtu: New MTU size to configure.
+ *
+ * Set new MTU value. Example, to use jumbo frames:
+ * vxge_hw_vpath_mtu_set(my_device, 9600);
+ *
+ */
+enum vxge_hw_status vxge_hw_vpath_mtu_set(
+			struct __hw_vpath_handle *vp,
+			u32 new_mtu)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_ring *ring;
+
+	vxge_assert(vp != NULL);
+
+	if (vp == NULL) {
+		status = VXGE_HW_ERR_INVALID_HANDLE;
+		goto exit;
+	}
+
+	new_mtu += VXGE_HW_MAC_HEADER_MAX_SIZE;
+
+	if ((new_mtu < VXGE_HW_MIN_MTU) || (new_mtu > vp->vpath->max_mtu))
+		status = VXGE_HW_ERR_INVALID_MTU_SIZE;
+
+	val64 = readq(&vp->vpath->vp_reg->rxmac_vcfg0);
+
+	val64 &= ~VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(0x3fff);
+	val64 |= VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(new_mtu);
+
+	writeq(val64, &vp->vpath->vp_reg->rxmac_vcfg0);
+
+	vp->vpath->vp_config->mtu = new_mtu - VXGE_HW_MAC_HEADER_MAX_SIZE;
+
+	ring = (struct __hw_ring *)vp->vpath->ringh;
+	if (ring) { /* Did user configured this ring? */
+
+		if (vp->vpath->vp_config->mtu > VXGE_HW_DEFAULT_MTU)
+			ring->indicate_max_pkts =
+				vp->vpath->vp_config->ring.indicate_max_pkts;
+		else
+			ring->indicate_max_pkts =
+				vp->vpath->vp_config->
+				ring.indicate_max_pkts * 3;
+
+		if (ring->indicate_max_pkts >
+			VXGE_HW_MAX_RING_INDICATE_MAX_PKTS)
+			ring->indicate_max_pkts =
+				VXGE_HW_MAX_RING_INDICATE_MAX_PKTS;
+	}
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_open - Open a virtual path on a given adapter
+ * @hldev: handle to device object
+ * @attr: Virtual path attributes
+ * @client_handle: handle to be returned in the callback
+ * @vpath_handle: Buffer to return a handle to the vpath
+ *
+ * This function is used to open access to virtual path of an
+ * adapter for offload, LRO and SPDM operations. This function returns
+ * synchronously.
+ */
+enum vxge_hw_status vxge_hw_vpath_open(
+	struct __hw_device *hldev,
+	struct vxge_hw_vpath_attr *attr,
+	void *client_handle,
+	struct __hw_vpath_handle **vpath_handle)
+{
+	struct __hw_virtualpath *vpath;
+	struct __hw_vpath_handle *vp;
+	enum vxge_hw_status status;
+
+	vxge_assert((hldev != NULL) && (attr != NULL) &&
+		(vpath_handle != NULL));
+
+	vpath = (struct __hw_virtualpath *)&hldev->virtual_paths[attr->vp_id];
+
+	if (vpath->vp_open == VXGE_HW_VP_OPEN) {
+		status = VXGE_HW_ERR_INVALID_STATE;
+		goto vpath_open_exit1;
+	}
+
+	status = __hw_vp_initialize(hldev, attr->vp_id,
+			&hldev->config.vp_config[attr->vp_id]);
+
+	if (status != VXGE_HW_OK)
+		goto vpath_open_exit1;
+
+	vp = (struct __hw_vpath_handle *)\
+		vmalloc(sizeof(struct __hw_vpath_handle));
+
+	if (vp == NULL) {
+
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+
+		goto vpath_open_exit2;
+
+	}
+
+	memset(vp, 0, sizeof(struct __hw_vpath_handle));
+
+	vp->vpath = vpath;
+	vp->client_handle = client_handle;
+	if (vpath->vp_config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
+
+		status = __hw_fifo_create(vp, &attr->fifo_attr);
+
+		if (status != VXGE_HW_OK)
+			goto vpath_open_exit6;
+	}
+
+	if (vpath->vp_config->ring.enable == VXGE_HW_RING_ENABLE) {
+
+		status = __hw_ring_create(vp, &attr->ring_attr);
+
+		if (status != VXGE_HW_OK)
+			goto vpath_open_exit7;
+
+		__hw_vpath_prc_configure(hldev, attr->vp_id);
+
+	}
+	((struct __hw_fifo *)vpath->fifoh)->tx_intr_num =
+		(attr->vp_id * VXGE_HW_MAX_INTR_PER_VP)  +
+			VXGE_HW_VPATH_INTR_TX;
+
+	((struct __hw_ring *)vpath->ringh)->rx_intr_num =
+		(attr->vp_id * VXGE_HW_MAX_INTR_PER_VP)  +
+			VXGE_HW_VPATH_INTR_RX;
+
+	vpath->stats_block = __hw_blockpool_block_allocate(hldev,
+				VXGE_HW_BLOCK_SIZE);
+
+	if (vpath->stats_block == NULL) {
+
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+
+		goto vpath_open_exit8;
+
+	}
+
+	vpath->hw_stats =
+		(struct vxge_hw_vpath_stats_hw_info *)vpath->
+			stats_block->memblock;
+
+	memset(vpath->hw_stats, 0,
+			sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	hldev->stats.hw_dev_info_stats.vpath_info[attr->vp_id] =
+						vpath->hw_stats;
+
+	vpath->hw_stats_sav =
+		&hldev->stats.hw_dev_info_stats.vpath_info_sav[attr->vp_id];
+
+	memset(vpath->hw_stats_sav, 0,
+			sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	writeq(vpath->stats_block->dma_addr, &vpath->vp_reg->stats_cfg);
+
+	status = vxge_hw_vpath_stats_enable(vp);
+
+	if (status != VXGE_HW_OK)
+		goto vpath_open_exit8;
+
+	vxge_list_insert(&vp->item, &vpath->vpath_handles);
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
+		__hw_ring_delete(vp);
+vpath_open_exit7:
+	if (vpath->fifoh != NULL)
+		__hw_fifo_delete(vp);
+vpath_open_exit6:
+	vfree(vp);
+vpath_open_exit2:
+	__hw_vp_terminate(hldev, attr->vp_id);
+vpath_open_exit1:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_close - Close the handle got from previous vpath (vpath) open
+ * @vp: Handle got from previous vpath open
+ *
+ * This function is used to close access to virtual path opened
+ * earlier.
+ */
+enum vxge_hw_status
+vxge_hw_vpath_close(struct __hw_vpath_handle *vp)
+{
+	struct __hw_virtualpath *vpath = NULL;
+	struct __hw_device *devh = NULL;
+	u32 vp_id = vp->vpath->vp_id;
+	u32 is_empty = TRUE;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	vxge_assert(vp != NULL);
+
+	devh = (struct __hw_device *)vp->vpath->hldev;
+	vpath = (struct __hw_virtualpath *)vp->vpath;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto vpath_close_exit;
+	}
+
+	vxge_list_remove(&vp->item);
+
+	if (!vxge_list_is_empty(&vpath->vpath_handles)) {
+		vxge_list_insert(&vp->item, &vpath->vpath_handles);
+		is_empty = FALSE;
+	}
+
+	if (!is_empty) {
+
+		status = VXGE_HW_FAIL;
+		goto vpath_close_exit;
+	}
+
+	vpath->hldev->vpaths_deployed &= ~vxge_mBIT(vp_id);
+
+	if (vpath->ringh != NULL)
+		__hw_ring_delete(vp);
+
+	if (vpath->fifoh != NULL)
+		__hw_fifo_delete(vp);
+
+	if (vpath->stats_block != NULL)
+		__hw_blockpool_block_free(devh, vpath->stats_block);
+
+	vfree(vp);
+
+	__hw_vp_terminate(devh, vp_id);
+
+	vpath->vp_open = VXGE_HW_VP_NOT_OPEN;
+
+vpath_close_exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_reset - Resets vpath
+ * @vp: Handle got from previous vpath open
+ *
+ * This function is used to request a reset of vpath
+ */
+enum vxge_hw_status
+vxge_hw_vpath_reset(struct __hw_vpath_handle *vp)
+{
+	enum vxge_hw_status status;
+	struct __hw_device *hldev;
+	u32 vp_id;
+
+	vxge_assert(vp != NULL);
+
+	vp_id = vxge_hw_vpath_id(vp);
+	hldev = vp->vpath->hldev;
+
+	if (vp->vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	status = __hw_vpath_reset(vp->vpath->hldev, vp_id);
+	if (status == VXGE_HW_OK)
+		vp->vpath->sw_stats->soft_reset_cnt++;
+exit:
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_recover_from_reset - Poll for reset complete and re-initialize.
+ * @vp: Handle got from previous vpath open
+ *
+ * This function poll's for the vpath reset completion and re initializes
+ * the vpath.
+ */
+enum vxge_hw_status
+vxge_hw_vpath_recover_from_reset(struct __hw_vpath_handle *vp)
+{
+	struct __hw_virtualpath *vpath = NULL;
+	enum vxge_hw_status status;
+	struct __hw_device *hldev;
+	u32 vp_id;
+
+	vxge_assert(vp != NULL);
+
+	vp_id = vxge_hw_vpath_id(vp);
+	vpath = (struct __hw_virtualpath *)vp->vpath;
+	hldev = vpath->hldev;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	status = __hw_vpath_reset_check(vpath);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __hw_vpath_sw_reset(hldev, vp_id);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __hw_vpath_initialize(hldev, vp_id);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	if (vp->vpath->ringh != NULL)
+		__hw_vpath_prc_configure(hldev, vp_id);
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
+
+	return status;
+}
+
+/**
+ * vxge_hw_vpath_id - Get virtual path ID
+ * @vp: Handle got from previous vpath open
+ *
+ * This function returns virtual path id
+ */
+u32
+vxge_hw_vpath_id(struct __hw_vpath_handle *vp)
+{
+	struct __hw_virtualpath *vpath = NULL;
+
+	vxge_assert(vp != NULL);
+
+	vpath = (struct __hw_virtualpath *)vp->vpath;
+
+	return vpath->vp_id;
+}
+
+/**
+ * vxge_hw_vpath_enable - Enable vpath.
+ * @vp: Handle got from previous vpath open
+ *
+ * This routine clears the vpath reset thereby enabling a vpath
+ * to start forwarding frames and generating interrupts.
+ */
+void
+vxge_hw_vpath_enable(struct __hw_vpath_handle *vp)
+{
+	struct __hw_device *hldev;
+	u64 val64;
+
+	vxge_assert(vp != NULL);
+
+	hldev = vp->vpath->hldev;
+
+	val64 = VXGE_HW_CMN_RSTHDLR_CFG1_CLR_VPATH_RESET(
+		1 << (16 - vxge_hw_vpath_id(vp)));
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+		&hldev->common_reg->cmn_rsthdlr_cfg1);
+
+}
+
+/**
+ * vxge_hw_vpath_stats_enable - Enable vpath h/wstatistics.
+ * @vp: Virtual Path handle.
+ *
+ * Enable the DMA vpath statistics. The function is to be called to re-enable
+ * the adapter to update stats into the host memory
+ */
+enum vxge_hw_status vxge_hw_vpath_stats_enable(struct __hw_vpath_handle *vp)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __hw_virtualpath *vpath;
+
+	vxge_assert(vp != NULL);
+
+	vpath = vp->vpath;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	memcpy(vpath->hw_stats_sav,
+			vpath->hw_stats,
+			sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+	if (vpath->hldev->config.stats_read_method ==
+					VXGE_HW_STATS_READ_METHOD_DMA) {
+		val64 = readq(&vpath->hldev->common_reg->stats_cfg0);
+
+		val64 |= VXGE_HW_STATS_CFG0_STATS_ENABLE(
+				(1 << (16 - vpath->vp_id)));
+
+		__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+				&vpath->hldev->common_reg->stats_cfg0);
+	} else
+		status = __hw_vpath_stats_get(
+				vpath,
+				vpath->hw_stats);
+exit:
+
+	return status;
+}
+/*
+ * __hw_vpath_stats_access - Get the statistics from the given location
+ *                           and offset and perform an operation
+ * @vpath: Virtual path.
+ * @operation: Operation to be performed
+ * @location: Location (one of vpath id, aggregate or port)
+ * @offset: Offset with in the location
+ * @stat: Pointer to a buffer to return the value
+ *
+ * Get the statistics from the given location and offset.
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_stats_access(
+	struct __hw_virtualpath *vpath,
+	u32 operation,
+	u32 offset,
+	u64 *stat)
+
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(vpath != NULL);
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto vpath_stats_access_exit;
+	}
+
+	val64 =  VXGE_HW_XMAC_STATS_ACCESS_CMD_OP(operation) |
+		 VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE |
+		 VXGE_HW_XMAC_STATS_ACCESS_CMD_OFFSET_SEL(offset);
+
+	__hw_pio_mem_write32_lower((u32)bVAL32(val64, 32),
+			&vpath->vp_reg->xmac_stats_access_cmd);
+	wmb();
+
+	__hw_pio_mem_write32_upper((u32)bVAL32(val64, 0),
+			&vpath->vp_reg->xmac_stats_access_cmd);
+	wmb();
+
+	status = __hw_device_register_poll(
+			(u64 *)&vpath->vp_reg->xmac_stats_access_cmd,
+			0,
+			VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE,
+			vpath->hldev->config.device_poll_millis);
+
+	if ((status == VXGE_HW_OK) && (operation == VXGE_HW_STATS_OP_READ))
+
+		*stat = readq(&vpath->vp_reg->xmac_stats_access_data);
+
+	else
+		*stat = 0;
+
+vpath_stats_access_exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_xmac_tx_stats_get - Get the TX Statistics of a vpath
+ * @vpath: vpath
+ * @vpath_tx_stats: Buffer to return TX Statistics of vpath.
+ *
+ * Get the TX Statistics of a vpath
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_xmac_tx_stats_get(struct __hw_virtualpath *vpath,
+		struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats)
+{
+	u64 *val64;
+	int i;
+	u32 offset = VXGE_HW_STATS_VPATH_TX_OFFSET;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(vpath != NULL);
+	val64 = (u64 *) vpath_tx_stats;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_tx_stats) / 8; i++) {
+		status = __hw_vpath_stats_access(vpath, VXGE_HW_STATS_OP_READ,
+					offset, val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+		offset++;
+		val64++;
+	}
+
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_xmac_rx_stats_get - Get the RX Statistics of a vpath
+ * @vpath: vpath
+ * @vpath_rx_stats: Buffer to return RX Statistics of vpath.
+ *
+ * Get the RX Statistics of a vpath
+ *
+ */
+enum vxge_hw_status
+__hw_vpath_xmac_rx_stats_get(struct __hw_virtualpath *vpath,
+			struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats)
+{
+	u64 *val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	int i;
+	u32 offset = VXGE_HW_STATS_VPATH_RX_OFFSET;
+	vxge_assert(vpath != NULL);
+	val64 = (u64 *) vpath_rx_stats;
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+	for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_rx_stats) / 8; i++) {
+		status = __hw_vpath_stats_access(vpath, VXGE_HW_STATS_OP_READ,
+					offset >> 3, val64);
+		if (status != VXGE_HW_OK)
+			goto exit;
+
+		offset += 8;
+		val64++;
+	}
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_vpath_stats_get - Get the vpath hw statistics.
+ * @vpath: Virtual Path.
+ * @hw_stats: Hardware stats
+ *
+ * Returns the vpath h/w stats.
+ *
+ * See also: vxge_hw_vpath_stats_enable()
+ */
+enum vxge_hw_status __hw_vpath_stats_get(
+			struct __hw_virtualpath *vpath,
+			struct vxge_hw_vpath_stats_hw_info *hw_stats)
+{
+	u64 val64;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert((vpath != NULL) && (hw_stats != NULL));
+
+	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+		goto exit;
+	}
+
+	val64 = readq(&vpath->vp_reg->vpath_debug_stats0);
+
+	hw_stats->ini_num_mwr_sent =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS0_GET_INI_NUM_MWR_SENT(val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_debug_stats1);
+
+	hw_stats->ini_num_mrd_sent =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS1_GET_INI_NUM_MRD_SENT(val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_debug_stats2);
+
+	hw_stats->ini_num_cpl_rcvd =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS2_GET_INI_NUM_CPL_RCVD(val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_debug_stats3);
+
+	hw_stats->ini_num_mwr_byte_sent =
+		VXGE_HW_VPATH_DEBUG_STATS3_GET_INI_NUM_MWR_BYTE_SENT(val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_debug_stats4);
+
+	hw_stats->ini_num_cpl_byte_rcvd =
+		VXGE_HW_VPATH_DEBUG_STATS4_GET_INI_NUM_CPL_BYTE_RCVD(val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_debug_stats5);
+
+	hw_stats->wrcrdtarb_xoff =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS5_GET_WRCRDTARB_XOFF(val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_debug_stats6);
+
+	hw_stats->rdcrdtarb_xoff =
+		(u32)VXGE_HW_VPATH_DEBUG_STATS6_GET_RDCRDTARB_XOFF(val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_genstats_count01);
+
+	hw_stats->vpath_genstats_count0 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT0(
+		val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_genstats_count01);
+
+	hw_stats->vpath_genstats_count1 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT1(
+		val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_genstats_count23);
+
+	hw_stats->vpath_genstats_count2 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT2(
+		val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_genstats_count01);
+
+	hw_stats->vpath_genstats_count3 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT3(
+		val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_genstats_count4);
+
+	hw_stats->vpath_genstats_count4 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT4_GET_PPIF_VPATH_GENSTATS_COUNT4(
+		val64);
+
+	val64 = readq(&vpath->vp_reg->vpath_genstats_count5);
+
+	hw_stats->vpath_genstats_count5 =
+	(u32)VXGE_HW_VPATH_GENSTATS_COUNT5_GET_PPIF_VPATH_GENSTATS_COUNT5(
+		val64);
+
+	status = __hw_vpath_xmac_tx_stats_get(vpath, &hw_stats->tx_stats);
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	status = __hw_vpath_xmac_rx_stats_get(vpath, &hw_stats->rx_stats);
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
+	val64 = readq(&vpath->vp_reg->rx_multi_cast_stats);
+
+	hw_stats->rx_multi_cast_frame_discard =
+		(u16)VXGE_HW_RX_MULTI_CAST_STATS_GET_FRAME_DISCARD(val64);
+
+	val64 = readq(&vpath->vp_reg->rx_frm_transferred);
+
+	hw_stats->rx_frm_transferred =
+		(u32)VXGE_HW_RX_FRM_TRANSFERRED_GET_RX_FRM_TRANSFERRED(val64);
+
+	val64 = readq(&vpath->vp_reg->rxd_returned);
+
+	hw_stats->rxd_returned =
+		(u16)VXGE_HW_RXD_RETURNED_GET_RXD_RETURNED(val64);
+
+	val64 = readq(&vpath->vp_reg->dbg_stats_rx_mpa);
+
+	hw_stats->rx_mpa_len_fail_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_LEN_FAIL_FRMS(val64);
+	hw_stats->rx_mpa_mrk_fail_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_MRK_FAIL_FRMS(val64);
+	hw_stats->rx_mpa_crc_fail_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_CRC_FAIL_FRMS(val64);
+
+	val64 = readq(&vpath->vp_reg->dbg_stats_rx_fau);
+
+	hw_stats->rx_permitted_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_PERMITTED_FRMS(val64);
+	hw_stats->rx_vp_reset_discarded_frms =
+	(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_VP_RESET_DISCARDED_FRMS(val64);
+	hw_stats->rx_wol_frms =
+		(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_WOL_FRMS(val64);
+
+	val64 = readq(&vpath->vp_reg->tx_vp_reset_discarded_frms);
+
+	hw_stats->tx_vp_reset_discarded_frms =
+	(u16)VXGE_HW_TX_VP_RESET_DISCARDED_FRMS_GET_TX_VP_RESET_DISCARDED_FRMS(
+		val64);
+exit:
+
+	return status;
+}
+
+/*
+ * __hw_blockpool_create - Create block pool
+ * @devh: Pointer to HW Device object.
+ * @blockpool: Block pool to be created.
+ * @pool_size: Number of blocks in the pool.
+ * @pool_incr: Number of blocks to be request from OS at a time
+ * @pool_min: Number of blocks below which new blocks to be requested.
+ * @pool_max: Number of blocks above which block to be freed.
+ *
+ * This function creates block pool
+ */
+
+enum vxge_hw_status
+__hw_blockpool_create(struct __hw_device *devh,
+			struct __hw_blockpool  *blockpool,
+			u32 pool_size,
+			u32 pool_incr,
+			u32 pool_min,
+			u32 pool_max)
+{
+	u32 i;
+	struct __hw_device *hldev = (struct __hw_device *)devh;
+	struct __hw_blockpool_entry *entry;
+	void *memblock;
+	dma_addr_t dma_addr;
+	struct pci_dev *dma_handle;
+	struct pci_dev *acc_handle;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(devh != NULL);
+
+	if (blockpool == NULL) {
+
+		status = VXGE_HW_FAIL;
+		goto blockpool_create_exit;
+	}
+
+	blockpool->hldev = devh;
+	blockpool->block_size = VXGE_HW_BLOCK_SIZE;
+	blockpool->pool_size = 0;
+	blockpool->pool_incr = pool_incr;
+	blockpool->pool_min = pool_min;
+	blockpool->pool_max = pool_max;
+	blockpool->req_out = 0;
+
+#ifdef VXGE_HW_DMA_CONSISTENT
+	blockpool->dma_flags = VXGE_OS_DMA_CONSISTENT;
+#else
+	blockpool->dma_flags = VXGE_OS_DMA_STREAMING;
+#endif
+
+	vxge_list_init(&blockpool->free_block_list);
+
+	vxge_list_init(&blockpool->free_entry_list);
+
+	for (i = 0; i < pool_size  +  pool_max; i++) {
+
+		entry = (struct __hw_blockpool_entry *)\
+			vmalloc(sizeof(struct __hw_blockpool_entry));
+		if (entry == NULL) {
+			__hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+
+		vxge_list_insert(&entry->item, &blockpool->free_entry_list);
+	}
+
+	for (i = 0; i < pool_size; i++) {
+
+		memblock = vxge_os_dma_malloc(
+				hldev->pdev,
+				VXGE_HW_BLOCK_SIZE,
+				blockpool->dma_flags,
+				&dma_handle,
+				&acc_handle);
+
+		if (memblock == NULL) {
+			__hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+
+		dma_addr = vxge_os_dma_map(
+				hldev->pdev,
+				dma_handle,
+				memblock,
+				VXGE_HW_BLOCK_SIZE,
+				PCI_DMA_BIDIRECTIONAL,
+				blockpool->dma_flags);
+
+		if (unlikely(vxge_do_pci_dma_mapping_error(hldev->pdev,
+				dma_addr))) {
+
+			vxge_os_dma_free(hldev->pdev,
+					memblock,
+					VXGE_HW_BLOCK_SIZE,
+					blockpool->dma_flags,
+					&dma_handle,
+					&acc_handle);
+			__hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+
+		entry = (struct __hw_blockpool_entry *)
+			vxge_list_first_get(&blockpool->free_entry_list);
+
+		if (entry == NULL) {
+			entry = (struct __hw_blockpool_entry *)\
+				vmalloc(sizeof(struct __hw_blockpool_entry));
+		}
+
+		if (entry != NULL) {
+			vxge_list_remove(&entry->item);
+			entry->length = VXGE_HW_BLOCK_SIZE;
+			entry->memblock = memblock;
+			entry->dma_addr = dma_addr;
+			entry->acc_handle = acc_handle;
+			entry->dma_handle = dma_handle;
+			vxge_list_insert(&entry->item,
+					  &blockpool->free_block_list);
+			blockpool->pool_size++;
+		} else {
+			__hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+	}
+
+blockpool_create_exit:
+
+	return status;
+}
+
+/*
+ * __hw_blockpool_destroy - Deallocates the block pool
+ * @blockpool: blockpool to be deallocated
+ *
+ * This function freeup the memory pool and removes the
+ * block pool.
+ */
+
+void
+__hw_blockpool_destroy(
+	struct __hw_blockpool  *blockpool)
+{
+
+	struct __hw_device *hldev;
+	struct vxge_list *p, *n;
+	u16 ret;
+
+	vxge_assert(blockpool != NULL);
+
+	if (blockpool == NULL) {
+
+		ret = 1;
+		goto exit;
+	}
+
+	hldev = (struct __hw_device *)blockpool->hldev;
+
+	vxge_list_for_each_safe(p, n, &blockpool->free_block_list) {
+
+		vxge_os_dma_unmap(hldev->pdev,
+				((struct __hw_blockpool_entry *)p)->dma_handle,
+				((struct __hw_blockpool_entry *)p)->dma_addr,
+				((struct __hw_blockpool_entry *)p)->length,
+				PCI_DMA_BIDIRECTIONAL);
+
+		vxge_os_dma_free(hldev->pdev,
+				((struct __hw_blockpool_entry *)p)->memblock,
+				((struct __hw_blockpool_entry *)p)->length,
+				blockpool->dma_flags,
+				&((struct __hw_blockpool_entry *)p)->dma_handle,
+				&((struct __hw_blockpool_entry *)
+					p)->acc_handle);
+
+		vxge_list_remove(&((struct __hw_blockpool_entry *)p)->item);
+		vfree(p);
+		blockpool->pool_size--;
+	}
+
+	vxge_list_for_each_safe(p, n, &blockpool->free_entry_list) {
+		vxge_list_remove(&((struct __hw_blockpool_entry *)p)->item);
+		vfree((void *)p);
+	}
+	ret = 0;
+exit:
+
+	return;
+}
+
+/*
+ * __hw_blockpool_blocks_add - Request additional blocks
+ * @blockpool: Block pool.
+ *
+ * Requests additional blocks to block pool
+ */
+static inline
+void __hw_blockpool_blocks_add(
+			struct __hw_blockpool *blockpool)
+{
+	u32 nreq = 0, i;
+
+	vxge_assert(blockpool != NULL);
+
+	if ((blockpool->pool_size  +  blockpool->req_out) <
+		blockpool->pool_min) {
+		nreq = blockpool->pool_incr;
+		blockpool->req_out += nreq;
+	}
+
+	for (i = 0; i < nreq; i++) {
+		vxge_os_dma_malloc_async(
+			((struct __hw_device *)blockpool->hldev)->pdev,
+			blockpool->hldev,
+			VXGE_HW_BLOCK_SIZE,
+			blockpool->dma_flags);
+	}
+
+}
+
+/*
+ * __hw_blockpool_blocks_remove - Free additional blocks
+ * @blockpool: Block pool.
+ *
+ * Frees additional blocks over maximum from the block pool
+ */
+static inline
+void __hw_blockpool_blocks_remove(
+			struct __hw_blockpool *blockpool)
+{
+	struct vxge_list *p, *n;
+
+	vxge_assert(blockpool != NULL);
+
+	vxge_list_for_each_safe(p, n, &blockpool->free_block_list) {
+
+		if (blockpool->pool_size < blockpool->pool_max)
+			break;
+
+		vxge_os_dma_unmap(
+			((struct __hw_device *)blockpool->hldev)->pdev,
+			((struct __hw_blockpool_entry *)p)->dma_handle,
+			((struct __hw_blockpool_entry *)p)->dma_addr,
+			((struct __hw_blockpool_entry *)p)->length,
+			PCI_DMA_BIDIRECTIONAL);
+
+		vxge_os_dma_free(
+			((struct __hw_device *)blockpool->hldev)->pdev,
+			((struct __hw_blockpool_entry *)p)->memblock,
+			((struct __hw_blockpool_entry *)p)->length,
+			blockpool->dma_flags,
+			&((struct __hw_blockpool_entry *)p)->dma_handle,
+			&((struct __hw_blockpool_entry *)p)->acc_handle);
+
+		vxge_list_remove(&((struct __hw_blockpool_entry *)p)->item);
+
+		vxge_list_insert(p, &blockpool->free_entry_list);
+
+		blockpool->pool_size--;
+
+	}
+
+}
+
+/**
+ * vxge_hw_blockpool_block_add - callback for vxge_os_dma_malloc_async
+ * @devh: HW device handle.
+ * @block_addr: Virtual address of the block
+ * @length: Length of the block.
+ * @p_dma_h: Physical address of the block
+ * @acc_handle: DMA acc handle
+ *
+ * Adds a block to block pool
+ */
+void vxge_hw_blockpool_block_add(
+			struct __hw_device *devh,
+			void *block_addr,
+			u32 length,
+			struct pci_dev *dma_h,
+			struct pci_dev *acc_handle)
+{
+	struct __hw_blockpool  *blockpool;
+	struct __hw_blockpool_entry  *entry;
+	dma_addr_t dma_addr;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u32 req_out;
+
+	vxge_assert(devh != NULL);
+
+	blockpool = &((struct __hw_device *)devh)->block_pool;
+
+	if (block_addr == NULL) {
+		blockpool->req_out--;
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	dma_addr = vxge_os_dma_map(((struct __hw_device *)devh)->pdev,
+				dma_h,
+				block_addr,
+				length,
+				PCI_DMA_BIDIRECTIONAL,
+				blockpool->dma_flags);
+
+	if (unlikely(vxge_do_pci_dma_mapping_error(
+			((struct __hw_device *)devh)->pdev,
+			dma_addr))) {
+
+		vxge_os_dma_free(((struct __hw_device *)devh)->pdev,
+				block_addr,
+				length,
+				blockpool->dma_flags,
+				&dma_h,
+				&acc_handle);
+		blockpool->req_out--;
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
+
+	entry = (struct __hw_blockpool_entry *)
+			vxge_list_first_get(&blockpool->free_entry_list);
+
+	if (entry == NULL) {
+		entry = (struct __hw_blockpool_entry *)\
+			vmalloc(sizeof(struct __hw_blockpool_entry));
+	} else
+		vxge_list_remove(&entry->item);
+
+	if (entry != NULL) {
+		entry->length = length;
+		entry->memblock = block_addr;
+		entry->dma_addr = dma_addr;
+		entry->acc_handle = acc_handle;
+		entry->dma_handle = dma_h;
+		vxge_list_insert(&entry->item, &blockpool->free_block_list);
+		blockpool->pool_size++;
+		status = VXGE_HW_OK;
+	} else
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+
+	blockpool->req_out--;
+
+	req_out = blockpool->req_out;
+exit:
+
+	return;
+}
+
+/**
+ * __hw_blockpool_malloc - Allocate a memory block from pool
+ * @devh: HW device handle.
+ * @size: Length of the block.
+ * @dma_addr: Buffer to return DMA Address of the block.
+ * @dma_handle: Buffer to return DMA handle of the block.
+ * @acc_handle: Buffer to return DMA acc handle
+ *
+ * Allocates a block of memory of given size, either from block pool
+ * or by calling vxge_os_dma_malloc()
+ */
+void *
+__hw_blockpool_malloc(struct __hw_device *devh,
+			u32 size,
+			dma_addr_t *dma_addr,
+			struct pci_dev **dma_handle,
+			struct pci_dev **acc_handle)
+{
+	struct __hw_blockpool_entry *entry;
+	struct __hw_blockpool  *blockpool;
+	void *memblock = NULL;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(devh != NULL);
+
+	blockpool = &((struct __hw_device *)devh)->block_pool;
+
+	if (size != blockpool->block_size) {
+
+		memblock = vxge_os_dma_malloc(((struct __hw_device *)
+						devh)->pdev,
+						size,
+						blockpool->dma_flags |
+						VXGE_OS_DMA_CACHELINE_ALIGNED,
+						dma_handle,
+						acc_handle);
+
+		if (memblock == NULL) {
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+		*dma_addr = vxge_os_dma_map(((struct __hw_device *)
+					devh)->pdev,
+					*dma_handle,
+					memblock,
+					size,
+					PCI_DMA_BIDIRECTIONAL,
+					blockpool->dma_flags);
+
+		if (unlikely(vxge_do_pci_dma_mapping_error(
+				((struct __hw_device *)devh)->pdev,
+				*dma_addr))) {
+
+			vxge_os_dma_free(((struct __hw_device *)devh)->pdev,
+					memblock,
+					size,
+					blockpool->dma_flags |
+					VXGE_OS_DMA_CACHELINE_ALIGNED,
+					dma_handle,
+					acc_handle);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto exit;
+		}
+
+	} else {
+
+		entry = (struct __hw_blockpool_entry *)
+			vxge_list_first_get(&blockpool->free_block_list);
+
+		if (entry != NULL) {
+			vxge_list_remove(&entry->item);
+			*dma_addr = entry->dma_addr;
+			*dma_handle = entry->dma_handle;
+			*acc_handle = entry->acc_handle;
+			memblock = entry->memblock;
+
+			vxge_list_insert(&entry->item,
+					&blockpool->free_entry_list);
+			blockpool->pool_size--;
+		}
+
+		if (memblock != NULL)
+			__hw_blockpool_blocks_add(blockpool);
+	}
+exit:
+
+	return memblock;
+
+}
+
+/**
+ * __hw_blockpool_free - Frees the memory allcoated with __hw_blockpool_malloc
+ * @devh: HW device handle.
+ * @memblock: Virtual address block
+ * @size: Length of the block.
+ * @dma_addr: DMA Address of the block.
+ * @dma_handle: DMA handle of the block.
+ * @acc_handle: DMA acc handle
+ *
+ * Frees the memory allocated with __hw_blockpool_malloc to blockpool or system
+ */
+void
+__hw_blockpool_free(struct __hw_device *devh,
+			void *memblock,
+			u32 size,
+			dma_addr_t *dma_addr,
+			struct pci_dev **dma_handle,
+			struct pci_dev **acc_handle)
+{
+	struct __hw_blockpool_entry *entry;
+	struct __hw_blockpool  *blockpool;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	vxge_assert(devh != NULL);
+
+	blockpool = &((struct __hw_device *)devh)->block_pool;
+
+	if (size != blockpool->block_size) {
+
+		vxge_os_dma_unmap(((struct __hw_device *)devh)->pdev,
+				*dma_handle,
+				*dma_addr,
+				size,
+				PCI_DMA_BIDIRECTIONAL);
+
+		vxge_os_dma_free(((struct __hw_device *)devh)->pdev,
+				memblock,
+				size,
+				blockpool->dma_flags |
+				VXGE_OS_DMA_CACHELINE_ALIGNED,
+				dma_handle,
+				acc_handle);
+	} else {
+
+		entry = (struct __hw_blockpool_entry *)
+			vxge_list_first_get(&blockpool->free_entry_list);
+
+		if (entry == NULL) {
+			entry = (struct __hw_blockpool_entry *)\
+				vmalloc(sizeof(struct __hw_blockpool_entry));
+		} else {
+			vxge_list_remove(&entry->item);
+		}
+
+		if (entry != NULL) {
+			entry->length = size;
+			entry->memblock = memblock;
+			entry->dma_addr = *dma_addr;
+			entry->acc_handle = *acc_handle;
+			entry->dma_handle = *dma_handle;
+			vxge_list_insert(&entry->item,
+					&blockpool->free_block_list);
+			blockpool->pool_size++;
+			status = VXGE_HW_OK;
+		} else
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+
+		if (status == VXGE_HW_OK)
+			__hw_blockpool_blocks_remove(blockpool);
+
+	}
+
+	return;
+}
+
+/*
+ * __hw_blockpool_block_allocate - Allocates a block from block pool
+ * @hldev: Hal device
+ * @size: Size of the block to be allocated
+ *
+ * This function allocates a block from block pool or from the system
+ */
+struct __hw_blockpool_entry *
+__hw_blockpool_block_allocate(struct __hw_device *devh,
+			       u32 size)
+{
+	struct __hw_blockpool_entry *entry = NULL;
+	struct __hw_blockpool  *blockpool;
+
+	vxge_assert(devh != NULL);
+
+	blockpool = &((struct __hw_device *)devh)->block_pool;
+
+	if (size == blockpool->block_size) {
+
+		entry = (struct __hw_blockpool_entry *)
+			vxge_list_first_get(&blockpool->free_block_list);
+
+		if (entry != NULL) {
+			vxge_list_remove(&entry->item);
+			blockpool->pool_size--;
+		}
+
+	}
+
+	if (entry != NULL)
+		__hw_blockpool_blocks_add(blockpool);
+
+	return entry;
+}
+
+/*
+ * __hw_blockpool_block_free - Frees a block from block pool
+ * @devh: Hal device
+ * @entry: Entry of block to be freed
+ *
+ * This function frees a block from block pool
+ */
+void
+__hw_blockpool_block_free(struct __hw_device *devh,
+			struct __hw_blockpool_entry *entry)
+{
+	struct __hw_blockpool  *blockpool;
+
+	vxge_assert(devh != NULL);
+
+	blockpool = &((struct __hw_device *)devh)->block_pool;
+
+	if (entry->length == blockpool->block_size) {
+
+		vxge_list_insert(&entry->item, &blockpool->free_block_list);
+		blockpool->pool_size++;
+
+	}
+
+	__hw_blockpool_blocks_remove(blockpool);
+
+	return;
+}
diff -urpN patch_5/drivers/net/vxge/vxge-config.h patch_6/drivers/net/vxge/vxge-config.h
--- patch_5/drivers/net/vxge/vxge-config.h	1969-12-31 16:00:00.000000000 -0800
+++ patch_6/drivers/net/vxge/vxge-config.h	2009-03-13 00:11:31.000000000 -0700
@@ -0,0 +1,3323 @@
+/******************************************************************************
+ * This software may be used and distributed according to the terms of
+ * the GNU General Public License (GPL), incorporated herein by reference.
+ * Drivers based on or derived from this code fall under the GPL and must
+ * retain the authorship, copyright and license notice.  This file is not
+ * a complete program and may only be used when the entire operating
+ * system is licensed under the GPL.
+ * See the file COPYING in this distribution for more information.
+ ******************************************************************************/
+/*******************************************************************************
+ * vxge-config.h: Driver for Neterion Inc's X3100 Series 10GbE PCIe I/O
+ *                Virtualized Server Adapter.
+ * Copyright(c) 2002-2009 Neterion Inc.
+ ******************************************************************************/
+#ifndef VXGE_CONFIG_H
+#define VXGE_CONFIG_H
+
+#if defined(__cplusplus)
+#define __EXTERN_BEGIN_DECLS	extern "C" {
+#define __EXTERN_END_DECLS			}
+#else
+#define __EXTERN_BEGIN_DECLS
+#define __EXTERN_END_DECLS
+#endif
+
+#define VXGE_MIN(x, y) ((x < y) ? x : y)
+
+#ifndef VXGE_CACHE_LINE_SIZE
+#define VXGE_CACHE_LINE_SIZE 128
+#endif
+
+#define VXGE_OS_HAS_SNPRINTF	1
+
+#define vxge_os_vaprintf(level, mask, fmt, ...) { \
+	char buff[255]; \
+		sprintf(buff, fmt, __VA_ARGS__); \
+		printk(buff); \
+		printk("\n"); \
+}
+/*---------------------------- DMA attributes ------------------------------*/
+/*           Used in vxge_os_dma_malloc() and vxge_os_dma_map() */
+/*---------------------------- DMA attributes ------------------------------*/
+
+#define VXGE_OS_DMA_CACHELINE_ALIGNED			0x1
+/* Either STREAMING or CONSISTENT should be used.
+	The combination of both or none is invalid */
+#define VXGE_OS_DMA_STREAMING				0x2
+#define VXGE_OS_DMA_CONSISTENT				0x4
+
+#ifndef VXGE_ALIGN
+#define VXGE_ALIGN(adrs, size) \
+	(((size) - (((u64)adrs) & ((size)-1))) & ((size)-1))
+#endif
+
+#ifndef VXGE_ALIGNED
+#define VXGE_ALIGNED(adrs, size)   (((ULONG)(adrs) & ((size)-1)) == 0)
+#endif
+
+#define vxge_os_udelay(us)	 { 		\
+		if (us > 1000)			\
+			mdelay(us/1000);	\
+		else				\
+			udelay(us);		\
+	}
+
+#define VXGE_HW_MIN_MTU				46
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
+ * @VXGE_COMPONENT_HW_DEVICE: do debug for vxge core device module
+ * @VXGE_COMPONENT_HW_DEVICE_IRQ: do debug for vxge device ISR
+ * @VXGE_COMPONENT_HW_VAPTH: do debug for vxge core virtual path module
+ * @VXGE_COMPONENT_HW_VAPTH_ISR: do debug for vxge vpath ISR
+ * @VXGE_COMPONENT_HW_CONFIG: do debug for vxge core config module
+ * @VXGE_COMPONENT_HW_MM: do debug for vxge core memory module
+ * @VXGE_COMPONENT_HW_POOL: do debug for vxge core memory pool module
+ * @VXGE_COMPONENT_HW_CHANNEL: do debug for vxge core channel module
+ * @VXGE_COMPONENT_HW_FIFO: do debug for vxge core fifo module
+ * @VXGE_COMPONENT_HW_RING: do debug for vxge core ring module
+ * @VXGE_COMPONENT_HW_STAG: do debug for vxge core STAG module
+ * @VXGE_COMPONENT_HW_STATS: do debug for vxge core statistics module
+ * @VXGE_COMPONENT_HW_MRPCIM: do debug for vxge core mrpcim module
+ * @VXGE_COMPONENT_HW_SRPCIM: do debug for vxge core srpcim module
+ * @VXGE_COMPONENT_OSDEP: do debug for vxge os dependent parts
+ * @VXGE_COMPONENT_LL: do debug for vxge link layer module
+ * @VXGE_COMPONENT_ALL: activate debug for all modules with no exceptions
+ *
+ * This enumeration going to be used to distinguish modules
+ * or libraries during compilation and runtime.  Makefile must declare
+ * VXGE_DEBUG_MODULE_MASK macro and set it to proper value.
+ */
+#define	VXGE_COMPONENT_HW_DEVICE			0x00000001
+#define	VXGE_COMPONENT_HW_DEVICE_IRQ			0x00000002
+#define	VXGE_COMPONENT_HW_VPATH				0x00000004
+#define	VXGE_COMPONENT_HW_VPATH_IRQ			0x00000008
+#define VXGE_COMPONENT_HW_CONFIG			0x00000010
+#define	VXGE_COMPONENT_HW_MM				0x00000020
+#define	VXGE_COMPONENT_HW_POOL				0x00000040
+#define	VXGE_COMPONENT_HW_CHANNEL			0x00000200
+#define	VXGE_COMPONENT_HW_FIFO				0x00000400
+#define	VXGE_COMPONENT_HW_RING				0x00000800
+#define	VXGE_COMPONENT_HW_STAG				0x00040000
+#define	VXGE_COMPONENT_HW_TCP				0x00080000
+#define	VXGE_COMPONENT_HW_LRO				0x00100000
+#define	VXGE_COMPONENT_HW_STATS				0x00800000
+#define	VXGE_COMPONENT_HW_MRPCIM			0x01000000
+#define	VXGE_COMPONENT_HW_SRPCIM			0x02000000
+
+#define	VXGE_COMPONENT_OSDEP				0x10000000
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
+	VXGE_HW_INF_MEM_STROBE_CMD_EXECUTING	  = VXGE_HW_BASE_INF + 3,
+	VXGE_HW_INF_SW_LRO_BEGIN		  = VXGE_HW_BASE_INF + 4,
+	VXGE_HW_INF_SW_LRO_CONT                   = VXGE_HW_BASE_INF + 5,
+	VXGE_HW_INF_SW_LRO_UNCAPABLE		  = VXGE_HW_BASE_INF + 6,
+	VXGE_HW_INF_SW_LRO_FLUSH_SESSION	  = VXGE_HW_BASE_INF + 7,
+	VXGE_HW_INF_SW_LRO_FLUSH_BOTH		  = VXGE_HW_BASE_INF + 8,
+
+	VXGE_HW_ERR_INVALID_HANDLE		  = VXGE_HW_BASE_ERR + 1,
+	VXGE_HW_ERR_OUT_OF_MEMORY		  = VXGE_HW_BASE_ERR + 2,
+	VXGE_HW_ERR_VPATH_NOT_AVAILABLE	  	  = VXGE_HW_BASE_ERR + 3,
+	VXGE_HW_ERR_VPATH_NOT_OPEN		  = VXGE_HW_BASE_ERR + 4,
+	VXGE_HW_ERR_WRONG_IRQ			  = VXGE_HW_BASE_ERR + 5,
+	VXGE_HW_ERR_SWAPPER_CTRL		  = VXGE_HW_BASE_ERR + 6,
+	VXGE_HW_ERR_INVALID_MTU_SIZE		  = VXGE_HW_BASE_ERR + 7,
+	VXGE_HW_ERR_BAD_SUBSYSTEM_ID		  = VXGE_HW_BASE_ERR + 8,
+	VXGE_HW_ERR_INVALID_INDEX		  = VXGE_HW_BASE_ERR + 9,
+	VXGE_HW_ERR_INVALID_TYPE		  = VXGE_HW_BASE_ERR + 10,
+	VXGE_HW_ERR_INVALID_OFFSET		  = VXGE_HW_BASE_ERR + 11,
+	VXGE_HW_ERR_INVALID_DEVICE		  = VXGE_HW_BASE_ERR + 12,
+	VXGE_HW_ERR_OUT_OF_SPACE		  = VXGE_HW_BASE_ERR + 13,
+	VXGE_HW_ERR_INVALID_VALUE_BIT_SIZE	  = VXGE_HW_BASE_ERR + 14,
+	VXGE_HW_ERR_VERSION_CONFLICT		  = VXGE_HW_BASE_ERR + 15,
+	VXGE_HW_ERR_INVALID_MAC_ADDRESS	  	  = VXGE_HW_BASE_ERR + 16,
+	VXGE_HW_ERR_BAD_DEVICE_ID		  = VXGE_HW_BASE_ERR + 17,
+	VXGE_HW_ERR_OUT_ALIGNED_FRAGS		  = VXGE_HW_BASE_ERR + 18,
+	VXGE_HW_ERR_DEVICE_NOT_INITIALIZED	  = VXGE_HW_BASE_ERR + 19,
+	VXGE_HW_ERR_INVALID_PCI_INFO		  = VXGE_HW_BASE_ERR + 20,
+	VXGE_HW_ERR_INVALID_TCODE 		  = VXGE_HW_BASE_ERR + 21,
+	VXGE_HW_ERR_RESET_FAILED		  = VXGE_HW_BASE_ERR + 22,
+	VXGE_HW_ERR_TOO_MANY			  = VXGE_HW_BASE_ERR + 23,
+	VXGE_HW_ERR_PKT_DROP			  = VXGE_HW_BASE_ERR + 24,
+	VXGE_HW_ERR_INVALID_BLOCK_SIZE		  = VXGE_HW_BASE_ERR + 25,
+	VXGE_HW_ERR_INVALID_STATE		  = VXGE_HW_BASE_ERR + 26,
+	VXGE_HW_ERR_PRIVILAGED_OPEARATION	  = VXGE_HW_BASE_ERR + 27,
+	VXGE_HW_ERR_RESET_IN_PROGRESS		  = VXGE_HW_BASE_ERR + 28,
+	VXGE_HW_ERR_MAC_TABLE_FULL		  = VXGE_HW_BASE_ERR + 29,
+	VXGE_HW_ERR_MAC_TABLE_EMPTY		  = VXGE_HW_BASE_ERR + 30,
+	VXGE_HW_ERR_MAC_TABLE_NO_MORE_ENTRIES	  = VXGE_HW_BASE_ERR + 31,
+	VXGE_HW_ERR_RTDMA_RTDMA_READY		  = VXGE_HW_BASE_ERR + 32,
+	VXGE_HW_ERR_WRDMA_WRDMA_READY		  = VXGE_HW_BASE_ERR + 33,
+	VXGE_HW_ERR_KDFC_KDFC_READY		  = VXGE_HW_BASE_ERR + 34,
+	VXGE_HW_ERR_TPA_TMAC_BUF_EMPTY		  = VXGE_HW_BASE_ERR + 35,
+	VXGE_HW_ERR_RDCTL_PIC_QUIESCENT	  	  = VXGE_HW_BASE_ERR + 36,
+	VXGE_HW_ERR_XGMAC_NETWORK_FAULT	  	  = VXGE_HW_BASE_ERR + 37,
+	VXGE_HW_ERR_ROCRC_OFFLOAD_QUIESCENT	  = VXGE_HW_BASE_ERR + 38,
+	VXGE_HW_ERR_G3IF_FB_G3IF_FB_GDDR3_READY   = VXGE_HW_BASE_ERR + 39,
+	VXGE_HW_ERR_G3IF_CM_G3IF_CM_GDDR3_READY   = VXGE_HW_BASE_ERR + 40,
+	VXGE_HW_ERR_RIC_RIC_RUNNING		  = VXGE_HW_BASE_ERR + 41,
+	VXGE_HW_ERR_CMG_C_PLL_IN_LOCK		  = VXGE_HW_BASE_ERR + 42,
+	VXGE_HW_ERR_XGMAC_X_PLL_IN_LOCK	  	  = VXGE_HW_BASE_ERR + 43,
+	VXGE_HW_ERR_FBIF_M_PLL_IN_LOCK		  = VXGE_HW_BASE_ERR + 44,
+	VXGE_HW_ERR_PCC_PCC_IDLE 		  = VXGE_HW_BASE_ERR + 45,
+	VXGE_HW_ERR_ROCRC_RC_PRC_QUIESCENT 	  = VXGE_HW_BASE_ERR + 46,
+	VXGE_HW_ERR_INVALID_PORT 		  = VXGE_HW_BASE_ERR + 47,
+	VXGE_HW_ERR_INVALID_PRIORITY 		  = VXGE_HW_BASE_ERR + 48,
+	VXGE_HW_ERR_INVALID_MIN_BANDWIDTH 	  = VXGE_HW_BASE_ERR + 49,
+	VXGE_HW_ERR_INVALID_MAX_BANDWIDTH 	  = VXGE_HW_BASE_ERR + 50,
+	VXGE_HW_ERR_INVALID_TOTAL_BANDWIDTH 	  = VXGE_HW_BASE_ERR + 51,
+	VXGE_HW_ERR_FIFO		 	  = VXGE_HW_BASE_ERR + 52,
+	VXGE_HW_ERR_VPATH			  = VXGE_HW_BASE_ERR + 53,
+	VXGE_HW_ERR_CRITICAL			  = VXGE_HW_BASE_ERR + 54,
+	VXGE_HW_ERR_SLOT_FREEZE 		  = VXGE_HW_BASE_ERR + 55,
+
+	VXGE_HW_BADCFG_QUEUE_SIZE_INITIAL	  = VXGE_HW_BASE_BADCFG + 1,
+	VXGE_HW_BADCFG_QUEUE_SIZE_MAX		  = VXGE_HW_BASE_BADCFG + 2,
+	VXGE_HW_BADCFG_TRACEBUF_SIZE		  = VXGE_HW_BASE_BADCFG + 3,
+	VXGE_HW_BADCFG_RING_ENABLE		  = VXGE_HW_BASE_BADCFG + 4,
+	VXGE_HW_BADCFG_RING_BLOCKS		  = VXGE_HW_BASE_BADCFG + 5,
+	VXGE_HW_BADCFG_RING_RXD_BUFFER_MODE	  = VXGE_HW_BASE_BADCFG + 6,
+	VXGE_HW_BADCFG_RING_SCATTER_MODE	  = VXGE_HW_BASE_BADCFG + 7,
+	VXGE_HW_BADCFG_RING_MAX_FRM_LEN		  = VXGE_HW_BASE_BADCFG + 8,
+	VXGE_HW_BADCFG_RING_NO_SNOOP_ALL	  = VXGE_HW_BASE_BADCFG + 12,
+	VXGE_HW_BADCFG_RING_TIMER_VAL		  = VXGE_HW_BASE_BADCFG + 13,
+	VXGE_HW_BADCFG_RING_GREEDY_RETURN	  = VXGE_HW_BASE_BADCFG + 14,
+	VXGE_HW_BADCFG_RING_TIMER_CI		  = VXGE_HW_BASE_BADCFG + 15,
+	VXGE_HW_BADCFG_RING_BACKOFF_INTERVAL_US	  = VXGE_HW_BASE_BADCFG + 16,
+	VXGE_HW_BADCFG_RING_INDICATE_MAX_PKTS	  = VXGE_HW_BASE_BADCFG + 17,
+	VXGE_HW_BADCFG_FIFO_ENABLE		  = VXGE_HW_BASE_BADCFG + 18,
+	VXGE_HW_BADCFG_FIFO_BLOCKS		  = VXGE_HW_BASE_BADCFG + 19,
+	VXGE_HW_BADCFG_FIFO_FRAGS		  = VXGE_HW_BASE_BADCFG + 20,
+	VXGE_HW_BADCFG_FIFO_MEMBLOCK_SIZE	  = VXGE_HW_BASE_BADCFG + 21,
+	VXGE_HW_BADCFG_FIFO_ALIGNMENT_SIZE	  = VXGE_HW_BASE_BADCFG + 22,
+	VXGE_HW_BADCFG_FIFO_MAX_FRAGS		  = VXGE_HW_BASE_BADCFG + 23,
+	VXGE_HW_BADCFG_FIFO_QUEUE_INTR		  = VXGE_HW_BASE_BADCFG + 24,
+	VXGE_HW_BADCFG_FIFO_NO_SNOOP_ALL	  = VXGE_HW_BASE_BADCFG + 25,
+	VXGE_HW_BADCFG_TIM_INTR_ENABLE		  = VXGE_HW_BASE_BADCFG + 26,
+	VXGE_HW_BADCFG_TIM_BTIMER_VAL		  = VXGE_HW_BASE_BADCFG + 27,
+	VXGE_HW_BADCFG_TIM_TIMER_AC_EN		  = VXGE_HW_BASE_BADCFG + 28,
+	VXGE_HW_BADCFG_TIM_TIMER_CI_EN		  = VXGE_HW_BASE_BADCFG + 29,
+	VXGE_HW_BADCFG_TIM_TIMER_RI_EN		  = VXGE_HW_BASE_BADCFG + 30,
+	VXGE_HW_BADCFG_TIM_BTIMER_EVENT_SF	  = VXGE_HW_BASE_BADCFG + 31,
+	VXGE_HW_BADCFG_TIM_RTIMER_VAL		  = VXGE_HW_BASE_BADCFG + 32,
+	VXGE_HW_BADCFG_TIM_UTIL_SEL		  = VXGE_HW_BASE_BADCFG + 33,
+	VXGE_HW_BADCFG_TIM_LTIMER_VAL		  = VXGE_HW_BASE_BADCFG + 34,
+	VXGE_HW_BADCFG_TXFRM_CNT_EN		  = VXGE_HW_BASE_BADCFG + 35,
+	VXGE_HW_BADCFG_TXD_CNT_EN		  = VXGE_HW_BASE_BADCFG + 36,
+	VXGE_HW_BADCFG_TIM_URANGE_A		  = VXGE_HW_BASE_BADCFG + 37,
+	VXGE_HW_BADCFG_TIM_UEC_A		  = VXGE_HW_BASE_BADCFG + 38,
+	VXGE_HW_BADCFG_TIM_URANGE_B		  = VXGE_HW_BASE_BADCFG + 39,
+	VXGE_HW_BADCFG_TIM_UEC_B		  = VXGE_HW_BASE_BADCFG + 40,
+	VXGE_HW_BADCFG_TIM_URANGE_C		  = VXGE_HW_BASE_BADCFG + 41,
+	VXGE_HW_BADCFG_TIM_UEC_C		  = VXGE_HW_BASE_BADCFG + 42,
+	VXGE_HW_BADCFG_TIM_UEC_D		  = VXGE_HW_BASE_BADCFG + 43,
+	VXGE_HW_BADCFG_VPATH_ID			  = VXGE_HW_BASE_BADCFG + 44,
+	VXGE_HW_BADCFG_VP_CONFIG_VALID		  = VXGE_HW_BASE_BADCFG + 45,
+	VXGE_HW_BADCFG_BITMAP_INTR_NUM		  = VXGE_HW_BASE_BADCFG + 46,
+	VXGE_HW_BADCFG_VPATH_NO_SNOOP		  = VXGE_HW_BASE_BADCFG + 47,
+	VXGE_HW_BADCFG_VPATH_MTU		  = VXGE_HW_BASE_BADCFG + 48,
+	VXGE_HW_BADCFG_VPATH_TPA_LSOV2_EN	  = VXGE_HW_BASE_BADCFG + 49,
+	VXGE_HW_BADCFG_VPATH_TPA_IGNORE_FRAME_ERROR = VXGE_HW_BASE_BADCFG + 50,
+	VXGE_HW_BADCFG_VPATH_TPA_IPV6_KEEP_SEARCHING = VXGE_HW_BASE_BADCFG + 51,
+	VXGE_HW_BADCFG_VPATH_TPA_L4_PSHDR_PRESENT = VXGE_HW_BASE_BADCFG + 52,
+	VXGE_HW_BADCFG_VPATH_TPA_SUPPORT_MOBILE_IPV6_HDRS =
+						VXGE_HW_BASE_BADCFG + 53,
+	VXGE_HW_BADCFG_VPATH_RPA_IPV4_TCP_INCL_PH = VXGE_HW_BASE_BADCFG + 54,
+	VXGE_HW_BADCFG_VPATH_RPA_IPV6_TCP_INCL_PH = VXGE_HW_BASE_BADCFG + 55,
+	VXGE_HW_BADCFG_VPATH_RPA_IPV4_UDP_INCL_PH = VXGE_HW_BASE_BADCFG + 56,
+	VXGE_HW_BADCFG_VPATH_RPA_IPV6_UDP_INCL_PH = VXGE_HW_BASE_BADCFG + 57,
+	VXGE_HW_BADCFG_VPATH_RPA_L4_INCL_CF	  = VXGE_HW_BASE_BADCFG + 58,
+	VXGE_HW_BADCFG_VPATH_RPA_STRIP_VLAN_TAG  = VXGE_HW_BASE_BADCFG + 59,
+	VXGE_HW_BADCFG_VPATH_RPA_L4_COMP_CSUM	  = VXGE_HW_BASE_BADCFG + 60,
+	VXGE_HW_BADCFG_VPATH_RPA_L3_INCL_CF	  = VXGE_HW_BASE_BADCFG + 61,
+	VXGE_HW_BADCFG_VPATH_RPA_L3_COMP_CSUM	  = VXGE_HW_BASE_BADCFG + 62,
+	VXGE_HW_BADCFG_VPATH_RPA_UCAST_ALL_ADDR_EN = VXGE_HW_BASE_BADCFG + 63,
+	VXGE_HW_BADCFG_VPATH_RPA_MCAST_ALL_ADDR_EN = VXGE_HW_BASE_BADCFG + 64,
+	VXGE_HW_BADCFG_VPATH_RPA_CAST_EN	  = VXGE_HW_BASE_BADCFG + 65,
+	VXGE_HW_BADCFG_VPATH_RPA_ALL_VID_EN	  = VXGE_HW_BASE_BADCFG + 66,
+	VXGE_HW_BADCFG_VPATH_VP_Q_L2_FLOW	  = VXGE_HW_BASE_BADCFG + 67,
+	VXGE_HW_BADCFG_VPATH_VP_STATS_READ_METHOD = VXGE_HW_BASE_BADCFG + 68,
+	VXGE_HW_BADCFG_VPATH_PRIORITY		  = VXGE_HW_BASE_BADCFG + 69,
+	VXGE_HW_BADCFG_VPATH_MIN_BANDWIDTH	  = VXGE_HW_BASE_BADCFG + 70,
+	VXGE_HW_BADCFG_VPATH_MAX_BANDWIDTH	  = VXGE_HW_BASE_BADCFG + 71,
+	VXGE_HW_BADCFG_BLOCKPOOL_MIN		  = VXGE_HW_BASE_BADCFG + 72,
+	VXGE_HW_BADCFG_BLOCKPOOL_INITIAL	  = VXGE_HW_BASE_BADCFG + 73,
+	VXGE_HW_BADCFG_BLOCKPOOL_INCR		  = VXGE_HW_BASE_BADCFG + 74,
+	VXGE_HW_BADCFG_BLOCKPOOL_MAX		  = VXGE_HW_BASE_BADCFG + 75,
+	VXGE_HW_BADCFG_ISR_POLLING_CNT		  = VXGE_HW_BASE_BADCFG + 76,
+	VXGE_HW_BADCFG_LATENCY_TIMER		  = VXGE_HW_BASE_BADCFG + 77,
+	VXGE_HW_BADCFG_MAX_PAYLOAD_SIZE	  = VXGE_HW_BASE_BADCFG + 78,
+	VXGE_HW_BADCFG_MMRB_COUNT		  = VXGE_HW_BASE_BADCFG + 79,
+	VXGE_HW_BADCFG_STATS_REFRESH_TIME	  = VXGE_HW_BASE_BADCFG + 80,
+	VXGE_HW_BADCFG_DUMP_ON_SERR		  = VXGE_HW_BASE_BADCFG + 81,
+	VXGE_HW_BADCFG_DUMP_ON_ECCERR		  = VXGE_HW_BASE_BADCFG + 82,
+	VXGE_HW_BADCFG_INTR_MODE		  = VXGE_HW_BASE_BADCFG + 83,
+	VXGE_HW_BADCFG_RTH_EN			  = VXGE_HW_BASE_BADCFG + 84,
+	VXGE_HW_BADCFG_RTH_IT_TYPE		  = VXGE_HW_BASE_BADCFG + 85,
+	VXGE_HW_BADCFG_RTH_BUCKET_SIZE		  = VXGE_HW_BASE_BADCFG + 86,
+	VXGE_HW_BADCFG_UFCA_INTR_THRES		  = VXGE_HW_BASE_BADCFG + 87,
+	VXGE_HW_BADCFG_UFCA_LO_LIM		  = VXGE_HW_BASE_BADCFG + 88,
+	VXGE_HW_BADCFG_UFCA_HI_LIM		  = VXGE_HW_BASE_BADCFG + 89,
+	VXGE_HW_BADCFG_UFCA_LBOLT_PERIOD	  = VXGE_HW_BASE_BADCFG + 90,
+	VXGE_HW_BADCFG_DEVICE_POLL_MILLIS	  = VXGE_HW_BASE_BADCFG + 91,
+	VXGE_HW_BADCFG_RTS_MAC_EN		  = VXGE_HW_BASE_BADCFG + 92,
+	VXGE_HW_BADCFG_RTS_QOS_EN		  = VXGE_HW_BASE_BADCFG + 93,
+	VXGE_HW_BADCFG_RTS_PORT_EN		  = VXGE_HW_BASE_BADCFG + 94,
+	VXGE_HW_BADCFG_STATS_READ_METHOD	  = VXGE_HW_BASE_BADCFG + 95,
+	VXGE_HW_BADCFG_POLL_OR_DOOR_BELL	  = VXGE_HW_BASE_BADCFG + 96,
+	VXGE_HW_BADCFG_MSIX_ID			  = VXGE_HW_BASE_BADCFG + 97,
+	VXGE_HW_BADCFG_SW_LRO_SESSIONS		  = VXGE_HW_BASE_BADCFG + 98,
+	VXGE_HW_BADCFG_SW_LRO_SG_SIZE		  = VXGE_HW_BASE_BADCFG + 99,
+	VXGE_HW_BADCFG_SW_LRO_FRM_LEN		  = VXGE_HW_BASE_BADCFG + 100,
+	VXGE_HW_BADCFG_VPATH_AGGR_ACK		  = VXGE_HW_BASE_BADCFG + 101,
+
+	VXGE_HW_EOF_TRACE_BUF			  = -1
+
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
+ * enum enum vxge_hw_device_data_rate - Data rate enumeration.
+ * @VXGE_HW_DATA_RATE_UNKNOWN: Unknown .
+ * @VXGE_HW_DATA_RATE_1G: 1G.
+ * @VXGE_HW_DATA_RATE_10G: 10G.
+ *
+ */
+enum vxge_hw_device_data_rate {
+	VXGE_HW_DATA_RATE_UNKNOWN,
+	VXGE_HW_DATA_RATE_1G,
+	VXGE_HW_DATA_RATE_10G
+};
+
+/**
+ * enum enum vxge_hw_pci_e_signalling_rate -  PCI-E Lane signalling rate
+ * @VXGE_HW_PCI_E_SIGNALLING_RATE_2_5GB:   PCI-E signalling rate 2.5 GB
+ * @VXGE_HW_PCI_E_SIGNALLING_RATE_5GB:	   PCI-E signalling rate 5 GB
+ * @VXGE_HW_PCI_E_SIGNALLING_RATE_UNKNOWN: Unrecognized PCI bus frequency value
+ *
+ * PCI-E Lane signalling rate
+ */
+enum vxge_hw_pci_e_signalling_rate {
+	VXGE_HW_PCI_E_SIGNALLING_RATE_2_5GB	= 1,
+	VXGE_HW_PCI_E_SIGNALLING_RATE_5GB	= 2,
+	VXGE_HW_PCI_E_SIGNALLING_RATE_UNKNOWN	= 0
+};
+
+/**
+ * enum enum vxge_hw_pci_e_link_width - PCI-E Link width enumeration.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_X1:	1 Lane.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_X2:	2 Lane.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_X4:	4 Lane.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_X8:	8 Lane.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_X12:	12 Lane.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_X16:	16 Lane.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_X32:	32 Lane.
+ * @VXGE_HW_PCI_E_LINK_WIDTH_UNKNOWN:	Unknown
+ *
+ * PCI-E Link width enumeration.
+ */
+enum vxge_hw_pci_e_link_width {
+	VXGE_HW_PCI_E_LINK_WIDTH_X1		= 1,
+	VXGE_HW_PCI_E_LINK_WIDTH_X2		= 2,
+	VXGE_HW_PCI_E_LINK_WIDTH_X4		= 4,
+	VXGE_HW_PCI_E_LINK_WIDTH_X8		= 8,
+	VXGE_HW_PCI_E_LINK_WIDTH_X12		= 12,
+	VXGE_HW_PCI_E_LINK_WIDTH_X16		= 16,
+	VXGE_HW_PCI_E_LINK_WIDTH_X32		= 32,
+	VXGE_HW_PCI_E_LINK_WIDTH_UNKNOWN	= 0
+};
+struct vxge_hw_device_date {
+	u32     day;
+	u32     month;
+	u32     year;
+	char    date[16];
+};
+struct vxge_hw_device_version {
+	u32     major;
+	u32     monor;
+	u32     build;
+#define VXGE_HW_FW_VERSION_LEN	32
+	char    version[VXGE_HW_FW_VERSION_LEN];
+};
+
+enum vxge_hw_status
+__hw_vpath_fw_flash_ver_get(
+	u32	vp_id,
+	struct vxge_hw_vpath_reg	*vpath_reg,
+	struct vxge_hw_device_version	*fw_version,
+	struct vxge_hw_device_date	*fw_date,
+	struct vxge_hw_device_version	*flash_version,
+	struct vxge_hw_device_date	*flash_date);
+
+/*
+ * struct vxge_hw_vpd_data
+ *
+ * Represents vpd capabilty structure
+ */
+struct vxge_hw_vpd_data {
+	u8      product_name[VXGE_HW_VPD_LEN];
+	u8      serial_num[VXGE_HW_VPD_LEN];
+};
+
+/**
+ * struct vxge_list - List item.
+ * @prev: Previous list item.
+ * @next: Next list item.
+ *
+ * Item of a bi-directional linked list.
+ */
+struct vxge_list {
+	struct vxge_list *prev;
+	struct vxge_list *next;
+};
+
+/*
+ * struct __hw_tracebuf
+ *
+ * HW trace buffer object.
+ */
+struct __hw_tracebuf {
+	u8		*data;
+	u64		wrapped_count;
+	volatile u32	offset;
+	u32		size;
+};
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
+ * @max_aligned_frags: Number of fragments to be aligned out of
+ *             maximum fragments (see @max_frags).
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
+#define VXGE_HW_FIFO_ENABLE					1
+#define VXGE_HW_FIFO_DISABLE					0
+#define VXGE_HW_FIFO_DEFAULT					1
+
+	u32				fifo_blocks;
+#define VXGE_HW_MIN_FIFO_BLOCKS				2
+#define VXGE_HW_MAX_FIFO_BLOCKS				128
+#define VXGE_HW_DEF_FIFO_BLOCKS				2
+
+	u32				max_frags;
+#define VXGE_HW_MIN_FIFO_FRAGS					1
+#define VXGE_HW_MAX_FIFO_FRAGS					256
+#define VXGE_HW_DEF_FIFO_FRAGS					256
+
+	u32				memblock_size;
+#define VXGE_HW_MIN_FIFO_MEMBLOCK_SIZE			VXGE_HW_BLOCK_SIZE
+#define VXGE_HW_MAX_FIFO_MEMBLOCK_SIZE				131072
+#define VXGE_HW_DEF_FIFO_MEMBLOCK_SIZE				8096
+
+	u32		                alignment_size;
+#define VXGE_HW_MIN_FIFO_ALIGNMENT_SIZE		0
+#define VXGE_HW_MAX_FIFO_ALIGNMENT_SIZE		65536
+#define VXGE_HW_DEF_FIFO_ALIGNMENT_SIZE		VXGE_CACHE_LINE_SIZE
+
+	u32				max_aligned_frags;
+	/* range: (1, @max_frags) */
+
+	u32		                intr;
+#define VXGE_HW_FIFO_QUEUE_INTR_ENABLE				1
+#define VXGE_HW_FIFO_QUEUE_INTR_DISABLE			0
+#define VXGE_HW_FIFO_QUEUE_INTR_DEFAULT			0
+
+	u32				no_snoop_bits;
+#define VXGE_HW_FIFO_NO_SNOOP_DISABLED				0
+#define VXGE_HW_FIFO_NO_SNOOP_TXD				1
+#define VXGE_HW_FIFO_NO_SNOOP_FRM				2
+#define VXGE_HW_FIFO_NO_SNOOP_ALL				3
+#define VXGE_HW_FIFO_NO_SNOOP_DEFAULT				0
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
+ * @indicate_max_pkts: Sets maximum number of received frames to be processed
+ *             within single interrupt.
+ * @sw_lro_sessions: Number of LRO Sessions
+ * @sw_lro_sg_size: Size of LROable segment
+ * @lro_frm_len: Length of LROable frame
+ *
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
+	u32				indicate_max_pkts;
+#define VXGE_HW_MIN_RING_INDICATE_MAX_PKTS			1
+#define VXGE_HW_MAX_RING_INDICATE_MAX_PKTS			65536
+#define VXGE_HW_DEF_RING_INDICATE_MAX_PKTS			128
+
+	int				sw_lro_sessions;
+#define VXGE_HW_SW_LRO_MIN_SESSIONS				1
+#define VXGE_HW_SW_LRO_MAX_SESSIONS				64
+#define VXGE_HW_SW_LRO_DEFAULT_SESSIONS				32
+
+	int				sw_lro_sg_size;
+#define VXGE_HW_SW_LRO_MIN_SG_SIZE				1
+#define VXGE_HW_SW_LRO_MAX_SG_SIZE				64
+#define VXGE_HW_SW_LRO_DEFAULT_SG_SIZE				10
+
+	int				sw_lro_frm_len;
+#define VXGE_HW_SW_LRO_MIN_FRM_LEN				4096
+#define VXGE_HW_SW_LRO_MAX_FRM_LEN				65536
+#define VXGE_HW_SW_LRO_DEFAULT_FRM_LEN				65536
+
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
+ * @tpa_lsov2_en: LSOv2 Behaviour for IP ID roll-over
+ * @tpa_ignore_frame_error: Ignore Frame Error.
+ * 		The TPA may detect frame integrity
+ *             errors as it processes each frame. If this bit is set to '0',
+ *             the TPA will tag such frames as invalid and they will be dropped
+ *             by the transmit MAC. If the bit is set to '1', the frame will not
+ *             be tagged as "errored".  Detectable errors include:
+ *             1) early end-of-frame error, which occurs when the frame ends
+ *                before the number of bytes predicted by the IP "total length"
+ *                field have been received;
+ *             2) IP version mismatches;
+ *             3) IPv6 packets that include routing headers that are not type 0;
+ *             4) Frames which contain IP packets but have an illegal SNAP-OUI
+ *                or LLC-CTRL fields, unless IGNORE_SNAP_OUI or IGNORE_LLC_CTRL
+ *                are set (see below).
+ * @tpa_ipv6_keep_searching: If unknown IPv6 header is found,
+ *              0 - stop searching for TCP
+ *              1 - keep searching for TCP
+ * @tpa_l4_pshdr_present: If asserted true, indicates the
+ * 		host has provided a valid
+ *              pseudo header for TCP or UDP running over IPv4 or IPv6
+ * @tpa_support_mobile_ipv6_hdrs: This register is somewhat
+ * 		equivalent to asserting
+ *              both Hercules register fields LSO_RT2_EN and LSO_IPV6_HAO_EN.
+ *              Enable/disable support for Type 2 Routing Headers, and for
+ *              Mobile-IPv6 Home Address Option (HAO),
+ *              	as defined by mobile-ipv6.
+ * @rpa_ipv4_tcp_incl_ph: Determines whether the
+ * 		pseudo-header is included in the
+ *             calculation of the L4 checksum that is passed to the host. This
+ *             field applies to TCP/IPv4 packets only. This field affects both
+ *             non-offload and LRO traffic. Note that the RPA always includes
+ *             the pseudo-header in the "Checksum Ok" L4 checksum calculation
+ *             i.e. the checksum that decides whether a frame is a candidate to
+ *             be offloaded.
+ *             0 - Do not include the pseudo-header in L4 checksum calculation.
+ *                 This setting should be used if the adapter is incorrectly
+ *                 calculating the pseudo-header.
+ *             1 - Include the pseudo-header in L4 checksum calculation
+ * @rpa_ipv6_tcp_incl_ph: Determines whether the pseudo-header is included in
+ *             the calculation of the L4 checksum that is passed to the host.
+ *             This field applies to TCP/IPv6 packets only. This field affects
+ *             both non-offload and LRO traffic. Note that the RPA always
+ *             includes the pseudo-header in the "Checksum Ok" L4 checksum
+ *             calculation. i.e. the checksum that decides whether a frame
+ *             is a candidate to be offloaded.
+ *             0 - Do not include the pseudo-header in L4 checksum calculation.
+ *                 This setting should be used if the adapter is incorrectly
+ *                 calculating the pseudo-header.
+ *             1 - Include the pseudo-header in L4 checksum calculation
+ * @rpa_ipv4_udp_incl_ph: Determines whether the pseudo-header is included in
+ *             the calculation of the L4 checksum that is passed to the host.
+ *             This field applies to UDP/IPv4 packets only. It only affects
+ *             non-offload traffic (since UDP frames are not candidates for
+ *             LRO).
+ *             0 - Do not include the pseudo-header in L4 checksum calculation.
+ *                 This setting should be used if the adapter is incorrectly
+ *                 calculating the pseudo-header.
+ *             1 - Include the pseudo-header in L4 checksum calculation
+ * @rpa_ipv6_udp_incl_ph: Determines whether the
+ * 		pseudo-header is included in the
+ *             calculation of the L4 checksum that is passed to the host. This
+ *             field applies to UDP/IPv6 packets only. It only affects
+ *             non-offload traffic (since UDP frames
+ *             are not candidates for LRO).
+ *             0 - Do not include the pseudo-header in L4 checksum calculation.
+ *                 This setting should be used if the adapter is incorrectly
+ *                 calculating the pseudo-header.
+ *             1 - Include the pseudo-header in L4 checksum calculation
+ * @rpa_l4_incl_cf: Determines whether the checksum field (CF) of the received
+ *             frame is included in the calculation of the L4 checksum that is
+ *             passed to the host. This field affects both non-offload and LRO
+ *             traffic. Note that the RPA always includes the checksum field in
+ *             the "Checksum Ok" L4 checksum calculation -- i.e. the checksum
+ *             that decides whether a frame is a candidate to be offloaded.
+ *             0 - Do not include the checksum field in L4 checksum calculation.
+ *             1 - Include the checksum field in L4 checksum calculation
+ * @rpa_strip_vlan_tag: Strip VLAN Tag enable/disable. Instructs the device to
+ *             remove the VLAN tag from all received tagged frames that are not
+ *             replicated at the internal L2 switch.
+ *             0 - Do not strip the VLAN tag.
+ *             1 - Strip the VLAN tag. Regardless of this setting, VLAN tags are
+ *                 always placed into the RxDMA descriptor.
+ * @rpa_l4_comp_csum: Determines whether the calculated L4 checksum should be
+ *             complemented before it is passed to the host This field affects
+ *             both non-offload and LRO traffic.
+ *             0 - Do not complement the calculated L4 checksum.
+ *             1 - Complement the calculated L4 checksum
+ * @rpa_l3_incl_cf:	Determines whether the checksum field
+ * 		(CF) of the received frame
+ *             is included in the calculation of the L3 checksum that is passed
+ *             to the host. This field affects both non-offload and LRO traffic.
+ *             Note that the RPA always includes the checksum field in the
+ *             "Checksum Ok" L3 checksum calculation -- i.e. the checksum that
+ *             decides whether a frame is a candidate to be offloaded.
+ *             0 - Do not include the checksum field in L3 checksum calculation.
+ *             1 - Include the checksum field in L3 checksum calculation
+ * @rpa_l3_comp_csum: Determines whether the calculated L3 checksum should be
+ *             complemented before it is passed to the host This field affects
+ *             both non-offload and LRO traffic.
+ *             0 - Do not complement the calculated L3 checksum.
+ *             1 - Complement the calculated L3 checksum
+ * @rpa_all_vid_en: romiscuous mode, it overrides the value held in this field.
+ *             0 - Disable;
+ *             1 - Enable
+ *             Note: RXMAC_GLOBAL_CFG.AUTHORIZE_VP_ALL_VID must be set to
+ *             allow this.
+ * @vp_queue_l2_flow: Allows per-VPATH receive queue from
+ *             contributing to L2 flow control. Has precedence over
+ *             RMAC_PAUSE_CFG_PORTn.LIMITER_EN.
+ *             0 - Queue is not allowed to contribute to L2 flow control.
+ *             1 - Queue is allowed to contribute to L2 flow control.
+ *
+ * This structure is used by the driver to pass the configuration parameters to
+ * configure Virtual Path.
+ */
+struct vxge_hw_vp_config {
+	u32				vp_id;
+
+#define	VXGE_HW_VPATH_PRIORITY_MIN				0
+#define	VXGE_HW_VPATH_PRIORITY_MAX				16
+#define	VXGE_HW_VPATH_PRIORITY_DEFAULT				0
+
+	u32				min_bandwidth;
+#define	VXGE_HW_VPATH_BANDWIDTH_MIN				0
+#define	VXGE_HW_VPATH_BANDWIDTH_MAX				100
+#define	VXGE_HW_VPATH_BANDWIDTH_DEFAULT				0
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
+#define VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE		1
+#define VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_DISABLE		0
+#define VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT	0xffffffff
+
+	u8				aggr_ack;
+#define VXGE_HW_VPATH_AGGR_ACK_ENABLE				1
+#define VXGE_HW_VPATH_AGGR_ACK_DISABLE				0
+#define	VXGE_HW_VPATH_AGGR_ACK_DEFAULT				0
+};
+/**
+ * struct vxge_hw_device_config - Device configuration.
+ * @dma_blockpool_min: Minimum blocks in the DMA pool
+ * @dma_blockpool_initial: Initial size of DMA Pool
+ * @dma_blockpool_incr: Number of blocks to request each time number of blocks
+ *             in the pool reaches dma_pool_min
+ * @dma_blockpool_max: Maximum blocks in DMA pool
+ * @isr_polling_cnt: Maximum number of times to "poll" for Tx and Rx
+ *                   completions.
+ * Specify either zero or 0xffffffff to use BIOS default.
+ * @max_payload_size: Maximum TLP payload size for the device/fFunction.
+ *              As a Receiver, the Function/device must handle TLPs as large
+ *              as the set value; as . As a Transmitter, the Function/device
+ *              must not generate TLPs exceeding the set value. Permissible
+ *              values that can be programmed are indicated by the
+ *              Max_Payload_Size Supported in the Device Capabilities register
+ * @stats_refresh_time_sec: Sets the default interval for
+ * 		automatic stats transfer
+ *              to the host. This includes MAC stats as well as PCI stats.
+ * @intr_mode: Line, or MSI-X interrupt.
+ *
+ * @rth_en: Enable Receive Traffic Hashing(RTH) using IT(Indirection Table).
+ * @rth_it_type: RTH IT table programming type
+ * @rth_bucket_size: RTH bucket width (in bits). For valid range please see
+ *                   struct vxge_hw_device_config{} in the driver sources.
+ * @rts_mac_en: Enable Receive Traffic Steering using MAC destination address
+ * @rts_qos_en: TBD
+ * @rts_port_en: TBD
+ * @vp_config: Configuration for virtual paths
+ * @poll_or_doorbell: TBD
+ * @stats_read_method: Stats read method.(DMA or PIO)
+ * @device_poll_millis: Specify the interval (in mulliseconds)
+ * 			to wait for register reads
+ * @tracebuf_size: Size of the trace buffer. Set it to '0' to disable.
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
+	u32				dma_blockpool_min;
+	u32				dma_blockpool_initial;
+	u32				dma_blockpool_incr;
+	u32				dma_blockpool_max;
+#define VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE		0
+#define VXGE_HW_INITIAL_DMA_BLOCK_POOL_SIZE		0
+#define VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE		4
+#define VXGE_HW_MAX_DMA_BLOCK_POOL_SIZE		4096
+
+#define        VXGE_HW_MAX_PAYLOAD_SIZE_512                    2
+
+	u32				intr_mode;
+#define VXGE_HW_INTR_MODE_IRQLINE			0
+#define VXGE_HW_INTR_MODE_MSIX				1
+#define VXGE_HW_INTR_MODE_MSIX_ONE_SHOT		2
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
+#define VXGE_HW_RTS_MAC_ENABLE				1
+#define VXGE_HW_RTS_MAC_DEFAULT			0
+
+	struct vxge_hw_vp_config	vp_config[VXGE_HW_MAX_VIRTUAL_PATHS];
+
+	u32				stats_read_method;
+#define VXGE_HW_STATS_READ_METHOD_DMA			1
+#define VXGE_HW_STATS_READ_METHOD_PIO			0
+#define VXGE_HW_STATS_READ_METHOD_DEFAULT		1
+
+	u32				device_poll_millis;
+#define VXGE_HW_MIN_DEVICE_POLL_MILLIS			1
+#define VXGE_HW_MAX_DEVICE_POLL_MILLIS			100000
+#define VXGE_HW_DEF_DEVICE_POLL_MILLIS			1000
+
+	u32				lro_enable;
+#define VXGE_HW_LRO_DONOT_AGGREGATE                    0
+#define VXGE_HW_LRO_ALWAYS_AGGREGATE                   1
+#define VXGE_HW_LRO_DONT_AGGR_FWD_PKTS                 2
+
+	u32				tracebuf_size;
+#define VXGE_HW_MIN_CIRCULAR_ARR			4096
+#define VXGE_HW_MAX_CIRCULAR_ARR			65536
+
+#define VXGE_HW_DEF_CIRCULAR_ARR			0
+
+};
+
+/**
+ * function vxge_uld_sched_timer_cb_f - Per-device periodic timer
+ * callback.
+ * @devh: HW device handle.
+ * @userdata: Per-device user data (a.k.a. context) specified via
+ * vxge_hw_device_initialize().
+ *
+ * Periodic or one-shot timer callback. If specified (that is, not NULL)
+ * HW invokes this callback periodically. The call is performed in the
+ * interrupt context.
+ *
+ * See also: vxge_hw_device_initialize{}
+ */
+
+/**
+ * function vxge_uld_link_up_f - Link-Up callback provided by driver.
+ * @devh: HW device handle.
+ * @userdata: Opaque context set by the driver via
+ * vxge_hw_device_private_set()
+ * (typically - at HW device iinitialization time).
+ *
+ * Link-up notification callback provided by the driver.
+ * This is one of the per-driver callbacks, see struct vxge_hw_uld_cbs{}.
+ *
+ * See also: struct vxge_hw_uld_cbs{}, vxge_uld_link_down_f{},
+ * vxge_hw_driver_initialize(), vxge_hw_device_private_set().
+ */
+
+/**
+ * function vxge_uld_link_down_f - Link-Down callback provided by
+ * driver.
+ * @devh: HW device handle.
+ * @userdata: Opaque context set by the driver via
+ * vxge_hw_device_private_set()
+ * (typically - at HW device iinitialization time).
+ *
+ * Link-Down notification callback provided by the driver.
+ * This is one of the per-driver callbacks, see struct vxge_hw_uld_cbs{}.
+ *
+ * See also: struct vxge_hw_uld_cbs{}, vxge_uld_link_up_f{},
+ * vxge_hw_driver_initialize(), vxge_hw_device_private_set().
+ */
+
+/**
+ * function vxge_uld_crit_err_f - Critical Error notification callback.
+ * @devh: HW device handle.
+ * @userdata: Opaque context set by the driver via
+ * vxge_hw_device_private_set()
+ * (typically - at HW device iinitialization time).
+ * @type: Enumerated hw error, e.g.: double ECC.
+ * @serr_data: Titan status.
+ * @ext_data: Extended data. The contents depends on the @type.
+ *
+ * Link-Down notification callback provided by the driver.
+ * This is one of the per-driver callbacks, see struct vxge_hw_uld_cbs{}.
+ *
+ * See also: struct vxge_hw_uld_cbs{}, enum vxge_hw_event{},
+ * vxge_hw_device_private_set(), vxge_hw_driver_initialize().
+ */
+
+/**
+ * function vxge_uld_xpak_alarm_log_f - driver "XPAK alarm log" callback.
+ * @devh: HHW device handle.
+ * @type: XPAK Alarm type
+ *
+ * Unless NULL is specified, HW invokes the callback after checking XPAK
+ * counters
+ */
+
+/**
+ * struct vxge_hw_uld_cbs - driver "slow-path" callbacks.
+ * @link_up: See vxge_uld_link_up_f{}.
+ * @link_down: See vxge_uld_link_down_f{}.
+ * @crit_err: See vxge_uld_crit_err_f{}.
+ * @sched_timer: See vxge_uld_sched_timer_cb_f{}.
+ * @xpak_alarm_log: TODO
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
+	void (*link_up)(
+			struct __hw_device *devh,
+			void *userdata);
+
+	void (*link_down)(
+			struct __hw_device *devh,
+			void *userdata);
+
+	void (*crit_err)(
+			struct __hw_device *devh,
+			void *userdata,
+			enum vxge_hw_event type,
+			u64 ext_data);
+
+	void (*sched_timer)(
+			struct __hw_device *devh,
+			void *userdata);
+
+	void (*xpak_alarm_log)(
+			struct __hw_device *devh,
+			enum vxge_hw_xpak_alarm_type type);
+};
+
+/*
+ * struct __hw_blockpool_entry - Block private data structure
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
+struct __hw_blockpool_entry {
+	struct vxge_list		item;
+	u32				length;
+	void				*memblock;
+	dma_addr_t			dma_addr;
+	struct pci_dev *dma_handle;
+	struct pci_dev *acc_handle;
+};
+
+/*
+ * struct __hw_blockpool - Block Pool
+ * @hldev: HW device
+ * @block_size: size of each block.
+ * @Pool_size: Number of blocks in the pool
+ * @pool_incr: Number of blocks to be requested/freed at a time from OS
+ * @pool_min: Minimum number of block below which to request additional blocks
+ * @pool_max: Maximum number of blocks above which to free additional blocks
+ * @req_out: Number of block requests with OS out standing
+ * @dma_flags: DMA flags
+ * @free_block_list: List of free blocks
+ *
+ * Block pool contains the DMA blocks preallocated.
+ *
+ */
+struct __hw_blockpool {
+	struct __hw_device *hldev;
+	u32				block_size;
+	u32				pool_size;
+	u32				pool_incr;
+	u32				pool_min;
+	u32				pool_max;
+	u32				req_out;
+	u32				dma_flags;
+	struct vxge_list		free_block_list;
+	struct vxge_list		free_entry_list;
+};
+
+/*
+ * enum enum __hw_channel_type - Enumerated channel types.
+ * @VXGE_HW_CHANNEL_TYPE_UNKNOWN: Unknown channel.
+ * @VXGE_HW_CHANNEL_TYPE_FIFO: fifo.
+ * @VXGE_HW_CHANNEL_TYPE_RING: ring.
+ * @VXGE_HW_CHANNEL_TYPE_MAX: Maximum number of HW-supported
+ * (and recognized) channel types. Currently: 2.
+ *
+ * Enumerated channel types. Currently there are only two link-layer
+ * channels - Titan fifo and Titan ring. In the future the list will grow.
+ */
+enum __hw_channel_type {
+	VXGE_HW_CHANNEL_TYPE_UNKNOWN			= 0,
+	VXGE_HW_CHANNEL_TYPE_FIFO			= 1,
+	VXGE_HW_CHANNEL_TYPE_RING			= 2,
+	VXGE_HW_CHANNEL_TYPE_MAX			= 3
+};
+
+/*
+ * struct __hw_channel
+ * @item: List item; used to maintain a list of open channels.
+ * @type: Channel type. See enum vxge_hw_channel_type{}.
+ * @devh: Device handle. HW device object that contains _this_ channel.
+ * @pdev: PCI Device object
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
+ * @poll_bytes: Poll bytes.
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
+struct __hw_channel {
+	struct vxge_list		item;
+	enum __hw_channel_type	type;
+	struct __hw_device *devh;
+	struct __hw_vpath_handle *vph;
+	u32		length;
+	u32		vp_id;
+	void		**reserve_arr;
+	u32		reserve_ptr;
+	u32		reserve_top;
+	void		**work_arr;
+
+	u32		post_index ____cacheline_aligned;
+	u32		compl_index ____cacheline_aligned;
+
+	void		**free_arr;
+	u32		free_ptr;
+	void		**orig_arr;
+	u32		poll_bytes;
+	u32		per_dtr_space;
+	u32		level_err;
+	u32		level_trace;
+	void		*userdata;
+	struct vxge_hw_common_reg	*common_reg;
+	u32			first_vp_id;
+	struct vxge_hw_vpath_stats_sw_common_info *stats;
+
+} ____cacheline_aligned;
+
+/*
+ * struct __hw_virtualpath - Virtual Path
+ *
+ * @vp_id: Virtual path id
+ * @vp_open: This flag specifies if vxge_hw_vp_open is called from LL Driver
+ * @hldev: Hal device
+ * @vp_config: Virtual Path Config
+ * @vp_reg: VPATH Register map address in BAR0
+ * @vpmgmt_reg: VPATH_MGMT register map address
+ * @is_first_vpath: 1 if this first vpath in this vfunc, 0 otherwise
+ * @max_mtu: Max mtu that can be supported
+ * @bmap_root_assigned: The bitmap root for this vpath
+ * @vsport_choices: The mask of vsports that are available for this vpath
+ * @vsport_number: vsport attached to this vpath
+ * @sess_grp_start: Session oid start
+ * @sess_grp_end: session oid end
+ * @max_kdfc_db: Maximum kernel mode doorbells
+ * @max_nofl_db: Maximum non offload doorbells
+ * @max_ofl_db: Maximum offload doorbells
+ * @tx_intr_num: Interrupt Number associated with the TX
+ * @rx_intr_num: Interrupt Number associated with the RX
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
+struct __hw_virtualpath {
+	u32				vp_id;
+
+	u32				vp_open;
+#define VXGE_HW_VP_NOT_OPEN	0
+#define	VXGE_HW_VP_OPEN		1
+
+	struct __hw_device		*hldev;
+	struct vxge_hw_vp_config	*vp_config;
+	struct vxge_hw_vpath_reg	*vp_reg;
+	struct vxge_hw_vpmgmt_reg	*vpmgmt_reg;
+	struct __hw_non_offload_db_wrapper	*nofl_db;
+	struct __hw_messaging_db_wrapper	*msg_db;
+	u32				is_first_vpath;
+
+	u32				max_mtu;
+	u32				bmap_root_assigned;
+	u32				vsport_choices;
+	u32				vsport_number;
+	u32				sess_grp_start;
+	u32				sess_grp_end;
+	u32				max_kdfc_db;
+	u32				max_nofl_db;
+	u32				max_ofl_db;
+
+	struct __hw_ring *____cacheline_aligned ringh;
+	struct __hw_fifo *____cacheline_aligned fifoh;
+	struct vxge_list		vpath_handles;
+	struct __hw_blockpool_entry		*stats_block;
+	struct vxge_hw_vpath_stats_hw_info	*hw_stats;
+	struct vxge_hw_vpath_stats_hw_info	*hw_stats_sav;
+	struct vxge_hw_vpath_stats_sw_info	*sw_stats;
+};
+
+/*
+ * struct __hw_vpath_handle - List item to store callback information
+ * @item: List head to keep the item in linked list
+ * @vpath: Virtual path to which this item belongs
+ * @client_handle: Client handle to be returned with the callback
+ *
+ * This structure is used to store the callback information.
+ */
+struct __hw_vpath_handle{
+	struct vxge_list	item;
+	struct __hw_virtualpath	*vpath;
+	void *client_handle;
+};
+
+/*
+ * struct __hw_device
+ *
+ * HW device object.
+ */
+/**
+ * struct __hw_device  - Hal device object
+ * @magic: Magic Number
+ * @device_id: PCI Device Id of the adapter
+ * @major_revision: PCI Device major revision
+ * @minor_revision: PCI Device minor revision
+ * @signalling_rate: PCI-E signalling rate
+ * @link_width: see enum vxge_hw_pci_e_link_width{}
+ * @bar0: BAR0 virtual address.
+ * @bar1: BAR1 virtual address.
+ * @bar2: BAR2 virtual address.
+ * @pdev: Physical device handle
+ * @config: Confguration passed by the LL driver at initialization
+ * @is_initialized: Flag to specify if device is initialized
+ * @msix_enabled: Flag to indicate if msix is enabled
+ * @link_state: Link state
+ * @queueh: Per device event queue
+ * @upper_layer_data: Private data set by LL driver
+ *
+ * HW device object. Represents Titan adapter
+ */
+struct __hw_device {
+	u32				magic;
+#define VXGE_HW_DEVICE_MAGIC					0x12345678
+#define VXGE_HW_DEVICE_DEAD					0xDEADDEAD
+	u16				device_id;
+	u8				major_revision;
+	u8				minor_revision;
+	void				*upper_layer_data;
+	enum vxge_hw_pci_e_signalling_rate	signalling_rate;
+	enum vxge_hw_pci_e_link_width	link_width;
+	u8				*bar0;
+	u8				*bar1;
+	u8				*bar2;
+	struct pci_dev *pdev;
+	struct vxge_hw_device_config	config;
+	volatile u32			is_initialized;
+	volatile enum vxge_hw_device_link_state	link_state;
+	enum vxge_hw_device_data_rate	data_rate;
+
+	struct vxge_hw_uld_cbs		uld_callbacks;
+
+	u32				host_type;
+	u32				func_id;
+	u32				srpcim_id;
+	u32				access_rights;
+#define VXGE_HW_DEVICE_ACCESS_RIGHT_VPATH      0x1
+#define VXGE_HW_DEVICE_ACCESS_RIGHT_SRPCIM     0x2
+#define VXGE_HW_DEVICE_ACCESS_RIGHT_MRPCIM     0x4
+	struct vxge_hw_pci_config	pci_config_space;
+	struct vxge_hw_pci_config	pci_config_space_bios;
+	struct vxge_hw_pci_caps_offset	pci_caps;
+	 u32	pci_e_caps;
+	struct vxge_hw_pci_e_ext_caps_offset	pci_e_ext_caps;
+	struct vxge_hw_legacy_reg	*legacy_reg;
+	struct vxge_hw_toc_reg		*toc_reg;
+	struct vxge_hw_common_reg	*common_reg;
+	struct vxge_hw_memrepair_reg	*memrepair_reg;
+	struct vxge_hw_pcicfgmgmt_reg	*pcicfgmgmt_reg \
+					[VXGE_HW_TITAN_PCICFGMGMT_REG_SPACES];
+	struct vxge_hw_mrpcim_reg	*mrpcim_reg;
+	struct vxge_hw_srpcim_reg	*srpcim_reg \
+					[VXGE_HW_TITAN_SRPCIM_REG_SPACES];
+	struct vxge_hw_vpmgmt_reg	*vpmgmt_reg \
+					[VXGE_HW_TITAN_VPMGMT_REG_SPACES];
+	struct vxge_hw_vpath_reg	*vpath_reg \
+					[VXGE_HW_TITAN_VPATH_REG_SPACES];
+	u8				*kdfc;
+	u8				*usdc;
+	struct __hw_virtualpath		virtual_paths \
+					[VXGE_HW_MAX_VIRTUAL_PATHS];
+	u64				vpath_assignments;
+	u64				vpaths_deployed;
+	u32				first_vp_id;
+	u64				tim_int_mask0[4];
+	u32				tim_int_mask1[4];
+
+	struct __hw_blockpool		block_pool;
+	struct vxge_list		pending_channel_list;
+	struct __hw_blockpool_entry	*mrpcim_stats_block;
+	struct vxge_hw_device_stats_mrpcim_info	*mrpcim_stats;
+	struct vxge_hw_device_stats_mrpcim_info	*mrpcim_stats_sav;
+	struct vxge_hw_device_stats	stats;
+	int				tti_enabled;
+	u32				mtu_first_time_set;
+	u32				debug_module_mask;
+	u32				debug_level;
+	u32				level_err;
+	u32				level_trace;
+	struct vxge_hw_vpd_data		vpd_data;
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
+#define VXGE_HW_SR_VH_FUNCTION0				5
+#define VXGE_HW_SR_VH_VIRTUAL_FUNCTION				6
+#define VXGE_HW_VH_NORMAL_FUNCTION				7
+	u64		function_mode;
+#define VXGE_HW_FUNCTION_MODE_MULTI_FUNCTION                   0
+#define VXGE_HW_FUNCTION_MODE_SINGLE_FUNCTION                  1
+#define VXGE_HW_FUNCTION_MODE_SRIOV                            2
+#define VXGE_HW_FUNCTION_MODE_MRIOV                            3
+	u32		func_id;
+	u64		vpath_mask;
+	struct vxge_hw_device_version fw_version;
+	struct vxge_hw_device_date    fw_date;
+	struct vxge_hw_device_version flash_version;
+	struct vxge_hw_device_date    flash_date;
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
+	u8			*bar0;
+	u8			*bar1;
+	u8			*bar2;
+	struct pci_dev *pdev;
+	struct vxge_hw_uld_cbs	uld_callbacks;
+};
+
+#define VXGE_HW_DEVICE_LINK_STATE_SET(hldev, ls) {	\
+	((struct __hw_device  *)hldev)->link_state = ls; \
+}
+
+#define VXGE_HW_DEVICE_DATA_RATE_SET(hldev, dr) {	\
+	((struct __hw_device  *)hldev)->data_rate = dr; \
+}
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
+	status = __hw_vpath_stats_access(vpath, \
+			VXGE_HW_STATS_OP_READ, \
+			offset, \
+			&val64);					\
+	if (status != VXGE_HW_OK)					\
+		return status;						\
+}
+
+/*
+ * struct __hw_ring - Ring channel.
+ * @channel: Channel "base" of this ring, the common part of all HW
+ *           channels.
+ * @mempool: Memory pool, the pool from which descriptors get allocated.
+ *           (See vxge_hw_mm.h).
+ * @config: Ring configuration, part of device configuration
+ *          (see struct vxge_hw_device_config{}).
+ * @ring_length: Length of the ring
+ * @buffer_mode: 1, 3, or 5. The value specifies a receive buffer mode,
+ *          as per Titan User Guide.
+ * @indicate_max_pkts: Maximum number of packets processed within a single
+ *          interrupt. Can be used to limit the time spent inside hw
+ *          interrupt.
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
+ *            Used in conjunction with @indicate_max_pkts.
+ * @active_sw_lros: List of Software LRO sessions in progess
+ * @active_sw_lro_count: Number of Software LRO sessions in progess
+ * @free_sw_lros: List of Software LRO sessions free
+ * @free_sw_lro_count: Number of Software LRO sessions free
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
+struct __hw_ring {
+	struct __hw_channel				channel;
+	struct vxge_hw_mempool			*mempool;
+	struct vxge_hw_vpath_reg			*vp_reg;
+	struct vxge_hw_common_reg			*common_reg;
+	u32					ring_length;
+	u32					buffer_mode;
+	u32					indicate_max_pkts;
+	u32					rxd_size;
+	u32					rxd_priv_size;
+	u32					per_rxd_space;
+	u32					rxds_per_block;
+	u32					rxdblock_priv_size;
+	u32					cmpl_cnt;
+	u32					vp_id;
+	u32					active_sw_lro_count;
+	u32					free_sw_lro_count;
+	u32					rx_intr_num;
+	u32					lro_enable;
+	u32					rpa_strip_vlan_tag;
+	u8					aggr_ack;
+
+	struct vxge_list				active_sw_lros;
+	struct vxge_list				free_sw_lros;
+	enum vxge_hw_status (*callback)(
+			struct __hw_ring *ringh,
+			void *rxdh,
+			u8 t_code,
+			void *userdata);
+
+	enum vxge_hw_status (*rxd_init)(
+			void *rxdh,
+			u32 index,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+
+	void (*rxd_term)(
+			void *rxdh,
+			enum vxge_hw_rxd_state state,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+	struct vxge_hw_vpath_stats_sw_ring_info *stats	____cacheline_aligned;
+	struct vxge_hw_ring_config	*config;
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
+ * struct __hw_fifo - Fifo.
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
+ *             per-TxDL HW private space (struct __hw_fifo_txdl_priv).
+ * @priv_size: Per-Tx descriptor space reserved for driver
+ *             usage.
+ * @per_txdl_space: Per txdl private space for the driver
+ * @align_size: Cache alignment size
+ * @callback: Fifo completion callback. HW invokes the callback when there
+ *             are new completions on that fifo. In many implementations
+ *             the @callback executes in the hw interrupt context.
+ * @txdl_init: Fifo's descriptor-initialize callback.
+ *             See vxge_hw_fifo_txdl_init_f{}.
+ *             If not NULL, HW invokes the callback when opening
+ *             the fifo via vxge_hw_vpath_open().
+ * @txdl_term: Fifo's descriptor-terminate callback. If not NULL,
+ *             HW invokes the callback when closing the corresponding fifo.
+ *             See also vxge_hw_fifo_txdl_term_f{}.
+ * @stats: Statistics of this fifo
+ *
+ * Fifo channel.
+ * Note: The structure is cache line aligned.
+ */
+struct __hw_fifo {
+	struct __hw_channel				channel;
+	struct vxge_hw_mempool			*mempool;
+	struct vxge_hw_fifo_config		*config;
+	struct vxge_hw_vpath_reg		*vp_reg;
+	struct __hw_non_offload_db_wrapper	*nofl_db;
+	u64					interrupt_type;
+	u32					no_snoop_bits;
+	u32					txdl_per_memblock;
+	u32					txdl_size;
+	u32					priv_size;
+	u32					per_txdl_space;
+	u32					align_size;
+	u32					vp_id;
+	u32					tx_intr_num;
+
+	enum vxge_hw_status (*callback)(
+			struct __hw_fifo *fifo_handle,
+			void *txdlh,
+			void *txdl_priv,
+			enum vxge_hw_fifo_tcode t_code,
+			void *userdata,
+			void **skb_ptr);
+
+	enum vxge_hw_status (*txdl_init)(
+			struct __hw_vpath_handle *vpath_handle,
+			void *txdlh,
+			void *txdl_priv,
+			u32 index,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+
+	void (*txdl_term)(
+			void *txdlh,
+			void *txdl_priv,
+			enum vxge_hw_txdl_state state,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+	struct vxge_hw_vpath_stats_sw_fifo_info *stats ____cacheline_aligned;
+} ____cacheline_aligned;
+
+/*
+ * struct __hw_fifo_txdl_priv - Transmit descriptor HW-private data.
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
+ *             (the maximum defined by configration variable
+ *             @max_aligned_frags).
+ * @align_dma_addr: DMA address translated from the @align_vaddr.
+ * @align_dma_handle: DMA handle that corresponds to @align_dma_addr.
+ * @align_dma_acch: DMA access handle corresponds to @align_dma_addr.
+ * @align_dma_offset: The current offset into the @align_vaddr area.
+ * Grows while filling the descriptor, gets reset.
+ * @align_used_frags: Number of fragments used.
+ * @alloc_frags: Total number of fragments allocated.
+ * @dang_frags: Number of fragments kept from release until this TxDL is freed.
+ * @bytes_sent: TODO
+ * @unused: TODO
+ * @dang_txdl: (TODO).
+ * @next_txdl_priv: (TODO).
+ * @first_txdp: (TODO).
+ * @dang_txdlh: Pointer to TxDL (list) kept from release until this TxDL
+ *             is freed.
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
+struct __hw_fifo_txdl_priv {
+	dma_addr_t			dma_addr;
+	struct pci_dev *dma_handle;
+	ptrdiff_t			dma_offset;
+	u32				frags;
+	u8				*align_vaddr_start;
+	u8				*align_vaddr;
+	dma_addr_t			align_dma_addr;
+	struct pci_dev *align_dma_handle;
+	struct pci_dev *align_dma_acch;
+	ptrdiff_t			align_dma_offset;
+	u32				align_used_frags;
+	u32				alloc_frags;
+	u32				dang_frags;
+	u32				bytes_sent;
+	u32				unused;
+	struct vxge_hw_fifo_txd		*dang_txdl;
+	struct __hw_fifo_txdl_priv	*next_txdl_priv;
+	struct vxge_hw_fifo_txd		*first_txdp;
+	void				*memblock;
+#ifdef VXGE_DEBUG_ASSERT
+	struct vxge_hw_mempool_dma		*dma_object;
+#endif
+};
+
+/*
+ * struct __hw_non_offload_db_wrapper - Non-offload Doorbell Wrapper
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
+struct __hw_non_offload_db_wrapper {
+	u64		control_0;
+#define	VXGE_HW_NODBW_GET_TYPE(ctrl0)				bVAL8(ctrl0, 0)
+#define VXGE_HW_NODBW_TYPE(val) vxge_vBIT(val, 0, 8)
+#define	VXGE_HW_NODBW_TYPE_NODBW				0
+
+#define	VXGE_HW_NODBW_GET_LAST_TXD_NUMBER(ctrl0)		bVAL8(ctrl0, 32)
+#define VXGE_HW_NODBW_LAST_TXD_NUMBER(val) vxge_vBIT(val, 32, 8)
+
+#define	VXGE_HW_NODBW_GET_NO_SNOOP(ctrl0)			bVAL8(ctrl0, 56)
+#define VXGE_HW_NODBW_LIST_NO_SNOOP(val) vxge_vBIT(val, 56, 8)
+#define	VXGE_HW_NODBW_LIST_NO_SNOOP_TXD_READ_TXD0_WRITE		0x2
+#define	VXGE_HW_NODBW_LIST_NO_SNOOP_TX_FRAME_DATA_READ		0x1
+
+	u64		txdl_ptr;
+};
+
+/**
+ * struct __hw_messaging_db_wrapper - Messaging Doorbell Wrapper
+ * @control_0: Bits 0 to 7 - Doorbell type.
+ *             Bits 8 to 31 - Reserved.
+ *             Bits 32 to 63 - The number of new message bytes made available
+ *                             by this doorbell entry.
+ * @control_1: Bits 0 to 7 - Reserved.
+ *	       Bits 8 to 15 - The number of Immediate messaging bytes included
+ *                            in this doorbell.
+ *             Bits 16 to 63 - Reserved.
+ *
+ * Created by the host and written to the adapter via PIO to a Kernel Doorbell
+ * FIFO. All message doorbell wrapper fields must be written by the host as
+ * part of a doorbell write. Consumed by the adapter but not written by adapter.
+ */
+struct __hw_messaging_db_wrapper {
+	u64		control_0;
+#define	VXGE_HW_MDBW_GET_TYPE(ctrl0)				bVAL8(ctrl0, 0)
+#define VXGE_HW_MDBW_TYPE(val) vxge_vBIT(val, 0, 8)
+#define	VXGE_HW_MDBW_TYPE_MDBW					3
+
+#define	VXGE_HW_MDBW_GET_MESSAGE_BYTE_COUNT(ctrl0)	bVAL32(ctrl0, 32)
+#define VXGE_HW_MDBW_MESSAGE_BYTE_COUNT(val) vxge_vBIT(val, 32, 32)
+
+	u64		control_1;
+#define	VXGE_HW_MDBW_GET_IMMEDIATE_BYTE_COUNT(ctrl1)		bVAL8(ctrl1, 8)
+#define VXGE_HW_MDBW_IMMEDIATE_BYTE_COUNT(val) vxge_vBIT(val, 8, 8)
+
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
+#define VXGE_HW_FIFO_TXD_LIST_OWN_GET(ctrl0)		bVAL1(ctrl0, 7)
+#define VXGE_HW_FIFO_TXD_LIST_OWN_ADAPTER		vxge_mBIT(7)
+
+#define VXGE_HW_FIFO_TXD_T_CODE_GET(ctrl0)		bVAL4(ctrl0, 12)
+#define VXGE_HW_FIFO_TXD_T_CODE(val) vxge_vBIT(val, 12, 4)
+#define VXGE_HW_FIFO_TXD_T_CODE_OK		 VXGE_HW_FIFO_T_CODE_OK
+#define VXGE_HW_FIFO_TXD_T_CODE_PCI_READ_CORRUPT \
+				VXGE_HW_FIFO_T_CODE_PCI_READ_CORRUPT
+#define VXGE_HW_FIFO_TXD_T_CODE_PCI_READ_FAIL \
+				VXGE_HW_FIFO_T_CODE_PCI_READ_FAIL
+#define VXGE_HW_FIFO_TXD_T_CODE_INVALID_MSS VXGE_HW_FIFO_T_CODE_INVALID_MSS
+#define VXGE_HW_FIFO_TXD_T_CODE_LSO_ERROR VXGE_HW_FIFO_T_CODE_LSO_ERROR
+#define VXGE_HW_FIFO_TXD_T_CODE_UNUSED		VXGE_HW_FIFO_T_CODE_UNUSED
+#define VXGE_HW_FIFO_TXD_T_CODE_MULTI_ERROR VXGE_HW_FIFO_T_CODE_MULTI_ERROR
+
+#define VXGE_HW_FIFO_TXD_HOST_STEER_GET(ctrl0)		bVAL2(ctrl0, 16)
+#define VXGE_HW_FIFO_TXD_HOST_STEER(val) vxge_vBIT(val, 16, 2)
+#define VXGE_HW_FIFO_TXD_HOST_STEER_NORMAL	VXGE_HW_FIFO_HOST_STEER_NORMAL
+#define VXGE_HW_FIFO_TXD_HOST_STEER_PORT1	VXGE_HW_FIFO_HOST_STEER_PORT1
+#define VXGE_HW_FIFO_TXD_HOST_STEER_PORT0	VXGE_HW_FIFO_HOST_STEER_PORT0
+#define VXGE_HW_FIFO_TXD_HOST_STEER_BOTH	VXGE_HW_FIFO_HOST_STEER_BOTH
+
+#define VXGE_HW_FIFO_TXD_GATHER_CODE_GET(ctrl0)	bVAL2(ctrl0, 22)
+#define VXGE_HW_FIFO_TXD_GATHER_CODE(val) vxge_vBIT(val, 22, 2)
+#define VXGE_HW_FIFO_TXD_GATHER_CODE_FIRST	VXGE_HW_FIFO_GATHER_CODE_FIRST
+#define VXGE_HW_FIFO_TXD_GATHER_CODE_MIDDLE	VXGE_HW_FIFO_GATHER_CODE_MIDDLE
+#define VXGE_HW_FIFO_TXD_GATHER_CODE_LAST	VXGE_HW_FIFO_GATHER_CODE_LAST
+#define VXGE_HW_FIFO_TXD_GATHER_CODE_FIRST_LAST \
+					VXGE_HW_FIFO_GATHER_CODE_FIRST_LAST
+
+#define VXGE_HW_FIFO_TXD_LSO_FRM_ENCAP_GET(ctrl0)	bVAL2(ctrl0, 28)
+#define VXGE_HW_FIFO_TXD_LSO_FRM_ENCAP(val) vxge_vBIT(val, 28, 2)
+#define VXGE_HW_FIFO_TXD_LSO_FRM_ENCAP_AUTO	VXGE_HW_FIFO_LSO_FRM_ENCAP_AUTO
+#define VXGE_HW_FIFO_TXD_LSO_FRM_ENCAP_LLC	VXGE_HW_FIFO_LSO_FRM_ENCAP_LLC
+#define VXGE_HW_FIFO_TXD_LSO_FRM_ENCAP_SNAP	VXGE_HW_FIFO_LSO_FRM_ENCAP_SNAP
+#define VXGE_HW_FIFO_TXD_LSO_FRM_ENCAP_DIX	VXGE_HW_FIFO_LSO_FRM_ENCAP_DIX
+
+#define VXGE_HW_FIFO_TXD_LSO_FLAG_GET(ctrl0)		bVAL1(ctrl0, 30)
+#define VXGE_HW_FIFO_TXD_LSO_EN				vxge_mBIT(30)
+
+#define VXGE_HW_FIFO_TXD_LSO_MSS_GET(ctrl0)		bVAL14(ctrl0, 34)
+#define VXGE_HW_FIFO_TXD_LSO_MSS(val) vxge_vBIT(val, 34, 14)
+
+#define VXGE_HW_FIFO_TXD_BUFFER_SIZE_GET(ctrl0)	bVAL16(ctrl0, 48)
+#define VXGE_HW_FIFO_TXD_BUFFER_SIZE(val) vxge_vBIT(val, 48, 16)
+
+#define VXGE_HW_FIFO_TXD_LSO_BYTES_SENT_GET(ctrl0)	bVAL32(ctrl0, 32)
+#define VXGE_HW_FIFO_TXD_LSO_BYTES_SENT(val) vxge_vBIT(val, 32, 32)
+
+	u64 control_1;
+#define VXGE_HW_FIFO_TXD_TX_CKO_IPV4_EN_GET(ctrl1)	bVAL1(ctrl1, 5)
+#define VXGE_HW_FIFO_TXD_TX_CKO_IPV4_EN		vxge_mBIT(5)
+
+#define VXGE_HW_FIFO_TXD_TX_CKO_TCP_EN_GET(ctrl1)	bVAL1(ctrl1, 6)
+#define VXGE_HW_FIFO_TXD_TX_CKO_TCP_EN			vxge_mBIT(6)
+
+#define VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN_GET(ctrl1)	bVAL1(ctrl1, 7)
+#define VXGE_HW_FIFO_TXD_TX_CKO_UDP_EN			vxge_mBIT(7)
+
+#define VXGE_HW_FIFO_TXD_TX_CKO_CONTROL	(vxge_mBIT(5)|vxge_mBIT(6)|vxge_mBIT(7))
+
+#define VXGE_HW_FIFO_TXD_VLAN_ENABLE_GET(ctrl1)	bVAL1(ctrl1, 15)
+#define VXGE_HW_FIFO_TXD_VLAN_ENABLE				vxge_mBIT(15)
+
+#define VXGE_HW_FIFO_TXD_VLAN_TAG_GET(ctrl1)		bVAL16(ctrl1, 16)
+#define VXGE_HW_FIFO_TXD_VLAN_TAG(val) vxge_vBIT(val, 16, 16)
+
+#define VXGE_HW_FIFO_TXD_INT_NUMBER_GET(ctrl1)		bVAL6(ctrl1, 34)
+#define VXGE_HW_FIFO_TXD_INT_NUMBER(val) vxge_vBIT(val, 34, 6)
+
+#define VXGE_HW_FIFO_TXD_NO_BW_LIMIT_GET(ctrl1)	bVAL1(ctrl1, 43)
+#define VXGE_HW_FIFO_TXD_NO_BW_LIMIT			vxge_mBIT(43)
+
+#define VXGE_HW_FIFO_TXD_INT_TYPE_PER_LIST_GET(ctrl1)	bVAL1(ctrl1, 46)
+#define VXGE_HW_FIFO_TXD_INT_TYPE_PER_LIST		vxge_mBIT(46)
+
+#define VXGE_HW_FIFO_TXD_INT_TYPE_UTILZ_GET(ctrl1)	bVAL1(ctrl1, 47)
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
+#define VXGE_HW_RING_RXD_RTH_BUCKET_GET(ctrl0)			bVAL7(ctrl0, 0)
+#define VXGE_HW_RING_RXD_RTH_BUCKET_ADAPTER vxge_vBIT(val, 0, 7)
+
+#define VXGE_HW_RING_RXD_LIST_OWN_GET(ctrl0)			bVAL1(ctrl0, 7)
+#define VXGE_HW_RING_RXD_LIST_OWN_ADAPTER			vxge_mBIT(7)
+
+#define VXGE_HW_RING_RXD_FAST_PATH_ELIGIBLE_GET(ctrl0)		bVAL1(ctrl0, 8)
+#define VXGE_HW_RING_RXD_FAST_PATH_ELIGIBLE			vxge_mBIT(8)
+
+#define VXGE_HW_RING_RXD_L3_CKSUM_CORRECT_GET(ctrl0)		bVAL1(ctrl0, 9)
+#define VXGE_HW_RING_RXD_L3_CKSUM_CORRECT			vxge_mBIT(9)
+
+#define VXGE_HW_RING_RXD_L4_CKSUM_CORRECT_GET(ctrl0)		bVAL1(ctrl0, 10)
+#define VXGE_HW_RING_RXD_L4_CKSUM_CORRECT			vxge_mBIT(10)
+
+#define VXGE_HW_RING_RXD_T_CODE_GET(ctrl0)			bVAL4(ctrl0, 12)
+#define VXGE_HW_RING_RXD_T_CODE(val) vxge_vBIT(val, 12, 4)
+#define VXGE_HW_RING_RXD_T_CODE_OK	             VXGE_HW_RING_T_CODE_OK
+#define VXGE_HW_RING_RXD_T_CODE_L3_CKSUM_MISMATCH \
+					VXGE_HW_RING_T_CODE_L3_CKSUM_MISMATCH
+#define VXGE_HW_RING_RXD_T_CODE_L4_CKSUM_MISMATCH \
+					VXGE_HW_RING_T_CODE_L4_CKSUM_MISMATCH
+#define VXGE_HW_RING_RXD_T_CODE_L3_L4_CKSUM_MISMATCH \
+				VXGE_HW_RING_T_CODE_L3_L4_CKSUM_MISMATCH
+#define VXGE_HW_RING_RXD_T_CODE_L3_PKT_ERR	VXGE_HW_RING_T_CODE_L3_PKT_ERR
+#define VXGE_HW_RING_RXD_T_CODE_L2_FRM_ERR     VXGE_HW_RING_T_CODE_L2_FRM_ERR
+#define VXGE_HW_RING_RXD_T_CODE_BUF_SIZE_ERR \
+					VXGE_HW_RING_T_CODE_BUF_SIZE_ERR
+#define VXGE_HW_RING_RXD_T_CODE_INT_ECC_ERR	VXGE_HW_RING_T_CODE_INT_ECC_ERR
+#define VXGE_HW_RING_RXD_T_CODE_BENIGN_OVFLOW \
+					VXGE_HW_RING_T_CODE_BENIGN_OVFLOW
+#define VXGE_HW_RING_RXD_T_CODE_ZERO_LEN_BUFF \
+					VXGE_HW_RING_T_CODE_ZERO_LEN_BUFF
+#define VXGE_HW_RING_RXD_T_CODE_FRM_DROP     VXGE_HW_RING_T_CODE_FRM_DROP
+#define VXGE_HW_RING_RXD_T_CODE_UNUSED		VXGE_HW_RING_T_CODE_UNUSED
+#define VXGE_HW_RING_RXD_T_CODE_MULTI_ERR	VXGE_HW_RING_T_CODE_MULTI_ERR
+
+#define VXGE_HW_RING_RXD_SYN_GET(ctrl0)		bVAL1(ctrl0, 16)
+#define VXGE_HW_RING_RXD_SYN				vxge_mBIT(16)
+
+#define VXGE_HW_RING_RXD_IS_ICMP_GET(ctrl0)		bVAL1(ctrl0, 17)
+#define VXGE_HW_RING_RXD_IS_ICMP				vxge_mBIT(17)
+
+#define VXGE_HW_RING_RXD_RTH_SPDM_HIT_GET(ctrl0)		bVAL1(ctrl0, 18)
+#define VXGE_HW_RING_RXD_RTH_SPDM_HIT				vxge_mBIT(18)
+
+#define VXGE_HW_RING_RXD_RTH_IT_HIT_GET(ctrl0)			bVAL1(ctrl0, 19)
+#define VXGE_HW_RING_RXD_RTH_IT_HIT				vxge_mBIT(19)
+
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_GET(ctrl0)		bVAL4(ctrl0, 20)
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE(val) vxge_vBIT(val, 20, 4)
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_NONE	VXGE_HW_RING_HASH_TYPE_NONE
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_TCP_IPV4 \
+						VXGE_HW_RING_HASH_TYPE_TCP_IPV4
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_UDP_IPV4 \
+					VXGE_HW_RING_HASH_TYPE_UDP_IPV4
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_IPV4	VXGE_HW_RING_HASH_TYPE_IPV4
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_TCP_IPV6 \
+					VXGE_HW_RING_HASH_TYPE_TCP_IPV6
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_UDP_IPV6 \
+					VXGE_HW_RING_HASH_TYPE_UDP_IPV6
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_IPV6	VXGE_HW_RING_HASH_TYPE_IPV6
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_TCP_IPV6_EX \
+					VXGE_HW_RING_HASH_TYPE_TCP_IPV6_EX
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_UDP_IPV6_EX \
+					     VXGE_HW_RING_HASH_TYPE_UDP_IPV6_EX
+#define VXGE_HW_RING_RXD_RTH_HASH_TYPE_IPV6_EX	VXGE_HW_RING_HASH_TYPE_IPV6_EX
+
+#define VXGE_HW_RING_RXD_IS_VLAN_GET(ctrl0)		bVAL1(ctrl0, 24)
+#define VXGE_HW_RING_RXD_IS_VLAN				vxge_mBIT(24)
+
+#define VXGE_HW_RING_RXD_ETHER_ENCAP_GET(ctrl0)	bVAL2(ctrl0, 25)
+#define VXGE_HW_RING_RXD_ETHER_ENCAP(val) vxge_vBIT(val, 25, 2)
+#define VXGE_HW_RING_RXD_ETHER_ENCAP_DIX		VXGE_HW_FRAME_TYPE_DIX
+#define VXGE_HW_RING_RXD_ETHER_ENCAP_LLC		VXGE_HW_FRAME_TYPE_LLC
+#define VXGE_HW_RING_RXD_ETHER_ENCAP_SNAP		VXGE_HW_FRAME_TYPE_SNAP
+#define VXGE_HW_RING_RXD_ETHER_ENCAP_IPX		VXGE_HW_FRAME_TYPE_IPX
+
+#define VXGE_HW_RING_RXD_IS_IPV4_GET(ctrl0)			bVAL1(ctrl0, 27)
+#define VXGE_HW_RING_RXD_IS_IPV4				vxge_mBIT(27)
+
+#define VXGE_HW_RING_RXD_IS_IPV6_GET(ctrl0)			bVAL1(ctrl0, 28)
+#define VXGE_HW_RING_RXD_IS_IPV6				vxge_mBIT(28)
+
+#define VXGE_HW_RING_RXD_IS_IPV_FRAG_GET(ctrl0)		bVAL1(ctrl0, 29)
+#define VXGE_HW_RING_RXD_IS_IPV_FRAG				vxge_mBIT(29)
+
+#define VXGE_HW_RING_RXD_IS_TCP_GET(ctrl0)			bVAL1(ctrl0, 30)
+#define VXGE_HW_RING_RXD_IS_TCP					vxge_mBIT(30)
+
+#define VXGE_HW_RING_RXD_IS_UDP_GET(ctrl0)			bVAL1(ctrl0, 31)
+#define VXGE_HW_RING_RXD_IS_UDP					vxge_mBIT(31)
+
+#define VXGE_HW_RING_RXD_FRAME_PROTO_GET(ctrl0)		bVAL5(ctrl0, 27)
+#define VXGE_HW_RING_RXD_FRAME_PROTO(val) vxge_vBIT(val, 27, 5)
+#define VXGE_HW_RING_RXD_FRAME_PROTO_IPV4	     VXGE_HW_FRAME_PROTO_IPV4
+#define VXGE_HW_RING_RXD_FRAME_PROTO_IPV6	     VXGE_HW_FRAME_PROTO_IPV6
+#define VXGE_HW_RING_RXD_FRAME_PROTO_IP_FRAG     VXGE_HW_FRAME_PROTO_IP_FRAG
+#define VXGE_HW_RING_RXD_FRAME_PROTO_TCP	     VXGE_HW_FRAME_PROTO_TCP
+#define VXGE_HW_RING_RXD_FRAME_PROTO_UDP	     VXGE_HW_FRAME_PROTO_UDP
+#define VXGE_HW_RING_RXD_FRAME_PROTO_TCP_OR_UDP \
+						(VXGE_HW_FRAME_PROTO_TCP | \
+						     VXGE_HW_FRAME_PROTO_UDP)
+
+#define VXGE_HW_RING_RXD_L3_CKSUM_GET(ctrl0)		bVAL16(ctrl0, 32)
+#define VXGE_HW_RING_RXD_L3_CKSUM(val) vxge_vBIT(val, 32, 16)
+
+#define VXGE_HW_RING_RXD_L4_CKSUM_GET(ctrl0)		bVAL16(ctrl0, 48)
+#define VXGE_HW_RING_RXD_L4_CKSUM(val) vxge_vBIT(val, 48, 16)
+
+	u64 control_1;
+#define VXGE_HW_RING_RXD_LIST_TAIL_OWN_ADAPTER		vxge_mBIT(0)
+
+#define VXGE_HW_RING_RXD_1_BUFFER0_SIZE_GET(ctrl1)	bVAL14(ctrl1, 2)
+#define VXGE_HW_RING_RXD_1_BUFFER0_SIZE(val) vxge_vBIT(val, 2, 14)
+#define VXGE_HW_RING_RXD_1_BUFFER0_SIZE_MASK	        vxge_vBIT(0x3FFF, 2, 14)
+
+#define VXGE_HW_RING_RXD_1_RTH_HASH_VAL_GET(ctrl1)	bVAL32(ctrl1, 16)
+#define VXGE_HW_RING_RXD_1_RTH_HASH_VAL(val) vxge_vBIT(val, 16, 32)
+
+#define VXGE_HW_RING_RXD_VLAN_TAG_GET(ctrl1)		bVAL16(ctrl1, 48)
+#define VXGE_HW_RING_RXD_VLAN_TAG(val) vxge_vBIT(val, 48, 16)
+
+	u64 buffer0_ptr;
+
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
+__EXTERN_BEGIN_DECLS
+
+u32
+vxge_hw_device_debug_level_get(struct __hw_device *devh);
+
+u32
+vxge_hw_device_debug_mask_get(struct __hw_device *devh);
+
+void vxge_hw_device_debug_set(
+	struct __hw_device *devh,
+	enum vxge_debug_level level,
+	u32 mask);
+
+u32
+vxge_hw_device_debug_level_get(struct __hw_device *devh);
+
+u32
+vxge_hw_device_error_level_get(struct __hw_device *devh);
+
+u32
+vxge_hw_device_trace_level_get(struct __hw_device *devh);
+
+u32
+vxge_hw_device_debug_mask_get(struct __hw_device *devh);
+
+/**
+ * vxge_hw_ring_rxd_size_get	- Get the size of ring descriptor.
+ * @buf_mode: Buffer mode (1, 3 or 5)
+ *
+ * This function returns the size of RxD for given buffer mode
+ */
+static inline u32
+vxge_hw_ring_rxd_size_get(
+	u32 buf_mode)
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
+static inline u32
+vxge_hw_ring_rxds_per_block_get(
+	u32 buf_mode)
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
+	struct __hw_ring *ring_handle,
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
+	struct __hw_ring *ring_handle,
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
+
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
+static inline
+void *vxge_hw_ring_rxd_private_get(
+	void *rxdh)
+{
+	struct vxge_hw_ring_rxd_1 *rxdp = (struct vxge_hw_ring_rxd_1 *)rxdh;
+
+	return (void *)(ptr_t)rxdp->host_control;
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
+static inline
+void vxge_hw_fifo_txdl_cksum_set_bits(
+			void *txdlh,
+			u64 cksum_bits)
+{
+	struct vxge_hw_fifo_txd *txdp = (struct vxge_hw_fifo_txd *)txdlh;
+
+	txdp->control_1 |= cksum_bits;
+
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
+static inline
+void vxge_hw_fifo_txdl_mss_set(
+			void *txdlh,
+			int mss)
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
+static inline
+void vxge_hw_fifo_txdl_vlan_set(
+	void *txdlh,
+	u16 vlan_tag)
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
+static inline
+void *vxge_hw_fifo_txdl_private_get(
+	void *txdlh)
+{
+	struct vxge_hw_fifo_txd *txdp  = (struct vxge_hw_fifo_txd *)txdlh;
+
+	return (void *)(ptr_t)txdp->host_control;
+
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
+			struct __hw_ring *ringh,
+			void *rxdh,
+			u8 t_code,
+			void *userdata);
+
+	enum vxge_hw_status (*rxd_init)(
+			void *rxdh,
+			u32 index,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+
+	void (*rxd_term)(
+			void *rxdh,
+			enum vxge_hw_rxd_state state,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+	void			*userdata;
+	u32				per_rxd_space;
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
+
+/**
+ * function vxge_hw_fifo_txdl_init_f - Initialize descriptor callback.
+ * @vpath_handle: Virtual path whose Fifo "containing" the @txdlh descriptor.
+ * @txdlh: Descriptor.
+ * @txdl_priv: Pointer to per txdl space allocated
+ * @index: Index of the descriptor in the fifo's set of descriptors.
+ * @userdata: Per-fifo user data (a.k.a. context) specified at
+ * fifo open time, via vxge_hw_vpath_open().
+ * @reopen: See  enum vxge_hw_reopen{}.
+ *
+ * Initialize descriptor callback. Unless NULL is specified in the
+ * struct vxge_hw_fifo_attr{} structure passed to vxge_hw_vpath_open()),
+ * HW invokes the callback as part of the vxge_hw_vpath_open()
+ * implementation.
+ * The driver could use the callback to pre-set DMA mappings and/or alignment
+ * buffers.
+ *
+ * See also: struct vxge_hw_fifo_attr{}, vxge_hw_fifo_txdl_term_f{}.
+ */
+
+/**
+ * function vxge_hw_fifo_txdl_term_f - Terminate descriptor callback.
+ * @txdlh: First completed descriptor.
+ * @txdl_priv: Pointer to per txdl space allocated
+ * @state: One of the enum vxge_hw_txdl_state{} enumerated states.
+ * @userdata: Per-fifo user data (a.k.a. context) specified at
+ * fifo open time, via vxge_hw_vpath_open().
+ * @reopen: See  enum vxge_hw_reopen{}.
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
+ * See also: struct vxge_hw_fifo_attr{}, vxge_hw_fifo_txdl_init_f{}.
+ */
+/**
+ * struct vxge_hw_fifo_attr - Fifo open "template".
+ * @callback: Fifo completion callback. HW invokes the callback when there
+ *            are new completions on that fifo. In many implementations
+ *            the @callback executes in the hw interrupt context.
+ * @txdl_init: Fifo's descriptor-initialize callback.
+ *            See vxge_hw_fifo_txdl_init_f{}.
+ *            If not NULL, HW invokes the callback when opening
+ *            the fifo via vxge_hw_vpath_open().
+ * @txdl_term: Fifo's descriptor-terminate callback. If not NULL,
+ *          HW invokes the callback when closing the corresponding fifo.
+ *          See also vxge_hw_fifo_txdl_term_f{}.
+ * @userdata: User-defined "context" of _that_ fifo. Passed back to the
+ *            user as one of the @callback, @txdl_init and @txdl_term arguments.
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
+			struct __hw_fifo *fifo_handle,
+			void *txdlh,
+			void *txdl_priv,
+			enum vxge_hw_fifo_tcode t_code,
+			void *userdata,
+			void **skb_ptr);
+
+	enum vxge_hw_status (*txdl_init)(
+			struct __hw_vpath_handle *vpath_handle,
+			void *txdlh,
+			void *txdl_priv,
+			u32 index,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+
+	void (*txdl_term)(
+			void *txdlh,
+			void *txdl_priv,
+			enum vxge_hw_txdl_state state,
+			void *userdata,
+			enum vxge_hw_reopen reopen);
+	void				*userdata;
+	u32				per_txdl_space;
+};
+__EXTERN_END_DECLS
+
+/**
+ * struct vxge_hw_vpath_attr - Attributes of virtual path
+ * @vp_id: Identifier of Virtual Path
+ * @ring_attr: Attributes of ring for non-offload receive
+ * @fifo_attr: Attributes of fifo for non-offload transmit
+ *
+ * Attributes of virtual path.  This structure is passed as parameter
+ * to the vxge_hw_vpath_open() routine to set the attributes of DMQ, UMQ,
+ * ring and fifo. After virtual path is open, iWARP/RDMA module can attach
+ * to virtual path.
+ */
+struct vxge_hw_vpath_attr {
+	u32				vp_id;
+	struct vxge_hw_ring_attr	ring_attr;
+	struct vxge_hw_fifo_attr	fifo_attr;
+};
+
+__EXTERN_BEGIN_DECLS
+
+enum vxge_hw_status
+__hw_blockpool_create(struct __hw_device *hldev,
+			struct __hw_blockpool  *blockpool,
+			u32 pool_size,
+			u32 pool_incr,
+			u32 pool_min,
+			u32 pool_max);
+
+void
+__hw_blockpool_destroy(struct __hw_blockpool  *blockpool);
+
+struct __hw_blockpool_entry *
+__hw_blockpool_block_allocate(struct __hw_device *hldev,
+			u32 size);
+
+void
+__hw_blockpool_block_free(struct __hw_device *hldev,
+			struct __hw_blockpool_entry *entry);
+
+void *
+__hw_blockpool_malloc(struct __hw_device *hldev,
+			u32 size,
+			dma_addr_t *dma_addr,
+			struct pci_dev **dma_handle,
+			struct pci_dev **acc_handle);
+
+void
+__hw_blockpool_free(struct __hw_device *hldev,
+			void *memblock,
+			u32 size,
+			dma_addr_t *dma_addr,
+			struct pci_dev **dma_handle,
+			struct pci_dev **acc_handle);
+
+enum vxge_hw_status
+__hw_device_ring_config_check(struct vxge_hw_ring_config *ring_config);
+
+enum vxge_hw_status
+__hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config);
+
+enum vxge_hw_status
+__hw_device_tim_intr_config_check(struct vxge_hw_tim_intr_config
+					*tim_intr_config);
+enum vxge_hw_status
+__hw_device_config_check(struct vxge_hw_device_config *new_config);
+
+enum vxge_hw_status
+vxge_hw_mgmt_device_config(struct __hw_device *devh,
+		struct vxge_hw_device_config	*dev_config, int size);
+
+enum vxge_hw_status vxge_hw_device_hw_info_get(
+	u8		*bar0,
+	struct vxge_hw_device_hw_info *hw_info);
+
+enum vxge_hw_status vxge_hw_device_config_default_get(
+	struct vxge_hw_device_config *device_config);
+
+/**
+ * vxge_hw_device_pci_info_get - Get PCI bus informations such as width,
+ *			 frequency, and mode from previously stored values.
+ * @devh:		HW device handle.
+ * @signalling_rate:	pointer to a variable of enumerated type
+ *			enum vxge_hw_pci_e_signalling_rate{}.
+ * @link_width:		pointer to a variable of enumerated type
+ *			enum vxge_hw_pci_e_link_width{}.
+ *
+ * Get pci-e signalling rate and link width.
+ *
+ * Returns: one of the enum vxge_hw_status{} enumerated types.
+ * VXGE_HW_OK			- for success.
+ * VXGE_HW_ERR_INVALID_DEVICE	- for invalid device handle.
+ */
+static inline
+enum vxge_hw_status vxge_hw_device_pci_info_get(struct __hw_device *devh,
+	enum vxge_hw_pci_e_signalling_rate *signalling_rate,
+	enum vxge_hw_pci_e_link_width *link_width)
+{
+	struct __hw_device  *hldev = (struct __hw_device  *)devh;
+
+	if (!hldev || !hldev->is_initialized ||
+			(hldev->magic != VXGE_HW_DEVICE_MAGIC)) {
+		return  VXGE_HW_ERR_INVALID_DEVICE;
+	}
+
+	*signalling_rate	= hldev->signalling_rate;
+	*link_width		= hldev->link_width;
+
+	return VXGE_HW_OK;
+}
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
+	struct __hw_device *devh)
+{
+	return ((struct __hw_device  *)devh)->link_state;
+}
+
+/**
+ * vxge_hw_device_data_rate_get - Get data rate.
+ * @devh: HW device handle.
+ *
+ * Get data rate.
+ * Returns: data rate(1G or 10G).
+ */
+static inline
+enum vxge_hw_device_data_rate vxge_hw_device_data_rate_get(
+	struct __hw_device *devh)
+{
+	return ((struct __hw_device  *)devh)->data_rate;
+}
+
+void vxge_hw_device_private_set(struct __hw_device *devh, void *data);
+
+void vxge_hw_device_terminate(struct __hw_device *devh);
+
+const u8 *
+vxge_hw_device_serial_number_get(struct __hw_device *devh);
+
+u8
+vxge_hw_device_link_width_get(struct __hw_device *devh);
+
+const u8 *
+vxge_hw_device_product_name_get(struct __hw_device *devh);
+
+enum vxge_hw_status vxge_hw_device_initialize(
+	struct __hw_device **devh,
+	struct vxge_hw_device_attr *attr,
+	struct vxge_hw_device_config *device_config);
+
+enum vxge_hw_status vxge_hw_device_getpause_data(
+	 struct __hw_device *devh,
+	 u32 port,
+	 u32 *tx,
+	 u32 *rx);
+
+enum vxge_hw_status vxge_hw_device_setpause_data(
+	struct __hw_device *devh,
+	u32 port,
+	u32 tx,
+	u32 rx);
+
+static inline void *__vxge_os_dma_malloc(struct pci_dev *pdev,
+			unsigned long size,
+			int dma_flags, struct pci_dev **p_dmah,
+			struct pci_dev **p_dma_acch, char *file, int line)
+{
+	int flags;
+	void *vaddr;
+	unsigned long misaligned = 0;
+	*p_dma_acch = *p_dmah = NULL;
+
+	flags = in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
+	flags |= GFP_DMA;
+
+	size += VXGE_CACHE_LINE_SIZE;
+
+	vaddr = kmalloc((size), flags);
+
+	if (vaddr != NULL)
+		*p_dma_acch = *p_dmah = 0; /* for dma_map(), dma_free() */
+	misaligned = (unsigned long)VXGE_ALIGN(*((u64 *)&vaddr),
+						VXGE_CACHE_LINE_SIZE);
+	*(unsigned long *)p_dma_acch = misaligned;
+	vaddr = (void *)((u8 *)vaddr + misaligned);
+	return vaddr;
+}
+
+#define vxge_os_dma_malloc(pdev, size, dma_flags, p_dmah, p_dma_acch) \
+	__vxge_os_dma_malloc(pdev, size, dma_flags, p_dmah, p_dma_acch, \
+			  __FILE__, __LINE__)
+
+extern void vxge_hw_blockpool_block_add(
+			struct __hw_device *devh,
+			void *block_addr,
+			u32 length,
+			struct pci_dev *dma_h,
+			struct pci_dev *acc_handle);
+
+static inline void vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh,
+					unsigned long size,
+					int dma_flags)
+{
+	int flags;
+	void *vaddr;
+
+	flags = in_interrupt() ? GFP_ATOMIC : GFP_KERNEL;
+	flags |= GFP_DMA;
+	vaddr = kmalloc((size), flags);
+
+	vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
+}
+
+static inline void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
+			int size,
+			int dma_flags,
+			struct pci_dev **p_dmah, struct pci_dev **p_dma_acch)
+{
+	unsigned long misaligned = *(unsigned long *)p_dma_acch;
+	u8 *tmp = (u8 *)vaddr;
+	tmp -= misaligned;
+	kfree((void *)tmp);
+}
+
+static inline int vxge_do_pci_dma_mapping_error(struct pci_dev *pdev,
+			dma_addr_t dma_addr)
+{
+
+	return pci_dma_mapping_error(pdev, dma_addr);
+
+}
+
+static inline dma_addr_t vxge_os_dma_map(struct pci_dev *pdev,
+				struct pci_dev *dmah,
+				void *vaddr, size_t size, int dir,
+				int dma_flags)
+{
+
+	return pci_map_single(pdev, vaddr, size, dir);
+
+}
+
+static inline void vxge_os_dma_unmap(struct pci_dev *pdev, struct pci_dev *dmah,
+			dma_addr_t dma_addr, size_t size, int dir)
+{
+
+	pci_unmap_single(pdev, dma_addr, size, dir);
+
+}
+
+/*
+ * __hw_mempool_item_priv - will return pointer on per item private space
+ */
+static inline void*
+__hw_mempool_item_priv(
+	struct vxge_hw_mempool *mempool,
+	u32 memblock_idx,
+	void *item,
+	u32 *memblock_item_idx)
+{
+	ptrdiff_t offset;
+	void *memblock = mempool->memblocks_arr[memblock_idx];
+
+	vxge_assert(memblock);
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
+/*
+ * __hw_mempool_memblock - will return pointer to the memblock in the
+ *  mempool memblocks array.
+ */
+static inline void*
+__hw_mempool_memblock(
+	struct vxge_hw_mempool *mempool,
+	u32 memblock_idx)
+{
+	vxge_assert(mempool->memblocks_arr[memblock_idx]);
+	return mempool->memblocks_arr[memblock_idx];
+}
+
+struct __hw_channel*
+__hw_channel_allocate(
+	struct __hw_device *devh,
+	struct __hw_vpath_handle *vph,
+	enum __hw_channel_type type,
+	u32 length,
+	u32 alloc_work_array,
+	u32 alloc_free_array,
+	u32 alloc_reserve_array,
+	u32 per_dtr_space,
+	void *userdata);
+
+void
+__hw_channel_free(
+	struct __hw_channel *channel);
+
+enum vxge_hw_status
+__hw_channel_initialize(
+	struct __hw_channel *channel);
+
+enum vxge_hw_status
+__hw_channel_reset(
+	struct __hw_channel *channel);
+
+/*
+ * __hw_fifo_txdl_priv - Return the max fragments allocated
+ * for the fifo.
+ * @fifo: Fifo
+ * @txdp: Poniter to a TxD
+ */
+static inline struct __hw_fifo_txdl_priv *
+__hw_fifo_txdl_priv(
+	struct __hw_fifo *fifo,
+	struct vxge_hw_fifo_txd *txdp)
+{
+	return (struct __hw_fifo_txdl_priv *)
+			(((char *)((ulong_t)txdp->host_control)) +
+				fifo->per_txdl_space);
+}
+
+enum vxge_hw_status vxge_hw_vpath_open(
+	struct __hw_device *devh,
+	struct vxge_hw_vpath_attr *attr,
+	void *client_handle,
+	struct __hw_vpath_handle **vpath_handle);
+
+enum vxge_hw_status
+__hw_device_vpath_reset_in_prog_check(u64 *vpath_rst_in_prog);
+
+enum vxge_hw_status vxge_hw_vpath_close(
+	struct __hw_vpath_handle *vpath_handle);
+
+enum vxge_hw_status
+vxge_hw_vpath_reset(
+	struct __hw_vpath_handle *vpath_handle);
+
+enum vxge_hw_status
+vxge_hw_vpath_recover_from_reset(
+	struct __hw_vpath_handle *vpath_handle);
+
+void
+vxge_hw_vpath_enable(struct __hw_vpath_handle *vp);
+
+enum vxge_hw_status
+vxge_hw_vpath_check_leak(struct __hw_ring *ringh);
+
+enum vxge_hw_status vxge_hw_vpath_mtu_set(
+	struct __hw_vpath_handle *vpath_handle,
+	u32 new_mtu);
+
+enum vxge_hw_status vxge_hw_vpath_stats_enable(
+	struct __hw_vpath_handle *vpath_handle);
+
+enum vxge_hw_status
+__hw_vpath_stats_access(
+	struct __hw_virtualpath	*vpath,
+	u32			operation,
+	u32			offset,
+	u64			*stat);
+
+enum vxge_hw_status
+__hw_vpath_xmac_tx_stats_get(
+	struct __hw_virtualpath	*vpath,
+	struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats);
+
+enum vxge_hw_status
+__hw_vpath_xmac_rx_stats_get(
+	struct __hw_virtualpath	*vpath,
+	struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats);
+
+enum vxge_hw_status
+__hw_vpath_stats_get(
+	struct __hw_virtualpath *vpath,
+	struct vxge_hw_vpath_stats_hw_info *hw_stats);
+
+void
+vxge_hw_vpath_rx_doorbell_init(struct __hw_vpath_handle *vp);
+
+enum vxge_hw_status
+__hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config);
+
+void
+__hw_device_pci_caps_list_process(struct __hw_device *hldev);
+
+void
+__hw_device_pci_e_init(struct __hw_device *hldev);
+
+enum vxge_hw_status
+__hw_device_register_poll(
+	u64		*reg,
+	u32		op,
+	u64		mask,
+	u32		max_millis);
+
+struct vxge_hw_toc_reg *
+__hw_device_toc_get(u8 *bar0);
+
+enum vxge_hw_status
+__hw_device_reg_addr_get(struct __hw_device *hldev);
+
+void
+__hw_device_id_get(struct __hw_device *hldev);
+
+void
+__hw_device_host_info_get(struct __hw_device *hldev);
+
+void
+__hw_device_get_vpd_data(struct __hw_device *hldev);
+
+enum vxge_hw_status
+__hw_device_initialize(struct __hw_device *hldev);
+
+enum vxge_hw_status
+__hw_device_mrpcim_stats_get(
+	struct __hw_device *hldev,
+	struct vxge_hw_device_stats_mrpcim_info *mrpcim_stats);
+
+enum vxge_hw_status vxge_hw_aux_device_config_read(struct __hw_device *devh,
+	int bufsize, char *retbuf, int *retsize);
+
+enum vxge_hw_status
+__hw_vpath_pci_read(
+	struct __hw_virtualpath	*vpath,
+	u32			phy_func_0,
+	u32			offset,
+	u32			*val);
+
+u32
+__hw_vpath_func_id_get(u32 vp_id, struct vxge_hw_vpmgmt_reg *vpmgmt_reg);
+
+enum vxge_hw_status
+__hw_vpath_reset_check(
+	struct __hw_virtualpath	*vpath);
+
+/**
+ * vxge_debug_osdep
+ * @level: level of debug verbosity.
+ * @fmt: printf like format string
+ *
+ * Provides logging facilities for OS Dependent functions. Can be customized
+ * with debug levels. Input parameters, except level, are the same
+ * as posix printf. This function may be compiled out if DEBUG macro
+ * was never defined.
+ * See also: enum vxge_debug_level{}.
+ */
+#if (VXGE_COMPONENT_OSDEP & VXGE_DEBUG_MODULE_MASK)
+#define vxge_debug_osdep(level, fmt, ...) \
+	vxge_debug(VXGE_COMPONENT_OSDEP, level, VXGE_DEBUG_MASK, \
+			fmt, __VA_ARGS__)
+#else
+#define vxge_debug_osdep(level, fmt, ...)
+#endif
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
+/**
+ * vxge_list_init - Initialize linked list.
+ * header: first element of the list (head)
+ *
+ * Initialize linked list.
+ * See also: struct vxge_list{}.
+ */
+static inline void vxge_list_init(struct vxge_list *header)
+{
+	vxge_assert(header != NULL);
+
+	header->next = header;
+	header->prev = header;
+}
+
+/**
+ * vxge_list_is_empty - Is the list empty?
+ * header: first element of the list (head)
+ *
+ * Determine whether the bi-directional list is empty. Return '1' in
+ * case of 'empty'.
+ * See also: struct vxge_list{}.
+ */
+static inline int vxge_list_is_empty(struct vxge_list *header)
+{
+	vxge_assert(header != NULL);
+
+	return header->next == header;
+}
+
+/**
+ * vxge_list_first_get - Return the first item from the linked list.
+ * header: first element of the list (head)
+ *
+ * Returns the next item from the header.
+ * Returns NULL if the next item is header itself
+ * See also: vxge_list_remove(), vxge_list_insert(), struct vxge_list{}.
+ */
+static inline struct vxge_list *vxge_list_first_get(struct vxge_list *header)
+{
+	vxge_assert(header != NULL);
+	vxge_assert(header->next != NULL);
+	vxge_assert(header->prev != NULL);
+
+	if (header->next == header)
+		return NULL;
+	else
+		return header->next;
+}
+
+/**
+ * vxge_list_remove - Remove the specified item from the linked list.
+ * item: element of the list
+ *
+ * Remove item from a list.
+ * See also: vxge_list_insert(), struct vxge_list{}.
+ */
+static inline void vxge_list_remove(struct vxge_list *item)
+{
+	vxge_assert(item != NULL);
+	vxge_assert(item->next != NULL);
+	vxge_assert(item->prev != NULL);
+
+	item->next->prev = item->prev;
+	item->prev->next = item->next;
+#ifdef VXGE_DEBUG_ASSERT
+	item->next = item->prev = NULL;
+#endif
+}
+
+/**
+ * vxge_list_insert - Insert a new item after the specified item.
+ * new_item: new element of the list
+ * prev_item: element of the list after which the new element is
+ *             inserted
+ *
+ * Insert new item (new_item) after given item (prev_item).
+ * See also: vxge_list_remove(), vxge_list_insert_before(), struct vxge_list{}.
+ */
+static inline void vxge_list_insert(struct vxge_list *new_item,
+				    struct vxge_list *prev_item)
+{
+	vxge_assert(new_item  != NULL);
+	vxge_assert(prev_item != NULL);
+	vxge_assert(prev_item->next != NULL);
+
+	new_item->next = prev_item->next;
+	new_item->prev = prev_item;
+	prev_item->next->prev = new_item;
+	prev_item->next = new_item;
+}
+
+#define vxge_list_for_each(_p, _h) \
+	for (_p = (_h)->next, prefetch(_p->next); _p != (_h); \
+		_p = _p->next, prefetch(_p->next))
+
+#define vxge_list_for_each_safe(_p, _n, _h) \
+	for (_p = (_h)->next, _n = _p->next; _p != (_h); \
+		_p = _n, _n = _p->next)
+
+enum vxge_hw_status vxge_hw_vpath_rts_rth_itable_set(
+			struct __hw_vpath_handle **vpath_handles,
+			u32 vpath_count,
+			u8 *mtable,
+			u8 *itable,
+			u32 itable_size);
+enum vxge_hw_status vxge_hw_vpath_rts_rth_set(
+	struct __hw_vpath_handle *vpath_handle,
+	enum vxge_hw_rth_algoritms algorithm,
+	struct vxge_hw_rth_hash_types *hash_type,
+	u16 bucket_size);
+
+enum vxge_hw_status  vxge_hw_vpath_rts_rth_jhash_cfg_set(
+	struct __hw_vpath_handle *vpath_handle,
+	u32 golden_ratio,
+	u32 init_value);
+
+enum vxge_hw_status  vxge_hw_vpath_rts_rth_jhash_cfg_get(
+	struct __hw_vpath_handle *vpath_handle,
+	u32 *golden_ratio,
+	u32 *init_value);
+
+enum vxge_hw_status vxge_hw_vpath_rts_rth_mask_set(
+	struct __hw_vpath_handle *vpath_handle,
+	u32 table_size,
+	u32 *hash_mask_ipv6sa,
+	u32 *hash_mask_ipv6da,
+	u32 *hash_mask_ipv4sa,
+	u32 *hash_mask_ipv4da,
+	u32 *hash_mask_l4sp,
+	u32 *hash_mask_l4dp);
+
+/**
+ * vxge_hw_device_stats_clear - Clear the statistics of the device
+ * @devh: HW Device handle.
+ *
+ * Clear the statistics of the given Device.
+ *
+ */
+static inline
+enum vxge_hw_status vxge_hw_device_stats_clear(
+	struct __hw_device *devh)
+{
+	u64 stat;
+
+	return vxge_hw_mrpcim_stats_access(
+				devh,
+				VXGE_HW_STATS_OP_CLEAR_ALL_STATS,
+				0,
+				0,
+				&stat);
+}
+
+/**
+ * vxge_hw_vpath_stats_clear - Clear all the statistics of vpath
+ * @vpath_handle: Virtual path handle.
+ *
+ * Clear the statistics of the given vpath.
+ *
+ */
+static inline
+enum vxge_hw_status vxge_hw_vpath_stats_clear(
+	struct __hw_vpath_handle *vpath_handle)
+{
+	u64 stat;
+
+	return __hw_vpath_stats_access(
+				vpath_handle->vpath,
+				VXGE_HW_STATS_OP_CLEAR_ALL_VPATH_STATS,
+				0,
+				&stat);
+}
+
+__EXTERN_END_DECLS
+#endif



