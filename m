From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH] mlx4: Fix tx ring affinity_mask creation
Date: Mon, 27 Apr 2015 20:26:37 -0700
Message-ID: <20150428032637.GA6169@f1.synalogic.ca>
References: <1428683240-22879-1-git-send-email-bpoirier@suse.de>
 <552A18A8.1040109@dev.mellanox.co.il>
 <20150414002256.GA22775@f1.synalogic.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ido Shamay <idos@dev.mellanox.co.il>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150414002256.GA22775@f1.synalogic.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/04/13 17:22, Benjamin Poirier wrote:
> On 2015/04/12 10:03, Ido Shamay wrote:
> > Hi Benjamin,
> > 
> > On 4/10/2015 7:27 PM, Benjamin Poirier wrote:
> > >By default, the number of tx queues is limited by the number of online cpus in
> > >mlx4_en_get_profile(). However, this limit no longer holds after the ethtool
> > >.set_channels method has been called. In that situation, the driver may access
> > >invalid bits of certain cpumask variables when queue_index > nr_cpu_ids.
> > 
> > I must say I don't see the above issue with the current code.
> > Whatever is the modified value of priv->num_tx_rings_p_up, it will set XPS
> > only on queues which have
> > been set with CPU affinity mask (no access to invalid bits).
> 
> The problem is not with the call to netif_set_xps_queue() it is with the
> calls to cpu_online() and cpumask_set_cpu().
> 
> For example, if the user calls `ethtool -L ethX tx 32`, queue_index in
> mlx4_en_create_tx_ring() can be up to 255. Depending on CONFIG_NR_CPUS
> and CONFIG_CPUMASK_OFFSTACK this may result in calls to cpu_online() and
> cpumask_set_cpu() with cpu >= nr_cpumask_bits which is an invalid usage
> of the cpumask api. The driver will potentially read or write beyond the
> end of the bitmap. With CONFIG_CPUMASK_OFFSTACK=y and
> CONFIG_DEBUG_PER_CPU_MAPS=y, the aforementioned ethtool call on a system
> with <32 cpus triggers the warning in cpumask_check(). 
> 

Mellanox, can you please
ack the patch as submitted, or
clarify what changes you'd like to see given my reply above, or
submit a fix of your own for this problem

Thanks,
-Benjamin

> > 
> > It's true that when priv->num_tx_rings_p_up > nr_cpus. not all queues will
> > be set with XPS.
> > This is because the code tries to preserve 1:1 mapping of queues to cores,
> > to avoid a double mapping
> > of queues to cores.
> > I guess it's ok to break the 1:1 mapping in this condition, but the commit
> > message should say that instead
> > of invalid bits. Please fix me if I'm wrong.
> > 
> > >Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> > >---
> > >  drivers/net/ethernet/mellanox/mlx4/en_tx.c | 8 +++++---
> > >  1 file changed, 5 insertions(+), 3 deletions(-)
> > >
> > >diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > >index 55f9f5c..8c234ec 100644
> > >--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > >+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > >@@ -143,8 +143,10 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
> > >  	ring->hwtstamp_tx_type = priv->hwtstamp_config.tx_type;
> > >  	ring->queue_index = queue_index;
> > >-	if (queue_index < priv->num_tx_rings_p_up && cpu_online(queue_index))
> > >-		cpumask_set_cpu(queue_index, &ring->affinity_mask);
> > >+	if (queue_index < priv->num_tx_rings_p_up)
> > >+			cpumask_set_cpu_local_first(queue_index,
> > >+					    priv->mdev->dev->numa_node,
> > >+					    &ring->affinity_mask);
> > Moving from cpumask_set_cpu to cpumask_set_cpu_local_first is great, but
> > should come in a different commit, since
> > the behavior of the XPS is changed here (xps_cpus[tx_ring[queue_index]] !=
> > queue_index from now).
> > Commit should state of this behavior change.
> > Thanks a lot Benjamin.
> > >  	*pring = ring;
> > >  	return 0;
> > >@@ -213,7 +215,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
> > >  	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
> > >  			       &ring->qp, &ring->qp_state);
> > >-	if (!user_prio && cpu_online(ring->queue_index))
> > >+	if (!cpumask_empty(&ring->affinity_mask))
> > >  		netif_set_xps_queue(priv->dev, &ring->affinity_mask,
> > >  				    ring->queue_index);
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
