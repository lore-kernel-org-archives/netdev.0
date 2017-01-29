From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] net: ethtool: silence kmalloc warning
Date: Sat, 28 Jan 2017 17:17:05 -0800
Message-ID: <1485652625-2881838-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>, <netdev@vger.kernel.org>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:59196 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752768AbdA2BSY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2017 20:18:24 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0T1F6Uq006325
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 17:17:08 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 288qg01xe7-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2017 17:17:08 -0800
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)     by
 mx-out.facebook.com (10.223.100.99) with ESMTP id
 a5cdc4b6e5c011e6983924be05956610-107f8a50 for <netdev@vger.kernel.org>;        Sat,
 28 Jan 2017 17:17:06 -0800
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
under memory pressure.  Since 'get stats' command is not critical
avoid reclaim and warning.
Also convert to safer kmalloc_array.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
Long term this place is a good candidate to use kvmalloc() once it's merged.
---
 net/core/ethtool.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 236a21e3c878..be681a06bf3f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1820,7 +1820,8 @@ static int ethtool_get_strings(struct net_device *dev, void __user *useraddr)
 
 	gstrings.len = ret;
 
-	data = kcalloc(gstrings.len, ETH_GSTRING_LEN, GFP_USER);
+	data = kcalloc(gstrings.len, ETH_GSTRING_LEN,
+		       GFP_USER | __GFP_NORETRY | __GFP_NOWARN);
 	if (!data)
 		return -ENOMEM;
 
@@ -1918,7 +1919,8 @@ static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = kmalloc(n_stats * sizeof(u64), GFP_USER);
+	data = kmalloc_array(n_stats, sizeof(u64),
+			     GFP_USER | __GFP_NORETRY | __GFP_NOWARN);
 	if (!data)
 		return -ENOMEM;
 
@@ -1957,7 +1959,8 @@ static int ethtool_get_phy_stats(struct net_device *dev, void __user *useraddr)
 		return -EFAULT;
 
 	stats.n_stats = n_stats;
-	data = kmalloc_array(n_stats, sizeof(u64), GFP_USER);
+	data = kmalloc_array(n_stats, sizeof(u64),
+			     GFP_USER | __GFP_NORETRY | __GFP_NOWARN);
 	if (!data)
 		return -ENOMEM;
 
-- 
2.8.0
