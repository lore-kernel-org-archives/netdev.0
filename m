From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next 06/12] nfp: add stats and xmit helpers for representors
Date: Tue, 20 Jun 2017 07:51:44 +0200
Message-ID: <1497937910-32059-7-git-send-email-simon.horman@netronome.com>
References: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f179.google.com ([209.85.220.179]:33599 "EHLO
        mail-qk0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751762AbdFTFw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 01:52:29 -0400
Received: by mail-qk0-f179.google.com with SMTP id r62so49886887qkf.0
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 22:52:28 -0700 (PDT)
In-Reply-To: <1497937910-32059-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide helpers for stats and xmit on representor netdevs.

Parts based on work by Bert van Leeuwen, Benjamin LaHaise and
Jakub Kicinski.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c | 198 +++++++++++++++++++++-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.h |  28 +++
 2 files changed, 225 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index bdd34d206d22..a97bb6f2cc12 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -38,9 +38,191 @@
 #include "nfpcore/nfp_cpp.h"
 #include "nfp_app.h"
 #include "nfp_main.h"
+#include "nfp_net_ctrl.h"
 #include "nfp_net_repr.h"
 #include "nfp_port.h"
 
+static void
+nfp_repr_inc_tx_stats(struct net_device *netdev, unsigned int len,
+		      int tx_status)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+	struct nfp_repr_pcpu_stats *stats;
+
+	if (unlikely(tx_status != NET_XMIT_SUCCESS &&
+		     tx_status != NET_XMIT_CN)) {
+		this_cpu_inc(repr->stats->tx_drops);
+		return;
+	}
+
+	stats = this_cpu_ptr(repr->stats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->tx_packets++;
+	stats->tx_bytes += len;
+	u64_stats_update_end(&stats->syncp);
+}
+
+void nfp_repr_inc_rx_stats(struct net_device *netdev, unsigned int len)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+	struct nfp_repr_pcpu_stats *stats;
+
+	stats = this_cpu_ptr(repr->stats);
+	u64_stats_update_begin(&stats->syncp);
+	stats->rx_packets++;
+	stats->rx_bytes += len;
+	u64_stats_update_end(&stats->syncp);
+}
+
+void
+nfp_repr_phy_port_get_stats64(const struct nfp_app *app, u8 phy_port,
+			      struct rtnl_link_stats64 *stats)
+{
+	u8 __iomem *mem;
+
+	mem = app->pf->mac_stats_mem + phy_port * NFP_MAC_STATS_SIZE;
+
+	/* TX and RX stats are flipped as we are returning the stats as seen
+	 * at the switch port corresponding to the phys port.
+	 */
+	stats->tx_packets = readq(mem + NFP_MAC_STATS_RX_FRAMES_RECEIVED_OK);
+	stats->tx_bytes = readq(mem + NFP_MAC_STATS_RX_IN_OCTETS);
+	stats->tx_dropped = readq(mem + NFP_MAC_STATS_RX_IN_ERRORS);
+
+	stats->rx_packets = readq(mem + NFP_MAC_STATS_TX_FRAMES_TRANSMITTED_OK);
+	stats->rx_bytes = readq(mem + NFP_MAC_STATS_TX_OUT_OCTETS);
+	stats->rx_dropped = readq(mem + NFP_MAC_STATS_TX_OUT_ERRORS);
+}
+
+void
+nfp_repr_vf_get_stats64(const struct nfp_app *app, u8 vf,
+			struct rtnl_link_stats64 *stats)
+{
+	u8 __iomem *mem;
+
+	mem = app->pf->vf_cfg_mem + vf * NFP_NET_CFG_BAR_SZ;
+
+	/* TX and RX stats are flipped as we are returning the stats as seen
+	 * at the switch port corresponding to the VF.
+	 */
+	stats->tx_packets = readq(mem + NFP_NET_CFG_STATS_RX_FRAMES);
+	stats->tx_bytes = readq(mem + NFP_NET_CFG_STATS_RX_OCTETS);
+	stats->tx_dropped = readq(mem + NFP_NET_CFG_STATS_RX_DISCARDS);
+
+	stats->rx_packets = readq(mem + NFP_NET_CFG_STATS_TX_FRAMES);
+	stats->rx_bytes = readq(mem + NFP_NET_CFG_STATS_TX_OCTETS);
+	stats->rx_dropped = readq(mem + NFP_NET_CFG_STATS_TX_DISCARDS);
+}
+
+void
+nfp_repr_pf_get_stats64(const struct nfp_app *app, u8 pf,
+			struct rtnl_link_stats64 *stats)
+{
+	u8 __iomem *mem;
+
+	if (pf)
+		return;
+
+	mem = nfp_cpp_area_iomem(app->pf->data_vnic_bar);
+
+	stats->tx_packets = readq(mem + NFP_NET_CFG_STATS_RX_FRAMES);
+	stats->tx_bytes = readq(mem + NFP_NET_CFG_STATS_RX_OCTETS);
+	stats->tx_dropped = readq(mem + NFP_NET_CFG_STATS_RX_DISCARDS);
+
+	stats->rx_packets = readq(mem + NFP_NET_CFG_STATS_TX_FRAMES);
+	stats->rx_bytes = readq(mem + NFP_NET_CFG_STATS_TX_OCTETS);
+	stats->rx_dropped = readq(mem + NFP_NET_CFG_STATS_TX_DISCARDS);
+}
+
+void
+nfp_repr_get_stats64(const struct nfp_app *app, enum nfp_repr_type type,
+		     u8 port, struct rtnl_link_stats64 *stats)
+{
+	switch (type) {
+	case NFP_REPR_TYPE_PHYS_PORT:
+		nfp_repr_phy_port_get_stats64(app, port, stats);
+		break;
+	case NFP_REPR_TYPE_PF:
+		nfp_repr_pf_get_stats64(app, port, stats);
+		break;
+	case NFP_REPR_TYPE_VF:
+		nfp_repr_vf_get_stats64(app, port, stats);
+	default:
+		break;
+	}
+}
+
+bool
+nfp_repr_has_offload_stats(const struct net_device *dev, int attr_id)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return true;
+	}
+
+	return false;
+}
+
+static int
+nfp_repr_get_host_stats64(const struct net_device *netdev,
+			  struct rtnl_link_stats64 *stats)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+	int i;
+
+	for_each_possible_cpu(i) {
+		u64 tbytes, tpkts, tdrops, rbytes, rpkts;
+		struct nfp_repr_pcpu_stats *repr_stats;
+		unsigned int start;
+
+		repr_stats = per_cpu_ptr(repr->stats, i);
+		do {
+			start = u64_stats_fetch_begin_irq(&repr_stats->syncp);
+			tbytes = repr_stats->tx_bytes;
+			tpkts = repr_stats->tx_packets;
+			tdrops = repr_stats->tx_drops;
+			rbytes = repr_stats->rx_bytes;
+			rpkts = repr_stats->rx_packets;
+		} while (u64_stats_fetch_retry_irq(&repr_stats->syncp, start));
+
+		stats->tx_bytes += tbytes;
+		stats->tx_packets += tpkts;
+		stats->tx_dropped += tdrops;
+		stats->rx_bytes += rbytes;
+		stats->rx_packets += rpkts;
+	}
+
+	return 0;
+}
+
+int nfp_repr_get_offload_stats(int attr_id, const struct net_device *dev,
+			       void *stats)
+{
+	switch (attr_id) {
+	case IFLA_OFFLOAD_XSTATS_CPU_HIT:
+		return nfp_repr_get_host_stats64(dev, stats);
+	}
+
+	return -EINVAL;
+}
+
+netdev_tx_t nfp_repr_xmit(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct nfp_repr *repr = netdev_priv(netdev);
+	unsigned int len = skb->len;
+	int ret;
+
+	skb_dst_drop(skb);
+	dst_hold((struct dst_entry *)repr->dst);
+	skb_dst_set(skb, (struct dst_entry *)repr->dst);
+	skb->dev = repr->dst->u.port_info.lower_dev;
+
+	ret = dev_queue_xmit(skb);
+	nfp_repr_inc_tx_stats(netdev, len, ret);
+
+	return ret;
+}
+
 static void nfp_repr_clean(struct nfp_repr *repr)
 {
 	unregister_netdev(repr->netdev);
@@ -93,6 +275,12 @@ int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
 	return err;
 }
 
+static void nfp_repr_free(struct nfp_repr *repr)
+{
+	free_percpu(repr->stats);
+	free_netdev(repr->netdev);
+}
+
 struct net_device *nfp_repr_alloc(struct nfp_app *app)
 {
 	struct net_device *netdev;
@@ -106,7 +294,15 @@ struct net_device *nfp_repr_alloc(struct nfp_app *app)
 	repr->netdev = netdev;
 	repr->app = app;
 
+	repr->stats = netdev_alloc_pcpu_stats(struct nfp_repr_pcpu_stats);
+	if (!repr->stats)
+		goto err_free_netdev;
+
 	return netdev;
+
+err_free_netdev:
+	free_netdev(netdev);
+	return NULL;
 }
 
 static void nfp_repr_clean_and_free(struct nfp_repr *repr)
@@ -114,7 +310,7 @@ static void nfp_repr_clean_and_free(struct nfp_repr *repr)
 	nfp_info(repr->app->cpp, "Destroying Representor(%s)\n",
 		 repr->netdev->name);
 	nfp_repr_clean(repr);
-	free_netdev(repr->netdev);
+	nfp_repr_free(repr);
 }
 
 void nfp_reprs_clean_and_free(struct nfp_reprs *reprs)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
index 98064f3c2623..c5ed6611f708 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.h
@@ -49,17 +49,37 @@ struct nfp_reprs {
 };
 
 /**
+ * struct nfp_repr_pcpu_stats
+ * @rx_packets:	Received packets
+ * @rx_bytes:	Received bytes
+ * @tx_packets:	Transmitted packets
+ * @tx_bytes:	Transmitted dropped
+ * @tx_drops:	Packets dropped on transmit
+ * @syncp:	Reference count
+ */
+struct nfp_repr_pcpu_stats {
+	u64 rx_packets;
+	u64 rx_bytes;
+	u64 tx_packets;
+	u64 tx_bytes;
+	u64 tx_drops;
+	struct u64_stats_sync syncp;
+};
+
+/**
  * struct nfp_repr - priv data for representor netdevs
  * @netdev:	Back pointer to netdev
  * @dst:	Destination for packet TX
  * @port:	Port of representor
  * @app:	APP handle
+ * @stats:	Statistic of packets hitting CPU
  */
 struct nfp_repr {
 	struct net_device *netdev;
 	struct metadata_dst *dst;
 	struct nfp_port *port;
 	struct nfp_app *app;
+	struct nfp_repr_pcpu_stats __percpu *stats;
 };
 
 /**
@@ -77,6 +97,14 @@ enum nfp_repr_type {
 };
 #define NFP_REPR_TYPE_MAX (__NFP_REPR_TYPE_MAX - 1)
 
+void nfp_repr_inc_rx_stats(struct net_device *netdev, unsigned int len);
+void
+nfp_repr_get_stats64(const struct nfp_app *app, enum nfp_repr_type type,
+		     u8 port, struct rtnl_link_stats64 *stats);
+bool nfp_repr_has_offload_stats(const struct net_device *dev, int attr_id);
+int nfp_repr_get_offload_stats(int attr_id, const struct net_device *dev,
+			       void *stats);
+netdev_tx_t nfp_repr_xmit(struct sk_buff *skb, struct net_device *netdev);
 int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
 		  const struct net_device_ops *netdev_ops,
 		  u32 cmsg_port_id, struct nfp_port *port,
-- 
2.1.4
