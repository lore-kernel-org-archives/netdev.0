From: Amir Vadai <amirv@mellanox.com>
Subject: Re: net/mlx4_en: Use affinity hint
Date: Thu, 2 Jan 2014 18:33:37 +0200
Message-ID: <20140102163333.GA27176@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1388581537-4810-1-git-send-email-amirv@mellanox.com>
 <1388581537-4810-2-git-send-email-amirv@mellanox.com>
 <1388594070.6642.17.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yuval Atias <yuvala@mellanox.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:57751 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaABQdm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 11:33:42 -0500
Received: by mail-ea0-f181.google.com with SMTP id m10so6306108eaj.26
        for <netdev@vger.kernel.org>; Thu, 02 Jan 2014 08:33:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1388594070.6642.17.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/01/14 16:34 +0000, Ben Hutchings wrote:
> On Wed, 2014-01-01 at 15:05 +0200, Amir Vadai wrote:
> > From: Yuval Atias <yuvala@mellanox.com>
> >=20
> > The =E2=80=9Caffinity hint=E2=80=9D mechanism is used by the user s=
pace
> > daemon, irqbalancer, to indicate a preferred CPU mask for irqs.
> > Irqbalancer can use this hint to balance the irqs between the
> > cpus indicated by the mask.
> >=20
> > We wish the HCA to preferentially map the IRQs it uses to numa core=
s
> > close to it.
> > To accomplish this, we use affinity hint: first we map IRQs to =E2=80=
=9Cclose=E2=80=9D
> > numa cores.
> > If these are exhausted, the remaining IRQs are mapped to =E2=80=9Cf=
ar=E2=80=9D numa
> > cores.
> >=20
> > Signed-off-by: Yuval Atias <yuvala@mellanox.com>
> [...]
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> > @@ -1532,6 +1532,45 @@ static void mlx4_en_linkstate(struct work_st=
ruct *work)
> >  	mutex_unlock(&mdev->state_lock);
> >  }
> > =20
> > +static int mlx4_en_rings_affinity_hint(struct mlx4_en_priv *priv ,
> > +				      int *affinity_hint_mapping)
> > +{
> > +	int cpu;
> > +	int cores_arr_index =3D 0;
> > +	cpumask_t *numa_cores_mask;
> > +	cpumask_t *non_numa_cores_mask;
>=20
> The types of these masks must be cpumask_var_t.
>=20
Will be fixed in V1

> > +	if (!zalloc_cpumask_var(&non_numa_cores_mask, GFP_KERNEL)) {
> > +		en_err(priv, "Failed allocating cores mask\n");
> > +		return -EINVAL;
> > +	}
> > +	numa_cores_mask =3D (cpumask_t *)cpumask_of_node(
> > +					priv->mdev->dev->numa_node);
> > +	if (!cpumask_and(numa_cores_mask, cpu_online_mask, numa_cores_mas=
k))
> > +		en_warn(priv, "Failed to find online cores for local numa\n");
>=20
> This changes the CPU mask of your device's NUMA node.  Don't do that.
> You need to copy it to numa_cores_mask and then start changing it.
>=20
Will change in V1

> [...]
> > @@ -1557,6 +1596,9 @@ int mlx4_en_start_port(struct net_device *dev=
)
> >  	memset(&priv->ethtool_rules[0], 0,
> >  	       sizeof(struct ethtool_flow_id) * MAX_NUM_OF_FS_RULES);
> > =20
> > +	affinity_hint_mapping =3D kzalloc(num_online_cpus() * sizeof(int)=
,
> > +					GFP_KERNEL);
> [...]
>=20
> What makes you think that the online CPU IDs are all contiguous start=
ing
> at 0?  The correct array size is nr_cpu_ids, if I remember correctly.
Changing the design to go over the cpumask using cpumask_next(),
instead of preparing this array. So, it will fix this comment too.

>=20
> Ben.
>=20
> --=20
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Thanks,
Amir
