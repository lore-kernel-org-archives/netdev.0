From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: stmmac: potential circular locking dependency
Date: Mon, 3 Nov 2014 15:39:50 +0100
Message-ID: <545793B6.5010109@st.com>
References: <545792E8.1020208@elopez.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>
To: =?UTF-8?B?RW1pbGlvIEzDs3Bleg==?= <emilio@elopez.com.ar>,
	<maxime.ripard@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:40787 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752543AbaKCOka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 09:40:30 -0500
In-Reply-To: <545792E8.1020208@elopez.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Emilio

I have a subset of new patches to review and fix locks in the
driver. I will plan to send them in the next days.

Sincerely
Peppe

On 11/3/2014 3:36 PM, Emilio L=C3=B3pez wrote:
> Hi everyone,
>
> I was playing with iperf on my Cubietruck today when I hit this lockd=
ep
> report/breakage on stmmac. It seems to be fairly reproducible by
>
> 1) Being on a GbE network
> 2) "iperf -s" on the stmmmac device
> 3) "iperf -c <IP of above device> -d -P 5" on some other device on th=
e LAN
>
> Here it goes:
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
> [ INFO: possible circular locking dependency detected ]
> 3.18.0-rc3-00003-g7180edf #916 Not tainted
> -------------------------------------------------------
> iperf/141 is trying to acquire lock:
>   (&(&dev->tx_global_lock)->rlock){+.-...}, at: [<c025927c>]
> stmmac_tx_clean+0x350/0x43c
>
> but task is already holding lock:
>   (&(&priv->tx_lock)->rlock){+.-...}, at: [<c0258f5c>]
> stmmac_tx_clean+0x30/0x43c
>
> which lock already depends on the new lock.
>
>
> the existing dependency chain (in reverse order) is:
>
> -> #2 (&(&priv->tx_lock)->rlock){+.-...}:
>         [<c03f57d0>] _raw_spin_lock+0x5c/0x94
>         [<c0259ec4>] stmmac_xmit+0x88/0x620
>         [<c0319058>] dev_hard_start_xmit+0x230/0x49c
>         [<c033773c>] sch_direct_xmit+0xdc/0x20c
>         [<c03194dc>] __dev_queue_xmit+0x218/0x604
>         [<c0319954>] dev_queue_xmit+0x1c/0x20
>         [<c032896c>] neigh_resolve_output+0x180/0x254
>         [<c03a36fc>] ip6_finish_output2+0x188/0x8a4
>         [<c03a7440>] ip6_output+0xc8/0x398
>         [<c03c81ec>] mld_sendpack+0x2e0/0x6d8
>         [<c03ca564>] mld_ifc_timer_expire+0x1f0/0x308
>         [<c007c06c>] call_timer_fn+0xb4/0x1f0
>         [<c007c7d0>] run_timer_softirq+0x224/0x2f0
>         [<c0023fb0>] __do_softirq+0x1d4/0x3e0
>         [<c00244e0>] irq_exit+0x9c/0xd0
>         [<c006df48>] __handle_domain_irq+0x70/0xb4
>         [<c0008754>] gic_handle_irq+0x34/0x6c
>         [<c0013484>] __irq_svc+0x44/0x5c
>         [<c00628f0>] lock_acquire+0xec/0x17c
>         [<c00628f0>] lock_acquire+0xec/0x17c
>         [<c03f57d0>] _raw_spin_lock+0x5c/0x94
>         [<c00ddeac>] do_read_fault.isra.93+0xa8/0x2a0
>         [<c00e0144>] handle_mm_fault+0x44c/0x8dc
>         [<c0018670>] do_page_fault+0x160/0x2d8
>         [<c0008564>] do_PrefetchAbort+0x44/0xa8
>         [<c0013960>] ret_from_exception+0x0/0x20
>         [<b6eb0120>] 0xb6eb0120
>
> -> #1 (_xmit_ETHER#2){+.-...}:
>         [<c03f57d0>] _raw_spin_lock+0x5c/0x94
>         [<c0338254>] dev_deactivate_many+0xd0/0x250
>         [<c0338410>] dev_deactivate+0x3c/0x4c
>         [<c032e908>] linkwatch_do_dev+0x50/0x84
>         [<c032eb74>] __linkwatch_run_queue+0xdc/0x148
>         [<c032ec1c>] linkwatch_event+0x3c/0x44
>         [<c00367d0>] process_one_work+0x1ec/0x510
>         [<c0036b50>] worker_thread+0x5c/0x4d8
>         [<c003c748>] kthread+0xe8/0xfc
>         [<c000ed28>] ret_from_fork+0x14/0x20
>
> -> #0 (&(&dev->tx_global_lock)->rlock){+.-...}:
>         [<c00628e0>] lock_acquire+0xdc/0x17c
>         [<c03f57d0>] _raw_spin_lock+0x5c/0x94
>         [<c025927c>] stmmac_tx_clean+0x350/0x43c
>         [<c02593c0>] stmmac_poll+0x3c/0x618
>         [<c031a760>] net_rx_action+0x178/0x28c
>         [<c0023fb0>] __do_softirq+0x1d4/0x3e0
>         [<c00244e0>] irq_exit+0x9c/0xd0
>         [<c006df48>] __handle_domain_irq+0x70/0xb4
>         [<c0008754>] gic_handle_irq+0x34/0x6c
>         [<c0013484>] __irq_svc+0x44/0x5c
>         [<c002435c>] __local_bh_enable_ip+0x9c/0xfc
>         [<c002435c>] __local_bh_enable_ip+0x9c/0xfc
>         [<c03f5f64>] _raw_read_unlock_bh+0x40/0x44
>         [<c03ad050>] inet6_dump_addr+0x33c/0x530
>         [<c03ad2a0>] inet6_dump_ifaddr+0x1c/0x20
>         [<c032a0fc>] rtnl_dump_all+0x50/0xf4
>         [<c033c020>] netlink_dump+0xc0/0x250
>         [<c033c3e4>] netlink_recvmsg+0x234/0x300
>         [<c02ff7b4>] sock_recvmsg+0xa4/0xc8
>         [<c03000bc>] ___sys_recvmsg.part.33+0xe4/0x1c0
>         [<c0302158>] __sys_recvmsg+0x60/0x90
>         [<c03021a0>] SyS_recvmsg+0x18/0x1c
>         [<c000ec60>] ret_fast_syscall+0x0/0x48
>
> other info that might help us debug this:
>
> Chain exists of:
>    &(&dev->tx_global_lock)->rlock --> _xmit_ETHER#2 -->
> &(&priv->tx_lock)->rlock
>
>   Possible unsafe locking scenario:
>
>         CPU0                    CPU1
>         ----                    ----
>    lock(&(&priv->tx_lock)->rlock);
>                                 lock(_xmit_ETHER#2);
>                                 lock(&(&priv->tx_lock)->rlock);
>    lock(&(&dev->tx_global_lock)->rlock);
>
>   *** DEADLOCK ***
>
> 3 locks held by iperf/141:
>   #0:  (rtnl_mutex){+.+.+.}, at: [<c033bf88>] netlink_dump+0x28/0x250
>   #1:  (rcu_read_lock){......}, at: [<c03acd14>] inet6_dump_addr+0x0/=
0x530
>   #2:  (&(&priv->tx_lock)->rlock){+.-...}, at: [<c0258f5c>]
> stmmac_tx_clean+0x30/0x43c
>
> stack backtrace:
> CPU: 0 PID: 141 Comm: iperf Not tainted 3.18.0-rc3-00003-g7180edf #91=
6
> [<c0015df4>] (unwind_backtrace) from [<c0012850>] (show_stack+0x20/0x=
24)
> [<c0012850>] (show_stack) from [<c03ef6dc>] (dump_stack+0x9c/0xbc)
> [<c03ef6dc>] (dump_stack) from [<c005bbc0>]
> (print_circular_bug+0x21c/0x33c)
> [<c005bbc0>] (print_circular_bug) from [<c0061e88>]
> (__lock_acquire+0x2060/0x2148)
> [<c0061e88>] (__lock_acquire) from [<c00628e0>] (lock_acquire+0xdc/0x=
17c)
> [<c00628e0>] (lock_acquire) from [<c03f57d0>] (_raw_spin_lock+0x5c/0x=
94)
> [<c03f57d0>] (_raw_spin_lock) from [<c025927c>]
> (stmmac_tx_clean+0x350/0x43c)
> [<c025927c>] (stmmac_tx_clean) from [<c02593c0>] (stmmac_poll+0x3c/0x=
618)
> [<c02593c0>] (stmmac_poll) from [<c031a760>] (net_rx_action+0x178/0x2=
8c)
> [<c031a760>] (net_rx_action) from [<c0023fb0>] (__do_softirq+0x1d4/0x=
3e0)
> [<c0023fb0>] (__do_softirq) from [<c00244e0>] (irq_exit+0x9c/0xd0)
> [<c00244e0>] (irq_exit) from [<c006df48>] (__handle_domain_irq+0x70/0=
xb4)
> [<c006df48>] (__handle_domain_irq) from [<c0008754>]
> (gic_handle_irq+0x34/0x6c)
> [<c0008754>] (gic_handle_irq) from [<c0013484>] (__irq_svc+0x44/0x5c)
> Exception stack(0xcabc1be0 to 0xcabc1c28)
> 1be0: 00000001 2df53000 00000000 caf15e80 cabc0000 00000201 ca9a9840
> c03ad050
> 1c00: ca8d9404 00000000 ca9b4f50 cabc1c44 c08732d0 cabc1c28 c005d5d0
> c002435c
> 1c20: 20000013 ffffffff
> [<c0013484>] (__irq_svc) from [<c002435c>] (__local_bh_enable_ip+0x9c=
/0xfc)
> [<c002435c>] (__local_bh_enable_ip) from [<c03f5f64>]
> (_raw_read_unlock_bh+0x40/0x44)
> [<c03f5f64>] (_raw_read_unlock_bh) from [<c03ad050>]
> (inet6_dump_addr+0x33c/0x530)
> [<c03ad050>] (inet6_dump_addr) from [<c03ad2a0>]
> (inet6_dump_ifaddr+0x1c/0x20)
> [<c03ad2a0>] (inet6_dump_ifaddr) from [<c032a0fc>]
> (rtnl_dump_all+0x50/0xf4)
> [<c032a0fc>] (rtnl_dump_all) from [<c033c020>] (netlink_dump+0xc0/0x2=
50)
> [<c033c020>] (netlink_dump) from [<c033c3e4>] (netlink_recvmsg+0x234/=
0x300)
> [<c033c3e4>] (netlink_recvmsg) from [<c02ff7b4>] (sock_recvmsg+0xa4/0=
xc8)
> [<c02ff7b4>] (sock_recvmsg) from [<c03000bc>]
> (___sys_recvmsg.part.33+0xe4/0x1c0)
> [<c03000bc>] (___sys_recvmsg.part.33) from [<c0302158>]
> (__sys_recvmsg+0x60/0x90)
> [<c0302158>] (__sys_recvmsg) from [<c03021a0>] (SyS_recvmsg+0x18/0x1c=
)
> [<c03021a0>] (SyS_recvmsg) from [<c000ec60>] (ret_fast_syscall+0x0/0x=
48)
> ---------------------------------
>
> Cheers,
>
> Emilio
>
>
