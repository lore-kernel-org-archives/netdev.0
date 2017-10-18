From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v5 net-next 05/12] gtp: Change to use gro_cells
Date: Wed, 18 Oct 2017 13:10:11 -0700
Message-ID: <20171018201018.5692-6-tom@quantonium.net>
References: <20171018201018.5692-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:56315 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdJRULI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 16:11:08 -0400
Received: by mail-pg0-f68.google.com with SMTP id 15so483153pgc.12
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 13:11:08 -0700 (PDT)
In-Reply-To: <20171018201018.5692-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call gro_cells_receive instead of netif_rx.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/Kconfig |  1 +
 drivers/net/gtp.c   | 11 ++++++++++-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 0936da592e12..720c2af0bb88 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -214,6 +214,7 @@ config GTP
 	tristate "GPRS Tunneling Protocol datapath (GTP-U)"
 	depends on INET && NET_UDP_TUNNEL
 	select NET_IP_TUNNEL
+	select GRO_CELLS
 	---help---
 	  This allows one to create gtp virtual interfaces that provide
 	  the GPRS Tunneling Protocol datapath (GTP-U). This tunneling protocol
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
