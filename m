From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #16626] Machine hangs with EIP at skb_copy_and_csum_dev
Date: Sun, 05 Sep 2010 09:49:43 +0200
Message-ID: <1283672983.3402.38.camel@edumazet-laptop>
References: <20100904203429.GA4891@del.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	"Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100904203429.GA4891-qLhEM4ewh5CNj9Bq2fkWzw@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le samedi 04 septembre 2010 =C3=A0 22:34 +0200, Jarek Poplawski a =C3=A9=
crit :

> Hi again,
>=20
> Just had a second look, and unless I miss something...
>=20
> Plamen, could you test this patch, too? (Without removing the previou=
s
> one.)
>=20
> Thanks,
> Jarek P.
>=20
> ------------------->
>=20
> [PATCH] gro: Re-fix different skb headrooms
>=20
> The patch: "gro: fix different skb headrooms" in its part:
> "2) allocate a minimal skb for head of frag_list" is buggy. The copie=
d
> skb has p->data set at the ip header at the moment, and skb_gro_offse=
t
> is the length of ip + tcp headers. So, after the change the length of
> mac header is skipped. Later skb_set_mac_header() sets it into the
> NET_SKB_PAD area (if it's long enough) and ip header is misaligned at
> NET_SKB_PAD + NET_IP_ALIGN offset. There is no reason to assume the
> original skb was wrongly allocated, so let's copy it as it was.
>=20
> bugzilla : https://bugzilla.kernel.org/show_bug.cgi?id=3D16626
> fixes commit: 3d3be4333fdf6faa080947b331a6a19bce1a4f57
>=20
> Reported-by: Plamen Petrov <pvp-lsts-s6OjJRe3oxUfI6EYonfoRA@public.gmane.org>
> Signed-off-by: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> CC: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>=20
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 26396ff..c83b421 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2706,7 +2706,7 @@ int skb_gro_receive(struct sk_buff **head, stru=
ct sk_buff *skb)
>  	} else if (skb_gro_len(p) !=3D pinfo->gso_size)
>  		return -E2BIG;
> =20
> -	headroom =3D NET_SKB_PAD + NET_IP_ALIGN;
> +	headroom =3D skb_headroom(p);
>  	nskb =3D alloc_skb(headroom + skb_gro_offset(p), GFP_ATOMIC);
>  	if (unlikely(!nskb))
>  		return -ENOMEM;

You are right, thanks for reviewing this patch again :)

By the way, NET_IP_ALIGN is now 0 on x86, so technically speaking, your
patch un-aligns IP header on x86, but thats OK, since other arches migh=
t
want it being aligned, while x86 doesnt care.

Acked-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
