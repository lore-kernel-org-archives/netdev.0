From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v6 4/11] bonding: rebuild the lock use for bond_loadbalance_arp_mon()
Date: Fri, 13 Dec 2013 10:19:50 +0800
Message-ID: <52AA6EC6.9000402@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:28466 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797Ab3LMCV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 21:21:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_loadbalance_arp_mon() use the bond lock to protect the
bond slave list, it is no effect, so I could use RTNL or RCU to
replace it, considering the performance impact, the RCU is more
better here, so the bond lock replace with the RCU.

The bond_select_active_slave() need RTNL and curr_slave_lock
together, but there is no RTNL lock here, so add a rtnl_rtylock.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ab55429..1f5e709 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2415,12 +2415,12 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	struct list_head *iter;
 	int do_failover = 0;
 
-	read_lock(&bond->lock);
-
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
-	oldcurrent = bond->curr_active_slave;
+	rcu_read_lock();
+
+	oldcurrent = ACCESS_ONCE(bond->curr_active_slave);
 	/* see if any of the previous devices are up now (i.e. they have
 	 * xmt and rcv traffic). the curr_active_slave does not come into
 	 * the picture unless it is null. also, slave->jiffies is not needed
@@ -2429,7 +2429,7 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 	 * TODO: what about up/down delay in arp mode? it wasn't here before
 	 *       so it can wait
 	 */
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		unsigned long trans_start = dev_trans_start(slave->dev);
 
 		if (slave->link != BOND_LINK_UP) {
@@ -2491,7 +2491,14 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 			bond_arp_send_all(bond, slave);
 	}
 
+	rcu_read_unlock();
+
 	if (do_failover) {
+		/* the bond_select_active_slave must hold RTNL
+		 * and curr_slave_lock for write.
+		 */
+		if (!rtnl_trylock())
+			goto re_arm;
 		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 
@@ -2499,14 +2506,13 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 		write_unlock_bh(&bond->curr_slave_lock);
 		unblock_netpoll_tx();
+		rtnl_unlock();
 	}
 
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
