From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Repeatable inet6_dump_fib crash in stock 4.12.0-rc4+
Date: Fri, 09 Jun 2017 14:25:57 -0700
Message-ID: <1497043557.736.94.camel@edumazet-glaptop3.roam.corp.google.com>
References: <bbfa5208-3a04-c87a-a6e1-ee0ae73965d0@candelatech.com>
         <a5733c67-e3a3-9cc0-0862-40ef6fc03de3@gmail.com>
         <1496795269.736.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <da189b9d-760f-0591-2acf-1a6b7910e227@gmail.com>
         <1496809166.736.25.camel@edumazet-glaptop3.roam.corp.google.com>
         <94bcc041-6402-d0ce-b9cf-3b46aa622f34@candelatech.com>
         <CAM_iQpXM3G=J0tw=n1_mKno=i41Kmoxb00+nDyBWofWskj5P_A@mail.gmail.com>
         <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Ben Greear <greearb@candelatech.com>,
        netdev <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:35401 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdFIV0A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 17:26:00 -0400
Received: by mail-pg0-f42.google.com with SMTP id k71so30115805pgd.2
        for <netdev@vger.kernel.org>; Fri, 09 Jun 2017 14:26:00 -0700 (PDT)
In-Reply-To: <7e0c97fa-cd6e-ed0f-bf99-0e4af40fbd2f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-09 at 07:27 -0600, David Ahern wrote:
> On 6/8/17 11:55 PM, Cong Wang wrote:
> > On Thu, Jun 8, 2017 at 2:27 PM, Ben Greear <greearb@candelatech.com> wrote:
> >>
> >> As far as I can tell, the patch did not help, or at least we still reproduce
> >> the
> >> crash easily.
> > 
> > netlink dump is serialized by nlk->cb_mutex so I don't think that
> > patch makes any sense w.r.t race condition.
> 
> From what I can see fn_sernum should be accessed under table lock, so
> when saving and checking it during a walk make sure it the lock is held.
> That has nothing to do with the netlink dump, but the table changing
> during a walk.


Yes, your patch makes total sense, of course.




> 
> 
> >> (gdb) l *(fib6_walk_continue+0x76)
> >> 0x188c6 is in fib6_walk_continue
> >> (/home/greearb/git/linux-2.6/net/ipv6/ip6_fib.c:1593).
> >> 1588                            if (fn == w->root)
> >> 1589                                    return 0;
> >> 1590                            pn = fn->parent;
> >> 1591                            w->node = pn;
> >> 1592    #ifdef CONFIG_IPV6_SUBTREES
> >> 1593                            if (FIB6_SUBTREE(pn) == fn) {
> > 
> > Apparently fn->parent is NULL here for some reason, but
> > I don't know if that is expected or not. If a simple NULL check
> > is not enough here, we have to trace why it is NULL.
> 
> From my understanding, parent should not be null hence the attempts to
> fix access to table nodes under a lock. ie., figuring out why it is null
> here.
