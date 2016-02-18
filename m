From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next V1 04/12] net/mlx5e: Support DCBNL IEEE ETS
Date: Thu, 18 Feb 2016 07:30:03 -0800
Message-ID: <56C5E37B.20207@gmail.com>
References: <1455791573-5270-1-git-send-email-saeedm@mellanox.com> <1455791573-5270-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:34601 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1424370AbcBRPaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 10:30:19 -0500
Received: by mail-pf0-f172.google.com with SMTP id x65so33182867pfb.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 07:30:18 -0800 (PST)
In-Reply-To: <1455791573-5270-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-18 02:32 AM, Saeed Mahameed wrote:
> Support the ndo_setup_tc callback and the needed methods
> for multi TC/UP support, and removed the default_vlan_prio
> from mlx5e_priv which is always 0, it was replaced with
> hardcoded "0" in the new select queue method.
> 
> For that we now create MAX_NUM_TC num of TISs (one per prio)
> on netdevice creation instead of priv->params.num_tc which
> was always 1.
> 
> So far each channel had a single TXQ, Now each channel has a
> TXQ per TC (Traffic Class).
> 
> Added en_dcbnl.c which implements the set/get DCBNL IEEE ETS,
> set/get dcbx and registers the mlx5e dcbnl ops.
> 
> We still use the kernel's default TXQ selection method to select the
> channel to transmit through but now we use our own method to select
> the TXQ inside the channel based on VLAN priority.
> 
> In mlx5, as opposed to mlx4, tc group N gets lower priority than
> tc group N+1.
> 
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Rana Shahout <ranas@mellanox.com>
> ---


[...]

>  
> +static int mlx5e_setup_tc(struct net_device *netdev, u8 tc)
> +{
> +	struct mlx5e_priv *priv = netdev_priv(netdev);
> +	bool was_opened;
> +	int err = 0;
> +
> +	if (tc && tc != MLX5E_MAX_NUM_TC)
> +		return -EINVAL;
> +
> +	mutex_lock(&priv->state_lock);
> +
> +	was_opened = test_bit(MLX5E_STATE_OPENED, &priv->state);
> +	if (was_opened)
> +		mlx5e_close_locked(priv->netdev);
> +
> +	priv->params.num_tc = tc ? tc : 1;
> +
> +	if (was_opened)
> +		err = mlx5e_open_locked(priv->netdev);
> +
> +	mutex_unlock(&priv->state_lock);
> +
> +	return err;
> +}
> +

Hi Saeed,

I just changed the signature on the setup_tc ndo hook so you will
need to change this to something like,

static int __mlx5e_setup_tc(struct net_device *dev, u32 handle,
			    __be16 proto, struct tc_to_netdev *tc)
{
	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
		return -EINVAL;
	return mlx5e_setup_tc(dev, tc->tc)
}


and then use __mlx5e_setup_tc() to populate the ndo op hook. If you
look at the mlx4 drivers I did this change there already.

Other than that nice to see another dcb supporting driver.

Thanks,
John
