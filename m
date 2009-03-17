From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [net-2.6 PATCH 6/10] Neterion: New driver: Hardware init & configuration
Date: Tue, 17 Mar 2009 02:26:56 +0100
Message-ID: <87bps12b33.fsf@basil.nowhere.org>
References: <1237018885.4966.431.camel@flash>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>
To: ram.vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:48002 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753051AbZCQB3g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 21:29:36 -0400
In-Reply-To: <1237018885.4966.431.camel@flash> (Ramkrishna Vepa's message of "14 Mar 2009 00:21:44 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ramkrishna Vepa <ram.vepa@neterion.com> writes:

> +struct __hw_channel*
> +__hw_channel_allocate(
> +	struct __hw_device *hldev,
> +	struct __hw_vpath_handle *vph,
> +	enum __hw_channel_type type,
> +	u32 length,
> +	u32 alloc_work_array,
> +	u32 alloc_free_array,
> +	u32 alloc_reserve_array,
> +	u32 per_dtr_space,
> +	void *userdata)

Having so many arguments in a function is usually a clear sign that it needs
to be refactored into smaller functions.

> +	channel = (struct __hw_channel *) vmalloc(size);

You seem to use vmalloc nearly everywhere. First that has a lot of 
overhead (rounds up to pages, flushes TLBs) and also will cause more
TLB misses. It's better to avoid it when not absolutely needed.

> +	vxge_assert(channel != NULL);
> +
> +	hldev = (struct __hw_device  *)channel->devh;

That assert is pretyt pointless because you'll just get a NULL pointer
reference next. Same true all over. asserts (or rather BUG_ON) only
make sense when they check for something that's not nearly obvious
given a oops.

> +	while (next_ptr != 0) {
> +
> +		cap_id = VXGE_HW_PCI_CAP_ID((((u8 *)pci_config)  +  next_ptr));
> +
> +		switch (cap_id) {
> +
> +		case VXGE_HW_PCI_CAP_ID_PM:
> +			hldev->pci_caps.pm_cap_offset = next_ptr;

This all could be done much shorter with a table.

> +	if (VXGE_HW_PCI_CONFIG_SPACE_SIZE <= 0x100)
> +		goto exit;
> +
> +	next_ptr = 0x100;

Such magic numbers are frowned upon.

Also in general you should use the pci capabilities accessor functions
provided by the PCI layer.


> +			break;
> +		case VXGE_HW_PCI_EXT_CAP_ID_DSN:
> +			hldev->pci_e_ext_caps.dsn_cap_offset = next_ptr;
> +			break;
> +		case VXGE_HW_PCI_EXT_CAP_ID_PWR:
> +			hldev->pci_e_ext_caps.pwr_budget_cap_offset = next_ptr;
> +			break;
> +
> +		default:
> +
> +			break;
> +		}
> +
> +		next_ptr = (u16)VXGE_HW_PCI_EXT_CAP_NEXT(
> +				*(u32 *)(((u8 *)pci_config)  +  next_ptr));

Especially the patch orgies are scary. Does that really use readl() et.al.
correctly? I doubt it. Again this should use the pci layer code for this.

> +/**
> + * vxge_hw_device_private_set - Set driver context.
> + * @hldev: HW device handle.
> + * @data: pointer to driver context
> + *
> + * Use HW device to set driver context.
> + *
> + * See also: vxge_hw_device_private_get()
> + */
> +void vxge_hw_device_private_set(struct __hw_device *hldev, void *data)
> +{
> +	hldev->upper_layer_data = data;
> +}

Such wrappers are not encouraged in Linux code, which aims to do with
only necessary abstraction. Lots of occurrences.

> +
> +#ifdef VXGE_HW_INTERNAL_COMPILER_ERROR
> +
> +#pragma optimize("", off)
> +
> +#endif

That's not for gcc isn't it?

> +/*
> + * __hw_ring_block_memblock_idx - Return the memblock index
> + * @block: Virtual address of memory block
> + *
> + * This function returns the index of memory block
> + */
> +static inline u32
> +__hw_ring_block_memblock_idx(
> +	u8 (block)[VXGE_HW_BLOCK_SIZE])
> +{
> +	return (u32)*((u64 *)((u8 *)block  +
> +		VXGE_HW_RING_MEMBLOCK_IDX_OFFSET));

Is that readl/writel clean again?

In general your driver looks like it could use a pass with sparse's
__iomem checking (make V=1)

> +static enum vxge_hw_status
> +__hw_ring_mempool_item_alloc(
> +	struct vxge_hw_mempool *mempoolh,
> +	void *memblock,
> +	u32 memblock_index,
> +	struct vxge_hw_mempool_dma *dma_object,
> +	void *item,
> +	u32 index,
> +	u32 is_last,
> +	void *userdata)

Again far too many arguments.


Stopped reading for now, but that file needs a lot of work in general.

-Andi


