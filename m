From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Wed, 30 Mar 2011 22:04:32 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1103302156270.17065@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:58143 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751892Ab1CaFEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Mar 2011 01:04:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses __copy_from_user_nocache (from skb_copy_to_page)
on transmit to bypass data cache for a performance improvement.
This functionality is configurable per device using ethtool.

Presumably, this feature would only be useful when the driver does
not touch the data.  The feature is turned on by default if a device
indicates that it does some form of checksum offload; it is off by
default for devices that do no checksum offload or indicate no checksum
is necessary.  For the former case copy-checksum is probably done
anyway, in the latter case the device is likely loopback in which case
the no cache copy is probably not beneficial.

This patch was tested using 200 instances of netperf TCP_RR with
1400 byte request and one byte reply.  Platform is 16 core AMD x86.

No-cache copy disabled:
   672703 tps, 97.13% utilization
   50/90/99% latency:244.31 484.205 1028.41

No-cache copy enabled:
   702113 tps, 96.16% utilization,
   50/90/99% latency 238.56 467.56 956.955

Using 14000 byte request and response sizes demonstrate the
effects more dramatically:

No-cache copy disabled:
   79571 tps, 34.34 %utlization
   50/90/95% latency 1584.46 2319.59 5001.76

No-cache copy enabled:
   83856 tps, 34.81% utilization
   50/90/95% latency 2508.42 2622.62 2735.88

Note especially the effect on latency tail (95th percentile).

This seems to provide a nice performance improvement and is
consistent in the tests I ran.  Presumably, this would provide
the greatest benfits in the presence of an application workload
stressing the cache and a lot of transmit data happening.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/bonding/bond_main.c |    2 +-
 include/linux/netdevice.h       |    6 ++++--
 include/net/sock.h              |    5 +++++
 net/core/dev.c                  |   11 +++++++++++
 net/core/ethtool.c              |    2 +-
 5 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 1a6e9eb..59b6ce9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1407,7 +1407,7 @@ static int bond_compute_features(struct bonding *bond)
 	int i;
 
 	features &= ~(NETIF_F_ALL_CSUM | BOND_VLAN_FEATURES);
-	features |=  NETIF_F_GSO_MASK | NETIF_F_NO_CSUM;
+	features |=  NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_NOCACHE_COPY;
 
 	if (!bond->first_slave)
 		goto done;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5eeb2cd..06327b5 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1066,6 +1066,7 @@ struct net_device {
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
 #define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
+#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -1081,7 +1082,7 @@ struct net_device {
 	/* = all defined minus driver/device-class-related */
 #define NETIF_F_NEVER_CHANGE	(NETIF_F_HIGHDMA | NETIF_F_VLAN_CHALLENGED | \
 				  NETIF_F_LLTX | NETIF_F_NETNS_LOCAL)
-#define NETIF_F_ETHTOOL_BITS	(0x3f3fffff & ~NETIF_F_NEVER_CHANGE)
+#define NETIF_F_ETHTOOL_BITS	(0x7f3fffff & ~NETIF_F_NEVER_CHANGE)
 
 	/* List of features with software fallbacks. */
 #define NETIF_F_GSO_SOFTWARE	(NETIF_F_TSO | NETIF_F_TSO_ECN | \
@@ -1108,7 +1109,8 @@ struct net_device {
 				 NETIF_F_FRAGLIST)
 
 	/* changeable features with no special hardware requirements */
-#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO |	\
+				 NETIF_F_NOCACHE_COPY)
 
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
diff --git a/include/net/sock.h b/include/net/sock.h
index da0534d..74ce586 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1401,6 +1401,11 @@ static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 		if (err)
 			return err;
 		skb->csum = csum_block_add(skb->csum, csum, skb->len);
+	} else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
+		if (!access_ok(VERIFY_READ, from, copy) ||
+		    __copy_from_user_nocache(page_address(page) + off,
+						from, copy))
+			return -EFAULT;
 	} else if (copy_from_user(page_address(page) + off, from, copy))
 		return -EFAULT;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 0b88eba..454abfd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5444,6 +5444,13 @@ int register_netdevice(struct net_device *dev)
 		dev->features &= ~NETIF_F_GSO;
 	}
 
+	/* Turn no cache copy off if HW isn't doing checksum */
+	if (!(dev->features & NETIF_F_ALL_CSUM) ||
+	    (dev->features & NETIF_F_NO_CSUM)) {
+		dev->wanted_features &= ~NETIF_F_NOCACHE_COPY;
+		dev->features &= ~NETIF_F_NOCACHE_COPY;
+	}
+
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.
@@ -6201,6 +6208,10 @@ u32 netdev_increment_features(u32 all, u32 one, u32 mask)
 		}
 	}
 
+	/* If device can't no cache copy, don't do for all */
+	if (!(one & NETIF_F_NOCACHE_COPY))
+		all &= ~NETIF_F_NOCACHE_COPY;
+
 	one |= NETIF_F_ALL_CSUM;
 
 	one |= all & NETIF_F_ONE_FOR_ALL;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..40b6fe0 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -344,7 +344,7 @@ static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
 	/* NETIF_F_RXHASH */          "rx-hashing",
 	/* NETIF_F_RXCSUM */          "rx-checksum",
-	"",
+	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy"
 	"",
 };
 
-- 
1.7.3.1

