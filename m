From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH rfc 5/6] block: Add rdma affinity based queue mapping
        helper
Date: Tue, 4 Apr 2017 08:33:41 +0200
Message-ID: <20170404063341.GE8978@lst.de>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me> <1491140492-25703-6-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: Sagi Grimberg <sagi@grimberg.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:50393 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751066AbdDDGdn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 4 Apr 2017 02:33:43 -0400
Content-Disposition: inline
In-Reply-To: <1491140492-25703-6-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 02, 2017 at 04:41:31PM +0300, Sagi Grimberg wrote:
> Like pci and virtio, we add a rdma helper for affinity
> spreading. This achieves optimal mq affinity assignments
> according to the underlying rdma device affinity maps.
> 
> Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
> ---
>  block/Kconfig               |  5 ++++
>  block/Makefile              |  1 +
>  block/blk-mq-rdma.c         | 56 +++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/blk-mq-rdma.h | 10 ++++++++
>  4 files changed, 72 insertions(+)
>  create mode 100644 block/blk-mq-rdma.c
>  create mode 100644 include/linux/blk-mq-rdma.h
> 
> diff --git a/block/Kconfig b/block/Kconfig
> index 89cd28f8d051..3ab42bbb06d5 100644
> --- a/block/Kconfig
> +++ b/block/Kconfig
> @@ -206,4 +206,9 @@ config BLK_MQ_VIRTIO
>  	depends on BLOCK && VIRTIO
>  	default y
>  
> +config BLK_MQ_RDMA
> +	bool
> +	depends on BLOCK && INFINIBAND
> +	default y
> +
>  source block/Kconfig.iosched
> diff --git a/block/Makefile b/block/Makefile
> index 081bb680789b..4498603dbc83 100644
> --- a/block/Makefile
> +++ b/block/Makefile
> @@ -26,6 +26,7 @@ obj-$(CONFIG_BLK_CMDLINE_PARSER)	+= cmdline-parser.o
>  obj-$(CONFIG_BLK_DEV_INTEGRITY) += bio-integrity.o blk-integrity.o t10-pi.o
>  obj-$(CONFIG_BLK_MQ_PCI)	+= blk-mq-pci.o
>  obj-$(CONFIG_BLK_MQ_VIRTIO)	+= blk-mq-virtio.o
> +obj-$(CONFIG_BLK_MQ_RDMA)	+= blk-mq-rdma.o
>  obj-$(CONFIG_BLK_DEV_ZONED)	+= blk-zoned.o
>  obj-$(CONFIG_BLK_WBT)		+= blk-wbt.o
>  obj-$(CONFIG_BLK_DEBUG_FS)	+= blk-mq-debugfs.o
> diff --git a/block/blk-mq-rdma.c b/block/blk-mq-rdma.c
> new file mode 100644
> index 000000000000..d402f7c93528
> --- /dev/null
> +++ b/block/blk-mq-rdma.c
> @@ -0,0 +1,56 @@
> +/*
> + * Copyright (c) 2017 Sagi Grimberg.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms and conditions of the GNU General Public License,
> + * version 2, as published by the Free Software Foundation.
> + *
> + * This program is distributed in the hope it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + */
> +#include <linux/blk-mq.h>
> +#include <linux/blk-mq-rdma.h>
> +#include <rdma/ib_verbs.h>
> +#include <linux/module.h>
> +#include "blk-mq.h"
> +
> +/**
> + * blk_mq_rdma_map_queues - provide a default queue mapping for rdma device
> + * @set:	tagset to provide the mapping for
> + * @dev:	rdma device associated with @set.
> + * @first_vec:	first interrupt vectors to use for queues (usually 0)
> + *
> + * This function assumes the rdma device @dev has at least as many available
> + * interrupt vetors as @set has queues.  It will then query it's affinity mask
> + * and built queue mapping that maps a queue to the CPUs that have irq affinity
> + * for the corresponding vector.
> + *
> + * In case either the driver passed a @dev with less vectors than
> + * @set->nr_hw_queues, or @dev does not provide an affinity mask for a
> + * vector, we fallback to the naive mapping.
> + */
> +int blk_mq_rdma_map_queues(struct blk_mq_tag_set *set,
> +		struct ib_device *dev, int first_vec)
> +{
> +	const struct cpumask *mask;
> +	unsigned int queue, cpu;
> +
> +	if (set->nr_hw_queues > dev->num_comp_vectors)
> +		goto fallback;

maybe print a warning here?

Otherwise looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
