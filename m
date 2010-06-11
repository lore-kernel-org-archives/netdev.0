From: Jens Axboe <jaxboe@fusionio.com>
Subject: Re: 2.6.35-rc2-git2: Reported regressions from 2.6.34
Date: Fri, 11 Jun 2010 11:07:38 +0200
Message-ID: <4C11FCDA.8070902@fusionio.com>
References: <Rlf_Qjov7bG.A.a8F.I8rDMB@chimera> <alpine.LFD.2.00.1006081814240.4506@i5.linux-foundation.org> <4C0F4872.7090909@fusionio.com> <20100611083249.GA11143@elte.hu> <4C11F661.3070604@fusionio.com> <20100611085520.GA20218@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Carl Worth <cworth@cworth.org>,
	Eric Anholt <eric@anholt.net>,
	Venkatesh Pallipadi <venki@google.com>,
	Dave Airlie <airlied@gmail.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	David H?rdeman <david@hardeman.nu>,
	Mauro Carvalho Chehab <mchehab@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux ACPI <linux-acpi@vger.kernel.org>,
	Linux PM List <linux-pm@lists.linux-foundation.org>,
	Linux SCSI List <linux-scsi@vger.kernel.org>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	DRI <dri-devel@lists.sourceforge.net>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20100611085520.GA20218@elte.hu>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2010-06-11 10:55, Ingo Molnar wrote:
> 
> * Jens Axboe <jaxboe@fusionio.com> wrote:
> 
>> On 2010-06-11 10:32, Ingo Molnar wrote:
>>>
>>> * Jens Axboe <jaxboe@fusionio.com> wrote:
>>>
>>>> On 2010-06-09 03:53, Linus Torvalds wrote:
>>>>>> Bug-Entry	: http://bugzilla.kernel.org/show_bug.cgi?id=16129
>>>>>> Subject	: BUG: using smp_processor_id() in preemptible [00000000] code: jbd2/sda2
>>>>>> Submitter	: Jan Kreuzer <kontrollator@gmx.de>
>>>>>> Date		: 2010-06-05 06:15 (4 days old)
>>>>>
>>>>> This seems to have been introduced by
>>>>>
>>>>> 	commit 7cbaef9c83e58bbd4bdd534b09052b6c5ec457d5
>>>>> 	Author: Ingo Molnar <mingo@elte.hu>
>>>>> 	Date:   Sat Nov 8 17:05:38 2008 +0100
>>>>>
>>>>> 	    sched: optimize sched_clock() a bit
>>>>>     
>>>>> 	    sched_clock() uses cycles_2_ns() needlessly - which is an irq-disabling
>>>>> 	    variant of __cycles_2_ns().
>>>>>     
>>>>> 	    Most of the time sched_clock() is called with irqs disabled already.
>>>>> 	    The few places that call it with irqs enabled need to be updated..
>>>>>     
>>>>> 	    Signed-off-by: Ingo Molnar <mingo@elte.hu>
>>>>>
>>>>> and this seems to be one of those calling cases that need to be updated..
>>>>>
>>>>> Ingo? The call trace is:
>>>>>
>>>>> 	BUG: using smp_processor_id() in preemptible [00000000] code: jbd2/sda2-8/337
>>>>> 	caller is native_sched_clock+0x3c/0x68
>>>>> 	Pid: 337, comm: jbd2/sda2-8 Not tainted 2.6.35-rc1jan+ #4
>>>>> 	Call Trace:
>>>>> 	[<ffffffff812362c5>] debug_smp_processor_id+0xc9/0xe4
>>>>> 	[<ffffffff8101059d>] native_sched_clock+0x3c/0x68
>>>>> 	[<ffffffff8101043d>] sched_clock+0x9/0xd
>>>>> 	[<ffffffff81212d7a>] blk_rq_init+0x97/0xa3
>>>>> 	[<ffffffff81214d71>] get_request+0x1c4/0x2d0
>>>>> 	[<ffffffff81214ea6>] get_request_wait+0x29/0x1a6
>>>>> 	[<ffffffff81215537>] __make_request+0x338/0x45b
>>>>> 	[<ffffffff812147c2>] generic_make_request+0x2bb/0x330
>>>>> 	[<ffffffff81214909>] submit_bio+0xd2/0xef
>>>>> 	[<ffffffff811413cb>] submit_bh+0xf4/0x116
>>>>> 	[<ffffffff81144853>] block_write_full_page_endio+0x89/0x96
>>>>> 	[<ffffffff81144875>] block_write_full_page+0x15/0x17
>>>>> 	[<ffffffff8119b00a>] ext4_writepage+0x356/0x36b
>>>>> 	[<ffffffff810e1f91>] __writepage+0x1a/0x39
>>>>> 	[<ffffffff810e32a6>] write_cache_pages+0x20d/0x346
>>>>> 	[<ffffffff810e3406>] generic_writepages+0x27/0x29
>>>>> 	[<ffffffff811ca279>] journal_submit_data_buffers+0x110/0x17d
>>>>> 	[<ffffffff811ca986>] jbd2_journal_commit_transaction+0x4cb/0x156d
>>>>> 	[<ffffffff811d0cba>] kjournald2+0x147/0x37a
>>>>>
>>>>> (from the bugzilla thing)
>>>>
>>>> This should be fixed by commit 28f4197e which was merged on friday.
>>>
>>> Hm, it's still not entirely fixed, as of 2.6.35-rc2-00131-g7908a9e. With some 
>>> configs i get bad spinlock warnings during bootup:
>>>
>>> [   28.968013] initcall net_olddevs_init+0x0/0x82 returned 0 after 93750 usecs
>>> [   28.972003] calling  b44_init+0x0/0x55 @ 1
>>> [   28.976009] bus: 'pci': add driver b44
>>> [   28.976374]  sda:
>>> [   28.978157] BUG: spinlock bad magic on CPU#1, async/0/117
>>> [   28.980000]  lock: 7e1c5bbc, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
>>> [   28.980000] Pid: 117, comm: async/0 Not tainted 2.6.35-rc2-tip-01092-g010e7ef-dirty #8183
>>> [   28.980000] Call Trace:
>>> [   28.980000]  [<41ba6d55>] ? printk+0x20/0x24
>>> [   28.980000]  [<4134b7b7>] spin_bug+0x7c/0x87
>>> [   28.980000]  [<4134b853>] do_raw_spin_lock+0x1e/0x123
>>> [   28.980000]  [<41ba92ca>] ? _raw_spin_lock_irqsave+0x12/0x20
>>> [   28.980000]  [<41ba92d2>] _raw_spin_lock_irqsave+0x1a/0x20
>>> [   28.980000]  [<4133476f>] blkiocg_update_io_add_stats+0x25/0xfb
>>> [   28.980000]  [<41335dae>] ? cfq_prio_tree_add+0xb1/0xc1
>>> [   28.980000]  [<41337bc7>] cfq_insert_request+0x8c/0x425
>>> [   28.980000]  [<41ba9271>] ? _raw_spin_unlock_irqrestore+0x17/0x23
>>> [   28.980000]  [<41ba9271>] ? _raw_spin_unlock_irqrestore+0x17/0x23
>>> [   28.980000]  [<41329225>] elv_insert+0x107/0x1a0
>>> [   28.980000]  [<41329354>] __elv_add_request+0x96/0x9d
>>> [   28.980000]  [<4132bb8c>] ? drive_stat_acct+0x9d/0xc6
>>> [   28.980000]  [<4132dd64>] __make_request+0x335/0x376
>>> [   28.980000]  [<4132c726>] generic_make_request+0x336/0x39d
>>> [   28.980000]  [<410ad422>] ? kmem_cache_alloc+0xa1/0x105
>>> [   28.980000]  [<41089285>] ? mempool_alloc_slab+0xe/0x10
>>> [   28.980000]  [<41089285>] ? mempool_alloc_slab+0xe/0x10
>>> [   28.980000]  [<41089285>] ? mempool_alloc_slab+0xe/0x10
>>> [   28.980000]  [<41089347>] ? mempool_alloc+0x57/0xe2
>>> [   28.980000]  [<4132c804>] submit_bio+0x77/0x8f
>>> [   28.980000]  [<410d2cbc>] ? bio_alloc_bioset+0x37/0x94
>>> [   28.980000]  [<410ceb90>] submit_bh+0xc3/0xe2
>>> [   28.980000]  [<410d1474>] block_read_full_page+0x249/0x259
>>> [   28.980000]  [<410d31fb>] ? blkdev_get_block+0x0/0xc6
>>> [   28.980000]  [<41087bfa>] ? add_to_page_cache_locked+0x94/0xb5
>>> [   28.980000]  [<410d3d92>] blkdev_readpage+0xf/0x11
>>> [   28.980000]  [<41088823>] do_read_cache_page+0x7d/0x11a
>>> [   28.980000]  [<410d3d83>] ? blkdev_readpage+0x0/0x11
>>> [   28.980000]  [<410888f4>] read_cache_page_async+0x16/0x1b
>>> [   28.980000]  [<41088904>] read_cache_page+0xb/0x12
>>> [   28.980000]  [<410e80e1>] read_dev_sector+0x2a/0x63
>>> [   28.980000]  [<410e92e8>] adfspart_check_ICS+0x2e/0x166
>>> [   28.980000]  [<41ba6d55>] ? printk+0x20/0x24
>>> [   28.980000]  [<410e8d23>] rescan_partitions+0x196/0x3e4
>>> [   28.980000]  [<41ba7dc7>] ? __mutex_unlock_slowpath+0x98/0x9f
>>> [   28.980000]  [<410e92ba>] ? adfspart_check_ICS+0x0/0x166
>>> [   28.980000]  [<410d4277>] __blkdev_get+0x1e7/0x292
>>> [   28.980000]  [<4133a201>] ? kobject_put+0x14/0x16
>>> [   28.980000]  [<410d432c>] blkdev_get+0xa/0xc
>>> [   28.980000]  [<410e81fb>] register_disk+0x94/0xe5
>>> [   28.980000]  [<413326c6>] ? blk_register_region+0x1b/0x20
>>> [   28.980000]  [<41332815>] add_disk+0x57/0x95
>>> [   28.980000]  [<41331fc6>] ? exact_match+0x0/0x8
>>> [   28.980000]  [<4133233f>] ? exact_lock+0x0/0x11
>>> [   28.980000]  [<41643848>] sd_probe_async+0x108/0x1be
>>> [   28.980000]  [<41048865>] async_thread+0xf5/0x1e6
>>> [   28.980000]  [<4102cbcb>] ? default_wake_function+0x0/0xd
>>> [   28.980000]  [<41048770>] ? async_thread+0x0/0x1e6
>>> [   28.980000]  [<410433df>] kthread+0x5f/0x64
>>> [   28.980000]  [<41043380>] ? kthread+0x0/0x64
>>> [   28.980000]  [<41002cc6>] kernel_thread_helper+0x6/0x10
>>> [   29.264071] async/1 used greatest stack depth: 2336 bytes left
>>> [   29.267020] bus: 'ssb': add driver b44
>>> [   29.267072] initcall b44_init+0x0/0x55 returned 0 after 281250 usecs
>>> [   29.267076] calling  init_nic+0x0/0x16 @ 1
>>>
>>> Caused by the same blkiocg_update_io_add_stats() function. Bootlog and config 
>>> attached. Reproducible on that sha1 and with that config.
>>
>> I think I see it, the internal CFQ blkg groups are not properly
>> initialized... Will send a patch shortly.
> 
> Cool - can test it with a short turnaround, the bug is easy to reproduce.

Thanks, I need to ensure what the best way to solve it is. The problem
is that if you have BLK_CGROUP set but don't enable the CFQ cgroup
stuff, then you end up calling the real update functions but CFQ has not
initialized them.

-- 
Jens Axboe

