From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net] ipv6: set fc_protocol with 0 when rtm_protocol is RTPROT_REDIRECT
Date: Tue, 1 Aug 2017 13:40:05 +1200
Message-ID: <CADvbK_dWwZU1EXf4ehAyV9cWOK-7b4hn=mGrytGTYACrCUUQ6g@mail.gmail.com>
References: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
 <9fcbffcb-4a14-764c-7fe4-2108b8944c17@gmail.com> <CADvbK_ew8tD=sQQkZ03ijGafFQEzR0sf69DZ1_rNkX9E5mFpuw@mail.gmail.com>
 <11af493f-1128-cae6-d1a3-0d3d962da269@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        =?UTF-8?Q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36467 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751327AbdHABkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 21:40:06 -0400
Received: by mail-qk0-f195.google.com with SMTP id d136so276467qkg.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 18:40:06 -0700 (PDT)
In-Reply-To: <11af493f-1128-cae6-d1a3-0d3d962da269@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 1, 2017 at 12:12 PM, David Ahern <dsahern@gmail.com> wrote:
> On 7/30/17 9:31 PM, Xin Long wrote:
>>> Did you look at removing this hunk from rt6_fill_node:
>>>
>>>         if (rt->rt6i_flags & RTF_DYNAMIC)
>>>                 rtm->rtm_protocol = RTPROT_REDIRECT;
>>>         else if (rt->rt6i_flags & RTF_ADDRCONF) {
>>>                 if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
>>>                         rtm->rtm_protocol = RTPROT_RA;
>>>                 else
>>>                         rtm->rtm_protocol = RTPROT_KERNEL;
>>>         }
>> The issue seems to affect "ip -6 route flush all" as well, not only cache
>> since 'else if {}' also  causes rtm proto being different from rt6 proto.
>>
>>>
>>> And have rtm_protocol set properly on the route when it is installed?
>> The codes not keeping rtm proto consistent with rt6 proto day 1,
>> any idea on why it didn't use rt6 proto in kernel properly?
>
> no, AFAIK it was just an oversight when the original code was written. I
> do not know of any reason that would prevent properly setting the
> rt6i_protocol in the route when it is allocated.
That's what I was worried about, it might break something,
but double checked, should be fine.

>
> Something like this (not compiled, much less tested):
To respect the old code more, setting RTPROT_RA only when
it's with the flag (ADDRCONF | DEFAULT | ROUTEINFO),
shouldn't it be:

[...]
@@ -2464,6 +2465,7 @@ static struct rt6_info
*rt6_add_route_info(struct net *net,
                .fc_nlinfo.portid = 0,
                .fc_nlinfo.nlh = NULL,
                .fc_nlinfo.nl_net = net,
+               .fc_protocol = RTPROT_KERNEL,
        };

        cfg.fc_table = l3mdev_fib_table(dev) ? : RT6_TABLE_INFO,
@@ -2471,8 +2473,10 @@ static struct rt6_info
*rt6_add_route_info(struct net *net,
        cfg.fc_gateway = *gwaddr;

        /* We should treat it as a default route if prefix length is 0. */
-       if (!prefixlen)
+       if (!prefixlen) {
+               cfg.fc_protocol = RTPROT_RA;
                cfg.fc_flags |= RTF_DEFAULT;
+       }

        ip6_route_add(&cfg, NULL);

@@ -2516,6 +2520,7 @@ struct rt6_info *rt6_add_dflt_router(const
struct in6_addr *gwaddr,
                .fc_nlinfo.portid = 0,
                .fc_nlinfo.nlh = NULL,
                .fc_nlinfo.nl_net = dev_net(dev),
+               .fc_protocol = RTPROT_KERNEL,
        };
[...]

or you changed it intentionally ?

I will do some testing before posting v2.
thanks for your suggestion. :-)

>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4d30c96a819d..9a928839d247 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -2347,6 +2347,7 @@ static void rt6_do_redirect(struct dst_entry *dst,
> struct sock *sk, struct sk_bu
>         if (!nrt)
>                 goto out;
>
> +       nrt->rt6i_protocol = RTPROT_REDIRECT;
>         nrt->rt6i_flags = RTF_GATEWAY|RTF_UP|RTF_DYNAMIC|RTF_CACHE;
>         if (on_link)
>                 nrt->rt6i_flags &= ~RTF_GATEWAY;
> @@ -2461,6 +2462,7 @@ static struct rt6_info *rt6_add_route_info(struct
> net *net,
>                 .fc_dst_len     = prefixlen,
>                 .fc_flags       = RTF_GATEWAY | RTF_ADDRCONF |
> RTF_ROUTEINFO |
>                                   RTF_UP | RTF_PREF(pref),
> +               .fc_protocol    = RTPROT_RA,
>                 .fc_nlinfo.portid = 0,
>                 .fc_nlinfo.nlh = NULL,
>                 .fc_nlinfo.nl_net = net,
> @@ -2513,6 +2515,7 @@ struct rt6_info *rt6_add_dflt_router(const struct
> in6_addr *gwaddr,
>                 .fc_ifindex     = dev->ifindex,
>                 .fc_flags       = RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
>                                   RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
> +               .fc_protocol    = RTPROT_RA,
>                 .fc_nlinfo.portid = 0,
>                 .fc_nlinfo.nlh = NULL,
>                 .fc_nlinfo.nl_net = dev_net(dev),
> @@ -3424,14 +3427,6 @@ static int rt6_fill_node(struct net *net,
>         rtm->rtm_flags = 0;
>         rtm->rtm_scope = RT_SCOPE_UNIVERSE;
>         rtm->rtm_protocol = rt->rt6i_protocol;
> -       if (rt->rt6i_flags & RTF_DYNAMIC)
> -               rtm->rtm_protocol = RTPROT_REDIRECT;
> -       else if (rt->rt6i_flags & RTF_ADDRCONF) {
> -               if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
> -                       rtm->rtm_protocol = RTPROT_RA;
> -               else
> -                       rtm->rtm_protocol = RTPROT_KERNEL;
> -       }
>
>         if (rt->rt6i_flags & RTF_CACHE)
>                 rtm->rtm_flags |= RTM_F_CLONED;
