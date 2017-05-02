From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: net/ipv6: use-after-free in __call_rcu/in6_dev_finish_destroy_rcu
Date: Mon, 1 May 2017 20:44:22 -0600
Message-ID: <e133f72f-89ab-bf45-67f5-4ad0c502adc4@cumulusnetworks.com>
References: <CAAeHK+y=YqG0Kb2chQ=_2E8aPttMetQjZPCxFibHKCfktQS2PQ@mail.gmail.com>
 <20170426135950.GO3956@linux.vnet.ibm.com>
 <CAAeHK+yzuh7mAmLR9DgHsLYBykqD8YhFcv=Nx6Az_f+PV_YMzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Lai Jiangshan <jiangshanlai@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Andrey Konovalov <andreyknvl@google.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAAeHK+yzuh7mAmLR9DgHsLYBykqD8YhFcv=Nx6Az_f+PV_YMzw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/26/17 9:15 AM, Andrey Konovalov wrote:
> +David
> 
> I've enabled CONFIG_DEBUG_OBJECTS_RCU_HEAD and this is what I get.
> 
> Apparently the rcu warning is related to the fib6_del_route bug I've
> been trying to reproduce:
> https://groups.google.com/forum/#!msg/syzkaller/3SS80JbVPKA/2tfIAcW7DwAJ
> 
> Adding David, who provided the fix:
> https://patchwork.ozlabs.org/patch/754913/
> 
> I've managed to extract a reproducer, attached together with the
> .config that I used.
> 
> On commit 5a7ad1146caa895ad718a534399e38bd2ba721b7 (4.11-rc8) with
> David's patch applied.
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

I think I got to the bottom of this one.

With your config, ip6_tunnel is compiled in.

The program runs in a very tight loop, calling 'unshare -n' and then
spawns 2 sets of 14 threads running random ioctl calls. The networking
sequence:

1. New network namespace created via unshare -n
- ip6tnl0 device is created in down state

2. address added to ip6tnl0 (equivalent to ip -6 addr add dev ip6tnl0
fd00::bb/1)
- the host route is created and inserted into FIB

3. ip6tnl0 is brought up - starts DAD on the address

4. exit namespace
- teardown / cleanup sequence starts
- lo teardown appears to happen BEFORE teardown of ip6tunl0
  + removes host route from FIB
  + host route added to rcu callback list: call_rcu(&rt->dst.rcu_head,
dst_rcu_free);
  + rcu callback has not run yet, so rt is NOT on the gc list so it has
    NOT been marked obsolete

5. worker_thread runs addrconf_dad_completed
- calls ipv6_ifa_notify which inserts the host route

All of that happens very quickly. The result is that a route that has
been deleted and added to the RCU list is re-inserted into the FIB. What
happens next depends on order -- in this case the exit namespace
eventually gets to cleaning up ip6tnl0 which removes the host route from
the FIB, calls the rcu function for cleanup -- and triggers the double
rcu trace.

I have a hack that flags this sequence and prevents the re-insertion
following DAD. That allows the command to run until it consumes all 2G
of memory the VM has -- about 600+ iterations without triggering any
stack traces.
