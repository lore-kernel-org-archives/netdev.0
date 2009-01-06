From: Zdenek Kabelac <zkabelac@redhat.com>
Subject: Re: [BUG] INFO: inconsistent lock state
Date: Tue, 06 Jan 2009 13:38:55 +0100
Message-ID: <496350DF.5030500@redhat.com>
References: <4962C322.8000201@cn.fujitsu.com> <49633005.5080305@redhat.com> <4963319D.8040204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38388 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795AbZAFMjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 07:39:06 -0500
In-Reply-To: <4963319D.8040204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Li Zefan napsal(a):
> Zdenek Kabelac wrote:
>> Li Zefan napsal(a):
>>> I am using Linus' tree, and the top commit is:
>>>
>>> commit fe0bdec68b77020281dc814805edfe594ae89e0f
>>> Merge: 099e657... 5af75d8...
>>> Author: Linus Torvalds <torvalds@linux-foundation.org>
>>> Date:   Sun Jan 4 16:32:11 2009 -0800
>>>
>>>     Merge branch 'audit.b61' of
>>> git://git.kernel.org/pub/scm/linux/kernel/git/viro/audit-current
>>>
>>> don't know how I triggered this, and not sure whom to CC, network
>>> related?
>>>
>> I've got the similar one too: http://lkml.org/lkml/2009/1/3/55
>>
> 
> So your box freezed and can do nothing but reset ?
> 
> I was much luckier that this bug didn't do any harm to my box. :)
> 

I've just tested the very latest build from git repository:
(commit: 238c6d54830c624f34ac9cf123ac04aebfca5013)

And I still get this INFO trace - and this time my machine seems to be still 
alive:


=================================
[ INFO: inconsistent lock state ]
2.6.28 #103
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
firefox/3196 [HC0[0]:SC1[1]:HE1:SE0] takes:
  (&fbc->lock){-+..}, at: [<ffffffff803aace8>] __percpu_counter_add+0x58/0x80
{softirq-on-W} state was registered at:
   [<ffffffff8026f85c>] __lock_acquire+0x3ac/0x1280
   [<ffffffff802707c1>] lock_acquire+0x91/0xc0
   [<ffffffff80538781>] _spin_lock+0x31/0x70
   [<ffffffff803aace8>] __percpu_counter_add+0x58/0x80
   [<ffffffff802da20e>] get_empty_filp+0x7e/0x1a0
   [<ffffffff802e4e26>] path_lookup_open+0x36/0xd0
   [<ffffffff802e5ce8>] do_filp_open+0xb8/0x920
   [<ffffffff802d6c98>] do_sys_open+0x78/0x100
   [<ffffffff802d6d4b>] sys_open+0x1b/0x20
   [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b
   [<ffffffffffffffff>] 0xffffffffffffffff
irq event stamp: 486132
hardirqs last  enabled at (486132): [<ffffffff8026f2f2>] 
debug_check_no_locks_freed+0x92/0x150
hardirqs last disabled at (486131): [<ffffffff8026f293>] 
debug_check_no_locks_freed+0x33/0x150
softirqs last  enabled at (486096): [<ffffffff804a25d5>] release_sock+0xd5/0xe0
softirqs last disabled at (486097): [<ffffffff8020d8bc>] call_softirq+0x1c/0x50

other info that might help us debug this:
5 locks held by firefox/3196:
  #0:  (rcu_read_lock){..--}, at: [<ffffffff804b2842>] net_rx_action+0x102/0x290
  #1:  (rcu_read_lock){..--}, at: [<ffffffff804ae4c0>] 
netif_receive_skb+0x100/0x400
  #2:  (rcu_read_lock){..--}, at: [<ffffffff804d0080>] 
ip_local_deliver_finish+0x40/0x260
  #3:  (slock-AF_INET/1){-+..}, at: [<ffffffff804f0bde>] tcp_v4_rcv+0x59e/0x840
  #4:  (slock-AF_INET){-+..}, at: [<ffffffff804a46de>] sk_clone+0xee/0x3b0

stack backtrace:
Pid: 3196, comm: firefox Not tainted 2.6.28 #103
Call Trace:
  <IRQ>  [<ffffffff8026d31d>] print_usage_bug+0x17d/0x190
  [<ffffffff8026ebf3>] mark_lock+0x523/0x840
  [<ffffffff8026f9d5>] __lock_acquire+0x525/0x1280
  [<ffffffff802707c1>] lock_acquire+0x91/0xc0
  [<ffffffff803aace8>] ? __percpu_counter_add+0x58/0x80
  [<ffffffff80538781>] _spin_lock+0x31/0x70
  [<ffffffff803aace8>] ? __percpu_counter_add+0x58/0x80
  [<ffffffff803aace8>] __percpu_counter_add+0x58/0x80
  [<ffffffff804a495e>] sk_clone+0x36e/0x3b0
  [<ffffffff804d9ce1>] inet_csk_clone+0x11/0xa0
  [<ffffffff804f140d>] tcp_create_openreq_child+0x1d/0x420
  [<ffffffff804ef233>] tcp_v4_syn_recv_sock+0x53/0x1f0
  [<ffffffff804f129b>] tcp_check_req+0x2ab/0x400
  [<ffffffff804ef0f2>] tcp_v4_do_rcv+0x152/0x240
  [<ffffffff804f0bfe>] tcp_v4_rcv+0x5be/0x840
  [<ffffffff804d0153>] ip_local_deliver_finish+0x113/0x260
  [<ffffffff804d0080>] ? ip_local_deliver_finish+0x40/0x260
  [<ffffffff804d032d>] ip_local_deliver+0x8d/0xa0
  [<ffffffff804cf9a3>] ip_rcv_finish+0x133/0x390
  [<ffffffff804cfe63>] ip_rcv+0x263/0x2f0
  [<ffffffff804ae6ca>] netif_receive_skb+0x30a/0x400
  [<ffffffff804ae4c0>] ? netif_receive_skb+0x100/0x400
  [<ffffffff804aee48>] napi_gro_receive+0x38/0x40
  [<ffffffff804b15fa>] process_backlog+0x8a/0xe0
  [<ffffffff804b2847>] ? net_rx_action+0x107/0x290
  [<ffffffff804b28bf>] net_rx_action+0x17f/0x290
  [<ffffffff804b2842>] ? net_rx_action+0x102/0x290
  [<ffffffff8024b13c>] __do_softirq+0x9c/0x180
  [<ffffffff8020d8bc>] call_softirq+0x1c/0x50
  <EOI>  [<ffffffff8020ec65>] do_softirq+0x75/0xc0
  [<ffffffff804a25d5>] ? release_sock+0xd5/0xe0
  [<ffffffff8024b666>] local_bh_enable_ip+0xf6/0x100
  [<ffffffff805384df>] _spin_unlock_bh+0x2f/0x40
  [<ffffffff804a25d5>] release_sock+0xd5/0xe0
  [<ffffffff804fde14>] inet_stream_connect+0x64/0x2c0
  [<ffffffff802d9f81>] ? fget_light+0x101/0x110
  [<ffffffff802d9edd>] ? fget_light+0x5d/0x110
  [<ffffffff804a0378>] sys_connect+0xb8/0xd0
  [<ffffffff8020d1a9>] ? retint_swapgs+0xe/0x13
  [<ffffffff8026f1ea>] ? trace_hardirqs_on_caller+0x16a/0x1d0
  [<ffffffff802904be>] ? audit_syscall_entry+0x17e/0x1a0
  [<ffffffff80538066>] ? trace_hardirqs_on_thunk+0x3a/0x3f
  [<ffffffff8020c6db>] system_call_fastpath+0x16/0x1b


Zdenek
