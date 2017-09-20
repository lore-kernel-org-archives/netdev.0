From: =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>
Subject: Re: [PATCH v2 1/3] can: m_can: Make hclk optional
Date: Thu, 21 Sep 2017 00:00:01 +0200
Message-ID: <096c73b1-eaa5-8c40-4486-e08a784c0897@gmx.net>
References: <20170724225142.19975-1-fcooper@ti.com>
 <20170724225142.19975-2-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="wefDJUqxLH21jSrudeGjVQH84FqTTeP80"
To: Franklin S Cooper Jr <fcooper@ti.com>,
        linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org, linux-can@vger.kernel.org,
        wg@grandegger.com, mkl@pengutronix.de, robh+dt@kernel.org,
        quentin.schulz@free-electrons.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170724225142.19975-2-fcooper@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--wefDJUqxLH21jSrudeGjVQH84FqTTeP80
Content-Type: multipart/mixed; boundary="aPHjf94lsGt7w3KL4fNvD97fIDMLNXMGn";
 protected-headers="v1"
From: =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>
To: Franklin S Cooper Jr <fcooper@ti.com>, linux-kernel@vger.kernel.org,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 linux-can@vger.kernel.org, wg@grandegger.com, mkl@pengutronix.de,
 robh+dt@kernel.org, quentin.schulz@free-electrons.com
Message-ID: <096c73b1-eaa5-8c40-4486-e08a784c0897@gmx.net>
Subject: Re: [PATCH v2 1/3] can: m_can: Make hclk optional
References: <20170724225142.19975-1-fcooper@ti.com>
 <20170724225142.19975-2-fcooper@ti.com>
In-Reply-To: <20170724225142.19975-2-fcooper@ti.com>

--aPHjf94lsGt7w3KL4fNvD97fIDMLNXMGn
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US

> Hclk is the MCAN's interface clock. However, for OMAP based devices suc=
h as
> DRA7 SoC family the interface clock is handled by hwmod. Therefore, thi=
s
> interface clock is managed by hwmod driver via pm_runtime_get and
> pm_runtime_put calls. Therefore, this interface clock isn't defined in =
DT
> and thus the driver shouldn't fail if this clock isn't found.
I also agree in this point.
However, there's a problem I want to point out:

The M_CAN can only function correctly, if the condition
'hclk >=3D cclk' holds true.

The internal clock domain crossing can fail if this condition
is violated.

I thought about adding the condition to the driver to ensure
correct operation. But I had some problems:

1. Determine the clock rates:
=C2=A0=C2=A0=C2=A0 The devices you've mentioned above don't have an assig=
ned
=C2=A0=C2=A0=C2=A0 hclk. Is there still a possibility to get the clock fr=
equency?

2. What to do if 'hclk < cclk'?
=C2=A0=C2=A0=C2=A0 Is there a general way to process such an error? - I t=
hink not.
=C2=A0 =C2=A0 Is a simple warning in case of an error enough?

Is there a way of ensuring that the condition is always met at all?

I think it is quite unlikely that the condition is violated, because
devices that actually run Linux usually have (bus) clock rates that
are high enough to ensure the correct operation.

Would it be safe to just ignore this possible fault?

Regards

Mario
=C2=A0=C2=A0=C2=A0
>
> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
> ---
> Version 2 changes:
> Used NULL instead of 0 for unused hclk handle
>
>  drivers/net/can/m_can/m_can.c | 9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_ca=
n.c
> index f4947a7..ea48e59 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -1568,8 +1568,13 @@ static int m_can_plat_probe(struct platform_devi=
ce *pdev)
>  	hclk =3D devm_clk_get(&pdev->dev, "hclk");
>  	cclk =3D devm_clk_get(&pdev->dev, "cclk");
> =20
> -	if (IS_ERR(hclk) || IS_ERR(cclk)) {
> -		dev_err(&pdev->dev, "no clock found\n");
> +	if (IS_ERR(hclk)) {
> +		dev_warn(&pdev->dev, "hclk could not be found\n");
> +		hclk =3D NULL;
> +	}
> +
> +	if (IS_ERR(cclk)) {
> +		dev_err(&pdev->dev, "cclk could not be found\n");
>  		ret =3D -ENODEV;
>  		goto failed_ret;
>  	}



--aPHjf94lsGt7w3KL4fNvD97fIDMLNXMGn--

--wefDJUqxLH21jSrudeGjVQH84FqTTeP80
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEwjdBGUhyDYwF3W3ckaOeH7OEy/0FAlnC5OEACgkQkaOeH7OE
y/3bKg/9F/WWcKrRmarFRDObIc6o+EsV/Y6FnWtYVTPb5p9NszOkbSZ20OqGPvTX
q4haOS6A3zZYHt8StKpnY7QtKjdxRw+X2LEsppNquvVuhYEuQya793d8NzW576fW
LX7N7LKH7Ax/op8Xv+3vo3lI/2Bpc9out3BFnOTPrddlTk151+quG8fi1ssub8nG
p2K4RMeaVhT9YCiszMlEl/nUHM8z5WoP0GFTS8llu1CygoXF1k94CbUXML4XmLlL
kDkwJye4UqgZiFsJi0ZrKgUhnrXU3perYoouUtwyJcrAt1d7RLCRnCMvxxRI+8Ec
wdFSXh2fZr2bgxHJfuN3+eb0VHmic5q9wiqW4SA2eDFXh9y6Tc/3U09EtAomuzD4
+bsmDP8p8TsUjMOt75f9IG6/1239VBVOQDsEThh8Ll0eFDWhvKgajnanRSIW/hea
KIqg4zpKgwqFt/3T+weQO6zaHzxnjKJQPsg1V2gfeY14oe5QClTlfiyZQ8E0JXzP
jMfiZPyEdBsQ/tZVFhNJ1z1YcS64LeTCXKOaMW/tSsM4c/TidtImBZmq4kd6yRKd
xGRq8EyVLvrWcOaQh++uRahzpPV0sckW0EaRZYtgR89LocEC3L9604CEFYHKuAuN
ubbEXbhkqfaEbo1wwO019MTiqUNPkLW4D0H0w+9hp4a09SuGUA8=
=MTvU
-----END PGP SIGNATURE-----

--wefDJUqxLH21jSrudeGjVQH84FqTTeP80--
