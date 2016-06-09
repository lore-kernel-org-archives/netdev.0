From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v9 11/22] IB/hns: Add IB device registration
Date: Thu, 9 Jun 2016 09:26:31 +0300
Message-ID: <20160609062631.GN3663@leon.nu>
References: <1464795484-77395-1-git-send-email-oulijun@huawei.com>
 <1464795484-77395-12-git-send-email-oulijun@huawei.com>
Reply-To: leon@kernel.org
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Y4VYWfdFdHwFhC6D"
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50838 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753622AbcFIG0y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 02:26:54 -0400
Content-Disposition: inline
In-Reply-To: <1464795484-77395-12-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Y4VYWfdFdHwFhC6D
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 01, 2016 at 11:37:53PM +0800, Lijun Ou wrote:
> This patch registered IB device when loaded, and unregistered
> IB device when removed.
>=20
> Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> ---
>  drivers/infiniband/hw/hns/hns_roce_main.c | 46 +++++++++++++++++++++++++=
++++++
>  1 file changed, 46 insertions(+)
>=20
> diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infiniba=
nd/hw/hns/hns_roce_main.c
> index 7fb0d34..f179a7f 100644
> --- a/drivers/infiniband/hw/hns/hns_roce_main.c
> +++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> @@ -62,6 +62,41 @@
>  #include "hns_roce_device.h"
>  #include "hns_roce_icm.h"
> =20
> +void hns_roce_unregister_device(struct hns_roce_dev *hr_dev)

You are not calling to this function in this patch.

> +{
> +	ib_unregister_device(&hr_dev->ib_dev);
> +}
> +
> +int hns_roce_register_device(struct hns_roce_dev *hr_dev)

This function should be static.

> +{
> +	int ret;
> +	struct hns_roce_ib_iboe *iboe =3D NULL;
> +	struct ib_device *ib_dev =3D NULL;
> +	struct device *dev =3D &hr_dev->pdev->dev;
> +
> +	iboe =3D &hr_dev->iboe;
> +
> +	ib_dev =3D &hr_dev->ib_dev;
> +	strlcpy(ib_dev->name, "hisi_%d", IB_DEVICE_NAME_MAX);
> +
> +	ib_dev->owner			=3D THIS_MODULE;
> +	ib_dev->node_type		=3D RDMA_NODE_IB_CA;
> +	ib_dev->dma_device		=3D dev;
> +
> +	ib_dev->phys_port_cnt		=3D hr_dev->caps.num_ports;
> +	ib_dev->local_dma_lkey		=3D hr_dev->caps.reserved_lkey;
> +	ib_dev->num_comp_vectors	=3D hr_dev->caps.num_comp_vectors;
> +	ib_dev->uverbs_abi_ver		=3D 1;
> +
> +	ret =3D ib_register_device(ib_dev, NULL);
> +	if (ret) {
> +		dev_err(dev, "ib_register_device failed!\n");
> +		return ret;
> +	}
> +
> +	return 0;
> +}
> +
>  int hns_roce_get_cfg(struct hns_roce_dev *hr_dev)
>  {
>  	int i;
> @@ -363,6 +398,17 @@ static int hns_roce_probe(struct platform_device *pd=
ev)
>  		goto error_failed_engine_init;
>  	}
> =20
> +	ret =3D hns_roce_register_device(hr_dev);
> +	if (ret) {
> +		dev_err(dev, "register_device failed!\n");

According to the current code, you will print this error together with
error line in hns_roce_register_device for the same failure.

"ib_register_device failed!"
"register_device failed!"

> +		goto error_failed_register_device;
> +	}
> +
> +	return 0;
> +
> +error_failed_register_device:
> +	hns_roce_engine_exit(hr_dev);
> +
>  error_failed_engine_init:
>  	hns_roce_cleanup_bitmap(hr_dev);
> =20
> --=20
> 1.9.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--Y4VYWfdFdHwFhC6D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXWQwXAAoJEORje4g2clin7vEP/1rLiLZjbw7DUSlFZIjKMCGj
PDyZEf+JOn+WAzePp+DLCmdLxYng9lyLfGzamXXjl/ynGG0VJ30PVftKu984ohyr
h4zTwDRnsZLq0dYCXodjOdtc4LmvidTrqp04bPff/A1vAQpLth+kbw+wvLYSXiuv
W0d2MndeWhxbLmF83ueonTw+bubBTI9bzSAHRoKlzZjBaKlig59Ai7NlfMZ257dt
49VEDj89OtPL+u/fwC2RZ0nHVJkEjytWmnPI0aZcd5nITVbXSoFmXa7hEJte+SzK
AfyIAl6EGANyxcsaylh2110UjPXqvTBnO2hAlRnLf96ZJGv32xfz2YD8E2aJTVqV
3zJ2bBA3Db4xAXJykS8cVzduUyizOC2Weg7VNk/y/zjitQgdK3Jil3bWII4Ln+OQ
VQL4f8vYm0EkubmadK8FzSwDEeSIt5Xz+6TGGNs7Cj2yV5Zv1Rv7OM8DF2ROQ7sh
sv6pd/AsbgngP3gF0mSTBcrC9g0GGGo9wjH6cphr0XYs5oYVLMn9/ZHx1YTbDWxG
V6BLFCxFZcORQQe1Cm6uvk/K9j/woXqtTdD566WGmFdE/RB+lCz4RsoFttBBxq7H
3PskdV8Q6NDCE1oPn2e7fh/+vU5WnDeFo6Vg+vkwYIljeEeQgJdExEZNI6jKgMOF
bsT0dG+eJXsJdIwZj6nz
=hPeh
-----END PGP SIGNATURE-----

--Y4VYWfdFdHwFhC6D--
