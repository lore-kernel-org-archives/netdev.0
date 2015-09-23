From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next 2/2] ipv4: ICMP packet inspection for multipath
Date: Wed, 23 Sep 2015 14:01:23 -0700
Message-ID: <CALx6S36zdhbP=tfqhjOhO9juH_uYX+ZbgAaAZHD8HgYRN75cXg@mail.gmail.com>
References: <1443037777-25390-1-git-send-email-pch@ordbogen.com>
	<1443037777-25390-3-git-send-email-pch@ordbogen.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: =?UTF-8?Q?Peter_N=C3=B8rlund?= <pch@ordbogen.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:34501 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbbIWVBY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 17:01:24 -0400
Received: by iofb144 with SMTP id b144so56539653iof.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 14:01:23 -0700 (PDT)
In-Reply-To: <1443037777-25390-3-git-send-email-pch@ordbogen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 23, 2015 at 12:49 PM, Peter N=C3=B8rlund <pch@ordbogen.com>=
 wrote:
> ICMP packets are inspected to let them route together with the flow t=
hey
> belong to, minimizing the chance that a problematic path will affect =
flows
> on other paths, and so that anycast environments can work with ECMP.
>
> Signed-off-by: Peter N=C3=B8rlund <pch@ordbogen.com>
> ---
>  include/net/route.h |   11 +++++++++-
>  net/ipv4/icmp.c     |   19 ++++++++++++++++-
>  net/ipv4/route.c    |   57 +++++++++++++++++++++++++++++++++++++++++=
++++------
>  3 files changed, 79 insertions(+), 8 deletions(-)
>
> diff --git a/include/net/route.h b/include/net/route.h
> index 10a7d21..0f7abdc 100644
> --- a/include/net/route.h
> +++ b/include/net/route.h
> @@ -28,6 +28,7 @@
>  #include <net/inetpeer.h>
>  #include <net/flow.h>
>  #include <net/inet_sock.h>
> +#include <net/ip_fib.h>
>  #include <linux/in_route.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/rcupdate.h>
> @@ -112,7 +113,15 @@ struct in_device;
>  int ip_rt_init(void);
>  void rt_cache_flush(struct net *net);
>  void rt_flush_dev(struct net_device *dev);
> -struct rtable *__ip_route_output_key(struct net *, struct flowi4 *fl=
p);
> +struct rtable *__ip_route_output_key_hash(struct net *, struct flowi=
4 *flp,
> +                                         int mp_hash);
> +
> +static inline struct rtable *__ip_route_output_key(struct net *net,
> +                                                  struct flowi4 *flp=
)
> +{
> +       return __ip_route_output_key_hash(net, flp, -1);
> +}
> +
>  struct rtable *ip_route_output_flow(struct net *, struct flowi4 *flp=
,
>                                     struct sock *sk);
>  struct dst_entry *ipv4_blackhole_route(struct net *net,
> diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
> index 79fe05b..f81daca 100644
> --- a/net/ipv4/icmp.c
> +++ b/net/ipv4/icmp.c
> @@ -440,6 +440,22 @@ out_unlock:
>         icmp_xmit_unlock(sk);
>  }
>
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +
> +/* Source and destination is swapped. See ip_multipath_icmp_hash */
> +static int icmp_multipath_hash_skb(const struct sk_buff *skb)
> +{
> +       const struct iphdr *iph =3D ip_hdr(skb);
> +
> +       return fib_multipath_hash(iph->daddr, iph->saddr);
> +}
> +
> +#else
> +
> +#define icmp_multipath_hash_skb(skb) (-1)
> +
> +#endif
> +
>  static struct rtable *icmp_route_lookup(struct net *net,
>                                         struct flowi4 *fl4,
>                                         struct sk_buff *skb_in,
> @@ -464,7 +480,8 @@ static struct rtable *icmp_route_lookup(struct ne=
t *net,
>         fl4->flowi4_oif =3D vrf_master_ifindex(skb_in->dev) ? : skb_i=
n->dev->ifindex;
>
>         security_skb_classify_flow(skb_in, flowi4_to_flowi(fl4));
> -       rt =3D __ip_route_output_key(net, fl4);
> +       rt =3D __ip_route_output_key_hash(net, fl4,
> +                                       icmp_multipath_hash_skb(skb_i=
n));
>         if (IS_ERR(rt))
>                 return rt;
>
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 3dc83b6..29048e1 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1652,6 +1652,48 @@ out:
>         return err;
>  }
>
> +#ifdef CONFIG_IP_ROUTE_MULTIPATH
> +
> +/* To make ICMP packets follow the right flow, the multipath hash is
> + * calculated from the inner IP addresses in reverse order.
> + */
> +static int ip_multipath_icmp_hash(struct sk_buff *skb)
> +{

This seems like overkill to me. Even if you do this on the host no
device in the network is going to crack open ICMP like this for doing
its ECMP. I suppose the argument is that this is another hack needed
to make anycast "work"...

> +       const struct iphdr *outer_iph =3D ip_hdr(skb);
> +       struct icmphdr _icmph;
> +       const struct icmphdr *icmph;
> +       struct iphdr _inner_iph;
> +       const struct iphdr *inner_iph;
> +
> +       if (unlikely((outer_iph->frag_off & htons(IP_OFFSET)) !=3D 0)=
)
> +               goto standard_hash;
> +
> +       icmph =3D skb_header_pointer(skb, outer_iph->ihl * 4, sizeof(=
_icmph),
> +                                  &_icmph);
> +       if (!icmph)
> +               goto standard_hash;
> +
> +       if (icmph->type !=3D ICMP_DEST_UNREACH &&
> +           icmph->type !=3D ICMP_REDIRECT &&
> +           icmph->type !=3D ICMP_TIME_EXCEEDED &&
> +           icmph->type !=3D ICMP_PARAMETERPROB) {
> +               goto standard_hash;
> +       }
> +
> +       inner_iph =3D skb_header_pointer(skb,
> +                                      outer_iph->ihl * 4 + sizeof(_i=
cmph),
> +                                      sizeof(_inner_iph), &_inner_ip=
h);
> +       if (!inner_iph)
> +               goto standard_hash;
> +
> +       return fib_multipath_hash(inner_iph->daddr, inner_iph->saddr)=
;
> +
> +standard_hash:
> +       return fib_multipath_hash(outer_iph->saddr, outer_iph->daddr)=
;
> +}
> +
> +#endif /* CONFIG_IP_ROUTE_MULTIPATH */
> +
>  static int ip_mkroute_input(struct sk_buff *skb,
>                             struct fib_result *res,
>                             const struct flowi4 *fl4,
> @@ -1662,7 +1704,10 @@ static int ip_mkroute_input(struct sk_buff *sk=
b,
>         if (res->fi && res->fi->fib_nhs > 1) {
>                 int h;
>
> -               h =3D fib_multipath_hash(saddr, daddr);
> +               if (unlikely(ip_hdr(skb)->protocol =3D=3D IPPROTO_ICM=
P))
> +                       h =3D ip_multipath_icmp_hash(skb);
> +               else
> +                       h =3D fib_multipath_hash(saddr, daddr);
>                 fib_select_multipath(res, h);
>         }
>  #endif
> @@ -2032,7 +2077,8 @@ add:
>   * Major route resolver routine.
>   */
>
> -struct rtable *__ip_route_output_key(struct net *net, struct flowi4 =
*fl4)
> +struct rtable *__ip_route_output_key_hash(struct net *net, struct fl=
owi4 *fl4,
> +                                         int mp_hash)
>  {
>         struct net_device *dev_out =3D NULL;
>         __u8 tos =3D RT_FL_TOS(fl4);
> @@ -2195,10 +2241,9 @@ struct rtable *__ip_route_output_key(struct ne=
t *net, struct flowi4 *fl4)
>
>  #ifdef CONFIG_IP_ROUTE_MULTIPATH
>         if (res.fi->fib_nhs > 1 && fl4->flowi4_oif =3D=3D 0) {
> -               int h;
> -
> -               h =3D fib_multipath_hash(fl4->saddr, fl4->daddr);
> -               fib_select_multipath(&res, h);
> +               if (mp_hash < 0)
> +                       mp_hash =3D fib_multipath_hash(fl4->saddr, fl=
4->daddr);
> +               fib_select_multipath(&res, mp_hash);
>         }
>         else
>  #endif
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
