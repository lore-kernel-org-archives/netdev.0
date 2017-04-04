From: Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH rfc 5/6] block: Add rdma affinity based queue mapping
 helper
Date: Tue, 4 Apr 2017 10:46:54 +0300
Message-ID: <becb84ac-7819-a207-56b1-70f16cb80e42@mellanox.com>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
 <1491140492-25703-6-git-send-email-sagi@grimberg.me>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
To: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>, <linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1491140492-25703-6-git-send-email-sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


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

shouldn't you include  <linux/kobject.h> and <linux/blkdev.h> like in 
commit 8ec2ef2b66ea2f that fixes blk-mq-pci.c ?

> +#include <linux/blk-mq.h>
> +#include <linux/blk-mq-rdma.h>
> +#include <rdma/ib_verbs.h>
> +#include <linux/module.h>
> +#include "blk-mq.h"

Is this include needed ?


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
> +
> +	for (queue = 0; queue < set->nr_hw_queues; queue++) {
> +		mask = ib_get_vector_affinity(dev, first_vec + queue);
> +		if (!mask)
> +			goto fallback;

Christoph,
we can use fallback also in the blk-mq-pci.c in case 
pci_irq_get_affinity fails, right ?

> +
> +		for_each_cpu(cpu, mask)
> +			set->mq_map[cpu] = queue;
> +	}
> +
> +	return 0;
> +fallback:
> +	return blk_mq_map_queues(set);
> +}
> +EXPORT_SYMBOL_GPL(blk_mq_rdma_map_queues);

Otherwise, Looks good.

Reviewed-by: Max Gurtovoy <maxg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
