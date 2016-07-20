From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next 2/2] macsec: enable GRO and RPS on macsec devices
Date: Wed, 20 Jul 2016 18:11:32 +0200
Message-ID: <801ea10bbeb01dd455737e9d199974a3969507cf.1469030596.git.pabeni@redhat.com>
References: <cover.1469030596.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sabrina Dubroca <sd@queasysnail.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37254 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755108AbcGTQMY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 12:12:24 -0400
In-Reply-To: <cover.1469030596.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use gro_gells to trigger GRO and allow RPS on macsec traffic
after decryption.
Also, be sure to avoid clearing software offload features in
macsec_fix_features().
Overall this increase TCP tput by 30% on recent h/w.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/macsec.c | 32 +++++++++++++++++++++++++-------
 1 file changed, 25 insertions(+), 7 deletions(-)

diff --git a/drivers/net/macsec.c b/drivers/net/macsec.c
index 8bcd78f..0cbb935 100644
--- a/drivers/net/macsec.c
+++ b/drivers/net/macsec.c
@@ -18,6 +18,7 @@
 #include <linux/rtnetlink.h>
 #include <net/genetlink.h>
 #include <net/sock.h>
+#include <net/gro_cells.h>
 
 #include <uapi/linux/if_macsec.h>
 
@@ -268,6 +269,7 @@ struct macsec_dev {
 	struct net_device *real_dev;
 	struct pcpu_secy_stats __percpu *stats;
 	struct list_head secys;
+	struct gro_cells gro_cells;
 };
 
 /**
@@ -879,7 +881,7 @@ static void macsec_decrypt_done(struct crypto_async_request *base, int err)
 	macsec_reset_skb(skb, macsec->secy.netdev);
 
 	len = skb->len;
-	ret = netif_rx(skb);
+	ret = gro_cells_receive(&macsec->gro_cells, skb);
 	if (ret == NET_RX_SUCCESS)
 		count_rx(dev, len);
 	else
@@ -1052,6 +1054,7 @@ static rx_handler_result_t macsec_handle_frame(struct sk_buff **pskb)
 	struct pcpu_rx_sc_stats *rxsc_stats;
 	struct pcpu_secy_stats *secy_stats;
 	bool pulled_sci;
+	int ret;
 
 	if (skb_headroom(skb) < ETH_HLEN)
 		goto drop_direct;
@@ -1193,12 +1196,17 @@ deliver:
 
 	if (rx_sa)
 		macsec_rxsa_put(rx_sa);
-	count_rx(dev, skb->len);
+
+	ret = gro_cells_receive(&macsec->gro_cells, skb);
+	if (ret == NET_RX_SUCCESS)
+		count_rx(dev, skb->len);
+	else
+		macsec->secy.netdev->stats.rx_dropped++;
 
 	rcu_read_unlock();
 
-	*pskb = skb;
-	return RX_HANDLER_ANOTHER;
+	*pskb = NULL;
+	return RX_HANDLER_CONSUMED;
 
 drop:
 	macsec_rxsa_put(rx_sa);
@@ -1218,7 +1226,6 @@ nosci:
 
 	list_for_each_entry_rcu(macsec, &rxd->secys, secys) {
 		struct sk_buff *nskb;
-		int ret;
 
 		secy_stats = this_cpu_ptr(macsec->stats);
 
@@ -2675,11 +2682,18 @@ static int macsec_dev_init(struct net_device *dev)
 {
 	struct macsec_dev *macsec = macsec_priv(dev);
 	struct net_device *real_dev = macsec->real_dev;
+	int err;
 
 	dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
 	if (!dev->tstats)
 		return -ENOMEM;
 
+	err = gro_cells_init(&macsec->gro_cells, dev);
+	if (err) {
+		free_percpu(dev->tstats);
+		return err;
+	}
+
 	dev->features = real_dev->features & MACSEC_FEATURES;
 	dev->features |= NETIF_F_LLTX | NETIF_F_GSO_SOFTWARE;
 
@@ -2698,6 +2712,9 @@ static int macsec_dev_init(struct net_device *dev)
 
 static void macsec_dev_uninit(struct net_device *dev)
 {
+	struct macsec_dev *macsec = macsec_priv(dev);
+
+	gro_cells_destroy(&macsec->gro_cells);
 	free_percpu(dev->tstats);
 }
 
@@ -2707,8 +2724,9 @@ static netdev_features_t macsec_fix_features(struct net_device *dev,
 	struct macsec_dev *macsec = macsec_priv(dev);
 	struct net_device *real_dev = macsec->real_dev;
 
-	features &= real_dev->features & MACSEC_FEATURES;
-	features |= NETIF_F_LLTX | NETIF_F_GSO_SOFTWARE;
+	features &= (real_dev->features & MACSEC_FEATURES) |
+		    NETIF_F_GSO_SOFTWARE | NETIF_F_SOFT_FEATURES;
+	features |= NETIF_F_LLTX;
 
 	return features;
 }
-- 
1.8.3.1
