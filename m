From: Xose Vazquez Perez <xose.vazquez@gmail.com>
Subject: Re: [BUG] ISIC + 2.6.22 (via-rhine)
Date: Tue, 31 Jul 2007 23:53:51 +0200
Message-ID: <46AFAF6F.2090103@gmail.com>
References: <46AFA576.1060902@gmail.com> <1185917013.2766.12.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.234]:57461 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052AbXGaVx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2007 17:53:59 -0400
Received: by hu-out-0506.google.com with SMTP id 19so15943hue
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2007 14:53:57 -0700 (PDT)
In-Reply-To: <1185917013.2766.12.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:

>> =================================
>> [ INFO: inconsistent lock state ]
>> 2.6.22 #1
>> ---------------------------------
>> inconsistent {in-hardirq-W} -> {hardirq-on-W} usage.
>> swapper/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
>>   (&rp->lock){++..}, at: [<f8c890db>] rhine_tx_timeout+0x6f/0xf4 [via_rhine]
> 
> 
> 
> this is a case of homegrown locking: the via-rhine driver does
> 
>         /* protect against concurrent rx interrupts */
>         disable_irq(rp->pdev->irq);
> 
>         spin_lock(&rp->lock);
> 
>         /* clear all descriptors */
>         free_tbufs(dev);
>         free_rbufs(dev);
>         alloc_tbufs(dev);
>         alloc_rbufs(dev);
> 
>         /* Reinitialize the hardware. */
>         rhine_chip_reset(dev);
>         init_registers(dev);  
> 
>         spin_unlock(&rp->lock);
>         enable_irq(rp->pdev->irq);
> 
> 
> as a way to protect code against interrupts... rather than using the
> normal mechanism.
> 
> 
> the annotation is pretty simple (untested, not even compiled):
> 
> --- linux-2.6.22/drivers/net/via-rhine.c.org	2007-07-31 14:22:06.000000000 -0700
> +++ linux-2.6.22/drivers/net/via-rhine.c	2007-07-31 14:22:26.000000000 -0700
> @@ -1191,7 +1191,7 @@
>  	       mdio_read(dev, rp->mii_if.phy_id, MII_BMSR));
>  
>  	/* protect against concurrent rx interrupts */
> -	disable_irq(rp->pdev->irq);
> +	disable_irq_lockdep(rp->pdev->irq);
>  
>  	spin_lock(&rp->lock);
>  
> @@ -1206,7 +1206,7 @@
>  	init_registers(dev);
>  
>  	spin_unlock(&rp->lock);
> -	enable_irq(rp->pdev->irq);
> +	enable_irq_lockdep(rp->pdev->irq);
>  
>  	dev->trans_start = jiffies;
>  	rp->stats.tx_errors++;

thanks Arjan. Patch applied and now I get:

NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timed out, status 0000, PHY status 786d, resetting...

======================================================
[ INFO: hard-safe -> hard-unsafe lock order detected ]
2.6.22 #1
------------------------------------------------------
swapper/0 [HC0[0]:SC1[1]:HE0:SE0] is trying to acquire:
  (af_callback_keys + sk->sk_family#3){-.-?}, at: [<c05ab7d3>] sock_def_write_space+0x18/0x96

and this task is already holding:
  (&rp->lock){++..}, at: [<f8d0a0e1>] rhine_tx_timeout+0x75/0x102 [via_rhine]
which would create a new lock dependency:
  (&rp->lock){++..} -> (af_callback_keys + sk->sk_family#3){-.-?}

but this new dependency connects a hard-irq-safe lock:
  (&rp->lock){++..}
... which became hard-irq-safe at:
   [<c04440d4>] __lock_acquire+0x38c/0xb12
   [<c0444c1b>] lock_acquire+0x56/0x6f
   [<c0615279>] _spin_lock+0x2b/0x38
   [<f8d08b49>] rhine_interrupt+0x16b/0x69b [via_rhine]
   [<c045aac6>] handle_IRQ_event+0x1a/0x46
   [<c045bbc0>] handle_fasteoi_irq+0x7d/0xb6
   [<c0407089>] do_IRQ+0xb1/0xd8
   [<ffffffff>] 0xffffffff

to a hard-irq-unsafe lock:
  (af_callback_keys + sk->sk_family#3){-.-?}
... which became hard-irq-unsafe at:
...  [<c0444144>] __lock_acquire+0x3fc/0xb12
   [<c0444c1b>] lock_acquire+0x56/0x6f
   [<c061532b>] _write_lock_bh+0x30/0x3d
   [<c05d829e>] tcp_close+0x24e/0x531
   [<c05f1175>] inet_release+0x43/0x49
   [<c05a85d4>] sock_release+0x17/0x62
   [<c05a89fb>] sock_close+0x2d/0x33
   [<c047db0f>] __fput+0xbe/0x168
   [<c047dbd0>] fput+0x17/0x19
   [<c047b4b5>] filp_close+0x54/0x5c
   [<c047c444>] sys_close+0x78/0xb0
   [<c0404e26>] sysenter_past_esp+0x5f/0x99
   [<ffffffff>] 0xffffffff

other info that might help us debug this:

2 locks held by swapper/0:
  #0:  (_xmit_ETHER){-+..}, at: [<c05c042a>] dev_watchdog+0x14/0xbf
  #1:  (&rp->lock){++..}, at: [<f8d0a0e1>] rhine_tx_timeout+0x75/0x102 [via_rhine]

the hard-irq-safe lock's dependencies:
-> (&rp->lock){++..} ops: 0 {
    initial-use  at:
                         [<c044417d>] __lock_acquire+0x435/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c06155af>] _spin_lock_irqsave+0x34/0x44
                         [<f8d0a19b>] rhine_get_stats+0x2d/0x9d [via_rhine]
                         [<c05b9017>] rtnl_fill_ifinfo+0x2e9/0x414
                         [<c05b9547>] rtmsg_ifinfo+0x57/0xd4
                         [<c05b95fc>] rtnetlink_event+0x38/0x3c
                         [<c0616f9e>] notifier_call_chain+0x2b/0x4a
                         [<c0433984>] __raw_notifier_call_chain+0x19/0x1e
                         [<c04339a3>] raw_notifier_call_chain+0x1a/0x1c
                         [<c05b14a3>] register_netdevice+0x335/0x33f
                         [<c05b27d6>] register_netdev+0x40/0x4d
                         [<f8d09d07>] rhine_init_one+0x515/0x6c7 [via_rhine]
                         [<c04f8085>] pci_device_probe+0x39/0x5b
                         [<c055cffc>] driver_probe_device+0xe9/0x16a
                         [<c055d1a6>] __driver_attach+0x76/0xaf
                         [<c055c4ec>] bus_for_each_dev+0x3a/0x5f
                         [<c055ce47>] driver_attach+0x19/0x1b
                         [<c055c80a>] bus_add_driver+0x79/0x181
                         [<c055d3a1>] driver_register+0x67/0x6c
                         [<c04f81dd>] __pci_register_driver+0x56/0x83
                         [<f885f06c>] 0xf885f06c
                         [<c044b77f>] sys_init_module+0x1579/0x16ca
                         [<c0404e26>] sysenter_past_esp+0x5f/0x99
                         [<ffffffff>] 0xffffffff
    in-hardirq-W at:
                         [<c04440d4>] __lock_acquire+0x38c/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c0615279>] _spin_lock+0x2b/0x38
                         [<f8d08b49>] rhine_interrupt+0x16b/0x69b [via_rhine]
                         [<c045aac6>] handle_IRQ_event+0x1a/0x46
                         [<c045bbc0>] handle_fasteoi_irq+0x7d/0xb6
                         [<c0407089>] do_IRQ+0xb1/0xd8
                         [<ffffffff>] 0xffffffff
    in-softirq-W at:
                         [<c04440f5>] __lock_acquire+0x3ad/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c06154e4>] _spin_lock_irq+0x31/0x3e
                         [<f8d0a68e>] rhine_start_tx+0x1b2/0x24a [via_rhine]
                         [<c05b21e9>] dev_hard_start_xmit+0x1ea/0x247
                         [<c05c0344>] __qdisc_run+0xc9/0x19b
                         [<c05b3ce0>] dev_queue_xmit+0x157/0x26b
                         [<f8fa81ed>] mld_sendpack+0x210/0x35a [ipv6]
                         [<f8fa8eb8>] mld_ifc_timer_expire+0x1e9/0x211 [ipv6]
                         [<c04303be>] run_timer_softirq+0x11a/0x182
                         [<c042d1fe>] __do_softirq+0x6f/0xe9
                         [<c0406f72>] do_softirq+0x61/0xc7
                         [<ffffffff>] 0xffffffff
  }
  ... key      at: [<f8d0f200>] __key.22744+0x0/0xffffb5f3 [via_rhine]

the hard-irq-unsafe lock's dependencies:
-> (af_callback_keys + sk->sk_family#3){-.-?} ops: 0 {
    initial-use  at:
                         [<c044417d>] __lock_acquire+0x435/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c061532b>] _write_lock_bh+0x30/0x3d
                         [<c05d829e>] tcp_close+0x24e/0x531
                         [<c05f1175>] inet_release+0x43/0x49
                         [<c05a85d4>] sock_release+0x17/0x62
                         [<c05a89fb>] sock_close+0x2d/0x33
                         [<c047db0f>] __fput+0xbe/0x168
                         [<c047dbd0>] fput+0x17/0x19
                         [<c047b4b5>] filp_close+0x54/0x5c
                         [<c047c444>] sys_close+0x78/0xb0
                         [<c0404e26>] sysenter_past_esp+0x5f/0x99
                         [<ffffffff>] 0xffffffff
    hardirq-on-W at:
                         [<c0444144>] __lock_acquire+0x3fc/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c061532b>] _write_lock_bh+0x30/0x3d
                         [<c05d829e>] tcp_close+0x24e/0x531
                         [<c05f1175>] inet_release+0x43/0x49
                         [<c05a85d4>] sock_release+0x17/0x62
                         [<c05a89fb>] sock_close+0x2d/0x33
                         [<c047db0f>] __fput+0xbe/0x168
                         [<c047dbd0>] fput+0x17/0x19
                         [<c047b4b5>] filp_close+0x54/0x5c
                         [<c047c444>] sys_close+0x78/0xb0
                         [<c0404e26>] sysenter_past_esp+0x5f/0x99
                         [<ffffffff>] 0xffffffff
    in-softirq-R at:
                         [<c04440f5>] __lock_acquire+0x3ad/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c06153de>] _read_lock+0x2b/0x38
                         [<c05ab765>] sock_def_readable+0x18/0x6e
                         [<c05abca3>] sock_queue_rcv_skb+0xe1/0x102
                         [<c05ead1f>] udp_queue_rcv_skb+0x2d8/0x383
                         [<c05eb23b>] __udp4_lib_rcv+0x471/0x73a
                         [<c05eb516>] udp_rcv+0x12/0x14
                         [<c05cda19>] ip_local_deliver+0x187/0x232
                         [<c05cd85a>] ip_rcv+0x490/0x4c8
                         [<c05b1bc2>] netif_receive_skb+0x2ce/0x33e
                         [<c05b389b>] process_backlog+0x8b/0xec
                         [<c05b3a86>] net_rx_action+0x9b/0x19e
                         [<c042d1fe>] __do_softirq+0x6f/0xe9
                         [<c0406f72>] do_softirq+0x61/0xc7
                         [<ffffffff>] 0xffffffff
    softirq-on-R at:
                         [<c0444168>] __lock_acquire+0x420/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c06153de>] _read_lock+0x2b/0x38
                         [<c05ab7d3>] sock_def_write_space+0x18/0x96
                         [<c05aae32>] sock_setsockopt+0x11b/0x4d4
                         [<c05a7e9d>] sys_setsockopt+0x61/0x97
                         [<c05a9513>] sys_socketcall+0x1e8/0x241
                         [<c0404e26>] sysenter_past_esp+0x5f/0x99
                         [<ffffffff>] 0xffffffff
    hardirq-on-R at:
                         [<c0444119>] __lock_acquire+0x3d1/0xb12
                         [<c0444c1b>] lock_acquire+0x56/0x6f
                         [<c06153de>] _read_lock+0x2b/0x38
                         [<c05ab7d3>] sock_def_write_space+0x18/0x96
                         [<c05abbad>] sock_wfree+0x27/0x3c
                         [<c0562b18>] loopback_xmit+0x12/0x66
                         [<c05b21e9>] dev_hard_start_xmit+0x1ea/0x247
                         [<c05b3d48>] dev_queue_xmit+0x1bf/0x26b
                         [<c05b854d>] neigh_resolve_output+0x1f7/0x22c
                         [<c05d25e6>] ip_output+0x287/0x2b5
                         [<c05cfd04>] ip_push_pending_frames+0x2f9/0x3ba
                         [<c05ea8aa>] udp_push_pending_frames+0x2c7/0x2e9
                         [<c05eba55>] udp_sendmsg+0x455/0x580
                         [<c05f0b8f>] inet_sendmsg+0x3e/0x49
                         [<c05a834f>] sock_sendmsg+0xe7/0x104
                         [<c05a8c26>] sys_sendto+0xcc/0xec
                         [<c05a8c7c>] sys_send+0x36/0x38
                         [<c05a9469>] sys_socketcall+0x13e/0x241
                         [<c0404e26>] sysenter_past_esp+0x5f/0x99
                         [<ffffffff>] 0xffffffff
  }
  ... key      at: [<c0a2dfd0>] af_callback_keys+0x10/0x110

stack backtrace:
  [<c0405e6a>] show_trace_log_lvl+0x1a/0x2f
  [<c04068cf>] show_trace+0x12/0x14
  [<c0406928>] dump_stack+0x16/0x18
  [<c0443cb4>] check_usage+0x258/0x262
  [<c04445ee>] __lock_acquire+0x8a6/0xb12
  [<c0444c1b>] lock_acquire+0x56/0x6f
  [<c06153de>] _read_lock+0x2b/0x38
  [<c05ab7d3>] sock_def_write_space+0x18/0x96
  [<c05abbad>] sock_wfree+0x27/0x3c
  [<c05ad393>] __kfree_skb+0xa6/0xfc
  [<c05ad417>] kfree_skb+0x2e/0x30
  [<f8d084dd>] free_tbufs+0x3f/0x66 [via_rhine]
  [<f8d0a0e8>] rhine_tx_timeout+0x7c/0x102 [via_rhine]
  [<c05c048c>] dev_watchdog+0x76/0xbf
  [<c04303be>] run_timer_softirq+0x11a/0x182
  [<c042d1fe>] __do_softirq+0x6f/0xe9
  [<c0406f72>] do_softirq+0x61/0xc7
  =======================
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timed out, status 0000, PHY status 786d, resetting...
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timed out, status 0000, PHY status 786d, resetting...
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timed out, status 0000, PHY status 786d, resetting...
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timed out, status 0000, PHY status 786d, resetting...
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
NETDEV WATCHDOG: eth0: transmit timed out
eth0: Transmit timed out, status 0000, PHY status 786d, resetting...
eth0: link up, 100Mbps, full-duplex, lpa 0x45E1



-- 
Politicos de mierda, yo no soy un terrorista.
