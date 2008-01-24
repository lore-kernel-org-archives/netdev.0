From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 2/3] Platform changes for UCC TDM driver for
 MPC8323ERDB.Also includes related QE changes and dts entries.
Date: Thu, 24 Jan 2008 17:34:23 +1100
Message-ID: <20080124173423.6f71f016.sfr@canb.auug.org.au>
References: <Pine.LNX.4.64.0801241016440.27491@linux121>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__24_Jan_2008_17_34_23_+1100_uuyfMNofWS2a/6AR"
Cc: kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	timur@freescale.com, ashish.kalra@freescale.com
To: Poonam_Aggrwal-b10812 <b10812@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:45317 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbYAXGee (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 01:34:34 -0500
In-Reply-To: <Pine.LNX.4.64.0801241016440.27491@linux121>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__24_Jan_2008_17_34_23_+1100_uuyfMNofWS2a/6AR
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

This patch needs to come before the previous one ("UCC TDM driver for
QE based MPC83xx platforms") as that uses some of the fields defined here.

On Thu, 24 Jan 2008 10:19:44 +0530 (IST) Poonam_Aggrwal-b10812 <b10812@free=
scale.com> wrote:
>
> +u32 get_brg_clk(enum qe_clock brgclk, enum qe_clock *brg_source)
>  {

> -	struct device_node *qe;
> -	if (brg_clk)
> -		return brg_clk;
> +	struct device_node *qe, *brg, *clocks;
> +	enum qe_clock brg_src;
> +	u32 brg_input_freq =3D 0;
> +	u32 brg_num;
> +	int ret;
> +	const unsigned int *prop;
> =20
> -	qe =3D of_find_node_by_type(NULL, "qe");
> -	if (qe) {
> +	*brg_source =3D 0;
> +
> +	brg_num =3D brgclk - QE_BRG1;
> +	brg =3D of_find_compatible_node(NULL, NULL, "fsl,cpm-brg");
> +	if (brg) {

If you did
	if (!brg) {
		.
		.
		goto err;
	}
Then you would save indenting all the rest of this function.

> +		prop =3D of_get_property(brg,
> +					"fsl,brg-sources", &size);

Join these lines.

> +		of_node_put(brg);
> +
> +		if (prop)
> +			brg_src =3D *(prop + brg_num);
> +		else {
> +			printk(KERN_ERR "%s: invalid fsl,brg-sources in device "
> +				"tree\n", __FUNCTION__);
> +			ret =3D -EINVAL;
> +			goto err;
> +		}
> +		if (brg_src =3D=3D 0) {
> +			*brg_source =3D 0;
> +			if (brg_clk > 0)
> +				return brg_clk;
> +			qe =3D of_find_node_by_type(NULL, "qe");
> +			if (qe) {

Again testing (!qe) and jumping to err would save another level if
indentation.

> +				unsigned int size;
> +				prop =3D of_get_property
> +						(qe, "brg-frequency", &size);

And you wouldn't have to split things like this.

> +				if (!prop) {
> +					printk(KERN_ERR "%s: QE brg-frequency"
> +						"not present in device tree\n",
> +						 __FUNCTION__);
> +					ret =3D -EINVAL;
> +					of_node_put(qe);
> +					goto err;
> +				}
> +				if (*prop) {
> +					of_node_put(qe);
> +					brg_clk =3D *prop;
> +					return *prop;
> +				} else {

This else (and indentation) is unnecessary as you just returned above.

> +		} else {
> +			*brg_source =3D brg_src + QE_CLK1 - 1;
> +			clocks =3D of_find_compatible_node(NULL, NULL,
> +							"fsl,cpm-clocks");
> +			if (!clocks) {
> +				printk(KERN_ERR "%s: no clocks node in device"
> +					" tree \n", __FUNCTION__);
> +				ret =3D -EINVAL;
> +				goto err;
> +			} else {

Same here.

> +	} else {
> +		printk(KERN_ERR "%s: no brg node in device tree\n",
> +			 __FUNCTION__);
> +		ret =3D -EINVAL;
> +		goto err;

This goto is redundant.

> +	}
> +err: return ret;

Put the label on a line by itself and indent it one space (that means that
"diff -p will reference the funstion anem instead of the label).

> @@ -152,6 +152,10 @@ struct ucc_fast_info {
>  	enum ucc_fast_rx_decoding_method renc;
>  	enum ucc_fast_transparent_tcrc tcrc;
>  	enum ucc_fast_sync_len synl;
> +	char *tdm_rx_clk;
> +	char *tdm_tx_clk;
> +	char *tdm_rx_sync;
> +	char *tdm_tx_sync;

If you make these "const char *" you won't have to cast the results of
of_get_property() that you assign to them.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__24_Jan_2008_17_34_23_+1100_uuyfMNofWS2a/6AR
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHmDF4TgG2atn1QN8RAq+YAJ4ty7SZ/kJsAmYwa+DogdyLXnFoAwCcDQ7A
m3Z5SUtUtaOzammyQgqpeKQ=
=gFCT
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Jan_2008_17_34_23_+1100_uuyfMNofWS2a/6AR--
