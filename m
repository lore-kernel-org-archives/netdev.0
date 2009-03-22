From: Marcin Slusarz <marcin.slusarz@gmail.com>
Subject: [PATCH] netconsole: fix BUG during net device "upping"
Date: Sun, 22 Mar 2009 12:02:02 +0100
Message-ID: <49C61AAA.8050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Matt Mackall <mpm@selenic.com>, stable@kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:45432 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751973AbZCVLCS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 07:02:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ndo_open (eg skge_up) function printks something, netconsole decides
it can use this device because it checks state only (netif_running) which is
set before ndo_open. Check device flags too.

[35437.623580] skge eth1: enabling interface
[35437.623601] ------------[ cut here ]------------
[35437.623603] kernel BUG at drivers/net/skge.c:2767!
[35437.623606] invalid opcode: 0000 [#1] PREEMPT
[35437.623608] last sysfs file: /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
[35437.623611] CPU 0
[35437.623613] Modules linked in:
[35437.623617] Pid: 12711, comm: ip Not tainted 2.6.29-rc6-idle #82 To Be Filled By O.E.M.
[35437.623619] RIP: 0010:[<ffffffff803f3c30>]  [<ffffffff803f3c30>] skge_xmit_frame+0xbe/0x3ba
[35437.623628] RSP: 0018:ffff88003cc0f8b8  EFLAGS: 00010086
[35437.623630] RAX: 000000000000007f RBX: ffff88003e850000 RCX: 0000000000000001
[35437.623632] RDX: 0000000000000001 RSI: ffff88003f188720 RDI: ffff88002e568900
[35437.623635] RBP: ffff88003cc0f918 R08: 0000000000000002 R09: 0000000000000000
[35437.623637] R10: 0000000000000006 R11: 0000000000000000 R12: ffff88002e568900
[35437.623639] R13: ffff88003e850000 R14: ffffffff807180c0 R15: 0000000000000001
[35437.623642] FS:  00007f46b39086f0(0000) GS:ffffffff807dc020(0000) knlGS:00000000f6577b90
[35437.623644] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[35437.623646] CR2: 00007f46b3282110 CR3: 000000002ab18000 CR4: 00000000000006e0
[35437.623648] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[35437.623651] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[35437.623653] Process ip (pid: 12711, threadinfo ffff88003cc0e000, task ffff88002a8b5af0)
[35437.623655] Stack:
[35437.623657]  ffff88003eb43000 000000008077cc20 ffff88003f188000 ffff88003f188720
[35437.623660]  ffff88003efba800 ffff88003f188000 0000000000000000 ffff88003efd78a0
[35437.623664]  0000000000000086 ffff88003f188000 0000000000000000 0000000000000001
[35437.623667] Call Trace:
[35437.623670]  [<ffffffff804fac57>] netpoll_send_skb+0xd8/0x1a1
[35437.623675]  [<ffffffff804fb228>] netpoll_send_udp+0x214/0x220
[35437.623678]  [<ffffffff803fdf39>] write_msg+0x80/0xbf
[35437.623682]  [<ffffffff80233413>] __call_console_drivers+0x58/0x69
[35437.623687]  [<ffffffff80233485>] _call_console_drivers+0x61/0x66
[35437.623691]  [<ffffffff802335bb>] release_console_sem+0x131/0x1d4
[35437.623694]  [<ffffffff80233c0c>] vprintk+0x389/0x3b8
[35437.623698]  [<ffffffff802556c3>] ? __lock_acquire+0x73b/0x797
[35437.623703]  [<ffffffff80233ca2>] printk+0x67/0x69
[35437.623706]  [<ffffffff802556c3>] ? __lock_acquire+0x73b/0x797
[35437.623709]  [<ffffffff802539e1>] ? mark_held_locks+0x52/0x72
[35437.623712]  [<ffffffff80237609>] ? local_bh_enable_ip+0xbe/0xda
[35437.623716]  [<ffffffff803f0a0f>] skge_up+0x7c/0x88e
[35437.623719]  [<ffffffff804ebf62>] ? dev_set_rx_mode+0x29/0x2e
[35437.623723]  [<ffffffff80237609>] ? local_bh_enable_ip+0xbe/0xda
[35437.623726]  [<ffffffff804f0164>] dev_open+0x73/0xa8
[35437.623729]  [<ffffffff804edf99>] dev_change_flags+0xa8/0x167
[35437.623732]  [<ffffffff8052e0d5>] devinet_ioctl+0x26a/0x5e3
[35437.623736]  [<ffffffff8052efed>] inet_ioctl+0x92/0xaa
[35437.623739]  [<ffffffff804e1eec>] sock_ioctl+0x1e2/0x20e
[35437.623742]  [<ffffffff802a3ed0>] vfs_ioctl+0x2a/0x77
[35437.623745]  [<ffffffff802a4375>] do_vfs_ioctl+0x458/0x4b0
[35437.623747]  [<ffffffff802491bd>] ? up_read+0x26/0x2b
[35437.623751]  [<ffffffff8020b4cc>] ? sysret_check+0x27/0x62
[35437.623754]  [<ffffffff802a440f>] sys_ioctl+0x42/0x65
[35437.623757]  [<ffffffff8020b49b>] system_call_fastpath+0x16/0x1b
[35437.623760] Code: 52 04 69 c0 cd cc cc cc 8d 44 30 ff ff c2 39 d0 0f 8c 00 03 00 00 48 8b 75 b8 4c 8b ae a8 00 00 00 4d 8b 75 08 41 83 3e 00 79 04 <0f> 0b eb fe 4d 89 65 10 41 8b 44 24 68 45 31 ff 41 8b 54 24 6c
[35437.623787] RIP  [<ffffffff803f3c30>] skge_xmit_frame+0xbe/0x3ba
[35437.623790]  RSP <ffff88003cc0f8b8>
[35437.623793] ---[ end trace 4dbaa362038903db ]---
[35437.623796] note: ip[12711] exited with preempt_count 3

I could reliably trigger it by:
ifconfig eth0 down; while [ true ]; do ifconfig eth1 down; ifconfig eth1 up; done

Netconsole oopsed that way since at least 2.6.22 (oldest kernel I tried).

Fixes bug 12160.

Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Keiichi Kii <k-keiichi@bx.jp.nec.com>
Cc: Matt Mackall <mpm@selenic.com>
Cc: stable <stable@kernel.org> ?
---
 drivers/net/netconsole.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index d304d38..97e30b0 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -705,7 +705,7 @@ static void write_msg(struct console *con, const char *msg, unsigned int len)
 	spin_lock_irqsave(&target_list_lock, flags);
 	list_for_each_entry(nt, &target_list, list) {
 		netconsole_target_get(nt);
-		if (nt->enabled && netif_running(nt->np.dev)) {
+		if (nt->enabled && netif_running(nt->np.dev) && (nt->np.dev->flags & IFF_UP)) {
 			/*
 			 * We nest this inside the for-each-target loop above
 			 * so that we're able to get as much logging out to
-- 
1.6.0.6


