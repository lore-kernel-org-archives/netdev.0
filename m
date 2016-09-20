From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: DSA: Suspicious RCU usage (via rtnl_bridge_getlink)
Date: Tue, 20 Sep 2016 11:26:12 +0100
Message-ID: <20160920102611.GO1041@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: netdev@vger.kernel.org,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:43593 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752295AbcITK0W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 06:26:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Issuing "bridge vlan show" on clearfog provokes a "suspicious RCU usage"
warning from the kernel (see below).

As it's illegal to schedule while holding the RCU read lock, there's the
possibility for this happening much earlier in the call sequence -
mv88e6xxx_port_vlan_dump() takes a mutex, and if that mutex were already
held, we'd schedule at that point.  The RCU read lock was taken by
rtnl_bridge_getlink().

It looks horrible to fix - mvmdio.c as well as DSA locking are involved.

I'm wondering why might_sleep() doesn't detect this illegal RCU state,
rather than detecting it when we actually schedule - Paul?

===============================
[ INFO: suspicious RCU usage. ]
4.7.0+ #98 Not tainted
-------------------------------
include/linux/rcupdate.h:554 Illegal context switch in RCU read-side critical section!
other info that might help us debug this:

rcu_scheduler_active = 1, debug_locks = 0
5 locks held by bridge/31769:
 #0:  (rtnl_mutex){+.+.+.}, at: [<c058f508>] netlink_dump+0x20/0x268
 #1:  (rcu_read_lock){......}, at: [<c0571674>] rtnl_bridge_getlink+0x4c/0x25c
 #2:  (&ps->smi_mutex){+.+.+.}, at: [<c042ee58>] mv88e6xxx_port_vlan_dump+0x50/0x13c
 #3:  (&bus->mdio_lock/2){+.+...}, at: [<c042a6c4>] mdiobus_read_nested+0x4c/0x78
 #4:  (&dev->lock){+.+...}, at: [<c043a064>] orion_mdio_read+0x28/0xa4
stack backtrace:
CPU: 0 PID: 31769 Comm: bridge Not tainted 4.7.0+ #98
Hardware name: Marvell Armada 380/385 (Device Tree)
Backtrace:
[<c0013488>] (dump_backtrace) from [<c00137d0>] (show_stack+0x18/0x1c)
 r6:60070013 r5:ffffffff r4:00000000 r3:dc8ba500
[<c00137b8>] (show_stack) from [<c02c7b00>] (dump_stack+0xa4/0xdc)
[<c02c7a5c>] (dump_stack) from [<c0076864>] (lockdep_rcu_suspicious+0xbc/0x11c)
 r6:0000022a r5:c0822fec r4:ecd78c80 r3:ecd78c80
[<c00767a8>] (lockdep_rcu_suspicious) from [<c06bc4c0>] (__schedule+0x348/0x698)
 r7:00000000 r6:e9cc38e8 r5:c0981976 r4:ecd78c80
[<c06bc178>] (__schedule) from [<c06bc940>] (schedule+0x3c/0xa0)
 r10:c093d4c8 r9:00000000 r8:00002710 r7:00000000 r6:0000d6d8 r5:00000000
 r4:0000afc8
[<c06bc904>] (schedule) from [<c06c1130>] (schedule_hrtimeout_range_clock+0xe8/0x168)
[<c06c1048>] (schedule_hrtimeout_range_clock) from [<c06c11d4>] (schedule_hrtimeout_range+0x24/0x2c)
 r10:c093d100 r9:00000000 r8:00000000 r7:e9cc3a30 r6:00000001 r5:ee860c30
 r4:ee860be0
[<c06c11b0>] (schedule_hrtimeout_range) from [<c06c0b58>] (usleep_range+0x54/0x5c)
[<c06c0b04>] (usleep_range) from [<c0439f9c>] (orion_mdio_wait_ready+0x114/0x14c)
[<c0439e88>] (orion_mdio_wait_ready) from [<c043a098>] (orion_mdio_read+0x5c/0xa4)
 r10:00000000 r9:00000000 r8:04040000 r7:04040000 r6:00000000 r5:ee860800
 r4:ee860be0
[<c043a03c>] (orion_mdio_read) from [<c042a6d8>] (mdiobus_read_nested+0x60/0x78)
 r8:edc53810 r7:00000000 r6:00000004 r5:ee86082c r4:ee860800 r3:c043a03c
[<c042a678>] (mdiobus_read_nested) from [<c042d1cc>] (mv88e6xxx_reg_wait_ready+0x28/0x50)
 r7:00000007 r6:ee860800 r5:00000004 r4:00000010
[<c042d1a4>] (mv88e6xxx_reg_wait_ready) from [<c042d688>] (__mv88e6xxx_reg_read+0x24/0x98)
 r6:00000010 r5:ee860800 r4:00000004 r3:00000007
[<c042d664>] (__mv88e6xxx_reg_read) from [<c042d850>] (_mv88e6xxx_reg_read+0x38/0x60)
 r7:00000000 r6:e9cc3b38 r5:00000010 r4:edc53810
[<c042d818>] (_mv88e6xxx_reg_read) from [<c042e240>] (_mv88e6xxx_port_pvid+0x28/0x8c)
 r5:00000010 r4:edc53810
[<c042e218>] (_mv88e6xxx_port_pvid) from [<c042ee6c>] (mv88e6xxx_port_vlan_dump+0x64/0x13c)
 r8:c06b48e8 r7:edc5381c r6:e9cc3bc4 r5:c093d4c8 r4:edc53810 r3:e9cc3b38
[<c042ee08>] (mv88e6xxx_port_vlan_dump) from [<c0685ab4>] (dsa_slave_port_obj_dump+0x54/0x70)
 r10:00007c19 r9:00000000 r8:00000002 r7:e9cc3bc4 r6:c06b48e8 r5:c07237e0
 r4:e9cc3bc4
[<c0685a60>] (dsa_slave_port_obj_dump) from [<c06b50b8>] (switchdev_port_obj_dump+0x50/0xa8)
 r4:ef0e0800 r3:c0685a60
[<c06b5068>] (switchdev_port_obj_dump) from [<c06b51f4>] (switchdev_port_vlan_fill+0x6c/0x98)
 r7:ea96c0cc r6:eaa7a180 r5:ea96c074 r4:00000002
[<c06b5188>] (switchdev_port_vlan_fill) from [<c0573f80>] (ndo_dflt_bridge_getlink+0x28c/0x484)
 r4:ef0e0800
[<c0573cf4>] (ndo_dflt_bridge_getlink) from [<c06b4c64>] (switchdev_port_bridge_getlink+0xc8/0xec)
 r10:57e108bb r9:edefbb18 r8:eaa7a180 r7:00007c19 r6:57e108bb r5:c093d4c8
 r4:ef0e0800
[<c06b4b9c>] (switchdev_port_bridge_getlink) from [<c0571744>] (rtnl_bridge_getlink+0x11c/0x25c)
 r8:eaa7a180 r7:c09770f0 r6:c07236e4 r5:ef0e0800 r4:00000001
[<c0571628>] (rtnl_bridge_getlink) from [<c058f5d8>] (netlink_dump+0xf0/0x268)
 r10:c0571628 r9:00000000 r8:00004000 r7:edefbb18 r6:00000f40 r5:eaa7a180
 r4:edefb800
[<c058f4e8>] (netlink_dump) from [<c05904ec>] (__netlink_dump_start+0x13c/0x198)
 r8:edefbb18 r7:edc7c200 r6:e9cc3d90 r5:eaa7a300 r4:edefb800
[<c05903b0>] (__netlink_dump_start) from [<c0575b74>] (rtnetlink_rcv_msg+0x118/0x1f8)
 r8:c0977000 r7:00000007 r6:eaa7a300 r5:00000818 r4:edc7c200 r3:e9cc3d90
[<c0575a5c>] (rtnetlink_rcv_msg) from [<c0592ad8>] (netlink_rcv_skb+0xb4/0xc8)
 r10:00000000 r8:e9cc3e0c r7:eaa7a300 r6:c0575a5c r5:eaa7a300 r4:edc7c200
[<c0592a24>] (netlink_rcv_skb) from [<c0573c08>] (rtnetlink_rcv+0x24/0x2c)
 r6:00000028 r5:edefb800 r4:eaa7a300 r3:000041de
[<c0573be4>] (rtnetlink_rcv) from [<c0592484>] (netlink_unicast+0x1a0/0x204)
 r4:ef120800 r3:c0573be4
[<c05922e4>] (netlink_unicast) from [<c05928dc>] (netlink_sendmsg+0x348/0x364)
 r10:eaa7a300 r8:00000000 r7:00000000 r6:00000028 r5:edefb800 r4:e9cc3eb8
[<c0592594>] (netlink_sendmsg) from [<c053deb0>] (sock_sendmsg+0x1c/0x2c)
 r10:00000000 r9:e9cc2000 r8:00000000 r7:00000000 r6:c093d4c8 r5:eed4efc0
 r4:00000000
[<c053de94>] (sock_sendmsg) from [<c053f2f4>] (SyS_sendto+0xc4/0x108)
[<c053f230>] (SyS_sendto) from [<c053f358>] (SyS_send+0x20/0x28)
 r10:00000000 r8:c0010004 r7:00000121 r6:00000008 r5:57e108bb r4:00000000
[<c053f338>] (SyS_send) from [<c000fe60>] (ret_fast_syscall+0x0/0x1c)

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
