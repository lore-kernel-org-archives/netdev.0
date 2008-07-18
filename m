From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [bug] Attempt to release alive inet socket f6fac040
Date: Fri, 18 Jul 2008 21:10:37 +0200
Message-ID: <20080718191037.GA25937@elte.hu>
References: <20080717214222.GA29449@elte.hu> <19f34abd0807171615s5b477d4cr22d3e9444bcf65df@mail.gmail.com> <20080717.190315.186892939.davem@davemloft.net> <19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, penberg@cs.helsinki.fi, rjw@sisk.pl
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:36412 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421AbYGRTLJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 15:11:09 -0400
Content-Disposition: inline
In-Reply-To: <19f34abd0807180003m7bdf832g141777751d7ea563@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hm, just got another skb related weirdness and crash on that testbox:

[   13.495000] usb 1-0:1.0: uevent
[   19.392000] Attempt to release alive inet socket f6fac040
[   20.387000] EXT3 FS on sda1, internal journal
[   20.762500] eth0: no IPv6 routers present
[   22.431000] warning: process `kudzu' used the deprecated sysctl system call with 1.23.
[   22.906000] ------------[ cut here ]------------
[   22.906000] kernel BUG at mm/slab.c:2927!
[   22.906000] invalid opcode: 0000 [#1] PREEMPT SMP 
[   22.906000] Modules linked in:
[   22.906000] 
[   22.906000] Pid: 1831, comm: ip6tables-resto Tainted: G        W (2.6.26-tip-03923-g2c96bcb-dirty #3134)
[   22.906000] EIP: 0060:[<b01878d2>] EFLAGS: 00010046 CPU: 0
[   22.906000] EIP is at cache_alloc_refill+0xfa/0x431
[   22.906000] EAX: 00000004 EBX: f6ec1a00 ECX: f67826c0 EDX: f6fa3c40
[   22.906000] ESI: f6fac000 EDI: 0000000b EBP: f5c01ec4 ESP: f5c01e70
[   22.906000]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[   22.906000] Process ip6tables-resto (pid: 1831, ti=f5c01000 task=f5d2f060 task.ti=f5c01000)
[   22.906000] Stack: 00000004 00000004 000000d0 000000d0 f67826c8 f67826d0 f6fac01c 000080d0 
[   22.906000]        f6fa3c40 f6fa9800 f67826c0 00000000 7f431025 b014a3e9 b2bd6ab8 00000000 
[   22.906000]        00000000 00000000 00000246 f6fa3c40 f6fa3c40 f5c01ee4 b0187793 b07c11d6 
[   22.906000] Call Trace:
[   22.906000]  [<b014a3e9>] ? __wake_up_bit+0xc/0x37
[   22.906000]  [<b0187793>] ? kmem_cache_alloc+0x53/0x98
[   22.906000]  [<b05589b5>] ? sk_prot_alloc+0x1e/0xa7
[   22.906000]  [<b026cb86>] ? cap_capable+0xa/0x2b
[   22.906000]  [<b0559fa4>] ? sk_alloc+0x20/0xa3
[   22.906000]  [<b05c4364>] ? inet6_create+0x187/0x316
[   22.906000]  [<b0556e87>] ? __sock_create+0x15b/0x229
[   22.906000]  [<b0556f9c>] ? sock_create+0x29/0x2e
[   22.906000]  [<b0557112>] ? sys_socket+0x1e/0x42
[   22.906000]  [<b05577b6>] ? sys_socketcall+0x56/0x163
[   22.906000]  [<b011a418>] ? resume_userspace+0x8/0x30
[   22.906000]  [<b011a4ff>] ? sysenter_past_esp+0x78/0xb9
[   22.906000]  =======================
[   22.906000] Code: bb 00 00 00 8b 45 d4 8b 30 39 c6 75 13 c7 40 50 01 00 00 00 8b 70 10 3b 75 c0 0f 84 94 00 00 00 8b 55 cc 8b 42 38 39 46 10 72 37 <0f> 0b eb fe 8b 0b 89 4d ac 8b 56 14 8b 45 cc 0f af 50 2c 03 56 
[   22.906000] EIP: [<b01878d2>] cache_alloc_refill+0xfa/0x431 SS:ESP 0068:f5c01e70
[   22.906000] Kernel panic - not syncing: Fatal exception
[   22.906000] Pid: 1831, comm: ip6tables-resto Tainted: G      D W 2.6.26-tip-03923-g2c96bcb-dirty #3134

Config and full crashlog at:

 http://redhat.com/~mingo/misc/config-Fri_Jul_18_19_59_56_CEST_2008.bad
 http://redhat.com/~mingo/misc/crash-2.6.26-tip-03923-g2c96bcb.log

Note, the first warning the bootlog is here:

[   10.039500] initcall ip6_queue_init+0x0/0x111 returned 0 after 0 msecs
[   10.039500] calling  ip6_tunnel_init+0x0/0x91
[   10.039500] ------------[ cut here ]------------
[   10.039500] WARNING: at net/core/dst.c:265 dst_release+0x24/0x2b()
[   10.039500] Modules linked in:
[   10.039500] Pid: 7, comm: ksoftirqd/1 Not tainted 2.6.26-tip-03923-g2c96bcb-dirty #3134
[   10.040500]  [<b0139b2d>] warn_on_slowpath+0x46/0x6a
[   10.040500]  [<b0152c9a>] ? put_lock_stats+0xd/0x21
[   10.040500]  [<b015397b>] ? __lock_acquire+0x5ba/0x618
[   10.040500]  [<b0152c9a>] ? put_lock_stats+0xd/0x21
[   10.040500]  [<b05642f6>] dst_release+0x24/0x2b
[   10.040500]  [<b055bfa3>] skb_release_all+0x13/0x83
[   10.041500]  [<b055b910>] __kfree_skb+0x10/0x6b
[   10.041500]  [<b0561e16>] net_tx_action+0x6e/0xee
[   10.041500]  [<b013e38d>] __do_softirq+0x7a/0xe8
[   10.041500]  [<b013e313>] ? __do_softirq+0x0/0xe8
[   10.041500]  [<b011ccc6>] do_softirq+0x79/0xba
[   10.041500]  [<b013e647>] ksoftirqd+0x88/0x13b
[   10.042500]  [<b013e5bf>] ? ksoftirqd+0x0/0x13b
[   10.042500]  [<b014a365>] kthread+0x40/0x67
[   10.042500]  [<b014a325>] ? kthread+0x0/0x67
[   10.042500]  [<b011b7c7>] kernel_thread_helper+0x7/0x10
[   10.042500]  =======================
[   10.042500] ---[ end trace 5c376f440d7caa15 ]---
[   10.042500] Attempt to release alive inet socket f6fac040
[   10.043500] initcall ip6_tunnel_init+0x0/0x91 returned 0 after 3 msecs
[   10.043500] calling  packet_init+0x0/0x3e

That does seem to be quite specific.

Note, this box never had skb problems and was running hundreds of 
similar boot tests every day - these appeared in this merge window.

The upstream base of 2.6.26-tip-03923-g2c96bcb is v2.6.26-3465-g5b664cb.

I'll now check how reproducible this crash is.

	Ingo
