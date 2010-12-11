From: Jon Mason <jon.mason@exar.com>
Subject: [PATCH 1/7] vxge: code cleanup and reorganization
Date: Fri, 10 Dec 2010 18:02:56 -0600
Message-ID: <1292025782-16372-1-git-send-email-jon.mason@exar.com>
Cc: netdev@vger.kernel.org,
	Sivakumar Subramani <sivakumar.subramani@exar.com>,
	Sreenivasa Honnur <sreenivasa.honnur@exar.com>,
	Ram Vepa <ram.vepa@exar.com>,
	Arpit Patel <arpit.patel@exar.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:45252 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686Ab0LKADL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 19:03:11 -0500
Received: by ywl5 with SMTP id 5so2401509ywl.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 16:03:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move function locations to remove the need for internal declarations and
other misc clean-ups.

Signed-off-by: Jon Mason <jon.mason@exar.com>
Signed-off-by: Arpit Patel <arpit.patel@exar.com>
---
 drivers/net/vxge/vxge-config.c  | 2481 +++++++++++++++++++--------------------
 drivers/net/vxge/vxge-config.h  |   34 +-
 drivers/net/vxge/vxge-main.c    |  474 ++++----
 drivers/net/vxge/vxge-main.h    |    8 +-
 drivers/net/vxge/vxge-traffic.c |  773 ++++++-------
 drivers/net/vxge/vxge-traffic.h |   21 +-
 6 files changed, 1812 insertions(+), 1979 deletions(-)

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index a0241fe..1169aa3 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -21,100 +21,15 @@
 #include "vxge-config.h"
 #include "vxge-main.h"
 
-static enum vxge_hw_status
-__vxge_hw_fifo_delete(
-	struct __vxge_hw_vpath_handle *vpath_handle);
-
-static struct __vxge_hw_blockpool_entry *
-__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *hldev,
-			u32 size);
-
-static void
-__vxge_hw_blockpool_block_free(struct __vxge_hw_device *hldev,
-			struct __vxge_hw_blockpool_entry *entry);
-
-static void vxge_hw_blockpool_block_add(struct __vxge_hw_device *devh,
-					void *block_addr,
-					u32 length,
-					struct pci_dev *dma_h,
-					struct pci_dev *acc_handle);
-
-static enum vxge_hw_status
-__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
-			struct __vxge_hw_blockpool  *blockpool,
-			u32 pool_size,
-			u32 pool_max);
-
-static void
-__vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool  *blockpool);
-
-static void *
-__vxge_hw_blockpool_malloc(struct __vxge_hw_device *hldev,
-			u32 size,
-			struct vxge_hw_mempool_dma *dma_object);
-
-static void
-__vxge_hw_blockpool_free(struct __vxge_hw_device *hldev,
-			void *memblock,
-			u32 size,
-			struct vxge_hw_mempool_dma *dma_object);
-
-static void
-__vxge_hw_channel_free(
-	struct __vxge_hw_channel *channel);
-
-static enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp);
-
-static enum vxge_hw_status
-__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config);
-
-static enum vxge_hw_status
-__vxge_hw_device_register_poll(
-	void __iomem	*reg,
-	u64 mask, u32 max_millis);
-
-static inline enum vxge_hw_status
-__vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
-			  u64 mask, u32 max_millis)
-{
-	__vxge_hw_pio_mem_write32_lower((u32)vxge_bVALn(val64, 32, 32), addr);
-	wmb();
-
-	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32), addr);
-	wmb();
-
-	return  __vxge_hw_device_register_poll(addr, mask, max_millis);
+#define VXGE_HW_VPATH_STATS_PIO_READ(offset) {				\
+	status = __vxge_hw_vpath_stats_access(vpath,			\
+					      VXGE_HW_STATS_OP_READ,	\
+					      offset,			\
+					      &val64);			\
+	if (status != VXGE_HW_OK)					\
+		return status;						\
 }
 
-static struct vxge_hw_mempool*
-__vxge_hw_mempool_create(struct __vxge_hw_device *devh, u32 memblock_size,
-			u32 item_size, u32 private_size, u32 items_initial,
-			u32 items_max, struct vxge_hw_mempool_cbs *mp_callback,
-			void *userdata);
-
-static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool);
-
-static enum vxge_hw_status
-__vxge_hw_vpath_stats_get(struct __vxge_hw_virtualpath *vpath,
-			  struct vxge_hw_vpath_stats_hw_info *hw_stats);
-
-static enum vxge_hw_status
-vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vpath_handle);
-
-static enum vxge_hw_status
-__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg);
-
-static void
-__vxge_hw_vp_terminate(struct __vxge_hw_device *devh, u32 vp_id);
-
-static enum vxge_hw_status
-__vxge_hw_vpath_xmac_tx_stats_get(struct __vxge_hw_virtualpath	*vpath,
-				  struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats);
-
-static enum vxge_hw_status
-__vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath	*vpath,
-				  struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats);
-
 static void
 vxge_hw_vpath_set_zero_rx_frm_len(struct vxge_hw_vpath_reg __iomem *vp_reg)
 {
@@ -124,8 +39,6 @@ vxge_hw_vpath_set_zero_rx_frm_len(struct vxge_hw_vpath_reg __iomem *vp_reg)
 	val64 &= ~VXGE_HW_RXMAC_VCFG0_RTS_MAX_FRM_LEN(0x3fff);
 	writeq(val64, &vp_reg->rxmac_vcfg0);
 	val64 = readq(&vp_reg->rxmac_vcfg0);
-
-	return;
 }
 
 /*
@@ -197,6 +110,50 @@ void vxge_hw_device_wait_receive_idle(struct __vxge_hw_device *hldev)
 	}
 }
 
+/*
+ * __vxge_hw_device_register_poll
+ * Will poll certain register for specified amount of time.
+ * Will poll until masked bit is not cleared.
+ */
+static enum vxge_hw_status
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
+static inline enum vxge_hw_status
+__vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
+			  u64 mask, u32 max_millis)
+{
+	__vxge_hw_pio_mem_write32_lower((u32)vxge_bVALn(val64, 32, 32), addr);
+	wmb();
+	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32), addr);
+	wmb();
+
+	return __vxge_hw_device_register_poll(addr, mask, max_millis);
+}
+
 static enum vxge_hw_status
 vxge_hw_vpath_fw_api(struct __vxge_hw_virtualpath *vpath, u32 action,
 		     u32 fw_memo, u32 offset, u64 *data0, u64 *data1,
@@ -446,77 +403,6 @@ vxge_hw_vpath_eprom_img_ver_get(struct __vxge_hw_device *hldev,
 }
 
 /*
- * __vxge_hw_channel_allocate - Allocate memory for channel
- * This function allocates required memory for the channel and various arrays
- * in the channel
- */
-static struct __vxge_hw_channel *
-__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
-			   enum __vxge_hw_channel_type type,
-	u32 length, u32 per_dtr_space, void *userdata)
-{
-	struct __vxge_hw_channel *channel;
-	struct __vxge_hw_device *hldev;
-	int size = 0;
-	u32 vp_id;
-
-	hldev = vph->vpath->hldev;
-	vp_id = vph->vpath->vp_id;
-
-	switch (type) {
-	case VXGE_HW_CHANNEL_TYPE_FIFO:
-		size = sizeof(struct __vxge_hw_fifo);
-		break;
-	case VXGE_HW_CHANNEL_TYPE_RING:
-		size = sizeof(struct __vxge_hw_ring);
-		break;
-	default:
-		break;
-	}
-
-	channel = kzalloc(size, GFP_KERNEL);
-	if (channel == NULL)
-		goto exit0;
-	INIT_LIST_HEAD(&channel->item);
-
-	channel->common_reg = hldev->common_reg;
-	channel->first_vp_id = hldev->first_vp_id;
-	channel->type = type;
-	channel->devh = hldev;
-	channel->vph = vph;
-	channel->userdata = userdata;
-	channel->per_dtr_space = per_dtr_space;
-	channel->length = length;
-	channel->vp_id = vp_id;
-
-	channel->work_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-	if (channel->work_arr == NULL)
-		goto exit1;
-
-	channel->free_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-	if (channel->free_arr == NULL)
-		goto exit1;
-	channel->free_ptr = length;
-
-	channel->reserve_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-	if (channel->reserve_arr == NULL)
-		goto exit1;
-	channel->reserve_ptr = length;
-	channel->reserve_top = 0;
-
-	channel->orig_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-	if (channel->orig_arr == NULL)
-		goto exit1;
-
-	return channel;
-exit1:
-	__vxge_hw_channel_free(channel);
-
-exit0:
-	return NULL;
-}
-
-/*
  * __vxge_hw_channel_free - Free memory allocated for channel
  * This function deallocates memory from the channel and various arrays
  * in the channel
@@ -609,38 +495,6 @@ static void __vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
 	pci_save_state(hldev->pdev);
 }
 
-/*
- * __vxge_hw_device_register_poll
- * Will poll certain register for specified amount of time.
- * Will poll until masked bit is not cleared.
- */
-static enum vxge_hw_status
-__vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
-{
-	u64 val64;
-	u32 i = 0;
-	enum vxge_hw_status ret = VXGE_HW_FAIL;
-
-	udelay(10);
-
-	do {
-		val64 = readq(reg);
-		if (!(val64 & mask))
-			return VXGE_HW_OK;
-		udelay(100);
-	} while (++i <= 9);
-
-	i = 0;
-	do {
-		val64 = readq(reg);
-		if (!(val64 & mask))
-			return VXGE_HW_OK;
-		mdelay(1);
-	} while (++i <= max_millis);
-
-	return ret;
-}
-
 /* __vxge_hw_device_vpath_reset_in_prog_check - Check if vpath reset
  * in progress
  * This routine checks the vpath reset in progress register is turned zero
@@ -656,6 +510,60 @@ __vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog)
 }
 
 /*
+ * _hw_legacy_swapper_set - Set the swapper bits for the legacy secion.
+ * Set the swapper bits appropriately for the lagacy section.
+ */
+static enum vxge_hw_status
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
  * __vxge_hw_device_toc_get
  * This routine sets the swapper and reads the toc pointer and returns the
  * memory mapped address of the toc
@@ -1132,7 +1040,6 @@ vxge_hw_device_hw_info_get(void __iomem *bar0,
 	   (u32)VXGE_HW_HOST_TYPE_ASSIGNMENTS_GET_HOST_TYPE_ASSIGNMENTS(val64);
 
 	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-
 		if (!((hw_info->vpath_mask) & vxge_mBIT(i)))
 			continue;
 
@@ -1196,6 +1103,218 @@ exit:
 }
 
 /*
+ * __vxge_hw_blockpool_destroy - Deallocates the block pool
+ */
+static void __vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool *blockpool)
+{
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
+		pci_unmap_single(hldev->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
+			((struct __vxge_hw_blockpool_entry *)p)->length,
+			PCI_DMA_BIDIRECTIONAL);
+
+		vxge_os_dma_free(hldev->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->memblock,
+			&((struct __vxge_hw_blockpool_entry *)p)->acc_handle);
+
+		list_del(&((struct __vxge_hw_blockpool_entry *)p)->item);
+		kfree(p);
+		blockpool->pool_size--;
+	}
+
+	list_for_each_safe(p, n, &blockpool->free_entry_list) {
+		list_del(&((struct __vxge_hw_blockpool_entry *)p)->item);
+		kfree((void *)p);
+	}
+	ret = 0;
+exit:
+	return;
+}
+
+/*
+ * __vxge_hw_blockpool_create - Create block pool
+ */
+static enum vxge_hw_status
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
+		memblock = vxge_os_dma_malloc(
+				hldev->pdev,
+				VXGE_HW_BLOCK_SIZE,
+				&dma_handle,
+				&acc_handle);
+		if (memblock == NULL) {
+			__vxge_hw_blockpool_destroy(blockpool);
+			status = VXGE_HW_ERR_OUT_OF_MEMORY;
+			goto blockpool_create_exit;
+		}
+
+		dma_addr = pci_map_single(hldev->pdev, memblock,
+				VXGE_HW_BLOCK_SIZE, PCI_DMA_BIDIRECTIONAL);
+		if (unlikely(pci_dma_mapping_error(hldev->pdev,
+				dma_addr))) {
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
+ * __vxge_hw_device_fifo_config_check - Check fifo configuration.
+ * Check the fifo configuration
+ */
+static enum vxge_hw_status
+__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config)
+{
+	if ((fifo_config->fifo_blocks < VXGE_HW_MIN_FIFO_BLOCKS) ||
+	    (fifo_config->fifo_blocks > VXGE_HW_MAX_FIFO_BLOCKS))
+		return VXGE_HW_BADCFG_FIFO_BLOCKS;
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_vpath_config_check - Check vpath configuration.
+ * Check the vpath configuration
+ */
+static enum vxge_hw_status
+__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
+{
+	enum vxge_hw_status status;
+
+	if ((vp_config->min_bandwidth < VXGE_HW_VPATH_BANDWIDTH_MIN) ||
+	    (vp_config->min_bandwidth >	VXGE_HW_VPATH_BANDWIDTH_MAX))
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
+static enum vxge_hw_status
+__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
+{
+	u32 i;
+	enum vxge_hw_status status;
+
+	if ((new_config->intr_mode != VXGE_HW_INTR_MODE_IRQLINE) &&
+	    (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX) &&
+	    (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) &&
+	    (new_config->intr_mode != VXGE_HW_INTR_MODE_DEF))
+		return VXGE_HW_BADCFG_INTR_MODE;
+
+	if ((new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE) &&
+	    (new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE))
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
  * vxge_hw_device_initialize - Initialize Titan device.
  * Initialize Titan device. Note that all the arguments of this public API
  * are 'IN', including @hldev. Driver cooperates with
@@ -1303,6 +1422,242 @@ vxge_hw_device_terminate(struct __vxge_hw_device *hldev)
 }
 
 /*
+ * __vxge_hw_vpath_stats_access - Get the statistics from the given location
+ *                           and offset and perform an operation
+ */
+static enum vxge_hw_status
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
+static enum vxge_hw_status
+__vxge_hw_vpath_xmac_tx_stats_get(struct __vxge_hw_virtualpath *vpath,
+			struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats)
+{
+	u64 *val64;
+	int i;
+	u32 offset = VXGE_HW_STATS_VPATH_TX_OFFSET;
+	enum vxge_hw_status status = VXGE_HW_OK;
+
+	val64 = (u64 *)vpath_tx_stats;
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
+static enum vxge_hw_status
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
+static enum vxge_hw_status
+__vxge_hw_vpath_stats_get(struct __vxge_hw_virtualpath *vpath,
+			  struct vxge_hw_vpath_stats_hw_info *hw_stats)
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
  * vxge_hw_device_stats_get - Get the device hw statistics.
  * Returns the vpath h/w stats for the device.
  */
@@ -1468,7 +1823,6 @@ vxge_hw_device_xmac_stats_get(struct __vxge_hw_device *hldev,
 
 	status = vxge_hw_device_xmac_aggr_stats_get(hldev,
 					0, &xmac_stats->aggr_stats[0]);
-
 	if (status != VXGE_HW_OK)
 		goto exit;
 
@@ -1843,189 +2197,359 @@ exit:
 }
 
 /*
- * __vxge_hw_ring_create - Create a Ring
- * This function creates Ring and initializes it.
+ * __vxge_hw_channel_allocate - Allocate memory for channel
+ * This function allocates required memory for the channel and various arrays
+ * in the channel
  */
-static enum vxge_hw_status
-__vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
-		      struct vxge_hw_ring_attr *attr)
+static struct __vxge_hw_channel *
+__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
+			   enum __vxge_hw_channel_type type,
+			   u32 length, u32 per_dtr_space,
+			   void *userdata)
 {
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct __vxge_hw_ring *ring;
-	u32 ring_length;
-	struct vxge_hw_ring_config *config;
+	struct __vxge_hw_channel *channel;
 	struct __vxge_hw_device *hldev;
+	int size = 0;
 	u32 vp_id;
-	struct vxge_hw_mempool_cbs ring_mp_callback;
 
-	if ((vp == NULL) || (attr == NULL)) {
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
+ * vxge_hw_blockpool_block_add - callback for vxge_os_dma_malloc_async
+ * Adds a block to block pool
+ */
+static void vxge_hw_blockpool_block_add(struct __vxge_hw_device *devh,
+					void *block_addr,
+					u32 length,
+					struct pci_dev *dma_h,
+					struct pci_dev *acc_handle)
+{
+	struct __vxge_hw_blockpool *blockpool;
+	struct __vxge_hw_blockpool_entry *entry = NULL;
+	dma_addr_t dma_addr;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	u32 req_out;
+
+	blockpool = &devh->block_pool;
+
+	if (block_addr == NULL) {
+		blockpool->req_out--;
 		status = VXGE_HW_FAIL;
 		goto exit;
 	}
 
-	hldev = vp->vpath->hldev;
-	vp_id = vp->vpath->vp_id;
+	dma_addr = pci_map_single(devh->pdev, block_addr, length,
+				PCI_DMA_BIDIRECTIONAL);
 
-	config = &hldev->config.vp_config[vp_id].ring;
+	if (unlikely(pci_dma_mapping_error(devh->pdev, dma_addr))) {
+		vxge_os_dma_free(devh->pdev, block_addr, &acc_handle);
+		blockpool->req_out--;
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
 
-	ring_length = config->ring_blocks *
-			vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+	if (!list_empty(&blockpool->free_entry_list))
+		entry = (struct __vxge_hw_blockpool_entry *)
+			list_first_entry(&blockpool->free_entry_list,
+				struct __vxge_hw_blockpool_entry,
+				item);
 
-	ring = (struct __vxge_hw_ring *)__vxge_hw_channel_allocate(vp,
-						VXGE_HW_CHANNEL_TYPE_RING,
-						ring_length,
-						attr->per_rxd_space,
-						attr->userdata);
+	if (entry == NULL)
+		entry =	vmalloc(sizeof(struct __vxge_hw_blockpool_entry));
+	else
+		list_del(&entry->item);
 
-	if (ring == NULL) {
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
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
-		goto exit;
-	}
 
-	vp->vpath->ringh = ring;
-	ring->vp_id = vp_id;
-	ring->vp_reg = vp->vpath->vp_reg;
-	ring->common_reg = hldev->common_reg;
-	ring->stats = &vp->vpath->sw_stats->ring_stats;
-	ring->config = config;
-	ring->callback = attr->callback;
-	ring->rxd_init = attr->rxd_init;
-	ring->rxd_term = attr->rxd_term;
-	ring->buffer_mode = config->buffer_mode;
-	ring->rxds_limit = config->rxds_limit;
+	blockpool->req_out--;
 
-	ring->rxd_size = vxge_hw_ring_rxd_size_get(config->buffer_mode);
-	ring->rxd_priv_size =
-		sizeof(struct __vxge_hw_ring_rxd_priv) + attr->per_rxd_space;
-	ring->per_rxd_space = attr->per_rxd_space;
+	req_out = blockpool->req_out;
+exit:
+	return;
+}
 
-	ring->rxd_priv_size =
-		((ring->rxd_priv_size + VXGE_CACHE_LINE_SIZE - 1) /
-		VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
+static inline void
+vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh, unsigned long size)
+{
+	gfp_t flags;
+	void *vaddr;
 
-	/* how many RxDs can fit into one block. Depends on configured
-	 * buffer_mode. */
-	ring->rxds_per_block =
-		vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+	if (in_interrupt())
+		flags = GFP_ATOMIC | GFP_DMA;
+	else
+		flags = GFP_KERNEL | GFP_DMA;
 
-	/* calculate actual RxD block private size */
-	ring->rxdblock_priv_size = ring->rxd_priv_size * ring->rxds_per_block;
-	ring_mp_callback.item_func_alloc = __vxge_hw_ring_mempool_item_alloc;
-	ring->mempool = __vxge_hw_mempool_create(hldev,
-				VXGE_HW_BLOCK_SIZE,
-				VXGE_HW_BLOCK_SIZE,
-				ring->rxdblock_priv_size,
-				ring->config->ring_blocks,
-				ring->config->ring_blocks,
-				&ring_mp_callback,
-				ring);
+	vaddr = kmalloc((size), flags);
 
-	if (ring->mempool == NULL) {
-		__vxge_hw_ring_delete(vp);
-		return VXGE_HW_ERR_OUT_OF_MEMORY;
-	}
+	vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
+}
 
-	status = __vxge_hw_channel_initialize(&ring->channel);
-	if (status != VXGE_HW_OK) {
-		__vxge_hw_ring_delete(vp);
-		goto exit;
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
 	}
 
-	/* Note:
-	 * Specifying rxd_init callback means two things:
-	 * 1) rxds need to be initialized by driver at channel-open time;
-	 * 2) rxds need to be posted at channel-open time
-	 *    (that's what the initial_replenish() below does)
-	 * Currently we don't have a case when the 1) is done without the 2).
-	 */
-	if (ring->rxd_init) {
-		status = vxge_hw_ring_replenish(ring);
-		if (status != VXGE_HW_OK) {
-			__vxge_hw_ring_delete(vp);
+	for (i = 0; i < nreq; i++)
+		vxge_os_dma_malloc_async(
+			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			blockpool->hldev, VXGE_HW_BLOCK_SIZE);
+}
+
+/*
+ * __vxge_hw_blockpool_malloc - Allocate a memory block from pool
+ * Allocates a block of memory of given size, either from block pool
+ * or by calling vxge_os_dma_malloc()
+ */
+static void *__vxge_hw_blockpool_malloc(struct __vxge_hw_device *devh, u32 size,
+					struct vxge_hw_mempool_dma *dma_object)
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
 			goto exit;
 		}
-	}
 
-	/* initial replenish will increment the counter in its post() routine,
-	 * we have to reset it */
-	ring->stats->common_stats.usage_cnt = 0;
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
 exit:
-	return status;
+	return memblock;
 }
 
 /*
- * __vxge_hw_ring_abort - Returns the RxD
- * This function terminates the RxDs of ring
+ * __vxge_hw_blockpool_blocks_remove - Free additional blocks
  */
-static enum vxge_hw_status __vxge_hw_ring_abort(struct __vxge_hw_ring *ring)
+static void
+__vxge_hw_blockpool_blocks_remove(struct __vxge_hw_blockpool *blockpool)
 {
-	void *rxdh;
-	struct __vxge_hw_channel *channel;
-
-	channel = &ring->channel;
+	struct list_head *p, *n;
 
-	for (;;) {
-		vxge_hw_channel_dtr_try_complete(channel, &rxdh);
+	list_for_each_safe(p, n, &blockpool->free_block_list) {
 
-		if (rxdh == NULL)
+		if (blockpool->pool_size < blockpool->pool_max)
 			break;
 
-		vxge_hw_channel_dtr_complete(channel);
+		pci_unmap_single(
+			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
+			((struct __vxge_hw_blockpool_entry *)p)->length,
+			PCI_DMA_BIDIRECTIONAL);
 
-		if (ring->rxd_term)
-			ring->rxd_term(rxdh, VXGE_HW_RXD_STATE_POSTED,
-				channel->userdata);
+		vxge_os_dma_free(
+			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+			((struct __vxge_hw_blockpool_entry *)p)->memblock,
+			&((struct __vxge_hw_blockpool_entry *)p)->acc_handle);
 
-		vxge_hw_channel_dtr_free(channel, rxdh);
-	}
+		list_del(&((struct __vxge_hw_blockpool_entry *)p)->item);
 
-	return VXGE_HW_OK;
+		list_add(p, &blockpool->free_entry_list);
+
+		blockpool->pool_size--;
+
+	}
 }
 
 /*
- * __vxge_hw_ring_reset - Resets the ring
- * This function resets the ring during vpath reset operation
+ * __vxge_hw_blockpool_free - Frees the memory allcoated with
+ *				__vxge_hw_blockpool_malloc
  */
-static enum vxge_hw_status __vxge_hw_ring_reset(struct __vxge_hw_ring *ring)
+static void __vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
+				     void *memblock, u32 size,
+				     struct vxge_hw_mempool_dma *dma_object)
 {
+	struct __vxge_hw_blockpool_entry *entry = NULL;
+	struct __vxge_hw_blockpool  *blockpool;
 	enum vxge_hw_status status = VXGE_HW_OK;
-	struct __vxge_hw_channel *channel;
 
-	channel = &ring->channel;
+	blockpool = &devh->block_pool;
 
-	__vxge_hw_ring_abort(ring);
+	if (size != blockpool->block_size) {
+		pci_unmap_single(devh->pdev, dma_object->addr, size,
+			PCI_DMA_BIDIRECTIONAL);
+		vxge_os_dma_free(devh->pdev, memblock, &dma_object->acc_handle);
+	} else {
 
-	status = __vxge_hw_channel_reset(channel);
+		if (!list_empty(&blockpool->free_entry_list))
+			entry = (struct __vxge_hw_blockpool_entry *)
+				list_first_entry(&blockpool->free_entry_list,
+					struct __vxge_hw_blockpool_entry,
+					item);
 
-	if (status != VXGE_HW_OK)
-		goto exit;
+		if (entry == NULL)
+			entry =	vmalloc(sizeof(
+					struct __vxge_hw_blockpool_entry));
+		else
+			list_del(&entry->item);
 
-	if (ring->rxd_init) {
-		status = vxge_hw_ring_replenish(ring);
-		if (status != VXGE_HW_OK)
-			goto exit;
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
 	}
-exit:
-	return status;
 }
 
 /*
- * __vxge_hw_ring_delete - Removes the ring
- * This function freeup the memory pool and removes the ring
+ * vxge_hw_mempool_destroy
  */
-static enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp)
+static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
 {
-	struct __vxge_hw_ring *ring = vp->vpath->ringh;
+	u32 i, j;
+	struct __vxge_hw_device *devh = mempool->devh;
 
-	__vxge_hw_ring_abort(ring);
+	for (i = 0; i < mempool->memblocks_allocated; i++) {
+		struct vxge_hw_mempool_dma *dma_object;
 
-	if (ring->mempool)
-		__vxge_hw_mempool_destroy(ring->mempool);
+		vxge_assert(mempool->memblocks_arr[i]);
+		vxge_assert(mempool->memblocks_dma_arr + i);
 
-	vp->vpath->ringh = NULL;
-	__vxge_hw_channel_free(&ring->channel);
+		dma_object = mempool->memblocks_dma_arr + i;
 
-	return VXGE_HW_OK;
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
+	vfree(mempool->items_arr);
+	vfree(mempool->memblocks_dma_arr);
+	vfree(mempool->memblocks_priv_arr);
+	vfree(mempool->memblocks_arr);
+	vfree(mempool);
 }
 
 /*
@@ -2118,16 +2642,15 @@ exit:
  * with size enough to hold %items_initial number of items. Memory is
  * DMA-able but client must map/unmap before interoperating with the device.
  */
-static struct vxge_hw_mempool*
-__vxge_hw_mempool_create(
-	struct __vxge_hw_device *devh,
-	u32 memblock_size,
-	u32 item_size,
-	u32 items_priv_size,
-	u32 items_initial,
-	u32 items_max,
-	struct vxge_hw_mempool_cbs *mp_callback,
-	void *userdata)
+static struct vxge_hw_mempool *
+__vxge_hw_mempool_create(struct __vxge_hw_device *devh,
+			 u32 memblock_size,
+			 u32 item_size,
+			 u32 items_priv_size,
+			 u32 items_initial,
+			 u32 items_max,
+			 struct vxge_hw_mempool_cbs *mp_callback,
+			 void *userdata)
 {
 	enum vxge_hw_status status = VXGE_HW_OK;
 	u32 memblocks_to_allocate;
@@ -2185,7 +2708,6 @@ __vxge_hw_mempool_create(
 	mempool->memblocks_dma_arr =
 		vzalloc(sizeof(struct vxge_hw_mempool_dma) *
 			mempool->memblocks_max);
-
 	if (mempool->memblocks_dma_arr == NULL) {
 		__vxge_hw_mempool_destroy(mempool);
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
@@ -2222,122 +2744,188 @@ exit:
 }
 
 /*
- * vxge_hw_mempool_destroy
+ * __vxge_hw_ring_abort - Returns the RxD
+ * This function terminates the RxDs of ring
  */
-static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
+static enum vxge_hw_status __vxge_hw_ring_abort(struct __vxge_hw_ring *ring)
 {
-	u32 i, j;
-	struct __vxge_hw_device *devh = mempool->devh;
-
-	for (i = 0; i < mempool->memblocks_allocated; i++) {
-		struct vxge_hw_mempool_dma *dma_object;
+	void *rxdh;
+	struct __vxge_hw_channel *channel;
 
-		vxge_assert(mempool->memblocks_arr[i]);
-		vxge_assert(mempool->memblocks_dma_arr + i);
+	channel = &ring->channel;
 
-		dma_object = mempool->memblocks_dma_arr + i;
+	for (;;) {
+		vxge_hw_channel_dtr_try_complete(channel, &rxdh);
 
-		for (j = 0; j < mempool->items_per_memblock; j++) {
-			u32 index = i * mempool->items_per_memblock + j;
+		if (rxdh == NULL)
+			break;
 
-			/* to skip last partially filled(if any) memblock */
-			if (index >= mempool->items_current)
-				break;
-		}
+		vxge_hw_channel_dtr_complete(channel);
 
-		vfree(mempool->memblocks_priv_arr[i]);
+		if (ring->rxd_term)
+			ring->rxd_term(rxdh, VXGE_HW_RXD_STATE_POSTED,
+				channel->userdata);
 
-		__vxge_hw_blockpool_free(devh, mempool->memblocks_arr[i],
-				mempool->memblock_size, dma_object);
+		vxge_hw_channel_dtr_free(channel, rxdh);
 	}
 
-	vfree(mempool->items_arr);
+	return VXGE_HW_OK;
+}
 
-	vfree(mempool->memblocks_dma_arr);
+/*
+ * __vxge_hw_ring_reset - Resets the ring
+ * This function resets the ring during vpath reset operation
+ */
+static enum vxge_hw_status __vxge_hw_ring_reset(struct __vxge_hw_ring *ring)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_channel *channel;
 
-	vfree(mempool->memblocks_priv_arr);
+	channel = &ring->channel;
 
-	vfree(mempool->memblocks_arr);
+	__vxge_hw_ring_abort(ring);
 
-	vfree(mempool);
+	status = __vxge_hw_channel_reset(channel);
+
+	if (status != VXGE_HW_OK)
+		goto exit;
+
+	if (ring->rxd_init) {
+		status = vxge_hw_ring_replenish(ring);
+		if (status != VXGE_HW_OK)
+			goto exit;
+	}
+exit:
+	return status;
 }
 
 /*
- * __vxge_hw_device_fifo_config_check - Check fifo configuration.
- * Check the fifo configuration
+ * __vxge_hw_ring_delete - Removes the ring
+ * This function freeup the memory pool and removes the ring
  */
 static enum vxge_hw_status
-__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config)
+__vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp)
 {
-	if ((fifo_config->fifo_blocks < VXGE_HW_MIN_FIFO_BLOCKS) ||
-	     (fifo_config->fifo_blocks > VXGE_HW_MAX_FIFO_BLOCKS))
-		return VXGE_HW_BADCFG_FIFO_BLOCKS;
+	struct __vxge_hw_ring *ring = vp->vpath->ringh;
+
+	__vxge_hw_ring_abort(ring);
+
+	if (ring->mempool)
+		__vxge_hw_mempool_destroy(ring->mempool);
+
+	vp->vpath->ringh = NULL;
+	__vxge_hw_channel_free(&ring->channel);
 
 	return VXGE_HW_OK;
 }
 
 /*
- * __vxge_hw_device_vpath_config_check - Check vpath configuration.
- * Check the vpath configuration
+ * __vxge_hw_ring_create - Create a Ring
+ * This function creates Ring and initializes it.
  */
 static enum vxge_hw_status
-__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
+__vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
+		      struct vxge_hw_ring_attr *attr)
 {
-	enum vxge_hw_status status;
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct __vxge_hw_ring *ring;
+	u32 ring_length;
+	struct vxge_hw_ring_config *config;
+	struct __vxge_hw_device *hldev;
+	u32 vp_id;
+	struct vxge_hw_mempool_cbs ring_mp_callback;
 
-	if ((vp_config->min_bandwidth < VXGE_HW_VPATH_BANDWIDTH_MIN) ||
-		(vp_config->min_bandwidth >
-					VXGE_HW_VPATH_BANDWIDTH_MAX))
-		return VXGE_HW_BADCFG_VPATH_MIN_BANDWIDTH;
+	if ((vp == NULL) || (attr == NULL)) {
+		status = VXGE_HW_FAIL;
+		goto exit;
+	}
 
-	status = __vxge_hw_device_fifo_config_check(&vp_config->fifo);
-	if (status != VXGE_HW_OK)
-		return status;
+	hldev = vp->vpath->hldev;
+	vp_id = vp->vpath->vp_id;
 
-	if ((vp_config->mtu != VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU) &&
-		((vp_config->mtu < VXGE_HW_VPATH_MIN_INITIAL_MTU) ||
-		(vp_config->mtu > VXGE_HW_VPATH_MAX_INITIAL_MTU)))
-		return VXGE_HW_BADCFG_VPATH_MTU;
+	config = &hldev->config.vp_config[vp_id].ring;
 
-	if ((vp_config->rpa_strip_vlan_tag !=
-		VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT) &&
-		(vp_config->rpa_strip_vlan_tag !=
-		VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE) &&
-		(vp_config->rpa_strip_vlan_tag !=
-		VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_DISABLE))
-		return VXGE_HW_BADCFG_VPATH_RPA_STRIP_VLAN_TAG;
+	ring_length = config->ring_blocks *
+			vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
 
-	return VXGE_HW_OK;
-}
+	ring = (struct __vxge_hw_ring *)__vxge_hw_channel_allocate(vp,
+						VXGE_HW_CHANNEL_TYPE_RING,
+						ring_length,
+						attr->per_rxd_space,
+						attr->userdata);
+	if (ring == NULL) {
+		status = VXGE_HW_ERR_OUT_OF_MEMORY;
+		goto exit;
+	}
 
-/*
- * __vxge_hw_device_config_check - Check device configuration.
- * Check the device configuration
- */
-static enum vxge_hw_status
-__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
-{
-	u32 i;
-	enum vxge_hw_status status;
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
 
-	if ((new_config->intr_mode != VXGE_HW_INTR_MODE_IRQLINE) &&
-	   (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX) &&
-	   (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) &&
-	   (new_config->intr_mode != VXGE_HW_INTR_MODE_DEF))
-		return VXGE_HW_BADCFG_INTR_MODE;
+	ring->rxd_size = vxge_hw_ring_rxd_size_get(config->buffer_mode);
+	ring->rxd_priv_size =
+		sizeof(struct __vxge_hw_ring_rxd_priv) + attr->per_rxd_space;
+	ring->per_rxd_space = attr->per_rxd_space;
 
-	if ((new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE) &&
-	   (new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE))
-		return VXGE_HW_BADCFG_RTS_MAC_EN;
+	ring->rxd_priv_size =
+		((ring->rxd_priv_size + VXGE_CACHE_LINE_SIZE - 1) /
+		VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
 
-	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-		status = __vxge_hw_device_vpath_config_check(
-				&new_config->vp_config[i]);
-		if (status != VXGE_HW_OK)
-			return status;
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
+	if (ring->mempool == NULL) {
+		__vxge_hw_ring_delete(vp);
+		return VXGE_HW_ERR_OUT_OF_MEMORY;
 	}
 
-	return VXGE_HW_OK;
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
+		status = vxge_hw_ring_replenish(ring);
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
 }
 
 /*
@@ -2359,7 +2947,6 @@ vxge_hw_device_config_default_get(struct vxge_hw_device_config *device_config)
 	device_config->rts_mac_en =  VXGE_HW_RTS_MAC_DEFAULT;
 
 	for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-
 		device_config->vp_config[i].vp_id = i;
 
 		device_config->vp_config[i].min_bandwidth =
@@ -2499,61 +3086,6 @@ vxge_hw_device_config_default_get(struct vxge_hw_device_config *device_config)
 }
 
 /*
- * _hw_legacy_swapper_set - Set the swapper bits for the legacy secion.
- * Set the swapper bits appropriately for the lagacy section.
- */
-static enum vxge_hw_status
-__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg)
-{
-	u64 val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	val64 = readq(&legacy_reg->toc_swapper_fb);
-
-	wmb();
-
-	switch (val64) {
-
-	case VXGE_HW_SWAPPER_INITIAL_VALUE:
-		return status;
-
-	case VXGE_HW_SWAPPER_BYTE_SWAPPED_BIT_FLIPPED:
-		writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
-			&legacy_reg->pifm_rd_swap_en);
-		writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
-			&legacy_reg->pifm_rd_flip_en);
-		writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
-			&legacy_reg->pifm_wr_swap_en);
-		writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
-			&legacy_reg->pifm_wr_flip_en);
-		break;
-
-	case VXGE_HW_SWAPPER_BYTE_SWAPPED:
-		writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
-			&legacy_reg->pifm_rd_swap_en);
-		writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
-			&legacy_reg->pifm_wr_swap_en);
-		break;
-
-	case VXGE_HW_SWAPPER_BIT_FLIPPED:
-		writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
-			&legacy_reg->pifm_rd_flip_en);
-		writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
-			&legacy_reg->pifm_wr_flip_en);
-		break;
-	}
-
-	wmb();
-
-	val64 = readq(&legacy_reg->toc_swapper_fb);
-
-	if (val64 != VXGE_HW_SWAPPER_INITIAL_VALUE)
-		status = VXGE_HW_ERR_SWAPPER_CTRL;
-
-	return status;
-}
-
-/*
  * __vxge_hw_vpath_swapper_set - Set the swapper bits for the vpath.
  * Set the swapper bits appropriately for the vpath.
  */
@@ -2577,9 +3109,8 @@ __vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg)
  * Set the swapper bits appropriately for the vpath.
  */
 static enum vxge_hw_status
-__vxge_hw_kdfc_swapper_set(
-	struct vxge_hw_legacy_reg __iomem *legacy_reg,
-	struct vxge_hw_vpath_reg __iomem *vpath_reg)
+__vxge_hw_kdfc_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg,
+			   struct vxge_hw_vpath_reg __iomem *vpath_reg)
 {
 	u64 val64;
 
@@ -2829,6 +3360,69 @@ exit:
 }
 
 /*
+ * __vxge_hw_fifo_abort - Returns the TxD
+ * This function terminates the TxDs of fifo
+ */
+static enum vxge_hw_status __vxge_hw_fifo_abort(struct __vxge_hw_fifo *fifo)
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
+static enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
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
+static enum vxge_hw_status
+__vxge_hw_fifo_delete(struct __vxge_hw_vpath_handle *vp)
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
  * __vxge_hw_fifo_mempool_item_alloc - Allocate List blocks for TxD
  * list callback
  * This function is callback passed to __vxge_hw_mempool_create to create memory
@@ -2993,69 +3587,6 @@ exit:
 }
 
 /*
- * __vxge_hw_fifo_abort - Returns the TxD
- * This function terminates the TxDs of fifo
- */
-static enum vxge_hw_status __vxge_hw_fifo_abort(struct __vxge_hw_fifo *fifo)
-{
-	void *txdlh;
-
-	for (;;) {
-		vxge_hw_channel_dtr_try_complete(&fifo->channel, &txdlh);
-
-		if (txdlh == NULL)
-			break;
-
-		vxge_hw_channel_dtr_complete(&fifo->channel);
-
-		if (fifo->txdl_term) {
-			fifo->txdl_term(txdlh,
-			VXGE_HW_TXDL_STATE_POSTED,
-			fifo->channel.userdata);
-		}
-
-		vxge_hw_channel_dtr_free(&fifo->channel, txdlh);
-	}
-
-	return VXGE_HW_OK;
-}
-
-/*
- * __vxge_hw_fifo_reset - Resets the fifo
- * This function resets the fifo during vpath reset operation
- */
-static enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
-{
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	__vxge_hw_fifo_abort(fifo);
-	status = __vxge_hw_channel_reset(&fifo->channel);
-
-	return status;
-}
-
-/*
- * __vxge_hw_fifo_delete - Removes the FIFO
- * This function freeup the memory pool and removes the FIFO
- */
-static enum vxge_hw_status
-__vxge_hw_fifo_delete(struct __vxge_hw_vpath_handle *vp)
-{
-	struct __vxge_hw_fifo *fifo = vp->vpath->fifoh;
-
-	__vxge_hw_fifo_abort(fifo);
-
-	if (fifo->mempool)
-		__vxge_hw_mempool_destroy(fifo->mempool);
-
-	vp->vpath->fifoh = NULL;
-
-	__vxge_hw_channel_free(&fifo->channel);
-
-	return VXGE_HW_OK;
-}
-
-/*
  * __vxge_hw_vpath_pci_read - Read the content of given address
  *                          in pci config space.
  * Read from the vpath pci config space.
@@ -3786,10 +4317,10 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 	vp_reg = vpath->vp_reg;
 	config = vpath->vp_config;
 
-	writeq((u64)0, &vp_reg->tim_dest_addr);
-	writeq((u64)0, &vp_reg->tim_vpath_map);
-	writeq((u64)0, &vp_reg->tim_bitmap);
-	writeq((u64)0, &vp_reg->tim_remap);
+	writeq(0, &vp_reg->tim_dest_addr);
+	writeq(0, &vp_reg->tim_vpath_map);
+	writeq(0, &vp_reg->tim_bitmap);
+	writeq(0, &vp_reg->tim_remap);
 
 	if (config->ring.enable == VXGE_HW_RING_ENABLE)
 		writeq(VXGE_HW_TIM_RING_ASSN_INT_NUM(
@@ -4021,8 +4552,7 @@ __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 	return status;
 }
 
-void
-vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id)
+void vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id)
 {
 	struct __vxge_hw_virtualpath *vpath;
 	struct vxge_hw_vpath_reg __iomem *vp_reg;
@@ -4033,17 +4563,15 @@ vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id)
 	vp_reg = vpath->vp_reg;
 	config = vpath->vp_config;
 
-	if (config->fifo.enable == VXGE_HW_FIFO_ENABLE) {
+	if (config->fifo.enable == VXGE_HW_FIFO_ENABLE &&
+	    config->tti.timer_ci_en != VXGE_HW_TIM_TIMER_CI_ENABLE) {
+		config->tti.timer_ci_en = VXGE_HW_TIM_TIMER_CI_ENABLE;
 		val64 = readq(&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
-
-		if (config->tti.timer_ci_en != VXGE_HW_TIM_TIMER_CI_ENABLE) {
-			config->tti.timer_ci_en = VXGE_HW_TIM_TIMER_CI_ENABLE;
-			val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
-			writeq(val64,
-			&vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
-		}
+		val64 |= VXGE_HW_TIM_CFG1_INT_NUM_TIMER_CI;
+		writeq(val64, &vp_reg->tim_cfg1_int_num[VXGE_HW_VPATH_INTR_TX]);
 	}
 }
+
 /*
  * __vxge_hw_vpath_initialize
  * This routine is the final phase of init which initializes the
@@ -4067,22 +4595,18 @@ __vxge_hw_vpath_initialize(struct __vxge_hw_device *hldev, u32 vp_id)
 	vp_reg = vpath->vp_reg;
 
 	status =  __vxge_hw_vpath_swapper_set(vpath->vp_reg);
-
 	if (status != VXGE_HW_OK)
 		goto exit;
 
 	status =  __vxge_hw_vpath_mac_configure(hldev, vp_id);
-
 	if (status != VXGE_HW_OK)
 		goto exit;
 
 	status =  __vxge_hw_vpath_kdfc_configure(hldev, vp_id);
-
 	if (status != VXGE_HW_OK)
 		goto exit;
 
 	status = __vxge_hw_vpath_tim_configure(hldev, vp_id);
-
 	if (status != VXGE_HW_OK)
 		goto exit;
 
@@ -4090,7 +4614,6 @@ __vxge_hw_vpath_initialize(struct __vxge_hw_device *hldev, u32 vp_id)
 
 	/* Get MRRS value from device control */
 	status  = __vxge_hw_vpath_pci_read(vpath, 1, 0x78, &val32);
-
 	if (status == VXGE_HW_OK) {
 		val32 = (val32 & VXGE_HW_PCI_EXP_DEVCTL_READRQ) >> 12;
 		val64 &=
@@ -4114,6 +4637,28 @@ exit:
 }
 
 /*
+ * __vxge_hw_vp_terminate - Terminate Virtual Path structure
+ * This routine closes all channels it opened and freeup memory
+ */
+static void __vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
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
  * __vxge_hw_vp_initialize - Initialize Virtual Path structure
  * This routine is the initial phase of init which resets the vpath and
  * initializes the software support structures.
@@ -4169,29 +4714,6 @@ exit:
 }
 
 /*
- * __vxge_hw_vp_terminate - Terminate Virtual Path structure
- * This routine closes all channels it opened and freeup memory
- */
-static void
-__vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
-{
-	struct __vxge_hw_virtualpath *vpath;
-
-	vpath = &hldev->virtual_paths[vp_id];
-
-	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN)
-		goto exit;
-
-	VXGE_HW_DEVICE_TIM_INT_MASK_RESET(vpath->hldev->tim_int_mask0,
-		vpath->hldev->tim_int_mask1, vpath->vp_id);
-	hldev->stats.hw_dev_info_stats.vpath_info[vpath->vp_id] = NULL;
-
-	memset(vpath, 0, sizeof(struct __vxge_hw_virtualpath));
-exit:
-	return;
-}
-
-/*
  * vxge_hw_vpath_mtu_set - Set MTU.
  * Set new MTU value. Example, to use jumbo frames:
  * vxge_hw_vpath_mtu_set(my_device, 9600);
@@ -4228,6 +4750,64 @@ exit:
 }
 
 /*
+ * vxge_hw_vpath_stats_enable - Enable vpath h/wstatistics.
+ * Enable the DMA vpath statistics. The function is to be called to re-enable
+ * the adapter to update stats into the host memory
+ */
+static enum vxge_hw_status
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
+ * __vxge_hw_blockpool_block_allocate - Allocates a block from block pool
+ * This function allocates a block from block pool or from the system
+ */
+static struct __vxge_hw_blockpool_entry *
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
  * vxge_hw_vpath_open - Open a virtual path on a given adapter
  * This function is used to open access to virtual path of an
  * adapter for offload, GRO operations. This function returns
@@ -4251,7 +4831,6 @@ vxge_hw_vpath_open(struct __vxge_hw_device *hldev,
 
 	status = __vxge_hw_vp_initialize(hldev, attr->vp_id,
 			&hldev->config.vp_config[attr->vp_id]);
-
 	if (status != VXGE_HW_OK)
 		goto vpath_open_exit1;
 
@@ -4283,7 +4862,6 @@ vxge_hw_vpath_open(struct __vxge_hw_device *hldev,
 
 	vpath->stats_block = __vxge_hw_blockpool_block_allocate(hldev,
 				VXGE_HW_BLOCK_SIZE);
-
 	if (vpath->stats_block == NULL) {
 		status = VXGE_HW_ERR_OUT_OF_MEMORY;
 		goto vpath_open_exit8;
@@ -4342,8 +4920,7 @@ vpath_open_exit1:
  * This function is used to close access to virtual path opened
  * earlier.
  */
-void
-vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp)
+void vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp)
 {
 	struct __vxge_hw_virtualpath *vpath = vp->vpath;
 	struct __vxge_hw_ring *ring = vpath->ringh;
@@ -4379,6 +4956,29 @@ vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp)
 }
 
 /*
+ * __vxge_hw_blockpool_block_free - Frees a block from block pool
+ * @devh: Hal device
+ * @entry: Entry of block to be freed
+ *
+ * This function frees a block from block pool
+ */
+static void
+__vxge_hw_blockpool_block_free(struct __vxge_hw_device *devh,
+			       struct __vxge_hw_blockpool_entry *entry)
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
+}
+
+/*
  * vxge_hw_vpath_close - Close the handle got from previous vpath (vpath) open
  * This function is used to close access to virtual path opened
  * earlier.
@@ -4529,728 +5129,3 @@ vxge_hw_vpath_enable(struct __vxge_hw_vpath_handle *vp)
 	__vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32),
 		&hldev->common_reg->cmn_rsthdlr_cfg1);
 }
-
-/*
- * vxge_hw_vpath_stats_enable - Enable vpath h/wstatistics.
- * Enable the DMA vpath statistics. The function is to be called to re-enable
- * the adapter to update stats into the host memory
- */
-static enum vxge_hw_status
-vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vp)
-{
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct __vxge_hw_virtualpath *vpath;
-
-	vpath = vp->vpath;
-
-	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-		goto exit;
-	}
-
-	memcpy(vpath->hw_stats_sav, vpath->hw_stats,
-			sizeof(struct vxge_hw_vpath_stats_hw_info));
-
-	status = __vxge_hw_vpath_stats_get(vpath, vpath->hw_stats);
-exit:
-	return status;
-}
-
-/*
- * __vxge_hw_vpath_stats_access - Get the statistics from the given location
- *                           and offset and perform an operation
- */
-static enum vxge_hw_status
-__vxge_hw_vpath_stats_access(struct __vxge_hw_virtualpath *vpath,
-			     u32 operation, u32 offset, u64 *stat)
-{
-	u64 val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct vxge_hw_vpath_reg __iomem *vp_reg;
-
-	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-		goto vpath_stats_access_exit;
-	}
-
-	vp_reg = vpath->vp_reg;
-
-	val64 =  VXGE_HW_XMAC_STATS_ACCESS_CMD_OP(operation) |
-		 VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE |
-		 VXGE_HW_XMAC_STATS_ACCESS_CMD_OFFSET_SEL(offset);
-
-	status = __vxge_hw_pio_mem_write64(val64,
-				&vp_reg->xmac_stats_access_cmd,
-				VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE,
-				vpath->hldev->config.device_poll_millis);
-
-	if ((status == VXGE_HW_OK) && (operation == VXGE_HW_STATS_OP_READ))
-		*stat = readq(&vp_reg->xmac_stats_access_data);
-	else
-		*stat = 0;
-
-vpath_stats_access_exit:
-	return status;
-}
-
-/*
- * __vxge_hw_vpath_xmac_tx_stats_get - Get the TX Statistics of a vpath
- */
-static enum vxge_hw_status
-__vxge_hw_vpath_xmac_tx_stats_get(
-	struct __vxge_hw_virtualpath *vpath,
-	struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats)
-{
-	u64 *val64;
-	int i;
-	u32 offset = VXGE_HW_STATS_VPATH_TX_OFFSET;
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	val64 = (u64 *) vpath_tx_stats;
-
-	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-		goto exit;
-	}
-
-	for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_tx_stats) / 8; i++) {
-		status = __vxge_hw_vpath_stats_access(vpath,
-					VXGE_HW_STATS_OP_READ,
-					offset, val64);
-		if (status != VXGE_HW_OK)
-			goto exit;
-		offset++;
-		val64++;
-	}
-exit:
-	return status;
-}
-
-/*
- * __vxge_hw_vpath_xmac_rx_stats_get - Get the RX Statistics of a vpath
- */
-static enum vxge_hw_status
-__vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath *vpath,
-				  struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats)
-{
-	u64 *val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
-	int i;
-	u32 offset = VXGE_HW_STATS_VPATH_RX_OFFSET;
-	val64 = (u64 *) vpath_rx_stats;
-
-	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-		goto exit;
-	}
-	for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_rx_stats) / 8; i++) {
-		status = __vxge_hw_vpath_stats_access(vpath,
-					VXGE_HW_STATS_OP_READ,
-					offset >> 3, val64);
-		if (status != VXGE_HW_OK)
-			goto exit;
-
-		offset += 8;
-		val64++;
-	}
-exit:
-	return status;
-}
-
-/*
- * __vxge_hw_vpath_stats_get - Get the vpath hw statistics.
- */
-static enum vxge_hw_status
-__vxge_hw_vpath_stats_get(struct __vxge_hw_virtualpath *vpath,
-			  struct vxge_hw_vpath_stats_hw_info *hw_stats)
-{
-	u64 val64;
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct vxge_hw_vpath_reg __iomem *vp_reg;
-
-	if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-		status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-		goto exit;
-	}
-	vp_reg = vpath->vp_reg;
-
-	val64 = readq(&vp_reg->vpath_debug_stats0);
-	hw_stats->ini_num_mwr_sent =
-		(u32)VXGE_HW_VPATH_DEBUG_STATS0_GET_INI_NUM_MWR_SENT(val64);
-
-	val64 = readq(&vp_reg->vpath_debug_stats1);
-	hw_stats->ini_num_mrd_sent =
-		(u32)VXGE_HW_VPATH_DEBUG_STATS1_GET_INI_NUM_MRD_SENT(val64);
-
-	val64 = readq(&vp_reg->vpath_debug_stats2);
-	hw_stats->ini_num_cpl_rcvd =
-		(u32)VXGE_HW_VPATH_DEBUG_STATS2_GET_INI_NUM_CPL_RCVD(val64);
-
-	val64 = readq(&vp_reg->vpath_debug_stats3);
-	hw_stats->ini_num_mwr_byte_sent =
-		VXGE_HW_VPATH_DEBUG_STATS3_GET_INI_NUM_MWR_BYTE_SENT(val64);
-
-	val64 = readq(&vp_reg->vpath_debug_stats4);
-	hw_stats->ini_num_cpl_byte_rcvd =
-		VXGE_HW_VPATH_DEBUG_STATS4_GET_INI_NUM_CPL_BYTE_RCVD(val64);
-
-	val64 = readq(&vp_reg->vpath_debug_stats5);
-	hw_stats->wrcrdtarb_xoff =
-		(u32)VXGE_HW_VPATH_DEBUG_STATS5_GET_WRCRDTARB_XOFF(val64);
-
-	val64 = readq(&vp_reg->vpath_debug_stats6);
-	hw_stats->rdcrdtarb_xoff =
-		(u32)VXGE_HW_VPATH_DEBUG_STATS6_GET_RDCRDTARB_XOFF(val64);
-
-	val64 = readq(&vp_reg->vpath_genstats_count01);
-	hw_stats->vpath_genstats_count0 =
-	(u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT0(
-		val64);
-
-	val64 = readq(&vp_reg->vpath_genstats_count01);
-	hw_stats->vpath_genstats_count1 =
-	(u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT1(
-		val64);
-
-	val64 = readq(&vp_reg->vpath_genstats_count23);
-	hw_stats->vpath_genstats_count2 =
-	(u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT2(
-		val64);
-
-	val64 = readq(&vp_reg->vpath_genstats_count01);
-	hw_stats->vpath_genstats_count3 =
-	(u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT3(
-		val64);
-
-	val64 = readq(&vp_reg->vpath_genstats_count4);
-	hw_stats->vpath_genstats_count4 =
-	(u32)VXGE_HW_VPATH_GENSTATS_COUNT4_GET_PPIF_VPATH_GENSTATS_COUNT4(
-		val64);
-
-	val64 = readq(&vp_reg->vpath_genstats_count5);
-	hw_stats->vpath_genstats_count5 =
-	(u32)VXGE_HW_VPATH_GENSTATS_COUNT5_GET_PPIF_VPATH_GENSTATS_COUNT5(
-		val64);
-
-	status = __vxge_hw_vpath_xmac_tx_stats_get(vpath, &hw_stats->tx_stats);
-	if (status != VXGE_HW_OK)
-		goto exit;
-
-	status = __vxge_hw_vpath_xmac_rx_stats_get(vpath, &hw_stats->rx_stats);
-	if (status != VXGE_HW_OK)
-		goto exit;
-
-	VXGE_HW_VPATH_STATS_PIO_READ(
-		VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM0_OFFSET);
-
-	hw_stats->prog_event_vnum0 =
-			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM0(val64);
-
-	hw_stats->prog_event_vnum1 =
-			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM1(val64);
-
-	VXGE_HW_VPATH_STATS_PIO_READ(
-		VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM2_OFFSET);
-
-	hw_stats->prog_event_vnum2 =
-			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM2(val64);
-
-	hw_stats->prog_event_vnum3 =
-			(u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM3(val64);
-
-	val64 = readq(&vp_reg->rx_multi_cast_stats);
-	hw_stats->rx_multi_cast_frame_discard =
-		(u16)VXGE_HW_RX_MULTI_CAST_STATS_GET_FRAME_DISCARD(val64);
-
-	val64 = readq(&vp_reg->rx_frm_transferred);
-	hw_stats->rx_frm_transferred =
-		(u32)VXGE_HW_RX_FRM_TRANSFERRED_GET_RX_FRM_TRANSFERRED(val64);
-
-	val64 = readq(&vp_reg->rxd_returned);
-	hw_stats->rxd_returned =
-		(u16)VXGE_HW_RXD_RETURNED_GET_RXD_RETURNED(val64);
-
-	val64 = readq(&vp_reg->dbg_stats_rx_mpa);
-	hw_stats->rx_mpa_len_fail_frms =
-		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_LEN_FAIL_FRMS(val64);
-	hw_stats->rx_mpa_mrk_fail_frms =
-		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_MRK_FAIL_FRMS(val64);
-	hw_stats->rx_mpa_crc_fail_frms =
-		(u16)VXGE_HW_DBG_STATS_GET_RX_MPA_CRC_FAIL_FRMS(val64);
-
-	val64 = readq(&vp_reg->dbg_stats_rx_fau);
-	hw_stats->rx_permitted_frms =
-		(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_PERMITTED_FRMS(val64);
-	hw_stats->rx_vp_reset_discarded_frms =
-	(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_VP_RESET_DISCARDED_FRMS(val64);
-	hw_stats->rx_wol_frms =
-		(u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_WOL_FRMS(val64);
-
-	val64 = readq(&vp_reg->tx_vp_reset_discarded_frms);
-	hw_stats->tx_vp_reset_discarded_frms =
-	(u16)VXGE_HW_TX_VP_RESET_DISCARDED_FRMS_GET_TX_VP_RESET_DISCARDED_FRMS(
-		val64);
-exit:
-	return status;
-}
-
-
-static void vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh,
-					unsigned long size)
-{
-	gfp_t flags;
-	void *vaddr;
-
-	if (in_interrupt())
-		flags = GFP_ATOMIC | GFP_DMA;
-	else
-		flags = GFP_KERNEL | GFP_DMA;
-
-	vaddr = kmalloc((size), flags);
-
-	vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
-}
-
-static void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
-			     struct pci_dev **p_dma_acch)
-{
-	unsigned long misaligned = *(unsigned long *)p_dma_acch;
-	u8 *tmp = (u8 *)vaddr;
-	tmp -= misaligned;
-	kfree((void *)tmp);
-}
-
-/*
- * __vxge_hw_blockpool_create - Create block pool
- */
-
-static enum vxge_hw_status
-__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
-			   struct __vxge_hw_blockpool *blockpool,
-			   u32 pool_size,
-			   u32 pool_max)
-{
-	u32 i;
-	struct __vxge_hw_blockpool_entry *entry = NULL;
-	void *memblock;
-	dma_addr_t dma_addr;
-	struct pci_dev *dma_handle;
-	struct pci_dev *acc_handle;
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	if (blockpool == NULL) {
-		status = VXGE_HW_FAIL;
-		goto blockpool_create_exit;
-	}
-
-	blockpool->hldev = hldev;
-	blockpool->block_size = VXGE_HW_BLOCK_SIZE;
-	blockpool->pool_size = 0;
-	blockpool->pool_max = pool_max;
-	blockpool->req_out = 0;
-
-	INIT_LIST_HEAD(&blockpool->free_block_list);
-	INIT_LIST_HEAD(&blockpool->free_entry_list);
-
-	for (i = 0; i < pool_size + pool_max; i++) {
-		entry = kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
-				GFP_KERNEL);
-		if (entry == NULL) {
-			__vxge_hw_blockpool_destroy(blockpool);
-			status = VXGE_HW_ERR_OUT_OF_MEMORY;
-			goto blockpool_create_exit;
-		}
-		list_add(&entry->item, &blockpool->free_entry_list);
-	}
-
-	for (i = 0; i < pool_size; i++) {
-
-		memblock = vxge_os_dma_malloc(
-				hldev->pdev,
-				VXGE_HW_BLOCK_SIZE,
-				&dma_handle,
-				&acc_handle);
-
-		if (memblock == NULL) {
-			__vxge_hw_blockpool_destroy(blockpool);
-			status = VXGE_HW_ERR_OUT_OF_MEMORY;
-			goto blockpool_create_exit;
-		}
-
-		dma_addr = pci_map_single(hldev->pdev, memblock,
-				VXGE_HW_BLOCK_SIZE, PCI_DMA_BIDIRECTIONAL);
-
-		if (unlikely(pci_dma_mapping_error(hldev->pdev,
-				dma_addr))) {
-
-			vxge_os_dma_free(hldev->pdev, memblock, &acc_handle);
-			__vxge_hw_blockpool_destroy(blockpool);
-			status = VXGE_HW_ERR_OUT_OF_MEMORY;
-			goto blockpool_create_exit;
-		}
-
-		if (!list_empty(&blockpool->free_entry_list))
-			entry = (struct __vxge_hw_blockpool_entry *)
-				list_first_entry(&blockpool->free_entry_list,
-					struct __vxge_hw_blockpool_entry,
-					item);
-
-		if (entry == NULL)
-			entry =
-			    kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
-					GFP_KERNEL);
-		if (entry != NULL) {
-			list_del(&entry->item);
-			entry->length = VXGE_HW_BLOCK_SIZE;
-			entry->memblock = memblock;
-			entry->dma_addr = dma_addr;
-			entry->acc_handle = acc_handle;
-			entry->dma_handle = dma_handle;
-			list_add(&entry->item,
-					  &blockpool->free_block_list);
-			blockpool->pool_size++;
-		} else {
-			__vxge_hw_blockpool_destroy(blockpool);
-			status = VXGE_HW_ERR_OUT_OF_MEMORY;
-			goto blockpool_create_exit;
-		}
-	}
-
-blockpool_create_exit:
-	return status;
-}
-
-/*
- * __vxge_hw_blockpool_destroy - Deallocates the block pool
- */
-
-static void __vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool *blockpool)
-{
-
-	struct __vxge_hw_device *hldev;
-	struct list_head *p, *n;
-	u16 ret;
-
-	if (blockpool == NULL) {
-		ret = 1;
-		goto exit;
-	}
-
-	hldev = blockpool->hldev;
-
-	list_for_each_safe(p, n, &blockpool->free_block_list) {
-
-		pci_unmap_single(hldev->pdev,
-			((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
-			((struct __vxge_hw_blockpool_entry *)p)->length,
-			PCI_DMA_BIDIRECTIONAL);
-
-		vxge_os_dma_free(hldev->pdev,
-			((struct __vxge_hw_blockpool_entry *)p)->memblock,
-			&((struct __vxge_hw_blockpool_entry *) p)->acc_handle);
-
-		list_del(
-			&((struct __vxge_hw_blockpool_entry *)p)->item);
-		kfree(p);
-		blockpool->pool_size--;
-	}
-
-	list_for_each_safe(p, n, &blockpool->free_entry_list) {
-		list_del(
-			&((struct __vxge_hw_blockpool_entry *)p)->item);
-		kfree((void *)p);
-	}
-	ret = 0;
-exit:
-	return;
-}
-
-/*
- * __vxge_hw_blockpool_blocks_add - Request additional blocks
- */
-static
-void __vxge_hw_blockpool_blocks_add(struct __vxge_hw_blockpool *blockpool)
-{
-	u32 nreq = 0, i;
-
-	if ((blockpool->pool_size  +  blockpool->req_out) <
-		VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE) {
-		nreq = VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE;
-		blockpool->req_out += nreq;
-	}
-
-	for (i = 0; i < nreq; i++)
-		vxge_os_dma_malloc_async(
-			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
-			blockpool->hldev, VXGE_HW_BLOCK_SIZE);
-}
-
-/*
- * __vxge_hw_blockpool_blocks_remove - Free additional blocks
- */
-static
-void __vxge_hw_blockpool_blocks_remove(struct __vxge_hw_blockpool *blockpool)
-{
-	struct list_head *p, *n;
-
-	list_for_each_safe(p, n, &blockpool->free_block_list) {
-
-		if (blockpool->pool_size < blockpool->pool_max)
-			break;
-
-		pci_unmap_single(
-			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
-			((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
-			((struct __vxge_hw_blockpool_entry *)p)->length,
-			PCI_DMA_BIDIRECTIONAL);
-
-		vxge_os_dma_free(
-			((struct __vxge_hw_device *)blockpool->hldev)->pdev,
-			((struct __vxge_hw_blockpool_entry *)p)->memblock,
-			&((struct __vxge_hw_blockpool_entry *)p)->acc_handle);
-
-		list_del(&((struct __vxge_hw_blockpool_entry *)p)->item);
-
-		list_add(p, &blockpool->free_entry_list);
-
-		blockpool->pool_size--;
-
-	}
-}
-
-/*
- * vxge_hw_blockpool_block_add - callback for vxge_os_dma_malloc_async
- * Adds a block to block pool
- */
-static void vxge_hw_blockpool_block_add(struct __vxge_hw_device *devh,
-					void *block_addr,
-					u32 length,
-					struct pci_dev *dma_h,
-					struct pci_dev *acc_handle)
-{
-	struct __vxge_hw_blockpool  *blockpool;
-	struct __vxge_hw_blockpool_entry  *entry = NULL;
-	dma_addr_t dma_addr;
-	enum vxge_hw_status status = VXGE_HW_OK;
-	u32 req_out;
-
-	blockpool = &devh->block_pool;
-
-	if (block_addr == NULL) {
-		blockpool->req_out--;
-		status = VXGE_HW_FAIL;
-		goto exit;
-	}
-
-	dma_addr = pci_map_single(devh->pdev, block_addr, length,
-				PCI_DMA_BIDIRECTIONAL);
-
-	if (unlikely(pci_dma_mapping_error(devh->pdev, dma_addr))) {
-
-		vxge_os_dma_free(devh->pdev, block_addr, &acc_handle);
-		blockpool->req_out--;
-		status = VXGE_HW_FAIL;
-		goto exit;
-	}
-
-
-	if (!list_empty(&blockpool->free_entry_list))
-		entry = (struct __vxge_hw_blockpool_entry *)
-			list_first_entry(&blockpool->free_entry_list,
-				struct __vxge_hw_blockpool_entry,
-				item);
-
-	if (entry == NULL)
-		entry = vmalloc(sizeof(struct __vxge_hw_blockpool_entry));
-	else
-		list_del(&entry->item);
-
-	if (entry != NULL) {
-		entry->length = length;
-		entry->memblock = block_addr;
-		entry->dma_addr = dma_addr;
-		entry->acc_handle = acc_handle;
-		entry->dma_handle = dma_h;
-		list_add(&entry->item, &blockpool->free_block_list);
-		blockpool->pool_size++;
-		status = VXGE_HW_OK;
-	} else
-		status = VXGE_HW_ERR_OUT_OF_MEMORY;
-
-	blockpool->req_out--;
-
-	req_out = blockpool->req_out;
-exit:
-	return;
-}
-
-/*
- * __vxge_hw_blockpool_malloc - Allocate a memory block from pool
- * Allocates a block of memory of given size, either from block pool
- * or by calling vxge_os_dma_malloc()
- */
-static void *
-__vxge_hw_blockpool_malloc(struct __vxge_hw_device *devh, u32 size,
-				struct vxge_hw_mempool_dma *dma_object)
-{
-	struct __vxge_hw_blockpool_entry *entry = NULL;
-	struct __vxge_hw_blockpool  *blockpool;
-	void *memblock = NULL;
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	blockpool = &devh->block_pool;
-
-	if (size != blockpool->block_size) {
-
-		memblock = vxge_os_dma_malloc(devh->pdev, size,
-						&dma_object->handle,
-						&dma_object->acc_handle);
-
-		if (memblock == NULL) {
-			status = VXGE_HW_ERR_OUT_OF_MEMORY;
-			goto exit;
-		}
-
-		dma_object->addr = pci_map_single(devh->pdev, memblock, size,
-					PCI_DMA_BIDIRECTIONAL);
-
-		if (unlikely(pci_dma_mapping_error(devh->pdev,
-				dma_object->addr))) {
-			vxge_os_dma_free(devh->pdev, memblock,
-				&dma_object->acc_handle);
-			status = VXGE_HW_ERR_OUT_OF_MEMORY;
-			goto exit;
-		}
-
-	} else {
-
-		if (!list_empty(&blockpool->free_block_list))
-			entry = (struct __vxge_hw_blockpool_entry *)
-				list_first_entry(&blockpool->free_block_list,
-					struct __vxge_hw_blockpool_entry,
-					item);
-
-		if (entry != NULL) {
-			list_del(&entry->item);
-			dma_object->addr = entry->dma_addr;
-			dma_object->handle = entry->dma_handle;
-			dma_object->acc_handle = entry->acc_handle;
-			memblock = entry->memblock;
-
-			list_add(&entry->item,
-				&blockpool->free_entry_list);
-			blockpool->pool_size--;
-		}
-
-		if (memblock != NULL)
-			__vxge_hw_blockpool_blocks_add(blockpool);
-	}
-exit:
-	return memblock;
-}
-
-/*
- * __vxge_hw_blockpool_free - Frees the memory allcoated with
-				__vxge_hw_blockpool_malloc
- */
-static void
-__vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
-			void *memblock, u32 size,
-			struct vxge_hw_mempool_dma *dma_object)
-{
-	struct __vxge_hw_blockpool_entry *entry = NULL;
-	struct __vxge_hw_blockpool  *blockpool;
-	enum vxge_hw_status status = VXGE_HW_OK;
-
-	blockpool = &devh->block_pool;
-
-	if (size != blockpool->block_size) {
-		pci_unmap_single(devh->pdev, dma_object->addr, size,
-			PCI_DMA_BIDIRECTIONAL);
-		vxge_os_dma_free(devh->pdev, memblock, &dma_object->acc_handle);
-	} else {
-
-		if (!list_empty(&blockpool->free_entry_list))
-			entry = (struct __vxge_hw_blockpool_entry *)
-				list_first_entry(&blockpool->free_entry_list,
-					struct __vxge_hw_blockpool_entry,
-					item);
-
-		if (entry == NULL)
-			entry = vmalloc(sizeof(
-					struct __vxge_hw_blockpool_entry));
-		else
-			list_del(&entry->item);
-
-		if (entry != NULL) {
-			entry->length = size;
-			entry->memblock = memblock;
-			entry->dma_addr = dma_object->addr;
-			entry->acc_handle = dma_object->acc_handle;
-			entry->dma_handle = dma_object->handle;
-			list_add(&entry->item,
-					&blockpool->free_block_list);
-			blockpool->pool_size++;
-			status = VXGE_HW_OK;
-		} else
-			status = VXGE_HW_ERR_OUT_OF_MEMORY;
-
-		if (status == VXGE_HW_OK)
-			__vxge_hw_blockpool_blocks_remove(blockpool);
-	}
-}
-
-/*
- * __vxge_hw_blockpool_block_allocate - Allocates a block from block pool
- * This function allocates a block from block pool or from the system
- */
-static struct __vxge_hw_blockpool_entry *
-__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *devh, u32 size)
-{
-	struct __vxge_hw_blockpool_entry *entry = NULL;
-	struct __vxge_hw_blockpool  *blockpool;
-
-	blockpool = &devh->block_pool;
-
-	if (size == blockpool->block_size) {
-
-		if (!list_empty(&blockpool->free_block_list))
-			entry = (struct __vxge_hw_blockpool_entry *)
-				list_first_entry(&blockpool->free_block_list,
-					struct __vxge_hw_blockpool_entry,
-					item);
-
-		if (entry != NULL) {
-			list_del(&entry->item);
-			blockpool->pool_size--;
-		}
-	}
-
-	if (entry != NULL)
-		__vxge_hw_blockpool_blocks_add(blockpool);
-
-	return entry;
-}
-
-/*
- * __vxge_hw_blockpool_block_free - Frees a block from block pool
- * @devh: Hal device
- * @entry: Entry of block to be freed
- *
- * This function frees a block from block pool
- */
-static void
-__vxge_hw_blockpool_block_free(struct __vxge_hw_device *devh,
-			struct __vxge_hw_blockpool_entry *entry)
-{
-	struct __vxge_hw_blockpool  *blockpool;
-
-	blockpool = &devh->block_pool;
-
-	if (entry->length == blockpool->block_size) {
-		list_add(&entry->item, &blockpool->free_block_list);
-		blockpool->pool_size++;
-	}
-
-	__vxge_hw_blockpool_blocks_remove(blockpool);
-}
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 5b2c831..e249e28 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -314,9 +314,9 @@ struct vxge_hw_ring_config {
 #define VXGE_HW_RING_DEFAULT					1
 
 	u32				ring_blocks;
-#define VXGE_HW_MIN_RING_BLOCKS				1
-#define VXGE_HW_MAX_RING_BLOCKS				128
-#define VXGE_HW_DEF_RING_BLOCKS				2
+#define VXGE_HW_MIN_RING_BLOCKS					1
+#define VXGE_HW_MAX_RING_BLOCKS					128
+#define VXGE_HW_DEF_RING_BLOCKS					2
 
 	u32				buffer_mode;
 #define VXGE_HW_RING_RXD_BUFFER_MODE_1				1
@@ -700,7 +700,7 @@ struct __vxge_hw_virtualpath {
  *
  * This structure is used to store the callback information.
  */
-struct __vxge_hw_vpath_handle{
+struct __vxge_hw_vpath_handle {
 	struct list_head	item;
 	struct __vxge_hw_virtualpath	*vpath;
 };
@@ -815,8 +815,8 @@ struct vxge_hw_device_hw_info {
 	u8		serial_number[VXGE_HW_INFO_LEN];
 	u8		part_number[VXGE_HW_INFO_LEN];
 	u8		product_desc[VXGE_HW_INFO_LEN];
-	u8 (mac_addrs)[VXGE_HW_MAX_VIRTUAL_PATHS][ETH_ALEN];
-	u8 (mac_addr_masks)[VXGE_HW_MAX_VIRTUAL_PATHS][ETH_ALEN];
+	u8 mac_addrs[VXGE_HW_MAX_VIRTUAL_PATHS][ETH_ALEN];
+	u8 mac_addr_masks[VXGE_HW_MAX_VIRTUAL_PATHS][ETH_ALEN];
 };
 
 /**
@@ -863,20 +863,10 @@ struct vxge_hw_device_attr {
 				loc, \
 				offset, \
 				&val64);			\
-								\
 	if (status != VXGE_HW_OK)				\
 		return status;						\
 }
 
-#define VXGE_HW_VPATH_STATS_PIO_READ(offset) {				\
-	status = __vxge_hw_vpath_stats_access(vpath, \
-			VXGE_HW_STATS_OP_READ, \
-			offset, \
-			&val64);					\
-	if (status != VXGE_HW_OK)					\
-		return status;						\
-}
-
 /*
  * struct __vxge_hw_ring - Ring channel.
  * @channel: Channel "base" of this ring, the common part of all HW
@@ -1148,7 +1138,7 @@ struct __vxge_hw_non_offload_db_wrapper {
  *             lookup to determine the transmit port.
  *             01: Send on physical Port1.
  *             10: Send on physical Port0.
-	*	       11: Send on both ports.
+ *	       11: Send on both ports.
  *             Bits 18 to 21 - Reserved
  *             Bits 22 to 23 - Gather_Code. This field is set by the host and
  *             is used to describe how individual buffers comprise a frame.
@@ -1927,6 +1917,15 @@ out:
 	return vaddr;
 }
 
+static inline void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
+			struct pci_dev **p_dma_acch)
+{
+	unsigned long misaligned = *(unsigned long *)p_dma_acch;
+	u8 *tmp = (u8 *)vaddr;
+	tmp -= misaligned;
+	kfree((void *)tmp);
+}
+
 /*
  * __vxge_hw_mempool_item_priv - will return pointer on per item private space
  */
@@ -1996,7 +1995,6 @@ enum vxge_hw_status vxge_hw_vpath_mtu_set(
 void
 vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp);
 
-
 #ifndef readq
 static inline u64 readq(void __iomem *addr)
 {
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index 4877b3b..70c3279 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -84,15 +84,6 @@ module_param_array(bw_percentage, uint, NULL, 0);
 
 static struct vxge_drv_config *driver_config;
 
-static enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
-					     struct macInfo *mac);
-static enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
-					     struct macInfo *mac);
-static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac);
-static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac);
-static enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath);
-static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath);
-
 static inline int is_vxge_card_up(struct vxgedev *vdev)
 {
 	return test_bit(__VXGE_STATE_CARD_UP, &vdev->state);
@@ -149,8 +140,7 @@ static inline void VXGE_COMPLETE_ALL_RX(struct vxgedev *vdev)
  * This function is called during interrupt context to notify link up state
  * change.
  */
-static void
-vxge_callback_link_up(struct __vxge_hw_device *hldev)
+static void vxge_callback_link_up(struct __vxge_hw_device *hldev)
 {
 	struct net_device *dev = hldev->ndev;
 	struct vxgedev *vdev = netdev_priv(dev);
@@ -173,8 +163,7 @@ vxge_callback_link_up(struct __vxge_hw_device *hldev)
  * This function is called during interrupt context to notify link down state
  * change.
  */
-static void
-vxge_callback_link_down(struct __vxge_hw_device *hldev)
+static void vxge_callback_link_down(struct __vxge_hw_device *hldev)
 {
 	struct net_device *dev = hldev->ndev;
 	struct vxgedev *vdev = netdev_priv(dev);
@@ -196,7 +185,7 @@ vxge_callback_link_down(struct __vxge_hw_device *hldev)
  *
  * Allocate SKB.
  */
-static struct sk_buff*
+static struct sk_buff *
 vxge_rx_alloc(void *dtrh, struct vxge_ring *ring, const int skb_size)
 {
 	struct net_device    *dev;
@@ -414,7 +403,6 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 
 		prefetch((char *)skb + L1_CACHE_BYTES);
 		if (unlikely(t_code)) {
-
 			if (vxge_hw_ring_handle_tcode(ringh, dtr, t_code) !=
 				VXGE_HW_OK) {
 
@@ -437,9 +425,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
 		}
 
 		if (pkt_length > VXGE_LL_RX_COPY_THRESHOLD) {
-
 			if (vxge_rx_alloc(dtr, ring, data_size) != NULL) {
-
 				if (!vxge_rx_map(dtr, ring)) {
 					skb_put(skb, pkt_length);
 
@@ -678,6 +664,65 @@ static enum vxge_hw_status vxge_search_mac_addr_in_list(
 	return FALSE;
 }
 
+static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
+{
+	struct vxge_mac_addrs *new_mac_entry;
+	u8 *mac_address = NULL;
+
+	if (vpath->mac_addr_cnt >= VXGE_MAX_LEARN_MAC_ADDR_CNT)
+		return TRUE;
+
+	new_mac_entry = kzalloc(sizeof(struct vxge_mac_addrs), GFP_ATOMIC);
+	if (!new_mac_entry) {
+		vxge_debug_mem(VXGE_ERR,
+			"%s: memory allocation failed",
+			VXGE_DRIVER_NAME);
+		return FALSE;
+	}
+
+	list_add(&new_mac_entry->item, &vpath->mac_addr_list);
+
+	/* Copy the new mac address to the list */
+	mac_address = (u8 *)&new_mac_entry->macaddr;
+	memcpy(mac_address, mac->macaddr, ETH_ALEN);
+
+	new_mac_entry->state = mac->state;
+	vpath->mac_addr_cnt++;
+
+	/* Is this a multicast address */
+	if (0x01 & mac->macaddr[0])
+		vpath->mcast_addr_cnt++;
+
+	return TRUE;
+}
+
+/* Add a mac address to DA table */
+static enum vxge_hw_status
+vxge_add_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath;
+	enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode;
+
+	if (0x01 & mac->macaddr[0]) /* multicast address */
+		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE;
+	else
+		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_REPLACE_DUPLICATE;
+
+	vpath = &vdev->vpaths[mac->vpath_no];
+	status = vxge_hw_vpath_mac_addr_add(vpath->handle, mac->macaddr,
+						mac->macmask, duplicate_mode);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"DA config add entry failed for vpath:%d",
+			vpath->device_id);
+	} else
+		if (FALSE == vxge_mac_list_add(vpath, mac))
+			status = -EPERM;
+
+	return status;
+}
+
 static int vxge_learn_mac(struct vxgedev *vdev, u8 *mac_header)
 {
 	struct macInfo mac_info;
@@ -1023,6 +1068,50 @@ vxge_tx_term(void *dtrh, enum vxge_hw_txdl_state state, void *userdata)
 		"%s:%d  Exiting...", __func__, __LINE__);
 }
 
+static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
+{
+	struct list_head *entry, *next;
+	u64 del_mac = 0;
+	u8 *mac_address = (u8 *) (&del_mac);
+
+	/* Copy the mac address to delete from the list */
+	memcpy(mac_address, mac->macaddr, ETH_ALEN);
+
+	list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+		if (((struct vxge_mac_addrs *)entry)->macaddr == del_mac) {
+			list_del(entry);
+			kfree((struct vxge_mac_addrs *)entry);
+			vpath->mac_addr_cnt--;
+
+			/* Is this a multicast address */
+			if (0x01 & mac->macaddr[0])
+				vpath->mcast_addr_cnt--;
+			return TRUE;
+		}
+	}
+
+	return FALSE;
+}
+
+/* delete a mac address from DA table */
+static enum vxge_hw_status
+vxge_del_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxge_vpath *vpath;
+
+	vpath = &vdev->vpaths[mac->vpath_no];
+	status = vxge_hw_vpath_mac_addr_delete(vpath->handle, mac->macaddr,
+						mac->macmask);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"DA config delete entry failed for vpath:%d",
+			vpath->device_id);
+	} else
+		vxge_mac_list_del(vpath, mac);
+	return status;
+}
+
 /**
  * vxge_set_multicast
  * @dev: pointer to the device structure
@@ -1333,6 +1422,95 @@ static void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
 	}
 }
 
+/* list all mac addresses from DA table */
+static enum vxge_hw_status
+vxge_search_mac_addr_in_da_table(struct vxge_vpath *vpath, struct macInfo *mac)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	unsigned char macmask[ETH_ALEN];
+	unsigned char macaddr[ETH_ALEN];
+
+	status = vxge_hw_vpath_mac_addr_get(vpath->handle,
+				macaddr, macmask);
+	if (status != VXGE_HW_OK) {
+		vxge_debug_init(VXGE_ERR,
+			"DA config list entry failed for vpath:%d",
+			vpath->device_id);
+		return status;
+	}
+
+	while (memcmp(mac->macaddr, macaddr, ETH_ALEN)) {
+		status = vxge_hw_vpath_mac_addr_get_next(vpath->handle,
+				macaddr, macmask);
+		if (status != VXGE_HW_OK)
+			break;
+	}
+
+	return status;
+}
+
+/* Store all mac addresses from the list to the DA table */
+static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct macInfo mac_info;
+	u8 *mac_address = NULL;
+	struct list_head *entry, *next;
+
+	memset(&mac_info, 0, sizeof(struct macInfo));
+
+	if (vpath->is_open) {
+		list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+			mac_address =
+				(u8 *)&
+				((struct vxge_mac_addrs *)entry)->macaddr;
+			memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
+			((struct vxge_mac_addrs *)entry)->state =
+				VXGE_LL_MAC_ADDR_IN_DA_TABLE;
+			/* does this mac address already exist in da table? */
+			status = vxge_search_mac_addr_in_da_table(vpath,
+				&mac_info);
+			if (status != VXGE_HW_OK) {
+				/* Add this mac address to the DA table */
+				status = vxge_hw_vpath_mac_addr_add(
+					vpath->handle, mac_info.macaddr,
+					mac_info.macmask,
+				    VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE);
+				if (status != VXGE_HW_OK) {
+					vxge_debug_init(VXGE_ERR,
+					    "DA add entry failed for vpath:%d",
+					    vpath->device_id);
+					((struct vxge_mac_addrs *)entry)->state
+						= VXGE_LL_MAC_ADDR_IN_LIST;
+				}
+			}
+		}
+	}
+
+	return status;
+}
+
+/* Store all vlan ids from the list to the vid table */
+static enum vxge_hw_status
+vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
+{
+	enum vxge_hw_status status = VXGE_HW_OK;
+	struct vxgedev *vdev = vpath->vdev;
+	u16 vid;
+
+	if (vdev->vlgrp && vpath->is_open) {
+
+		for (vid = 0; vid < VLAN_N_VID; vid++) {
+			if (!vlan_group_get_device(vdev->vlgrp, vid))
+				continue;
+			/* Add these vlan to the vid table */
+			status = vxge_hw_vpath_vid_add(vpath->handle, vid);
+		}
+	}
+
+	return status;
+}
+
 /*
  * vxge_reset_vpath
  * @vdev: pointer to vdev
@@ -1745,7 +1923,6 @@ static enum vxge_hw_status vxge_rth_configure(struct vxgedev *vdev)
 				vdev->config.rth_algorithm,
 				&hash_types,
 				vdev->config.rth_bkt_sz);
-
 		 if (status != VXGE_HW_OK) {
 			vxge_debug_init(VXGE_ERR,
 				"RTH configuration failed for vpath:%d",
@@ -1757,199 +1934,6 @@ static enum vxge_hw_status vxge_rth_configure(struct vxgedev *vdev)
 	return status;
 }
 
-static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
-{
-	struct vxge_mac_addrs *new_mac_entry;
-	u8 *mac_address = NULL;
-
-	if (vpath->mac_addr_cnt >= VXGE_MAX_LEARN_MAC_ADDR_CNT)
-		return TRUE;
-
-	new_mac_entry = kzalloc(sizeof(struct vxge_mac_addrs), GFP_ATOMIC);
-	if (!new_mac_entry) {
-		vxge_debug_mem(VXGE_ERR,
-			"%s: memory allocation failed",
-			VXGE_DRIVER_NAME);
-		return FALSE;
-	}
-
-	list_add(&new_mac_entry->item, &vpath->mac_addr_list);
-
-	/* Copy the new mac address to the list */
-	mac_address = (u8 *)&new_mac_entry->macaddr;
-	memcpy(mac_address, mac->macaddr, ETH_ALEN);
-
-	new_mac_entry->state = mac->state;
-	vpath->mac_addr_cnt++;
-
-	/* Is this a multicast address */
-	if (0x01 & mac->macaddr[0])
-		vpath->mcast_addr_cnt++;
-
-	return TRUE;
-}
-
-/* Add a mac address to DA table */
-static enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
-					     struct macInfo *mac)
-{
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct vxge_vpath *vpath;
-	enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode;
-
-	if (0x01 & mac->macaddr[0]) /* multicast address */
-		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE;
-	else
-		duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_REPLACE_DUPLICATE;
-
-	vpath = &vdev->vpaths[mac->vpath_no];
-	status = vxge_hw_vpath_mac_addr_add(vpath->handle, mac->macaddr,
-						mac->macmask, duplicate_mode);
-	if (status != VXGE_HW_OK) {
-		vxge_debug_init(VXGE_ERR,
-			"DA config add entry failed for vpath:%d",
-			vpath->device_id);
-	} else
-		if (FALSE == vxge_mac_list_add(vpath, mac))
-			status = -EPERM;
-
-	return status;
-}
-
-static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
-{
-	struct list_head *entry, *next;
-	u64 del_mac = 0;
-	u8 *mac_address = (u8 *)(&del_mac);
-
-	/* Copy the mac address to delete from the list */
-	memcpy(mac_address, mac->macaddr, ETH_ALEN);
-
-	list_for_each_safe(entry, next, &vpath->mac_addr_list) {
-		if (((struct vxge_mac_addrs *)entry)->macaddr == del_mac) {
-			list_del(entry);
-			kfree((struct vxge_mac_addrs *)entry);
-			vpath->mac_addr_cnt--;
-
-			/* Is this a multicast address */
-			if (0x01 & mac->macaddr[0])
-				vpath->mcast_addr_cnt--;
-			return TRUE;
-		}
-	}
-
-	return FALSE;
-}
-/* delete a mac address from DA table */
-static enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
-					     struct macInfo *mac)
-{
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct vxge_vpath *vpath;
-
-	vpath = &vdev->vpaths[mac->vpath_no];
-	status = vxge_hw_vpath_mac_addr_delete(vpath->handle, mac->macaddr,
-						mac->macmask);
-	if (status != VXGE_HW_OK) {
-		vxge_debug_init(VXGE_ERR,
-			"DA config delete entry failed for vpath:%d",
-			vpath->device_id);
-	} else
-		vxge_mac_list_del(vpath, mac);
-	return status;
-}
-
-/* list all mac addresses from DA table */
-enum vxge_hw_status
-static vxge_search_mac_addr_in_da_table(struct vxge_vpath *vpath,
-					struct macInfo *mac)
-{
-	enum vxge_hw_status status = VXGE_HW_OK;
-	unsigned char macmask[ETH_ALEN];
-	unsigned char macaddr[ETH_ALEN];
-
-	status = vxge_hw_vpath_mac_addr_get(vpath->handle,
-				macaddr, macmask);
-	if (status != VXGE_HW_OK) {
-		vxge_debug_init(VXGE_ERR,
-			"DA config list entry failed for vpath:%d",
-			vpath->device_id);
-		return status;
-	}
-
-	while (memcmp(mac->macaddr, macaddr, ETH_ALEN)) {
-
-		status = vxge_hw_vpath_mac_addr_get_next(vpath->handle,
-				macaddr, macmask);
-		if (status != VXGE_HW_OK)
-			break;
-	}
-
-	return status;
-}
-
-/* Store all vlan ids from the list to the vid table */
-static enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
-{
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct vxgedev *vdev = vpath->vdev;
-	u16 vid;
-
-	if (vdev->vlgrp && vpath->is_open) {
-
-		for (vid = 0; vid < VLAN_N_VID; vid++) {
-			if (!vlan_group_get_device(vdev->vlgrp, vid))
-				continue;
-			/* Add these vlan to the vid table */
-			status = vxge_hw_vpath_vid_add(vpath->handle, vid);
-		}
-	}
-
-	return status;
-}
-
-/* Store all mac addresses from the list to the DA table */
-static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
-{
-	enum vxge_hw_status status = VXGE_HW_OK;
-	struct macInfo mac_info;
-	u8 *mac_address = NULL;
-	struct list_head *entry, *next;
-
-	memset(&mac_info, 0, sizeof(struct macInfo));
-
-	if (vpath->is_open) {
-
-		list_for_each_safe(entry, next, &vpath->mac_addr_list) {
-			mac_address =
-				(u8 *)&
-				((struct vxge_mac_addrs *)entry)->macaddr;
-			memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
-			((struct vxge_mac_addrs *)entry)->state =
-				VXGE_LL_MAC_ADDR_IN_DA_TABLE;
-			/* does this mac address already exist in da table? */
-			status = vxge_search_mac_addr_in_da_table(vpath,
-				&mac_info);
-			if (status != VXGE_HW_OK) {
-				/* Add this mac address to the DA table */
-				status = vxge_hw_vpath_mac_addr_add(
-					vpath->handle, mac_info.macaddr,
-					mac_info.macmask,
-				    VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE);
-				if (status != VXGE_HW_OK) {
-					vxge_debug_init(VXGE_ERR,
-					    "DA add entry failed for vpath:%d",
-					    vpath->device_id);
-					((struct vxge_mac_addrs *)entry)->state
-						= VXGE_LL_MAC_ADDR_IN_LIST;
-				}
-			}
-		}
-	}
-
-	return status;
-}
-
 /* reset vpaths */
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
 {
@@ -2042,6 +2026,7 @@ static int vxge_open_vpaths(struct vxgedev *vdev)
 
 		vpath->ring.ndev = vdev->ndev;
 		vpath->ring.pdev = vdev->pdev;
+
 		status = vxge_hw_vpath_open(vdev->devh, &attr, &vpath->handle);
 		if (status == VXGE_HW_OK) {
 			vpath->fifo.handle =
@@ -2070,11 +2055,10 @@ static int vxge_open_vpaths(struct vxgedev *vdev)
 			vdev->stats.vpaths_open++;
 		} else {
 			vdev->stats.vpath_open_fail++;
-			vxge_debug_init(VXGE_ERR,
-				"%s: vpath: %d failed to open "
-				"with status: %d",
-			    vdev->ndev->name, vpath->device_id,
-				status);
+			vxge_debug_init(VXGE_ERR, "%s: vpath: %d failed to "
+					"open with status: %d",
+					vdev->ndev->name, vpath->device_id,
+					status);
 			vxge_close_vpaths(vdev, 0);
 			return -EPERM;
 		}
@@ -2082,6 +2066,7 @@ static int vxge_open_vpaths(struct vxgedev *vdev)
 		vp_id = vpath->handle->vpath->vp_id;
 		vdev->vpaths_deployed |= vxge_mBIT(vp_id);
 	}
+
 	return VXGE_HW_OK;
 }
 
@@ -2114,8 +2099,7 @@ static irqreturn_t vxge_isr_napi(int irq, void *dev_id)
 	if (unlikely(!is_vxge_card_up(vdev)))
 		return IRQ_HANDLED;
 
-	status = vxge_hw_device_begin_irq(hldev, vdev->exec_mode,
-			&reason);
+	status = vxge_hw_device_begin_irq(hldev, vdev->exec_mode, &reason);
 	if (status == VXGE_HW_OK) {
 		vxge_hw_device_mask_all(hldev);
 
@@ -2568,8 +2552,7 @@ static void vxge_poll_vp_lockup(unsigned long data)
  * Return value: '0' on success and an appropriate (-)ve integer as
  * defined in errno.h file on failure.
  */
-static int
-vxge_open(struct net_device *dev)
+static int vxge_open(struct net_device *dev)
 {
 	enum vxge_hw_status status;
 	struct vxgedev *vdev;
@@ -2578,6 +2561,7 @@ vxge_open(struct net_device *dev)
 	int ret = 0;
 	int i;
 	u64 val64, function_mode;
+
 	vxge_debug_entryexit(VXGE_TRACE,
 		"%s: %s:%d", dev->name, __func__, __LINE__);
 
@@ -2830,7 +2814,6 @@ static int do_vxge_close(struct net_device *dev, int do_io)
 					struct vxge_hw_mrpcim_reg,
 					rts_mgr_cbasin_cfg),
 				&val64);
-
 		if (status == VXGE_HW_OK) {
 			val64 &= ~vpath_vector;
 			status = vxge_hw_mgmt_reg_write(vdev->devh,
@@ -2914,8 +2897,7 @@ static int do_vxge_close(struct net_device *dev, int do_io)
  * Return value: '0' on success and an appropriate (-)ve integer as
  * defined in errno.h file on failure.
  */
-static int
-vxge_close(struct net_device *dev)
+static int vxge_close(struct net_device *dev)
 {
 	do_vxge_close(dev, 1);
 	return 0;
@@ -2989,9 +2971,7 @@ vxge_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *net_stats)
 		net_stats->rx_bytes += vdev->vpaths[k].ring.stats.rx_bytes;
 		net_stats->rx_errors += vdev->vpaths[k].ring.stats.rx_errors;
 		net_stats->multicast += vdev->vpaths[k].ring.stats.rx_mcast;
-		net_stats->rx_dropped +=
-			vdev->vpaths[k].ring.stats.rx_dropped;
-
+		net_stats->rx_dropped += vdev->vpaths[k].ring.stats.rx_dropped;
 		net_stats->tx_packets += vdev->vpaths[k].fifo.stats.tx_frms;
 		net_stats->tx_bytes += vdev->vpaths[k].fifo.stats.tx_bytes;
 		net_stats->tx_errors += vdev->vpaths[k].fifo.stats.tx_errors;
@@ -3264,15 +3244,12 @@ static const struct net_device_ops vxge_netdev_ops = {
 	.ndo_start_xmit         = vxge_xmit,
 	.ndo_validate_addr      = eth_validate_addr,
 	.ndo_set_multicast_list = vxge_set_multicast,
-
 	.ndo_do_ioctl           = vxge_ioctl,
-
 	.ndo_set_mac_address    = vxge_set_mac_addr,
 	.ndo_change_mtu         = vxge_change_mtu,
 	.ndo_vlan_rx_register   = vxge_vlan_rx_register,
 	.ndo_vlan_rx_kill_vid   = vxge_vlan_rx_kill_vid,
 	.ndo_vlan_rx_add_vid	= vxge_vlan_rx_add_vid,
-
 	.ndo_tx_timeout         = vxge_tx_watchdog,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller    = vxge_netpoll,
@@ -3698,9 +3675,9 @@ static int __devinit vxge_config_vpaths(
 		device_config->vp_config[i].tti.timer_ac_en =
 				VXGE_HW_TIM_TIMER_AC_ENABLE;
 
-		/* For msi-x with napi (each vector
-		has a handler of its own) -
-		Set CI to OFF for all vpaths */
+		/* For msi-x with napi (each vector has a handler of its own) -
+		 * Set CI to OFF for all vpaths
+		 */
 		device_config->vp_config[i].tti.timer_ci_en =
 			VXGE_HW_TIM_TIMER_CI_DISABLE;
 
@@ -3730,10 +3707,13 @@ static int __devinit vxge_config_vpaths(
 
 		device_config->vp_config[i].ring.ring_blocks  =
 						VXGE_HW_DEF_RING_BLOCKS;
+
 		device_config->vp_config[i].ring.buffer_mode =
 			VXGE_HW_RING_RXD_BUFFER_MODE_1;
+
 		device_config->vp_config[i].ring.rxds_limit  =
 				VXGE_HW_DEF_RING_RXDS_LIMIT;
+
 		device_config->vp_config[i].ring.scatter_mode =
 					VXGE_HW_RING_SCATTER_MODE_A;
 
@@ -3813,6 +3793,7 @@ static void __devinit vxge_device_config_init(
 		device_config->intr_mode = VXGE_HW_INTR_MODE_MSIX;
 		break;
 	}
+
 	/* Timer period between device poll */
 	device_config->device_poll_millis = VXGE_TIMER_DELAY;
 
@@ -3824,16 +3805,10 @@ static void __devinit vxge_device_config_init(
 
 	vxge_debug_ll_config(VXGE_TRACE, "%s : Device Config Params ",
 			__func__);
-	vxge_debug_ll_config(VXGE_TRACE, "dma_blockpool_initial : %d",
-			device_config->dma_blockpool_initial);
-	vxge_debug_ll_config(VXGE_TRACE, "dma_blockpool_max : %d",
-			device_config->dma_blockpool_max);
 	vxge_debug_ll_config(VXGE_TRACE, "intr_mode : %d",
 			device_config->intr_mode);
 	vxge_debug_ll_config(VXGE_TRACE, "device_poll_millis : %d",
 			device_config->device_poll_millis);
-	vxge_debug_ll_config(VXGE_TRACE, "rts_mac_en : %d",
-			device_config->rts_mac_en);
 	vxge_debug_ll_config(VXGE_TRACE, "rth_en : %d",
 			device_config->rth_en);
 	vxge_debug_ll_config(VXGE_TRACE, "rth_it_type : %d",
@@ -4013,7 +3988,7 @@ static pci_ers_result_t vxge_io_slot_reset(struct pci_dev *pdev)
 	}
 
 	pci_set_master(pdev);
-	vxge_reset(vdev);
+	do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
 
 	return PCI_ERS_RESULT_RECOVERED;
 }
@@ -4244,9 +4219,10 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 	attr.pdev = pdev;
 
 	/* In SRIOV-17 mode, functions of the same adapter
-	 * can be deployed on different buses */
-	if ((!pdev->is_virtfn) && ((bus != pdev->bus->number) ||
-		(device != PCI_SLOT(pdev->devfn))))
+	 * can be deployed on different buses
+	 */
+	if (((bus != pdev->bus->number) || (device != PCI_SLOT(pdev->devfn))) &&
+	    !pdev->is_virtfn)
 		new_device = 1;
 
 	bus = pdev->bus->number;
@@ -4264,6 +4240,7 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		driver_config->config_dev_cnt = 0;
 		driver_config->total_dev_cnt = 0;
 	}
+
 	/* Now making the CPU based no of vpath calculation
 	 * applicable for individual functions as well.
 	 */
@@ -4286,11 +4263,11 @@ vxge_probe(struct pci_dev *pdev, const struct pci_device_id *pre)
 		goto _exit0;
 	}
 
-	ll_config = kzalloc(sizeof(*ll_config), GFP_KERNEL);
+	ll_config = kzalloc(sizeof(struct vxge_config), GFP_KERNEL);
 	if (!ll_config) {
 		ret = -ENOMEM;
 		vxge_debug_init(VXGE_ERR,
-			"ll_config : malloc failed %s %d",
+			"device_config : malloc failed %s %d",
 			__FILE__, __LINE__);
 		goto _exit0;
 	}
@@ -4746,6 +4723,10 @@ vxge_starter(void)
 		return -ENOMEM;
 
 	ret = pci_register_driver(&vxge_driver);
+	if (ret) {
+		kfree(driver_config);
+		goto err;
+	}
 
 	if (driver_config->config_dev_cnt &&
 	   (driver_config->config_dev_cnt != driver_config->total_dev_cnt))
@@ -4753,10 +4734,7 @@ vxge_starter(void)
 			"%s: Configured %d of %d devices",
 			VXGE_DRIVER_NAME, driver_config->config_dev_cnt,
 			driver_config->total_dev_cnt);
-
-	if (ret)
-		kfree(driver_config);
-
+err:
 	return ret;
 }
 
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 953cb0d..256d5b4 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -305,8 +305,8 @@ struct vxge_vpath {
 	int is_configured;
 	int is_open;
 	struct vxgedev *vdev;
-	u8 (macaddr)[ETH_ALEN];
-	u8 (macmask)[ETH_ALEN];
+	u8 macaddr[ETH_ALEN];
+	u8 macmask[ETH_ALEN];
 
 #define VXGE_MAX_LEARN_MAC_ADDR_CNT	2048
 	/* mac addresses currently programmed into NIC */
@@ -420,10 +420,8 @@ struct vxge_tx_priv {
 		mod_timer(&timer, (jiffies + exp)); \
 	} while (0);
 
-extern void vxge_initialize_ethtool_ops(struct net_device *ndev);
-
+void vxge_initialize_ethtool_ops(struct net_device *ndev);
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
-
 int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override);
 
 /**
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index 4bdb611..42cc298 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -17,13 +17,6 @@
 #include "vxge-config.h"
 #include "vxge-main.h"
 
-static enum vxge_hw_status
-__vxge_hw_device_handle_error(struct __vxge_hw_device *hldev,
-			      u32 vp_id, enum vxge_hw_event type);
-static enum vxge_hw_status
-__vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
-			      u32 skip_alarms);
-
 /*
  * vxge_hw_vpath_intr_enable - Enable vpath interrupts.
  * @vp: Virtual Path handle.
@@ -419,6 +412,384 @@ void vxge_hw_device_flush_io(struct __vxge_hw_device *hldev)
 }
 
 /**
+ * __vxge_hw_device_handle_error - Handle error
+ * @hldev: HW device
+ * @vp_id: Vpath Id
+ * @type: Error type. Please see enum vxge_hw_event{}
+ *
+ * Handle error.
+ */
+static enum vxge_hw_status
+__vxge_hw_device_handle_error(struct __vxge_hw_device *hldev, u32 vp_id,
+			      enum vxge_hw_event type)
+{
+	switch (type) {
+	case VXGE_HW_EVENT_UNKNOWN:
+		break;
+	case VXGE_HW_EVENT_RESET_START:
+	case VXGE_HW_EVENT_RESET_COMPLETE:
+	case VXGE_HW_EVENT_LINK_DOWN:
+	case VXGE_HW_EVENT_LINK_UP:
+		goto out;
+	case VXGE_HW_EVENT_ALARM_CLEARED:
+		goto out;
+	case VXGE_HW_EVENT_ECCERR:
+	case VXGE_HW_EVENT_MRPCIM_ECCERR:
+		goto out;
+	case VXGE_HW_EVENT_FIFO_ERR:
+	case VXGE_HW_EVENT_VPATH_ERR:
+	case VXGE_HW_EVENT_CRITICAL_ERR:
+	case VXGE_HW_EVENT_SERR:
+		break;
+	case VXGE_HW_EVENT_SRPCIM_SERR:
+	case VXGE_HW_EVENT_MRPCIM_SERR:
+		goto out;
+	case VXGE_HW_EVENT_SLOT_FREEZE:
+		break;
+	default:
+		vxge_assert(0);
+		goto out;
+	}
+
+	/* notify driver */
+	if (hldev->uld_callbacks.crit_err)
+		hldev->uld_callbacks.crit_err(
+			(struct __vxge_hw_device *)hldev,
+			type, vp_id);
+out:
+
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_handle_link_down_ind
+ * @hldev: HW device handle.
+ *
+ * Link down indication handler. The function is invoked by HW when
+ * Titan indicates that the link is down.
+ */
+static enum vxge_hw_status
+__vxge_hw_device_handle_link_down_ind(struct __vxge_hw_device *hldev)
+{
+	/*
+	 * If the previous link state is not down, return.
+	 */
+	if (hldev->link_state == VXGE_HW_LINK_DOWN)
+		goto exit;
+
+	hldev->link_state = VXGE_HW_LINK_DOWN;
+
+	/* notify driver */
+	if (hldev->uld_callbacks.link_down)
+		hldev->uld_callbacks.link_down(hldev);
+exit:
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_handle_link_up_ind
+ * @hldev: HW device handle.
+ *
+ * Link up indication handler. The function is invoked by HW when
+ * Titan indicates that the link is up for programmable amount of time.
+ */
+static enum vxge_hw_status
+__vxge_hw_device_handle_link_up_ind(struct __vxge_hw_device *hldev)
+{
+	/*
+	 * If the previous link state is not down, return.
+	 */
+	if (hldev->link_state == VXGE_HW_LINK_UP)
+		goto exit;
+
+	hldev->link_state = VXGE_HW_LINK_UP;
+
+	/* notify driver */
+	if (hldev->uld_callbacks.link_up)
+		hldev->uld_callbacks.link_up(hldev);
+exit:
+	return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_vpath_alarm_process - Process Alarms.
+ * @vpath: Virtual Path.
+ * @skip_alarms: Do not clear the alarms
+ *
+ * Process vpath alarms.
+ *
+ */
+static enum vxge_hw_status
+__vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
+			      u32 skip_alarms)
+{
+	u64 val64;
+	u64 alarm_status;
+	u64 pic_status;
+	struct __vxge_hw_device *hldev = NULL;
+	enum vxge_hw_event alarm_event = VXGE_HW_EVENT_UNKNOWN;
+	u64 mask64;
+	struct vxge_hw_vpath_stats_sw_info *sw_stats;
+	struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+	if (vpath == NULL) {
+		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
+			alarm_event);
+		goto out2;
+	}
+
+	hldev = vpath->hldev;
+	vp_reg = vpath->vp_reg;
+	alarm_status = readq(&vp_reg->vpath_general_int_status);
+
+	if (alarm_status == VXGE_HW_ALL_FOXES) {
+		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_SLOT_FREEZE,
+			alarm_event);
+		goto out;
+	}
+
+	sw_stats = vpath->sw_stats;
+
+	if (alarm_status & ~(
+		VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT |
+		VXGE_HW_VPATH_GENERAL_INT_STATUS_PCI_INT |
+		VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT |
+		VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT)) {
+		sw_stats->error_stats.unknown_alarms++;
+
+		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
+			alarm_event);
+		goto out;
+	}
+
+	if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT) {
+
+		val64 = readq(&vp_reg->xgmac_vp_int_status);
+
+		if (val64 &
+		VXGE_HW_XGMAC_VP_INT_STATUS_ASIC_NTWK_VP_ERR_ASIC_NTWK_VP_INT) {
+
+			val64 = readq(&vp_reg->asic_ntwk_vp_err_reg);
+
+			if (((val64 &
+			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT) &&
+			     (!(val64 &
+				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK))) ||
+			    ((val64 &
+			     VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR) &&
+			     (!(val64 &
+				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR)
+				     ))) {
+				sw_stats->error_stats.network_sustained_fault++;
+
+				writeq(
+				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT,
+					&vp_reg->asic_ntwk_vp_err_mask);
+
+				__vxge_hw_device_handle_link_down_ind(hldev);
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_LINK_DOWN, alarm_event);
+			}
+
+			if (((val64 &
+			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK) &&
+			     (!(val64 &
+				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT))) ||
+			    ((val64 &
+			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR) &&
+			     (!(val64 &
+				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR)
+				     ))) {
+
+				sw_stats->error_stats.network_sustained_ok++;
+
+				writeq(
+				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK,
+					&vp_reg->asic_ntwk_vp_err_mask);
+
+				__vxge_hw_device_handle_link_up_ind(hldev);
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_LINK_UP, alarm_event);
+			}
+
+			writeq(VXGE_HW_INTR_MASK_ALL,
+				&vp_reg->asic_ntwk_vp_err_reg);
+
+			alarm_event = VXGE_HW_SET_LEVEL(
+				VXGE_HW_EVENT_ALARM_CLEARED, alarm_event);
+
+			if (skip_alarms)
+				return VXGE_HW_OK;
+		}
+	}
+
+	if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT) {
+
+		pic_status = readq(&vp_reg->vpath_ppif_int_status);
+
+		if (pic_status &
+		    VXGE_HW_VPATH_PPIF_INT_STATUS_GENERAL_ERRORS_GENERAL_INT) {
+
+			val64 = readq(&vp_reg->general_errors_reg);
+			mask64 = readq(&vp_reg->general_errors_mask);
+
+			if ((val64 &
+				VXGE_HW_GENERAL_ERRORS_REG_INI_SERR_DET) &
+				~mask64) {
+				sw_stats->error_stats.ini_serr_det++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_SERR, alarm_event);
+			}
+
+			if ((val64 &
+			    VXGE_HW_GENERAL_ERRORS_REG_DBLGEN_FIFO0_OVRFLOW) &
+				~mask64) {
+				sw_stats->error_stats.dblgen_fifo0_overflow++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_FIFO_ERR, alarm_event);
+			}
+
+			if ((val64 &
+			    VXGE_HW_GENERAL_ERRORS_REG_STATSB_PIF_CHAIN_ERR) &
+				~mask64)
+				sw_stats->error_stats.statsb_pif_chain_error++;
+
+			if ((val64 &
+			   VXGE_HW_GENERAL_ERRORS_REG_STATSB_DROP_TIMEOUT_REQ) &
+				~mask64)
+				sw_stats->error_stats.statsb_drop_timeout++;
+
+			if ((val64 &
+				VXGE_HW_GENERAL_ERRORS_REG_TGT_ILLEGAL_ACCESS) &
+				~mask64)
+				sw_stats->error_stats.target_illegal_access++;
+
+			if (!skip_alarms) {
+				writeq(VXGE_HW_INTR_MASK_ALL,
+					&vp_reg->general_errors_reg);
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_ALARM_CLEARED,
+					alarm_event);
+			}
+		}
+
+		if (pic_status &
+		    VXGE_HW_VPATH_PPIF_INT_STATUS_KDFCCTL_ERRORS_KDFCCTL_INT) {
+
+			val64 = readq(&vp_reg->kdfcctl_errors_reg);
+			mask64 = readq(&vp_reg->kdfcctl_errors_mask);
+
+			if ((val64 &
+			    VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_OVRWR) &
+				~mask64) {
+				sw_stats->error_stats.kdfcctl_fifo0_overwrite++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_FIFO_ERR,
+					alarm_event);
+			}
+
+			if ((val64 &
+			    VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_POISON) &
+				~mask64) {
+				sw_stats->error_stats.kdfcctl_fifo0_poison++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_FIFO_ERR,
+					alarm_event);
+			}
+
+			if ((val64 &
+			    VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_DMA_ERR) &
+				~mask64) {
+				sw_stats->error_stats.kdfcctl_fifo0_dma_error++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_FIFO_ERR,
+					alarm_event);
+			}
+
+			if (!skip_alarms) {
+				writeq(VXGE_HW_INTR_MASK_ALL,
+					&vp_reg->kdfcctl_errors_reg);
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_ALARM_CLEARED,
+					alarm_event);
+			}
+		}
+
+	}
+
+	if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT) {
+
+		val64 = readq(&vp_reg->wrdma_alarm_status);
+
+		if (val64 & VXGE_HW_WRDMA_ALARM_STATUS_PRC_ALARM_PRC_INT) {
+
+			val64 = readq(&vp_reg->prc_alarm_reg);
+			mask64 = readq(&vp_reg->prc_alarm_mask);
+
+			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RING_BUMP)&
+				~mask64)
+				sw_stats->error_stats.prc_ring_bumps++;
+
+			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ERR) &
+				~mask64) {
+				sw_stats->error_stats.prc_rxdcm_sc_err++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_VPATH_ERR,
+					alarm_event);
+			}
+
+			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ABORT)
+				& ~mask64) {
+				sw_stats->error_stats.prc_rxdcm_sc_abort++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+						VXGE_HW_EVENT_VPATH_ERR,
+						alarm_event);
+			}
+
+			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_QUANTA_SIZE_ERR)
+				 & ~mask64) {
+				sw_stats->error_stats.prc_quanta_size_err++;
+
+				alarm_event = VXGE_HW_SET_LEVEL(
+					VXGE_HW_EVENT_VPATH_ERR,
+					alarm_event);
+			}
+
+			if (!skip_alarms) {
+				writeq(VXGE_HW_INTR_MASK_ALL,
+					&vp_reg->prc_alarm_reg);
+				alarm_event = VXGE_HW_SET_LEVEL(
+						VXGE_HW_EVENT_ALARM_CLEARED,
+						alarm_event);
+			}
+		}
+	}
+out:
+	hldev->stats.sw_dev_err_stats.vpath_alarms++;
+out2:
+	if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
+		(alarm_event == VXGE_HW_EVENT_UNKNOWN))
+		return VXGE_HW_OK;
+
+	__vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
+
+	if (alarm_event == VXGE_HW_EVENT_SERR)
+		return VXGE_HW_ERR_CRITICAL;
+
+	return (alarm_event == VXGE_HW_EVENT_SLOT_FREEZE) ?
+		VXGE_HW_ERR_SLOT_FREEZE :
+		(alarm_event == VXGE_HW_EVENT_FIFO_ERR) ? VXGE_HW_ERR_FIFO :
+		VXGE_HW_ERR_VPATH;
+}
+
+/**
  * vxge_hw_device_begin_irq - Begin IRQ processing.
  * @hldev: HW device handle.
  * @skip_alarms: Do not clear the alarms
@@ -513,108 +884,6 @@ exit:
 	return ret;
 }
 
-/*
- * __vxge_hw_device_handle_link_up_ind
- * @hldev: HW device handle.
- *
- * Link up indication handler. The function is invoked by HW when
- * Titan indicates that the link is up for programmable amount of time.
- */
-static enum vxge_hw_status
-__vxge_hw_device_handle_link_up_ind(struct __vxge_hw_device *hldev)
-{
-	/*
-	 * If the previous link state is not down, return.
-	 */
-	if (hldev->link_state == VXGE_HW_LINK_UP)
-		goto exit;
-
-	hldev->link_state = VXGE_HW_LINK_UP;
-
-	/* notify driver */
-	if (hldev->uld_callbacks.link_up)
-		hldev->uld_callbacks.link_up(hldev);
-exit:
-	return VXGE_HW_OK;
-}
-
-/*
- * __vxge_hw_device_handle_link_down_ind
- * @hldev: HW device handle.
- *
- * Link down indication handler. The function is invoked by HW when
- * Titan indicates that the link is down.
- */
-static enum vxge_hw_status
-__vxge_hw_device_handle_link_down_ind(struct __vxge_hw_device *hldev)
-{
-	/*
-	 * If the previous link state is not down, return.
-	 */
-	if (hldev->link_state == VXGE_HW_LINK_DOWN)
-		goto exit;
-
-	hldev->link_state = VXGE_HW_LINK_DOWN;
-
-	/* notify driver */
-	if (hldev->uld_callbacks.link_down)
-		hldev->uld_callbacks.link_down(hldev);
-exit:
-	return VXGE_HW_OK;
-}
-
-/**
- * __vxge_hw_device_handle_error - Handle error
- * @hldev: HW device
- * @vp_id: Vpath Id
- * @type: Error type. Please see enum vxge_hw_event{}
- *
- * Handle error.
- */
-static enum vxge_hw_status
-__vxge_hw_device_handle_error(
-		struct __vxge_hw_device *hldev,
-		u32 vp_id,
-		enum vxge_hw_event type)
-{
-	switch (type) {
-	case VXGE_HW_EVENT_UNKNOWN:
-		break;
-	case VXGE_HW_EVENT_RESET_START:
-	case VXGE_HW_EVENT_RESET_COMPLETE:
-	case VXGE_HW_EVENT_LINK_DOWN:
-	case VXGE_HW_EVENT_LINK_UP:
-		goto out;
-	case VXGE_HW_EVENT_ALARM_CLEARED:
-		goto out;
-	case VXGE_HW_EVENT_ECCERR:
-	case VXGE_HW_EVENT_MRPCIM_ECCERR:
-		goto out;
-	case VXGE_HW_EVENT_FIFO_ERR:
-	case VXGE_HW_EVENT_VPATH_ERR:
-	case VXGE_HW_EVENT_CRITICAL_ERR:
-	case VXGE_HW_EVENT_SERR:
-		break;
-	case VXGE_HW_EVENT_SRPCIM_SERR:
-	case VXGE_HW_EVENT_MRPCIM_SERR:
-		goto out;
-	case VXGE_HW_EVENT_SLOT_FREEZE:
-		break;
-	default:
-		vxge_assert(0);
-		goto out;
-	}
-
-	/* notify driver */
-	if (hldev->uld_callbacks.crit_err)
-		hldev->uld_callbacks.crit_err(
-			(struct __vxge_hw_device *)hldev,
-			type, vp_id);
-out:
-
-	return VXGE_HW_OK;
-}
-
 /**
  * vxge_hw_device_clear_tx_rx - Acknowledge (that is, clear) the
  * condition that has caused the Tx and RX interrupt.
@@ -699,8 +968,8 @@ _alloc_after_swap:
  * Posts a dtr to work array.
  *
  */
-static void vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel,
-				     void *dtrh)
+static void
+vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel, void *dtrh)
 {
 	vxge_assert(channel->work_arr[channel->post_index] == NULL);
 
@@ -911,10 +1180,6 @@ void vxge_hw_ring_rxd_post(struct __vxge_hw_ring *ring, void *rxdh)
  */
 void vxge_hw_ring_rxd_post_post_wmb(struct __vxge_hw_ring *ring, void *rxdh)
 {
-	struct __vxge_hw_channel *channel;
-
-	channel = &ring->channel;
-
 	wmb();
 	vxge_hw_ring_rxd_post_post(ring, rxdh);
 }
@@ -1868,284 +2133,6 @@ exit:
 }
 
 /*
- * __vxge_hw_vpath_alarm_process - Process Alarms.
- * @vpath: Virtual Path.
- * @skip_alarms: Do not clear the alarms
- *
- * Process vpath alarms.
- *
- */
-static enum vxge_hw_status
-__vxge_hw_vpath_alarm_process(struct __vxge_hw_virtualpath *vpath,
-			      u32 skip_alarms)
-{
-	u64 val64;
-	u64 alarm_status;
-	u64 pic_status;
-	struct __vxge_hw_device *hldev = NULL;
-	enum vxge_hw_event alarm_event = VXGE_HW_EVENT_UNKNOWN;
-	u64 mask64;
-	struct vxge_hw_vpath_stats_sw_info *sw_stats;
-	struct vxge_hw_vpath_reg __iomem *vp_reg;
-
-	if (vpath == NULL) {
-		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
-			alarm_event);
-		goto out2;
-	}
-
-	hldev = vpath->hldev;
-	vp_reg = vpath->vp_reg;
-	alarm_status = readq(&vp_reg->vpath_general_int_status);
-
-	if (alarm_status == VXGE_HW_ALL_FOXES) {
-		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_SLOT_FREEZE,
-			alarm_event);
-		goto out;
-	}
-
-	sw_stats = vpath->sw_stats;
-
-	if (alarm_status & ~(
-		VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT |
-		VXGE_HW_VPATH_GENERAL_INT_STATUS_PCI_INT |
-		VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT |
-		VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT)) {
-		sw_stats->error_stats.unknown_alarms++;
-
-		alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
-			alarm_event);
-		goto out;
-	}
-
-	if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT) {
-
-		val64 = readq(&vp_reg->xgmac_vp_int_status);
-
-		if (val64 &
-		VXGE_HW_XGMAC_VP_INT_STATUS_ASIC_NTWK_VP_ERR_ASIC_NTWK_VP_INT) {
-
-			val64 = readq(&vp_reg->asic_ntwk_vp_err_reg);
-
-			if (((val64 &
-			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT) &&
-			     (!(val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK))) ||
-			    ((val64 &
-			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR) &&
-			     (!(val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR)
-				     ))) {
-				sw_stats->error_stats.network_sustained_fault++;
-
-				writeq(
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT,
-					&vp_reg->asic_ntwk_vp_err_mask);
-
-				__vxge_hw_device_handle_link_down_ind(hldev);
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_LINK_DOWN, alarm_event);
-			}
-
-			if (((val64 &
-			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK) &&
-			     (!(val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT))) ||
-			    ((val64 &
-			      VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR) &&
-			     (!(val64 &
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR)
-				     ))) {
-
-				sw_stats->error_stats.network_sustained_ok++;
-
-				writeq(
-				VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK,
-					&vp_reg->asic_ntwk_vp_err_mask);
-
-				__vxge_hw_device_handle_link_up_ind(hldev);
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_LINK_UP, alarm_event);
-			}
-
-			writeq(VXGE_HW_INTR_MASK_ALL,
-				&vp_reg->asic_ntwk_vp_err_reg);
-
-			alarm_event = VXGE_HW_SET_LEVEL(
-				VXGE_HW_EVENT_ALARM_CLEARED, alarm_event);
-
-			if (skip_alarms)
-				return VXGE_HW_OK;
-		}
-	}
-
-	if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT) {
-
-		pic_status = readq(&vp_reg->vpath_ppif_int_status);
-
-		if (pic_status &
-		    VXGE_HW_VPATH_PPIF_INT_STATUS_GENERAL_ERRORS_GENERAL_INT) {
-
-			val64 = readq(&vp_reg->general_errors_reg);
-			mask64 = readq(&vp_reg->general_errors_mask);
-
-			if ((val64 &
-				VXGE_HW_GENERAL_ERRORS_REG_INI_SERR_DET) &
-				~mask64) {
-				sw_stats->error_stats.ini_serr_det++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_SERR, alarm_event);
-			}
-
-			if ((val64 &
-			    VXGE_HW_GENERAL_ERRORS_REG_DBLGEN_FIFO0_OVRFLOW) &
-				~mask64) {
-				sw_stats->error_stats.dblgen_fifo0_overflow++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_FIFO_ERR, alarm_event);
-			}
-
-			if ((val64 &
-			    VXGE_HW_GENERAL_ERRORS_REG_STATSB_PIF_CHAIN_ERR) &
-				~mask64)
-				sw_stats->error_stats.statsb_pif_chain_error++;
-
-			if ((val64 &
-			   VXGE_HW_GENERAL_ERRORS_REG_STATSB_DROP_TIMEOUT_REQ) &
-				~mask64)
-				sw_stats->error_stats.statsb_drop_timeout++;
-
-			if ((val64 &
-				VXGE_HW_GENERAL_ERRORS_REG_TGT_ILLEGAL_ACCESS) &
-				~mask64)
-				sw_stats->error_stats.target_illegal_access++;
-
-			if (!skip_alarms) {
-				writeq(VXGE_HW_INTR_MASK_ALL,
-					&vp_reg->general_errors_reg);
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_ALARM_CLEARED,
-					alarm_event);
-			}
-		}
-
-		if (pic_status &
-		    VXGE_HW_VPATH_PPIF_INT_STATUS_KDFCCTL_ERRORS_KDFCCTL_INT) {
-
-			val64 = readq(&vp_reg->kdfcctl_errors_reg);
-			mask64 = readq(&vp_reg->kdfcctl_errors_mask);
-
-			if ((val64 &
-			    VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_OVRWR) &
-				~mask64) {
-				sw_stats->error_stats.kdfcctl_fifo0_overwrite++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_FIFO_ERR,
-					alarm_event);
-			}
-
-			if ((val64 &
-			    VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_POISON) &
-				~mask64) {
-				sw_stats->error_stats.kdfcctl_fifo0_poison++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_FIFO_ERR,
-					alarm_event);
-			}
-
-			if ((val64 &
-			    VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_DMA_ERR) &
-				~mask64) {
-				sw_stats->error_stats.kdfcctl_fifo0_dma_error++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_FIFO_ERR,
-					alarm_event);
-			}
-
-			if (!skip_alarms) {
-				writeq(VXGE_HW_INTR_MASK_ALL,
-					&vp_reg->kdfcctl_errors_reg);
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_ALARM_CLEARED,
-					alarm_event);
-			}
-		}
-
-	}
-
-	if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT) {
-
-		val64 = readq(&vp_reg->wrdma_alarm_status);
-
-		if (val64 & VXGE_HW_WRDMA_ALARM_STATUS_PRC_ALARM_PRC_INT) {
-
-			val64 = readq(&vp_reg->prc_alarm_reg);
-			mask64 = readq(&vp_reg->prc_alarm_mask);
-
-			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RING_BUMP)&
-				~mask64)
-				sw_stats->error_stats.prc_ring_bumps++;
-
-			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ERR) &
-				~mask64) {
-				sw_stats->error_stats.prc_rxdcm_sc_err++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_VPATH_ERR,
-					alarm_event);
-			}
-
-			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ABORT)
-				& ~mask64) {
-				sw_stats->error_stats.prc_rxdcm_sc_abort++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-						VXGE_HW_EVENT_VPATH_ERR,
-						alarm_event);
-			}
-
-			if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_QUANTA_SIZE_ERR)
-				 & ~mask64) {
-				sw_stats->error_stats.prc_quanta_size_err++;
-
-				alarm_event = VXGE_HW_SET_LEVEL(
-					VXGE_HW_EVENT_VPATH_ERR,
-					alarm_event);
-			}
-
-			if (!skip_alarms) {
-				writeq(VXGE_HW_INTR_MASK_ALL,
-					&vp_reg->prc_alarm_reg);
-				alarm_event = VXGE_HW_SET_LEVEL(
-						VXGE_HW_EVENT_ALARM_CLEARED,
-						alarm_event);
-			}
-		}
-	}
-out:
-	hldev->stats.sw_dev_err_stats.vpath_alarms++;
-out2:
-	if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
-		(alarm_event == VXGE_HW_EVENT_UNKNOWN))
-		return VXGE_HW_OK;
-
-	__vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
-
-	if (alarm_event == VXGE_HW_EVENT_SERR)
-		return VXGE_HW_ERR_CRITICAL;
-
-	return (alarm_event == VXGE_HW_EVENT_SLOT_FREEZE) ?
-		VXGE_HW_ERR_SLOT_FREEZE :
-		(alarm_event == VXGE_HW_EVENT_FIFO_ERR) ? VXGE_HW_ERR_FIFO :
-		VXGE_HW_ERR_VPATH;
-}
-
-/*
  * vxge_hw_vpath_alarm_process - Process Alarms.
  * @vpath: Virtual Path.
  * @skip_alarms: Do not clear the alarms
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-traffic.h
index 1fceee8..8c3103f 100644
--- a/drivers/net/vxge/vxge-traffic.h
+++ b/drivers/net/vxge/vxge-traffic.h
@@ -2081,10 +2081,6 @@ struct __vxge_hw_ring_rxd_priv {
 #endif
 };
 
-/* ========================= FIFO PRIVATE API ============================= */
-
-struct vxge_hw_fifo_attr;
-
 struct vxge_hw_mempool_cbs {
 	void (*item_func_alloc)(
 			struct vxge_hw_mempool *mempoolh,
@@ -2158,27 +2154,27 @@ enum vxge_hw_vpath_mac_addr_add_mode {
 enum vxge_hw_status
 vxge_hw_vpath_mac_addr_add(
 	struct __vxge_hw_vpath_handle *vpath_handle,
-	u8 (macaddr)[ETH_ALEN],
-	u8 (macaddr_mask)[ETH_ALEN],
+	u8 *macaddr,
+	u8 *macaddr_mask,
 	enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode);
 
 enum vxge_hw_status
 vxge_hw_vpath_mac_addr_get(
 	struct __vxge_hw_vpath_handle *vpath_handle,
-	u8 (macaddr)[ETH_ALEN],
-	u8 (macaddr_mask)[ETH_ALEN]);
+	u8 *macaddr,
+	u8 *macaddr_mask);
 
 enum vxge_hw_status
 vxge_hw_vpath_mac_addr_get_next(
 	struct __vxge_hw_vpath_handle *vpath_handle,
-	u8 (macaddr)[ETH_ALEN],
-	u8 (macaddr_mask)[ETH_ALEN]);
+	u8 *macaddr,
+	u8 *macaddr_mask);
 
 enum vxge_hw_status
 vxge_hw_vpath_mac_addr_delete(
 	struct __vxge_hw_vpath_handle *vpath_handle,
-	u8 (macaddr)[ETH_ALEN],
-	u8 (macaddr_mask)[ETH_ALEN]);
+	u8 *macaddr,
+	u8 *macaddr_mask);
 
 enum vxge_hw_status
 vxge_hw_vpath_vid_add(
@@ -2285,6 +2281,7 @@ vxge_hw_channel_dtr_free(struct __vxge_hw_channel *channel, void *dtrh);
 
 int
 vxge_hw_channel_dtr_count(struct __vxge_hw_channel *channel);
+
 void
 vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id);
 
-- 
1.7.0.4

