From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] mlx4: xdp_prog becomes inactive after ethtool '-L'
 or '-G'
Date: Tue, 31 Jan 2017 21:54:44 -0800
Message-ID: <20170201055444.vqszzuinuedvqwdr@kkwok-mbp.local.dhcp.thefacebook.com>
References: <1485589251-3896393-1-git-send-email-kafai@fb.com>
 <f2963258-62af-c7ed-b1ad-2924ba087880@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: Tariq Toukan <tariqt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:55984 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750991AbdBAFy5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 00:54:57 -0500
Content-Disposition: inline
In-Reply-To: <f2963258-62af-c7ed-b1ad-2924ba087880@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 30, 2017 at 07:18:28PM +0200, Tariq Toukan wrote:
> Hi Martin,
>
> Thanks for your patch.
>
> It looks good to me, in general.
> I just have one small comment below.
Thanks for your feedback and sorry for the delay.

>
> On 28/01/2017 9:40 AM, Martin KaFai Lau wrote:
> > If the rx-queues ever get re-initialized (e.g. by changing the
> > number of rx-queues with ethtool -L), the existing xdp_prog becomes
> > inactive.
> >
> > The bug is that the xdp_prog ptr has not been carried over from
> > the old rx-queues to the new rx-queues
> >
> > Fixes: 47a38e155037 ("net/mlx4_en: add support for fast rx drop bpf program")
> > Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> > ---
> ...
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > index 761f8b12399c..f4179086b3c6 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > @@ -2184,23 +2184,57 @@ static void mlx4_en_update_priv(struct mlx4_en_priv *dst,
> >   int mlx4_en_try_alloc_resources(struct mlx4_en_priv *priv,
> >   				struct mlx4_en_priv *tmp,
> > -				struct mlx4_en_port_profile *prof)
> > +				struct mlx4_en_port_profile *prof,
> > +				bool carry_xdp_prog)
> >   {
> > -	int t;
> > +	struct bpf_prog *xdp_prog = NULL;
> > +	int err;
> > +	int i;
> >   	mlx4_en_copy_priv(tmp, priv, prof);
> > +	if (carry_xdp_prog) {
> > +		/* All rx_rings has the same xdp_prog.  Pick the first one */
> > +		xdp_prog = rcu_dereference_protected(
> > +			priv->rx_ring[0]->xdp_prog,
> > +			lockdep_is_held(&priv->mdev->state_lock));
> > +
> > +		if (xdp_prog) {
> > +			xdp_prog = bpf_prog_add(xdp_prog, tmp->rx_ring_num);
> > +			if (IS_ERR(xdp_prog)) {
> > +				err = PTR_ERR(xdp_prog);
> > +				xdp_prog = NULL;
> > +				goto err_free;
> > +			}
> > +		}
> > +	}
> Why do you prefer dealing with xdp_prog in two stages? You can handle it all
> at once, after "mlx4_en_alloc_resources()" succeeds.
If bpf_prog_add() did fail, resources allocated for tmp had to
be freed.  I was thinking it is not safe to call mlx4_en_free_resources()
at this point.  Since your feedback, I took another look and re-read the
'goto err' path in mlx4_en_alloc_resources(), I realized we can use
mlx4_en_free_resources() here for the bpf_prog_add() error case.  Hence,
agree with your suggestion.

A side note though:
after taking another look at mlx4_en_free_resources(), I might have found
another issue.  I need to run some tests to confirm first to avoid any false
alarm.

I will post v2.

Thanks,
--Martin


> > +
> >   	if (mlx4_en_alloc_resources(tmp)) {
> >   		en_warn(priv,
> >   			"%s: Resource allocation failed, using previous configuration\n",
> >   			__func__);
> > -		for (t = 0; t < MLX4_EN_NUM_TX_TYPES; t++) {
> > -			kfree(tmp->tx_ring[t]);
> > -			kfree(tmp->tx_cq[t]);
> > -		}
> > -		return -ENOMEM;
> > +		err = -ENOMEM;
> > +		goto err_free;
> > +	}
> > +
> > +	if (xdp_prog) {
> > +		for (i = 0; i < tmp->rx_ring_num; i++)
> > +			rcu_assign_pointer(tmp->rx_ring[i]->xdp_prog,
> > +					   xdp_prog);
> >   	}
> > +
> >   	return 0;
> > +
> > +err_free:
> > +	if (xdp_prog)
> > +		bpf_prog_sub(xdp_prog, tmp->rx_ring_num);
> > +
> > +	for (i = 0; i < MLX4_EN_NUM_TX_TYPES; i++) {
> > +		kfree(tmp->tx_ring[i]);
> > +		kfree(tmp->tx_cq[i]);
> > +	}
> > +
> > +	return err;
> >   }
> >   void mlx4_en_safe_replace_resources(struct mlx4_en_priv *priv,
> >
> Regards,
> Tariq Toukan.
