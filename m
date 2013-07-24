From: Eli Cohen <eli@dev.mellanox.co.il>
Subject: Re: [patch] mlx5: use after free in mlx5_cmd_comp_handler()
Date: Wed, 24 Jul 2013 19:35:44 +0300
Message-ID: <20130724163544.GA29427@mtldesk30>
References: <20130722080201.GG14617@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>, moshel@mellanox.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130722080201.GG14617@longonot.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This race has been spotted and fixed by Moshe Lazer two weeks ago.
Anyways,

Acked by Eli Cohen <eli@mellanox.com>

On Mon, Jul 22, 2013 at 11:02:01AM +0300, Dan Carpenter wrote:
> We can't dereference "ent" after passing it to free_cmd().
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> index 205753a..4037406 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/cmd.c
> @@ -1113,7 +1113,13 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
>  
>  	for (i = 0; i < (1 << cmd->log_sz); i++) {
>  		if (test_bit(i, &vector)) {
> +			struct semaphore *sem;
> +
>  			ent = cmd->ent_arr[i];
> +			if (ent->page_queue)
> +				sem = &cmd->pages_sem;
> +			else
> +				sem = &cmd->sem;
>  			ktime_get_ts(&ent->ts2);
>  			memcpy(ent->out->first.data, ent->lay->out, sizeof(ent->lay->out));
>  			dump_command(dev, ent, 0);
> @@ -1136,10 +1142,7 @@ void mlx5_cmd_comp_handler(struct mlx5_core_dev *dev, unsigned long vector)
>  			} else {
>  				complete(&ent->done);
>  			}
> -			if (ent->page_queue)
> -				up(&cmd->pages_sem);
> -			else
> -				up(&cmd->sem);
> +			up(sem);
>  		}
>  	}
>  }
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
