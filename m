From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net] net: ipv6: Do not duplicate DAD on link up
Date: Wed, 3 May 2017 14:22:46 -0700
Message-ID: <CAM_iQpVJZRzYmWqhYBhoAnv71GkM=0HQW7yUvzUQgVT-5hy_3g@mail.gmail.com>
References: <1493761424-17407-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Dmitry Vyukov <dvyukov@google.com>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35843 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751074AbdECVXI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 17:23:08 -0400
Received: by mail-wm0-f66.google.com with SMTP id u65so419620wmu.3
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 14:23:08 -0700 (PDT)
In-Reply-To: <1493761424-17407-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 2, 2017 at 2:43 PM, David Ahern <dsahern@gmail.com> wrote:
> Andrey reported a warning triggered by the rcu code:
>
> ------------[ cut here ]------------
> WARNING: CPU: 1 PID: 5911 at lib/debugobjects.c:289
> debug_print_object+0x175/0x210
> ODEBUG: activate active (active state 1) object type: rcu_head hint:
>         (null)
> Modules linked in:
> CPU: 1 PID: 5911 Comm: a.out Not tainted 4.11.0-rc8+ #271
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Call Trace:
>  __dump_stack lib/dump_stack.c:16
>  dump_stack+0x192/0x22d lib/dump_stack.c:52
>  __warn+0x19f/0x1e0 kernel/panic.c:549
>  warn_slowpath_fmt+0xe0/0x120 kernel/panic.c:564
>  debug_print_object+0x175/0x210 lib/debugobjects.c:286
>  debug_object_activate+0x574/0x7e0 lib/debugobjects.c:442
>  debug_rcu_head_queue kernel/rcu/rcu.h:75
>  __call_rcu.constprop.76+0xff/0x9c0 kernel/rcu/tree.c:3229
>  call_rcu_sched+0x12/0x20 kernel/rcu/tree.c:3288
>  rt6_rcu_free net/ipv6/ip6_fib.c:158
>  rt6_release+0x1ea/0x290 net/ipv6/ip6_fib.c:188
>  fib6_del_route net/ipv6/ip6_fib.c:1461
>  fib6_del+0xa42/0xdc0 net/ipv6/ip6_fib.c:1500
>  __ip6_del_rt+0x100/0x160 net/ipv6/route.c:2174
>  ip6_del_rt+0x140/0x1b0 net/ipv6/route.c:2187
>  __ipv6_ifa_notify+0x269/0x780 net/ipv6/addrconf.c:5520
>  addrconf_ifdown+0xe60/0x1a20 net/ipv6/addrconf.c:3672
> ...
>
> Andrey's reproducer program runs in a very tight loop, calling
> 'unshare -n' and then spawning 2 sets of 14 threads running random ioctl
> calls. The relevant networking sequence:
>
> 1. New network namespace created via unshare -n
> - ip6tnl0 device is created in down state
>
> 2. address added to ip6tnl0
> - equivalent to ip -6 addr add dev ip6tnl0 fd00::bb/1
> - DAD is started on the address and when it completes the host
>   route is inserted into the FIB
>
> 3. ip6tnl0 is brought up
> - the new fixup_permanent_addr function restarts DAD on the address
>
> 4. exit namespace
> - teardown / cleanup sequence starts
> - once in a blue moon, lo teardown appears to happen BEFORE teardown
>   of ip6tunl0

Why is this possible? Loopback device should be always the first one to
register therefore the last one to unregister.


>   + down on 'lo' removes the host route from the FIB since the dst->dev
>     for the route is loobback
>   + host route added to rcu callback list
>     * rcu callback has not run yet, so rt is NOT on the gc list so it has
>       NOT been marked obsolete
>
> 5. in parallel to 4. worker_thread runs addrconf_dad_completed
> - DAD on the address on ip6tnl0 completes
> - calls ipv6_ifa_notify which inserts the host route
>
> All of that happens very quickly. The result is that a host route that
> has been deleted from the IPv6 FIB and added to the RCU list is re-inserted
> into the FIB.
>
> The exit namespace eventually gets to cleaning up ip6tnl0 which removes the
> host route from the FIB again, calls the rcu function for cleanup -- and
> triggers the double rcu trace.
>
> The root cause is duplicate DAD on the address -- steps 2 and 3. Arguably,
> DAD should not be started in step 2. The interface is in the down state,
> so it can not really send out requests for the address which makes starting
> DAD pointless.
>
> Since the second DAD was introduced by a recent change, seems appropriate
> to use it for the Fixes tag and have the fixup function only start DAD for
> addresses in the PREDAD state which occurs in addrconf_ifdown if the
> address is retained.

Hmm? But addrconf_ifdown() is called when the device is going from UP
to down, how does your patch prevent a duplicated DAD for a device which
is going from DOWN to UP in step 3? This is very confusing.
