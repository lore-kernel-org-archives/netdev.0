From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH 2/3] arch/ : Platform changes for UCC TDM driver for
 MPC8323ERDB.Also includes related QE changes.
Date: Tue, 11 Dec 2007 11:18:55 +1100
Message-ID: <20071211111855.dc5276a2.sfr@canb.auug.org.au>
References: <Pine.LNX.4.64.0712101734490.29623@linux121>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__11_Dec_2007_11_18_55_+1100_aYXMMFeJtgjYB5/J"
Cc: rubini@vision.unipv.it, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, kumar.gala@freescale.com,
	linuxppc-dev@ozlabs.org, michael.barkowski@freescale.com,
	rich.cutler@freescale.com, ashish.kalra@freescale.com
To: Poonam_Aggrwal-b10812 <b10812@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:38169 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXLKATx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 19:19:53 -0500
In-Reply-To: <Pine.LNX.4.64.0712101734490.29623@linux121>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__11_Dec_2007_11_18_55_+1100_aYXMMFeJtgjYB5/J
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 10 Dec 2007 17:39:22 +0530 (IST) Poonam_Aggrwal-b10812 <b10812@free=
scale.com> wrote:
>
> +++ b/arch/powerpc/sysdev/qe_lib/qe.c
> @@ -149,22 +149,116 @@ EXPORT_SYMBOL(qe_issue_cmd);
>   */
>  static unsigned int brg_clk =3D 0;
> =20
> -unsigned int get_brg_clk(void)
> +u32 get_brg_clk(enum qe_clock brgclk, enum qe_clock *brg_source)
>  {
> -	struct device_node *qe;
> -	if (brg_clk)
> -		return brg_clk;
> +	struct device_node *qe, *brg, *clocks;
> +	enum qe_clock brg_src;
> +	u32 brg_input_freq =3D 0;
> +	u32 brg_num;
> +	const unsigned int *prop;
> =20
> -	qe =3D of_find_node_by_type(NULL, "qe");
> -	if (qe) {
> +	*brg_source =3D 0;
> +
> +	brg_num =3D brgclk - QE_BRG1;
> +	brg =3D of_find_compatible_node(NULL, NULL, "fsl,cpm-brg");
> +	if (brg) {
>  		unsigned int size;
> -		const u32 *prop =3D of_get_property(qe, "brg-frequency", &size);
> -		brg_clk =3D *prop;
> -		of_node_put(qe);
> -	};
> +		prop =3D of_get_property(brg,
> +					"fsl,brg-sources", &size);
> +
> +		brg_src =3D *(prop + brg_num);

You should probably sanity check that prop is not NULL and points to
something large enough.

You don't use brg after here, so the "of_node_put(brg)" could go here to
save putting it in multiple places later.  Also, currently there are
paths through the following code that do not do the of_node_put(brg).

> +		if (brg_src =3D=3D 0) {
> +			*brg_source =3D 0;
> +			if (brg_clk > 0) {
> +				of_node_put(brg);
> +				return brg_clk;
> +			}
> +			qe =3D of_find_node_by_type(NULL, "qe");
> +			if (qe) {
> +				unsigned int size;
> +				prop =3D of_get_property
> +						(qe, "brg-frequency", &size);
> +				of_node_put(qe);
> +				of_node_put(brg);
> +				return *prop;

NULL check here (yes, I know that the old code didn't check).

> +			}
> +		} else {
> +			*brg_source =3D brg_src + QE_CLK1 - 1;
> +			clocks =3D of_find_compatible_node(NULL, NULL,
> +							"fsl,cpm-clocks");
> +			prop =3D of_get_property(clocks,
> +						"#clock-cells", &size);
> +			/*
> +			 * clock-cells =3D 1 only supported right now.
> +			 */
> +			if (*prop !=3D 1)

Again check for NULL (and possibly size).

> +				return 0;
> +			prop =3D of_get_property(clocks,
> +						"clock-frequency", &size);
> +
> +			brg_input_freq =3D *(prop+(brg_src - 1));

And again.

> +			of_node_put(clocks);
> +			of_node_put(brg);
> +			return brg_input_freq;
> +		}
> +	}
>  	return brg_clk;
>  }
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__11_Dec_2007_11_18_55_+1100_aYXMMFeJtgjYB5/J
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHXdd1TgG2atn1QN8RArh5AJ4z8kANPQGUw2pYDIfRI2CdvnttngCfT+pA
BH33qJqo4Ko6RxABhcfvFlo=
=PF5i
-----END PGP SIGNATURE-----

--Signature=_Tue__11_Dec_2007_11_18_55_+1100_aYXMMFeJtgjYB5/J--
