From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net 1/2] tuntap: limit head length of skb allocated
Date: Tue, 12 Nov 2013 09:21:12 -0500 (EST)
Message-ID: <857673324.22319676.1384266072168.JavaMail.root@redhat.com>
References: <1384250577-20330-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com, stefanha@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384250577-20330-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



----- =E5=8E=9F=E5=A7=8B=E9=82=AE=E4=BB=B6 -----
> We currently use hdr_len as a hint of head length which is advertised=
 by
> guest. But when guest advertise a very big value, it can lead to an 6=
4K+
> allocating of kmalloc() which has a very high possibility of failure =
when
> host
> memory is fragmented or under heavy stress. The huge hdr_len also red=
uce the
> effect of zerocopy or even disable if a gso skb is linearized in gues=
t.
>=20
> To solves those issues, this patch introduces an upper limit (PAGE_SI=
ZE) of
> the
> head, which guarantees an order 0 allocation each time.
>=20
> Cc: Stefan Hajnoczi <stefanha@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> The patch was needed for stable.
> ---
>  drivers/net/tun.c | 5 +++++
>  1 file changed, 5 insertions(+)
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 7cb105c..5537b65 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -954,6 +954,11 @@ static struct sk_buff *tun_alloc_skb(struct tun_=
file
> *tfile,
>  	struct sock *sk =3D tfile->socket.sk;
>  	struct sk_buff *skb;
>  	int err;
> +	int good_linear =3D SKB_MAX_HEAD(prepad);
> +
> +	/* Don't use huge linear part */
> +	if (linear > good_linear)
> +		linear =3D good_linear;
> =20
>  	/* Under a page?  Don't bother with paged skb. */
>  	if (prepad + len < PAGE_SIZE || !linear)
> --
> 1.8.3.2
>=20

Looks like reduce the linear here will cause callers' iov_pages() under=
 estimation.
Will send V2.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>=20
