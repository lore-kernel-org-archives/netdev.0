From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 1/9] bonding: remove __get_next_port()
Date: Fri, 27 Sep 2013 16:11:57 +0200
Message-ID: <1380291125-5671-2-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31698 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751993Ab3I0OLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:48 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently this function is only used in constructs like

for (port = __get_first_port(bond); port; port = __get_next_port(port))

which is basicly the same as

bond_for_each_slave(bond, slave, iter) {
	port = &(SLAVE_AD_INFO(slave).port);

but a more time consuming.

Remove the function and convert the users to bond_for_each_slave().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 34 +++++++++-------------------------
 1 file changed, 9 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 2715ea8..c1535f8 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -149,28 +149,6 @@ static inline struct port *__get_first_port(struct bonding *bond)
 }
 
 /**
- * __get_next_port - get the next port in the bond
- * @port: the port we're looking at
- *
- * Return the port of the slave that is next in line of @port's slave in the
- * bond, or %NULL if it can't be found.
- */
-static inline struct port *__get_next_port(struct port *port)
-{
-	struct bonding *bond = __get_bond_by_port(port);
-	struct slave *slave = port->slave, *slave_next;
-
-	// If there's no bond for this port, or this is the last slave
-	if (bond == NULL)
-		return NULL;
-	slave_next = bond_next_slave(bond, slave);
-	if (!slave_next || bond_is_first_slave(bond, slave_next))
-		return NULL;
-
-	return &(SLAVE_AD_INFO(slave_next).port);
-}
-
-/**
  * __get_first_agg - get the first aggregator in the bond
  * @bond: the bond we're looking at
  *
@@ -2113,8 +2091,10 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 					    ad_work.work);
-	struct port *port;
 	struct aggregator *aggregator;
+	struct list_head *iter;
+	struct slave *slave;
+	struct port *port;
 
 	read_lock(&bond->lock);
 
@@ -2139,7 +2119,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 	// for each port run the state machines
-	for (port = __get_first_port(bond); port; port = __get_next_port(port)) {
+	bond_for_each_slave(bond, slave, iter) {
+		port = &(SLAVE_AD_INFO(slave).port);
 		if (!port->slave) {
 			pr_warning("%s: Warning: Found an uninitialized port\n",
 				   bond->dev->name);
@@ -2384,9 +2365,12 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 				   struct ad_info *ad_info)
 {
 	struct aggregator *aggregator = NULL;
+	struct list_head *iter;
+	struct slave *slave;
 	struct port *port;
 
-	for (port = __get_first_port(bond); port; port = __get_next_port(port)) {
+	bond_for_each_slave(bond, slave, iter) {
+		port = &(SLAVE_AD_INFO(slave).port);
 		if (port->aggregator && port->aggregator->is_active) {
 			aggregator = port->aggregator;
 			break;
-- 
1.8.4
