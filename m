From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] net: Fix locking bug in netif_set_xps_queue
Date: Fri, 22 Feb 2013 08:38:44 -0800
Message-ID: <20130222163806.7590.98066.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, davem@davemloft.net,
	dan.carpenter@oracle.com, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:53133 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757665Ab3BVQkd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Feb 2013 11:40:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Smatch found a locking bug in netif_set_xps_queue in which we were not
releasing the lock in the case of an allocation failure.

This change corrects that so that we release the xps_map_mutex before
returning -ENOMEM in the case of an allocation failure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 17bc535..18d8b5a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1882,8 +1882,10 @@ int netif_set_xps_queue(struct net_device *dev, struct cpumask *mask, u16 index)
 
 		if (!new_dev_maps)
 			new_dev_maps = kzalloc(maps_sz, GFP_KERNEL);
-		if (!new_dev_maps)
+		if (!new_dev_maps) {
+			mutex_unlock(&xps_map_mutex);
 			return -ENOMEM;
+		}
 
 		map = dev_maps ? xmap_dereference(dev_maps->cpu_map[cpu]) :
 				 NULL;
