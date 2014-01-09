From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/3] bonding: fix bond_3ad_set_carrier() RCU usage
Date: Thu,  9 Jan 2014 11:48:28 +0100
Message-ID: <1389264510-22141-2-git-send-email-vfalico@redhat.com>
References: <1389264510-22141-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>, dingtianhong@huawei.com,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14128 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbaAIKxt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jan 2014 05:53:49 -0500
In-Reply-To: <1389264510-22141-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, its usage is just plainly wrong. It first gets a slave under
RCU, and, after releasing the RCU lock, continues to use it - whilst it can
be freed.

Fix this by ensuring that bond_3ad_set_carrier() is either under RCU read
lock or under the RTNL lock (bond_set_carrier() always holds it).

Fixes: be79bd048ab ("bonding: add RCU for bond_3ad_state_machine_handler()")
CC: dingtianhong@huawei.com
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 29db1ca..6330beb 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1597,9 +1597,9 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		}
 	}
 
-	rcu_read_unlock();
-
 	bond_3ad_set_carrier(bond);
+
+	rcu_read_unlock();
 }
 
 /**
@@ -2322,15 +2322,14 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
  *
  * Called by bond_set_carrier(). Return zero if carrier state does not
  * change, nonzero if it does.
+ * The caller must hold RCU read lock.
  */
 int bond_3ad_set_carrier(struct bonding *bond)
 {
 	struct aggregator *active;
 	struct slave *first_slave;
 
-	rcu_read_lock();
 	first_slave = bond_first_slave_rcu(bond);
-	rcu_read_unlock();
 	if (!first_slave)
 		return 0;
 	active = __get_active_agg(&(SLAVE_AD_INFO(first_slave).aggregator));
-- 
1.8.4
