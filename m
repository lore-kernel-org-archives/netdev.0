From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 2/3] bonding: fix __get_first_agg RCU usage
Date: Fri, 10 Jan 2014 10:18:42 +0100
Message-ID: <1389345523-5497-3-git-send-email-vfalico@redhat.com>
References: <1389345523-5497-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>, dingtianhong@huawei.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751216AbaAJJXC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 04:23:02 -0500
In-Reply-To: <1389345523-5497-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the RCU read lock usage is just wrong - it gets the slave struct
under RCU and continues to use it when RCU lock is released.

However, it's still safe to do this cause we didn't need the
rcu_read_lock() initially - all of the __get_first_agg() callers are either
holding RCU read lock or the RTNL lock, so that we can't sync while in it.

So, remove the useless rcu locking and add a comment.

Fixes: be79bd048 ("bonding: add RCU for bond_3ad_state_machine_handler()")
CC: dingtianhong@huawei.com
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2 -> v3:
    Use the rcu primitives.
    
    v1 -> v2:
    Don't use RCU primitives as we can hold RTNL.

 drivers/net/bonding/bond_3ad.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 9ff55eb..27dac0e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -143,6 +143,7 @@ static inline struct bonding *__get_bond_by_port(struct port *port)
  *
  * Return the aggregator of the first slave in @bond, or %NULL if it can't be
  * found.
+ * The caller must hold RCU lock.
  */
 static inline struct aggregator *__get_first_agg(struct port *port)
 {
@@ -153,9 +154,7 @@ static inline struct aggregator *__get_first_agg(struct port *port)
 	if (bond == NULL)
 		return NULL;
 
-	rcu_read_lock();
 	first_slave = bond_first_slave_rcu(bond);
-	rcu_read_unlock();
 
 	return first_slave ? &(SLAVE_AD_INFO(first_slave).aggregator) : NULL;
 }
-- 
1.8.4
