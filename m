From: Yury Norov <ynorov@caviumnetworks.com>
Subject: Re: arm64: next-20170428 hangs on boot
Date: Fri, 28 Apr 2017 18:09:31 +0300
Message-ID: <20170428150931.iyoewmc5qs55aw3t@yury-N73SV>
References: <20170428132429.c3dlxbmt7iqs2isl@yury-N73SV>
 <20170428145233.GB5292@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, davem@davemloft.net
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170428145233.GB5292@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 28, 2017 at 03:52:34PM +0100, Mark Rutland wrote:
> On Fri, Apr 28, 2017 at 04:24:29PM +0300, Yury Norov wrote:
> > Hi all,
> 
> Hi,
> 
> [adding Dave Miller, netdev, lkml]

thanks

> > On QEMU the next-20170428 hangs on boot for me due to kernel panic in 
> > rtnetlink_init():
> > 
> > void __init rtnetlink_init(void)
> > {
> >         if (register_pernet_subsys(&rtnetlink_net_ops))
> >                 panic("rtnetlink_init: cannot initialize rtnetlink\n");
> > 
> >         ...
> > }
> 
> I see the same thing with a next-20170428 arm64 defconfig, on a Juno R1
> system:
> 
> [    0.531949] Kernel panic - not syncing: rtnetlink_init: cannot initialize rtnetlink
> [    0.531949] 
> [    0.541271] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.11.0-rc8-next-20170428-00002-g6ee3799 #10
> [    0.550307] Hardware name: ARM Juno development board (r1) (DT)
> [    0.556332] Call trace:
> [    0.558833] [<ffff000008088538>] dump_backtrace+0x0/0x238
> [    0.564332] [<ffff000008088834>] show_stack+0x14/0x20
> [    0.569477] [<ffff00000839dd54>] dump_stack+0x9c/0xc0
> [    0.574622] [<ffff000008175344>] panic+0x11c/0x28c
> [    0.579505] [<ffff000008d80034>] rtnetlink_init+0x2c/0x1d0
> [    0.585092] [<ffff000008d8047c>] netlink_proto_init+0x14c/0x17c
> [    0.591119] [<ffff000008083150>] do_one_initcall+0x38/0x120
> [    0.596796] [<ffff000008d30d00>] kernel_init_freeable+0x1a0/0x240
> [    0.603003] [<ffff00000892a790>] kernel_init+0x10/0x100
> [    0.608324] [<ffff000008082ec0>] ret_from_fork+0x10/0x50
> [    0.613736] SMP: stopping secondary CPUs
> [    0.617738] ---[ end Kernel panic - not syncing: rtnetlink_init: cannot initialize rtnetlink
> 
> If this isn't a known issue, it would be worth trying to bisect this.

The exact function that fails is: 
include/linux/rhashtable.h
static inline void *__rhashtable_insert_fast(
        struct rhashtable *ht, const void *key, struct rhash_head *obj,
        const struct rhashtable_params params, bool rhlist)
{
        ...

        data = ERR_PTR(-E2BIG);
        if (unlikely(rht_grow_above_max(ht, tbl)))
               goto out;
        ...

out:
        spin_unlock_bh(lock);
        rcu_read_unlock();

        return data;
}

And the backtrace:
#0  __rhashtable_insert_fast (rhlist=<optimized out>, params=..., obj=<optimized out>, 
    key=<optimized out>, ht=<optimized out>) at ./include/linux/rhashtable.h:803
#1  rhashtable_lookup_insert_key (params=..., obj=<optimized out>, key=<optimized out>, 
    ht=<optimized out>) at ./include/linux/rhashtable.h:980
#2  __netlink_insert (sk=<optimized out>, table=<optimized out>) at net/netlink/af_netlink.c:484
#3  netlink_insert (sk=0xffff80003da85000, portid=0) at net/netlink/af_netlink.c:548
#4  0xffff00000876c5a0 in __netlink_kernel_create (net=<optimized out>, unit=0, module=0x0, 
    cfg=0xffff80003d84fc60) at net/netlink/af_netlink.c:1996
#5  0xffff000008756704 in netlink_kernel_create (cfg=<optimized out>, unit=<optimized out>, 
    net=<optimized out>) at ./include/linux/netlink.h:62
#6  rtnetlink_net_init (net=0xffff000008c7c100 <init_net>) at net/core/rtnetlink.c:4175
#7  0xffff000008737a2c in ops_init (ops=0xffff000008c7e268 <rtnetlink_net_ops>, 
    net=0xffff000008c7c100 <init_net>) at net/core/net_namespace.c:117
#8  0xffff000008738704 in __register_pernet_operations (ops=<optimized out>,
    list=<optimized out>) at net/core/net_namespace.c:818
#9  register_pernet_operations (list=<optimized out>, ops=0xffff000008c7e268
    <rtnetlink_net_ops>) at net/core/net_namespace.c:892
#10 0xffff0000087387fc in register_pernet_subsys (ops=0xffff000008c7e268
    <rtnetlink_net_ops>) at net/core/net_namespace.c:934
#11 0xffff000008b5b9b8 in rtnetlink_init () at net/core/rtnetlink.c:4195
#12 0xffff000008b5be08 in netlink_proto_init () at net/netlink/af_netlink.c:2730
#13 0xffff000008083158 in do_one_initcall (fn=0xffff000008b5bcc4 <netlink_proto_init>) at init/main.c:795
#14 0xffff000008b20d04 in do_initcall_level (level=<optimized out>) at init/main.c:861
#15 do_initcalls () at init/main.c:869
#16 do_basic_setup () at init/main.c:887

Yury
