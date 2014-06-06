From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: netlink executing RO memory
Date: Fri, 6 Jun 2014 09:02:14 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17258588@AcuExch.aculab.com>
References: <5390D152.30702@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: 'Sasha Levin' <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:37765 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751098AbaFFJCq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 05:02:46 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 15041-09 for <netdev@vger.kernel.org>;
 Fri,  6 Jun 2014 10:02:36 +0100 (BST)
In-Reply-To: <5390D152.30702@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sasha Levin
> While fuzzing with trinity inside a KVM tools guest running the latest -next
> kernel I've stumbled on the following spew:
> 
> [  306.065161] kernel tried to execute NX-protected page - exploit attempt? (uid: 0)
> [  306.067295] BUG: unable to handle kernel paging request at ffff880053b8fd08
> [  306.069237] IP: 0xffff880053b8fd08  (??:?)
> [  306.070071] PGD 24b9c067 PUD 705dd2067 PMD 705d34067 PTE 8000000053b8f163
> [  306.070071] Oops: 0011 [#1] PREEMPT SMP DEBUG_PAGEALLOC
> [  306.070071] Dumping ftrace buffer:
> [  306.070071]    (ftrace buffer empty)
> [  306.070071] Modules linked in:
> [  306.070071] CPU: 16 PID: 9577 Comm: trinity-c194 Tainted: G        W     3.15.0-rc8-next-20140605-
> sasha-00020-g833a807 #592
> [  306.070071] task: ffff880053b90000 ti: ffff880053b8c000 task.ti: ffff880053b8c000
> [  306.070071] RIP: 0xffff880053b8fd08  (??:?)
> [  306.070071] RSP: 0018:ffff880053b8fcc8  EFLAGS: 00010287
> [  306.070071] RAX: ffff8806286e8000 RBX: 0000000000000000 RCX: 0000004742e748d4
> [  306.070071] RDX: 0000000000000007 RSI: ffffffff9fffd31c RDI: ffffffffa0558ed5
> [  306.070071] RBP: ffff880053b8fd08 R08: 0000000000005d3c R09: 0000000000000000
> [  306.070071] R10: 0000000000000000 R11: 0000000000000001 R12: ffff880053b8fdf8
> [  306.070071] R13: ffff8803d55b8000 R14: ffff88065ea35cd0 R15: 0000000000000000
> [  306.070071] FS:  00007f5c3bb31700(0000) GS:ffff8803d7000000(0000) knlGS:0000000000000000
> [  306.070071] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  306.070071] CR2: ffff880053b8fd08 CR3: 0000000053b6b000 CR4: 00000000000006a0
> [  306.070071] DR0: 00000000006d6000 DR1: 00000000006d6000 DR2: 0000000000000000
> [  306.070071] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 000000000095060a
> [  306.070071] Stack:
> [  306.070071]  ffff880053b8fdc8 00000000026d7de0 0000000000000010 7fffffffffffffff
> [  306.070071]  0000000000000000 ffff88065ea35cd0 0000000000000001 0000000000000000
> [  306.095047]  ffff880053b8fda8 ffffffffa0000ad1 ffff8803d55b8000 ffff8803d71d8340
> [  306.095047] Call Trace:
> [  306.095047] netlink_sendmsg (net/netlink/af_netlink.c:2398)
> [  306.095047] sock_aio_write (net/socket.c:959 net/socket.c:974)
> [  306.095047] ? sched_clock_local (kernel/sched/clock.c:214)
> [  306.095047] ? vtime_account_user (kernel/sched/cputime.c:687)
> [  306.095047] do_sync_write (fs/read_write.c:458)
> [  306.095047] vfs_write (fs/read_write.c:534)
> [  306.095047] SyS_write (fs/read_write.c:584 fs/read_write.c:576)
> [  306.095047] tracesys (arch/x86/kernel/entry_64.S:542)
> [ 306.095047] Code: 00 00 00 ff ff ff ff ff ff ff 7f 00 00 00 00 00 00 00 00 d0 5c a3 5e 06 88 ff ff
> 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 <a8> fd b8 53 00 88 ff ff d1 0a 00 a0 ff ff ff ff 00
> 80 5b d5 03
> All code
> ========
>    0:	00 00                	add    %al,(%rax)
>    2:	00 ff                	add    %bh,%bh
>    4:	ff                   	(bad)
>    5:	ff                   	(bad)
>    6:	ff                   	(bad)
>    7:	ff                   	(bad)
>    8:	ff                   	(bad)
>    9:	ff                   	(bad)
>    a:	7f 00                	jg     0xc
>    c:	00 00                	add    %al,(%rax)
>    e:	00 00                	add    %al,(%rax)
>   10:	00 00                	add    %al,(%rax)
>   12:	00 d0                	add    %dl,%al
>   14:	5c                   	pop    %rsp
>   15:	a3 5e 06 88 ff ff 01 	movabs %eax,0x1ffff88065e
>   1c:	00 00
> 	...
>   2a:*	00 a8 fd b8 53 00    	add    %ch,0x53b8fd(%rax)		<-- trapping instruction
>   30:	88 ff                	mov    %bh,%bh
>   32:	ff d1                	callq  *%rcx
>   34:	0a 00                	or     (%rax),%al
>   36:	a0 ff ff ff ff 00 80 	movabs 0xd55b8000ffffffff,%al
>   3d:	5b d5
>   3f:	03 00                	add    (%rax),%eax

The disassembly hasn't aligned itself with the instruction boundaries.

> Code starting with the faulting instruction
> ===========================================
>    0:	a8 fd                	test   $0xfd,%al
>    2:	b8 53 00 88 ff       	mov    $0xff880053,%eax
>    7:	ff d1                	callq  *%rcx
>    9:	0a 00                	or     (%rax),%al
>    b:	a0 ff ff ff ff 00 80 	movabs 0xd55b8000ffffffff,%al
>   12:	5b d5
>   14:	03 00                	add    (%rax),%eax

And that doesn't look like valid code at all.

The code must have jumped to the instruction - otherwise it would
have faulted on the previous one.

So most likely there was an indirect call from the previous frame.
Note that $rbp also contains the faulting address.

	David
