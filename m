From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: Wrong usage of hash in L2TP leading to NULL ptr derefs
Date: Mon, 28 May 2012 19:21:08 +0200
Message-ID: <1338225668.4284.29.camel@lappy>
References: <1338221539.4284.25.camel@lappy> <4FC3A599.1040909@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: James Chapman <jchapman@katalix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4FC3A599.1040909@katalix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi James,

On Mon, 2012-05-28 at 17:19 +0100, James Chapman wrote:
> On 28/05/12 17:12, Sasha Levin wrote:
> > Hi all,
> > 
> > Looking at net/l2tp/l2tp_ip{6}.c, l2tp uses UDP for communications, but
> > uses inet_hash and inet_unhash for hashing - which appears to be wrong
> > (and causes NULL ptr derefs during runtime).
> 
> L2TPv3 also supports IP encapsulation, which is L2TP directly in IP, no
> UDP. That's what the l2tp_ip[6] code implements.

Hm... Odd, I thought it uses UDP because there I saw it using udp_disconnect, udp_ioctl, and friends...

> Can you post an oops with steps for how to reproduce it?

Sure!

The code is pretty simple:

#include <linux/l2tp.h>
#include <sys/types.h>
#include <sys/socket.h>

void main(void)
{
        struct sockaddr addr = { .sa_family = AF_UNSPEC };
        connect(socket(AF_INET, SOCK_DGRAM, IPPROTO_L2TP), &addr, sizeof(addr));
}


And the BUG it produces:

[   18.161780] BUG: unable to handle kernel NULL pointer dereference at 0000000000000014
[   18.162025] IP: [<ffffffff82e133b0>] inet_unhash+0x50/0xd0
[   18.162025] PGD 4066e067 PUD 40661067 PMD 0 
[   18.162025] Oops: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC
[   18.162025] CPU 1 
[   18.162025] Pid: 5821, comm: a.out Tainted: G        W    3.4.0-next-20120528-sasha-00009-gd406307 #309 Bochs Bochs
[   18.162025] RIP: 0010:[<ffffffff82e133b0>]  [<ffffffff82e133b0>] inet_unhash+0x50/0xd0
[   18.162025] RSP: 0018:ffff88001989be28  EFLAGS: 00010293
[   18.162025] RAX: 0000000000000000 RBX: ffff8800407a8000 RCX: 0000000000000000
[   18.162025] RDX: 0000000000000007 RSI: 0000000000000000 RDI: ffff8800407a8000
[   18.162025] RBP: ffff88001989be38 R08: 0000000000000000 R09: 0000000000000001
[   18.162025] R10: 0000000000000001 R11: 0000000000000001 R12: ffff8800407a8000
[   18.162025] R13: ffff88001989bec8 R14: 00007fff79818700 R15: 0000000000000000
[   18.162025] FS:  00007f312ff36700(0000) GS:ffff88001b800000(0000) knlGS:0000000000000000
[   18.162025] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   18.162025] CR2: 0000000000000014 CR3: 0000000040793000 CR4: 00000000000407e0
[   18.162025] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[   18.162025] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[   18.162025] Process a.out (pid: 5821, threadinfo ffff88001989a000, task ffff880019c18000)
[   18.162025] Stack:
[   18.162025]  ffff8800407a8000 0000000000000000 ffff88001989be78 ffffffff82e3a249
[   18.162025]  ffffffff82e3a050 ffff88001989bec8 ffff88001989be88 ffff8800407a8000
[   18.162025]  0000000000000010 ffff88001989bec8 ffff88001989bea8 ffffffff82e42639
[   18.162025] Call Trace:
[   18.162025]  [<ffffffff82e3a249>] udp_disconnect+0x1f9/0x290
[   18.162025]  [<ffffffff82e3a050>] ? udp_rcv+0x20/0x20
[   18.162025]  [<ffffffff82e42639>] inet_dgram_connect+0x29/0x80
[   18.162025]  [<ffffffff82d00645>] ? move_addr_to_kernel+0x35/0x80
[   18.162025]  [<ffffffff82d012fc>] sys_connect+0x9c/0x100
[   18.162025]  [<ffffffff8325c319>] ? retint_swapgs+0x13/0x1b
[   18.162025]  [<ffffffff81968f7e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[   18.162025]  [<ffffffff8325cbf9>] system_call_fastpath+0x16/0x1b
[   18.162025] Code: fa 0a 75 27 48 8b 57 30 0f b7 8f 2a 05 00 00 48 c1 ea 06 8d 14 11 83 e2 1f 48 8d 14 92 48 c1 e2 04 48 8d 5c 10 40 eb 15 0f 1f 00 <8b> 50 14 23 57 08 48 8d 1c d2 48 c1 e3 03 48 03 58 08 48 89 df 
[   18.162025] RIP  [<ffffffff82e133b0>] inet_unhash+0x50/0xd0
[   18.162025]  RSP <ffff88001989be28>
[   18.162025] CR2: 0000000000000014
[   18.409434] ---[ end trace 8f6ca168297608b9 ]---
