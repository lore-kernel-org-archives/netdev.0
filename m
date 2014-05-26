From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 net-next 1/2] enic: Add support for adaptive
 interrupt coalescing
Date: Mon, 26 May 2014 18:42:15 +0100
Message-ID: <1401126135.17377.134.camel@deadeye.wl.decadent.org.uk>
References: <1400535845-13400-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Jl02Lnlyk92admSh19TD"
Cc: davem@davemloft.net, netdev@vger.kernel.org, benve@cisco.com,
	neepatel@cisco.com, ssujith@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54335 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751202AbaEZRmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 13:42:52 -0400
In-Reply-To: <1400535845-13400-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Jl02Lnlyk92admSh19TD
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-05-20 at 03:14 +0530, Govindarajulu Varadarajan wrote:
[...]
> @@ -191,17 +207,31 @@ static int enic_set_coalesce(struct net_device *net=
dev,
>  	struct enic *enic =3D netdev_priv(netdev);
>  	u32 tx_coalesce_usecs;
>  	u32 rx_coalesce_usecs;
> +	u32 rx_coalesce_usecs_low;
> +	u32 rx_coalesce_usecs_high;
> +	u32 coalesce_usecs_max;
>  	unsigned int i, intr;
> +	struct enic_rx_coal *rxcoal =3D &enic->rx_coalesce_setting;
> =20
> +	coalesce_usecs_max =3D vnic_dev_get_intr_coal_timer_max(enic->vdev);
>  	tx_coalesce_usecs =3D min_t(u32, ecmd->tx_coalesce_usecs,
> -		vnic_dev_get_intr_coal_timer_max(enic->vdev));
> +				  coalesce_usecs_max);
>  	rx_coalesce_usecs =3D min_t(u32, ecmd->rx_coalesce_usecs,
> -		vnic_dev_get_intr_coal_timer_max(enic->vdev));
> +				  coalesce_usecs_max);
> +
> +	rx_coalesce_usecs_low =3D min_t(u32, ecmd->rx_coalesce_usecs_low,
> +				      coalesce_usecs_max);
> +	rx_coalesce_usecs_high =3D min_t(u32, ecmd->rx_coalesce_usecs_high,
> +				       coalesce_usecs_max);
> =20
>  	switch (vnic_dev_get_intr_mode(enic->vdev)) {
>  	case VNIC_DEV_INTR_MODE_INTX:
>  		if (tx_coalesce_usecs !=3D rx_coalesce_usecs)
>  			return -EINVAL;
> +		if (ecmd->use_adaptive_rx_coalesce	||
> +		    ecmd->rx_coalesce_usecs_low		||
> +		    ecmd->rx_coalesce_usecs_high)
> +			return -EOPNOTSUPP;

-EINVAL, please.  The operation (set coalescing parameters) is
supported, just not these particular arguments.

>  		intr =3D enic_legacy_io_intr();
>  		vnic_intr_coalescing_timer_set(&enic->intr[intr],
> @@ -210,6 +240,10 @@ static int enic_set_coalesce(struct net_device *netd=
ev,
>  	case VNIC_DEV_INTR_MODE_MSI:
>  		if (tx_coalesce_usecs !=3D rx_coalesce_usecs)
>  			return -EINVAL;
> +		if (ecmd->use_adaptive_rx_coalesce	||
> +		    ecmd->rx_coalesce_usecs_low		||
> +		    ecmd->rx_coalesce_usecs_high)
> +			return -EOPNOTSUPP;

-EINVAL again.
=20
>  		vnic_intr_coalescing_timer_set(&enic->intr[0],
>  			tx_coalesce_usecs);
> @@ -221,12 +255,27 @@ static int enic_set_coalesce(struct net_device *net=
dev,
>  				tx_coalesce_usecs);
>  		}
> =20
> -		for (i =3D 0; i < enic->rq_count; i++) {
> -			intr =3D enic_msix_rq_intr(enic, i);
> -			vnic_intr_coalescing_timer_set(&enic->intr[intr],
> -				rx_coalesce_usecs);
> +		if (rxcoal->use_adaptive_rx_coalesce) {
> +			if (!ecmd->use_adaptive_rx_coalesce) {
> +				rxcoal->use_adaptive_rx_coalesce =3D 0;
> +				enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
> +			}
> +		} else {
> +			if (ecmd->use_adaptive_rx_coalesce)
> +				rxcoal->use_adaptive_rx_coalesce =3D 1;
> +			else
> +				enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
>  		}

This seems to be an overly complicated way of writing:

		rxcoal->use_adaptive_rx_coalesce =3D !!ecmd->use_adaptive_rx_coalesce;
		if (!rxcoal->use_adaptive_rx_coalesce)
			enic_intr_coal_set_rx(enic, rx_coalesce_usecs);

> +		if (ecmd->rx_coalesce_usecs_high) {
> +			if (rx_coalesce_usecs_high <
> +			    (rx_coalesce_usecs_low + ENIC_AIC_LARGE_PKT_DIFF))
> +				return -EINVAL;
[...]

It's a bit late to detect invalid arguments when you've already started
applying changes.

Ben.

--=20
Ben Hutchings
Humans are not rational beings; they are rationalising beings.

--=-Jl02Lnlyk92admSh19TD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUAU4N8/ee/yOyVhhEJAQqRmw//cHVpsquqAWi3Hnw41ig4sJmVPsjQJ0WN
ODFBn/JmAgkJjIa1vrB5VBe0E/Ajiksxtph2ETPFtj/X6I8WycPGV1NqTO52EwmZ
cGydLT5q2os7GkbntihikzZq0+w/fB5zcvzupFUEMW86ttdUoEqxKlfv5G5yEGlX
TSqxyk+3TC7UwjNPMzDBkaUeOms6mhSbawTe9QA3I4OvPd72UoynTgBverRfWZBz
ulPcUvMdcMPkI77mNziMMQML1RR8kH3WfeGoNa3gnGxc0Sohbx1v9fsOGRtvvIoc
vUcodHbDjuzoO2e/oO8Ep+UeifGsHKcoNQwUX3s7AlmcXqyEMmQP73akX89gdWjz
MXYUwKpFcxZA4DZu4DN6gVe0RFM/msBsP1tewLggbJOULANGW1ezCI49jSrwPbdo
NklrcPM3hDPkRcvkhkuSSyGVeaHpKpg37YmFmK0Fcjq88VPZQU1INel6bm1HCI8B
NnjuV5+ClHPG83fI3j7CyZjVLHu54e23iwQB2HlfjGrlyC9QWzdT4ovDOe1TeFQ2
37ovrhrQxP4Ui8IRIo2RCQOVCtSPDJu1HsNqMLRUIqtbf+PAjrf7gulUYAsY/mhb
8nknYiUdfo+LmVnlrvcVI9LI7PMp+6WOxiLtGhcVI7tgi+4yXc7GQXi/LLlGl3QA
q6LPY9TDXRw=
=91Nn
-----END PGP SIGNATURE-----

--=-Jl02Lnlyk92admSh19TD--
