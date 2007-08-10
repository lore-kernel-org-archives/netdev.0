From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 2/4] ethtool: introduce get_sset_count
Date: Fri, 10 Aug 2007 16:25:28 -0400
Message-ID: <20070810202528.GA25095@havoc.gtf.org>
References: <20070810202426.GA25050@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:47424 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965894AbXHJUZ3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Aug 2007 16:25:29 -0400
Content-Disposition: inline
In-Reply-To: <20070810202426.GA25050@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Required prep for the priv-flags changeset (next patch), which also uses
ethtool string sets.


commit 86fe0ff220a795c82aa9dea5dc4b7359519a1366
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Aug 10 15:49:21 2007 -0400

    [ETHTOOL] Introduce get_sset_count. Obsolete get_stats_count, self_test_count
    
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

 include/linux/ethtool.h |    7 ++-
 net/core/ethtool.c      |   95 +++++++++++++++++++++++++++++++++++-------------
 2 files changed, 75 insertions(+), 27 deletions(-)

86fe0ff220a795c82aa9dea5dc4b7359519a1366
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 0e5de2f..f617998 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -376,11 +376,9 @@ struct ethtool_ops {
 	int	(*set_sg)(struct net_device *, u32);
 	u32	(*get_tso)(struct net_device *);
 	int	(*set_tso)(struct net_device *, u32);
-	int	(*self_test_count)(struct net_device *);
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
 	int	(*phys_id)(struct net_device *, u32);
-	int	(*get_stats_count)(struct net_device *);
 	void	(*get_ethtool_stats)(struct net_device *, struct ethtool_stats *, u64 *);
 	int	(*begin)(struct net_device *);
 	void	(*complete)(struct net_device *);
@@ -388,6 +386,11 @@ struct ethtool_ops {
 	int     (*set_ufo)(struct net_device *, u32);
 	u32     (*get_flags)(struct net_device *);
 	int     (*set_flags)(struct net_device *, u32);
+	int	(*get_sset_count)(struct net_device *, int);
+
+	/* the following hooks are obsolete */
+	int	(*self_test_count)(struct net_device *);/* use get_sset_count */
+	int	(*get_stats_count)(struct net_device *);/* use get_sset_count */
 };
 #endif /* __KERNEL__ */
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 6e8563e..2b366a5 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -179,10 +179,23 @@ static int ethtool_get_drvinfo(struct net_device *dev, void __user *useraddr)
 	info.cmd = ETHTOOL_GDRVINFO;
 	ops->get_drvinfo(dev, &info);
 
-	if (ops->self_test_count)
-		info.testinfo_len = ops->self_test_count(dev);
-	if (ops->get_stats_count)
-		info.n_stats = ops->get_stats_count(dev);
+	if (ops->get_sset_count) {
+		int rc;
+
+		rc = ops->get_sset_count(dev, ETH_SS_TEST);
+		if (rc >= 0)
+			info.testinfo_len = rc;
+		rc = ops->get_sset_count(dev, ETH_SS_STATS);
+		if (rc >= 0)
+			info.n_stats = rc;
+	} else {
+		/* code path for obsolete hooks */
+
+		if (ops->self_test_count)
+			info.testinfo_len = ops->self_test_count(dev);
+		if (ops->get_stats_count)
+			info.n_stats = ops->get_stats_count(dev);
+	}
 	if (ops->get_regs_len)
 		info.regdump_len = ops->get_regs_len(dev);
 	if (ops->get_eeprom_len)
@@ -669,16 +682,27 @@ static int ethtool_self_test(struct net_device *dev, char __user *useraddr)
 	struct ethtool_test test;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u64 *data;
-	int ret;
+	int ret, test_len;
 
-	if (!ops->self_test || !ops->self_test_count)
+	if (!ops->self_test)
+		return -EOPNOTSUPP;
+	if (!ops->get_sset_count && !ops->self_test_count)
 		return -EOPNOTSUPP;
 
+	if (ops->get_sset_count)
+		test_len = ops->get_sset_count(dev, ETH_SS_TEST);
+	else
+		/* code path for obsolete hook */
+		test_len = ops->self_test_count(dev);
+	if (test_len < 0)
+		return test_len;
+	WARN_ON(test_len == 0);
+
 	if (copy_from_user(&test, useraddr, sizeof(test)))
 		return -EFAULT;
 
-	test.len = ops->self_test_count(dev);
-	data = kmalloc(test.len * sizeof(u64), GFP_USER);
+	test.len = test_len;
+	data = kmalloc(test_len * sizeof(u64), GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
@@ -710,19 +734,29 @@ static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 	if (copy_from_user(&gstrings, useraddr, sizeof(gstrings)))
 		return -EFAULT;
 
-	switch (gstrings.string_set) {
-	case ETH_SS_TEST:
-		if (!ops->self_test_count)
-			return -EOPNOTSUPP;
-		gstrings.len = ops->self_test_count(dev);
-		break;
-	case ETH_SS_STATS:
-		if (!ops->get_stats_count)
-			return -EOPNOTSUPP;
-		gstrings.len = ops->get_stats_count(dev);
-		break;
-	default:
-		return -EINVAL;
+	if (ops->get_sset_count) {
+		ret = ops->get_sset_count(dev, gstrings.string_set);
+		if (ret < 0)
+			return ret;
+
+		gstrings.len = ret;
+	} else {
+		/* code path for obsolete hooks */
+
+		switch (gstrings.string_set) {
+		case ETH_SS_TEST:
+			if (!ops->self_test_count)
+				return -EOPNOTSUPP;
+			gstrings.len = ops->self_test_count(dev);
+			break;
+		case ETH_SS_STATS:
+			if (!ops->get_stats_count)
+				return -EOPNOTSUPP;
+			gstrings.len = ops->get_stats_count(dev);
+			break;
+		default:
+			return -EINVAL;
+		}
 	}
 
 	data = kmalloc(gstrings.len * ETH_GSTRING_LEN, GFP_USER);
@@ -762,16 +796,27 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 	struct ethtool_stats stats;
 	const struct ethtool_ops *ops = dev->ethtool_ops;
 	u64 *data;
-	int ret;
+	int ret, n_stats;
 
-	if (!ops->get_ethtool_stats || !ops->get_stats_count)
+	if (!ops->get_ethtool_stats)
 		return -EOPNOTSUPP;
+	if (!ops->get_sset_count && !ops->get_stats_count)
+		return -EOPNOTSUPP;
+
+	if (ops->get_sset_count)
+		n_stats = ops->get_sset_count(dev, ETH_SS_STATS);
+	else
+		/* code path for obsolete hook */
+		n_stats = ops->get_stats_count(dev);
+	if (n_stats < 0)
+		return n_stats;
+	WARN_ON(n_stats == 0);
 
 	if (copy_from_user(&stats, useraddr, sizeof(stats)))
 		return -EFAULT;
 
-	stats.n_stats = ops->get_stats_count(dev);
-	data = kmalloc(stats.n_stats * sizeof(u64), GFP_USER);
+	stats.n_stats = n_stats;
+	data = kmalloc(n_stats * sizeof(u64), GFP_USER);
 	if (!data)
 		return -ENOMEM;
 
