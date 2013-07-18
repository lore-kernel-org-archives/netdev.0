From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [DISCUSSION] rt6i_genid
Date: Thu, 18 Jul 2013 17:12:25 +0200
Message-ID: <51E805D9.9040408@6wind.com>
References: <51E75F82.4080300@windriver.com> <51E7B1B0.3000109@6wind.com> <51E7B522.4070105@windriver.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:47617 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932262Ab3GRPM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 11:12:29 -0400
Received: by mail-wi0-f171.google.com with SMTP id hj3so6774037wib.16
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 08:12:28 -0700 (PDT)
In-Reply-To: <51E7B522.4070105@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 18/07/2013 11:28, Fan Du a =C3=A9crit :
>
> Thanks for replying :)
>
> On 2013=E5=B9=B407=E6=9C=8818=E6=97=A5 17:13, Nicolas Dichtel wrote:
>> Le 18/07/2013 05:22, Fan Du a =C3=A9crit :
>>> Hello Nicolas
>>>
>>> Commit 6f3118b571b8a4c06c7985dc3172c3526cb86253: "ipv6: use net->rt=
_genid to
>>> check dst validity"
>>> makes ip6_dst_check to check rt6i_genid against with struct net->rt=
_genid,
>>> As a matter of fact, struct net->rt_genid could only be modified by=
 two places,
>>> first is adding/delete IPv4 address, second is inserting new XFRM p=
olicy.
>>>
>>> Is there any other considerations that adding/deleting IPv4 address=
 would
>>> invalid all IPv6 dst
>>> as well? because I'm working a patch which actually depends on the =
result of
>>> this question.
>> No, the goal was to cover the IPsec case, ie invalidate dst entries =
when an
>> xfrm policy is inserted/deleted.
>
> Ok, then how about we only checking rt6i_genid against rt_genid *only=
*
> when XFRM is enabled for IPv6, because when XFRM is not enabled for I=
Pv6
> ip6_dst_check for rt_genid is really not necessary.
>
> So what do you think of below modifications?
Seems good. Just a small comment below.

>
> diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
> index 2a601e7..4ae35fd 100644
> --- a/include/net/ip6_fib.h
> +++ b/include/net/ip6_fib.h
> @@ -119,7 +119,9 @@ struct rt6_info {
>          struct inet6_dev                *rt6i_idev;
>          unsigned long                   _rt6i_peer;
>
> +#ifdef CONFIG_XFRM
>          u32                             rt6i_genid;
> +#endif
>
>          /* more non-fragment space at head required */
>          unsigned short                  rt6i_nfheader_len;
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index bd5fd70..1b64406 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -277,7 +277,9 @@ static inline struct rt6_info *ip6_dst_alloc(stru=
ct net *net,
>
>                  memset(dst + 1, 0, sizeof(*rt) - sizeof(*dst));
>                  rt6_init_peer(rt, table ? &table->tb6_peers : net->i=
pv6.peers);
> +#ifdef CONFIG_XFRM
>                  rt->rt6i_genid =3D rt_genid(net);
> +#endif
>                  INIT_LIST_HEAD(&rt->rt6i_siblings);
>                  rt->rt6i_nsiblings =3D 0;
>          }
> @@ -1041,12 +1043,15 @@ static struct dst_entry *ip6_dst_check(struct=
 dst_entry
> *dst, u32 cookie)
>
>          rt =3D (struct rt6_info *) dst;
>
> +#ifdef CONFIG_XFRM
>          /* All IPV6 dsts are created with ->obsolete set to the valu=
e
>           * DST_OBSOLETE_FORCE_CHK which forces validation calls down
>           * into this function always.
> +        * Note: for IPv6, rt6i_genid is noly used when XFRM enabled.
indentation is wrong, but I'm not sure this comment is really needed ..=
=2E you've=20
put the ifdef 4 lines above.

>           */
>          if (rt->rt6i_genid !=3D rt_genid(dev_net(rt->dst.dev)))
>                  return NULL;
> +#endif
>
>          if (rt->rt6i_node && (rt->rt6i_node->fn_sernum =3D=3D cookie=
))
>                  return dst;
