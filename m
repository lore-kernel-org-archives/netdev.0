From: Hangbin Liu <liuhangbin@gmail.com>
Subject: Re: [PATCH net] ipv6: no need to return rt->dst.error if it is not
 null entry.
Date: Fri, 28 Jul 2017 00:08:22 +0800
Message-ID: <20170727160822.GE5465@leo.usersys.redhat.com>
References: <20170724030907.GC2938@leo.usersys.redhat.com>
 <CAM_iQpW4qj2N77QrCvt9jd6jhOGvyRye8eyBzzk+vXeUi_FaoQ@mail.gmail.com>
 <20170725000849.GD2938@leo.usersys.redhat.com>
 <01b1cd24-ab81-3276-f253-70eef20e550b@gmail.com>
 <20170725073202.GE2938@leo.usersys.redhat.com>
 <9e198c2a-c026-f4bd-f190-8d5a887efe7f@gmail.com>
 <CAJieiUgyHDksxVjoCSz9pxbDy-ZZR9uUWWZXdth0diSKAcvx4Q@mail.gmail.com>
 <64377a01-38df-6d43-16a4-401d426fb9b2@gmail.com>
 <CAJieiUi+Me_wXDz0A1oLH2LgBw9DsMoxctV56SjEwGpusFGt4Q@mail.gmail.com>
 <2d75317c-160c-01c2-5a5b-bc6111c099c6@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        network dev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:33027 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750981AbdG0QIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 12:08:34 -0400
Received: by mail-pg0-f44.google.com with SMTP id c14so7257821pgn.0
        for <netdev@vger.kernel.org>; Thu, 27 Jul 2017 09:08:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <2d75317c-160c-01c2-5a5b-bc6111c099c6@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Wed, Jul 26, 2017 at 01:00:26PM -0600, David Ahern wrote:
> >> I don't think so. If I add a prohibit route and use the fibmatch
> >> attribute, I want to see the route from the FIB that was matched.
> > 
> > 
> > yes, exactly. wouldn't  'rt != net->ipv6.ip6_prohibit_entry' above let
> > it fall through to the route fill code ?
> > 
> > ah...but i guess you are saying that they will have rt6_info's of
> > their own and will not match. got it. ack.
> > 
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

Thanks for your explains. Now I know where I made the mistake. I mis-looked
FR_ACT_UNREACHABLE to RTN_UNREACHABLE and thought we return rt =
net->ipv6.ip6_null_entry in fib6_rule_action().

With you help I know we just set rt->dst.error to -EACCES for prohibit
entry in ip6_route_info_create. So remove the rt->dst.error check is enought.

Thanks
Hangbin
