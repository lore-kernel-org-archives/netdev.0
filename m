From: Pavel Emelyanov <xemul@parallels.com>
Subject: Recent Linus' tree, kernel BUG at fs/inode.c:1436!
Date: Fri, 19 Dec 2014 14:34:00 +0300
Message-ID: <54940D28.8050901@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:45827 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752078AbaLSLeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 06:34:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

It looks like there's a strange refcount underflow in VFS/socket code.
The proggie [1] crashes the recent Linus' tree (d790be38 Merge tag
'modules-next-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/rusty/linux) 
with the calltrace [2].

If in the proggie the psk is replaced with non-socket descriptor the
issue doesn't appear.

Thanks,
Pavel


[1]--------------------------------------------

#include <sys/socket.h>
#include <sys/un.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

int main(int argc, char **argv)
{
	int psk, proc;
	char buf[1024];

	psk = socket(PF_LOCAL, SOCK_STREAM, 0);
	sprintf(buf, "/proc/self/fd/%d", psk);
	proc = open(buf, O_RDONLY);
	close(proc);
	close(psk);

	return 0;
}

[2]--------------------------------------------

[  322.823998] ------------[ cut here ]------------
[  322.824251] kernel BUG at fs/inode.c:1436!
[  322.824251] invalid opcode: 0000 [#6] SMP 
[  322.824251] Modules linked in: serio_raw ata_generic
[  322.824251] CPU: 0 PID: 1058 Comm: a.out Tainted: G      D        3.18.0-criu+ #10
[  322.824251] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  322.824251] task: ffff88003ca7d070 ti: ffff880037058000 task.ti: ffff880037058000
[  322.824251] RIP: 0010:[<ffffffff811521bf>]  [<ffffffff811521bf>] iput+0x13f/0x180
[  322.824251] RSP: 0018:ffff88003705be08  EFLAGS: 00010202
[  322.824251] RAX: 0000000000000000 RBX: ffff88003dd0dbb0 RCX: dead000000200200
[  322.824251] RDX: 0000000000000000 RSI: 0000000000000001 RDI: ffff88003dd0dbb0
[  322.824251] RBP: ffff88003705be28 R08: ffff88003d187a50 R09: ffff88003fc15820
[  322.824251] R10: ffffffff81392d4e R11: ffffea0000f74300 R12: ffff88003dd0dbb0
[  322.824251] R13: ffff88003d187a18 R14: 0000000000000000 R15: ffff88003d1879c0
[  322.824251] FS:  00007f1720ba7740(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
[  322.824251] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  322.824251] CR2: 00007f17206c4630 CR3: 000000003731d000 CR4: 00000000000006f0
[  322.824251] Stack:
[  322.824251]  ffff88003d1879c0 ffff88003dd0dbb0 ffff88003d187a18 0000000000000000
[  322.824251]  ffff88003705be58 ffffffff8114d710 ffff88003705be58 0000000000000000
[  322.824251]  ffff88003d187a18 ffff88003dd0dbb0 ffff88003705be88 ffffffff8114d7fd
[  322.824251] Call Trace:
[  322.824251]  [<ffffffff8114d710>] __dentry_kill+0x180/0x1d0
[  322.824251]  [<ffffffff8114d7fd>] dput+0x9d/0x160
[  322.824251]  [<ffffffff81139198>] __fput+0x168/0x1e0
[  322.824251]  [<ffffffff81139259>] ____fput+0x9/0x10
[  322.824251]  [<ffffffff81065d2f>] task_work_run+0xaf/0xf0
[  322.824251]  [<ffffffff81002c71>] do_notify_resume+0x51/0x80
[  322.824251]  [<ffffffff81494920>] int_signal+0x12/0x17
[  322.824251] Code: 00 00 00 eb a0 0f 1f 80 00 00 00 00 48 81 8b 90 00 00 00 00 01 00 00 48 89 df e8 7d fe ff ff 80 83 80 00 00 00 01 e9 fb fe ff ff <0f> 0b be 71 05 00 00 48 c7 c7 53 2a 75 81 e8 5e a9 ef ff e9 06 
[  322.824251] RIP  [<ffffffff811521bf>] iput+0x13f/0x180
[  322.824251]  RSP <ffff88003705be08>
[  322.855968] ---[ end trace 2e35ddcef73fed30 ]---
