From: Dmitry Vyukov <dvyukov@google.com>
Subject: Resource leak in unshare
Date: Mon, 2 Nov 2015 12:05:09 +0100
Message-ID: <CACT4Y+Y5mcBrnLOsXchJVrO_8FD-u=EFU67WsH3bU51aAU-idA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Kees Cook <keescook@google.com>,
	Julien Tinnes <jln@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Miller <davem@davemloft.net>, nicolas.dichtel@6wind.com,
	Al Viro <viro@zeniv.linux.org.uk>, Thomas Graf <tgraf@suug.ch>,
	ebiederm@xmission.com, xiyou.wangcong@gmail.com,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I am hitting the following warnings on
bcee19f424a0d8c26ecf2607b73c690802658b29 (4.3):

------------[ cut here ]------------
WARNING: CPU: 3 PID: 16049 at fs/proc/generic.c:575
remove_proc_entry+0x284/0x2f0()
remove_proc_entry: removing non-empty directory 'net/dev_snmp6',
leaking at least 'sit0'
Modules linked in:
CPU: 3 PID: 16049 Comm: syzkaller_execu Not tainted 4.3.0-rc2+ #21
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88000c91fad8 ffffffff81a44e70 ffff88000c91fb48
 ffff88006e39e800 ffffffff83098e40 ffff88000c91fb18 ffffffff810fa399
 ffffffff815c4d14 ffffed0001923f65 ffffffff83098e40 000000000000023f
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81a44e70>] dump_stack+0x68/0x88 lib/dump_stack.c:50
 [<ffffffff810fa399>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:447
 [<ffffffff810fa4a9>] warn_slowpath_fmt+0xa9/0xd0 kernel/panic.c:459
 [<ffffffff815c4d14>] remove_proc_entry+0x284/0x2f0 fs/proc/generic.c:573
 [<ffffffff82aefc6a>] ipv6_proc_exit_net+0x6a/0xc0 net/ipv6/proc.c:328
 [<ffffffff8272b87e>] ops_exit_list.isra.6+0xae/0x150
net/core/net_namespace.c:134
 [<ffffffff8272d390>] setup_net+0x2a0/0x4a0 net/core/net_namespace.c:301
 [<ffffffff8272eb5e>] copy_net_ns+0xbe/0x1d0 net/core/net_namespace.c:367
 [<ffffffff811577bf>] create_new_namespaces+0x2ff/0x620 kernel/nsproxy.c:95
 [<ffffffff81157f0e>] unshare_nsproxy_namespaces+0xae/0x160 kernel/nsproxy.c:190
 [<     inline     >] SYSC_unshare kernel/fork.c:2023
 [<ffffffff810f943c>] SyS_unshare+0x37c/0x790 kernel/fork.c:1973
 [<ffffffff82e3acd1>] entry_SYSCALL_64_fastpath+0x31/0x95
arch/x86/entry/entry_64.S:187
---[ end trace fd4be0a0d59bcf96 ]---

------------[ cut here ]------------
WARNING: CPU: 2 PID: 11469 at fs/proc/generic.c:575
remove_proc_entry+0x284/0x2f0()
remove_proc_entry: removing non-empty directory 'net/dev_snmp6',
leaking at least 'lo'
Modules linked in:
CPU: 2 PID: 11469 Comm: syzkaller_execu Not tainted 4.3.0-rc2+ #21
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 00000000ffffffff ffff88003ec3fad8 ffffffff81a44e70 ffff88003ec3fb48
 ffff88003cdfa700 ffffffff83098e40 ffff88003ec3fb18 ffffffff810fa399
 ffffffff815c4d14 ffffed0007d87f65 ffffffff83098e40 000000000000023f
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff81a44e70>] dump_stack+0x68/0x88 lib/dump_stack.c:50
 [<ffffffff810fa399>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:447
 [<ffffffff810fa4a9>] warn_slowpath_fmt+0xa9/0xd0 kernel/panic.c:459
 [<ffffffff815c4d14>] remove_proc_entry+0x284/0x2f0 fs/proc/generic.c:573
 [<ffffffff82aefc6a>] ipv6_proc_exit_net+0x6a/0xc0 net/ipv6/proc.c:328
 [<ffffffff8272b87e>] ops_exit_list.isra.6+0xae/0x150
net/core/net_namespace.c:134
 [<ffffffff8272d390>] setup_net+0x2a0/0x4a0 net/core/net_namespace.c:301
 [<ffffffff8272eb5e>] copy_net_ns+0xbe/0x1d0 net/core/net_namespace.c:367
 [<ffffffff811577bf>] create_new_namespaces+0x2ff/0x620 kernel/nsproxy.c:95
 [<ffffffff81157f0e>] unshare_nsproxy_namespaces+0xae/0x160 kernel/nsproxy.c:190
 [<     inline     >] SYSC_unshare kernel/fork.c:2023
 [<ffffffff810f943c>] SyS_unshare+0x37c/0x790 kernel/fork.c:1973
 [<ffffffff82e3acd1>] entry_SYSCALL_64_fastpath+0x31/0x95
arch/x86/entry/entry_64.S:187
---[ end trace 95bc097df8fd8f83 ]---


The trigger seems to be unshare syscall happening in low memory
conditions, so that error cleanup paths are triggered.

Found with syzkaller syscall fuzzer.
