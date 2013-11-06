From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 6/9] bonding: use RTNL instead of bond lock for bond_3ad_state_machine_handler()
Date: Wed, 6 Nov 2013 14:53:00 +0800
Message-ID: <5279E74C.8070403@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:13125 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab3KFGyH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:54:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_3ad_state_machine_handler() is a slow path, it use the bond
lock to protect the bond slave list and slave port, the slave list
could not be protect by bond lock anymore, so I need to use RTNL or
RCU instead of bond lock, but if I remove the bond lock, the
bond_3ad_state_machine_handler() may use the slave port when bond
releasing the slave, it will occur problems.

As the bond_3ad_unbind_slave() only protected by bond lock or RTNL,
so add RCU is not a good solution as it could not protect the slave
port, so RTNL is fit here.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 187b1b7..a4d190e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2068,18 +2068,19 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 	struct slave *slave;
 	struct port *port;
 
-	read_lock(&bond->lock);
+	if (!rtnl_trylock()) {
+		queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
+		return;
+	}
 
-	//check if there are any slaves
 	if (!bond_has_slaves(bond))
 		goto re_arm;
 
-	// check if agg_select_timer timer after initialize is timed out
+	/* check if agg_select_timer timer after initialize is timed out */
 	if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
 		slave = bond_first_slave(bond);
 		port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
 
-		// select the active aggregator for the bond
 		if (port) {
 			if (!port->slave) {
 				pr_warning("%s: Warning: bond's first port is uninitialized\n",
@@ -2093,7 +2094,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
 		bond_3ad_set_carrier(bond);
 	}
 
-	// for each port run the state machines
 	bond_for_each_slave(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave).port);
 		if (!port->slave) {
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
+	rtnl_unlock();
 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
-
-	read_unlock(&bond->lock);
 }
 
 /**
-- 
1.8.2.1
