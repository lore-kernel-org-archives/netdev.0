From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net PATCH v3 3/3] net: netprio: fix cgrp create and write priomap
	race
Date: Tue, 14 Aug 2012 15:34:35 -0700
Message-ID: <20120814223435.3551.62387.stgit@jf-dev1-dcblab>
References: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-kernel@vger.kernel.org, joe@perches.com
To: viro@ZenIV.linux.org.uk, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814223424.3551.21608.stgit@jf-dev1-dcblab>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A race exists where creating cgroups and also updating the priomap
may result in losing a priomap update. This is because priomap
writers are not protected by rtnl_lock.

Move priority writer into rtnl_lock()/rtnl_unlock().

CC: Neil Horman <nhorman@tuxdriver.com>
Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/netprio_cgroup.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index f65dba3..c75e3f9 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -101,12 +101,10 @@ static int write_update_netdev_table(struct net_device *dev)
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
@@ -256,17 +254,17 @@ static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
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
