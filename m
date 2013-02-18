From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH] bonding: Fix initialize after use for 3ad machine state spinlock
Date: Mon, 18 Feb 2013 13:45:41 +0100
Message-ID: <1361191541-7654-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754942Ab3BRMr7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2013 07:47:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 3ad machine state spinlock can be used before it is inititialized
while doing bond_enslave() (and the port is being initialized) since
port->slave is set before the lock is prepared, thus causing soft
lock-ups and a multitude of other nasty bugs.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 1720742..96d471e 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -389,13 +389,13 @@ static u8 __get_duplex(struct port *port)
 
 /**
  * __initialize_port_locks - initialize a port's STATE machine spinlock
- * @port: the port we're looking at
+ * @port: the slave of the port we're looking at
  *
  */
-static inline void __initialize_port_locks(struct port *port)
+static inline void __initialize_port_locks(struct slave *port)
 {
 	// make sure it isn't called twice
-	spin_lock_init(&(SLAVE_AD_INFO(port->slave).state_machine_lock));
+	spin_lock_init(&(SLAVE_AD_INFO(port).state_machine_lock));
 }
 
 //conversions
@@ -1910,6 +1910,7 @@ int bond_3ad_bind_slave(struct slave *slave)
 
 		ad_initialize_port(port, bond->params.lacp_fast);
 
+		__initialize_port_locks(slave);
 		port->slave = slave;
 		port->actor_port_number = SLAVE_AD_INFO(slave).id;
 		// key is determined according to the link speed, duplex and user key(which is yet not supported)
@@ -1932,8 +1933,6 @@ int bond_3ad_bind_slave(struct slave *slave)
 		port->next_port_in_aggregator = NULL;
 
 		__disable_port(port);
-		__initialize_port_locks(port);
-
 
 		// aggregator initialization
 		aggregator = &(SLAVE_AD_INFO(slave).aggregator);
-- 
1.7.11.7
