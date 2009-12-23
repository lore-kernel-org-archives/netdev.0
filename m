From: lsorense@csclub.uwaterloo.ca (Lennart Sorensen)
Subject: ucc_geth broken in 2.6.32 by
	864fdf884e82bacbe8ca5e93bd43393a61d2e2b4
Date: Wed, 23 Dec 2009 12:40:19 -0500
Message-ID: <20091223174019.GB762@caffeine.csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	leoli@freescale.com, Len Sorensen <lsorense@csclub.uwaterloo.ca>,
	Anton Vorontsov <avorontsov@ru.mvista.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755665AbZLWRkX@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We use the ucc_geth for 6 ports (4 100Mbit and 2 Gbit ports) on an
mpc8360e.  Up to 2.6.31 this worked fine.  2.6.32 on the other hand
crashes very quickly after boot.

I managed to see the same crash when I was selectively trying to add newer
ucc_geth patches to the 2.6.31 kernel a couple of months ago, and the same
patch that caused a crash then seems suspect.  If I revert the patch the
system runs completely stable.  Amusingly, the excact error message the
patch claims to fix is in fact the error it causes to happen in my case.

So preferably 864fdf884e82bacbe8ca5e93bd43393a61d2e2b4 could be reverted
unless someone can fix it.  I can't even make sense of why it is supposed
to improve anything, it certainly seems like a very unsafe change
to make.  Removing locking and disabling of interrupts before poking at
phy settings and such doesn't seem like a minor change and doesn't seem
that safe either.

Now I must add that I run with the xenomai/adeos-ipipe patches as well,
which do change interrupt handling a little, but so far this has worked
fine with the previous code and only the current code is broken for us.
I could try to build without the patch, although I would loose some major
functionality on the box doing so, and I would not be surprised if it
still fails since I believe I tried that already with 2.6.31+selected
git patches before without xenomai patched in and it still failed,
but I am only about 99% sure of that.

With the patch I get:
NETDEV WATCHDOG: eth2 (ucc_geth): transmit queue 0 timed out
------------[ cut here ]------------
Badness at c02729a8 [verbose debug info unavailable]
NIP: c02729a8 LR: c02729a8 CTR: c01b6088
REGS: c0451c40 TRAP: 0700   Not tainted  (2.6.32-trunk-8360e)
MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 42042024  XER: 20000000
TASK = c041f3e8[0] 'swapper' THREAD: c0450000
GPR00: c02729a8 c0451cf0 c041f3e8 00000045 00002ae9 ffffffff c01b6afc c0422c48
GPR08: c042fde8 00000002 00000003 00010000 22042024 1001af90 1fffd000 00000000
GPR16: 00000000 c038c6d8 00000001 00200200 00000000 c0465eec c0465cec c0465aec
GPR24: c0450000 c04658ec c0423c2c df0e01c0 c0480000 df0e0000 c0423c2c 00000000
NIP [c02729a8] dev_watchdog+0x280/0x290
LR [c02729a8] dev_watchdog+0x280/0x290
Call Trace:
[c0451cf0] [c02729a8] dev_watchdog+0x280/0x290 (unreliable)
[c0451d50] [c00377c4] run_timer_softirq+0x164/0x224
[c0451da0] [c0032a38] __do_softirq+0xb8/0x13c
[c0451df0] [c00065cc] do_softirq+0xa0/0xac
[c0451e00] [c003280c] irq_exit+0x7c/0x9c
[c0451e10] [c00640c4] __ipipe_sync_stage+0x248/0x24c
[c0451e50] [c0064374] ipipe_suspend_domain+0xa0/0xf4
[c0451e70] [c00644a4] __ipipe_walk_pipeline+0xdc/0x120
[c0451e90] [c000af28] __ipipe_handle_irq+0x164/0x168
[c0451ec0] [c000b03c] __ipipe_grab_irq+0x3c/0xa4
[c0451ed0] [c0014814] __ipipe_ret_from_except+0x0/0xc
--- Exception: 501 at cpu_idle+0xe0/0xf0
    LR = cpu_idle+0xe0/0xf0
[c0451f90] [c000970c] cpu_idle+0x68/0xf0 (unreliable)
[c0451fb0] [c0003f30] rest_init+0x5c/0x6c
[c0451fc0] [c03f07ac] start_kernel+0x27c/0x2e0
[c0451ff0] [00003438] 0x3438
Instruction dump:
7d2903a6 4bfffea8 38810008 7fa3eb78 38a00040 4bfe9c81 7fe6fb78 7fa4eb78
7c651b78 3c60c03c 38631774 480b7d2d <0fe00000> 38000001 901c2fb0 4bffff94
warning: `zebra' uses 32-bit capabilities (legacy support in use)
PHY: 0:03 - Link is Up - 1000/Full
PHY: 0:09 - Link is Up - 100/Full
PHY: 0:02 - Link is Up - 100/Full
PHY: 0:0f - Link is Up - 100/Full
PHY: 0:17 - Link is Up - 100/Full

When reverted I get a stable running system with no errors.

Which port happens to fail first varies, but one always does and then
the system almost always crashes soon after.

-- 
Len Sorensen
