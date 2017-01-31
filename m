From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next] net: ethtool: convert large order kmalloc allocations to vzalloc
Date: Mon, 30 Jan 2017 18:25:18 -0800
Message-ID: <1485829518-190263-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57230 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751702AbdAaCZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 21:25:37 -0500
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0V2PAAW030661
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 18:25:21 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 28ae7b8kff-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 18:25:21 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.102.107.99) with ESMTP id
 827cda54e75c11e68c310002c99293a0-739f9a50 for <netdev@vger.kernel.org>;        Mon,
 30 Jan 2017 18:25:19 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

under memory pressure 'ethtool -S' command may warn:
[ 2374.385195] ethtool: page allocation failure: order:4, mode:0x242c0c0
[ 2374.405573] CPU: 12 PID: 40211 Comm: ethtool Not tainted
[ 2374.423071] Call Trace:
[ 2374.423076]  [<ffffffff8148cb29>] dump_stack+0x4d/0x64
[ 2374.423080]  [<ffffffff811667cb>] warn_alloc_failed+0xeb/0x150
[ 2374.423082]  [<ffffffff81169cd3>] ? __alloc_pages_direct_compact+0x43/0xf0
[ 2374.423084]  [<ffffffff8116a25c>] __alloc_pages_nodemask+0x4dc/0xbf0
[ 2374.423091]  [<ffffffffa0023dc2>] ? cmd_exec+0x722/0xcd0 [mlx5_core]
[ 2374.423095]  [<ffffffff811b3dcc>] alloc_pages_current+0x8c/0x110
[ 2374.423097]  [<ffffffff81168859>] alloc_kmem_pages+0x19/0x90
[ 2374.423099]  [<ffffffff81186e5e>] kmalloc_order_trace+0x2e/0xe0
[ 2374.423101]  [<ffffffff811c0084>] __kmalloc+0x204/0x220
[ 2374.423105]  [<ffffffff816c269e>] dev_ethtool+0xe4e/0x1f80
[ 2374.423106]  [<ffffffff816b967e>] ? dev_get_by_name_rcu+0x5e/0x80
[ 2374.423108]  [<ffffffff816d6926>] dev_ioctl+0x156/0x560
[ 2374.423111]  [<ffffffff811d4c68>] ? mem_cgroup_commit_charge+0x78/0x3c0
[ 2374.423117]  [<ffffffff8169d542>] sock_do_ioctl+0x42/0x50
[ 2374.423119]  [<ffffffff8169d9c3>] sock_ioctl+0x1b3/0x250
[ 2374.423121]  [<ffffffff811f0f42>] do_vfs_ioctl+0x92/0x580
[ 2374.423123]  [<ffffffff8100222b>] ? do_audit_syscall_entry+0x4b/0x70
[ 2374.423124]  [<ffffffff8100287c>] ? syscall_trace_enter_phase1+0xfc/0x120
[ 2374.423126]  [<ffffffff811f14a9>] SyS_ioctl+0x79/0x90
[ 2374.423127]  [<ffffffff81002bb0>] do_syscall_64+0x50/0xa0
[ 2374.423129]  [<ffffffff817e19bc>] entry_SYSCALL64_slow_path+0x25/0x25

~1160 mlx5 counters ~= order 4 allocation which is unlikely to succeed
under memory pressure. Convert them to vzalloc() as ethtool_get_regs() does.
Also take care of drivers without counters similar to
commit 67ae7cf1eeda ("ethtool: Allow zero-length register dumps again")
and reduce warn_on to warn_on_once.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
Dave, I think by 'careful about size calculations' you mean
to take care of zero-length. Please let me know if I misunderstood.

I couldn't find any in-tree drivers that have zero length strings
and we already warn_on ops->get_sset_count() == 0, so makes sense
to warn in ethtool_get_strings() as well.
---
 net/core/ethtool.c | 39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 236a21e3c878..6b3eee0834a0 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1817,11 +1817,13 @@ static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 	ret = __ethtool_get_sset_count(dev, gstrings.string_set);
 	if (ret < 0)
 		return ret;
+	if (ret > S32_MAX / ETH_GSTRING_LEN)
+		return -ENOMEM;
+	WARN_ON_ONCE(!ret);
 
 	gstrings.len = ret;
-
-	data = kcalloc(gstrings.len, ETH_GSTRING_LEN, GFP_USER);
-	if (!data)
+	data = vzalloc(gstrings.len * ETH_GSTRING_LEN);
+	if (gstrings.len && !data)
 		return -ENOMEM;
 
 	__ethtool_get_strings(dev, gstrings.string_set, data);
@@ -1830,12 +1832,13 @@ static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 	if (copy_to_user(useraddr, &gstrings, sizeof(gstrings)))
 		goto out;
 	useraddr += sizeof(gstrings);
-	if (copy_to_user(useraddr, data, gstrings.len * ETH_GSTRING_LEN))
+	if (gstrings.len &&
+	    copy_to_user(useraddr, data, gstrings.len * ETH_GSTRING_LEN))
 		goto out;
 	ret = 0;
 
 out:
-	kfree(data);
+	vfree(data);
 	return ret;
 }
 
@@ -1912,14 +1915,15 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 	n_stats = ops->get_sset_count(dev, ETH_SS_STATS);
 	if (n_stats < 0)
 		return n_stats;
-	WARN_ON(n_stats == 0);
-
+	if (n_stats > S32_MAX / sizeof(u64))
+		return -ENOMEM;
+	WARN_ON_ONCE(!n_stats);
 	if (copy_from_user(&stats, useraddr, sizeof(stats)))
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = kmalloc(n_stats * sizeof(u64), GFP_USER);
-	if (!data)
+	data = vzalloc(n_stats * sizeof(u64));
+	if (n_stats && !data)
 		return -ENOMEM;
 
 	ops->get_ethtool_stats(dev, &stats, data);
@@ -1928,12 +1932,12 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 	if (copy_to_user(useraddr, &stats, sizeof(stats)))
 		goto out;
 	useraddr += sizeof(stats);
-	if (copy_to_user(useraddr, data, stats.n_stats * sizeof(u64)))
+	if (n_stats && copy_to_user(useraddr, data, n_stats * sizeof(u64)))
 		goto out;
 	ret = 0;
 
  out:
-	kfree(data);
+	vfree(data);
 	return ret;
 }
 
@@ -1948,17 +1952,18 @@ static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
 		return -EOPNOTSUPP;
 
 	n_stats = phy_get_sset_count(phydev);
-
 	if (n_stats < 0)
 		return n_stats;
-	WARN_ON(n_stats == 0);
+	if (n_stats > S32_MAX / sizeof(u64))
+		return -ENOMEM;
+	WARN_ON_ONCE(!n_stats);
 
 	if (copy_from_user(&stats, useraddr, sizeof(stats)))
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = kmalloc_array(n_stats, sizeof(u64), GFP_USER);
-	if (!data)
+	data = vzalloc(n_stats * sizeof(u64));
+	if (n_stats && !data)
 		return -ENOMEM;
 
 	mutex_lock(&phydev->lock);
@@ -1969,12 +1974,12 @@ static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
 	if (copy_to_user(useraddr, &stats, sizeof(stats)))
 		goto out;
 	useraddr += sizeof(stats);
-	if (copy_to_user(useraddr, data, stats.n_stats * sizeof(u64)))
+	if (n_stats && copy_to_user(useraddr, data, n_stats * sizeof(u64)))
 		goto out;
 	ret = 0;
 
  out:
-	kfree(data);
+	vfree(data);
 	return ret;
 }
 
-- 
2.8.0
