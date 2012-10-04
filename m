From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] bonding: set qdisc_tx_busylock to avoid LOCKDEP splat
Date: Thu, 04 Oct 2012 11:05:26 +0200
Message-ID: <1349341526.16011.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40825 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750698Ab2JDJFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 05:05:32 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so138310bkc.19
        for <netdev@vger.kernel.org>; Thu, 04 Oct 2012 02:05:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If a qdisc is installed on a bonding device, its possible to get
following lockdep splat under stress :

 =============================================
 [ INFO: possible recursive locking detected ]
 3.6.0+ #211 Not tainted
 ---------------------------------------------
 ping/4876 is trying to acquire lock:
  (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, at: [<ffffffff8157a191>] dev_queue_xmit+0xe1/0x830
 
 but task is already holding lock:
  (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, at: [<ffffffff8157a191>] dev_queue_xmit+0xe1/0x830
 
 other info that might help us debug this:
  Possible unsafe locking scenario:
 
        CPU0
        ----
   lock(dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);
   lock(dev->qdisc_tx_busylock ?: &qdisc_tx_busylock);
 
  *** DEADLOCK ***
 
  May be due to missing lock nesting notation
 
 6 locks held by ping/4876:
  #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff815e5030>] raw_sendmsg+0x600/0xc30
  #1:  (rcu_read_lock_bh){.+....}, at: [<ffffffff815ba4bd>] ip_finish_output+0x12d/0x870
  #2:  (rcu_read_lock_bh){.+....}, at: [<ffffffff8157a0b0>] dev_queue_xmit+0x0/0x830
  #3:  (dev->qdisc_tx_busylock ?: &qdisc_tx_busylock){+.-...}, at: [<ffffffff8157a191>] dev_queue_xmit+0xe1/0x830
  #4:  (&bond->lock){++.?..}, at: [<ffffffffa02128c1>] bond_start_xmit+0x31/0x4b0 [bonding]
  #5:  (rcu_read_lock_bh){.+....}, at: [<ffffffff8157a0b0>] dev_queue_xmit+0x0/0x830
 
 stack backtrace:
 Pid: 4876, comm: ping Not tainted 3.6.0+ #211
 Call Trace:
  [<ffffffff810a0145>] __lock_acquire+0x715/0x1b80
  [<ffffffff810a256b>] ? mark_held_locks+0x9b/0x100
  [<ffffffff810a1bf2>] lock_acquire+0x92/0x1d0
  [<ffffffff8157a191>] ? dev_queue_xmit+0xe1/0x830
  [<ffffffff81726b7c>] _raw_spin_lock+0x3c/0x50
  [<ffffffff8157a191>] ? dev_queue_xmit+0xe1/0x830
  [<ffffffff8106264d>] ? rcu_read_lock_bh_held+0x5d/0x90
  [<ffffffff8157a191>] dev_queue_xmit+0xe1/0x830
  [<ffffffff8157a0b0>] ? netdev_pick_tx+0x570/0x570
  [<ffffffffa0212a6a>] bond_start_xmit+0x1da/0x4b0 [bonding]
  [<ffffffff815796d0>] dev_hard_start_xmit+0x240/0x6b0
  [<ffffffff81597c6e>] sch_direct_xmit+0xfe/0x2a0
  [<ffffffff8157a249>] dev_queue_xmit+0x199/0x830
  [<ffffffff8157a0b0>] ? netdev_pick_tx+0x570/0x570
  [<ffffffff815ba96f>] ip_finish_output+0x5df/0x870
  [<ffffffff815ba4bd>] ? ip_finish_output+0x12d/0x870
  [<ffffffff815bb964>] ip_output+0x54/0xf0
  [<ffffffff815bad48>] ip_local_out+0x28/0x90
  [<ffffffff815bc444>] ip_send_skb+0x14/0x50
  [<ffffffff815bc4b2>] ip_push_pending_frames+0x32/0x40
  [<ffffffff815e536a>] raw_sendmsg+0x93a/0xc30
  [<ffffffff8128d570>] ? selinux_file_send_sigiotask+0x1f0/0x1f0
  [<ffffffff8109ddb4>] ? __lock_is_held+0x54/0x80
  [<ffffffff815f6730>] ? inet_recvmsg+0x220/0x220
  [<ffffffff8109ddb4>] ? __lock_is_held+0x54/0x80
  [<ffffffff815f6855>] inet_sendmsg+0x125/0x240
  [<ffffffff815f6730>] ? inet_recvmsg+0x220/0x220
  [<ffffffff8155cddb>] sock_sendmsg+0xab/0xe0
  [<ffffffff810a1650>] ? lock_release_non_nested+0xa0/0x2e0
  [<ffffffff810a1650>] ? lock_release_non_nested+0xa0/0x2e0
  [<ffffffff8155d18c>] __sys_sendmsg+0x37c/0x390
  [<ffffffff81195b2a>] ? fsnotify+0x2ca/0x7e0
  [<ffffffff811958e8>] ? fsnotify+0x88/0x7e0
  [<ffffffff81361f36>] ? put_ldisc+0x56/0xd0
  [<ffffffff8116f98a>] ? fget_light+0x3da/0x510
  [<ffffffff8155f6c4>] sys_sendmsg+0x44/0x80
  [<ffffffff8172fc22>] system_call_fastpath+0x16/0x1b

Avoid this problem using a distinct lock_class_key for bonding
devices.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/bonding/bond_main.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 7858c58..b721902 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4826,6 +4826,7 @@ static int bond_check_params(struct bond_params *params)
 
 static struct lock_class_key bonding_netdev_xmit_lock_key;
 static struct lock_class_key bonding_netdev_addr_lock_key;
+static struct lock_class_key bonding_tx_busylock_key;
 
 static void bond_set_lockdep_class_one(struct net_device *dev,
 				       struct netdev_queue *txq,
@@ -4840,6 +4841,7 @@ static void bond_set_lockdep_class(struct net_device *dev)
 	lockdep_set_class(&dev->addr_list_lock,
 			  &bonding_netdev_addr_lock_key);
 	netdev_for_each_tx_queue(dev, bond_set_lockdep_class_one, NULL);
+	dev->qdisc_tx_busylock = &bonding_tx_busylock_key;
 }
 
 /*
