From: Dmitry Vyukov <dvyukov@google.com>
Subject: net: memory leak due to CLONE_NEWNET
Date: Sat, 2 Apr 2016 15:55:53 +0200
Message-ID: <CACT4Y+bNxEoM9iEydzsKqO50Pfe3JLJszS=Kyiom47vE=J7cvQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: "David S. Miller" <davem@davemloft.net>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:35813 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbcDBN4O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2016 09:56:14 -0400
Received: by mail-lb0-f179.google.com with SMTP id bc4so98661127lbc.2
        for <netdev@vger.kernel.org>; Sat, 02 Apr 2016 06:56:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

The following program leads to memory leaks in:

unreferenced object 0xffff88005c10d208 (size 96):
  comm "a.out", pid 10753, jiffies 4296778619 (age 43.118s)
  hex dump (first 32 bytes):
    e8 31 85 2d 00 88 ff ff 0f 00 00 00 00 00 00 00  .1.-............
    00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
  backtrace:
    [<ffffffff8679bb23>] kmemleak_alloc+0x63/0xa0 mm/kmemleak.c:915
    [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
    [<     inline     >] slab_post_alloc_hook mm/slab.h:406
    [<     inline     >] slab_alloc_node mm/slub.c:2602
    [<     inline     >] slab_alloc mm/slub.c:2610
    [<ffffffff8179b4c0>] kmem_cache_alloc_trace+0x160/0x3d0 mm/slub.c:2627
    [<     inline     >] kmalloc include/linux/slab.h:478
    [<     inline     >] tc_action_net_init include/net/act_api.h:122
    [<ffffffff8574e62e>] csum_init_net+0x15e/0x450 net/sched/act_csum.c:593
    [<ffffffff8564ffc9>] ops_init+0xa9/0x3a0 net/core/net_namespace.c:109
    [<ffffffff85650474>] setup_net+0x1b4/0x3e0 net/core/net_namespace.c:287
    [<ffffffff85651a56>] copy_net_ns+0xd6/0x1a0 net/core/net_namespace.c:367
    [<ffffffff813d01bf>] create_new_namespaces+0x37f/0x740 kernel/nsproxy.c:106
    [<ffffffff813d0b69>] unshare_nsproxy_namespaces+0xa9/0x1d0
kernel/nsproxy.c:205
    [<     inline     >] SYSC_unshare kernel/fork.c:2019
    [<ffffffff81365283>] SyS_unshare+0x3b3/0x800 kernel/fork.c:1969
    [<ffffffff867b9400>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88005c10e1c8 (size 96):
  comm "a.out", pid 10753, jiffies 4296778620 (age 43.117s)
  hex dump (first 32 bytes):
    e8 0b 85 2d 00 88 ff ff 0f 00 00 00 00 00 ad de  ...-............
    00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
  backtrace:
    [<ffffffff8679bb23>] kmemleak_alloc+0x63/0xa0 mm/kmemleak.c:915
    [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
    [<     inline     >] slab_post_alloc_hook mm/slab.h:406
    [<     inline     >] slab_alloc_node mm/slub.c:2602
    [<     inline     >] slab_alloc mm/slub.c:2610
    [<ffffffff8179b4c0>] kmem_cache_alloc_trace+0x160/0x3d0 mm/slub.c:2627
    [<     inline     >] kmalloc include/linux/slab.h:478
    [<     inline     >] tc_action_net_init include/net/act_api.h:122
    [<ffffffff85753f7e>] ife_init_net+0x15e/0x450 net/sched/act_ife.c:838
    [<ffffffff8564ffc9>] ops_init+0xa9/0x3a0 net/core/net_namespace.c:109
    [<ffffffff85650474>] setup_net+0x1b4/0x3e0 net/core/net_namespace.c:287
    [<ffffffff85651a56>] copy_net_ns+0xd6/0x1a0 net/core/net_namespace.c:367
    [<ffffffff813d01bf>] create_new_namespaces+0x37f/0x740 kernel/nsproxy.c:106
    [<ffffffff813d0b69>] unshare_nsproxy_namespaces+0xa9/0x1d0
kernel/nsproxy.c:205
    [<     inline     >] SYSC_unshare kernel/fork.c:2019
    [<ffffffff81365283>] SyS_unshare+0x3b3/0x800 kernel/fork.c:1969
    [<ffffffff867b9400>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff880025a55b08 (size 96):
  comm "a.out", pid 10702, jiffies 4296768144 (age 61.526s)
  hex dump (first 32 bytes):
    28 ed 55 2b 00 88 ff ff 0f 00 00 00 00 00 00 00  (.U+............
    00 00 00 00 ad 4e ad de ff ff ff ff 00 00 00 00  .....N..........
  backtrace:
    [<ffffffff8679bb23>] kmemleak_alloc+0x63/0xa0 mm/kmemleak.c:915
    [<     inline     >] kmemleak_alloc_recursive include/linux/kmemleak.h:47
    [<     inline     >] slab_post_alloc_hook mm/slab.h:406
    [<     inline     >] slab_alloc_node mm/slub.c:2602
    [<     inline     >] slab_alloc mm/slub.c:2610
    [<ffffffff8179b4c0>] kmem_cache_alloc_trace+0x160/0x3d0 mm/slub.c:2627
    [<     inline     >] kmalloc include/linux/slab.h:478
    [<     inline     >] tc_action_net_init include/net/act_api.h:122
    [<ffffffff8574890e>] nat_init_net+0x15e/0x450 net/sched/act_nat.c:311
    [<ffffffff8564ffc9>] ops_init+0xa9/0x3a0 net/core/net_namespace.c:109
    [<ffffffff85650474>] setup_net+0x1b4/0x3e0 net/core/net_namespace.c:287
    [<ffffffff85651a56>] copy_net_ns+0xd6/0x1a0 net/core/net_namespace.c:367
    [<ffffffff813d01bf>] create_new_namespaces+0x37f/0x740 kernel/nsproxy.c:106
    [<ffffffff813d0b69>] unshare_nsproxy_namespaces+0xa9/0x1d0
kernel/nsproxy.c:205
    [<     inline     >] SYSC_unshare kernel/fork.c:2019
    [<ffffffff81365283>] SyS_unshare+0x3b3/0x800 kernel/fork.c:1969
    [<ffffffff867b9400>] entry_SYSCALL_64_fastpath+0x23/0xc1
arch/x86/entry/entry_64.S:207
    [<ffffffffffffffff>] 0xffffffffffffffff


#include <stdlib.h>
#include <unistd.h>
#include <sched.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <linux/sched.h>

int main()
{
        int pid, status;

        pid = fork();
        if (pid == 0) {
                unshare(CLONE_NEWNET);
                exit(0);
        }
        while (waitpid(pid, &status, 0) != pid) {
        }
        return 0;
}


grep "kmalloc-96" /proc/slabinfo confirms the leak.

I am on commit 05cf8077e54b20dddb756eaa26f3aeb5c38dd3cf (Apr 1).
