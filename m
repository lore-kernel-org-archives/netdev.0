From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v7 net-next 01/13] vxlan: Move gro_cells_init to ndo_init
Date: Fri, 27 Oct 2017 17:09:25 -0700
Message-ID: <20171028000937.2631-2-tom@quantonium.net>
References: <20171028000937.2631-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:53729 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdJ1AKB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:10:01 -0400
Received: by mail-pf0-f193.google.com with SMTP id t188so6003014pfd.10
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:10:01 -0700 (PDT)
In-Reply-To: <20171028000937.2631-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move gro_cells_init to ndo_init and properly check return value.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/vxlan.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index d7c49cf1d5e9..a54dd3d2a824 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2392,10 +2392,19 @@ static void vxlan_vs_add_dev(struct vxlan_sock *vs, struct vxlan_dev *vxlan,
 /* Setup stats when device is created */
 static int vxlan_init(struct net_device *dev)
 {
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	int err;
+
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	err = gro_cells_init(&vxlan->gro_cells, dev);
+	if (err) {
+		free_percpu(dev->tstats);
+		return err;
+	}
+
 	return 0;
 }
 
@@ -2653,8 +2662,6 @@ static void vxlan_setup(struct net_device *dev)
 
 	vxlan->dev = dev;
 
-	gro_cells_init(&vxlan->gro_cells, dev);
-
 	for (h = 0; h < FDB_HASH_SIZE; ++h)
 		INIT_HLIST_HEAD(&vxlan->fdb_head[h]);
 }
-- 
2.11.0
