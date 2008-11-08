From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: seq_read bugs with ipmr
Date: Sat, 8 Nov 2008 01:22:08 +0100
Message-ID: <20081108002208.GB17721@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alan@lxorguk.ukuu.org.uk
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:55064 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752312AbYKHAWN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Nov 2008 19:22:13 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

running a bunch of network related stresstests (isic, isicng, ...) 
and trying to read all files in /proc afterwards gave me two
oopses. I was able to reproduce them on another box with
a different config. I was able to reproduce this on 2.6.24 too,
so this is no regression. The icmpsic is version 0.06. 
The minimal testcase to trigger this:

------------8<----------------
#!/bin/bash

icmpsic -s 127.0.0.1 -d 127.0.0.1 -p 100000

find /proc/net/ | xargs cat > /dev/null

cat /proc/net/ip_mr_cache
cat /proc/net/ip_mr_vif
------------8<----------------


root@computer-desktop:~/testing# cat /proc/338/net/ip_mr_cache

[ 1572.702100] BUG: unable to handle kernel NULL pointer dereference at 000001c1
[ 1572.702588] IP: [<c05942c6>] ipmr_mfc_seq_show+0x26/0xf0
[ 1572.702906] *pde = 00000000 
[ 1572.703178] Oops: 0000 [#1] DEBUG_PAGEALLOC
[ 1572.703547] last sysfs file: /sys/block/md0/md/reshape_position
[ 1572.703812] Dumping ftrace buffer:
[ 1572.703959]    (ftrace buffer empty)
[ 1572.704038] Modules linked in: ip6table_filter ip6_tables af_packet nfsd auth_rpcgss exportfs nfs lockd nfs_acl sunrpc ipv6 fuse unix
[ 1572.704038] 
[ 1572.704038] Pid: 10475, comm: cat Not tainted (2.6.28-rc3 #59) 
[ 1572.704038] EIP: 0060:[<c05942c6>] EFLAGS: 00010202 CPU: 0
[ 1572.704038] EIP is at ipmr_mfc_seq_show+0x26/0xf0
[ 1572.704038] EAX: c9196128 EBX: c8b8ebb0 ECX: c06be34c EDX: 00000199
[ 1572.704038] ESI: c9196128 EDI: 00000199 EBP: c927ff0c ESP: c927fed8
[ 1572.704038]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 1572.704038] Process cat (pid: 10475, ti=c927f000 task=c915e710 task.ti=c927f000)
[ 1572.704038] Stack:
[ 1572.704038]  00000002 00000002 00000000 c0594421 00000000 c927ff00 c0594421 c8b8ebb0
[ 1572.704038]  00000199 c9196128 00000036 c9196128 00000199 c927ff48 c01c1554 00001000
[ 1572.704038]  086f2000 c4a55a30 c9196148 00000000 00000000 00000001 00000000 00000000
[ 1572.704038] Call Trace:
[ 1572.704038]  [<c0594421>] ? ipmr_mfc_seq_idx+0x21/0xc0
[ 1572.704038]  [<c0594421>] ? ipmr_mfc_seq_idx+0x21/0xc0
[ 1572.704038]  [<c01c1554>] ? seq_read+0x1e4/0x2e0
[ 1572.704038]  [<c01c1370>] ? seq_read+0x0/0x2e0
[ 1572.704038]  [<c01e6eb2>] ? proc_reg_read+0x62/0x90
[ 1572.704038]  [<c01a9031>] ? vfs_read+0xa1/0x160
[ 1572.704038]  [<c01e6e50>] ? proc_reg_read+0x0/0x90
[ 1572.704038]  [<c01a91c2>] ? sys_read+0x42/0x70
[ 1572.704038]  [<c01036c1>] ? sysenter_do_call+0x12/0x31
[ 1572.704038] Code: bf 00 00 00 00 55 89 e5 57 56 53 83 ec 28 e8 6a 01 b7 ff 89 55 ec 83 ea 01 89 45 f0 0f 84 be 00 00 00 8b 55 ec 8b 45 f0 8b 58 64 <8b> 42 28 89 44 24 1c 8b 42 20 89 44 24 18 8b 42 24 89 44 24 14 
[ 1572.704038] EIP: [<c05942c6>] ipmr_mfc_seq_show+0x26/0xf0 SS:ESP 0068:c927fed8
[ 1572.795742] ---[ end trace 2fef75e6cd09c1fb ]---

(gdb) l *(ipmr_mfc_seq_show+0x26)
0xc05942c6 is in ipmr_mfc_seq_show (net/ipv4/ipmr.c:1869).
1864			 "Group    Origin   Iif     Pkts    Bytes    Wrong Oifs\n");
1865		} else {
1866			const struct mfc_cache *mfc = v;
1867			const struct ipmr_mfc_iter *it = seq->private;
1868	
1869			seq_printf(seq, "%08lX %08lX %-3d %8ld %8ld %8ld",
1870				   (unsigned long) mfc->mfc_mcastgrp,
1871				   (unsigned long) mfc->mfc_origin,
1872				   mfc->mfc_parent,
1873				   mfc->mfc_un.res.pkt,



root@computer-desktop:~/testing# cat /proc/338/net/ip_mr_vif

[ 1572.811395] BUG: unable to handle kernel paging request at a903f90e
[ 1572.811850] IP: [<c02a47fe>] strnlen+0xe/0x20
[ 1572.812217] *pde = 00000000 
[ 1572.812472] Oops: 0000 [#2] DEBUG_PAGEALLOC
[ 1572.812819] last sysfs file: /sys/block/md0/md/reshape_position
[ 1572.813002] Modules linked in: ip6table_filter ip6_tables af_packet nfsd auth_rpcgss exportfs nfs lockd nfs_acl sunrpc ipv6 fuse unix
[ 1572.814874] 
[ 1572.815025] Pid: 10478, comm: cat Tainted: G      D    (2.6.28-rc3 #59) 
[ 1572.815275] EIP: 0060:[<c02a47fe>] EFLAGS: 00010297 CPU: 0
[ 1572.815460] EIP is at strnlen+0xe/0x20
[ 1572.815636] EAX: a903f90e EBX: c0812c0a ECX: a903f90e EDX: fffffffe
[ 1572.815824] ESI: c8a8e000 EDI: a903f90e EBP: c92ced70 ESP: c92ced70
[ 1572.816068]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 1572.816175] Process cat (pid: 10478, ti=c92ce000 task=ca96a710 task.ti=c92ce000)
[ 1572.816175] Stack:
[ 1572.816175]  c92ced8c c02a3598 c8a8dbb2 00000004 c0812c0a 0000000a c92ceee8 c92ceec0
[ 1572.816175]  c02a3ad4 0000000a ffffffff 00000010 00000002 ffffffff 00000000 c92ceee8
[ 1572.816175]  00000451 c8a8dbaf c018f0bd 0000000a c8a8dbb2 c8a8e000 ffffffff c010442a
[ 1572.816175] Call Trace:
[ 1572.816175]  [<c02a3598>] ? string+0x28/0xd0
[ 1572.816175]  [<c02a3ad4>] ? vsnprintf+0x494/0x8b0
[ 1572.816175]  [<c018f0bd>] ? __do_fault+0x1fd/0x3b0
[ 1572.816175]  [<c010442a>] ? ftrace_call+0x5/0x8
[ 1572.816175]  [<c011d072>] ? lookup_address+0x12/0x90
[ 1572.816175]  [<c011d4cb>] ? __change_page_attr_set_clr+0xab/0x570
[ 1572.816175]  [<c018f44c>] ? handle_mm_fault+0x1dc/0x610
[ 1572.816175]  [<c010442a>] ? ftrace_call+0x5/0x8
[ 1572.816175]  [<c018c05e>] ? page_address+0xe/0xe0
[ 1572.816175]  [<c010442a>] ? ftrace_call+0x5/0x8
[ 1572.816175]  [<c01c0f6f>] ? seq_printf+0x2f/0x60
[ 1572.816175]  [<c059427a>] ? ipmr_vif_seq_show+0x7a/0xa0
[ 1572.816175]  [<c01c1554>] ? seq_read+0x1e4/0x2e0
[ 1572.816175]  [<c01c1370>] ? seq_read+0x0/0x2e0
[ 1572.816175]  [<c01e6eb2>] ? proc_reg_read+0x62/0x90
[ 1572.816175]  [<c01a9031>] ? vfs_read+0xa1/0x160
[ 1572.816175]  [<c01e6e50>] ? proc_reg_read+0x0/0x90
[ 1572.816175]  [<c01a91c2>] ? sys_read+0x42/0x70
[ 1572.816175]  [<c01036c1>] ? sysenter_do_call+0x12/0x31
[ 1572.816175] Code: 57 e8 3f fc e5 ff 85 c9 89 c7 89 d0 74 05 f2 ae 75 01 4f 89 f8 5f 5d c3 90 8d 74 26 00 55 89 e5 e8 20 fc e5 ff 89 c1 89 c8 eb 06 <80> 38 00 74 07 40 4a 83 fa ff 75 f4 29 c8 5d c3 90 90 55 89 e5 
[ 1572.816175] EIP: [<c02a47fe>] strnlen+0xe/0x20 SS:ESP 0068:c92ced70
[ 1572.834407] ---[ end trace 2fef75e6cd09c1fb ]---


caused by the seq_printf() in "net/ipv4/ipmr.c" line 1737
ipmr_vif_seq_show()


Here are the oopses from the second box:

cat /proc/190/net/ip_mr_cache

[ 3221.884344] BUG: unable to handle kernel NULL pointer dereference at 000001b1
[ 3221.884695] IP: [<c06d2bf1>] ipmr_mfc_seq_show+0x2d/0xb2
[ 3221.884937] *pde = 00000000 
[ 3221.885205] Oops: 0000 [#22] PREEMPT DEBUG_PAGEALLOC
[ 3221.885605] last sysfs file: /sys/block/md0/md/reshape_position
[ 3221.885756] Modules linked in:
[ 3221.885946] 
[ 3221.886057] Pid: 19709, comm: cat Tainted: G      D    (2.6.28-rc3-00234-gfed4d59 #139) System Name
[ 3221.886057] EIP: 0060:[<c06d2bf1>] EFLAGS: 00010206 CPU: 0
[ 3221.886057] EIP is at ipmr_mfc_seq_show+0x2d/0xb2
[ 3221.886057] EAX: cb911160 EBX: ceff9f18 ECX: c08171c8 EDX: 00000189
[ 3221.886057] ESI: 00000189 EDI: 00000189 EBP: cb9fff10 ESP: cb9ffefc
[ 3221.886057]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 3221.886057] Process cat (pid: 19709, ti=cb9ff000 task=c90fc0b0 task.ti=cb9ff000)
[ 3221.886057] Stack:
[ 3221.886057]  cb911160 00000001 c08171c8 cb911160 00000189 cb9fff50 c01a3e41 00000400
[ 3221.886057]  08db8000 c9067100 cb911180 00000000 00000000 00000036 00000001 00000000
[ 3221.886057]  00000000 00000000 fffffffb cf06ab40 c01a3c5c cb9fff74 c01c3dab cb9fff9c
[ 3221.886057] Call Trace:
[ 3221.886057]  [<c01a3e41>] ? seq_read+0x1e5/0x2bd
[ 3221.886057]  [<c01a3c5c>] ? seq_read+0x0/0x2bd
[ 3221.886057]  [<c01c3dab>] ? proc_reg_read+0x65/0x79
[ 3221.886057]  [<c01c3d46>] ? proc_reg_read+0x0/0x79
[ 3221.886057]  [<c0190381>] ? vfs_read+0x8f/0x10b
[ 3221.886057]  [<c019069f>] ? sys_read+0x40/0x65
[ 3221.886057]  [<c0103a91>] ? sysenter_do_call+0x12/0x31
[ 3221.886057] Code: e5 57 56 53 83 ec 08 e8 26 1c a3 ff 83 fa 01 89 d6 89 45 ec 75 0f ba c9 bc 9c c0 e8 2a 09 ad ff e9 81 00 00 00 8b 45 ec 8b 58 6c <ff> 72 28 ff 72 20 ff 72 24 0f b7 42 0c 50 ff 72 08 ff 72 04 68 
[ 3221.886057] EIP: [<c06d2bf1>] ipmr_mfc_seq_show+0x2d/0xb2 SS:ESP 0068:cb9ffefc
[ 3221.897871] ---[ end trace e2e58d1efbfe6295 ]---


cat /proc/190/net/ip_mr_vif

[ 3158.523276] BUG: unable to handle kernel paging request at ffffffff
[ 3158.523467] IP: [<c04e4784>] strnlen+0xe/0x1e
[ 3158.523691] *pde = 0003a067 *pte = 00000000 
[ 3158.523852] Oops: 0000 [#21] PREEMPT DEBUG_PAGEALLOC
[ 3158.524016] last sysfs file: /sys/block/md0/md/reshape_position
[ 3158.524016] Modules linked in:
[ 3158.524016] 
[ 3158.524016] Pid: 19683, comm: cat Tainted: G      D    (2.6.28-rc3-00234-gfed4d59 #139) System Name
[ 3158.524016] EIP: 0060:[<c04e4784>] EFLAGS: 00010297 CPU: 0
[ 3158.524016] EIP is at strnlen+0xe/0x1e
[ 3158.524016] EAX: ffffffff EBX: cba6d45f ECX: ffffffff EDX: fffffffe
[ 3158.524016] ESI: ffffffff EDI: 0000000a EBP: c9052d84 ESP: c9052d84
[ 3158.524016]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 3158.524016] Process cat (pid: 19683, ti=c9052000 task=c90fc0b0 task.ti=c9052000)
[ 3158.524016] Stack:
[ 3158.524016]  c9052d9c c04e39dc cba6e0f0 c9052ef0 cba6d45f c9052ef0 c9052ec0 c04e3d2f
[ 3158.524016]  0000000a ffffffff 00000010 00000c94 cba6d45c 0000000a cba6e0f0 00000010
[ 3158.524016]  0000000a ffffffff cba52a94 c09cbca2 c9052de4 c079bf87 cba52a94 00000001
[ 3158.524016] Call Trace:
[ 3158.524016]  [<c04e39dc>] ? string+0x2b/0x74
[ 3158.524016]  [<c04e3d2f>] ? vsnprintf+0x30a/0x5b9
[ 3158.524016]  [<c079bf87>] ? _spin_unlock_irqrestore+0x47/0x5d
[ 3158.524016]  [<c0120424>] ? __wake_up+0x31/0x3b
[ 3158.524016]  [<c0533511>] ? n_tty_receive_buf+0xf8c/0xfc5
[ 3158.524016]  [<c013f513>] ? clockevents_program_event+0xd9/0xe8
[ 3158.524016]  [<c014034f>] ? tick_dev_program_event+0x2d/0x9a
[ 3158.524016]  [<c01a3816>] ? seq_printf+0x30/0x50
[ 3158.524016]  [<c06d2bba>] ? ipmr_vif_seq_show+0x5d/0x67
[ 3158.524016]  [<c01a3e41>] ? seq_read+0x1e5/0x2bd
[ 3158.524016]  [<c01a3c5c>] ? seq_read+0x0/0x2bd
[ 3158.524016]  [<c01c3dab>] ? proc_reg_read+0x65/0x79
[ 3158.524016]  [<c01c3d46>] ? proc_reg_read+0x0/0x79
[ 3158.524016]  [<c0190381>] ? vfs_read+0x8f/0x10b
[ 3158.524016]  [<c019069f>] ? sys_read+0x40/0x65
[ 3158.524016]  [<c0103a91>] ? sysenter_do_call+0x12/0x31
[ 3158.524016] Code: 5d c3 55 89 e5 57 e8 94 00 c2 ff 85 c9 89 c7 89 d0 74 05 f2 ae 75 01 4f 89 f8 5f 5d c3 55 89 e5 e8 7a 00 c2 ff 89 c1 89 c8 eb 06 <80> 38 00 74 07 40 4a 83 fa ff 75 f4 29 c8 5d c3 55 89 e5 57 56 
[ 3158.524016] EIP: [<c04e4784>] strnlen+0xe/0x1e SS:ESP 0068:c9052d84
[ 3158.524016] ---[ end trace e2e58d1efbfe6295 ]---
[ 3158.524016] note: cat[19683] exited with preempt_count 1
[ 3158.534211] BUG: scheduling while atomic: cat/19683/0x10000002
[ 3158.534359] INFO: lockdep is turned off.
[ 3158.534508] Modules linked in:
[ 3158.534716] Pid: 19683, comm: cat Tainted: G      D    2.6.28-rc3-00234-gfed4d59 #139
[ 3158.534908] Call Trace:
[ 3158.535077]  [<c0123b7b>] __schedule_bug+0x5d/0x64
[ 3158.535222]  [<c07997ab>] schedule+0x6b/0x45c
[ 3158.535392]  [<c0170f5f>] ? free_hot_cold_page+0x1d9/0x20a
[ 3158.535541]  [<c0123ba3>] __cond_resched+0x21/0x3a
[ 3158.535699]  [<c0799cd1>] _cond_resched+0x24/0x2f
[ 3158.535851]  [<c01798e9>] unmap_vmas+0x385/0x44f
[ 3158.536037]  [<c01441bc>] ? trace_hardirqs_on_caller+0x17/0x12e
[ 3158.536194]  [<c017c9b7>] exit_mmap+0x83/0x104
[ 3158.536357]  [<c0125112>] mmput+0x39/0x89
[ 3158.536498]  [<c01284c7>] exit_mm+0xc3/0xcb
[ 3158.536656]  [<c01296f4>] do_exit+0x1b2/0x6fc
[ 3158.536798]  [<c0127cc4>] ? printk+0x1a/0x1c
[ 3158.536959]  [<c0126e78>] ? print_oops_end_marker+0x23/0x28
[ 3158.537165]  [<c079cb4d>] oops_end+0x82/0x8a
[ 3158.537311]  [<c0105a69>] die+0x5c/0x64
[ 3158.537470]  [<c079deb6>] do_page_fault+0x532/0x5fb
[ 3158.537615]  [<c079d984>] ? do_page_fault+0x0/0x5fb
[ 3158.537777]  [<c079d984>] ? do_page_fault+0x0/0x5fb
[ 3158.537922]  [<c079c27f>] error_code+0x6f/0x74
[ 3158.538103]  [<c04e4784>] ? strnlen+0xe/0x1e
[ 3158.538246]  [<c04e39dc>] string+0x2b/0x74
[ 3158.538404]  [<c04e3d2f>] vsnprintf+0x30a/0x5b9
[ 3158.538551]  [<c079bf87>] ? _spin_unlock_irqrestore+0x47/0x5d
[ 3158.538718]  [<c0120424>] ? __wake_up+0x31/0x3b
[ 3158.538861]  [<c0533511>] ? n_tty_receive_buf+0xf8c/0xfc5
[ 3158.539048]  [<c013f513>] ? clockevents_program_event+0xd9/0xe8
[ 3158.539201]  [<c014034f>] ? tick_dev_program_event+0x2d/0x9a
[ 3158.539375]  [<c01a3816>] seq_printf+0x30/0x50
[ 3158.539518]  [<c06d2bba>] ipmr_vif_seq_show+0x5d/0x67
[ 3158.539681]  [<c01a3e41>] seq_read+0x1e5/0x2bd
[ 3158.539825]  [<c01a3c5c>] ? seq_read+0x0/0x2bd
[ 3158.539983]  [<c01c3dab>] proc_reg_read+0x65/0x79
[ 3158.540164]  [<c01c3d46>] ? proc_reg_read+0x0/0x79
[ 3158.540308]  [<c0190381>] vfs_read+0x8f/0x10b
[ 3158.540467]  [<c019069f>] sys_read+0x40/0x65
[ 3158.540607]  [<c0103a91>] sysenter_do_call+0x12/0x31


Greetings, Eric
