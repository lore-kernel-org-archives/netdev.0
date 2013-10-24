From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 2/5] bonding: remove bond read lock for bond_alb_monitor()
Date: Thu, 24 Oct 2013 11:09:12 +0800
Message-ID: <52688F58.1040705@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:40956 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752826Ab3JXDNn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:13:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond slave list may change when the monitor is running, the slave list is no longer
protected by bond->lock, only protected by rtnl lock(), so we has 3 way to modify it:
1.add bond_master_upper_dev_link() and bond_upper_dev_unlink() in bond->lock, but it is unsafe
to call call_netdevice_notifiers() in write lock.
2.remove unused bond->lock for monitor function, only use the exist rtnl lock().
3.use rcu_read_lock() to protect it, of course, it will transform bond_for_each_slave to
bond_for_each_slave_rcu() and performance is better, but in slow path, it is ignored.
so I remove the bond->lock and move the rtnl lock to protect the whole monitor function.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_alb.c | 20 ++++----------------
 1 file changed, 4 insertions(+), 16 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 0287240..5d79f5e 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1495,11 +1495,13 @@ void bond_alb_monitor(struct work_struct *work)
 	struct list_head *iter;
 	struct slave *slave;
 
-	read_lock(&bond->lock);
+	if (!rtnl_trylock())
+		goto re_arm;
 
 	if (!bond_has_slaves(bond)) {
 		bond_info->tx_rebalance_counter = 0;
 		bond_info->lp_counter = 0;
+		rtnl_unlock();
 		goto re_arm;
 	}
 
@@ -1548,16 +1550,6 @@ void bond_alb_monitor(struct work_struct *work)
 		if (bond_info->primary_is_promisc &&
 		    (++bond_info->rlb_promisc_timeout_counter >= RLB_PROMISC_TIMEOUT)) {
 
-			/*
-			 * dev_set_promiscuity requires rtnl and
-			 * nothing else.  Avoid race with bond_close.
-			 */
-			read_unlock(&bond->lock);
-			if (!rtnl_trylock()) {
-				read_lock(&bond->lock);
-				goto re_arm;
-			}
-
 			bond_info->rlb_promisc_timeout_counter = 0;
 
 			/* If the primary was set to promiscuous mode
@@ -1566,9 +1558,6 @@ void bond_alb_monitor(struct work_struct *work)
 			 */
 			dev_set_promiscuity(bond->curr_active_slave->dev, -1);
 			bond_info->primary_is_promisc = 0;
-
-			rtnl_unlock();
-			read_lock(&bond->lock);
 		}
 
 		if (bond_info->rlb_rebalance) {
@@ -1591,10 +1580,9 @@ void bond_alb_monitor(struct work_struct *work)
 		}
 	}
 
+	rtnl_unlock();
 re_arm:
 	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks);
-
-	read_unlock(&bond->lock);
 }
 
 /* assumption: called before the slave is attached to the bond
-- 
1.8.2.1
