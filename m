From: Valdis.Kletnieks@vt.edu
Subject: Re: [next] unix stream crashes
Date: Sat, 03 Sep 2011 01:35:15 -0400
Message-ID: <6043.1315028115@turing-police.cc.vt.edu>
References: <4E5FEF28.60406@gmail.com> <3179.1314924559@turing-police.cc.vt.edu> <1314927645.2576.2939.camel@schen9-DESK> <6805.1314979936@turing-police.cc.vt.edu>
            <1315007703.2576.2965.camel@schen9-DESK>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1315028115_5293P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jirislaby@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	ML netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Sedat Dilek <sedat.dilek@googlemail.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>
To: Tim Chen <tim.c.chen@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:37981 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab1ICFhC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2011 01:37:02 -0400
In-Reply-To: Your message of "Fri, 02 Sep 2011 16:55:03 PDT."
             <1315007703.2576.2965.camel@schen9-DESK>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1315028115_5293P
Content-Type: text/plain; charset=us-ascii

On Fri, 02 Sep 2011 16:55:03 PDT, Tim Chen said:

> I'll like to isolate the problem to either the send path or receive
> path. My suspicion is the error handling portion of the send path is not
> quite right but I haven't yet found any issues after reviewing the
> patch.  

Took a while, because it took a few tries to get netconsole working,
and then I was seeing odd results, but here we go:

next-20110831 - crashes 100% consistent.
next-20110831 + revert 0856a30409 - OK.
revert + scm_recv.patch - OK.
revert + scm_send.patch - crashes 100% consistent.

Now the odd part - although I was seeing crashes 100% of the time, I saw a
number of different tracebacks (but I never actually saw the same traceback
that Jiri had). Also, the system died at different points - most of the time it
would live long enough for GDM to prompt for a userid/password and then die,
but sometimes it didn't get as far as the GDM screen. Hopefully the variety of
crashes will tell you something useful.

I'll be able to test patches for go/nogo over the weekend, but probably won't
have a second machine to catch netconsole until I'm back in the office Monday.

Example 1:

[  142.316258] Kernel panic - not syncing: CRED: put_cred_rcu() sees ffff88010d1ff300 with usage -41
[  142.316260] 
[  142.316275] Pid: 2264, comm: gdm-simple-slav Tainted: G        W   3.1.0-rc4-next-20110831-dirty #17
[  142.316279] Call Trace:
[  142.316283]  <IRQ>  [<ffffffff81577a6c>] panic+0x96/0x1a2
[  142.316300]  [<ffffffff8105cb54>] put_cred_rcu+0x32/0x91
[  142.316306]  [<ffffffff8157a44f>] rcu_do_batch+0xcb/0x1e4
[  142.316313]  [<ffffffff81092967>] invoke_rcu_callbacks+0x6c/0xc7
[  142.316319]  [<ffffffff810932f8>] __rcu_process_callbacks+0x118/0x124
[  142.316325]  [<ffffffff810934f0>] rcu_process_callbacks+0x64/0x72
[  142.316331]  [<ffffffff8103f8c4>] __do_softirq+0x110/0x278
[  142.316338]  [<ffffffff815a23ac>] call_softirq+0x1c/0x30
[  142.316342]  <EOI>  [<ffffffff81003647>] do_softirq+0x44/0xf1
[  142.316352]  [<ffffffff8103f485>] _local_bh_enable_ip+0x12a/0x178
[  142.316358]  [<ffffffff8103f4dc>] local_bh_enable_ip+0x9/0xb
[  142.316364]  [<ffffffff8159a2f3>] _raw_write_unlock_bh+0x36/0x3a
[  142.316372]  [<ffffffff814c1ac3>] unix_release_sock+0x86/0x1ff
[  142.316378]  [<ffffffff8105b548>] ? up_read+0x1b/0x32
[  142.316383]  [<ffffffff814c1c5d>] unix_release+0x21/0x23
[  142.316390]  [<ffffffff81423d02>] sock_release+0x1a/0x6f
[  142.316395]  [<ffffffff81424a30>] sock_close+0x22/0x26
[  142.316401]  [<ffffffff810fcacb>] __fput+0x140/0x1fe
[  142.316407]  [<ffffffff810f97cb>] ? sys_close+0xe6/0x158
[  142.316412]  [<ffffffff810fcb9e>] fput+0x15/0x17
[  142.316417]  [<ffffffff810f8ef2>] filp_close+0x87/0x93
[  142.316422]  [<ffffffff810f97d6>] sys_close+0xf1/0x158
[  142.316429]  [<ffffffff815a0ffb>] system_call_fastpath+0x16/0x1b

Example 2:  another RCU botch, but different traceback - probably the most common
variant I hit, at least 5-6 times.

[  224.109024] Kernel panic - not syncing: CRED: put_cred_rcu() sees ffff880114888e00 with usage -27
[  224.109026] 
[  224.109041] Pid: 10, comm: ksoftirqd/1 Tainted: G        W   3.1.0-rc4-next-20110831-00001-gf3a20c5-dirty #18
[  224.109045] Call Trace:
[  224.109055]  [<ffffffff81577aac>] panic+0x96/0x1a2
[  224.109063]  [<ffffffff8105cb54>] put_cred_rcu+0x32/0x91
[  224.109069]  [<ffffffff8157a48f>] rcu_do_batch+0xcb/0x1e4
[  224.109075]  [<ffffffff81092967>] invoke_rcu_callbacks+0x6c/0xc7
[  224.109081]  [<ffffffff810932f8>] __rcu_process_callbacks+0x118/0x124
[  224.109087]  [<ffffffff810934f0>] rcu_process_callbacks+0x64/0x72
[  224.109093]  [<ffffffff8103f8c4>] __do_softirq+0x110/0x278
[  224.109098]  [<ffffffff8103faeb>] ? run_ksoftirqd+0xbf/0x20e
[  224.109103]  [<ffffffff8103fafc>] run_ksoftirqd+0xd0/0x20e
[  224.109109]  [<ffffffff8103fa2c>] ? __do_softirq+0x278/0x278
[  224.109115]  [<ffffffff810570d6>] kthread+0x7f/0x87
[  224.109122]  [<ffffffff815a22f4>] kernel_thread_helper+0x4/0x10
[  224.109129]  [<ffffffff8159aea1>] ? retint_restore_args+0xe/0xe
[  224.109135]  [<ffffffff81057057>] ? __init_kthread_worker+0x55/0x55
[  224.109141]  [<ffffffff815a22f0>] ? gs_change+0xb/0xb


Example 3:

[   83.816051] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[   83.816069] IP: [<ffffffff8123c1fc>] __list_del_entry+0x144/0x1ab
[   83.816081] PGD 116ba3067 PUD 114ae9067 PMD 0 
[   83.816093] Oops: 0000 [#1] PREEMPT SMP 

[   83.816129] Pid: 1, comm: systemd Tainted: G        W   3.1.0-rc4-next-20110831-dirty #17 Dell Inc. Latitude E6500                /      
[   83.816141] RIP: 0010:[<ffffffff8123c1fc>]  [<ffffffff8123c1fc>] __list_del_entry+0x144/0x1ab
[   83.816150] RSP: 0018:ffff88011f095e58  EFLAGS: 00010246
[   83.816154] RAX: ffff88011fa0edc0 RBX: ffff8800d278c5c0 RCX: 0000000000000061
[   83.816157] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffff81ae1640
[   83.816161] RBP: ffff88011f095e88 R08: dead000000200200 R09: 0000000000000000
[   83.816166] R10: ffff8800d278c5d0 R11: ffff8800d278c5c0 R12: 0000000000000000
[   83.816170] R13: 0000000000000000 R14: ffff88011fa19bc0 R15: ffff8801131c9358
[   83.816174] FS:  00007fe3ca2077e0(0000) GS:ffff88011fa00000(0000) knlGS:0000000000000000
[   83.816179] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   83.816183] CR2: 0000000000000008 CR3: 0000000116a3a000 CR4: 00000000000406f0
[   83.816187] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   83.816191] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   83.816196] Process systemd (pid: 1, threadinfo ffff88011f094000, task ffff88011f092040)
[   83.816200] Stack:
[   83.816203]  ffff88011f095e88 dead000000200200 ffff8800d278c5c0 0000000000000000
[   83.816218]  ffff8801131ce4a0 ffff8801131ce4a0 ffff88011f095ea8 ffffffff810fc94a
[   83.816233]  ffffffff8160c400 ffff8800d278c5c0 ffff88011f095ef8 ffffffff810fcb43
[   83.816247] Call Trace:
[   83.816255]  [<ffffffff810fc94a>] file_sb_list_del+0x1e/0x31
[   83.816261]  [<ffffffff810fcb43>] __fput+0x1b8/0x1fe
[   83.816267]  [<ffffffff810f97cb>] ? sys_close+0xe6/0x158
[   83.816272]  [<ffffffff810fcb9e>] fput+0x15/0x17
[   83.816277]  [<ffffffff810f8ef2>] filp_close+0x87/0x93
[   83.816283]  [<ffffffff810f97d6>] sys_close+0xf1/0x158
[   83.816289]  [<ffffffff815a0ffb>] system_call_fastpath+0x16/0x1b
[   83.816294] Code: 35 00 00 00 48 c7 c7 a1 69 8b 81 31 c0 e8 0a d5 df ff 31 d2 44 89 e6 48 c7 c7 40 16 ae 81 e8 5c 6f e6 ff 45 85 e4 75 5f 45 31 e4 
[   83.816402]  39 5d 08 48 c7 c7 68 16 ae 81 41 0f 95 c4 31 d2 44 89 e6 e8 
[   83.816457] RIP  [<ffffffff8123c1fc>] __list_del_entry+0x144/0x1ab
[   83.816464]  RSP <ffff88011f095e58>
[   83.816469] CR2: 0000000000000008
[   83.816481] ---[ end trace 86b3a584f3090560 ]---

(after which we hit a bunch of "scheduling while atomic" before the other processor grinds
to a halt:

Example 4:

[  171.035508] dell_wmi: Received unknown WMI event (0x11)
[  171.345340] general protection fault: 0000 [#1] PREEMPT SMP 
[  171.346608] CPU 1 
[  171.346608] Pid: 2501, comm: polkit-gnome-au Tainted: G        W   3.1.0-rc4-next-20110831-dirty #17 Dell Inc. Latitude E6500                  /      
[  171.346608] RIP: 0010:[<ffffffff81054203>]  [<ffffffff81054203>] free_pid+0x32/0x93
[  171.346608] RSP: 0018:ffff8800d2d65c68  EFLAGS: 00010046
[  171.346608] RAX: 0000000000000096 RBX: ffff8801156db740 RCX: ffff8801156db780
[  171.346608] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
[  171.346608] RBP: ffff8800d2d65c78 R08: dead000000200200 R09: 0000000000000001
[  171.346608] R10: 0000000000000000 R11: ffff880037bf86a0 R12: ffff8801145be3c0
[  171.346608] R13: 0000000000000000 R14: ffff880116804580 R15: ffff880116804d88
[  171.346608] FS:  00007f11f74f7700(0000) GS:ffff88011fb00000(0000) knlGS:0000000000000000
[  171.346608] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  171.346608] CR2: 0000000001eb7ee0 CR3: 0000000001a23000 CR4: 00000000000406e0
[  171.346608] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  171.346608] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  171.346608] Process polkit-gnome-au (pid: 2501, threadinfo ffff8800d2d64000, task ffff8800d2d627c0)
[  171.346608] Stack:
[  171.346608]  ffff8800d2d627c0 ffff8801145be3c0 ffff8800d2d65c88 ffffffff810542b9
[  171.346608]  ffff8800d2d65c98 ffffffff81054442 ffff8800d2d65ce8 ffffffff8157801f
[  171.346608]  ffffffff00000000 0000000000000000 ffff8800d2d65ce8 ffff8800d2d627c0
[  171.346608] Call Trace:
[  171.346608]  [<ffffffff810542b9>] __change_pid+0x55/0x57
[  171.346608]  [<ffffffff81054442>] detach_pid+0xb/0xd
[  171.346608]  [<ffffffff8157801f>] __exit_signal+0x1e4/0x2d4
[  171.346608]  [<ffffffff8103bdcc>] release_task+0xf1/0x186
[  171.346608]  [<ffffffff81578418>] exit_notify+0x171/0x17a
[  171.346608]  [<ffffffff8103d16b>] do_exit+0x458/0x4f5
[  171.346608]  [<ffffffff810a299b>] ? trace_preempt_on+0x15/0x28
[  171.346608]  [<ffffffff8103d3dd>] do_group_exit+0x9e/0xcb
[  171.346608]  [<ffffffff8104bc3a>] get_signal_to_deliver+0x469/0x4aa
[  171.346608]  [<ffffffff81001c6d>] do_signal+0x31/0xe9
[  171.346608]  [<ffffffff81067ca2>] ? lockdep_init_map.part.9+0x47/0xb2
[  171.346608]  [<ffffffff810f9908>] ? fd_install+0xcb/0xd8
[  171.346608]  [<ffffffff810a299b>] ? trace_preempt_on+0x15/0x28
[  171.346608]  [<ffffffff810f9908>] ? fd_install+0xcb/0xd8
[  171.346608]  [<ffffffff8159a75c>] ? _raw_spin_unlock+0x2d/0x66
[  171.346608]  [<ffffffff8159db56>] ? sub_preempt_count+0x33/0x46
[  171.346608]  [<ffffffff810a2943>] ? time_hardirqs_on+0x1b/0x2f
[  171.346608]  [<ffffffff815a1081>] ? sysret_signal+0x5/0x47
[  171.346608]  [<ffffffff81001e8d>] do_notify_resume+0x27/0x5c
[  171.346608]  [<ffffffff8123607e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  171.346608]  [<ffffffff815a1318>] int_signal+0x12/0x17
[  171.346608] Code: 48 89 fb 48 c7 c7 40 41 a0 81 e8 7f 60 54 00 31 d2 eb 31 48 63 ca 48 83 c1 02 48 c1 e1 05 48 01 d9 48 8b 39 4c 8b 41 08 48 85 ff 
[  171.346608]  89 38 74 04 4c 89 47 08 49 bb 00 02 20 00 00 00 ad de ff c2 
[  171.346608] RIP  [<ffffffff81054203>] free_pid+0x32/0x93
[  171.346608]  RSP <ffff8800d2d65c68>
[  171.346608] ---[ end trace 403d5ef3a1ab950e ]---
[  171.346608] Fixing recursive fault but reboot is needed!

and then the other CPU catches a hard lockup error.


--==_Exmh_1315028115_5293P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFOYbyTcC3lWbTT17ARApZ9AJsF1gckByX0ZJY1lf1w+316PAPoXACdEy+y
E7vYwKf0arCYpTWObmHgLsY=
=U9lh
-----END PGP SIGNATURE-----

--==_Exmh_1315028115_5293P--
