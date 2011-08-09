From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] gianfar: reduce stack usage in gianfar_ethtool.c
Date: Tue, 09 Aug 2011 17:43:44 +0200
Message-ID: <1312904624.2371.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1312903103-1734-1-git-send-email-wangshaoyan.pt@taobao.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, Sandeep.Kumar@freescale.com,
	Wang Shaoyan <wangshaoyan.pt@taobao.com>
To: stufever@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1312903103-1734-1-git-send-email-wangshaoyan.pt@taobao.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 09 ao=C3=BBt 2011 =C3=A0 23:18 +0800, stufever@gmail.com a =C3=
=A9crit :
> From: Wang Shaoyan <wangshaoyan.pt@taobao.com>
>=20
>   drivers/net/gianfar_ethtool.c:765: warning: the frame size of 2048 =
bytes is larger than 1024 bytes
>=20
> Signed-off-by: Wang Shaoyan <wangshaoyan.pt@taobao.com>
> ---
>  drivers/net/gianfar_ethtool.c |   26 +++++++++++++++++++++++---
>  1 files changed, 23 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_etht=
ool.c
> index 6e35069..039e9c3 100644
> --- a/drivers/net/gianfar_ethtool.c
> +++ b/drivers/net/gianfar_ethtool.c
> @@ -686,10 +686,26 @@ static int gfar_ethflow_to_filer_table(struct g=
far_private *priv, u64 ethflow, u
>  {
>  	unsigned int last_rule_idx =3D priv->cur_filer_idx;
>  	unsigned int cmp_rqfpr;
> -	unsigned int local_rqfpr[MAX_FILER_IDX + 1];
> -	unsigned int local_rqfcr[MAX_FILER_IDX + 1];
> +	unsigned int *local_rqfpr;
> +	unsigned int *local_rqfcr;
>  	int i =3D 0x0, k =3D 0x0;
>  	int j =3D MAX_FILER_IDX, l =3D 0x0;
> +	int ret =3D 1;
> +
> +	local_rqfpr =3D kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
> +		GFP_KERNEL);
> +	if (local_rqfpr) {

	if (!local_rqfpr) {

> +		pr_err("Out of memory\n");
> +		ret =3D 0;
> +		got err;
> +	}
> +	local_rqfcr =3D kmalloc(sizeof(unsigned int) * (MAX_FILER_IDX + 1),
> +		GFP_KERNEL);
> +	if (local_rqfcr) {

same here : if (!local_rqfcr) ...

> +		pr_err("Out of memory\n");
> +		ret =3D 0;
> +		goto err1;
> +	}
> =20
>  	switch (class) {
>  	case TCP_V4_FLOW:
> @@ -765,7 +781,11 @@ static int gfar_ethflow_to_filer_table(struct gf=
ar_private *priv, u64 ethflow, u
>  		priv->cur_filer_idx =3D priv->cur_filer_idx - 1;
>  	}
> =20
> -	return 1;
> +	kfree(local_rqfcr);
> +err1:
> +	kfree(local_rqfpr);
> +err:
> +	return ret;
>  }
> =20
>  static int gfar_set_hash_opts(struct gfar_private *priv, struct etht=
ool_rxnfc *cmd)
