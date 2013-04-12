From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from spin_lock_mutex
Date: Fri, 12 Apr 2013 16:01:04 +0200
Message-ID: <516813A0.1040300@acm.org>
References: <5166BDAA.3000603@acm.org> <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com> <5166F35B.1040200@acm.org> <20130411191409.GA9790@hmsreliant.think-freely.org> <5167A953.1020900@acm.org> <20130412113232.GA19966@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ingo Molnar <mingo@redhat.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:42897 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751183Ab3DLOBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Apr 2013 10:01:13 -0400
In-Reply-To: <20130412113232.GA19966@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/12/13 13:32, Neil Horman wrote:
> On Fri, Apr 12, 2013 at 08:27:31AM +0200, Bart Van Assche wrote:
>> On 04/11/13 21:14, Neil Horman wrote:
>>>      This resulted from my commit ca99ca14c which introduced a mutex_trylock
>>>      operation in a path that could execute in interrupt context.  When mutex
>>>      debugging is enabled, the above warns the user when we are in fact exectuting in
>>>      interrupt context.
>>>
>>>      I think this is a false positive however.  The check is intended to catch users
>>>      who might be issuing sleeping calls in irq context, but the use of mutex_trylock
>>>      here is guaranteed not to sleep.
>>>
>>>      We could fix this by replacing the DEBUG_LOCK_WARN_ON check in spin_lock_mutex
>>>      with a __might_sleep call in the appropriate parent mutex operations, but for
>>>      the sake of effiency (which It seems is why the check was put in the spin lock
>>>      code only when debug is enabled), lets split the spin_lock_mutex call into two
>>>      components, where the outer component does the debug checking.  Then
>>>      mutex_trylock can just call the inner part as its callable from irq context
>>>      safely.
>>
>> Sorry but I'm not yet convinced that it's safe to invoke
>> mutex_trylock() from IRQ context. Please have a look at the
>> implementation of mutex_set_owner(), which is invoked by
>> mutex_trylock(). mutex_set_owner() stores the value of the "current"
>> pointer into lock->owner. The value of "current" does not have a
>> meaning in IRQ context.
> 
> Thats irrelevant, at least as far as deadlock safety is concerned.  current will
> be set to the process that was running when we were interrupted, but it won't
> change during the course of the irq handler, which is all that matters.  The
> lock->owner field is used for optimistic spinning.  The worst that will happen
> is, if CONFIG_MUTEX_SPIN_ON_OWNER is configured, another process may wait on
> this mutex, spinning on the wrong task to release it (see mutex_spin_on_owner).
> Thats not efficient, but its not deadlock prone, and its not even that
> inefficient, when you consider that the critical path in the netpoll code is
> relatively short.  And using the trylock here is certainly preferable to the
> memory corruption that was possible previously.

I think there is another issue with invoking mutex_trylock() and mutex_unlock()
from IRQ context: as far as I can see if CONFIG_DEBUG_MUTEXES is disabled
__mutex_unlock_common_slowpath() uses spin_lock() to lock mutex.wait_lock and
hence invoking mutex_unlock() from both non-IRQ and IRQ context is not safe.
Any thoughts about that ?

With v2 of your patch and CONFIG_DEBUG_MUTEXES enabled I get the warning below:

------------[ cut here ]------------
WARNING: at kernel/mutex.c:313 __mutex_unlock_slowpath+0x157/0x160()
Pid: 181, comm: kworker/0:1H Tainted: G           O 3.9.0-rc6-debug+ #1
Call Trace:
<IRQ>  [<ffffffff8103c3ef>] warn_slowpath_common+0x7f/0xc0
[<ffffffff8103c44a>] warn_slowpath_null+0x1a/0x20
[<ffffffff81432047>] __mutex_unlock_slowpath+0x157/0x160
[<ffffffff8143205e>] mutex_unlock+0xe/0x10
[<ffffffff8136d031>] netpoll_poll_dev+0x111/0x9a0
[<ffffffff81345f32>] ? __alloc_skb+0x82/0x2a0
[<ffffffff8136dac5>] netpoll_send_skb_on_dev+0x205/0x3b0
[<ffffffff8136e00a>] netpoll_send_udp+0x28a/0x3a0
[<ffffffffa0524843>] ? write_msg+0x53/0x110 [netconsole]
[<ffffffffa05248bf>] write_msg+0xcf/0x110 [netconsole]
[<ffffffff8103d7f1>] call_console_drivers.constprop.16+0xa1/0x120
[<ffffffff8103e848>] console_unlock+0x3f8/0x450
[<ffffffff8103ecce>] vprintk_emit+0x1ee/0x510
[<ffffffff812d1f2c>] dev_vprintk_emit+0x5c/0x70
[<ffffffff810ff047>] ? mempool_free_slab+0x17/0x20
[<ffffffff810ff047>] ? mempool_free_slab+0x17/0x20
[<ffffffff81145922>] ? kmem_cache_free+0x1c2/0x1d0
[<ffffffff812d1f79>] dev_printk_emit+0x39/0x40
[<ffffffff811f6702>] ? blk_update_request+0x3d2/0x520
[<ffffffffa000a110>] ? device_block+0x10/0x10 [scsi_mod]
[<ffffffff812d2a7e>] __dev_printk+0x5e/0x90
[<ffffffff812d2e05>] dev_printk+0x45/0x50
[<ffffffffa000b5a7>] scsi_io_completion+0x277/0x6c0 [scsi_mod]
[<ffffffffa000107d>] scsi_finish_command+0xbd/0x120 [scsi_mod]
[<ffffffffa000b22f>] scsi_softirq_done+0x13f/0x160 [scsi_mod]
[<ffffffff811fd4c0>] blk_done_softirq+0x80/0xa0
[<ffffffff81044d61>] __do_softirq+0x101/0x280
[<ffffffff81045095>] irq_exit+0xb5/0xc0
[<ffffffff8143f2be>] smp_apic_timer_interrupt+0x6e/0x99
[<ffffffff8143e5ef>] apic_timer_interrupt+0x6f/0x80
<EOI>  [<ffffffff810986b2>] ? mark_held_locks+0xb2/0x130
[<ffffffff8143516a>] ? _raw_spin_unlock_irq+0x3a/0x50
[<ffffffff81435160>] ? _raw_spin_unlock_irq+0x30/0x50
[<ffffffff8120b074>] cfq_kick_queue+0x44/0x50
[<ffffffff81059e5d>] process_one_work+0x1fd/0x510
[<ffffffff81059df2>] ? process_one_work+0x192/0x510
[<ffffffff8105bccf>] worker_thread+0x10f/0x380
[<ffffffff8105bbc0>] ? busy_worker_rebind_fn+0xb0/0xb0
[<ffffffff8106209b>] kthread+0xdb/0xe0
[<ffffffff81061fc0>] ? kthread_create_on_node+0x140/0x140
[<ffffffff8143d95c>] ret_from_fork+0x7c/0xb0
[<ffffffff81061fc0>] ? kthread_create_on_node+0x140/0x140
---[ end trace dd7421d6dfb2c4ed ]---

Bart.
