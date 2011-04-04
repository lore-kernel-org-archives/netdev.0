From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Sun, 3 Apr 2011 21:56:17 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1104032136540.5452@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:58795 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021Ab1DDE4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 00:56:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses __copy_from_user_nocache on transmit to bypass data
cache for a performance improvement.  skb_add_data_nocache and
skb_copy_to_page_nocache can be called by sendmsg functions to use
this feature, initial support is in tcp_sendmsg.  This functionality is
configurable per device using ethtool.

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
 include/linux/netdevice.h       |    3 +-
 include/net/sock.h              |   55 +++++++++++++++++++++++++++++++++++++++
 net/core/dev.c                  |   15 ++++++++++
 net/core/ethtool.c              |    2 +-
 net/ipv4/tcp.c                  |    7 +++--
 6 files changed, 78 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 16d6fe9..b51e021 100644
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
index 423a544..1828119 100644
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
diff --git a/include/net/sock.h b/include/net/sock.h
index da0534d..91c81f5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -52,6 +52,7 @@
 #include <linux/mm.h>
 #include <linux/security.h>
 #include <linux/slab.h>
+#include <linux/uaccess.h>
 
 #include <linux/filter.h>
 #include <linux/rculist_nulls.h>
@@ -1389,6 +1390,60 @@ static inline void sk_nocaps_add(struct sock *sk, int flags)
 	sk->sk_route_caps &= ~flags;
 }
 
+static inline int skb_do_copy_data_nocache(struct sock *sk, struct sk_buff *skb,
+					   char __user *from, char *to,
+					   int copy)
+{
+	if (skb->ip_summed == CHECKSUM_NONE) {
+		int err = 0;
+		__wsum csum = csum_and_copy_from_user(from, to, copy, 0, &err);
+		if (err)
+			return err;
+		skb->csum = csum_block_add(skb->csum, csum, skb->len);
+#ifdef ARCH_HAS_NOCACHE_UACCESS
+	} else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
+		if (!access_ok(VERIFY_READ, from, copy) ||
+		    __copy_from_user_nocache(to, from, copy))
+			return -EFAULT;
+#endif
+	} else if (copy_from_user(to, from, copy))
+		return -EFAULT;
+
+	return 0;
+}
+
+static inline int skb_add_data_nocache(struct sock *sk, struct sk_buff *skb,
+				       char __user *from, int copy)
+{
+	int err;
+
+	err = skb_do_copy_data_nocache(sk, skb, from, skb_put(skb, copy), copy);
+	if (err)
+		__skb_trim(skb, skb->len);
+
+	return err;
+}
+
+static inline int skb_copy_to_page_nocache(struct sock *sk, char __user *from,
+					   struct sk_buff *skb,
+					   struct page *page,
+					   int off, int copy)
+{
+	int err;
+
+	err = skb_do_copy_data_nocache(sk, skb, from,
+				       page_address(page) + off, copy);
+	if (err)
+		return err;
+
+	skb->len	     += copy;
+	skb->data_len	     += copy;
+	skb->truesize	     += copy;
+	sk->sk_wmem_queued   += copy;
+	sk_mem_charge(sk, copy);
+	return 0;
+}
+
 static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 				   struct sk_buff *skb, struct page *page,
 				   int off, int copy)
diff --git a/net/core/dev.c b/net/core/dev.c
index 02f5637..4c58a90 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5425,6 +5425,17 @@ int register_netdevice(struct net_device *dev)
 		dev->features &= ~NETIF_F_GSO;
 	}
 
+#ifdef ARCH_HAS_NOCACHE_UACCESS
+	dev->hw_features |= NETIF_F_NOCACHE_COPY;
+
+	/* Turn on no cache copy off if HW is doing checksum */
+	if ((dev->features & NETIF_F_ALL_CSUM) &&
+	    !(dev->features & NETIF_F_NO_CSUM)) {
+		dev->wanted_features |= NETIF_F_NOCACHE_COPY;
+		dev->features |= NETIF_F_NOCACHE_COPY;
+	}
+#endif
+
 	/* Enable GRO and NETIF_F_HIGHDMA for vlans by default,
 	 * vlan_dev_init() will do the dev->features check, so these features
 	 * are enabled only if supported by underlying device.
@@ -6182,6 +6193,10 @@ u32 netdev_increment_features(u32 all, u32 one, u32 mask)
 		}
 	}
 
+	/* If device can't no cache copy, don't do for all */
+	if (!(one & NETIF_F_NOCACHE_COPY))
+		all &= ~NETIF_F_NOCACHE_COPY;
+
 	one |= NETIF_F_ALL_CSUM;
 
 	one |= all & NETIF_F_ONE_FOR_ALL;
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 439e4b0..719670a 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -359,7 +359,7 @@ static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_NTUPLE */          "rx-ntuple-filter",
 	/* NETIF_F_RXHASH */          "rx-hashing",
 	/* NETIF_F_RXCSUM */          "rx-checksum",
-	"",
+	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy"
 	"",
 };
 
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b22d450..054a59d 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -999,7 +999,8 @@ new_segment:
 				/* We have some space in skb head. Superb! */
 				if (copy > skb_tailroom(skb))
 					copy = skb_tailroom(skb);
-				if ((err = skb_add_data(skb, from, copy)) != 0)
+				err = skb_add_data_nocache(sk, skb, from, copy);
+				if (err)
 					goto do_fault;
 			} else {
 				int merge = 0;
@@ -1042,8 +1043,8 @@ new_segment:
 
 				/* Time to copy data. We are close to
 				 * the end! */
-				err = skb_copy_to_page(sk, from, skb, page,
-						       off, copy);
+				err = skb_copy_to_page_nocache(sk, from, skb,
+							       page, off, copy);
 				if (err) {
 					/* If this page was new, give it to the
 					 * socket so it does not get leaked.
-- 
1.7.3.1

