From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 3/5] bonding: remove bond read lock for bond_loadbalance_arp_mon()
Date: Thu, 24 Oct 2013 11:09:17 +0800
Message-ID: <52688F5D.1010400@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:39660 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719Ab3JXDMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:12:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond slave list may change when the monitor is running, the slave list is no longer
protected by bond->lock, only protected by rtnl lock(), so we has 3 way to modify it:
1.add bond_master_upper_dev_link() and bond_upper_dev_unlink() in bond->lock, but it is unsafe
to call call_netdevice_notifiers() in write lock.
2.remove unused bond->lock for monitor function, only use the exist rtnl lock().
3.use rcu_read_lock() to protect it, of course, it will transform bond_for_each_slave to
bond_for_each_slave_rcu() and performance is better, but in slow path, it is ignored.
so I remove the bond->lock and add the rtnl lock to protect the whole monitor function.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ba90f45..149f4b9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2433,10 +2433,13 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	struct list_head *iter;
 	int do_failover = 0;
 
-	read_lock(&bond->lock);
+	if (!rtnl_trylock())
+		goto re_arm;
 
-	if (!bond_has_slaves(bond))
+	if (!bond_has_slaves(bond)) {
+		rtnl_unlock();
 		goto re_arm;
+	}
 
 	oldcurrent = bond->curr_active_slave;
 	/* see if any of the previous devices are up now (i.e. they have
@@ -2518,13 +2521,12 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
 	}
+	rtnl_unlock();
 
 re_arm:
 	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work,
 				   msecs_to_jiffies(bond->params.arp_interval));
-
-	read_unlock(&bond->lock);
 }
 
 /*
-- 
1.8.2.1
