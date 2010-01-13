From: Valdis.Kletnieks@vt.edu
Subject: 2.6.33-rc3-mmotm0106 BUG during modprobe at system shutdown
Date: Wed, 13 Jan 2010 01:35:38 -0500
Message-ID: <30706.1263364538@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1263364538_4458P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:33653 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752085Ab0AMGfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 01:35:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1263364538_4458P
Content-Type: text/plain; charset=us-ascii

Not sure why it was trying to modprobe on the way down during a 'shutdown -r'.
My guess is that it had turned off IPv6 on the network interfaces, then something
referenced an IPv6 address, and it tried to do a 6in4 tunnel as a last-ditch
effort to save the day.  I think I've triggered this before, but this was
the first one I've had a saved syslog capturing it.

Dunno if it's a network ipv6/sit issue or a sysfs issue, so we'll throw
it at the wall and see what sticks...

[14730.616738] IPv6 over IPv4 tunneling driver
[14730.616843] BUG: unable to handle kernel paging request at 0000000030746973
[14730.616885] IP: [<ffffffff810be964>] kstrdup+0x17/0x40
[14730.616920] PGD 1078ed067 PUD 11eb40067 PMD 0 
[14730.616954] Oops: 0000 [#1] PREEMPT SMP 
[14730.616986] last sysfs file: /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/graphics/fb0/modes
[14730.617029] CPU 1 
[14730.617048] Pid: 30404, comm: modprobe Not tainted 2.6.33-rc3-mmotm0106 #6 0X564R/Latitude E6500                  
[14730.617097] RIP: 0010:[<ffffffff810be964>]  [<ffffffff810be964>] kstrdup+0x17/0x40
[14730.617139] RSP: 0018:ffff8801079abb78  EFLAGS: 00010286
[14730.617166] RAX: 0000000000000000 RBX: 0000000030746973 RCX: ffffffffffffffff
[14730.617201] RDX: 0000000000000001 RSI: 00000000000000d0 RDI: 0000000030746973
[14730.617243] RBP: ffff8801079abb98 R08: 00000000ffffffea R09: ffff8800b83d9500
[14730.617256] R10: ffff8801079abb88 R11: 00000000000062c1 R12: 0000000030746973
[14730.617256] R13: 0000000000000001 R14: 00000000000041ed R15: 0000000000000000
[14730.617256] FS:  00007f3de5419700(0000) GS:ffff880028300000(0000) knlGS:0000000000000000
[14730.617256] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[14730.617256] CR2: 0000000030746973 CR3: 000000011d87e000 CR4: 00000000000406e0
[14730.617256] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[14730.617256] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[14730.617256] Process modprobe (pid: 30404, threadinfo ffff8801079aa000, task ffff88010f642940)
[14730.617256] Stack:
[14730.617256]  ffff8801079abb98 ffffffff81576360 0000000000000000 0000000000000000
[14730.617256] <0> ffff8801079abbf8 ffffffff8113619a ffffffff8113616a ffff8801079abc54
[14730.617256] <0> ffff8801079abbd8 ffffffff8102eafe ffff88011fc3e2b0 ffff88011c1e0130
[14730.617256] Call Trace:
[14730.617256]  [<ffffffff81576360>] ? sub_preempt_count+0x35/0x48
[14730.617256]  [<ffffffff8113619a>] sysfs_new_dirent+0x2e/0x118
[14730.617256]  [<ffffffff8113616a>] ? sysfs_addrm_start+0x21/0x23
[14730.617256]  [<ffffffff8102eafe>] ? get_parent_ip+0x11/0x42
[14730.617256]  [<ffffffff81136654>] create_dir+0x32/0x88
[14730.617256]  [<ffffffff81136728>] sysfs_create_subdir+0x16/0x18
[14730.617256]  [<ffffffff811378c8>] internal_create_group+0x9b/0x1d7
[14730.617256]  [<ffffffff8113651d>] ? sysfs_addrm_finish+0x16/0x50
[14730.617256]  [<ffffffff811356a2>] ? sysfs_add_file_mode+0x5f/0x7a
[14730.617256]  [<ffffffff81137a25>] sysfs_create_group+0xe/0x11
[14730.617256]  [<ffffffff812ecbdd>] device_add_groups+0x25/0x64
[14730.617256]  [<ffffffff812ed2fb>] device_add+0x2b3/0x4e1
[14730.617256]  [<ffffffff8145369b>] netdev_register_kobject+0x6e/0x77
[14730.617256]  [<ffffffff81448ee3>] register_netdevice+0x2a4/0x40c
[14730.617256]  [<ffffffff81449085>] register_netdev+0x3a/0x4c
[14730.617256]  [<ffffffffa00002d1>] sit_init_net+0xdf/0x10e [sit]
[14730.617256]  [<ffffffff81442726>] ops_init.clone.2+0x6d/0x75
[14730.617256]  [<ffffffff8144277a>] register_pernet_operations+0x4c/0x8b
[14730.617256]  [<ffffffff81571896>] ? mutex_lock_nested+0x34/0x39
[14730.617256]  [<ffffffff814427e2>] register_pernet_device+0x29/0x5a
[14730.617256]  [<ffffffffa0005000>] ? sit_init+0x0/0x6b [sit]
[14730.617256]  [<ffffffffa0005000>] ? sit_init+0x0/0x6b [sit]
[14730.617256]  [<ffffffffa000504d>] sit_init+0x4d/0x6b [sit]
[14730.617256]  [<ffffffffa0005000>] ? sit_init+0x0/0x6b [sit]
[14730.617256]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
[14730.617256]  [<ffffffff8107463d>] sys_init_module+0xd8/0x239
[14730.617256]  [<ffffffff810023ab>] system_call_fastpath+0x16/0x1b
[14730.617256] Code: 89 de 4c 89 e1 f3 a4 42 c6 04 20 00 5a 5b 41 5c 41 5d c9 c3 55 31 c0 48 89 e5 53 48 89 fb 48 83 ec 18 48 85 ff 74 26 48 83 c9 ff <f2> ae 48 f7 d1 48 89 cf 48 89 4d e8 e8 3f 94 01 00 48 8b 4d e8 
[14730.617256] RIP  [<ffffffff810be964>] kstrdup+0x17/0x40
[14730.617256]  RSP <ffff8801079abb78>
[14730.617256] CR2: 0000000030746973
[14730.619645] ---[ end trace 97a6b28ceef52096 ]---


--==_Exmh_1263364538_4458P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLTWm6cC3lWbTT17ARApvNAJsHDM/8TuwzdeS1fIFNX2dr9byf3wCghWYa
bfWNhJtwKd5ZXoG20j3r6J8=
=ZPLr
-----END PGP SIGNATURE-----

--==_Exmh_1263364538_4458P--

