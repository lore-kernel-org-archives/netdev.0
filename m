From: Brian Bloniarz <bmb@athenacr.com>
Subject: Re: Multicast packet loss
Date: Mon, 06 Apr 2009 17:53:51 -0400
Message-ID: <49DA79EF.5010509@athenacr.com>
References: <49B4B909.7050002@cosmosbay.com>	<20090313.145152.121603300.davem@davemloft.net>	<49BADE87.40407@cosmosbay.com> <20090313.153851.11725991.davem@davemloft.net> <49BED109.3020504@cosmosbay.com> <49D66379.7070106@athenacr.com> <49D8B6DA.7050902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sprinkles.athenacr.com ([64.95.46.210]:1052 "EHLO
	sprinkles.inp.in.athenacr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759215AbZDFVx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 17:53:57 -0400
In-Reply-To: <49D8B6DA.7050902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Pointer being null might tell us that we managed to call inet_def_readable()
> without socket lock hold...

Trying to track this down: I added:
	BUG_ON(!spin_is_locked(&sk->sk_lock.slock));
to the top of inet_def_readable. This gives me the following panic:

[ 2528.745311] kernel BUG at net/core/sock.c:1674!
[ 2528.745311] invalid opcode: 0000 [#1] PREEMPT SMP
[ 2528.745311] last sysfs file: /sys/devices/system/cpu/cpu7/crash_notes
[ 2528.745311] CPU 6
[ 2528.745311] Modules linked in: iptable_filter ip_tables x_tables parport_pc lp parport loop iTCO_wdt iTCO_vendor_support serio_raw psmouse pcspkr i5k_amb shpchp i5000_edac pci_hotplug button edac_core ipv6 ibmpex joydev ipmi_msghandler evdev ext3 jbd mbcache usbhid hid sr_mod cdrom pata_acpi ata_generic sg sd_mod ata_piix ehci_hcd uhci_hcd libata aacraid usbcore scsi_mod bnx2 thermal processor fan thermal_sys fuse
[ 2528.745311] Pid: 14507, comm: signalgen Not tainted 2.6.29.1-eric2-lowlat-lockdep #3 IBM System x3550 -[7978AC1]-
[ 2528.745311] RIP: 0010:[<ffffffff80444ec2>]  [<ffffffff80444ec2>] inet_def_readable+0x52/0x60
[ 2528.745311] RSP: 0018:ffff88043b985b58  EFLAGS: 00010246
[ 2528.745311] RAX: 0000000000000019 RBX: ffff88043b90c280 RCX: 0000000000000000
[ 2528.745311] RDX: 0000000000001919 RSI: 0000000000000068 RDI: ffff88043b90c280
[ 2528.745311] RBP: ffff88043b985b68 R08: 0000000000000000 R09: 0000000000000000
[ 2528.745311] R10: 0000000000000000 R11: 0000000000000000 R12: ffff88043b811400
[ 2528.745311] R13: 0000000000000000 R14: 0000000000000068 R15: 0000000000000000
[ 2528.745311] FS:  00007f82f0742750(0000) GS:ffff88043dbc8280(0000) knlGS:0000000000000000
[ 2528.745311] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 2528.745311] CR2: 000000000057f1a0 CR3: 000000043915e000 CR4: 00000000000406e0
[ 2528.745311] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 2528.745311] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 2528.745311] Process signalgen (pid: 14507, threadinfo ffff88043b984000, task ffff8804309a9ef0)
[ 2528.745311] Stack:
[ 2528.745311]  ffff88043b811400 ffff88043b90c280 ffff88043b985b98 ffffffff80444ff6
[ 2528.745311]  ffff88043b90c280 ffff88043b811400 0000000000000000 ffff88043b90c2c0
[ 2528.745311]  ffff88043b985bc8 ffffffff8049ee67 ffff88043b985bc8 ffff88043b811400
[ 2528.745311] Call Trace:
[ 2528.745311]  [<ffffffff80444ff6>] sock_queue_rcv_skb+0xd6/0x120
[ 2528.745311]  [<ffffffff8049ee67>] __udp_queue_rcv_skb+0x27/0xe0
[ 2528.745311]  [<ffffffff8044406a>] release_sock+0x7a/0xe0
[ 2528.745311]  [<ffffffff804a1d0d>] udp_recvmsg+0x1ed/0x330
[ 2528.745311]  [<ffffffff804437e2>] sock_common_recvmsg+0x32/0x50
[ 2528.745311]  [<ffffffff80441449>] sock_recvmsg+0x139/0x150
[ 2528.745311]  [<ffffffff8025a590>] ? autoremove_wake_function+0x0/0x40
[ 2528.745311]  [<ffffffff8026c4d9>] ? validate_chain+0x469/0x1270
[ 2528.745311]  [<ffffffff8026d60e>] ? __lock_acquire+0x32e/0xa40
[ 2528.745311]  [<ffffffff804429df>] sys_recvfrom+0xaf/0x110
[ 2528.745311]  [<ffffffff804e6109>] ? mutex_unlock+0x9/0x10
[ 2528.745311]  [<ffffffff80310041>] ? sys_epoll_wait+0x4a1/0x510
[ 2528.745311]  [<ffffffff8020c55b>] system_call_fastpath+0x16/0x1b
[ 2528.745311] Code: 85 c0 7e 1b 48 8d bf 98 02 00 00 e8 29 34 e0 ff 85 c0 74 04 f0 ff 43 28 48 83 c4 08 5b c9 c3 e8 15 f3 ff ff 48 83 c4 08 5b c9 c3 <0f> 0b eb fe 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 e5 48 83 ec
[ 2528.745311] RIP  [<ffffffff80444ec2>] inet_def_readable+0x52/0x60
[ 2528.745311]  RSP <ffff88043b985b58>

Looks to me like __release_sock will call sk_backlog_rcv() with
the socket unlocked -- does that help at all?

Thanks,
Brian Bloniarz
