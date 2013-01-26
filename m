From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH 3.4.y 3/3] net: netprio: fix cgrp create and write priomap
 race
Date: Sat, 26 Jan 2013 12:42:22 +0800
Message-ID: <51035EAE.5090004@huawei.com>
References: <51035E4F.6030508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Gao feng <gaofeng@cn.fujitsu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:38987 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907Ab3AZEmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 23:42:33 -0500
In-Reply-To: <51035E4F.6030508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>

commit 476ad154f3b41dd7d9a08a2f641e28388abc2fd1 upstream.

A race exists where creating cgroups and also updating the priomap
may result in losing a priomap update. This is because priomap
writers are not protected by rtnl_lock.

Move priority writer into rtnl_lock()/rtnl_unlock().

CC: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 net/core/netprio_cgroup.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index dca347e..eb07ea9 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -112,12 +112,10 @@ static int write_update_netdev_table(struct net_device *dev)
 	u32 max_len;
 	struct netprio_map *map;
 
-	rtnl_lock();
 	max_len = atomic_read(&max_prioidx) + 1;
 	map = rtnl_dereference(dev->priomap);
 	if (!map || map->priomap_len < max_len)
 		ret = extend_netdev_table(dev, max_len);
-	rtnl_unlock();
 
 	return ret;
 }
@@ -267,17 +265,17 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
 	if (!dev)
 		goto out_free_devname;
 
+	rtnl_lock();
 	ret = write_update_netdev_table(dev);
 	if (ret < 0)
 		goto out_put_dev;
 
-	rcu_read_lock();
-	map = rcu_dereference(dev->priomap);
+	map = rtnl_dereference(dev->priomap);
 	if (map)
 		map->priomap[prioidx] = priority;
-	rcu_read_unlock();
 
 out_put_dev:
+	rtnl_unlock();
 	dev_put(dev);
 
 out_free_devname:
-- 
1.8.0.2
