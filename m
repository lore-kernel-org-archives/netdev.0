From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH] UCC TDM driver for QE based MPC83xx platforms.
Date: Thu, 24 Jan 2008 17:19:20 +1100
Message-ID: <20080124171920.49d805cb.sfr@canb.auug.org.au>
References: <Pine.LNX.4.64.0801241014240.27491@linux121>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__24_Jan_2008_17_19_20_+1100_M8q4g+u4cutXlxEd"
Cc: kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	timur@freescale.com, ashish.kalra@freescale.com
To: Poonam_Aggrwal-b10812 <b10812@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:58712 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752985AbYAXGT3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2008 01:19:29 -0500
In-Reply-To: <Pine.LNX.4.64.0801241014240.27491@linux121>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Thu__24_Jan_2008_17_19_20_+1100_M8q4g+u4cutXlxEd
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 24 Jan 2008 10:16:42 +0530 (IST) Poonam_Aggrwal-b10812 <b10812@free=
scale.com> wrote:
>
> +static int ucc_tdm_probe(struct of_device *ofdev,
> +			 const struct of_device_id *match)
> +{
> +	struct device_node *np =3D ofdev->node;
> +	struct resource res;
> +	const unsigned int *prop;
> +	u32 ucc_num, device_num, err, ret =3D 0;
> +	struct device_node *np_tmp =3D NULL;

You don't need to initialise this.

> +	dma_addr_t physaddr;
> +	void *tdm_buff;
> +	struct ucc_tdm_info *ut_info;
> +
> +	prop =3D of_get_property(np, "device-id", NULL);

You should check for (prop =3D=3D NULL).

> +	ucc_num =3D *prop - 1;
> +	if ((ucc_num < 0) || (ucc_num > 7))
> +		return -ENODEV;
> +
> +	ut_info =3D &utdm_info[ucc_num];
> +	if (ut_info =3D=3D NULL) {

This cannot be NULL as you have just taken the address of an array
element.

> +	tdm_ctrl[device_num]->ut_info =3D ut_info;
> +
> +	tdm_ctrl[device_num]->ut_info->uf_info.ucc_num =3D ucc_num;
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
This is the same as "ut_info".

> +	tdm_ctrl[device_num]->ut_info->uf_info.tdm_tx_clk =3D
> +			(char *) of_get_property(np, "fsl,tdm-tx-clk", NULL);
                                ^
We don't normall put spaces here.

> +	tdm_ctrl[device_num]->ut_info->uf_info.tdm_rx_clk =3D
> +			(char *) of_get_property(np, "fsl,tdm-rx-clk", NULL);
                                ^
Ditto. And later as well.

> +	tdm_ctrl[device_num]->ut_info->uf_info.irq =3D
> +					irq_of_parse_and_map(np, 0);
> +	err =3D of_address_to_resource(np, 0, &res);
> +	if (err) {
> +		ret =3D EINVAL;

This should be -EINVAL or err.

> +		goto get_property_error;

You need to do something about unmapping the irq in the error path.

> +	tdm_ctrl[device_num]->uf_regs =3D of_iomap(np, 0);
> +
> +	np_tmp =3D of_find_compatible_node(np_tmp, "slic", "legerity-slic");
> +	if (np_tmp !=3D NULL)
> +		tdm_ctrl[device_num]->leg_slic =3D 1;
> +	else
> +		tdm_ctrl[device_num]->leg_slic =3D 0;

	of_node_ut(np_tmp);

> +	tdm_buff =3D dma_alloc_coherent(NULL, 2 * NR_BUFS * SAMPLE_DEPTH *
> +				tdm_ctrl[device_num]->cfg_ctrl.active_num_ts,
> +					&physaddr, GFP_KERNEL);
> +	if (!tdm_buff) {
> +		printk(KERN_ERR "ucc-tdm: could not allocate buffer"
> +					"descriptors\n");
> +		ret =3D -ENOMEM;
> +		goto get_property_error;

You need to unmap the uf_regs in the error path.

> +get_property_error:
> +	kfree(tdm_ctrl[device_num]);

Do you need to set "tdm_ctrl[device_num]" to NULL and decrement
num_tdm_devices?

> +	return ret;
> +}
> +
> +static int ucc_tdm_remove(struct of_device *ofdev)
> +{
> +	struct tdm_ctrl *tdm_c;
> +	struct ucc_tdm_info *ut_info;
> +	u32 ucc_num;
> +
> +	tdm_c =3D dev_get_drvdata(&(ofdev->dev));

	dev_set_drvdata(&of_dev->dev, NULL);

> +	ucc_num =3D tdm_c->ut_info->uf_info.ucc_num;
> +	ut_info =3D &utdm_info[ucc_num];
> +	tdm_stop(tdm_c);
> +	tdm_deinit(tdm_c);
> +
> +	ucc_fast_free(tdm_c->uf_private);
> +
> +	dma_free_coherent(NULL, 2 * NR_BUFS * SAMPLE_DEPTH *
> +				tdm_c->cfg_ctrl.active_num_ts,
> +				tdm_c->tdm_input_data,
> +				tdm_c->dma_input_addr);
> +

You need to unmap the uf_reg and the irq.

> +static struct of_device_id ucc_tdm_match[] =3D {

const, please.

> +	{
> +	 .type =3D "tdm",
> +	 .compatible =3D "fsl,ucc-tdm",
> +	 }, {},

We euld normall format this like:

	{ .type =3D "tdm", .compatible =3D "fsl,ucc-tdm", },
	{},

> +static struct of_platform_driver ucc_tdm_driver =3D {

	.driver =3D {

> +	.name =3D DRV_NAME,

	},

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__24_Jan_2008_17_19_20_+1100_M8q4g+u4cutXlxEd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHmC3sTgG2atn1QN8RAgXGAJ4uMTjBoYK8ZY3LkcspcHfPKuvyEgCeOkVE
mWEA3F5o5j/zT6OiVoK6aic=
=y4E+
-----END PGP SIGNATURE-----

--Signature=_Thu__24_Jan_2008_17_19_20_+1100_M8q4g+u4cutXlxEd--
