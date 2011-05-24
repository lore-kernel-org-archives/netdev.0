From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: bridge netfilter output bug on 2.6.39
Date: Tue, 24 May 2011 10:40:22 -0700
Message-ID: <20110524104022.212b0b71@nehalam>
References: <20110524074156.58eb30f8@nehalam>
	<1306251543.3026.57.camel@edumazet-laptop>
	<1306254457.3026.69.camel@edumazet-laptop>
	<1306255587.3026.76.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34658 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753777Ab1EXRkZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 13:40:25 -0400
In-Reply-To: <1306255587.3026.76.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 24 May 2011 18:46:27 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le mardi 24 mai 2011 =C3=A0 18:27 +0200, Eric Dumazet a =C3=A9crit :
> > Le mardi 24 mai 2011 =C3=A0 17:39 +0200, Eric Dumazet a =C3=A9crit =
:
> >=20
> > > I would say its more likely a problem with dst metrics changes
> > >=20
> > > In this crash, we dereference a NULL dst->_metrics 'pointer' in
> > > dst_metric_raw(dst, RTAX_MTU);
> >=20
> > It seems bridge code uses one fake_rtable
> >=20
> > You probably want to properly init its _metric field.
> >=20
> > I can do the patch in one hour eventually, if nobody beats me.
> >=20
> >=20
>=20
> Here is the patch :
>=20
> [PATCH] bridge: initialize fake_rtable metrics
>=20
> bridge netfilter code uses a fake_rtable, and we must init its _metri=
c
> field or risk NULL dereference later.
>=20
> Ref: https://bugzilla.kernel.org/show_bug.cgi?id=3D35672
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Stephen Hemminger <shemminger@vyatta.com>
> CC: Herbert Xu <herbert@gondor.apana.org.au>
> ---
>  net/bridge/br_netfilter.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletion(-)
>=20
> diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
> index e1f5ec7..3fa1231 100644
> --- a/net/bridge/br_netfilter.c
> +++ b/net/bridge/br_netfilter.c
> @@ -117,6 +117,10 @@ static struct dst_ops fake_dst_ops =3D {
>   * ipt_REJECT needs it.  Future netfilter modules might
>   * require us to fill additional fields.
>   */
> +static const u32 br_dst_default_metrics[RTAX_MAX] =3D {
> +	[RTAX_MTU - 1] =3D 1500,
> +};
> +
>  void br_netfilter_rtable_init(struct net_bridge *br)
>  {
>  	struct rtable *rt =3D &br->fake_rtable;
> @@ -124,7 +128,7 @@ void br_netfilter_rtable_init(struct net_bridge *=
br)
>  	atomic_set(&rt->dst.__refcnt, 1);
>  	rt->dst.dev =3D br->dev;
>  	rt->dst.path =3D &rt->dst;
> -	dst_metric_set(&rt->dst, RTAX_MTU, 1500);
> +	dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
>  	rt->dst.flags	=3D DST_NOXFRM;
>  	rt->dst.ops =3D &fake_dst_ops;
>  }

This part is fine.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

I think there should be BUG_ON any calls to dst_metric_set where
dst has no metrics available.

[PATCH] dst: catch uninitialized metrics

Catch cases where dst_metric_set() and other functions are called
but _metrics is NULL.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/dst.h	2011-05-24 10:36:07.597962703 -0700
+++ b/include/net/dst.h	2011-05-24 10:36:54.382509111 -0700
@@ -111,6 +111,8 @@ static inline u32 *dst_metrics_write_ptr
 {
 	unsigned long p =3D dst->_metrics;
=20
+	BUG_ON(!p);
+
 	if (p & DST_METRICS_READ_ONLY)
 		return dst->ops->cow_metrics(dst, p);
 	return __DST_METRICS_PTR(p);


