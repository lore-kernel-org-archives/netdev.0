From: Kevin Groeneveld <kgroeneveld@gmail.com>
Subject: [PATCH v2] ppp: add 64 bit stats
Date: Fri, 27 Jul 2012 23:38:53 -0400
Message-ID: <1343446733-4791-1-git-send-email-kgroeneveld@gmail.com>
Cc: Kevin Groeneveld <kgroeneveld@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:64460 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945Ab2G1DjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 23:39:02 -0400
Received: by ghrr11 with SMTP id r11so3834778ghr.19
        for <netdev@vger.kernel.org>; Fri, 27 Jul 2012 20:39:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 64 bit stats to ppp driver.  The 64 bit stats include tx_bytes,
rx_bytes, tx_packets and rx_packets.  Other stats are still 32 bit.
The 64 bit stats can be retrieved via the ndo_get_stats operation.  The
SIOCGPPPSTATS ioctl is still 32 bit stats only.

Signed-off-by: Kevin Groeneveld <kgroeneveld@gmail.com>
---
v2: - do not use percpu variables for stats
    - use ppp_recv_lock/ppp_xmit_lock when reading 64 bit stats

 drivers/net/ppp/ppp_generic.c |   58 ++++++++++++++++++++++++++++++++++-------
 1 file changed, 48 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 5c05572..eb3f5ce 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -94,6 +94,18 @@ struct ppp_file {
 #define PF_TO_CHANNEL(pf)	PF_TO_X(pf, struct channel)
 
 /*
+ * Data structure to hold primary network stats for which
+ * we want to use 64 bit storage.  Other network stats
+ * are stored in dev->stats of the ppp strucute.
+ */
+struct ppp_link_stats {
+	u64 rx_packets;
+	u64 tx_packets;
+	u64 rx_bytes;
+	u64 tx_bytes;
+};
+
+/*
  * Data structure describing one ppp unit.
  * A ppp unit corresponds to a ppp network interface device
  * and represents a multilink bundle.
@@ -136,6 +148,7 @@ struct ppp {
 	unsigned pass_len, active_len;
 #endif /* CONFIG_PPP_FILTER */
 	struct net	*ppp_net;	/* the net we belong to */
+	struct ppp_link_stats stats64;	/* 64 bit network stats */
 };
 
 /*
@@ -1021,9 +1034,34 @@ ppp_net_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return err;
 }
 
+struct rtnl_link_stats64*
+ppp_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats64)
+{
+	struct ppp *ppp = netdev_priv(dev);
+
+	ppp_recv_lock(ppp);
+	stats64->rx_packets = ppp->stats64.rx_packets;
+	stats64->rx_bytes   = ppp->stats64.rx_bytes;
+	ppp_recv_unlock(ppp);
+
+	ppp_xmit_lock(ppp);
+	stats64->tx_packets = ppp->stats64.tx_packets;
+	stats64->tx_bytes   = ppp->stats64.tx_bytes;
+	ppp_xmit_unlock(ppp);
+
+	stats64->rx_errors        = dev->stats.rx_errors;
+	stats64->tx_errors        = dev->stats.tx_errors;
+	stats64->rx_dropped       = dev->stats.rx_dropped;
+	stats64->tx_dropped       = dev->stats.tx_dropped;
+	stats64->rx_length_errors = dev->stats.rx_length_errors;
+
+	return stats64;
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
@@ -1157,8 +1195,8 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 #endif /* CONFIG_PPP_FILTER */
 	}
 
-	++ppp->dev->stats.tx_packets;
-	ppp->dev->stats.tx_bytes += skb->len - 2;
+	++ppp->stats64.tx_packets;
+	ppp->stats64.tx_bytes += skb->len - 2;
 
 	switch (proto) {
 	case PPP_IP:
@@ -1745,8 +1783,8 @@ ppp_receive_nonmp_frame(struct ppp *ppp, struct sk_buff *skb)
 		break;
 	}
 
-	++ppp->dev->stats.rx_packets;
-	ppp->dev->stats.rx_bytes += skb->len - 2;
+	++ppp->stats64.rx_packets;
+	ppp->stats64.rx_bytes += skb->len - 2;
 
 	npi = proto_to_npindex(proto);
 	if (npi < 0) {
@@ -2570,12 +2608,12 @@ ppp_get_stats(struct ppp *ppp, struct ppp_stats *st)
 	struct slcompress *vj = ppp->vj;
 
 	memset(st, 0, sizeof(*st));
-	st->p.ppp_ipackets = ppp->dev->stats.rx_packets;
+	st->p.ppp_ipackets = ppp->stats64.rx_packets;
 	st->p.ppp_ierrors = ppp->dev->stats.rx_errors;
-	st->p.ppp_ibytes = ppp->dev->stats.rx_bytes;
-	st->p.ppp_opackets = ppp->dev->stats.tx_packets;
+	st->p.ppp_ibytes = ppp->stats64.rx_bytes;
+	st->p.ppp_opackets = ppp->stats64.tx_packets;
 	st->p.ppp_oerrors = ppp->dev->stats.tx_errors;
-	st->p.ppp_obytes = ppp->dev->stats.tx_bytes;
+	st->p.ppp_obytes = ppp->stats64.tx_bytes;
 	if (!vj)
 		return;
 	st->vj.vjs_packets = vj->sls_o_compressed + vj->sls_o_uncompressed;
-- 
1.7.9.5
