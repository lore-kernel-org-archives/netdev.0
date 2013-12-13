From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 3/3] bonding: protect port for bond_3ad_handle_link_change()
Date: Fri, 13 Dec 2013 17:29:29 +0800
Message-ID: <52AAD379.5010307@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:58468 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231Ab3LMJar (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 04:30:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_3ad_handle_link_change is called with RTNL only,
and the function will modify the port's information with
no further locking, it will not mutex against bond state
machine and incoming LACPDU which do not hold RTNL, So I
add __get_state_machine_lock to protect the port.

But it is not a critical bug, it exist since day one, and till
now it has never been hit and reported, because changes to
speed is very rare, and will not occur critical problem.

The comments in the function is very old, cleanup it and
add a new pr_debug to debug the port message.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index e851a67..4ced594 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2268,15 +2268,21 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 
 	port = &(SLAVE_AD_INFO(slave).port);
 
-	// if slave is null, the whole port is not initialized
+	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
 		pr_warning("Warning: %s: link status changed for uninitialized port on %s\n",
 			   slave->bond->dev->name, slave->dev->name);
 		return;
 	}
 
-	// on link down we are zeroing duplex and speed since some of the adaptors(ce1000.lan) report full duplex/speed instead of N/A(duplex) / 0(speed)
-	// on link up we are forcing recheck on the duplex and speed since some of he adaptors(ce1000.lan) report
+	__get_state_machine_lock(port);
+	/* on link down we are zeroing duplex and speed since
+	 * some of the adaptors(ce1000.lan) report full duplex/speed
+	 * instead of N/A(duplex) / 0(speed).
+	 *
+	 * on link up we are forcing recheck on the duplex and speed since
+	 * some of he adaptors(ce1000.lan) report.
+	 */
 	if (link == BOND_LINK_UP) {
 		port->is_enabled = true;
 		port->actor_admin_port_key &= ~AD_DUPLEX_KEY_BITS;
@@ -2292,10 +2298,15 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
 		port->actor_oper_port_key = (port->actor_admin_port_key &=
 					     ~AD_SPEED_KEY_BITS);
 	}
-	//BOND_PRINT_DBG(("Port %d changed link status to %s", port->actor_port_number, ((link == BOND_LINK_UP)?"UP":"DOWN")));
-	// there is no need to reselect a new aggregator, just signal the
-	// state machines to reinitialize
+	pr_debug("Port %d changed link status to %s",
+		port->actor_port_number,
+		(link == BOND_LINK_UP) ? "UP" : "DOWN");
+	/* there is no need to reselect a new aggregator, just signal the
+	 * state machines to reinitialize
+	 */
 	port->sm_vars |= AD_PORT_BEGIN;
+
+	__release_state_machine_lock(port);
 }
 
 /*
-- 
1.8.0
