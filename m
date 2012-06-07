From: Ani Sinha <ani@aristanetworks.com>
Subject: [PATCH] fix kernel crash in the macvlan driver
Date: Thu, 7 Jun 2012 11:45:58 -0700 (PDT)
Message-ID: <alpine.OSX.2.00.1206071137360.86561@animac.local>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Biederman <ebiederm@xmission.com>,
	Francesco Ruggeri <fruggeri@aristanetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:38588 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab2FGSp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 14:45:59 -0400
Received: by dady13 with SMTP id y13so1254659dad.19
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 11:45:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello folks :

We noticed a consistently reproducable kernel crash in the macvlan driver
when we were running our test script. I believe I have found the reason
for the crash and a patch that fixes it. I am attaching the patch for your
comments and opinions.

Cheers,
Ani



commit cd28ce3cb624ddaaf97935c1f34d44bb13ffb786
Author: Anirban Sinha <ani@aristanetworks.com>
Date:   Thu Jun 7 11:21:02 2012 -0700

    macvlan : The patch d5cd92448fded12c91f7574e49747c5f7d975a8d introduced reference
    counting for macvlan_port. This patch fixes an issue where the reference
    counts were being decremented incorrectly from macvlan_uninit() and not from
    macvlan_dellink(). This was causing the kernel crash shown below :

    BUG: unable to handle kernel paging request at 0000000100000000
    IP: [<ffffffffa031f8e5>] macvlan_addr_busy+0x58/0x8d [macvlan]
    PGD 3a2aa067 PUD 0
    Oops: 0000 [#1] SMP
    last sysfs file: /sys/devices/LNXSYSTM:00/device:00/PNP0C0A:00/power_supply/BAT1/energy_full
    CPU 0
    Modules linked in: macvlan rfcomm sco bnep l2cap sunrpc ipt_REJECT iptable_filter ip6t_REJECT xt_tcpudp

    Pid: 2490, comm: ip Not tainted 2.6.38.8-705892.2012aniArora.7.fc14.x86_64 #1
    RIP: 0010:[<ffffffffa031f8e5>]  [<ffffffffa031f8e5>] macvlan_addr_busy+0x58/0x8d [macvlan]
    RSP: 0018:ffff880037d2b698  EFLAGS: 00010296
    RAX: 0000000100000000 RBX: ffff88003bf54000 RCX: 0000000000000000
    RDX: 0000111111111102 RSI: 0000000000000092 RDI: 0000000000000246
    RBP: ffff880037d2b6a8 R08: 0000000000000040 R09: ffffffff81a73f18
    R10: ffffffff81e03a20 R11: 0000000000000020 R12: ffff88003c8e33d0
    R13: ffff880037ecd000 R14: 00000000fffffff0 R15: 0000000000000001
    FS:  0000000000000000(0000) GS:ffff88003e200000(0063) knlGS:00000000f75d26c0
    CS:  0010 DS: 002b ES: 002b CR0: 0000000080050033
    CR2: 0000000100000000 CR3: 00000000377e7000 CR4: 00000000000006f0
    DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
    DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
    Process ip (pid: 2490, threadinfo ffff880037d2a000, task ffff88003d1206c0)
    Stack:
     ffff88003d031000 ffff88003d031680 ffff880037d2b6d8 ffffffffa031fbcc
     ffff88003d031000 ffffffffa03211c0 ffff88003d031078 0000000000000000
     ffff880037d2b708 ffffffff81345cf7 ffff88003d031000 0000000000001003
    Call Trace:
     [<ffffffffa031fbcc>] macvlan_open+0x7e/0x116 [macvlan]
     [<ffffffff81345cf7>] __dev_open+0x90/0xc7
     [<ffffffff81345f26>] __dev_change_flags+0xa8/0x12c
     [<ffffffff81346021>] dev_change_flags+0x1c/0x52
     [<ffffffff8134fce1>] do_setlink+0x2b4/0x67d
     [<ffffffff813bc85f>] ? inet6_fill_link_af+0x1a/0x22
     [<ffffffff8134f6bf>] ? rtnl_fill_ifinfo+0x99f/0xa7d
     [<ffffffff81350d02>] rtnl_newlink+0x247/0x40d
     [<ffffffff81350b7a>] ? rtnl_newlink+0xbf/0x40d
     [<ffffffff81337ced>] ? sock_rmalloc+0x2e/0x90
     [<ffffffff810dc46c>] ? arch_local_irq_save+0x16/0x1c
     [<ffffffff810685fe>] ? arch_local_irq_save+0x18/0x1e
     [<ffffffff813508dc>] rtnetlink_rcv_msg+0x1e6/0x1fc
     [<ffffffff810af70a>] ? get_page_from_freelist+0x4dd/0x68d
     [<ffffffff813506f6>] ? rtnetlink_rcv_msg+0x0/0x1fc
     [<ffffffff81364239>] netlink_rcv_skb+0x40/0x8b
     [<ffffffff813502c7>] rtnetlink_rcv+0x21/0x28
     [<ffffffff81363d27>] netlink_unicast+0xec/0x155
     [<ffffffff81364041>] netlink_sendmsg+0x2b1/0x2cf
     [<ffffffff81332ec2>] ? __sock_recvmsg+0x75/0x84
     [<ffffffff81332d70>] __sock_sendmsg+0x66/0x72
     [<ffffffff81333521>] sock_sendmsg+0xa3/0xbc
     [<ffffffff810b25da>] ? lru_cache_add_lru+0x3c/0x3e
     [<ffffffff810cc1e3>] ? page_add_new_anon_rmap+0x5b/0x6d
     [<ffffffff810c17cb>] ? set_pte_at+0x9/0xd
     [<ffffffff810c2f31>] ? do_wp_page+0x496/0x541
     [<ffffffff81333ec0>] ? move_addr_to_kernel+0x44/0x49
     [<ffffffff813585a4>] ? verify_compat_iovec+0x6d/0xb9
     [<ffffffff81334cac>] sys_sendmsg+0x230/0x2ae
     [<ffffffff810c1965>] ? pmd_offset+0x14/0x3b
     [<ffffffff810c4c0a>] ? handle_mm_fault+0x13a/0x14f
     [<ffffffff81334756>] ? sys_sendto+0x13f/0x16c
     [<ffffffff81334d76>] ? sys_recvmsg+0x4c/0x5b
     [<ffffffff81358deb>] compat_sys_sendmsg+0xf/0x11
     [<ffffffff81359005>] compat_sys_socketcall+0x14f/0x186
     [<ffffffff8102c2b0>] sysenter_dispatch+0x7/0x2e
    Code: 0e e1 48 8b 03 4c 89 e2 48 c7 c7 6c 10 32 a0 48 8b b0 80 02 00 00 31 c0 e8 f1 17 0e e1 48 8b 03 49 8b 14 24 48 8b 80 80 02 00 00 <48> 33 10 b8 01 00 00 00 48 c1 e2 10 74 22 48 c7 c7 93 10 32 a0

    Signed-off-by: Anirban Sinha <ani@aristanetworks.com>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 66a9bfe..d880bc8 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -481,7 +481,6 @@ static void macvlan_uninit(struct net_device *dev)

 	free_percpu(vlan->pcpu_stats);

-	port->count -= 1;
 	if (!port->count)
 		macvlan_port_destroy(port->dev);
 }
@@ -795,7 +794,9 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 void macvlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
+	struct macvlan_port *port = vlan->port;

+	port->count -= 1;
 	list_del(&vlan->list);
 	unregister_netdevice_queue(dev, head);
 }
