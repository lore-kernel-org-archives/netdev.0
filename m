From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 12 Feb 2008 10:58:21 +0000
Message-ID: <47B17BCD.2070903@katalix.com>
References: <47B0C9F7.5040200@katalix.com>	<20080211224924.GA2863@ami.dom.local>	<47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:38188 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbYBLK63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Feb 2008 05:58:29 -0500
In-Reply-To: <20080211.213048.192442721.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: James Chapman <jchapman@katalix.com>
> Date: Mon, 11 Feb 2008 23:41:18 +0000
> 
>> Jarek Poplawski wrote:
>>> On Mon, Feb 11, 2008 at 10:19:35PM +0000, James Chapman wrote:
>>> ...
>>>> Below is example output from lockdep. The oops is reproducible when  
>>>> creating/deleting lots of sessions while passing data. The lock is being  
>>>> acquired for read and write in softirq contexts.
>>>>
>>>> Is there a better way to fix this?
>>>>
>>>> =================================
>>>> [ INFO: inconsistent lock state ]
>>>> 2.6.24-core2 #1
>>>> ---------------------------------
>>>> inconsistent {in-softirq-R} -> {softirq-on-W} usage.
>>>> openl2tpd/3215 [HC0[0]:SC0[0]:HE1:SE1] takes:
>>>>   (&tunnel->hlist_lock){---?}, at: [<f8eea157>]
>>>> pppol2tp_connect+0x517/0x6d0 [pppol2tp]
>>>> {in-softirq-R} state was registered at:
>>> IMHO, according to this, disabling bh should be enough. And if it's
>>> like in this report: only read_lock is taken from softirqs, then this
>>> should be necessary to change only all write_locks to write_lock_bh
>>> (of course unless somewhere bhs are disabled already). Unless I miss
>>> something?!
>> I thought so too. I tried _bh locks first and the problem still 
>> occurred. Maybe I'll try it again in case I messed something up.
> 
> I agree with Jarek here, I look at all the code paths that take
> ->hlist_lock and all of them are in user context or software
> interrupts.
> 
> Please get a lockdep trace with the change to _bh intead of
> hw interrupt protection so we can find out what that doesn't
> work.
> 
> Thanks!

Here is a trace from when we had _bh locks.

Feb  5 16:26:32  ======================================================
Feb  5 16:26:32  [ INFO: soft-safe -> soft-unsafe lock order detected ]
Feb  5 16:26:32  2.6.24-core2 #1
Feb  5 16:26:32  ------------------------------------------------------
Feb  5 16:26:32  pppd/3224 [HC0[0]:SC0[2]:HE1:SE0] is trying to acquire:
Feb  5 16:26:32  (&sk->sk_dst_lock){----}, at: [<f8efacac>] 
pppol2tp_xmit+0x23c/0x460 [pppol2tp]
Feb  5 16:26:32
Feb  5 16:26:32  and this task is already holding:
Feb  5 16:26:32  (&pch->downl){-...}, at: [<f8eb828e>] 
ppp_push+0x44e/0x620 [ppp_generic]
Feb  5 16:26:32  which would create a new lock dependency:
Feb  5 16:26:32  (&pch->downl){-...} -> (&sk->sk_dst_lock){----}
Feb  5 16:26:32
Feb  5 16:26:32  but this new dependency connects a soft-irq-safe lock:
Feb  5 16:26:32  (&pch->upl){-.-+}
Feb  5 16:26:32  ... which became soft-irq-safe at:
Feb  5 16:26:32  [<c014d87f>] check_usage_backwards+0x1f/0x50
Feb  5 16:26:32  [<c014c479>] save_trace+0x39/0xa0
Feb  5 16:26:32  [<c014edaf>] __lock_acquire+0x6bf/0x10a0
Feb  5 16:26:32  [<c014ee8e>] __lock_acquire+0x79e/0x10a0
Feb  5 16:26:32  [<c014ee8e>] __lock_acquire+0x79e/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eba092>] ppp_input+0x62/0x140 [ppp_generic]
Feb  5 16:26:32  [<c040425f>] _read_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eba092>] ppp_input+0x62/0x140 [ppp_generic]
Feb  5 16:26:32  [<f8eba092>] ppp_input+0x62/0x140 [ppp_generic]
Feb  5 16:26:32  [<f8ef915a>] pppol2tp_recv_core+0x46a/0x960 [pppol2tp]
Feb  5 16:26:32  [<f8ef967e>] pppol2tp_udp_encap_recv+0x2e/0x70 [pppol2tp]
Feb  5 16:26:32  [<c0403fd4>] _read_unlock+0x14/0x20
Feb  5 16:26:32  [<c03dd6b6>] udp_queue_rcv_skb+0x106/0x2a0
Feb  5 16:26:32  [<c03ddc7a>] __udp4_lib_rcv+0x42a/0x7e0
Feb  5 16:26:32  [<f8d5c090>] ipt_hook+0x0/0x20 [iptable_filter]
Feb  5 16:26:32  [<c03bc2fa>] ip_local_deliver_finish+0xca/0x1c0
Feb  5 16:26:32  [<c03bc25e>] ip_local_deliver_finish+0x2e/0x1c0
Feb  5 16:26:32  [<c03bbfcf>] ip_rcv_finish+0xff/0x360
Feb  5 16:26:32  [<c03bc6fc>] ip_rcv+0x20c/0x2a0
Feb  5 16:26:32  [<c03bbed0>] ip_rcv_finish+0x0/0x360
Feb  5 16:26:32  [<c039ad87>] netif_receive_skb+0x317/0x4b0
Feb  5 16:26:32  [<c039ab70>] netif_receive_skb+0x100/0x4b0
Feb  5 16:26:32  [<f8d7e27a>] e1000_clean_rx_irq_ps+0x28a/0x560 [e1000]
Feb  5 16:26:32  [<f8d7dff0>] e1000_clean_rx_irq_ps+0x0/0x560 [e1000]
Feb  5 16:26:32  [<f8d7b84d>] e1000_clean+0x5d/0x290 [e1000]
Feb  5 16:26:32  [<c039d580>] net_rx_action+0x1a0/0x2a0
Feb  5 16:26:32  [<c039d43f>] net_rx_action+0x5f/0x2a0
Feb  5 16:26:32  [<c0131e72>] __do_softirq+0x92/0x120
Feb  5 16:26:32  [<c0131f78>] do_softirq+0x78/0x80
Feb  5 16:26:32  [<c010b15a>] do_IRQ+0x4a/0xa0
Feb  5 16:26:32  [<c0127af0>] finish_task_switch+0x0/0xc0
Feb  5 16:26:32  [<c0108dcc>] common_interrupt+0x24/0x34
Feb  5 16:26:32  [<c0108dd6>] common_interrupt+0x2e/0x34
Feb  5 16:26:32  [<c01062d6>] mwait_idle_with_hints+0x46/0x60
Feb  5 16:26:32  [<c0106550>] mwait_idle+0x0/0x20
Feb  5 16:26:32  [<c0106694>] cpu_idle+0x74/0xe0
Feb  5 16:26:32  [<c0536a9a>] start_kernel+0x30a/0x3a0
Feb  5 16:26:32  [<c0536150>] unknown_bootoption+0x0/0x1f0
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32
Feb  5 16:26:32  to a soft-irq-unsafe lock:
Feb  5 16:26:32  (&sk->sk_dst_lock){----}
Feb  5 16:26:32  ... which became soft-irq-unsafe at:
Feb  5 16:26:32  ...  [<c014e02e>] mark_held_locks+0x5e/0x80
Feb  5 16:26:32  [<c014ed92>] __lock_acquire+0x6a2/0x10a0
Feb  5 16:26:32  [<c010f5b0>] save_stack_trace+0x20/0x40
Feb  5 16:26:32  [<c014c524>] add_lock_to_list+0x44/0xb0
Feb  5 16:26:32  [<c03dea29>] __udp_lib_get_port+0x19/0x200
Feb  5 16:26:32  [<c014f735>] __lock_acquire+0x1045/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<c03db0a3>] ip4_datagram_connect+0x53/0x380
Feb  5 16:26:32  [<c040418a>] _write_lock+0x2a/0x40
Feb  5 16:26:32  [<c03db0a3>] ip4_datagram_connect+0x53/0x380
Feb  5 16:26:32  [<c03db0a3>] ip4_datagram_connect+0x53/0x380
Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
Feb  5 16:26:32  [<c0132317>] local_bh_enable_ip+0xa7/0x120
Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
Feb  5 16:26:32  [<c040414f>] _spin_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<c03e4d55>] inet_dgram_connect+0x35/0x80
Feb  5 16:26:32  [<c038ec52>] sys_connect+0x82/0xd0
Feb  5 16:26:32  [<c01455df>] down_read_trylock+0x4f/0x60
Feb  5 16:26:32  [<c011fe9c>] do_page_fault+0xfc/0x940
Feb  5 16:26:32  [<c0404024>] _spin_unlock+0x14/0x20
Feb  5 16:26:32  [<c03905f8>] sys_socketcall+0x98/0x280
Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
Feb  5 16:26:32  [<c02a86ba>] copy_to_user+0x3a/0x70
Feb  5 16:26:32  [<c0108417>] restore_nocheck+0x12/0x15
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32
Feb  5 16:26:32  other info that might help us debug this:
Feb  5 16:26:32
Feb  5 16:26:32  2 locks held by pppd/3224:
Feb  5 16:26:32  #0:  (&ppp->wlock){-...}, at: [<f8eb8478>] 
ppp_xmit_process+0x18/0x630 [ppp_generic]
Feb  5 16:26:32  #1:  (&pch->downl){-...}, at: [<f8eb828e>] 
ppp_push+0x44e/0x620 [ppp_generic]
Feb  5 16:26:32
Feb  5 16:26:32  the soft-irq-safe lock's dependencies:
Feb  5 16:26:32  -> (&pch->upl){-.-+} ops: 0 {
Feb  5 16:26:32  initial-use  at:
Feb  5 16:26:32  [<c014e80d>] __lock_acquire+0x11d/0x10a0
Feb  5 16:26:32  [<f8efacf3>] pppol2tp_xmit+0x283/0x460 [pppol2tp]
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb8af2>] ppp_channel_push+0x62/0x90 [ppp_generic]
Feb  5 16:26:32  [<c040425f>] _read_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb8af2>] ppp_channel_push+0x62/0x90 [ppp_generic]
Feb  5 16:26:32  [<f8eb8af2>] ppp_channel_push+0x62/0x90 [ppp_generic]
Feb  5 16:26:32  [<f8eb9ffd>] ppp_write+0xdd/0x110 [ppp_generic]
Feb  5 16:26:32  [<c0181f86>] vfs_write+0xa6/0x140
Feb  5 16:26:32  [<c0108417>] restore_nocheck+0x12/0x15
Feb  5 16:26:32  [<f8eb9f20>] ppp_write+0x0/0x110 [ppp_generic]
Feb  5 16:26:32  [<c0182651>] sys_write+0x41/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  hardirq-on-W at:
Feb  5 16:26:32  [<c014ee8e>] __lock_acquire+0x79e/0x10a0
Feb  5 16:26:32  [<c014c524>] add_lock_to_list+0x44/0xb0
Feb  5 16:26:32  [<c014ed68>] __lock_acquire+0x678/0x10a0
Feb  5 16:26:32  [<c014e02e>] mark_held_locks+0x5e/0x80
Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb7387>] ppp_ioctl+0x647/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c04041cf>] _write_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb7387>] ppp_ioctl+0x647/0xf40 [ppp_generic]
Feb  5 16:26:32  [<f8eb7387>] ppp_ioctl+0x647/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c0404665>] _spin_unlock_irqrestore+0x55/0x70
Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
Feb  5 16:26:32  [<c0403e4e>] __down+0xde/0xed
Feb  5 16:26:32  [<c0124220>] default_wake_function+0x0/0x10
Feb  5 16:26:32  [<c0403bdb>] __down_failed+0x7/0xc
Feb  5 16:26:32  [<c018d8f8>] do_ioctl+0x78/0x90
Feb  5 16:26:32  [<c018d96c>] vfs_ioctl+0x5c/0x290
Feb  5 16:26:32  [<c018dbdd>] sys_ioctl+0x3d/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  in-softirq-R at:
Feb  5 16:26:32  [<c014d87f>] check_usage_backwards+0x1f/0x50
Feb  5 16:26:32  [<c014c479>] save_trace+0x39/0xa0
Feb  5 16:26:32  [<c014edaf>] __lock_acquire+0x6bf/0x10a0
Feb  5 16:26:32  [<c014ee8e>] __lock_acquire+0x79e/0x10a0
Feb  5 16:26:32  [<c014ee8e>] __lock_acquire+0x79e/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eba092>] ppp_input+0x62/0x140 [ppp_generic]
Feb  5 16:26:32  [<c040425f>] _read_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eba092>] ppp_input+0x62/0x140 [ppp_generic]
Feb  5 16:26:32  [<f8eba092>] ppp_input+0x62/0x140 [ppp_generic]
Feb  5 16:26:32  [<f8ef915a>] pppol2tp_recv_core+0x46a/0x960 [pppol2tp]
Feb  5 16:26:32  [<f8ef967e>] pppol2tp_udp_encap_recv+0x2e/0x70 [pppol2tp]
Feb  5 16:26:32  [<c0403fd4>] _read_unlock+0x14/0x20
Feb  5 16:26:32  [<c03dd6b6>] udp_queue_rcv_skb+0x106/0x2a0
Feb  5 16:26:32  [<c03ddc7a>] __udp4_lib_rcv+0x42a/0x7e0
Feb  5 16:26:32  [<f8d5c090>] ipt_hook+0x0/0x20 [iptable_filter]
Feb  5 16:26:32  [<c03bc2fa>] ip_local_deliver_finish+0xca/0x1c0
Feb  5 16:26:32  [<c03bc25e>] ip_local_deliver_finish+0x2e/0x1c0
Feb  5 16:26:32  [<c03bbfcf>] ip_rcv_finish+0xff/0x360
Feb  5 16:26:32  [<c03bc6fc>] ip_rcv+0x20c/0x2a0
Feb  5 16:26:32  [<c03bbed0>] ip_rcv_finish+0x0/0x360
Feb  5 16:26:32  [<c039ad87>] netif_receive_skb+0x317/0x4b0
Feb  5 16:26:32  [<c039ab70>] netif_receive_skb+0x100/0x4b0
Feb  5 16:26:32  [<f8d7e27a>] e1000_clean_rx_irq_ps+0x28a/0x560 [e1000]
Feb  5 16:26:32  [<f8d7dff0>] e1000_clean_rx_irq_ps+0x0/0x560 [e1000]
Feb  5 16:26:32  [<f8d7b84d>] e1000_clean+0x5d/0x290 [e1000]
Feb  5 16:26:32  [<c039d580>] net_rx_action+0x1a0/0x2a0
Feb  5 16:26:32  [<c039d43f>] net_rx_action+0x5f/0x2a0
Feb  5 16:26:32  [<c0131e72>] __do_softirq+0x92/0x120
Feb  5 16:26:32  [<c0131f78>] do_softirq+0x78/0x80
Feb  5 16:26:32  [<c010b15a>] do_IRQ+0x4a/0xa0
Feb  5 16:26:32  [<c0127af0>] finish_task_switch+0x0/0xc0
Feb  5 16:26:32  [<c0108dcc>] common_interrupt+0x24/0x34
Feb  5 16:26:32  [<c0108dd6>] common_interrupt+0x2e/0x34
Feb  5 16:26:32  [<c01062d6>] mwait_idle_with_hints+0x46/0x60
Feb  5 16:26:32  [<c0106550>] mwait_idle+0x0/0x20
Feb  5 16:26:32  [<c0106694>] cpu_idle+0x74/0xe0
Feb  5 16:26:32  [<c0536a9a>] start_kernel+0x30a/0x3a0
Feb  5 16:26:32  [<c0536150>] unknown_bootoption+0x0/0x1f0
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  hardirq-on-R at:
Feb  5 16:26:32  [<c014da27>] mark_lock+0x77/0x620
Feb  5 16:26:32  [<c014ec2f>] __lock_acquire+0x53f/0x10a0
Feb  5 16:26:32  [<f8efacf3>] pppol2tp_xmit+0x283/0x460 [pppol2tp]
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb8af2>] ppp_channel_push+0x62/0x90 [ppp_generic]
Feb  5 16:26:32  [<c040425f>] _read_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb8af2>] ppp_channel_push+0x62/0x90 [ppp_generic]
Feb  5 16:26:32  [<f8eb8af2>] ppp_channel_push+0x62/0x90 [ppp_generic]
Feb  5 16:26:32  [<f8eb9ffd>] ppp_write+0xdd/0x110 [ppp_generic]
Feb  5 16:26:32  [<c0181f86>] vfs_write+0xa6/0x140
Feb  5 16:26:32  [<c0108417>] restore_nocheck+0x12/0x15
Feb  5 16:26:32  [<f8eb9f20>] ppp_write+0x0/0x110 [ppp_generic]
Feb  5 16:26:32  [<c0182651>] sys_write+0x41/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  }
Feb  5 16:26:32  ... key      at: [<f8ebdf20>] 
__key.30415+0x0/0xffffc2e7 [ppp_generic]
Feb  5 16:26:32  -> (&ppp->wlock){-...} ops: 0 {
Feb  5 16:26:32  initial-use  at:
Feb  5 16:26:32  [<c014e80d>] __lock_acquire+0x11d/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb7698>] ppp_ioctl+0x958/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c040414f>] _spin_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb7698>] ppp_ioctl+0x958/0xf40 [ppp_generic]
Feb  5 16:26:32  [<f8eb7698>] ppp_ioctl+0x958/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c0404665>] _spin_unlock_irqrestore+0x55/0x70
Feb  5 16:26:32  [<c0403e4e>] __down+0xde/0xed
Feb  5 16:26:32  [<c0124220>] default_wake_function+0x0/0x10
Feb  5 16:26:32  [<c0403bdb>] __down_failed+0x7/0xc
Feb  5 16:26:32  [<c018d8f8>] do_ioctl+0x78/0x90
Feb  5 16:26:32  [<c018d96c>] vfs_ioctl+0x5c/0x290
Feb  5 16:26:32  [<c018dbdd>] sys_ioctl+0x3d/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  hardirq-on-W at:
Feb  5 16:26:32  [<c014da27>] mark_lock+0x77/0x620
Feb  5 16:26:32  [<c014ed68>] __lock_acquire+0x678/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb7698>] ppp_ioctl+0x958/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c040414f>] _spin_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb7698>] ppp_ioctl+0x958/0xf40 [ppp_generic]
Feb  5 16:26:32  [<f8eb7698>] ppp_ioctl+0x958/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c0404665>] _spin_unlock_irqrestore+0x55/0x70
Feb  5 16:26:32  [<c0403e4e>] __down+0xde/0xed
Feb  5 16:26:32  [<c0124220>] default_wake_function+0x0/0x10
Feb  5 16:26:32  [<c0403bdb>] __down_failed+0x7/0xc
Feb  5 16:26:32  [<c018d8f8>] do_ioctl+0x78/0x90
Feb  5 16:26:32  [<c018d96c>] vfs_ioctl+0x5c/0x290
Feb  5 16:26:32  [<c018dbdd>] sys_ioctl+0x3d/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  }
Feb  5 16:26:32  ... key      at: [<f8ebdf08>] 
__key.30659+0x0/0xffffc2ff [ppp_generic]
Feb  5 16:26:32  -> (&ppp->rlock){-...} ops: 0 {
Feb  5 16:26:32  initial-use  at:
Feb  5 16:26:32  [<c014e80d>] __lock_acquire+0x11d/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb7661>] ppp_ioctl+0x921/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c040414f>] _spin_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb7661>] ppp_ioctl+0x921/0xf40 [ppp_generic]
Feb  5 16:26:32  [<f8eb7661>] ppp_ioctl+0x921/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c0404665>] _spin_unlock_irqrestore+0x55/0x70
Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
Feb  5 16:26:32  [<c0403e4e>] __down+0xde/0xed
Feb  5 16:26:32  [<c0124220>] default_wake_function+0x0/0x10
Feb  5 16:26:32  [<c0403bdb>] __down_failed+0x7/0xc
Feb  5 16:26:32  [<c018d8f8>] do_ioctl+0x78/0x90
Feb  5 16:26:32  [<c018d96c>] vfs_ioctl+0x5c/0x290
Feb  5 16:26:32  [<c018dbdd>] sys_ioctl+0x3d/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  hardirq-on-W at:
Feb  5 16:26:32  [<c014da27>] mark_lock+0x77/0x620
Feb  5 16:26:32  [<c014ed68>] __lock_acquire+0x678/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb7661>] ppp_ioctl+0x921/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c040414f>] _spin_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb7661>] ppp_ioctl+0x921/0xf40 [ppp_generic]
Feb  5 16:26:32  [<f8eb7661>] ppp_ioctl+0x921/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c0404665>] _spin_unlock_irqrestore+0x55/0x70
Feb  5 16:26:32  [<c014e1c5>] trace_hardirqs_on+0xc5/0x170
Feb  5 16:26:32  [<c0403e4e>] __down+0xde/0xed
Feb  5 16:26:32  [<c0124220>] default_wake_function+0x0/0x10
Feb  5 16:26:32  [<c0403bdb>] __down_failed+0x7/0xc
Feb  5 16:26:32  [<c018d8f8>] do_ioctl+0x78/0x90
Feb  5 16:26:32  [<c018d96c>] vfs_ioctl+0x5c/0x290
Feb  5 16:26:32  [<c018dbdd>] sys_ioctl+0x3d/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  }
Feb  5 16:26:32  ... key      at: [<f8ebdf10>] 
__key.30658+0x0/0xffffc2f7 [ppp_generic]
Feb  5 16:26:32  ... acquired at:
Feb  5 16:26:32  [<c014f68f>] __lock_acquire+0xf9f/0x10a0
Feb  5 16:26:32  [<f8eb76a5>] ppp_ioctl+0x965/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<f8eb76a5>] ppp_ioctl+0x965/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c040414f>] _spin_lock_bh+0x2f/0x40
Feb  5 16:26:32  [<f8eb76a5>] ppp_ioctl+0x965/0xf40 [ppp_generic]
Feb  5 16:26:32  [<f8eb76a5>] ppp_ioctl+0x965/0xf40 [ppp_generic]
Feb  5 16:26:32  [<c0404665>] _spin_unlock_irqrestore+0x55/0x70
Feb  5 16:26:32  [<c0403e4e>] __down+0xde/0xed
Feb  5 16:26:32  [<c0124220>] default_wake_function+0x0/0x10
Feb  5 16:26:32  [<c0403bdb>] __down_failed+0x7/0xc
Feb  5 16:26:32  [<c018d8f8>] do_ioctl+0x78/0x90
Feb  5 16:26:32  [<c018d96c>] vfs_ioctl+0x5c/0x290
Feb  5 16:26:32  [<c018dbdd>] sys_ioctl+0x3d/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32
Feb  5 16:26:32  -> (&list->lock#4){.+..} ops: 0 {
Feb  5 16:26:32  initial-use  at:
Feb  5 16:26:32  [<c014e80d>] __lock_acquire+0x11d/0x10a0
Feb  5 16:26:32  [<c0193ba2>] dput+0xa2/0x130
Feb  5 16:26:32  [<c014ee8e>] __lock_acquire+0x79e/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<c0394b9c>] skb_queue_tail+0x1c/0x50
Feb  5 16:26:32  [<c040450c>] _spin_lock_irqsave+0x4c/0x70
Feb  5 16:26:32  [<c0394b9c>] skb_queue_tail+0x1c/0x50
Feb  5 16:26:32  [<c0394b9c>] skb_queue_tail+0x1c/0x50
Feb  5 16:26:32  [<f8eb9fd5>] ppp_write+0xb5/0x110 [ppp_generic]
Feb  5 16:26:32  [<c0181f86>] vfs_write+0xa6/0x140
Feb  5 16:26:32  [<c0108417>] restore_nocheck+0x12/0x15
Feb  5 16:26:32  [<f8eb9f20>] ppp_write+0x0/0x110 [ppp_generic]
Feb  5 16:26:32  [<c0182651>] sys_write+0x41/0x70
Feb  5 16:26:32  [<c01083aa>] syscall_call+0x7/0xb
Feb  5 16:26:32  [<ffffffff>] 0xffffffff
Feb  5 16:26:32  in-softirq-W at:
Feb  5 16:26:32  [<c014c479>] save_trace+0x39/0xa0
Feb  5 16:26:32  [<c014db32>] mark_lock+0x182/0x620
Feb  5 16:26:32  [<c014ed36>] __lock_acquire+0x646/0x10a0
Feb  5 16:26:32  [<c014ef26>] __lock_acquire+0x836/0x10a0
Feb  5 16:26:32  [<c014ee8e>] __lock_acquire+0x79e/0x10a0
Feb  5 16:26:32  [<c014f804>] lock_acquire+0x74/0xa0
Feb  5 16:26:32  [<c0394b9c>] skb_queue_tail+0x1c/0x50
Feb  5 16:26:32  [<c040450c>] _spin_lock_irqsave+0x4c/0x70
Feb  5 16:26:32  [<c0394b9c>] skb_queue_tail+0x1c/0x50
Feb  5 16:26:32  [<c0394b9c>] skb_queue_tail+0x1c/0x50
Feb  5 16:26:32  [<f8eba0a8>] ppp_input+0x78/0x140 [ppp_generic]
Feb  5 16:26:32  [<f8ef915a>] pppol2tp_recv_core+0x46a/0x960 [pppol2tp]
Feb  5 16:26:32  [<f8ef967e>] pppol2tp_udp_encap_recv+0x2e/0x70 [pppol2tp]
Feb  5 16:26:32  [<c0403fd4>] _read_unlock+0x14/0x20
Feb  5 16:26:32  [<c03dd6b6>] udp_queue_rcv_skb+0x106/0x2a0
Feb  5 16:26:32  [<c03ddc7a>] __udp4_lib_rcv+0x42a/0x7e0
Feb  5 16:26:32  [<f8d5c090>] ipt_hook+0x0/0x20 [iptable_filter]
Feb  5 16:26:32  [<c03bc2fa>] ip_local_deliver_finish+0xca/0x1c0
Feb  5 16:26:32  [<c03bc25e>] ip_local_deliver_finish+0x2e/0x1c0
Feb  5 16:26:32  [<c03bbfcf>] ip_rcv_finish+0xff/0x360
Feb  5 16:26:32  [<c03bc6fc>] ip_rcv+0x20c/0x2a0
Feb  5 16:26:32  [<c03bbed0>] ip_rcv_finish+0x0/0x360
Feb  5 16:26:32  [<c039ad87>] netif_receive_skb+0x317/0x4b0
Feb  5 16:26:32  [<c039ab70>] netif_receive_skb+0x100/0x4b0
Feb  5 16:26:32  [<f8d7e27a>] e1000_clean_rx_irq_ps+0x28a/0x560 [e1000]
Feb  5 16:26:32  [<f8d7dff0>] e1000_clean_rx_irq_ps+0x0/0x560 [e1000]
Feb  5 16:26:32  [<f8d7b84d>] e1000_clean+0x5d/0x290 [e1000]
Feb  5 16:26:32  [<c039d580>] net_rx_action+0x1a0/0x2a0
Feb  5 16:26:32  [<c039d43f>] net_rx_action+0x5f/0x2a0
Feb  5 16:26:32  [<c0131e72>] __do_softirq+0x92/0x120
Feb  5 16:26:32  [<c0131f78>] do_softirq+0x78/0x80
Feb  5 16:26:32  [<c010b15a>] do_IRQ+0x4a/0xa0
Feb  5 16:26:32  [<c0127af0>] finish_task_switch+0x0/0xc0
Feb  5 16:26:32  [<c0108dcc>] common_interrupt+0x24/0x34
Feb  5 16:26:32  [<c0108dd6>] common_interrupt+0x2e/0x34
Feb  5 16:26:32  [<c01062d6>] mwait_idle_with_hints+0x46/0x60
Feb  5 16:26:32  [<c0106550>] mwait_idle+0x0/0x20
Feb  5 16:26:32  [<c0106694>] cpu_idle+0x74/0xe0
Feb  5 16:26:32  [<c0536a9a>] start_kernel+0x30a/0x3a0

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

