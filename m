From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6] bonding: use ndo_change_rx_flags callback
Date: Tue, 16 Aug 2011 11:30:50 +0200
Message-ID: <1313487050-4048-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18777 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751698Ab1HPJaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2011 05:30:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benefit from use of ndo_change_rx_flags in handling change of promisc
and allmulti. No need to store previous state locally.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |   44 ++++++++++++--------------------------
 drivers/net/bonding/bonding.h   |    1 -
 2 files changed, 14 insertions(+), 31 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 854aa8d..731763a 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3686,44 +3686,27 @@ static bool bond_addr_in_mc_list(unsigned char *addr,
 	return false;
 }
 
-static void bond_set_multicast_list(struct net_device *bond_dev)
+static void bond_change_rx_flags(struct net_device *bond_dev, int change)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
-	struct netdev_hw_addr *ha;
-	bool found;
 
-	/*
-	 * Do promisc before checking multicast_mode
-	 */
-	if ((bond_dev->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC))
-		/*
-		 * FIXME: Need to handle the error when one of the multi-slaves
-		 * encounters error.
-		 */
-		bond_set_promiscuity(bond, 1);
-
-
-	if (!(bond_dev->flags & IFF_PROMISC) && (bond->flags & IFF_PROMISC))
-		bond_set_promiscuity(bond, -1);
+	if (change & IFF_PROMISC)
+		bond_set_promiscuity(bond,
+				     bond_dev->flags & IFF_ALLMULTI ? 1 : -1);
 
+	if (change & IFF_ALLMULTI)
+		bond_set_allmulti(bond,
+				  bond_dev->flags & IFF_ALLMULTI ? 1 : -1);
+}
 
-	/* set allmulti flag to slaves */
-	if ((bond_dev->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI))
-		/*
-		 * FIXME: Need to handle the error when one of the multi-slaves
-		 * encounters error.
-		 */
-		bond_set_allmulti(bond, 1);
-
-
-	if (!(bond_dev->flags & IFF_ALLMULTI) && (bond->flags & IFF_ALLMULTI))
-		bond_set_allmulti(bond, -1);
-
+static void bond_set_multicast_list(struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	struct netdev_hw_addr *ha;
+	bool found;
 
 	read_lock(&bond->lock);
 
-	bond->flags = bond_dev->flags;
-
 	/* looking for addresses to add to slaves' mc list */
 	netdev_for_each_mc_addr(ha, bond_dev) {
 		found = bond_addr_in_mc_list(ha->addr, &bond->mc_list,
@@ -4282,6 +4265,7 @@ static const struct net_device_ops bond_netdev_ops = {
 	.ndo_select_queue	= bond_select_queue,
 	.ndo_get_stats64	= bond_get_stats,
 	.ndo_do_ioctl		= bond_do_ioctl,
+	.ndo_change_rx_flags	= bond_change_rx_flags,
 	.ndo_set_multicast_list	= bond_set_multicast_list,
 	.ndo_change_mtu		= bond_change_mtu,
 	.ndo_set_mac_address	= bond_set_mac_address,
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 43526a2..e823366 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -234,7 +234,6 @@ struct bonding {
 	struct   netdev_hw_addr_list mc_list;
 	int      (*xmit_hash_policy)(struct sk_buff *, int);
 	__be32   master_ip;
-	u16      flags;
 	u16      rr_tx_counter;
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
-- 
1.7.6

