From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 6/9] bonding: make bond_3ad_unbind_slave() use bond_for_each_slave()
Date: Fri, 27 Sep 2013 16:12:02 +0200
Message-ID: <1380291125-5671-7-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835Ab3I0OL7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:59 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert all instances of

for (agg = __get_first_agg(); agg; agg = __get_next_port)

to the standard bond_for_each_slave().

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 6cd1444..6dbb84d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1936,6 +1936,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
 	struct port *port, *prev_port, *temp_port;
 	struct aggregator *aggregator, *new_aggregator, *temp_aggregator;
 	int select_new_active_agg = 0;
+	struct bonding *bond = slave->bond;
+	struct slave *slave_iter;
+	struct list_head *iter;
 
 	// find the aggregator related to this slave
 	aggregator = &(SLAVE_AD_INFO(slave).aggregator);
@@ -1965,14 +1968,16 @@ void bond_3ad_unbind_slave(struct slave *slave)
 		// reason to search for new aggregator, and that we will find one
 		if ((aggregator->lag_ports != port) || (aggregator->lag_ports->next_port_in_aggregator)) {
 			// find new aggregator for the related port(s)
-			new_aggregator = __get_first_agg(port);
-			for (; new_aggregator; new_aggregator = __get_next_agg(new_aggregator)) {
+			bond_for_each_slave(bond, slave_iter, iter) {
+				new_aggregator = &(SLAVE_AD_INFO(slave_iter).aggregator);
 				// if the new aggregator is empty, or it is connected to our port only
 				if (!new_aggregator->lag_ports
 				    || ((new_aggregator->lag_ports == port)
 					&& !new_aggregator->lag_ports->next_port_in_aggregator))
 					break;
 			}
+			if (!slave_iter)
+				new_aggregator = NULL;
 			// if new aggregator found, copy the aggregator's parameters
 			// and connect the related lag_ports to the new aggregator
 			if ((new_aggregator) && ((!new_aggregator->lag_ports) || ((new_aggregator->lag_ports == port) && !new_aggregator->lag_ports->next_port_in_aggregator))) {
@@ -2032,8 +2037,8 @@ void bond_3ad_unbind_slave(struct slave *slave)
 
 	pr_debug("Unbinding port %d\n", port->actor_port_number);
 	// find the aggregator that this port is connected to
-	temp_aggregator = __get_first_agg(port);
-	for (; temp_aggregator; temp_aggregator = __get_next_agg(temp_aggregator)) {
+	bond_for_each_slave(bond, slave_iter, iter) {
+		temp_aggregator = &(SLAVE_AD_INFO(slave_iter).aggregator);
 		prev_port = NULL;
 		// search the port in the aggregator's related ports
 		for (temp_port = temp_aggregator->lag_ports; temp_port;
-- 
1.8.4
