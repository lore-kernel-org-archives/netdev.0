From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel 3.7.6, l2tp, qdisc_tx circular locking
Date: Mon, 11 Feb 2013 08:52:25 -0800
Message-ID: <1360601545.20362.24.camel@edumazet-glaptop>
References: <a0cb5c50926ca95b0ad64bde7535efa6@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a0cb5c50926ca95b0ad64bde7535efa6@visp.net.lb>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-02-11 at 14:28 +0200, Denys Fedoryshchenko wrote:
> Hello,
> 
> I was running l2tp connections with accel-ppp as test, and got this:
> Nothing unusual in kernel, x86_64, 2 CPU, gentoo, gcc 4.6.3
> If you need more information - let me know please.
> 
> 
> [ 7575.690820]
> [ 7575.690834] ======================================================
> [ 7575.690850] [ INFO: possible circular locking dependency detected ]
> [ 7575.690870] 3.7.6-wbuild #6 Not tainted
> [ 7575.690882] -------------------------------------------------------
> [ 7575.690901] swapper/1/0 is trying to acquire lock:
> [ 7575.690916]  (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, 
> at: [<ffffffff812d8087>] dev_queue_xmit+0x90/0x34d
> [ 7575.690972]
> [ 7575.690972] but task is already holding lock:
> [ 7575.690988]  (l2tp_sock){+.-...}, at: [<ffffffffa05b0b2b>] 
> l2tp_xmit_skb+0x1b8/0x453 [l2tp_core]
> [ 7575.691037]
> [ 7575.691037] which lock already depends on the new lock.
> [ 7575.691037]
> [ 7575.691059]
> [ 7575.691059] the existing dependency chain (in reverse order) is:
> [ 7575.691082]
> [ 7575.691082] -> #4 (l2tp_sock){+.-...}:
> [ 7575.691119]        [<ffffffff81066c17>] lock_acquire+0x7e/0x94
> [ 7575.691141]        [<ffffffff81361ce8>] _raw_spin_lock+0x2c/0x3b
> [ 7575.691615]        [<ffffffffa05b0b2b>] l2tp_xmit_skb+0x1b8/0x453 
> [l2tp_core]
> [ 7575.692088]        [<ffffffffa05be93b>] pppol2tp_xmit+0x122/0x15d 
> [l2tp_ppp]
> [ 7575.692560]        [<ffffffff8126ec23>] ppp_channel_push+0x48/0xad
> [ 7575.693031]        [<ffffffff8126ed5d>] ppp_write+0xc1/0xcd
> [ 7575.693499]        [<ffffffff810c5c6a>] vfs_write+0xa3/0xca
> [ 7575.693969]        [<ffffffff810c5e24>] sys_write+0x54/0x78
> [ 7575.694436]        [<ffffffff81362e52>] 
> system_call_fastpath+0x16/0x1b
> [ 7575.694907]
> [ 7575.694907] -> #3 (&(&pch->downl)->rlock){+.-...}:
> [ 7575.695830]        [<ffffffff81066c17>] lock_acquire+0x7e/0x94
> [ 7575.696297]        [<ffffffff81361ece>] _raw_spin_lock_bh+0x31/0x40
> [ 7575.696767]        [<ffffffff8126c39a>] ppp_push+0x69/0x507
> [ 7575.697235]        [<ffffffff8126e9e3>] ppp_xmit_process+0x44a/0x4ff
> [ 7575.697703]        [<ffffffff8126ed53>] ppp_write+0xb7/0xcd
> [ 7575.698170]        [<ffffffff810c5c6a>] vfs_write+0xa3/0xca
> [ 7575.698638]        [<ffffffff810c5e24>] sys_write+0x54/0x78
> [ 7575.699105]        [<ffffffff81362e52>] 
> system_call_fastpath+0x16/0x1b
> [ 7575.699575]
> [ 7575.699575] -> #2 (&(&ppp->wlock)->rlock){+.-...}:
> [ 7575.700498]        [<ffffffff81066c17>] lock_acquire+0x7e/0x94
> [ 7575.700966]        [<ffffffff81361ece>] _raw_spin_lock_bh+0x31/0x40
> [ 7575.701435]        [<ffffffff8126e5bc>] ppp_xmit_process+0x23/0x4ff
> [ 7575.701905]        [<ffffffff8126ebc0>] ppp_start_xmit+0x128/0x143
> [ 7575.702373]        [<ffffffff812d7d3f>] 
> dev_hard_start_xmit+0x267/0x371
> [ 7575.702843]        [<ffffffff812eab61>] sch_direct_xmit+0x70/0x14f
> [ 7575.703312]        [<ffffffff812d8149>] dev_queue_xmit+0x152/0x34d
> [ 7575.703869]        [<ffffffff812de128>] neigh_direct_output+0xc/0xe
> [ 7575.704336]        [<ffffffff812fe943>] 
> ip_finish_output2+0x268/0x2e5
> [ 7575.704806]        [<ffffffff812ff8c8>] ip_finish_output+0x46/0x4b
> [ 7575.705274]        [<ffffffff812fffd4>] ip_output+0x63/0x67
> [ 7575.705742]        [<ffffffff812fcfce>] ip_forward_finish+0x6b/0x70
> [ 7575.706211]        [<ffffffff812fd1d8>] ip_forward+0x205/0x285
> [ 7575.706678]        [<ffffffff812fbaf1>] ip_rcv_finish+0x2b3/0x2cb
> [ 7575.707147]        [<ffffffff812fbb55>] 
> NF_HOOK.constprop.8+0x4c/0x55
> [ 7575.707617]        [<ffffffff812fbec6>] ip_rcv+0x22b/0x259
> [ 7575.708084]        [<ffffffff812d5649>] 
> __netif_receive_skb+0x458/0x4c5
> [ 7575.708556]        [<ffffffff812d5844>] netif_receive_skb+0x56/0x8b
> [ 7575.709026]        [<ffffffff812d69ae>] napi_skb_finish+0x21/0x53
> [ 7575.709495]        [<ffffffff812d6a0a>] napi_gro_receive+0x2a/0x2f
> [ 7575.709963]        [<ffffffff812618d6>] igb_poll+0x634/0x909
> [ 7575.710430]        [<ffffffff812d5e3c>] net_rx_action+0xa3/0x1b9
> [ 7575.710897]        [<ffffffff81030204>] __do_softirq+0xa8/0x157
> [ 7575.711368]        [<ffffffff81363f8c>] call_softirq+0x1c/0x26
> [ 7575.711835]        [<ffffffff81003f45>] do_softirq+0x38/0x83
> [ 7575.712304]        [<ffffffff810303b1>] irq_exit+0x4e/0xad
> [ 7575.712771]        [<ffffffff81003c55>] do_IRQ+0x89/0xa0
> [ 7575.713236]        [<ffffffff813625ef>] ret_from_intr+0x0/0x13
> [ 7575.713703]        [<ffffffff812b8b92>] cpuidle_enter+0x12/0x14
> [ 7575.714171]        [<ffffffff812b8fb8>] 
> cpuidle_enter_state+0x10/0x39
> [ 7575.714642]        [<ffffffff812b905f>] cpuidle_idle_call+0x7e/0xa4
> [ 7575.715112]        [<ffffffff81009bd2>] cpu_idle+0x58/0xa2
> [ 7575.715579]        [<ffffffff81355e88>] start_secondary+0x188/0x18d
> [ 7575.716049]
> [ 7575.716049] -> #1 (_xmit_PPP#2){+.-...}:
> [ 7575.716977]        [<ffffffff81066c17>] lock_acquire+0x7e/0x94
> [ 7575.717443]        [<ffffffff81361ce8>] _raw_spin_lock+0x2c/0x3b
> [ 7575.718000]        [<ffffffff812eab3a>] sch_direct_xmit+0x49/0x14f
> [ 7575.718467]        [<ffffffff812d8149>] dev_queue_xmit+0x152/0x34d
> [ 7575.718933]        [<ffffffff812de128>] neigh_direct_output+0xc/0xe
> [ 7575.719403]        [<ffffffff812fe943>] 
> ip_finish_output2+0x268/0x2e5
> [ 7575.719873]        [<ffffffff812ff8c8>] ip_finish_output+0x46/0x4b
> [ 7575.720344]        [<ffffffff812fffd4>] ip_output+0x63/0x67
> [ 7575.720812]        [<ffffffff812fcfce>] ip_forward_finish+0x6b/0x70
> [ 7575.721282]        [<ffffffff812fd1d8>] ip_forward+0x205/0x285
> [ 7575.721750]        [<ffffffff812fbaf1>] ip_rcv_finish+0x2b3/0x2cb
> [ 7575.722219]        [<ffffffff812fbb55>] 
> NF_HOOK.constprop.8+0x4c/0x55
> [ 7575.722689]        [<ffffffff812fbec6>] ip_rcv+0x22b/0x259
> [ 7575.723158]        [<ffffffff812d5649>] 
> __netif_receive_skb+0x458/0x4c5
> [ 7575.723628]        [<ffffffff812d5844>] netif_receive_skb+0x56/0x8b
> [ 7575.724098]        [<ffffffff812d69ae>] napi_skb_finish+0x21/0x53
> [ 7575.724566]        [<ffffffff812d6a0a>] napi_gro_receive+0x2a/0x2f
> [ 7575.725034]        [<ffffffff812618d6>] igb_poll+0x634/0x909
> [ 7575.725501]        [<ffffffff812d5e3c>] net_rx_action+0xa3/0x1b9
> [ 7575.725970]        [<ffffffff81030204>] __do_softirq+0xa8/0x157
> [ 7575.726439]        [<ffffffff81363f8c>] call_softirq+0x1c/0x26
> [ 7575.726907]        [<ffffffff81003f45>] do_softirq+0x38/0x83
> [ 7575.727375]        [<ffffffff810303b1>] irq_exit+0x4e/0xad
> [ 7575.727841]        [<ffffffff81003c55>] do_IRQ+0x89/0xa0
> [ 7575.728308]        [<ffffffff813625ef>] ret_from_intr+0x0/0x13
> [ 7575.728779]        [<ffffffff812b8b92>] cpuidle_enter+0x12/0x14
> [ 7575.740374]        [<ffffffff812b8fb8>] 
> cpuidle_enter_state+0x10/0x39
> [ 7575.740846]        [<ffffffff812b905f>] cpuidle_idle_call+0x7e/0xa4
> [ 7575.741315]        [<ffffffff81009bd2>] cpu_idle+0x58/0xa2
> [ 7575.741784]        [<ffffffff81355e88>] start_secondary+0x188/0x18d
> [ 7575.742256]
> [ 7575.742256] -> #0 (dev->qdisc_tx_busylock ?: 
> &qdisc_tx_busylock){+.-...}:
> [ 7575.743190]        [<ffffffff81066567>] __lock_acquire+0xaf1/0xdce
> [ 7575.743661]        [<ffffffff81066c17>] lock_acquire+0x7e/0x94
> [ 7575.744129]        [<ffffffff81361ce8>] _raw_spin_lock+0x2c/0x3b
> [ 7575.744605]        [<ffffffff812d8087>] dev_queue_xmit+0x90/0x34d
> [ 7575.745077]        [<ffffffff812fe935>] 
> ip_finish_output2+0x25a/0x2e5
> [ 7575.745548]        [<ffffffff812ff8c8>] ip_finish_output+0x46/0x4b
> [ 7575.746017]        [<ffffffff812fffd4>] ip_output+0x63/0x67
> [ 7575.746570]        [<ffffffff812fe549>] dst_output+0x18/0x1c
> [ 7575.747036]        [<ffffffff812ff972>] ip_local_out+0x1b/0x1f
> [ 7575.747502]        [<ffffffff812ffc49>] ip_queue_xmit+0x2d3/0x337
> [ 7575.747970]        [<ffffffffa05b0d77>] l2tp_xmit_skb+0x404/0x453 
> [l2tp_core]
> [ 7575.748442]        [<ffffffffa05be93b>] pppol2tp_xmit+0x122/0x15d 
> [l2tp_ppp]
> [ 7575.748916]        [<ffffffff8126c3b0>] ppp_push+0x7f/0x507
> [ 7575.749383]        [<ffffffff8126e9e3>] ppp_xmit_process+0x44a/0x4ff
> [ 7575.749852]        [<ffffffff8126ebc0>] ppp_start_xmit+0x128/0x143
> [ 7575.750320]        [<ffffffff812d7dc7>] 
> dev_hard_start_xmit+0x2ef/0x371
> [ 7575.750790]        [<ffffffff812eab61>] sch_direct_xmit+0x70/0x14f
> [ 7575.751258]        [<ffffffff812d8149>] dev_queue_xmit+0x152/0x34d
> [ 7575.751727]        [<ffffffff812de128>] neigh_direct_output+0xc/0xe
> [ 7575.752196]        [<ffffffff812fe943>] 
> ip_finish_output2+0x268/0x2e5
> [ 7575.752667]        [<ffffffff812ff8c8>] ip_finish_output+0x46/0x4b
> [ 7575.753136]        [<ffffffff812fffd4>] ip_output+0x63/0x67
> [ 7575.753604]        [<ffffffff812fcfce>] ip_forward_finish+0x6b/0x70
> [ 7575.754073]        [<ffffffff812fd1d8>] ip_forward+0x205/0x285
> [ 7575.754541]        [<ffffffff812fbaf1>] ip_rcv_finish+0x2b3/0x2cb
> [ 7575.755009]        [<ffffffff812fbb55>] 
> NF_HOOK.constprop.8+0x4c/0x55
> [ 7575.755478]        [<ffffffff812fbec6>] ip_rcv+0x22b/0x259
> [ 7575.755945]        [<ffffffff812d5649>] 
> __netif_receive_skb+0x458/0x4c5
> [ 7575.756414]        [<ffffffff812d5844>] netif_receive_skb+0x56/0x8b
> [ 7575.756884]        [<ffffffff812d594a>] napi_gro_complete+0xd1/0xdc
> [ 7575.757354]        [<ffffffff812d5d2f>] napi_gro_flush+0x4c/0x68
> [ 7575.757822]        [<ffffffff812d5d64>] napi_complete+0x19/0x4e
> [ 7575.758290]        [<ffffffff81261967>] igb_poll+0x6c5/0x909
> [ 7575.758759]        [<ffffffff812d5e3c>] net_rx_action+0xa3/0x1b9
> [ 7575.759228]        [<ffffffff81030204>] __do_softirq+0xa8/0x157
> [ 7575.759697]        [<ffffffff81363f8c>] call_softirq+0x1c/0x26
> [ 7575.760164]        [<ffffffff81003f45>] do_softirq+0x38/0x83
> [ 7575.760721]        [<ffffffff810303b1>] irq_exit+0x4e/0xad
> [ 7575.761184]        [<ffffffff81003c55>] do_IRQ+0x89/0xa0
> [ 7575.761648]        [<ffffffff813625ef>] ret_from_intr+0x0/0x13
> [ 7575.762117]        [<ffffffff812b8b92>] cpuidle_enter+0x12/0x14
> [ 7575.762585]        [<ffffffff812b8fb8>] 
> cpuidle_enter_state+0x10/0x39
> [ 7575.763056]        [<ffffffff812b905f>] cpuidle_idle_call+0x7e/0xa4
> [ 7575.763525]        [<ffffffff81009bd2>] cpu_idle+0x58/0xa2
> [ 7575.763992]        [<ffffffff81355e88>] start_secondary+0x188/0x18d
> [ 7575.764462]
> [ 7575.764462] other info that might help us debug this:
> [ 7575.764462]
> [ 7575.765817] Chain exists of:
> [ 7575.765817]   dev->qdisc_tx_busylock ?: &qdisc_tx_busylock --> 
> &(&pch->downl)->rlock --> l2tp_sock
> [ 7575.765817]
> [ 7575.767652]  Possible unsafe locking scenario:
> [ 7575.767652]
> [ 7575.768560]        CPU0                    CPU1
> [ 7575.769021]        ----                    ----
> [ 7575.769482]   lock(l2tp_sock);
> [ 7575.769948]                                
> lock(&(&pch->downl)->rlock);
> [ 7575.770422]                                lock(l2tp_sock);
> [ 7575.770895]   lock(dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);
> [ 7575.771368]
> [ 7575.771368]  *** DEADLOCK ***
> [ 7575.771368]
> [ 7575.772824] 10 locks held by swapper/1/0:
> [ 7575.773283]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff812d2b10>] 
> rcu_lock_acquire+0x0/0x29
> [ 7575.774223]  #1:  (rcu_read_lock_bh){.+....}, at: 
> [<ffffffff812fe4b1>] rcu_lock_acquire+0x0/0x29
> [ 7575.775248]  #2:  (rcu_read_lock_bh){.+....}, at: 
> [<ffffffff812d2b10>] rcu_lock_acquire+0x0/0x29
> [ 7575.776184]  #3:  (_xmit_PPP#2){+.-...}, at: [<ffffffff812eab3a>] 
> sch_direct_xmit+0x49/0x14f
> [ 7575.777133]  #4:  (&(&ppp->wlock)->rlock){+.-...}, at: 
> [<ffffffff8126e5bc>] ppp_xmit_process+0x23/0x4ff
> [ 7575.778072]  #5:  (&(&pch->downl)->rlock){+.-...}, at: 
> [<ffffffff8126c39a>] ppp_push+0x69/0x507
> [ 7575.779010]  #6:  (l2tp_sock){+.-...}, at: [<ffffffffa05b0b2b>] 
> l2tp_xmit_skb+0x1b8/0x453 [l2tp_core]
> [ 7575.779951]  #7:  (rcu_read_lock){.+.+..}, at: [<ffffffff812fe4b1>] 
> rcu_lock_acquire+0x0/0x29
> [ 7575.780891]  #8:  (rcu_read_lock_bh){.+....}, at: 
> [<ffffffff812fe4b1>] rcu_lock_acquire+0x0/0x29
> [ 7575.781830]  #9:  (rcu_read_lock_bh){.+....}, at: 
> [<ffffffff812d2b10>] rcu_lock_acquire+0x0/0x29
> [ 7575.782769]
> [ 7575.782769] stack backtrace:
> [ 7575.783674] Pid: 0, comm: swapper/1 Not tainted 3.7.6-wbuild #6
> [ 7575.784139] Call Trace:
> [ 7575.784596]  <IRQ>  [<ffffffff8135b67b>] 
> print_circular_bug+0x1f8/0x209
> [ 7575.785075]  [<ffffffff81066567>] __lock_acquire+0xaf1/0xdce
> [ 7575.785540]  [<ffffffff81066c17>] lock_acquire+0x7e/0x94
> [ 7575.786004]  [<ffffffff812d8087>] ? dev_queue_xmit+0x90/0x34d
> [ 7575.786470]  [<ffffffff812d2b10>] ? dev_seq_stop+0xb/0xb
> [ 7575.786935]  [<ffffffff81361ce8>] _raw_spin_lock+0x2c/0x3b
> [ 7575.787398]  [<ffffffff812d8087>] ? dev_queue_xmit+0x90/0x34d
> [ 7575.787864]  [<ffffffff812d8087>] dev_queue_xmit+0x90/0x34d
> [ 7575.788328]  [<ffffffff812fe935>] ip_finish_output2+0x25a/0x2e5
> [ 7575.788794]  [<ffffffff812ff8c8>] ip_finish_output+0x46/0x4b
> [ 7575.789347]  [<ffffffff812fffd4>] ip_output+0x63/0x67
> [ 7575.789808]  [<ffffffff812fe549>] dst_output+0x18/0x1c
> [ 7575.790271]  [<ffffffff812ff972>] ip_local_out+0x1b/0x1f
> [ 7575.790735]  [<ffffffff812ffc49>] ip_queue_xmit+0x2d3/0x337
> [ 7575.791200]  [<ffffffffa05b0d77>] l2tp_xmit_skb+0x404/0x453 
> [l2tp_core]
> [ 7575.791668]  [<ffffffffa05be93b>] pppol2tp_xmit+0x122/0x15d 
> [l2tp_ppp]
> [ 7575.792135]  [<ffffffff8126c3b0>] ppp_push+0x7f/0x507
> [ 7575.792600]  [<ffffffff81362259>] ? 
> _raw_spin_unlock_irqrestore+0x3a/0x41
> [ 7575.793069]  [<ffffffff8106700b>] ? 
> trace_hardirqs_on_caller+0x107/0x158
> [ 7575.793536]  [<ffffffff81067069>] ? trace_hardirqs_on+0xd/0xf
> [ 7575.794002]  [<ffffffff8126e9e3>] ppp_xmit_process+0x44a/0x4ff
> [ 7575.794467]  [<ffffffff8126ebc0>] ppp_start_xmit+0x128/0x143
> [ 7575.794933]  [<ffffffff812d7dc7>] dev_hard_start_xmit+0x2ef/0x371
> [ 7575.795400]  [<ffffffff812eab61>] sch_direct_xmit+0x70/0x14f
> [ 7575.795864]  [<ffffffff812d8149>] dev_queue_xmit+0x152/0x34d
> [ 7575.796328]  [<ffffffff812de128>] neigh_direct_output+0xc/0xe
> [ 7575.796795]  [<ffffffff812fe943>] ip_finish_output2+0x268/0x2e5
> [ 7575.797261]  [<ffffffff812ff8c8>] ip_finish_output+0x46/0x4b
> [ 7575.797726]  [<ffffffff812fffd4>] ip_output+0x63/0x67
> [ 7575.798190]  [<ffffffff812fcfce>] ip_forward_finish+0x6b/0x70
> [ 7575.798656]  [<ffffffff812fd1d8>] ip_forward+0x205/0x285
> [ 7575.799120]  [<ffffffff812fbaf1>] ip_rcv_finish+0x2b3/0x2cb
> [ 7575.799586]  [<ffffffff812fb83e>] ? skb_dst.isra.7+0x58/0x58
> [ 7575.800051]  [<ffffffff812fbb55>] NF_HOOK.constprop.8+0x4c/0x55
> [ 7575.800517]  [<ffffffff812fbec6>] ip_rcv+0x22b/0x259
> [ 7575.800981]  [<ffffffff812d5649>] __netif_receive_skb+0x458/0x4c5
> [ 7575.801448]  [<ffffffff812d5844>] netif_receive_skb+0x56/0x8b
> [ 7575.801913]  [<ffffffff812d594a>] napi_gro_complete+0xd1/0xdc
> [ 7575.802378]  [<ffffffff812d5d2f>] napi_gro_flush+0x4c/0x68
> [ 7575.802843]  [<ffffffff812d2af8>] ? rcu_read_unlock+0x1c/0x1e
> [ 7575.803395]  [<ffffffff812d5d64>] napi_complete+0x19/0x4e
> [ 7575.803856]  [<ffffffff81261967>] igb_poll+0x6c5/0x909
> [ 7575.804317]  [<ffffffff8106602f>] ? __lock_acquire+0x5b9/0xdce
> [ 7575.804783]  [<ffffffff812d5e3c>] net_rx_action+0xa3/0x1b9
> [ 7575.805247]  [<ffffffff810301cc>] ? __do_softirq+0x70/0x157
> [ 7575.805712]  [<ffffffff81030204>] __do_softirq+0xa8/0x157
> [ 7575.806176]  [<ffffffff81363f8c>] call_softirq+0x1c/0x26
> [ 7575.806641]  [<ffffffff81003f45>] do_softirq+0x38/0x83
> [ 7575.807106]  [<ffffffff810303b1>] irq_exit+0x4e/0xad
> [ 7575.807569]  [<ffffffff81003c55>] do_IRQ+0x89/0xa0
> [ 7575.808032]  [<ffffffff813625ef>] common_interrupt+0x6f/0x6f
> [ 7575.808495]  <EOI>  [<ffffffff8136269c>] ? 
> retint_restore_args+0xe/0xe
> [ 7575.808974]  [<ffffffff81197d0c>] ? intel_idle+0xeb/0x111
> [ 7575.809443]  [<ffffffff81197d05>] ? intel_idle+0xe4/0x111
> [ 7575.809909]  [<ffffffff812b8b92>] cpuidle_enter+0x12/0x14
> [ 7575.810373]  [<ffffffff812b8fb8>] cpuidle_enter_state+0x10/0x39
> [ 7575.810840]  [<ffffffff812b905f>] cpuidle_idle_call+0x7e/0xa4
> [ 7575.811306]  [<ffffffff81009bd2>] cpu_idle+0x58/0xa2
> [ 7575.811770]  [<ffffffff81355e88>] start_secondary+0x188/0x18d

Hmm...

It seems keeping the socket locked is not needed and painful for
LOCKDEP.

Could you try the following patch ?


diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index dcfd64e..7baf88f 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1251,8 +1251,11 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	}
 
 	l2tp_skb_set_owner_w(skb, sk);
+	bh_unlock_sock(sk);
 
 	l2tp_xmit_core(session, skb, fl, data_len);
+	return ret;
+
 out_unlock:
 	bh_unlock_sock(sk);
 
