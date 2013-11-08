From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 7/10] bonding: rebuild the lock use for bond_3ad_state_machine_handler()
Date: Fri, 8 Nov 2013 10:08:08 +0800
Message-ID: <527C4788.9090508@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:26164 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756417Ab3KHCId (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:08:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_3ad_state_machine_handler() use the bond lock to protect
the bond slave list and slave port, so as the before patch said,
I remove bond lock and replace with RCU.

The nots in the function is still too old, clean up the nots.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 21 ++++++++++-----------
 1 file changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 187b1b7..09edccf61 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2068,18 +2068,18 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct slave *slave;
 	struct port *port;
 
-	read_lock(&bond->lock);
+	rcu_read_lock();
 
-	//check if there are any slaves
-	if (!bond_has_slaves(bond))
+	/* check if there are any slaves */
+	if (!bond_has_slaves_rcu(bond))
 		goto re_arm;
 
-	// check if agg_select_timer timer after initialize is timed out
+	/* check if agg_select_timer timer after initialize is timed out */
 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
-		slave = bond_first_slave(bond);
+		slave = bond_first_slave_rcu(bond);
 		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
 
-		// select the active aggregator for the bond
+		/* select the active aggregator for the bond */
 		if (port) {
 			if (!port->slave) {
 				pr_warning("%s: Warning: bond's first port is uninitialized\n",
@@ -2093,8 +2093,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		bond_3ad_set_carrier(bond);
 	}
 
-	// for each port run the state machines
-	bond_for_each_slave(bond, slave, iter) {
+	/* for each port run the state machines */
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave).port);
 		if (!port->slave) {
 			pr_warning("%s: Warning: Found an uninitialized port\n",
@@ -2114,7 +2114,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		ad_mux_machine(port);
 		ad_tx_machine(port);
 
-		// turn off the BEGIN bit, since we already handled it
+		/* turn off the BEGIN bit, since we already handled it */
 		if (port->sm_vars & AD_PORT_BEGIN)
 			port->sm_vars &= ~AD_PORT_BEGIN;
 
@@ -2122,9 +2122,8 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	}
 
 re_arm:
+	rcu_read_unlock();
 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
-
-	read_unlock(&bond->lock);
 }
 
 /**
-- 
1.8.2.1
