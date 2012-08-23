From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: IPv6 deadlock with CONFIG_IPV6_ROUTER_PREF
Date: Thu, 23 Aug 2012 23:10:37 +0800
Message-ID: <CAF1ivSZN8PyPhAkyaFL-GsTbnr4uwP=zzzjZbgqOKts_wgngYA@mail.gmail.com>
References: <CC52AD11.7CC2%dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hunt, Joshua" <johunt@akamai.com>,
	"dbavatar@gmail.com" <dbavatar@gmail.com>,
	"Lubashev, Igor" <ilubashe@akamai.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Banerjee, Debabrata" <dbanerje@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CC52AD11.7CC2%dbanerje@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 17, 2012 at 1:58 AM, Banerjee, Debabrata
<dbanerje@akamai.com> wrote:
> This code tries to send a neighbor discovery ICMPv6 packet for router
> reachability while read_lock(tb6_lock) is held. The send may want to cause
> a fib6_clean_all() garbage collection, which will try to take
> write_lock(tb6_lock), resulting in deadlock. Garbage collection becomes
> more likely under high load of cloned routes, so this is exploitable as a
> DDOS attack, given enough attack hosts in relation max_size of the route
> table (default of 4k). I checked from 3.6-rc1 back to 2.6.32, it is
> present everywhere.

How about moving the garbage collection to a kernel thread?
Then the write_lock(tb6_lock) in this kernel thread won't cause such
kind of dead lock with other threads.

Lin Ming

>
> Stack trace below.
>
> Thanks,
> Debabrata
>
> [46476.055009] Pid: 7963, comm: xxxx Not tainted 2.6.38-amd64
> [46476.055009] RIP: 0010:[<ffffffff812878c9>]  [<ffffffff812878c9>]
> __write_lock_failed+0x9/0x20
> [46476.055009] RSP: 0018:ffff8801a099f8f0  EFLAGS: 00200287
> [46476.055009] RAX: ffff8801a099ffd8 RBX: 0000000000000000 RCX:
> 0000000000000000
> [46476.055009] RDX: 0000000000000000 RSI: ffffffffa0196e60 RDI:
> ffff88020bc95454
> [46476.055009] RBP: ffff8801a099f908 R08: ffff8801a099fb78 R09:
> 0000000000000003
> [46476.055009] R10: ffff8801a099fa38 R11: ffff88020ebf1c00 R12:
> ffffffff8100370e
> [46476.055009] R13: 0000000000000000 R14: 0000000000000000 R15:
> 0000000000000000
> [46476.055009] FS:  00007fa1f4a596d0(0000) GS:ffff8800e7c00000(0063)
> knlGS:00000000f6a5fba0
> [46476.055009] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
> [46476.055009] CR2: 00000000f7791000 CR3: 00000001a0bcc000 CR4:
> 00000000000006f0
> [46476.055009] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
> 0000000000000000
> [46476.055009] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
> 0000000000000400
> [46476.055009] Process xxxx (pid: 7963, threadinfo ffff8801a099e000, task
> ffff8801a099c880)
> [46476.055009] Stack:
> [46476.055009]  ffffffff81482c17 ffff8801a099f928 ffff88020bc95454
> ffff8801a099f948
> [46476.055009]  ffffffffa01972f9 ffffffffa0196e60 0000000000000200
> ffffffff81960a80
> [46476.055009]  0000000000000d80 000000000000ea60 00000001004cbccc
> ffff8801a099f968
> [46476.055009] Call Trace:
> [46476.055009]  [<ffffffff81482c17>] ? _raw_write_lock_bh+0x27/0x30
> (deadlock on write_lock tb6_lock)
> [46476.055009]  [<ffffffffa01972f9>] fib6_clean_all+0x49/0x90 [ipv6]
> [46476.055009]  [<ffffffffa0196e60>] ? fib6_age+0x0/0x80 [ipv6]
> [46476.055009]  [<ffffffffa019744f>] fib6_run_gc+0x4f/0xe0 [ipv6]
> [46476.055009]  [<ffffffffa0193547>] ip6_dst_gc+0x97/0x120 [ipv6]
> [46476.055009]  [<ffffffff813d5515>] dst_alloc+0xa5/0xc0
> [46476.055009]  [<ffffffffa0196c91>] icmp6_dst_alloc+0x51/0x170 [ipv6]
> [46476.055009]  [<ffffffffa019ac3f>] ndisc_send_skb+0x6f/0x2c0 [ipv6]
> [46476.055009]  [<ffffffff81481b2d>] ?
> schedule_hrtimeout_range_clock+0xcd/0x110
> [46476.055009]  [<ffffffffa019aef1>] __ndisc_send+0x61/0x80 [ipv6]
> [46476.055009]  [<ffffffffa019afbc>] ndisc_send_ns+0x6c/0xa0 [ipv6]
> [46476.055009]  [<ffffffffa0195459>] rt6_probe+0xc9/0xd0 [ipv6]
> [46476.055009]  [<ffffffff81120e50>] ? __pollwait+0x0/0x100
> [46476.055009]  [<ffffffffa0195575>] find_match+0x115/0x180 [ipv6]
> [46476.055009]  [<ffffffffa01956b3>] ip6_pol_route+0xd3/0x2d0 [ipv6]
> (read_lock tb6_lock)
> [46476.055009]  [<ffffffffa01958c6>] ip6_pol_route_output+0x16/0x20 [ipv6]
> [46476.055009]  [<ffffffffa0196dfe>] fib6_rule_lookup+0x1e/0x20 [ipv6]
> [46476.055009]  [<ffffffffa01948c1>] ip6_route_output+0x61/0xa0 [ipv6]
> [46476.055009]  [<ffffffffa0188232>] ip6_dst_lookup_tail+0xe2/0xf0 [ipv6]
> [46476.055009]  [<ffffffffa0188255>] ip6_dst_lookup+0x15/0x20 [ipv6]
> [46476.055009]  [<ffffffffa01aca8c>] tcp_v6_connect+0x26c/0x6e0 [ipv6]
> [46476.055009]  [<ffffffff81235a36>] ? security_sk_alloc+0x16/0x20
> [46476.055009]  [<ffffffff8142be49>] inet_stream_connect+0x2a9/0x300
> [46476.055009]  [<ffffffff81482be4>] ? _raw_spin_unlock_bh+0x14/0x20
> [46476.055009]  [<ffffffff813be329>] ? release_sock+0xd9/0x110
> [46476.055009]  [<ffffffff813bc00f>] sys_connect+0xaf/0xd0
> [46476.055009]  [<ffffffff813e4077>] ? compat_sys_setsockopt+0x87/0x220
> [46476.055009]  [<ffffffff81150e28>] ? compat_sys_fcntl64+0x1d8/0x380
> [46476.055009]  [<ffffffff813e4c93>] compat_sys_socketcall+0x93/0x1f0
> [46476.055009]  [<ffffffff810354ec>] cstar_dispatch+0x7/0x32
> [46476.055009] Code: 00 00 48 8b 5b 20 48 83 eb 07 48 39 d9 73 06 48 89 01
> 31 c0 c3 b8 f2 ff ff ff c3 90 90 90 90 90 90 90 f0 81 07 00 00 00 01 f3 90
> <81> 3f 00 00 00 01 75 f6 f0 81 2f 00 00 00 01 0f 85 e2 ff ff ff
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
