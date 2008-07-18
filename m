From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: bug: mutex_lock() in interrupt conntext via phy_stop() in gianfar
Date: Fri, 18 Jul 2008 14:10:08 +0200
Message-ID: <20080718121008.GA28871@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org, Nate Case <ncase@xes-inc.com>,
	Li Yang <leoli@freescale.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, linuxppc-dev@ozlabs.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:40383 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753950AbYGRMKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 08:10:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 35b5f6b1a aka [PHYLIB: Locking fixes for PHY I/O potentially sleeping]
changed the phydev->lock from spinlock into a mutex. Now, the following
code path got triggered while NFS was unavailable:

|[   21.287359] nfs: server 10.11.3.47 not responding, still trying
|[   38.891373] nfs: server 10.11.3.47 not responding, still trying
|[  148.179592] INFO: task udevd:1762 blocked for more than 120 seconds.
|[  148.185967] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
|[  148.193810] udevd         D 0fef1dd8     0  1762   1761
|[  148.199055] Call Trace:
|[  148.201504] [cecdda80] [c00071e4] __switch_to+0x6c/0x84
|[  148.206764] [cecddaa0] [c025973c] schedule+0x46c/0x4cc
|[  148.211937] [cecddad0] [c00f3d84] nfs_wait_schedule+0x24/0x38
|[  148.217712] [cecddae0] [c0259b74] __wait_on_bit_lock+0x68/0xcc
|[  148.223576] [cecddb00] [c0259c4c] out_of_line_wait_on_bit_lock+0x74/0x88
|[  148.230300] [cecddb50] [c00f3e6c] __nfs_revalidate_inode+0xd4/0x264
|[  148.236597] [cecddc20] [c00f1298] nfs_lookup_revalidate+0x1bc/0x3d4
|[  148.243071] [cecddd80] [c0081db8] do_lookup+0x148/0x1a0
|[  148.248361] [cecdddb0] [c0083bac] __link_path_walk+0x930/0xe24
|[  148.254219] [cecdde00] [c00840e8] path_walk+0x48/0xa8
|[  148.259293] [cecdde30] [c008442c] do_path_lookup+0x160/0x194
|[  148.264982] [cecdde60] [c0084fe0] __path_lookup_intent_open+0x58/0xa4
|[  148.271444] [cecdde80] [c007ea54] open_exec+0x2c/0xdc
|[  148.276525] [cecddef0] [c007efa4] do_execve+0x58/0x1c4
|[  148.281704] [cecddf20] [c0007568] sys_execve+0x58/0x84
|[  148.286873] [cecddf40] [c000df58] ret_from_syscall+0x0/0x3c
|[  169.651632] INFO: task udevsettle:1053 blocked for more than 120 seconds.

some more of this and now the interresting part:

|[  194.859659] NETDEV WATCHDOG: eth0: transmit timed out
|[  194.864733] BUG: sleeping function called from invalid context at /home/bigeasy/git/linux-2.6-powerpc/kernel/mutex.c:87
|[  194.875529] in_atomic():1, irqs_disabled():0
|[  194.879805] Call Trace:
|[  194.882250] [c0383d90] [c0006dd8] show_stack+0x48/0x184 (unreliable)
|[  194.888649] [c0383db0] [c001e938] __might_sleep+0xe0/0xf4
|[  194.894069] [c0383dc0] [c025a43c] mutex_lock+0x24/0x3c
|[  194.899234] [c0383de0] [c019005c] phy_stop+0x20/0x70
|[  194.904234] [c0383df0] [c018d4ec] stop_gfar+0x28/0xf4
|[  194.909305] [c0383e10] [c018e8c4] gfar_timeout+0x30/0x60
|[  194.914638] [c0383e20] [c01fe7c0] dev_watchdog+0xa8/0x144
|[  194.920064] [c0383e30] [c002f93c] run_timer_softirq+0x148/0x1c8
|[  194.926008] [c0383e60] [c002b084] __do_softirq+0x5c/0xc4
|[  194.931350] [c0383e80] [c00046fc] do_softirq+0x3c/0x54
|[  194.936515] [c0383e90] [c002ac60] irq_exit+0x3c/0x5c
|[  194.941499] [c0383ea0] [c000b378] timer_interrupt+0xe0/0xf8
|[  194.947097] [c0383ec0] [c000e5ac] ret_from_except+0x0/0x18
|[  194.952610] [c0383f80] [c000804c] cpu_idle+0xcc/0xdc
|[  194.957592] [c0383fa0] [c025c07c] etext+0x7c/0x90
|[  194.962322] [c0383fc0] [c0338960] start_kernel+0x294/0x2a8
|[  194.967839] [c0383ff0] [c00003dc] skpinv+0x304/0x340
|[  194.972833] ------------[ cut here ]------------
|[  194.977450] Badness at /home/bigeasy/git/linux-2.6-powerpc/kernel/mutex.c:134
|[  194.984589] NIP: c025a268 LR: c025a250 CTR: c017e224
|[  194.989557] REGS: c0383cf0 TRAP: 0700   Not tainted  (2.6.26)
|[  194.995302] MSR: 00029000 <EE,ME>  CR: 28002022  XER: 00000000
|[  195.001167] TASK = c035e500[0] 'swapper' THREAD: c0382000
|[  195.006390] GPR00: 00000000 c0383da0 c035e500 00000001 c035e500 00000010 00000000 c0360000 
|[  195.014798] GPR08: 00000000 c0390000 00000001 c0360000 00006353 628a87a2 0ffe8600 00000000 
|[  195.023206] GPR16: cab54ee3 00000000 00000000 0ffe7384 00000000 00000000 0ff904a0 00000000 
|[  195.031612] GPR24: 00000000 00000000 c038e5a4 d1058000 c035e500 cf86b570 cf9c3888 cf9c3888 
|[  195.040199] NIP [c025a268] __mutex_lock_slowpath+0x44/0x1f4
|[  195.045783] LR [c025a250] __mutex_lock_slowpath+0x2c/0x1f4
|[  195.051277] Call Trace:
|[  195.053721] [c0383da0] [cf9c3888] 0xcf9c3888 (unreliable)
|[  195.059146] [c0383de0] [c019005c] phy_stop+0x20/0x70
|[  195.064135] [c0383df0] [c018d4ec] stop_gfar+0x28/0xf4
|[  195.069202] [c0383e10] [c018e8c4] gfar_timeout+0x30/0x60
|[  195.074529] [c0383e20] [c01fe7c0] dev_watchdog+0xa8/0x144
|[  195.079946] [c0383e30] [c002f93c] run_timer_softirq+0x148/0x1c8
|[  195.085885] [c0383e60] [c002b084] __do_softirq+0x5c/0xc4
|[  195.091219] [c0383e80] [c00046fc] do_softirq+0x3c/0x54
|[  195.096374] [c0383e90] [c002ac60] irq_exit+0x3c/0x5c
|[  195.101353] [c0383ea0] [c000b378] timer_interrupt+0xe0/0xf8
|[  195.106944] [c0383ec0] [c000e5ac] ret_from_except+0x0/0x18
|[  195.112447] [c0383f80] [c000804c] cpu_idle+0xcc/0xdc
|[  195.117426] [c0383fa0] [c025c07c] etext+0x7c/0x90
|[  195.122147] [c0383fc0] [c0338960] start_kernel+0x294/0x2a8
|[  195.127655] [c0383ff0] [c00003dc] skpinv+0x304/0x340
|[  195.132633] Instruction dump:
|[  195.135422] 90010044 7c5c1378 8009000c 5409012f 41a20024 4bee78dd 2f830000 419e0018 
|[  195.143222] 3d20c039 80098714 2f800000 409e0008 <0fe00000> 7fc000a6 7c000146 801f0024 

I found out that the same code path may be trigger in
- drivers/net/ucc_geth.c
- drivers/net/fec_mpc52xx.c
- drivers/net/fs_enet/fs_enet-main.c

other drivers use phy_stop() in ->close only.

Sebastian
