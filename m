From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 05/12] gtp: Change to use gro_cells
Date: Sun, 24 Sep 2017 20:29:34 -0700
Message-ID: <20170925032941.14586-6-tom@quantonium.net>
References: <20170925032941.14586-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:52098 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932947AbdIYDaM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 24 Sep 2017 23:30:12 -0400
Received: by mail-pf0-f180.google.com with SMTP id b70so3138692pfl.8
        for <netdev@vger.kernel.org>; Sun, 24 Sep 2017 20:30:12 -0700 (PDT)
In-Reply-To: <20170925032941.14586-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call gro_cells_receive instead of netif_rx.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 6dabd605607c..f2aac5d01143 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -80,6 +80,8 @@ struct gtp_dev {
 	unsigned int		hash_size;
 	struct hlist_head	*tid_hash;
 	struct hlist_head	*addr_hash;
+
+	struct gro_cells	gro_cells;
 };
 
 static unsigned int gtp_net_id __read_mostly;
@@ -189,6 +191,7 @@ static bool gtp_check_ms(struct sk_buff *skb, struct pdp_ctx *pctx,
 static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
 			unsigned int hdrlen, unsigned int role)
 {
+	struct gtp_dev *gtp = netdev_priv(pctx->dev);
 	struct pcpu_sw_netstats *stats;
 
 	if (!gtp_check_ms(skb, pctx, hdrlen, role)) {
@@ -217,7 +220,8 @@ static int gtp_rx(struct pdp_ctx *pctx, struct sk_buff *skb,
 	stats->rx_bytes += skb->len;
 	u64_stats_update_end(&stats->syncp);
 
-	netif_rx(skb);
+	gro_cells_receive(&gtp->gro_cells, skb);
+
 	return 0;
 }
 
@@ -611,6 +615,8 @@ static const struct net_device_ops gtp_netdev_ops = {
 
 static void gtp_link_setup(struct net_device *dev)
 {
+	struct gtp_dev *gtp = netdev_priv(dev);
+
 	dev->netdev_ops		= &gtp_netdev_ops;
 	dev->needs_free_netdev	= true;
 
@@ -630,6 +636,8 @@ static void gtp_link_setup(struct net_device *dev)
 				  sizeof(struct iphdr) +
 				  sizeof(struct udphdr) +
 				  sizeof(struct gtp0_header);
+
+	gro_cells_init(&gtp->gro_cells, dev);
 }
 
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
@@ -686,6 +694,7 @@ static void gtp_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 
+	gro_cells_destroy(&gtp->gro_cells);
 	gtp_encap_disable(gtp);
 	gtp_hashtable_free(gtp);
 	list_del_rcu(&gtp->list);
-- 
2.11.0
