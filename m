From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH v10 04/22] IB/hns: Add RoCE engine reset function
Date: Mon, 27 Jun 2016 11:01:22 +0300
Message-ID: <20160627080122.GA3584@leon.nu>
References: <1466087730-54856-1-git-send-email-oulijun@huawei.com>
 <1466087730-54856-5-git-send-email-oulijun@huawei.com>
 <20160624145938.GE23995@leon.nu>
 <576E5C21.5030904@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgqxwSJOaUobr8KG"
Cc: Lijun Ou <oulijun@huawei.com>, dledford@redhat.com,
	sean.hefty@intel.com, hal.rosenstock@gmail.com,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jiri@mellanox.com, ogerlitz@mellanox.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, gongyangming@huawei.com,
	xiaokun@huawei.com, tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	charles.chenxin@huawei.com, linuxarm@huawei.com
To: "Wei Hu (Xavier)" <xavier.huwei@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:59656 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751710AbcF0IBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2016 04:01:48 -0400
Content-Disposition: inline
In-Reply-To: <576E5C21.5030904@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 25, 2016 at 06:25:37PM +0800, Wei Hu (Xavier) wrote:
>=20
>=20
> On 2016/6/24 22:59, Leon Romanovsky wrote:
> >On Thu, Jun 16, 2016 at 10:35:12PM +0800, Lijun Ou wrote:
> >>This patch mainly added reset flow of RoCE engine in RoCE
> >>driver. It is necessary when RoCE is loaded and removed.
> >>
> >>Signed-off-by: Wei Hu <xavier.huwei@huawei.com>
> >>Signed-off-by: Nenglong Zhao <zhaonenglong@hisilicon.com>
> >>Signed-off-by: Lijun Ou <oulijun@huawei.com>
> >>---

=2E..

> >>+
> >>+#define SLEEP_TIME_INTERVAL				20
> >>+
> >>+extern int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool=
 enable);
> >Why did you add this extern?
> >You already exported this function.
> >drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c:EXPORT_SYMBOL(hns_dsa=
f_roce_reset);
> Hi, Leon
>=20
>         The function named hns_dsaf_roce_reset is defined in hns_dsaf_mai=
n.c
>         It exists in hns_dsaf.ko(ethernet driver)
>=20
>         RoCE driver will call this function.
>=20
>         Your suggestion is that delete "extern" as below:
>             In /drivers/infiniband/hw/hns/hns_roce_hw_v1.h:
>=20
>           int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool
> enable);
>=20
> Right? or other soultion?

You placed it in header file.
Please move it to your hns_roce_hw_v1.c file.

>=20
>=20
> Regards
> Wei Hu
> >>+
> >>+#endif
> >>diff --git a/drivers/infiniband/hw/hns/hns_roce_main.c b/drivers/infini=
band/hw/hns/hns_roce_main.c
> >>index 8924ce3..d5ccce2 100644
> >>--- a/drivers/infiniband/hw/hns/hns_roce_main.c
> >>+++ b/drivers/infiniband/hw/hns/hns_roce_main.c
> >>@@ -71,7 +71,9 @@ static int hns_roce_get_cfg(struct hns_roce_dev *hr_d=
ev)
> >>  	struct platform_device *pdev =3D NULL;
> >>  	struct resource *res;
> >>-	if (!of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
> >>+	if (of_device_is_compatible(np, "hisilicon,hns-roce-v1")) {
> >>+		hr_dev->hw =3D &hns_roce_hw_v1;
> >>+	} else {
> >>  		dev_err(dev, "device no compatible!\n");
> >>  		return -EINVAL;
> >>  	}
> >>@@ -118,6 +120,11 @@ static int hns_roce_get_cfg(struct hns_roce_dev *h=
r_dev)
> >>  	return 0;
> >>  }
> >>+static int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bool ena=
ble)
> >>+{
> >>+	return hr_dev->hw->reset(hr_dev, enable);
> >>+}
> >>+
> >>  /**
> >>  * hns_roce_probe - RoCE driver entrance
> >>  * @pdev: pointer to platform device
> >>@@ -156,6 +163,12 @@ static int hns_roce_probe(struct platform_device *=
pdev)
> >>  		goto error_failed_get_cfg;
> >>  	}
> >>+	ret =3D hns_roce_engine_reset(hr_dev, true);
> >Do you have better solution to sense device without doing full reset of
> >your hardware?
> Hi, Leon
>=20
>     In this place, we need reset RoCEE engine to ensure that RoCE engine =
can
> work correctly.
>     Hip06 Soc only support full reset RoCEE engine.
>=20
> Regards
> Wei Hu
>=20
> >
> >>+	if (ret) {
> >>+		dev_err(dev, "Reset roce engine failed!\n");
> >>+		goto error_failed_get_cfg;
> >>+	}
> >>+
> >>  error_failed_get_cfg:
> >>  	ib_dealloc_device(&hr_dev->ib_dev);
> >>@@ -170,6 +183,8 @@ static int hns_roce_remove(struct platform_device *=
pdev)
> >>  {
> >>  	struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
> >>+	(void)hns_roce_engine_reset(hr_dev, false);
> >Any reason to do explicit casting?
> Hi, Leon
>=20
> /**
>  * hns_roce_engine_reset - reset roce
>  * @hr_dev: roce device struct pointer
>  * @enable: true -- drop reset, false -- reset
>  * return 0 - success , negative --fail
>  */
> static int hns_roce_engine_reset(struct hns_roce_dev *hr_dev, bool enable=
);
>=20
> hns_roce_engine_reset->hns_roce_v1_reset->hns_dsaf_roce_reset
>=20
> The err branch of hns_roce_engine_reset as below=EF=BC=9A
> int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, bool enable)
> {
>     <...>
>     if (!is_of_node(dsaf_fwnode)) {
>         pr_err("hisi_dsaf: Only support DT node!\n");
>         return -EINVAL;
>     }
>=20
>     pdev =3D of_find_device_by_node(to_of_node(dsaf_fwnode));
>     dsaf_dev =3D dev_get_drvdata(&pdev->dev);
>     if (AE_IS_VER1(dsaf_dev->dsaf_ver)) {
>         dev_err(dsaf_dev->dev, "%s v1 chip do not support roce!\n",
>             dsaf_dev->ae_dev.name);
>         return -ENODEV;
>     }
>     <...>
> }
>=20
>    When the cpu is processing hns_roce_engine_reset(hr_dev, false),
> hns_roce_engine_reset(hr_dev, true)  have been alomost processed
> sucessfully.
>    From the err branch of hns_roce_engine_reset, we found at this time
> hns_roce_engine_reset(hr_dev, true) could not return err.
>=20
> In hns_roce_remove function, we call hns_roce_engine_reset(hr_dev, false),
> and doesn't need to judge the return value.

Do you see any compilation warning for this part of code?

    struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
+   hns_roce_engine_reset(hr_dev, false);

instead of

    struct hns_roce_dev *hr_dev =3D platform_get_drvdata(pdev);
+   (void)hns_roce_engine_reset(hr_dev, false);

--OgqxwSJOaUobr8KG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXcN1SAAoJEORje4g2clink1sQAIJi8vyye3blhJcsZ0BFnLsA
5WfLRqrCdrdS8uyNplu1Jq8OjoqxG9Pd4+bekRqpXRwS7s1QYUkLRucb+zqVR7X8
A0KCRvxoYzijVEmd+KDTg7+pI6goD66i7JUV22UryLFejLIFWU1YzBJeZTSksalR
YcbWCN9J5WBh4Ao/rxSIkXm9ugS+O3S6NtK9uJNqMn4+p10eS4Kc2rF6grzQM8ji
gWWIbmycohAee6jy4VBuDaUV6ji6mi0XeNJQMlTGlBDLgIHIvHRe0SC+rFWLBU/o
n3I8mKpgmYDfVObTbYeVemaDdaM6ndNm4XwNLkrxhrxwiLetpm8Vdw+/AC8nYnzO
VkbzYFZRZcvhqHP/l7C34ICAhVsjoHAeyX92TtuwJRz9luKlkPRm+8YspZ3pgyhS
IeLHi154fV9XuyvbOMlT/ZUf/5B6UseKn8zjRPiVcx94AgiLmWAUQkuqRss22Jhc
KRbZ1oTomHRyZm7kp+lP9sSf18SBhi7YDFLqTrAR15cQcV4A3cTy2f+VED2ElT0R
e20H6Rx8A+TsPdsQ0ZP9AofjWxAz8NtznYH+qyXd6Fy7U4SVzvbRdq6Rkb12YNNf
SGaN/ZGXDDwxn4q1xOkliNyyIyzmfu3arOROHKTjKMZFJgRFszt/YxdQhi7+6mJX
OqfrvpjU4eU0pDwdcvdf
=/aEU
-----END PGP SIGNATURE-----

--OgqxwSJOaUobr8KG--
