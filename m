From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 04/23 v3] mlx4_core: add slave resource allocation
Date: Tue, 09 Feb 2010 14:44:52 +0000
Message-ID: <1265726692.2126.80.camel@achroite.uk.solarflarecom.com>
References: <49BFC313.1030901@mellanox.co.il>
	 <4B6AEDCC.8020503@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <rdreier@cisco.com>, general@lists.openfabrics.org,
	netdev@vger.kernel.org, liranl@mellanox.co.il,
	tziporet@mellanox.co.il
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48861 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754290Ab0BIOo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Feb 2010 09:44:56 -0500
In-Reply-To: <4B6AEDCC.8020503@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-04 at 17:54 +0200, Yevgeny Petrilin wrote:
> All QPs/CQs/SRQs/MPTs/MTTs are allocated from shared pools, which are owned by
> the master. In addition, all backing ICM memory for these objects is managed by
> the master.
> To allow slaves to allocate resources, ICM allocation is separated from the rest
> of the object state, which is held at the slave.
> Slaves can then reserve resource ranges and allocate ICM over the comm channel.
> 
> Signed-off-by: Liran Liss <liranl@mellanox.co.il>
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/cmd.c   |  110 +++++++++++++++++++++++++++++++++
>  drivers/net/mlx4/cq.c    |   91 +++++++++++++++++++++-------
>  drivers/net/mlx4/mlx4.h  |   27 ++++++++
>  drivers/net/mlx4/mr.c    |  125 ++++++++++++++++++++++++++++++++++----
>  drivers/net/mlx4/qp.c    |  151 +++++++++++++++++++++++++++++++++-------------
>  drivers/net/mlx4/srq.c   |   88 ++++++++++++++++++++-------
>  include/linux/mlx4/cmd.h |    2 +
>  7 files changed, 496 insertions(+), 98 deletions(-)
> 
> diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/mlx4/cmd.c
> index 9e85330..533ce77 100644
> --- a/drivers/net/mlx4/cmd.c
> +++ b/drivers/net/mlx4/cmd.c
> @@ -417,6 +417,100 @@ static int mlx4_ACCESS_MEM(struct mlx4_dev *dev, u64 master_addr,
>  					   MLX4_CMD_TIME_CLASS_A);
>  }
>  
> +static int mlx4_RESOURCE_wrapper(struct mlx4_dev *dev, int slave, struct mlx4_vhcr *vhcr,
> +						       struct mlx4_cmd_mailbox *inbox,
> +						       struct mlx4_cmd_mailbox *outbox)
> +{
> +	u32 param1 = *((u32 *) &vhcr->in_param);
> +	u32 param2 = *(((u32 *) &vhcr->in_param) + 1);
> +	int ret;
> +
> +#if 0
> +	char *res[] = {"QP", "CQ", "SRQ", "MPT", "MTT"};
> +	mlx4_warn(dev, "resource wrapper - %s (mode: %s) type:%s param1:%d param2:%d\n",
> +			vhcr->op == MLX4_CMD_ALLOC_RES ? "allocate" : "free",
> +			vhcr->op_modifier == ICM_RESERVE ? "reserve" :
> +				(vhcr->op_modifier == ICM_ALLOC ? "alloc" : "reserve+alloc"),
> +			res[vhcr->in_modifier], param1, param2);
> +#endif

Either make this really conditional or remove it.  '#if 0' is not
useful.

[...]
> diff --git a/drivers/net/mlx4/cq.c b/drivers/net/mlx4/cq.c
> index ccfe276..3fb9f7f 100644
> --- a/drivers/net/mlx4/cq.c
> +++ b/drivers/net/mlx4/cq.c
[...]
> +void mlx4_cq_free_icm(struct mlx4_dev *dev, int cqn)
> +{
> +	struct mlx4_priv *priv = mlx4_priv(dev);
> +	struct mlx4_cq_table *cq_table = &priv->cq_table;
> +	u64 in_param;
> +	int err;
> +
> +	if (mlx4_is_slave(dev)) {
> +		*((u32 *) &in_param) = cqn;
> +		*(((u32 *) &in_param) + 1) = 0;
> +		err = mlx4_cmd(dev, in_param, RES_CQ, ICM_RESERVE_AND_ALLOC,
> +						      MLX4_CMD_FREE_RES,
> +						      MLX4_CMD_TIME_CLASS_A);

This is fairly disgusting, and surely only works for one byte order.  I
think you really want:

	in_param = cqn;

[...]
> diff --git a/drivers/net/mlx4/mr.c b/drivers/net/mlx4/mr.c
> index 9e4ab0f..0db7f88 100644
> --- a/drivers/net/mlx4/mr.c
> +++ b/drivers/net/mlx4/mr.c
> @@ -178,10 +178,26 @@ static void mlx4_buddy_cleanup(struct mlx4_buddy *buddy)
>  	kfree(buddy->num_free);
>  }
>  
> -static u32 mlx4_alloc_mtt_range(struct mlx4_dev *dev, int order)
> +u32 mlx4_alloc_mtt_range(struct mlx4_dev *dev, int order)
>  {
>  	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
> +	u64 in_param;
> +	u64 out_param;
>  	u32 seg;
> +	int err;
> +
> +	if (mlx4_is_slave(dev)) {
> +		*((u32 *) &in_param) = order;
> +		*(((u32 *) &in_param) + 1) = 0;
> +		err = mlx4_cmd_imm(dev, in_param, &out_param, RES_MTT,
> +						       ICM_RESERVE_AND_ALLOC,
> +						       MLX4_CMD_ALLOC_RES,
> +						       MLX4_CMD_TIME_CLASS_A);

Again with the byte-ordering...

> +		if (err)
> +			return -1;
> +		else
> +			return out_param;
> +	}
>  
>  	seg = mlx4_buddy_alloc(&mr_table->mtt_buddy, order);
>  	if (seg == -1)
> @@ -219,16 +235,33 @@ int mlx4_mtt_init(struct mlx4_dev *dev, int npages, int page_shift,
>  }
>  EXPORT_SYMBOL_GPL(mlx4_mtt_init);
>  
> -void mlx4_mtt_cleanup(struct mlx4_dev *dev, struct mlx4_mtt *mtt)
> +void mlx4_free_mtt_range(struct mlx4_dev *dev, u32 first_seg, int order)
>  {
>  	struct mlx4_mr_table *mr_table = &mlx4_priv(dev)->mr_table;
> +	u64 in_param;
> +	int err;
> +
> +	if (mlx4_is_slave(dev)) {
> +		*((u32 *) &in_param) = first_seg;
> +		*(((u32 *) &in_param) + 1) = order;
> +		err = mlx4_cmd(dev, in_param, RES_MTT, ICM_RESERVE_AND_ALLOC,
> +						       MLX4_CMD_FREE_RES,
> +						       MLX4_CMD_TIME_CLASS_A);

and here:

		in_param = first_seg | (u64)order << 32;

[...]
> +void mlx4_mr_release(struct mlx4_dev *dev, u32 index)
> +{
> +	struct mlx4_priv *priv = mlx4_priv(dev);
> +	u64 in_param;
> +	int err;
> +
> +	if (mlx4_is_slave(dev)) {
> +		*((u32 *) &in_param) = index;
> +		*(((u32 *) &in_param) + 1) = 0;

etc. etc.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

