From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Wed, 26 Jul 2017 12:38:25 -0700
Message-ID: <CAJieiUiKqXYkH56xH2Kk5-33kZbpkTsJCzAsRintwhstPsOw=Q@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com> <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com> <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com> <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
 <CAJieiUgyHDksxVjoCSz9pxbDy-ZZR9uUWWZXdth0diSKAcvx4Q@mail.gmail.com>
 <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com> <CAJieiUi+Me_wXDz0A1oLH2LgBw9DsMoxctV56SjEwGpusFGt4Q@mail.gmail.com>
 <2d75317c-160c-01c2-5a5b-bc6111c099c6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Hangbin Liu <liuhangbin@gmail.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f182.google.com ([209.85.217.182]:34842 "EHLO
        mail-ua0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751053AbdGZTi0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 15:38:26 -0400
Received: by mail-ua0-f182.google.com with SMTP id d29so115382864uai.2
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 12:38:26 -0700 (PDT)
In-Reply-To: <2d75317c-160c-01c2-5a5b-bc6111c099c6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 26, 2017 at 12:00 PM, David Ahern <dsahern@gmail.com> wrote:
> On 7/26/17 12:55 PM, Roopa Prabhu wrote:
>> On Wed, Jul 26, 2017 at 11:49 AM, David Ahern <dsahern@gmail.com> wrote:
>>> On 7/26/17 12:27 PM, Roopa Prabhu wrote:
>>>> agreed...so looks like the check in v3 should be
>>>>
>>>>
>>>> +       if ( rt == net->ipv6.ip6_null_entry ||
>>>> +            (rt->dst.error &&
>>>> + #ifdef CONFIG_IPV6_MULTIPLE_TABLES
>>>> +              rt != net->ipv6.ip6_prohibit_entry &&
>>>> +              rt != net->ipv6.ip6_blk_hole_entry &&
>>>> +#endif
>>>> +             )) {
>>>>                 err = rt->dst.error;
>>>>                 ip6_rt_put(rt);
>>>>                 goto errout;
>>>>
>>>
>>> I don't think so. If I add a prohibit route and use the fibmatch
>>> attribute, I want to see the route from the FIB that was matched.
>>
>>
>> yes, exactly. wouldn't  'rt != net->ipv6.ip6_prohibit_entry' above let
>> it fall through to the route fill code ?
>>
>> ah...but i guess you are saying that they will have rt6_info's of
>> their own and will not match. got it. ack.
>>
>
> This:
>
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index 4d30c96a819d..24de81c804c2 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -3637,11 +3637,6 @@ static int inet6_rtm_getroute(struct sk_buff
> *in_skb, struct nlmsghdr *nlh,
>                 dst = ip6_route_lookup(net, &fl6, 0);
>
>         rt = container_of(dst, struct rt6_info, dst);
> -       if (rt->dst.error) {
> -               err = rt->dst.error;
> -               ip6_rt_put(rt);
> -               goto errout;
> -       }
>
>         if (rt == net->ipv6.ip6_null_entry) {
>                 err = rt->dst.error;
>
> Puts back the original behavior. In that case, only rt == null_entry
> drops to the error path which is correct. All other rt values will drop
> to rt6_fill_node and return rt data.

yes, i thought so too and hence acked v1. But, following congs
comment, realized that it may mask some real errors for fibmatch ?

I just tested a case of unreachable route with just the above patch
you posted, and I do get the error correctly.

so, I guess you are saying all real errors for fibmatch will have "rt
== net->ipv6.ip6_null_entry" and we should be ok.
sounds good to me.
