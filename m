From: Yuval Shaia <yuval.shaia@oracle.com>
Subject: Re: [for-next V2 06/10] net/mlx5: Add interface to get reference to
 a UAR
Date: Sun, 8 Jan 2017 19:05:40 +0200
Message-ID: <20170108170539.GA6323@yuval-lap.uk.oracle.com>
References: <1483890891-8767-1-git-send-email-saeedm@mellanox.com>
 <1483890891-8767-7-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
        Eli Cohen <eli@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26121 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935490AbdAHRGC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 12:06:02 -0500
Content-Disposition: inline
In-Reply-To: <1483890891-8767-7-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 08, 2017 at 05:54:47PM +0200, Saeed Mahameed wrote:
> From: Eli Cohen <eli@mellanox.com>
> 
> A reference to a UAR is required to generate CQ or EQ doorbells. Since
> CQ or EQ doorbells can all be generated using the same UAR area without
> any effect on performance, we are just getting a reference to any
> available UAR, If one is not available we allocate it but we don't waste
> the blue flame registers it can provide and we will use them for
> subsequent allocations.
> We get a reference to such UAR and put in mlx5_priv so any kernel
> consumer can make use of it.
> 
> Signed-off-by: Eli Cohen <eli@mellanox.com>
> Reviewed-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Leon Romanovsky <leon@kernel.org>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c   | 14 ++++-------
>  drivers/net/ethernet/mellanox/mlx5/core/main.c | 22 ++++++++++++++----
>  drivers/net/ethernet/mellanox/mlx5/core/uar.c  | 32 ++++++++++++++++++++++++++
>  include/linux/mlx5/driver.h                    |  5 +++-
>  4 files changed, 59 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
> index 11a8d63..9849ee9 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
> @@ -512,7 +512,7 @@ static void init_eq_buf(struct mlx5_eq *eq)
>  
>  int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
>  		       int nent, u64 mask, const char *name,
> -		       struct mlx5_uar *uar, enum mlx5_eq_type type)
> +		       enum mlx5_eq_type type)
>  {
>  	u32 out[MLX5_ST_SZ_DW(create_eq_out)] = {0};
>  	struct mlx5_priv *priv = &dev->priv;
> @@ -556,7 +556,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
>  
>  	eqc = MLX5_ADDR_OF(create_eq_in, in, eq_context_entry);
>  	MLX5_SET(eqc, eqc, log_eq_size, ilog2(eq->nent));
> -	MLX5_SET(eqc, eqc, uar_page, uar->index);
> +	MLX5_SET(eqc, eqc, uar_page, priv->uar->index);
>  	MLX5_SET(eqc, eqc, intr, vecidx);
>  	MLX5_SET(eqc, eqc, log_page_size,
>  		 eq->buf.page_shift - MLX5_ADAPTER_PAGE_SHIFT);
> @@ -571,7 +571,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
>  	eq->eqn = MLX5_GET(create_eq_out, out, eq_number);
>  	eq->irqn = priv->msix_arr[vecidx].vector;
>  	eq->dev = dev;
> -	eq->doorbell = uar->map + MLX5_EQ_DOORBEL_OFFSET;
> +	eq->doorbell = priv->uar->map + MLX5_EQ_DOORBEL_OFFSET;
>  	err = request_irq(eq->irqn, handler, 0,
>  			  priv->irq_info[vecidx].name, eq);
>  	if (err)
> @@ -686,8 +686,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
>  
>  	err = mlx5_create_map_eq(dev, &table->cmd_eq, MLX5_EQ_VEC_CMD,
>  				 MLX5_NUM_CMD_EQE, 1ull << MLX5_EVENT_TYPE_CMD,
> -				 "mlx5_cmd_eq", &dev->priv.bfregi.uars[0],
> -				 MLX5_EQ_TYPE_ASYNC);
> +				 "mlx5_cmd_eq",  MLX5_EQ_TYPE_ASYNC);

Remove extra space

>  	if (err) {
>  		mlx5_core_warn(dev, "failed to create cmd EQ %d\n", err);
>  		return err;
> @@ -697,8 +696,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
>  
>  	err = mlx5_create_map_eq(dev, &table->async_eq, MLX5_EQ_VEC_ASYNC,
>  				 MLX5_NUM_ASYNC_EQE, async_event_mask,
> -				 "mlx5_async_eq", &dev->priv.bfregi.uars[0],
> -				 MLX5_EQ_TYPE_ASYNC);
> +				 "mlx5_async_eq", MLX5_EQ_TYPE_ASYNC);
>  	if (err) {
>  		mlx5_core_warn(dev, "failed to create async EQ %d\n", err);
>  		goto err1;
> @@ -708,7 +706,6 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
>  				 MLX5_EQ_VEC_PAGES,
>  				 /* TODO: sriov max_vf + */ 1,
>  				 1 << MLX5_EVENT_TYPE_PAGE_REQUEST, "mlx5_pages_eq",
> -				 &dev->priv.bfregi.uars[0],
>  				 MLX5_EQ_TYPE_ASYNC);
>  	if (err) {
>  		mlx5_core_warn(dev, "failed to create pages EQ %d\n", err);
> @@ -722,7 +719,6 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
>  					 MLX5_NUM_ASYNC_EQE,
>  					 1 << MLX5_EVENT_TYPE_PAGE_FAULT,
>  					 "mlx5_page_fault_eq",
> -					 &dev->priv.bfregi.uars[0],
>  					 MLX5_EQ_TYPE_PF);
>  		if (err) {
>  			mlx5_core_warn(dev, "failed to create page fault EQ %d\n",
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> index 634e96a..2882d04 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
> @@ -753,8 +753,7 @@ static int alloc_comp_eqs(struct mlx5_core_dev *dev)
>  		snprintf(name, MLX5_MAX_IRQ_NAME, "mlx5_comp%d", i);
>  		err = mlx5_create_map_eq(dev, eq,
>  					 i + MLX5_EQ_VEC_COMP_BASE, nent, 0,
> -					 name, &dev->priv.bfregi.uars[0],
> -					 MLX5_EQ_TYPE_COMP);
> +					 name, MLX5_EQ_TYPE_COMP);
>  		if (err) {
>  			kfree(eq);
>  			goto clean;
> @@ -1094,12 +1093,18 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
>  		goto err_cleanup_once;
>  	}
>  
> -	err = mlx5_alloc_bfregs(dev, &priv->bfregi);
> -	if (err) {
> +	dev->priv.uar = mlx5_get_uars_page(dev);
> +	if (!dev->priv.uar) {
>  		dev_err(&pdev->dev, "Failed allocating uar, aborting\n");
>  		goto err_disable_msix;
>  	}
>  
> +	err = mlx5_alloc_bfregs(dev, &priv->bfregi);
> +	if (err) {
> +		dev_err(&pdev->dev, "Failed allocating uuars, aborting\n");
> +		goto err_uar_cleanup;
> +	}
> +
>  	err = mlx5_start_eqs(dev);
>  	if (err) {
>  		dev_err(&pdev->dev, "Failed to start pages and async EQs\n");
> @@ -1172,6 +1177,9 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
>  err_free_uar:
>  	mlx5_free_bfregs(dev, &priv->bfregi);
>  
> +err_uar_cleanup:
> +	mlx5_put_uars_page(dev, priv->uar);
> +
>  err_disable_msix:
>  	mlx5_disable_msix(dev);
>  
> @@ -1231,6 +1239,7 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
>  	free_comp_eqs(dev);
>  	mlx5_stop_eqs(dev);
>  	mlx5_free_bfregs(dev, &priv->bfregi);
> +	mlx5_put_uars_page(dev, priv->uar);
>  	mlx5_disable_msix(dev);
>  	if (cleanup)
>  		mlx5_cleanup_once(dev);
> @@ -1305,6 +1314,11 @@ static int init_one(struct pci_dev *pdev,
>  		goto clean_dev;
>  	}
>  #endif
> +	mutex_init(&priv->bfregs.reg_head.lock);
> +	mutex_init(&priv->bfregs.wc_head.lock);
> +	INIT_LIST_HEAD(&priv->bfregs.reg_head.list);
> +	INIT_LIST_HEAD(&priv->bfregs.wc_head.list);
> +
>  	err = mlx5_pci_init(dev, priv);
>  	if (err) {
>  		dev_err(&pdev->dev, "mlx5_pci_init failed with error code %d\n", err);
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
> index 6a081a8..fcc0270 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
> @@ -332,6 +332,38 @@ static struct mlx5_uars_page *alloc_uars_page(struct mlx5_core_dev *mdev,
>  	return ERR_PTR(err);
>  }
>  
> +struct mlx5_uars_page *mlx5_get_uars_page(struct mlx5_core_dev *mdev)
> +{
> +	struct mlx5_uars_page *ret;
> +
> +	mutex_lock(&mdev->priv.bfregs.reg_head.lock);
> +	if (list_empty(&mdev->priv.bfregs.reg_head.list)) {
> +		ret = alloc_uars_page(mdev, false);
> +		if (IS_ERR(ret)) {
> +			ret = NULL;
> +			goto out;
> +		}
> +		list_add(&ret->list, &mdev->priv.bfregs.reg_head.list);
> +	} else {
> +		ret = list_first_entry(&mdev->priv.bfregs.reg_head.list,
> +				       struct mlx5_uars_page, list);
> +		kref_get(&ret->ref_count);
> +	}
> +out:
> +	mutex_unlock(&mdev->priv.bfregs.reg_head.lock);
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(mlx5_get_uars_page);
> +
> +void mlx5_put_uars_page(struct mlx5_core_dev *mdev, struct mlx5_uars_page *up)
> +{
> +	mutex_lock(&mdev->priv.bfregs.reg_head.lock);
> +	kref_put(&up->ref_count, up_rel_func);
> +	mutex_unlock(&mdev->priv.bfregs.reg_head.lock);
> +}
> +EXPORT_SYMBOL(mlx5_put_uars_page);
> +
>  static unsigned long map_offset(struct mlx5_core_dev *mdev, int dbi)
>  {
>  	/* return the offset in bytes from the start of the page to the
> diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
> index 969aa1f..9a3a095 100644
> --- a/include/linux/mlx5/driver.h
> +++ b/include/linux/mlx5/driver.h
> @@ -679,6 +679,7 @@ struct mlx5_priv {
>  	struct srcu_struct      pfault_srcu;
>  #endif
>  	struct mlx5_bfreg_data		bfregs;
> +	struct mlx5_uars_page	       *uar;
>  };
>  
>  enum mlx5_device_state {
> @@ -1007,7 +1008,7 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, u64 vec);
>  void mlx5_cq_event(struct mlx5_core_dev *dev, u32 cqn, int event_type);
>  int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
>  		       int nent, u64 mask, const char *name,
> -		       struct mlx5_uar *uar, enum mlx5_eq_type type);
> +		       enum mlx5_eq_type type);
>  int mlx5_destroy_unmap_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq);
>  int mlx5_start_eqs(struct mlx5_core_dev *dev);
>  int mlx5_stop_eqs(struct mlx5_core_dev *dev);
> @@ -1118,6 +1119,8 @@ int mlx5_cmd_create_vport_lag(struct mlx5_core_dev *dev);
>  int mlx5_cmd_destroy_vport_lag(struct mlx5_core_dev *dev);
>  bool mlx5_lag_is_active(struct mlx5_core_dev *dev);
>  struct net_device *mlx5_lag_get_roce_netdev(struct mlx5_core_dev *dev);
> +struct mlx5_uars_page *mlx5_get_uars_page(struct mlx5_core_dev *mdev);
> +void mlx5_put_uars_page(struct mlx5_core_dev *mdev, struct mlx5_uars_page *up);
>  
>  struct mlx5_profile {
>  	u64	mask;
> -- 
> 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
