From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] ethtool: Remove fallback to old ethtool operations
 for ETHTOOL_SFEATURES
Date: Sat, 14 May 2011 02:05:42 +0100
Message-ID: <1305335142.2851.70.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:55197 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911Ab1ENBFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 21:05:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool_set_feature_compat() squashes the feature mask into a boolean,
which is not correct for ethtool_ops::set_flags.

We could fix this, but the fallback code for ETHTOOL_SFEATURES actually
makes things more complicated for the ethtool utility and any other
application using the ethtool API.  They will still need to fall back to
the old offload control commands in order to support older kernel
versions.  The fallback code in the kernel adds a third possibility for
them to handle.  So make ETHTOOL_SFEATURES fail when the driver
implements the old offload control operations, and let userland do the
fallback.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    5 ----
 net/core/ethtool.c      |   55 ++++++-----------------------------------------
 2 files changed, 7 insertions(+), 53 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index dc80d82..5fb916c 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -625,9 +625,6 @@ struct ethtool_sfeatures {
  *      Probably there are other device-specific constraints on some features
  *      in the set. When %ETHTOOL_F_UNSUPPORTED is set, .valid is considered
  *      here as though ignored bits were cleared.
- *   %ETHTOOL_F_COMPAT - some or all changes requested were made by calling
- *      compatibility functions. Requested offload state cannot be properly
- *      managed by kernel.
  *
  * Meaning of bits in the masks are obtained by %ETHTOOL_GSSET_INFO (number of
  * bits in the arrays - always multiple of 32) and %ETHTOOL_GSTRINGS commands
@@ -637,12 +634,10 @@ struct ethtool_sfeatures {
 enum ethtool_sfeatures_retval_bits {
 	ETHTOOL_F_UNSUPPORTED__BIT,
 	ETHTOOL_F_WISH__BIT,
-	ETHTOOL_F_COMPAT__BIT,
 };
 
 #define ETHTOOL_F_UNSUPPORTED   (1 << ETHTOOL_F_UNSUPPORTED__BIT)
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
-#define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
 #ifdef __KERNEL__
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 74ead9e..5f58f1f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -207,52 +207,6 @@ static void ethtool_get_features_compat(struct net_device *dev,
 		features[0].available |= flags_dup_features;
 }
 
-static int ethtool_set_feature_compat(struct net_device *dev,
-	int (*legacy_set)(struct net_device *, u32),
-	struct ethtool_set_features_block *features, u32 mask)
-{
-	u32 do_set;
-
-	if (!legacy_set)
-		return 0;
-
-	if (!(features[0].valid & mask))
-		return 0;
-
-	features[0].valid &= ~mask;
-
-	do_set = !!(features[0].requested & mask);
-
-	if (legacy_set(dev, do_set) < 0)
-		netdev_info(dev,
-			"Legacy feature change (%s) failed for 0x%08x\n",
-			do_set ? "set" : "clear", mask);
-
-	return 1;
-}
-
-static int ethtool_set_features_compat(struct net_device *dev,
-	struct ethtool_set_features_block *features)
-{
-	int compat;
-
-	if (!dev->ethtool_ops)
-		return 0;
-
-	compat  = ethtool_set_feature_compat(dev, dev->ethtool_ops->set_sg,
-		features, NETIF_F_SG);
-	compat |= ethtool_set_feature_compat(dev, dev->ethtool_ops->set_tx_csum,
-		features, NETIF_F_ALL_CSUM);
-	compat |= ethtool_set_feature_compat(dev, dev->ethtool_ops->set_tso,
-		features, NETIF_F_ALL_TSO);
-	compat |= ethtool_set_feature_compat(dev, dev->ethtool_ops->set_rx_csum,
-		features, NETIF_F_RXCSUM);
-	compat |= ethtool_set_feature_compat(dev, dev->ethtool_ops->set_flags,
-		features, flags_dup_features);
-
-	return compat;
-}
-
 static int ethtool_get_features(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_gfeatures cmd = {
@@ -307,8 +261,13 @@ static int ethtool_set_features(struct net_device *dev, void __user *useraddr)
 	if (features[0].valid & ~NETIF_F_ETHTOOL_BITS)
 		return -EINVAL;
 
-	if (ethtool_set_features_compat(dev, features))
-		ret |= ETHTOOL_F_COMPAT;
+	/* If the driver implements any of the old operations, don't
+	 * update features directly.
+	 */
+	if (dev->ethtool_ops->set_sg || dev->ethtool_ops->set_tx_csum ||
+	    dev->ethtool_ops->set_tso || dev->ethtool_ops->set_rx_csum ||
+	    dev->ethtool_ops->set_flags)
+		return -EOPNOTSUPP;
 
 	if (features[0].valid & ~dev->hw_features) {
 		features[0].valid &= dev->hw_features;
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

