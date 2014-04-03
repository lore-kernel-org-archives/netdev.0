From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [PATCH] net/mlx4_core: match pci_device_id including dynids
Date: Thu, 3 Apr 2014 15:12:54 -0600
Message-ID: <20140403211254.GA21931@google.com>
References: <1396326961-20395-1-git-send-email-weiyang@linux.vnet.ibm.com>
 <CAErSpo4yj+31puKhnxJ9Dns4c-1cWoUxxQt+OTDQDCGuuksOAw@mail.gmail.com>
 <20140403015130.GA6151@richard>
 <CAErSpo749gfvcJmwjCw6c6H07S9cvaX2kz4jw1AwUZzbDN6Afw@mail.gmail.com>
 <20140403065432.GA18045@richard>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, yevgenyp@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Wei Yang <weiyang@linux.vnet.ibm.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140403065432.GA18045@richard>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 03, 2014 at 02:54:32PM +0800, Wei Yang wrote:
> Here is another one based on your comment, which split mlx4_remove_one into
> two and named a helper __mlx4_remove_one(). mlx4_pci_err_detected() will just
> call __mlx4_remove_one(), which will not release drvdata.
> 
> BTW, this is not tested, just want to make sure my understanding is correct.

A couple minor comments below, but in general, yes, this is what I was
thinking.

> From 84a5a9df0604cbea9b70c74b0709258841637946 Mon Sep 17 00:00:00 2001
> From: Wei Yang <weiyang@linux.vnet.ibm.com>
> Date: Mon, 31 Mar 2014 11:34:57 +0800
> Subject: [PATCH] net/mlx4_core: match pci_device_id including dynids
> 
> Fix issue introduced by commit: 97a5221 "net/mlx4_core: pass
> pci_device_id.driver_data to __mlx4_init_one during reset".
> 
> pci_match_id() just match the static pci_device_id, which may return NULL if
> someone binds the driver to a device manually using
> /sys/bus/pci/drivers/.../new_id.
> 
> This patch wrap up a helper function __mlx4_remove_one() which does the tear
> down function but preserve the drv_data. Functions like
> mlx4_pci_err_detected() and mlx4_restart_one() will call this one with out
> releasing drvdata.
> 
> CC: Bjorn Helgaas <bhelgaas@google.com>
> CC: Amir Vadai <amirv@mellanox.com>
> Signed-off-by: Wei Yang <weiyang@linux.vnet.ibm.com>
> Acked-by: Amir Vadai <amirv@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/main.c |  149 ++++++++++++++++-------------
>  1 file changed, 80 insertions(+), 69 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
> index aa54ef7..fd1f288 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/main.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/main.c
> @@ -2268,7 +2268,12 @@ static int __mlx4_init_one(struct pci_dev *pdev, int pci_dev_data)
>  	/* Allow large DMA segments, up to the firmware limit of 1 GB */
>  	dma_set_max_seg_size(&pdev->dev, 1024 * 1024 * 1024);
>  
> -	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> +	dev = pci_get_drvdata(pdev);
> +	if (!dev)
> +		priv = kzalloc(sizeof(*priv), GFP_KERNEL);
> +	else
> +		priv = mlx4_priv(dev);

Why don't you move the priv kzalloc into mlx4_init_one()?  Then it would be
symmetric -- you alloc and call pci_set_drvdata() in mlx4_init_one(), and
you call pci_set_drvdata(NULL) and free it in mlx4_remove_one().  And you
wouldn't need the test here.

> +
>  	if (!priv) {
>  		err = -ENOMEM;
>  		goto err_release_regions;
> @@ -2525,77 +2530,81 @@ static int mlx4_init_one(struct pci_dev *pdev, const struct pci_device_id *id)
>  	return __mlx4_init_one(pdev, id->driver_data);
>  }
>  
> -static void mlx4_remove_one(struct pci_dev *pdev)
> +static void __mlx4_remove_one(struct mlx4_dev *dev)
>  {
> -	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
> -	struct mlx4_priv *priv = mlx4_priv(dev);
> -	int p;
> +	/* in SRIOV it is not allowed to unload the pf's
> +	 * driver while there are alive vf's */
> +	if (mlx4_is_master(dev)) {
> +		if (mlx4_how_many_lives_vf(dev))
> +			printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
> +	}
> +	mlx4_stop_sense(dev);
> +	mlx4_unregister_device(dev);
>  
> -	if (dev) {
> -		/* in SRIOV it is not allowed to unload the pf's
> -		 * driver while there are alive vf's */
> -		if (mlx4_is_master(dev)) {
> -			if (mlx4_how_many_lives_vf(dev))
> -				printk(KERN_ERR "Removing PF when there are assigned VF's !!!\n");
> -		}
> -		mlx4_stop_sense(dev);
> -		mlx4_unregister_device(dev);
> +	for (p = 1; p <= dev->caps.num_ports; p++) {
> +		mlx4_cleanup_port_info(&priv->port[p]);
> +		mlx4_CLOSE_PORT(dev, p);
> +	}
>  
> -		for (p = 1; p <= dev->caps.num_ports; p++) {
> -			mlx4_cleanup_port_info(&priv->port[p]);
> -			mlx4_CLOSE_PORT(dev, p);
> -		}
> +	if (mlx4_is_master(dev))
> +		mlx4_free_resource_tracker(dev,
> +					   RES_TR_FREE_SLAVES_ONLY);
>  
> -		if (mlx4_is_master(dev))
> -			mlx4_free_resource_tracker(dev,
> -						   RES_TR_FREE_SLAVES_ONLY);
> -
> -		mlx4_cleanup_counters_table(dev);
> -		mlx4_cleanup_qp_table(dev);
> -		mlx4_cleanup_srq_table(dev);
> -		mlx4_cleanup_cq_table(dev);
> -		mlx4_cmd_use_polling(dev);
> -		mlx4_cleanup_eq_table(dev);
> -		mlx4_cleanup_mcg_table(dev);
> -		mlx4_cleanup_mr_table(dev);
> -		mlx4_cleanup_xrcd_table(dev);
> -		mlx4_cleanup_pd_table(dev);
> +	mlx4_cleanup_counters_table(dev);
> +	mlx4_cleanup_qp_table(dev);
> +	mlx4_cleanup_srq_table(dev);
> +	mlx4_cleanup_cq_table(dev);
> +	mlx4_cmd_use_polling(dev);
> +	mlx4_cleanup_eq_table(dev);
> +	mlx4_cleanup_mcg_table(dev);
> +	mlx4_cleanup_mr_table(dev);
> +	mlx4_cleanup_xrcd_table(dev);
> +	mlx4_cleanup_pd_table(dev);
>  
> -		if (mlx4_is_master(dev))
> -			mlx4_free_resource_tracker(dev,
> -						   RES_TR_FREE_STRUCTS_ONLY);
> -
> -		iounmap(priv->kar);
> -		mlx4_uar_free(dev, &priv->driver_uar);
> -		mlx4_cleanup_uar_table(dev);
> -		if (!mlx4_is_slave(dev))
> -			mlx4_clear_steering(dev);
> -		mlx4_free_eq_table(dev);
> -		if (mlx4_is_master(dev))
> -			mlx4_multi_func_cleanup(dev);
> -		mlx4_close_hca(dev);
> -		if (mlx4_is_slave(dev))
> -			mlx4_multi_func_cleanup(dev);
> -		mlx4_cmd_cleanup(dev);
> -
> -		if (dev->flags & MLX4_FLAG_MSI_X)
> -			pci_disable_msix(pdev);
> -		if (dev->flags & MLX4_FLAG_SRIOV) {
> -			mlx4_warn(dev, "Disabling SR-IOV\n");
> -			pci_disable_sriov(pdev);
> -		}
> +	if (mlx4_is_master(dev))
> +		mlx4_free_resource_tracker(dev,
> +					   RES_TR_FREE_STRUCTS_ONLY);
>  
> -		if (!mlx4_is_slave(dev))
> -			mlx4_free_ownership(dev);
> +	iounmap(priv->kar);
> +	mlx4_uar_free(dev, &priv->driver_uar);
> +	mlx4_cleanup_uar_table(dev);
> +	if (!mlx4_is_slave(dev))
> +		mlx4_clear_steering(dev);
> +	mlx4_free_eq_table(dev);
> +	if (mlx4_is_master(dev))
> +		mlx4_multi_func_cleanup(dev);
> +	mlx4_close_hca(dev);
> +	if (mlx4_is_slave(dev))
> +		mlx4_multi_func_cleanup(dev);
> +	mlx4_cmd_cleanup(dev);
> +
> +	if (dev->flags & MLX4_FLAG_MSI_X)
> +		pci_disable_msix(pdev);
> +	if (dev->flags & MLX4_FLAG_SRIOV) {
> +		mlx4_warn(dev, "Disabling SR-IOV\n");
> +		pci_disable_sriov(pdev);
> +	}
> +
> +	if (!mlx4_is_slave(dev))
> +		mlx4_free_ownership(dev);
> +
> +	kfree(dev->caps.qp0_tunnel);
> +	kfree(dev->caps.qp0_proxy);
> +	kfree(dev->caps.qp1_tunnel);
> +	kfree(dev->caps.qp1_proxy);
> +	pci_release_regions(pdev);
> +	pci_disable_device(pdev);
> +}
>  
> -		kfree(dev->caps.qp0_tunnel);
> -		kfree(dev->caps.qp0_proxy);
> -		kfree(dev->caps.qp1_tunnel);
> -		kfree(dev->caps.qp1_proxy);
> +static void mlx4_remove_one(struct pci_dev *pdev)
> +{
> +	struct mlx4_dev  *dev  = pci_get_drvdata(pdev);
> +	struct mlx4_priv *priv = mlx4_priv(dev);
> +	int p;
>  
> +	if (dev) {

I don't think you should test "dev" here.  What scenario is there where
mlx4_remove_one() would be called with a pci_dev that has no drvdata?

> +		__mlx4_remove_one(dev);
>  		kfree(priv);
> -		pci_release_regions(pdev);
> -		pci_disable_device(pdev);
>  		pci_set_drvdata(pdev, NULL);
>  	}
>  }
> @@ -2607,7 +2616,7 @@ int mlx4_restart_one(struct pci_dev *pdev)
>  	int		  pci_dev_data;
>  
>  	pci_dev_data = priv->pci_dev_data;
> -	mlx4_remove_one(pdev);
> +	__mlx4_remove_one(pdev);
>  	return __mlx4_init_one(pdev, pci_dev_data);
>  }
>  
> @@ -2662,7 +2671,7 @@ MODULE_DEVICE_TABLE(pci, mlx4_pci_table);
>  static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>  					      pci_channel_state_t state)
>  {
> -	mlx4_remove_one(pdev);
> +	__mlx4_remove_one(pdev);
>  
>  	return state == pci_channel_io_perm_failure ?
>  		PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_NEED_RESET;
> @@ -2670,11 +2679,13 @@ static pci_ers_result_t mlx4_pci_err_detected(struct pci_dev *pdev,
>  
>  static pci_ers_result_t mlx4_pci_slot_reset(struct pci_dev *pdev)
>  {
> -	const struct pci_device_id *id;
> -	int ret;
> +	struct mlx4_dev	 *dev  = pci_get_drvdata(pdev);
> +	struct mlx4_priv *priv = mlx4_priv(dev);
> +	int		  pci_dev_data;
> +	int               ret;
>  
> -	id = pci_match_id(mlx4_pci_table, pdev);
> -	ret = __mlx4_init_one(pdev, id->driver_data);
> +	pci_dev_data = priv->pci_dev_data;
> +	ret = __mlx4_init_one(pdev, pci_dev_data);
>  
>  	return ret ? PCI_ERS_RESULT_DISCONNECT : PCI_ERS_RESULT_RECOVERED;
>  }
> -- 
> 1.7.9.5
> 
> 
> -- 
> Richard Yang
> Help you, Help me
> 
