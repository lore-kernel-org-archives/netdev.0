From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net 1/3] bonding: protect port for bond_3ad_adapter_speed_changed()
Date: Fri, 13 Dec 2013 17:29:19 +0800
Message-ID: <52AAD36F.3060801@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:58580 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750830Ab3LMJbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 04:31:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh said that the bond_3ad_adapter_speed_changed is
called with RTNL only, and the function will modify the port's
information with no further locking, it will not mutex against
bond state machine and incoming LACPDU which do not hold RTNL,
So I add __get_state_machine_lock to protect the port.

But it is not a critical bug, it exist since day one, and till
now it has never been hit and reported, because changes to
speed is very rare, and will not occur critical problem.

The comment in the function is very old, cleanup it.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 187b1b7..6405ce3 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2201,20 +2201,25 @@ void bond_3ad_adapter_speed_changed(struct slave *slave)
 
 	port = &(SLAVE_AD_INFO(slave).port);
 
-	// if slave is null, the whole port is not initialized
+	/* if slave is null, the whole port is not initialized */
 	if (!port->slave) {
 		pr_warning("Warning: %s: speed changed for uninitialized port on %s\n",
 			   slave->bond->dev->name, slave->dev->name);
 		return;
 	}
 
+	__get_state_machine_lock(port);
+
 	port->actor_admin_port_key &= ~AD_SPEED_KEY_BITS;
 	port->actor_oper_port_key = port->actor_admin_port_key |=
 		(__get_link_speed(port) << 1);
 	pr_debug("Port %d changed speed\n", port->actor_port_number);
-	// there is no need to reselect a new aggregator, just signal the
-	// state machines to reinitialize
+	/* there is no need to reselect a new aggregator, just signal the
+	 * state machines to reinitialize
+	 */
 	port->sm_vars |= AD_PORT_BEGIN;
+
+	__release_state_machine_lock(port);
 }
 
 /**
-- 
1.8.0
