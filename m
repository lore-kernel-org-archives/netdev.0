From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 3/9] bonding: make ad_port_selection_logic() use bond_for_each_slave()
Date: Fri, 27 Sep 2013 16:11:59 +0200
Message-ID: <1380291125-5671-4-git-send-email-vfalico@redhat.com>
References: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Cc: nikolay@redhat.com, bhutchings@solarflare.com,
	Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45527 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318Ab3I0OLv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 10:11:51 -0400
In-Reply-To: <1380291125-5671-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, ad_port_selection_logic() uses

for (aggregator = __get_first_agg(port); aggregator;
     aggregator = __get_next_agg(aggregator)) {

construct, however it's suboptimal, difficult to read and understand.

Change it to a standard bond_for_each_slave(), so that we won't need
__get_first/next_agg() and have it more readable.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 0f86d2b..8b64ed4 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1239,12 +1239,17 @@ static void ad_port_selection_logic(struct port *port)
 {
 	struct aggregator *aggregator, *free_aggregator = NULL, *temp_aggregator;
 	struct port *last_port = NULL, *curr_port;
+	struct list_head *iter;
+	struct bonding *bond;
+	struct slave *slave;
 	int found = 0;
 
 	// if the port is already Selected, do nothing
 	if (port->sm_vars & AD_PORT_SELECTED)
 		return;
 
+	bond = __get_bond_by_port(port);
+
 	// if the port is connected to other aggregator, detach it
 	if (port->aggregator) {
 		// detach the port from its former aggregator
@@ -1285,8 +1290,8 @@ static void ad_port_selection_logic(struct port *port)
 		}
 	}
 	// search on all aggregators for a suitable aggregator for this port
-	for (aggregator = __get_first_agg(port); aggregator;
-	     aggregator = __get_next_agg(aggregator)) {
+	bond_for_each_slave(bond, slave, iter) {
+		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
 
 		// keep a free aggregator for later use(if needed)
 		if (!aggregator->lag_ports) {
-- 
1.8.4
