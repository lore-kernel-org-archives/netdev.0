From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [BUG] net: kernel BUG at include/net/netns/generic.h:40!
Date: Sat, 03 Dec 2011 22:21:41 +0200
Message-ID: <1322943701.4040.0.camel@lappy>
References: <1322892365.2664.2.camel@sasha>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322892365.2664.2.camel@sasha>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I've also got it bisected to:

bd30ce4bc0b7dc859c1d1cba7ad87e08642418b0
f36214408470ecf6a052e76b72d05b2328b60fcf

The second commit doesn't build, so it could be either one of those.

On Sat, 2011-12-03 at 08:06 +0200, Sasha Levin wrote:
> Hi all,
> 
> I got the following when trying a clone():
> 
> [  126.413983] ------------[ cut here ]------------
> [  126.414023] kernel BUG at include/net/netns/generic.h:40!
> [  126.414023] invalid opcode: 0000 [#1] PREEMPT SMP 
> [  126.414023] CPU 0 
> [  126.414023] Pid: 2507, comm: trinity Not tainted 3.2.0-rc3-next-20111202-sasha-00003-gc9d4348 #17  
> [  126.414023] RIP: 0010:[<ffffffff8235762e>]  [<ffffffff8235762e>] get_cfcnfg+0xee/0x100
> [  126.414023] RSP: 0018:ffff88001108db00  EFLAGS: 00010212
> [  126.414023] RAX: 0000000000000001 RBX: 0000000000000010 RCX: 0000000000000000
> [  126.414023] RDX: 0000000000000001 RSI: ffffffff82c1ff20 RDI: 0000000000000282
> [  126.414023] RBP: ffff88001108db20 R08: 0000000000000003 R09: 0000000000000001
> [  126.414023] R10: 0000000000000000 R11: 0000000000000001 R12: ffff88001107ed80
> [  126.414023] R13: ffffffff82db4b20 R14: 0000000000000000 R15: 0000000000000010
> [  126.414023] FS:  00007f77a32d7700(0000) GS:ffff880013a00000(0000) knlGS:0000000000000000
> [  126.414023] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  126.414023] CR2: 00007f77a2e054d0 CR3: 0000000011029000 CR4: 00000000000006f0
> [  126.414023] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  126.414023] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  126.414023] Process trinity (pid: 2507, threadinfo ffff88001108c000, task ffff8800115c1610)
> [  126.414023] Stack:
> [  126.414023]  ffffffff82357557 ffffffff8203cc20 ffff8800110b4000 00000000ffffffd9
> [  126.414023]  ffff88001108db80 ffffffff823579ae ffff88001108db80 ffffffff8216292d
> [  126.414023]  0000000000000001 ffff8800115c1610 ffff88001108db80 ffff8800110b4000
> [  126.414023] Call Trace:
> [  126.414023]  [<ffffffff82357557>] ? get_cfcnfg+0x17/0x100
> [  126.414023]  [<ffffffff8203cc20>] ? lockdep_rtnl_is_held+0x10/0x20
> [  126.414023]  [<ffffffff823579ae>] caif_device_notify+0x2e/0x380
> [  126.414023]  [<ffffffff8216292d>] ? packet_notifier+0x19d/0x220
> [  126.414023]  [<ffffffff810d5a73>] notifier_call_chain+0x93/0xf0
> [  126.414023]  [<ffffffff810d5fd1>] raw_notifier_call_chain+0x11/0x20
> [  126.414023]  [<ffffffff820296d2>] call_netdevice_notifiers+0x32/0x60
> [  126.414023]  [<ffffffff82030c06>] register_netdevice+0x196/0x300
> [  126.414023]  [<ffffffff82030d89>] register_netdev+0x19/0x30
> [  126.414023]  [<ffffffff81afe29a>] loopback_net_init+0x4a/0xa0
> [  126.414023]  [<ffffffff82024c92>] ops_init+0x42/0x180
> [  126.414023]  [<ffffffff82024e3b>] setup_net+0x6b/0x100
> [  126.414023]  [<ffffffff82025296>] copy_net_ns+0x86/0x110
> [  126.414023]  [<ffffffff810d5009>] create_new_namespaces+0xd9/0x190
> [  126.414023]  [<ffffffff810d51d4>] copy_namespaces+0x84/0xc0
> [  126.414023]  [<ffffffff810d343c>] ? __mutex_init+0x5c/0x70
> [  126.414023]  [<ffffffff810ad531>] copy_process+0xa31/0x1490
> [  126.414023]  [<ffffffff810ae043>] do_fork+0x73/0x350
> [  126.414023]  [<ffffffff810e828d>] ? trace_hardirqs_on+0xd/0x10
> [  126.414023]  [<ffffffff823e361d>] ? retint_swapgs+0x13/0x1b
> [  126.414023]  [<ffffffff8104bd63>] sys_clone+0x23/0x30
> [  126.414023]  [<ffffffff823e4273>] stub_clone+0x13/0x20
> [  126.414023]  [<ffffffff823e3ed2>] ? system_call_fastpath+0x16/0x1b
> [  126.414023] Code: 20 d9 fe 85 c0 75 8f 48 c7 c2 68 62 93 82 be 27 00 00 00 48 c7 c7 fa 49 a2 82 c6 05 a0 f2 bc 01 01 e8 47 5e d9 fe e9 6b ff ff ff <0f> 0b 0f 0b 66 66 66 66 66 2e 0f 1f 84 00 00 00 00 00 55 48 89 
> [  126.414023] RIP  [<ffffffff8235762e>] get_cfcnfg+0xee/0x100
> [  126.414023]  RSP <ffff88001108db00>
> [  126.475257] ---[ end trace c62732ec90be8c83 ]---
> 
> Please let me know if I can help debugging this issue.
> 

-- 

Sasha.
