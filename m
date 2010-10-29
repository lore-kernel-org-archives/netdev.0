From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH net-next] vxge: make functions local and remove dead
 code
Date: Fri, 29 Oct 2010 16:44:29 -0500
Message-ID: <20101029214427.GA18716@exar.com>
References: <20101015102110.056690c6@nehalam>
 <20101018202822.GC13623@exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.exar.com ([204.154.183.83]:18312 "EHLO smtp1.exar.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754304Ab0J2Vti convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 17:49:38 -0400
Content-Disposition: inline
In-Reply-To: <20101018202822.GC13623@exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The original patch did not apply after the patch-set I sent out
yesterday, so I've reworked it based on the output of namespace.
Below is the patch which handles all of the issues.  I've done a quick
sniff test, and it seems to be happy.  I'll add it to our internal
patch queue, and push it out once testing has been completed.

Thanks,
Jon

commit 9d78e68196097b5ed4e9fbd16d9e936b498f075f
Author: Jon Mason <jon.mason@exar.com>
Date:   Fri Oct 29 13:59:53 2010 -0500

    vxge: make functions local and remove dead code

    Use results of make namespacecheck to make functions local and
    remove code that is not used.

    Also rename initialize_ethtool_ops to vxge_initialize_ethtool_ops.

    Based on original patch by Stephen Hemminger

    Signed-off-by: Jon Mason <jon.mason@exar.com>

diff --git a/drivers/net/vxge/vxge-config.c b/drivers/net/vxge/vxge-config.c
index 312c4c1..6a2ed90 100644
--- a/drivers/net/vxge/vxge-config.c
+++ b/drivers/net/vxge/vxge-config.c
@@ -21,6 +21,15 @@
 #include "vxge-config.h"
 #include "vxge-main.h"

+#define VXGE_HW_VPATH_STATS_PIO_READ(offset) {                         \
+       status = __vxge_hw_vpath_stats_access(vpath,                    \
+                       VXGE_HW_STATS_OP_READ,                          \
+                       offset,                                         \
+                       &val64);                                        \
+       if (status != VXGE_HW_OK)                                       \
+               return status;                                          \
+}
+
 static void
 vxge_hw_vpath_set_zero_rx_frm_len(struct vxge_hw_vpath_reg __iomem *vp_reg)
 {
@@ -103,6 +112,53 @@ void vxge_hw_device_wait_receive_idle(struct __vxge_hw_device *hldev)
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
+       u64 val64;
+       u32 i = 0;
+       enum vxge_hw_status ret = VXGE_HW_FAIL;
+
+       udelay(10);
+
+       do {
+               val64 = readq(reg);
+               if (!(val64 & mask))
+                       return VXGE_HW_OK;
+               udelay(100);
+       } while (++i <= 9);
+
+       i = 0;
+       do {
+               val64 = readq(reg);
+               if (!(val64 & mask))
+                       return VXGE_HW_OK;
+               mdelay(1);
+       } while (++i <= max_millis);
+
+       return ret;
+}
+
+static inline enum vxge_hw_status
+__vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
+                         u64 mask, u32 max_millis)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+
+       __vxge_hw_pio_mem_write32_lower((u32)vxge_bVALn(val64, 32, 32), addr);
+       wmb();
+       __vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32), addr);
+       wmb();
+
+       status = __vxge_hw_device_register_poll(addr, mask, max_millis);
+       return status;
+}
+
 static enum vxge_hw_status
 vxge_hw_vpath_fw_api(struct __vxge_hw_virtualpath *vpath, u32 action,
                     u32 fw_memo, u32 offset, u64 *data0, u64 *data1,
@@ -355,82 +411,11 @@ vxge_hw_vpath_eprom_img_ver_get(struct __vxge_hw_device *hldev,
 }

 /*
- * __vxge_hw_channel_allocate - Allocate memory for channel
- * This function allocates required memory for the channel and various arrays
- * in the channel
- */
-struct __vxge_hw_channel*
-__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
-                          enum __vxge_hw_channel_type type,
-       u32 length, u32 per_dtr_space, void *userdata)
-{
-       struct __vxge_hw_channel *channel;
-       struct __vxge_hw_device *hldev;
-       int size = 0;
-       u32 vp_id;
-
-       hldev = vph->vpath->hldev;
-       vp_id = vph->vpath->vp_id;
-
-       switch (type) {
-       case VXGE_HW_CHANNEL_TYPE_FIFO:
-               size = sizeof(struct __vxge_hw_fifo);
-               break;
-       case VXGE_HW_CHANNEL_TYPE_RING:
-               size = sizeof(struct __vxge_hw_ring);
-               break;
-       default:
-               break;
-       }
-
-       channel = kzalloc(size, GFP_KERNEL);
-       if (channel == NULL)
-               goto exit0;
-       INIT_LIST_HEAD(&channel->item);
-
-       channel->common_reg = hldev->common_reg;
-       channel->first_vp_id = hldev->first_vp_id;
-       channel->type = type;
-       channel->devh = hldev;
-       channel->vph = vph;
-       channel->userdata = userdata;
-       channel->per_dtr_space = per_dtr_space;
-       channel->length = length;
-       channel->vp_id = vp_id;
-
-       channel->work_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-       if (channel->work_arr == NULL)
-               goto exit1;
-
-       channel->free_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-       if (channel->free_arr == NULL)
-               goto exit1;
-       channel->free_ptr = length;
-
-       channel->reserve_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-       if (channel->reserve_arr == NULL)
-               goto exit1;
-       channel->reserve_ptr = length;
-       channel->reserve_top = 0;
-
-       channel->orig_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
-       if (channel->orig_arr == NULL)
-               goto exit1;
-
-       return channel;
-exit1:
-       __vxge_hw_channel_free(channel);
-
-exit0:
-       return NULL;
-}
-
-/*
  * __vxge_hw_channel_free - Free memory allocated for channel
  * This function deallocates memory from the channel and various arrays
  * in the channel
  */
-void __vxge_hw_channel_free(struct __vxge_hw_channel *channel)
+static void __vxge_hw_channel_free(struct __vxge_hw_channel *channel)
 {
        kfree(channel->work_arr);
        kfree(channel->free_arr);
@@ -444,7 +429,7 @@ void __vxge_hw_channel_free(struct __vxge_hw_channel *channel)
  * This function initializes a channel by properly setting the
  * various references
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_channel_initialize(struct __vxge_hw_channel *channel)
 {
        u32 i;
@@ -479,7 +464,7 @@ __vxge_hw_channel_initialize(struct __vxge_hw_channel *channel)
  * __vxge_hw_channel_reset - Resets a channel
  * This function resets a channel by properly setting the various references
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_channel_reset(struct __vxge_hw_channel *channel)
 {
        u32 i;
@@ -506,8 +491,7 @@ __vxge_hw_channel_reset(struct __vxge_hw_channel *channel)
  * Initialize certain PCI/PCI-X configuration registers
  * with recommended values. Save config space for future hw resets.
  */
-void
-__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
+static void __vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
 {
        u16 cmd = 0;

@@ -519,43 +503,11 @@ __vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev)
        pci_save_state(hldev->pdev);
 }

-/*
- * __vxge_hw_device_register_poll
- * Will poll certain register for specified amount of time.
- * Will poll until masked bit is not cleared.
- */
-enum vxge_hw_status
-__vxge_hw_device_register_poll(void __iomem *reg, u64 mask, u32 max_millis)
-{
-       u64 val64;
-       u32 i = 0;
-       enum vxge_hw_status ret = VXGE_HW_FAIL;
-
-       udelay(10);
-
-       do {
-               val64 = readq(reg);
-               if (!(val64 & mask))
-                       return VXGE_HW_OK;
-               udelay(100);
-       } while (++i <= 9);
-
-       i = 0;
-       do {
-               val64 = readq(reg);
-               if (!(val64 & mask))
-                       return VXGE_HW_OK;
-               mdelay(1);
-       } while (++i <= max_millis);
-
-       return ret;
-}
-
 /* __vxge_hw_device_vpath_reset_in_prog_check - Check if vpath reset
  * in progress
  * This routine checks the vpath reset in progress register is turned zero
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog)
 {
        enum vxge_hw_status status;
@@ -566,11 +518,66 @@ __vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog)
 }

 /*
+ * _hw_legacy_swapper_set - Set the swapper bits for the legacy secion.
+ * Set the swapper bits appropriately for the lagacy section.
+ */
+static enum vxge_hw_status
+__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg)
+{
+       u64 val64;
+       enum vxge_hw_status status = VXGE_HW_OK;
+
+       val64 = readq(&legacy_reg->toc_swapper_fb);
+
+       wmb();
+
+       switch (val64) {
+
+       case VXGE_HW_SWAPPER_INITIAL_VALUE:
+               return status;
+
+       case VXGE_HW_SWAPPER_BYTE_SWAPPED_BIT_FLIPPED:
+               writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
+                       &legacy_reg->pifm_rd_swap_en);
+               writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
+                       &legacy_reg->pifm_rd_flip_en);
+               writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
+                       &legacy_reg->pifm_wr_swap_en);
+               writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
+                       &legacy_reg->pifm_wr_flip_en);
+               break;
+
+       case VXGE_HW_SWAPPER_BYTE_SWAPPED:
+               writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
+                       &legacy_reg->pifm_rd_swap_en);
+               writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
+                       &legacy_reg->pifm_wr_swap_en);
+               break;
+
+       case VXGE_HW_SWAPPER_BIT_FLIPPED:
+               writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
+                       &legacy_reg->pifm_rd_flip_en);
+               writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
+                       &legacy_reg->pifm_wr_flip_en);
+               break;
+       }
+
+       wmb();
+
+       val64 = readq(&legacy_reg->toc_swapper_fb);
+
+       if (val64 != VXGE_HW_SWAPPER_INITIAL_VALUE)
+               status = VXGE_HW_ERR_SWAPPER_CTRL;
+
+       return status;
+}
+
+/*
  * __vxge_hw_device_toc_get
  * This routine sets the swapper and reads the toc pointer and returns the
  * memory mapped address of the toc
  */
-struct vxge_hw_toc_reg __iomem *
+static struct vxge_hw_toc_reg __iomem *
 __vxge_hw_device_toc_get(void __iomem *bar0)
 {
        u64 val64;
@@ -596,7 +603,7 @@ exit:
  * register location pointers in the device object. It waits until the ric is
  * completed initializing registers.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev)
 {
        u64 val64;
@@ -792,7 +799,8 @@ __vxge_hw_verify_pci_e_info(struct __vxge_hw_device *hldev)
  * __vxge_hw_device_initialize
  * Initialize Titan-V hardware.
  */
-enum vxge_hw_status __vxge_hw_device_initialize(struct __vxge_hw_device *hldev)
+static enum vxge_hw_status
+__vxge_hw_device_initialize(struct __vxge_hw_device *hldev)
 {
        enum vxge_hw_status status = VXGE_HW_OK;

@@ -1105,6 +1113,227 @@ exit:
 }

 /*
+ * __vxge_hw_blockpool_destroy - Deallocates the block pool
+ */
+static void __vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool *blockpool)
+{
+
+       struct __vxge_hw_device *hldev;
+       struct list_head *p, *n;
+       u16 ret;
+
+       if (blockpool == NULL) {
+               ret = 1;
+               goto exit;
+       }
+
+       hldev = blockpool->hldev;
+
+       list_for_each_safe(p, n, &blockpool->free_block_list) {
+
+               pci_unmap_single(hldev->pdev,
+                       ((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
+                       ((struct __vxge_hw_blockpool_entry *)p)->length,
+                       PCI_DMA_BIDIRECTIONAL);
+
+               vxge_os_dma_free(hldev->pdev,
+                       ((struct __vxge_hw_blockpool_entry *)p)->memblock,
+                       &((struct __vxge_hw_blockpool_entry *) p)->acc_handle);
+
+               list_del(
+                       &((struct __vxge_hw_blockpool_entry *)p)->item);
+               kfree(p);
+               blockpool->pool_size--;
+       }
+
+       list_for_each_safe(p, n, &blockpool->free_entry_list) {
+               list_del(
+                       &((struct __vxge_hw_blockpool_entry *)p)->item);
+               kfree((void *)p);
+       }
+       ret = 0;
+exit:
+       return;
+}
+
+/*
+ * __vxge_hw_blockpool_create - Create block pool
+ */
+static enum vxge_hw_status
+__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
+                          struct __vxge_hw_blockpool *blockpool,
+                          u32 pool_size,
+                          u32 pool_max)
+{
+       u32 i;
+       struct __vxge_hw_blockpool_entry *entry = NULL;
+       void *memblock;
+       dma_addr_t dma_addr;
+       struct pci_dev *dma_handle;
+       struct pci_dev *acc_handle;
+       enum vxge_hw_status status = VXGE_HW_OK;
+
+       if (blockpool == NULL) {
+               status = VXGE_HW_FAIL;
+               goto blockpool_create_exit;
+       }
+
+       blockpool->hldev = hldev;
+       blockpool->block_size = VXGE_HW_BLOCK_SIZE;
+       blockpool->pool_size = 0;
+       blockpool->pool_max = pool_max;
+       blockpool->req_out = 0;
+
+       INIT_LIST_HEAD(&blockpool->free_block_list);
+       INIT_LIST_HEAD(&blockpool->free_entry_list);
+
+       for (i = 0; i < pool_size + pool_max; i++) {
+               entry = kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
+                               GFP_KERNEL);
+               if (entry == NULL) {
+                       __vxge_hw_blockpool_destroy(blockpool);
+                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
+                       goto blockpool_create_exit;
+               }
+               list_add(&entry->item, &blockpool->free_entry_list);
+       }
+
+       for (i = 0; i < pool_size; i++) {
+
+               memblock = vxge_os_dma_malloc(
+                               hldev->pdev,
+                               VXGE_HW_BLOCK_SIZE,
+                               &dma_handle,
+                               &acc_handle);
+
+               if (memblock == NULL) {
+                       __vxge_hw_blockpool_destroy(blockpool);
+                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
+                       goto blockpool_create_exit;
+               }
+
+               dma_addr = pci_map_single(hldev->pdev, memblock,
+                               VXGE_HW_BLOCK_SIZE, PCI_DMA_BIDIRECTIONAL);
+
+               if (unlikely(pci_dma_mapping_error(hldev->pdev,
+                               dma_addr))) {
+
+                       vxge_os_dma_free(hldev->pdev, memblock, &acc_handle);
+                       __vxge_hw_blockpool_destroy(blockpool);
+                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
+                       goto blockpool_create_exit;
+               }
+
+               if (!list_empty(&blockpool->free_entry_list))
+                       entry = (struct __vxge_hw_blockpool_entry *)
+                               list_first_entry(&blockpool->free_entry_list,
+                                       struct __vxge_hw_blockpool_entry,
+                                       item);
+
+               if (entry == NULL)
+                       entry =
+                           kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
+                                       GFP_KERNEL);
+               if (entry != NULL) {
+                       list_del(&entry->item);
+                       entry->length = VXGE_HW_BLOCK_SIZE;
+                       entry->memblock = memblock;
+                       entry->dma_addr = dma_addr;
+                       entry->acc_handle = acc_handle;
+                       entry->dma_handle = dma_handle;
+                       list_add(&entry->item,
+                                         &blockpool->free_block_list);
+                       blockpool->pool_size++;
+               } else {
+                       __vxge_hw_blockpool_destroy(blockpool);
+                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
+                       goto blockpool_create_exit;
+               }
+       }
+
+blockpool_create_exit:
+       return status;
+}
+
+/*
+ * __vxge_hw_device_fifo_config_check - Check fifo configuration.
+ * Check the fifo configuration
+ */
+static enum vxge_hw_status
+__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config)
+{
+       if ((fifo_config->fifo_blocks < VXGE_HW_MIN_FIFO_BLOCKS) ||
+            (fifo_config->fifo_blocks > VXGE_HW_MAX_FIFO_BLOCKS))
+               return VXGE_HW_BADCFG_FIFO_BLOCKS;
+
+       return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_vpath_config_check - Check vpath configuration.
+ * Check the vpath configuration
+ */
+static enum vxge_hw_status
+__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
+{
+       enum vxge_hw_status status;
+
+       if ((vp_config->min_bandwidth < VXGE_HW_VPATH_BANDWIDTH_MIN) ||
+               (vp_config->min_bandwidth >
+                                       VXGE_HW_VPATH_BANDWIDTH_MAX))
+               return VXGE_HW_BADCFG_VPATH_MIN_BANDWIDTH;
+
+       status = __vxge_hw_device_fifo_config_check(&vp_config->fifo);
+       if (status != VXGE_HW_OK)
+               return status;
+
+       if ((vp_config->mtu != VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU) &&
+               ((vp_config->mtu < VXGE_HW_VPATH_MIN_INITIAL_MTU) ||
+               (vp_config->mtu > VXGE_HW_VPATH_MAX_INITIAL_MTU)))
+               return VXGE_HW_BADCFG_VPATH_MTU;
+
+       if ((vp_config->rpa_strip_vlan_tag !=
+               VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT) &&
+               (vp_config->rpa_strip_vlan_tag !=
+               VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE) &&
+               (vp_config->rpa_strip_vlan_tag !=
+               VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_DISABLE))
+               return VXGE_HW_BADCFG_VPATH_RPA_STRIP_VLAN_TAG;
+
+       return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_device_config_check - Check device configuration.
+ * Check the device configuration
+ */
+static enum vxge_hw_status
+__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
+{
+       u32 i;
+       enum vxge_hw_status status;
+
+       if ((new_config->intr_mode != VXGE_HW_INTR_MODE_IRQLINE) &&
+          (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX) &&
+          (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) &&
+          (new_config->intr_mode != VXGE_HW_INTR_MODE_DEF))
+               return VXGE_HW_BADCFG_INTR_MODE;
+
+       if ((new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE) &&
+          (new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE))
+               return VXGE_HW_BADCFG_RTS_MAC_EN;
+
+       for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
+               status = __vxge_hw_device_vpath_config_check(
+                               &new_config->vp_config[i]);
+               if (status != VXGE_HW_OK)
+                       return status;
+       }
+
+       return VXGE_HW_OK;
+}
+
+/*
  * vxge_hw_device_initialize - Initialize Titan device.
  * Initialize Titan device. Note that all the arguments of this public API
  * are 'IN', including @hldev. Driver cooperates with
@@ -1214,6 +1443,243 @@ vxge_hw_device_terminate(struct __vxge_hw_device *hldev)
 }

 /*
+ * __vxge_hw_vpath_stats_access - Get the statistics from the given location
+ *                           and offset and perform an operation
+ */
+static enum vxge_hw_status
+__vxge_hw_vpath_stats_access(struct __vxge_hw_virtualpath *vpath,
+                            u32 operation, u32 offset, u64 *stat)
+{
+       u64 val64;
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+               goto vpath_stats_access_exit;
+       }
+
+       vp_reg = vpath->vp_reg;
+
+       val64 =  VXGE_HW_XMAC_STATS_ACCESS_CMD_OP(operation) |
+                VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE |
+                VXGE_HW_XMAC_STATS_ACCESS_CMD_OFFSET_SEL(offset);
+
+       status = __vxge_hw_pio_mem_write64(val64,
+                               &vp_reg->xmac_stats_access_cmd,
+                               VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE,
+                               vpath->hldev->config.device_poll_millis);
+
+       if ((status == VXGE_HW_OK) && (operation == VXGE_HW_STATS_OP_READ))
+               *stat = readq(&vp_reg->xmac_stats_access_data);
+       else
+               *stat = 0;
+
+vpath_stats_access_exit:
+       return status;
+}
+
+/*
+ * __vxge_hw_vpath_xmac_tx_stats_get - Get the TX Statistics of a vpath
+ */
+static enum vxge_hw_status
+__vxge_hw_vpath_xmac_tx_stats_get(struct __vxge_hw_virtualpath *vpath,
+                       struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats)
+{
+       u64 *val64;
+       int i;
+       u32 offset = VXGE_HW_STATS_VPATH_TX_OFFSET;
+       enum vxge_hw_status status = VXGE_HW_OK;
+
+       val64 = (u64 *) vpath_tx_stats;
+
+       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+               goto exit;
+       }
+
+       for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_tx_stats) / 8; i++) {
+               status = __vxge_hw_vpath_stats_access(vpath,
+                                       VXGE_HW_STATS_OP_READ,
+                                       offset, val64);
+               if (status != VXGE_HW_OK)
+                       goto exit;
+               offset++;
+               val64++;
+       }
+exit:
+       return status;
+}
+
+/*
+ * __vxge_hw_vpath_xmac_rx_stats_get - Get the RX Statistics of a vpath
+ */
+static enum vxge_hw_status
+__vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath *vpath,
+                       struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats)
+{
+       u64 *val64;
+       enum vxge_hw_status status = VXGE_HW_OK;
+       int i;
+       u32 offset = VXGE_HW_STATS_VPATH_RX_OFFSET;
+       val64 = (u64 *) vpath_rx_stats;
+
+       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+               goto exit;
+       }
+       for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_rx_stats) / 8; i++) {
+               status = __vxge_hw_vpath_stats_access(vpath,
+                                       VXGE_HW_STATS_OP_READ,
+                                       offset >> 3, val64);
+               if (status != VXGE_HW_OK)
+                       goto exit;
+
+               offset += 8;
+               val64++;
+       }
+exit:
+       return status;
+}
+
+/*
+ * __vxge_hw_vpath_stats_get - Get the vpath hw statistics.
+ */
+static enum vxge_hw_status
+__vxge_hw_vpath_stats_get(struct __vxge_hw_virtualpath *vpath,
+                         struct vxge_hw_vpath_stats_hw_info *hw_stats)
+{
+       u64 val64;
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+               goto exit;
+       }
+       vp_reg = vpath->vp_reg;
+
+       val64 = readq(&vp_reg->vpath_debug_stats0);
+       hw_stats->ini_num_mwr_sent =
+               (u32)VXGE_HW_VPATH_DEBUG_STATS0_GET_INI_NUM_MWR_SENT(val64);
+
+       val64 = readq(&vp_reg->vpath_debug_stats1);
+       hw_stats->ini_num_mrd_sent =
+               (u32)VXGE_HW_VPATH_DEBUG_STATS1_GET_INI_NUM_MRD_SENT(val64);
+
+       val64 = readq(&vp_reg->vpath_debug_stats2);
+       hw_stats->ini_num_cpl_rcvd =
+               (u32)VXGE_HW_VPATH_DEBUG_STATS2_GET_INI_NUM_CPL_RCVD(val64);
+
+       val64 = readq(&vp_reg->vpath_debug_stats3);
+       hw_stats->ini_num_mwr_byte_sent =
+               VXGE_HW_VPATH_DEBUG_STATS3_GET_INI_NUM_MWR_BYTE_SENT(val64);
+
+       val64 = readq(&vp_reg->vpath_debug_stats4);
+       hw_stats->ini_num_cpl_byte_rcvd =
+               VXGE_HW_VPATH_DEBUG_STATS4_GET_INI_NUM_CPL_BYTE_RCVD(val64);
+
+       val64 = readq(&vp_reg->vpath_debug_stats5);
+       hw_stats->wrcrdtarb_xoff =
+               (u32)VXGE_HW_VPATH_DEBUG_STATS5_GET_WRCRDTARB_XOFF(val64);
+
+       val64 = readq(&vp_reg->vpath_debug_stats6);
+       hw_stats->rdcrdtarb_xoff =
+               (u32)VXGE_HW_VPATH_DEBUG_STATS6_GET_RDCRDTARB_XOFF(val64);
+
+       val64 = readq(&vp_reg->vpath_genstats_count01);
+       hw_stats->vpath_genstats_count0 =
+       (u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT0(
+               val64);
+
+       val64 = readq(&vp_reg->vpath_genstats_count01);
+       hw_stats->vpath_genstats_count1 =
+       (u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT1(
+               val64);
+
+       val64 = readq(&vp_reg->vpath_genstats_count23);
+       hw_stats->vpath_genstats_count2 =
+       (u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT2(
+               val64);
+
+       val64 = readq(&vp_reg->vpath_genstats_count01);
+       hw_stats->vpath_genstats_count3 =
+       (u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT3(
+               val64);
+
+       val64 = readq(&vp_reg->vpath_genstats_count4);
+       hw_stats->vpath_genstats_count4 =
+       (u32)VXGE_HW_VPATH_GENSTATS_COUNT4_GET_PPIF_VPATH_GENSTATS_COUNT4(
+               val64);
+
+       val64 = readq(&vp_reg->vpath_genstats_count5);
+       hw_stats->vpath_genstats_count5 =
+       (u32)VXGE_HW_VPATH_GENSTATS_COUNT5_GET_PPIF_VPATH_GENSTATS_COUNT5(
+               val64);
+
+       status = __vxge_hw_vpath_xmac_tx_stats_get(vpath, &hw_stats->tx_stats);
+       if (status != VXGE_HW_OK)
+               goto exit;
+
+       status = __vxge_hw_vpath_xmac_rx_stats_get(vpath, &hw_stats->rx_stats);
+       if (status != VXGE_HW_OK)
+               goto exit;
+
+       VXGE_HW_VPATH_STATS_PIO_READ(
+               VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM0_OFFSET);
+
+       hw_stats->prog_event_vnum0 =
+                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM0(val64);
+
+       hw_stats->prog_event_vnum1 =
+                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM1(val64);
+
+       VXGE_HW_VPATH_STATS_PIO_READ(
+               VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM2_OFFSET);
+
+       hw_stats->prog_event_vnum2 =
+                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM2(val64);
+
+       hw_stats->prog_event_vnum3 =
+                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM3(val64);
+
+       val64 = readq(&vp_reg->rx_multi_cast_stats);
+       hw_stats->rx_multi_cast_frame_discard =
+               (u16)VXGE_HW_RX_MULTI_CAST_STATS_GET_FRAME_DISCARD(val64);
+
+       val64 = readq(&vp_reg->rx_frm_transferred);
+       hw_stats->rx_frm_transferred =
+               (u32)VXGE_HW_RX_FRM_TRANSFERRED_GET_RX_FRM_TRANSFERRED(val64);
+
+       val64 = readq(&vp_reg->rxd_returned);
+       hw_stats->rxd_returned =
+               (u16)VXGE_HW_RXD_RETURNED_GET_RXD_RETURNED(val64);
+
+       val64 = readq(&vp_reg->dbg_stats_rx_mpa);
+       hw_stats->rx_mpa_len_fail_frms =
+               (u16)VXGE_HW_DBG_STATS_GET_RX_MPA_LEN_FAIL_FRMS(val64);
+       hw_stats->rx_mpa_mrk_fail_frms =
+               (u16)VXGE_HW_DBG_STATS_GET_RX_MPA_MRK_FAIL_FRMS(val64);
+       hw_stats->rx_mpa_crc_fail_frms =
+               (u16)VXGE_HW_DBG_STATS_GET_RX_MPA_CRC_FAIL_FRMS(val64);
+
+       val64 = readq(&vp_reg->dbg_stats_rx_fau);
+       hw_stats->rx_permitted_frms =
+               (u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_PERMITTED_FRMS(val64);
+       hw_stats->rx_vp_reset_discarded_frms =
+       (u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_VP_RESET_DISCARDED_FRMS(val64);
+       hw_stats->rx_wol_frms =
+               (u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_WOL_FRMS(val64);
+
+       val64 = readq(&vp_reg->tx_vp_reset_discarded_frms);
+       hw_stats->tx_vp_reset_discarded_frms =
+       (u16)VXGE_HW_TX_VP_RESET_DISCARDED_FRMS_GET_TX_VP_RESET_DISCARDED_FRMS(
+               val64);
+exit:
+       return status;
+}
+
+/*
  * vxge_hw_device_stats_get - Get the device hw statistics.
  * Returns the vpath h/w stats for the device.
  */
@@ -1300,7 +1766,7 @@ exit:
  * vxge_hw_device_xmac_aggr_stats_get - Get the Statistics on aggregate port
  * Get the Statistics on aggregate port
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 vxge_hw_device_xmac_aggr_stats_get(struct __vxge_hw_device *hldev, u32 port,
                                   struct vxge_hw_xmac_aggr_stats *aggr_stats)
 {
@@ -1335,7 +1801,7 @@ exit:
  * vxge_hw_device_xmac_port_stats_get - Get the Statistics on a port
  * Get the Statistics on port
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 vxge_hw_device_xmac_port_stats_get(struct __vxge_hw_device *hldev, u32 port,
                                   struct vxge_hw_xmac_port_stats *port_stats)
 {
@@ -1473,20 +1939,7 @@ u32 vxge_hw_device_trace_level_get(struct __vxge_hw_device *hldev)
        return 0;
 #endif
 }
-/*
- * vxge_hw_device_debug_mask_get - Get the debug mask
- * This routine returns the current debug mask set
- */
-u32 vxge_hw_device_debug_mask_get(struct __vxge_hw_device *hldev)
-{
-#if defined(VXGE_DEBUG_TRACE_MASK) || defined(VXGE_DEBUG_ERR_MASK)
-       if (hldev == NULL)
-               return 0;
-       return hldev->debug_module_mask;
-#else
-       return 0;
-#endif
-}
+

 /*
  * vxge_hw_getpause_data -Pause frame frame generation and reception.
@@ -1610,7 +2063,7 @@ __vxge_hw_ring_block_next_pointer_set(u8 *block, dma_addr_t dma_next)
  *             first block
  * Returns the dma address of the first RxD block
  */
-u64 __vxge_hw_ring_first_block_address_get(struct __vxge_hw_ring *ring)
+static u64 __vxge_hw_ring_first_block_address_get(struct __vxge_hw_ring *ring)
 {
        struct vxge_hw_mempool_dma *dma_object;

@@ -1768,196 +2221,368 @@ exit:
 }

 /*
- * __vxge_hw_ring_create - Create a Ring
- * This function creates Ring and initializes it.
+ * __vxge_hw_channel_allocate - Allocate memory for channel
+ * This function allocates required memory for the channel and various arrays
+ * in the channel
  */
-enum vxge_hw_status
-__vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
-                     struct vxge_hw_ring_attr *attr)
+static struct __vxge_hw_channel *
+__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
+                          enum __vxge_hw_channel_type type,
+                          u32 length, u32 per_dtr_space,
+                          void *userdata)
 {
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct __vxge_hw_ring *ring;
-       u32 ring_length;
-       struct vxge_hw_ring_config *config;
+       struct __vxge_hw_channel *channel;
        struct __vxge_hw_device *hldev;
+       int size = 0;
        u32 vp_id;
-       struct vxge_hw_mempool_cbs ring_mp_callback;

-       if ((vp == NULL) || (attr == NULL)) {
+       hldev = vph->vpath->hldev;
+       vp_id = vph->vpath->vp_id;
+
+       switch (type) {
+       case VXGE_HW_CHANNEL_TYPE_FIFO:
+               size = sizeof(struct __vxge_hw_fifo);
+               break;
+       case VXGE_HW_CHANNEL_TYPE_RING:
+               size = sizeof(struct __vxge_hw_ring);
+               break;
+       default:
+               break;
+       }
+
+       channel = kzalloc(size, GFP_KERNEL);
+       if (channel == NULL)
+               goto exit0;
+       INIT_LIST_HEAD(&channel->item);
+
+       channel->common_reg = hldev->common_reg;
+       channel->first_vp_id = hldev->first_vp_id;
+       channel->type = type;
+       channel->devh = hldev;
+       channel->vph = vph;
+       channel->userdata = userdata;
+       channel->per_dtr_space = per_dtr_space;
+       channel->length = length;
+       channel->vp_id = vp_id;
+
+       channel->work_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+       if (channel->work_arr == NULL)
+               goto exit1;
+
+       channel->free_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+       if (channel->free_arr == NULL)
+               goto exit1;
+       channel->free_ptr = length;
+
+       channel->reserve_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+       if (channel->reserve_arr == NULL)
+               goto exit1;
+       channel->reserve_ptr = length;
+       channel->reserve_top = 0;
+
+       channel->orig_arr = kzalloc(sizeof(void *)*length, GFP_KERNEL);
+       if (channel->orig_arr == NULL)
+               goto exit1;
+
+       return channel;
+exit1:
+       __vxge_hw_channel_free(channel);
+
+exit0:
+       return NULL;
+}
+
+/*
+ * vxge_hw_blockpool_block_add - callback for vxge_os_dma_malloc_async
+ * Adds a block to block pool
+ */
+static void vxge_hw_blockpool_block_add(struct __vxge_hw_device *devh,
+                                       void *block_addr,
+                                       u32 length,
+                                       struct pci_dev *dma_h,
+                                       struct pci_dev *acc_handle)
+{
+       struct __vxge_hw_blockpool *blockpool;
+       struct __vxge_hw_blockpool_entry *entry = NULL;
+       dma_addr_t dma_addr;
+       enum vxge_hw_status status = VXGE_HW_OK;
+       u32 req_out;
+
+       blockpool = &devh->block_pool;
+
+       if (block_addr == NULL) {
+               blockpool->req_out--;
                status = VXGE_HW_FAIL;
                goto exit;
        }

-       hldev = vp->vpath->hldev;
-       vp_id = vp->vpath->vp_id;
+       dma_addr = pci_map_single(devh->pdev, block_addr, length,
+                               PCI_DMA_BIDIRECTIONAL);

-       config = &hldev->config.vp_config[vp_id].ring;
+       if (unlikely(pci_dma_mapping_error(devh->pdev, dma_addr))) {
+               vxge_os_dma_free(devh->pdev, block_addr, &acc_handle);
+               blockpool->req_out--;
+               status = VXGE_HW_FAIL;
+               goto exit;
+       }

-       ring_length = config->ring_blocks *
-                       vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+       if (!list_empty(&blockpool->free_entry_list))
+               entry = (struct __vxge_hw_blockpool_entry *)
+                       list_first_entry(&blockpool->free_entry_list,
+                               struct __vxge_hw_blockpool_entry,
+                               item);

-       ring = (struct __vxge_hw_ring *)__vxge_hw_channel_allocate(vp,
-                                               VXGE_HW_CHANNEL_TYPE_RING,
-                                               ring_length,
-                                               attr->per_rxd_space,
-                                               attr->userdata);
+       if (entry == NULL)
+               entry = (struct __vxge_hw_blockpool_entry *)
+                       vmalloc(sizeof(struct __vxge_hw_blockpool_entry));
+       else
+               list_del(&entry->item);

-       if (ring == NULL) {
+       if (entry != NULL) {
+               entry->length = length;
+               entry->memblock = block_addr;
+               entry->dma_addr = dma_addr;
+               entry->acc_handle = acc_handle;
+               entry->dma_handle = dma_h;
+               list_add(&entry->item, &blockpool->free_block_list);
+               blockpool->pool_size++;
+               status = VXGE_HW_OK;
+       } else
                status = VXGE_HW_ERR_OUT_OF_MEMORY;
-               goto exit;
-       }

-       vp->vpath->ringh = ring;
-       ring->vp_id = vp_id;
-       ring->vp_reg = vp->vpath->vp_reg;
-       ring->common_reg = hldev->common_reg;
-       ring->stats = &vp->vpath->sw_stats->ring_stats;
-       ring->config = config;
-       ring->callback = attr->callback;
-       ring->rxd_init = attr->rxd_init;
-       ring->rxd_term = attr->rxd_term;
-       ring->buffer_mode = config->buffer_mode;
-       ring->rxds_limit = config->rxds_limit;
+       blockpool->req_out--;

-       ring->rxd_size = vxge_hw_ring_rxd_size_get(config->buffer_mode);
-       ring->rxd_priv_size =
-               sizeof(struct __vxge_hw_ring_rxd_priv) + attr->per_rxd_space;
-       ring->per_rxd_space = attr->per_rxd_space;
+       req_out = blockpool->req_out;
+exit:
+       return;
+}

-       ring->rxd_priv_size =
-               ((ring->rxd_priv_size + VXGE_CACHE_LINE_SIZE - 1) /
-               VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
+static inline void
+vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh, unsigned long size)
+{
+       gfp_t flags;
+       void *vaddr;

-       /* how many RxDs can fit into one block. Depends on configured
-        * buffer_mode. */
-       ring->rxds_per_block =
-               vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+       if (in_interrupt())
+               flags = GFP_ATOMIC | GFP_DMA;
+       else
+               flags = GFP_KERNEL | GFP_DMA;

-       /* calculate actual RxD block private size */
-       ring->rxdblock_priv_size = ring->rxd_priv_size * ring->rxds_per_block;
-       ring_mp_callback.item_func_alloc = __vxge_hw_ring_mempool_item_alloc;
-       ring->mempool = __vxge_hw_mempool_create(hldev,
-                               VXGE_HW_BLOCK_SIZE,
-                               VXGE_HW_BLOCK_SIZE,
-                               ring->rxdblock_priv_size,
-                               ring->config->ring_blocks,
-                               ring->config->ring_blocks,
-                               &ring_mp_callback,
-                               ring);
+       vaddr = kmalloc((size), flags);

-       if (ring->mempool == NULL) {
-               __vxge_hw_ring_delete(vp);
-               return VXGE_HW_ERR_OUT_OF_MEMORY;
-       }
+       vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
+}

-       status = __vxge_hw_channel_initialize(&ring->channel);
-       if (status != VXGE_HW_OK) {
-               __vxge_hw_ring_delete(vp);
-               goto exit;
+/*
+ * __vxge_hw_blockpool_blocks_add - Request additional blocks
+ */
+static
+void __vxge_hw_blockpool_blocks_add(struct __vxge_hw_blockpool *blockpool)
+{
+       u32 nreq = 0, i;
+
+       if ((blockpool->pool_size  +  blockpool->req_out) <
+               VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE) {
+               nreq = VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE;
+               blockpool->req_out += nreq;
        }

-       /* Note:
-        * Specifying rxd_init callback means two things:
-        * 1) rxds need to be initialized by driver at channel-open time;
-        * 2) rxds need to be posted at channel-open time
-        *    (that's what the initial_replenish() below does)
-        * Currently we don't have a case when the 1) is done without the 2).
-        */
-       if (ring->rxd_init) {
-               status = vxge_hw_ring_replenish(ring);
-               if (status != VXGE_HW_OK) {
-                       __vxge_hw_ring_delete(vp);
+       for (i = 0; i < nreq; i++)
+               vxge_os_dma_malloc_async(
+                       ((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+                       blockpool->hldev, VXGE_HW_BLOCK_SIZE);
+}
+
+/*
+ * __vxge_hw_blockpool_malloc - Allocate a memory block from pool
+ * Allocates a block of memory of given size, either from block pool
+ * or by calling vxge_os_dma_malloc()
+ */
+static void *__vxge_hw_blockpool_malloc(struct __vxge_hw_device *devh, u32 size,
+                                       struct vxge_hw_mempool_dma *dma_object)
+{
+       struct __vxge_hw_blockpool_entry *entry = NULL;
+       struct __vxge_hw_blockpool  *blockpool;
+       void *memblock = NULL;
+       enum vxge_hw_status status = VXGE_HW_OK;
+
+       blockpool = &devh->block_pool;
+
+       if (size != blockpool->block_size) {
+
+               memblock = vxge_os_dma_malloc(devh->pdev, size,
+                                               &dma_object->handle,
+                                               &dma_object->acc_handle);
+
+               if (memblock == NULL) {
+                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
                        goto exit;
                }
-       }

-       /* initial replenish will increment the counter in its post() routine,
-        * we have to reset it */
-       ring->stats->common_stats.usage_cnt = 0;
+               dma_object->addr = pci_map_single(devh->pdev, memblock, size,
+                                       PCI_DMA_BIDIRECTIONAL);
+
+               if (unlikely(pci_dma_mapping_error(devh->pdev,
+                               dma_object->addr))) {
+                       vxge_os_dma_free(devh->pdev, memblock,
+                               &dma_object->acc_handle);
+                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
+                       goto exit;
+               }
+
+       } else {
+
+               if (!list_empty(&blockpool->free_block_list))
+                       entry = (struct __vxge_hw_blockpool_entry *)
+                               list_first_entry(&blockpool->free_block_list,
+                                       struct __vxge_hw_blockpool_entry,
+                                       item);
+
+               if (entry != NULL) {
+                       list_del(&entry->item);
+                       dma_object->addr = entry->dma_addr;
+                       dma_object->handle = entry->dma_handle;
+                       dma_object->acc_handle = entry->acc_handle;
+                       memblock = entry->memblock;
+
+                       list_add(&entry->item,
+                               &blockpool->free_entry_list);
+                       blockpool->pool_size--;
+               }
+
+               if (memblock != NULL)
+                       __vxge_hw_blockpool_blocks_add(blockpool);
+       }
 exit:
-       return status;
+       return memblock;
 }

 /*
- * __vxge_hw_ring_abort - Returns the RxD
- * This function terminates the RxDs of ring
+ * __vxge_hw_blockpool_blocks_remove - Free additional blocks
  */
-enum vxge_hw_status __vxge_hw_ring_abort(struct __vxge_hw_ring *ring)
+static void
+__vxge_hw_blockpool_blocks_remove(struct __vxge_hw_blockpool *blockpool)
 {
-       void *rxdh;
-       struct __vxge_hw_channel *channel;
-
-       channel = &ring->channel;
+       struct list_head *p, *n;

-       for (;;) {
-               vxge_hw_channel_dtr_try_complete(channel, &rxdh);
+       list_for_each_safe(p, n, &blockpool->free_block_list) {

-               if (rxdh == NULL)
+               if (blockpool->pool_size < blockpool->pool_max)
                        break;

-               vxge_hw_channel_dtr_complete(channel);
+               pci_unmap_single(
+                       ((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+                       ((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
+                       ((struct __vxge_hw_blockpool_entry *)p)->length,
+                       PCI_DMA_BIDIRECTIONAL);

-               if (ring->rxd_term)
-                       ring->rxd_term(rxdh, VXGE_HW_RXD_STATE_POSTED,
-                               channel->userdata);
+               vxge_os_dma_free(
+                       ((struct __vxge_hw_device *)blockpool->hldev)->pdev,
+                       ((struct __vxge_hw_blockpool_entry *)p)->memblock,
+                       &((struct __vxge_hw_blockpool_entry *)p)->acc_handle);

-               vxge_hw_channel_dtr_free(channel, rxdh);
-       }
+               list_del(&((struct __vxge_hw_blockpool_entry *)p)->item);

-       return VXGE_HW_OK;
+               list_add(p, &blockpool->free_entry_list);
+
+               blockpool->pool_size--;
+
+       }
 }

 /*
- * __vxge_hw_ring_reset - Resets the ring
- * This function resets the ring during vpath reset operation
+ * __vxge_hw_blockpool_free - Frees the memory allcoated with
+ *                             __vxge_hw_blockpool_malloc
  */
-enum vxge_hw_status __vxge_hw_ring_reset(struct __vxge_hw_ring *ring)
+static void __vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
+                                    void *memblock, u32 size,
+                                    struct vxge_hw_mempool_dma *dma_object)
 {
+       struct __vxge_hw_blockpool_entry *entry = NULL;
+       struct __vxge_hw_blockpool  *blockpool;
        enum vxge_hw_status status = VXGE_HW_OK;
-       struct __vxge_hw_channel *channel;

-       channel = &ring->channel;
+       blockpool = &devh->block_pool;

-       __vxge_hw_ring_abort(ring);
+       if (size != blockpool->block_size) {
+               pci_unmap_single(devh->pdev, dma_object->addr, size,
+                       PCI_DMA_BIDIRECTIONAL);
+               vxge_os_dma_free(devh->pdev, memblock, &dma_object->acc_handle);
+       } else {

-       status = __vxge_hw_channel_reset(channel);
+               if (!list_empty(&blockpool->free_entry_list))
+                       entry = (struct __vxge_hw_blockpool_entry *)
+                               list_first_entry(&blockpool->free_entry_list,
+                                       struct __vxge_hw_blockpool_entry,
+                                       item);

-       if (status != VXGE_HW_OK)
-               goto exit;
+               if (entry == NULL)
+                       entry = (struct __vxge_hw_blockpool_entry *)
+                               vmalloc(sizeof(
+                                       struct __vxge_hw_blockpool_entry));
+               else
+                       list_del(&entry->item);

-       if (ring->rxd_init) {
-               status = vxge_hw_ring_replenish(ring);
-               if (status != VXGE_HW_OK)
-                       goto exit;
+               if (entry != NULL) {
+                       entry->length = size;
+                       entry->memblock = memblock;
+                       entry->dma_addr = dma_object->addr;
+                       entry->acc_handle = dma_object->acc_handle;
+                       entry->dma_handle = dma_object->handle;
+                       list_add(&entry->item,
+                                       &blockpool->free_block_list);
+                       blockpool->pool_size++;
+                       status = VXGE_HW_OK;
+               } else
+                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
+
+               if (status == VXGE_HW_OK)
+                       __vxge_hw_blockpool_blocks_remove(blockpool);
        }
-exit:
-       return status;
 }

 /*
- * __vxge_hw_ring_delete - Removes the ring
- * This function freeup the memory pool and removes the ring
+ * vxge_hw_mempool_destroy
  */
-enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp)
+static void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
 {
-       struct __vxge_hw_ring *ring = vp->vpath->ringh;
+       u32 i, j;
+       struct __vxge_hw_device *devh = mempool->devh;

-       __vxge_hw_ring_abort(ring);
+       for (i = 0; i < mempool->memblocks_allocated; i++) {
+               struct vxge_hw_mempool_dma *dma_object;

-       if (ring->mempool)
-               __vxge_hw_mempool_destroy(ring->mempool);
+               vxge_assert(mempool->memblocks_arr[i]);
+               vxge_assert(mempool->memblocks_dma_arr + i);

-       vp->vpath->ringh = NULL;
-       __vxge_hw_channel_free(&ring->channel);
+               dma_object = mempool->memblocks_dma_arr + i;

-       return VXGE_HW_OK;
+               for (j = 0; j < mempool->items_per_memblock; j++) {
+                       u32 index = i * mempool->items_per_memblock + j;
+
+                       /* to skip last partially filled(if any) memblock */
+                       if (index >= mempool->items_current)
+                               break;
+               }
+
+               vfree(mempool->memblocks_priv_arr[i]);
+
+               __vxge_hw_blockpool_free(devh, mempool->memblocks_arr[i],
+                               mempool->memblock_size, dma_object);
+       }
+
+       vfree(mempool->items_arr);
+       vfree(mempool->memblocks_dma_arr);
+       vfree(mempool->memblocks_priv_arr);
+       vfree(mempool->memblocks_arr);
+       vfree(mempool);
 }

 /*
  * __vxge_hw_mempool_grow
  * Will resize mempool up to %num_allocate value.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_mempool_grow(struct vxge_hw_mempool *mempool, u32 num_allocate,
                       u32 *num_allocated)
 {
@@ -2046,16 +2671,15 @@ exit:
  * with size enough to hold %items_initial number of items. Memory is
  * DMA-able but client must map/unmap before interoperating with the device.
  */
-struct vxge_hw_mempool*
-__vxge_hw_mempool_create(
-       struct __vxge_hw_device *devh,
-       u32 memblock_size,
-       u32 item_size,
-       u32 items_priv_size,
-       u32 items_initial,
-       u32 items_max,
-       struct vxge_hw_mempool_cbs *mp_callback,
-       void *userdata)
+static struct vxge_hw_mempool *
+__vxge_hw_mempool_create(struct __vxge_hw_device *devh,
+                        u32 memblock_size,
+                        u32 item_size,
+                        u32 items_priv_size,
+                        u32 items_initial,
+                        u32 items_max,
+                        struct vxge_hw_mempool_cbs *mp_callback,
+                        void *userdata)
 {
        enum vxge_hw_status status = VXGE_HW_OK;
        u32 memblocks_to_allocate;
@@ -2161,122 +2785,189 @@ exit:
 }

 /*
- * vxge_hw_mempool_destroy
+ * __vxge_hw_ring_abort - Returns the RxD
+ * This function terminates the RxDs of ring
  */
-void __vxge_hw_mempool_destroy(struct vxge_hw_mempool *mempool)
+static enum vxge_hw_status __vxge_hw_ring_abort(struct __vxge_hw_ring *ring)
 {
-       u32 i, j;
-       struct __vxge_hw_device *devh = mempool->devh;
-
-       for (i = 0; i < mempool->memblocks_allocated; i++) {
-               struct vxge_hw_mempool_dma *dma_object;
+       void *rxdh;
+       struct __vxge_hw_channel *channel;

-               vxge_assert(mempool->memblocks_arr[i]);
-               vxge_assert(mempool->memblocks_dma_arr + i);
+       channel = &ring->channel;

-               dma_object = mempool->memblocks_dma_arr + i;
+       for (;;) {
+               vxge_hw_channel_dtr_try_complete(channel, &rxdh);

-               for (j = 0; j < mempool->items_per_memblock; j++) {
-                       u32 index = i * mempool->items_per_memblock + j;
+               if (rxdh == NULL)
+                       break;

-                       /* to skip last partially filled(if any) memblock */
-                       if (index >= mempool->items_current)
-                               break;
-               }
+               vxge_hw_channel_dtr_complete(channel);

-               vfree(mempool->memblocks_priv_arr[i]);
+               if (ring->rxd_term)
+                       ring->rxd_term(rxdh, VXGE_HW_RXD_STATE_POSTED,
+                               channel->userdata);

-               __vxge_hw_blockpool_free(devh, mempool->memblocks_arr[i],
-                               mempool->memblock_size, dma_object);
+               vxge_hw_channel_dtr_free(channel, rxdh);
        }

-       vfree(mempool->items_arr);
+       return VXGE_HW_OK;
+}

-       vfree(mempool->memblocks_dma_arr);
+/*
+ * __vxge_hw_ring_reset - Resets the ring
+ * This function resets the ring during vpath reset operation
+ */
+static enum vxge_hw_status __vxge_hw_ring_reset(struct __vxge_hw_ring *ring)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct __vxge_hw_channel *channel;

-       vfree(mempool->memblocks_priv_arr);
+       channel = &ring->channel;

-       vfree(mempool->memblocks_arr);
+       __vxge_hw_ring_abort(ring);

-       vfree(mempool);
+       status = __vxge_hw_channel_reset(channel);
+
+       if (status != VXGE_HW_OK)
+               goto exit;
+
+       if (ring->rxd_init) {
+               status = vxge_hw_ring_replenish(ring);
+               if (status != VXGE_HW_OK)
+                       goto exit;
+       }
+exit:
+       return status;
 }

 /*
- * __vxge_hw_device_fifo_config_check - Check fifo configuration.
- * Check the fifo configuration
+ * __vxge_hw_ring_delete - Removes the ring
+ * This function freeup the memory pool and removes the ring
  */
-enum vxge_hw_status
-__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config)
+static enum vxge_hw_status __vxge_hw_ring_delete(struct __vxge_hw_vpath_handle *vp)
 {
-       if ((fifo_config->fifo_blocks < VXGE_HW_MIN_FIFO_BLOCKS) ||
-            (fifo_config->fifo_blocks > VXGE_HW_MAX_FIFO_BLOCKS))
-               return VXGE_HW_BADCFG_FIFO_BLOCKS;
+       struct __vxge_hw_ring *ring = vp->vpath->ringh;
+
+       __vxge_hw_ring_abort(ring);
+
+       if (ring->mempool)
+               __vxge_hw_mempool_destroy(ring->mempool);
+
+       vp->vpath->ringh = NULL;
+       __vxge_hw_channel_free(&ring->channel);

        return VXGE_HW_OK;
 }

 /*
- * __vxge_hw_device_vpath_config_check - Check vpath configuration.
- * Check the vpath configuration
+ * __vxge_hw_ring_create - Create a Ring
+ * This function creates Ring and initializes it.
  */
-enum vxge_hw_status
-__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config)
+static enum vxge_hw_status
+__vxge_hw_ring_create(struct __vxge_hw_vpath_handle *vp,
+                     struct vxge_hw_ring_attr *attr)
 {
-       enum vxge_hw_status status;
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct __vxge_hw_ring *ring;
+       u32 ring_length;
+       struct vxge_hw_ring_config *config;
+       struct __vxge_hw_device *hldev;
+       u32 vp_id;
+       struct vxge_hw_mempool_cbs ring_mp_callback;

-       if ((vp_config->min_bandwidth < VXGE_HW_VPATH_BANDWIDTH_MIN) ||
-               (vp_config->min_bandwidth >
-                                       VXGE_HW_VPATH_BANDWIDTH_MAX))
-               return VXGE_HW_BADCFG_VPATH_MIN_BANDWIDTH;
+       if ((vp == NULL) || (attr == NULL)) {
+               status = VXGE_HW_FAIL;
+               goto exit;
+       }

-       status = __vxge_hw_device_fifo_config_check(&vp_config->fifo);
-       if (status != VXGE_HW_OK)
-               return status;
+       hldev = vp->vpath->hldev;
+       vp_id = vp->vpath->vp_id;

-       if ((vp_config->mtu != VXGE_HW_VPATH_USE_FLASH_DEFAULT_INITIAL_MTU) &&
-               ((vp_config->mtu < VXGE_HW_VPATH_MIN_INITIAL_MTU) ||
-               (vp_config->mtu > VXGE_HW_VPATH_MAX_INITIAL_MTU)))
-               return VXGE_HW_BADCFG_VPATH_MTU;
+       config = &hldev->config.vp_config[vp_id].ring;

-       if ((vp_config->rpa_strip_vlan_tag !=
-               VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_USE_FLASH_DEFAULT) &&
-               (vp_config->rpa_strip_vlan_tag !=
-               VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_ENABLE) &&
-               (vp_config->rpa_strip_vlan_tag !=
-               VXGE_HW_VPATH_RPA_STRIP_VLAN_TAG_DISABLE))
-               return VXGE_HW_BADCFG_VPATH_RPA_STRIP_VLAN_TAG;
+       ring_length = config->ring_blocks *
+                       vxge_hw_ring_rxds_per_block_get(config->buffer_mode);

-       return VXGE_HW_OK;
-}
+       ring = (struct __vxge_hw_ring *)__vxge_hw_channel_allocate(vp,
+                                               VXGE_HW_CHANNEL_TYPE_RING,
+                                               ring_length,
+                                               attr->per_rxd_space,
+                                               attr->userdata);

-/*
- * __vxge_hw_device_config_check - Check device configuration.
- * Check the device configuration
- */
-enum vxge_hw_status
-__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config)
-{
-       u32 i;
-       enum vxge_hw_status status;
+       if (ring == NULL) {
+               status = VXGE_HW_ERR_OUT_OF_MEMORY;
+               goto exit;
+       }

-       if ((new_config->intr_mode != VXGE_HW_INTR_MODE_IRQLINE) &&
-          (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX) &&
-          (new_config->intr_mode != VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) &&
-          (new_config->intr_mode != VXGE_HW_INTR_MODE_DEF))
-               return VXGE_HW_BADCFG_INTR_MODE;
+       vp->vpath->ringh = ring;
+       ring->vp_id = vp_id;
+       ring->vp_reg = vp->vpath->vp_reg;
+       ring->common_reg = hldev->common_reg;
+       ring->stats = &vp->vpath->sw_stats->ring_stats;
+       ring->config = config;
+       ring->callback = attr->callback;
+       ring->rxd_init = attr->rxd_init;
+       ring->rxd_term = attr->rxd_term;
+       ring->buffer_mode = config->buffer_mode;
+       ring->rxds_limit = config->rxds_limit;

-       if ((new_config->rts_mac_en != VXGE_HW_RTS_MAC_DISABLE) &&
-          (new_config->rts_mac_en != VXGE_HW_RTS_MAC_ENABLE))
-               return VXGE_HW_BADCFG_RTS_MAC_EN;
+       ring->rxd_size = vxge_hw_ring_rxd_size_get(config->buffer_mode);
+       ring->rxd_priv_size =
+               sizeof(struct __vxge_hw_ring_rxd_priv) + attr->per_rxd_space;
+       ring->per_rxd_space = attr->per_rxd_space;

-       for (i = 0; i < VXGE_HW_MAX_VIRTUAL_PATHS; i++) {
-               status = __vxge_hw_device_vpath_config_check(
-                               &new_config->vp_config[i]);
-               if (status != VXGE_HW_OK)
-                       return status;
+       ring->rxd_priv_size =
+               ((ring->rxd_priv_size + VXGE_CACHE_LINE_SIZE - 1) /
+               VXGE_CACHE_LINE_SIZE) * VXGE_CACHE_LINE_SIZE;
+
+       /* how many RxDs can fit into one block. Depends on configured
+        * buffer_mode. */
+       ring->rxds_per_block =
+               vxge_hw_ring_rxds_per_block_get(config->buffer_mode);
+
+       /* calculate actual RxD block private size */
+       ring->rxdblock_priv_size = ring->rxd_priv_size * ring->rxds_per_block;
+       ring_mp_callback.item_func_alloc = __vxge_hw_ring_mempool_item_alloc;
+       ring->mempool = __vxge_hw_mempool_create(hldev,
+                               VXGE_HW_BLOCK_SIZE,
+                               VXGE_HW_BLOCK_SIZE,
+                               ring->rxdblock_priv_size,
+                               ring->config->ring_blocks,
+                               ring->config->ring_blocks,
+                               &ring_mp_callback,
+                               ring);
+
+       if (ring->mempool == NULL) {
+               __vxge_hw_ring_delete(vp);
+               return VXGE_HW_ERR_OUT_OF_MEMORY;
        }

-       return VXGE_HW_OK;
+       status = __vxge_hw_channel_initialize(&ring->channel);
+       if (status != VXGE_HW_OK) {
+               __vxge_hw_ring_delete(vp);
+               goto exit;
+       }
+
+       /* Note:
+        * Specifying rxd_init callback means two things:
+        * 1) rxds need to be initialized by driver at channel-open time;
+        * 2) rxds need to be posted at channel-open time
+        *    (that's what the initial_replenish() below does)
+        * Currently we don't have a case when the 1) is done without the 2).
+        */
+       if (ring->rxd_init) {
+               status = vxge_hw_ring_replenish(ring);
+               if (status != VXGE_HW_OK) {
+                       __vxge_hw_ring_delete(vp);
+                       goto exit;
+               }
+       }
+
+       /* initial replenish will increment the counter in its post() routine,
+        * we have to reset it */
+       ring->stats->common_stats.usage_cnt = 0;
+exit:
+       return status;
 }

 /*
@@ -2438,65 +3129,10 @@ vxge_hw_device_config_default_get(struct vxge_hw_device_config *device_config)
 }

 /*
- * _hw_legacy_swapper_set - Set the swapper bits for the legacy secion.
- * Set the swapper bits appropriately for the lagacy section.
- */
-enum vxge_hw_status
-__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg)
-{
-       u64 val64;
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       val64 = readq(&legacy_reg->toc_swapper_fb);
-
-       wmb();
-
-       switch (val64) {
-
-       case VXGE_HW_SWAPPER_INITIAL_VALUE:
-               return status;
-
-       case VXGE_HW_SWAPPER_BYTE_SWAPPED_BIT_FLIPPED:
-               writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
-                       &legacy_reg->pifm_rd_swap_en);
-               writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
-                       &legacy_reg->pifm_rd_flip_en);
-               writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
-                       &legacy_reg->pifm_wr_swap_en);
-               writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
-                       &legacy_reg->pifm_wr_flip_en);
-               break;
-
-       case VXGE_HW_SWAPPER_BYTE_SWAPPED:
-               writeq(VXGE_HW_SWAPPER_READ_BYTE_SWAP_ENABLE,
-                       &legacy_reg->pifm_rd_swap_en);
-               writeq(VXGE_HW_SWAPPER_WRITE_BYTE_SWAP_ENABLE,
-                       &legacy_reg->pifm_wr_swap_en);
-               break;
-
-       case VXGE_HW_SWAPPER_BIT_FLIPPED:
-               writeq(VXGE_HW_SWAPPER_READ_BIT_FLAP_ENABLE,
-                       &legacy_reg->pifm_rd_flip_en);
-               writeq(VXGE_HW_SWAPPER_WRITE_BIT_FLAP_ENABLE,
-                       &legacy_reg->pifm_wr_flip_en);
-               break;
-       }
-
-       wmb();
-
-       val64 = readq(&legacy_reg->toc_swapper_fb);
-
-       if (val64 != VXGE_HW_SWAPPER_INITIAL_VALUE)
-               status = VXGE_HW_ERR_SWAPPER_CTRL;
-
-       return status;
-}
-
-/*
  * __vxge_hw_vpath_swapper_set - Set the swapper bits for the vpath.
  * Set the swapper bits appropriately for the vpath.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg)
 {
 #ifndef __BIG_ENDIAN
@@ -2515,10 +3151,9 @@ __vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg)
  * __vxge_hw_kdfc_swapper_set - Set the swapper bits for the kdfc.
  * Set the swapper bits appropriately for the vpath.
  */
-enum vxge_hw_status
-__vxge_hw_kdfc_swapper_set(
-       struct vxge_hw_legacy_reg __iomem *legacy_reg,
-       struct vxge_hw_vpath_reg __iomem *vpath_reg)
+static enum vxge_hw_status
+__vxge_hw_kdfc_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg,
+                          struct vxge_hw_vpath_reg __iomem *vpath_reg)
 {
        u64 val64;

@@ -2540,28 +3175,6 @@ __vxge_hw_kdfc_swapper_set(
 }

 /*
- * vxge_hw_mgmt_device_config - Retrieve device configuration.
- * Get device configuration. Permits to retrieve at run-time configuration
- * values that were used to initialize and configure the device.
- */
-enum vxge_hw_status
-vxge_hw_mgmt_device_config(struct __vxge_hw_device *hldev,
-                          struct vxge_hw_device_config *dev_config, int size)
-{
-
-       if ((hldev == NULL) || (hldev->magic != VXGE_HW_DEVICE_MAGIC))
-               return VXGE_HW_ERR_INVALID_DEVICE;
-
-       if (size != sizeof(struct vxge_hw_device_config))
-               return VXGE_HW_ERR_VERSION_CONFLICT;
-
-       memcpy(dev_config, &hldev->config,
-               sizeof(struct vxge_hw_device_config));
-
-       return VXGE_HW_OK;
-}
-
-/*
  * vxge_hw_mgmt_reg_read - Read Titan register.
  */
 enum vxge_hw_status
@@ -2790,6 +3403,69 @@ exit:
 }

 /*
+ * __vxge_hw_fifo_abort - Returns the TxD
+ * This function terminates the TxDs of fifo
+ */
+static enum vxge_hw_status __vxge_hw_fifo_abort(struct __vxge_hw_fifo *fifo)
+{
+       void *txdlh;
+
+       for (;;) {
+               vxge_hw_channel_dtr_try_complete(&fifo->channel, &txdlh);
+
+               if (txdlh == NULL)
+                       break;
+
+               vxge_hw_channel_dtr_complete(&fifo->channel);
+
+               if (fifo->txdl_term) {
+                       fifo->txdl_term(txdlh,
+                       VXGE_HW_TXDL_STATE_POSTED,
+                       fifo->channel.userdata);
+               }
+
+               vxge_hw_channel_dtr_free(&fifo->channel, txdlh);
+       }
+
+       return VXGE_HW_OK;
+}
+
+/*
+ * __vxge_hw_fifo_reset - Resets the fifo
+ * This function resets the fifo during vpath reset operation
+ */
+static enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+
+       __vxge_hw_fifo_abort(fifo);
+       status = __vxge_hw_channel_reset(&fifo->channel);
+
+       return status;
+}
+
+/*
+ * __vxge_hw_fifo_delete - Removes the FIFO
+ * This function freeup the memory pool and removes the FIFO
+ */
+static enum vxge_hw_status
+__vxge_hw_fifo_delete(struct __vxge_hw_vpath_handle *vp)
+{
+       struct __vxge_hw_fifo *fifo = vp->vpath->fifoh;
+
+       __vxge_hw_fifo_abort(fifo);
+
+       if (fifo->mempool)
+               __vxge_hw_mempool_destroy(fifo->mempool);
+
+       vp->vpath->fifoh = NULL;
+
+       __vxge_hw_channel_free(&fifo->channel);
+
+       return VXGE_HW_OK;
+}
+
+/*
  * __vxge_hw_fifo_mempool_item_alloc - Allocate List blocks for TxD
  * list callback
  * This function is callback passed to __vxge_hw_mempool_create to create memory
@@ -2835,7 +3511,7 @@ __vxge_hw_fifo_mempool_item_alloc(
  * __vxge_hw_fifo_create - Create a FIFO
  * This function creates FIFO and initializes it.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_fifo_create(struct __vxge_hw_vpath_handle *vp,
                      struct vxge_hw_fifo_attr *attr)
 {
@@ -2954,73 +3630,11 @@ exit:
 }

 /*
- * __vxge_hw_fifo_abort - Returns the TxD
- * This function terminates the TxDs of fifo
- */
-enum vxge_hw_status __vxge_hw_fifo_abort(struct __vxge_hw_fifo *fifo)
-{
-       void *txdlh;
-
-       for (;;) {
-               vxge_hw_channel_dtr_try_complete(&fifo->channel, &txdlh);
-
-               if (txdlh == NULL)
-                       break;
-
-               vxge_hw_channel_dtr_complete(&fifo->channel);
-
-               if (fifo->txdl_term) {
-                       fifo->txdl_term(txdlh,
-                       VXGE_HW_TXDL_STATE_POSTED,
-                       fifo->channel.userdata);
-               }
-
-               vxge_hw_channel_dtr_free(&fifo->channel, txdlh);
-       }
-
-       return VXGE_HW_OK;
-}
-
-/*
- * __vxge_hw_fifo_reset - Resets the fifo
- * This function resets the fifo during vpath reset operation
- */
-enum vxge_hw_status __vxge_hw_fifo_reset(struct __vxge_hw_fifo *fifo)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       __vxge_hw_fifo_abort(fifo);
-       status = __vxge_hw_channel_reset(&fifo->channel);
-
-       return status;
-}
-
-/*
- * __vxge_hw_fifo_delete - Removes the FIFO
- * This function freeup the memory pool and removes the FIFO
- */
-enum vxge_hw_status __vxge_hw_fifo_delete(struct __vxge_hw_vpath_handle *vp)
-{
-       struct __vxge_hw_fifo *fifo = vp->vpath->fifoh;
-
-       __vxge_hw_fifo_abort(fifo);
-
-       if (fifo->mempool)
-               __vxge_hw_mempool_destroy(fifo->mempool);
-
-       vp->vpath->fifoh = NULL;
-
-       __vxge_hw_channel_free(&fifo->channel);
-
-       return VXGE_HW_OK;
-}
-
-/*
  * __vxge_hw_vpath_pci_read - Read the content of given address
  *                          in pci config space.
  * Read from the vpath pci config space.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_pci_read(struct __vxge_hw_virtualpath *vpath,
                         u32 phy_func_0, u32 offset, u32 *val)
 {
@@ -3459,7 +4073,7 @@ __vxge_hw_vpath_mgmt_read(
  * This routine checks the vpath_rst_in_prog register to see if
  * adapter completed the reset process for the vpath
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath)
 {
        enum vxge_hw_status status;
@@ -3477,7 +4091,7 @@ __vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath)
  * __vxge_hw_vpath_reset
  * This routine resets the vpath on the device
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_reset(struct __vxge_hw_device *hldev, u32 vp_id)
 {
        u64 val64;
@@ -3495,7 +4109,7 @@ __vxge_hw_vpath_reset(struct __vxge_hw_device *hldev, u32 vp_id)
  * __vxge_hw_vpath_sw_reset
  * This routine resets the vpath structures
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_sw_reset(struct __vxge_hw_device *hldev, u32 vp_id)
 {
        enum vxge_hw_status status = VXGE_HW_OK;
@@ -3520,7 +4134,7 @@ exit:
  * This routine configures the prc registers of virtual path using the config
  * passed
  */
-void
+static void
 __vxge_hw_vpath_prc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 {
        u64 val64;
@@ -3592,7 +4206,7 @@ __vxge_hw_vpath_prc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
  * This routine configures the kdfc registers of virtual path using the
  * config passed
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_kdfc_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 {
        u64 val64;
@@ -3665,7 +4279,7 @@ exit:
  * __vxge_hw_vpath_mac_configure
  * This routine configures the mac of virtual path using the config passed
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_mac_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 {
        u64 val64;
@@ -3733,7 +4347,7 @@ __vxge_hw_vpath_mac_configure(struct __vxge_hw_device *hldev, u32 vp_id)
  * This routine configures the tim registers of virtual path using the config
  * passed
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_tim_configure(struct __vxge_hw_device *hldev, u32 vp_id)
 {
        u64 val64;
@@ -4009,7 +4623,7 @@ vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id)
  * This routine is the final phase of init which initializes the
  * registers of the vpath using the configuration passed.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vpath_initialize(struct __vxge_hw_device *hldev, u32 vp_id)
 {
        u64 val64;
@@ -4074,11 +4688,33 @@ exit:
 }

 /*
+ * __vxge_hw_vp_terminate - Terminate Virtual Path structure
+ * This routine closes all channels it opened and freeup memory
+ */
+static void __vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
+{
+       struct __vxge_hw_virtualpath *vpath;
+
+       vpath = &hldev->virtual_paths[vp_id];
+
+       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN)
+               goto exit;
+
+       VXGE_HW_DEVICE_TIM_INT_MASK_RESET(vpath->hldev->tim_int_mask0,
+               vpath->hldev->tim_int_mask1, vpath->vp_id);
+       hldev->stats.hw_dev_info_stats.vpath_info[vpath->vp_id] = NULL;
+
+       memset(vpath, 0, sizeof(struct __vxge_hw_virtualpath));
+exit:
+       return;
+}
+
+/*
  * __vxge_hw_vp_initialize - Initialize Virtual Path structure
  * This routine is the initial phase of init which resets the vpath and
  * initializes the software support structures.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 __vxge_hw_vp_initialize(struct __vxge_hw_device *hldev, u32 vp_id,
                        struct vxge_hw_vp_config *config)
 {
@@ -4129,29 +4765,6 @@ exit:
 }

 /*
- * __vxge_hw_vp_terminate - Terminate Virtual Path structure
- * This routine closes all channels it opened and freeup memory
- */
-void
-__vxge_hw_vp_terminate(struct __vxge_hw_device *hldev, u32 vp_id)
-{
-       struct __vxge_hw_virtualpath *vpath;
-
-       vpath = &hldev->virtual_paths[vp_id];
-
-       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN)
-               goto exit;
-
-       VXGE_HW_DEVICE_TIM_INT_MASK_RESET(vpath->hldev->tim_int_mask0,
-               vpath->hldev->tim_int_mask1, vpath->vp_id);
-       hldev->stats.hw_dev_info_stats.vpath_info[vpath->vp_id] = NULL;
-
-       memset(vpath, 0, sizeof(struct __vxge_hw_virtualpath));
-exit:
-       return;
-}
-
-/*
  * vxge_hw_vpath_mtu_set - Set MTU.
  * Set new MTU value. Example, to use jumbo frames:
  * vxge_hw_vpath_mtu_set(my_device, 9600);
@@ -4188,6 +4801,64 @@ exit:
 }

 /*
+ * vxge_hw_vpath_stats_enable - Enable vpath h/wstatistics.
+ * Enable the DMA vpath statistics. The function is to be called to re-enable
+ * the adapter to update stats into the host memory
+ */
+static enum vxge_hw_status
+vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vp)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct __vxge_hw_virtualpath *vpath;
+
+       vpath = vp->vpath;
+
+       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
+               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
+               goto exit;
+       }
+
+       memcpy(vpath->hw_stats_sav, vpath->hw_stats,
+                       sizeof(struct vxge_hw_vpath_stats_hw_info));
+
+       status = __vxge_hw_vpath_stats_get(vpath, vpath->hw_stats);
+exit:
+       return status;
+}
+
+/*
+ * __vxge_hw_blockpool_block_allocate - Allocates a block from block pool
+ * This function allocates a block from block pool or from the system
+ */
+static struct __vxge_hw_blockpool_entry *
+__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *devh, u32 size)
+{
+       struct __vxge_hw_blockpool_entry *entry = NULL;
+       struct __vxge_hw_blockpool  *blockpool;
+
+       blockpool = &devh->block_pool;
+
+       if (size == blockpool->block_size) {
+
+               if (!list_empty(&blockpool->free_block_list))
+                       entry = (struct __vxge_hw_blockpool_entry *)
+                               list_first_entry(&blockpool->free_block_list,
+                                       struct __vxge_hw_blockpool_entry,
+                                       item);
+
+               if (entry != NULL) {
+                       list_del(&entry->item);
+                       blockpool->pool_size--;
+               }
+       }
+
+       if (entry != NULL)
+               __vxge_hw_blockpool_blocks_add(blockpool);
+
+       return entry;
+}
+
+/*
  * vxge_hw_vpath_open - Open a virtual path on a given adapter
  * This function is used to open access to virtual path of an
  * adapter for offload, GRO operations. This function returns
@@ -4342,6 +5013,29 @@ vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp)
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
+                              struct __vxge_hw_blockpool_entry *entry)
+{
+       struct __vxge_hw_blockpool  *blockpool;
+
+       blockpool = &devh->block_pool;
+
+       if (entry->length == blockpool->block_size) {
+               list_add(&entry->item, &blockpool->free_block_list);
+               blockpool->pool_size++;
+       }
+
+       __vxge_hw_blockpool_blocks_remove(blockpool);
+}
+
+/*
  * vxge_hw_vpath_close - Close the handle got from previous vpath (vpath) open
  * This function is used to close access to virtual path opened
  * earlier.
@@ -4492,705 +5186,3 @@ vxge_hw_vpath_enable(struct __vxge_hw_vpath_handle *vp)
        __vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32),
                &hldev->common_reg->cmn_rsthdlr_cfg1);
 }
-
-/*
- * vxge_hw_vpath_stats_enable - Enable vpath h/wstatistics.
- * Enable the DMA vpath statistics. The function is to be called to re-enable
- * the adapter to update stats into the host memory
- */
-enum vxge_hw_status
-vxge_hw_vpath_stats_enable(struct __vxge_hw_vpath_handle *vp)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct __vxge_hw_virtualpath *vpath;
-
-       vpath = vp->vpath;
-
-       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-               goto exit;
-       }
-
-       memcpy(vpath->hw_stats_sav, vpath->hw_stats,
-                       sizeof(struct vxge_hw_vpath_stats_hw_info));
-
-       status = __vxge_hw_vpath_stats_get(vpath, vpath->hw_stats);
-exit:
-       return status;
-}
-
-/*
- * __vxge_hw_vpath_stats_access - Get the statistics from the given location
- *                           and offset and perform an operation
- */
-enum vxge_hw_status
-__vxge_hw_vpath_stats_access(struct __vxge_hw_virtualpath *vpath,
-                            u32 operation, u32 offset, u64 *stat)
-{
-       u64 val64;
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct vxge_hw_vpath_reg __iomem *vp_reg;
-
-       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-               goto vpath_stats_access_exit;
-       }
-
-       vp_reg = vpath->vp_reg;
-
-       val64 =  VXGE_HW_XMAC_STATS_ACCESS_CMD_OP(operation) |
-                VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE |
-                VXGE_HW_XMAC_STATS_ACCESS_CMD_OFFSET_SEL(offset);
-
-       status = __vxge_hw_pio_mem_write64(val64,
-                               &vp_reg->xmac_stats_access_cmd,
-                               VXGE_HW_XMAC_STATS_ACCESS_CMD_STROBE,
-                               vpath->hldev->config.device_poll_millis);
-
-       if ((status == VXGE_HW_OK) && (operation == VXGE_HW_STATS_OP_READ))
-               *stat = readq(&vp_reg->xmac_stats_access_data);
-       else
-               *stat = 0;
-
-vpath_stats_access_exit:
-       return status;
-}
-
-/*
- * __vxge_hw_vpath_xmac_tx_stats_get - Get the TX Statistics of a vpath
- */
-enum vxge_hw_status
-__vxge_hw_vpath_xmac_tx_stats_get(
-       struct __vxge_hw_virtualpath *vpath,
-       struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats)
-{
-       u64 *val64;
-       int i;
-       u32 offset = VXGE_HW_STATS_VPATH_TX_OFFSET;
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       val64 = (u64 *) vpath_tx_stats;
-
-       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-               goto exit;
-       }
-
-       for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_tx_stats) / 8; i++) {
-               status = __vxge_hw_vpath_stats_access(vpath,
-                                       VXGE_HW_STATS_OP_READ,
-                                       offset, val64);
-               if (status != VXGE_HW_OK)
-                       goto exit;
-               offset++;
-               val64++;
-       }
-exit:
-       return status;
-}
-
-/*
- * __vxge_hw_vpath_xmac_rx_stats_get - Get the RX Statistics of a vpath
- */
-enum vxge_hw_status
-__vxge_hw_vpath_xmac_rx_stats_get(struct __vxge_hw_virtualpath *vpath,
-                       struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats)
-{
-       u64 *val64;
-       enum vxge_hw_status status = VXGE_HW_OK;
-       int i;
-       u32 offset = VXGE_HW_STATS_VPATH_RX_OFFSET;
-       val64 = (u64 *) vpath_rx_stats;
-
-       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-               goto exit;
-       }
-       for (i = 0; i < sizeof(struct vxge_hw_xmac_vpath_rx_stats) / 8; i++) {
-               status = __vxge_hw_vpath_stats_access(vpath,
-                                       VXGE_HW_STATS_OP_READ,
-                                       offset >> 3, val64);
-               if (status != VXGE_HW_OK)
-                       goto exit;
-
-               offset += 8;
-               val64++;
-       }
-exit:
-       return status;
-}
-
-/*
- * __vxge_hw_vpath_stats_get - Get the vpath hw statistics.
- */
-enum vxge_hw_status __vxge_hw_vpath_stats_get(
-                       struct __vxge_hw_virtualpath *vpath,
-                       struct vxge_hw_vpath_stats_hw_info *hw_stats)
-{
-       u64 val64;
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct vxge_hw_vpath_reg __iomem *vp_reg;
-
-       if (vpath->vp_open == VXGE_HW_VP_NOT_OPEN) {
-               status = VXGE_HW_ERR_VPATH_NOT_OPEN;
-               goto exit;
-       }
-       vp_reg = vpath->vp_reg;
-
-       val64 = readq(&vp_reg->vpath_debug_stats0);
-       hw_stats->ini_num_mwr_sent =
-               (u32)VXGE_HW_VPATH_DEBUG_STATS0_GET_INI_NUM_MWR_SENT(val64);
-
-       val64 = readq(&vp_reg->vpath_debug_stats1);
-       hw_stats->ini_num_mrd_sent =
-               (u32)VXGE_HW_VPATH_DEBUG_STATS1_GET_INI_NUM_MRD_SENT(val64);
-
-       val64 = readq(&vp_reg->vpath_debug_stats2);
-       hw_stats->ini_num_cpl_rcvd =
-               (u32)VXGE_HW_VPATH_DEBUG_STATS2_GET_INI_NUM_CPL_RCVD(val64);
-
-       val64 = readq(&vp_reg->vpath_debug_stats3);
-       hw_stats->ini_num_mwr_byte_sent =
-               VXGE_HW_VPATH_DEBUG_STATS3_GET_INI_NUM_MWR_BYTE_SENT(val64);
-
-       val64 = readq(&vp_reg->vpath_debug_stats4);
-       hw_stats->ini_num_cpl_byte_rcvd =
-               VXGE_HW_VPATH_DEBUG_STATS4_GET_INI_NUM_CPL_BYTE_RCVD(val64);
-
-       val64 = readq(&vp_reg->vpath_debug_stats5);
-       hw_stats->wrcrdtarb_xoff =
-               (u32)VXGE_HW_VPATH_DEBUG_STATS5_GET_WRCRDTARB_XOFF(val64);
-
-       val64 = readq(&vp_reg->vpath_debug_stats6);
-       hw_stats->rdcrdtarb_xoff =
-               (u32)VXGE_HW_VPATH_DEBUG_STATS6_GET_RDCRDTARB_XOFF(val64);
-
-       val64 = readq(&vp_reg->vpath_genstats_count01);
-       hw_stats->vpath_genstats_count0 =
-       (u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT0(
-               val64);
-
-       val64 = readq(&vp_reg->vpath_genstats_count01);
-       hw_stats->vpath_genstats_count1 =
-       (u32)VXGE_HW_VPATH_GENSTATS_COUNT01_GET_PPIF_VPATH_GENSTATS_COUNT1(
-               val64);
-
-       val64 = readq(&vp_reg->vpath_genstats_count23);
-       hw_stats->vpath_genstats_count2 =
-       (u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT2(
-               val64);
-
-       val64 = readq(&vp_reg->vpath_genstats_count01);
-       hw_stats->vpath_genstats_count3 =
-       (u32)VXGE_HW_VPATH_GENSTATS_COUNT23_GET_PPIF_VPATH_GENSTATS_COUNT3(
-               val64);
-
-       val64 = readq(&vp_reg->vpath_genstats_count4);
-       hw_stats->vpath_genstats_count4 =
-       (u32)VXGE_HW_VPATH_GENSTATS_COUNT4_GET_PPIF_VPATH_GENSTATS_COUNT4(
-               val64);
-
-       val64 = readq(&vp_reg->vpath_genstats_count5);
-       hw_stats->vpath_genstats_count5 =
-       (u32)VXGE_HW_VPATH_GENSTATS_COUNT5_GET_PPIF_VPATH_GENSTATS_COUNT5(
-               val64);
-
-       status = __vxge_hw_vpath_xmac_tx_stats_get(vpath, &hw_stats->tx_stats);
-       if (status != VXGE_HW_OK)
-               goto exit;
-
-       status = __vxge_hw_vpath_xmac_rx_stats_get(vpath, &hw_stats->rx_stats);
-       if (status != VXGE_HW_OK)
-               goto exit;
-
-       VXGE_HW_VPATH_STATS_PIO_READ(
-               VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM0_OFFSET);
-
-       hw_stats->prog_event_vnum0 =
-                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM0(val64);
-
-       hw_stats->prog_event_vnum1 =
-                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM1(val64);
-
-       VXGE_HW_VPATH_STATS_PIO_READ(
-               VXGE_HW_STATS_VPATH_PROG_EVENT_VNUM2_OFFSET);
-
-       hw_stats->prog_event_vnum2 =
-                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM2(val64);
-
-       hw_stats->prog_event_vnum3 =
-                       (u32)VXGE_HW_STATS_GET_VPATH_PROG_EVENT_VNUM3(val64);
-
-       val64 = readq(&vp_reg->rx_multi_cast_stats);
-       hw_stats->rx_multi_cast_frame_discard =
-               (u16)VXGE_HW_RX_MULTI_CAST_STATS_GET_FRAME_DISCARD(val64);
-
-       val64 = readq(&vp_reg->rx_frm_transferred);
-       hw_stats->rx_frm_transferred =
-               (u32)VXGE_HW_RX_FRM_TRANSFERRED_GET_RX_FRM_TRANSFERRED(val64);
-
-       val64 = readq(&vp_reg->rxd_returned);
-       hw_stats->rxd_returned =
-               (u16)VXGE_HW_RXD_RETURNED_GET_RXD_RETURNED(val64);
-
-       val64 = readq(&vp_reg->dbg_stats_rx_mpa);
-       hw_stats->rx_mpa_len_fail_frms =
-               (u16)VXGE_HW_DBG_STATS_GET_RX_MPA_LEN_FAIL_FRMS(val64);
-       hw_stats->rx_mpa_mrk_fail_frms =
-               (u16)VXGE_HW_DBG_STATS_GET_RX_MPA_MRK_FAIL_FRMS(val64);
-       hw_stats->rx_mpa_crc_fail_frms =
-               (u16)VXGE_HW_DBG_STATS_GET_RX_MPA_CRC_FAIL_FRMS(val64);
-
-       val64 = readq(&vp_reg->dbg_stats_rx_fau);
-       hw_stats->rx_permitted_frms =
-               (u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_PERMITTED_FRMS(val64);
-       hw_stats->rx_vp_reset_discarded_frms =
-       (u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_VP_RESET_DISCARDED_FRMS(val64);
-       hw_stats->rx_wol_frms =
-               (u16)VXGE_HW_DBG_STATS_GET_RX_FAU_RX_WOL_FRMS(val64);
-
-       val64 = readq(&vp_reg->tx_vp_reset_discarded_frms);
-       hw_stats->tx_vp_reset_discarded_frms =
-       (u16)VXGE_HW_TX_VP_RESET_DISCARDED_FRMS_GET_TX_VP_RESET_DISCARDED_FRMS(
-               val64);
-exit:
-       return status;
-}
-
-/*
- * __vxge_hw_blockpool_create - Create block pool
- */
-
-enum vxge_hw_status
-__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
-                          struct __vxge_hw_blockpool *blockpool,
-                          u32 pool_size,
-                          u32 pool_max)
-{
-       u32 i;
-       struct __vxge_hw_blockpool_entry *entry = NULL;
-       void *memblock;
-       dma_addr_t dma_addr;
-       struct pci_dev *dma_handle;
-       struct pci_dev *acc_handle;
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       if (blockpool == NULL) {
-               status = VXGE_HW_FAIL;
-               goto blockpool_create_exit;
-       }
-
-       blockpool->hldev = hldev;
-       blockpool->block_size = VXGE_HW_BLOCK_SIZE;
-       blockpool->pool_size = 0;
-       blockpool->pool_max = pool_max;
-       blockpool->req_out = 0;
-
-       INIT_LIST_HEAD(&blockpool->free_block_list);
-       INIT_LIST_HEAD(&blockpool->free_entry_list);
-
-       for (i = 0; i < pool_size + pool_max; i++) {
-               entry = kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
-                               GFP_KERNEL);
-               if (entry == NULL) {
-                       __vxge_hw_blockpool_destroy(blockpool);
-                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
-                       goto blockpool_create_exit;
-               }
-               list_add(&entry->item, &blockpool->free_entry_list);
-       }
-
-       for (i = 0; i < pool_size; i++) {
-
-               memblock = vxge_os_dma_malloc(
-                               hldev->pdev,
-                               VXGE_HW_BLOCK_SIZE,
-                               &dma_handle,
-                               &acc_handle);
-
-               if (memblock == NULL) {
-                       __vxge_hw_blockpool_destroy(blockpool);
-                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
-                       goto blockpool_create_exit;
-               }
-
-               dma_addr = pci_map_single(hldev->pdev, memblock,
-                               VXGE_HW_BLOCK_SIZE, PCI_DMA_BIDIRECTIONAL);
-
-               if (unlikely(pci_dma_mapping_error(hldev->pdev,
-                               dma_addr))) {
-
-                       vxge_os_dma_free(hldev->pdev, memblock, &acc_handle);
-                       __vxge_hw_blockpool_destroy(blockpool);
-                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
-                       goto blockpool_create_exit;
-               }
-
-               if (!list_empty(&blockpool->free_entry_list))
-                       entry = (struct __vxge_hw_blockpool_entry *)
-                               list_first_entry(&blockpool->free_entry_list,
-                                       struct __vxge_hw_blockpool_entry,
-                                       item);
-
-               if (entry == NULL)
-                       entry =
-                           kzalloc(sizeof(struct __vxge_hw_blockpool_entry),
-                                       GFP_KERNEL);
-               if (entry != NULL) {
-                       list_del(&entry->item);
-                       entry->length = VXGE_HW_BLOCK_SIZE;
-                       entry->memblock = memblock;
-                       entry->dma_addr = dma_addr;
-                       entry->acc_handle = acc_handle;
-                       entry->dma_handle = dma_handle;
-                       list_add(&entry->item,
-                                         &blockpool->free_block_list);
-                       blockpool->pool_size++;
-               } else {
-                       __vxge_hw_blockpool_destroy(blockpool);
-                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
-                       goto blockpool_create_exit;
-               }
-       }
-
-blockpool_create_exit:
-       return status;
-}
-
-/*
- * __vxge_hw_blockpool_destroy - Deallocates the block pool
- */
-
-void __vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool *blockpool)
-{
-
-       struct __vxge_hw_device *hldev;
-       struct list_head *p, *n;
-       u16 ret;
-
-       if (blockpool == NULL) {
-               ret = 1;
-               goto exit;
-       }
-
-       hldev = blockpool->hldev;
-
-       list_for_each_safe(p, n, &blockpool->free_block_list) {
-
-               pci_unmap_single(hldev->pdev,
-                       ((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
-                       ((struct __vxge_hw_blockpool_entry *)p)->length,
-                       PCI_DMA_BIDIRECTIONAL);
-
-               vxge_os_dma_free(hldev->pdev,
-                       ((struct __vxge_hw_blockpool_entry *)p)->memblock,
-                       &((struct __vxge_hw_blockpool_entry *) p)->acc_handle);
-
-               list_del(
-                       &((struct __vxge_hw_blockpool_entry *)p)->item);
-               kfree(p);
-               blockpool->pool_size--;
-       }
-
-       list_for_each_safe(p, n, &blockpool->free_entry_list) {
-               list_del(
-                       &((struct __vxge_hw_blockpool_entry *)p)->item);
-               kfree((void *)p);
-       }
-       ret = 0;
-exit:
-       return;
-}
-
-/*
- * __vxge_hw_blockpool_blocks_add - Request additional blocks
- */
-static
-void __vxge_hw_blockpool_blocks_add(struct __vxge_hw_blockpool *blockpool)
-{
-       u32 nreq = 0, i;
-
-       if ((blockpool->pool_size  +  blockpool->req_out) <
-               VXGE_HW_MIN_DMA_BLOCK_POOL_SIZE) {
-               nreq = VXGE_HW_INCR_DMA_BLOCK_POOL_SIZE;
-               blockpool->req_out += nreq;
-       }
-
-       for (i = 0; i < nreq; i++)
-               vxge_os_dma_malloc_async(
-                       ((struct __vxge_hw_device *)blockpool->hldev)->pdev,
-                       blockpool->hldev, VXGE_HW_BLOCK_SIZE);
-}
-
-/*
- * __vxge_hw_blockpool_blocks_remove - Free additional blocks
- */
-static
-void __vxge_hw_blockpool_blocks_remove(struct __vxge_hw_blockpool *blockpool)
-{
-       struct list_head *p, *n;
-
-       list_for_each_safe(p, n, &blockpool->free_block_list) {
-
-               if (blockpool->pool_size < blockpool->pool_max)
-                       break;
-
-               pci_unmap_single(
-                       ((struct __vxge_hw_device *)blockpool->hldev)->pdev,
-                       ((struct __vxge_hw_blockpool_entry *)p)->dma_addr,
-                       ((struct __vxge_hw_blockpool_entry *)p)->length,
-                       PCI_DMA_BIDIRECTIONAL);
-
-               vxge_os_dma_free(
-                       ((struct __vxge_hw_device *)blockpool->hldev)->pdev,
-                       ((struct __vxge_hw_blockpool_entry *)p)->memblock,
-                       &((struct __vxge_hw_blockpool_entry *)p)->acc_handle);
-
-               list_del(&((struct __vxge_hw_blockpool_entry *)p)->item);
-
-               list_add(p, &blockpool->free_entry_list);
-
-               blockpool->pool_size--;
-
-       }
-}
-
-/*
- * vxge_hw_blockpool_block_add - callback for vxge_os_dma_malloc_async
- * Adds a block to block pool
- */
-void vxge_hw_blockpool_block_add(
-                       struct __vxge_hw_device *devh,
-                       void *block_addr,
-                       u32 length,
-                       struct pci_dev *dma_h,
-                       struct pci_dev *acc_handle)
-{
-       struct __vxge_hw_blockpool  *blockpool;
-       struct __vxge_hw_blockpool_entry  *entry = NULL;
-       dma_addr_t dma_addr;
-       enum vxge_hw_status status = VXGE_HW_OK;
-       u32 req_out;
-
-       blockpool = &devh->block_pool;
-
-       if (block_addr == NULL) {
-               blockpool->req_out--;
-               status = VXGE_HW_FAIL;
-               goto exit;
-       }
-
-       dma_addr = pci_map_single(devh->pdev, block_addr, length,
-                               PCI_DMA_BIDIRECTIONAL);
-
-       if (unlikely(pci_dma_mapping_error(devh->pdev, dma_addr))) {
-
-               vxge_os_dma_free(devh->pdev, block_addr, &acc_handle);
-               blockpool->req_out--;
-               status = VXGE_HW_FAIL;
-               goto exit;
-       }
-
-
-       if (!list_empty(&blockpool->free_entry_list))
-               entry = (struct __vxge_hw_blockpool_entry *)
-                       list_first_entry(&blockpool->free_entry_list,
-                               struct __vxge_hw_blockpool_entry,
-                               item);
-
-       if (entry == NULL)
-               entry = (struct __vxge_hw_blockpool_entry *)
-                       vmalloc(sizeof(struct __vxge_hw_blockpool_entry));
-       else
-               list_del(&entry->item);
-
-       if (entry != NULL) {
-               entry->length = length;
-               entry->memblock = block_addr;
-               entry->dma_addr = dma_addr;
-               entry->acc_handle = acc_handle;
-               entry->dma_handle = dma_h;
-               list_add(&entry->item, &blockpool->free_block_list);
-               blockpool->pool_size++;
-               status = VXGE_HW_OK;
-       } else
-               status = VXGE_HW_ERR_OUT_OF_MEMORY;
-
-       blockpool->req_out--;
-
-       req_out = blockpool->req_out;
-exit:
-       return;
-}
-
-/*
- * __vxge_hw_blockpool_malloc - Allocate a memory block from pool
- * Allocates a block of memory of given size, either from block pool
- * or by calling vxge_os_dma_malloc()
- */
-void *
-__vxge_hw_blockpool_malloc(struct __vxge_hw_device *devh, u32 size,
-                               struct vxge_hw_mempool_dma *dma_object)
-{
-       struct __vxge_hw_blockpool_entry *entry = NULL;
-       struct __vxge_hw_blockpool  *blockpool;
-       void *memblock = NULL;
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       blockpool = &devh->block_pool;
-
-       if (size != blockpool->block_size) {
-
-               memblock = vxge_os_dma_malloc(devh->pdev, size,
-                                               &dma_object->handle,
-                                               &dma_object->acc_handle);
-
-               if (memblock == NULL) {
-                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
-                       goto exit;
-               }
-
-               dma_object->addr = pci_map_single(devh->pdev, memblock, size,
-                                       PCI_DMA_BIDIRECTIONAL);
-
-               if (unlikely(pci_dma_mapping_error(devh->pdev,
-                               dma_object->addr))) {
-                       vxge_os_dma_free(devh->pdev, memblock,
-                               &dma_object->acc_handle);
-                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
-                       goto exit;
-               }
-
-       } else {
-
-               if (!list_empty(&blockpool->free_block_list))
-                       entry = (struct __vxge_hw_blockpool_entry *)
-                               list_first_entry(&blockpool->free_block_list,
-                                       struct __vxge_hw_blockpool_entry,
-                                       item);
-
-               if (entry != NULL) {
-                       list_del(&entry->item);
-                       dma_object->addr = entry->dma_addr;
-                       dma_object->handle = entry->dma_handle;
-                       dma_object->acc_handle = entry->acc_handle;
-                       memblock = entry->memblock;
-
-                       list_add(&entry->item,
-                               &blockpool->free_entry_list);
-                       blockpool->pool_size--;
-               }
-
-               if (memblock != NULL)
-                       __vxge_hw_blockpool_blocks_add(blockpool);
-       }
-exit:
-       return memblock;
-}
-
-/*
- * __vxge_hw_blockpool_free - Frees the memory allcoated with
-                               __vxge_hw_blockpool_malloc
- */
-void
-__vxge_hw_blockpool_free(struct __vxge_hw_device *devh,
-                       void *memblock, u32 size,
-                       struct vxge_hw_mempool_dma *dma_object)
-{
-       struct __vxge_hw_blockpool_entry *entry = NULL;
-       struct __vxge_hw_blockpool  *blockpool;
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       blockpool = &devh->block_pool;
-
-       if (size != blockpool->block_size) {
-               pci_unmap_single(devh->pdev, dma_object->addr, size,
-                       PCI_DMA_BIDIRECTIONAL);
-               vxge_os_dma_free(devh->pdev, memblock, &dma_object->acc_handle);
-       } else {
-
-               if (!list_empty(&blockpool->free_entry_list))
-                       entry = (struct __vxge_hw_blockpool_entry *)
-                               list_first_entry(&blockpool->free_entry_list,
-                                       struct __vxge_hw_blockpool_entry,
-                                       item);
-
-               if (entry == NULL)
-                       entry = (struct __vxge_hw_blockpool_entry *)
-                               vmalloc(sizeof(
-                                       struct __vxge_hw_blockpool_entry));
-               else
-                       list_del(&entry->item);
-
-               if (entry != NULL) {
-                       entry->length = size;
-                       entry->memblock = memblock;
-                       entry->dma_addr = dma_object->addr;
-                       entry->acc_handle = dma_object->acc_handle;
-                       entry->dma_handle = dma_object->handle;
-                       list_add(&entry->item,
-                                       &blockpool->free_block_list);
-                       blockpool->pool_size++;
-                       status = VXGE_HW_OK;
-               } else
-                       status = VXGE_HW_ERR_OUT_OF_MEMORY;
-
-               if (status == VXGE_HW_OK)
-                       __vxge_hw_blockpool_blocks_remove(blockpool);
-       }
-}
-
-/*
- * __vxge_hw_blockpool_block_allocate - Allocates a block from block pool
- * This function allocates a block from block pool or from the system
- */
-struct __vxge_hw_blockpool_entry *
-__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *devh, u32 size)
-{
-       struct __vxge_hw_blockpool_entry *entry = NULL;
-       struct __vxge_hw_blockpool  *blockpool;
-
-       blockpool = &devh->block_pool;
-
-       if (size == blockpool->block_size) {
-
-               if (!list_empty(&blockpool->free_block_list))
-                       entry = (struct __vxge_hw_blockpool_entry *)
-                               list_first_entry(&blockpool->free_block_list,
-                                       struct __vxge_hw_blockpool_entry,
-                                       item);
-
-               if (entry != NULL) {
-                       list_del(&entry->item);
-                       blockpool->pool_size--;
-               }
-       }
-
-       if (entry != NULL)
-               __vxge_hw_blockpool_blocks_add(blockpool);
-
-       return entry;
-}
-
-/*
- * __vxge_hw_blockpool_block_free - Frees a block from block pool
- * @devh: Hal device
- * @entry: Entry of block to be freed
- *
- * This function frees a block from block pool
- */
-void
-__vxge_hw_blockpool_block_free(struct __vxge_hw_device *devh,
-                       struct __vxge_hw_blockpool_entry *entry)
-{
-       struct __vxge_hw_blockpool  *blockpool;
-
-       blockpool = &devh->block_pool;
-
-       if (entry->length == blockpool->block_size) {
-               list_add(&entry->item, &blockpool->free_block_list);
-               blockpool->pool_size++;
-       }
-
-       __vxge_hw_blockpool_blocks_remove(blockpool);
-}
diff --git a/drivers/net/vxge/vxge-config.h b/drivers/net/vxge/vxge-config.h
index 252969c..94c809c 100644
--- a/drivers/net/vxge/vxge-config.h
+++ b/drivers/net/vxge/vxge-config.h
@@ -868,15 +868,6 @@ struct vxge_hw_device_attr {
                return status;                                          \
 }

-#define VXGE_HW_VPATH_STATS_PIO_READ(offset) {                         \
-       status = __vxge_hw_vpath_stats_access(vpath, \
-                       VXGE_HW_STATS_OP_READ, \
-                       offset, \
-                       &val64);                                        \
-       if (status != VXGE_HW_OK)                                       \
-               return status;                                          \
-}
-
 /*
  * struct __vxge_hw_ring - Ring channel.
  * @channel: Channel "base" of this ring, the common part of all HW
@@ -1455,9 +1446,6 @@ struct vxge_hw_rth_hash_types {
           hash_type_ipv6ex_en:1;
 };

-u32
-vxge_hw_device_debug_mask_get(struct __vxge_hw_device *devh);
-
 void vxge_hw_device_debug_set(
        struct __vxge_hw_device *devh,
        enum vxge_debug_level level,
@@ -1469,9 +1457,6 @@ vxge_hw_device_error_level_get(struct __vxge_hw_device *devh);
 u32
 vxge_hw_device_trace_level_get(struct __vxge_hw_device *devh);

-u32
-vxge_hw_device_debug_mask_get(struct __vxge_hw_device *devh);
-
 /**
  * vxge_hw_ring_rxd_size_get   - Get the size of ring descriptor.
  * @buf_mode: Buffer mode (1, 3 or 5)
@@ -1846,44 +1831,6 @@ struct vxge_hw_vpath_attr {
        struct vxge_hw_fifo_attr        fifo_attr;
 };

-enum vxge_hw_status
-__vxge_hw_blockpool_create(struct __vxge_hw_device *hldev,
-                       struct __vxge_hw_blockpool  *blockpool,
-                       u32 pool_size,
-                       u32 pool_max);
-
-void
-__vxge_hw_blockpool_destroy(struct __vxge_hw_blockpool  *blockpool);
-
-struct __vxge_hw_blockpool_entry *
-__vxge_hw_blockpool_block_allocate(struct __vxge_hw_device *hldev,
-                       u32 size);
-
-void
-__vxge_hw_blockpool_block_free(struct __vxge_hw_device *hldev,
-                       struct __vxge_hw_blockpool_entry *entry);
-
-void *
-__vxge_hw_blockpool_malloc(struct __vxge_hw_device *hldev,
-                       u32 size,
-                       struct vxge_hw_mempool_dma *dma_object);
-
-void
-__vxge_hw_blockpool_free(struct __vxge_hw_device *hldev,
-                       void *memblock,
-                       u32 size,
-                       struct vxge_hw_mempool_dma *dma_object);
-
-enum vxge_hw_status
-__vxge_hw_device_fifo_config_check(struct vxge_hw_fifo_config *fifo_config);
-
-enum vxge_hw_status
-__vxge_hw_device_config_check(struct vxge_hw_device_config *new_config);
-
-enum vxge_hw_status
-vxge_hw_mgmt_device_config(struct __vxge_hw_device *devh,
-               struct vxge_hw_device_config    *dev_config, int size);
-
 enum vxge_hw_status __devinit vxge_hw_device_hw_info_get(
        void __iomem *bar0,
        struct vxge_hw_device_hw_info *hw_info);
@@ -1971,29 +1918,6 @@ out:
        return vaddr;
 }

-extern void vxge_hw_blockpool_block_add(
-                       struct __vxge_hw_device *devh,
-                       void *block_addr,
-                       u32 length,
-                       struct pci_dev *dma_h,
-                       struct pci_dev *acc_handle);
-
-static inline void vxge_os_dma_malloc_async(struct pci_dev *pdev, void *devh,
-                                       unsigned long size)
-{
-       gfp_t flags;
-       void *vaddr;
-
-       if (in_interrupt())
-               flags = GFP_ATOMIC | GFP_DMA;
-       else
-               flags = GFP_KERNEL | GFP_DMA;
-
-       vaddr = kmalloc((size), flags);
-
-       vxge_hw_blockpool_block_add(devh, vaddr, size, pdev, pdev);
-}
-
 static inline void vxge_os_dma_free(struct pci_dev *pdev, const void *vaddr,
                        struct pci_dev **p_dma_acch)
 {
@@ -2027,40 +1951,6 @@ __vxge_hw_mempool_item_priv(
                            (*memblock_item_idx) * mempool->items_priv_size;
 }

-enum vxge_hw_status
-__vxge_hw_mempool_grow(
-       struct vxge_hw_mempool *mempool,
-       u32 num_allocate,
-       u32 *num_allocated);
-
-struct vxge_hw_mempool*
-__vxge_hw_mempool_create(
-       struct __vxge_hw_device *devh,
-       u32 memblock_size,
-       u32 item_size,
-       u32 private_size,
-       u32 items_initial,
-       u32 items_max,
-       struct vxge_hw_mempool_cbs *mp_callback,
-       void *userdata);
-
-struct __vxge_hw_channel*
-__vxge_hw_channel_allocate(struct __vxge_hw_vpath_handle *vph,
-                       enum __vxge_hw_channel_type type, u32 length,
-                       u32 per_dtr_space, void *userdata);
-
-void
-__vxge_hw_channel_free(
-       struct __vxge_hw_channel *channel);
-
-enum vxge_hw_status
-__vxge_hw_channel_initialize(
-       struct __vxge_hw_channel *channel);
-
-enum vxge_hw_status
-__vxge_hw_channel_reset(
-       struct __vxge_hw_channel *channel);
-
 /*
  * __vxge_hw_fifo_txdl_priv - Return the max fragments allocated
  * for the fifo.
@@ -2082,9 +1972,6 @@ enum vxge_hw_status vxge_hw_vpath_open(
        struct vxge_hw_vpath_attr *attr,
        struct __vxge_hw_vpath_handle **vpath_handle);

-enum vxge_hw_status
-__vxge_hw_device_vpath_reset_in_prog_check(u64 __iomem *vpath_rst_in_prog);
-
 enum vxge_hw_status vxge_hw_vpath_close(
        struct __vxge_hw_vpath_handle *vpath_handle);

@@ -2106,55 +1993,9 @@ enum vxge_hw_status vxge_hw_vpath_mtu_set(
        struct __vxge_hw_vpath_handle *vpath_handle,
        u32 new_mtu);

-enum vxge_hw_status vxge_hw_vpath_stats_enable(
-       struct __vxge_hw_vpath_handle *vpath_handle);
-
-enum vxge_hw_status
-__vxge_hw_vpath_stats_access(
-       struct __vxge_hw_virtualpath    *vpath,
-       u32                     operation,
-       u32                     offset,
-       u64                     *stat);
-
-enum vxge_hw_status
-__vxge_hw_vpath_xmac_tx_stats_get(
-       struct __vxge_hw_virtualpath    *vpath,
-       struct vxge_hw_xmac_vpath_tx_stats *vpath_tx_stats);
-
-enum vxge_hw_status
-__vxge_hw_vpath_xmac_rx_stats_get(
-       struct __vxge_hw_virtualpath    *vpath,
-       struct vxge_hw_xmac_vpath_rx_stats *vpath_rx_stats);
-
-enum vxge_hw_status
-__vxge_hw_vpath_stats_get(
-       struct __vxge_hw_virtualpath *vpath,
-       struct vxge_hw_vpath_stats_hw_info *hw_stats);
-
 void
 vxge_hw_vpath_rx_doorbell_init(struct __vxge_hw_vpath_handle *vp);

-enum vxge_hw_status
-__vxge_hw_device_vpath_config_check(struct vxge_hw_vp_config *vp_config);
-
-void
-__vxge_hw_device_pci_e_init(struct __vxge_hw_device *hldev);
-
-enum vxge_hw_status
-__vxge_hw_legacy_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg);
-
-enum vxge_hw_status
-__vxge_hw_vpath_swapper_set(struct vxge_hw_vpath_reg __iomem *vpath_reg);
-
-enum vxge_hw_status
-__vxge_hw_kdfc_swapper_set(struct vxge_hw_legacy_reg __iomem *legacy_reg,
-       struct vxge_hw_vpath_reg __iomem *vpath_reg);
-
-enum vxge_hw_status
-__vxge_hw_device_register_poll(
-       void __iomem    *reg,
-       u64 mask, u32 max_millis);
-
 #ifndef readq
 static inline u64 readq(void __iomem *addr)
 {
@@ -2185,44 +2026,10 @@ static inline void __vxge_hw_pio_mem_write32_lower(u32 val, void __iomem *addr)
        writel(val, addr);
 }

-static inline enum vxge_hw_status
-__vxge_hw_pio_mem_write64(u64 val64, void __iomem *addr,
-                         u64 mask, u32 max_millis)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       __vxge_hw_pio_mem_write32_lower((u32)vxge_bVALn(val64, 32, 32), addr);
-       wmb();
-       __vxge_hw_pio_mem_write32_upper((u32)vxge_bVALn(val64, 0, 32), addr);
-       wmb();
-
-       status = __vxge_hw_device_register_poll(addr, mask, max_millis);
-       return status;
-}
-
-struct vxge_hw_toc_reg __iomem *
-__vxge_hw_device_toc_get(void __iomem *bar0);
-
-enum vxge_hw_status
-__vxge_hw_device_reg_addr_get(struct __vxge_hw_device *hldev);
-
 enum vxge_hw_status
 vxge_hw_device_flick_link_led(struct __vxge_hw_device *devh, u64 on_off);

 enum vxge_hw_status
-__vxge_hw_device_initialize(struct __vxge_hw_device *hldev);
-
-enum vxge_hw_status
-__vxge_hw_vpath_pci_read(
-       struct __vxge_hw_virtualpath    *vpath,
-       u32                     phy_func_0,
-       u32                     offset,
-       u32                     *val);
-
-enum vxge_hw_status
-__vxge_hw_vpath_reset_check(struct __vxge_hw_virtualpath *vpath);
-
-enum vxge_hw_status
 vxge_hw_vpath_strip_fcs_check(struct __vxge_hw_device *hldev, u64 vpath_mask);

 /**
diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
index c5ab375..7e026e9 100644
--- a/drivers/net/vxge/vxge-ethtool.c
+++ b/drivers/net/vxge/vxge-ethtool.c
@@ -1193,7 +1193,7 @@ static const struct ethtool_ops vxge_ethtool_ops = {
        .flash_device           = vxge_fw_flash,
 };

-void initialize_ethtool_ops(struct net_device *ndev)
+void vxge_initialize_ethtool_ops(struct net_device *ndev)
 {
        SET_ETHTOOL_OPS(ndev, &vxge_ethtool_ops);
 }
diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
index c014b26..47bb914 100644
--- a/drivers/net/vxge/vxge-main.c
+++ b/drivers/net/vxge/vxge-main.c
@@ -140,8 +140,7 @@ static inline void VXGE_COMPLETE_ALL_RX(struct vxgedev *vdev)
  * This function is called during interrupt context to notify link up state
  * change.
  */
-void
-vxge_callback_link_up(struct __vxge_hw_device *hldev)
+static void vxge_callback_link_up(struct __vxge_hw_device *hldev)
 {
        struct net_device *dev = hldev->ndev;
        struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
@@ -164,8 +163,7 @@ vxge_callback_link_up(struct __vxge_hw_device *hldev)
  * This function is called during interrupt context to notify link down state
  * change.
  */
-void
-vxge_callback_link_down(struct __vxge_hw_device *hldev)
+static void vxge_callback_link_down(struct __vxge_hw_device *hldev)
 {
        struct net_device *dev = hldev->ndev;
        struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
@@ -356,7 +354,7 @@ static inline void vxge_post(int *dtr_cnt, void **first_dtr,
  * If the interrupt is because of a received frame or if the receive ring
  * contains fresh as yet un-processed frames, this function is called.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
                 u8 t_code, void *userdata)
 {
@@ -550,7 +548,7 @@ vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
  * freed and frees all skbs whose data have already DMA'ed into the NICs
  * internal memory.
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
                enum vxge_hw_fifo_tcode t_code, void *userdata,
                struct sk_buff ***skb_ptr, int nr_skb, int *more)
@@ -669,6 +667,65 @@ static enum vxge_hw_status vxge_search_mac_addr_in_list(
        return FALSE;
 }

+static int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
+{
+       struct vxge_mac_addrs *new_mac_entry;
+       u8 *mac_address = NULL;
+
+       if (vpath->mac_addr_cnt >= VXGE_MAX_LEARN_MAC_ADDR_CNT)
+               return TRUE;
+
+       new_mac_entry = kzalloc(sizeof(struct vxge_mac_addrs), GFP_ATOMIC);
+       if (!new_mac_entry) {
+               vxge_debug_mem(VXGE_ERR,
+                       "%s: memory allocation failed",
+                       VXGE_DRIVER_NAME);
+               return FALSE;
+       }
+
+       list_add(&new_mac_entry->item, &vpath->mac_addr_list);
+
+       /* Copy the new mac address to the list */
+       mac_address = (u8 *)&new_mac_entry->macaddr;
+       memcpy(mac_address, mac->macaddr, ETH_ALEN);
+
+       new_mac_entry->state = mac->state;
+       vpath->mac_addr_cnt++;
+
+       /* Is this a multicast address */
+       if (0x01 & mac->macaddr[0])
+               vpath->mcast_addr_cnt++;
+
+       return TRUE;
+}
+
+/* Add a mac address to DA table */
+static enum vxge_hw_status
+vxge_add_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct vxge_vpath *vpath;
+       enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode;
+
+       if (0x01 & mac->macaddr[0]) /* multicast address */
+               duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE;
+       else
+               duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_REPLACE_DUPLICATE;
+
+       vpath = &vdev->vpaths[mac->vpath_no];
+       status = vxge_hw_vpath_mac_addr_add(vpath->handle, mac->macaddr,
+                                               mac->macmask, duplicate_mode);
+       if (status != VXGE_HW_OK) {
+               vxge_debug_init(VXGE_ERR,
+                       "DA config add entry failed for vpath:%d",
+                       vpath->device_id);
+       } else
+               if (FALSE == vxge_mac_list_add(vpath, mac))
+                       status = -EPERM;
+
+       return status;
+}
+
 static int vxge_learn_mac(struct vxgedev *vdev, u8 *mac_header)
 {
        struct macInfo mac_info;
@@ -1014,6 +1071,50 @@ vxge_tx_term(void *dtrh, enum vxge_hw_txdl_state state, void *userdata)
                "%s:%d  Exiting...", __func__, __LINE__);
 }

+static int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
+{
+       struct list_head *entry, *next;
+       u64 del_mac = 0;
+       u8 *mac_address = (u8 *) (&del_mac);
+
+       /* Copy the mac address to delete from the list */
+       memcpy(mac_address, mac->macaddr, ETH_ALEN);
+
+       list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+               if (((struct vxge_mac_addrs *)entry)->macaddr == del_mac) {
+                       list_del(entry);
+                       kfree((struct vxge_mac_addrs *)entry);
+                       vpath->mac_addr_cnt--;
+
+                       /* Is this a multicast address */
+                       if (0x01 & mac->macaddr[0])
+                               vpath->mcast_addr_cnt--;
+                       return TRUE;
+               }
+       }
+
+       return FALSE;
+}
+
+/* delete a mac address from DA table */
+static enum vxge_hw_status
+vxge_del_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct vxge_vpath *vpath;
+
+       vpath = &vdev->vpaths[mac->vpath_no];
+       status = vxge_hw_vpath_mac_addr_delete(vpath->handle, mac->macaddr,
+                                               mac->macmask);
+       if (status != VXGE_HW_OK) {
+               vxge_debug_init(VXGE_ERR,
+                       "DA config delete entry failed for vpath:%d",
+                       vpath->device_id);
+       } else
+               vxge_mac_list_del(vpath, mac);
+       return status;
+}
+
 /**
  * vxge_set_multicast
  * @dev: pointer to the device structure
@@ -1265,7 +1366,7 @@ static int vxge_set_mac_addr(struct net_device *dev, void *p)
  *
  * Enables the interrupts for the vpath
 */
-void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
+static void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
 {
        struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
        int msix_id = 0;
@@ -1298,7 +1399,7 @@ void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id)
  *
  * Disables the interrupts for the vpath
 */
-void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
+static void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
 {
        struct vxge_vpath *vpath = &vdev->vpaths[vp_id];
        struct __vxge_hw_device *hldev;
@@ -1324,6 +1425,97 @@ void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id)
        }
 }

+/* list all mac addresses from DA table */
+static enum vxge_hw_status
+vxge_search_mac_addr_in_da_table(struct vxge_vpath *vpath, struct macInfo *mac)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+       unsigned char macmask[ETH_ALEN];
+       unsigned char macaddr[ETH_ALEN];
+
+       status = vxge_hw_vpath_mac_addr_get(vpath->handle,
+                               macaddr, macmask);
+       if (status != VXGE_HW_OK) {
+               vxge_debug_init(VXGE_ERR,
+                       "DA config list entry failed for vpath:%d",
+                       vpath->device_id);
+               return status;
+       }
+
+       while (memcmp(mac->macaddr, macaddr, ETH_ALEN)) {
+
+               status = vxge_hw_vpath_mac_addr_get_next(vpath->handle,
+                               macaddr, macmask);
+               if (status != VXGE_HW_OK)
+                       break;
+       }
+
+       return status;
+}
+
+/* Store all mac addresses from the list to the DA table */
+static enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct macInfo mac_info;
+       u8 *mac_address = NULL;
+       struct list_head *entry, *next;
+
+       memset(&mac_info, 0, sizeof(struct macInfo));
+
+       if (vpath->is_open) {
+
+               list_for_each_safe(entry, next, &vpath->mac_addr_list) {
+                       mac_address =
+                               (u8 *)&
+                               ((struct vxge_mac_addrs *)entry)->macaddr;
+                       memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
+                       ((struct vxge_mac_addrs *)entry)->state =
+                               VXGE_LL_MAC_ADDR_IN_DA_TABLE;
+                       /* does this mac address already exist in da table? */
+                       status = vxge_search_mac_addr_in_da_table(vpath,
+                               &mac_info);
+                       if (status != VXGE_HW_OK) {
+                               /* Add this mac address to the DA table */
+                               status = vxge_hw_vpath_mac_addr_add(
+                                       vpath->handle, mac_info.macaddr,
+                                       mac_info.macmask,
+                                   VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE);
+                               if (status != VXGE_HW_OK) {
+                                       vxge_debug_init(VXGE_ERR,
+                                           "DA add entry failed for vpath:%d",
+                                           vpath->device_id);
+                                       ((struct vxge_mac_addrs *)entry)->state
+                                               = VXGE_LL_MAC_ADDR_IN_LIST;
+                               }
+                       }
+               }
+       }
+
+       return status;
+}
+
+/* Store all vlan ids from the list to the vid table */
+static enum vxge_hw_status
+vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
+{
+       enum vxge_hw_status status = VXGE_HW_OK;
+       struct vxgedev *vdev = vpath->vdev;
+       u16 vid;
+
+       if (vdev->vlgrp && vpath->is_open) {
+
+               for (vid = 0; vid < VLAN_N_VID; vid++) {
+                       if (!vlan_group_get_device(vdev->vlgrp, vid))
+                               continue;
+                       /* Add these vlan to the vid table */
+                       status = vxge_hw_vpath_vid_add(vpath->handle, vid);
+               }
+       }
+
+       return status;
+}
+
 /*
  * vxge_reset_vpath
  * @vdev: pointer to vdev
@@ -1578,7 +1770,7 @@ out:
  *
  * driver may reset the chip on events of serr, eccerr, etc
  */
-int vxge_reset(struct vxgedev *vdev)
+static int vxge_reset(struct vxgedev *vdev)
 {
        return do_vxge_reset(vdev, VXGE_LL_FULL_RESET);
 }
@@ -1749,197 +1941,6 @@ static enum vxge_hw_status vxge_rth_configure(struct vxgedev *vdev)
        return status;
 }

-int vxge_mac_list_add(struct vxge_vpath *vpath, struct macInfo *mac)
-{
-       struct vxge_mac_addrs *new_mac_entry;
-       u8 *mac_address = NULL;
-
-       if (vpath->mac_addr_cnt >= VXGE_MAX_LEARN_MAC_ADDR_CNT)
-               return TRUE;
-
-       new_mac_entry = kzalloc(sizeof(struct vxge_mac_addrs), GFP_ATOMIC);
-       if (!new_mac_entry) {
-               vxge_debug_mem(VXGE_ERR,
-                       "%s: memory allocation failed",
-                       VXGE_DRIVER_NAME);
-               return FALSE;
-       }
-
-       list_add(&new_mac_entry->item, &vpath->mac_addr_list);
-
-       /* Copy the new mac address to the list */
-       mac_address = (u8 *)&new_mac_entry->macaddr;
-       memcpy(mac_address, mac->macaddr, ETH_ALEN);
-
-       new_mac_entry->state = mac->state;
-       vpath->mac_addr_cnt++;
-
-       /* Is this a multicast address */
-       if (0x01 & mac->macaddr[0])
-               vpath->mcast_addr_cnt++;
-
-       return TRUE;
-}
-
-/* Add a mac address to DA table */
-enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct vxge_vpath *vpath;
-       enum vxge_hw_vpath_mac_addr_add_mode duplicate_mode;
-
-       if (0x01 & mac->macaddr[0]) /* multicast address */
-               duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE;
-       else
-               duplicate_mode = VXGE_HW_VPATH_MAC_ADDR_REPLACE_DUPLICATE;
-
-       vpath = &vdev->vpaths[mac->vpath_no];
-       status = vxge_hw_vpath_mac_addr_add(vpath->handle, mac->macaddr,
-                                               mac->macmask, duplicate_mode);
-       if (status != VXGE_HW_OK) {
-               vxge_debug_init(VXGE_ERR,
-                       "DA config add entry failed for vpath:%d",
-                       vpath->device_id);
-       } else
-               if (FALSE == vxge_mac_list_add(vpath, mac))
-                       status = -EPERM;
-
-       return status;
-}
-
-int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac)
-{
-       struct list_head *entry, *next;
-       u64 del_mac = 0;
-       u8 *mac_address = (u8 *) (&del_mac);
-
-       /* Copy the mac address to delete from the list */
-       memcpy(mac_address, mac->macaddr, ETH_ALEN);
-
-       list_for_each_safe(entry, next, &vpath->mac_addr_list) {
-               if (((struct vxge_mac_addrs *)entry)->macaddr == del_mac) {
-                       list_del(entry);
-                       kfree((struct vxge_mac_addrs *)entry);
-                       vpath->mac_addr_cnt--;
-
-                       /* Is this a multicast address */
-                       if (0x01 & mac->macaddr[0])
-                               vpath->mcast_addr_cnt--;
-                       return TRUE;
-               }
-       }
-
-       return FALSE;
-}
-/* delete a mac address from DA table */
-enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev, struct macInfo *mac)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct vxge_vpath *vpath;
-
-       vpath = &vdev->vpaths[mac->vpath_no];
-       status = vxge_hw_vpath_mac_addr_delete(vpath->handle, mac->macaddr,
-                                               mac->macmask);
-       if (status != VXGE_HW_OK) {
-               vxge_debug_init(VXGE_ERR,
-                       "DA config delete entry failed for vpath:%d",
-                       vpath->device_id);
-       } else
-               vxge_mac_list_del(vpath, mac);
-       return status;
-}
-
-/* list all mac addresses from DA table */
-enum vxge_hw_status
-static vxge_search_mac_addr_in_da_table(struct vxge_vpath *vpath,
-                                       struct macInfo *mac)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-       unsigned char macmask[ETH_ALEN];
-       unsigned char macaddr[ETH_ALEN];
-
-       status = vxge_hw_vpath_mac_addr_get(vpath->handle,
-                               macaddr, macmask);
-       if (status != VXGE_HW_OK) {
-               vxge_debug_init(VXGE_ERR,
-                       "DA config list entry failed for vpath:%d",
-                       vpath->device_id);
-               return status;
-       }
-
-       while (memcmp(mac->macaddr, macaddr, ETH_ALEN)) {
-
-               status = vxge_hw_vpath_mac_addr_get_next(vpath->handle,
-                               macaddr, macmask);
-               if (status != VXGE_HW_OK)
-                       break;
-       }
-
-       return status;
-}
-
-/* Store all vlan ids from the list to the vid table */
-enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct vxgedev *vdev = vpath->vdev;
-       u16 vid;
-
-       if (vdev->vlgrp && vpath->is_open) {
-
-               for (vid = 0; vid < VLAN_N_VID; vid++) {
-                       if (!vlan_group_get_device(vdev->vlgrp, vid))
-                               continue;
-                       /* Add these vlan to the vid table */
-                       status = vxge_hw_vpath_vid_add(vpath->handle, vid);
-               }
-       }
-
-       return status;
-}
-
-/* Store all mac addresses from the list to the DA table */
-enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath)
-{
-       enum vxge_hw_status status = VXGE_HW_OK;
-       struct macInfo mac_info;
-       u8 *mac_address = NULL;
-       struct list_head *entry, *next;
-
-       memset(&mac_info, 0, sizeof(struct macInfo));
-
-       if (vpath->is_open) {
-
-               list_for_each_safe(entry, next, &vpath->mac_addr_list) {
-                       mac_address =
-                               (u8 *)&
-                               ((struct vxge_mac_addrs *)entry)->macaddr;
-                       memcpy(mac_info.macaddr, mac_address, ETH_ALEN);
-                       ((struct vxge_mac_addrs *)entry)->state =
-                               VXGE_LL_MAC_ADDR_IN_DA_TABLE;
-                       /* does this mac address already exist in da table? */
-                       status = vxge_search_mac_addr_in_da_table(vpath,
-                               &mac_info);
-                       if (status != VXGE_HW_OK) {
-                               /* Add this mac address to the DA table */
-                               status = vxge_hw_vpath_mac_addr_add(
-                                       vpath->handle, mac_info.macaddr,
-                                       mac_info.macmask,
-                                   VXGE_HW_VPATH_MAC_ADDR_ADD_DUPLICATE);
-                               if (status != VXGE_HW_OK) {
-                                       vxge_debug_init(VXGE_ERR,
-                                           "DA add entry failed for vpath:%d",
-                                           vpath->device_id);
-                                       ((struct vxge_mac_addrs *)entry)->state
-                                               = VXGE_LL_MAC_ADDR_IN_LIST;
-                               }
-                       }
-               }
-       }
-
-       return status;
-}
-
 /* reset vpaths */
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
 {
@@ -1973,7 +1974,7 @@ enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev)
 }

 /* close vpaths */
-void vxge_close_vpaths(struct vxgedev *vdev, int index)
+static void vxge_close_vpaths(struct vxgedev *vdev, int index)
 {
        struct vxge_vpath *vpath;
        int i;
@@ -1991,7 +1992,7 @@ void vxge_close_vpaths(struct vxgedev *vdev, int index)
 }

 /* open vpaths */
-int vxge_open_vpaths(struct vxgedev *vdev)
+static int vxge_open_vpaths(struct vxgedev *vdev)
 {
        struct vxge_hw_vpath_attr attr;
        enum vxge_hw_status status;
@@ -2558,8 +2559,7 @@ static void vxge_poll_vp_lockup(unsigned long data)
  * Return value: '0' on success and an appropriate (-)ve integer as
  * defined in errno.h file on failure.
  */
-int
-vxge_open(struct net_device *dev)
+static int vxge_open(struct net_device *dev)
 {
        enum vxge_hw_status status;
        struct vxgedev *vdev;
@@ -2765,7 +2765,7 @@ out0:
 }

 /* Loop throught the mac address list and delete all the entries */
-void vxge_free_mac_add_list(struct vxge_vpath *vpath)
+static void vxge_free_mac_add_list(struct vxge_vpath *vpath)
 {

        struct list_head *entry, *next;
@@ -2789,7 +2789,7 @@ static void vxge_napi_del_all(struct vxgedev *vdev)
        }
 }

-int do_vxge_close(struct net_device *dev, int do_io)
+static int do_vxge_close(struct net_device *dev, int do_io)
 {
        enum vxge_hw_status status;
        struct vxgedev *vdev;
@@ -2904,8 +2904,7 @@ int do_vxge_close(struct net_device *dev, int do_io)
  * Return value: '0' on success and an appropriate (-)ve integer as
  * defined in errno.h file on failure.
  */
-int
-vxge_close(struct net_device *dev)
+static int vxge_close(struct net_device *dev)
 {
        do_vxge_close(dev, 1);
        return 0;
@@ -3338,7 +3337,7 @@ static int __devinit vxge_device_register(struct __vxge_hw_device *hldev,

        ndev->watchdog_timeo = VXGE_LL_WATCH_DOG_TIMEOUT;

-       initialize_ethtool_ops(ndev);
+       vxge_initialize_ethtool_ops(ndev);

        if (vdev->config.rth_steering != NO_STEERING) {
                ndev->features |= NETIF_F_RXHASH;
@@ -3429,8 +3428,7 @@ _out0:
  *
  * This function will unregister and free network device
  */
-void
-vxge_device_unregister(struct __vxge_hw_device *hldev)
+static void vxge_device_unregister(struct __vxge_hw_device *hldev)
 {
        struct vxgedev *vdev;
        struct net_device *dev;
diff --git a/drivers/net/vxge/vxge-main.h b/drivers/net/vxge/vxge-main.h
index 151f54b..994d1e0 100644
--- a/drivers/net/vxge/vxge-main.h
+++ b/drivers/net/vxge/vxge-main.h
@@ -420,61 +420,8 @@ struct vxge_tx_priv {
                mod_timer(&timer, (jiffies + exp)); \
        } while (0);

-void vxge_device_unregister(struct __vxge_hw_device *devh);
-
-void vxge_vpath_intr_enable(struct vxgedev *vdev, int vp_id);
-
-void vxge_vpath_intr_disable(struct vxgedev *vdev, int vp_id);
-
-void vxge_callback_link_up(struct __vxge_hw_device *devh);
-
-void vxge_callback_link_down(struct __vxge_hw_device *devh);
-
-enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
-       struct macInfo *mac);
-
-int vxge_mac_list_del(struct vxge_vpath *vpath, struct macInfo *mac);
-
-int vxge_reset(struct vxgedev *vdev);
-
-enum vxge_hw_status
-vxge_rx_1b_compl(struct __vxge_hw_ring *ringh, void *dtr,
-       u8 t_code, void *userdata);
-
-enum vxge_hw_status
-vxge_xmit_compl(struct __vxge_hw_fifo *fifo_hw, void *dtr,
-       enum vxge_hw_fifo_tcode t_code, void *userdata,
-       struct sk_buff ***skb_ptr, int nr_skbs, int *more);
-
-int vxge_close(struct net_device *dev);
-
-int vxge_open(struct net_device *dev);
-
-void vxge_close_vpaths(struct vxgedev *vdev, int index);
-
-int vxge_open_vpaths(struct vxgedev *vdev);
-
 enum vxge_hw_status vxge_reset_all_vpaths(struct vxgedev *vdev);
-
-enum vxge_hw_status vxge_add_mac_addr(struct vxgedev *vdev,
-       struct macInfo *mac);
-
-enum vxge_hw_status vxge_del_mac_addr(struct vxgedev *vdev,
-       struct macInfo *mac);
-
-int vxge_mac_list_add(struct vxge_vpath *vpath,
-       struct macInfo *mac);
-
-void vxge_free_mac_add_list(struct vxge_vpath *vpath);
-
-enum vxge_hw_status vxge_restore_vpath_mac_addr(struct vxge_vpath *vpath);
-
-enum vxge_hw_status vxge_restore_vpath_vid_table(struct vxge_vpath *vpath);
-
-int do_vxge_close(struct net_device *dev, int do_io);
-
-extern void initialize_ethtool_ops(struct net_device *ndev);
-
+void vxge_initialize_ethtool_ops(struct net_device *ndev);
 int vxge_fw_upgrade(struct vxgedev *vdev, char *fw_name, int override);

 /**
diff --git a/drivers/net/vxge/vxge-traffic.c b/drivers/net/vxge/vxge-traffic.c
index cedf08f..0fb8505 100644
--- a/drivers/net/vxge/vxge-traffic.c
+++ b/drivers/net/vxge/vxge-traffic.c
@@ -412,6 +412,384 @@ void vxge_hw_device_flush_io(struct __vxge_hw_device *hldev)
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
+                             enum vxge_hw_event type)
+{
+       switch (type) {
+       case VXGE_HW_EVENT_UNKNOWN:
+               break;
+       case VXGE_HW_EVENT_RESET_START:
+       case VXGE_HW_EVENT_RESET_COMPLETE:
+       case VXGE_HW_EVENT_LINK_DOWN:
+       case VXGE_HW_EVENT_LINK_UP:
+               goto out;
+       case VXGE_HW_EVENT_ALARM_CLEARED:
+               goto out;
+       case VXGE_HW_EVENT_ECCERR:
+       case VXGE_HW_EVENT_MRPCIM_ECCERR:
+               goto out;
+       case VXGE_HW_EVENT_FIFO_ERR:
+       case VXGE_HW_EVENT_VPATH_ERR:
+       case VXGE_HW_EVENT_CRITICAL_ERR:
+       case VXGE_HW_EVENT_SERR:
+               break;
+       case VXGE_HW_EVENT_SRPCIM_SERR:
+       case VXGE_HW_EVENT_MRPCIM_SERR:
+               goto out;
+       case VXGE_HW_EVENT_SLOT_FREEZE:
+               break;
+       default:
+               vxge_assert(0);
+               goto out;
+       }
+
+       /* notify driver */
+       if (hldev->uld_callbacks.crit_err)
+               hldev->uld_callbacks.crit_err(
+                       (struct __vxge_hw_device *)hldev,
+                       type, vp_id);
+out:
+
+       return VXGE_HW_OK;
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
+       /*
+        * If the previous link state is not down, return.
+        */
+       if (hldev->link_state == VXGE_HW_LINK_DOWN)
+               goto exit;
+
+       hldev->link_state = VXGE_HW_LINK_DOWN;
+
+       /* notify driver */
+       if (hldev->uld_callbacks.link_down)
+               hldev->uld_callbacks.link_down(hldev);
+exit:
+       return VXGE_HW_OK;
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
+       /*
+        * If the previous link state is not down, return.
+        */
+       if (hldev->link_state == VXGE_HW_LINK_UP)
+               goto exit;
+
+       hldev->link_state = VXGE_HW_LINK_UP;
+
+       /* notify driver */
+       if (hldev->uld_callbacks.link_up)
+               hldev->uld_callbacks.link_up(hldev);
+exit:
+       return VXGE_HW_OK;
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
+                             u32 skip_alarms)
+{
+       u64 val64;
+       u64 alarm_status;
+       u64 pic_status;
+       struct __vxge_hw_device *hldev = NULL;
+       enum vxge_hw_event alarm_event = VXGE_HW_EVENT_UNKNOWN;
+       u64 mask64;
+       struct vxge_hw_vpath_stats_sw_info *sw_stats;
+       struct vxge_hw_vpath_reg __iomem *vp_reg;
+
+       if (vpath == NULL) {
+               alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
+                       alarm_event);
+               goto out2;
+       }
+
+       hldev = vpath->hldev;
+       vp_reg = vpath->vp_reg;
+       alarm_status = readq(&vp_reg->vpath_general_int_status);
+
+       if (alarm_status == VXGE_HW_ALL_FOXES) {
+               alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_SLOT_FREEZE,
+                       alarm_event);
+               goto out;
+       }
+
+       sw_stats = vpath->sw_stats;
+
+       if (alarm_status & ~(
+               VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT |
+               VXGE_HW_VPATH_GENERAL_INT_STATUS_PCI_INT |
+               VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT |
+               VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT)) {
+               sw_stats->error_stats.unknown_alarms++;
+
+               alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
+                       alarm_event);
+               goto out;
+       }
+
+       if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT) {
+
+               val64 = readq(&vp_reg->xgmac_vp_int_status);
+
+               if (val64 &
+               VXGE_HW_XGMAC_VP_INT_STATUS_ASIC_NTWK_VP_ERR_ASIC_NTWK_VP_INT) {
+
+                       val64 = readq(&vp_reg->asic_ntwk_vp_err_reg);
+
+                       if (((val64 &
+                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT) &&
+                            (!(val64 &
+                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK))) ||
+                           ((val64 &
+                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR) &&
+                            (!(val64 &
+                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR)
+                                    ))) {
+                               sw_stats->error_stats.network_sustained_fault++;
+
+                               writeq(
+                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT,
+                                       &vp_reg->asic_ntwk_vp_err_mask);
+
+                               __vxge_hw_device_handle_link_down_ind(hldev);
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_LINK_DOWN, alarm_event);
+                       }
+
+                       if (((val64 &
+                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK) &&
+                            (!(val64 &
+                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT))) ||
+                           ((val64 &
+                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR) &&
+                            (!(val64 &
+                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR)
+                                    ))) {
+
+                               sw_stats->error_stats.network_sustained_ok++;
+
+                               writeq(
+                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK,
+                                       &vp_reg->asic_ntwk_vp_err_mask);
+
+                               __vxge_hw_device_handle_link_up_ind(hldev);
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_LINK_UP, alarm_event);
+                       }
+
+                       writeq(VXGE_HW_INTR_MASK_ALL,
+                               &vp_reg->asic_ntwk_vp_err_reg);
+
+                       alarm_event = VXGE_HW_SET_LEVEL(
+                               VXGE_HW_EVENT_ALARM_CLEARED, alarm_event);
+
+                       if (skip_alarms)
+                               return VXGE_HW_OK;
+               }
+       }
+
+       if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT) {
+
+               pic_status = readq(&vp_reg->vpath_ppif_int_status);
+
+               if (pic_status &
+                   VXGE_HW_VPATH_PPIF_INT_STATUS_GENERAL_ERRORS_GENERAL_INT) {
+
+                       val64 = readq(&vp_reg->general_errors_reg);
+                       mask64 = readq(&vp_reg->general_errors_mask);
+
+                       if ((val64 &
+                               VXGE_HW_GENERAL_ERRORS_REG_INI_SERR_DET) &
+                               ~mask64) {
+                               sw_stats->error_stats.ini_serr_det++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_SERR, alarm_event);
+                       }
+
+                       if ((val64 &
+                           VXGE_HW_GENERAL_ERRORS_REG_DBLGEN_FIFO0_OVRFLOW) &
+                               ~mask64) {
+                               sw_stats->error_stats.dblgen_fifo0_overflow++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_FIFO_ERR, alarm_event);
+                       }
+
+                       if ((val64 &
+                           VXGE_HW_GENERAL_ERRORS_REG_STATSB_PIF_CHAIN_ERR) &
+                               ~mask64)
+                               sw_stats->error_stats.statsb_pif_chain_error++;
+
+                       if ((val64 &
+                          VXGE_HW_GENERAL_ERRORS_REG_STATSB_DROP_TIMEOUT_REQ) &
+                               ~mask64)
+                               sw_stats->error_stats.statsb_drop_timeout++;
+
+                       if ((val64 &
+                               VXGE_HW_GENERAL_ERRORS_REG_TGT_ILLEGAL_ACCESS) &
+                               ~mask64)
+                               sw_stats->error_stats.target_illegal_access++;
+
+                       if (!skip_alarms) {
+                               writeq(VXGE_HW_INTR_MASK_ALL,
+                                       &vp_reg->general_errors_reg);
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_ALARM_CLEARED,
+                                       alarm_event);
+                       }
+               }
+
+               if (pic_status &
+                   VXGE_HW_VPATH_PPIF_INT_STATUS_KDFCCTL_ERRORS_KDFCCTL_INT) {
+
+                       val64 = readq(&vp_reg->kdfcctl_errors_reg);
+                       mask64 = readq(&vp_reg->kdfcctl_errors_mask);
+
+                       if ((val64 &
+                           VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_OVRWR) &
+                               ~mask64) {
+                               sw_stats->error_stats.kdfcctl_fifo0_overwrite++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_FIFO_ERR,
+                                       alarm_event);
+                       }
+
+                       if ((val64 &
+                           VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_POISON) &
+                               ~mask64) {
+                               sw_stats->error_stats.kdfcctl_fifo0_poison++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_FIFO_ERR,
+                                       alarm_event);
+                       }
+
+                       if ((val64 &
+                           VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_DMA_ERR) &
+                               ~mask64) {
+                               sw_stats->error_stats.kdfcctl_fifo0_dma_error++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_FIFO_ERR,
+                                       alarm_event);
+                       }
+
+                       if (!skip_alarms) {
+                               writeq(VXGE_HW_INTR_MASK_ALL,
+                                       &vp_reg->kdfcctl_errors_reg);
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_ALARM_CLEARED,
+                                       alarm_event);
+                       }
+               }
+
+       }
+
+       if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT) {
+
+               val64 = readq(&vp_reg->wrdma_alarm_status);
+
+               if (val64 & VXGE_HW_WRDMA_ALARM_STATUS_PRC_ALARM_PRC_INT) {
+
+                       val64 = readq(&vp_reg->prc_alarm_reg);
+                       mask64 = readq(&vp_reg->prc_alarm_mask);
+
+                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RING_BUMP)&
+                               ~mask64)
+                               sw_stats->error_stats.prc_ring_bumps++;
+
+                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ERR) &
+                               ~mask64) {
+                               sw_stats->error_stats.prc_rxdcm_sc_err++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_VPATH_ERR,
+                                       alarm_event);
+                       }
+
+                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ABORT)
+                               & ~mask64) {
+                               sw_stats->error_stats.prc_rxdcm_sc_abort++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                               VXGE_HW_EVENT_VPATH_ERR,
+                                               alarm_event);
+                       }
+
+                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_QUANTA_SIZE_ERR)
+                                & ~mask64) {
+                               sw_stats->error_stats.prc_quanta_size_err++;
+
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                       VXGE_HW_EVENT_VPATH_ERR,
+                                       alarm_event);
+                       }
+
+                       if (!skip_alarms) {
+                               writeq(VXGE_HW_INTR_MASK_ALL,
+                                       &vp_reg->prc_alarm_reg);
+                               alarm_event = VXGE_HW_SET_LEVEL(
+                                               VXGE_HW_EVENT_ALARM_CLEARED,
+                                               alarm_event);
+                       }
+               }
+       }
+out:
+       hldev->stats.sw_dev_err_stats.vpath_alarms++;
+out2:
+       if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
+               (alarm_event == VXGE_HW_EVENT_UNKNOWN))
+               return VXGE_HW_OK;
+
+       __vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
+
+       if (alarm_event == VXGE_HW_EVENT_SERR)
+               return VXGE_HW_ERR_CRITICAL;
+
+       return (alarm_event == VXGE_HW_EVENT_SLOT_FREEZE) ?
+               VXGE_HW_ERR_SLOT_FREEZE :
+               (alarm_event == VXGE_HW_EVENT_FIFO_ERR) ? VXGE_HW_ERR_FIFO :
+               VXGE_HW_ERR_VPATH;
+}
+
+/**
  * vxge_hw_device_begin_irq - Begin IRQ processing.
  * @hldev: HW device handle.
  * @skip_alarms: Do not clear the alarms
@@ -506,108 +884,6 @@ exit:
        return ret;
 }

-/*
- * __vxge_hw_device_handle_link_up_ind
- * @hldev: HW device handle.
- *
- * Link up indication handler. The function is invoked by HW when
- * Titan indicates that the link is up for programmable amount of time.
- */
-enum vxge_hw_status
-__vxge_hw_device_handle_link_up_ind(struct __vxge_hw_device *hldev)
-{
-       /*
-        * If the previous link state is not down, return.
-        */
-       if (hldev->link_state == VXGE_HW_LINK_UP)
-               goto exit;
-
-       hldev->link_state = VXGE_HW_LINK_UP;
-
-       /* notify driver */
-       if (hldev->uld_callbacks.link_up)
-               hldev->uld_callbacks.link_up(hldev);
-exit:
-       return VXGE_HW_OK;
-}
-
-/*
- * __vxge_hw_device_handle_link_down_ind
- * @hldev: HW device handle.
- *
- * Link down indication handler. The function is invoked by HW when
- * Titan indicates that the link is down.
- */
-enum vxge_hw_status
-__vxge_hw_device_handle_link_down_ind(struct __vxge_hw_device *hldev)
-{
-       /*
-        * If the previous link state is not down, return.
-        */
-       if (hldev->link_state == VXGE_HW_LINK_DOWN)
-               goto exit;
-
-       hldev->link_state = VXGE_HW_LINK_DOWN;
-
-       /* notify driver */
-       if (hldev->uld_callbacks.link_down)
-               hldev->uld_callbacks.link_down(hldev);
-exit:
-       return VXGE_HW_OK;
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
-enum vxge_hw_status
-__vxge_hw_device_handle_error(
-               struct __vxge_hw_device *hldev,
-               u32 vp_id,
-               enum vxge_hw_event type)
-{
-       switch (type) {
-       case VXGE_HW_EVENT_UNKNOWN:
-               break;
-       case VXGE_HW_EVENT_RESET_START:
-       case VXGE_HW_EVENT_RESET_COMPLETE:
-       case VXGE_HW_EVENT_LINK_DOWN:
-       case VXGE_HW_EVENT_LINK_UP:
-               goto out;
-       case VXGE_HW_EVENT_ALARM_CLEARED:
-               goto out;
-       case VXGE_HW_EVENT_ECCERR:
-       case VXGE_HW_EVENT_MRPCIM_ECCERR:
-               goto out;
-       case VXGE_HW_EVENT_FIFO_ERR:
-       case VXGE_HW_EVENT_VPATH_ERR:
-       case VXGE_HW_EVENT_CRITICAL_ERR:
-       case VXGE_HW_EVENT_SERR:
-               break;
-       case VXGE_HW_EVENT_SRPCIM_SERR:
-       case VXGE_HW_EVENT_MRPCIM_SERR:
-               goto out;
-       case VXGE_HW_EVENT_SLOT_FREEZE:
-               break;
-       default:
-               vxge_assert(0);
-               goto out;
-       }
-
-       /* notify driver */
-       if (hldev->uld_callbacks.crit_err)
-               hldev->uld_callbacks.crit_err(
-                       (struct __vxge_hw_device *)hldev,
-                       type, vp_id);
-out:
-
-       return VXGE_HW_OK;
-}
-
 /**
  * vxge_hw_device_clear_tx_rx - Acknowledge (that is, clear) the
  * condition that has caused the Tx and RX interrupt.
@@ -646,7 +922,7 @@ void vxge_hw_device_clear_tx_rx(struct __vxge_hw_device *hldev)
  * it swaps the reserve and free arrays.
  *
  */
-enum vxge_hw_status
+static enum vxge_hw_status
 vxge_hw_channel_dtr_alloc(struct __vxge_hw_channel *channel, void **dtrh)
 {
        void **tmp_arr;
@@ -692,7 +968,8 @@ _alloc_after_swap:
  * Posts a dtr to work array.
  *
  */
-void vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel, void *dtrh)
+static void
+vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel, void *dtrh)
 {
        vxge_assert(channel->work_arr[channel->post_index] == NULL);

@@ -1658,37 +1935,6 @@ exit:
 }

 /**
- * vxge_hw_vpath_vid_get_next - Get the next vid entry for this vpath
- *               from vlan id table.
- * @vp: Vpath handle.
- * @vid: Buffer to return vlan id
- *
- * Returns the next vlan id in the list for this vpath.
- * see also: vxge_hw_vpath_vid_get
- *
- */
-enum vxge_hw_status
-vxge_hw_vpath_vid_get_next(struct __vxge_hw_vpath_handle *vp, u64 *vid)
-{
-       u64 data;
-       enum vxge_hw_status status = VXGE_HW_OK;
-
-       if (vp == NULL) {
-               status = VXGE_HW_ERR_INVALID_HANDLE;
-               goto exit;
-       }
-
-       status = __vxge_hw_vpath_rts_table_get(vp,
-                       VXGE_HW_RTS_ACCESS_STEER_CTRL_ACTION_LIST_NEXT_ENTRY,
-                       VXGE_HW_RTS_ACCESS_STEER_CTRL_DATA_STRUCT_SEL_VID,
-                       0, vid, &data);
-
-       *vid = VXGE_HW_RTS_ACCESS_STEER_DATA0_GET_VLAN_ID(*vid);
-exit:
-       return status;
-}
-
-/**
  * vxge_hw_vpath_vid_delete - Delete the vlan id entry for this vpath
  *               to vlan id table.
  * @vp: Vpath handle.
@@ -1891,284 +2137,6 @@ exit:
 }

 /*
- * __vxge_hw_vpath_alarm_process - Process Alarms.
- * @vpath: Virtual Path.
- * @skip_alarms: Do not clear the alarms
- *
- * Process vpath alarms.
- *
- */
-enum vxge_hw_status __vxge_hw_vpath_alarm_process(
-                       struct __vxge_hw_virtualpath *vpath,
-                       u32 skip_alarms)
-{
-       u64 val64;
-       u64 alarm_status;
-       u64 pic_status;
-       struct __vxge_hw_device *hldev = NULL;
-       enum vxge_hw_event alarm_event = VXGE_HW_EVENT_UNKNOWN;
-       u64 mask64;
-       struct vxge_hw_vpath_stats_sw_info *sw_stats;
-       struct vxge_hw_vpath_reg __iomem *vp_reg;
-
-       if (vpath == NULL) {
-               alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
-                       alarm_event);
-               goto out2;
-       }
-
-       hldev = vpath->hldev;
-       vp_reg = vpath->vp_reg;
-       alarm_status = readq(&vp_reg->vpath_general_int_status);
-
-       if (alarm_status == VXGE_HW_ALL_FOXES) {
-               alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_SLOT_FREEZE,
-                       alarm_event);
-               goto out;
-       }
-
-       sw_stats = vpath->sw_stats;
-
-       if (alarm_status & ~(
-               VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT |
-               VXGE_HW_VPATH_GENERAL_INT_STATUS_PCI_INT |
-               VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT |
-               VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT)) {
-               sw_stats->error_stats.unknown_alarms++;
-
-               alarm_event = VXGE_HW_SET_LEVEL(VXGE_HW_EVENT_UNKNOWN,
-                       alarm_event);
-               goto out;
-       }
-
-       if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_XMAC_INT) {
-
-               val64 = readq(&vp_reg->xgmac_vp_int_status);
-
-               if (val64 &
-               VXGE_HW_XGMAC_VP_INT_STATUS_ASIC_NTWK_VP_ERR_ASIC_NTWK_VP_INT) {
-
-                       val64 = readq(&vp_reg->asic_ntwk_vp_err_reg);
-
-                       if (((val64 &
-                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT) &&
-                            (!(val64 &
-                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK))) ||
-                           ((val64 &
-                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR) &&
-                            (!(val64 &
-                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR)
-                                    ))) {
-                               sw_stats->error_stats.network_sustained_fault++;
-
-                               writeq(
-                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT,
-                                       &vp_reg->asic_ntwk_vp_err_mask);
-
-                               __vxge_hw_device_handle_link_down_ind(hldev);
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_LINK_DOWN, alarm_event);
-                       }
-
-                       if (((val64 &
-                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK) &&
-                            (!(val64 &
-                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT))) ||
-                           ((val64 &
-                             VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK_OCCURR) &&
-                            (!(val64 &
-                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_FLT_OCCURR)
-                                    ))) {
-
-                               sw_stats->error_stats.network_sustained_ok++;
-
-                               writeq(
-                               VXGE_HW_ASIC_NW_VP_ERR_REG_XMACJ_STN_OK,
-                                       &vp_reg->asic_ntwk_vp_err_mask);
-
-                               __vxge_hw_device_handle_link_up_ind(hldev);
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_LINK_UP, alarm_event);
-                       }
-
-                       writeq(VXGE_HW_INTR_MASK_ALL,
-                               &vp_reg->asic_ntwk_vp_err_reg);
-
-                       alarm_event = VXGE_HW_SET_LEVEL(
-                               VXGE_HW_EVENT_ALARM_CLEARED, alarm_event);
-
-                       if (skip_alarms)
-                               return VXGE_HW_OK;
-               }
-       }
-
-       if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_PIC_INT) {
-
-               pic_status = readq(&vp_reg->vpath_ppif_int_status);
-
-               if (pic_status &
-                   VXGE_HW_VPATH_PPIF_INT_STATUS_GENERAL_ERRORS_GENERAL_INT) {
-
-                       val64 = readq(&vp_reg->general_errors_reg);
-                       mask64 = readq(&vp_reg->general_errors_mask);
-
-                       if ((val64 &
-                               VXGE_HW_GENERAL_ERRORS_REG_INI_SERR_DET) &
-                               ~mask64) {
-                               sw_stats->error_stats.ini_serr_det++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_SERR, alarm_event);
-                       }
-
-                       if ((val64 &
-                           VXGE_HW_GENERAL_ERRORS_REG_DBLGEN_FIFO0_OVRFLOW) &
-                               ~mask64) {
-                               sw_stats->error_stats.dblgen_fifo0_overflow++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_FIFO_ERR, alarm_event);
-                       }
-
-                       if ((val64 &
-                           VXGE_HW_GENERAL_ERRORS_REG_STATSB_PIF_CHAIN_ERR) &
-                               ~mask64)
-                               sw_stats->error_stats.statsb_pif_chain_error++;
-
-                       if ((val64 &
-                          VXGE_HW_GENERAL_ERRORS_REG_STATSB_DROP_TIMEOUT_REQ) &
-                               ~mask64)
-                               sw_stats->error_stats.statsb_drop_timeout++;
-
-                       if ((val64 &
-                               VXGE_HW_GENERAL_ERRORS_REG_TGT_ILLEGAL_ACCESS) &
-                               ~mask64)
-                               sw_stats->error_stats.target_illegal_access++;
-
-                       if (!skip_alarms) {
-                               writeq(VXGE_HW_INTR_MASK_ALL,
-                                       &vp_reg->general_errors_reg);
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_ALARM_CLEARED,
-                                       alarm_event);
-                       }
-               }
-
-               if (pic_status &
-                   VXGE_HW_VPATH_PPIF_INT_STATUS_KDFCCTL_ERRORS_KDFCCTL_INT) {
-
-                       val64 = readq(&vp_reg->kdfcctl_errors_reg);
-                       mask64 = readq(&vp_reg->kdfcctl_errors_mask);
-
-                       if ((val64 &
-                           VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_OVRWR) &
-                               ~mask64) {
-                               sw_stats->error_stats.kdfcctl_fifo0_overwrite++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_FIFO_ERR,
-                                       alarm_event);
-                       }
-
-                       if ((val64 &
-                           VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_POISON) &
-                               ~mask64) {
-                               sw_stats->error_stats.kdfcctl_fifo0_poison++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_FIFO_ERR,
-                                       alarm_event);
-                       }
-
-                       if ((val64 &
-                           VXGE_HW_KDFCCTL_ERRORS_REG_KDFCCTL_FIFO0_DMA_ERR) &
-                               ~mask64) {
-                               sw_stats->error_stats.kdfcctl_fifo0_dma_error++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_FIFO_ERR,
-                                       alarm_event);
-                       }
-
-                       if (!skip_alarms) {
-                               writeq(VXGE_HW_INTR_MASK_ALL,
-                                       &vp_reg->kdfcctl_errors_reg);
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_ALARM_CLEARED,
-                                       alarm_event);
-                       }
-               }
-
-       }
-
-       if (alarm_status & VXGE_HW_VPATH_GENERAL_INT_STATUS_WRDMA_INT) {
-
-               val64 = readq(&vp_reg->wrdma_alarm_status);
-
-               if (val64 & VXGE_HW_WRDMA_ALARM_STATUS_PRC_ALARM_PRC_INT) {
-
-                       val64 = readq(&vp_reg->prc_alarm_reg);
-                       mask64 = readq(&vp_reg->prc_alarm_mask);
-
-                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RING_BUMP)&
-                               ~mask64)
-                               sw_stats->error_stats.prc_ring_bumps++;
-
-                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ERR) &
-                               ~mask64) {
-                               sw_stats->error_stats.prc_rxdcm_sc_err++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_VPATH_ERR,
-                                       alarm_event);
-                       }
-
-                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_RXDCM_SC_ABORT)
-                               & ~mask64) {
-                               sw_stats->error_stats.prc_rxdcm_sc_abort++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                               VXGE_HW_EVENT_VPATH_ERR,
-                                               alarm_event);
-                       }
-
-                       if ((val64 & VXGE_HW_PRC_ALARM_REG_PRC_QUANTA_SIZE_ERR)
-                                & ~mask64) {
-                               sw_stats->error_stats.prc_quanta_size_err++;
-
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                       VXGE_HW_EVENT_VPATH_ERR,
-                                       alarm_event);
-                       }
-
-                       if (!skip_alarms) {
-                               writeq(VXGE_HW_INTR_MASK_ALL,
-                                       &vp_reg->prc_alarm_reg);
-                               alarm_event = VXGE_HW_SET_LEVEL(
-                                               VXGE_HW_EVENT_ALARM_CLEARED,
-                                               alarm_event);
-                       }
-               }
-       }
-out:
-       hldev->stats.sw_dev_err_stats.vpath_alarms++;
-out2:
-       if ((alarm_event == VXGE_HW_EVENT_ALARM_CLEARED) ||
-               (alarm_event == VXGE_HW_EVENT_UNKNOWN))
-               return VXGE_HW_OK;
-
-       __vxge_hw_device_handle_error(hldev, vpath->vp_id, alarm_event);
-
-       if (alarm_event == VXGE_HW_EVENT_SERR)
-               return VXGE_HW_ERR_CRITICAL;
-
-       return (alarm_event == VXGE_HW_EVENT_SLOT_FREEZE) ?
-               VXGE_HW_ERR_SLOT_FREEZE :
-               (alarm_event == VXGE_HW_EVENT_FIFO_ERR) ? VXGE_HW_ERR_FIFO :
-               VXGE_HW_ERR_VPATH;
-}
-
-/*
  * vxge_hw_vpath_alarm_process - Process Alarms.
  * @vpath: Virtual Path.
  * @skip_alarms: Do not clear the alarms
@@ -2265,36 +2233,6 @@ vxge_hw_vpath_msix_mask(struct __vxge_hw_vpath_handle *vp, int msix_id)
 }

 /**
- * vxge_hw_vpath_msix_clear - Clear MSIX Vector.
- * @vp: Virtual Path handle.
- * @msix_id:  MSI ID
- *
- * The function clears the msix interrupt for the given msix_id
- *
- * Returns: 0,
- * Otherwise, VXGE_HW_ERR_WRONG_IRQ if the msix index is out of range
- * status.
- * See also:
- */
-void
-vxge_hw_vpath_msix_clear(struct __vxge_hw_vpath_handle *vp, int msix_id)
-{
-       struct __vxge_hw_device *hldev = vp->vpath->hldev;
-       if (hldev->config.intr_mode ==
-                       VXGE_HW_INTR_MODE_MSIX_ONE_SHOT) {
-               __vxge_hw_pio_mem_write32_upper(
-                       (u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
-                               &hldev->common_reg->
-                                       clr_msix_one_shot_vec[msix_id%4]);
-       } else {
-               __vxge_hw_pio_mem_write32_upper(
-                       (u32)vxge_bVALn(vxge_mBIT(msix_id >> 2), 0, 32),
-                               &hldev->common_reg->
-                                       clear_msix_mask_vect[msix_id%4]);
-       }
-}
-
-/**
  * vxge_hw_vpath_msix_unmask - Unmask the MSIX Vector.
  * @vp: Virtual Path handle.
  * @msix_id:  MSI ID
@@ -2316,22 +2254,6 @@ vxge_hw_vpath_msix_unmask(struct __vxge_hw_vpath_handle *vp, int msix_id)
 }

 /**
- * vxge_hw_vpath_msix_mask_all - Mask all MSIX vectors for the vpath.
- * @vp: Virtual Path handle.
- *
- * The function masks all msix interrupt for the given vpath
- *
- */
-void
-vxge_hw_vpath_msix_mask_all(struct __vxge_hw_vpath_handle *vp)
-{
-
-       __vxge_hw_pio_mem_write32_upper(
-               (u32)vxge_bVALn(vxge_mBIT(vp->vpath->vp_id), 0, 32),
-               &vp->vpath->hldev->common_reg->set_msix_mask_all_vect);
-}
-
-/**
  * vxge_hw_vpath_inta_mask_tx_rx - Mask Tx and Rx interrupts.
  * @vp: Virtual Path handle.
  *
diff --git a/drivers/net/vxge/vxge-traffic.h b/drivers/net/vxge/vxge-traffic.h
index 20fda17..35f8afc 100644
--- a/drivers/net/vxge/vxge-traffic.h
+++ b/drivers/net/vxge/vxge-traffic.h
@@ -1749,14 +1749,6 @@ vxge_hw_mrpcim_stats_access(
        u64 *stat);

 enum vxge_hw_status
-vxge_hw_device_xmac_aggr_stats_get(struct __vxge_hw_device *devh, u32 port,
-                                  struct vxge_hw_xmac_aggr_stats *aggr_stats);
-
-enum vxge_hw_status
-vxge_hw_device_xmac_port_stats_get(struct __vxge_hw_device *devh, u32 port,
-                                  struct vxge_hw_xmac_port_stats *port_stats);
-
-enum vxge_hw_status
 vxge_hw_device_xmac_stats_get(struct __vxge_hw_device *devh,
                              struct vxge_hw_xmac_stats *xmac_stats);

@@ -2089,49 +2081,6 @@ struct __vxge_hw_ring_rxd_priv {
 #endif
 };

-/* ========================= RING PRIVATE API ============================= */
-u64
-__vxge_hw_ring_first_block_address_get(
-       struct __vxge_hw_ring *ringh);
-
-enum vxge_hw_status
-__vxge_hw_ring_create(
-       struct __vxge_hw_vpath_handle *vpath_handle,
-       struct vxge_hw_ring_attr *attr);
-
-enum vxge_hw_status
-__vxge_hw_ring_abort(
-       struct __vxge_hw_ring *ringh);
-
-enum vxge_hw_status
-__vxge_hw_ring_reset(
-       struct __vxge_hw_ring *ringh);
-
-enum vxge_hw_status
-__vxge_hw_ring_delete(
-       struct __vxge_hw_vpath_handle *vpath_handle);
-
-/* ========================= FIFO PRIVATE API ============================= */
-
-struct vxge_hw_fifo_attr;
-
-enum vxge_hw_status
-__vxge_hw_fifo_create(
-       struct __vxge_hw_vpath_handle *vpath_handle,
-       struct vxge_hw_fifo_attr *attr);
-
-enum vxge_hw_status
-__vxge_hw_fifo_abort(
-       struct __vxge_hw_fifo *fifoh);
-
-enum vxge_hw_status
-__vxge_hw_fifo_reset(
-       struct __vxge_hw_fifo *ringh);
-
-enum vxge_hw_status
-__vxge_hw_fifo_delete(
-       struct __vxge_hw_vpath_handle *vpath_handle);
-
 struct vxge_hw_mempool_cbs {
        void (*item_func_alloc)(
                        struct vxge_hw_mempool *mempoolh,
@@ -2141,10 +2090,6 @@ struct vxge_hw_mempool_cbs {
                        u32                     is_last);
 };

-void
-__vxge_hw_mempool_destroy(
-       struct vxge_hw_mempool *mempool);
-
 #define VXGE_HW_VIRTUAL_PATH_HANDLE(vpath)                             \
                ((struct __vxge_hw_vpath_handle *)(vpath)->vpath_handles.next)

@@ -2167,61 +2112,10 @@ __vxge_hw_vpath_rts_table_set(
        u64                     data2);

 enum vxge_hw_status
-__vxge_hw_vpath_reset(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
-__vxge_hw_vpath_sw_reset(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
 __vxge_hw_vpath_enable(
        struct __vxge_hw_device *devh,
        u32                     vp_id);

-void
-__vxge_hw_vpath_prc_configure(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
-__vxge_hw_vpath_kdfc_configure(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
-__vxge_hw_vpath_mac_configure(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
-__vxge_hw_vpath_tim_configure(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
-__vxge_hw_vpath_initialize(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
-__vxge_hw_vp_initialize(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id,
-       struct vxge_hw_vp_config        *config);
-
-void
-__vxge_hw_vp_terminate(
-       struct __vxge_hw_device *devh,
-       u32                     vp_id);
-
-enum vxge_hw_status
-__vxge_hw_vpath_alarm_process(
-       struct __vxge_hw_virtualpath    *vpath,
-       u32                     skip_alarms);
-
 void vxge_hw_device_intr_enable(
        struct __vxge_hw_device *devh);

@@ -2293,11 +2187,6 @@ vxge_hw_vpath_vid_get(
        u64                     *vid);

 enum vxge_hw_status
-vxge_hw_vpath_vid_get_next(
-       struct __vxge_hw_vpath_handle *vpath_handle,
-       u64                     *vid);
-
-enum vxge_hw_status
 vxge_hw_vpath_vid_delete(
        struct __vxge_hw_vpath_handle *vpath_handle,
        u64                     vid);
@@ -2359,16 +2248,9 @@ vxge_hw_vpath_msix_mask(struct __vxge_hw_vpath_handle *vpath_handle,
 void vxge_hw_device_flush_io(struct __vxge_hw_device *devh);

 void
-vxge_hw_vpath_msix_clear(struct __vxge_hw_vpath_handle *vpath_handle,
-                        int msix_id);
-
-void
 vxge_hw_vpath_msix_unmask(struct __vxge_hw_vpath_handle *vpath_handle,
                          int msix_id);

-void
-vxge_hw_vpath_msix_mask_all(struct __vxge_hw_vpath_handle *vpath_handle);
-
 enum vxge_hw_status vxge_hw_vpath_intr_enable(
                                struct __vxge_hw_vpath_handle *vpath_handle);

@@ -2387,12 +2269,6 @@ vxge_hw_channel_msix_mask(struct __vxge_hw_channel *channelh, int msix_id);
 void
 vxge_hw_channel_msix_unmask(struct __vxge_hw_channel *channelh, int msix_id);

-enum vxge_hw_status
-vxge_hw_channel_dtr_alloc(struct __vxge_hw_channel *channel, void **dtrh);
-
-void
-vxge_hw_channel_dtr_post(struct __vxge_hw_channel *channel, void *dtrh);
-
 void
 vxge_hw_channel_dtr_try_complete(struct __vxge_hw_channel *channel,
                                 void **dtrh);
@@ -2408,18 +2284,4 @@ vxge_hw_channel_dtr_count(struct __vxge_hw_channel *channel);
 void
 vxge_hw_vpath_tti_ci_set(struct __vxge_hw_device *hldev, u32 vp_id);

-/* ========================== PRIVATE API ================================= */
-
-enum vxge_hw_status
-__vxge_hw_device_handle_link_up_ind(struct __vxge_hw_device *hldev);
-
-enum vxge_hw_status
-__vxge_hw_device_handle_link_down_ind(struct __vxge_hw_device *hldev);
-
-enum vxge_hw_status
-__vxge_hw_device_handle_error(
-               struct __vxge_hw_device *hldev,
-               u32 vp_id,
-               enum vxge_hw_event type);
-
 #endif

The information and any attached documents contained in this message
may be confidential and/or legally privileged.  The message is
intended solely for the addressee(s).  If you are not the intended
recipient, you are hereby notified that any use, dissemination, or
reproduction is strictly prohibited and may be unlawful.  If you are
not the intended recipient, please contact the sender immediately by
return e-mail and destroy all copies of the original message.
