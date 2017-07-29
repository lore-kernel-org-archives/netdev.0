From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Sat, 29 Jul 2017 08:41:00 -0600
Message-ID: <cabe22e9-f300-ffa5-46bc-c8b48ea91b66@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JTF+j84+Bv4Zn=pqju2tnMuuJrhTr9Un786-PZ0D6af3w@mail.gmail.com>
 <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
 <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com>
 <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
 <CAJieiUgyHDksxVjoCSz9pxbDy-ZZR9uUWWZXdth0diSKAcvx4Q@mail.gmail.com>
 <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com>
 <CAM_iQpU5EZr1rtgY8sCBjD=utzmi9c6MQ2xb36iXLk++qSk3WA@mail.gmail.com>
 <7f404f61-0b9a-b25b-3c15-83395d30641d@gmail.com>
 <CAJieiUgxQ+okYAffbb6dqA-=U9qn1QA7A3-ZJ8=HC=o1bkF3ow@mail.gmail.com>
 <ea0c0319-1b74-da8f-e307-2bf02e674119@gmail.com>
 <CAJieiUiqFTAuPpUZF1_v7fbfGPiqdj+wagKwUKbvtfUJognT1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:32828 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753717AbdG2OlF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 10:41:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id u185so3969182pgb.0
        for <netdev@vger.kernel.org>; Sat, 29 Jul 2017 07:41:05 -0700 (PDT)
In-Reply-To: <CAJieiUiqFTAuPpUZF1_v7fbfGPiqdj+wagKwUKbvtfUJognT1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/17 1:52 PM, Roopa Prabhu wrote:
> On Fri, Jul 28, 2017 at 10:39 AM, David Ahern <dsahern@gmail.com> wrote:
>> IPv4 does not have the notion of null_entry or prohibit route entries
>> which makes IPv4 and IPv6 inconsistent - something we really need to be
>> avoiding from a user experience.
>>
>> We have the following cases:
>>
>> # ip -4 rule  add to 172.16.60.0/24 prohibit
>> # ip -4 route add prohibit 172.16.50.0/24
>> # ip -6 rule  add to 6000::/120 prohibit
>> # ip -6 route add prohibit 5000::/120
>>
>>
>> Behavior before Roopa's patch set:
>>   Rule match:
>>     # ip ro get 172.16.60.1
>>     RTNETLINK answers: Permission denied
>>
>>     # ip -6 ro get 6000::1
>>     prohibit 6000::1 from :: dev lo proto kernel src 2001:db8::3 metric
>> 4294967295  error -13 pref medium
>>
>>   Route match:
>>     # ip ro get 172.16.50.1
>>     RTNETLINK answers: Permission denied
>>
>>     # ip -6 ro get 5000::1
>>     prohibit 5000::1 from :: dev lo table red src 2001:db8::3 metric
>> 1024  error -13 pref medium
>>
>>
>> Behavior after Roopa's patch set:
>>   Rule match:
>>     # ip ro get 172.16.60.1
>>     RTNETLINK answers: Permission denied
>>
>>     # ip -6 ro get 6000::1
>>     RTNETLINK answers: Permission denied
>>
>>   Route match:
>>     # ip ro get 172.16.50.1
>>     RTNETLINK answers: Permission denied
>>
>>     # ip -6 ro get 5000::1
>>     RTNETLINK answers: Permission denied
>>
>>
>> So Roopa's fibmatch patches brings consistency between IPv4 and IPv6 at
>> the cost of breaking backwards compatibility for IPv6 when the prohibit
>> or blackhole routes are hit.
>>
>> If that is not acceptable, then let's wrap the change in 'if (fibmatch)'
>> so that when fibmatch is requested we have consistency between IPv4 and
>> IPv6 when it is set.
> 
> 
> David, Thanks for listing all the cases and options.
> 
> for the route match fibmatch case, if a prohibit route entry exists
> (added by user), I was hoping fibmatch can return that entry...
> 
>  # ip -6 ro get fibmatch 5000::1
>     prohibit 5000::1 from :: dev lo
> 
> because the semantics of fibmatch is to return the matching route
> entry if exists.
> I am assuming that is possible with appropriate checks around the
> dst.error check for fibmatch. what do you say ?
> I need to verify if this can work for ipv4 the same way.
> 

Routes such as prohibit, blackhole and unreachable cause
fib_table_lookup to return an error (see the fib_props reference in
fib_table_lookup) and the IPv4 code does not generate an rtable for
them. IMO it does not make sense to complicate the general IPv4 lookup
code to create an rtable for these 'special' routes just for the
fibmatch getroute case. Furthermore, I think consistency between IPv4
and IPv6 is important from a programmability perspective which is what
we have now.

DaveM: as I outlined above, Roopa's fibmatch patches caused a change in
user behavior in IPv6 getroute for prohibit, blackhole and unreachable
route entries. Opinions on whether we should limit that new behavior to
just the fibmatch lookup in which case a patch is needed or take the new
behavior and consistency in which case nothing is needed?
