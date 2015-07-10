From: Erik Kline <ek@google.com>
Subject: Re: [PATCH net-next] ipv6: Do not iterate over all interfaces when
 finding source address on specific interface.
Date: Fri, 10 Jul 2015 16:19:24 +0900
Message-ID: <CAAedzxpD7EEV-3BXdGA72wqwxM1b0tge0iqBKehfZG4KvRjYrQ@mail.gmail.com>
References: <559F6B2E.8010408@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:37606 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752920AbbGJHTp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 03:19:45 -0400
Received: by wicmz13 with SMTP id mz13so6322056wic.0
        for <netdev@vger.kernel.org>; Fri, 10 Jul 2015 00:19:44 -0700 (PDT)
In-Reply-To: <559F6B2E.8010408@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 July 2015 at 15:50, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=
=E6=98=8E
<hideaki.yoshifuji@miraclelinux.com> wrote:
> If outgoing interface is specified and the candidate addresses
> are restricted to the outgoing interface, it is enough to iterate
> over that given interface only.
>
> Signed-off-by: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
> ---
>  net/ipv6/addrconf.c | 201 +++++++++++++++++++++++++++++-------------=
----------
>  1 file changed, 111 insertions(+), 90 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 21c2c81..b4c82d8 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -1358,15 +1358,94 @@ out:
>         return ret;
>  }
>
> +static void __ipv6_dev_get_saddr(struct net *net,
> +                                struct ipv6_saddr_dst *dst,
> +                                unsigned int prefs,
> +                                const struct in6_addr *saddr,
> +                                struct inet6_dev *idev,
> +                                struct ipv6_saddr_score *scores)
> +{
> +       struct ipv6_saddr_score *score =3D &scores[0], *hiscore =3D &=
scores[1];
> +
> +       read_lock_bh(&idev->lock);
> +       list_for_each_entry(score->ifa, &idev->addr_list, if_list) {
> +               int i;
> +
> +               /*
> +                * - Tentative Address (RFC2462 section 5.4)
> +                *  - A tentative address is not considered
> +                *    "assigned to an interface" in the traditional
> +                *    sense, unless it is also flagged as optimistic.
> +                * - Candidate Source Address (section 4)
> +                *  - In any case, anycast addresses, multicast
> +                *    addresses, and the unspecified address MUST
> +                *    NOT be included in a candidate set.
> +                */
> +               if ((score->ifa->flags & IFA_F_TENTATIVE) &&
> +                   (!(score->ifa->flags & IFA_F_OPTIMISTIC)))
> +                       continue;
> +
> +               score->addr_type =3D __ipv6_addr_type(&score->ifa->ad=
dr);
> +
> +               if (unlikely(score->addr_type =3D=3D IPV6_ADDR_ANY ||
> +                            score->addr_type & IPV6_ADDR_MULTICAST))=
 {
> +                       net_dbg_ratelimited("ADDRCONF: unspecified / =
multicast address assigned as unicast address on %s",
> +                                           idev->dev->name);
> +                       continue;
> +               }
> +
> +               score->rule =3D -1;
> +               bitmap_zero(score->scorebits, IPV6_SADDR_RULE_MAX);
> +
> +               for (i =3D 0; i < IPV6_SADDR_RULE_MAX; i++) {
> +                       int minihiscore, miniscore;
> +
> +                       minihiscore =3D ipv6_get_saddr_eval(net, hisc=
ore, dst, i);
> +                       miniscore =3D ipv6_get_saddr_eval(net, score,=
 dst, i);
> +
> +                       if (minihiscore > miniscore) {
> +                               if (i =3D=3D IPV6_SADDR_RULE_SCOPE &&
> +                                   score->scopedist > 0) {
> +                                       /*
> +                                        * special case:
> +                                        * each remaining entry
> +                                        * has too small (not enough)
> +                                        * scope, because ifa entries
> +                                        * are sorted by their scope
> +                                        * values.
> +                                        */
> +                                       goto out;
> +                               }
> +                               break;
> +                       } else if (minihiscore < miniscore) {
> +                               if (hiscore->ifa)
> +                                       in6_ifa_put(hiscore->ifa);
> +
> +                               in6_ifa_hold(score->ifa);
> +
> +                               swap(hiscore, score);
> +
> +                               /* restore our iterator */
> +                               score->ifa =3D hiscore->ifa;
> +
> +                               break;
> +                       }
> +               }
> +       }
> +out:
> +       read_unlock_bh(&idev->lock);
> +}
> +
>  int ipv6_dev_get_saddr(struct net *net, const struct net_device *dst=
_dev,
>                        const struct in6_addr *daddr, unsigned int pre=
fs,
>                        struct in6_addr *saddr)
>  {
> -       struct ipv6_saddr_score scores[2],
> -                               *score =3D &scores[0], *hiscore =3D &=
scores[1];
> +       struct ipv6_saddr_score scores[2], *hiscore =3D &scores[1];
>         struct ipv6_saddr_dst dst;
> +       struct inet6_dev *idev;
>         struct net_device *dev;
>         int dst_type;
> +       bool use_oif_addr =3D false;
>
>         dst_type =3D __ipv6_addr_type(daddr);
>         dst.addr =3D daddr;
> @@ -1380,97 +1459,39 @@ int ipv6_dev_get_saddr(struct net *net, const=
 struct net_device *dst_dev,
>
>         rcu_read_lock();
>
> -       for_each_netdev_rcu(net, dev) {
> -               struct inet6_dev *idev;
> -
> -               /* Candidate Source Address (section 4)
> -                *  - multicast and link-local destination address,
> -                *    the set of candidate source address MUST only
> -                *    include addresses assigned to interfaces
> -                *    belonging to the same link as the outgoing
> -                *    interface.
> -                * (- For site-local destination addresses, the
> -                *    set of candidate source addresses MUST only
> -                *    include addresses assigned to interfaces
> -                *    belonging to the same site as the outgoing
> -                *    interface.)
> -                */
> -               if (((dst_type & IPV6_ADDR_MULTICAST) ||
> -                    dst.scope <=3D IPV6_ADDR_SCOPE_LINKLOCAL) &&
> -                   dst.ifindex && dev->ifindex !=3D dst.ifindex)
> -                       continue;
> -
> -               idev =3D __in6_dev_get(dev);
> -               if (!idev)
> -                       continue;
> -
> -               read_lock_bh(&idev->lock);
> -               list_for_each_entry(score->ifa, &idev->addr_list, if_=
list) {
> -                       int i;
> -
> -                       /*
> -                        * - Tentative Address (RFC2462 section 5.4)
> -                        *  - A tentative address is not considered
> -                        *    "assigned to an interface" in the tradi=
tional
> -                        *    sense, unless it is also flagged as opt=
imistic.
> -                        * - Candidate Source Address (section 4)
> -                        *  - In any case, anycast addresses, multica=
st
> -                        *    addresses, and the unspecified address =
MUST
> -                        *    NOT be included in a candidate set.
> -                        */
> -                       if ((score->ifa->flags & IFA_F_TENTATIVE) &&
> -                           (!(score->ifa->flags & IFA_F_OPTIMISTIC))=
)
> -                               continue;
> -
> -                       score->addr_type =3D __ipv6_addr_type(&score-=
>ifa->addr);
> +       /* Candidate Source Address (section 4)
> +        *  - multicast and link-local destination address,
> +        *    the set of candidate source address MUST only
> +        *    include addresses assigned to interfaces
> +        *    belonging to the same link as the outgoing
> +        *    interface.
> +        * (- For site-local destination addresses, the
> +        *    set of candidate source addresses MUST only
> +        *    include addresses assigned to interfaces
> +        *    belonging to the same site as the outgoing
> +        *    interface.)
> +        *  - "It is RECOMMENDED that the candidate source addresses
> +        *    be the set of unicast addresses assigned to the
> +        *    interface that will be used to send to the destination
> +        *    (the 'outgoing' interface)." (RFC 6724)
> +        */
> +       if (dst_dev) {
> +               if ((dst_type & IPV6_ADDR_MULTICAST) ||
> +                   dst.scope <=3D IPV6_ADDR_SCOPE_LINKLOCAL) {
> +                       idev =3D __in6_dev_get(dst_dev);
> +                       use_oif_addr =3D true;
> +               }
> +       }
>
> -                       if (unlikely(score->addr_type =3D=3D IPV6_ADD=
R_ANY ||
> -                                    score->addr_type & IPV6_ADDR_MUL=
TICAST)) {
> -                               net_dbg_ratelimited("ADDRCONF: unspec=
ified / multicast address assigned as unicast address on %s",
> -                                                   dev->name);
> +       if (use_oif_addr) {
> +               __ipv6_dev_get_saddr(net, &dst, prefs, saddr, idev, s=
cores);
> +       } else {
> +               for_each_netdev_rcu(net, dev) {
> +                       idev =3D __in6_dev_get(dev);
> +                       if (!idev)
>                                 continue;
> -                       }
> -
> -                       score->rule =3D -1;
> -                       bitmap_zero(score->scorebits, IPV6_SADDR_RULE=
_MAX);
> -
> -                       for (i =3D 0; i < IPV6_SADDR_RULE_MAX; i++) {
> -                               int minihiscore, miniscore;
> -
> -                               minihiscore =3D ipv6_get_saddr_eval(n=
et, hiscore, &dst, i);
> -                               miniscore =3D ipv6_get_saddr_eval(net=
, score, &dst, i);
> -
> -                               if (minihiscore > miniscore) {
> -                                       if (i =3D=3D IPV6_SADDR_RULE_=
SCOPE &&
> -                                           score->scopedist > 0) {
> -                                               /*
> -                                                * special case:
> -                                                * each remaining ent=
ry
> -                                                * has too small (not=
 enough)
> -                                                * scope, because ifa=
 entries
> -                                                * are sorted by thei=
r scope
> -                                                * values.
> -                                                */
> -                                               goto try_nextdev;
> -                                       }
> -                                       break;
> -                               } else if (minihiscore < miniscore) {
> -                                       if (hiscore->ifa)
> -                                               in6_ifa_put(hiscore->=
ifa);
> -
> -                                       in6_ifa_hold(score->ifa);
> -
> -                                       swap(hiscore, score);
> -
> -                                       /* restore our iterator */
> -                                       score->ifa =3D hiscore->ifa;
> -
> -                                       break;
> -                               }
> -                       }
> +                       __ipv6_dev_get_saddr(net, &dst, prefs, saddr,=
 idev, scores);
>                 }
> -try_nextdev:
> -               read_unlock_bh(&idev->lock);
>         }
>         rcu_read_unlock();
>
> --
> 1.9.1
>

LGTM, and thanks again.

Acked-by: Erik Kline <ek@google.com>
