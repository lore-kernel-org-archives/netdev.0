From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Thu, 8 Jun 2017 22:55:47 -0700
Message-ID: <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
 <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com> <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
 <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com> <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        David Ahern <dsahern@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35269 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751501AbdFIF4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 01:56:08 -0400
Received: by mail-wm0-f51.google.com with SMTP id x70so89329038wme.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 22:56:08 -0700 (PDT)
In-Reply-To: <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 8, 2017 at 2:27 PM, Ben Greear <greearb@candelatech.com> wrote:
>
> As far as I can tell, the patch did not help, or at least we still reproduce
> the
> crash easily.

netlink dump is serialized by nlk->cb_mutex so I don't think that
patch makes any sense w.r.t race condition.


> (gdb) l *(fib6_walk_continue+0x76)
> 0x188c6 is in fib6_walk_continue
> (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:1593).
> 1588                            if (fn == w->root)
> 1589                                    return 0;
> 1590                            pn = fn->parent;
> 1591                            w->node = pn;
> 1592    #ifdef CONFIG_IPV6_SUBTREES
> 1593                            if (FIB6_SUBTREE(pn) == fn) {

Apparently fn->parent is NULL here for some reason, but
I don't know if that is expected or not. If a simple NULL check
is not enough here, we have to trace why it is NULL.


> 1594                                    WARN_ON(!(fn->fn_flags & RTN_ROOT));
> 1595                                    w->state = FWS_L;
> 1596                                    continue;
> 1597                            }
> (gdb) l *(inet6_dump_fib+0x1ab)
> 0x1939b is in inet6_dump_fib
> (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:392).
> 387                             w->skip = w->count;
> 388                     } else
> 389                             w->skip = 0;
> 390
> 391                     res = fib6_walk_continue(w);
> 392                     read_unlock_bh(&table->tb6_lock);
> 393                     if (res <= 0) {
> 394                             fib6_walker_unlink(net, w);
> 395                             cb->args[4] = 0;
> 396                     }
> (gdb)


Thanks.
