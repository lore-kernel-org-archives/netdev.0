From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: ip6_append_data_mtu do not handle the mtu of the second fragment properly
Date: Sat, 15 Mar 2014 16:55:19 +0100
Message-ID: <20140315155519.GA12291@order.stressinduktion.org>
References: <1394512309-8823-1-git-send-email-lucien.xin@gmail.com> <20140311144906.GA29404@order.stressinduktion.org> <CADvbK_fS0rhPodczcZ52YN9D7NBY_TG+6xXvt-shvvz+e3qLnw@mail.gmail.com> <20140312102646.GD29404@order.stressinduktion.org> <CADvbK_eZ5AO3g7uHRykspHouXnvtCTf0dUWOXf8hd3r0wV6Hnw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: network dev <netdev@vger.kernel.org>,
	Gao feng <gaofeng@cn.fujitsu.com>
To: lucien xin <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38046 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbaCOPzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Mar 2014 11:55:21 -0400
Content-Disposition: inline
In-Reply-To: <CADvbK_eZ5AO3g7uHRykspHouXnvtCTf0dUWOXf8hd3r0wV6Hnw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 13, 2014 at 01:38:15PM +0800, lucien xin wrote:
> On Wed, Mar 12, 2014 at 6:26 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > On Wed, Mar 12, 2014 at 10:40:50AM +0800, lucien xin wrote:
> >
> > It would be possible if we are absolutely sure if we don't call
> > ip6_append_data_mtu a second time, which I have not yet reviewed.
> >
> > The line I proposed above may also suffer from this problem.
> >
> > Maybe you already checked that?
> >
> hmm... this problem do exist.  when it enter "the while( length>0 ){
> }" with skb !=3D NULL first, the problem
> will happen, of course, perhaps there are also other cases that
> trigger that problem.  because  that code seems
> a little mess=EF=BC=8C I hope the following change can make it more c=
lear and
> eliminate potential insecurity,
> pls help to check it

The diff is good, thanks!

> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 2bc1070..07ac8f9 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1101,21 +1101,19 @@ static void ip6_append_data_mtu(unsigned int
> *mtu,
>                                 unsigned int fragheaderlen,
>                                 struct sk_buff *skb,
>                                 struct rt6_info *rt,
> -                               bool pmtuprobe)
> +                               unsigned int orig_mtu)
>  {
>         if (!(rt->dst.flags & DST_XFRM_TUNNEL)) {
>                 if (skb =3D=3D NULL) {
>                         /* first fragment, reserve header_len */
> -                       *mtu =3D *mtu - rt->dst.header_len;
> +                       *mtu =3D orig_mtu - rt->dst.header_len;
>=20
>                 } else {
>                         /*
>                          * this fragment is not first, the headers
>                          * space is regarded as data space.
>                          */
> -                       *mtu =3D min(*mtu, pmtuprobe ?
> -                                  rt->dst.dev->mtu :
> -                                  dst_mtu(rt->dst.path));
> +                       *mtu =3D orig_mtu;
>                 }
>                 *maxfraglen =3D ((*mtu - fragheaderlen) & ~7)
>                               + fragheaderlen - sizeof(struct frag_hd=
r);
> @@ -1132,7 +1130,7 @@ int ip6_append_data(struct sock *sk, int
> getfrag(void *from, char *to,
>         struct ipv6_pinfo *np =3D inet6_sk(sk);
>         struct inet_cork *cork;
>         struct sk_buff *skb, *skb_prev =3D NULL;
> -       unsigned int maxfraglen, fragheaderlen, mtu;
> +       unsigned int maxfraglen, fragheaderlen, mtu, orig_mtu;
>         int exthdrlen;
>         int dst_exthdrlen;
>         int hh_len;
> @@ -1214,6 +1212,7 @@ int ip6_append_data(struct sock *sk, int
> getfrag(void *from, char *to,
>                 dst_exthdrlen =3D 0;
>                 mtu =3D cork->fragsize;
>         }
> +       orig_mtu =3D mtu;
>=20
>         hh_len =3D LL_RESERVED_SPACE(rt->dst.dev);
>=20
> @@ -1313,8 +1312,7 @@ alloc_new_skb:
>                         if (skb =3D=3D NULL || skb_prev =3D=3D NULL)
>                                 ip6_append_data_mtu(&mtu, &maxfraglen=
,
>                                                     fragheaderlen,
> skb, rt,
> -                                                   np->pmtudisc >=3D
> -                                                   IPV6_PMTUDISC_PRO=
BE);
> +                                                   orig_mtu);
>=20
>                         skb_prev =3D skb;
