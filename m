From: Li Zefan <lizefan@huawei.com>
Subject: [PATCH 3.4.y 1/3] cgroup: fix panic in netprio_cgroup
Date: Sat, 26 Jan 2013 12:41:15 +0800
Message-ID: <51035E6B.1000106@huawei.com>
References: <51035E4F.6030508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Gao feng <gaofeng@cn.fujitsu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:22124 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab3AZElV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 23:41:21 -0500
In-Reply-To: <51035E4F.6030508@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

commit b761c9b1f4f69eb53fb6147547a1ab25237a93b3 upstream.

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
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Li Zefan <lizefan@huawei.com>
---
 net/core/netprio_cgroup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index ba6900f..4435296 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -62,8 +62,9 @@ static int get_prioidx(u32 *prio)
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
1.8.0.2
