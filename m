From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Fri, 28 Jul 2017 11:39:52 -0600
Message-ID: <ea0c0319-1b74-da8f-e307-2bf02e674119@gmail.com>
References: <1500562286-14312-1-git-send-email-liuhangbin@gmail.com>
 <CAPwn2JQHyj5gxqTFcJ-u9ABe544ivTBWskQfMgk2a2NirCF5rg@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Hangbin Liu <liuhangbin@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34769 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752484AbdG1Rjz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 13:39:55 -0400
Received: by mail-pg0-f68.google.com with SMTP id v190so24211321pgv.1
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 10:39:55 -0700 (PDT)
In-Reply-To: <CAJieiUgxQ+okYAffbb6dqA-=U9qn1QA7A3-ZJ8=HC=o1bkF3ow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/28/17 11:13 AM, Roopa Prabhu wrote:
> for fibmatch, my original intent was to return with an error code.
> This is similar
> to the ipv4 behavior. One option is to keep the check in there and put
> the 'fibmatch'
> condition around it. But, i do want to make sure that for the fibmatch case,
> it does not return an error directly on an existing prohibit route
> entry in the fib.
> This is probably doable by checking for appropriate
> net->ipv6.ip6_prohibit_entry entries.
> 

IPv4 does not have the notion of null_entry or prohibit route entries
which makes IPv4 and IPv6 inconsistent - something we really need to be
avoiding from a user experience.

We have the following cases:

# ip -4 rule  add to 172.16.60.0/24 prohibit
# ip -4 route add prohibit 172.16.50.0/24
# ip -6 rule  add to 6000::/120 prohibit
# ip -6 route add prohibit 5000::/120


Behavior before Roopa's patch set:
  Rule match:
    # ip ro get 172.16.60.1
    RTNETLINK answers: Permission denied

    # ip -6 ro get 6000::1
    prohibit 6000::1 from :: dev lo proto kernel src 2001:db8::3 metric
4294967295  error -13 pref medium

  Route match:
    # ip ro get 172.16.50.1
    RTNETLINK answers: Permission denied

    # ip -6 ro get 5000::1
    prohibit 5000::1 from :: dev lo table red src 2001:db8::3 metric
1024  error -13 pref medium


Behavior after Roopa's patch set:
  Rule match:
    # ip ro get 172.16.60.1
    RTNETLINK answers: Permission denied

    # ip -6 ro get 6000::1
    RTNETLINK answers: Permission denied

  Route match:
    # ip ro get 172.16.50.1
    RTNETLINK answers: Permission denied

    # ip -6 ro get 5000::1
    RTNETLINK answers: Permission denied


So Roopa's fibmatch patches brings consistency between IPv4 and IPv6 at
the cost of breaking backwards compatibility for IPv6 when the prohibit
or blackhole routes are hit.

If that is not acceptable, then let's wrap the change in 'if (fibmatch)'
so that when fibmatch is requested we have consistency between IPv4 and
IPv6 when it is set.
