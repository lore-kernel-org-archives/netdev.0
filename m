From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: cgroup: fix out of bounds accesses
Date: Mon, 09 Jul 2012 09:45:10 +0200
Message-ID: <1341819910.3265.2106.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, lizefan@huawei.com, tj@kernel.org,
	Gao feng <gaofeng@cn.fujitsu.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

dev->priomap is allocated by extend_netdev_table() called from
update_netdev_tables().
And this is only called if write_priomap() is called.

But if write_priomap() is not called, it seems we can have out of bounds
accesses in cgrp_destroy(), read_priomap() & skb_update_prio()

With help from Gao Feng

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
---
net/core/dev.c            |    8 ++++++--
net/core/netprio_cgroup.c |    4 ++--
2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 84f01ba..0f28a9e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2444,8 +2444,12 @@ static void skb_update_prio(struct sk_buff *skb)
 {
 	struct netprio_map *map = rcu_dereference_bh(skb->dev->priomap);
 
-	if ((!skb->priority) && (skb->sk) && map)
-		skb->priority = map->priomap[skb->sk->sk_cgrp_prioidx];
+	if (!skb->priority && skb->sk && map) {
+		unsigned int prioidx = skb->sk->sk_cgrp_prioidx;
+
+		if (prioidx < map->priomap_len)
+			skb->priority = map->priomap[prioidx];
+	}
 }
 #else
 #define skb_update_prio(skb)
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index aa907ed..3e953ea 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -142,7 +142,7 @@ static void cgrp_destroy(struct cgroup *cgrp)
 	rtnl_lock();
 	for_each_netdev(&init_net, dev) {
 		map = rtnl_dereference(dev->priomap);
-		if (map)
+		if (map && cs->prioidx < map->priomap_len)
 			map->priomap[cs->prioidx] = 0;
 	}
 	rtnl_unlock();
@@ -166,7 +166,7 @@ static int read_priomap(struct cgroup *cont, struct cftype *cft,
 	rcu_read_lock();
 	for_each_netdev_rcu(&init_net, dev) {
 		map = rcu_dereference(dev->priomap);
-		priority = map ? map->priomap[prioidx] : 0;
+		priority = (map && prioidx < map->priomap_len) ? map->priomap[prioidx] : 0;
 		cb->fill(cb, dev->name, priority);
 	}
 	rcu_read_unlock();
