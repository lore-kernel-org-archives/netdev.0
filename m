From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH net-next 09/11] net/mlx5: Ethernet Datapath files
Date: Wed, 08 Apr 2015 19:01:22 -0700
Message-ID: <5525DD72.9040906@redhat.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com> <1428504685-8945-10-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47565 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753602AbbDICBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 22:01:24 -0400
In-Reply-To: <1428504685-8945-10-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2015 07:51 AM, Amir Vadai wrote:
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---
>   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   | 249 +++++++++++++++
>   drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 350 ++++++++++++++++++++++
>   drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 107 +++++++
>   3 files changed, 706 insertions(+)
>   create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
>   create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
>   create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
>

<snip>

> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
> new file mode 100644
> index 0000000..088bc42
> --- /dev/null
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
> @@ -0,0 +1,107 @@
> +/*
> + * Copyright (c) 2015, Mellanox Technologies. All rights reserved.
> + *
> + * This software is available to you under a choice of one of two
> + * licenses.  You may choose to be licensed under the terms of the GNU
> + * General Public License (GPL) Version 2, available from the file
> + * COPYING in the main directory of this source tree, or the
> + * OpenIB.org BSD license below:
> + *
> + *     Redistribution and use in source and binary forms, with or
> + *     without modification, are permitted provided that the following
> + *     conditions are met:
> + *
> + *      - Redistributions of source code must retain the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer.
> + *
> + *      - Redistributions in binary form must reproduce the above
> + *        copyright notice, this list of conditions and the following
> + *        disclaimer in the documentation and/or other materials
> + *        provided with the distribution.
> + *
> + * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
> + * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
> + * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
> + * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
> + * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
> + * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
> + * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
> + * SOFTWARE.
> + */
> +
> +#include "en.h"
> +
> +struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
> +{
> +	struct mlx5_cqwq *wq = &cq->wq;
> +	u32 ci = mlx5_cqwq_get_ci(wq);
> +	struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(wq, ci);
> +	int cqe_ownership_bit = cqe->op_own & MLX5_CQE_OWNER_MASK;
> +	int sw_ownership_val = mlx5_cqwq_get_wrap_cnt(wq) & 1;
> +
> +	if (cqe_ownership_bit != sw_ownership_val)
> +		return NULL;
> +
> +	mlx5_cqwq_pop(wq);
> +
> +	/* ensure cqe content is read after cqe ownership bit */
> +	rmb();
> +
> +	return cqe;
> +}
> +

I'm pretty sure this rmb can be a dma_rmb.
