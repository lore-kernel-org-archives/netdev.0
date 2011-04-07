From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next] net: fix skb_add_data_nocache() to calc csum correctly
Date: Wed, 6 Apr 2011 21:50:55 -0700
Message-ID: <BANLkTikspQHnjagFme0S3GdPUo-zw48zBw@mail.gmail.com>
References: <4D9D402C.60107@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:8226 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750941Ab1DGEvB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 00:51:01 -0400
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id p374oxtE031441
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 21:51:00 -0700
Received: from pxi2 (pxi2.prod.google.com [10.243.27.2])
	by hpaq6.eem.corp.google.com with ESMTP id p374ouwu029481
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2011 21:50:57 -0700
Received: by pxi2 with SMTP id 2so1162934pxi.38
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 21:50:56 -0700 (PDT)
In-Reply-To: <4D9D402C.60107@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nice catch.

Acked-by: Tom Herbert <therbert@google.com>

On Wed, Apr 6, 2011 at 9:40 PM, Wei Yongjun <yjwei@cn.fujitsu.com> wrot=
e:
> commit c6e1a0d12ca7b4f22c58e55a16beacfb7d3d8462 broken the calc
> =A0(net: Allow no-cache copy from user on transmit)
> of checksum, which may cause some tcp packets be dropped because
> incorrect checksum. ssh does not work under today's net-next-2.6
> tree.
>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> ---
> =A0include/net/sock.h | =A0 15 ++++++++-------
> =A01 files changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 43bd515..9cbf23c 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -1392,14 +1392,14 @@ static inline void sk_nocaps_add(struct sock =
*sk, int flags)
>
> =A0static inline int skb_do_copy_data_nocache(struct sock *sk, struct=
 sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 char __user *from, char *to,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0int copy)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0int copy, int offset)
> =A0{
> =A0 =A0 =A0 =A0if (skb->ip_summed =3D=3D CHECKSUM_NONE) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int err =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__wsum csum =3D csum_and_copy_from_use=
r(from, to, copy, 0, &err);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->csum =3D csum_block_add(skb->csum,=
 csum, skb->len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb->csum =3D csum_block_add(skb->csum,=
 csum, offset);
> =A0 =A0 =A0 =A0} else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!access_ok(VERIFY_READ, from, copy=
) ||
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__copy_from_user_nocache(to, f=
rom, copy))
> @@ -1413,11 +1413,12 @@ static inline int skb_do_copy_data_nocache(st=
ruct sock *sk, struct sk_buff *skb,
> =A0static inline int skb_add_data_nocache(struct sock *sk, struct sk_=
buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 char __user *from, int copy)
> =A0{
> - =A0 =A0 =A0 int err;
> + =A0 =A0 =A0 int err, offset =3D skb->len;
>
> - =A0 =A0 =A0 err =3D skb_do_copy_data_nocache(sk, skb, from, skb_put=
(skb, copy), copy);
> + =A0 =A0 =A0 err =3D skb_do_copy_data_nocache(sk, skb, from, skb_put=
(skb, copy),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0copy, offset);
> =A0 =A0 =A0 =A0if (err)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __skb_trim(skb, skb->len);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __skb_trim(skb, offset);
>
> =A0 =A0 =A0 =A0return err;
> =A0}
> @@ -1429,8 +1430,8 @@ static inline int skb_copy_to_page_nocache(stru=
ct sock *sk, char __user *from,
> =A0{
> =A0 =A0 =A0 =A0int err;
>
> - =A0 =A0 =A0 err =3D skb_do_copy_data_nocache(sk, skb, from,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0page_address(page) + off, copy);
> + =A0 =A0 =A0 err =3D skb_do_copy_data_nocache(sk, skb, from, page_ad=
dress(page) + off,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0copy, skb->len);
> =A0 =A0 =A0 =A0if (err)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return err;
>
> --
> 1.6.5.2
>
>
>
