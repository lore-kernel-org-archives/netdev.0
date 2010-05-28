From: Flavio Leitner <fbl@sysclose.org>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Fri, 28 May 2010 16:40:41 -0300
Message-ID: <20100528194041.GC2345@sysclose.org>
References: <20100505081514.5157.83783.sendpatchset@localhost.localdomain>
 <20100527180545.GA2345@sysclose.org>
 <4BFF2EA5.9090008@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Matt Mackall <mpm@selenic.com>,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	Andy Gospodarek <gospo@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	bonding-devel@lists.sourceforge.net,
	Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcahe.dreamhost.com ([208.97.132.74]:47767 "EHLO
	homiemail-a21.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753660Ab0E1Tku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 15:40:50 -0400
Content-Disposition: inline
In-Reply-To: <4BFF2EA5.9090008@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 28, 2010 at 10:47:01AM +0800, Cong Wang wrote:
> On 05/28/10 02:05, Flavio Leitner wrote:
> >
> >Hi guys!
> >
> >I finally could test this to see if an old problem reported on bugzilla[1] was
> >fixed now, but unfortunately it is still there.
> >
> >The ticket is private I guess, but basically the problem happens when bonding
> >driver tries to print something after it had taken the write_lock (monitor
> >functions, enslave/de-enslave), so the printk() will pass through netpoll, then
> >on bonding again which no matter what mode you use, it will try to read_lock()
> >the lock again. The result is a deadlock and the entire system hangs.
> 
> 
> This is true, I already fixed some similar issues.
> 
> >
> >I manage to get a fresh backtrace with mode 1, see below:
> >
> >
> >[   93.167079] Call Trace:
> >[   93.167079]  [<ffffffff81034cf9>] warn_slowpath_common+0x77/0x8f
> >[   93.167079]  [<ffffffff81034d5e>] warn_slowpath_fmt+0x3c/0x3e
> >[   93.167079]  [<ffffffff81366aef>] ? _raw_read_trylock+0x11/0x4b
> >[   93.167079]  [<ffffffffa02a2c42>] ? bond_start_xmit+0x12b/0x401 [bonding]
> >->  read_lock fails
> >[   93.167079]  [<ffffffffa02a2c9f>] bond_start_xmit+0x188/0x401 [bonding]
> >[   93.167079]  [<ffffffff81055b37>] ? trace_hardirqs_off+0xd/0xf
> >[   93.167079]  [<ffffffff812dfdb9>] netpoll_send_skb+0xbd/0x1f3
> >[   93.167079]  [<ffffffff812e00ed>] netpoll_send_udp+0x1fe/0x20d
> >[   93.167079]  [<ffffffffa02c017c>] write_msg+0x89/0xcd [netconsole]
> >[   93.167079]  [<ffffffff81034e65>] __call_console_drivers+0x67/0x79
> >[   93.167079]  [<ffffffff81034ed0>] _call_console_drivers+0x59/0x5d
> >[   93.167079]  [<ffffffff810352d3>] release_console_sem+0x121/0x1d7
> >[   93.167079]  [<ffffffff8103590a>] vprintk+0x35d/0x393
> >[   93.167079]  [<ffffffff8103f947>] ? add_timer+0x17/0x19
> >[   93.167079]  [<ffffffff81046ddf>] ? queue_delayed_work_on+0xa2/0xa9
> >[   93.167079]  [<ffffffff81363bb8>] printk+0x3c/0x44
> >[   93.167079]  [<ffffffffa02a3b17>] bond_select_active_slave+0x105/0x109 [bonding]
> >->  write_locked
> >[   93.167079]  [<ffffffffa02a4798>] bond_mii_monitor+0x479/0x4ed [bonding]
> >[   93.167079]  [<ffffffff81046009>] worker_thread+0x1ef/0x2e2
> >
> >In this case, the message should be
> >     "bonding: bond0: making interface eth0 the new active one"
> 
> 
> Hmm, you triggered a warning here, let me check the source code
> and try to reproduce it here.

Okay, just pull the cable from one slave or both slaves.



> >I did the following patch to discard the packet if it was IN_NETPOLL
> >and the read_lock() fails, so I could go ahead testing it:
> >
> >diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >index 5e12462..a3b8bad 100644
> >--- a/drivers/net/bonding/bond_main.c
> >+++ b/drivers/net/bonding/bond_main.c
> >@@ -4258,8 +4258,19 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
> >  	struct bonding *bond = netdev_priv(bond_dev);
> >  	int res = 1;
> >
> >-	read_lock(&bond->lock);
> >-	read_lock(&bond->curr_slave_lock);
> >+	if (read_trylock(&bond->lock) == 0&&
> >+		(bond_dev->flags&  IFF_IN_NETPOLL)) {
> >+			dev_kfree_skb(skb);
> >+			return NETDEV_TX_OK;
> >+	}
> >+
> >+	if (read_trylock(&bond->curr_slave_lock) == 0&&
> >+		(bond_dev->flags&  IFF_IN_NETPOLL)) {
> >+			read_unlock(&bond->lock);
> >+			dev_kfree_skb(skb);
> >+			return NETDEV_TX_OK;
> >+	}
> >+			
> >
> >  	if (!BOND_IS_OK(bond))
> >  		goto out;
> >
> 
> 
> This looks like a workaround, not a fix. :)

No, it's a debugging patch, otherwise I couldn't see anything on
serial console when it deadlocks or to keep testing it. :)


> >and I found another problem.  The function netpoll_send_skb() checks
> >if the npinfo's queue length is zero and if it's not, it will queue
> >the packet to make sure it's in order and then schedule the thread
> >to run. Later, the thread wakes up running queue_process() which disables
> >interrupts before calling ndo_start_xmit().  However, dev_queue_xmit()
> >uses rcu_*_bh() and before return, it will enable the interrupts again,
> >spitting this:
> >
> >------------[ cut here ]------------
> >WARNING: at kernel/softirq.c:143 local_bh_enable+0x3c/0x86()
> >Hardware name: Precision WorkStation 490
> >Modules linked in: netconsole bonding sunrpc ip6t_REJECT xt_tcpudp nf_conntrack_ipv6]
> >Pid: 17, comm: events/2 Not tainted 2.6.34-04700-gd938a70 #21
> >Call Trace:
> >  [<ffffffff810381d6>] warn_slowpath_common+0x77/0x8f
> >  [<ffffffff810381fd>] warn_slowpath_null+0xf/0x11
> >  [<ffffffff8103d691>] local_bh_enable+0x3c/0x86
> >  [<ffffffff812e4d85>] dev_queue_xmit+0x462/0x493
> >  [<ffffffffa018805f>] bond_dev_queue_xmit+0x1bd/0x1e3 [bonding]
> >  [<ffffffffa01881dd>] bond_start_xmit+0x158/0x37b [bonding]
> >->  interrupts disabled
> >  [<ffffffff812f3fca>] queue_process+0x9d/0xf9
> >  [<ffffffff8104d022>] worker_thread+0x19d/0x224
> >  [<ffffffff812f3f2d>] ? queue_process+0x0/0xf9
> >  [<ffffffff81050819>] ? autoremove_wake_function+0x0/0x34
> >  [<ffffffff8104ce85>] ? worker_thread+0x0/0x224
> >  [<ffffffff8105040b>] kthread+0x7a/0x82
> >  [<ffffffff810036d4>] kernel_thread_helper+0x4/0x10
> >  [<ffffffff81050391>] ? kthread+0x0/0x82
> >  [<ffffffff810036d0>] ? kernel_thread_helper+0x0/0x10
> >---[ end trace 74e3904503fdb632 ]---
> >
> >kernel/softirq.c:
> >141 static inline void _local_bh_enable_ip(unsigned long ip)
> >142 {
> >143         WARN_ON_ONCE(in_irq() || irqs_disabled());
> >144 #ifdef CONFIG_TRACE_IRQFLAGS
> >145         local_irq_disable();
> >146 #endif
> >147         /*
> >148          * Are softirqs going to be turned on now:
> >149          */
> >
> >
> 
> I am wondering if this was caused by the previous issue.

Yeah, the first problem can help to trigger this.
The spinlock target_list_lock in write_msg() seems to serialize
this, but I'm not sure yet if the queue will always be empty by
the time another call to write_msg() is made because the 
netpoll_send_skb() will queue the packet if it fails to send.


> >The git is updated up to:
> >   d938a70 be2net: increase POST timeout for EEH recovery
> >
> >Two slave interfaces, bonding mode 1, netconsole over bond0.
> >
> >[1] https://bugzilla.redhat.com/show_bug.cgi?id=248374#c5
> 
> How did you reproduce this?
> I will check that BZ to see if I can find how to reproduce this.
> 
> Thanks.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Flavio
