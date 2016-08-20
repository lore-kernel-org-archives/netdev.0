From: walter harms <wharms-fPG8STNUNVg@public.gmane.org>
Subject: Re: [PATCH] mlx5/core: Use memdup_user() rather than duplicating
 its implementation
Date: Sat, 20 Aug 2016 11:32:55 +0200
Message-ID: <57B823C7.3040705@bfs.de>
References: <566ABCD9.1060404@users.sourceforge.net> <ceb39933-438d-920d-f294-ea0ce32fd171@users.sourceforge.net>
Reply-To: wharms-fPG8STNUNVg@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Julia Lawall <julia.lawall-L2FTfq7BK8M@public.gmane.org>
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <ceb39933-438d-920d-f294-ea0ce32fd171-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



Am 20.08.2016 08:01, schrieb SF Markus Elfring:
> From: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> Date: Sat, 20 Aug 2016 07:50:09 +0200
> 
> * Reuse existing functionality from memdup_user() instead of keeping
>   duplicate source code.
> 
>   This issue was detected by using the Coccinelle software.
> 
> * Return directly if this copy operation failed.
> 
> Signed-off-by: Markus Elfring <elfring-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/cmd.c | 17 +++--------------
>  1 file changed, 3 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> index 6388bc0..bb89f04 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> @@ -1132,7 +1132,6 @@ static ssize_t data_write(struct file *filp, const char __user *buf,
>  	struct mlx5_core_dev *dev = filp->private_data;
>  	struct mlx5_cmd_debug *dbg = &dev->cmd.dbg;
>  	void *ptr;
> -	int err;
>  
>  	if (*pos != 0)
>  		return -EINVAL;
> @@ -1140,25 +1139,15 @@ static ssize_t data_write(struct file *filp, const char __user *buf,
>  	kfree(dbg->in_msg);
>  	dbg->in_msg = NULL;
>  	dbg->inlen = 0;
> -
> -	ptr = kzalloc(count, GFP_KERNEL);
> -	if (!ptr)
> -		return -ENOMEM;
> -
> -	if (copy_from_user(ptr, buf, count)) {
> -		err = -EFAULT;
> -		goto out;
> -	}
> +	ptr = memdup_user(buf, count);
> +	if (IS_ERR(ptr))
> +		return PTR_ERR(ptr);
>  	dbg->in_msg = ptr;
>  	dbg->inlen = count;
>  
>  	*pos = count;
>  

maybe i am missing something here but why do you need ptr ?

The use of count looks even more confusing it is stored in
 dbg->inlen, *pos and is returned.
is that realy needed ?

re,
 wh

>  	return count;
> -
> -out:
> -	kfree(ptr);
> -	return err;
>  }
>  
>  static ssize_t data_read(struct file *filp, char __user *buf, size_t count,
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
