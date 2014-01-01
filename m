From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 1/2] net/mlx4_en: Use affinity hint
Date: Wed, 1 Jan 2014 16:34:30 +0000
Message-ID: <1388594070.6642.17.camel@deadeye.wl.decadent.org.uk>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
	 <1388581537-4810-2-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:41488 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754416AbaAAQee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 11:34:34 -0500
In-Reply-To: <1388581537-4810-2-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-01-01 at 15:05 +0200, Amir Vadai wrote:
> From: Yuval Atias <yuvala@mellanox.com>
>=20
> The =E2=80=9Caffinity hint=E2=80=9D mechanism is used by the user spa=
ce
> daemon, irqbalancer, to indicate a preferred CPU mask for irqs.
> Irqbalancer can use this hint to balance the irqs between the
> cpus indicated by the mask.
>=20
> We wish the HCA to preferentially map the IRQs it uses to numa cores
> close to it.
> To accomplish this, we use affinity hint: first we map IRQs to =E2=80=
=9Cclose=E2=80=9D
> numa cores.
> If these are exhausted, the remaining IRQs are mapped to =E2=80=9Cfar=
=E2=80=9D numa
> cores.
>=20
> Signed-off-by: Yuval Atias <yuvala@mellanox.com>
[...]
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -1532,6 +1532,45 @@ static void mlx4_en_linkstate(struct work_stru=
ct *work)
>  	mutex_unlock(&mdev->state_lock);
>  }
> =20
> +static int mlx4_en_rings_affinity_hint(struct mlx4_en_priv *priv ,
> +				      int *affinity_hint_mapping)
> +{
> +	int cpu;
> +	int cores_arr_index =3D 0;
> +	cpumask_t *numa_cores_mask;
> +	cpumask_t *non_numa_cores_mask;

The types of these masks must be cpumask_var_t.

> +	if (!zalloc_cpumask_var(&non_numa_cores_mask, GFP_KERNEL)) {
> +		en_err(priv, "Failed allocating cores mask\n");
> +		return -EINVAL;
> +	}
> +	numa_cores_mask =3D (cpumask_t *)cpumask_of_node(
> +					priv->mdev->dev->numa_node);
> +	if (!cpumask_and(numa_cores_mask, cpu_online_mask, numa_cores_mask)=
)
> +		en_warn(priv, "Failed to find online cores for local numa\n");

This changes the CPU mask of your device's NUMA node.  Don't do that.
You need to copy it to numa_cores_mask and then start changing it.

[...]
> @@ -1557,6 +1596,9 @@ int mlx4_en_start_port(struct net_device *dev)
>  	memset(&priv->ethtool_rules[0], 0,
>  	       sizeof(struct ethtool_flow_id) * MAX_NUM_OF_FS_RULES);
> =20
> +	affinity_hint_mapping =3D kzalloc(num_online_cpus() * sizeof(int),
> +					GFP_KERNEL);
[...]

What makes you think that the online CPU IDs are all contiguous startin=
g
at 0?  The correct array size is nr_cpu_ids, if I remember correctly.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
