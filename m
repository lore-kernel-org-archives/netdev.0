From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 4/9] bonding: rebuild the lock use for bond_loadbalance_arp_mon()
Date: Wed, 6 Nov 2013 14:52:51 +0800
Message-ID: <5279E743.4050102@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:17275 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750802Ab3KFG6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:58:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_loadbalance_arp_mon() use the bond lock to protect the
bond slave list, it is no effect, so I could use RTNL or RCU to
replace it, the bond_select_active_slave() need RTNL, so whatever
the RCU use, the RTNL is need to add, so I choose the RTNL to
protect the whole monitor, I still remove the curr_slave_lock for
it, because RTNL is enough here.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 98171eb..b875dff 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2376,10 +2376,13 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
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
@@ -2454,20 +2457,15 @@ void bond_loadbalance_arp_mon(struct work_struct *work)
 
 	if (do_failover) {
 		block_netpoll_tx();
-		write_lock_bh(&bond->curr_slave_lock);
-
 		bond_select_active_slave(bond);
-
-		write_unlock_bh(&bond->curr_slave_lock);
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
