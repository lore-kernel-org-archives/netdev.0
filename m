From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2] net: Allow no-cache copy from user on transmit
Date: Wed, 23 Mar 2011 10:10:41 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.1103231003120.16608@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:47461 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753665Ab1CWRKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2011 13:10:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses __copy_from_user_nocache (from skb_copy_to_page)
on transmit to bypass data cache for a performance improvement.
This functionality is configurable per device using ethtool, the
device must also be doing TX csum offload to enable.  It seems
reasonable to set this when the netdevice does not copy or
otherwise touch the data.

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

Note especially the effect on tail latency (95th percentile).

This seems to provide a nice performance improvement and is
consistent in the tests I ran.  Presumably, this would provide
the greatest benfits in the presence of an application workload
stressing the cache and a lot of transmit data happening.  I don't
yet see a downside to using this.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |   10 ++++++++--
 include/net/sock.h        |    5 +++++
 net/core/dev.c            |    2 +-
 net/core/ethtool.c        |    2 +-
 4 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5eeb2cd..52d444f 100644
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
@@ -1108,7 +1109,12 @@ struct net_device {
 				 NETIF_F_FRAGLIST)
 
 	/* changeable features with no special hardware requirements */
-#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO |	\
+				 NETIF_F_NOCACHE_COPY)
+
+	/* soft features automatically enabled */
+#define NETIF_F_SOFT_FEAT_ENAB	(NETIF_F_GSO | NETIF_F_GRO)
+
 
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
index 0b88eba..c3ed95e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5435,7 +5435,7 @@ int register_netdevice(struct net_device *dev)
 	 * software offloads (GSO and GRO).
 	 */
 	dev->hw_features |= NETIF_F_SOFT_FEATURES;
-	dev->features |= NETIF_F_SOFT_FEATURES;
+	dev->features |= NETIF_F_SOFT_FEAT_ENAB;
 	dev->wanted_features = dev->features & dev->hw_features;
 
 	/* Avoid warning from netdev_fix_features() for GSO without SG */
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

