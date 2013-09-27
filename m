From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] bonding: Fix broken promiscuity reference counting issue
Date: Fri, 27 Sep 2013 12:22:15 -0400
Message-ID: <1380298935-32140-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mark Wu <wudxw@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49189 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752591Ab3I0QYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 12:24:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently grabbed this report:
https://bugzilla.redhat.com/show_bug.cgi?id=1005567

Of an issue in which the bonding driver, with an attached vlan encountered the
following errors when bond0 was taken down and back up:

dummy1: promiscuity touches roof, set promiscuity failed. promiscuity feature of
device might be broken.

The error occurs because, during __bond_release_one, if we release our last
slave, we take on a random mac address and issue a NETDEV_CHANGEADDR
notification.  With an attached vlan, the vlan may see that the vlan and bond
mac address were in sync, but no longer are.  This triggers a call to dev_uc_add
and dev_set_rx_mode, which enables IFF_PROMISC on the bond device.  Then, when
we complete __bond_release_one, we use the current state of the bond flags to
determine if we should decrement the promiscuity of the releasing slave.  But
since the bond changed promiscuity state during the release operation, we
incorrectly decrement the slave promisc count when it wasn't in promiscuous mode
to begin with, causing the above error

Fix is pretty simple, just cache the bonding flags at the start of the function
and use those when determining the need to set promiscuity.

This is also needed for the ALLMULTI flag

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: Mark Wu <wudxw@linux.vnet.ibm.com>
CC: "David S. Miller" <davem@davemloft.net>
Reported-by: Mark Wu <wudxw@linux.vnet.ibm.com>
---
 drivers/net/bonding/bond_main.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index d5c3153..5373a8d 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1710,6 +1710,7 @@ static int __bond_release_one(struct net_device *bond_dev,
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
+	int old_flags = bond_dev->flags;
 	netdev_features_t old_features = bond_dev->features;
 
 	/* slave is not a slave or master is not master of this slave */
@@ -1841,12 +1842,18 @@ static int __bond_release_one(struct net_device *bond_dev,
 	 * bond_change_active_slave(..., NULL)
 	 */
 	if (!USES_PRIMARY(bond->params.mode)) {
-		/* unset promiscuity level from slave */
-		if (bond_dev->flags & IFF_PROMISC)
+		/* unset promiscuity level from slave
+		 * NOTE: The NETDEV_CHANGEADDR call above may change the value
+		 * of the IFF_PROMISC flag in the bond_dev, but we need the
+		 * value of that flag before that change, as that was the value
+		 * when this slave was attached, so we cache at the start of the
+		 * function and use it here. Same goes for ALLMULTI below
+		 */
+		if (old_flags & IFF_PROMISC)
 			dev_set_promiscuity(slave_dev, -1);
 
 		/* unset allmulti level from slave */
-		if (bond_dev->flags & IFF_ALLMULTI)
+		if (old_flags & IFF_ALLMULTI)
 			dev_set_allmulti(slave_dev, -1);
 
 		bond_hw_addr_flush(bond_dev, slave_dev);
-- 
1.8.3.1
