From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Deadlock after info soft-safe -> soft-unsafe lock order
 detected
Date: Mon, 5 Jan 2009 20:18:11 -0800
Message-ID: <20090105201811.00242be7.akpm@linux-foundation.org>
References: <c4e36d110901030404n377ac2bbg2ec74c5ddad35e4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Eric Dumazet <dada1@cosmosbay.com>
To: "Zdenek Kabelac" <zdenek.kabelac@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57113 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751625AbZAFESx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 23:18:53 -0500
In-Reply-To: <c4e36d110901030404n377ac2bbg2ec74c5ddad35e4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(cc netdev)

On Sat, 3 Jan 2009 13:04:54 +0100 "Zdenek Kabelac" <zdenek.kabelac@gmail.com> wrote:

> Hi
> 
> With todays kernel build I've got this trace which followed deadlock of my box.
> (T61, 2GB, inel graphics)

I'd be suspecting the percpu counter work in TCP?

> glxgears:3427 map pfn expected mapping type write-back for
> e2800000-e337c000, got uncached-minus
> glxgears:3427 freeing invalid memtype e2800000-e337c000
> 
> ======================================================
> [ INFO: soft-safe -> soft-unsafe lock order detected ]
> 2.6.28 #102
> ------------------------------------------------------
> firefox/3654 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
>  (&fbc->lock){--..}, at: [<ffffffff803aa578>] __percpu_counter_add+0x58/0x80
> 
> and this task is already holding:
>  (slock-AF_INET){-+..}, at: [<ffffffff804dd578>] tcp_close+0x198/0x4d0
> which would create a new lock dependency:
>  (slock-AF_INET){-+..} -> (&fbc->lock){--..}
> 
> but this new dependency connects a soft-irq-safe lock:
>  (slock-AF_INET){-+..}
> ... which became soft-irq-safe at:
>   [<ffffffffffffffff>] 0xffffffffffffffff
> 
> to a soft-irq-unsafe lock:
>  (&fbc->lock){--..}
> ... which became soft-irq-unsafe at:
> ...  [<ffffffff8026f4ec>] __lock_acquire+0x3ac/0x1280
>   [<ffffffff80270451>] lock_acquire+0x91/0xc0
>   [<ffffffff805376a1>] _spin_lock+0x31/0x70
>   [<ffffffff803aa578>] __percpu_counter_add+0x58/0x80
>   [<ffffffff802d9aae>] get_empty_filp+0x7e/0x1a0
>   [<ffffffff802e46d6>] path_lookup_open+0x36/0xd0
>   [<ffffffff802e5598>] do_filp_open+0xb8/0x930
>   [<ffffffff802d6548>] do_sys_open+0x78/0x100
>   [<ffffffff802d65fb>] sys_open+0x1b/0x20
>   [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>   [<ffffffffffffffff>] 0xffffffffffffffff
> 
> other info that might help us debug this:
> 
> 1 lock held by firefox/3654:
>  #0:  (slock-AF_INET){-+..}, at: [<ffffffff804dd578>] tcp_close+0x198/0x4d0
> 
> the soft-irq-safe lock's dependencies:
> -> (slock-AF_INET){-+..} ops: 15574 {
>    initial-use  at:
>                                        [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                        [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                        [<ffffffff80537716>]
> _spin_lock_bh+0x36/0x70
>                                        [<ffffffff804a1b85>]
> lock_sock_nested+0x45/0x120
>                                        [<ffffffff804dd3fe>] tcp_close+0x1e/0x4d0
>                                        [<ffffffff804fe1c2>]
> inet_release+0x42/0x70
>                                        [<ffffffff8049ef54>]
> sock_release+0x24/0x90
>                                        [<ffffffff8049efd2>] sock_close+0x12/0x30
>                                        [<ffffffff802d9d45>] __fput+0xd5/0x1f0
>                                        [<ffffffff802d9e7d>] fput+0x1d/0x30
>                                        [<ffffffff802d637b>] filp_close+0x5b/0x90
>                                        [<ffffffff802d6469>] sys_close+0xb9/0x120
>                                        [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                        [<ffffffffffffffff>] 0xffffffffffffffff
>    in-softirq-W at:
>                                        [<ffffffffffffffff>] 0xffffffffffffffff
>    hardirq-on-W at:
>                                        [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                        [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                        [<ffffffff80537716>]
> _spin_lock_bh+0x36/0x70
>                                        [<ffffffff804a1b85>]
> lock_sock_nested+0x45/0x120
>                                        [<ffffffff804dd3fe>] tcp_close+0x1e/0x4d0
>                                        [<ffffffff804fe1c2>]
> inet_release+0x42/0x70
>                                        [<ffffffff8049ef54>]
> sock_release+0x24/0x90
>                                        [<ffffffff8049efd2>] sock_close+0x12/0x30
>                                        [<ffffffff802d9d45>] __fput+0xd5/0x1f0
>                                        [<ffffffff802d9e7d>] fput+0x1d/0x30
>                                        [<ffffffff802d637b>] filp_close+0x5b/0x90
>                                        [<ffffffff802d6469>] sys_close+0xb9/0x120
>                                        [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                        [<ffffffffffffffff>] 0xffffffffffffffff
>  }
>  ... key      at: [<ffffffff810400b0>] af_family_slock_keys+0x10/0x120
>  -> (&list->lock){-+..} ops: 17288 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                          [<ffffffff804a5476>]
> skb_queue_tail+0x26/0x60
>                                          [<ffffffff804c3f9b>]
> netlink_broadcast+0x30b/0x480
>                                          [<ffffffff8039f22a>]
> kobject_uevent_env+0x3ba/0x5c0
>                                          [<ffffffff8039f43b>]
> kobject_uevent+0xb/0x10
>                                          [<ffffffff80279cea>]
> mod_sysfs_setup+0xba/0xd0
>                                          [<ffffffff8027b4f1>]
> load_module+0x17f1/0x1bf0
>                                          [<ffffffff8027b95f>]
> sys_init_module+0x6f/0x1e0
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     hardirq-on-W at:
>                                          [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537716>]
> _spin_lock_bh+0x36/0x70
>                                          [<ffffffff804f3c28>]
> udp_poll+0x88/0x170
>                                          [<ffffffff8049db58>]
> sock_poll+0x18/0x20
>                                          [<ffffffff802e832c>]
> do_sys_poll+0x21c/0x4d0
>                                          [<ffffffff802e87d7>]
> sys_poll+0x77/0x110
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffff8103ff30>] __key.24203+0x0/0x8
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  -> (&q->lock){++..} ops: 86318651 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff8053778f>]
> _spin_lock_irq+0x3f/0x90
>                                          [<ffffffff80534b98>]
> wait_for_common+0x48/0x1b0
>                                          [<ffffffff80534d98>]
> wait_for_completion+0x18/0x20
>                                          [<ffffffff8025cc79>]
> kthread_create+0xa9/0x100
>                                          [<ffffffff805315b8>]
> migration_call+0x3aa/0x55b
>                                          [<ffffffff806f0f01>]
> migration_init+0x25/0x5b
>                                          [<ffffffff8020903c>] _stext+0x3c/0x170
>                                          [<ffffffff806da5c5>]
> kernel_init+0x70/0x194
>                                          [<ffffffff8020d7ba>] child_rip+0xa/0x20
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-hardirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffff80967be8>] __key.16629+0x0/0x18
>   -> (&rq->lock){++..} ops: 7667315 {
>      initial-use  at:
>                                            [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                            [<ffffffff8023a746>]
> rq_attach_root+0x26/0xf0
>                                            [<ffffffff806f0d5f>]
> sched_init+0x271/0x3ee
>                                            [<ffffffff806daafc>]
> start_kernel+0x171/0x419
>                                            [<ffffffff806da299>]
> x86_64_start_reservations+0x99/0xb9
>                                            [<ffffffff806da3b4>]
> x86_64_start_kernel+0xd8/0xdf
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-hardirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-softirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>    }
>    ... key      at: [<ffffffff80922598>] __key.43526+0x0/0x8
>    -> (&vec->lock){.+..} ops: 106044 {
>       initial-use  at:
>                                              [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                              [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                              [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                              [<ffffffff802a6403>]
> cpupri_set+0xd3/0x170
>                                              [<ffffffff80238b24>]
> rq_online_rt+0x44/0x80
>                                              [<ffffffff80235d3e>]
> set_rq_online+0x5e/0x80
>                                              [<ffffffff8023a7bb>]
> rq_attach_root+0x9b/0xf0
>                                              [<ffffffff806f0d5f>]
> sched_init+0x271/0x3ee
>                                              [<ffffffff806daafc>]
> start_kernel+0x171/0x419
>                                              [<ffffffff806da299>]
> x86_64_start_reservations+0x99/0xb9
>                                              [<ffffffff806da3b4>]
> x86_64_start_kernel+0xd8/0xdf
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>       in-softirq-W at:
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>     }
>     ... key      at: [<ffffffff81020d08>] __key.13652+0x0/0x38
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff802a6403>] cpupri_set+0xd3/0x170
>    [<ffffffff80238b24>] rq_online_rt+0x44/0x80
>    [<ffffffff80235d3e>] set_rq_online+0x5e/0x80
>    [<ffffffff8023a7bb>] rq_attach_root+0x9b/0xf0
>    [<ffffffff806f0d5f>] sched_init+0x271/0x3ee
>    [<ffffffff806daafc>] start_kernel+0x171/0x419
>    [<ffffffff806da299>] x86_64_start_reservations+0x99/0xb9
>    [<ffffffff806da3b4>] x86_64_start_kernel+0xd8/0xdf
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    -> (&rt_b->rt_runtime_lock){....} ops: 926 {
>       initial-use  at:
>                                              [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                              [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                              [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                              [<ffffffff80238f2c>]
> enqueue_task_rt+0x1cc/0x240
>                                              [<ffffffff80234fd0>]
> enqueue_task+0x50/0x60
>                                              [<ffffffff802350e2>]
> activate_task+0x22/0x30
>                                              [<ffffffff80239e18>]
> try_to_wake_up+0x248/0x2f0
>                                              [<ffffffff80239ef0>]
> wake_up_process+0x10/0x20
>                                              [<ffffffff8053126d>]
> migration_call+0x5f/0x55b
>                                              [<ffffffff806f0f1f>]
> migration_init+0x43/0x5b
>                                              [<ffffffff8020903c>]
> _stext+0x3c/0x170
>                                              [<ffffffff806da5c5>]
> kernel_init+0x70/0x194
>                                              [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>     }
>     ... key      at: [<ffffffff809225a0>] __key.35059+0x0/0x8
>     -> (&cpu_base->lock){++..} ops: 7379273 {
>        initial-use  at:
>                                                [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                                [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                                [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                                [<ffffffff8026040c>]
> lock_hrtimer_base+0x2c/0x60
>                                                [<ffffffff802608ba>]
> hrtimer_start_range_ns+0x3a/0x1b0
>                                                [<ffffffff80238f7f>]
> enqueue_task_rt+0x21f/0x240
>                                                [<ffffffff80234fd0>]
> enqueue_task+0x50/0x60
>                                                [<ffffffff802350e2>]
> activate_task+0x22/0x30
>                                                [<ffffffff80239e18>]
> try_to_wake_up+0x248/0x2f0
>                                                [<ffffffff80239ef0>]
> wake_up_process+0x10/0x20
>                                                [<ffffffff8053126d>]
> migration_call+0x5f/0x55b
>                                                [<ffffffff806f0f1f>]
> migration_init+0x43/0x5b
>                                                [<ffffffff8020903c>]
> _stext+0x3c/0x170
>                                                [<ffffffff806da5c5>]
> kernel_init+0x70/0x194
>                                                [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-hardirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-softirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>      }
>      ... key      at: [<ffffffff80967c30>] __key.18600+0x0/0x8
>     ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff8026040c>] lock_hrtimer_base+0x2c/0x60
>    [<ffffffff802608ba>] hrtimer_start_range_ns+0x3a/0x1b0
>    [<ffffffff80238f7f>] enqueue_task_rt+0x21f/0x240
>    [<ffffffff80234fd0>] enqueue_task+0x50/0x60
>    [<ffffffff802350e2>] activate_task+0x22/0x30
>    [<ffffffff80239e18>] try_to_wake_up+0x248/0x2f0
>    [<ffffffff80239ef0>] wake_up_process+0x10/0x20
>    [<ffffffff8053126d>] migration_call+0x5f/0x55b
>    [<ffffffff806f0f1f>] migration_init+0x43/0x5b
>    [<ffffffff8020903c>] _stext+0x3c/0x170
>    [<ffffffff806da5c5>] kernel_init+0x70/0x194
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     -> (&rt_rq->rt_runtime_lock){++..} ops: 54877 {
>        initial-use  at:
>                                                [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                                [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                                [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                                [<ffffffff80240eaa>]
> update_curr_rt+0x10a/0x180
>                                                [<ffffffff8024104f>]
> dequeue_task_rt+0x1f/0x70
>                                                [<ffffffff80235076>]
> dequeue_task+0x96/0xe0
>                                                [<ffffffff80235112>]
> deactivate_task+0x22/0x30
>                                                [<ffffffff80534440>]
> thread_return+0x14a/0x6fa
>                                                [<ffffffff8023f990>]
> migration_thread+0x1e0/0x2d0
>                                                [<ffffffff8025c9f9>]
> kthread+0x49/0x90
>                                                [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-hardirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-softirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>      }
>      ... key      at: [<ffffffff809225a8>] __key.43508+0x0/0x8
>     ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff802381f9>] __enable_runtime+0x39/0x80
>    [<ffffffff80238b08>] rq_online_rt+0x28/0x80
>    [<ffffffff80235d3e>] set_rq_online+0x5e/0x80
>    [<ffffffff805312a9>] migration_call+0x9b/0x55b
>    [<ffffffff8053ac85>] notifier_call_chain+0x65/0xa0
>    [<ffffffff802618e1>] raw_notifier_call_chain+0x11/0x20
>    [<ffffffff8053191c>] _cpu_up+0x101/0x12d
>    [<ffffffff805319bc>] cpu_up+0x74/0x7a
>    [<ffffffff806da625>] kernel_init+0xd0/0x194
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff80238f2c>] enqueue_task_rt+0x1cc/0x240
>    [<ffffffff80234fd0>] enqueue_task+0x50/0x60
>    [<ffffffff802350e2>] activate_task+0x22/0x30
>    [<ffffffff80239e18>] try_to_wake_up+0x248/0x2f0
>    [<ffffffff80239ef0>] wake_up_process+0x10/0x20
>    [<ffffffff8053126d>] migration_call+0x5f/0x55b
>    [<ffffffff806f0f1f>] migration_init+0x43/0x5b
>    [<ffffffff8020903c>] _stext+0x3c/0x170
>    [<ffffffff806da5c5>] kernel_init+0x70/0x194
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff80240eaa>] update_curr_rt+0x10a/0x180
>    [<ffffffff8024104f>] dequeue_task_rt+0x1f/0x70
>    [<ffffffff80235076>] dequeue_task+0x96/0xe0
>    [<ffffffff80235112>] deactivate_task+0x22/0x30
>    [<ffffffff80534440>] thread_return+0x14a/0x6fa
>    [<ffffffff8023f990>] migration_thread+0x1e0/0x2d0
>    [<ffffffff8025c9f9>] kthread+0x49/0x90
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    -> (&rq->lock/1){.+..} ops: 54954 {
>       initial-use  at:
>                                              [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                              [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                              [<ffffffff8053762f>]
> _spin_lock_nested+0x2f/0x70
>                                              [<ffffffff80239ae2>]
> double_rq_lock+0x32/0x90
>                                              [<ffffffff8023edef>]
> __migrate_task+0x6f/0x120
>                                              [<ffffffff8023f85d>]
> migration_thread+0xad/0x2d0
>                                              [<ffffffff8025c9f9>]
> kthread+0x49/0x90
>                                              [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>       in-softirq-W at:
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>     }
>     ... key      at: [<ffffffff80922599>] __key.43526+0x1/0x8
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff8053762f>] _spin_lock_nested+0x2f/0x70
>    [<ffffffff80239ae2>] double_rq_lock+0x32/0x90
>    [<ffffffff8023edef>] __migrate_task+0x6f/0x120
>    [<ffffffff8023f85d>] migration_thread+0xad/0x2d0
>    [<ffffffff8025c9f9>] kthread+0x49/0x90
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    -> (latency_lock){++..} ops: 1267263 {
>       initial-use  at:
>                                              [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                              [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                              [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                              [<ffffffff8029c932>]
> clear_all_latency_tracing+0x22/0x60
>                                              [<ffffffff80243d93>]
> copy_process+0xf73/0x13d0
>                                              [<ffffffff8024427b>]
> do_fork+0x8b/0x440
>                                              [<ffffffff8020a433>]
> sys_clone+0x23/0x30
>                                              [<ffffffff8020cac3>]
> stub_clone+0x13/0x20
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>       in-hardirq-W at:
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>       in-softirq-W at:
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>     }
>     ... key      at: [<ffffffff806804b8>] latency_lock+0x18/0x40
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff80536ab9>] account_scheduler_latency+0x89/0x390
>    [<ffffffff8023db24>] enqueue_task_fair+0x234/0x310
>    [<ffffffff80234fd0>] enqueue_task+0x50/0x60
>    [<ffffffff802350e2>] activate_task+0x22/0x30
>    [<ffffffff80239e18>] try_to_wake_up+0x248/0x2f0
>    [<ffffffff80239ecd>] default_wake_function+0xd/0x10
>    [<ffffffff8023586a>] __wake_up_common+0x5a/0x90
>    [<ffffffff802358b3>] __wake_up_locked+0x13/0x20
>    [<ffffffff80309af0>] ep_poll_callback+0x90/0x120
>    [<ffffffff8023586a>] __wake_up_common+0x5a/0x90
>    [<ffffffff8023677a>] __wake_up_sync+0x4a/0x70
>    [<ffffffff804a1dbe>] sock_def_readable+0x3e/0x70
>    [<ffffffff80519acd>] unix_stream_sendmsg+0x1ed/0x3b0
>    [<ffffffff8049e64a>] sock_aio_write+0x17a/0x190
>    [<ffffffff802d8421>] do_sync_write+0xf1/0x140
>    [<ffffffff802d8bb9>] vfs_write+0x179/0x190
>    [<ffffffff802d8cc0>] sys_write+0x50/0x90
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff80236934>] task_rq_lock+0x54/0xa0
>    [<ffffffff80239c51>] try_to_wake_up+0x81/0x2f0
>    [<ffffffff80239ecd>] default_wake_function+0xd/0x10
>    [<ffffffff8023586a>] __wake_up_common+0x5a/0x90
>    [<ffffffff8023670f>] complete+0x3f/0x60
>    [<ffffffff8025c9d7>] kthread+0x27/0x90
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   -> (&ep->lock){....} ops: 4470 {
>      initial-use  at:
>                                            [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                            [<ffffffff8030a93f>]
> sys_epoll_ctl+0x41f/0x540
>                                            [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>    }
>    ... key      at: [<ffffffff81023d10>] __key.21125+0x0/0x10
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff80236934>] task_rq_lock+0x54/0xa0
>    [<ffffffff80239c51>] try_to_wake_up+0x81/0x2f0
>    [<ffffffff80239ecd>] default_wake_function+0xd/0x10
>    [<ffffffff8023586a>] __wake_up_common+0x5a/0x90
>    [<ffffffff802358b3>] __wake_up_locked+0x13/0x20
>    [<ffffffff80309af0>] ep_poll_callback+0x90/0x120
>    [<ffffffff8023586a>] __wake_up_common+0x5a/0x90
>    [<ffffffff8023677a>] __wake_up_sync+0x4a/0x70
>    [<ffffffff804a1dbe>] sock_def_readable+0x3e/0x70
>    [<ffffffff805198ca>] unix_stream_connect+0x47a/0x490
>    [<ffffffff8049f8e8>] sys_connect+0xb8/0xd0
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff80309a84>] ep_poll_callback+0x24/0x120
>    [<ffffffff8023586a>] __wake_up_common+0x5a/0x90
>    [<ffffffff8023677a>] __wake_up_sync+0x4a/0x70
>    [<ffffffff804a1dbe>] sock_def_readable+0x3e/0x70
>    [<ffffffff805198ca>] unix_stream_connect+0x47a/0x490
>    [<ffffffff8049f8e8>] sys_connect+0xb8/0xd0
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  -> (tcp_lock){-+..} ops: 5777 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537966>]
> _write_lock_bh+0x36/0x70
>                                          [<ffffffffa0460671>]
> tcp_packet+0x61/0x13c0 [nf_conntrack]
>                                          [<ffffffffa045bfed>]
> nf_conntrack_in+0x30d/0x970 [nf_conntrack]
>                                          [<ffffffffa0482566>]
> ipv4_conntrack_local+0x56/0x80 [nf_conntrack_ipv4]
>                                          [<ffffffff804c7ab7>]
> nf_iterate+0x67/0xa0
>                                          [<ffffffff804c7bc3>]
> nf_hook_slow+0xd3/0x120
>                                          [<ffffffff804d379f>]
> __ip_local_out+0x9f/0xb0
>                                          [<ffffffff804d37c1>]
> ip_local_out+0x11/0x30
>                                          [<ffffffff804d4054>]
> ip_queue_xmit+0x1e4/0x3d0
>                                          [<ffffffff804e891b>]
> tcp_transmit_skb+0x4cb/0x750
>                                          [<ffffffff804ea60c>]
> tcp_connect+0x36c/0x470
>                                          [<ffffffff804ef3b9>]
> tcp_v4_connect+0x429/0x500
>                                          [<ffffffff804fd137>]
> inet_stream_connect+0x227/0x2c0
>                                          [<ffffffff8049f8e8>]
> sys_connect+0xb8/0xd0
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     hardirq-on-W at:
>                                          [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537966>]
> _write_lock_bh+0x36/0x70
>                                          [<ffffffffa0460671>]
> tcp_packet+0x61/0x13c0 [nf_conntrack]
>                                          [<ffffffffa045bfed>]
> nf_conntrack_in+0x30d/0x970 [nf_conntrack]
>                                          [<ffffffffa0482566>]
> ipv4_conntrack_local+0x56/0x80 [nf_conntrack_ipv4]
>                                          [<ffffffff804c7ab7>]
> nf_iterate+0x67/0xa0
>                                          [<ffffffff804c7bc3>]
> nf_hook_slow+0xd3/0x120
>                                          [<ffffffff804d379f>]
> __ip_local_out+0x9f/0xb0
>                                          [<ffffffff804d37c1>]
> ip_local_out+0x11/0x30
>                                          [<ffffffff804d4054>]
> ip_queue_xmit+0x1e4/0x3d0
>                                          [<ffffffff804e891b>]
> tcp_transmit_skb+0x4cb/0x750
>                                          [<ffffffff804ea60c>]
> tcp_connect+0x36c/0x470
>                                          [<ffffffff804ef3b9>]
> tcp_v4_connect+0x429/0x500
>                                          [<ffffffff804fd137>]
> inet_stream_connect+0x227/0x2c0
>                                          [<ffffffff8049f8e8>]
> sys_connect+0xb8/0xd0
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffffa046e2b8>]
> tcp_lock+0x18/0xffffffffffff44a6 [nf_conntrack]
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  -> (nf_conntrack_lock){-+..} ops: 6826 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537716>]
> _spin_lock_bh+0x36/0x70
>                                          [<ffffffffa045c262>]
> nf_conntrack_in+0x582/0x970 [nf_conntrack]
>                                          [<ffffffffa0482566>]
> ipv4_conntrack_local+0x56/0x80 [nf_conntrack_ipv4]
>                                          [<ffffffff804c7ab7>]
> nf_iterate+0x67/0xa0
>                                          [<ffffffff804c7bc3>]
> nf_hook_slow+0xd3/0x120
>                                          [<ffffffff804d379f>]
> __ip_local_out+0x9f/0xb0
>                                          [<ffffffff804d37c1>]
> ip_local_out+0x11/0x30
>                                          [<ffffffff804d3ac8>]
> ip_push_pending_frames+0x2e8/0x420
>                                          [<ffffffff804f408f>]
> udp_push_pending_frames+0x13f/0x3d0
>                                          [<ffffffff804f50b6>]
> udp_sendmsg+0x316/0x750
>                                          [<ffffffff804fc865>]
> inet_sendmsg+0x45/0x80
>                                          [<ffffffff8049ff17>]
> sock_sendmsg+0x107/0x130
>                                          [<ffffffff804a00c9>]
> sys_sendmsg+0x189/0x320
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     hardirq-on-W at:
>                                          [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537716>]
> _spin_lock_bh+0x36/0x70
>                                          [<ffffffffa045c262>]
> nf_conntrack_in+0x582/0x970 [nf_conntrack]
>                                          [<ffffffffa0482566>]
> ipv4_conntrack_local+0x56/0x80 [nf_conntrack_ipv4]
>                                          [<ffffffff804c7ab7>]
> nf_iterate+0x67/0xa0
>                                          [<ffffffff804c7bc3>]
> nf_hook_slow+0xd3/0x120
>                                          [<ffffffff804d379f>]
> __ip_local_out+0x9f/0xb0
>                                          [<ffffffff804d37c1>]
> ip_local_out+0x11/0x30
>                                          [<ffffffff804d3ac8>]
> ip_push_pending_frames+0x2e8/0x420
>                                          [<ffffffff804f408f>]
> udp_push_pending_frames+0x13f/0x3d0
>                                          [<ffffffff804f50b6>]
> udp_sendmsg+0x316/0x750
>                                          [<ffffffff804fc865>]
> inet_sendmsg+0x45/0x80
>                                          [<ffffffff8049ff17>]
> sock_sendmsg+0x107/0x130
>                                          [<ffffffff804a00c9>]
> sys_sendmsg+0x189/0x320
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffffa046dcd8>]
> nf_conntrack_lock+0x18/0xffffffffffff4a86 [nf_conntrack]
>   -> (&base->lock){++..} ops: 827369 {
>      initial-use  at:
>                                            [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                            [<ffffffff802505e6>]
> lock_timer_base+0x36/0x70
>                                            [<ffffffff802507ba>]
> __mod_timer+0x3a/0xe0
>                                            [<ffffffff8025092b>]
> mod_timer+0x4b/0x60
>                                            [<ffffffff806fe0e4>]
> con_init+0x239/0x23e
>                                            [<ffffffff806fd5ef>]
> console_init+0x22/0x36
>                                            [<ffffffff806dabf0>]
> start_kernel+0x265/0x419
>                                            [<ffffffff806da299>]
> x86_64_start_reservations+0x99/0xb9
>                                            [<ffffffff806da3b4>]
> x86_64_start_kernel+0xd8/0xdf
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-hardirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-softirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>    }
>    ... key      at: [<ffffffff80967498>] __key.21376+0x0/0x8
>   ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff802505e6>] lock_timer_base+0x36/0x70
>    [<ffffffff802507ba>] __mod_timer+0x3a/0xe0
>    [<ffffffffa045b435>] __nf_conntrack_confirm+0x2a5/0x3a0 [nf_conntrack]
>    [<ffffffffa04826d5>] ipv4_confirm+0x125/0x140 [nf_conntrack_ipv4]
>    [<ffffffff804c7ab7>] nf_iterate+0x67/0xa0
>    [<ffffffff804c7bc3>] nf_hook_slow+0xd3/0x120
>    [<ffffffff804d4b50>] ip_mc_output+0xe0/0x210
>    [<ffffffff804d37d0>] ip_local_out+0x20/0x30
>    [<ffffffff804d3ac8>] ip_push_pending_frames+0x2e8/0x420
>    [<ffffffff804f408f>] udp_push_pending_frames+0x13f/0x3d0
>    [<ffffffff804f50b6>] udp_sendmsg+0x316/0x750
>    [<ffffffff804fc865>] inet_sendmsg+0x45/0x80
>    [<ffffffff8049ff17>] sock_sendmsg+0x107/0x130
>    [<ffffffff804a00c9>] sys_sendmsg+0x189/0x320
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  -> (&tcp_hashinfo.bhash[i].lock){-+..} ops: 487 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                          [<ffffffff804d9aaa>]
> inet_csk_get_port+0x1ba/0x2d0
>                                          [<ffffffff804fd2f6>]
> inet_bind+0x126/0x200
>                                          [<ffffffff8049f9b0>] sys_bind+0xb0/0xd0
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     hardirq-on-W at:
>                                          [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                          [<ffffffff804d9aaa>]
> inet_csk_get_port+0x1ba/0x2d0
>                                          [<ffffffff804fd2f6>]
> inet_bind+0x126/0x200
>                                          [<ffffffff8049f9b0>] sys_bind+0xb0/0xd0
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffff81042560>] __key.43256+0x0/0x8
>   -> (&hashinfo->ehash_locks[i]){-+..} ops: 332 {
>      initial-use  at:
>                                            [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                            [<ffffffff804d7cf0>]
> __inet_hash_nolisten+0xe0/0x140
>                                            [<ffffffff804d7807>]
> __inet_hash_connect+0x2d7/0x300
>                                            [<ffffffff804d787a>]
> inet_hash_connect+0x4a/0x60
>                                            [<ffffffff804ef21f>]
> tcp_v4_connect+0x28f/0x500
>                                            [<ffffffff804fd137>]
> inet_stream_connect+0x227/0x2c0
>                                            [<ffffffff8049f8e8>]
> sys_connect+0xb8/0xd0
>                                            [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-softirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      hardirq-on-W at:
>                                            [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                            [<ffffffff804d7cf0>]
> __inet_hash_nolisten+0xe0/0x140
>                                            [<ffffffff804d7807>]
> __inet_hash_connect+0x2d7/0x300
>                                            [<ffffffff804d787a>]
> inet_hash_connect+0x4a/0x60
>                                            [<ffffffff804ef21f>]
> tcp_v4_connect+0x28f/0x500
>                                            [<ffffffff804fd137>]
> inet_stream_connect+0x227/0x2c0
>                                            [<ffffffff8049f8e8>]
> sys_connect+0xb8/0xd0
>                                            [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>    }
>    ... key      at: [<ffffffff81042568>] __key.36312+0x0/0x18
>   ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff804d7cf0>] __inet_hash_nolisten+0xe0/0x140
>    [<ffffffff804d7807>] __inet_hash_connect+0x2d7/0x300
>    [<ffffffff804d787a>] inet_hash_connect+0x4a/0x60
>    [<ffffffff804ef21f>] tcp_v4_connect+0x28f/0x500
>    [<ffffffff804fd137>] inet_stream_connect+0x227/0x2c0
>    [<ffffffff8049f8e8>] sys_connect+0xb8/0xd0
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   -> (&n->list_lock){++..} ops: 142231 {
>      initial-use  at:
>                                            [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                            [<ffffffff802d1381>]
> add_partial+0x21/0x80
>                                            [<ffffffff802d43e1>]
> __slab_free+0x191/0x350
>                                            [<ffffffff802d5bd9>]
> kmem_cache_free+0x99/0xf0
>                                            [<ffffffff803cf44e>]
> acpi_os_release_object+0x9/0xd
>                                            [<ffffffff803e89a7>]
> acpi_ps_free_op+0x61/0x65
>                                            [<ffffffff803e865a>]
> acpi_ps_delete_parse_tree+0x3e/0x5c
>                                            [<ffffffff803e7984>]
> acpi_ps_complete_this_op+0x179/0x189
>                                            [<ffffffff803e79bd>]
> acpi_ps_complete_op+0x29/0x28a
>                                            [<ffffffff803e83cf>]
> acpi_ps_parse_loop+0x7b1/0x93e
>                                            [<ffffffff803e7449>]
> acpi_ps_parse_aml+0xee/0x3c0
>                                            [<ffffffff803e643d>]
> acpi_ns_one_complete_parse+0x131/0x14c
>                                            [<ffffffff803e64a1>]
> acpi_ns_parse_table+0x49/0x8c
>                                            [<ffffffff803e2eae>]
> acpi_ns_load_table+0x7a/0x114
>                                            [<ffffffff803ea77e>]
> acpi_load_tables+0xf5/0x1e4
>                                            [<ffffffff806fbcbe>]
> acpi_early_init+0x60/0xf5
>                                            [<ffffffff806daced>]
> start_kernel+0x362/0x419
>                                            [<ffffffff806da299>]
> x86_64_start_reservations+0x99/0xb9
>                                            [<ffffffff806da3b4>]
> x86_64_start_kernel+0xd8/0xdf
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-hardirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-softirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>    }
>    ... key      at: [<ffffffff81022f04>] __key.23338+0x0/0xc
>   ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff802d1381>] add_partial+0x21/0x80
>    [<ffffffff802d43e1>] __slab_free+0x191/0x350
>    [<ffffffff802d5bd9>] kmem_cache_free+0x99/0xf0
>    [<ffffffff804d7419>] inet_bind_bucket_destroy+0x29/0x30
>    [<ffffffff804d74a7>] inet_put_port+0x87/0xb0
>    [<ffffffff804ef755>] tcp_v4_destroy_sock+0x205/0x260
>    [<ffffffff804d8d12>] inet_csk_destroy_sock+0x52/0x140
>    [<ffffffff804dd7ae>] tcp_close+0x3ce/0x4d0
>    [<ffffffff804fe1c2>] inet_release+0x42/0x70
>    [<ffffffff8049ef54>] sock_release+0x24/0x90
>    [<ffffffff8049efd2>] sock_close+0x12/0x30
>    [<ffffffff802d9d45>] __fput+0xd5/0x1f0
>    [<ffffffff802d9e7d>] fput+0x1d/0x30
>    [<ffffffff802d637b>] filp_close+0x5b/0x90
>    [<ffffffff802d6469>] sys_close+0xb9/0x120
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff804d746f>] inet_put_port+0x4f/0xb0
>    [<ffffffff804ef755>] tcp_v4_destroy_sock+0x205/0x260
>    [<ffffffff804d8d12>] inet_csk_destroy_sock+0x52/0x140
>    [<ffffffff804dd7ae>] tcp_close+0x3ce/0x4d0
>    [<ffffffff804fe1c2>] inet_release+0x42/0x70
>    [<ffffffff8049ef54>] sock_release+0x24/0x90
>    [<ffffffff8049efd2>] sock_close+0x12/0x30
>    [<ffffffff802d9d45>] __fput+0xd5/0x1f0
>    [<ffffffff802d9e7d>] fput+0x1d/0x30
>    [<ffffffff802d637b>] filp_close+0x5b/0x90
>    [<ffffffff802d6469>] sys_close+0xb9/0x120
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  -> (&list->lock#3){-+..} ops: 12322 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537716>]
> _spin_lock_bh+0x36/0x70
>                                          [<ffffffff804c22f7>]
> dev_deactivate+0x197/0x1d0
>                                          [<ffffffff804ae775>]
> dev_close+0x65/0xc0
>                                          [<ffffffff804b0d9d>]
> dev_change_flags+0x9d/0x1e0
>                                          [<ffffffff804bac05>]
> do_setlink+0x2b5/0x450
>                                          [<ffffffff804bb484>]
> rtnl_newlink+0x444/0x500
>                                          [<ffffffff804b9c2d>]
> rtnetlink_rcv_msg+0x18d/0x240
>                                          [<ffffffff804c48d9>]
> netlink_rcv_skb+0x89/0xb0
>                                          [<ffffffff804b9a89>]
> rtnetlink_rcv+0x29/0x40
>                                          [<ffffffff804c45fd>]
> netlink_unicast+0x2bd/0x2d0
>                                          [<ffffffff804c5814>]
> netlink_sendmsg+0x214/0x300
>                                          [<ffffffff8049ff17>]
> sock_sendmsg+0x107/0x130
>                                          [<ffffffff804a00c9>]
> sys_sendmsg+0x189/0x320
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     hardirq-on-W at:
>                                          [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537716>]
> _spin_lock_bh+0x36/0x70
>                                          [<ffffffff804c22f7>]
> dev_deactivate+0x197/0x1d0
>                                          [<ffffffff804ae775>]
> dev_close+0x65/0xc0
>                                          [<ffffffff804b0d9d>]
> dev_change_flags+0x9d/0x1e0
>                                          [<ffffffff804bac05>]
> do_setlink+0x2b5/0x450
>                                          [<ffffffff804bb484>]
> rtnl_newlink+0x444/0x500
>                                          [<ffffffff804b9c2d>]
> rtnetlink_rcv_msg+0x18d/0x240
>                                          [<ffffffff804c48d9>]
> netlink_rcv_skb+0x89/0xb0
>                                          [<ffffffff804b9a89>]
> rtnetlink_rcv+0x29/0x40
>                                          [<ffffffff804c45fd>]
> netlink_unicast+0x2bd/0x2d0
>                                          [<ffffffff804c5814>]
> netlink_sendmsg+0x214/0x300
>                                          [<ffffffff8049ff17>]
> sock_sendmsg+0x107/0x130
>                                          [<ffffffff804a00c9>]
> sys_sendmsg+0x189/0x320
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffff81041740>] __key.19984+0x0/0x20
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  -> (_xmit_ETHER#2){-+..} ops: 3070 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                          [<ffffffff804c2212>]
> dev_deactivate+0xb2/0x1d0
>                                          [<ffffffff804ae775>]
> dev_close+0x65/0xc0
>                                          [<ffffffff804b0d9d>]
> dev_change_flags+0x9d/0x1e0
>                                          [<ffffffff804bac05>]
> do_setlink+0x2b5/0x450
>                                          [<ffffffff804bb484>]
> rtnl_newlink+0x444/0x500
>                                          [<ffffffff804b9c2d>]
> rtnetlink_rcv_msg+0x18d/0x240
>                                          [<ffffffff804c48d9>]
> netlink_rcv_skb+0x89/0xb0
>                                          [<ffffffff804b9a89>]
> rtnetlink_rcv+0x29/0x40
>                                          [<ffffffff804c45fd>]
> netlink_unicast+0x2bd/0x2d0
>                                          [<ffffffff804c5814>]
> netlink_sendmsg+0x214/0x300
>                                          [<ffffffff8049ff17>]
> sock_sendmsg+0x107/0x130
>                                          [<ffffffff804a00c9>]
> sys_sendmsg+0x189/0x320
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     hardirq-on-W at:
>                                          [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                          [<ffffffff804c2212>]
> dev_deactivate+0xb2/0x1d0
>                                          [<ffffffff804ae775>]
> dev_close+0x65/0xc0
>                                          [<ffffffff804b0d9d>]
> dev_change_flags+0x9d/0x1e0
>                                          [<ffffffff804bac05>]
> do_setlink+0x2b5/0x450
>                                          [<ffffffff804bb484>]
> rtnl_newlink+0x444/0x500
>                                          [<ffffffff804b9c2d>]
> rtnetlink_rcv_msg+0x18d/0x240
>                                          [<ffffffff804c48d9>]
> netlink_rcv_skb+0x89/0xb0
>                                          [<ffffffff804b9a89>]
> rtnetlink_rcv+0x29/0x40
>                                          [<ffffffff804c45fd>]
> netlink_unicast+0x2bd/0x2d0
>                                          [<ffffffff804c5814>]
> netlink_sendmsg+0x214/0x300
>                                          [<ffffffff8049ff17>]
> sock_sendmsg+0x107/0x130
>                                          [<ffffffff804a00c9>]
> sys_sendmsg+0x189/0x320
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffff81040e68>] netdev_xmit_lock_key+0x8/0x1e0
>   -> (&sta->flaglock){.+..} ops: 22130 {
>      initial-use  at:
>                                            [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                            [<ffffffffa0167eb9>]
> set_sta_flags+0x29/0x50 [mac80211]
>                                            [<ffffffffa0168843>]
> ieee80211_rx_mgmt_assoc_resp+0x2d3/0xcb0 [mac80211]
>                                            [<ffffffffa0169373>]
> ieee80211_sta_rx_queued_mgmt+0x153/0x900 [mac80211]
>                                            [<ffffffffa0169bbb>]
> ieee80211_sta_work+0x9b/0x7f0 [mac80211]
>                                            [<ffffffff80258325>]
> run_workqueue+0x105/0x240
>                                            [<ffffffff8025866f>]
> worker_thread+0xaf/0x130
>                                            [<ffffffff8025c9f9>]
> kthread+0x49/0x90
>                                            [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-softirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>    }
>    ... key      at: [<ffffffffa0182ac8>]
> __key.34687+0x0/0xffffffffffff4630 [mac80211]
>   ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   -> (_xmit_IEEE80211#2){-+..} ops: 3092 {
>      initial-use  at:
>                                            [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                            [<ffffffff804c268a>]
> __qdisc_run+0x23a/0x290
>                                            [<ffffffff804b1fc0>]
> dev_queue_xmit+0x2e0/0x5f0
>                                            [<ffffffffa0175021>]
> ieee80211_tx_skb+0x61/0x70 [mac80211]
>                                            [<ffffffffa01672b7>]
> ieee80211_send_probe_req+0x1a7/0x220 [mac80211]
>                                            [<ffffffffa016a2f6>]
> ieee80211_sta_work+0x7d6/0x7f0 [mac80211]
>                                            [<ffffffff80258325>]
> run_workqueue+0x105/0x240
>                                            [<ffffffff8025866f>]
> worker_thread+0xaf/0x130
>                                            [<ffffffff8025c9f9>]
> kthread+0x49/0x90
>                                            [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      in-softirq-W at:
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>      hardirq-on-W at:
>                                            [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                            [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                            [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                            [<ffffffff804c268a>]
> __qdisc_run+0x23a/0x290
>                                            [<ffffffff804b1fc0>]
> dev_queue_xmit+0x2e0/0x5f0
>                                            [<ffffffffa0175021>]
> ieee80211_tx_skb+0x61/0x70 [mac80211]
>                                            [<ffffffffa01672b7>]
> ieee80211_send_probe_req+0x1a7/0x220 [mac80211]
>                                            [<ffffffffa016a2f6>]
> ieee80211_sta_work+0x7d6/0x7f0 [mac80211]
>                                            [<ffffffff80258325>]
> run_workqueue+0x105/0x240
>                                            [<ffffffff8025866f>]
> worker_thread+0xaf/0x130
>                                            [<ffffffff8025c9f9>]
> kthread+0x49/0x90
>                                            [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                            [<ffffffffffffffff>]
> 0xffffffffffffffff
>    }
>    ... key      at: [<ffffffff81040ff0>] netdev_xmit_lock_key+0x190/0x1e0
>    -> (&priv->lock){++..} ops: 48192 {
>       initial-use  at:
>                                              [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                              [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                              [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                              [<ffffffffa019aff9>]
> iwl3945_reset_qos+0x19/0x230 [iwl3945]
>                                              [<ffffffffa019d63e>]
> iwl3945_pci_probe+0x35e/0xf70 [iwl3945]
>                                              [<ffffffff803b332c>]
> pci_device_probe+0x7c/0xa0
>                                              [<ffffffff8043624f>]
> driver_probe_device+0xbf/0x320
>                                              [<ffffffff8043654b>]
> __driver_attach+0x9b/0xa0
>                                              [<ffffffff8043588b>]
> bus_for_each_dev+0x6b/0xa0
>                                              [<ffffffff80435fbc>]
> driver_attach+0x1c/0x20
>                                              [<ffffffff80435030>]
> bus_add_driver+0x1f0/0x2b0
>                                              [<ffffffff80436733>]
> driver_register+0x73/0x170
>                                              [<ffffffff803b361d>]
> __pci_register_driver+0x7d/0xd0
>                                              [<ffffffffa008f04a>]
> 0xffffffffa008f04a
>                                              [<ffffffff8020903c>]
> _stext+0x3c/0x170
>                                              [<ffffffff8027b99f>]
> sys_init_module+0xaf/0x1e0
>                                              [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>       in-hardirq-W at:
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>       in-softirq-W at:
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>     }
>     ... key      at: [<ffffffffa01b1fe4>]
> __key.39355+0x0/0xffffffffffff79b5 [iwl3945]
>     -> (&rxq->lock){.+..} ops: 52904 {
>        initial-use  at:
>                                                [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                                [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                                [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                                [<ffffffffa019bad2>]
> iwl3945_rx_allocate+0x32/0x1a0 [iwl3945]
>                                                [<ffffffffa019f11c>]
> iwl3945_rx_replenish+0x1c/0x50 [iwl3945]
>                                                [<ffffffffa01a8429>]
> iwl3945_hw_nic_init+0x399/0x9c0 [iwl3945]
>                                                [<ffffffffa019faca>]
> __iwl3945_up+0x9a/0x630 [iwl3945]
>                                                [<ffffffffa01a3648>]
> iwl3945_mac_start+0x418/0x820 [iwl3945]
>                                                [<ffffffffa016b292>]
> ieee80211_open+0x2d2/0x810 [mac80211]
>                                                [<ffffffff804b18b2>]
> dev_open+0xc2/0x100
>                                                [<ffffffff804b0d9d>]
> dev_change_flags+0x9d/0x1e0
>                                                [<ffffffff804bac05>]
> do_setlink+0x2b5/0x450
>                                                [<ffffffff804baead>]
> rtnl_setlink+0x10d/0x150
>                                                [<ffffffff804b9c2d>]
> rtnetlink_rcv_msg+0x18d/0x240
>                                                [<ffffffff804c48d9>]
> netlink_rcv_skb+0x89/0xb0
>                                                [<ffffffff804b9a89>]
> rtnetlink_rcv+0x29/0x40
>                                                [<ffffffff804c45fd>]
> netlink_unicast+0x2bd/0x2d0
>                                                [<ffffffff804c5814>]
> netlink_sendmsg+0x214/0x300
>                                                [<ffffffff8049ff17>]
> sock_sendmsg+0x107/0x130
>                                                [<ffffffff804a00c9>]
> sys_sendmsg+0x189/0x320
>                                                [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-softirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>      }
>      ... key      at: [<ffffffffa01b2050>]
> __key.37074+0x0/0xffffffffffff7949 [iwl3945]
>      -> (&zone->lock){.+..} ops: 2249020 {
>         initial-use  at:
>                                                  [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                                  [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                                  [<ffffffff805376a1>]
> _spin_lock+0x31/0x70
>                                                  [<ffffffff802ad5b0>]
> free_pages_bulk+0x30/0x310
>                                                  [<ffffffff802adc3b>]
> free_hot_cold_page+0x27b/0x2b0
>                                                  [<ffffffff802adcdb>]
> free_hot_page+0xb/0x10
>                                                  [<ffffffff802ae185>]
> __free_pages+0x35/0x40
>                                                  [<ffffffff8070a23f>]
> __free_pages_bootmem+0x4f/0x51
>                                                  [<ffffffff806f4ade>]
> free_all_bootmem_core+0xfa/0x1fc
>                                                  [<ffffffff806f4bf0>]
> free_all_bootmem+0x10/0x12
>                                                  [<ffffffff806ef6d0>]
> mem_init+0x1e/0x161
>                                                  [<ffffffff806dac35>]
> start_kernel+0x2aa/0x419
>                                                  [<ffffffff806da299>]
> x86_64_start_reservations+0x99/0xb9
>                                                  [<ffffffff806da3b4>]
> x86_64_start_kernel+0xd8/0xdf
>                                                  [<ffffffffffffffff>]
> 0xffffffffffffffff
>         in-softirq-W at:
>                                                  [<ffffffffffffffff>]
> 0xffffffffffffffff
>       }
>       ... key      at: [<ffffffff81020d8c>] __key.28617+0x0/0x8
>      ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff802acf7e>] get_page_from_freelist+0x54e/0x5a0
>    [<ffffffff802ad0c0>] __alloc_pages_internal+0xf0/0x4f0
>    [<ffffffff802d3e38>] __slab_alloc+0x388/0x560
>    [<ffffffff802d4ca7>] __kmalloc_track_caller+0x117/0x150
>    [<ffffffff804a67de>] __alloc_skb+0x6e/0x150
>    [<ffffffffa019bbe1>] iwl3945_rx_allocate+0x141/0x1a0 [iwl3945]
>    [<ffffffffa019f11c>] iwl3945_rx_replenish+0x1c/0x50 [iwl3945]
>    [<ffffffffa01a8429>] iwl3945_hw_nic_init+0x399/0x9c0 [iwl3945]
>    [<ffffffffa019faca>] __iwl3945_up+0x9a/0x630 [iwl3945]
>    [<ffffffffa01a3648>] iwl3945_mac_start+0x418/0x820 [iwl3945]
>    [<ffffffffa016b292>] ieee80211_open+0x2d2/0x810 [mac80211]
>    [<ffffffff804b18b2>] dev_open+0xc2/0x100
>    [<ffffffff804b0d9d>] dev_change_flags+0x9d/0x1e0
>    [<ffffffff804bac05>] do_setlink+0x2b5/0x450
>    [<ffffffff804baead>] rtnl_setlink+0x10d/0x150
>    [<ffffffff804b9c2d>] rtnetlink_rcv_msg+0x18d/0x240
>    [<ffffffff804c48d9>] netlink_rcv_skb+0x89/0xb0
>    [<ffffffff804b9a89>] rtnetlink_rcv+0x29/0x40
>    [<ffffffff804c45fd>] netlink_unicast+0x2bd/0x2d0
>    [<ffffffff804c5814>] netlink_sendmsg+0x214/0x300
>    [<ffffffff8049ff17>] sock_sendmsg+0x107/0x130
>    [<ffffffff804a00c9>] sys_sendmsg+0x189/0x320
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>      ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff802d3e7e>] __slab_alloc+0x3ce/0x560
>    [<ffffffff802d4106>] kmem_cache_alloc+0xf6/0x100
>    [<ffffffff804a67b4>] __alloc_skb+0x44/0x150
>    [<ffffffffa019bbe1>] iwl3945_rx_allocate+0x141/0x1a0 [iwl3945]
>    [<ffffffffa019f11c>] iwl3945_rx_replenish+0x1c/0x50 [iwl3945]
>    [<ffffffffa01a8429>] iwl3945_hw_nic_init+0x399/0x9c0 [iwl3945]
>    [<ffffffffa019faca>] __iwl3945_up+0x9a/0x630 [iwl3945]
>    [<ffffffffa01a3648>] iwl3945_mac_start+0x418/0x820 [iwl3945]
>    [<ffffffffa016b292>] ieee80211_open+0x2d2/0x810 [mac80211]
>    [<ffffffff804b18b2>] dev_open+0xc2/0x100
>    [<ffffffff804b0d9d>] dev_change_flags+0x9d/0x1e0
>    [<ffffffff804bac05>] do_setlink+0x2b5/0x450
>    [<ffffffff804baead>] rtnl_setlink+0x10d/0x150
>    [<ffffffff804b9c2d>] rtnetlink_rcv_msg+0x18d/0x240
>    [<ffffffff804c48d9>] netlink_rcv_skb+0x89/0xb0
>    [<ffffffff804b9a89>] rtnetlink_rcv+0x29/0x40
>    [<ffffffff804c45fd>] netlink_unicast+0x2bd/0x2d0
>    [<ffffffff804c5814>] netlink_sendmsg+0x214/0x300
>    [<ffffffff8049ff17>] sock_sendmsg+0x107/0x130
>    [<ffffffff804a00c9>] sys_sendmsg+0x189/0x320
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffffa019efaf>] iwl3945_rx_queue_restock+0x1f/0x170 [iwl3945]
>    [<ffffffffa019f136>] iwl3945_rx_replenish+0x36/0x50 [iwl3945]
>    [<ffffffffa01a8429>] iwl3945_hw_nic_init+0x399/0x9c0 [iwl3945]
>    [<ffffffffa019faca>] __iwl3945_up+0x9a/0x630 [iwl3945]
>    [<ffffffffa01a3648>] iwl3945_mac_start+0x418/0x820 [iwl3945]
>    [<ffffffffa016b292>] ieee80211_open+0x2d2/0x810 [mac80211]
>    [<ffffffff804b18b2>] dev_open+0xc2/0x100
>    [<ffffffff804b0d9d>] dev_change_flags+0x9d/0x1e0
>    [<ffffffff804bac05>] do_setlink+0x2b5/0x450
>    [<ffffffff804baead>] rtnl_setlink+0x10d/0x150
>    [<ffffffff804b9c2d>] rtnetlink_rcv_msg+0x18d/0x240
>    [<ffffffff804c48d9>] netlink_rcv_skb+0x89/0xb0
>    [<ffffffff804b9a89>] rtnetlink_rcv+0x29/0x40
>    [<ffffffff804c45fd>] netlink_unicast+0x2bd/0x2d0
>    [<ffffffff804c5814>] netlink_sendmsg+0x214/0x300
>    [<ffffffff8049ff17>] sock_sendmsg+0x107/0x130
>    [<ffffffff804a00c9>] sys_sendmsg+0x189/0x320
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     -> (&cwq->lock){++..} ops: 98321 {
>        initial-use  at:
>                                                [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                                [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                                [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                                [<ffffffff80258e1f>]
> __queue_work+0x1f/0x50
>                                                [<ffffffff80258edd>]
> queue_work_on+0x4d/0x60
>                                                [<ffffffff8025902a>]
> queue_work+0x1a/0x20
>                                                [<ffffffff80257e9c>]
> call_usermodehelper_exec+0xbc/0xe0
>                                                [<ffffffff8039f2b8>]
> kobject_uevent_env+0x448/0x5c0
>                                                [<ffffffff8039f43b>]
> kobject_uevent+0xb/0x10
>                                                [<ffffffff8039e662>]
> kset_register+0x52/0x60
>                                                [<ffffffff80435b92>]
> bus_register+0xd2/0x2e0
>                                                [<ffffffff806ff04f>]
> platform_bus_init+0x30/0x44
>                                                [<ffffffff806ff145>]
> driver_init+0x25/0x39
>                                                [<ffffffff806da66d>]
> kernel_init+0x118/0x194
>                                                [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-hardirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-softirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>      }
>      ... key      at: [<ffffffff80967514>] __key.21884+0x0/0x8
>      ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff802367cd>] __wake_up+0x2d/0x70
>    [<ffffffff8025873f>] insert_work+0x4f/0x60
>    [<ffffffff80258e31>] __queue_work+0x31/0x50
>    [<ffffffff80258edd>] queue_work_on+0x4d/0x60
>    [<ffffffff8025902a>] queue_work+0x1a/0x20
>    [<ffffffff80257e9c>] call_usermodehelper_exec+0xbc/0xe0
>    [<ffffffff8039f2b8>] kobject_uevent_env+0x448/0x5c0
>    [<ffffffff8039f43b>] kobject_uevent+0xb/0x10
>    [<ffffffff8039e662>] kset_register+0x52/0x60
>    [<ffffffff80435b92>] bus_register+0xd2/0x2e0
>    [<ffffffff806ff04f>] platform_bus_init+0x30/0x44
>    [<ffffffff806ff145>] driver_init+0x25/0x39
>    [<ffffffff806da66d>] kernel_init+0x118/0x194
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffff80258e1f>] __queue_work+0x1f/0x50
>    [<ffffffff80258edd>] queue_work_on+0x4d/0x60
>    [<ffffffff8025902a>] queue_work+0x1a/0x20
>    [<ffffffffa01a50ef>] iwl3945_mac_hw_scan+0x24f/0x290 [iwl3945]
>    [<ffffffffa01627f9>] ieee80211_start_scan+0x99/0x2b0 [mac80211]
>    [<ffffffffa016a25e>] ieee80211_sta_work+0x73e/0x7f0 [mac80211]
>    [<ffffffff80258325>] run_workqueue+0x105/0x240
>    [<ffffffff8025866f>] worker_thread+0xaf/0x130
>    [<ffffffff8025c9f9>] kthread+0x49/0x90
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     -> (&list->lock#6){.+..} ops: 60988 {
>        initial-use  at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-softirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>      }
>      ... key      at: [<ffffffffa0182ab0>]
> __key.17254+0x0/0xffffffffffff4648 [mac80211]
>     ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     -> (&priv->sta_lock){.+..} ops: 3137 {
>        initial-use  at:
>                                                [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                                [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                                [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                                [<ffffffffa019ae63>]
> iwl3945_clear_stations_table+0x23/0x60 [iwl3945]
>                                                [<ffffffffa019d606>]
> iwl3945_pci_probe+0x326/0xf70 [iwl3945]
>                                                [<ffffffff803b332c>]
> pci_device_probe+0x7c/0xa0
>                                                [<ffffffff8043624f>]
> driver_probe_device+0xbf/0x320
>                                                [<ffffffff8043654b>]
> __driver_attach+0x9b/0xa0
>                                                [<ffffffff8043588b>]
> bus_for_each_dev+0x6b/0xa0
>                                                [<ffffffff80435fbc>]
> driver_attach+0x1c/0x20
>                                                [<ffffffff80435030>]
> bus_add_driver+0x1f0/0x2b0
>                                                [<ffffffff80436733>]
> driver_register+0x73/0x170
>                                                [<ffffffff803b361d>]
> __pci_register_driver+0x7d/0xd0
>                                                [<ffffffffa008f04a>]
> 0xffffffffa008f04a
>                                                [<ffffffff8020903c>]
> _stext+0x3c/0x170
>                                                [<ffffffff8027b99f>]
> sys_init_module+0xaf/0x1e0
>                                                [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-softirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>      }
>      ... key      at: [<ffffffffa01b1fd4>]
> __key.39357+0x0/0xffffffffffff79c5 [iwl3945]
>     ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffffa01a650a>] iwl3945_hw_build_tx_cmd_rate+0x9a/0x1e0 [iwl3945]
>    [<ffffffffa01a2041>] iwl3945_mac_tx+0x551/0x990 [iwl3945]
>    [<ffffffffa01734ee>] __ieee80211_tx+0x4e/0x150 [mac80211]
>    [<ffffffffa0173a75>] ieee80211_master_start_xmit+0x245/0x530 [mac80211]
>    [<ffffffff804b028d>] dev_hard_start_xmit+0x28d/0x310
>    [<ffffffff804c266c>] __qdisc_run+0x21c/0x290
>    [<ffffffff804b1fc0>] dev_queue_xmit+0x2e0/0x5f0
>    [<ffffffffa0175021>] ieee80211_tx_skb+0x61/0x70 [mac80211]
>    [<ffffffffa01672b7>] ieee80211_send_probe_req+0x1a7/0x220 [mac80211]
>    [<ffffffffa016a2f6>] ieee80211_sta_work+0x7d6/0x7f0 [mac80211]
>    [<ffffffff80258325>] run_workqueue+0x105/0x240
>    [<ffffffff8025866f>] worker_thread+0xaf/0x130
>    [<ffffffff8025c9f9>] kthread+0x49/0x90
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>     -> (&local->queue_stop_reason_lock){.+..} ops: 3091 {
>        initial-use  at:
>                                                [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                                [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                                [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                                [<ffffffffa0175656>]
> ieee80211_wake_queues_by_reason+0x26/0x80 [mac80211]
>                                                [<ffffffffa01756bb>]
> ieee80211_wake_queues+0xb/0x10 [mac80211]
>                                                [<ffffffffa01a57ea>]
> iwl3945_bg_alive_start+0x15a/0x3a0 [iwl3945]
>                                                [<ffffffff80258325>]
> run_workqueue+0x105/0x240
>                                                [<ffffffff8025866f>]
> worker_thread+0xaf/0x130
>                                                [<ffffffff8025c9f9>]
> kthread+0x49/0x90
>                                                [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>        in-softirq-W at:
>                                                [<ffffffffffffffff>]
> 0xffffffffffffffff
>      }
>      ... key      at: [<ffffffffa0182aa0>]
> __key.35230+0x0/0xffffffffffff4658 [mac80211]
>     ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffffa01a1b55>] iwl3945_mac_tx+0x65/0x990 [iwl3945]
>    [<ffffffffa01734ee>] __ieee80211_tx+0x4e/0x150 [mac80211]
>    [<ffffffffa0173a75>] ieee80211_master_start_xmit+0x245/0x530 [mac80211]
>    [<ffffffff804b028d>] dev_hard_start_xmit+0x28d/0x310
>    [<ffffffff804c266c>] __qdisc_run+0x21c/0x290
>    [<ffffffff804b1fc0>] dev_queue_xmit+0x2e0/0x5f0
>    [<ffffffffa0175021>] ieee80211_tx_skb+0x61/0x70 [mac80211]
>    [<ffffffffa01672b7>] ieee80211_send_probe_req+0x1a7/0x220 [mac80211]
>    [<ffffffffa016a2f6>] ieee80211_sta_work+0x7d6/0x7f0 [mac80211]
>    [<ffffffff80258325>] run_workqueue+0x105/0x240
>    [<ffffffff8025866f>] worker_thread+0xaf/0x130
>    [<ffffffff8025c9f9>] kthread+0x49/0x90
>    [<ffffffff8020d7ba>] child_rip+0xa/0x20
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    -> (&rs_sta->lock){.+..} ops: 9505 {
>       initial-use  at:
>                                              [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                              [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                              [<ffffffff80537824>]
> _spin_lock_irqsave+0x44/0x90
>                                              [<ffffffffa01a95e8>]
> iwl3945_rate_scale_init+0x68/0x1b0 [iwl3945]
>                                              [<ffffffffa01a2c0b>]
> iwl3945_post_associate+0x19b/0x240 [iwl3945]
>                                              [<ffffffffa01a2ded>]
> iwl3945_bss_info_changed+0x13d/0x180 [iwl3945]
>                                              [<ffffffffa015d977>]
> ieee80211_bss_info_change_notify+0x37/0x50 [mac80211]
>                                              [<ffffffffa01690d4>]
> ieee80211_rx_mgmt_assoc_resp+0xb64/0xcb0 [mac80211]
>                                              [<ffffffffa0169373>]
> ieee80211_sta_rx_queued_mgmt+0x153/0x900 [mac80211]
>                                              [<ffffffffa0169bbb>]
> ieee80211_sta_work+0x9b/0x7f0 [mac80211]
>                                              [<ffffffff80258325>]
> run_workqueue+0x105/0x240
>                                              [<ffffffff8025866f>]
> worker_thread+0xaf/0x130
>                                              [<ffffffff8025c9f9>]
> kthread+0x49/0x90
>                                              [<ffffffff8020d7ba>]
> child_rip+0xa/0x20
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>       in-softirq-W at:
>                                              [<ffffffffffffffff>]
> 0xffffffffffffffff
>     }
>     ... key      at: [<ffffffffa01b2070>]
> __key.34794+0x0/0xffffffffffff7929 [iwl3945]
>     ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff80537824>] _spin_lock_irqsave+0x44/0x90
>    [<ffffffffa01a8d39>] rs_get_rate+0x109/0x4c0 [iwl3945]
>    [<ffffffffa016ba36>] rate_control_get_rate+0xb6/0xc0 [mac80211]
>    [<ffffffffa01728eb>] invoke_tx_handlers+0x4eb/0xe50 [mac80211]
>    [<ffffffffa0173a4d>] ieee80211_master_start_xmit+0x21d/0x530 [mac80211]
>    [<ffffffff804b028d>] dev_hard_start_xmit+0x28d/0x310
>    [<ffffffff804c266c>] __qdisc_run+0x21c/0x290
>    [<ffffffff804b1fc0>] dev_queue_xmit+0x2e0/0x5f0
>    [<ffffffffa0172153>] ieee80211_subif_start_xmit+0x3d3/0x680 [mac80211]
>    [<ffffffff804b028d>] dev_hard_start_xmit+0x28d/0x310
>    [<ffffffff804c266c>] __qdisc_run+0x21c/0x290
>    [<ffffffff804b1fc0>] dev_queue_xmit+0x2e0/0x5f0
>    [<ffffffff8051d7d3>] packet_sendmsg+0x273/0x2b0
>    [<ffffffff8049e64a>] sock_aio_write+0x17a/0x190
>    [<ffffffff802d8421>] do_sync_write+0xf1/0x140
>    [<ffffffff802d8bb9>] vfs_write+0x179/0x190
>    [<ffffffff802d8cc0>] sys_write+0x50/0x90
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>    ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff802d3e7e>] __slab_alloc+0x3ce/0x560
>    [<ffffffff802d4df6>] __kmalloc+0x116/0x150
>    [<ffffffff804a5e74>] pskb_expand_head+0x54/0x180
>    [<ffffffffa0171d09>] ieee80211_skb_resize+0x79/0xf0 [mac80211]
>    [<ffffffffa0173967>] ieee80211_master_start_xmit+0x137/0x530 [mac80211]
>    [<ffffffff804b028d>] dev_hard_start_xmit+0x28d/0x310
>    [<ffffffff804c266c>] __qdisc_run+0x21c/0x290
>    [<ffffffff804b1fc0>] dev_queue_xmit+0x2e0/0x5f0
>    [<ffffffffa0172153>] ieee80211_subif_start_xmit+0x3d3/0x680 [mac80211]
>    [<ffffffff804b028d>] dev_hard_start_xmit+0x28d/0x310
>    [<ffffffff804c266c>] __qdisc_run+0x21c/0x290
>    [<ffffffff804b1fc0>] dev_queue_xmit+0x2e0/0x5f0
>    [<ffffffff804d489b>] ip_finish_output+0x1bb/0x2e0
>    [<ffffffff804d4a24>] ip_output+0x64/0xb0
>    [<ffffffff804d37d0>] ip_local_out+0x20/0x30
>    [<ffffffff804d3ac8>] ip_push_pending_frames+0x2e8/0x420
>    [<ffffffff804f408f>] udp_push_pending_frames+0x13f/0x3d0
>    [<ffffffff804f50b6>] udp_sendmsg+0x316/0x750
>    [<ffffffff804fc865>] inet_sendmsg+0x45/0x80
>    [<ffffffff8049ff17>] sock_sendmsg+0x107/0x130
>    [<ffffffff804a03aa>] sys_sendto+0xea/0x120
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>   ... acquired at:
>    [<ffffffff8026ff53>] __lock_acquire+0xe13/0x1280
>    [<ffffffff80270451>] lock_acquire+0x91/0xc0
>    [<ffffffff805376a1>] _spin_lock+0x31/0x70
>    [<ffffffff802d3e7e>] __slab_alloc+0x3ce/0x560
>    [<ffffffff802d4df6>] __kmalloc+0x116/0x150
>    [<ffffffff804a5e74>] pskb_expand_head+0x54/0x180
>    [<ffffffffa0171d09>] ieee80211_skb_resize+0x79/0xf0 [mac80211]
>    [<ffffffffa0172045>] ieee80211_subif_start_xmit+0x2c5/0x680 [mac80211]
>    [<ffffffff804b028d>] dev_hard_start_xmit+0x28d/0x310
>    [<ffffffff804c266c>] __qdisc_run+0x21c/0x290
>    [<ffffffff804b1fc0>] dev_queue_xmit+0x2e0/0x5f0
>    [<ffffffff804b60fc>] neigh_resolve_output+0x10c/0x2e0
>    [<ffffffff804d48fa>] ip_finish_output+0x21a/0x2e0
>    [<ffffffff804d4c48>] ip_mc_output+0x1d8/0x210
>    [<ffffffff804d37d0>] ip_local_out+0x20/0x30
>    [<ffffffff804d3ac8>] ip_push_pending_frames+0x2e8/0x420
>    [<ffffffff804f408f>] udp_push_pending_frames+0x13f/0x3d0
>    [<ffffffff804f50b6>] udp_sendmsg+0x316/0x750
>    [<ffffffff804fc865>] inet_sendmsg+0x45/0x80
>    [<ffffffff8049ff17>] sock_sendmsg+0x107/0x130
>    [<ffffffff804a00c9>] sys_sendmsg+0x189/0x320
>    [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  -> (&queue->syn_wait_lock){-+..} ops: 21 {
>     initial-use  at:
>                                          [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537966>]
> _write_lock_bh+0x36/0x70
>                                          [<ffffffff804a43cc>]
> reqsk_queue_alloc+0xec/0x120
>                                          [<ffffffff804d8bc6>]
> inet_csk_listen_start+0x26/0x120
>                                          [<ffffffff804fd819>]
> inet_listen+0x89/0xa0
>                                          [<ffffffff8049ed95>]
> sys_listen+0x75/0x80
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     in-softirq-W at:
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>     hardirq-on-W at:
>                                          [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                          [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                          [<ffffffff80537966>]
> _write_lock_bh+0x36/0x70
>                                          [<ffffffff804a43cc>]
> reqsk_queue_alloc+0xec/0x120
>                                          [<ffffffff804d8bc6>]
> inet_csk_listen_start+0x26/0x120
>                                          [<ffffffff804fd819>]
> inet_listen+0x89/0xa0
>                                          [<ffffffff8049ed95>]
> sys_listen+0x75/0x80
>                                          [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                          [<ffffffffffffffff>] 0xffffffffffffffff
>   }
>   ... key      at: [<ffffffff810402e8>] __key.32241+0x0/0x18
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
>  ... acquired at:
>    [<ffffffffffffffff>] 0xffffffffffffffff
> 
> 
> the soft-irq-unsafe lock's dependencies:
> -> (&fbc->lock){--..} ops: 4449 {
>    initial-use  at:
>                                        [<ffffffff8026f2e7>]
> __lock_acquire+0x1a7/0x1280
>                                        [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                        [<ffffffff805376a1>] _spin_lock+0x31/0x70
>                                        [<ffffffff803aa578>]
> __percpu_counter_add+0x58/0x80
>                                        [<ffffffff802d9aae>]
> get_empty_filp+0x7e/0x1a0
>                                        [<ffffffff802e46d6>]
> path_lookup_open+0x36/0xd0
>                                        [<ffffffff802e5598>]
> do_filp_open+0xb8/0x930
>                                        [<ffffffff802d6548>]
> do_sys_open+0x78/0x100
>                                        [<ffffffff802d65fb>] sys_open+0x1b/0x20
>                                        [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                        [<ffffffffffffffff>] 0xffffffffffffffff
>    softirq-on-W at:
>                                        [<ffffffff8026f4ec>]
> __lock_acquire+0x3ac/0x1280
>                                        [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                        [<ffffffff805376a1>] _spin_lock+0x31/0x70
>                                        [<ffffffff803aa578>]
> __percpu_counter_add+0x58/0x80
>                                        [<ffffffff802d9aae>]
> get_empty_filp+0x7e/0x1a0
>                                        [<ffffffff802e46d6>]
> path_lookup_open+0x36/0xd0
>                                        [<ffffffff802e5598>]
> do_filp_open+0xb8/0x930
>                                        [<ffffffff802d6548>]
> do_sys_open+0x78/0x100
>                                        [<ffffffff802d65fb>] sys_open+0x1b/0x20
>                                        [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                        [<ffffffffffffffff>] 0xffffffffffffffff
>    hardirq-on-W at:
>                                        [<ffffffff8026f69b>]
> __lock_acquire+0x55b/0x1280
>                                        [<ffffffff80270451>]
> lock_acquire+0x91/0xc0
>                                        [<ffffffff805376a1>] _spin_lock+0x31/0x70
>                                        [<ffffffff803aa578>]
> __percpu_counter_add+0x58/0x80
>                                        [<ffffffff802d9aae>]
> get_empty_filp+0x7e/0x1a0
>                                        [<ffffffff802e46d6>]
> path_lookup_open+0x36/0xd0
>                                        [<ffffffff802e5598>]
> do_filp_open+0xb8/0x930
>                                        [<ffffffff802d6548>]
> do_sys_open+0x78/0x100
>                                        [<ffffffff802d65fb>] sys_open+0x1b/0x20
>                                        [<ffffffff8020c6db>]
> system_call_fastpath+0x16/0x1b
>                                        [<ffffffffffffffff>] 0xffffffffffffffff
>  }
>  ... key      at: [<ffffffff81033ce4>] __key.10712+0x0/0x8
> 
> stack backtrace:
> Pid: 3654, comm: firefox Not tainted 2.6.28 #102
> Call Trace:
>  [<ffffffff8026d8df>] check_usage+0x2ef/0x3a0
>  [<ffffffff8025083e>] ? __mod_timer+0xbe/0xe0
>  [<ffffffff8026fe03>] __lock_acquire+0xcc3/0x1280
>  [<ffffffff80270451>] lock_acquire+0x91/0xc0
>  [<ffffffff803aa578>] ? __percpu_counter_add+0x58/0x80
>  [<ffffffff805376a1>] _spin_lock+0x31/0x70
>  [<ffffffff803aa578>] ? __percpu_counter_add+0x58/0x80
>  [<ffffffff803aa578>] __percpu_counter_add+0x58/0x80
>  [<ffffffff804dd578>] ? tcp_close+0x198/0x4d0
>  [<ffffffff804dd5a3>] tcp_close+0x1c3/0x4d0
>  [<ffffffff804fe1c2>] inet_release+0x42/0x70
>  [<ffffffff8049ef54>] sock_release+0x24/0x90
>  [<ffffffff8049efd2>] sock_close+0x12/0x30
>  [<ffffffff802d9d45>] __fput+0xd5/0x1f0
>  [<ffffffff802d9e7d>] fput+0x1d/0x30
>  [<ffffffff802d637b>] filp_close+0x5b/0x90
>  [<ffffffff802d6469>] sys_close+0xb9/0x120
>  [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
> 
> 
> After this even Sysrq+B didn't work
> 

