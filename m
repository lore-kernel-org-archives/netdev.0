From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Regression, bisected: reference leak with IPSec since ~2.6.31
Date: Tue, 21 Sep 2010 13:58:30 +0200
Message-ID: <1285070310.2617.359.camel@edumazet-laptop>
References: <20100921091248.GA8424@ff.dom.local>
	 <1285060860.2617.158.camel@edumazet-laptop>
	 <20100921093853.GA8664@ff.dom.local>
	 <1285062948.2617.204.camel@edumazet-laptop>
	 <1285063657.2617.226.camel@edumazet-laptop>
	 <20100921104821.GA8986@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nick Bowler <nbowler@elliptictech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100921104821.GA8986@ff.dom.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 21 septembre 2010 =C3=A0 10:48 +0000, Jarek Poplawski a =C3=A9=
crit :

> But if you were honest about caches there is no reason to be smart
> no more. ;-)
>=20
> Below is your patch mostly as an example only that I didn't mean
> nothing complex (ipv4 only, not compiled).
>=20
> Jarek P.
> ---
>=20
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 04b6989..049d61f 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -490,7 +490,6 @@ int ip_fragment(struct sk_buff *skb, int (*output=
)(struct sk_buff *))
>  	if (skb_has_frags(skb)) {
>  		struct sk_buff *frag;
>  		int first_len =3D skb_pagelen(skb);
> -		int truesizes =3D 0;
> =20
>  		if (first_len - hlen > mtu ||
>  		    ((first_len - hlen) & 7) ||
> @@ -503,18 +502,18 @@ int ip_fragment(struct sk_buff *skb, int (*outp=
ut)(struct sk_buff *))
>  			if (frag->len > mtu ||
>  			    ((frag->len & 7) && frag->next) ||
>  			    skb_headroom(frag) < hlen)
> -			    goto slow_path;
> +			    goto slow_path_clean;
> =20
>  			/* Partially cloned skb? */
>  			if (skb_shared(frag))
> -				goto slow_path;
> +				goto slow_path_clean;
> =20
>  			BUG_ON(frag->sk);
>  			if (skb->sk) {
>  				frag->sk =3D skb->sk;
>  				frag->destructor =3D sock_wfree;
> +				skb->truesize -=3D frag->truesize;
>  			}
> -			truesizes +=3D frag->truesize;
>  		}
> =20
>  		/* Everything is OK. Generate! */
> @@ -524,7 +523,6 @@ int ip_fragment(struct sk_buff *skb, int (*output=
)(struct sk_buff *))
>  		frag =3D skb_shinfo(skb)->frag_list;
>  		skb_frag_list_init(skb);
>  		skb->data_len =3D first_len - skb_headlen(skb);
> -		skb->truesize -=3D truesizes;
>  		skb->len =3D first_len;
>  		iph->tot_len =3D htons(first_len);
>  		iph->frag_off =3D htons(IP_MF);
> @@ -576,6 +574,17 @@ int ip_fragment(struct sk_buff *skb, int (*outpu=
t)(struct sk_buff *))
>  		}
>  		IP_INC_STATS(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
>  		return err;
> +
> +slow_path_clean:
> +		if (skb->sk) {
> +			skb_walk_frags(skb, frag) {
> +				if (!frag->sk)
> +					break;
> +				frag->sk =3D NULL;
> +				frag->destructor =3D NULL;
> +				skb->truesize +=3D frag->truesize;
> +			}
> +		}
>  	}
> =20
>  slow_path:

Nice try, but this adds a bug unfortunately, or if you prefer makes the
"BUG_ON(frag->sk);" being not fully covered.

If we hit slow path, and one or more frags had frag->sk set, we silentl=
y
unset it, instead of a nice BUG_ON().

If you really want to have a slow_path_clean, you should use a differen=
t
frag2 iterator :

slow_path_clean:
       if (skb->sk) {
                skb_walk_frags(skb, frag2) {
                       if (frag2 =3D=3D frag)
                               break;
                       frag2->sk =3D NULL;
                       frag2->destructor =3D NULL;
                       skb->truesize +=3D frag2->truesize;
               }
       }

=46ace it, this is too complex for net-2.6, could we just fix the bug, =
and
'optimize' later ?
