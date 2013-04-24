From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: gre: Support GRE over IPv6
Date: Wed, 24 Apr 2013 08:14:04 -0700
Message-ID: <1366816444.8964.72.camel@edumazet-glaptop>
References: <20121002205219.7C3BD340556@ra.kernel.org>
	 <alpine.DEB.2.00.1304241417570.21513@ayla.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dmitry Kozlov <xeb@mail.ru>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1304241417570.21513@ayla.of.borg>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-04-24 at 14:23 +0200, Geert Uytterhoeven wrote:
> On Tue, 2 Oct 2012, Linux Kernel Mailing List wrote:
> > Gitweb:     http://git.kernel.org/linus/;a=3Dcommit;h=3Dc12b395a466=
46bab69089ce7016ac78177f6001f
> > Commit:     c12b395a46646bab69089ce7016ac78177f6001f
> > Parent:     b7bc2a5b5bd99b216c3e5fe68c7f45c684ab5745
> > Author:     xeb@mail.ru <xeb@mail.ru>
> > AuthorDate: Fri Aug 10 00:51:50 2012 +0000
> > Committer:  David S. Miller <davem@davemloft.net>
> > CommitDate: Tue Aug 14 14:28:32 2012 -0700
> >=20
> >     gre: Support GRE over IPv6
> >    =20
> >     GRE over IPv6 implementation.
> >    =20
> >     Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
>=20
> > --- /dev/null
> > +++ b/net/ipv6/ip6_gre.c
>=20
> > +static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
> > +			 struct net_device *dev,
> > +			 __u8 dsfield,
> > +			 struct flowi6 *fl6,
> > +			 int encap_limit,
> > +			 __u32 *pmtu)
> > +{
> > +	struct net *net =3D dev_net(dev);
> > +	struct ip6_tnl *tunnel =3D netdev_priv(dev);
> > +	struct net_device *tdev;    /* Device to other host */
> > +	struct ipv6hdr  *ipv6h;     /* Our new IP header */
> > +	unsigned int max_headroom;  /* The extra header space needed */
>=20
> max_headroom is not initialized
>=20
> > +	mtu =3D dst_mtu(dst) - sizeof(*ipv6h);
> > +	if (encap_limit >=3D 0) {
> > +		max_headroom +=3D 8;
>=20
> Hence gcc (4.1.2) rightfully complains:
>=20
> net/ipv6/ip6_gre.c: In function =E2=80=98ip6gre_xmit2=E2=80=99:
> net/ipv6/ip6_gre.c:713: warning: =E2=80=98max_headroom=E2=80=99 is us=
ed uninitialized in this function
>=20
> However, initializing max_headroom to zero at the top, or replacing t=
he line
> above by "max_headroom =3D 8" doesn't seem to be the right fix...
>=20
> > +		mtu -=3D 8;
> > +	}
> > +	if (mtu < IPV6_MIN_MTU)
> > +		mtu =3D IPV6_MIN_MTU;
> > +	if (skb_dst(skb))
> > +		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
> > +	if (skb->len > mtu) {
> > +		*pmtu =3D mtu;
> > +		err =3D -EMSGSIZE;
> > +		goto tx_err_dst_release;
> > +	}
> > +
> > +	if (tunnel->err_count > 0) {
> > +		if (time_before(jiffies,
> > +				tunnel->err_time + IP6TUNNEL_ERR_TIMEO)) {
> > +			tunnel->err_count--;
> > +
> > +			dst_link_failure(skb);
> > +		} else
> > +			tunnel->err_count =3D 0;
> > +	}
> > +
> > +	max_headroom =3D LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header=
_len;
>=20
> ... as max_headroom is overwritten here anyway?
>=20
> So something is really wrong here. What is the right fix?
>=20
> This issue is present in current mainline as of v3.7.

I would use following fix. Can you provide an official patch ?

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index d3ddd84..150d17d 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -620,7 +620,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb=
,
 	struct ip6_tnl *tunnel =3D netdev_priv(dev);
 	struct net_device *tdev;    /* Device to other host */
 	struct ipv6hdr  *ipv6h;     /* Our new IP header */
-	unsigned int max_headroom;  /* The extra header space needed */
+	unsigned int max_headroom =3D 0;  /* The extra header space needed */
 	int    gre_hlen;
 	struct ipv6_tel_txoption opt;
 	int    mtu;
@@ -693,7 +693,7 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb=
,
 			tunnel->err_count =3D 0;
 	}
=20
-	max_headroom =3D LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_len=
;
+	max_headroom +=3D LL_RESERVED_SPACE(tdev) + gre_hlen + dst->header_le=
n;
=20
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
