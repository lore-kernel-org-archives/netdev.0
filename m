From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: [regression] 6ae459bd skbuff: Fix skb checksum flag on skb pull
Date: Thu, 01 Oct 2015 09:55:48 +0200
Message-ID: <1443686148.2726.6.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pravin B Shelar <pshelar@nicira.com>,
	LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:38173 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755755AbbJAHzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2015 03:55:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings network wizards,

$subject broke git-daemon here.

homer:/usr/local/src/kernel/linux-3.x.git # time strace -vvvfFtT git remote update 2> /strace.out
Fetching origin

real    2m9.164s
user    0m1.616s
sys     0m0.316s

2 minutes of thumb twiddling should have been..

homer:/usr/local/src/kernel/linux-3.x.git # time git remote update
Fetching origin

real    0m0.213s
user    0m0.156s
sys     0m0.036s

Daemon runs as user git like so, with all repositories living in ~git:
/usr/lib/git/git-daemon --syslog --detach --reuseaddr --user=git --group=daemon --pid-file=/var/run/git-daemon.pid --export-all --user-path

Bisected and post bisect verified by applying/removing a revert.

Log:

6ae459bdaaeebc632b16e54dcbabb490c6931d61 is the first bad commit
commit 6ae459bdaaeebc632b16e54dcbabb490c6931d61
Author: Pravin B Shelar <pshelar@nicira.com>
Date:   Tue Sep 22 12:57:53 2015 -0700

    skbuff: Fix skb checksum flag on skb pull
    
    VXLAN device can receive skb with checksum partial. But the checksum
    offset could be in outer header which is pulled on receive. This results
    in negative checksum offset for the skb. Such skb can cause the assert
    failure in skb_checksum_help(). Following patch fixes the bug by setting
    checksum-none while pulling outer header.
    
    Following is the kernel panic msg from old kernel hitting the bug.
    
    ------------[ cut here ]------------
    kernel BUG at net/core/dev.c:1906!
    RIP: 0010:[<ffffffff81518034>] skb_checksum_help+0x144/0x150
    Call Trace:
    <IRQ>
    [<ffffffffa0164c28>] queue_userspace_packet+0x408/0x470 [openvswitch]
    [<ffffffffa016614d>] ovs_dp_upcall+0x5d/0x60 [openvswitch]
    [<ffffffffa0166236>] ovs_dp_process_packet_with_key+0xe6/0x100 [openvswitch]
    [<ffffffffa016629b>] ovs_dp_process_received_packet+0x4b/0x80 [openvswitch]
    [<ffffffffa016c51a>] ovs_vport_receive+0x2a/0x30 [openvswitch]
    [<ffffffffa0171383>] vxlan_rcv+0x53/0x60 [openvswitch]
    [<ffffffffa01734cb>] vxlan_udp_encap_recv+0x8b/0xf0 [openvswitch]
    [<ffffffff8157addc>] udp_queue_rcv_skb+0x2dc/0x3b0
    [<ffffffff8157b56f>] __udp4_lib_rcv+0x1cf/0x6c0
    [<ffffffff8157ba7a>] udp_rcv+0x1a/0x20
    [<ffffffff8154fdbd>] ip_local_deliver_finish+0xdd/0x280
    [<ffffffff81550128>] ip_local_deliver+0x88/0x90
    [<ffffffff8154fa7d>] ip_rcv_finish+0x10d/0x370
    [<ffffffff81550365>] ip_rcv+0x235/0x300
    [<ffffffff8151ba1d>] __netif_receive_skb+0x55d/0x620
    [<ffffffff8151c360>] netif_receive_skb+0x80/0x90
    [<ffffffff81459935>] virtnet_poll+0x555/0x6f0
    [<ffffffff8151cd04>] net_rx_action+0x134/0x290
    [<ffffffff810683d8>] __do_softirq+0xa8/0x210
    [<ffffffff8162fe6c>] call_softirq+0x1c/0x30
    [<ffffffff810161a5>] do_softirq+0x65/0xa0
    [<ffffffff810687be>] irq_exit+0x8e/0xb0
    [<ffffffff81630733>] do_IRQ+0x63/0xe0
    [<ffffffff81625f2e>] common_interrupt+0x6e/0x6e
    
    Reported-by: Anupam Chanda <achanda@vmware.com>
    Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
    Acked-by: Tom Herbert <tom@herbertland.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 3bb5c605650664362514aa1834029f478478057c f016d3e96119e2d67e582da593ca2fbfac6347d2 M	include

git bisect start
# good: [1f93e4a96c9109378204c147b3eec0d0e8100fde] Linux 4.3-rc2
git bisect good 1f93e4a96c9109378204c147b3eec0d0e8100fde
# bad: [dd36d7393d6310b0c1adefb22fba79c3cf8a577c] Merge git://www.linux-watchdog.org/linux-watchdog
git bisect bad dd36d7393d6310b0c1adefb22fba79c3cf8a577c
# good: [d4a748a10e50d95992ae67677f1a1a13e2d6ed47] Merge branch 'for-4.3-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup
git bisect good d4a748a10e50d95992ae67677f1a1a13e2d6ed47
# bad: [fb740f9bab3b3c049d6207b148e45de05163b6e5] Merge tag 'tty-4.3-rc3' of git://git.kernel.org/pub/scm/linux/kernel/git/gregkh/tty
git bisect bad fb740f9bab3b3c049d6207b148e45de05163b6e5
# good: [23eedbc2435ddd226717603c4f3c8efec7bdbb4d] ch9200: Convert to use module_usb_driver
git bisect good 23eedbc2435ddd226717603c4f3c8efec7bdbb4d
# bad: [7322967bc1bd97ac9c49ecea19e5a1f681ca27ee] phy: add proper phy struct device refcounting
git bisect bad 7322967bc1bd97ac9c49ecea19e5a1f681ca27ee
# good: [41b976414c88016e2c9d9b2f6667ee67a998d388] 8139cp: Dump contents of descriptor ring on TX timeout
git bisect good 41b976414c88016e2c9d9b2f6667ee67a998d388
# bad: [d682d2bdc30650a5c7ce9908ab83ab674b658744] bnx2x: byte swap rss_key to comply to Toeplitz specs
git bisect bad d682d2bdc30650a5c7ce9908ab83ab674b658744
# bad: [d5b8d6404395641987db76e28334cae4cef771ae] net: gianfar: remove misuse of IRQF_NO_SUSPEND flag
git bisect bad d5b8d6404395641987db76e28334cae4cef771ae
# good: [da314c9923fed553a007785a901fd395b7eb6c19] netlink: Replace rhash_portid with bound
git bisect good da314c9923fed553a007785a901fd395b7eb6c19
# bad: [6ae459bdaaeebc632b16e54dcbabb490c6931d61] skbuff: Fix skb checksum flag on skb pull
git bisect bad 6ae459bdaaeebc632b16e54dcbabb490c6931d61
# first bad commit: [6ae459bdaaeebc632b16e54dcbabb490c6931d61] skbuff: Fix skb checksum flag on skb pull
