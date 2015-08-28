From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net v2] bonding: fix bond_poll_controller bh_enable warning
Date: Fri, 28 Aug 2015 10:22:20 -0700
Message-ID: <1440782540-7876-1-git-send-email-razor@blackwall.org>
References: <658DEBCA-6BE2-4388-AFE8-58C6A71029AC@cumulusnetworks.com>
Cc: 13806511171@163.com, shemminger@linux-foundation.org,
	maheshb@google.com, j.vosburgh@gmail.com, vfalico@gmail.com,
	gospo@cumulusnetworks.com, davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35165 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752265AbbH1RXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 13:23:33 -0400
Received: by pacdd16 with SMTP id dd16so68788650pac.2
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 10:23:32 -0700 (PDT)
In-Reply-To: <658DEBCA-6BE2-4388-AFE8-58C6A71029AC@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

The problem is rcu_read_unlock_bh() which triggers a warning when irqs are
disabled.
ndo_poll_controller can run with bh enabled, disabled or irqs disabled
so check if that is the case and acquire rcu_read_lock_bh only when not
running with disabled irqs. The only potential problem is with
netpoll_send_udp() currently because it can call find_skb() which may
invoke ndo_poll_controller.
We're okay w.r.t to rcu_bh when irqs are disabled so no need to acquire it.
Use the standard rcu_read_lock/unlock to make the non-bh rcu_dereference
happy.
To clarify currently the only user of netpoll_send_udp() is netconsole and
calls it with irqs disabled so we're fine.

[   98.502922] bond0: making interface eth1 the new active one
[   98.503039] ------------[ cut here ]------------
[   98.503039] WARNING: CPU: 0 PID: 1744 at kernel/softirq.c:150 __local_bh_enable_ip+0x96/0xc0()
[   98.503039] Modules linked in: bonding(OE) rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache netconsole ppdev joydev parport_pc serio_raw parport i2c_piix4 video acpi_cpufreq nfsd auth_rpcgss nfs_acl lockd grace sunrpc virtio_net e1000 ata_generic pcnet32 mii virtio_pci virtio_ring virtio pata_acpi
[   98.503039] CPU: 0 PID: 1744 Comm: ifenslave Tainted: G           OE   4.2.0-rc7+ #56
[   98.503039] Hardware name: innotek GmbH VirtualBox/VirtualBox, BIOS VirtualBox 12/01/2006
[   98.503039]  0000000000000000 00000000e96ba230 ffff880020c236b8 ffffffff8183f105
[   98.503039]  0000000000000000 0000000000000000 ffff880020c236f8 ffffffff810a9496
[   98.503039]  ffff88002ea99e08 0000000000000200 ffffffffa02a8e06 ffff88002ea99e08
[   98.503039] Call Trace:
[   98.503039]  [<ffffffff8183f105>] dump_stack+0x4c/0x65
[   98.503039]  [<ffffffff810a9496>] warn_slowpath_common+0x86/0xc0
[   98.503039]  [<ffffffffa02a8e06>] ? bond_poll_controller+0x146/0x250 [bonding]
[   98.503039]  [<ffffffff810a95ca>] warn_slowpath_null+0x1a/0x20
[   98.503039]  [<ffffffff810ae376>] __local_bh_enable_ip+0x96/0xc0
[   98.503039]  [<ffffffffa02a8e2f>] bond_poll_controller+0x16f/0x250 [bonding]
[   98.503039]  [<ffffffffa02a8cf3>] ? bond_poll_controller+0x33/0x250 [bonding]
[   98.503039]  [<ffffffff810feaed>] ? trace_hardirqs_off+0xd/0x10
[   98.503039]  [<ffffffff81848afb>] ? _raw_spin_unlock_irqrestore+0x5b/0x60
[   98.503039]  [<ffffffff816ec48e>] netpoll_poll_dev+0x6e/0x350
[   98.503039]  [<ffffffff816eb977>] ? netpoll_start_xmit+0x137/0x1d0
[   98.503039]  [<ffffffff816b2e8b>] ? __alloc_skb+0x5b/0x210
[   98.503039]  [<ffffffff816ec89d>] netpoll_send_skb_on_dev+0x12d/0x2a0
[   98.503039]  [<ffffffff816eccde>] netpoll_send_udp+0x2ce/0x430
[   98.503039]  [<ffffffffa0190850>] write_msg+0xb0/0xf0 [netconsole]
[   98.503039]  [<ffffffff81116b63>] call_console_drivers.constprop.25+0x133/0x260
[   98.503039]  [<ffffffff81117934>] console_unlock+0x2f4/0x580
[   98.503039]  [<ffffffff81117ea5>] ? vprintk_emit+0x2e5/0x630
[   98.503039]  [<ffffffff81117ee5>] vprintk_emit+0x325/0x630
[   98.503039]  [<ffffffff81118379>] vprintk_default+0x29/0x40
[   98.503039]  [<ffffffff8183de4f>] printk+0x55/0x6b
[   98.503039]  [<ffffffff816c754c>] __netdev_printk+0x16c/0x260
[   98.503039]  [<ffffffff816c7a12>] netdev_info+0x62/0x80
[   98.503039]  [<ffffffffa02ab464>] bond_change_active_slave+0x134/0x6a0 [bonding]
[   98.503039]  [<ffffffffa02aba95>] bond_select_active_slave+0xc5/0x310 [bonding]
[   98.503039]  [<ffffffffa02aeb78>] bond_enslave+0x1088/0x10c0 [bonding]
[   98.503039]  [<ffffffffa02af46b>] bond_do_ioctl+0x37b/0x400 [bonding]
[   98.503039]  [<ffffffff81101d8d>] ? trace_hardirqs_on+0xd/0x10
[   98.503039]  [<ffffffff816dc437>] ? rtnl_lock+0x17/0x20
[   98.503039]  [<ffffffff816e5fd1>] dev_ifsioc+0x331/0x3e0
[   98.503039]  [<ffffffff816e62dc>] dev_ioctl+0xec/0x6c0
[   98.503039]  [<ffffffff816a6c6a>] sock_do_ioctl+0x4a/0x60
[   98.503039]  [<ffffffff816a7300>] sock_ioctl+0x1c0/0x250
[   98.503039]  [<ffffffff81271bfe>] do_vfs_ioctl+0x2ee/0x540
[   98.503039]  [<ffffffff810fd943>] ? up_read+0x23/0x40
[   98.503039]  [<ffffffff81070993>] ? __do_page_fault+0x1d3/0x420
[   98.503039]  [<ffffffff8127e246>] ? __fget_light+0x66/0x90
[   98.503039]  [<ffffffff81271ec9>] SyS_ioctl+0x79/0x90
[   98.503039]  [<ffffffff8184936e>] entry_SYSCALL_64_fastpath+0x12/0x76
[   98.503039] ---[ end trace 00cfa804b0670051 ]---

Fixes: 616f45416ca0 ("bonding: implement bond_poll_controller()")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
v2: make sure we're either running with irqs disabled or have rcu_bh
Making it this way to protect against future potential users of
netpoll_send_udp() which may not disable interrupts, if we agree that
it can't be called without disabling interrupts then I can resubmit this
patch without the conditional rcu_bh and possibly add a warn to catch any
future offenders that use it without disabling interrupts.

 drivers/net/bonding/bond_main.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a98dd4f1b0e3..3197a2180978 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -974,12 +974,17 @@ static void bond_poll_controller(struct net_device *bond_dev)
 	struct ad_info ad_info;
 	struct netpoll_info *ni;
 	const struct net_device_ops *ops;
+	bool rcubh_taken = false;
 
 	if (BOND_MODE(bond) == BOND_MODE_8023AD)
 		if (bond_3ad_get_active_agg_info(bond, &ad_info))
 			return;
 
-	rcu_read_lock_bh();
+	if (!in_irq() && !irqs_disabled()) {
+		rcu_read_lock_bh();
+		rcubh_taken = true;
+	}
+	rcu_read_lock();
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		ops = slave->dev->netdev_ops;
 		if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
@@ -1000,7 +1005,9 @@ static void bond_poll_controller(struct net_device *bond_dev)
 		ops->ndo_poll_controller(slave->dev);
 		up(&ni->dev_lock);
 	}
-	rcu_read_unlock_bh();
+	rcu_read_unlock();
+	if (rcubh_taken)
+		rcu_read_unlock_bh();
 }
 
 static void bond_netpoll_cleanup(struct net_device *bond_dev)
-- 
2.4.3
