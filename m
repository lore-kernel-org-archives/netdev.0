From: David Miller <davem@davemloft.net>
Subject: Re: X or AF_UNIX and order 3 allocation
Date: Tue, 15 Apr 2008 21:51:44 -0700 (PDT)
Message-ID: <20080415.215144.87148045.davem@davemloft.net>
References: <20080415211055.882e67fe.zaitcev@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: zaitcev@redhat.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760456AbYDPEv5@vger.kernel.org>
In-Reply-To: <20080415211055.882e67fe.zaitcev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pete Zaitcev <zaitcev@redhat.com>
Date: Tue, 15 Apr 2008 21:10:55 -0700

> Hi, Guys:
> 
> Not sure if the problem is caused by X or kernel, but this is what

It seems to be the b44 driver doing a large huge order allocation.

That driver only asks for (1536 + 30 + 64) bytes, so I suppose part of
the problem is that SLAB is using an order 3 allocation to satisfy
that.

lkml added to CC:

> Apr 13 18:19:14 niphredil kernel: Xorg: page allocation failure. order:3, mode:0x4020
> Apr 13 18:19:14 niphredil kernel: Pid: 2399, comm: Xorg Not tainted 2.6.25-0.195.rc8.git1.fc9.x86_64 #1
> Apr 13 18:19:14 niphredil kernel: 
> Apr 13 18:19:14 niphredil kernel: Call Trace:
> Apr 13 18:19:14 niphredil kernel:  <IRQ>  [__alloc_pages+931/963] __alloc_pages+0x3a3/0x3c3
> Apr 13 18:19:14 niphredil kernel:  [unfreeze_slab+112/179] ? unfreeze_slab+0x70/0xb3
> Apr 13 18:19:14 niphredil kernel:  [alloc_pages_current+256/265] alloc_pages_current+0x100/0x109
> Apr 13 18:19:14 niphredil kernel:  [new_slab+74/585] new_slab+0x4a/0x249
> Apr 13 18:19:14 niphredil kernel:  [__slab_alloc+593/1248] __slab_alloc+0x251/0x4e0
> Apr 13 18:19:14 niphredil kernel:  [__netdev_alloc_skb+49/79] ? __netdev_alloc_skb+0x31/0x4f
> Apr 13 18:19:14 niphredil kernel:  [__kmalloc_node_track_caller+138/226] __kmalloc_node_track_caller+0x8a/0xe2
> Apr 13 18:19:14 niphredil kernel:  [sched_clock+80/109] ? native_sched_clock+0x50/0x6d
> Apr 13 18:19:14 niphredil kernel:  [__netdev_alloc_skb+49/79] ? __netdev_alloc_skb+0x31/0x4f
> Apr 13 18:19:14 niphredil kernel:  [__alloc_skb+111/309] __alloc_skb+0x6f/0x135
> Apr 13 18:19:14 niphredil kernel:  [__netdev_alloc_skb+49/79] __netdev_alloc_skb+0x31/0x4f
> Apr 13 18:19:14 niphredil kernel:  [_end+108612744/2109740072] :b44:b44_alloc_rx_skb+0x43/0x2c0
> Apr 13 18:19:14 niphredil kernel:  [_end+108621334/2109740072] :b44:b44_poll+0x240/0x4ea
> Apr 13 18:19:14 niphredil kernel:  [net_rx_action+217/526] net_rx_action+0xd9/0x20e
> Apr 13 18:19:14 niphredil kernel:  [__do_softirq+112/241] __do_softirq+0x70/0xf1
> Apr 13 18:19:14 niphredil kernel:  [call_softirq+28/40] call_softirq+0x1c/0x28
> Apr 13 18:19:14 niphredil kernel:  [do_softirq+57/138] do_softirq+0x39/0x8a
> Apr 13 18:19:14 niphredil kernel:  [irq_exit+78/143] irq_exit+0x4e/0x8f
> Apr 13 18:19:14 niphredil kernel:  [do_IRQ+325/359] do_IRQ+0x145/0x167
> Apr 13 18:19:14 niphredil kernel:  [ret_from_intr+0/15] ret_from_intr+0x0/0xf
> Apr 13 18:19:14 niphredil kernel:  <EOI>  [_spin_unlock_irqrestore+66/71] ? _spin_unlock_irqrestore+0x42/0x47
> Apr 13 18:19:14 niphredil kernel:  [add_wait_queue+55/64] ? add_wait_queue+0x37/0x40
> Apr 13 18:19:14 niphredil kernel:  [__pollwait+214/224] ? __pollwait+0xd6/0xe0
> Apr 13 18:19:14 niphredil kernel:  [unix_poll+35/164] ? unix_poll+0x23/0xa4
> Apr 13 18:19:14 niphredil kernel:  [sock_poll+24/26] ? sock_poll+0x18/0x1a
> Apr 13 18:19:14 niphredil kernel:  [do_select+841/1339] ? do_select+0x349/0x53b
> Apr 13 18:19:14 niphredil kernel:  [__pollwait+0/224] ? __pollwait+0x0/0xe0
> Apr 13 18:19:14 niphredil kernel:  [default_wake_function+0/15] ? default_wake_function+0x0/0xf
> Apr 13 18:19:15 niphredil kernel:last message repeated 9 times
> Apr 13 18:19:14 niphredil kernel:  [core_sys_select+486/660] ? core_sys_select+0x1e6/0x294
> Apr 13 18:19:14 niphredil kernel:  [sched_clock+80/109] ? native_sched_clock+0x50/0x6d
> Apr 13 18:19:14 niphredil kernel:  [hrtimer_try_to_cancel+112/121] ? hrtimer_try_to_cancel+0x70/0x79
> Apr 13 18:19:14 niphredil kernel:  [sched_clock+80/109] ? native_sched_clock+0x50/0x6d
> Apr 13 18:19:14 niphredil kernel:  [do_setitimer+387/805] ? do_setitimer+0x183/0x325
> Apr 13 18:19:14 niphredil kernel:  [lock_release_holdtime+30/264] ? lock_release_holdtime+0x1e/0x108
> Apr 13 18:19:14 niphredil kernel:  [_spin_unlock_irq+43/48] ? _spin_unlock_irq+0x2b/0x30
> Apr 13 18:19:14 niphredil kernel:  [trace_hardirqs_on+241/277] ? trace_hardirqs_on+0xf1/0x115
> Apr 13 18:19:14 niphredil kernel:  [sys_select+181/343] ? sys_select+0xb5/0x157
> Apr 13 18:19:14 niphredil kernel:  [tracesys+213/218] ? tracesys+0xd5/0xda
