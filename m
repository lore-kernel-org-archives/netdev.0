From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Thu, 20 Jul 2017 23:23:52 +0800
Message-ID: <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com> <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f171.google.com ([209.85.223.171]:36390 "EHLO
        mail-io0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964876AbdGTPXx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Jul 2017 11:23:53 -0400
Received: by mail-io0-f171.google.com with SMTP id q2so12811286ioe.3
        for <netdev@vger.kernel.org>; Thu, 20 Jul 2017 08:23:53 -0700 (PDT)
In-Reply-To: <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-07-20 23:06 GMT+08:00 Hangbin Liu <liuhangbin@gmail.com>:
>> +++ b/net/ipv6/route.c
>> @@ -3637,12 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff *in_skb, struct nlmsghdr *nlh,
>>                 dst = ip6_route_lookup(net, &fl6, 0);
>>
>>         rt = container_of(dst, struct rt6_info, dst);
>> -       if (rt->dst.error) {
>> -               err = rt->dst.error;
>> -               ip6_rt_put(rt);
>> -               goto errout;
>> -       }
>
> hmm... or instead of remove this check, should we check all the entry? Like
> if ((rt->dst.error && rt != net->ipv6.ip6_null_entry && rt !=
                                                    ^^ mistake here
> net->ipv6.ip6_blk_hole_entry) ||
>      rt == net->ipv6.ip6_null_entry )

Sorry,  there should be no need to check ip6_null_entry since the
error is already
-ENETUNREACH. So how about

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4d30c96..c290aa4 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3637,13 +3637,8 @@ static int inet6_rtm_getroute(struct sk_buff
*in_skb, struct nlmsghdr *nlh,
                dst = ip6_route_lookup(net, &fl6, 0);

        rt = container_of(dst, struct rt6_info, dst);
-       if (rt->dst.error) {
-               err = rt->dst.error;
-               ip6_rt_put(rt);
-               goto errout;
-       }
-
-       if (rt == net->ipv6.ip6_null_entry) {
+       if (rt->dst.error && rt != net->ipv6.ip6_prohibit_entry &&
+           rt != net->ipv6.ip6_blk_hole_entry) {
                err = rt->dst.error;
                ip6_rt_put(rt);
                goto errout;

Thanks
Hangbin
