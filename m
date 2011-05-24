From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [gianfar PATCH] RFC v2: Add rx_ntuple feature
Date: Tue, 24 May 2011 00:09:02 -0700
Message-ID: <1306220942.17233.20.camel@localhost>
References: <14348.80.254.147.148.1305638298.squirrel@webmail.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sebastian.poehn@belden.com
To: s.poehn@stud.hs-esslingen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17384 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753049Ab1EXHJb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 03:09:31 -0400
In-Reply-To: <14348.80.254.147.148.1305638298.squirrel@webmail.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 15:18 +0200, Sebastian P=C3=B6hn wrote:
> This patch implements rx ntuple filtering for the gianfar driver.
> Changes since last version:
> #Added code is now re-entrant
> #Consolidation of convert routines
>=20
> I am planing to do some final testing. After that I hope I can send t=
he
> final patch.
>=20
> Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
> ---
>=20
>  drivers/net/gianfar.c         |   16 +-
>  drivers/net/gianfar.h         |   44 ++
>  drivers/net/gianfar_ethtool.c | 1006
> +++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1062 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
> index ff60b23..ddd4007 100644
> --- a/drivers/net/gianfar.c
> +++ b/drivers/net/gianfar.c
[...]
> @@ -1042,6 +1048,9 @@ static int gfar_probe(struct platform_device *o=
fdev)
>  	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_VLAN)
>  		dev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
>=20
> +	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_RX_FILER)
> +		dev->features |=3D NETIF_F_NTUPLE;
> +

It should be possible to turn this feature on and off, so add it to
hw_features and handle it in gfar_set_features() by clearing filters
when it's being turned off.

[...]
> --- a/drivers/net/gianfar.h
> +++ b/drivers/net/gianfar.h
[...]
> @@ -1066,6 +1069,9 @@ struct gfar_private {
>=20
>  	struct vlan_group *vlgrp;
>=20
> +	/* RX queue filer rule set*/
> +	struct ethtool_rx_ntuple_list ntuple_list;
> +	struct mutex rx_queue_access;
>=20
>  	/* Hash registers and their width */
>  	u32 __iomem *hash_regs[16];

Don't use struct ethtool_rx_ntuple_list; it is going to be removed once
ixgbe is converted to implement RX NFC.

Really, at this point I would say: please implement RX NFC, not RX
n-tuple.

> @@ -1140,6 +1146,16 @@ static inline void gfar_write_filer(struct
> gfar_private *priv,
>  	gfar_write(&regs->rqfpr, fpr);
>  }
>=20
> +static inline void gfar_read_filer(struct gfar_private *priv,
> +		unsigned int far, unsigned int *fcr, unsigned int *fpr)
> +{
> +	struct gfar __iomem *regs =3D priv->gfargrp[0].regs;
> +
> +	gfar_write(&regs->rqfar, far);
> +	*fcr =3D gfar_read(&regs->rqfcr);
> +	*fpr =3D gfar_read(&regs->rqfpr);
> +}
> +
>  extern void lock_rx_qs(struct gfar_private *priv);
>  extern void lock_tx_qs(struct gfar_private *priv);
>  extern void unlock_rx_qs(struct gfar_private *priv);
> @@ -1157,4 +1173,32 @@ int gfar_set_features(struct net_device *dev, =
u32
> features);
>=20
>  extern const struct ethtool_ops gfar_ethtool_ops;
>=20
> +#define ESWFULL 160
> +#define EHWFULL 161
> +#define EOUTOFRANGE 162

You can't just make up new error codes like this.

[...]
> --- a/drivers/net/gianfar_ethtool.c
> +++ b/drivers/net/gianfar_ethtool.c
[...]
> +static int gfar_add_table_entry(struct ethtool_rx_ntuple_flow_spec *=
flow,
> +		struct ethtool_rx_ntuple_list *list)
> +{
> +	struct ethtool_rx_ntuple_flow_spec_container *temp;
> +	temp =3D kmalloc(sizeof(struct ethtool_rx_ntuple_flow_spec_containe=
r),
> +			GFP_KERNEL);
> +	if (temp =3D=3D NULL)
> +		return -ENOMEM;
> +	memcpy(&temp->fs, flow, sizeof(struct ethtool_rx_ntuple_flow_spec))=
;
> +	list_add_tail(&temp->list, &list->list);
> +	list->count++;
> +
> +	if (~flow->data_mask)
> +		printk(KERN_WARNING
> +			"User-specific data is not supported by hardware!\n");
> +	if (flow->flow_type =3D=3D IP_USER_FLOW)
> +		if (flow->m_u.usr_ip4_spec.ip_ver !=3D 255)
> +			printk(KERN_WARNING
> +				"IP-Version is not supported by hardware!\n");

That's not right; the value of ip_ver must be 4 and the mask must be 0.

[...]
> +static int gfar_process_filer_changes(struct ethtool_rx_ntuple_flow_=
spec
> *flow,
> +		struct gfar_private *priv)
> +{
> +	struct ethtool_rx_ntuple_flow_spec_container *j;
> +	struct filer_table *tab;
> +	s32 i =3D 0;
> +	s32 ret =3D 0;
> +
> +	/*So index is set to zero, too!*/
> +	tab =3D kzalloc(sizeof(struct filer_table), GFP_KERNEL);
> +	if (tab =3D=3D NULL) {
> +		printk(KERN_WARNING "Can not get memory!\n");
> +		return -ENOMEM;
> +	}
> +
> +	j =3D gfar_search_table_entry(flow, &priv->ntuple_list);
> +
> +	if (flow->action =3D=3D ETHTOOL_RXNTUPLE_ACTION_CLEAR) {
> +		if (j !=3D NULL)
> +			gfar_del_table_entry(j, &priv->ntuple_list);
> +		else {
> +			printk(KERN_WARNING
> +			"Deleting this rule is not possible,"
> +			" because it does not exist!\n");
> +			return -1;

-1 is -EPERM.  You should return -ENOENT and not log anything.

> +		}
> +	} else if (j !=3D NULL) {
> +		printk(KERN_WARNING "Adding this rule is not possible,"
> +			" because it already exists!\n");
> +		return -1;

You should return -EEXIST and not log anything.

> +	}
> +
> +	/*Now convert the existing filer data from flow_spec into
> +	* filer tables binary format*/
> +	list_for_each_entry(j, &priv->ntuple_list.list, list) {
> +		ret =3D gfar_convert_to_filer(&j->fs, tab);
> +		if (ret =3D=3D -ESWFULL) {
> +			printk(KERN_WARNING
> +			"Adding this rule is not possible,"
> +			" because there is not space left!\n");
> +			goto end;
> +		}
> +	}
[...]

I think the error code should be -EBUSY if the hardware or software
table is full.

Also, please run checkpatch.pl over your changes and fix the style
errors it finds.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

