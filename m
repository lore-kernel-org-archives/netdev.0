From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8668] New: HTB Deadlock
Date: Sun, 24 Jun 2007 22:24:30 -0700
Message-ID: <20070624222430.8d5b4bd7.akpm@linux-foundation.org>
References: <bug-8668-10286@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>, ranko@spidernet.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:58315 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753484AbXFYFYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2007 01:24:49 -0400
In-Reply-To: <bug-8668-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 24 Jun 2007 21:57:19 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8668
> 
>            Summary: HTB Deadlock
>            Product: Networking
>            Version: 2.5
>      KernelVersion: 2.6.19.7
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: ranko@spidernet.net
> 
> 
> Most recent kernel where this bug did not occur:
> Distribution:
> Hardware Environment:
> Software Environment:
> Problem Description:
> Greetings,
> 
> I've been experiencing problems with HTB where the whole machine locks
> up. This usually happens when the whole qdisc is being removed and
> occasionally when a leaf is being removed.
> 
> Common is that it always happens when some sort of removal is in
> progress.
> 
> Console output I have captured is at the end of this message. The same
> behavior exists from vanilla 2.6.19.7 and above. It is possible that the
> problem also exist in the earlier versions however I did not go further
> back.
> 
> I also believe I have found where the actual problem is:
> 
> qdisc_destroy() function is always called with dev->queue_lock locked.
> htb_destroy() function up the stack is using del_timer_sync() call to
> deactivate HTB qdisc timers. 

yep, I would agree with that analysis.  del_timer_sync() under a lock is
quite dangerous in this regard.

If the (misspelled) comment over htb_destroy() is true, current mainline
appears still to have this bug.


> >From the comments in the source where del_timer_sync() is defined:
> 
> ---copy/paste---
> /**
>  * del_timer_sync - deactivate a timer and wait for the handler to finish.
>  * @timer: the timer to be deactivated
>  *
>  * This function only differs from del_timer() on SMP: besides deactivating
>  * the timer it also makes sure the handler has finished executing on other
>  * CPUs.
>  *
>  * Synchronization rules: Callers must prevent restarting of the timer,
>  * otherwise this function is meaningless. It must not be called from
>  * interrupt contexts. The caller must not hold locks which would prevent
>  * completion of the timer's handler. The timer's handler must not call
>  * add_timer_on(). Upon exit the timer is not queued and the handler is
>  * not running on any CPU.
>  *
>  * The function returns whether it has deactivated a pending timer or not.
>  */
> ---copy/paste---
> 
> Now, htb_rate_timer() does exactly what appears to be the source of the
> problem - it tries obtain dev->queue_lock - and given the right moment
> (timer fired handler while qdisc_destroy was holding the lock) - system
> locks up - del_timer_sync is waiting for handler to finish while the
> handler is waiting for the dev->queue_lock.
> 
> Of course I could also be completely wrong here and missing something
> not so obvious.
> 
> I could also attempt to fix this but I haven't dealt with this code in
> the past so I was hoping someone with better insight might just have an
> elegant solution up his sleeve.
> 
> Best regards,
> 
> Ranko
> 
> PS: If this is not the right place for this report - please let me
> know.
> 
> -----------CONSOLE (2.6.19.7)-----------
> BUG: soft lockup detected on CPU#3!
>  [<c013c890>] softlockup_tick+0x93/0xc2
>  [<c0127585>] update_process_times+0x26/0x5c
>  [<c0111cd5>] smp_apic_timer_interrupt+0x97/0xb2
>  [<c0104373>] apic_timer_interrupt+0x1f/0x24
>  [<c02e007b>] klist_next+0x4/0x8a
>  [<c02e2570>] _spin_unlock_irqrestore+0xa/0xc
>  [<c012729b>] try_to_del_timer_sync+0x47/0x4f
>  [<c01272b1>] del_timer_sync+0xe/0x14
>  [<f8b8a85b>] htb_destroy+0x20/0x7b [sch_htb]
>  [<c028f196>] qdisc_destroy+0x44/0x8d
>  [<f8b89645>] htb_destroy_class+0xd0/0x12d [sch_htb]
>  [<f8b895c7>] htb_destroy_class+0x52/0x12d [sch_htb]
>  [<f8b8a87a>] htb_destroy+0x3f/0x7b [sch_htb]
>  [<c028f196>] qdisc_destroy+0x44/0x8d
>  [<f8b89645>] htb_destroy_class+0xd0/0x12d [sch_htb]
>  [<f8b895c7>] htb_destroy_class+0x52/0x12d [sch_htb]
>  [<f8b8a87a>] htb_destroy+0x3f/0x7b [sch_htb]
>  [<c028f196>] qdisc_destroy+0x44/0x8d
>  [<c0290ba9>] tc_get_qdisc+0x1a3/0x1ef
>  [<c0290a06>] tc_get_qdisc+0x0/0x1ef
>  [<c028a366>] rtnetlink_rcv_msg+0x158/0x215
>  [<c028a20e>] rtnetlink_rcv_msg+0x0/0x215
>  [<c0294598>] netlink_run_queue+0x88/0x11d
>  [<c028a1c0>] rtnetlink_rcv+0x26/0x42
>  [<c0294b0c>] netlink_data_ready+0x12/0x54
>  [<c0293843>] netlink_sendskb+0x1c/0x33
>  [<c0294a11>] netlink_sendmsg+0x1ee/0x2d7
>  [<c0278ff7>] sock_sendmsg+0xe5/0x100
>  [<c01306b9>] autoremove_wake_function+0x0/0x37
>  [<c01306b9>] autoremove_wake_function+0x0/0x37
>  [<c0278ff7>] sock_sendmsg+0xe5/0x100
>  [<c01cd8be>] copy_from_user+0x33/0x69
>  [<c027913f>] sys_sendmsg+0x12d/0x243
>  [<c02e2564>] _read_unlock_irq+0x5/0x7
>  [<c013fb2b>] find_get_page+0x37/0x42
>  [<c01423dd>] filemap_nopage+0x30c/0x3a3
>  [<c014bb99>] __handle_mm_fault+0x21c/0x943
>  [<c02e24c5>] _spin_unlock_bh+0x5/0xd
>  [<c027b475>] sock_setsockopt+0x63/0x59d
>  [<c0151801>] anon_vma_prepare+0x1b/0xcb
>  [<c027a2ea>] sys_socketcall+0x24f/0x271
>  [<c02e3ad0>] do_page_fault+0x0/0x600
>  [<c01038f1>] sysenter_past_esp+0x56/0x79
>  =======================
> BUG: soft lockup detected on CPU#1!
>  [<c013c890>] softlockup_tick+0x93/0xc2
>  [<c0127585>] update_process_times+0x26/0x5c
>  [<c0111cd5>] smp_apic_timer_interrupt+0x97/0xb2
>  [<c0104373>] apic_timer_interrupt+0x1f/0x24
>  [<c01c007b>] blk_do_ordered+0x70/0x27e
>  [<c01ce788>] _raw_spin_lock+0xaa/0x13e
>  [<f8b8b422>] htb_rate_timer+0x18/0xc4 [sch_htb]
>  [<c0127539>] run_timer_softirq+0x163/0x189
>  [<f8b8b40a>] htb_rate_timer+0x0/0xc4 [sch_htb]
>  [<c0123315>] __do_softirq+0x70/0xdb
>  [<c01233bb>] do_softirq+0x3b/0x42
>  [<c0111cda>] smp_apic_timer_interrupt+0x9c/0xb2
>  [<c0104373>] apic_timer_interrupt+0x1f/0x24
>  [<c0101cc3>] mwait_idle_with_hints+0x3b/0x3f
>  [<c0101cd3>] mwait_idle+0xc/0x1b
>  [<c010271c>] cpu_idle+0x63/0x79
>  =======================
> BUG: soft lockup detected on CPU#2!
>  [<c013c890>] softlockup_tick+0x93/0xc2
>  [<c0127585>] update_process_times+0x26/0x5c
>  [<c0111cd5>] smp_apic_timer_interrupt+0x97/0xb2
>  [<c0104373>] apic_timer_interrupt+0x1f/0x24
>  [<c01c007b>] blk_do_ordered+0x70/0x27e
>  [<c01ce788>] _raw_spin_lock+0xaa/0x13e
>  [<c02846df>] dev_queue_xmit+0x53/0x2e4
>  [<c0286e20>] neigh_connected_output+0x80/0xa0
>  [<c02a213a>] ip_output+0x1b5/0x24b
>  [<c02a0b56>] ip_finish_output+0x0/0x192
>  [<c029dfef>] ip_forward+0x1c8/0x2b9
>  [<c029ddf0>] ip_forward_finish+0x0/0x37
>  [<c029c962>] ip_rcv+0x2a5/0x538
>  [<c029c100>] ip_rcv_finish+0x0/0x2aa
>  [<c027f3bc>] __netdev_alloc_skb+0x12/0x2a
>  [<c029c6bd>] ip_rcv+0x0/0x538
>  [<c0282a1e>] netif_receive_skb+0x218/0x318
>  [<c0270008>] bitmap_get_counter+0x41/0x1e6
>  [<f8a6146d>] e1000_clean_rx_irq+0x12c/0x4ef [e1000]
>  [<f8a61341>] e1000_clean_rx_irq+0x0/0x4ef [e1000]
>  [<f8a60612>] e1000_clean+0xe5/0x130 [e1000]
>  [<c0284573>] net_rx_action+0xbc/0x1d5
>  [<c0123315>] __do_softirq+0x70/0xdb
>  [<c01233bb>] do_softirq+0x3b/0x42
>  [<c01058c2>] do_IRQ+0x6c/0xda
>  [<c01042e2>] common_interrupt+0x1a/0x20
>  [<c0101cc3>] mwait_idle_with_hints+0x3b/0x3f
>  [<c0101cd3>] mwait_idle+0xc/0x1b
>  [<c010271c>] cpu_idle+0x63/0x79
>  =======================
> BUG: soft lockup detected on CPU#0!
>  [<c013c890>] softlockup_tick+0x93/0xc2
>  [<c0127585>] update_process_times+0x26/0x5c
>  [<c0111cd5>] smp_apic_timer_interrupt+0x97/0xb2
>  [<c0104373>] apic_timer_interrupt+0x1f/0x24
>  [<c01cd2eb>] delay_tsc+0x7/0x13
>  [<c01cd323>] __delay+0x6/0x7
>  [<c01ce796>] _raw_spin_lock+0xb8/0x13e
>  [<c02846df>] dev_queue_xmit+0x53/0x2e4
>  [<c0286e20>] neigh_connected_output+0x80/0xa0
>  [<c02a213a>] ip_output+0x1b5/0x24b
>  [<c02a0b56>] ip_finish_output+0x0/0x192
>  [<c029dfef>] ip_forward+0x1c8/0x2b9
>  [<c029ddf0>] ip_forward_finish+0x0/0x37
>  [<c029c962>] ip_rcv+0x2a5/0x538
>  [<c029c100>] ip_rcv_finish+0x0/0x2aa
>  [<c027e774>] __alloc_skb+0x47/0xf3
>  [<c029c6bd>] ip_rcv+0x0/0x538
>  [<c0282a1e>] netif_receive_skb+0x218/0x318
>  [<c0270008>] bitmap_get_counter+0x41/0x1e6
>  [<f88fac1d>] tg3_poll+0x6d3/0x906 [tg3]
>  [<c0284573>] net_rx_action+0xbc/0x1d5
>  [<c0123315>] __do_softirq+0x70/0xdb
>  [<c01233bb>] do_softirq+0x3b/0x42
>  [<c01058c2>] do_IRQ+0x6c/0xda
>  [<c01042e2>] common_interrupt+0x1a/0x20
>  [<c0101cc3>] mwait_idle_with_hints+0x3b/0x3f
>  [<c0101cd3>] mwait_idle+0xc/0x1b
>  [<c010271c>] cpu_idle+0x63/0x79
>  [<c03a9780>] start_kernel+0x353/0x423
>  [<c03a91cd>] unknown_bootoption+0x0/0x260
>  =======================
> -----------CONSOLE-----------
> 
> Steps to reproduce:
> 
> 
> -- 
> Configure bugmail: http://bugzilla.kernel.org/userprefs.cgi?tab=email
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.
