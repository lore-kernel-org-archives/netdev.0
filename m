From: "Wang, Xiaoming" <xiaoming.wang@intel.com>
Subject: [PATCH] net: ipv4: current group_info should be put after using.
Date: Mon, 14 Apr 2014 12:30:45 -0400
Message-ID: <1397493045.2575.8.camel@wxm-ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: chuansheng.liu@intel.com, dongxing.zhang@intel.com,
	xiaoming.wang@intel.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mguzik@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Plug a group_info refcount leak in ping_init.
group_info is only needed during initialization and 
the code failed to release the reference on exit.
While here move grabbing the reference to a place 
where it is actually needed.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Zhang Dongxing <dongxing.zhang@intel.com>
Signed-off-by: xiaoming wang <xiaoming.wang@intel.com>
---
 net/ipv4/ping.c |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index f4b19e5..8210964 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -252,26 +252,33 @@ int ping_init_sock(struct sock *sk)
 {
 	struct net *net = sock_net(sk);
 	kgid_t group = current_egid();
-	struct group_info *group_info = get_current_groups();
-	int i, j, count = group_info->ngroups;
+	struct group_info *group_info;
+	int i, j, count;
 	kgid_t low, high;
+	int ret = 0;
 
 	inet_get_ping_group_range_net(net, &low, &high);
 	if (gid_lte(low, group) && gid_lte(group, high))
 		return 0;
 
+	group_info = get_current_groups();
+	count = group_info->ngroups;
 	for (i = 0; i < group_info->nblocks; i++) {
 		int cp_count = min_t(int, NGROUPS_PER_BLOCK, count);
 		for (j = 0; j < cp_count; j++) {
 			kgid_t gid = group_info->blocks[i][j];
 			if (gid_lte(low, gid) && gid_lte(gid, high))
-				return 0;
+				goto out_release_group;
 		}
 
 		count -= cp_count;
 	}
 
-	return -EACCES;
+	ret = -EACCES;
+
+out_release_group:
+	put_group_info(group_info);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(ping_init_sock);
 
-- 
1.7.1
