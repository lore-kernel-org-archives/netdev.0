From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: bpf/asan related lockup
Date: Fri, 4 Dec 2015 11:06:16 -0800
Message-ID: <20151204190614.GA45508@ast-mbp.thefacebook.com>
References: <20151204182333.GB29406@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dave Jones <davej@codemonkey.org.uk>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151204182333.GB29406@codemonkey.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 04, 2015 at 01:23:33PM -0500, Dave Jones wrote:
> Trinity had aparently created a bpf program that upset things greatly.
> I guess I need to find a way to make it record those somewhere for replaying later.
> 
> Alexei, any ideas ?
> 
> 	Dave
> 
> 
> NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [kworker/0:1:991]
> irq event stamp: 153214
> hardirqs last  enabled at (153213): [<ffffffffa0cb390c>] _raw_spin_unlock_irq+0x2c/0x50
> hardirqs last disabled at (153214): [<ffffffffa0cb35c9>] _raw_spin_lock_irq+0x19/0x80
> softirqs last  enabled at (153108): [<ffffffffa00b32f8>] __do_softirq+0x2b8/0x590
> softirqs last disabled at (153103): [<ffffffffa00b3805>] irq_exit+0xf5/0x100
> CPU: 0 PID: 991 Comm: kworker/0:1 Tainted: G      D W       4.4.0-rc3-think+ #5
> Workqueue: events bpf_prog_free_deferred
> task: ffff880464dab700 ti: ffff8803041d8000 task.ti: ffff8803041d8000
> RIP: 0010:[<ffffffffa02d6950>]  [<ffffffffa02d6950>] __asan_load4+0x0/0x70
> RSP: 0018:ffff8803041dfa08  EFLAGS: 00000202
> RAX: 0000000000000003 RBX: ffff880468be39a8 RCX: 0000000000000000
> RDX: dffffc0000000000 RSI: 0000000000000001 RDI: ffff880468be39c0
> RBP: ffff8803041dfa70 R08: 0000000000000000 R09: 0000000000000001
> R10: ffff8803041dfb8f R11: 0000000000000000 R12: ffff880468be39c0
> R13: 0000000000000001 R14: ffff8804689dff00 R15: 0000000000000001
> FS:  0000000000000000(0000) GS:ffff880468800000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00007faeedb04000 CR3: 0000000452548000 CR4: 00000000001406f0
> DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
> Stack:
>  ffffffffa018f2ce 00000000001dfec0 01ff880300000001 ffff8803041dfaf8
>  ffffffffa0076610 ffffffffa18895d8 ffff8804689dff08 0000000000000004
>  ffffffffa0076610 ffff8803041dfaf8 0000000000000001 ffffc90000171000
> Call Trace:
>  [<ffffffffa018f2ce>] ? smp_call_function_many+0x32e/0x410
>  [<ffffffffa0076610>] ? rbt_memtype_copy_nth_element+0xd0/0xd0
>  [<ffffffffa0076610>] ? rbt_memtype_copy_nth_element+0xd0/0xd0
>  [<ffffffffa018f3f7>] smp_call_function+0x47/0x80
>  [<ffffffffa0076610>] ? rbt_memtype_copy_nth_element+0xd0/0xd0
>  [<ffffffffa018f45f>] on_each_cpu+0x2f/0x90
>  [<ffffffffa0077a10>] flush_tlb_kernel_range+0xc0/0xd0
>  [<ffffffffa0077950>] ? flush_tlb_all+0x20/0x20
>  [<ffffffffa02b547f>] remove_vm_area+0xaf/0x100
>  [<ffffffffa02b5506>] __vunmap+0x36/0x180
>  [<ffffffffa02b56c5>] vfree+0x35/0xa0
>  [<ffffffffa0229867>] __bpf_prog_free+0x27/0x30
>  [<ffffffffa00a4da9>] bpf_jit_free+0x69/0x6e
>  [<ffffffffa022988f>] bpf_prog_free_deferred+0x1f/0x30
>  [<ffffffffa00d6d3a>] process_one_work+0x3fa/0xa10
>  [<ffffffffa00d6c74>] ? process_one_work+0x334/0xa10
>  [<ffffffffa00d6940>] ? pwq_dec_nr_in_flight+0x110/0x110
>  [<ffffffffa00d73d8>] worker_thread+0x88/0x6c0

hmm. may be set_memory_rw(ptr) followed by vfree(ptr) have a race
deep inside mm logic.
Both of them do flush_tlb_kernel_range()...
