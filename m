From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/5] bonding: remove bond read lock for bond_loadbalance_arp_mon()
Date: Mon, 21 Oct 2013 16:58:59 +0800
Message-ID: <5264ECD3.8040300@huawei.com>
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
Received: from szxga02-in.huawei.com ([119.145.14.65]:8932 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754844Ab3JUJFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 05:05:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond now only attach and detach slave in rtnl lock,
so read_lock for bond could not protect slave list,
replace bond read lock with rtnl lock for bond_loadbalance_arp_mon().

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
