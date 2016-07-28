From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [RFC] net/mlx5_core/en_main: Remove deprecated create_workqueue
Date: Fri, 29 Jul 2016 01:30:05 +0300
Message-ID: <CALzJLG_B4q2TeAy9U+8nZisYtw8+MfwT8or81mBsPJ=VFLxBqw@mail.gmail.com>
References: <20160727061229.GA16943@Karyakshetra>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	linux-rdma@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Tejun Heo <tj@kernel.org>
To: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160727061229.GA16943@Karyakshetra>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 27, 2016 at 9:12 AM, Bhaktipriya Shridhar
<bhaktipriya96@gmail.com> wrote:
> alloc_ordered_workqueue() with WQ_MEM_RECLAIM set replaces
> deprecated create_singlethread_workqueue(). This is the identity
> conversion.
>
> A dedicated workqueue has been used since mlx5e workqueue was created to
> handle all mlx5e specific tasks. This is in preparation for vxlan using
> the mlx5e workqueue in order to schedule port add/remove operations.
> WQ_MEM_RECLAIM has been set to guarantee forward progress under memory
> pressure.
>
> Can the workitems be executed concurrently?

well, the work items that currently using the mlx5e WQ are:

priv->update_carrier_work : Read hardware link state and update netdev carrier
priv->update_stats_work: a periodic task that runs once every 1/4 sec
to update netdev statistics.
priv->set_rx_mode_work: A task queued from netdev set_rx_mdoe/set_mac
NDOs and sometimes explicitly from driver to update netdev RX mode and
filters.
mlx5e_vxlan_queue_work: Queue a _dynamically_ created workitem to
add/rem vxlan port, those tasks must not be executed concurrently
-since they are dynamically- allocated to gurantee add/remove
ordering.

bottom line, I wouldn't change concurrency of the mlx5e work queue.

> Are the workitems being used on a memory reclaim path?

do you mean they need to allocate memory ?

> Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> index fd43929..1a96445 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
> @@ -3042,7 +3042,7 @@ static void *mlx5e_create_netdev(struct mlx5_core_dev *mdev)
>
>         priv = netdev_priv(netdev);
>
> -       priv->wq = create_singlethread_workqueue("mlx5e");
> +       priv->wq = alloc_ordered_workqueue("mlx5e", WQ_MEM_RECLAIM);
>         if (!priv->wq)
>                 goto err_free_netdev;
>
> --
> 2.1.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
