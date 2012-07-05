From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH v2] cgroup: fix panic in netprio_cgroup
Date: Thu, 5 Jul 2012 17:28:40 +0800
Message-ID: <1341480520-25081-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nhorman@tuxdriver.com, tj@kernel.org, lizefan@huawei.com,
	eric.dumazet@gmail.com, Gao feng <gaofeng@cn.fujitsu.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

we set max_prioidx to the first zero bit index of prioidx_map in
function get_prioidx.

So when we delete the low index netprio cgroup and adding a new
netprio cgroup again,the max_prioidx will be set to the low index.

when we set the high index cgroup's net_prio.ifpriomap,the function
write_priomap will call update_netdev_tables to alloc memory which
size is sizeof(struct netprio_map) + sizeof(u32) * (max_prioidx + 1),
so the size of array that map->priomap point to is max_prioidx +1,
which is low than what we actually need.

fix this by adding check in get_prioidx,only set max_prioidx when
max_prioidx low than the new prioidx.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/core/netprio_cgroup.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 5b8aa2f..aa907ed 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -49,8 +49,9 @@ static int get_prioidx(u32 *prio)
 		return -ENOSPC;
 	}
 	set_bit(prioidx, prioidx_map);
+	if (atomic_read(&max_prioidx) < prioidx)
+		atomic_set(&max_prioidx, prioidx);
 	spin_unlock_irqrestore(&prioidx_map_lock, flags);
-	atomic_set(&max_prioidx, prioidx);
 	*prio = prioidx;
 	return 0;
 }
-- 
1.7.7.6
