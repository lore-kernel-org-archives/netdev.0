From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v7 net-next 06/13] gtp: Change to use gro_cells
Date: Fri, 27 Oct 2017 17:09:30 -0700
Message-ID: <20171028000937.2631-7-tom@quantonium.net>
References: <20171028000937.2631-1-tom@quantonium.net>
Cc: pablo@netfilter.org, laforge@gnumonks.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:56563 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751486AbdJ1AKP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 20:10:15 -0400
Received: by mail-pf0-f195.google.com with SMTP id b85so5996501pfj.13
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 17:10:15 -0700 (PDT)
In-Reply-To: <20171028000937.2631-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call gro_cells_receive instead of netif_rx.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/Kconfig |  1 +
 drivers/net/gtp.c   | 18 +++++++++++++++++-
 2 files changed, 18 insertions(+), 1 deletion(-)

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
index 6dabd605607c..265fa9fdbf3d 100644
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
 
@@ -363,6 +367,7 @@ static int gtp_encap_recv(struct sock *sk, struct sk_buff *skb)
 static int gtp_dev_init(struct net_device *dev)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
+	int err;
 
 	gtp->dev = dev;
 
@@ -370,6 +375,12 @@ static int gtp_dev_init(struct net_device *dev)
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	err = gro_cells_init(&gtp->gro_cells, dev);
+	if (err) {
+		free_percpu(dev->tstats);
+		return err;
+	}
+
 	return 0;
 }
 
@@ -611,6 +622,8 @@ static const struct net_device_ops gtp_netdev_ops = {
 
 static void gtp_link_setup(struct net_device *dev)
 {
+	struct gtp_dev *gtp = netdev_priv(dev);
+
 	dev->netdev_ops		= &gtp_netdev_ops;
 	dev->needs_free_netdev	= true;
 
@@ -630,6 +643,8 @@ static void gtp_link_setup(struct net_device *dev)
 				  sizeof(struct iphdr) +
 				  sizeof(struct udphdr) +
 				  sizeof(struct gtp0_header);
+
+	gro_cells_init(&gtp->gro_cells, dev);
 }
 
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
@@ -686,6 +701,7 @@ static void gtp_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct gtp_dev *gtp = netdev_priv(dev);
 
+	gro_cells_destroy(&gtp->gro_cells);
 	gtp_encap_disable(gtp);
 	gtp_hashtable_free(gtp);
 	list_del_rcu(&gtp->list);
-- 
2.11.0
