From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: net_ratelimit() pr_warn()s in 802.3ad mode
Date: Sun, 16 Mar 2014 17:29:40 +0100
Message-ID: <1394987380-15765-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:7755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753281AbaCPQdy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Mar 2014 12:33:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only ratelimit the ones that might spam, omiting the ones from
enslave/deslave.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index dee2a84..f2700aa 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -1280,7 +1280,7 @@ static void ad_port_selection_logic(struct port *port)
 				break;
 			}
 		}
-		if (!curr_port) {
+		if (!curr_port && net_ratelimit()) {
 			/* meaning: the port was related to an aggregator
 			 * but was not on the aggregator port list
 			 */
@@ -1445,9 +1445,10 @@ static struct aggregator *ad_agg_selection_test(struct aggregator *best,
 		break;
 
 	default:
-		pr_warn("%s: Impossible agg select mode %d\n",
-			curr->slave->bond->dev->name,
-			__get_agg_selection_mode(curr->lag_ports));
+		if (net_ratelimit())
+			pr_warn("%s: Impossible agg select mode %d\n",
+				curr->slave->bond->dev->name,
+				__get_agg_selection_mode(curr->lag_ports));
 		break;
 	}
 
@@ -1559,7 +1560,7 @@ static void ad_agg_selection_logic(struct aggregator *agg)
 		}
 
 		/* check if any partner replys */
-		if (best->is_individual) {
+		if (best->is_individual && net_ratelimit()) {
 			pr_warn("%s: Warning: No 802.3ad response from the link partner for any adapters in the bond\n",
 				best->slave ?
 				best->slave->bond->dev->name : "NULL");
@@ -2080,7 +2081,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 
 		/* select the active aggregator for the bond */
 		if (port) {
-			if (!port->slave) {
+			if (!port->slave && net_ratelimit()) {
 				pr_warn("%s: Warning: bond's first port is uninitialized\n",
 					bond->dev->name);
 				goto re_arm;
@@ -2095,7 +2096,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	/* for each port run the state machines */
 	bond_for_each_slave_rcu(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave).port);
-		if (!port->slave) {
+		if (!port->slave && net_ratelimit()) {
 			pr_warn("%s: Warning: Found an uninitialized port\n",
 				bond->dev->name);
 			goto re_arm;
@@ -2157,7 +2158,7 @@ static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave,
 
 		port = &(SLAVE_AD_INFO(slave).port);
 
-		if (!port->slave) {
+		if (!port->slave && net_ratelimit()) {
 			pr_warn("%s: Warning: port of slave %s is uninitialized\n",
 				slave->dev->name, slave->bond->dev->name);
 			return ret;
-- 
1.8.4
