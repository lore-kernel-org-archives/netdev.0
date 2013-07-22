From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH net-next] net: split rt_genid for ipv4 and ipv6
Date: Mon, 22 Jul 2013 22:40:35 +0200
Message-ID: <51ED98C3.8050108@6wind.com>
References: <51E8B273.1090002@windriver.com>	<20130718.203100.1960741588589171145.davem@davemloft.net>	<51E8EFBC.6040902@windriver.com> <20130719.023318.2201887768706444746.davem@davemloft.net> <51ECC682.1030409@windriver.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, jmorris@namei.org,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:34981 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757004Ab3GVUkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jul 2013 16:40:39 -0400
Received: by mail-we0-f169.google.com with SMTP id n57so6518524wev.0
        for <netdev@vger.kernel.org>; Mon, 22 Jul 2013 13:40:38 -0700 (PDT)
In-Reply-To: <51ECC682.1030409@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 22/07/2013 07:43, Fan Du a =C3=A9crit :
> Adding IPsec and other IPv4/IPv6 maintainers in the list.
>
> On 2013=E5=B9=B407=E6=9C=8819=E6=97=A5 17:33, David Miller wrote:
>> From: Fan Du<fan.du@windriver.com>
>> Date: Fri, 19 Jul 2013 15:50:20 +0800
>>
>>> The original commit is targeted for XFRM policy inserting/removing,
>>> but it uses net genid shared by both IPv4 and IPv6, the side effect=
 is
>>> add/delete IPv4 address will invalidate IPv6 dst in all.
>>>
>>> We *do* need to bump genid when add/delete IPv6 address in scenario=
 I
>>> described here: http://www.spinics.net/lists/netdev/msg243398.html,
>>> but definitely not from add/delete IPv4 address. Moreover test show=
s
>>> that DCCP still push thousands of packets on wire after delete its
>>> IPv6
>>> address in the same scenario I describe before.
>>>
>>> The impulse to bump genid for IPv6 is much more stronger after this
>>> commit even do it unintentionally.
>>
>> If you really think it will help, and it will still handle the IPSEC
>> case, you can make a seperate genid for ipv4 and ipv6 but that might=
 not
>> work out so cleanly.
>>
>
> At least let me give it a try. Any comments would be truly welcome.
>
>
>  From c79215d64038d62340d77c6ac070d8bb479b2f89 Mon Sep 17 00:00:00 20=
01
> From: Fan Du <fan.du@windriver.com>
> Date: Mon, 22 Jul 2013 11:31:56 +0800
> Subject: [RFC PATCH net-next] net: split rt_genid for ipv4 and ipv6
>
> Current net name space has only one genid for both IPv4 and IPv6, it =
has below
> drawbacks:
>
> - Add/delete an IPv4 address will invalidate all IPv6 routing table e=
ntries.
> - Insert/remove XFRM policy will also invalidate both IPv4/IPv6 routi=
ng table
> entries
>    even when the policy is only applied for one address family.
>
> Thus, this patch attempt to split one genid for two to cater for IPv4=
 and IPv6
> separately
> in a fine granularity.
>
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
>   include/net/net_namespace.h |   33 ++++++++++++++++++++++++++++----=
-
>   net/ipv4/route.c            |   16 ++++++++--------
>   net/ipv6/af_inet6.c         |    1 +
>   net/ipv6/route.c            |    4 ++--
>   net/xfrm/xfrm_policy.c      |    8 +++++++-
>   5 files changed, 46 insertions(+), 16 deletions(-)
>
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.=
h
> index 84e37b1..a08e312 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -119,8 +119,11 @@ struct net {
>       struct netns_ipvs    *ipvs;
>   #endif
>       struct sock        *diag_nlsk;
> -    atomic_t        rt_genid;
>       atomic_t        fnhe_genid;
> +    atomic_t                rt_genid_ipv4;
> +#if IS_ENABLED(CONFIG_IPV6)
> +    atomic_t                rt_genid_ipv6;
> +#endif
>   };
Why not putting these new fields in 'struct netns_ipv4' and 'struct net=
ns_ipv6'?
