From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next] net-ethtool: Allow ethtool to set interface in loopback mode.
Date: Mon, 28 Mar 2011 15:24:25 -0700
Message-ID: <1301351066-24916-1-git-send-email-maheshb@google.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:21302 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755102Ab1C1WYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 18:24:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add second word for feature (currently it's single word). Also use the first
bit of the second word to set the loopback mode. By configuring the interface
in loopback mode in conjunction with a policy route / rule, a user-land
application can stress the egress / ingress path exposing the flows of the
change in progress and potentially help developer(s) understand the impact of
those changes without even sending a packet out on the network.

Following set of commands illustrates one such example -
    a) ip -4 addr add 192.168.1.1/24 dev eth1
    b) ip -4 rule add from all iif eth1 lookup 250
    c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
    d) arp -Ds 192.168.1.100 eth1
    e) arp -Ds 192.168.1.200 eth1
    f) sysctl -w net.ipv4.ip_nonlocal_bind=1
    g) sysctl -w net.ipv4.conf.all.accept_local=1
    # Assuming that the machine has 8 cores
    h) taskset 000f netserver -L 192.168.1.200
    i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 include/linux/ethtool.h |   14 ++++++++++++
 net/core/ethtool.c      |   54 +++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 64 insertions(+), 4 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index aac3e2e..a42f60c 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -526,6 +526,8 @@ struct ethtool_flash {
 
 /* for returning and changing feature sets */
 
+#define ETHTOOL_DEV_FEATURE_WORDS	2
+
 /**
  * struct ethtool_get_features_block - block with state of 32 features
  * @available: mask of changeable features
@@ -594,6 +596,8 @@ struct ethtool_sfeatures {
  *   %ETHTOOL_F_COMPAT - some or all changes requested were made by calling
  *      compatibility functions. Requested offload state cannot be properly
  *      managed by kernel.
+ *   %ETHTOOL_F_2NDWORD - some or all changes requested in the second word of
+ *      the features failed.
  *
  * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO (number of
  * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS commands
@@ -604,11 +608,13 @@ enum ethtool_sfeatures_retval_bits {
 	ETHTOOL_F_UNSUPPORTED__BIT,
 	ETHTOOL_F_WISH__BIT,
 	ETHTOOL_F_COMPAT__BIT,
+	ETHTOOL_F_2NDWORD__BIT,
 };
 
 #define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
+#define ETHTOOL_F_2NDWORD       (1 << ETHTOOL_F_2NDWORD__BIT)
 
 #ifdef __KERNEL__
 
@@ -764,6 +770,8 @@ struct ethtool_ops {
 				  struct ethtool_rxfh_indir *);
 	int	(*set_rxfh_indir)(struct net_device *,
 				  const struct ethtool_rxfh_indir *);
+	int (*get_loopback)(struct net_device *);
+	int (*set_loopback)(struct net_device *, u32);
 };
 #endif /* __KERNEL__ */
 
@@ -837,6 +845,12 @@ struct ethtool_ops {
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
 
+/* Additional features (2 word of the feature-set) */
+#define ETHTOOL_LOOPBACK	(1 << 0)  /* Enable/Disable loop-back feature */
+
+/* Mask of all valid 2nd word features */
+#define ETHTOOL_VALID_2NDWORD_FEATURES	ETHTOOL_LOOPBACK
+
 /* Indicates what features are supported by the interface. */
 #define SUPPORTED_10baseT_Half		(1 << 0)
 #define SUPPORTED_10baseT_Full		(1 << 1)
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index c1a71bb..4f2c2d5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -166,8 +166,6 @@ EXPORT_SYMBOL(ethtool_ntuple_flush);
 
 /* Handlers for each ethtool command */
 
-#define ETHTOOL_DEV_FEATURE_WORDS	1
-
 static void ethtool_get_features_compat(struct net_device *dev,
 	struct ethtool_get_features_block *features)
 {
@@ -238,6 +236,38 @@ static int ethtool_set_features_compat(struct net_device *dev,
 	return compat;
 }
 
+static void ethtool_get_secondword_features(struct net_device *dev,
+		struct ethtool_get_features_block *features)
+{
+	if (!dev->ethtool_ops)
+		return;
+
+	if (dev->ethtool_ops->get_loopback) {
+		if (dev->ethtool_ops->get_loopback(dev))
+		    features[1].active |= ETHTOOL_LOOPBACK;
+	} else
+		features[1].available &= ~ETHTOOL_LOOPBACK;
+
+
+	return;
+}
+
+static int ethtool_set_secondword_features(struct net_device *dev,
+		struct ethtool_set_features_block *features)
+{
+	int ret = 0;
+
+	if (features[1].valid & ETHTOOL_LOOPBACK) {
+		features[1].valid &= ~ETHTOOL_LOOPBACK;
+		if (dev->ethtool_ops->set_loopback) {	
+			ret |= dev->ethtool_ops->set_loopback(dev,
+				!!(features[1].requested & ETHTOOL_LOOPBACK));
+		}
+	}
+
+	return(ret);
+}
+
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_gfeatures cmd = {
@@ -251,12 +281,19 @@ static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 			.active = dev->features,
 			.never_changed = NETIF_F_NEVER_CHANGE,
 		},
+		{
+			.available = ETHTOOL_VALID_2NDWORD_FEATURES,
+			.active = 0,
+		},
 	};
 	u32 __user *sizeaddr;
 	u32 copy_size;
 
 	ethtool_get_features_compat(dev, features);
 
+	/* Get 2nd-word features */
+	ethtool_get_secondword_features(dev, features);
+
 	sizeaddr = useraddr + offsetof(struct ethtool_gfeatures, size);
 	if (get_user(copy_size, sizeaddr))
 		return -EFAULT;
@@ -289,14 +326,20 @@ static int ethtool_set_features(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(features, useraddr, sizeof(features)))
 		return -EFAULT;
 
-	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
+	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS ||
+	    features[1].valid & ~ETHTOOL_VALID_2NDWORD_FEATURES)
 		return -EINVAL;
 
 	if (ethtool_set_features_compat(dev, features))
 		ret |= ETHTOOL_F_COMPAT;
 
-	if (features[0].valid & ~dev->hw_features) {
+	if (ethtool_set_secondword_features(dev, features))
+		ret |= ETHTOOL_F_2NDWORD;
+
+	if ((features[0].valid & ~dev->hw_features) ||
+	    (features[1].valid & ~ETHTOOL_VALID_2NDWORD_FEATURES)) {
 		features[0].valid &= dev->hw_features;
+		features[1].valid &= ETHTOOL_VALID_2NDWORD_FEATURES;
 		ret |= ETHTOOL_F_UNSUPPORTED;
 	}
 
@@ -346,6 +389,9 @@ static const char netdev_features_strings[ETHTOOL_DEV_FEATURE_WORDS * 32][ETH_GS
 	/* NETIF_F_RXCSUM */          "rx-checksum",
 	"",
 	"",
+
+	/* 2nd word of features */
+	/* ETHTOOL_LOOPBACK */        "loopback",
 };
 
 static int __ethtool_get_sset_count(struct net_device *dev, int sset)
-- 
1.7.3.1

