From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH net-next-2.6] bonding, net: Move last_rx update into bonding recv logic
Date: Mon, 03 Nov 2008 18:13:09 -0800
Message-ID: <20247.1225764789@death.nxdomain.ibm.com>
References: <20081031.165144.86556444.davem@davemloft.net> <20081031165620.7322b0e5@extreme> <22495.1225498593@death.nxdomain.ibm.com> <20081101.214008.201420949.davem@davemloft.net>
Cc: shemminger@vyatta.com, dada1@cosmosbay.com, zbr@ioremap.net,
	ilpo.jarvinen@helsinki.fi, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	efault@gmx.de, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:45271 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752002AbYKDCNP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 21:13:15 -0500
In-reply-to: <20081101.214008.201420949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	The only user of the net_device->last_rx field is bonding.  This
patch adds a conditional update of last_rx to the bonding special logic
in skb_bond_should_drop, causing last_rx to only be updated when the ARP
monitor is running.

	This frees network device drivers from the necessity of updating
last_rx, which can have cache line thrash issues.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 56c823c..39575d7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4564,6 +4564,8 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
 	bond_dev->priv_flags |= IFF_BONDING;
+	if (bond->params.arp_interval)
+		bond_dev->priv_flags |= IFF_MASTER_ARPMON;
 
 	/* At first, we block adding VLANs. That's the only way to
 	 * prevent problems that occur when adding VLANs over an
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 296a865..e400d7d 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -620,6 +620,8 @@ static ssize_t bonding_store_arp_interval(struct device *d,
 	       ": %s: Setting ARP monitoring interval to %d.\n",
 	       bond->dev->name, new_value);
 	bond->params.arp_interval = new_value;
+	if (bond->params.arp_interval)
+		bond->dev->priv_flags |= IFF_MASTER_ARPMON;
 	if (bond->params.miimon) {
 		printk(KERN_INFO DRV_NAME
 		       ": %s: ARP monitoring cannot be used with MII monitoring. "
@@ -1039,6 +1041,7 @@ static ssize_t bonding_store_miimon(struct device *d,
 			       "ARP monitoring. Disabling ARP monitoring...\n",
 			       bond->dev->name);
 			bond->params.arp_interval = 0;
+			bond->dev->priv_flags &= ~IFF_MASTER_ARPMON;
 			if (bond->params.arp_validate) {
 				bond_unregister_arp(bond);
 				bond->params.arp_validate =
diff --git a/include/linux/if.h b/include/linux/if.h
index 6524684..2a6e296 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -65,6 +65,7 @@
 #define IFF_BONDING	0x20		/* bonding master or slave	*/
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
 #define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
+#define IFF_MASTER_ARPMON 0x100		/* bonding master, ARP mon in use */
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9d77b1d..f1b0dbe 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1742,22 +1742,26 @@ static inline int skb_bond_should_drop(struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 	struct net_device *master = dev->master;
 
-	if (master &&
-	    (dev->priv_flags & IFF_SLAVE_INACTIVE)) {
-		if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
-		    skb->protocol == __constant_htons(ETH_P_ARP))
-			return 0;
-
-		if (master->priv_flags & IFF_MASTER_ALB) {
-			if (skb->pkt_type != PACKET_BROADCAST &&
-			    skb->pkt_type != PACKET_MULTICAST)
+	if (master) {
+		if (master->priv_flags & IFF_MASTER_ARPMON)
+			dev->last_rx = jiffies;
+
+		if (dev->priv_flags & IFF_SLAVE_INACTIVE) {
+			if ((dev->priv_flags & IFF_SLAVE_NEEDARP) &&
+			    skb->protocol == __constant_htons(ETH_P_ARP))
 				return 0;
-		}
-		if (master->priv_flags & IFF_MASTER_8023AD &&
-		    skb->protocol == __constant_htons(ETH_P_SLOW))
-			return 0;
 
-		return 1;
+			if (master->priv_flags & IFF_MASTER_ALB) {
+				if (skb->pkt_type != PACKET_BROADCAST &&
+				    skb->pkt_type != PACKET_MULTICAST)
+					return 0;
+			}
+			if (master->priv_flags & IFF_MASTER_8023AD &&
+			    skb->protocol == __constant_htons(ETH_P_SLOW))
+				return 0;
+
+			return 1;
+		}
 	}
 	return 0;
 }
