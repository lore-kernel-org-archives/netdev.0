From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 5/5] bonding: remove bond read lock for bond_3ad_state_machine_handler()
Date: Thu, 24 Oct 2013 11:09:31 +0800
Message-ID: <52688F6B.2000004@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:8015 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753746Ab3JXDMy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:12:54 -0400
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
 drivers/net/bonding/bond_3ad.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 187b1b7..d6fe00b 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2068,8 +2068,10 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct slave *slave;
 	struct port *port;
 
-	read_lock(&bond->lock);
-
+	if (!rtnl_trylock()) {
+		queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
+		return;
+	}
 	//check if there are any slaves
 	if (!bond_has_slaves(bond))
 		goto re_arm;
@@ -2122,9 +2124,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 re_arm:
+	rtnl_unlock();
 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
-
-	read_unlock(&bond->lock);
 }
 
 /**
-- 
1.8.2.1
