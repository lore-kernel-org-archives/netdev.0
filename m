From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Tue, 2 Mar 2010 14:12:06 -0800
Message-ID: <1267567926.19491.175.camel@nseg_linux_HP1.broadcom.com>
References: <20091229084929.54912c0c@pluto.restena.lu>
 <1262077540.12520.4.camel@localhost>
 <20091229145403.39f82773@pluto.restena.lu>
 <1262149691.2788.63.camel@localhost>
 <20100219091034.5fbb0165@pluto.restena.lu>
 <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
 <20100223131508.4c6cb866@neptune.home>
 <1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com>
 <20100302081051.3d1b1c53@pluto.restena.lu>
 <20100302092020.52cfcd0e@pluto.restena.lu>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Benjamin Li" <benli@broadcom.com>,
	NetDEV <netdev@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Bruno =?ISO-8859-1?Q?Pr=E9mont?=" <bonbons@linux-vserver.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100302092020.52cfcd0e@pluto.restena.lu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Tue, 2010-03-02 at 00:20 -0800, Bruno Pr=C3=A9mont wrote:
> [ 3405.422963] ------------[ cut here ]------------
> [ 3405.428958] WARNING: at /usr/src/linux-2.6.33-rc8-git7/kernel/soft=
irq.c:143 local_bh_enable_ip+0x72/0xa0()

In normal NAPI mode, we are in softirq context and we correctly use
spin_lock_bh() and spin_unlock_bh() here.  In netpoll mode, IRQs are
disabled and so we get a warning from spin_unlock_bh().

> [ 3405.431858] Hardware name: ProLiant DL360 G5
> [ 3405.431858] Modules linked in: netbomb bnx2 ipmi_devintf loop dm_m=
od sg sr_mod cdrom ata_piix ahci ipmi_si ipmi_msghandler uhci_hcd qla2x=
xx libata hpwdt ehci_hcd [last unloaded: bnx2]
> [ 3405.431858] Pid: 25763, comm: cat Not tainted 2.6.33-rc8-git7-x86_=
64 #1
> [ 3405.431858] Call Trace:
> [ 3405.431858]  [<ffffffff8103f002>] ? local_bh_enable_ip+0x72/0xa0
> [ 3405.431858]  [<ffffffff81039368>] warn_slowpath_common+0x78/0xd0
> [ 3405.431858]  [<ffffffff810393cf>] warn_slowpath_null+0xf/0x20
> [ 3405.431858]  [<ffffffff8103f002>] local_bh_enable_ip+0x72/0xa0
> [ 3405.431858]  [<ffffffff814002af>] _raw_spin_unlock_bh+0xf/0x20
> [ 3405.431858]  [<ffffffffa0108ed4>] bnx2_reg_rd_ind+0x44/0x60 [bnx2]
> [ 3405.431858]  [<ffffffffa0108eff>] bnx2_shmem_rd+0xf/0x20 [bnx2]
> [ 3405.431858]  [<ffffffffa0113464>] bnx2_poll+0x194/0x228 [bnx2]
> [ 3405.431858]  [<ffffffff8135c081>] netpoll_poll+0xe1/0x3c0
> [ 3405.431858]  [<ffffffff8135c518>] netpoll_send_skb+0x118/0x210
> [ 3405.431858]  [<ffffffff8135c80b>] netpoll_send_udp+0x1fb/0x210
> [ 3405.431858]  [<ffffffffa00131c5>] write_msg+0x95/0xd0 [netbomb]
> [ 3405.431858]  [<ffffffffa0013255>] netbomb_write+0x55/0xa4 [netbomb=
]
> [ 3405.431858]  [<ffffffff810f6571>] proc_reg_write+0x71/0xb0
> [ 3405.431858]  [<ffffffff810ab6db>] vfs_write+0xcb/0x180
> [ 3405.431858]  [<ffffffff810ab880>] sys_write+0x50/0x90
> [ 3405.431858]  [<ffffffff8102a1a4>] sysenter_dispatch+0x7/0x2b
> [ 3405.431858] ---[ end trace b4ac1510884bf2bc ]---
> [ 3411.050005] ------------[ cut here ]------------
> [ 3411.054851] WARNING: at /usr/src/linux-2.6.33-rc8-git7/net/sched/s=
ch_generic.c:255 dev_watchdog+0x25e/0x270()
> [ 3411.059546] Hardware name: ProLiant DL360 G5
> [ 3411.061569] NETDEV WATCHDOG: eth0 (bnx2): transmit queue 0 timed o=
ut
> [ 3411.064582] Modules linked in: netbomb bnx2 ipmi_devintf loop dm_m=
od sg sr_mod cdrom ata_piix ahci ipmi_si ipmi_msghandler uhci_hcd qla2x=
xx libata hpwdt ehci_hcd [last unloaded: bnx2]
> [ 3411.064597] Pid: 0, comm: swapper Tainted: G        W  2.6.33-rc8-=
git7-x86_64 #1
> [ 3411.064599] Call Trace:

Do we have timers running in this environment?  The timer in the bnx2
driver, bnx2_timer(), needs to run to provide a heart beat to the
firmware.  In netpoll mode without timer interrupts, if we are regularl=
y
calling the NAPI poll function, it should also be able to provide the
heartbeat.  Without the heartbeat, the firmware will reset the chip and
result in the NETDEV WATCHDOG.

> [ 3411.064601]  <IRQ>  [<ffffffff8135f84e>] ? dev_watchdog+0x25e/0x27=
0
> [ 3411.064609]  [<ffffffff81039368>] warn_slowpath_common+0x78/0xd0
> [ 3411.064612]  [<ffffffff81039444>] warn_slowpath_fmt+0x64/0x70
> [ 3411.064616]  [<ffffffff8103486d>] ? default_wake_function+0xd/0x10
> [ 3411.064620]  [<ffffffff8119f339>] ? strlcpy+0x49/0x60
> [ 3411.064623]  [<ffffffff81349b33>] ? netdev_drivername+0x43/0x50
> [ 3411.064626]  [<ffffffff8135f84e>] dev_watchdog+0x25e/0x270
> [ 3411.064630]  [<ffffffff8104c000>] ? delayed_work_timer_fn+0x0/0x40
> [ 3411.064633]  [<ffffffff8104bf87>] ? __queue_work+0x77/0x90
> [ 3411.064636]  [<ffffffff8103558b>] ? scheduler_tick+0x1bb/0x290
> [ 3411.064639]  [<ffffffff8135f5f0>] ? dev_watchdog+0x0/0x270
> [ 3411.064642]  [<ffffffff810440fc>] run_timer_softirq+0x13c/0x210
> [ 3411.064645]  [<ffffffff8105b4b7>] ? clockevents_program_event+0x57=
/0xa0
> [ 3411.064649]  [<ffffffff8103edb6>] __do_softirq+0xa6/0x130
> [ 3411.064652]  [<ffffffff81003bcc>] call_softirq+0x1c/0x30
> [ 3411.064655]  [<ffffffff81005be5>] do_softirq+0x55/0x90
> [ 3411.064658]  [<ffffffff8103eb35>] irq_exit+0x75/0x90
> [ 3411.064661]  [<ffffffff8101aeed>] smp_apic_timer_interrupt+0x6d/0x=
a0
> [ 3411.064664]  [<ffffffff81003693>] apic_timer_interrupt+0x13/0x20
> [ 3411.064666]  <EOI>  [<ffffffff8100b186>] ? mwait_idle+0x66/0x80
> [ 3411.064670]  [<ffffffff81001f90>] ? enter_idle+0x20/0x30
> [ 3411.064673]  [<ffffffff81002003>] cpu_idle+0x63/0xb0
> [ 3411.064676]  [<ffffffff813f2f14>] rest_init+0x74/0x80
> [ 3411.064680]  [<ffffffff81880c15>] start_kernel+0x2f8/0x336
> [ 3411.064683]  [<ffffffff8188026d>] x86_64_start_reservations+0x7d/0=
x84
> [ 3411.064686]  [<ffffffff81880354>] x86_64_start_kernel+0xe0/0xf2
> [ 3411.064688] ---[ end trace b4ac1510884bf2bd ]---
