From: Simon Kirby <sim@hostway.ca>
Subject: 3.3.0, 3.4-rc1 reproducible tun Oops
Date: Wed, 4 Apr 2012 15:05:25 -0700
Message-ID: <20120404220525.GD21505@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from peace.netnation.com ([204.174.223.2]:45171 "EHLO
	peace.netnation.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752852Ab2DDWFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 18:05:25 -0400
Received: from sim by peace.netnation.com with local (Exim 4.72)
	(envelope-from <sim@netnation.com>)
	id 1SFYKT-0006jK-C1
	for netdev@vger.kernel.org; Wed, 04 Apr 2012 15:05:25 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I use an SSH VPN occasionally from home, and since upgrading the remote
kernel to 3.3.0, the it now seems to Oops when I ^C the tunnel with
sockets still active. If I start the tunnel, log in to a box through it
and run "vmstat 1", ^C the tunnel SSH process, and start it up again, I
get an Oops like this:

BUG: unable to handle kernel NULL pointer dereference at 00000000000000ff
IP: [<ffffffff810ed5fa>] __kmalloc_track_caller+0xaa/0x1b0
PGD 12d2bc067 PUD 0
Oops: 0000 [#1] SMP
CPU 1
Modules linked in: nf_conntrack_netlink nfnetlink iptable_mangle ipt_MASQUERADE xt_state xt_conntrack iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack hwmon_vid ppp_async ppp_generic slhc crc_ccitt tun nvidia(PO) uvcvideo videobuf2_vmalloc videobuf2_memops videobuf2_core e100

Pid: 16156, comm: sshd Tainted: P           O 3.3.0 #32 System manufacturer System Product Name/A8N-VM CSM
RIP: 0010:[<ffffffff810ed5fa>]  [<ffffffff810ed5fa>] __kmalloc_track_caller+0xaa/0x1b0
RSP: 0000:ffff88012d0b3b58  EFLAGS: 00210206
RAX: 0000000000000000 RBX: ffff8801783f8e00 RCX: 000000000002c11f
RDX: 000000000002c11e RSI: 00000000000000d0 RDI: 0000000000014ac0
RBP: ffff88012d0b3ba8 R08: ffffffff81693c81 R09: ffff88007f546f30
R10: 00000000f80057e0 R11: 0000000000000000 R12: 00000000000000ff
R13: ffff88017b002900 R14: 0000000000000800 R15: 0000000000000800
FS:  0000000000000000(0000) GS:ffff88017fd00000(0063) knlGS:00000000f71ea740
CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
CR2: 00000000000000ff CR3: 000000011906a000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process sshd (pid: 16156, threadinfo ffff88012d0b2000, task ffff880100a43a00)
Stack:
 dead000000200200 ffff88007fabc0c0 ffffffff816d692c 000000d0000000db
 ffff880100000000 ffff8801783f8e00 0000000000000001 00000000000000d0
 ffff88017b002780 0000000000000800 ffff88012d0b3be8 ffffffff81693cae
Call Trace:
 [<ffffffff816d692c>] ? sk_stream_alloc_skb+0x3c/0x110
 [<ffffffff81693cae>] __alloc_skb+0x6e/0x220
 [<ffffffff816d692c>] sk_stream_alloc_skb+0x3c/0x110
 [<ffffffff816d6c90>] tcp_sendmsg+0x290/0xd90
 [<ffffffff81694537>] ? skb_release_data+0xe7/0xf0
 [<ffffffffa0032e3a>] ? tun_do_read.isra.24+0x29a/0x420 [tun]
 [<ffffffff816f8703>] inet_sendmsg+0x43/0xb0
 [<ffffffff8168b78e>] sock_aio_write+0x10e/0x130
 [<ffffffff810f04fa>] do_sync_write+0xca/0x110
 [<ffffffff8104676a>] ? set_current_blocked+0x3a/0x60
 [<ffffffff810467d5>] ? sigprocmask+0x45/0x80
 [<ffffffff810f0e15>] vfs_write+0x165/0x180
 [<ffffffff810f1085>] sys_write+0x45/0x90
 [<ffffffff818098f9>] ia32_do_call+0x13/0x13
Code: 76 bf 49 8b 4d 00 65 48 03 0c 25 b8 cb 00 00 48 8b 51 08 4c 8b 21 4d 85 e4 0f 84 eb 00 00 00 49 63 45 20 49 8b 7d 00 48 8d 4a 01 <49> 8b 1c 04 4c 89 e0 48 8d 37 e8 37 41 28 00 84 c0 74 c4 4d 85
RIP  [<ffffffff810ed5fa>] __kmalloc_track_caller+0xaa/0x1b0
 RSP <ffff88012d0b3b58>
CR2: 00000000000000ff
---[ end trace 4a40da26b9b3bff5 ]---

Looks like it might need some poisoning there. Sometimes the Oops stops
before it is fully emitted over the serial port. I have verified that
this happens on v3.3 and current Linus head (3.4-rc1+) and not on v3.2.

When I get some more time, I will try to track it down a bit further.

ssh -w any <vpn box> 'ifconfig tun0 x pointopoint y; echo "ifconfig tun0 y pointopoint x && ip route add 10.0.0.0/8 via x"; sleep 1d' | sh -v

Simon-
