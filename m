From: Jonas Bonn <jonas@southpole.se>
Subject: Lockdep warning
Date: Thu, 19 Dec 2013 14:36:40 +0100
Message-ID: <52B2F668.2030400@southpole.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here's a lockdep warning that I'm seeing on an MX28 with 3.13-rc4.  This 
seems to happen as soon as the network link comes up... including the 
'netdev' list here as the backtrace shows the FEC driver in the stacktrace.

Any advice on how to proceed to track this down appreciated...

/Jonas

[   37.140857] fec 800f0000.ethernet eth0: Freescale FEC PHY driver 
[Generic PHY] (mii_bus:phy_addr=800f0000.etherne:00, irq=-1)
[   37.148951] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   39.155538] libphy: 800f0000.etherne:00 - Link is Up - 100/Full
[   39.162273] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   41.167998]
[   41.169546] =================================
[   41.173925] [ INFO: inconsistent lock state ]
[   41.178308] 3.13.0-rc4-00018-g3b78c2f-dirty #8 Not tainted
[   41.183808] ---------------------------------
[   41.188182] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
[   41.194213] connmand/337 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   41.199452]  (&(&sk->sk_dst_lock)->rlock){+.?...}, at: [<c03d8088>] 
__udp4_lib_rcv+0x7e0/0x8a8
[   41.208175] {SOFTIRQ-ON-W} state was registered at:
[   41.213071]   [<c0046cb8>] __lock_acquire+0x5d0/0x1a64
[   41.218274]   [<c0048694>] lock_acquire+0x9c/0x104
[   41.223115]   [<c046a690>] _raw_spin_lock+0x28/0x38
[   41.228052]   [<c042be50>] ip6_datagram_connect+0x258/0x43c
[   41.233669]   [<c03e0478>] inet_dgram_connect+0x58/0x84
[   41.238945]   [<c0376c7c>] SyS_connect+0x64/0x8c
[   41.243610]   [<c0009560>] ret_fast_syscall+0x0/0x44
[   41.248629] irq event stamp: 70302
[   41.252050] hardirqs last  enabled at (70302): [<c0057c98>] 
__getnstimeofday+0x15c/0x178
[   41.260193] hardirqs last disabled at (70301): [<c0057b64>] 
__getnstimeofday+0x28/0x178
[   41.268243] softirqs last  enabled at (70208): [<c001a158>] 
__do_softirq+0x198/0x2c4
[   41.276049] softirqs last disabled at (70217): [<c001a640>] 
irq_exit+0xa4/0xf8
[   41.283309]
[   41.283309] other info that might help us debug this:
[   41.289856]  Possible unsafe locking scenario:
[   41.289856]
[   41.295793]        CPU0
[   41.298250]        ----
[   41.300706]   lock(&(&sk->sk_dst_lock)->rlock);
[   41.305277]   <Interrupt>
[   41.307908]     lock(&(&sk->sk_dst_lock)->rlock);
[   41.312652]
[   41.312652]  *** DEADLOCK ***
[   41.312652]
[   41.318605] 2 locks held by connmand/337:
[   41.322628]  #0:  (rcu_read_lock){.+.+..}, at: [<c0386648>] 
__netif_receive_skb_core+0x34/0x5e0
[   41.331445]  #1:  (rcu_read_lock){.+.+..}, at: [<c03abf80>] 
ip_local_deliver+0x5c/0x30c
[   41.339559]
[   41.339559] stack backtrace:
[   41.343959] CPU: 0 PID: 337 Comm: connmand Not tainted 
3.13.0-rc4-00018-g3b78c2f-dirty #8
[   41.352208] [<c000d970>] (unwind_backtrace+0x0/0xf0) from 
[<c000bd84>] (show_stack+0x10/0x14)
[   41.360797] [<c000bd84>] (show_stack+0x10/0x14) from [<c0463cb4>] 
(print_usage_bug.part.27+0x218/0x280)
[   41.370251] [<c0463cb4>] (print_usage_bug.part.27+0x218/0x280) from 
[<c0046308>] (mark_lock+0x288/0x668)
[   41.379784] [<c0046308>] (mark_lock+0x288/0x668) from [<c0046c80>] 
(__lock_acquire+0x598/0x1a64)
[   41.388620] [<c0046c80>] (__lock_acquire+0x598/0x1a64) from 
[<c0048694>] (lock_acquire+0x9c/0x104)
[   41.397639] [<c0048694>] (lock_acquire+0x9c/0x104) from [<c046a690>] 
(_raw_spin_lock+0x28/0x38)
[   41.406390] [<c046a690>] (_raw_spin_lock+0x28/0x38) from [<c03d8088>] 
(__udp4_lib_rcv+0x7e0/0x8a8)
[   41.415399] [<c03d8088>] (__udp4_lib_rcv+0x7e0/0x8a8) from 
[<c03abfec>] (ip_local_deliver+0xc8/0x30c)
[   41.424667] [<c03abfec>] (ip_local_deliver+0xc8/0x30c) from 
[<c03ac58c>] (ip_rcv+0x35c/0x74c)
[   41.433247] [<c03ac58c>] (ip_rcv+0x35c/0x74c) from [<c03868ec>] 
(__netif_receive_skb_core+0x2d8/0x5e0)
[   41.442611] [<c03868ec>] (__netif_receive_skb_core+0x2d8/0x5e0) from 
[<c03894ac>] (napi_gro_receive+0x74/0xa0)
[   41.452675] [<c03894ac>] (napi_gro_receive+0x74/0xa0) from 
[<c02d5f50>] (fec_enet_rx_napi+0x304/0x704)
[   41.462037] [<c02d5f50>] (fec_enet_rx_napi+0x304/0x704) from 
[<c038918c>] (net_rx_action+0xc0/0x20c)
[   41.471235] [<c038918c>] (net_rx_action+0xc0/0x20c) from [<c001a0ac>] 
(__do_softirq+0xec/0x2c4)
[   41.479987] [<c001a0ac>] (__do_softirq+0xec/0x2c4) from [<c001a640>] 
(irq_exit+0xa4/0xf8)
[   41.488208] [<c001a640>] (irq_exit+0xa4/0xf8) from [<c0009e44>] 
(handle_IRQ+0x34/0x84)
[   41.496172] [<c0009e44>] (handle_IRQ+0x34/0x84) from [<c000c9c4>] 
(__irq_usr+0x44/0x60)
