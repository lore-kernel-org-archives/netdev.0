From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: fix lockdep issue in __neigh_event_send
Date: Mon, 19 Sep 2011 13:39:32 -0700
Message-ID: <CANP3RGdxYg0Utfyrqfwoj+ojfCD+ZYJTa91nzPSdWBznZWKHaA@mail.gmail.com>
References: <1316459578-23413-1-git-send-email-zenczykowski@gmail.com>
	<1316461375.2455.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	MuraliRaja Muniraju <muralira@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:12221 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146Ab1ISUjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 16:39:35 -0400
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p8JKdYLc000639
	for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 13:39:34 -0700
Received: from gwj20 (gwj20.prod.google.com [10.200.10.20])
	by hpaq13.eem.corp.google.com with ESMTP id p8JKdEnl003912
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 13:39:33 -0700
Received: by gwj20 with SMTP id 20so5964921gwj.12
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 13:39:32 -0700 (PDT)
In-Reply-To: <1316461375.2455.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first hunk was for consistency - to always free in exit path.  The
second hunk is where the lockdep bug is.

LOCKDEP gives the following (it's pretty rare):

[   90.543085] =======================================================
[   90.544012] [ INFO: possible circular locking dependency detected ]
[   90.544012] 2.6.34-smp-DEV #70
[   90.544012] -------------------------------------------------------
[   90.544012] swapper/0 is trying to acquire lock:
[   90.544012]  (&tbl->lock){++--..}, at: [<ffffffff813c106d>]
neigh_lookup+0x42/0xbf
[   90.544012]
[   90.544012] but task is already holding lock:
[   90.544012]  (&(&rt_hash_locks[i])->rlock){+.-...}, at:
[<ffffffff813db663>] rt_intern_hash+0xf2/0x3ad
[   90.544012]
[   90.544012] which lock already depends on the new lock.
[   90.544012]
[   90.544012]
[   90.544012] the existing dependency chain (in reverse order) is:
[   90.544012]
[   90.544012] -> #2 (&(&rt_hash_locks[i])->rlock){+.-...}:
[   90.544012]        [<ffffffff810a4910>] __lock_acquire+0xb3b/0xcda
[   90.544012]        [<ffffffff810a4b72>] lock_acquire+0xc3/0xe9
[   90.544012]        [<ffffffff81430d66>] _raw_spin_lock_bh+0x36/0x45
[   90.544012]        [<ffffffff813d9659>] rt_dst_release+0x4a/0x8d
[   90.544012]        [<ffffffff813bee34>] dst_release+0x5d/0x66
[   90.544012]        [<ffffffff813af24e>] skb_release_head_state+0x1f/0xa5
[   90.544012]        [<ffffffff813aefec>] __kfree_skb+0x16/0x87
[   90.544012]        [<ffffffff813af101>] kfree_skb+0x72/0x7a
[   90.544012]        [<ffffffff813c06f9>] __neigh_event_send+0x126/0x176
[   90.544012]        [<ffffffff813c2c1b>] neigh_resolve_output+0x7f/0x267
[   90.544012]        [<ffffffff813e3057>] ip_finish_output2+0x1f2/0x221
[   90.544012]        [<ffffffff813e30ea>] ip_finish_output+0x64/0x66
[   90.544012]        [<ffffffff813e3200>] NF_HOOK_COND.clone.1+0x41/0x45
[   90.544012]        [<ffffffff813e3277>] ip_output+0x73/0x75
[   90.544012]        [<ffffffff813e1524>] dst_output+0x10/0x12
[   90.544012]        [<ffffffff813e349f>] ip_local_out+0x23/0x27
[   90.544012]        [<ffffffff813e378a>] ip_push_pending_frames+0x2e7/0x348
[   90.544012]        [<ffffffff81401a13>] udp_push_pending_frames+0x2dc/0x35c
[   90.544012]        [<ffffffff8140314e>] udp_sendmsg+0x628/0x763
[   90.544012]        [<ffffffff81409933>] inet_sendmsg+0x58/0x61
[   90.544012]        [<ffffffff813a726f>] __sock_sendmsg+0x5e/0x69
[   90.544012]        [<ffffffff813a7737>] sock_sendmsg+0xa8/0xc1
[   90.544012]        [<ffffffff813a79d9>] sys_sendmsg+0x1da/0x241
[   90.544012]        [<ffffffff813cb482>] compat_sys_sendmsg+0x14/0x16
[   90.544012]        [<ffffffff813cc081>] compat_sys_socketcall+0x13b/0x16c
[   90.544012]        [<ffffffff81059687>] sysenter_dispatch+0x7/0x2c
[   90.544012]
[   90.544012] -> #1 (&n->lock){++--..}:
[   90.544012]        [<ffffffff810a4910>] __lock_acquire+0xb3b/0xcda
[   90.544012]        [<ffffffff810a4b72>] lock_acquire+0xc3/0xe9
[   90.544012]        [<ffffffff81430e81>] _raw_write_lock+0x31/0x40
[   90.544012]        [<ffffffff813c16fb>] neigh_periodic_work+0xae/0x196
[   90.544012]        [<ffffffff8108a8ca>] worker_thread+0x1fb/0x2f1
[   90.544012]        [<ffffffff8108e099>] kthread+0x7f/0x87
[   90.544012]        [<ffffffff81032a94>] kernel_thread_helper+0x4/0x10
[   90.544012]
[   90.544012] -> #0 (&tbl->lock){++--..}:
[   90.544012]        [<ffffffff810a47ba>] __lock_acquire+0x9e5/0xcda
[   90.544012]        [<ffffffff810a4b72>] lock_acquire+0xc3/0xe9
[   90.544012]        [<ffffffff81430ffa>] _raw_read_lock_bh+0x39/0x48
[   90.544012]        [<ffffffff813c106d>] neigh_lookup+0x42/0xbf
[   90.544012]        [<ffffffff81405067>]
__neigh_lookup_errno.clone.0+0x24/0x40
[   90.544012]        [<ffffffff814054b2>] arp_bind_neighbour+0x4c/0x65
[   90.544012]        [<ffffffff813db815>] rt_intern_hash+0x2a4/0x3ad
[   90.544012]        [<ffffffff813dc054>] ip_route_output_slow+0x6ec/0x739
[   90.544012]        [<ffffffff813dc574>] __ip_route_output_key+0x1bd/0x1c9
[   90.544012]        [<ffffffff81406f45>] icmp_send+0x2bf/0x3ca
[   90.544012]        [<ffffffff813d9739>] ipv4_link_failure+0x22/0x5c
[   90.544012]        [<ffffffff81404acd>] arp_error_report+0x31/0x3d
[   90.544012]        [<ffffffff813c1172>] neigh_invalidate+0x88/0xa3
[   90.544012]        [<ffffffff813c2a1b>] neigh_timer_handler+0x1a8/0x27f
[   90.544012]        [<ffffffff8108087a>] run_timer_softirq+0x219/0x2e3
[   90.544012]        [<ffffffff8107910e>] __do_softirq+0xf7/0x1cb
[   90.544012]        [<ffffffff81032b8c>] call_softirq+0x1c/0x3e
[   90.544012]        [<ffffffff81034615>] do_softirq+0x3d/0x85
[   90.544012]        [<ffffffff81078d49>] irq_exit+0x4a/0x8c
[   90.544012]        [<ffffffff8143708c>] smp_apic_timer_interrupt+0x99/0xa7
[   90.544012]        [<ffffffff81032653>] apic_timer_interrupt+0x13/0x20
[   90.544012]        [<ffffffff81030d92>] cpu_idle+0x5c/0x79
[   90.544012]        [<ffffffff8142213f>] rest_init+0xc3/0xca
[   90.544012]        [<ffffffff81b47d77>] start_kernel+0x3e2/0x3ed
[   90.544012]        [<ffffffff81b4729f>] x86_64_start_reservations+0xaf/0xb3
[   90.544012]        [<ffffffff81b47393>] x86_64_start_kernel+0xf0/0xf7
[   90.544012]
[   90.544012] other info that might help us debug this:
[   90.544012]
[   90.544012] 3 locks held by swapper/0:
[   90.544012]  #0:  (&n->timer){+.-...}, at: [<ffffffff810807e8>]
run_timer_softirq+0x187/0x2e3
[   90.544012]  #1:  (slock-AF_INET){+.-...}, at: [<ffffffff814063d3>]
icmp_xmit_lock+0x35/0x47
[   90.544012]  #2:  (&(&rt_hash_locks[i])->rlock){+.-...}, at:
[<ffffffff813db663>] rt_intern_hash+0xf2/0x3ad
[   90.544012]
[   90.544012] stack backtrace:
[   90.544012] Pid: 0, comm: swapper Not tainted 2.6.34-smp-DEV #70
[   90.544012] Call Trace:
[   90.544012]  <IRQ>  [<ffffffff810a39c0>] print_circular_bug+0xa8/0xb7
[   90.544012]  [<ffffffff810a47ba>] __lock_acquire+0x9e5/0xcda
[   90.544012]  [<ffffffff813c106d>] ? neigh_lookup+0x42/0xbf
[   90.544012]  [<ffffffff810a4b72>] lock_acquire+0xc3/0xe9
[   90.544012]  [<ffffffff813c106d>] ? neigh_lookup+0x42/0xbf
[   90.544012]  [<ffffffff81430ffa>] _raw_read_lock_bh+0x39/0x48
[   90.544012]  [<ffffffff813c106d>] ? neigh_lookup+0x42/0xbf
[   90.544012]  [<ffffffff813c106d>] neigh_lookup+0x42/0xbf
[   90.544012]  [<ffffffff81405067>] __neigh_lookup_errno.clone.0+0x24/0x40
[   90.544012]  [<ffffffff814054b2>] arp_bind_neighbour+0x4c/0x65
[   90.544012]  [<ffffffff813db663>] ? rt_intern_hash+0xf2/0x3ad
[   90.544012]  [<ffffffff813db815>] rt_intern_hash+0x2a4/0x3ad
[   90.544012]  [<ffffffff813dc054>] ip_route_output_slow+0x6ec/0x739
[   90.544012]  [<ffffffff81078f49>] ? _local_bh_enable_ip+0xc1/0xc7
[   90.544012]  [<ffffffff813dc574>] __ip_route_output_key+0x1bd/0x1c9
[   90.544012]  [<ffffffff81406f45>] icmp_send+0x2bf/0x3ca
[   90.544012]  [<ffffffff813c2800>] ? neigh_event_ns+0x2f/0xa2
[   90.544012]  [<ffffffff813d9739>] ipv4_link_failure+0x22/0x5c
[   90.544012]  [<ffffffff81404acd>] arp_error_report+0x31/0x3d
[   90.544012]  [<ffffffff813c1172>] neigh_invalidate+0x88/0xa3
[   90.544012]  [<ffffffff813c2a1b>] neigh_timer_handler+0x1a8/0x27f
[   90.544012]  [<ffffffff8108087a>] run_timer_softirq+0x219/0x2e3
[   90.544012]  [<ffffffff810807e8>] ? run_timer_softirq+0x187/0x2e3
[   90.544012]  [<ffffffff8109158d>] ? __run_hrtimer+0xf4/0x132
[   90.544012]  [<ffffffff813c2873>] ? neigh_timer_handler+0x0/0x27f
[   90.544012]  [<ffffffff8107908d>] ? __do_softirq+0x76/0x1cb
[   90.544012]  [<ffffffff8107910e>] __do_softirq+0xf7/0x1cb
[   90.544012]  [<ffffffff8109f74a>] ? tick_program_event+0x2a/0x2c
[   90.544012]  [<ffffffff81032b8c>] call_softirq+0x1c/0x3e
[   90.544012]  [<ffffffff81034615>] do_softirq+0x3d/0x85
[   90.544012]  [<ffffffff81078d49>] irq_exit+0x4a/0x8c
[   90.544012]  [<ffffffff8143708c>] smp_apic_timer_interrupt+0x99/0xa7
[   90.544012]  [<ffffffff81032653>] apic_timer_interrupt+0x13/0x20
[   90.544012]  <EOI>  [<ffffffff81039700>] ? mwait_idle+0x85/0x92
[   90.544012]  [<ffffffff810396f7>] ? mwait_idle+0x7c/0x92
[   90.544012]  [<ffffffff81030d92>] cpu_idle+0x5c/0x79
[   90.544012]  [<ffffffff8142213f>] rest_init+0xc3/0xca
[   90.544012]  [<ffffffff8142207c>] ? rest_init+0x0/0xca
[   90.544012]  [<ffffffff81b47d77>] start_kernel+0x3e2/0x3ed
[   90.544012]  [<ffffffff81b4729f>] x86_64_start_reservations+0xaf/0xb3
[   90.544012]  [<ffffffff81b47393>] x86_64_start_kernel+0xf0/0xf7

At some point in the past of the lifetime of this kernel we grabbed
exactly the following 3 locks in the following order (where the first
2 were still held while we grabbed the 3rd):
  (&tbl->lock){++--..}   =>   (&n->lock){++--..}  =>
(&(&rt_hash_locks[i])->rlock){+.-...}

Now, we have grabbed the first three (are still holding them and are
trying to grab the fourth) of these locks in this order:
  (&n->timer){+.-...}   =>   (slock-AF_INET){+.-...}   =>
(&(&rt_hash_locks[i])->rlock){+.-...}  =>   (&tbl->lock){++--..}

We're complaining that this 4th lock is being grabbed after the 3rd,
when previously it was the 1st before the 3rd - we've apparently
reversed lock ordering...
