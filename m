From: Shawn Guo <shawn.guo@freescale.com>
Subject: Inconsistent lock state introduced by ipv6/addrconf change
Date: Fri, 4 Apr 2014 15:34:56 +0800
Message-ID: <20140404073455.GB29778@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe003.messaging.microsoft.com ([65.55.88.13]:14855 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751343AbaDDHfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 03:35:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm running into an inconsistent lock state warning on the final v3.14
kernel (-rc8 is good) on Freescale i.MX6 platform with fec driver
(drivers/net/ethernet/freescale/fec_main.c).  The git bisect points
the finger to commit c15b1cc (ipv6: move DAD and addrconf_verify
processing to workqueue).  Reverting the commit does fix the problem
for me.  The image is built from arch/arm/configs/imx_v6_v7_defconfig.

The interesting part is the same warning shows up on mainline tree until
net-next gets merged with commit cd6362b.  That's why Olof's autobooter
keeps reporting failure on hummingboard and wandboard (both i.MX6 based)
since v3.14 release [1], but reports success after commit cd6362b.

We're less concerned by the mainline tree, since the problem disappeared
now (nice to know why though).  But we do still want to fix it for 3.14
stable kernel.

Shawn

[1] http://lists.linaro.org/pipermail/kernel-build-reports/2014-April/003054.html
[2] http://lists.linaro.org/pipermail/kernel-build-reports/2014-April/003061.html

[....] Configuring network interfaces...Internet Systems Consortium DHCP Client 4.2.2
Copyright 2004-2011 Internet Systems Consortium.
All rights reserved.
For info, please visit https://www.isc.org/software/dhcp/

fec 2188000.ethernet eth0: Freescale FEC PHY driver [Atheros 8031 ethernet] (mii_bus:phy_addr=2188000.ethernet:01, irq=-1)
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
Listening on LPF/eth0/00:04:9f:02:67:58
Sending on   LPF/eth0/00:04:9f:02:67:58
Sending on   Socket/fallback
DHCPREQUEST on eth0 to 255.255.255.255 port 67
libphy: 2188000.ethernet:01 - Link is Up - 100/Full
IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready

=================================
[ INFO: inconsistent lock state ]
3.14.0 #3 Not tainted
---------------------------------
inconsistent {IN-SOFTIRQ-W} -> {SOFTIRQ-ON-W} usage.
kworker/1:1/28 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (&addrconf_stats->syncp.seq){+.?...}, at: [<80573b54>] mld_send_initial_cr.part.17+0x9c/0xb0
{IN-SOFTIRQ-W} state was registered at:
  [<8006230c>] mark_lock+0x140/0x6ac
  [<80062d48>] __lock_acquire+0x4d0/0x1c28
  [<8006496c>] lock_acquire+0x68/0x7c
  [<80573008>] mld_sendpack+0xec/0x728
  [<80573d48>] mld_ifc_timer_expire+0x1e0/0x2dc
  [<80031680>] call_timer_fn+0x74/0xf0
  [<800322f0>] run_timer_softirq+0x198/0x230
  [<8002bdd8>] __do_softirq+0x130/0x278
  [<8002c218>] irq_exit+0xb0/0x104
  [<8000f37c>] handle_IRQ+0x58/0xb8
  [<80008640>] gic_handle_irq+0x30/0x64
  [<800130e4>] __irq_svc+0x44/0x5c
  [<8006d6f4>] cpu_startup_entry+0x68/0x14c
  [<80014420>] secondary_start_kernel+0x12c/0x14c
  [<10008704>] 0x10008704
irq event stamp: 4567
hardirqs last  enabled at (4567): [<8002c080>] __local_bh_enable_ip+0x80/0xe8
hardirqs last disabled at (4565): [<8002c040>] __local_bh_enable_ip+0x40/0xe8
softirqs last  enabled at (4566): [<8054f7e4>] ip6_finish_output2+0x174/0x9e8
softirqs last disabled at (4550): [<8054f6c0>] ip6_finish_output2+0x50/0x9e8

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(&addrconf_stats->syncp.seq);
  <Interrupt>
    lock(&addrconf_stats->syncp.seq);

 *** DEADLOCK ***

4 locks held by kworker/1:1/28:
 #0:  ("%s"("ipv6_addrconf")){.+.+..}, at: [<8003dc0c>] process_one_work+0x130/0x448
 #1:  ((&(&ifa->dad_work)->work)){+.+...}, at: [<8003dc0c>] process_one_work+0x130/0x448
 #2:  (rtnl_mutex){+.+.+.}, at: [<804d909c>] rtnl_lock+0x18/0x20
 #3:  (rcu_read_lock){.+.+..}, at: [<80572f1c>] mld_sendpack+0x0/0x728

stack backtrace:
CPU: 1 PID: 28 Comm: kworker/1:1 Not tainted 3.14.0 #3
Workqueue: ipv6_addrconf addrconf_dad_work
Backtrace:
[<8001235c>] (dump_backtrace) from [<800124f8>] (show_stack+0x18/0x1c)
 r6:bf0adf00 r5:8076dcd4 r4:00000000 r3:bf0adf00
[<800124e0>] (show_stack) from [<80612740>] (dump_stack+0x80/0x9c)
[<806126c0>] (dump_stack) from [<806103c8>] (print_usage_bug+0x260/0x2d0)
 r4:80991560 r3:bf0adf00
[<80610168>] (print_usage_bug) from [<80062468>] (mark_lock+0x29c/0x6ac)
 r10:80061960 r8:00000004 r7:bf0adf00 r6:00001054 r5:bf0ae390 r4:00000006
[<800621cc>] (mark_lock) from [<80062e94>] (__lock_acquire+0x61c/0x1c28)
 r10:80970bb0 r9:bf0adf00 r8:00000004 r7:bf0ae390 r6:80dc1444 r5:000001eb
 r4:bf0ae390 r3:00000001
[<80062878>] (__lock_acquire) from [<8006496c>] (lock_acquire+0x68/0x7c)
 r10:808c7900 r9:80573b54 r8:bf7df438 r7:00000001 r6:60000013 r5:bf242000
 r4:00000000
[<80064904>] (lock_acquire) from [<80573320>] (mld_sendpack+0x404/0x728)
 r7:bf7df55c r6:0000004c r5:be8c0000 r4:be54cf00
[<80572f1c>] (mld_sendpack) from [<80573b54>] (mld_send_initial_cr.part.17+0x9c/0xb0)
 r10:be8c00d0 r9:bf242000 r8:00000000 r7:00000001 r6:be54cf00 r5:be84cf68
 r4:00000000
[<80573ab8>] (mld_send_initial_cr.part.17) from [<80577050>] (ipv6_mc_dad_complete+0x34/0x5c)
 r10:00000000 r8:be8c00d0 r7:be73ec00 r6:be73ec20 r5:bf0e2000 r4:be8c0000
[<8057701c>] (ipv6_mc_dad_complete) from [<8055b2d8>] (addrconf_dad_completed+0xfc/0x1a4)
 r4:be73ec00 r3:bf0adf00
[<8055b1dc>] (addrconf_dad_completed) from [<8055b578>] (addrconf_dad_work+0x1f8/0x314)
 r5:be73ec40 r4:be73ec74
[<8055b380>] (addrconf_dad_work) from [<8003dc88>] (process_one_work+0x1ac/0x448)
 r10:bf7df200 r8:00000000 r7:bf243ea8 r6:bf7d95c0 r5:be73ec74 r4:bf224300
[<8003dadc>] (process_one_work) from [<8003e328>] (worker_thread+0x124/0x398)
 r10:808d09b6 r9:bf7d95c0 r8:bf242000 r7:bf224318 r6:bf242000 r5:bf7d95f0
 r4:bf224300
[<8003e204>] (worker_thread) from [<80044fd0>] (kthread+0xcc/0xe8)
 r10:00000000 r9:00000000 r8:00000000 r7:8003e204 r6:bf224300 r5:bf2250c0
 r4:00000000
[<80044f04>] (kthread) from [<8000eae8>] (ret_from_fork+0x14/0x2c)
 r7:00000000 r6:00000000 r5:80044f04 r4:bf2250c0
DHCPREQUEST on eth0 to 255.255.255.255 port 67
DHCPACK from 192.168.1.1
bound to 192.168.1.105 -- renewal in 1073741823 seconds.
done.
