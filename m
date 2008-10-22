From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: net: Fix disjunct computation of netdev features
Date: Wed, 22 Oct 2008 16:12:27 +0800
Message-ID: <20081022081227.GA25276@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43223 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751314AbYJVIMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 04:12:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

net: Fix disjunct computation of netdev features

My change

    commit e2a6b85247aacc52d6ba0d9b37a99b8d1a3e0d83
    net: Enable TSO if supported by at least one device

didn't do what was intended because the netdev_compute_features
function was designed for conjunctions.  So what happened was that
it would simply take the TSO status of the last constituent device.

This patch extends it to support both conjunctions and disjunctions
under the new name of netdev_increment_features.

It also adds a new function netdev_fix_features which does the
sanity checking that usually occurs upon registration.  This ensures
that the computation doesn't result in an illegal combination
since this checking is absent when the change is initiated via
ethtool.

The two users of netdev_compute_features have been converted.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8e2be24..832739f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1341,18 +1341,24 @@ static int bond_compute_features(struct bonding *bond)
 	int i;
 
 	features &= ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
-	features |= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
-		    NETIF_F_GSO_MASK | NETIF_F_NO_CSUM;
+	features |=  NETIF_F_GSO_MASK | NETIF_F_NO_CSUM;
+
+	if (!bond->first_slave)
+		goto done;
+
+	features &= ~NETIF_F_ONE_FOR_ALL;
 
 	bond_for_each_slave(bond, slave, i) {
-		features = netdev_compute_features(features,
-						   slave->dev->features);
+		features = netdev_increment_features(features,
+						     slave->dev->features,
+						     NETIF_F_ONE_FOR_ALL);
 		if (slave->dev->hard_header_len > max_hard_header_len)
 			max_hard_header_len = slave->dev->hard_header_len;
 	}
 
+done:
 	features |= (bond_dev->features & BOND_VLAN_FEATURES);
-	bond_dev->features = features;
+	bond_dev->features = netdev_fix_features(features, NULL);
 	bond_dev->hard_header_len = max_hard_header_len;
 
 	return 0;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 6487585..c8bcb59 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -541,6 +541,14 @@ struct net_device
 #define NETIF_F_V6_CSUM		(NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
 #define NETIF_F_ALL_CSUM	(NETIF_F_V4_CSUM | NETIF_F_V6_CSUM)
 
+	/*
+	 * If one device supports one of these features, then enable them
+	 * for all in netdev_increment_features.
+	 */
+#define NETIF_F_ONE_FOR_ALL	(NETIF_F_GSO_SOFTWARE | NETIF_F_GSO_ROBUST | \
+				 NETIF_F_SG | NETIF_F_HIGHDMA | \
+				 NETIF_F_FRAGLIST)
+
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
@@ -1698,7 +1706,9 @@ extern char *netdev_drivername(const struct net_device *dev, char *buffer, int l
 
 extern void linkwatch_run_queue(void);
 
-extern int netdev_compute_features(unsigned long all, unsigned long one);
+unsigned long netdev_increment_features(unsigned long all, unsigned long one,
+					unsigned long mask);
+unsigned long netdev_fix_features(unsigned long features, const char *name);
 
 static inline int net_gso_ok(int features, int gso_type)
 {
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 22ba863..6c023f0 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -179,5 +179,5 @@ void br_dev_setup(struct net_device *dev)
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
-			NETIF_F_NETNS_LOCAL;
+			NETIF_F_NETNS_LOCAL | NETIF_F_GSO;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 573e20f..0a09ccf 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -347,15 +347,21 @@ int br_min_mtu(const struct net_bridge *br)
 void br_features_recompute(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
-	unsigned long features;
+	unsigned long features, mask;
 
-	features = br->feature_mask;
+	features = mask = br->feature_mask;
+	if (list_empty(&br->port_list))
+		goto done;
+
+	features &= ~NETIF_F_ONE_FOR_ALL;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		features = netdev_compute_features(features, p->dev->features);
+		features = netdev_increment_features(features,
+						     p->dev->features, mask);
 	}
 
-	br->dev->features = features;
+done:
+	br->dev->features = netdev_fix_features(features, NULL);
 }
 
 /* called with RTNL */
diff --git a/net/core/dev.c b/net/core/dev.c
index 868ec0b..48135b4 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3947,6 +3947,46 @@ static void netdev_init_queue_locks(struct net_device *dev)
 	__netdev_init_queue_locks_one(dev, &dev->rx_queue, NULL);
 }
 
+unsigned long netdev_fix_features(unsigned long features, const char *name)
+{
+	/* Fix illegal SG+CSUM combinations. */
+	if ((features & NETIF_F_SG) &&
+	    !(features & NETIF_F_ALL_CSUM)) {
+		if (name)
+			printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no "
+			       "checksum feature.\n", name);
+		features &= ~NETIF_F_SG;
+	}
+
+	/* TSO requires that SG is present as well. */
+	if ((features & NETIF_F_TSO) && !(features & NETIF_F_SG)) {
+		if (name)
+			printk(KERN_NOTICE "%s: Dropping NETIF_F_TSO since no "
+			       "SG feature.\n", name);
+		features &= ~NETIF_F_TSO;
+	}
+
+	if (features & NETIF_F_UFO) {
+		if (!(features & NETIF_F_GEN_CSUM)) {
+			if (name)
+				printk(KERN_ERR "%s: Dropping NETIF_F_UFO "
+				       "since no NETIF_F_HW_CSUM feature.\n",
+				       name);
+			features &= ~NETIF_F_UFO;
+		}
+
+		if (!(features & NETIF_F_SG)) {
+			if (name)
+				printk(KERN_ERR "%s: Dropping NETIF_F_UFO "
+				       "since no NETIF_F_SG feature.\n", name);
+			features &= ~NETIF_F_UFO;
+		}
+	}
+
+	return features;
+}
+EXPORT_SYMBOL(netdev_fix_features);
+
 /**
  *	register_netdevice	- register a network device
  *	@dev: device to register
@@ -4032,36 +4072,7 @@ int register_netdevice(struct net_device *dev)
 		dev->features &= ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CSUM);
 	}
 
-
-	/* Fix illegal SG+CSUM combinations. */
-	if ((dev->features & NETIF_F_SG) &&
-	    !(dev->features & NETIF_F_ALL_CSUM)) {
-		printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no checksum feature.\n",
-		       dev->name);
-		dev->features &= ~NETIF_F_SG;
-	}
-
-	/* TSO requires that SG is present as well. */
-	if ((dev->features & NETIF_F_TSO) &&
-	    !(dev->features & NETIF_F_SG)) {
-		printk(KERN_NOTICE "%s: Dropping NETIF_F_TSO since no SG feature.\n",
-		       dev->name);
-		dev->features &= ~NETIF_F_TSO;
-	}
-	if (dev->features & NETIF_F_UFO) {
-		if (!(dev->features & NETIF_F_HW_CSUM)) {
-			printk(KERN_ERR "%s: Dropping NETIF_F_UFO since no "
-					"NETIF_F_HW_CSUM feature.\n",
-							dev->name);
-			dev->features &= ~NETIF_F_UFO;
-		}
-		if (!(dev->features & NETIF_F_SG)) {
-			printk(KERN_ERR "%s: Dropping NETIF_F_UFO since no "
-					"NETIF_F_SG feature.\n",
-					dev->name);
-			dev->features &= ~NETIF_F_UFO;
-		}
-	}
+	dev->features = netdev_fix_features(dev->features, dev->name);
 
 	/* Enable software GSO if SG is supported. */
 	if (dev->features & NETIF_F_SG)
@@ -4700,49 +4711,45 @@ static int __init netdev_dma_register(void) { return -ENODEV; }
 #endif /* CONFIG_NET_DMA */
 
 /**
- *	netdev_compute_feature - compute conjunction of two feature sets
- *	@all: first feature set
- *	@one: second feature set
+ *	netdev_increment_features - increment feature set by one
+ *	@all: current feature set
+ *	@one: new feature set
+ *	@mask: mask feature set
  *
  *	Computes a new feature set after adding a device with feature set
- *	@one to the master device with current feature set @all.  Returns
- *	the new feature set.
+ *	@one to the master device with current feature set @all.  Will not
+ *	enable anything that is off in @mask. Returns the new feature set.
  */
-int netdev_compute_features(unsigned long all, unsigned long one)
-{
-	/* if device needs checksumming, downgrade to hw checksumming */
-	if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
-		all ^= NETIF_F_NO_CSUM | NETIF_F_HW_CSUM;
-
-	/* if device can't do all checksum, downgrade to ipv4/ipv6 */
-	if (all & NETIF_F_HW_CSUM && !(one & NETIF_F_HW_CSUM))
-		all ^= NETIF_F_HW_CSUM
-			| NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-
-	if (one & NETIF_F_GSO)
-		one |= NETIF_F_GSO_SOFTWARE;
-	one |= NETIF_F_GSO;
-
-	/*
-	 * If even one device supports a GSO protocol with software fallback,
-	 * enable it for all.
-	 */
-	all |= one & NETIF_F_GSO_SOFTWARE;
+unsigned long netdev_increment_features(unsigned long all, unsigned long one,
+					unsigned long mask)
+{
+	/* If device needs checksumming, downgrade to it. */
+        if (all & NETIF_F_NO_CSUM && !(one & NETIF_F_NO_CSUM))
+		all ^= NETIF_F_NO_CSUM | (one & NETIF_F_ALL_CSUM);
+	else if (mask & NETIF_F_ALL_CSUM) {
+		/* If one device supports v4/v6 checksumming, set for all. */
+		if (one & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM) &&
+		    !(all & NETIF_F_GEN_CSUM)) {
+			all &= ~NETIF_F_ALL_CSUM;
+			all |= one & (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+		}
 
-	/* If even one device supports robust GSO, enable it for all. */
-	if (one & NETIF_F_GSO_ROBUST)
-		all |= NETIF_F_GSO_ROBUST;
+		/* If one device supports hw checksumming, set for all. */
+		if (one & NETIF_F_GEN_CSUM && !(all & NETIF_F_GEN_CSUM)) {
+			all &= ~NETIF_F_ALL_CSUM;
+			all |= NETIF_F_HW_CSUM;
+		}
+	}
 
-	all &= one | NETIF_F_LLTX;
+	one |= NETIF_F_ALL_CSUM;
 
-	if (!(all & NETIF_F_ALL_CSUM))
-		all &= ~NETIF_F_SG;
-	if (!(all & NETIF_F_SG))
-		all &= ~NETIF_F_GSO_MASK;
+	one |= all & NETIF_F_ONE_FOR_ALL;
+	all &= one | NETIF_F_LLTX | NETIF_F_GSO;
+	all |= one & mask & NETIF_F_ONE_FOR_ALL;
 
 	return all;
 }
-EXPORT_SYMBOL(netdev_compute_features);
+EXPORT_SYMBOL(netdev_increment_features);
 
 static struct hlist_head *netdev_create_hash(void)
 {

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
