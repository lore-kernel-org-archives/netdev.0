From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 5/9] bonding: make ad_agg_selection_logic() use bond_for_each_slave()
Date: Fri, 27 Sep 2013 16:12:01 +0200
Message-ID: <1380291125-5671-6-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62660 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752706Ab3I0OL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:57 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert all instances of

for (agg = __get_first_agg(); agg; agg = __get_next_port)

to the standard bond_for_each_slave(). Also, remove the useless checks
before calling bond_3ad_set_carrier() - if we have something NULL - it
would fire long ago, in __get_first/next_port(), per example.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1109d82..6cd1444 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1484,19 +1484,23 @@ static int agg_device_up(const struct aggregator *agg)
 static void ad_agg_selection_logic(struct aggregator *agg)
 {
 	struct aggregator *best, *active, *origin;
+	struct bonding *bond = agg->slave->bond;
+	struct list_head *iter;
+	struct slave *slave;
 	struct port *port;
 
 	origin = agg;
 	active = __get_active_agg(agg);
 	best = (active && agg_device_up(active)) ? active : NULL;
 
-	do {
+	bond_for_each_slave(bond, slave, iter) {
+		agg = &(SLAVE_AD_INFO(slave).aggregator);
+
 		agg->is_active = 0;
 
 		if (agg->num_of_ports && agg_device_up(agg))
 			best = ad_agg_selection_test(best, agg);
-
-	} while ((agg = __get_next_agg(agg)));
+	}
 
 	if (best &&
 	    __get_agg_selection_mode(best->lag_ports) == BOND_AD_STABLE) {
@@ -1534,8 +1538,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 			 best->lag_ports, best->slave,
 			 best->slave ? best->slave->dev->name : "NULL");
 
-		for (agg = __get_first_agg(best->lag_ports); agg;
-		     agg = __get_next_agg(agg)) {
+		bond_for_each_slave(bond, slave, iter) {
+			agg = &(SLAVE_AD_INFO(slave).aggregator);
 
 			pr_debug("Agg=%d; P=%d; a k=%d; p k=%d; Ind=%d; Act=%d\n",
 				 agg->aggregator_identifier, agg->num_of_ports,
@@ -1583,13 +1587,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		}
 	}
 
-	if (origin->slave) {
-		struct bonding *bond;
-
-		bond = bond_get_bond_by_slave(origin->slave);
-		if (bond)
-			bond_3ad_set_carrier(bond);
-	}
+	bond_3ad_set_carrier(bond);
 }
 
 /**
-- 
1.8.4
