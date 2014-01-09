From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 3/3] bonding: fix __get_active_agg() RCU logic
Date: Thu,  9 Jan 2014 11:48:30 +0100
Message-ID: <1389264510-22141-4-git-send-email-vfalico@redhat.com>
References: <1389264510-22141-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>, dingtianhong@huawei.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29498 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbaAIKxx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 05:53:53 -0500
In-Reply-To: <1389264510-22141-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the implementation is meaningless - once again, we take the
slave structure and use it after we've exited RCU critical section.

Fix this by removing the rcu_read_lock() from __get_active_agg(), and
ensuring that all its callers are holding either RCU or RTNL lock.

Fixes: be79bd048 ("bonding: add RCU for bond_3ad_state_machine_handler()")
CC: dingtianhong@huawei.com
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 70e72d7..587fd7e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -674,6 +674,8 @@ static u32 __get_agg_bandwidth(struct aggregator *aggregator)
 /**
  * __get_active_agg - get the current active aggregator
  * @aggregator: the aggregator we're looking at
+ *
+ * Caller must hold either RCU or RTNL lock.
  */
 static struct aggregator *__get_active_agg(struct aggregator *aggregator)
 {
@@ -681,13 +683,9 @@ static struct aggregator *__get_active_agg(struct aggregator *aggregator)
 	struct list_head *iter;
 	struct slave *slave;
 
-	rcu_read_lock();
 	bond_for_each_slave_rcu(bond, slave, iter)
-		if (SLAVE_AD_INFO(slave).aggregator.is_active) {
-			rcu_read_unlock();
+		if (SLAVE_AD_INFO(slave).aggregator.is_active)
 			return &(SLAVE_AD_INFO(slave).aggregator);
-		}
-	rcu_read_unlock();
 
 	return NULL;
 }
@@ -1495,11 +1493,11 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 	struct slave *slave;
 	struct port *port;
 
+	rcu_read_lock();
 	origin = agg;
 	active = __get_active_agg(agg);
 	best = (active && agg_device_up(active)) ? active : NULL;
 
-	rcu_read_lock();
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		agg = &(SLAVE_AD_INFO(slave).aggregator);
 
-- 
1.8.4
