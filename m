From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add HW timesptamp support for RX
Date: Mon, 28 Sep 2015 10:26:53 +0530
Message-ID: <1443416213-18952-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6262 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750789AbbI1E4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 00:56:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for ethtool get time stamp ioctl, which is used by
tcpdump to get the supported time stamp types

eg: tcpdump -i eth5 -J
Time stamp types for eth5 (use option -j to set):
  host (Host)
  adapter_unsynced (Adapter, not synced with system time)

Adds support for adapter unsynced mode, by adding SIOCSHWTSTAMP support
in driver. 

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  4 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 15 +++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 24 +++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sge.c           | 36 ++++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h         |  5 +++
 5 files changed, 81 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index fa0c7b5..634e50c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -47,6 +47,7 @@
 #include <linux/timer.h>
 #include <linux/vmalloc.h>
 #include <linux/etherdevice.h>
+#include <linux/net_tstamp.h>
 #include <asm/io.h>
 #include "cxgb4_uld.h"
 
@@ -478,6 +479,8 @@ struct port_info {
 #ifdef CONFIG_CHELSIO_T4_FCOE
 	struct cxgb_fcoe fcoe;
 #endif /* CONFIG_CHELSIO_T4_FCOE */
+	bool rxtstamp;  /* Enable TS */
+	struct hwtstamp_config tstamp_config;
 };
 
 struct dentry;
@@ -517,6 +520,7 @@ struct sge_fl {                     /* SGE free-buffer queue state */
 
 /* A packet gather list */
 struct pkt_gl {
+	u64 sgetstamp;		    /* SGE Time Stamp for Ingress Packet */
 	struct page_frag frags[MAX_SKB_FRAGS];
 	void *va;                         /* virtual address of first byte */
 	unsigned int nfrags;              /* # of fragments */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 5eedb98..02e4e02 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -961,6 +961,20 @@ static int set_flash(struct net_device *netdev, struct ethtool_flash *ef)
 	return ret;
 }
 
+static int get_ts_info(struct net_device *dev, struct ethtool_ts_info *ts_info)
+{
+	ts_info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+				   SOF_TIMESTAMPING_RX_SOFTWARE |
+				   SOF_TIMESTAMPING_SOFTWARE;
+
+	ts_info->so_timestamping |= SOF_TIMESTAMPING_RX_HARDWARE |
+				    SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	ts_info->phc_index = -1;
+
+	return 0;
+}
+
 static u32 get_rss_table_size(struct net_device *dev)
 {
 	const struct port_info *pi = netdev_priv(dev);
@@ -1095,6 +1109,7 @@ static const struct ethtool_ops cxgb_ethtool_ops = {
 	.get_rxfh	   = get_rss_table,
 	.set_rxfh	   = set_rss_table,
 	.flash_device      = set_flash,
+	.get_ts_info       = get_ts_info
 };
 
 void cxgb4_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f5dcde2..0b7570d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2959,6 +2959,30 @@ static int cxgb_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 			ret = t4_mdio_wr(pi->adapter, mbox, prtad, devad,
 					 data->reg_num, data->val_in);
 		break;
+	case SIOCGHWTSTAMP:
+		return copy_to_user(req->ifr_data, &pi->tstamp_config,
+				    sizeof(pi->tstamp_config)) ?
+			-EFAULT : 0;
+	case SIOCSHWTSTAMP:
+		if (copy_from_user(&pi->tstamp_config, req->ifr_data,
+				   sizeof(pi->tstamp_config)))
+			return -EFAULT;
+
+		switch (pi->tstamp_config.rx_filter) {
+		case HWTSTAMP_FILTER_NONE:
+			pi->rxtstamp = false;
+			break;
+		case HWTSTAMP_FILTER_ALL:
+			pi->rxtstamp = true;
+			break;
+		default:
+			pi->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
+			return -ERANGE;
+		}
+
+		return copy_to_user(req->ifr_data, &pi->tstamp_config,
+				    sizeof(pi->tstamp_config)) ?
+			-EFAULT : 0;
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 9162746..b7b93e7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1820,11 +1820,34 @@ static noinline int handle_trace_pkt(struct adapter *adap,
 	return 0;
 }
 
+/**
+ * cxgb4_sgetim_to_hwtstamp - convert sge time stamp to hw time stamp
+ * @adap: the adapter
+ * @hwtstamps: time stamp structure to update
+ * @sgetstamp: 60bit iqe timestamp
+ *
+ * Every ingress queue entry has the 60-bit timestamp, convert that timestamp
+ * which is in Core Clock ticks into ktime_t and assign it
+ **/
+static void cxgb4_sgetim_to_hwtstamp(struct adapter *adap,
+				     struct skb_shared_hwtstamps *hwtstamps,
+				     u64 sgetstamp)
+{
+	u64 ns;
+	u64 tmp = (sgetstamp * 1000 * 1000 + adap->params.vpd.cclk / 2);
+
+	ns = div_u64(tmp, adap->params.vpd.cclk);
+
+	memset(hwtstamps, 0, sizeof(*hwtstamps));
+	hwtstamps->hwtstamp = ns_to_ktime(ns);
+}
+
 static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 		   const struct cpl_rx_pkt *pkt)
 {
 	struct adapter *adapter = rxq->rspq.adap;
 	struct sge *s = &adapter->sge;
+	struct port_info *pi;
 	int ret;
 	struct sk_buff *skb;
 
@@ -1842,6 +1865,10 @@ static void do_gro(struct sge_eth_rxq *rxq, const struct pkt_gl *gl,
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rxq->rspq.idx);
 	skb_mark_napi_id(skb, &rxq->rspq.napi);
+	pi = netdev_priv(skb->dev);
+	if (pi->rxtstamp)
+		cxgb4_sgetim_to_hwtstamp(adapter, skb_hwtstamps(skb),
+					 gl->sgetstamp);
 	if (rxq->rspq.netdev->features & NETIF_F_RXHASH)
 		skb_set_hash(skb, (__force u32)pkt->rsshdr.hash_val,
 			     PKT_HASH_TYPE_L3);
@@ -1877,9 +1904,7 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 	struct sge *s = &q->adap->sge;
 	int cpl_trace_pkt = is_t4(q->adap->params.chip) ?
 			    CPL_TRACE_PKT : CPL_TRACE_PKT_T5;
-#ifdef CONFIG_CHELSIO_T4_FCOE
 	struct port_info *pi;
-#endif
 
 	if (unlikely(*(u8 *)rsp == cpl_trace_pkt))
 		return handle_trace_pkt(q->adap, si);
@@ -1910,6 +1935,10 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 
 	rxq->stats.pkts++;
 
+	pi = netdev_priv(skb->dev);
+	if (pi->rxtstamp)
+		cxgb4_sgetim_to_hwtstamp(q->adap, skb_hwtstamps(skb),
+					 si->sgetstamp);
 	if (csum_ok && (pkt->l2info & htonl(RXF_UDP_F | RXF_TCP_F))) {
 		if (!pkt->ip_frag) {
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
@@ -1926,7 +1955,6 @@ int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 #define CPL_RX_PKT_FLAGS (RXF_PSH_F | RXF_SYN_F | RXF_UDP_F | \
 			  RXF_TCP_F | RXF_IP_F | RXF_IP6_F | RXF_LRO_F)
 
-		pi = netdev_priv(skb->dev);
 		if (!(pkt->l2info & cpu_to_be32(CPL_RX_PKT_FLAGS))) {
 			if ((pkt->l2info & cpu_to_be32(RXF_FCOE_F)) &&
 			    (pi->fcoe.flags & CXGB_FCOE_ENABLED)) {
@@ -2067,6 +2095,8 @@ static int process_responses(struct sge_rspq *q, int budget)
 				unmap_rx_buf(q->adap, &rxq->fl);
 			}
 
+			si.sgetstamp = SGE_TIMESTAMP_G(
+					be64_to_cpu(rc->last_flit));
 			/*
 			 * Last buffer remains mapped so explicitly make it
 			 * coherent for CPU access.
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
index 640369d..13708fd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
@@ -263,4 +263,9 @@ enum {
 #undef FLASH_START
 #undef FLASH_MAX_SIZE
 
+#define SGE_TIMESTAMP_S 0
+#define SGE_TIMESTAMP_M 0xfffffffffffffffULL
+#define SGE_TIMESTAMP_V(x) ((__u64)(x) << SGE_TIMESTAMP_S)
+#define SGE_TIMESTAMP_G(x) (((__u64)(x) >> SGE_TIMESTAMP_S) & SGE_TIMESTAMP_M)
+
 #endif /* __T4_HW_H */
-- 
2.3.4
