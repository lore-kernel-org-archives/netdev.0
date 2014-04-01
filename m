From: Sasha Levin <sasha.levin@oracle.com>
Subject: netfilter: NULL ptr deref on boot in xt_register_table
Date: Tue, 01 Apr 2014 00:21:53 -0400
Message-ID: <533A3EE1.7000104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, kadlec@blackhole.kfki.hu,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,


While fuzzing with trinity inside a KVM tools guest running latest -next
kernel I've stumbled on the following spew.

Since it sometimes happens during boot it seems like a race, but I can't
really figure what it's racing with so early in the process.

[   28.463086] ip_tables: (C) 2000-2006 Netfilter Core Team
[   28.465649] BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
[   28.467037] IP: strcmp (lib/string.c:251)
[   28.467999] PGD 0
[   28.468274] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   28.468933] Dumping ftrace buffer:
[   28.469426]    (ftrace buffer empty)
[   28.469809] Modules linked in:
[   28.470075] CPU: 8 PID: 1 Comm: swapper/0 Tainted: G        W     3.14.0-rc8-next-20140331-sasha-00013-g7a8780f #351
[   28.470075] task: ffff88096c5c8000 ti: ffff88003e298000 task.ti: ffff88003e298000
[   28.470075] RIP: strcmp (lib/string.c:251)
[   28.470075] RSP: 0000:ffff88003e299be8  EFLAGS: 00010217
[   28.470075] RAX: 0000000000000002 RBX: ffff88026beb7008 RCX: 0000000000000006
[   28.470075] RDX: 0000000000000000 RSI: ffff88026beb7038 RDI: 0000000000000030
[   28.470075] RBP: ffff88003e299be8 R08: 0000000000000000 R09: 0000000000000000
[   28.470075] R10: 0000000000000001 R11: 0000000000000000 R12: ffffffffa2f291b8
[   28.470075] R13: ffff88026beb7038 R14: ffffffffa2f28400 R15: 0000000000000000
[   28.470075] FS:  0000000000000000(0000) GS:ffff88026cc00000(0000) knlGS:0000000000000000
[   28.470075] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   28.470075] CR2: 0000000000000030 CR3: 0000000021e2c000 CR4: 00000000000006a0
[   28.470075] Stack:
[   28.470075]  ffff88003e299c58 ffffffffa0004d04 ffffffffa2f28400 ffff88026bea13b0
[   28.470075]  ffff88003e299c78 0200000000000278 ffff88003e299c58 0000000000000000
[   28.470075]  0000000000000008 ffff88026bea13b0 0000000000000000 ffff88003e299c78
[   28.470075] Call Trace:
[   28.470075] xt_register_table (net/netfilter/x_tables.c:905)
[   28.470075] ipt_register_table (net/ipv4/netfilter/ip_tables.c:2088)
[   28.470075] ? mutex_lock_nested (arch/x86/include/asm/paravirt.h:809 kernel/locking/mutex.c:569 kernel/locking/mutex.c:587)
[   28.470075] iptable_filter_net_init (net/ipv4/netfilter/iptable_filter.c:72)
[   28.470075] ops_init (net/core/net_namespace.c:107)
[   28.470075] ? mutex_lock_nested (arch/x86/include/asm/preempt.h:98 kernel/locking/mutex.c:570 kernel/locking/mutex.c:587)
[   28.470075] ? register_pernet_subsys (net/core/net_namespace.c:556)
[   28.470075] register_pernet_operations (net/core/net_namespace.c:450 net/core/net_namespace.c:514)
[   28.470075] ? printk (kernel/printk/printk.c:1695)
[   28.470075] ? ip_tables_init (net/ipv4/netfilter/iptable_filter.c:87)
[   28.470075] ? ip_tables_init (net/ipv4/netfilter/iptable_filter.c:87)
[   28.470075] register_pernet_subsys (net/core/net_namespace.c:557)
[   28.470075] iptable_filter_init (net/ipv4/netfilter/iptable_filter.c:91)
[   28.470075] do_one_initcall (init/main.c:696)
[   28.470075] ? parse_args (kernel/params.c:113 kernel/params.c:202)
[   28.470075] kernel_init_freeable (init/main.c:761 init/main.c:770 init/main.c:789 init/main.c:910)
[   28.470075] ? loglevel (init/main.c:241)
[   28.470075] ? rest_init (init/main.c:837)
[   28.470075] kernel_init (init/main.c:842)
[   28.470075] ret_from_fork (arch/x86/kernel/entry_64.S:555)
[   28.470075] ? rest_init (init/main.c:837)
[   28.470075] Code: 83 c6 01 44 88 01 48 83 c1 01 45 84 c0 75 dc 0f 1f 40 00 5d c3 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 0f 1f 40 00 <0f> b6 07 48 83 c7 01 0f b6 16 48 83 c6 01 38 d0 74 0e 19 c0 83
[   28.470075] RIP strcmp (lib/string.c:251)
[   28.470075]  RSP <ffff88003e299be8>
[   28.470075] CR2: 0000000000000030


Thanks,
Sasha
