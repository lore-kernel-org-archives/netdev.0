From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Fri, 28 Jul 2017 10:13:25 -0700
Message-ID: <CAJieiUgxQ+okYAffbb6dqA-=U9qn1QA7A3-ZJ8=HC=o1bkF3ow@mail.gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com> <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com> <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com> <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
 <CAJieiUgyHDksxVjoCSz9pxbDy-ZZR9uUWWZXdth0diSKAcvx4Q@mail.gmail.com>
 <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com> <CAM_iQpU5EZr1rtgY8sCBjD=utzmi9c6MQ2xb36iXLk++qSk3WA@mail.gmail.com>
 <7f404f61-0b9a-b25b-3c15-83395d30641d@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:34837 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752027AbdG1RN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:13:26 -0400
Received: by mail-ua0-f174.google.com with SMTP id d29so158951309uai.2
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 10:13:26 -0700 (PDT)
In-Reply-To: <7f404f61-0b9a-b25b-3c15-83395d30641d@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 8:10 AM, David Ahern <dsahern@gmail.com> wrote:
> On 7/27/17 10:56 PM, Cong Wang wrote:
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
>> But net->ipv6.ip6_prohibit_entry is not the prohibit route you can
>> add in user-space, it is only used by rule actions. So do you really
>> want to dump it?? My gut feeling is no, but I am definitely not sure.
>>
>> When you add a prohibit route, a new rt is allocated dynamically,
>> net->ipv6.ip6_prohibit_entry is relatively static, internal and is the
>> only one per netns. (Same for net->ipv6.ip6_blk_hole_entry)
>>
>> I think Hangbin's example doesn't have ip rules, so this case
>> is not shown up.
>>
>
> Understood. The v4 patch returns getroute to the original behavior. The
> original behavior returned a route entry not just an error code. The
> following is at 5dafc87f40d7 which the commit before roopa's patch set:
>
> # ip -6 ru add to 6000::/120 prohibit
> # ip -6 ro get 6000::1
> prohibit 6000::1 from :: dev lo proto kernel src 2001:db8::3 metric
> 4294967295  error -13 pref medium
>
> # ip -6 ro add vrf red prohibit 5000::1/120
> # ip -6 ro get vrf red 5000::1
> prohibit 5000::1 from :: dev lo table red src 2001:db8::3 metric 1024
> error -13 pref medium
>
> Generically, the only time you get just an error response is when the
> lookup fails to find a match and returns the null_entry which has
> dst.error = -ENETUNREACH.
>
>
> Now to your point about the new fibmatch option I have gone back and
> forth but in the end I think returning the route associated with the FIB
> rule is better than just failing with an error code.
>
> Roopa?

for fibmatch, my original intent was to return with an error code.
This is similar
to the ipv4 behavior. One option is to keep the check in there and put
the 'fibmatch'
condition around it. But, i do want to make sure that for the fibmatch case,
it does not return an error directly on an existing prohibit route
entry in the fib.
This is probably doable by checking for appropriate
net->ipv6.ip6_prohibit_entry entries.
