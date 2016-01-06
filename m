From: Yisen Zhuang <Yisen.zhuang@huawei.com>
Subject: Re: [PATCH] net: hns: avoid uninitialized variable warning:
Date: Wed, 6 Jan 2016 08:56:01 +0800
Message-ID: <568C6621.5090500@huawei.com>
References: <6649249.INrAY8KJG0@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<yankejian@huawei.com>, <lisheng011@huawei.com>,
	<huangdaode@hisilicon.com>, <salil.mehta@huawei.com>,
	<linux-arm-kernel@lists.infradead.org>
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6649249.INrAY8KJG0@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



=E5=9C=A8 2016/1/2 6:27, Arnd Bergmann =E5=86=99=E9=81=93:
> gcc fails to see that the use of the 'last_offset' variable
> in hns_nic_reuse_page() is used correctly and issues a bogus
> warning:
>=20
> drivers/net/ethernet/hisilicon/hns/hns_enet.c: In function 'hns_nic_r=
euse_page':
> drivers/net/ethernet/hisilicon/hns/hns_enet.c:541:6: warning: 'last_o=
ffset' may be used uninitialized in this function [-Wmaybe-uninitialize=
d]
>=20
> This simplifies the function to make it more obvious what is
> going on to both readers and compilers, which makes the warning
> go away.
>=20


Hi Arnd,

This patch is fine to me.

Many thanks,
Yisen

> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> ---
> Compile-tested only, and complex enough that this requires a proper
> review and testing before it gets apply. Please have a look at this.
>=20
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/=
net/ethernet/hisilicon/hns/hns_enet.c
> index 5a81dafd725e..0e30846a24f8 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
> @@ -499,50 +499,47 @@ static void hns_nic_reuse_page(struct sk_buff *=
skb, int i,
>  	struct hnae_desc *desc;
>  	int truesize, size;
>  	int last_offset;
> +	bool twobufs;
> +
> +	twobufs =3D ((PAGE_SIZE < 8192) && hnae_buf_size(ring) =3D=3D HNS_B=
UFFER_SIZE_2048);
> =20
>  	desc =3D &ring->desc[ring->next_to_clean];
>  	size =3D le16_to_cpu(desc->rx.size);
> =20
> -#if (PAGE_SIZE < 8192)
> -	if (hnae_buf_size(ring) =3D=3D HNS_BUFFER_SIZE_2048) {
> +	if (twobufs) {
>  		truesize =3D hnae_buf_size(ring);
>  	} else {
>  		truesize =3D ALIGN(size, L1_CACHE_BYTES);
>  		last_offset =3D hnae_page_size(ring) - hnae_buf_size(ring);
>  	}
> =20
> -#else
> -	truesize =3D ALIGN(size, L1_CACHE_BYTES);
> -	last_offset =3D hnae_page_size(ring) - hnae_buf_size(ring);
> -#endif
> -
>  	skb_add_rx_frag(skb, i, desc_cb->priv, desc_cb->page_offset + pull_=
len,
>  			size - pull_len, truesize - pull_len);
> =20
>  	 /* avoid re-using remote pages,flag default unreuse */
> -	if (likely(page_to_nid(desc_cb->priv) =3D=3D numa_node_id())) {
> -#if (PAGE_SIZE < 8192)
> -		if (hnae_buf_size(ring) =3D=3D HNS_BUFFER_SIZE_2048) {
> -			/* if we are only owner of page we can reuse it */
> -			if (likely(page_count(desc_cb->priv) =3D=3D 1)) {
> -				/* flip page offset to other buffer */
> -				desc_cb->page_offset ^=3D truesize;
> -
> -				desc_cb->reuse_flag =3D 1;
> -				/* bump ref count on page before it is given*/
> -				get_page(desc_cb->priv);
> -			}
> -			return;
> -		}
> -#endif
> -		/* move offset up to the next cache line */
> -		desc_cb->page_offset +=3D truesize;
> +	if (unlikely(page_to_nid(desc_cb->priv) !=3D numa_node_id()))
> +		return;
> +
> +	if (twobufs) {
> +		/* if we are only owner of page we can reuse it */
> +		if (likely(page_count(desc_cb->priv) =3D=3D 1)) {
> +			/* flip page offset to other buffer */
> +			desc_cb->page_offset ^=3D truesize;
> =20
> -		if (desc_cb->page_offset <=3D last_offset) {
>  			desc_cb->reuse_flag =3D 1;
>  			/* bump ref count on page before it is given*/
>  			get_page(desc_cb->priv);
>  		}
> +		return;
> +	}
> +
> +	/* move offset up to the next cache line */
> +	desc_cb->page_offset +=3D truesize;
> +
> +	if (desc_cb->page_offset <=3D last_offset) {
> +		desc_cb->reuse_flag =3D 1;
> +		/* bump ref count on page before it is given*/
> +		get_page(desc_cb->priv);
>  	}
>  }
> =20
>=20
>=20
> .
>=20
