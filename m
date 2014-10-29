From: Sabrina Dubroca <sd@queasysnail.net>
Subject: e1000_netpoll(): disable_irq() triggers might_sleep() on linux-next
Date: Wed, 29 Oct 2014 16:56:20 +0100
Message-ID: <20141029155620.GA4886@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org,
	jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit e22b886a8a43b ("sched/wait: Add might_sleep() checks") included
in today's linux-next added a check that fires on e1000 with netpoll:


BUG: sleeping function called from invalid context at kernel/irq/manage.c:104
in_atomic(): 1, irqs_disabled(): 1, pid: 1, name: systemd
no locks held by systemd/1.
irq event stamp: 10102965
hardirqs last  enabled at (10102965): [<ffffffff810cbafd>] vprintk_emit+0x2dd/0x6a0
hardirqs last disabled at (10102964): [<ffffffff810cb897>] vprintk_emit+0x77/0x6a0
softirqs last  enabled at (10102342): [<ffffffff810666aa>] __do_softirq+0x27a/0x6f0
softirqs last disabled at (10102337): [<ffffffff81066e86>] irq_exit+0x56/0xe0
Preemption disabled at:[<ffffffff817de50d>] printk_emit+0x31/0x33

CPU: 1 PID: 1 Comm: systemd Not tainted 3.18.0-rc2-next-20141029-dirty #222
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140617_173321-var-lib-archbuild-testing-x86_64-tobias 04/01/2014
 ffffffff81a82291 ffff88001e743978 ffffffff817df31d 0000000000000000
 0000000000000000 ffff88001e7439a8 ffffffff8108dfa2 ffff88001e7439a8
 ffffffff81a82291 0000000000000068 0000000000000000 ffff88001e7439d8
Call Trace:
 [<ffffffff817df31d>] dump_stack+0x4f/0x7c
 [<ffffffff8108dfa2>] ___might_sleep+0x182/0x2b0
 [<ffffffff8108e10a>] __might_sleep+0x3a/0xc0
 [<ffffffff810ce358>] synchronize_irq+0x38/0xa0
 [<ffffffff810ce633>] ? __disable_irq_nosync+0x43/0x70
 [<ffffffff810ce690>] disable_irq+0x20/0x30
 [<ffffffff815d7253>] e1000_netpoll+0x23/0x60
 [<ffffffff81678d02>] netpoll_poll_dev+0x72/0x3a0
 [<ffffffff817e9993>] ? _raw_spin_trylock+0x73/0x90
 [<ffffffff8167920f>] ? netpoll_send_skb_on_dev+0x1df/0x2e0
 [<ffffffff816791e7>] netpoll_send_skb_on_dev+0x1b7/0x2e0
 [<ffffffff816795f3>] netpoll_send_udp+0x2e3/0x490
 [<ffffffff815d1f61>] ? write_msg+0x51/0x140
 [<ffffffff815d1fdf>] write_msg+0xcf/0x140
 [<ffffffff810cadbb>] call_console_drivers.constprop.22+0x13b/0x2a0
 [<ffffffff810cb6bd>] console_unlock+0x39d/0x500
 [<ffffffff810cbb3e>] ? vprintk_emit+0x31e/0x6a0
 [<ffffffff810cbb5c>] vprintk_emit+0x33c/0x6a0
 [<ffffffff811a6c6e>] ? might_fault+0x5e/0xc0
 [<ffffffff817de50d>] printk_emit+0x31/0x33
 [<ffffffff810cbfad>] devkmsg_write+0xbd/0x110
 [<ffffffff811f24d5>] do_iter_readv_writev+0x65/0xa0
 [<ffffffff811f3b72>] do_readv_writev+0xe2/0x290
 [<ffffffff810cbef0>] ? vprintk+0x30/0x30
 [<ffffffff810d499d>] ? rcu_read_lock_held+0x6d/0x70
 [<ffffffff812142d6>] ? __fget_light+0xc6/0xd0
 [<ffffffff811f3dac>] vfs_writev+0x3c/0x50
 [<ffffffff811f3eed>] SyS_writev+0x4d/0xe0
 [<ffffffff817ea16d>] system_call_fastpath+0x16/0x1b



I'm able to reproduce it consistently by sending a lot of packets from
that interface while writing to /dev/kmsg with netconsole
enabled. Just writing to /dev/kmsg isn't enough.

# with ping -f or pktgen running
for i in `seq 1 20` ; do echo '............................................' > /dev/kmsg ; done


-- 
Sabrina
