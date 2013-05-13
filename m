From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH v5 1/1 net] net: fec: fix kernel oops when plug/unplug
 cable many times
Date: Mon, 13 May 2013 13:07:43 +0800
Message-ID: <CAAQ0ZWSfZLMahuBnSkB3KFOhzMyfdMLgSjWimDbX-fFhv8Xw0w@mail.gmail.com>
References: <1367971724-1974-1-git-send-email-Frank.Li@freescale.com>
	<20130513045710.GA4440@S2101-09.ap.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: romieu@fr.zoreil.com, Robert Schwebel <r.schwebel@pengutronix.de>,
	David Miller <davem@davemloft.net>, l.stach@pengutronix.de,
	Linux Netdev List <netdev@vger.kernel.org>,
	Fabio Estevam <festevam@gmail.com>, lznuaa@gmail.com
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:61106 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308Ab3EMFHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 01:07:44 -0400
Received: by mail-pa0-f48.google.com with SMTP id kp6so4298685pab.21
        for <netdev@vger.kernel.org>; Sun, 12 May 2013 22:07:43 -0700 (PDT)
In-Reply-To: <20130513045710.GA4440@S2101-09.ap.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 May 2013 12:57, Shawn Guo <shawn.guo@linaro.org> wrote:
> Hi Frank,
>
> On Wed, May 08, 2013 at 08:08:44AM +0800, Frank Li wrote:
>> reproduce steps
>>  1. flood ping from other machine
>>       ping -f -s 41000 IP
>>  2. run below script
>>     while [ 1 ]; do ethtool -s eth0 autoneg off;
>>     sleep 3;ethtool -s eth0 autoneg on; sleep 4; done;
>>
>> You can see oops in one hour.
>>
>> The reason is fec_restart clear BD but NAPI may use it.
>> The solution is disable NAPI and stop xmit when reset BD.
>> disable NAPI may sleep, so fec_restart can't be call in
>> atomic context.
>>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>> Reviewed-by: Lucas Stach <l.stach@pengutronix.de>
>> Tested-by: Lucas Stach <l.stach@pengutronix.de>
>
> The patch has landed on 3.10-rc1.  Seems that it introduces a lock
> warning as below.  Turn on CONFIG_PROVE_LOCKING and you will be able
> to see it.

The warning message looks a little different in one of my imx28 boot tests.

Shawn

[    4.749454] =================================
[    4.753829] [ INFO: inconsistent lock state ]
[    4.758207] 3.10.0-rc1-00013-gc5f5ad9 #77 Not tainted
[    4.763270] ---------------------------------
[    4.767641] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[    4.773669] kworker/0:1/20 [HC0[0]:SC1[3]:HE1:SE0] takes:
[    4.779080]  (_xmit_ETHER#2){+.?...}, at: [<c03c5644>]
sch_direct_xmit+0x9c/0x2d0
[    4.786686] {SOFTIRQ-ON-W} state was registered at:
[    4.791579]   [<c005a784>] __lock_acquire+0x5fc/0x1a90
[    4.796767]   [<c005c188>] lock_acquire+0x9c/0x124
[    4.801598]   [<c04449cc>] _raw_spin_lock+0x2c/0x3c
[    4.806532]   [<c02fd3e8>] fec_restart+0x5bc/0x654
[    4.811370]   [<c02fddfc>] fec_enet_adjust_link+0x7c/0xb4
[    4.816806]   [<c02fac20>] phy_state_machine+0x17c/0x394
[    4.822153]   [<c0035e08>] process_one_work+0x1bc/0x4c4
[    4.827422]   [<c00364e0>] worker_thread+0x134/0x3a0
[    4.832420]   [<c003c274>] kthread+0xa4/0xb0
[    4.836726]   [<c000e9c0>] ret_from_fork+0x14/0x34
[    4.841564] irq event stamp: 828
[    4.844806] hardirqs last  enabled at (828): [<c0022f80>]
local_bh_enable_ip+0x84/0xf0
[    4.852773] hardirqs last disabled at (827): [<c0022f40>]
local_bh_enable_ip+0x44/0xf0
[    4.860727] softirqs last  enabled at (808): [<c0022d24>]
__do_softirq+0x180/0x284
[    4.868333] softirqs last disabled at (811): [<c00231e0>] irq_exit+0x9c/0xd8
[    4.875416]
[    4.875416] other info that might help us debug this:
[    4.881959]  Possible unsafe locking scenario:
[    4.881959]
[    4.887891]        CPU0
[    4.890345]        ----
[    4.892799]   lock(_xmit_ETHER#2);
[    4.896247]   <Interrupt>
[    4.898874]     lock(_xmit_ETHER#2);
[    4.902497]
[    4.902497]  *** DEADLOCK ***
[    4.902497]
[    4.908444] 7 locks held by kworker/0:1/20:
[    4.912637]  #0:  (rpciod){.+.+.+}, at: [<c0035d84>]
process_one_work+0x138/0x4c4
[    4.920217]  #1:  ((&(&transport->connect_worker)->work)){+.+.+.},
at: [<c0035d84>] process_one_work+0x138/0x4c4
[    4.930482]  #2:  (sk_lock-AF_INET-RPC){+.+...}, at: [<c04010ec>]
inet_stream_connect+0x20/0x48
[    4.939293]  #3:  (rcu_read_lock){.+.+..}, at: [<c03d435c>]
ip_queue_xmit+0x0/0x3f8
[    4.947043]  #4:  (rcu_read_lock){.+.+..}, at: [<c03abb18>]
__netif_receive_skb_core+0x34/0x5b0
[    4.955834]  #5:  (rcu_read_lock){.+.+..}, at: [<c03b9508>]
neigh_update+0x2a4/0x50c
[    4.963667]  #6:  (rcu_read_lock_bh){.+....}, at: [<c03b0870>]
dev_queue_xmit+0x0/0x684
[    4.971767]
[    4.971767] stack backtrace:
[    4.976162] CPU: 0 PID: 20 Comm: kworker/0:1 Not tainted
3.10.0-rc1-00013-gc5f5ad9 #77
[    4.984122] Workqueue: rpciod xs_tcp_setup_socket
[    4.988909] [<c0013958>] (unwind_backtrace+0x0/0xf0) from
[<c001173c>] (show_stack+0x10/0x14)
[    4.997491] [<c001173c>] (show_stack+0x10/0x14) from [<c043e26c>]
(print_usage_bug.part.28+0x218/0x280)
[    5.006937] [<c043e26c>] (print_usage_bug.part.28+0x218/0x280) from
[<c005a048>] (mark_lock+0x528/0x668)
[    5.016461] [<c005a048>] (mark_lock+0x528/0x668) from [<c005a73c>]
(__lock_acquire+0x5b4/0x1a90)
[    5.025289] [<c005a73c>] (__lock_acquire+0x5b4/0x1a90) from
[<c005c188>] (lock_acquire+0x9c/0x124)
[    5.034298] [<c005c188>] (lock_acquire+0x9c/0x124) from
[<c04449cc>] (_raw_spin_lock+0x2c/0x3c)
[    5.043050] [<c04449cc>] (_raw_spin_lock+0x2c/0x3c) from
[<c03c5644>] (sch_direct_xmit+0x9c/0x2d0)
[    5.052055] [<c03c5644>] (sch_direct_xmit+0x9c/0x2d0) from
[<c03b0b18>] (dev_queue_xmit+0x2a8/0x684)
[    5.061234] [<c03b0b18>] (dev_queue_xmit+0x2a8/0x684) from
[<c03b9478>] (neigh_update+0x214/0x50c)
[    5.070241] [<c03b9478>] (neigh_update+0x214/0x50c) from
[<c03fa8b8>] (arp_process+0x264/0x62c)
[    5.078985] [<c03fa8b8>] (arp_process+0x264/0x62c) from
[<c03abd7c>] (__netif_receive_skb_core+0x298/0x5b0)
[    5.088770] [<c03abd7c>] (__netif_receive_skb_core+0x298/0x5b0)
from [<c03aeecc>] (napi_gro_receive+0x74/0xa0)
[    5.098824] [<c03aeecc>] (napi_gro_receive+0x74/0xa0) from
[<c02fe084>] (fec_enet_rx_napi+0x250/0x5d8)
[    5.108182] [<c02fe084>] (fec_enet_rx_napi+0x250/0x5d8) from
[<c03aeb90>] (net_rx_action+0xc0/0x238)
[    5.117364] [<c03aeb90>] (net_rx_action+0xc0/0x238) from
[<c0022c90>] (__do_softirq+0xec/0x284)
[    5.126110] [<c0022c90>] (__do_softirq+0xec/0x284) from
[<c00231e0>] (irq_exit+0x9c/0xd8)
[    5.134335] [<c00231e0>] (irq_exit+0x9c/0xd8) from [<c000f804>]
(handle_IRQ+0x34/0x84)
[    5.142296] [<c000f804>] (handle_IRQ+0x34/0x84) from [<c00086fc>]
(icoll_handle_irq+0x34/0x4c)
[    5.150949] [<c00086fc>] (icoll_handle_irq+0x34/0x4c) from
[<c000e544>] (__irq_svc+0x44/0x54)
[    5.159494] Exception stack(0xc7561c78 to 0xc7561cc0)
[    5.164571] 1c60:
    00000001 c7520338
[    5.172783] 1c80: 00000000 20000013 c7560000 c03d3e84 c76d6d00
c7736400 c77582c0 00000000
[    5.180994] 1ca0: 00000000 00000000 04228060 c7561cc0 c005c944
c002307c 20000013 ffffffff
[    5.189217] [<c000e544>] (__irq_svc+0x44/0x54) from [<c002307c>]
(local_bh_enable+0x90/0xf0)
[    5.197700] [<c002307c>] (local_bh_enable+0x90/0xf0) from
[<c03d3e84>] (ip_finish_output+0x21c/0x504)
[    5.206960] [<c03d3e84>] (ip_finish_output+0x21c/0x504) from
[<c03d42f8>] (ip_local_out+0x30/0x94)
[    5.215955] [<c03d42f8>] (ip_local_out+0x30/0x94) from [<c03d44a0>]
(ip_queue_xmit+0x144/0x3f8)
[    5.224707] [<c03d44a0>] (ip_queue_xmit+0x144/0x3f8) from
[<c03e9308>] (tcp_transmit_skb+0x3cc/0x80c)
[    5.233981] [<c03e9308>] (tcp_transmit_skb+0x3cc/0x80c) from
[<c03ebc40>] (tcp_connect+0x57c/0x5d4)
[    5.243081] [<c03ebc40>] (tcp_connect+0x57c/0x5d4) from
[<c03ef960>] (tcp_v4_connect+0x288/0x3a8)
[    5.252010] [<c03ef960>] (tcp_v4_connect+0x288/0x3a8) from
[<c0401048>] (__inet_stream_connect+0x258/0x2dc)
[    5.261799] [<c0401048>] (__inet_stream_connect+0x258/0x2dc) from
[<c0401100>] (inet_stream_connect+0x34/0x48)
[    5.271863] [<c0401100>] (inet_stream_connect+0x34/0x48) from
[<c039aaf8>] (kernel_connect+0x10/0x14)
[    5.281139] [<c039aaf8>] (kernel_connect+0x10/0x14) from
[<c041e384>] (xs_tcp_setup_socket+0x10c/0x360)
[    5.290587] [<c041e384>] (xs_tcp_setup_socket+0x10c/0x360) from
[<c0035e08>] (process_one_work+0x1bc/0x4c4)
[    5.300372] [<c0035e08>] (process_one_work+0x1bc/0x4c4) from
[<c00364e0>] (worker_thread+0x134/0x3a0)
[    5.309632] [<c00364e0>] (worker_thread+0x134/0x3a0) from
[<c003c274>] (kthread+0xa4/0xb0)
[    5.317944] [<c003c274>] (kthread+0xa4/0xb0) from [<c000e9c0>]
(ret_from_fork+0x14/0x34)
