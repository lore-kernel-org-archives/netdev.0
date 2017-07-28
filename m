From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Fri, 28 Jul 2017 19:04:42 +0800
Message-ID: <20170728110442.GF5465@leo.usersys.redhat.com>
References: <CAM_iQpUM6m=GvUU0OfwZAFsOGsf1UZmTjmuM9FH2P1iOZP=Svw@mail.gmail.com>
 <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
 <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com>
 <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
 <CAJieiUgyHDksxVjoCSz9pxbDy-ZZR9uUWWZXdth0diSKAcvx4Q@mail.gmail.com>
 <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com>
 <CAM_iQpU5EZr1rtgY8sCBjD=utzmi9c6MQ2xb36iXLk++qSk3WA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsahern@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        network dev <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36507 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751744AbdG1LEy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 07:04:54 -0400
Received: by mail-pg0-f68.google.com with SMTP id y129so23336539pgy.3
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 04:04:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAM_iQpU5EZr1rtgY8sCBjD=utzmi9c6MQ2xb36iXLk++qSk3WA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 09:56:08PM -0700, Cong Wang wrote:
> On Wed, Jul 26, 2017 at 11:49 AM, David Ahern <dsahern@gmail.com> wrote:
> > On 7/26/17 12:27 PM, Roopa Prabhu wrote:
> >> agreed...so looks like the check in v3 should be
> >>
> >>
> >> +       if ( rt == net->ipv6.ip6_null_entry ||
> >> +            (rt->dst.error &&
> >> + #ifdef CONFIG_IPV6_MULTIPLE_TABLES
> >> +              rt != net->ipv6.ip6_prohibit_entry &&
> >> +              rt != net->ipv6.ip6_blk_hole_entry &&
> >> +#endif
> >> +             )) {
> >>                 err = rt->dst.error;
> >>                 ip6_rt_put(rt);
> >>                 goto errout;
> >>
> >
> > I don't think so. If I add a prohibit route and use the fibmatch
> > attribute, I want to see the route from the FIB that was matched.
> 
> But net->ipv6.ip6_prohibit_entry is not the prohibit route you can
> add in user-space, it is only used by rule actions. So do you really
> want to dump it?? My gut feeling is no, but I am definitely not sure.
> 
> When you add a prohibit route, a new rt is allocated dynamically,
> net->ipv6.ip6_prohibit_entry is relatively static, internal and is the
> only one per netns. (Same for net->ipv6.ip6_blk_hole_entry)
> 
> I think Hangbin's example doesn't have ip rules, so this case
> is not shown up.

I mixed the rule entry and route entry these days. And with your help I can
separate them now.

When first time I find the rt->dst.error return directly issue, I was testing
ip rule actually.

e.g.
+ ip netns exec client ip -6 rule add to 2003::1/64 table 100 unreachable
+ ip netns exec server ip -6 rule add to 2001::1/64 table 100 prohibit
+ ip netns exec client ip -6 route get 2003::1
RTNETLINK answers: Network is unreachable
+ ip netns exec client ip -6 route get 2001::1
RTNETLINK answers: Permission denied

After check I thought we returned net->ipv6.ip6_null_entry /
net->ipv6.ip6_blk_hole_entry in function fib6_rule_action().

That's the reason I want to delete both rt->dst.error and
net->ipv6.ip6_null_entry check in patch v2 and v3.

Then with David's comments I realise we also need to take care about ip route
entrys.

my last mail's comment:
> Thanks for your explains. Now I know where I made the mistake. I mis-looked
> FR_ACT_UNREACHABLE to RTN_UNREACHABLE and thought we return rt =
> net->ipv6.ip6_null_entry in fib6_rule_action().

But then I fall in to the code logic and get lost... And thought
FR_ACT_UNREACHABLE and RTN_UNREACHABLE are not same. Today I re-check the
code and realise RTN_UNREACHABLE is defined in user space and FR_ACT_UNREACHABLE
is in kernel. Actually they are the same.

So after PATCH v4, we fixed the route side. And part of ip rule(prohibit and
blk hole). I will think over of this.

Thanks
Hangbin
