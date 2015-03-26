From: roy.qing.li@gmail.com
Subject: [PATCH] net: fix two possible memory leaks in netif_set_xps_queue
Date: Thu, 26 Mar 2015 15:40:43 +0800
Message-ID: <1427355643-10422-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org, alexander.h.duyck@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51850 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342AbbCZHkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 03:40:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

new_dev_maps->cpu_map[cpu] maybe be assigned to the memory from
expand_xps_map() in the first loop, so should be freed

when free dev_maps, make sure to free new_dev_maps->cpu_map[cpu]
firstly

Fixes: 537c00de1c [net: Add functions netif_reset_xps_queue and netif_set_xps_queue]
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/core/dev.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 5d43e01..aa6459f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2025,9 +2025,11 @@ int netif_set_xps_queue(struct net_device *dev, const struct cpumask *mask,
 		} else if (dev_maps) {
 			/* fill in the new device map from the old device map */
 			map = xmap_dereference(dev_maps->cpu_map[cpu]);
+			new_map = xmap_dereference(new_dev_maps->cpu_map[cpu]);
 			RCU_INIT_POINTER(new_dev_maps->cpu_map[cpu], map);
+			if (new_map && map != new_map)
+				kfree_rcu(new_map, rcu);
 		}
-
 	}
 
 	rcu_assign_pointer(dev->xps_maps, new_dev_maps);
@@ -2068,6 +2070,13 @@ out_no_new_maps:
 	/* free map if not active */
 	if (!active) {
 		RCU_INIT_POINTER(dev->xps_maps, NULL);
+
+		for_each_possible_cpu(cpu) {
+			map = xmap_dereference(dev_maps->cpu_map[cpu]);
+			if (map)
+				kfree_rcu(map, rcu);
+		}
+
 		kfree_rcu(dev_maps, rcu);
 	}
 
-- 
2.1.0
