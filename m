From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: [PATCH] ppp: add 64 bit stats
Date: Sun, 22 Jul 2012 16:19:56 -0400
Message-ID: <1342988397-3077-1-git-send-email-kgroeneveld@gmail.com>
Cc: Kevin Groeneveld <kgroeneveld@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:51141 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab2GVUUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 16:20:11 -0400
Received: by obbuo13 with SMTP id uo13so8378023obb.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 13:20:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
rx_bytes, tx_packets and rx_packets.  Other stats are still 32 bit.
The 64 bit stats can be retrieved via the ndo_get_stats operation.  The
SIOCGPPPSTATS ioctl is still 32 bit stats only.

Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
---
 drivers/net/ppp/ppp_generic.c |  110 +++++++++++++++++++++++++++++++++++------
 1 file changed, 95 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 5c05572..210238c 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -94,6 +94,19 @@ struct ppp_file {
 #define PF_TO_CHANNEL(pf)	PF_TO_X(pf, struct channel)
 
 /*
+ * Data structure to hold primary network stats for which
+ * we want to use 64 bit storage.  Other network stats
+ * are stored in dev->stats of the ppp strucute.
+ */
+struct ppp_link_stats {
+	struct u64_stats_sync syncp;
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 rx_bytes;
+	u64 rx_packets;
+};
+
+/*
  * Data structure describing one ppp unit.
  * A ppp unit corresponds to a ppp network interface device
  * and represents a multilink bundle.
@@ -136,6 +149,7 @@ struct ppp {
 	unsigned pass_len, active_len;
 #endif /* CONFIG_PPP_FILTER */
 	struct net	*ppp_net;	/* the net we belong to */
+	struct ppp_link_stats __percpu *stats;	/* 64 bit network stats */
 };
 
 /*
@@ -1021,9 +1035,45 @@ ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
+struct rtnl_link_stats64*
+ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *tot)
+{
+	struct ppp *ppp = netdev_priv(dev);
+	int cpu;
+
+	for_each_possible_cpu(cpu) {
+		struct ppp_link_stats *stats = per_cpu_ptr(ppp->stats, cpu);
+		unsigned int start;
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&stats->syncp);
+			rx_packets = stats->rx_packets;
+			tx_packets = stats->tx_packets;
+			rx_bytes   = stats->rx_bytes;
+			tx_bytes   = stats->tx_bytes;
+
+		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+	}
+
+	tot->rx_errors        = dev->stats.rx_errors;
+	tot->tx_errors        = dev->stats.tx_errors;
+	tot->rx_dropped       = dev->stats.rx_dropped;
+	tot->tx_dropped       = dev->stats.tx_dropped;
+	tot->rx_length_errors = dev->stats.rx_length_errors;
+
+	return tot;
+}
+
 static const struct net_device_ops ppp_netdev_ops = {
-	.ndo_start_xmit = ppp_start_xmit,
-	.ndo_do_ioctl   = ppp_net_ioctl,
+	.ndo_start_xmit  = ppp_start_xmit,
+	.ndo_do_ioctl    = ppp_net_ioctl,
+	.ndo_get_stats64 = ppp_get_stats64,
 };
 
 static void ppp_setup(struct net_device *dev)
@@ -1130,6 +1180,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	struct sk_buff *new_skb;
 	int len;
 	unsigned char *cp;
+	struct ppp_link_stats *stats = this_cpu_ptr(ppp->stats);
 
 	if (proto < 0x8000) {
 #ifdef CONFIG_PPP_FILTER
@@ -1157,8 +1208,10 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 #endif /* CONFIG_PPP_FILTER */
 	}
 
-	++ppp->dev->stats.tx_packets;
-	ppp->dev->stats.tx_bytes += skb->len - 2;
+	u64_stats_update_begin(&stats->syncp);
+	++stats->tx_packets;
+	stats->tx_bytes += skb->len - 2;
+	u64_stats_update_end(&stats->syncp);
 
 	switch (proto) {
 	case PPP_IP:
@@ -1673,6 +1726,7 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 {
 	struct sk_buff *ns;
 	int proto, len, npi;
+	struct ppp_link_stats *stats = this_cpu_ptr(ppp->stats);
 
 	/*
 	 * Decompress the frame, if compressed.
@@ -1745,8 +1799,10 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 		break;
 	}
 
-	++ppp->dev->stats.rx_packets;
-	ppp->dev->stats.rx_bytes += skb->len - 2;
+	u64_stats_update_begin(&stats->syncp);
+	++stats->rx_packets;
+	stats->rx_bytes += skb->len - 2;
+	u64_stats_update_end(&stats->syncp);
 
 	npi = proto_to_npindex(proto);
 	if (npi < 0) {
@@ -2568,14 +2624,32 @@ static void
 ppp_get_stats(struct ppp *ppp, struct ppp_stats *st)
 {
 	struct slcompress *vj = ppp->vj;
+	int cpu;
 
 	memset(st, 0, sizeof(*st));
-	st->p.ppp_ipackets = ppp->dev->stats.rx_packets;
+
+	for_each_possible_cpu(cpu) {
+		struct ppp_link_stats *stats = per_cpu_ptr(ppp->stats, cpu);
+		unsigned int start;
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&stats->syncp);
+			rx_packets = stats->rx_packets;
+			tx_packets = stats->tx_packets;
+			rx_bytes   = stats->rx_bytes;
+			tx_bytes   = stats->tx_bytes;
+
+		} while (u64_stats_fetch_retry_bh(&stats->syncp, start));
+
+		st->p.ppp_ipackets += rx_packets;
+		st->p.ppp_opackets += tx_packets;
+		st->p.ppp_ibytes   += rx_bytes;
+		st->p.ppp_obytes   += tx_bytes;
+	}
+
 	st->p.ppp_ierrors = ppp->dev->stats.rx_errors;
-	st->p.ppp_ibytes = ppp->dev->stats.rx_bytes;
-	st->p.ppp_opackets = ppp->dev->stats.tx_packets;
 	st->p.ppp_oerrors = ppp->dev->stats.tx_errors;
-	st->p.ppp_obytes = ppp->dev->stats.tx_bytes;
 	if (!vj)
 		return;
 	st->vj.vjs_packets = vj->sls_o_compressed + vj->sls_o_uncompressed;
@@ -2627,6 +2701,9 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 	ppp->minseq = -1;
 	skb_queue_head_init(&ppp->mrq);
 #endif /* CONFIG_PPP_MULTILINK */
+	ppp->stats = alloc_percpu(struct ppp_link_stats);
+	if (ppp->stats == NULL)
+		goto out2;
 
 	/*
 	 * drum roll: don't forget to set
@@ -2640,12 +2717,12 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 		unit = unit_get(&pn->units_idr, ppp);
 		if (unit < 0) {
 			ret = unit;
-			goto out2;
+			goto out3;
 		}
 	} else {
 		ret = -EEXIST;
 		if (unit_find(&pn->units_idr, unit))
-			goto out2; /* unit already exists */
+			goto out3; /* unit already exists */
 		/*
 		 * if caller need a specified unit number
 		 * lets try to satisfy him, otherwise --
@@ -2657,7 +2734,7 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 		 */
 		unit = unit_set(&pn->units_idr, ppp, unit);
 		if (unit < 0)
-			goto out2;
+			goto out3;
 	}
 
 	/* Initialize the new ppp unit */
@@ -2669,7 +2746,7 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 		unit_put(&pn->units_idr, unit);
 		netdev_err(ppp->dev, "PPP: couldn't register device %s (%d)\n",
 			   dev->name, ret);
-		goto out2;
+		goto out3;
 	}
 
 	ppp->ppp_net = net;
@@ -2680,8 +2757,10 @@ ppp_create_interface(struct net *net, int unit, int *retp)
 	*retp = 0;
 	return ppp;
 
-out2:
+out3:
 	mutex_unlock(&pn->all_ppp_mutex);
+	free_percpu(ppp->stats);
+out2:
 	free_netdev(dev);
 out1:
 	*retp = ret;
@@ -2765,6 +2844,7 @@ static void ppp_destroy_interface(struct ppp *ppp)
 
 	kfree_skb(ppp->xmit_pending);
 
+	free_percpu(ppp->stats);
 	free_netdev(ppp->dev);
 }
 
-- 
1.7.9.5
