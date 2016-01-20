From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: out of bounds in pptp_connect.
Date: Wed, 20 Jan 2016 18:08:09 -0500
Message-ID: <20160120230809.GA23182@codemonkey.org.uk>
References: <20160117170658.GA9973@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <peterz@infradead.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160117170658.GA9973@codemonkey.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 17, 2016 at 12:06:58PM -0500, Dave Jones wrote:
 > I've managed to trigger this a few times the last few days, on Linus' tree.
 > 
 > ==================================================================
 > BUG: KASAN: slab-out-of-bounds in pptp_connect+0xb7b/0xc70 [pptp] at addr ffff8800242da0d0
 > Read of size 2 by task trinity-c14/13664
 > =============================================================================
 > BUG kmalloc-8192 (Not tainted): kasan: bad access detected
 > -----------------------------------------------------------------------------
 > 
 > Disabling lock debugging due to kernel taint
 > INFO: Allocated in copy_thread_tls+0x6b3/0x8d0 age=5483091 cpu=1 pid=18329
 > 	___slab_alloc.constprop.66+0x4de/0x580
 > 	__slab_alloc.isra.63.constprop.65+0x48/0x80
 > 	__kmalloc_track_caller+0x2a2/0x2f0
 > 	kmemdup+0x20/0x50
 > 	copy_thread_tls+0x6b3/0x8d0
 > 	copy_process.part.40+0x3679/0x57b0
 > 	_do_fork+0x16c/0xba0
 > 	SyS_clone+0x19/0x20
 > 	tracesys_phase2+0x84/0x89
 > INFO: Freed in x86_pmu_event_init+0x477/0x550 age=5483145 cpu=1 pid=18329
 > 	__slab_free+0x18b/0x2b0
 > 	kfree+0x272/0x290
 > 	x86_pmu_event_init+0x477/0x550
 > 	perf_try_init_event+0x164/0x1c0
 > 	perf_event_alloc+0x1235/0x18c0
 > 	inherit_event.isra.88+0xd4/0x6c0
 > 	inherit_task_group.isra.90.part.91+0x68/0x200
 > 	perf_event_init_task+0x41f/0x830
 > 	copy_process.part.40+0x15d6/0x57b0
 > 	_do_fork+0x16c/0xba0
 > 	SyS_clone+0x19/0x20
 > 	tracesys_phase2+0x84/0x89

I'm now seeing different bug type, with similar traces.
Instead of an out of bounds, it's now a use-after-free, but
it's interesting that it's complaining about memory that used
to belong to perf again.  Could the bug be in perf ?

	Dave


BUG: KASAN: use-after-free in pptp_connect+0x19f/0x5e0 [pptp] at addr ffff8804632ba0d0
Read of size 2 by task trinity-c4/18013
=============================================================================
BUG kmalloc-2048 (Tainted: G        W      ): kasan: bad access detected
-----------------------------------------------------------------------------

INFO: Allocated in perf_event_alloc+0x72/0xd60 age=5653 cpu=0 pid=17555
        ___slab_alloc.constprop.71+0x523/0x5c0
        __slab_alloc.isra.67.constprop.70+0x48/0x80
        kmem_cache_alloc_trace+0x24c/0x2e0
        perf_event_alloc+0x72/0xd60
        inherit_event.isra.90+0x82/0x3a0
        inherit_task_group.isra.92.part.93+0x55/0x120
        perf_event_init_task+0x35a/0x530
        copy_process.part.40+0xb3d/0x2db0
        _do_fork+0x164/0x880
        SyS_clone+0x19/0x20
        tracesys_phase2+0x84/0x89
INFO: Freed in free_event_rcu+0x38/0x40 age=5635 cpu=0 pid=17555
        __slab_free+0x19e/0x2d0
        kfree+0x25c/0x280
        free_event_rcu+0x38/0x40
        rcu_process_callbacks+0xbac/0x1200
        __do_softirq+0x1a4/0x590
        irq_exit+0xf5/0x100
        smp_apic_timer_interrupt+0x5c/0x70
        apic_timer_interrupt+0x90/0xa0
        context_tracking_exit+0x1d/0x20
        enter_from_user_mode+0x1f/0x50
        syscall_trace_enter_phase1+0x1cb/0x260
        tracesys+0xd/0x44
INFO: Slab 0xffffea00118cae00 objects=13 used=9 fp=0xffff8804632bae68 flags=0x8000000000004080
INFO: Object 0xffff8804632b9bd8 @offset=7128 fp=0xffff8804632be618
