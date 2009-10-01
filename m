From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 4/4] ethtool: Remove support for obsolete string query
	operations
Date: Thu, 01 Oct 2009 22:33:03 +0100
Message-ID: <1254432783.2735.29.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:3504 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbZJAVmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:42:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The in-tree implementations have all been converted to
get_sset_count().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |    4 ---
 net/core/ethtool.c      |   58 ++++++++--------------------------------------
 2 files changed, 10 insertions(+), 52 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 15e4eb7..aa0dcb3 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -495,10 +495,6 @@ struct ethtool_ops {
 	u32     (*get_priv_flags)(struct net_device *);
 	int     (*set_priv_flags)(struct net_device *, u32);
 	int	(*get_sset_count)(struct net_device *, int);
-
-	/* the following hooks are obsolete */
-	int	(*self_test_count)(struct net_device *);/* use get_sset_count */
-	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
 	int	(*get_rxnfc)(struct net_device *, struct ethtool_rxnfc *, void *);
 	int	(*set_rxnfc)(struct net_device *, struct ethtool_rxnfc *);
 	int     (*flash_device)(struct net_device *, struct ethtool_flash *);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 4c12ddb..e195108 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -198,13 +198,6 @@ static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 		rc = ops->get_sset_count(dev, ETH_SS_PRIV_FLAGS);
 		if (rc >= 0)
 			info.n_priv_flags = rc;
-	} else {
-		/* code path for obsolete hooks */
-
-		if (ops->self_test_count)
-			info.testinfo_len = ops->self_test_count(dev);
-		if (ops->get_stats_count)
-			info.n_stats = ops->get_stats_count(dev);
 	}
 	if (ops->get_regs_len)
 		info.regdump_len = ops->get_regs_len(dev);
@@ -684,16 +677,10 @@ static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 	u64 *data;
 	int ret, test_len;
 
-	if (!ops->self_test)
-		return -EOPNOTSUPP;
-	if (!ops->get_sset_count && !ops->self_test_count)
+	if (!ops->self_test || !ops->get_sset_count)
 		return -EOPNOTSUPP;
 
-	if (ops->get_sset_count)
-		test_len = ops->get_sset_count(dev, ETH_SS_TEST);
-	else
-		/* code path for obsolete hook */
-		test_len = ops->self_test_count(dev);
+	test_len = ops->get_sset_count(dev, ETH_SS_TEST);
 	if (test_len < 0)
 		return test_len;
 	WARN_ON(test_len == 0);
@@ -728,36 +715,17 @@ static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 	u8 *data;
 	int ret;
 
-	if (!ops->get_strings)
+	if (!ops->get_strings || !ops->get_sset_count)
 		return -EOPNOTSUPP;
 
 	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
 		return -EFAULT;
 
-	if (ops->get_sset_count) {
-		ret = ops->get_sset_count(dev, gstrings.string_set);
-		if (ret < 0)
-			return ret;
-
-		gstrings.len = ret;
-	} else {
-		/* code path for obsolete hooks */
-
-		switch (gstrings.string_set) {
-		case ETH_SS_TEST:
-			if (!ops->self_test_count)
-				return -EOPNOTSUPP;
-			gstrings.len = ops->self_test_count(dev);
-			break;
-		case ETH_SS_STATS:
-			if (!ops->get_stats_count)
-				return -EOPNOTSUPP;
-			gstrings.len = ops->get_stats_count(dev);
-			break;
-		default:
-			return -EINVAL;
-		}
-	}
+	ret = ops->get_sset_count(dev, gstrings.string_set);
+	if (ret < 0)
+		return ret;
+
+	gstrings.len = ret;
 
 	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
 	if (!data)
@@ -798,16 +766,10 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 	u64 *data;
 	int ret, n_stats;
 
-	if (!ops->get_ethtool_stats)
-		return -EOPNOTSUPP;
-	if (!ops->get_sset_count && !ops->get_stats_count)
+	if (!ops->get_ethtool_stats || !ops->get_sset_count)
 		return -EOPNOTSUPP;
 
-	if (ops->get_sset_count)
-		n_stats = ops->get_sset_count(dev, ETH_SS_STATS);
-	else
-		/* code path for obsolete hook */
-		n_stats = ops->get_stats_count(dev);
+	n_stats = ops->get_sset_count(dev, ETH_SS_STATS);
 	if (n_stats < 0)
 		return n_stats;
 	WARN_ON(n_stats == 0);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

