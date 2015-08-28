From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH] geneve: Use GRO cells infrastructure.
Date: Fri, 28 Aug 2015 16:54:40 -0700
Message-ID: <1440806080-126757-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:32995 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752824AbbH1Xyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 19:54:45 -0400
Received: by pacgr6 with SMTP id gr6so3886137pac.0
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 16:54:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Geneve can benefit from GRO at the device level in a manner similar
to other tunnels, especially as hardware offloads are still emerging.

After this patch, aggregated frames are seen on the tunnel interface.
Single stream throughput nearly doubles in ideal circumstances (on
old hardware).

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 drivers/net/geneve.c | 17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 4357bae..cbb30fc 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -16,6 +16,7 @@
 #include <linux/etherdevice.h>
 #include <linux/hash.h>
 #include <net/dst_metadata.h>
+#include <net/gro_cells.h>
 #include <net/rtnetlink.h>
 #include <net/geneve.h>
 #include <net/protocol.h>
@@ -58,6 +59,7 @@ struct geneve_dev {
 	struct list_head   next;	/* geneve's per namespace list */
 	__be16		   dst_port;
 	bool		   collect_md;
+	struct gro_cells   gro_cells;
 };
 
 struct geneve_sock {
@@ -199,7 +201,7 @@ static void geneve_rx(struct geneve_sock *gs, struct sk_buff *skb)
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	netif_rx(skb);
+	gro_cells_receive(&geneve->gro_cells, skb);
 	return;
 drop:
 	/* Consume bad packet */
@@ -209,14 +211,27 @@ drop:
 /* Setup stats when device is created */
 static int geneve_init(struct net_device *dev)
 {
+	struct geneve_dev *geneve = netdev_priv(dev);
+	int err;
+
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
+
+	err = gro_cells_init(&geneve->gro_cells, dev);
+	if (err) {
+		free_percpu(dev->tstats);
+		return err;
+	}
+
 	return 0;
 }
 
 static void geneve_uninit(struct net_device *dev)
 {
+	struct geneve_dev *geneve = netdev_priv(dev);
+
+	gro_cells_destroy(&geneve->gro_cells);
 	free_percpu(dev->tstats);
 }
 
-- 
2.1.4
