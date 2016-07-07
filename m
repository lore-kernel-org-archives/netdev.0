From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 4/4] geneve: remove gro_cell support
Date: Thu,  7 Jul 2016 17:58:50 +0200
Message-ID: <e3d961b44dc144327a211d527b5426fe75f4735d.1467907022.git.pabeni@redhat.com>
References: <cover.1467907022.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@kernel.org>,
	Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51592 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753129AbcGGQAu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2016 12:00:50 -0400
In-Reply-To: <cover.1467907022.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO is now handled entirely by the udp_offload layer and there is no need
for trying it again at the device level. We can drop gro_cell usage,
simplifying the driver a bit, while maintaining the same performance for
TCP and improving slightly for UDP.
This basically reverts the commit 8e816df87997 ("geneve: Use GRO cells
infrastructure.")

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 drivers/net/geneve.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 5de892f..ede46a0 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -15,7 +15,6 @@
 #include <linux/etherdevice.h>
 #include <linux/hash.h>
 #include <net/dst_metadata.h>
-#include <net/gro_cells.h>
 #include <net/rtnetlink.h>
 #include <net/geneve.h>
 #include <net/protocol.h>
@@ -70,7 +69,6 @@ struct geneve_dev {
 	__be32		   label;	/* IPv6 flowlabel override */
 	__be16		   dst_port;
 	bool		   collect_md;
-	struct gro_cells   gro_cells;
 	u32		   flags;
 	struct dst_cache   dst_cache;
 };
@@ -282,7 +280,7 @@ static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	gro_cells_receive(&geneve->gro_cells, skb);
+	netif_rx(skb);
 	return;
 drop:
 	/* Consume bad packet */
@@ -299,16 +297,9 @@ static int geneve_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
-	err = gro_cells_init(&geneve->gro_cells, dev);
-	if (err) {
-		free_percpu(dev->tstats);
-		return err;
-	}
-
 	err = dst_cache_init(&geneve->dst_cache, GFP_KERNEL);
 	if (err) {
 		free_percpu(dev->tstats);
-		gro_cells_destroy(&geneve->gro_cells);
 		return err;
 	}
 
@@ -320,7 +311,6 @@ static void geneve_uninit(struct net_device *dev)
 	struct geneve_dev *geneve = netdev_priv(dev);
 
 	dst_cache_destroy(&geneve->dst_cache);
-	gro_cells_destroy(&geneve->gro_cells);
 	free_percpu(dev->tstats);
 }
 
-- 
1.8.3.1
