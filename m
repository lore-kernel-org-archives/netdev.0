From: Maciej Rutecki <maciej.rutecki@gmail.com>
Subject: Re: Hang deconfiguring network interface (in shutdown) on 3.3-rc1
Date: Tue, 31 Jan 2012 21:15:53 +0100
Message-ID: <201201312115.53700.maciej.rutecki@gmail.com>
References: <1327780565.2924.24.camel@dabdike.int.hansenpartnership.com>
Reply-To: maciej.rutecki@gmail.com
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Parisc List <linux-parisc@vger.kernel.org>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Paul McKenny <paulmck@linux.vnet.ibm.com>
To: James Bottomley <James.Bottomley@hansenpartnership.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <1327780565.2924.24.camel@dabdike.int.hansenpartnership.com>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On sobota, 28 stycznia 2012 o 20:56:05 James Bottomley wrote:
> It looks like it might be a tg3 or RCU issue.  When I shut down my
> parisc SMP 4 way system, I get an immediate hang here
> 
> Deconfiguring network interfaces...Internet Systems Consortium DHCP
> Client 4.1.1-P1
> Copyright 2004-2010 Internet Systems Consortium.
> All rights reserved.
> For info, please visit https://www.isc.org/software/dhcp/
> 
> Listening on LPF/eth0/00:30:6e:4b:15:59
> Sending on   LPF/eth0/00:30:6e:4b:15:59
> Sending on   Socket/fallback
> DHCPRELEASE on eth0 to 153.66.140.171 port 67
> 
> Followed some seconds later by
> 
> [ 5714.268000] INFO: rcu_sched detected stall on CPU 3 (t=15000 jiffies)
> [ 5714.268000] Backtrace:
> [ 5714.268000]  [<000000004011fdd4>] show_stack+0x14/0x20
> [ 5714.268000]  [<000000004011fdf8>] dump_stack+0x18/0x28
> [ 5714.268000]  [<00000000401c1fec>] __rcu_pending+0xcc/0x5c8
> [ 5714.276000]  [<00000000401c2d60>] rcu_check_callbacks+0x80/0xf8
> [ 5714.276000] INFO: rcu_sched detected stalls on CPUs/tasks: { 3}
> (detected by 2, t=15002 jiffies)
> [ 5714.276000] Backtrace:
> [ 5714.276000]  [<000000004011fdd4>] show_stack+0x14/0x20
> [ 5714.276000]  [<000000004011fdf8>] dump_stack+0x18/0x28
> [ 5714.276000]  [<00000000401c2484>] __rcu_pending+0x564/0x5c8
> [ 5714.276000]  [<00000000401c2d60>] rcu_check_callbacks+0x80/0xf8
> [ 5714.276000]  [<0000000040155dc8>] update_process_times+0x68/0xd8
> [ 5714.276000]  [<0000000040121378>] timer_interrupt+0x1c0/0x220
> [ 5714.276000]  [<00000000401b9cfc>] handle_irq_event_percpu+0xa4/0x2a0
> [ 5714.276000]  [<00000000401be58c>] handle_percpu_irq+0x9c/0xd0
> [ 5714.276000]  [<00000000401b9500>] generic_handle_irq+0x48/0x60
> [ 5714.276000]  [<0000000040121a50>] do_cpu_irq_mask+0x1b8/0x2a8
> [ 5714.276000]  [<0000000040105074>] intr_return+0x0/0x4
> [ 5714.276000]  [<0000000040105074>] intr_return+0x0/0x4
> [ 5714.276000]  [<00000000401296dc>] cpu_idle+0x74/0x80
> [ 5714.276000]  [<000000004078e1d0>] smp_callin+0x150/0x1a0
> [ 5714.276000]
> [ 5714.348000]  [<0000000040155dc8>] update_process_times+0x68/0xd8
> [ 5714.348000]  [<0000000040121378>] timer_interrupt+0x1c0/0x220
> [ 5714.356000]  [<00000000401b9cfc>] handle_irq_event_percpu+0xa4/0x2a0
> [ 5714.364000]  [<00000000401be58c>] handle_percpu_irq+0x9c/0xd0
> [ 5714.364000]  [<00000000401b9500>] generic_handle_irq+0x48/0x60
> [ 5714.372000]  [<0000000040121a50>] do_cpu_irq_mask+0x1b8/0x2a8
> [ 5714.372000]  [<0000000040105074>] intr_return+0x0/0x4
> [ 5714.380000]
> 
> This didn't happen in 3.2
> 
> Sysrq still works and sysrq-T shows ifconfig stuck:
> 
> 
> [ 6030.376000] ifconfig        R  running task        0  1470   1452
> 0x00000014
> [ 6030.376000] Backtrace:
> [ 6030.376000]  [<000000004017c6c8>] scheduler_tick+0x180/0x1a0
> [ 6030.376000]  [<0000000040155e1c>] update_process_times+0xbc/0xd8
> [ 6030.376000]  [<0000000040121378>] timer_interrupt+0x1c0/0x220
> [ 6030.376000]  [<00000000401b9d54>] handle_irq_event_percpu+0xfc/0x2a0
> [ 6030.376000]  [<0000000040105074>] intr_return+0x0/0x4
> [ 6030.376000]  [<000000004011c638>] _raw_spin_lock_bh+0x30/0x40
> [ 6030.376000]  [<000000004011c620>] _raw_spin_lock_bh+0x18/0x40
> [ 6030.376000]  [<000000001c6e3a64>] tg3_chip_reset+0x9c4/0x1328 [tg3]
> [ 6030.376000]  [<000000001c6eca9c>] tg3_halt+0xdc/0x1d8 [tg3]
> [ 6030.376000]  [<000000001c6f9964>] tg3_close+0x194/0x3f0 [tg3]
> [ 6030.376000]  [<0000000040411518>] __dev_close_many+0x100/0x178
> [ 6030.376000]  [<0000000040415130>] __dev_close+0x30/0x50
> [ 6030.376000]  [<000000004040ebf8>] __dev_change_flags+0xb0/0x1d0
> [ 6030.376000]  [<00000000404113b0>] dev_change_flags+0x28/0x90
> [ 6030.376000]  [<0000000040488d70>] devinet_ioctl+0x748/0x898
> [ 6030.376000]  [<000000004048a5f4>] inet_ioctl+0x204/0x228
> 
> James

I created a Bugzilla entry at 
https://bugzilla.kernel.org/show_bug.cgi?id=42707
for your bug report, please add your address to the CC list in there, thanks!

-- 
Maciej Rutecki
http://www.mrutecki.pl
