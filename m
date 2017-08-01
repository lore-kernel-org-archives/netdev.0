From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: set fc_protocol with 0 when rtm_protocol is
 RTPROT_REDIRECT
Date: Mon, 31 Jul 2017 18:12:44 -0600
Message-ID: <11af493f-1128-cae6-d1a3-0d3d962da269@gmail.com>
References: <e9342d18b97fc227cacc19db1b43f4c7350eed3f.1501419097.git.lucien.xin@gmail.com>
 <9fcbffcb-4a14-764c-7fe4-2108b8944c17@gmail.com>
 <CADvbK_ew8tD=sQQkZ03ijGafFQEzR0sf69DZ1_rNkX9E5mFpuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, davem <davem@davemloft.net>,
        =?UTF-8?Q?Mantas_Mikul=c4=97nas?= <grawity@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36667 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdHAAMq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:12:46 -0400
Received: by mail-pg0-f67.google.com with SMTP id y129so170861pgy.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 17:12:46 -0700 (PDT)
In-Reply-To: <CADvbK_ew8tD=sQQkZ03ijGafFQEzR0sf69DZ1_rNkX9E5mFpuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/30/17 9:31 PM, Xin Long wrote:
>> Did you look at removing this hunk from rt6_fill_node:
>>
>>         if (rt->rt6i_flags & RTF_DYNAMIC)
>>                 rtm->rtm_protocol = RTPROT_REDIRECT;
>>         else if (rt->rt6i_flags & RTF_ADDRCONF) {
>>                 if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
>>                         rtm->rtm_protocol = RTPROT_RA;
>>                 else
>>                         rtm->rtm_protocol = RTPROT_KERNEL;
>>         }
> The issue seems to affect "ip -6 route flush all" as well, not only cache
> since 'else if {}' also  causes rtm proto being different from rt6 proto.
> 
>>
>> And have rtm_protocol set properly on the route when it is installed?
> The codes not keeping rtm proto consistent with rt6 proto day 1,
> any idea on why it didn't use rt6 proto in kernel properly?

no, AFAIK it was just an oversight when the original code was written. I
do not know of any reason that would prevent properly setting the
rt6i_protocol in the route when it is allocated.

Something like this (not compiled, much less tested):

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96a819d..9a928839d247 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -2347,6 +2347,7 @@ static void rt6_do_redirect(struct dst_entry *dst,
struct sock *sk, struct sk_bu
        if (!nrt)
                goto out;

+       nrt->rt6i_protocol = RTPROT_REDIRECT;
        nrt->rt6i_flags = RTF_GATEWAY|RTF_UP|RTF_DYNAMIC|RTF_CACHE;
        if (on_link)
                nrt->rt6i_flags &= ~RTF_GATEWAY;
@@ -2461,6 +2462,7 @@ static struct rt6_info *rt6_add_route_info(struct
net *net,
                .fc_dst_len     = prefixlen,
                .fc_flags       = RTF_GATEWAY | RTF_ADDRCONF |
RTF_ROUTEINFO |
                                  RTF_UP | RTF_PREF(pref),
+               .fc_protocol    = RTPROT_RA,
                .fc_nlinfo.portid = 0,
                .fc_nlinfo.nlh = NULL,
                .fc_nlinfo.nl_net = net,
@@ -2513,6 +2515,7 @@ struct rt6_info *rt6_add_dflt_router(const struct
in6_addr *gwaddr,
                .fc_ifindex     = dev->ifindex,
                .fc_flags       = RTF_GATEWAY | RTF_ADDRCONF | RTF_DEFAULT |
                                  RTF_UP | RTF_EXPIRES | RTF_PREF(pref),
+               .fc_protocol    = RTPROT_RA,
                .fc_nlinfo.portid = 0,
                .fc_nlinfo.nlh = NULL,
                .fc_nlinfo.nl_net = dev_net(dev),
@@ -3424,14 +3427,6 @@ static int rt6_fill_node(struct net *net,
        rtm->rtm_flags = 0;
        rtm->rtm_scope = RT_SCOPE_UNIVERSE;
        rtm->rtm_protocol = rt->rt6i_protocol;
-       if (rt->rt6i_flags & RTF_DYNAMIC)
-               rtm->rtm_protocol = RTPROT_REDIRECT;
-       else if (rt->rt6i_flags & RTF_ADDRCONF) {
-               if (rt->rt6i_flags & (RTF_DEFAULT | RTF_ROUTEINFO))
-                       rtm->rtm_protocol = RTPROT_RA;
-               else
-                       rtm->rtm_protocol = RTPROT_KERNEL;
-       }

        if (rt->rt6i_flags & RTF_CACHE)
                rtm->rtm_flags |= RTM_F_CLONED;
