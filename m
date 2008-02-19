From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 19 Feb 2008 14:37:38 +0000
Message-ID: <47BAE9B2.7040602@katalix.com>
References: <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080218.202934.79548477.davem@davemloft.net> <47BA9B50.8040404@katalix.com> <20080219103047.GA3898@ff.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030602020304010109060003"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:38926 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751674AbYBSOh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 09:37:57 -0500
In-Reply-To: <20080219103047.GA3898@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030602020304010109060003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Jarek Poplawski wrote:
> On Tue, Feb 19, 2008 at 09:03:12AM +0000, James Chapman wrote:
>> David Miller wrote:
>>> From: James Chapman <jchapman@katalix.com>
>>> Date: Mon, 18 Feb 2008 22:09:24 +0000
>>>
>>>> Here's a new version of the patch. The patch avoids disabling irqs
>>>> and fixes the sk_dst_get() usage that DaveM mentioned. But even with
>>>> this patch, lockdep still complains if hundreds of ppp sessions are
>>>> inserted into a tunnel as rapidly as possible (lockdep trace is
>>>> below). I can stop these errors by wrapping the call to ppp_input()
>>>> in pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is
>>>> a better fix?
>>> Firstly, let's fix one thing at a time.  Leave the sk_dst_get()
>>> thing alone until we can prove that it's part of the lockdep
>>> traces.
>> In reproducing the problem, I obtained several lockdep traces that  
>> implicated sk_dst_get().
> 
> As a matter of fact I missed just that kind information on previous
> lockdep report, so if you could send them too this should be still
> helpful.

Here you go.

Just to be clear, the initial lockdep report was with non-bh locks. 
Yesterday's report was with _bh locks and the sk_dst_get() changes. This 
(older) report is with _bh locks but without the sk_dst_get() changes.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development


--------------030602020304010109060003
Content-Type: text/plain;
 name="lockdep-sk_dst.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="lockdep-sk_dst.log"

Feb 18 17:25:42 localhost kernel: ======================================================
Feb 18 17:25:42 localhost kernel: [ INFO: soft-safe -> soft-unsafe lock order detected ]
Feb 18 17:25:42 localhost kernel: 2.6.24.2 #1
Feb 18 17:25:42 localhost kernel: ------------------------------------------------------
Feb 18 17:25:42 localhost kernel: pppd/13863 [HC0[0]:SC0[1]:HE1:SE0] is trying to acquire:
Feb 18 17:25:42 localhost kernel:  (&sk->sk_dst_lock){----}, at: [<f8bbf73e>] pppol2tp_xmit+0x3a5/0x4a2 [pppol2tp]
Feb 18 17:25:42 localhost kernel: 
Feb 18 17:25:42 localhost kernel: and this task is already holding:
Feb 18 17:25:42 localhost kernel:  (&pch->downl){-...}, at: [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:25:42 localhost kernel: which would create a new lock dependency:
Feb 18 17:25:42 localhost pppd[13863]: Connection terminated.
Feb 18 17:25:42 localhost kernel:  (&pch->downl){-...} -> (&sk->sk_dst_lock){----}
Feb 18 17:25:42 localhost pppd[13863]: Exit.
Feb 18 17:25:42 localhost kernel: 
Feb 18 17:25:42 localhost kernel: but this new dependency connects a soft-irq-safe lock:
Feb 18 17:25:42 localhost kernel:  (&pch->upl){-.-+}
Feb 18 17:25:42 localhost kernel: ... which became soft-irq-safe at:
Feb 18 17:25:43 localhost kernel:   [<c0448013>] check_usage_backwards+0x19/0x41
Feb 18 17:25:43 localhost kernel:   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:43 localhost kernel:   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:43 localhost kernel:   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:43 localhost kernel:   [<f8bb840d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 17:25:43 localhost kernel:   [<c061b373>] _read_lock_bh+0x2e/0x39
Feb 18 17:25:43 localhost kernel:   [<f8bb840d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 17:25:43 localhost kernel:   [<f8bb840d>] ppp_input+0x45/0xef [ppp_generic]
Feb 18 17:25:43 localhost kernel:   [<f8bbf263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 17:25:43 localhost kernel:   [<f8bbf37a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 17:25:43 localhost kernel:   [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:25:43 localhost kernel:   [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 17:25:43 localhost kernel:   [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 17:25:43 localhost kernel:   [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 17:25:43 localhost kernel:   [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 17:25:43 localhost kernel:   [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 17:25:43 localhost kernel:   [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:25:43 localhost kernel:   [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 17:25:43 localhost kernel:   [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 17:25:43 localhost kernel:   [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:25:43 localhost kernel:   [<f89637c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 17:25:43 localhost kernel:   [<f8963453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 17:25:43 localhost kernel:   [<f8960f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 17:25:43 localhost kernel:   [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 17:25:43 localhost kernel:   [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 17:25:43 localhost kernel:   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:43 localhost kernel:   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:43 localhost kernel:   [<ffffffff>] 0xffffffff
Feb 18 17:25:43 localhost kernel: 
Feb 18 17:25:43 localhost kernel: to a soft-irq-unsafe lock:
Feb 18 17:25:43 localhost kernel:  (&sk->sk_dst_lock){----}
Feb 18 17:25:43 localhost kernel: ... which became soft-irq-unsafe at:
Feb 18 17:25:43 localhost kernel: ...  [<c0449046>] __lock_acquire+0x48b/0xbf1
Feb 18 17:25:43 localhost kernel:   [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:25:43 localhost kernel:   [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 17:25:43 localhost kernel:   [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 17:25:43 localhost kernel:   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:43 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:25:43 localhost kernel:   [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 17:25:43 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:25:43 localhost kernel:   [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:25:43 localhost kernel:   [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 17:25:44 localhost kernel:   [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 17:25:44 localhost kernel:   [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 17:25:44 localhost kernel:   [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 17:25:44 localhost kernel:   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:44 localhost kernel:   [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 17:25:44 localhost kernel:   [<ffffffff>] 0xffffffff
Feb 18 17:25:44 localhost kernel: 
Feb 18 17:25:44 localhost kernel: other info that might help us debug this:
Feb 18 17:25:44 localhost kernel: 
Feb 18 17:25:44 localhost kernel: 1 lock held by pppd/13863:
Feb 18 17:25:44 localhost kernel:  #0:  (&pch->downl){-...}, at: [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:25:44 localhost kernel: 
Feb 18 17:25:44 localhost kernel: the soft-irq-safe lock's dependencies:
Feb 18 17:25:44 localhost kernel: -> (&pch->upl){-.-+} ops: 13 {
Feb 18 17:25:44 localhost kernel:    initial-use  at:
Feb 18 17:25:44 localhost kernel:                         [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:44 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:44 localhost kernel:                         [<f8bb6b7c>] ppp_ioctl+0x4df/0xc06 [ppp_generic]
Feb 18 17:25:44 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:44 localhost kernel:                         [<f8bb6ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 17:25:44 localhost kernel:                         [<c061b300>] _write_lock_bh+0x2e/0x39
Feb 18 17:25:44 localhost kernel:                         [<f8bb6ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 17:25:44 localhost kernel:                         [<f8bb6ba1>] ppp_ioctl+0x504/0xc06 [ppp_generic]
Feb 18 17:25:44 localhost kernel:                         [<c061b008>] __down+0x82/0xb8
Feb 18 17:25:44 localhost kernel:                         [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:44 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:44 localhost kernel:                         [<c061b008>] __down+0x82/0xb8
Feb 18 17:25:44 localhost kernel:                         [<c0425474>] default_wake_function+0x0/0x8
Feb 18 17:25:44 localhost kernel:                         [<c061ae17>] __down_failed+0x7/0xc
Feb 18 17:25:44 localhost kernel:                         [<c0488854>] do_ioctl+0x4ebalance_domains+0x28/0x99
Feb 18 17:25:44 localhost kernel:                                       [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:44 localhost kernel:                                       [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:44 localhost kernel:                                       [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:44 localhost kernel:                                       [<ffffffff>] 0xffffffff
Feb 18 17:25:44 localhost kernel:         }
Feb 18 17:25:44 localhost kernel:         ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:25:44 localhost kernel:        ... acquired at:
Feb 18 17:25:44 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:44 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:44 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:45 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:45 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:45 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:45 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:45 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:25:45 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:45 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:25:45 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:45 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:25:45 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:25:45 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:45 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:45 localhost kernel: 
Feb 18 17:25:45 localhost kernel:       ... acquired at:
Feb 18 17:25:45 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:45 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:45 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:45 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:45 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:45 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:45 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:45 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:25:45 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:45 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:25:45 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:45 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:25:45 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:25:45 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:45 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:45 localhost kernel: 
Feb 18 17:25:45 localhost kernel:       -> (&rq->rq_lock_key#4){++..} ops: 1787266 {
Feb 18 17:25:45 localhost kernel:          initial-use  at:
Feb 18 17:25:45 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:45 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:45 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:45 localhost kernel:                                     [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:25:45 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:45 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:45 localhost kernel:                                     [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:25:45 localhost kernel:                                     [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:25:45 localhost kernel:                                     [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:46 localhost kernel:                                     [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:25:46 localhost kernel:                                     [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:25:46 localhost kernel:                                     [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:25:46 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:46 localhost kernel:                                     [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:46 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:46 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:46 localhost kernel:                                     [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:25:46 localhost kernel:                                     [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:25:46 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:46 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:46 localhost kernel:                                     [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:25:46 localhost kernel:                                     [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:25:46 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:46 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:46 localhost kernel:                                     [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:46 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:46 localhost kernel:          in-hardirq-W at:
Feb 18 17:25:46 localhost kernel:                                     [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:25:46 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:46 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:46 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:46 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:46 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:46 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:46 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:46 localhost kernel:                                     [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:25:46 localhost kernel:                                     [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:25:46 localhost kernel:                                     [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:25:46 localhost kernel:                                     [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:25:46 localhost kernel:                                     [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:25:46 localhost kernel:                                     [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:25:46 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:46 localhost kernel:                                     [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:25:46 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:46 localhost kernel:                                     [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:25:46 localhost kernel:                                     [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:25:46 localhost kernel:                                     [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:25:46 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:46 localhost kernel:          in-softirq-W at:
Feb 18 17:25:46 localhost kernel:                                     [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:25:46 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:47 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:47 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:47 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:                                     [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:25:47 localhost kernel:                                     [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:25:47 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:47 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:47 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:47 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:47 localhost kernel:        }
Feb 18 17:25:47 localhost kernel:        ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:25:47 localhost kernel:       ... acquired at:
Feb 18 17:25:47 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:25:47 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:47 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:25:47 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:47 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:25:47 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:25:47 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:47 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:47 localhost kernel: 
Feb 18 17:25:47 localhost kernel:      ... acquired at:
Feb 18 17:25:47 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:47 localhost kernel:    [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:25:47 localhost kernel:    [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:25:48 localhost kernel:    [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:48 localhost kernel:    [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:48 localhost kernel:    [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:48 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:48 localhost kernel: 
Feb 18 17:25:48 localhost kernel:      -> (&rq->rq_lock_key#3){++..} ops: 1928539 {
Feb 18 17:25:48 localhost kernel:         initial-use  at:
Feb 18 17:25:48 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:48 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:48 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:48 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:25:48 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:48 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:48 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:25:48 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:25:48 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:48 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:25:48 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:25:48 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:25:48 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:48 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:48 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:48 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:48 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:25:48 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:25:48 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:48 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:48 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:25:48 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:25:48 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:48 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:48 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:48 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:48 localhost kernel:         in-hardirq-W at:
Feb 18 17:25:48 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:25:48 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:48 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:48 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:48 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:48 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:48 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:48 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:48 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:25:49 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:25:49 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:25:49 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:25:49 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:25:49 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:25:49 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:49 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:25:49 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:49 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:25:49 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:25:49 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:25:49 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:49 localhost kernel:         in-softirq-W at:
Feb 18 17:25:49 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:49 localhost kernel:                                   [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 17:25:49 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:49 localhost kernel:                                   [<c04422f1>] getnstimeofday+0x30/0xbc
Feb 18 17:25:49 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:49 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:49 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:49 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:49 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:49 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:49 localhost kernel:                                   [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 17:25:49 localhost kernel:                                   [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:25:49 localhost kernel:                                   [<c0430afa>] __do_softirq+0xc9/0xde
Feb 18 17:25:49 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:49 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:49 localhost kernel:       }
Feb 18 17:25:49 localhost kernel:       ... key      at: [<c2a34488>] 0xc2a34488
Feb 18 17:25:49 localhost kernel:       -> (&rq->rq_lock_key#4){++..} ops: 1787266 {
Feb 18 17:25:49 localhost kernel:          initial-use  at:
Feb 18 17:25:49 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:49 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:49 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:49 localhost kernel:                                     [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:25:49 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:49 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:49 localhost kernel:                                     [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:25:50 localhost kernel:                                     [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:25:50 localhost kernel:                                     [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:50 localhost kernel:                                     [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:25:50 localhost kernel:                                     [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:25:50 localhost kernel:                                     [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:25:50 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:50 localhost kernel:                                     [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:50 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:50 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:50 localhost kernel:                                     [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:25:50 localhost kernel:                                     [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:25:50 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:50 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:50 localhost kernel:                                     [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:25:50 localhost kernel:                                     [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:25:50 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:50 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:50 localhost kernel:                                     [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:50 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:50 localhost kernel:          in-hardirq-W at:
Feb 18 17:25:50 localhost kernel:                                     [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:25:50 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:50 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:50 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:50 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:50 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:50 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:50 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:50 localhost kernel:                                     [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:25:50 localhost kernel:                                     [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:25:50 localhost kernel:                                     [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:25:50 localhost kernel:                                     [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:25:50 localhost kernel:                                     [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:25:50 localhost kernel:                                     [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:25:50 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:50 localhost kernel:                                     [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:25:50 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:50 localhost kernel:                                     [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:25:50 localhost kernel:                                     [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:25:50 localhost kernel:                                     [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:25:50 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:51 localhost kernel:          in-softirq-W at:
Feb 18 17:25:51 localhost kernel:                                     [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:25:51 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:51 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:51 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:51 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:                                     [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:25:51 localhost kernel:                                     [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:25:51 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:51 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:51 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:51 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:51 localhost kernel:        }
Feb 18 17:25:51 localhost kernel:        ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:25:51 localhost kernel:       ... acquired at:
Feb 18 17:25:51 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:25:51 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:51 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:25:51 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:51 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:25:51 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:25:51 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:51 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:51 localhost kernel: 
Feb 18 17:25:51 localhost kernel:      ... acquired at:
Feb 18 17:25:51 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:51 localhost kernel:    [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:25:52 localhost kernel:    [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:25:52 localhost kernel:    [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:52 localhost kernel:    [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:52 localhost kernel:    [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:52 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:52 localhost kernel: 
Feb 18 17:25:52 localhost kernel:      -> (&rq->rq_lock_key#4){++..} ops: 1787266 {
Feb 18 17:25:52 localhost kernel:         initial-use  at:
Feb 18 17:25:52 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:52 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:52 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:52 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:25:52 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:52 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:52 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:25:52 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:25:52 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:52 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:25:52 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:25:52 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:25:52 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:52 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:52 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:52 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:52 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:25:52 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:25:52 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:52 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:52 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:25:52 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:25:52 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:52 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:52 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:52 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:52 localhost kernel:         in-hardirq-W at:
Feb 18 17:25:52 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:25:52 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:52 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:52 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:53 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:53 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:53 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:53 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:53 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:25:53 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:25:53 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:25:53 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:25:53 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:25:53 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:25:53 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:53 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:25:53 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:53 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:25:53 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:25:53 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:25:53 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:53 localhost kernel:         in-softirq-W at:
Feb 18 17:25:53 localhost kernel:                                   [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:25:53 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:53 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:53 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:53 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:53 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:53 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:53 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:25:53 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:25:53 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:53 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:53 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:53 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:53 localhost kernel:       }
Feb 18 17:25:53 localhost kernel:       ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:25:53 localhost kernel:      ... acquired at:
Feb 18 17:25:53 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:53 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:53 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:53 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:53 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:53 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:53 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:53 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:25:54 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:54 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:25:54 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:54 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:25:54 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:25:54 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:54 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:54 localhost kernel: 
Feb 18 17:25:54 localhost kernel:     ... acquired at:
Feb 18 17:25:54 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:54 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:54 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:54 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:54 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:54 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:54 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:54 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:54 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 17:25:54 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 17:25:54 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 17:25:54 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:54 localhost kernel:    [<c043d502>] kthread+0x1c/0x5e
Feb 18 17:25:54 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:25:54 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:54 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:25:54 localhost kernel: 
Feb 18 17:25:54 localhost kernel:     -> (&rq->rq_lock_key#2){++..} ops: 1235688 {
Feb 18 17:25:54 localhost kernel:        initial-use  at:
Feb 18 17:25:54 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:54 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:54 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:54 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:25:54 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:54 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:54 localhost kernel:                                 [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:25:54 localhost kernel:                                 [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:25:54 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:54 localhost kernel:                                 [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:54 localhost kernel:                                 [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:25:54 localhost kernel:                                 [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:25:55 localhost kernel:                                 [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:25:55 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:55 localhost kernel:                                 [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:55 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:55 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:55 localhost kernel:                                 [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:25:55 localhost kernel:                                 [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:25:55 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:55 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:55 localhost kernel:                                 [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:25:55 localhost kernel:                                 [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:25:55 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:55 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:55 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:55 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:25:55 localhost kernel:        in-hardirq-W at:
Feb 18 17:25:55 localhost kernel:                                 [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:25:55 localhost kernel:                                 [<c040a9d6>] save_stack_trace+0x20/0x3a
Feb 18 17:25:55 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:25:55 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:55 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:55 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:55 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:55 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:55 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:55 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:55 localhost kernel:                                 [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:25:55 localhost kernel:                                 [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:25:55 localhost kernel:                                 [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:25:55 localhost kernel:                                 [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:25:55 localhost kernel:                                 [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:25:55 localhost kernel:                                 [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:25:55 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:55 localhost kernel:                                 [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:25:55 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:55 localhost kernel:                                 [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:25:55 localhost kernel:                                 [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:25:55 localhost kernel:                                 [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:25:55 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:25:55 localhost kernel:        in-softirq-W at:
Feb 18 17:25:55 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:56 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:56 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:56 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:56 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:56 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:56 localhost kernel:                                 [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:25:56 localhost kernel:                                 [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:25:56 localhost kernel:                                 [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:56 localhost kernel:                                 [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:56 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:56 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:25:56 localhost kernel:      }
Feb 18 17:25:56 localhost kernel:      ... key      at: [<c2a2b488>] 0xc2a2b488
Feb 18 17:25:56 localhost kernel:      -> (&rq->rq_lock_key#3){++..} ops: 1928539 {
Feb 18 17:25:56 localhost kernel:         initial-use  at:
Feb 18 17:25:56 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:56 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:56 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:56 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:25:56 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:56 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:56 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:25:56 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:25:56 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:56 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:25:56 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:25:56 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:25:56 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:56 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:56 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:56 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:56 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:25:56 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:25:56 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:56 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:56 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:25:56 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:25:56 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:56 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:56 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:56 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:56 localhost kernel:         in-hardirq-W at:
Feb 18 17:25:57 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:25:57 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:57 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:57 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:57 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:57 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:57 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:57 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:57 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:25:57 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:25:57 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:25:57 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:25:57 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:25:57 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:25:57 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:57 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:25:57 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:57 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:25:57 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:25:57 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:25:57 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:57 localhost kernel:         in-softirq-W at:
Feb 18 17:25:57 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:57 localhost kernel:                                   [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 17:25:57 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:57 localhost kernel:                                   [<c04422f1>] getnstimeofday+0x30/0xbc
Feb 18 17:25:57 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:57 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:57 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:57 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:57 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:57 localhost kernel:                                   [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:25:57 localhost kernel:                                   [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 17:25:57 localhost kernel:                                   [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:25:57 localhost kernel:                                   [<c0430afa>] __do_softirq+0xc9/0xde
Feb 18 17:25:57 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:57 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:25:57 localhost kernel:       }
Feb 18 17:25:57 localhost kernel:       ... key      at: [<c2a34488>] 0xc2a34488
Feb 18 17:25:57 localhost kernel:       -> (&rq->rq_lock_key#4){++..} ops: 1787266 {
Feb 18 17:25:58 localhost kernel:          initial-use  at:
Feb 18 17:25:58 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:25:58 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:58 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:58 localhost kernel:                                     [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:25:58 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:58 localhost kernel:                                     [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:25:58 localhost kernel:                                     [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:25:58 localhost kernel:                                     [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:25:58 localhost kernel:                                     [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:25:58 localhost kernel:                                     [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:25:58 localhost kernel:                                     [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:25:58 localhost kernel:                                     [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:25:58 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:58 localhost kernel:                                     [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:25:58 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:58 localhost kernel:                                     [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:25:58 localhost kernel:                                     [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:25:58 localhost kernel:                                     [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:25:58 localhost kernel:                                     [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:25:58 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:58 localhost kernel:                                     [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:25:58 localhost kernel:                                     [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:25:58 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:58 localhost kernel:                                     [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:25:58 localhost kernel:                                     [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:25:58 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:58 localhost kernel:          in-hardirq-W at:
Feb 18 17:25:58 localhost kernel:                                     [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:25:58 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:58 localhost kernel:                                     [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:25:58 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:58 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:58 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:58 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:58 localhost kernel:                                     [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:25:58 localhost kernel:                                     [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:25:58 localhost kernel:                                     [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:25:58 localhost kernel:                                     [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:25:58 localhost kernel:                                     [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:25:58 localhost kernel:                                     [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:25:59 localhost kernel:                                     [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:25:59 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:59 localhost kernel:                                     [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:25:59 localhost kernel:                                     [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:25:59 localhost kernel:                                     [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:25:59 localhost kernel:                                     [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:25:59 localhost kernel:                                     [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:25:59 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:59 localhost kernel:          in-softirq-W at:
Feb 18 17:25:59 localhost kernel:                                     [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:25:59 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:25:59 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:59 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:59 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:59 localhost openl2tpd: Loading plugin ppp_unix.so, version V1.0
Feb 18 17:25:59 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:59 localhost openl2tpd[14004]: Start, trace_flags=00000000
Feb 18 17:25:59 localhost kernel:                                     [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:59 localhost openl2tpd[14004]: OpenL2TP V1.0, (c) Copyright 2004,2005,2006,2007,2008 Katalix Systems Ltd.
Feb 18 17:25:59 localhost kernel:                                     [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:25:59 localhost kernel:                                     [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:25:59 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:25:59 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:25:59 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:25:59 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:25:59 localhost kernel:        }
Feb 18 17:25:59 localhost kernel:        ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:25:59 localhost kernel:       ... acquired at:
Feb 18 17:25:59 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:25:59 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:59 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:25:59 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:59 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:25:59 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:59 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:25:59 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:25:59 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:59 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:25:59 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:25:59 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:25:59 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:00 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:00 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:00 localhost kernel: 
Feb 18 17:26:00 localhost kernel:      ... acquired at:
Feb 18 17:26:00 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:00 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:00 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:00 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:00 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:00 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:00 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:00 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:26:00 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:00 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:26:00 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:00 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:00 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:00 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:00 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:00 localhost kernel: 
Feb 18 17:26:00 localhost kernel:      -> (&rq->rq_lock_key#4){++..} ops: 1787266 {
Feb 18 17:26:00 localhost kernel:         initial-use  at:
Feb 18 17:26:00 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:00 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:00 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:00 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:00 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:00 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:00 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:26:00 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:26:00 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:26:00 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:26:00 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:26:00 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:26:00 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:00 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:00 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:00 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:00 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:26:00 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:26:01 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:01 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:01 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:26:01 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:26:01 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:01 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:01 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:01 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:01 localhost kernel:         in-hardirq-W at:
Feb 18 17:26:01 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:26:01 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:01 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:01 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:01 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:01 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:01 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:01 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:01 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:26:01 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:26:01 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:26:01 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:26:01 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:26:01 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:26:01 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:01 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:26:01 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:01 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:26:01 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:26:01 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:26:01 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:01 localhost kernel:         in-softirq-W at:
Feb 18 17:26:01 localhost kernel:                                   [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:26:01 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:01 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:01 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:01 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:01 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:01 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:01 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:26:01 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:26:01 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:26:01 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:02 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:02 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:02 localhost kernel:       }
Feb 18 17:26:02 localhost kernel:       ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:26:02 localhost kernel:      ... acquired at:
Feb 18 17:26:02 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:02 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:02 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:02 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:02 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:02 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:02 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:02 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:26:02 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:02 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:26:02 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:02 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:02 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:02 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:02 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:02 localhost kernel: 
Feb 18 17:26:02 localhost kernel:     ... acquired at:
Feb 18 17:26:02 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:02 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:02 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:02 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:02 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:02 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:02 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:02 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 17:26:02 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 17:26:02 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 17:26:02 localhost kernel:    [<c043aad8>] worker_thread+0x0/0xc4
Feb 18 17:26:02 localhost kernel:    [<c043d502>] kthread+0x1c/0x5e
Feb 18 17:26:02 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:02 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:02 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:02 localhost kernel: 
Feb 18 17:26:02 localhost kernel:     -> (&rq->rq_lock_key#3){++..} ops: 1928539 {
Feb 18 17:26:02 localhost kernel:        initial-use  at:
Feb 18 17:26:02 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:03 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:03 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:03 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:03 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:03 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:03 localhost kernel:                                 [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:26:03 localhost kernel:                                 [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:26:03 localhost kernel:                                 [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:26:03 localhost kernel:                                 [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:26:03 localhost kernel:                                 [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:26:03 localhost kernel:                                 [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:26:03 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:03 localhost kernel:                                 [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:03 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:03 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:03 localhost kernel:                                 [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:26:03 localhost kernel:                                 [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:26:03 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:03 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:03 localhost kernel:                                 [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:26:03 localhost kernel:                                 [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:26:03 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:03 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:03 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:03 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:03 localhost kernel:        in-hardirq-W at:
Feb 18 17:26:03 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:26:03 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:03 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:03 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:03 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:03 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:03 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:03 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:03 localhost kernel:                                 [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:26:03 localhost kernel:                                 [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:26:03 localhost kernel:                                 [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:26:03 localhost kernel:                                 [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:26:03 localhost kernel:                                 [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:26:03 localhost kernel:                                 [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:26:03 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:04 localhost kernel:                                 [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:26:04 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:04 localhost kernel:                                 [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:26:04 localhost kernel:                                 [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:26:04 localhost kernel:                                 [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:26:04 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:04 localhost kernel:        in-softirq-W at:
Feb 18 17:26:04 localhost kernel:                                 [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:26:04 localhost kernel:                                 [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 17:26:04 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:04 localhost kernel:                                 [<c04422f1>] getnstimeofday+0x30/0xbc
Feb 18 17:26:04 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:04 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:04 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:04 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:04 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:04 localhost kernel:                                 [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:04 localhost kernel:                                 [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 17:26:04 localhost kernel:                                 [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:04 localhost kernel:                                 [<c0430afa>] __do_softirq+0xc9/0xde
Feb 18 17:26:04 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:04 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:04 localhost kernel:      }
Feb 18 17:26:04 localhost kernel:      ... key      at: [<c2a34488>] 0xc2a34488
Feb 18 17:26:04 localhost kernel:      -> (&rq->rq_lock_key#4){++..} ops: 1787266 {
Feb 18 17:26:04 localhost kernel:         initial-use  at:
Feb 18 17:26:04 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:04 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:04 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:04 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:04 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:04 localhost kernel:                                   [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:04 localhost kernel:                                   [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:26:04 localhost kernel:                                   [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:26:04 localhost kernel:                                   [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:26:04 localhost kernel:                                   [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:26:04 localhost kernel:                                   [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:26:04 localhost kernel:                                   [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:26:04 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:04 localhost kernel:                                   [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:04 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:05 localhost kernel:                                   [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:05 localhost kernel:                                   [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:26:05 localhost kernel:                                   [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:26:05 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:05 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:05 localhost kernel:                                   [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:26:05 localhost kernel:                                   [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:26:05 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:05 localhost kernel:                                   [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:05 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:05 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:05 localhost kernel:         in-hardirq-W at:
Feb 18 17:26:05 localhost kernel:                                   [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:26:05 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:05 localhost kernel:                                   [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:05 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:05 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:05 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:05 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:05 localhost kernel:                                   [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:05 localhost kernel:                                   [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:26:05 localhost kernel:                                   [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:26:05 localhost kernel:                                   [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:26:05 localhost kernel:                                   [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:26:05 localhost kernel:                                   [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:26:05 localhost kernel:                                   [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:26:05 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:05 localhost kernel:                                   [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:26:05 localhost kernel:                                   [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:05 localhost kernel:                                   [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:26:05 localhost kernel:                                   [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:26:05 localhost kernel:                                   [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:26:05 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:05 localhost kernel:         in-softirq-W at:
Feb 18 17:26:05 localhost kernel:                                   [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:26:05 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:05 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:05 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:05 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:05 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:05 localhost kernel:                                   [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:05 localhost kernel:                                   [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:26:06 localhost kernel:                                   [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:26:06 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:26:06 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:06 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:06 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:06 localhost kernel:       }
Feb 18 17:26:06 localhost kernel:       ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:26:06 localhost kernel:      ... acquired at:
Feb 18 17:26:06 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:06 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:06 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:06 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:06 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:06 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:06 localhost kernel:    [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:06 localhost kernel:    [<c04231b1>] __migrate_task+0x45/0xc0
Feb 18 17:26:06 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:06 localhost kernel:    [<c0428988>] migration_thread+0x178/0x1d2
Feb 18 17:26:06 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:06 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:06 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:06 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:06 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:06 localhost kernel: 
Feb 18 17:26:06 localhost kernel:     ... acquired at:
Feb 18 17:26:06 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:06 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:06 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:06 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:06 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:06 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:06 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:06 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 17:26:06 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 17:26:06 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 17:26:06 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:06 localhost kernel:    [<c0428996>] migration_thread+0x186/0x1d2
Feb 18 17:26:06 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:06 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:06 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:07 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:07 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:07 localhost kernel: 
Feb 18 17:26:07 localhost kernel:     -> (&rq->rq_lock_key#4){++..} ops: 1787266 {
Feb 18 17:26:07 localhost kernel:        initial-use  at:
Feb 18 17:26:07 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:07 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:07 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:07 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:07 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:07 localhost kernel:                                 [<c0423559>] init_idle+0x77/0xa1
Feb 18 17:26:07 localhost kernel:                                 [<c042b8d9>] fork_idle+0x45/0x4d
Feb 18 17:26:07 localhost kernel:                                 [<c04191c1>] do_boot_cpu+0x3d/0x4b9
Feb 18 17:26:07 localhost kernel:                                 [<c04eb4c4>] __next_cpu+0x12/0x21
Feb 18 17:26:07 localhost kernel:                                 [<c041aa84>] setup_local_APIC+0x27f/0x28f
Feb 18 17:26:07 localhost kernel:                                 [<c075a26f>] verify_local_APIC+0x89/0x137
Feb 18 17:26:07 localhost kernel:                                 [<c07593e0>] native_smp_prepare_cpus+0x34b/0x4a3
Feb 18 17:26:07 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:07 localhost kernel:                                 [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:07 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:07 localhost kernel:                                 [<c04284c5>] set_cpus_allowed+0x85/0x8d
Feb 18 17:26:07 localhost kernel:                                 [<c0427e1d>] finish_task_switch+0x50/0xbb
Feb 18 17:26:07 localhost kernel:                                 [<c061b505>] _spin_unlock_irq+0x20/0x23
Feb 18 17:26:07 localhost kernel:                                 [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:07 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:07 localhost kernel:                                 [<c074e399>] kernel_init+0x50/0x2af
Feb 18 17:26:07 localhost kernel:                                 [<c0404f5b>] restore_nocheck+0x12/0x15
Feb 18 17:26:07 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:07 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:07 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:07 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:07 localhost kernel:        in-hardirq-W at:
Feb 18 17:26:07 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:26:07 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:07 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:07 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:07 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:07 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:07 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:07 localhost kernel:                                 [<c0427ec7>] scheduler_tick+0x3f/0x19d
Feb 18 17:26:07 localhost kernel:                                 [<c0434365>] update_process_times+0x3a/0x44
Feb 18 17:26:08 localhost kernel:                                 [<c04449ea>] tick_periodic+0x63/0x6d
Feb 18 17:26:08 localhost kernel:                                 [<c0444a0b>] tick_handle_periodic+0x17/0x5c
Feb 18 17:26:08 localhost kernel:                                 [<c0445962>] tick_nohz_stop_sched_tick+0x294/0x2a1
Feb 18 17:26:08 localhost kernel:                                 [<c041af93>] smp_apic_timer_interrupt+0x6f/0x80
Feb 18 17:26:08 localhost kernel:                                 [<c04059e1>] apic_timer_interrupt+0x29/0x38
Feb 18 17:26:08 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:08 localhost kernel:                                 [<c04059eb>] apic_timer_interrupt+0x33/0x38
Feb 18 17:26:08 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:08 localhost kernel:                                 [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:26:08 localhost kernel:                                 [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:26:08 localhost kernel:                                 [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:26:08 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:08 localhost kernel:        in-softirq-W at:
Feb 18 17:26:08 localhost kernel:                                 [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:26:08 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:08 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:08 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:08 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:08 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:08 localhost kernel:                                 [<c0423141>] double_rq_lock+0x30/0x40
Feb 18 17:26:08 localhost kernel:                                 [<c0425611>] rebalance_domains+0x182/0x393
Feb 18 17:26:08 localhost kernel:                                 [<c0429203>] run_rebalance_domains+0x28/0x99
Feb 18 17:26:08 localhost kernel:                                 [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:26:08 localhost kernel:                                 [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:08 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:08 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:08 localhost kernel:      }
Feb 18 17:26:08 localhost kernel:      ... key      at: [<c2a3d488>] 0xc2a3d488
Feb 18 17:26:08 localhost kernel:     ... acquired at:
Feb 18 17:26:08 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:08 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:08 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:08 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:08 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:08 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:08 localhost kernel:    [<c0423379>] task_rq_lock+0x2d/0x50
Feb 18 17:26:08 localhost kernel:    [<c04250c8>] try_to_wake_up+0x19/0x3c5
Feb 18 17:26:08 localhost kernel:    [<c0421394>] __wake_up_common+0x32/0x5c
Feb 18 17:26:08 localhost kernel:    [<c04235fe>] complete+0x36/0x44
Feb 18 17:26:08 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:09 localhost kernel:    [<c0428996>] migration_thread+0x186/0x1d2
Feb 18 17:26:09 localhost kernel:    [<c0428810>] migration_thread+0x0/0x1d2
Feb 18 17:26:09 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:09 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:09 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:09 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:09 localhost kernel: 
Feb 18 17:26:09 localhost kernel:    ... acquired at:
Feb 18 17:26:09 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:09 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 17:26:09 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:09 localhost kernel:    [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:09 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:09 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 17:26:09 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:09 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 17:26:09 localhost kernel:    [<c042366f>] __wake_up+0x18/0x42
Feb 18 17:26:09 localhost kernel:    [<f8bb7a2b>] ppp_receive_nonmp_frame+0x51f/0x70a [ppp_generic]
Feb 18 17:26:09 localhost kernel:    [<f8bb8487>] ppp_input+0xbf/0xef [ppp_generic]
Feb 18 17:26:09 localhost kernel:    [<f8bbf263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 17:26:09 localhost kernel:    [<f8bbf37a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 17:26:09 localhost kernel:    [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:26:09 localhost kernel:    [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 17:26:09 localhost kernel:    [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 17:26:09 localhost kernel:    [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 17:26:09 localhost kernel:    [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 17:26:09 localhost kernel:    [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 17:26:09 localhost kernel:    [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:09 localhost kernel:    [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 17:26:09 localhost kernel:    [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 17:26:09 localhost kernel:    [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:09 localhost kernel:    [<f89637c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 17:26:09 localhost kernel:    [<f8963453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 17:26:09 localhost kernel:    [<f8960f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 17:26:09 localhost kernel:    [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 17:26:09 localhost kernel:    [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 17:26:09 localhost kernel:    [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:09 localhost kernel:    [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:09 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:09 localhost kernel: 
Feb 18 17:26:09 localhost kernel:   ... acquired at:
Feb 18 17:26:09 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:10 localhost kernel:    [<f8bb6bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 17:26:10 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:10 localhost kernel:    [<f8bb6bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 17:26:10 localhost kernel:    [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:10 localhost kernel:    [<f8bb6bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 17:26:10 localhost kernel:    [<f8bb6bc0>] ppp_ioctl+0x523/0xc06 [ppp_generic]
Feb 18 17:26:10 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 17:26:10 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:10 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:10 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 17:26:10 localhost kernel:    [<c0425474>] default_wake_function+0x0/0x8
Feb 18 17:26:10 localhost kernel:    [<c061ae17>] __down_failed+0x7/0xc
Feb 18 17:26:10 localhost kernel:    [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 17:26:10 localhost kernel:    [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 17:26:10 localhost kernel:    [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 17:26:10 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:10 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:10 localhost kernel: 
Feb 18 17:26:10 localhost kernel:   -> (&list->lock#8){.+..} ops: 46 {
Feb 18 17:26:10 localhost kernel:      initial-use  at:
Feb 18 17:26:10 localhost kernel:                             [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:10 localhost kernel:                             [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:10 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:10 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:10 localhost kernel:                             [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:10 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:10 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:10 localhost kernel:                             [<f8bb8433>] ppp_input+0x6b/0xef [ppp_generic]
Feb 18 17:26:10 localhost kernel:                             [<f8bbf263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 17:26:10 localhost kernel:                             [<f8bbf37a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 17:26:10 localhost kernel:                             [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:26:10 localhost kernel:                             [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 17:26:10 localhost kernel:                             [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 17:26:10 localhost kernel:                             [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 17:26:10 localhost kernel:                             [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 17:26:10 localhost kernel:                             [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 17:26:10 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:10 localhost kernel:                             [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 17:26:10 localhost kernel:                             [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 17:26:10 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:10 localhost kernel:                             [<f89637c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 17:26:11 localhost kernel:                             [<f8963453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 17:26:11 localhost kernel:                             [<f8960f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 17:26:11 localhost kernel:                             [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 17:26:11 localhost kernel:                             [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 17:26:11 localhost kernel:                             [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:11 localhost kernel:                             [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:11 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 17:26:11 localhost kernel:      in-softirq-W at:
Feb 18 17:26:11 localhost kernel:                             [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:11 localhost kernel:                             [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:11 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:11 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:11 localhost kernel:                             [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:11 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:11 localhost kernel:                             [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:11 localhost kernel:                             [<f8bb8433>] ppp_input+0x6b/0xef [ppp_generic]
Feb 18 17:26:11 localhost kernel:                             [<f8bbf263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 17:26:11 localhost kernel:                             [<f8bbf37a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 17:26:11 localhost kernel:                             [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:26:11 localhost kernel:                             [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 17:26:11 localhost kernel:                             [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 17:26:11 localhost kernel:                             [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 17:26:11 localhost kernel:                             [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 17:26:11 localhost kernel:                             [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 17:26:11 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:11 localhost kernel:                             [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 17:26:11 localhost kernel:                             [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 17:26:11 localhost kernel:                             [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:11 localhost kernel:                             [<f89637c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 17:26:11 localhost kernel:                             [<f8963453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 17:26:11 localhost kernel:                             [<f8960f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 17:26:11 localhost kernel:                             [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 17:26:11 localhost kernel:                             [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 17:26:11 localhost kernel:                             [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:11 localhost kernel:                             [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:11 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 17:26:11 localhost kernel:    }
Feb 18 17:26:11 localhost kernel:    ... key      at: [<f8bbcd18>] __key.21159+0x0/0xffffb82a [ppp_generic]
Feb 18 17:26:11 localhost kernel:   ... acquired at:
Feb 18 17:26:11 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:11 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:12 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:12 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:12 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:12 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:12 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:12 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:12 localhost kernel:    [<f8bb6424>] ppp_xmit_process+0x529/0x5a1 [ppp_generic]
Feb 18 17:26:12 localhost kernel:    [<f8bb734b>] ppp_channel_push+0x71/0x90 [ppp_generic]
Feb 18 17:26:12 localhost kernel:    [<c061b373>] _read_lock_bh+0x2e/0x39
Feb 18 17:26:12 localhost kernel:    [<f8bb735a>] ppp_channel_push+0x80/0x90 [ppp_generic]
Feb 18 17:26:12 localhost kernel:    [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:12 localhost kernel:    [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:12 localhost kernel:    [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:12 localhost kernel:    [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:12 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:12 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:12 localhost kernel: 
Feb 18 17:26:12 localhost kernel:   -> (&pch->downl){-...} ops: 8 {
Feb 18 17:26:12 localhost kernel:      initial-use  at:
Feb 18 17:26:12 localhost kernel:                             [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:12 localhost kernel:                             [<c046b874>] __do_fault+0x31b/0x35d
Feb 18 17:26:12 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:12 localhost kernel:                             [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:26:12 localhost kernel:                             [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:12 localhost kernel:                             [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:26:12 localhost kernel:                             [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:26:12 localhost kernel:                             [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:12 localhost kernel:                             [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:12 localhost kernel:                             [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:12 localhost kernel:                             [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:12 localhost kernel:                             [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:12 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 17:26:12 localhost kernel:      hardirq-on-W at:
Feb 18 17:26:12 localhost kernel:                             [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 17:26:12 localhost kernel:                             [<c046b874>] __do_fault+0x31b/0x35d
Feb 18 17:26:12 localhost kernel:                             [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:12 localhost kernel:                             [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:26:12 localhost kernel:                             [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:13 localhost kernel:                             [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:26:13 localhost kernel:                             [<f8bb72ed>] ppp_channel_push+0x13/0x90 [ppp_generic]
Feb 18 17:26:13 localhost kernel:                             [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:13 localhost kernel:                             [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:13 localhost kernel:                             [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:13 localhost kernel:                             [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:13 localhost kernel:                             [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:13 localhost kernel:                             [<ffffffff>] 0xffffffff
Feb 18 17:26:13 localhost kernel:    }
Feb 18 17:26:13 localhost kernel:    ... key      at: [<f8bbcd28>] __key.29740+0x0/0xffffb81a [ppp_generic]
Feb 18 17:26:13 localhost kernel:    -> (&list->lock#8){.+..} ops: 46 {
Feb 18 17:26:13 localhost kernel:       initial-use  at:
Feb 18 17:26:13 localhost kernel:                               [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:13 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:13 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:13 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:13 localhost kernel:                               [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:13 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:13 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:13 localhost kernel:                               [<f8bb8433>] ppp_input+0x6b/0xef [ppp_generic]
Feb 18 17:26:13 localhost kernel:                               [<f8bbf263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 17:26:13 localhost kernel:                               [<f8bbf37a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 17:26:13 localhost kernel:                               [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:26:13 localhost kernel:                               [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 17:26:13 localhost kernel:                               [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 17:26:13 localhost kernel:                               [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 17:26:13 localhost kernel:                               [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 17:26:13 localhost kernel:                               [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 17:26:13 localhost kernel:                               [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:13 localhost kernel:                               [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 17:26:13 localhost kernel:                               [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 17:26:13 localhost kernel:                               [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:13 localhost kernel:                               [<f89637c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 17:26:13 localhost kernel:                               [<f8963453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 17:26:13 localhost kernel:                               [<f8960f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 17:26:13 localhost kernel:                               [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 17:26:13 localhost kernel:                               [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 17:26:13 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:13 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:13 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:13 localhost kernel:       in-softirq-W at:
Feb 18 17:26:14 localhost kernel:                               [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:14 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:14 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:14 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:14 localhost kernel:                               [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:14 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:14 localhost kernel:                               [<c05b0641>] skb_queue_tail+0x11/0x2d
Feb 18 17:26:14 localhost kernel:                               [<f8bb8433>] ppp_input+0x6b/0xef [ppp_generic]
Feb 18 17:26:14 localhost kernel:                               [<f8bbf263>] pppol2tp_recv_core+0x75c/0x82d [pppol2tp]
Feb 18 17:26:14 localhost kernel:                               [<f8bbf37a>] pppol2tp_udp_encap_recv+0x46/0x65 [pppol2tp]
Feb 18 17:26:14 localhost kernel:                               [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:26:14 localhost kernel:                               [<c05ef9df>] udp_queue_rcv_skb+0xba/0x259
Feb 18 17:26:14 localhost kernel:                               [<c05efffe>] __udp4_lib_rcv+0x480/0x758
Feb 18 17:26:14 localhost kernel:                               [<c05d2c4b>] ip_local_deliver_finish+0x13f/0x1f8
Feb 18 17:26:14 localhost kernel:                               [<c05d2b3a>] ip_local_deliver_finish+0x2e/0x1f8
Feb 18 17:26:14 localhost kernel:                               [<c05d2ad2>] ip_rcv_finish+0x2fe/0x338
Feb 18 17:26:14 localhost kernel:                               [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:14 localhost kernel:                               [<c05d2dc6>] ip_rcv+0x0/0x237
Feb 18 17:26:14 localhost kernel:                               [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 17:26:14 localhost kernel:                               [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:14 localhost kernel:                               [<f89637c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 17:26:14 localhost kernel:                               [<f8963453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 17:26:14 localhost kernel:                               [<f8960f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 17:26:14 localhost kernel:                               [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 17:26:14 localhost kernel:                               [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 17:26:14 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:14 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:14 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:14 localhost kernel:     }
Feb 18 17:26:14 localhost kernel:     ... key      at: [<f8bbcd18>] __key.21159+0x0/0xffffb82a [ppp_generic]
Feb 18 17:26:14 localhost kernel:    ... acquired at:
Feb 18 17:26:14 localhost kernel:    [<c0446b6a>] add_lock_to_list+0x66/0x89
Feb 18 17:26:14 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:14 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:14 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:14 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:14 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:14 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:14 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:14 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:14 localhost kernel:    [<f8bb72ff>] ppp_channel_push+0x25/0x90 [ppp_generic]
Feb 18 17:26:14 localhost kernel:    [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:14 localhost kernel:    [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:15 localhost kernel:    [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:15 localhost kernel:    [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:15 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:15 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:15 localhost kernel: 
Feb 18 17:26:15 localhost kernel:    -> (inet_peer_idlock){-+..} ops: 1947 {
Feb 18 17:26:15 localhost kernel:       initial-use  at:
Feb 18 17:26:15 localhost kernel:                               [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:26:15 localhost kernel:                               [<c05d0e17>] rt_bind_peer+0x1b/0x50
Feb 18 17:26:15 localhost kernel:                               [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:15 localhost kernel:                               [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:15 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:15 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:15 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:15 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:15 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:15 localhost kernel:                               [<c05d4ea2>] ip_push_pending_frames+0x206/0x33b
Feb 18 17:26:15 localhost kernel:                               [<c05f368d>] icmp_send+0x310/0x386
Feb 18 17:26:15 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:15 localhost kernel:                               [<c05bcd7a>] neigh_timer_handler+0x14/0x276
Feb 18 17:26:15 localhost kernel:                               [<c05ce07c>] ipv4_link_failure+0x1c/0x44
Feb 18 17:26:15 localhost kernel:                               [<c05f1375>] arp_error_report+0x1c/0x24
Feb 18 17:26:15 localhost kernel:                               [<c05bcf16>] neigh_timer_handler+0x1b0/0x276
Feb 18 17:26:15 localhost kernel:                               [<c05bcd66>] neigh_timer_handler+0x0/0x276
Feb 18 17:26:15 localhost kernel:                               [<c0433d67>] run_timer_softirq+0x121/0x188
Feb 18 17:26:15 localhost kernel:                               [<c05bcd66>] neigh_timer_handler+0x0/0x276
Feb 18 17:26:15 localhost kernel:                               [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:15 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:15 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:15 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:15 localhost kernel:       in-softirq-W at:
Feb 18 17:26:15 localhost kernel:                               [<c0446ab0>] save_trace+0x37/0x8b
Feb 18 17:26:15 localhost kernel:                               [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:26:15 localhost kernel:                               [<c05d0e17>] rt_bind_peer+0x1b/0x50
Feb 18 17:26:15 localhost kernel:                               [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:15 localhost kernel:                               [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:15 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:15 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:15 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:15 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:15 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:15 localhost kernel:                               [<c05d4ea2>] ip_push_pending_frames+0x206/0x33b
Feb 18 17:26:16 localhost kernel:                               [<c05f368d>] icmp_send+0x310/0x386
Feb 18 17:26:16 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:16 localhost kernel:                               [<c05bcd7a>] neigh_timer_handler+0x14/0x276
Feb 18 17:26:16 localhost kernel:                               [<c05ce07c>] ipv4_link_failure+0x1c/0x44
Feb 18 17:26:16 localhost kernel:                               [<c05f1375>] arp_error_report+0x1c/0x24
Feb 18 17:26:16 localhost kernel:                               [<c05bcf16>] neigh_timer_handler+0x1b0/0x276
Feb 18 17:26:16 localhost kernel:                               [<c05bcd66>] neigh_timer_handler+0x0/0x276
Feb 18 17:26:16 localhost kernel:                               [<c0433d67>] run_timer_softirq+0x121/0x188
Feb 18 17:26:16 localhost kernel:                               [<c05bcd66>] neigh_timer_handler+0x0/0x276
Feb 18 17:26:16 localhost kernel:                               [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:16 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:16 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:16 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:16 localhost kernel:       hardirq-on-W at:
Feb 18 17:26:16 localhost kernel:                               [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:26:16 localhost kernel:                               [<c05d0e17>] rt_bind_peer+0x1b/0x50
Feb 18 17:26:16 localhost kernel:                               [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 17:26:16 localhost kernel:                               [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:16 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:16 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:16 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:16 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:16 localhost kernel:                               [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:16 localhost kernel:                               [<c05d4ea2>] ip_push_pending_frames+0x206/0x33b
Feb 18 17:26:16 localhost kernel:                               [<c05f368d>] icmp_send+0x310/0x386
Feb 18 17:26:16 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:16 localhost kernel:                               [<c05bcd7a>] neigh_timer_handler+0x14/0x276
Feb 18 17:26:16 localhost kernel:                               [<c05ce07c>] ipv4_link_failure+0x1c/0x44
Feb 18 17:26:16 localhost kernel:                               [<c05f1375>] arp_error_report+0x1c/0x24
Feb 18 17:26:16 localhost kernel:                               [<c05bcf16>] neigh_timer_handler+0x1b0/0x276
Feb 18 17:26:16 localhost kernel:                               [<c05bcd66>] neigh_timer_handler+0x0/0x276
Feb 18 17:26:16 localhost kernel:                               [<c0433d67>] run_timer_softirq+0x121/0x188
Feb 18 17:26:16 localhost kernel:                               [<c05bcd66>] neigh_timer_handler+0x0/0x276
Feb 18 17:26:16 localhost kernel:                               [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:16 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:16 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:16 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:16 localhost kernel:     }
Feb 18 17:26:16 localhost kernel:     ... key      at: [<c07380f0>] inet_peer_idlock+0x10/0x1c
Feb 18 17:26:16 localhost kernel:    ... acquired at:
Feb 18 17:26:16 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:16 localhost kernel:    [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:17 localhost kernel:    [<c048d217>] __d_lookup+0x0/0x12a
Feb 18 17:26:17 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:17 localhost kernel:    [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:17 localhost kernel:    [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:17 localhost kernel:    [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:17 localhost kernel:    [<c05d1015>] __ip_select_ident+0x3b/0xaa
Feb 18 17:26:17 localhost kernel:    [<c043badc>] __kernel_text_address+0x18/0x23
Feb 18 17:26:17 localhost kernel:    [<c05d6ec6>] ip_queue_xmit+0x27b/0x34d
Feb 18 17:26:17 localhost kernel:    [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:17 localhost kernel:    [<c047a1bd>] kfree+0x9f/0xa6
Feb 18 17:26:17 localhost kernel:    [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:17 localhost kernel:    [<c05b0c83>] pskb_expand_head+0xde/0x144
Feb 18 17:26:17 localhost kernel:    [<f8bbf7bf>] pppol2tp_xmit+0x426/0x4a2 [pppol2tp]
Feb 18 17:26:17 localhost kernel:    [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:17 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:17 localhost kernel:    [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:17 localhost kernel:    [<f8bb730e>] ppp_channel_push+0x34/0x90 [ppp_generic]
Feb 18 17:26:17 localhost kernel:    [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:17 localhost kernel:    [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:17 localhost kernel:    [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:17 localhost kernel:    [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:17 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:17 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:17 localhost kernel: 
Feb 18 17:26:17 localhost kernel:    -> (&dev->queue_lock#2){-+..} ops: 47607 {
Feb 18 17:26:17 localhost kernel:       initial-use  at:
Feb 18 17:26:17 localhost kernel:                               [<c047a1bd>] kfree+0x9f/0xa6
Feb 18 17:26:17 localhost kernel:                               [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:17 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:17 localhost kernel:                               [<c05c47ad>] qdisc_lock_tree+0x14/0x1c
Feb 18 17:26:17 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:17 localhost kernel:                               [<c05c47ad>] qdisc_lock_tree+0x14/0x1c
Feb 18 17:26:17 localhost kernel:                               [<c05c47ad>] qdisc_lock_tree+0x14/0x1c
Feb 18 17:26:17 localhost kernel:                               [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:17 localhost kernel:                               [<c05b680a>] register_netdevice+0x29f/0x2f9
Feb 18 17:26:17 localhost kernel:                               [<c05b6893>] register_netdev+0x2f/0x3b
Feb 18 17:26:17 localhost kernel:                               [<c076aded>] loopback_net_init+0x36/0x68
Feb 18 17:26:17 localhost kernel:                               [<c05b3fa0>] register_pernet_operations+0x10/0x11
Feb 18 17:26:17 localhost kernel:                               [<c05b3ffc>] register_pernet_device+0x1c/0x48
Feb 18 17:26:17 localhost kernel:                               [<c074e491>] kernel_init+0x148/0x2af
Feb 18 17:26:17 localhost kernel:                               [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:18 localhost kernel:                               [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:18 localhost kernel:                               [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:18 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:18 localhost kernel:       in-softirq-W at:
Feb 18 17:26:18 localhost kernel:                               [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:18 localhost kernel:                               [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:18 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:18 localhost kernel:                               [<c05b7eb4>] dev_queue_xmit+0x179/0x2e9
Feb 18 17:26:18 localhost kernel:                               [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:18 localhost kernel:                               [<c05b7eb4>] dev_queue_xmit+0x179/0x2e9
Feb 18 17:26:18 localhost kernel:                               [<c05b7eb4>] dev_queue_xmit+0x179/0x2e9
Feb 18 17:26:18 localhost kernel:                               [<c05b7e60>] dev_queue_xmit+0x125/0x2e9
Feb 18 17:26:18 localhost kernel:                               [<c05c341e>] eth_header+0x0/0xb6
Feb 18 17:26:18 localhost kernel:                               [<f8f3a487>] mld_sendpack+0x242/0x355 [ipv6]
Feb 18 17:26:18 localhost kernel:                               [<f8f3b453>] mld_ifc_timer_expire+0x143/0x208 [ipv6]
Feb 18 17:26:18 localhost kernel:                               [<f8f3b4e5>] mld_ifc_timer_expire+0x1d5/0x208 [ipv6]
Feb 18 17:26:18 localhost kernel:                               [<f8f3b4f0>] mld_ifc_timer_expire+0x1e0/0x208 [ipv6]
Feb 18 17:26:18 localhost kernel:                               [<f8f3b310>] mld_ifc_timer_expire+0x0/0x208 [ipv6]
Feb 18 17:26:18 localhost kernel:                               [<c0433d67>] run_timer_softirq+0x121/0x188
Feb 18 17:26:18 localhost kernel:                               [<f8f3b310>] mld_ifc_timer_expire+0x0/0x208 [ipv6]
Feb 18 17:26:18 localhost kernel:                               [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:18 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:18 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:18 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:18 localhost kernel:       hardirq-on-W at:
Feb 18 17:26:18 localhost kernel:                               [<c047a1bd>] kfree+0x9f/0xa6
Feb 18 17:26:18 localhost kernel:                               [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 17:26:18 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:18 localhost kernel:                               [<c05c47ad>] qdisc_lock_tree+0x14/0x1c
Feb 18 17:26:18 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:18 localhost kernel:                               [<c05c47ad>] qdisc_lock_tree+0x14/0x1c
Feb 18 17:26:18 localhost kernel:                               [<c05c47ad>] qdisc_lock_tree+0x14/0x1c
Feb 18 17:26:18 localhost kernel:                               [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:18 localhost kernel:                               [<c05b680a>] register_netdevice+0x29f/0x2f9
Feb 18 17:26:18 localhost kernel:                               [<c05b6893>] register_netdev+0x2f/0x3b
Feb 18 17:26:18 localhost kernel:                               [<c076aded>] loopback_net_init+0x36/0x68
Feb 18 17:26:18 localhost kernel:                               [<c05b3fa0>] register_pernet_operations+0x10/0x11
Feb 18 17:26:18 localhost kernel:                               [<c05b3ffc>] register_pernet_device+0x1c/0x48
Feb 18 17:26:18 localhost kernel:                               [<c074e491>] kernel_init+0x148/0x2af
Feb 18 17:26:18 localhost kernel:                               [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:18 localhost kernel:                               [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:18 localhost kernel:                               [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:19 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:19 localhost kernel:     }
Feb 18 17:26:19 localhost kernel:     ... key      at: [<c0a3e1c4>] __key.31614+0x0/0x8
Feb 18 17:26:19 localhost kernel:     -> (&dev->ingress_lock){-...} ops: 208 {
Feb 18 17:26:19 localhost kernel:        initial-use  at:
Feb 18 17:26:19 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:19 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:19 localhost kernel:                                 [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:19 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:19 localhost kernel:                                 [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:19 localhost kernel:                                 [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:19 localhost kernel:                                 [<c05b680a>] register_netdevice+0x29f/0x2f9
Feb 18 17:26:19 localhost kernel:                                 [<c05b6893>] register_netdev+0x2f/0x3b
Feb 18 17:26:19 localhost kernel:                                 [<c076aded>] loopback_net_init+0x36/0x68
Feb 18 17:26:19 localhost kernel:                                 [<c05b3fa0>] register_pernet_operations+0x10/0x11
Feb 18 17:26:19 localhost kernel:                                 [<c05b3ffc>] register_pernet_device+0x1c/0x48
Feb 18 17:26:19 localhost kernel:                                 [<c074e491>] kernel_init+0x148/0x2af
Feb 18 17:26:19 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:19 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:19 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:19 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:19 localhost kernel:        hardirq-on-W at:
Feb 18 17:26:19 localhost kernel:                                 [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 17:26:19 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:19 localhost kernel:                                 [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:19 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:19 localhost kernel:                                 [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:19 localhost kernel:                                 [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:19 localhost kernel:                                 [<c05b680a>] register_netdevice+0x29f/0x2f9
Feb 18 17:26:19 localhost kernel:                                 [<c05b6893>] register_netdev+0x2f/0x3b
Feb 18 17:26:19 localhost kernel:                                 [<c076aded>] loopback_net_init+0x36/0x68
Feb 18 17:26:19 localhost kernel:                                 [<c05b3fa0>] register_pernet_operations+0x10/0x11
Feb 18 17:26:19 localhost kernel:                                 [<c05b3ffc>] register_pernet_device+0x1c/0x48
Feb 18 17:26:19 localhost kernel:                                 [<c074e491>] kernel_init+0x148/0x2af
Feb 18 17:26:19 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:19 localhost kernel:                                 [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:19 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:19 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:19 localhost kernel:      }
Feb 18 17:26:19 localhost kernel:      ... key      at: [<c0a3e1b4>] __key.31616+0x0/0x8
Feb 18 17:26:19 localhost kernel:      -> (&list->lock#6){....} ops: 675 {
Feb 18 17:26:19 localhost kernel:         initial-use  at:
Feb 18 17:26:19 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:19 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:20 localhost kernel:                                   [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:20 localhost kernel:                                   [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:20 localhost kernel:                                   [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:20 localhost kernel:                                   [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:20 localhost kernel:                                   [<c05b0afd>] skb_queue_purge+0x11/0x17
Feb 18 17:26:20 localhost kernel:                                   [<c05c4eca>] pfifo_fast_reset+0x14/0x2f
Feb 18 17:26:20 localhost kernel:                                   [<c05c4712>] qdisc_reset+0x10/0x11
Feb 18 17:26:20 localhost kernel:                                   [<c05c4b83>] dev_deactivate+0x2a/0xfd
Feb 18 17:26:20 localhost kernel:                                   [<c05bf1f4>] __linkwatch_run_queue+0x143/0x17a
Feb 18 17:26:20 localhost kernel:                                   [<c05bf248>] linkwatch_event+0x1d/0x22
Feb 18 17:26:20 localhost kernel:                                   [<c043a0f3>] run_workqueue+0xdb/0x1ae
Feb 18 17:26:20 localhost kernel:                                   [<c043a09f>] run_workqueue+0x87/0x1ae
Feb 18 17:26:20 localhost kernel:                                   [<c05bf22b>] linkwatch_event+0x0/0x22
Feb 18 17:26:20 localhost kernel:                                   [<c043aad8>] worker_thread+0x0/0xc4
Feb 18 17:26:20 localhost kernel:                                   [<c043ab92>] worker_thread+0xba/0xc4
Feb 18 17:26:20 localhost kernel:                                   [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 17:26:20 localhost kernel:                                   [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:20 localhost kernel:                                   [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:20 localhost kernel:                                   [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:20 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:20 localhost kernel:       }
Feb 18 17:26:20 localhost kernel:       ... key      at: [<c0a3e7d4>] __key.21167+0x0/0x8
Feb 18 17:26:20 localhost kernel:      ... acquired at:
Feb 18 17:26:20 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:20 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:20 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:20 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:20 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:20 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:20 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:20 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:20 localhost kernel:    [<c05b0afd>] skb_queue_purge+0x11/0x17
Feb 18 17:26:20 localhost kernel:    [<c05c4eca>] pfifo_fast_reset+0x14/0x2f
Feb 18 17:26:20 localhost kernel:    [<c05c48f7>] qdisc_destroy+0x36/0x69
Feb 18 17:26:20 localhost kernel:    [<c05c4954>] dev_shutdown+0x2a/0x7b
Feb 18 17:26:20 localhost kernel:    [<c05b6210>] rollback_registered+0xb8/0x11e
Feb 18 17:26:20 localhost kernel:    [<c05b627e>] unregister_netdevice+0x8/0x35
Feb 18 17:26:20 localhost kernel:    [<c05b62ba>] unregister_netdev+0xf/0x15
Feb 18 17:26:20 localhost kernel:    [<f8bb523f>] ppp_shutdown_interface+0x58/0xad [ppp_generic]
Feb 18 17:26:20 localhost kernel:    [<f8bb5484>] ppp_release+0x29/0x56 [ppp_generic]
Feb 18 17:26:20 localhost kernel:    [<c047f08a>] __fput+0xba/0x172
Feb 18 17:26:20 localhost kernel:    [<c047c7df>] filp_close+0x51/0x58
Feb 18 17:26:21 localhost kernel:    [<c047d9c4>] sys_close+0x70/0xab
Feb 18 17:26:21 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:21 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:21 localhost kernel: 
Feb 18 17:26:21 localhost kernel:     ... acquired at:
Feb 18 17:26:21 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:21 localhost kernel:    [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:21 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:21 localhost kernel:    [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:21 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:21 localhost kernel:    [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:21 localhost kernel:    [<c05c47d9>] dev_init_scheduler+0x8/0x4f
Feb 18 17:26:21 localhost kernel:    [<c05b680a>] register_netdevice+0x29f/0x2f9
Feb 18 17:26:21 localhost kernel:    [<c05b6893>] register_netdev+0x2f/0x3b
Feb 18 17:26:21 localhost kernel:    [<c076aded>] loopback_net_init+0x36/0x68
Feb 18 17:26:21 localhost kernel:    [<c05b3fa0>] register_pernet_operations+0x10/0x11
Feb 18 17:26:21 localhost kernel:    [<c05b3ffc>] register_pernet_device+0x1c/0x48
Feb 18 17:26:21 localhost kernel:    [<c074e491>] kernel_init+0x148/0x2af
Feb 18 17:26:21 localhost kernel:    [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:21 localhost kernel:    [<c074e349>] kernel_init+0x0/0x2af
Feb 18 17:26:21 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:21 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:21 localhost kernel: 
Feb 18 17:26:21 localhost kernel:     -> (&list->lock#6){....} ops: 675 {
Feb 18 17:26:21 localhost kernel:        initial-use  at:
Feb 18 17:26:21 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:21 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:21 localhost kernel:                                 [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:21 localhost kernel:                                 [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:21 localhost kernel:                                 [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:21 localhost kernel:                                 [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:21 localhost kernel:                                 [<c05b0afd>] skb_queue_purge+0x11/0x17
Feb 18 17:26:21 localhost kernel:                                 [<c05c4eca>] pfifo_fast_reset+0x14/0x2f
Feb 18 17:26:21 localhost kernel:                                 [<c05c4712>] qdisc_reset+0x10/0x11
Feb 18 17:26:21 localhost kernel:                                 [<c05c4b83>] dev_deactivate+0x2a/0xfd
Feb 18 17:26:21 localhost kernel:                                 [<c05bf1f4>] __linkwatch_run_queue+0x143/0x17a
Feb 18 17:26:21 localhost kernel:                                 [<c05bf248>] linkwatch_event+0x1d/0x22
Feb 18 17:26:21 localhost kernel:                                 [<c043a0f3>] run_workqueue+0xdb/0x1ae
Feb 18 17:26:21 localhost kernel:                                 [<c043a09f>] run_workqueue+0x87/0x1ae
Feb 18 17:26:21 localhost kernel:                                 [<c05bf22b>] linkwatch_event+0x0/0x22
Feb 18 17:26:21 localhost kernel:                                 [<c043aad8>] worker_thread+0x0/0xc4
Feb 18 17:26:21 localhost kernel:                                 [<c043ab92>] worker_thread+0xba/0xc4
Feb 18 17:26:22 localhost kernel:                                 [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 17:26:22 localhost kernel:                                 [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:22 localhost kernel:                                 [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:22 localhost kernel:                                 [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:22 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:22 localhost kernel:      }
Feb 18 17:26:22 localhost kernel:      ... key      at: [<c0a3e7d4>] __key.21167+0x0/0x8
Feb 18 17:26:22 localhost kernel:     ... acquired at:
Feb 18 17:26:22 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:22 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:22 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:22 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:22 localhost kernel:    [<c061b55d>] _spin_lock_irqsave+0x32/0x41
Feb 18 17:26:22 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:22 localhost kernel:    [<c05b06e1>] skb_dequeue+0xf/0x3f
Feb 18 17:26:22 localhost kernel:    [<c05b0afd>] skb_queue_purge+0x11/0x17
Feb 18 17:26:22 localhost kernel:    [<c05c4eca>] pfifo_fast_reset+0x14/0x2f
Feb 18 17:26:22 localhost kernel:    [<c05c4712>] qdisc_reset+0x10/0x11
Feb 18 17:26:22 localhost kernel:    [<c05c4b83>] dev_deactivate+0x2a/0xfd
Feb 18 17:26:22 localhost kernel:    [<c05bf1f4>] __linkwatch_run_queue+0x143/0x17a
Feb 18 17:26:22 localhost kernel:    [<c05bf248>] linkwatch_event+0x1d/0x22
Feb 18 17:26:22 localhost kernel:    [<c043a0f3>] run_workqueue+0xdb/0x1ae
Feb 18 17:26:22 localhost kernel:    [<c043a09f>] run_workqueue+0x87/0x1ae
Feb 18 17:26:22 localhost kernel:    [<c05bf22b>] linkwatch_event+0x0/0x22
Feb 18 17:26:22 localhost kernel:    [<c043aad8>] worker_thread+0x0/0xc4
Feb 18 17:26:22 localhost kernel:    [<c043ab92>] worker_thread+0xba/0xc4
Feb 18 17:26:22 localhost kernel:    [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 17:26:22 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:22 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:22 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:22 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:22 localhost kernel: 
Feb 18 17:26:22 localhost kernel:    ... acquired at:
Feb 18 17:26:22 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:22 localhost kernel:    [<c05b7eb4>] dev_queue_xmit+0x179/0x2e9
Feb 18 17:26:22 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:22 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:22 localhost kernel:    [<c05b7eb4>] dev_queue_xmit+0x179/0x2e9
Feb 18 17:26:22 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:22 localhost kernel:    [<c05b7eb4>] dev_queue_xmit+0x179/0x2e9
Feb 18 17:26:22 localhost kernel:    [<c05b7eb4>] dev_queue_xmit+0x179/0x2e9
Feb 18 17:26:22 localhost kernel:    [<c05b7e60>] dev_queue_xmit+0x125/0x2e9
Feb 18 17:26:23 localhost kernel:    [<c05d62e7>] ip_finish_output+0x1e6/0x21e
Feb 18 17:26:23 localhost kernel:    [<c05d6f58>] ip_queue_xmit+0x30d/0x34d
Feb 18 17:26:23 localhost kernel:    [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:23 localhost kernel:    [<c047a1bd>] kfree+0x9f/0xa6
Feb 18 17:26:23 localhost kernel:    [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:23 localhost kernel:    [<c05b0c83>] pskb_expand_head+0xde/0x144
Feb 18 17:26:23 localhost kernel:    [<f8bbf7bf>] pppol2tp_xmit+0x426/0x4a2 [pppol2tp]
Feb 18 17:26:23 localhost kernel:    [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:23 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:23 localhost kernel:    [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:23 localhost kernel:    [<f8bb730e>] ppp_channel_push+0x34/0x90 [ppp_generic]
Feb 18 17:26:23 localhost kernel:    [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:23 localhost kernel:    [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:23 localhost kernel:    [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:23 localhost kernel:    [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:23 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:23 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:23 localhost kernel: 
Feb 18 17:26:23 localhost kernel:    -> (&rt_hash_locks[i]){-+..} ops: 24708841 {
Feb 18 17:26:23 localhost kernel:       initial-use  at:
Feb 18 17:26:23 localhost kernel:                               [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:23 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:23 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:23 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:23 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:23 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:23 localhost kernel:                               [<c05f90b6>] ip_mc_inc_group+0x184/0x1c1
Feb 18 17:26:23 localhost kernel:                               [<c05f9134>] ip_mc_up+0x41/0x59
Feb 18 17:26:23 localhost kernel:                               [<c05f4f9f>] inetdev_event+0x257/0x46e
Feb 18 17:26:23 localhost kernel:                               [<c05c258a>] fib_rules_event+0x120/0x12a
Feb 18 17:26:23 localhost kernel:                               [<c05c24b4>] fib_rules_event+0x4a/0x12a
Feb 18 17:26:23 localhost kernel:                               [<c061d06c>] notifier_call_chain+0x2a/0x47
Feb 18 17:26:23 localhost kernel:                               [<c0441084>] raw_notifier_call_chain+0x17/0x1a
Feb 18 17:26:23 localhost kernel:                               [<c05b73cf>] dev_open+0x71/0x77
Feb 18 17:26:23 localhost kernel:                               [<c05b5ffa>] dev_change_flags+0x9d/0x149
Feb 18 17:26:23 localhost kernel:                               [<c05b49b5>] __dev_get_by_name+0x67/0x72
Feb 18 17:26:23 localhost kernel:                               [<c05f54f7>] devinet_ioctl+0x22e/0x539
Feb 18 17:26:23 localhost kernel:                               [<c05b7188>] dev_ioctl+0x46f/0x5e0
Feb 18 17:26:23 localhost kernel:                               [<c05ab078>] sock_ioctl+0x1bb/0x1e0
Feb 18 17:26:23 localhost kernel:                               [<c05aaebd>] sock_ioctl+0x0/0x1e0
Feb 18 17:26:23 localhost kernel:                               [<c0488827>] do_ioctl+0x1f/0x62
Feb 18 17:26:23 localhost kernel:                               [<c061ccb2>] do_page_fault+0x234/0x5c4
Feb 18 17:26:23 localhost kernel:                               [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 17:26:24 localhost kernel:                               [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 17:26:24 localhost kernel:                               [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 17:26:24 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:24 localhost kernel:       in-softirq-W at:
Feb 18 17:26:24 localhost kernel:                               [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:24 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:24 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:24 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c05cee70>] rt_run_flush+0x0/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c0433d67>] run_timer_softirq+0x121/0x188
Feb 18 17:26:24 localhost kernel:                               [<c05cee70>] rt_run_flush+0x0/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:24 localhost kernel:                               [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:24 localhost kernel:                               [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:24 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:24 localhost kernel:       hardirq-on-W at:
Feb 18 17:26:24 localhost kernel:                               [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 17:26:24 localhost kernel:                               [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:24 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:24 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c05ceeb3>] rt_run_flush+0x43/0x8b
Feb 18 17:26:24 localhost kernel:                               [<c05f90b6>] ip_mc_inc_group+0x184/0x1c1
Feb 18 17:26:24 localhost kernel:                               [<c05f9134>] ip_mc_up+0x41/0x59
Feb 18 17:26:24 localhost kernel:                               [<c05f4f9f>] inetdev_event+0x257/0x46e
Feb 18 17:26:24 localhost kernel:                               [<c05c258a>] fib_rules_event+0x120/0x12a
Feb 18 17:26:24 localhost kernel:                               [<c05c24b4>] fib_rules_event+0x4a/0x12a
Feb 18 17:26:24 localhost kernel:                               [<c061d06c>] notifier_call_chain+0x2a/0x47
Feb 18 17:26:24 localhost kernel:                               [<c0441084>] raw_notifier_call_chain+0x17/0x1a
Feb 18 17:26:24 localhost kernel:                               [<c05b73cf>] dev_open+0x71/0x77
Feb 18 17:26:24 localhost kernel:                               [<c05b5ffa>] dev_change_flags+0x9d/0x149
Feb 18 17:26:24 localhost kernel:                               [<c05b49b5>] __dev_get_by_name+0x67/0x72
Feb 18 17:26:24 localhost kernel:                               [<c05f54f7>] devinet_ioctl+0x22e/0x539
Feb 18 17:26:24 localhost kernel:                               [<c05b7188>] dev_ioctl+0x46f/0x5e0
Feb 18 17:26:24 localhost kernel:                               [<c05ab078>] sock_ioctl+0x1bb/0x1e0
Feb 18 17:26:24 localhost kernel:                               [<c05aaebd>] sock_ioctl+0x0/0x1e0
Feb 18 17:26:24 localhost kernel:                               [<c0488827>] do_ioctl+0x1f/0x62
Feb 18 17:26:24 localhost kernel:                               [<c061ccb2>] do_page_fault+0x234/0x5c4
Feb 18 17:26:24 localhost kernel:                               [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 17:26:24 localhost kernel:                               [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 17:26:24 localhost kernel:                               [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 17:26:25 localhost kernel:                               [<ffffffff>] 0xffffffff
Feb 18 17:26:25 localhost kernel:     }
Feb 18 17:26:25 localhost kernel:     ... key      at: [<c0a3ea90>] __key.39046+0x0/0x8
Feb 18 17:26:25 localhost kernel:     -> (&parent->list_lock){++..} ops: 252663 {
Feb 18 17:26:25 localhost kernel:        initial-use  at:
Feb 18 17:26:25 localhost kernel:                                 [<c040a9d6>] save_stack_trace+0x20/0x3a
Feb 18 17:26:25 localhost kernel:                                 [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:25 localhost kernel:                                 [<c043badc>] __kernel_text_address+0x18/0x23
Feb 18 17:26:25 localhost kernel:                                 [<c0448013>] check_usage_backwards+0x19/0x41
Feb 18 17:26:25 localhost kernel:                                 [<c0446ab0>] save_trace+0x37/0x8b
Feb 18 17:26:25 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:25 localhost kernel:                                 [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:25 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:25 localhost kernel:                                 [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:25 localhost kernel:                                 [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:25 localhost kernel:                                 [<c047b89c>] kmem_cache_create+0x62/0x38e
Feb 18 17:26:25 localhost kernel:                                 [<c047a790>] kmem_cache_alloc+0x53/0x9f
Feb 18 17:26:25 localhost kernel:                                 [<c047b99d>] kmem_cache_create+0x163/0x38e
Feb 18 17:26:25 localhost kernel:                                 [<c0479da2>] cache_estimate+0x6c/0x89
Feb 18 17:26:25 localhost kernel:                                 [<c0762241>] kmem_cache_init+0x182/0x3f6
Feb 18 17:26:25 localhost kernel:                                 [<c074e88b>] start_kernel+0x293/0x327
Feb 18 17:26:25 localhost kernel:                                 [<c074e0e0>] unknown_bootoption+0x0/0x195
Feb 18 17:26:25 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:25 localhost kernel:        in-hardirq-W at:
Feb 18 17:26:25 localhost kernel:                                 [<c0448fc0>] __lock_acquire+0x405/0xbf1
Feb 18 17:26:25 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:25 localhost kernel:                                 [<c047b7ec>] do_drain+0x1e/0x49
Feb 18 17:26:25 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:25 localhost kernel:                                 [<c047b7ec>] do_drain+0x1e/0x49
Feb 18 17:26:25 localhost kernel:                                 [<c047b7ec>] do_drain+0x1e/0x49
Feb 18 17:26:25 localhost kernel:                                 [<c047b7ce>] do_drain+0x0/0x49
Feb 18 17:26:25 localhost kernel:                                 [<c0418ed5>] smp_call_function_interrupt+0x37/0x62
Feb 18 17:26:25 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:25 localhost kernel:                                 [<c04059b3>] call_function_interrupt+0x33/0x38
Feb 18 17:26:25 localhost kernel:                                 [<c0403c9b>] default_idle+0x0/0x54
Feb 18 17:26:25 localhost kernel:                                 [<c041007b>] cyrix_get_arr+0xbc/0x126
Feb 18 17:26:25 localhost kernel:                                 [<c0403cd8>] default_idle+0x3d/0x54
Feb 18 17:26:25 localhost kernel:                                 [<c0403583>] cpu_idle+0x9f/0xc0
Feb 18 17:26:25 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:25 localhost kernel:        in-softirq-W at:
Feb 18 17:26:25 localhost kernel:                                 [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 17:26:25 localhost kernel:                                 [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:26 localhost kernel:                                 [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:26 localhost kernel:                                 [<c04488b6>] debug_check_no_locks_freed+0x105/0x11f
Feb 18 17:26:26 localhost kernel:                                 [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:26 localhost kernel:                                 [<c047a0a0>] cache_flusharray+0x22/0xa0
Feb 18 17:26:26 localhost kernel:                                 [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:26 localhost kernel:                                 [<c047a0a0>] cache_flusharray+0x22/0xa0
Feb 18 17:26:26 localhost kernel:                                 [<c047a0a0>] cache_flusharray+0x22/0xa0
Feb 18 17:26:26 localhost kernel:                                 [<c047a1fa>] kmem_cache_free+0x36/0x5e
Feb 18 17:26:26 localhost kernel:                                 [<c043b647>] __rcu_process_callbacks+0xfc/0x16e
Feb 18 17:26:26 localhost kernel:                                 [<c043b6d1>] rcu_process_callbacks+0x18/0x30
Feb 18 17:26:26 localhost kernel:                                 [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:26:26 localhost kernel:                                 [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:26 localhost kernel:                                 [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:26 localhost kernel:                                 [<ffffffff>] 0xffffffff
Feb 18 17:26:26 localhost kernel:      }
Feb 18 17:26:26 localhost kernel:      ... key      at: [<c0a2bbe8>] __key.19871+0x0/0x8
Feb 18 17:26:26 localhost kernel:      -> (&zone->lock){.+..} ops: 63132 {
Feb 18 17:26:26 localhost kernel:         initial-use  at:
Feb 18 17:26:26 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:26 localhost kernel:                                   [<c04ef19a>] number+0x147/0x215
Feb 18 17:26:26 localhost kernel:                                   [<c04efab1>] vsnprintf+0x440/0x47c
Feb 18 17:26:26 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:26 localhost kernel:                                   [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:26 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:26 localhost kernel:                                   [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:26 localhost kernel:                                   [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:26 localhost kernel:                                   [<c04645c0>] free_hot_cold_page+0x133/0x175
Feb 18 17:26:26 localhost kernel:                                   [<c07606b8>] free_all_bootmem_core+0xdd/0x158
Feb 18 17:26:26 localhost kernel:                                   [<c075d82e>] mem_init+0x8c/0x383
Feb 18 17:26:26 localhost kernel:                                   [<c042c8c7>] printk+0x1b/0x1f
Feb 18 17:26:26 localhost kernel:                                   [<c0761a7b>] alloc_large_system_hash+0x1f7/0x222
Feb 18 17:26:26 localhost kernel:                                   [<c04f2f65>] __spin_lock_init+0x29/0x49
Feb 18 17:26:26 localhost kernel:                                   [<c076287c>] inode_init_early+0x49/0x72
Feb 18 17:26:26 localhost kernel:                                   [<c074e886>] start_kernel+0x28e/0x327
Feb 18 17:26:26 localhost kernel:                                   [<c074e0e0>] unknown_bootoption+0x0/0x195
Feb 18 17:26:26 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:26 localhost kernel:         in-softirq-W at:
Feb 18 17:26:26 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:26 localhost kernel:                                   [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 17:26:26 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:26 localhost kernel:                                   [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:27 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:27 localhost kernel:                                   [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:27 localhost kernel:                                   [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:27 localhost kernel:                                   [<c04645c0>] free_hot_cold_page+0x133/0x175
Feb 18 17:26:27 localhost kernel:                                   [<c042a030>] free_task+0x18/0x25
Feb 18 17:26:27 localhost kernel:                                   [<c043b647>] __rcu_process_callbacks+0xfc/0x16e
Feb 18 17:26:27 localhost kernel:                                   [<c043b6d1>] rcu_process_callbacks+0x18/0x30
Feb 18 17:26:27 localhost kernel:                                   [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:26:27 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:27 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:27 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:27 localhost kernel:       }
Feb 18 17:26:27 localhost kernel:       ... key      at: [<c0a21fb8>] __key.25233+0x0/0x8
Feb 18 17:26:27 localhost kernel:      ... acquired at:
Feb 18 17:26:27 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:27 localhost kernel:    [<c046472e>] __free_pages_ok+0x101/0x2a8
Feb 18 17:26:27 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:27 localhost kernel:    [<c046472e>] __free_pages_ok+0x101/0x2a8
Feb 18 17:26:27 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:27 localhost kernel:    [<c046472e>] __free_pages_ok+0x101/0x2a8
Feb 18 17:26:27 localhost kernel:    [<c046472e>] __free_pages_ok+0x101/0x2a8
Feb 18 17:26:27 localhost kernel:    [<c0479f5b>] kmem_freepages+0x4e/0xa5
Feb 18 17:26:27 localhost kernel:    [<c047a2a2>] slab_destroy+0x2e/0x49
Feb 18 17:26:27 localhost kernel:    [<c047a370>] free_block+0xb3/0xec
Feb 18 17:26:27 localhost kernel:    [<c047a433>] drain_array+0x8a/0xb5
Feb 18 17:26:27 localhost kernel:    [<c047b4ec>] cache_reap+0x7e/0xf4
Feb 18 17:26:27 localhost kernel:    [<c043a0f3>] run_workqueue+0xdb/0x1ae
Feb 18 17:26:27 localhost kernel:    [<c043a09f>] run_workqueue+0x87/0x1ae
Feb 18 17:26:27 localhost kernel:    [<c047b46e>] cache_reap+0x0/0xf4
Feb 18 17:26:27 localhost kernel:    [<c043aad8>] worker_thread+0x0/0xc4
Feb 18 17:26:27 localhost kernel:    [<c043ab92>] worker_thread+0xba/0xc4
Feb 18 17:26:27 localhost kernel:    [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 17:26:27 localhost kernel:    [<c043d51e>] kthread+0x38/0x5e
Feb 18 17:26:27 localhost kernel:    [<c043d4e6>] kthread+0x0/0x5e
Feb 18 17:26:27 localhost kernel:    [<c0405b83>] kernel_thread_helper+0x7/0x10
Feb 18 17:26:27 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:27 localhost kernel: 
Feb 18 17:26:27 localhost kernel:      -> (&on_slab_l3_key){.+..} ops: 28386 {
Feb 18 17:26:27 localhost kernel:         initial-use  at:
Feb 18 17:26:27 localhost kernel:                                   [<c044816c>] mark_lock+0x65/0x454
Feb 18 17:26:27 localhost kernel:                                   [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:27 localhost kernel:                                   [<c040a9d6>] save_stack_trace+0x20/0x3a
Feb 18 17:26:27 localhost kernel:                                   [<c0464b77>] get_page_from_freelist+0x24b/0x37a
Feb 18 17:26:28 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:28 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:28 localhost kernel:                                   [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:28 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:28 localhost kernel:                                   [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:28 localhost kernel:                                   [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:28 localhost kernel:                                   [<c046a328>] mod_zone_page_state+0x35/0x3c
Feb 18 17:26:28 localhost kernel:                                   [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:28 localhost kernel:                                   [<c047a790>] kmem_cache_alloc+0x53/0x9f
Feb 18 17:26:28 localhost kernel:                                   [<c047ab07>] cache_alloc_refill+0x32b/0x493
Feb 18 17:26:28 localhost kernel:                                   [<c047a790>] kmem_cache_alloc+0x53/0x9f
Feb 18 17:26:28 localhost kernel:                                   [<c075ee99>] pidmap_init+0x15/0x137
Feb 18 17:26:28 localhost kernel:                                   [<c074e8a0>] start_kernel+0x2a8/0x327
Feb 18 17:26:28 localhost kernel:                                   [<c074e0e0>] unknown_bootoption+0x0/0x195
Feb 18 17:26:28 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:28 localhost kernel:         in-softirq-W at:
Feb 18 17:26:28 localhost kernel:                                   [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:28 localhost kernel:                                   [<c05fdd2b>] fn_hash_lookup+0xaa/0xb4
Feb 18 17:26:28 localhost kernel:                                   [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:28 localhost kernel:                                   [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:28 localhost kernel:                                   [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:28 localhost kernel:                                   [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:28 localhost kernel:                                   [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:28 localhost kernel:                                   [<c047acf5>] __kmalloc+0x86/0xd2
Feb 18 17:26:28 localhost kernel:                                   [<c05bb6b9>] neigh_create+0x2e4/0x41a
Feb 18 17:26:28 localhost kernel:                                   [<c05baadb>] neigh_lookup+0x94/0x9d
Feb 18 17:26:28 localhost kernel:                                   [<c05bb82b>] neigh_event_ns+0x3c/0x76
Feb 18 17:26:28 localhost kernel:                                   [<c05f2116>] arp_process+0x218/0x60c
Feb 18 17:26:28 localhost kernel:                                   [<c05f1efe>] arp_process+0x0/0x60c
Feb 18 17:26:28 localhost kernel:                                   [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:28 localhost kernel:                                   [<c05f250a>] arp_rcv+0x0/0x105
Feb 18 17:26:28 localhost kernel:                                   [<c05b5681>] netif_receive_skb+0x373/0x3d4
Feb 18 17:26:28 localhost kernel:                                   [<c05b5402>] netif_receive_skb+0xf4/0x3d4
Feb 18 17:26:28 localhost kernel:                                   [<f89637c7>] e1000_clean_rx_irq+0x374/0x44a [e1000]
Feb 18 17:26:28 localhost kernel:                                   [<f8963453>] e1000_clean_rx_irq+0x0/0x44a [e1000]
Feb 18 17:26:28 localhost kernel:                                   [<f8960f13>] e1000_clean+0x63/0x203 [e1000]
Feb 18 17:26:28 localhost kernel:                                   [<c05b77f0>] net_rx_action+0xbc/0x1b3
Feb 18 17:26:28 localhost kernel:                                   [<c05b7782>] net_rx_action+0x4e/0x1b3
Feb 18 17:26:28 localhost kernel:                                   [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:28 localhost kernel:                                   [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:28 localhost kernel:                                   [<ffffffff>] 0xffffffff
Feb 18 17:26:28 localhost kernel:       }
Feb 18 17:26:29 localhost kernel:       ... key      at: [<c0a2bc0c>] on_slab_l3_key+0x0/0x8
Feb 18 17:26:29 localhost kernel:       -> (&zone->lock){.+..} ops: 63132 {
Feb 18 17:26:29 localhost kernel:          initial-use  at:
Feb 18 17:26:29 localhost kernel:                                     [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:29 localhost kernel:                                     [<c04ef19a>] number+0x147/0x215
Feb 18 17:26:29 localhost kernel:                                     [<c04efab1>] vsnprintf+0x440/0x47c
Feb 18 17:26:29 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:29 localhost kernel:                                     [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:29 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:29 localhost kernel:                                     [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:29 localhost kernel:                                     [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:29 localhost kernel:                                     [<c04645c0>] free_hot_cold_page+0x133/0x175
Feb 18 17:26:29 localhost kernel:                                     [<c07606b8>] free_all_bootmem_core+0xdd/0x158
Feb 18 17:26:29 localhost kernel:                                     [<c075d82e>] mem_init+0x8c/0x383
Feb 18 17:26:29 localhost kernel:                                     [<c042c8c7>] printk+0x1b/0x1f
Feb 18 17:26:29 localhost kernel:                                     [<c0761a7b>] alloc_large_system_hash+0x1f7/0x222
Feb 18 17:26:29 localhost kernel:                                     [<c04f2f65>] __spin_lock_init+0x29/0x49
Feb 18 17:26:29 localhost kernel:                                     [<c076287c>] inode_init_early+0x49/0x72
Feb 18 17:26:29 localhost kernel:                                     [<c074e886>] start_kernel+0x28e/0x327
Feb 18 17:26:29 localhost kernel:                                     [<c074e0e0>] unknown_bootoption+0x0/0x195
Feb 18 17:26:29 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:26:29 localhost kernel:          in-softirq-W at:
Feb 18 17:26:29 localhost kernel:                                     [<c0448fdf>] __lock_acquire+0x424/0xbf1
Feb 18 17:26:29 localhost kernel:                                     [<c0422625>] find_busiest_group+0x204/0x5f3
Feb 18 17:26:29 localhost kernel:                                     [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:29 localhost kernel:                                     [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:29 localhost kernel:                                     [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:29 localhost kernel:                                     [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:29 localhost kernel:                                     [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:29 localhost kernel:                                     [<c04645c0>] free_hot_cold_page+0x133/0x175
Feb 18 17:26:29 localhost kernel:                                     [<c042a030>] free_task+0x18/0x25
Feb 18 17:26:29 localhost kernel:                                     [<c043b647>] __rcu_process_callbacks+0xfc/0x16e
Feb 18 17:26:29 localhost kernel:                                     [<c043b6d1>] rcu_process_callbacks+0x18/0x30
Feb 18 17:26:29 localhost kernel:                                     [<c0430b8e>] tasklet_action+0x50/0xa4
Feb 18 17:26:29 localhost kernel:                                     [<c0430a9a>] __do_softirq+0x69/0xde
Feb 18 17:26:29 localhost kernel:                                     [<c040709f>] do_softirq+0x5e/0xc7
Feb 18 17:26:29 localhost kernel:                                     [<ffffffff>] 0xffffffff
Feb 18 17:26:29 localhost kernel:        }
Feb 18 17:26:29 localhost kernel:        ... key      at: [<c0a21fb8>] __key.25233+0x0/0x8
Feb 18 17:26:29 localhost kernel:       ... acquired at:
Feb 18 17:26:29 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:29 localhost kernel:    [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:29 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:29 localhost kernel:    [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:30 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:30 localhost kernel:    [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:30 localhost kernel:    [<c0464182>] free_pages_bulk+0x28/0x1b6
Feb 18 17:26:30 localhost kernel:    [<c04645c0>] free_hot_cold_page+0x133/0x175
Feb 18 17:26:30 localhost kernel:    [<c047a2a2>] slab_destroy+0x2e/0x49
Feb 18 17:26:30 localhost kernel:    [<c047a370>] free_block+0xb3/0xec
Feb 18 17:26:30 localhost kernel:    [<c047a0f2>] cache_flusharray+0x74/0xa0
Feb 18 17:26:30 localhost kernel:    [<c047a19c>] kfree+0x7e/0xa6
Feb 18 17:26:30 localhost kernel:    [<c05f594c>] snmp_mib_free+0x1a/0x29
Feb 18 17:26:30 localhost kernel:    [<f8f283ac>] in6_dev_finish_destroy+0x8e/0xb9 [ipv6]
Feb 18 17:26:30 localhost kernel:    [<f8f28dd9>] addrconf_ifdown+0x2df/0x2eb [ipv6]
Feb 18 17:26:30 localhost kernel:    [<f8f2b0f5>] addrconf_notify+0x738/0x7c2 [ipv6]
Feb 18 17:26:30 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:30 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:30 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:30 localhost kernel:    [<c0614a16>] packet_notifier+0x149/0x151
Feb 18 17:26:30 localhost kernel:    [<c06148f3>] packet_notifier+0x26/0x151
Feb 18 17:26:30 localhost kernel:    [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:26:30 localhost kernel:    [<c0614a16>] packet_notifier+0x149/0x151
Feb 18 17:26:30 localhost kernel:    [<c061d06c>] notifier_call_chain+0x2a/0x47
Feb 18 17:26:30 localhost kernel:    [<c0441084>] raw_notifier_call_chain+0x17/0x1a
Feb 18 17:26:30 localhost kernel:    [<c05b621c>] rollback_registered+0xc4/0x11e
Feb 18 17:26:30 localhost kernel:    [<c05b627e>] unregister_netdevice+0x8/0x35
Feb 18 17:26:30 localhost kernel:    [<c05b62ba>] unregister_netdev+0xf/0x15
Feb 18 17:26:30 localhost kernel:    [<f8bb523f>] ppp_shutdown_interface+0x58/0xad [ppp_generic]
Feb 18 17:26:30 localhost kernel:    [<f8bb5484>] ppp_release+0x29/0x56 [ppp_generic]
Feb 18 17:26:30 localhost kernel:    [<c047f08a>] __fput+0xba/0x172
Feb 18 17:26:30 localhost kernel:    [<c047c7df>] filp_close+0x51/0x58
Feb 18 17:26:30 localhost kernel:    [<c047d9c4>] sys_close+0x70/0xab
Feb 18 17:26:30 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:30 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:30 localhost kernel: 
Feb 18 17:26:30 localhost kernel:      ... acquired at:
Feb 18 17:26:30 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:30 localhost kernel:    [<c047a0a0>] cache_flusharray+0x22/0xa0
Feb 18 17:26:30 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:30 localhost kernel:    [<c047a0a0>] cache_flusharray+0x22/0xa0
Feb 18 17:26:30 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:30 localhost kernel:    [<c047a0a0>] cache_flusharray+0x22/0xa0
Feb 18 17:26:30 localhost kernel:    [<c047a0a0>] cache_flusharray+0x22/0xa0
Feb 18 17:26:30 localhost kernel:    [<c047a1fa>] kmem_cache_free+0x36/0x5e
Feb 18 17:26:30 localhost kernel:    [<c047a370>] free_block+0xb3/0xec
Feb 18 17:26:30 localhost kernel:    [<c047a0f2>] cache_flusharray+0x74/0xa0
Feb 18 17:26:31 localhost kernel:    [<c047a19c>] kfree+0x7e/0xa6
Feb 18 17:26:31 localhost kernel:    [<f8f28d8e>] addrconf_ifdown+0x294/0x2eb [ipv6]
Feb 18 17:26:31 localhost kernel:    [<f8f2b0f5>] addrconf_notify+0x738/0x7c2 [ipv6]
Feb 18 17:26:31 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:31 localhost kernel:    [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:31 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:31 localhost kernel:    [<c0614a16>] packet_notifier+0x149/0x151
Feb 18 17:26:31 localhost kernel:    [<c06148f3>] packet_notifier+0x26/0x151
Feb 18 17:26:31 localhost kernel:    [<c061b171>] _read_unlock+0x14/0x1c
Feb 18 17:26:31 localhost kernel:    [<c0614a16>] packet_notifier+0x149/0x151
Feb 18 17:26:31 localhost kernel:    [<c061d06c>] notifier_call_chain+0x2a/0x47
Feb 18 17:26:31 localhost kernel:    [<c0441084>] raw_notifier_call_chain+0x17/0x1a
Feb 18 17:26:31 localhost kernel:    [<c05b621c>] rollback_registered+0xc4/0x11e
Feb 18 17:26:31 localhost kernel:    [<c05b627e>] unregister_netdevice+0x8/0x35
Feb 18 17:26:31 localhost kernel:    [<c05b62ba>] unregister_netdev+0xf/0x15
Feb 18 17:26:31 localhost kernel:    [<f8bb523f>] ppp_shutdown_interface+0x58/0xad [ppp_generic]
Feb 18 17:26:31 localhost kernel:    [<f8bb5484>] ppp_release+0x29/0x56 [ppp_generic]
Feb 18 17:26:31 localhost kernel:    [<c047f08a>] __fput+0xba/0x172
Feb 18 17:26:31 localhost kernel:    [<c047c7df>] filp_close+0x51/0x58
Feb 18 17:26:31 localhost kernel:    [<c047d9c4>] sys_close+0x70/0xab
Feb 18 17:26:31 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:31 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:31 localhost kernel: 
Feb 18 17:26:31 localhost kernel:     ... acquired at:
Feb 18 17:26:31 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:31 localhost kernel:    [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:31 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:31 localhost kernel:    [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:31 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:31 localhost kernel:    [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:31 localhost kernel:    [<c047a834>] cache_alloc_refill+0x58/0x493
Feb 18 17:26:31 localhost kernel:    [<c047a790>] kmem_cache_alloc+0x53/0x9f
Feb 18 17:26:31 localhost kernel:    [<c05bb516>] neigh_create+0x141/0x41a
Feb 18 17:26:31 localhost kernel:    [<c05baadb>] neigh_lookup+0x94/0x9d
Feb 18 17:26:31 localhost kernel:    [<c05f144f>] arp_bind_neighbour+0x62/0x74
Feb 18 17:26:31 localhost kernel:    [<c05cf248>] rt_intern_hash+0x236/0x322
Feb 18 17:26:31 localhost kernel:    [<c05cfab6>] __ip_route_output_key+0x782/0x847
Feb 18 17:26:31 localhost kernel:    [<c05cf948>] __ip_route_output_key+0x614/0x847
Feb 18 17:26:31 localhost kernel:    [<c05eace7>] tcp_v4_connect+0xef/0x5a6
Feb 18 17:26:31 localhost kernel:    [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:31 localhost kernel:    [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 17:26:32 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:32 localhost kernel:    [<c05f6944>] inet_stream_connect+0x7f/0x208
Feb 18 17:26:32 localhost kernel:    [<c04f05f4>] copy_from_user+0x32/0x5e
Feb 18 17:26:32 localhost kernel:    [<c05ac371>] sys_connect+0x7b/0xa6
Feb 18 17:26:32 localhost kernel:    [<c05aea5a>] sock_setsockopt+0x492/0x4aa
Feb 18 17:26:32 localhost kernel:    [<c05aea5a>] sock_setsockopt+0x492/0x4aa
Feb 18 17:26:32 localhost kernel:    [<c05db937>] tcp_setsockopt+0x321/0x339
Feb 18 17:26:32 localhost kernel:    [<c05ab618>] sock_map_fd+0x41/0x4a
Feb 18 17:26:32 localhost kernel:    [<c061b25a>] _spin_lock+0x29/0x34
Feb 18 17:26:32 localhost kernel:    [<c05ab47f>] sys_setsockopt+0x62/0x9c
Feb 18 17:26:32 localhost kernel:    [<c05acb97>] sys_socketcall+0xac/0x261
Feb 18 17:26:32 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:32 localhost kernel:    [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 17:26:32 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:32 localhost kernel: 
Feb 18 17:26:32 localhost kernel:    ... acquired at:
Feb 18 17:26:32 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:32 localhost kernel:    [<c05cf06f>] rt_intern_hash+0x5d/0x322
Feb 18 17:26:32 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:32 localhost kernel:    [<c05cf06f>] rt_intern_hash+0x5d/0x322
Feb 18 17:26:32 localhost kernel:    [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:32 localhost kernel:    [<c05cf06f>] rt_intern_hash+0x5d/0x322
Feb 18 17:26:32 localhost kernel:    [<c05cf06f>] rt_intern_hash+0x5d/0x322
Feb 18 17:26:32 localhost kernel:    [<c05cf000>] rt_set_nexthop+0x105/0x117
Feb 18 17:26:32 localhost kernel:    [<c05cfab6>] __ip_route_output_key+0x782/0x847
Feb 18 17:26:32 localhost kernel:    [<c05cf948>] __ip_route_output_key+0x614/0x847
Feb 18 17:26:32 localhost kernel:    [<c0464b77>] get_page_from_freelist+0x24b/0x37a
Feb 18 17:26:32 localhost kernel:    [<c05cfb8f>] ip_route_output_flow+0x14/0x1ef
Feb 18 17:26:32 localhost kernel:    [<c05b0c83>] pskb_expand_head+0xde/0x144
Feb 18 17:26:32 localhost kernel:    [<f8bbf6fe>] pppol2tp_xmit+0x365/0x4a2 [pppol2tp]
Feb 18 17:26:32 localhost kernel:    [<f8bb730e>] ppp_channel_push+0x34/0x90 [ppp_generic]
Feb 18 17:26:32 localhost kernel:    [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:32 localhost kernel:    [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:32 localhost kernel:    [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:32 localhost kernel:    [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:32 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:32 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:32 localhost kernel: 
Feb 18 17:26:32 localhost kernel:   ... acquired at:
Feb 18 17:26:32 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:32 localhost kernel:    [<f8bb56db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 17:26:32 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:32 localhost kernel:    [<f8bb56db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:33 localhost kernel:    [<f8bb56db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<f8bb56db>] ppp_push+0x63/0x50d [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:33 localhost kernel:    [<c0448771>] trace_hardirqs_on+0x10c/0x14c
Feb 18 17:26:33 localhost kernel:    [<f8bb63f1>] ppp_xmit_process+0x4f6/0x5a1 [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:33 localhost kernel:    [<f8bb83b4>] ppp_write+0xc7/0xdb [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:33 localhost kernel:    [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:33 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:33 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:33 localhost kernel: 
Feb 18 17:26:33 localhost kernel:  ... acquired at:
Feb 18 17:26:33 localhost kernel:    [<c04495c0>] __lock_acquire+0xa05/0xbf1
Feb 18 17:26:33 localhost kernel:    [<f8bb6bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:33 localhost kernel:    [<f8bb6bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<c061b293>] _spin_lock_bh+0x2e/0x39
Feb 18 17:26:33 localhost kernel:    [<f8bb6bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<f8bb6bb5>] ppp_ioctl+0x518/0xc06 [ppp_generic]
Feb 18 17:26:33 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 17:26:33 localhost kernel:    [<c061b622>] _spin_unlock_irqrestore+0x34/0x39
Feb 18 17:26:33 localhost kernel:    [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:33 localhost kernel:    [<c061b008>] __down+0x82/0xb8
Feb 18 17:26:33 localhost kernel:    [<c0425474>] default_wake_function+0x0/0x8
Feb 18 17:26:33 localhost kernel:    [<c061ae17>] __down_failed+0x7/0xc
Feb 18 17:26:33 localhost kernel:    [<c0488854>] do_ioctl+0x4c/0x62
Feb 18 17:26:33 localhost kernel:    [<c0488aa1>] vfs_ioctl+0x237/0x249
Feb 18 17:26:33 localhost kernel:    [<c0488af8>] sys_ioctl+0x45/0x5d
Feb 18 17:26:33 localhost kernel:    [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:33 localhost kernel:    [<ffffffff>] 0xffffffff
Feb 18 17:26:33 localhost kernel: 
Feb 18 17:26:33 localhost kernel: 
Feb 18 17:26:33 localhost kernel: the soft-irq-unsafe lock's dependencies:
Feb 18 17:26:33 localhost kernel: -> (&sk->sk_dst_lock){----} ops: 3988 {
Feb 18 17:26:33 localhost kernel:    initial-use  at:
Feb 18 17:26:33 localhost kernel:                         [<c0449059>] __lock_acquire+0x49e/0xbf1
Feb 18 17:26:33 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:33 localhost kernel:                         [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 17:26:33 localhost kernel:                         [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 17:26:33 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 17:26:34 localhost kernel:                         [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 17:26:34 localhost kernel:                         [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 17:26:34 localhost kernel:                         [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 17:26:34 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:34 localhost kernel:                         [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 17:26:34 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 17:26:34 localhost kernel:    softirq-on-W at:
Feb 18 17:26:34 localhost kernel:                         [<c0449046>] __lock_acquire+0x48b/0xbf1
Feb 18 17:26:34 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:34 localhost kernel:                         [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 17:26:34 localhost kernel:                         [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 17:26:34 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 17:26:34 localhost kernel:                         [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 17:26:34 localhost kernel:                         [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 17:26:34 localhost kernel:                         [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 17:26:34 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:34 localhost kernel:                         [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 17:26:34 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 17:26:34 localhost kernel:    hardirq-on-W at:
Feb 18 17:26:34 localhost kernel:                         [<c0449027>] __lock_acquire+0x46c/0xbf1
Feb 18 17:26:34 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:34 localhost kernel:                         [<c043083a>] local_bh_enable+0x10e/0x115
Feb 18 17:26:34 localhost kernel:                         [<c05da996>] inet_csk_get_port+0xc1/0x1cb
Feb 18 17:26:34 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c05da85d>] inet_csk_listen_start+0x75/0xed
Feb 18 17:26:34 localhost kernel:                         [<c05f66da>] inet_listen+0x3b/0x5e
Feb 18 17:26:34 localhost kernel:                         [<c05ab68f>] sys_listen+0x43/0x5f
Feb 18 17:26:34 localhost kernel:                         [<c05acba8>] sys_socketcall+0xbd/0x261
Feb 18 17:26:34 localhost kernel:                         [<c0404ead>] sysenter_past_esp+0x9a/0xa5
Feb 18 17:26:34 localhost kernel:                         [<c0448787>] trace_hardirqs_on+0x122/0x14c
Feb 18 17:26:35 localhost kernel:                         [<c0404e72>] sysenter_past_esp+0x5f/0xa5
Feb 18 17:26:35 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 17:26:35 localhost kernel:    softirq-on-R at:
Feb 18 17:26:35 localhost kernel:                         [<c0449046>] __lock_acquire+0x48b/0xbf1
Feb 18 17:26:35 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:35 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 17:26:35 localhost kernel:                         [<c061b3a7>] _read_lock+0x29/0x34
Feb 18 17:26:35 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 17:26:35 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 17:26:35 localhost kernel:                         [<c05baadb>] neigh_lookup+0x94/0x9d
Feb 18 17:26:35 localhost kernel:                         [<c05f0609>] udp_sendmsg+0x240/0x59d
Feb 18 17:26:35 localhost kernel:                         [<c05cf322>] rt_intern_hash+0x310/0x322
Feb 18 17:26:35 localhost kernel:                         [<c05f5fc7>] inet_sendmsg+0x3b/0x45
Feb 18 17:26:35 localhost kernel:                         [<c05ab8cd>] sock_sendmsg+0xc9/0xe4
Feb 18 17:26:35 localhost kernel:                         [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 17:26:35 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:35 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:35 localhost kernel:                         [<c061b528>] _read_unlock_irq+0x20/0x23
Feb 18 17:26:35 localhost kernel:                         [<c061b528>] _read_unlock_irq+0x20/0x23
Feb 18 17:26:35 localhost kernel:                         [<c05ac29b>] sys_sendto+0x11b/0x13b
Feb 18 17:26:35 localhost kernel:                         [<c046b794>] __do_fault+0x23b/0x35d
Feb 18 17:26:35 localhost kernel:                         [<c046b874>] __do_fault+0x31b/0x35d
Feb 18 17:26:35 localhost kernel:                         [<c046d4ff>] handle_mm_fault+0x2a2/0x5f7
Feb 18 17:26:35 localhost kernel:                         [<c05ac2f2>] sys_send+0x37/0x3b
Feb 18 17:26:35 localhost kernel:                         [<c05acc35>] sys_socketcall+0x14a/0x261
Feb 18 17:26:35 localhost kernel:                         [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:35 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 17:26:35 localhost kernel:    hardirq-on-R at:
Feb 18 17:26:35 localhost kernel:                         [<c048926a>] do_sys_poll+0x260/0x2e0
Feb 18 17:26:35 localhost kernel:                         [<c0449001>] __lock_acquire+0x446/0xbf1
Feb 18 17:26:35 localhost kernel:                         [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:35 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 17:26:35 localhost kernel:                         [<c061b3a7>] _read_lock+0x29/0x34
Feb 18 17:26:35 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 17:26:35 localhost kernel:                         [<c05ada91>] sk_dst_check+0x18/0x105
Feb 18 17:26:35 localhost kernel:                         [<c05baadb>] neigh_lookup+0x94/0x9d
Feb 18 17:26:35 localhost kernel:                         [<c05f0609>] udp_sendmsg+0x240/0x59d
Feb 18 17:26:35 localhost kernel:                         [<c05cf322>] rt_intern_hash+0x310/0x322
Feb 18 17:26:35 localhost kernel:                         [<c05f5fc7>] inet_sendmsg+0x3b/0x45
Feb 18 17:26:35 localhost kernel:                         [<c05ab8cd>] sock_sendmsg+0xc9/0xe4
Feb 18 17:26:35 localhost kernel:                         [<c043d5d5>] autoremove_wake_function+0x0/0x35
Feb 18 17:26:35 localhost kernel:                         [<c0449764>] __lock_acquire+0xba9/0xbf1
Feb 18 17:26:35 localhost kernel:                         [<c0448594>] mark_held_locks+0x39/0x53
Feb 18 17:26:36 localhost kernel:                         [<c061b528>] _read_unlock_irq+0x20/0x23
Feb 18 17:26:36 localhost kernel:                         [<c061b528>] _read_unlock_irq+0x20/0x23
Feb 18 17:26:36 localhost kernel:                         [<c05ac29b>] sys_sendto+0x11b/0x13b
Feb 18 17:26:36 localhost kernel:                         [<c046b794>] __do_fault+0x23b/0x35d
Feb 18 17:26:36 localhost kernel:                         [<c046b874>] __do_fault+0x31b/0x35d
Feb 18 17:26:36 localhost kernel:                         [<c046d4ff>] handle_mm_fault+0x2a2/0x5f7
Feb 18 17:26:36 localhost kernel:                         [<c05ac2f2>] sys_send+0x37/0x3b
Feb 18 17:26:36 localhost kernel:                         [<c05acc35>] sys_socketcall+0x14a/0x261
Feb 18 17:26:36 localhost kernel:                         [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:36 localhost kernel:                         [<ffffffff>] 0xffffffff
Feb 18 17:26:36 localhost kernel:  }
Feb 18 17:26:36 localhost kernel:  ... key      at: [<c0a3dc28>] __key.35996+0x0/0x8
Feb 18 17:26:36 localhost kernel: 
Feb 18 17:26:36 localhost kernel: stack backtrace:
Feb 18 17:26:36 localhost kernel: Pid: 13863, comm: pppd Not tainted 2.6.24.2 #1
Feb 18 17:26:36 localhost kernel:  [<c0448b1e>] check_usage+0x24e/0x258
Feb 18 17:26:36 localhost kernel:  [<c0449555>] __lock_acquire+0x99a/0xbf1
Feb 18 17:26:36 localhost kernel:  [<c044981c>] lock_acquire+0x70/0x8a
Feb 18 17:26:36 localhost kernel:  [<f8bbf73e>] pppol2tp_xmit+0x3a5/0x4a2 [pppol2tp]
Feb 18 17:26:36 localhost kernel:  [<c061b2c7>] _write_lock+0x29/0x34
Feb 18 17:26:36 localhost kernel:  [<f8bbf73e>] pppol2tp_xmit+0x3a5/0x4a2 [pppol2tp]
Feb 18 17:26:36 localhost kernel:  [<f8bbf73e>] pppol2tp_xmit+0x3a5/0x4a2 [pppol2tp]
Feb 18 17:26:36 localhost kernel:  [<f8bb730e>] ppp_channel_push+0x34/0x90 [ppp_generic]
Feb 18 17:26:36 localhost kernel:  [<f8bb83bd>] ppp_write+0xd0/0xdb [ppp_generic]
Feb 18 17:26:36 localhost kernel:  [<f8bb82ed>] ppp_write+0x0/0xdb [ppp_generic]
Feb 18 17:26:36 localhost kernel:  [<c047e6d2>] vfs_write+0xa1/0x14d
Feb 18 17:26:36 localhost kernel:  [<c047ecfd>] sys_write+0x41/0x67
Feb 18 17:26:36 localhost kernel:  [<c0404efa>] syscall_call+0x7/0xb
Feb 18 17:26:36 localhost kernel:  =======================

--------------030602020304010109060003--
