From: Zdenek Kabelac <zkabelac@redhat.com>
Subject: Re: [BUG] INFO: inconsistent lock state
Date: Tue, 06 Jan 2009 14:53:22 +0100
Message-ID: <49636252.2080404@redhat.com>
References: <4962C322.8000201@cn.fujitsu.com> <49633005.5080305@redhat.com> <4963319D.8040204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52449 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750972AbZAFNxe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 08:53:34 -0500
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


And here is another one slightly different:

=================================
[ INFO: inconsistent lock state ]
2.6.28 #103
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
S20sendsigs/2307 [HC0[0]:SC1[1]:HE1:SE0] takes:
  (&fbc->lock){-+..}, at: [<ffffffff803aace8>] __percpu_counter_add+0x58/0x80
{softirq-on-W} state was registered at:
   [<ffffffff8026f85c>] __lock_acquire+0x3ac/0x1280
   [<ffffffff802707c1>] lock_acquire+0x91/0xc0
   [<ffffffff80538781>] _spin_lock+0x31/0x70
   [<ffffffff803aad25>] __percpu_counter_sum+0x15/0x80
   [<ffffffff80343ab1>] ext3_statfs+0x71/0x1a0
   [<ffffffff802d8024>] vfs_statfs+0x74/0x90
   [<ffffffff8031589b>] compat_sys_statfs64+0x7b/0xb0
   [<ffffffff80231a48>] sysenter_dispatch+0x7/0x2c
   [<ffffffffffffffff>] 0xffffffffffffffff
irq event stamp: 108
hardirqs last  enabled at (108): [<ffffffff80538583>] 
_spin_unlock_irqrestore+0x43/0x70
hardirqs last disabled at (107): [<ffffffff805388e0>] 
_spin_lock_irqsave+0x20/0x90
softirqs last  enabled at (0): [<ffffffff802432bd>] copy_process+0x30d/0x13d0
softirqs last disabled at (73): [<ffffffff8020d8bc>] call_softirq+0x1c/0x50

other info that might help us debug this:
6 locks held by S20sendsigs/2307:
  #0:  (&mm->mmap_sem){----}, at: [<ffffffff8053b3b2>] do_page_fault+0x122/0xa70
  #1:  (__pte_lockptr(page)){--..}, at: [<ffffffff802bc3dd>] 
__do_fault+0x16d/0x420
  #2:  (rcu_read_lock){..--}, at: [<ffffffff804b2842>] net_rx_action+0x102/0x290
  #3:  (rcu_read_lock){..--}, at: [<ffffffff804ae4c0>] 
netif_receive_skb+0x100/0x400
  #4:  (rcu_read_lock){..--}, at: [<ffffffff804d0080>] 
ip_local_deliver_finish+0x40/0x260
  #5:  (slock-AF_INET/1){-+..}, at: [<ffffffff804f0bde>] tcp_v4_rcv+0x59e/0x840

stack backtrace:
Pid: 2307, comm: S20sendsigs Not tainted 2.6.28 #103
Call Trace:
  <IRQ>  [<ffffffff8026d31d>] print_usage_bug+0x17d/0x190
  [<ffffffff8026ebf3>] mark_lock+0x523/0x840
  [<ffffffff8026f9d5>] __lock_acquire+0x525/0x1280
  [<ffffffff802707c1>] lock_acquire+0x91/0xc0
  [<ffffffff803aace8>] ? __percpu_counter_add+0x58/0x80
  [<ffffffff80538781>] _spin_lock+0x31/0x70
  [<ffffffff803aace8>] ? __percpu_counter_add+0x58/0x80
  [<ffffffff8026f25d>] ? trace_hardirqs_on+0xd/0x10
  [<ffffffff803aace8>] __percpu_counter_add+0x58/0x80
  [<ffffffff804f061d>] tcp_v4_destroy_sock+0x23d/0x260
  [<ffffffff804d9be2>] inet_csk_destroy_sock+0x52/0x140
  [<ffffffff804dd4b6>] tcp_done+0x46/0x80
  [<ffffffff804f1880>] tcp_time_wait+0x70/0x230
  [<ffffffff804e3ba7>] tcp_fin+0x117/0x200
  [<ffffffff804e4261>] tcp_data_queue+0x261/0xd10
  [<ffffffff80250c1b>] ? mod_timer+0x4b/0x60
  [<ffffffff804e83f9>] tcp_rcv_state_process+0x6b9/0xa50
  [<ffffffff804ef050>] tcp_v4_do_rcv+0xb0/0x240
  [<ffffffff8053873b>] ? _spin_lock_nested+0x5b/0x70
  [<ffffffff804f0bfe>] tcp_v4_rcv+0x5be/0x840
  [<ffffffff804d0153>] ip_local_deliver_finish+0x113/0x260
  [<ffffffff804d0080>] ? ip_local_deliver_finish+0x40/0x260
  [<ffffffff804d032d>] ip_local_deliver+0x8d/0xa0
  [<ffffffff804cf9a3>] ip_rcv_finish+0x133/0x390
  [<ffffffff804cfe63>] ip_rcv+0x263/0x2f0
  [<ffffffff804ae6ca>] netif_receive_skb+0x30a/0x400
  [<ffffffff804ae4c0>] ? netif_receive_skb+0x100/0x400
  [<ffffffff80212bb0>] ? nommu_map_single+0x0/0xa0
  [<ffffffffa005f0ec>] cp_rx_poll+0x2ac/0x410 [8139cp]
  [<ffffffff804b28bf>] net_rx_action+0x17f/0x290
  [<ffffffff804b2842>] ? net_rx_action+0x102/0x290
  [<ffffffff8024b13c>] __do_softirq+0x9c/0x180
  [<ffffffff8020d8bc>] call_softirq+0x1c/0x50
  [<ffffffff8020ec65>] do_softirq+0x75/0xc0
  [<ffffffff8024ad95>] irq_exit+0x95/0xa0
  [<ffffffff8020ef1a>] do_IRQ+0xba/0x1b0
  [<ffffffff8020d113>] ret_from_intr+0x0/0xf

Zdenek
