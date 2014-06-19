From: roy.qing.li@gmail.com
Subject: [PATCH] cxgb4: disable BH when hold the adap_rcu_lock lock
Date: Thu, 19 Jun 2014 17:06:50 +0800
Message-ID: <1403168810-9001-1-git-send-email-roy.qing.li@gmail.com>
References: <53A0DDF5.80103@candelatech.com>
Cc: greearb@candelatech.com, leedom@chelsio.com, hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:61757 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757613AbaFSJGl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 05:06:41 -0400
Received: by mail-pa0-f44.google.com with SMTP id rd3so1719613pab.3
        for <netdev@vger.kernel.org>; Thu, 19 Jun 2014 02:06:40 -0700 (PDT)
In-Reply-To: <53A0DDF5.80103@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

This lock is used in BH enabled condition and softirq context, so need to
disable BH to avoid the dead lock:
	=================================
	[ INFO: inconsistent lock state ]
	3.14.7+ #24 Tainted: G         C O
	---------------------------------
	inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
	radvd/3794 [HC0[0]:SC1[1]:HE1:SE0] takes:
	 (adap_rcu_lock){+.?...}, at: [<ffffffffa09989ea>] clip_add+0x2c/0x116 [cxgb4]
	{SOFTIRQ-ON-W} state was registered at:
	  [<ffffffff810fca81>] __lock_acquire+0x34a/0xe48
	  [<ffffffff810fd98b>] lock_acquire+0x82/0x9d
	  [<ffffffff815d6ff8>] _raw_spin_lock+0x34/0x43
	  [<ffffffffa09989ea>] clip_add+0x2c/0x116 [cxgb4]
	  [<ffffffffa0998beb>] cxgb4_inet6addr_handler+0x117/0x12c [cxgb4]
	  [<ffffffff815da98b>] notifier_call_chain+0x32/0x5c
	  [<ffffffff815da9f9>] __atomic_notifier_call_chain+0x44/0x6e
	  [<ffffffff815daa32>] atomic_notifier_call_chain+0xf/0x11
	  [<ffffffff815b1356>] inet6addr_notifier_call_chain+0x16/0x18
	  [<ffffffffa01f72e5>] ipv6_add_addr+0x404/0x46e [ipv6]
	  [<ffffffffa01f8df0>] addrconf_add_linklocal+0x5f/0x95 [ipv6]
	  [<ffffffffa01fc3e9>] addrconf_notify+0x632/0x841 [ipv6]
	  [<ffffffff815da98b>] notifier_call_chain+0x32/0x5c
	  [<ffffffff810e09a1>] __raw_notifier_call_chain+0x9/0xb
	  [<ffffffff810e09b2>] raw_notifier_call_chain+0xf/0x11
	  [<ffffffff8151b3b7>] call_netdevice_notifiers_info+0x4e/0x56
	  [<ffffffff8151b3d0>] call_netdevice_notifiers+0x11/0x13
	  [<ffffffff8151c0a6>] netdev_state_change+0x1f/0x38
	  [<ffffffff8152f004>] linkwatch_do_dev+0x3b/0x49
	  [<ffffffff8152f184>] __linkwatch_run_queue+0x10b/0x144
	  [<ffffffff8152f1dd>] linkwatch_event+0x20/0x27
	  [<ffffffff810d7bc0>] process_one_work+0x1cb/0x2ee
	  [<ffffffff810d7e3b>] worker_thread+0x12e/0x1fc
	  [<ffffffff810dd391>] kthread+0xc4/0xcc
	  [<ffffffff815dc48c>] ret_from_fork+0x7c/0xb0
	irq event stamp: 3388
	hardirqs last  enabled at (3388): [<ffffffff810c6c85>] __local_bh_enable_ip+0xaa/0xd9
	hardirqs last disabled at (3387): [<ffffffff810c6c2d>] __local_bh_enable_ip+0x52/0xd9
	softirqs last  enabled at (3288): [<ffffffffa01f1d5b>] rcu_read_unlock_bh+0x0/0x2f [ipv6]
	softirqs last disabled at (3289): [<ffffffff815ddafc>] do_softirq_own_stack+0x1c/0x30

	other info that might help us debug this:
	 Possible unsafe locking scenario:

	       CPU0
	       ----
	  lock(adap_rcu_lock);
	  <Interrupt>
	    lock(adap_rcu_lock);

	 *** DEADLOCK ***

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
Cc: Casey Leedom <leedom@chelsio.com>
Cc: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 2f8d6b9..f39e6db 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3960,9 +3960,9 @@ static void attach_ulds(struct adapter *adap)
 {
 	unsigned int i;
 
-	spin_lock(&adap_rcu_lock);
+	spin_lock_bh(&adap_rcu_lock);
 	list_add_tail_rcu(&adap->rcu_node, &adap_rcu_list);
-	spin_unlock(&adap_rcu_lock);
+	spin_unlock_bh(&adap_rcu_lock);
 
 	mutex_lock(&uld_mutex);
 	list_add_tail(&adap->list_node, &adapter_list);
@@ -3990,9 +3990,9 @@ static void detach_ulds(struct adapter *adap)
 	}
 	mutex_unlock(&uld_mutex);
 
-	spin_lock(&adap_rcu_lock);
+	spin_lock_bh(&adap_rcu_lock);
 	list_del_rcu(&adap->rcu_node);
-	spin_unlock(&adap_rcu_lock);
+	spin_unlock_bh(&adap_rcu_lock);
 }
 
 static void notify_ulds(struct adapter *adap, enum cxgb4_state new_state)
@@ -4064,14 +4064,14 @@ static int cxgb4_netdev(struct net_device *netdev)
 	struct adapter *adap;
 	int i;
 
-	spin_lock(&adap_rcu_lock);
+	spin_lock_bh(&adap_rcu_lock);
 	list_for_each_entry_rcu(adap, &adap_rcu_list, rcu_node)
 		for (i = 0; i < MAX_NPORTS; i++)
 			if (adap->port[i] == netdev) {
-				spin_unlock(&adap_rcu_lock);
+				spin_unlock_bh(&adap_rcu_lock);
 				return 1;
 			}
-	spin_unlock(&adap_rcu_lock);
+	spin_unlock_bh(&adap_rcu_lock);
 	return 0;
 }
 
-- 
1.7.10.4
