From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH] ipv6: Fix soft lockup for ipv6 network notifier.
Date: Fri, 1 Jul 2016 15:38:44 +0800
Message-ID: <57761E04.8030202@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <luto@kernel.org>, <mingo@kernel.org>,
	<linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:1703 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199AbcGAHjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 03:39:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The problem was occurs in my system that a lot of drviers register
its own handler to the notifiler call chain for netdev_chain, and
then create 4095 vlan dev for one nic, and add several ipv6 address
on each one of them, just like this:

for i in `seq 1 4095`; do ip link add link eth0 name eth0.$i type vlan id $i; done
for i in `seq 1 4095`; do ip -6 addr add 2001::$i dev eth0.$i; done
for i in `seq 1 4095`; do ip -6 addr add 2002::$i dev eth0.$i; done
for i in `seq 1 4095`; do ip -6 addr add 2003::$i dev eth0.$i; done

ifconfig eth0 up
ifconfig eth0 down

then it will halt several seconds, and occurs softlockup:

<0>[ 7620.364058]NMI watchdog: BUG: soft lockup - CPU#0 stuck for 23s! [ifconfig:19186]
<0>[ 7620.364592]Call trace:
<4>[ 7620.364599][<ffffffc000208f68>] dump_backtrace+0x0/0x220
<4>[ 7620.364603][<ffffffc0002091a8>] show_stack+0x20/0x28
<4>[ 7620.364607][<ffffffc000691fac>] dump_stack+0x90/0xb0
<4>[ 7620.364612][<ffffffc0002cacbc>] watchdog_timer_fn+0x41c/0x460
<4>[ 7620.364617][<ffffffc000289ec8>] __run_hrtimer+0x98/0x2d8
<4>[ 7620.364620][<ffffffc00028a3e0>] hrtimer_interrupt+0x110/0x288
<4>[ 7620.364624][<ffffffc00059c0c8>] arch_timer_handler_phys+0x38/0x48
<4>[ 7620.364628][<ffffffc000276d2c>] handle_percpu_devid_irq+0x9c/0x190
<4>[ 7620.364632][<ffffffc000271ef8>] generic_handle_irq+0x40/0x58
<4>[ 7620.364635][<ffffffc000272270>] __handle_domain_irq+0x68/0xc0
<4>[ 7620.364638][<ffffffc000200634>] gic_handle_irq+0xc4/0x1c8
<4>[ 7620.364641]Exception stack(0xffffffc0309b3640 to 0xffffffc0309b3770)
<4>[ 7620.364644]3640: 0000000000001000 0000000000000000 ffffffc0309b37c0 ffffffbfa1019cf8
<4>[ 7620.364647]3660: 0000000080000145 ffffffc0309b3958 0000000000000000 ffffffbfa1013008
<4>[ 7620.364651]3680: 00000000000007f0 ffffffbfa131b770 ffffffd08aaadc40 ffffffbfa1019cf8
<4>[ 7620.364654]36a0: ffffffbfa1019cc4 ffffffd089c2b000 ffffffd08eff8000 ffffffc0309b3958
<4>[ 7620.364656]36c0: ffffffbfa101c5c0 0000000000000000 0000000000000000 ffffffbfa101c66c
<4>[ 7620.364659]36e0: 7f7f7f7f7f7f7f7f 0000000000000030 ffffffffffffffff ffff000000000000
<4>[ 7620.364662]3700: 0000000000000000 0000000000000000 ffffffc000393d58 0000007f794d67b0
<4>[ 7620.364665]3720: 0000007fe62215d0 ffffffc0309b3830 ffffffc00021d8e0 ffffffbfa1049b68
<4>[ 7620.364668]3740: ffffffc000697578 ffffffc0006974b8 ffffffc0309b3958 0000000000000000
<4>[ 7620.364670]3760: ffffffbfa1013008 00000000000007f0
<4>[ 7620.364673][<ffffffc000203780>] el1_irq+0x80/0x100
<4>[ 7620.364692][<ffffffbfa1019ed4>] fib6_walk+0x3c/0x70 [ipv6]
<4>[ 7620.364710][<ffffffbfa1019f70>] fib6_clean_tree+0x68/0x90 [ipv6]
<4>[ 7620.364727][<ffffffbfa101a020>] __fib6_clean_all+0x88/0xc0 [ipv6]
<4>[ 7620.364746][<ffffffbfa101c760>] fib6_clean_all+0x28/0x30 [ipv6]
<4>[ 7620.364763][<ffffffbfa101933c>] rt6_ifdown+0x64/0x148 [ipv6]
<4>[ 7620.364781][<ffffffbfa100e6d8>] addrconf_ifdown+0x68/0x540 [ipv6]
<4>[ 7620.364798][<ffffffbfa1010f58>] addrconf_notify+0xd0/0x8b8 [ipv6]
<4>[ 7620.364801][<ffffffc00023f83c>] notifier_call_chain+0x5c/0xa0
<4>[ 7620.364804][<ffffffc00023f9e0>] raw_notifier_call_chain+0x20/0x28
<4>[ 7620.364809][<ffffffc0005cbab4>] call_netdevice_notifiers_info+0x4c/0x80
<4>[ 7620.364812][<ffffffc0005cbfc8>] dev_close_many+0xd0/0x138
<4>[ 7620.364821][<ffffffbfa33be6e8>] vlan_device_event+0x4a8/0x6a0 [8021q]
<4>[ 7620.364824][<ffffffc00023f83c>] notifier_call_chain+0x5c/0xa0
<4>[ 7620.364827][<ffffffc00023f9e0>] raw_notifier_call_chain+0x20/0x28
<4>[ 7620.364830][<ffffffc0005cbab4>] call_netdevice_notifiers_info+0x4c/0x80
<4>[ 7620.364833][<ffffffc0005d5148>] __dev_notify_flags+0xb8/0xe0
<4>[ 7620.364836][<ffffffc0005d5994>] dev_change_flags+0x54/0x68
<4>[ 7620.364840][<ffffffc00064a620>] devinet_ioctl+0x650/0x700
<4>[ 7620.364843][<ffffffc00064bea4>] inet_ioctl+0xa4/0xc8
<4>[ 7620.364847][<ffffffc0005b1094>] sock_do_ioctl+0x44/0x88
<4>[ 7620.364850][<ffffffc0005b1a3c>] sock_ioctl+0x23c/0x308
<4>[ 7620.364854][<ffffffc000393bc4>] do_vfs_ioctl+0x48c/0x620
<4>[ 7620.364857][<ffffffc000393dec>] SyS_ioctl+0x94/0xa8

=================================cut here========================================

It looks that the notifier_call_chain has to deal with too much handler, and will not
feed the watchdog until finish the work, and the notifier_call_chain would call the
ipv6_dev_notf several times and hold the cpu for a long time, so add cond_resched()
in the ipv6_dev_notf in order to schedule out in the network notifiers to avoid softlocking
to fix this problem.

Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 net/ipv6/addrconf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f555f4f..e294a3d 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3284,6 +3284,12 @@ restart:
 		spin_unlock_bh(&addrconf_hash_lock);
 	}
 
+	/*
+	 * It is safe here to schedule out to avoid softlocking if preempt
+	 * is disabled.
+	 */
+	cond_resched();
+
 	write_lock_bh(&idev->lock);
 
 	addrconf_del_rs_timer(idev);
-- 
1.9.0
