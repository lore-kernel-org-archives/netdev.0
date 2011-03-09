From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/2] net: Allow no-cache copy from user on transmit
Date: Tue, 8 Mar 2011 21:05:06 -0800 (PST)
Message-ID: <alpine.DEB.2.00.1103082053350.1433@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:16356 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750705Ab1CIFFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 00:05:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch uses __copy_from_user_nocache (from skb_copy_to_page)
on transmit to bypass data cache for a performance improvement.
This functionality is configurable per device using ethtool, the
device must also be doing TX csum offload to enable.  It seems
reasonable to set this when the device does not copy or
otherwise touch the data.

This patch was tested using 200 instances of netperf TCP_RR with
1400 byte request and one byte reply.  Platform is 16 core AMD.

No-cache copy disabled:
   672703 tps, 97.13% client utilization
   50/90/99% latency 244.31 484.205 1028.41

No-cache copy enabled:
   702113 tps, 96.16% client utilization,
   50/90/99% latency 238.56 467.56 956.955

This seems to provide a nice little performance improvement and is
consistent in the tests I ran.  Presumably, this would provide
the greatest  benfits in the presence of an application workload
stressing the cache and a lot of transmit data happening.  I don't
yet see a downside to using this.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/ethtool.h   |    4 ++++
 include/linux/netdevice.h |    4 +++-
 include/net/sock.h        |    5 +++++
 net/core/ethtool.c        |   11 ++++++++++-
 4 files changed, 22 insertions(+), 2 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index aac3e2e..2cf3cc9 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -833,6 +833,10 @@ struct ethtool_ops {
 #define ETHTOOL_GFEATURES	0x0000003a /* Get device offload settings */
 #define ETHTOOL_SFEATURES	0x0000003b /* Change device offload settings */
 
+#define ETHTOOL_GNCCOPY		0x0000003c /* Get no-cache-copy enable
+					    * (ethtool_value). */
+#define ETHTOOL_SNCCOPY		0x0000003d /* Set no-cache-copy enable
+					    * (ethtool_value). */
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 71563e7..1b72f29 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -978,6 +978,7 @@ struct net_device {
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
 #define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
+#define NETIF_F_NOCACHE_COPY	(1 << 30) /* Use no-cache copyfromuser */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -1020,7 +1021,8 @@ struct net_device {
 				 NETIF_F_FRAGLIST)
 
 	/* changeable features with no special hardware requirements */
-#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO)
+#define NETIF_F_SOFT_FEATURES	(NETIF_F_GSO | NETIF_F_GRO | \
+				 NETIF_F_NOCACHE_COPY)
 
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
diff --git a/include/net/sock.h b/include/net/sock.h
index da0534d..55b1385 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1401,6 +1401,11 @@ static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 		if (err)
 			return err;
 		skb->csum = csum_block_add(skb->csum, csum, skb->len);
+	} else if (sk->sk_route_caps & NETIF_F_NOCACHE_COPY) {
+		if (!access_ok(VERIFY_READ, from, copy)
+		   || __copy_from_user_nocache(page_address(page) + off,
+					       from, copy))
+			return -EFAULT;
 	} else if (copy_from_user(page_address(page) + off, from, copy))
 		return -EFAULT;
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..a8b2638 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -328,6 +328,7 @@ static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_NETNS_LOCAL */     "netns-local",
 	/* NETIF_F_GRO */             "rx-gro",
 	/* NETIF_F_LRO */             "rx-lro",
+	/* NETIF_F_NOCACHE_COPY */    "tx-nocache-copy",
 
 	/* NETIF_F_TSO */             "tx-tcp-segmentation",
 	/* NETIF_F_UFO */             "tx-udp-fragmentation",
@@ -336,7 +337,6 @@ static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_TSO6 */            "tx-tcp6-segmentation",
 	/* NETIF_F_FSO */             "tx-fcoe-segmentation",
 	"",
-	"",
 
 	/* NETIF_F_FCOE_CRC */        "tx-checksum-fcoe-crc",
 	/* NETIF_F_SCTP_CSUM */       "tx-checksum-sctp",
@@ -400,6 +400,9 @@ static u32 ethtool_get_feature_mask(u32 eth_cmd)
 	case ETHTOOL_GGRO:
 	case ETHTOOL_SGRO:
 		return NETIF_F_GRO;
+	case ETHTOOL_GNCCOPY:
+	case ETHTOOL_SNCCOPY:
+		return NETIF_F_NOCACHE_COPY;
 	default:
 		BUG();
 	}
@@ -1487,6 +1490,9 @@ static int __ethtool_set_tx_csum(struct net_device *dev, u32 data)
 			return err;
 	}
 
+	if (!data)
+		dev->features &= ~NETIF_F_NOCACHE_COPY;
+
 	return dev->ethtool_ops->set_tx_csum(dev, data);
 }
 
@@ -1768,6 +1774,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GUFO:
 	case ETHTOOL_GGSO:
 	case ETHTOOL_GGRO:
+	case ETHTOOL_GNCCOPY:
 	case ETHTOOL_GFLAGS:
 	case ETHTOOL_GPFLAGS:
 	case ETHTOOL_GRXFH:
@@ -1924,6 +1931,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_GUFO:
 	case ETHTOOL_GGSO:
 	case ETHTOOL_GGRO:
+	case ETHTOOL_GNCCOPY:
 		rc = ethtool_get_one_feature(dev, useraddr, ethcmd);
 		break;
 	case ETHTOOL_STXCSUM:
@@ -1933,6 +1941,7 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
 	case ETHTOOL_SUFO:
 	case ETHTOOL_SGSO:
 	case ETHTOOL_SGRO:
+	case ETHTOOL_SNCCOPY:
 		rc = ethtool_set_one_feature(dev, useraddr, ethcmd);
 		break;
 	default:
-- 
1.7.3.1

