From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v4 net-next 2/3] bonding: fix __get_first_agg RCU usage
Date: Fri, 10 Jan 2014 11:59:44 +0100
Message-ID: <1389351585-19615-3-git-send-email-vfalico@redhat.com>
References: <1389351585-19615-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>, dingtianhong@huawei.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34611 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756705AbaAJLEE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 06:04:04 -0500
In-Reply-To: <1389351585-19615-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the RCU read lock usage is just wrong - it gets the slave struct
under RCU and continues to use it when RCU lock is released.

However, it's still safe to do this cause we didn't need the
rcu_read_lock() initially - all of the __get_first_agg() callers are either
holding RCU read lock or the RTNL lock, so that we can't sync while in it.

Fixes: be79bd048 ("bonding: add RCU for bond_3ad_state_machine_handler()")
CC: dingtianhong@huawei.com
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v3 -> v4: add rcu_read_lock() to silence lockdep.
    
    v2 -> v3:
    Use the rcu primitives.
    
    v1 -> v2:
    Don't use RCU primitives as we can hold RTNL.

 drivers/net/bonding/bond_3ad.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index da0d7c5..b49f421 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -143,11 +143,13 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
  *
  * Return the aggregator of the first slave in @bond, or %NULL if it can't be
  * found.
+ * The caller must hold RCU or RTNL lock.
  */
 static inline struct aggregator *__get_first_agg(struct port *port)
 {
 	struct bonding *bond = __get_bond_by_port(port);
 	struct slave *first_slave;
+	struct aggregator *agg;
 
 	/* If there's no bond for this port, or bond has no slaves */
 	if (bond == NULL)
@@ -155,9 +157,10 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 
 	rcu_read_lock();
 	first_slave = bond_first_slave_rcu(bond);
+	agg = first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
 	rcu_read_unlock();
 
-	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
+	return agg;
 }
 
 /**
-- 
1.8.4
