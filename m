From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH] bonding: refuse to change bond type if it's used
Date: Mon, 8 Mar 2010 18:54:06 +0100
Message-ID: <20100308175406.GA2834@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753458Ab0CHRyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Mar 2010 12:54:53 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not desirable to be able to change the type of net_device in bond device if
it's in use by bridge, or vlan, or so. At the moment, there is possible for
example to have INFINIBAND bond type in bridge (by adding bond with eth type to
a bridge first and then enslave INFINIBAND device).

This patch adds netdev_is_independent() function to check if device is not
"enslaved" and use this function to do the check before type change is performed.

>From now on, the type change is allowed only for those bond devices not used by
any other net dev.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 430c022..4e64af1 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1476,6 +1476,15 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	if (bond->slave_cnt == 0) {
 		if (bond_dev->type != slave_dev->type) {
+			/* check if device is not used by bridge, vlan, etc */
+			if (!netdev_is_independent(bond_dev)) {
+				pr_debug("%s: can't change device type from "
+					 "%d to %d, device is busy\n",
+					 bond_dev->name,
+					 bond_dev->type, slave_dev->type);
+				res = -EBUSY;
+				goto err_undo_flags;
+			}
 			pr_debug("%s: change device type from %d to %d\n",
 				 bond_dev->name,
 				 bond_dev->type, slave_dev->type);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c79a88b..0c90a57 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -984,6 +984,12 @@ struct net_device {
 
 #define	NETDEV_ALIGN		32
 
+static inline int netdev_is_independent(const struct net_device *dev)
+{
+	return dev->master == NULL && dev->br_port == NULL &&
+	       dev->macvlan_port == NULL && dev->garp_port == NULL;
+}
+
 static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
 					 unsigned int index)
