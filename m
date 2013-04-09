From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 1/2] bonding: fix netdev event NULL pointer dereference
Date: Tue,  9 Apr 2013 22:17:23 +0200
Message-ID: <1365538644-1502-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3459 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754639Ab3DIUUg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Apr 2013 16:20:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 471cb5a33dcbd7c529684a2ac7ba4451414ee4a7 ("bonding: remove
usage of dev->master") a bug was introduced which causes a NULL pointer
dereference. If a bond device is in mode 6 (ALB) and a slave is added
it will dereference a NULL pointer in bond_slave_netdev_event().
This is because in bond_enslave we have bond_alb_init_slave() which
changes the MAC address of the slave and causes a NETDEV_CHANGEADDR.
Then we have in bond_slave_netdev_event():
        struct slave *slave = bond_slave_get_rtnl(slave_dev);
        struct bonding *bond = slave->bond;
bond_slave_get_rtnl() dereferences slave_dev->rx_handler_data which at
that time is NULL since netdev_rx_handler_register() is called later.

This is fixed by checking if slave is NULL before dereferencing it.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_main.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 171b10f..9995ddc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3168,11 +3168,21 @@ static int bond_slave_netdev_event(unsigned long event,
 				   struct net_device *slave_dev)
 {
 	struct slave *slave = bond_slave_get_rtnl(slave_dev);
-	struct bonding *bond = slave->bond;
-	struct net_device *bond_dev = slave->bond->dev;
+	struct bonding *bond;
+	struct net_device *bond_dev;
 	u32 old_speed;
 	u8 old_duplex;
 
+	/*
+	 * A netdev event can be generated while enslaving a device
+	 * before netdev_rx_handler_register is called in which case
+	 * slave will be NULL
+	 */
+	if (!slave)
+		return NOTIFY_DONE;
+	bond_dev = slave->bond->dev;
+	bond = slave->bond;
+
 	switch (event) {
 	case NETDEV_UNREGISTER:
 		if (bond->setup_by_slave)
-- 
1.8.1.4
