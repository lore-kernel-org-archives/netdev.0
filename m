From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: gre: Support GRE over IPv6
Date: Wed, 24 Apr 2013 14:23:37 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1304241417570.21513@ayla.of.borg>
References: <20121002205219.7C3BD340556@ra.kernel.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Dmitry Kozlov <xeb@mail.ru>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121002205219.7C3BD340556@ra.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2 Oct 2012, Linux Kernel Mailing List wrote:
> Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3Dc12b395a46646=
bab69089ce7016ac78177f6001f
> Commit:     c12b395a46646bab69089ce7016ac78177f6001f
> Parent:     b7bc2a5b5bd99b216c3e5fe68c7f45c684ab5745
> Author:     xeb@mail.ru <xeb@mail.ru>
> AuthorDate: Fri Aug 10 00:51:50 2012 +0000
> Committer:  David S. Miller <davem@davemloft.net>
> CommitDate: Tue Aug 14 14:28:32 2012 -0700
>=20
>     gre: Support GRE over IPv6
>    =20
>     GRE over IPv6 implementation.
>    =20
>     Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

> --- /dev/null
> +++ b/net/ipv6/ip6_gre.c

> +static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
> +			 struct net_device *dev,
> +			 __u8 dsfield,
> +			 struct flowi6 *fl6,
> +			 int encap_limit,
> +			 __u32 *pmtu)
> +{
> +	struct net *net =3D dev_net(dev);
> +	struct ip6_tnl *tunnel =3D netdev_priv(dev);
> +	struct net_device *tdev;    /* Device to other host */
> +	struct ipv6hdr  *ipv6h;     /* Our new IP header */
> +	unsigned int max_headroom;  /* The extra header space needed */

max_headroom is not initialized

> +	mtu =3D dst_mtu(dst) - sizeof(*ipv6h);
> +	if (encap_limit >=3D 0) {
> +		max_headroom +=3D 8;

Hence gcc (4.1.2) rightfully complains:

net/ipv6/ip6_gre.c: In function =E2=80=98ip6gre_xmit2=E2=80=99:
net/ipv6/ip6_gre.c:713: warning: =E2=80=98max_headroom=E2=80=99 is used=
 uninitialized in this function

However, initializing max_headroom to zero at the top, or replacing the=
 line
above by "max_headroom =3D 8" doesn't seem to be the right fix...

> +		mtu -=3D 8;
> +	}
> +	if (mtu < IPV6_MIN_MTU)
> +		mtu =3D IPV6_MIN_MTU;
> +	if (skb_dst(skb))
> +		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
> +	if (skb->len > mtu) {
> +		*pmtu =3D mtu;
> +		err =3D -EMSGSIZE;
> +		goto tx_err_dst_release;
> +	}
> +
> +	if (tunnel->err_count > 0) {
> +		if (time_before(jiffies,
> +				tunnel->err_time + IP6TUNNEL_ERR_TIMEO)) {
> +			tunnel->err_count--;
> +
> +			dst_link_failure(skb);
> +		} else
> +			tunnel->err_count =3D 0;
> +	}
> +
> +	max_headroom =3D LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_l=
en;

=2E.. as max_headroom is overwritten here anyway?

So something is really wrong here. What is the right fix?

This issue is present in current mainline as of v3.7.

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
							    -- Linus Torvalds
