From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 4/7] fs/proc/task_mmu.c: shift mm_access() from
 m_start() to proc_maps_open()
Date: Wed, 3 Dec 2014 16:14:33 +0200
Message-ID: <20141203141433.GA25683@node.dhcp.inet.fi>
References: <20140805194627.GA30693@redhat.com>
 <20140805194655.GA30728@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	David Howells <dhowells@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Sasha Levin <levinsasha928@gmail.com>,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
To: Oleg Nesterov <oleg@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140805194655.GA30728@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 05, 2014 at 09:46:55PM +0200, Oleg Nesterov wrote:
> A simple test-case from Kirill Shutemov
> 
> 	cat /proc/self/maps >/dev/null
> 	chmod +x /proc/self/net/packet
> 	exec /proc/self/net/packet
> 
> makes lockdep unhappy, cat/exec take seq_file->lock + cred_guard_mutex in
> the opposite order.

Oleg, I see it again with almost the same test-case:

	cat /proc/self/stack >/dev/null
	chmod +x /proc/self/net/packet
	exec /proc/self/net/packet

Looks like bunch of proc files were converted to use seq_file by Alexey
Dobriyan around the same time you've fixed the issue for /proc/pid/maps.

More generic test-case:

	find /proc/self/ -type f -exec dd if='{}' of=/dev/null bs=1 count=1 ';' 2>/dev/null
	chmod +x /proc/self/net/packet
	exec /proc/self/net/packet

David, any justification for allowing chmod +x for files under
/proc/pid/net?

[    2.042212] ======================================================
[    2.042930] [ INFO: possible circular locking dependency detected ]
[    2.043648] 3.18.0-rc7-00003-g3a18ca061311-dirty #237 Not tainted
[    2.044350] -------------------------------------------------------
[    2.045054] sh/94 is trying to acquire lock:
[    2.045546]  (&p->lock){+.+.+.}, at: [<ffffffff811e12fd>] seq_read+0x3d/0x3e0
[    2.045781] 
[    2.045781] but task is already holding lock:
[    2.045781]  (&sig->cred_guard_mutex){+.+.+.}, at: [<ffffffff811c0e3d>] prepare_bprm_creds+0x2d/0x90
[    2.045781] 
[    2.045781] which lock already depends on the new lock.
[    2.045781] 
[    2.045781] 
[    2.045781] the existing dependency chain (in reverse order) is:
[    2.045781] 
-> #1 (&sig->cred_guard_mutex){+.+.+.}:
[    2.045781]        [<ffffffff810a6e99>] __lock_acquire+0x4d9/0xd40
[    2.045781]        [<ffffffff810a7ff2>] lock_acquire+0xd2/0x2a0
[    2.045781]        [<ffffffff81849da6>] mutex_lock_killable_nested+0x66/0x460
[    2.045781]        [<ffffffff81229de4>] lock_trace+0x24/0x70
[    2.045781]        [<ffffffff81229e8f>] proc_pid_stack+0x5f/0xe0
[    2.045781]        [<ffffffff81227244>] proc_single_show+0x54/0xa0
[    2.045781]        [<ffffffff811e13a0>] seq_read+0xe0/0x3e0
[    2.045781]        [<ffffffff811b9377>] vfs_read+0x97/0x180
[    2.045781]        [<ffffffff811b9f5d>] SyS_read+0x4d/0xc0
[    2.045781]        [<ffffffff8184e492>] system_call_fastpath+0x12/0x17
[    2.045781] 
-> #0 (&p->lock){+.+.+.}:
[    2.045781]        [<ffffffff810a389f>] validate_chain.isra.36+0xfff/0x1400
[    2.045781]        [<ffffffff810a6e99>] __lock_acquire+0x4d9/0xd40
[    2.045781]        [<ffffffff810a7ff2>] lock_acquire+0xd2/0x2a0
[    2.045781]        [<ffffffff81849629>] mutex_lock_nested+0x69/0x3c0
[    2.045781]        [<ffffffff811e12fd>] seq_read+0x3d/0x3e0
[    2.045781]        [<ffffffff81226428>] proc_reg_read+0x48/0x70
[    2.045781]        [<ffffffff811b9377>] vfs_read+0x97/0x180
[    2.045781]        [<ffffffff811bf1a8>] kernel_read+0x48/0x60
[    2.045781]        [<ffffffff811bfb2c>] prepare_binprm+0xdc/0x180
[    2.045781]        [<ffffffff811c139a>] do_execve_common.isra.29+0x4fa/0x960
[    2.045781]        [<ffffffff811c1818>] do_execve+0x18/0x20
[    2.045781]        [<ffffffff811c1b05>] SyS_execve+0x25/0x30
[    2.045781]        [<ffffffff8184ea49>] stub_execve+0x69/0xa0
[    2.045781] 
[    2.045781] other info that might help us debug this:
[    2.045781] 
[    2.045781]  Possible unsafe locking scenario:
[    2.045781] 
[    2.045781]        CPU0                    CPU1
[    2.045781]        ----                    ----
[    2.045781]   lock(&sig->cred_guard_mutex);
[    2.045781]                                lock(&p->lock);
[    2.045781]                                lock(&sig->cred_guard_mutex);
[    2.045781]   lock(&p->lock);
[    2.045781] 
[    2.045781]  *** DEADLOCK ***
[    2.045781] 
[    2.045781] 1 lock held by sh/94:
[    2.045781]  #0:  (&sig->cred_guard_mutex){+.+.+.}, at: [<ffffffff811c0e3d>] prepare_bprm_creds+0x2d/0x90
[    2.045781] 
[    2.045781] stack backtrace:
[    2.045781] CPU: 0 PID: 94 Comm: sh Not tainted 3.18.0-rc7-00003-g3a18ca061311-dirty #237
[    2.045781] Hardware name: QEMU Standard PC (Q35 + ICH9, 2009), BIOS rel-1.7.5-0-ge51488c-20140602_164612-nilsson.home.kraxel.org 04/01/2014
[    2.045781]  ffffffff82a48d50 ffff88085427bad8 ffffffff81844a85 0000000000000cac
[    2.045781]  ffffffff82a654a0 ffff88085427bb28 ffffffff810a1b03 0000000000000000
[    2.045781]  ffff88085427bb68 ffff88085427bb28 ffff8808547f1500 ffff8808547f1c40
[    2.045781] Call Trace:
[    2.045781]  [<ffffffff81844a85>] dump_stack+0x4e/0x68
[    2.045781]  [<ffffffff810a1b03>] print_circular_bug+0x203/0x310
[    2.045781]  [<ffffffff810a389f>] validate_chain.isra.36+0xfff/0x1400
[    2.045781]  [<ffffffff8108fa76>] ? local_clock+0x16/0x30
[    2.045781]  [<ffffffff810a6e99>] __lock_acquire+0x4d9/0xd40
[    2.045781]  [<ffffffff810a7ff2>] lock_acquire+0xd2/0x2a0
[    2.045781]  [<ffffffff811e12fd>] ? seq_read+0x3d/0x3e0
[    2.045781]  [<ffffffff81849629>] mutex_lock_nested+0x69/0x3c0
[    2.045781]  [<ffffffff811e12fd>] ? seq_read+0x3d/0x3e0
[    2.045781]  [<ffffffff8108f9f8>] ? sched_clock_cpu+0x98/0xc0
[    2.045781]  [<ffffffff811e12fd>] ? seq_read+0x3d/0x3e0
[    2.045781]  [<ffffffff814050b9>] ? lockref_put_or_lock+0x29/0x40
[    2.045781]  [<ffffffff811e12fd>] seq_read+0x3d/0x3e0
[    2.045781]  [<ffffffff814050b9>] ? lockref_put_or_lock+0x29/0x40
[    2.045781]  [<ffffffff81226428>] proc_reg_read+0x48/0x70
[    2.045781]  [<ffffffff811b9377>] vfs_read+0x97/0x180
[    2.045781]  [<ffffffff811bf1a8>] kernel_read+0x48/0x60
[    2.045781]  [<ffffffff811bfb2c>] prepare_binprm+0xdc/0x180
[    2.045781]  [<ffffffff811c139a>] do_execve_common.isra.29+0x4fa/0x960
[    2.092142] tsc: Refined TSC clocksource calibration: 2693.484 MHz
[    2.045781]  [<ffffffff811c0fd3>] ? do_execve_common.isra.29+0x133/0x960
[    2.045781]  [<ffffffff8184f04d>] ? retint_swapgs+0xe/0x13
[    2.045781]  [<ffffffff811c1818>] do_execve+0x18/0x20
[    2.045781]  [<ffffffff811c1b05>] SyS_execve+0x25/0x30
[    2.045781]  [<ffffffff8184ea49>] stub_execve+0x69/0xa0
-- 
 Kirill A. Shutemov
