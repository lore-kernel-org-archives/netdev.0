From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [BUG] Adding vlan to DSA port causes lockdep splat
Date: Sun, 24 Jan 2016 16:21:40 +0000
Message-ID: <20160124162140.GF10826@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60547 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644AbcAXQVu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 11:21:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding a vlan to a DSA switch port netdev causes the following lockdep
splat on v4.4.  This was caused by:

# vconfig add lan5 2048
# ip link set lan5.2048 up

=============================================
[ INFO: possible recursive locking detected ]
4.4.0+ #41 Not tainted
---------------------------------------------
ip/1437 is trying to acquire lock:
 (_xmit_ETHER/1){+.....}, at: [<c0512190>] dev_mc_sync+0x4c/0x88

but task is already holding lock:
 (_xmit_ETHER/1){+.....}, at: [<c0512190>] dev_mc_sync+0x4c/0x88

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(_xmit_ETHER/1);
  lock(_xmit_ETHER/1);
 *** DEADLOCK ***

 May be due to missing lock nesting notation

3 locks held by ip/1437:
 #0:  (rtnl_mutex){+.+.+.}, at: [<c051c5e8>] rtnl_lock+0x1c/0x20
 #1:  (&vlan_netdev_addr_lock_key){+.....}, at: [<c050af38>] dev_set_rx_mode+0x1c/0x30
 #2:  (_xmit_ETHER/1){+.....}, at: [<c0512190>] dev_mc_sync+0x4c/0x88

stack backtrace:
CPU: 1 PID: 1437 Comm: ip Not tainted 4.4.0+ #41
Hardware name: Marvell Armada 380/385 (Device Tree)
Backtrace:
[<c00133b4>] (dump_backtrace) from [<c00136fc>] (show_stack+0x18/0x1c)
 r6:c1126954 r5:c0a23e10 r4:00000000 r3:dc8ba600
[<c00136e4>] (show_stack) from [<c028d5c0>] (dump_stack+0x7c/0x98)
[<c028d544>] (dump_stack) from [<c00712dc>] (__lock_acquire+0x138c/0x1b98)
 r4:c0a68580 r3:ef352280
[<c006ff50>] (__lock_acquire) from [<c0071e88>] (lock_acquire+0x74/0x94)
 r10:ee9a3f10 r9:ee9b7d80 r8:00000000 r7:00000001 r6:00000001 r5:600f0013
 r4:00000000
[<c0071e14>] (lock_acquire) from [<c0658d38>] (_raw_spin_lock_nested+0x30/0x40)
 r7:ec017030 r6:ef01d178 r5:ee8a2800 r4:ef01d178
[<c0658d08>] (_raw_spin_lock_nested) from [<c0512190>] (dev_mc_sync+0x4c/0x88)
 r4:ef01d000
[<c0512144>] (dev_mc_sync) from [<c061d860>] (dsa_slave_set_rx_mode+0x28/0x38)
 r6:00000000 r5:ef01d000 r4:ee8a2800 r3:ef3e0b50
[<c061d838>] (dsa_slave_set_rx_mode) from [<c050aee4>] (__dev_set_rx_mode+0x64/0x9c)
 r5:c06b2768 r4:ee8a2800
[<c050ae80>] (__dev_set_rx_mode) from [<c05121c0>] (dev_mc_sync+0x7c/0x88)
 r6:ee8a2978 r5:00000000 r4:ee8a2800 r3:00000002
[<c0512144>] (dev_mc_sync) from [<bf134c5c>] (vlan_dev_set_rx_mode+0x1c/0x2c [8021q])
 r6:00000000 r5:bf1366d4 r4:ec017000 r3:bf134c40
[<bf134c40>] (vlan_dev_set_rx_mode [8021q]) from [<c050aee4>] (__dev_set_rx_mode+0x64/0x9c)
 r4:ec017000 r3:bf134c40
[<c050ae80>] (__dev_set_rx_mode) from [<c050af40>] (dev_set_rx_mode+0x24/0x30)
 r6:bf1366d4 r5:ec017000 r4:ec017178 r3:ef352280
[<c050af1c>] (dev_set_rx_mode) from [<c050b010>] (__dev_open+0xc4/0x108)
 r5:00000000 r4:ec017000
[<c050af4c>] (__dev_open) from [<c050b280>] (__dev_change_flags+0x94/0x150)
 r7:00001002 r6:00000001 r5:00001003 r4:ec017000
[<c050b1ec>] (__dev_change_flags) from [<c050b374>] (dev_change_flags+0x20/0x50)
 r8:00000000 r7:bf1366d4 r6:00001002 r5:0000013c r4:ec017000 r3:00000001
[<c050b354>] (dev_change_flags) from [<c051d004>] (do_setlink+0x2c8/0x76c)
 r8:00000000 r7:bf1366d4 r6:eeac3be0 r5:00000000 r4:ec017000 r3:00000001
[<c051cd3c>] (do_setlink) from [<c051e708>] (rtnl_newlink+0x464/0x700)
 r10:00000000 r9:00000000 r8:00000000 r7:eeac3ba0 r6:ee9a3f00 r5:ec017000
 r4:00000000
[<c051e2a4>] (rtnl_newlink) from [<c051e208>] (rtnetlink_rcv_msg+0x158/0x1f4)
 r10:00000000 r9:00000000 r8:eeac3d84 r7:00000000 r6:ee9b7d80 r5:00000000
 r4:ee9a3f00
[<c051e0b0>] (rtnetlink_rcv_msg) from [<c0538018>] (netlink_rcv_skb+0xb4/0xc8)
 r8:eeac3d84 r7:ee9b7d80 r6:c051e0b0 r5:ee9b7d80 r4:ee9a3f00
[<c0537f64>] (netlink_rcv_skb) from [<c051c664>] (rtnetlink_rcv+0x24/0x2c)
 r6:eda45c00 r5:00000020 r4:ee9b7d80 r3:000026fb
[<c051c640>] (rtnetlink_rcv) from [<c05379c4>] (netlink_unicast+0x198/0x1fc)
 r4:ef10c000 r3:c051c640
[<c053782c>] (netlink_unicast) from [<c0537e1c>] (netlink_sendmsg+0x348/0x368)
 r10:ee9b7d80 r8:00000000 r7:00000000 r6:00000020 r5:eda45c00 r4:eeac3f4c
[<c0537ad4>] (netlink_sendmsg) from [<c04eb68c>] (sock_sendmsg+0x1c/0x2c)
 r10:00000000 r9:00000000 r8:ec8af8c0 r7:00000000 r6:c08b74c8 r5:00000000
 r4:eeac3f4c
[<c04eb670>] (sock_sendmsg) from [<c04ec4c4>] (___sys_sendmsg+0x240/0x254)
[<c04ec284>] (___sys_sendmsg) from [<c04ed170>] (__sys_sendmsg+0x44/0x70)
 r10:00000000 r9:eeac2000 r8:c000ff04 r7:00000128 r6:00000000 r5:ec8af8c0
 r4:bedad654
[<c04ed12c>] (__sys_sendmsg) from [<c04ed1ac>] (SyS_sendmsg+0x10/0x14)
 r6:bedad640 r5:00000010 r4:0000000c
[<c04ed19c>] (SyS_sendmsg) from [<c000fd60>] (ret_fast_syscall+0x0/0x1c)


The problem seems to be centered around:

dev_set_rx_mode ->
	__dev_set_rx_mode -> vlan_dev_set_rx_mode -> dev_mc_sync ->
	__dev_set_rx_mode -> dsa_slave_set_rx_mode -> dev_mc_sync

and the lock taken in dev_mc_sync().  On the face of it, it appears
that the vlan 'nest_level' was set to 1.

SINGLE_DEPTH_NESTING is set to 1, and netif_addr_lock_nested() does:

        int subclass = SINGLE_DEPTH_NESTING;

        if (dev->netdev_ops->ndo_get_lock_subclass)
                subclass = dev->netdev_ops->ndo_get_lock_subclass(dev);

        spin_lock_nested(&dev->addr_list_lock, subclass);

This has the effect that DSA (which does not provide
ndo_get_lock_subclass) uses a subclass of '1'.  However, when vlan
calculates its nesting:

        vlan->nest_level = dev_get_nest_level(real_dev, is_vlan_dev) + 1;

is_vlan_dev() will be false for "real_dev" (that being the DSA device).
However, dev_get_nest_level() returns zero if real_dev (or any of its
parents) are not a vlan device.  Hence, the vlan device is also taken
at a subclass of '1'.

As both locks are taken with the same class/subclass, lockdep thinks
this can deadlock.

I don't think implementing what vlan does in DSA will solve this,
because I think:

	dsa->nest_level = dev_get_nest_level(parent, is_dsa_dev) + 1;

will also return 1 - as it's parent device will be the ethernet
interface attached to the switch, which will be the root of the
network device tree.

I don't see a solution to this at present.

-- 
RMK's Patch system: http://www.arm.linux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
