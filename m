From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NET]: Share correct feature code between bridging and bonding
Date: Tue, 21 Aug 2007 14:22:55 +0800
Message-ID: <20070821062255.GA21799@gondor.apana.org.au>
References: <20070809033601.GA16912@gondor.apana.org.au> <20070810.154817.04442540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2606 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751468AbXHUGXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 02:23:00 -0400
Content-Disposition: inline
In-Reply-To: <20070810.154817.04442540.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

Here's the back-port for 2.6.22.

[NET]: Share correct feature code between bridging and bonding

http://bugzilla.kernel.org/show_bug.cgi?id=8797 shows that the
bonding driver may produce bogus combinations of the checksum
flags and SG/TSO.

For example, if you bond devices with NETIF_F_HW_CSUM and
NETIF_F_IP_CSUM you'll end up with a bonding device that
has neither flag set.  If both have TSO then this produces
an illegal combination.

The bridge device on the other hand has the correct code to
deal with this.

In fact, the same code can be used for both.  So this patch
moves that logic into net/core/dev.c and uses it for both
bonding and bridging.

In the process I've made small adjustments such as only
setting GSO_ROBUST if at least one constituent device
supports it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6287ffb..0af7bc8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1233,43 +1233,31 @@ int bond_sethwaddr(struct net_device *bond_dev, struct net_device *slave_dev)
 	return 0;
 }
 
-#define BOND_INTERSECT_FEATURES \
-	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_TSO | NETIF_F_UFO)
+#define BOND_VLAN_FEATURES \
+	(NETIF_F_VLAN_CHALLENGED | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX | \
+	 NETIF_F_HW_VLAN_FILTER)
 
 /* 
  * Compute the common dev->feature set available to all slaves.  Some
- * feature bits are managed elsewhere, so preserve feature bits set on
- * master device that are not part of the examined set.
+ * feature bits are managed elsewhere, so preserve those feature bits
+ * on the master device.
  */
 static int bond_compute_features(struct bonding *bond)
 {
-	unsigned long features = BOND_INTERSECT_FEATURES;
 	struct slave *slave;
 	struct net_device *bond_dev = bond->dev;
+	unsigned long features = bond_dev->features & ~BOND_VLAN_FEATURES;
 	unsigned short max_hard_header_len = ETH_HLEN;
 	int i;
 
 	bond_for_each_slave(bond, slave, i) {
-		features &= (slave->dev->features & BOND_INTERSECT_FEATURES);
+		features = netdev_compute_features(features,
+						   slave->dev->features);
 		if (slave->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len = slave->dev->hard_header_len;
 	}
 
-	if ((features & NETIF_F_SG) && 
-	    !(features & NETIF_F_ALL_CSUM))
-		features &= ~NETIF_F_SG;
-
-	/* 
-	 * features will include NETIF_F_TSO (NETIF_F_UFO) iff all 
-	 * slave devices support NETIF_F_TSO (NETIF_F_UFO), which 
-	 * implies that all slaves also support scatter-gather 
-	 * (NETIF_F_SG), which implies that features also includes 
-	 * NETIF_F_SG. So no need to check whether we have an  
-	 * illegal combination of NETIF_F_{TSO,UFO} and 
-	 * !NETIF_F_SG 
-	 */
-
-	features |= (bond_dev->features & ~BOND_INTERSECT_FEATURES);
+	features |= (bond_dev->features & BOND_VLAN_FEATURES);
 	bond_dev->features = features;
 	bond_dev->hard_header_len = max_hard_header_len;
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3a70f55..ab210be 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1032,6 +1032,8 @@ extern void dev_seq_stop(struct seq_file *seq, void *v);
 
 extern void linkwatch_run_queue(void);
 
+extern int netdev_compute_features(unsigned long all, unsigned long one);
+
 static inline int net_gso_ok(int features, int gso_type)
 {
 	int feature = gso_type << NETIF_F_GSO_SHIFT;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 5e1892d..c326602 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -179,5 +179,6 @@ void br_dev_setup(struct net_device *dev)
 	dev->priv_flags = IFF_EBRIDGE;
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
-			NETIF_F_TSO | NETIF_F_NO_CSUM | NETIF_F_GSO_ROBUST;
+			NETIF_F_GSO_SOFTWARE | NETIF_F_NO_CSUM |
+			NETIF_F_GSO_ROBUST | NETIF_F_LLTX;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 849deaf..fefd7c1 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -360,35 +360,15 @@ int br_min_mtu(const struct net_bridge *br)
 void br_features_recompute(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
-	unsigned long features, checksum;
+	unsigned long features;
 
-	checksum = br->feature_mask & NETIF_F_ALL_CSUM ? NETIF_F_NO_CSUM : 0;
-	features = br->feature_mask & ~NETIF_F_ALL_CSUM;
+	features = br->feature_mask;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		unsigned long feature = p->dev->features;
-
-		if (checksum & NETIF_F_NO_CSUM && !(feature & NETIF_F_NO_CSUM))
-			checksum ^= NETIF_F_NO_CSUM | NETIF_F_HW_CSUM;
-		if (checksum & NETIF_F_HW_CSUM && !(feature & NETIF_F_HW_CSUM))
-			checksum ^= NETIF_F_HW_CSUM | NETIF_F_IP_CSUM;
-		if (!(feature & NETIF_F_IP_CSUM))
-			checksum = 0;
-
-		if (feature & NETIF_F_GSO)
-			feature |= NETIF_F_GSO_SOFTWARE;
-		feature |= NETIF_F_GSO;
-
-		features &= feature;
+		features = netdev_compute_features(features, p->dev->features);
 	}
 
-	if (!(checksum & NETIF_F_ALL_CSUM))
-		features &= ~NETIF_F_SG;
-	if (!(features & NETIF_F_SG))
-		features &= ~NETIF_F_GSO_MASK;
-
-	br->dev->features = features | checksum | NETIF_F_LLTX |
-			    NETIF_F_GSO_ROBUST;
+	br->dev->features = features;
 }
 
 /* called with RTNL */
diff --git a/net/core/dev.c b/net/core/dev.c
index ee051bb..1561f61 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3635,6 +3635,44 @@ static int __init netdev_dma_register(void)
 static int __init netdev_dma_register(void) { return -ENODEV; }
 #endif /* CONFIG_NET_DMA */
 
+/**
+ *	netdev_compute_feature - compute conjunction of two feature sets
+ *	@all: first feature set
+ *	@one: second feature set
+ *
+ *	Computes a new feature set after adding a device with feature set
+ *	@one to the master device with current feature set @all.  Returns
+ *	the new feature set.
+ */
+int netdev_compute_features(unsigned long all, unsigned long one)
+{
+	/* if device needs checksumming, downgrade to hw checksumming */
+	if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
+		all ^= NETIF_F_NO_CSUM | NETIF_F_HW_CSUM;
+
+	/* if device can't do all checksum, downgrade to ipv4 */
+	if (all & NETIF_F_HW_CSUM && !(one & NETIF_F_HW_CSUM))
+		all ^= NETIF_F_HW_CSUM | NETIF_F_IP_CSUM;
+
+	if (one & NETIF_F_GSO)
+		one |= NETIF_F_GSO_SOFTWARE;
+	one |= NETIF_F_GSO;
+
+	/* If even one device supports robust GSO, enable it for all. */
+	if (one & NETIF_F_GSO_ROBUST)
+		all |= NETIF_F_GSO_ROBUST;
+
+	all &= one | NETIF_F_LLTX;
+
+	if (!(all & NETIF_F_ALL_CSUM))
+		all &= ~NETIF_F_SG;
+	if (!(all & NETIF_F_SG))
+		all &= ~NETIF_F_GSO_MASK;
+
+	return all;
+}
+EXPORT_SYMBOL(netdev_compute_features);
+
 /*
  *	Initialize the DEV module. At boot time this walks the device list and
  *	unhooks any devices that fail to initialise (normally hardware not
