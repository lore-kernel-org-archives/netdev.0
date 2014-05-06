From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next] enic: Add support for adaptive interrupt coalescing
Date: Tue,  6 May 2014 19:54:22 +0530
Message-ID: <1399386262-20769-1-git-send-email-_govind@gmx.com>
Cc: Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Christian Benvenuti <benve@cisco.com>,
	Neel Patel <neepatel@cisco.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:53248 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754825AbaEFOaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2014 10:30:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sujith Sankar <ssujith@cisco.com>

Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
Cc: Christian Benvenuti <benve@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h         |  30 +++++
 drivers/net/ethernet/cisco/enic/enic_dev.h     |   2 +
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |  67 +++++++++-
 drivers/net/ethernet/cisco/enic/enic_main.c    | 168 +++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_cq.h      |   8 ++
 5 files changed, 269 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index e35c8e0..fe74021 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -43,6 +43,8 @@
 #define ENIC_CQ_MAX		(ENIC_WQ_MAX + ENIC_RQ_MAX)
 #define ENIC_INTR_MAX		(ENIC_CQ_MAX + 2)
 
+#define ENIC_AIC_LARGE_PKT_DIFF	3
+
 struct enic_msix_entry {
 	int requested;
 	char devname[IFNAMSIZ];
@@ -50,6 +52,33 @@ struct enic_msix_entry {
 	void *devid;
 };
 
+/* Store only the lower range.  Higher range is given by fw. */
+struct enic_intr_mod_range {
+	u32 small_pkt_range_start;
+	u32 large_pkt_range_start;
+};
+
+struct enic_intr_mod_table {
+	u32 rx_rate;
+	u32 range_percent;
+};
+
+#define ENIC_MAX_LINK_SPEEDS		3
+#define ENIC_LINK_SPEED_10G		10000
+#define ENIC_LINK_SPEED_4G		4000
+#define ENIC_LINK_40G_INDEX		2
+#define ENIC_LINK_10G_INDEX		1
+#define ENIC_LINK_4G_INDEX		0
+#define ENIC_RX_COALESCE_RANGE_END	125
+
+struct enic_rx_coal {
+	u32 small_pkt_range_start;
+	u32 large_pkt_range_start;
+	u32 range_end;
+	u32 use_adaptive_rx_coalesce;
+	struct hrtimer ts_timer;
+};
+
 /* priv_flags */
 #define ENIC_SRIOV_ENABLED		(1 << 0)
 
@@ -92,6 +121,7 @@ struct enic {
 	unsigned int mc_count;
 	unsigned int uc_count;
 	u32 port_mtu;
+	struct enic_rx_coal rx_coalesce_setting;
 	u32 rx_coalesce_usecs;
 	u32 tx_coalesce_usecs;
 #ifdef CONFIG_PCI_IOV
diff --git a/drivers/net/ethernet/cisco/enic/enic_dev.h b/drivers/net/ethernet/cisco/enic/enic_dev.h
index 129b14a..7fac532 100644
--- a/drivers/net/ethernet/cisco/enic/enic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/enic_dev.h
@@ -62,4 +62,6 @@ int enic_dev_enable2(struct enic *enic, int arg);
 int enic_dev_enable2_done(struct enic *enic, int *status);
 int enic_dev_status_to_errno(int devcmd_status);
 
+struct vic_provinfo;
+
 #endif /* _ENIC_DEV_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 47e3562..f7e0e30 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -79,6 +79,17 @@ static const struct enic_stat enic_rx_stats[] = {
 static const unsigned int enic_n_tx_stats = ARRAY_SIZE(enic_tx_stats);
 static const unsigned int enic_n_rx_stats = ARRAY_SIZE(enic_rx_stats);
 
+void enic_intr_coal_set_rx(struct enic *enic, u32 timer)
+{
+	int i;
+	int intr;
+
+	for (i = 0; i < enic->rq_count; i++) {
+		intr = enic_msix_rq_intr(enic, i);
+		vnic_intr_coalescing_timer_set(&enic->intr[intr], timer);
+	}
+}
+
 static int enic_get_settings(struct net_device *netdev,
 	struct ethtool_cmd *ecmd)
 {
@@ -178,9 +189,14 @@ static int enic_get_coalesce(struct net_device *netdev,
 	struct ethtool_coalesce *ecmd)
 {
 	struct enic *enic = netdev_priv(netdev);
+	struct enic_rx_coal *rxcoal = &enic->rx_coalesce_setting;
 
 	ecmd->tx_coalesce_usecs = enic->tx_coalesce_usecs;
 	ecmd->rx_coalesce_usecs = enic->rx_coalesce_usecs;
+	if (rxcoal->use_adaptive_rx_coalesce)
+		ecmd->use_adaptive_rx_coalesce = 1;
+	ecmd->rx_coalesce_usecs_low = rxcoal->small_pkt_range_start;
+	ecmd->rx_coalesce_usecs_high = rxcoal->range_end;
 
 	return 0;
 }
@@ -191,17 +207,32 @@ static int enic_set_coalesce(struct net_device *netdev,
 	struct enic *enic = netdev_priv(netdev);
 	u32 tx_coalesce_usecs;
 	u32 rx_coalesce_usecs;
+	u32 rx_coalesce_usecs_low;
+	u32 rx_coalesce_usecs_high;
+	u32 coalesce_usecs_max;
+	ktime_t ktime;
 	unsigned int i, intr;
+	struct enic_rx_coal *rxcoal = &enic->rx_coalesce_setting;
 
+	coalesce_usecs_max = vnic_dev_get_intr_coal_timer_max(enic->vdev);
 	tx_coalesce_usecs = min_t(u32, ecmd->tx_coalesce_usecs,
-		vnic_dev_get_intr_coal_timer_max(enic->vdev));
+				  coalesce_usecs_max);
 	rx_coalesce_usecs = min_t(u32, ecmd->rx_coalesce_usecs,
-		vnic_dev_get_intr_coal_timer_max(enic->vdev));
+				  coalesce_usecs_max);
+
+	rx_coalesce_usecs_low = min_t(u32, ecmd->rx_coalesce_usecs_low,
+				      coalesce_usecs_max);
+	rx_coalesce_usecs_high = min_t(u32, ecmd->rx_coalesce_usecs_high,
+				       coalesce_usecs_max);
 
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	case VNIC_DEV_INTR_MODE_INTX:
 		if (tx_coalesce_usecs != rx_coalesce_usecs)
 			return -EINVAL;
+		if (ecmd->use_adaptive_rx_coalesce	||
+		    ecmd->rx_coalesce_usecs_low		||
+		    ecmd->rx_coalesce_usecs_high)
+			return -EOPNOTSUPP;
 
 		intr = enic_legacy_io_intr();
 		vnic_intr_coalescing_timer_set(&enic->intr[intr],
@@ -210,6 +241,10 @@ static int enic_set_coalesce(struct net_device *netdev,
 	case VNIC_DEV_INTR_MODE_MSI:
 		if (tx_coalesce_usecs != rx_coalesce_usecs)
 			return -EINVAL;
+		if (ecmd->use_adaptive_rx_coalesce	||
+		    ecmd->rx_coalesce_usecs_low		||
+		    ecmd->rx_coalesce_usecs_high)
+			return -EOPNOTSUPP;
 
 		vnic_intr_coalescing_timer_set(&enic->intr[0],
 			tx_coalesce_usecs);
@@ -221,12 +256,32 @@ static int enic_set_coalesce(struct net_device *netdev,
 				tx_coalesce_usecs);
 		}
 
-		for (i = 0; i < enic->rq_count; i++) {
-			intr = enic_msix_rq_intr(enic, i);
-			vnic_intr_coalescing_timer_set(&enic->intr[intr],
-				rx_coalesce_usecs);
+		if (rxcoal->use_adaptive_rx_coalesce) {
+			if (!ecmd->use_adaptive_rx_coalesce) {
+				rxcoal->use_adaptive_rx_coalesce = 0;
+				hrtimer_cancel(&rxcoal->ts_timer);
+				enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
+			}
+		} else {
+			if (ecmd->use_adaptive_rx_coalesce) {
+				rxcoal->use_adaptive_rx_coalesce = 1;
+				ktime = ktime_set(KTIME_SEC_MAX, 0);
+				hrtimer_start(&rxcoal->ts_timer, ktime,
+					      HRTIMER_MODE_REL);
+			} else {
+				enic_intr_coal_set_rx(enic, rx_coalesce_usecs);
+			}
 		}
 
+		if (ecmd->rx_coalesce_usecs_high) {
+			if (rx_coalesce_usecs_high <
+			    (rx_coalesce_usecs_low + ENIC_AIC_LARGE_PKT_DIFF))
+				return -EINVAL;
+			rxcoal->range_end = rx_coalesce_usecs_high;
+			rxcoal->small_pkt_range_start = rx_coalesce_usecs_low;
+			rxcoal->large_pkt_range_start = rx_coalesce_usecs_low +
+							ENIC_AIC_LARGE_PKT_DIFF;
+		}
 		break;
 	default:
 		break;
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 2945718..289e7be 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -38,6 +38,8 @@
 #include <linux/rtnetlink.h>
 #include <linux/prefetch.h>
 #include <net/ip6_checksum.h>
+#include <linux/hrtimer.h>
+#include <linux/ktime.h>
 
 #include "cq_enet_desc.h"
 #include "vnic_dev.h"
@@ -72,6 +74,35 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, enic_id_table);
 
+#define ENIC_LARGE_PKT_THRESHOLD		1000
+#define ENIC_MAX_COALESCE_TIMERS		10
+/*  Interrupt moderation table, which will be used to decide the
+ *  coalescing timer values
+ *  {rx_rate in Mbps, mapping percentage of the range}
+ */
+struct enic_intr_mod_table mod_table[ENIC_MAX_COALESCE_TIMERS + 1] = {
+	{4000,  0},
+	{4400, 10},
+	{5060, 20},
+	{5230, 30},
+	{5540, 40},
+	{5820, 50},
+	{6120, 60},
+	{6435, 70},
+	{6745, 80},
+	{7000, 90},
+	{0xFFFFFFFF, 100}
+};
+
+/* This table helps the driver to pick different ranges for rx coalescing
+ * timer depending on the link speed.
+ */
+struct enic_intr_mod_range mod_range[ENIC_MAX_LINK_SPEEDS] = {
+	{0,  0}, /* 0  - 4  Gbps */
+	{0,  3}, /* 4  - 10 Gbps */
+	{3,  6}, /* 10 - 40 Gbps */
+};
+
 int enic_is_dynamic(struct enic *enic)
 {
 	return enic->pdev->device == PCI_DEVICE_ID_CISCO_VIC_ENET_DYN;
@@ -979,6 +1010,15 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	return 0;
 }
 
+static void enic_intr_update_pkt_size(struct vnic_rx_bytes_counter *pkt_size,
+				      u32 pkt_len)
+{
+	if (ENIC_LARGE_PKT_THRESHOLD <= pkt_len)
+		pkt_size->large_pkt_bytes_cnt += pkt_len;
+	else
+		pkt_size->small_pkt_bytes_cnt += pkt_len;
+}
+
 static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
 	int skipped, void *opaque)
@@ -986,6 +1026,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	struct enic *enic = vnic_dev_priv(rq->vdev);
 	struct net_device *netdev = enic->netdev;
 	struct sk_buff *skb;
+	struct vnic_cq *cq = &enic->cq[enic_cq_rq(enic, rq->index)];
 
 	u8 type, color, eop, sop, ingress_port, vlan_stripped;
 	u8 fcoe, fcoe_sof, fcoe_fc_crc_ok, fcoe_enc_error, fcoe_eof;
@@ -1056,6 +1097,9 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 			napi_gro_receive(&enic->napi[q_number], skb);
 		else
 			netif_receive_skb(skb);
+		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
+			enic_intr_update_pkt_size(&cq->pkt_size_counter,
+						  bytes_written);
 	} else {
 
 		/* Buffer overflow
@@ -1134,6 +1178,65 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	return rq_work_done;
 }
 
+enum hrtimer_restart enic_hrtimer_cb(struct hrtimer *timer)
+{
+	return HRTIMER_RESTART;
+}
+
+static void enic_apply_int_moderation(struct enic *enic, struct vnic_rq *rq)
+{
+	struct enic_rx_coal *rx_coal = &enic->rx_coalesce_setting;
+	unsigned int intr = enic_msix_rq_intr(enic, rq->index);
+	struct vnic_cq *cq = &enic->cq[enic_cq_rq(enic, rq->index)];
+	struct vnic_rx_bytes_counter *pkt_size_counter = &cq->pkt_size_counter;
+	int index;
+	u32 timer;
+	u32 range_start;
+	u32 traffic;
+	u64 delta;
+	ktime_t now = hrtimer_cb_get_time(&enic->rx_coalesce_setting.ts_timer);
+
+	delta = ktime_us_delta(now, cq->prev_ts);
+	if (!delta)
+		return;
+	cq->prev_ts = now;
+
+	traffic = pkt_size_counter->large_pkt_bytes_cnt +
+		  pkt_size_counter->small_pkt_bytes_cnt;
+	/* The table takes Mbps
+	 * traffic *= 8    => bits
+	 * traffic *= (10^6 / delta)    => bps
+	 * traffic /= 10^6     => Mbps
+	 *
+	 * Combining, traffic *= (8 / delta)
+	 */
+
+	traffic <<= 3;
+	traffic = traffic/delta;
+
+	for (index = 0; index < ENIC_MAX_COALESCE_TIMERS; index++)
+		if (traffic < mod_table[index].rx_rate)
+			break;
+	range_start = (pkt_size_counter->small_pkt_bytes_cnt >
+		       pkt_size_counter->large_pkt_bytes_cnt << 1) ?
+		      rx_coal->small_pkt_range_start :
+		      rx_coal->large_pkt_range_start;
+	timer = range_start + ((rx_coal->range_end - range_start) *
+			       mod_table[index].range_percent / 100);
+
+	if (timer != cq->cur_rx_coal_timeval) {
+		/* Damping */
+		timer = (timer + cq->cur_rx_coal_timeval) >> 1;
+		vnic_intr_coalescing_timer_set(&enic->intr[intr], timer);
+		cq->cur_rx_coal_timeval = timer;
+	}
+
+	pkt_size_counter->large_pkt_bytes_cnt = 0;
+	pkt_size_counter->small_pkt_bytes_cnt = 0;
+
+	return;
+}
+
 static int enic_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct net_device *netdev = napi->dev;
@@ -1182,6 +1285,14 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 		vnic_intr_unmask(&enic->intr[intr]);
 	}
 
+	if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
+		/* Call the function which refreshes
+		 * the intr coalescing timer value based on
+		 * the traffic.  This is supported only in
+		 * the case of MSI-x mode
+		 */
+		enic_apply_int_moderation(enic, &enic->rq[rq]);
+
 	return work_done;
 }
 
@@ -1314,6 +1425,44 @@ static void enic_synchronize_irqs(struct enic *enic)
 	}
 }
 
+static int enic_set_rx_coal_setting(struct enic *enic)
+{
+	unsigned int speed;
+	int index = -1;
+	struct enic_rx_coal *rx_coal = &enic->rx_coalesce_setting;
+
+	/* If intr mode is not MSIX, do not do adaptive coalescing */
+	if (VNIC_DEV_INTR_MODE_MSIX != vnic_dev_get_intr_mode(enic->vdev)) {
+		netdev_info(enic->netdev, "INTR mode is not MSIX, Not initializing adaptive coalescing");
+		return 1;
+	}
+
+	/* 1. Read the link speed from fw
+	 * 2. Pick the default range for the speed
+	 * 3. Update it in enic->rx_coalesce_setting
+	 */
+	speed = vnic_dev_port_speed(enic->vdev);
+	if (ENIC_LINK_SPEED_10G < speed)
+		index = ENIC_LINK_40G_INDEX;
+	else if (ENIC_LINK_SPEED_4G < speed)
+		index = ENIC_LINK_10G_INDEX;
+	else
+		index = ENIC_LINK_4G_INDEX;
+
+	rx_coal->small_pkt_range_start = mod_range[index].small_pkt_range_start;
+	rx_coal->large_pkt_range_start = mod_range[index].large_pkt_range_start;
+	rx_coal->range_end = ENIC_RX_COALESCE_RANGE_END;
+
+	/* Start with the value provided by UCSM */
+	for (index = 0; index < enic->rq_count; index++)
+		enic->cq[index].cur_rx_coal_timeval =
+				enic->config.intr_timer_usec;
+
+	rx_coal->use_adaptive_rx_coalesce = 1;
+
+	return 0;
+}
+
 static int enic_dev_notify_set(struct enic *enic)
 {
 	int err;
@@ -1355,6 +1504,8 @@ static int enic_open(struct net_device *netdev)
 	struct enic *enic = netdev_priv(netdev);
 	unsigned int i;
 	int err;
+	ktime_t ktime;
+	struct enic_rx_coal *rx_coal = &enic->rx_coalesce_setting;
 
 	err = enic_request_intr(enic);
 	if (err) {
@@ -1369,6 +1520,12 @@ static int enic_open(struct net_device *netdev)
 		goto err_out_free_intr;
 	}
 
+	if (rx_coal->use_adaptive_rx_coalesce) {
+		ktime = ktime_set(KTIME_SEC_MAX, 0);
+		hrtimer_start(&enic->rx_coalesce_setting.ts_timer, ktime,
+			      HRTIMER_MODE_REL);
+	}
+
 	for (i = 0; i < enic->rq_count; i++) {
 		vnic_rq_fill(&enic->rq[i], enic_rq_alloc_buf);
 		/* Need at least one buffer on ring to get going */
@@ -1418,6 +1575,8 @@ static int enic_stop(struct net_device *netdev)
 	unsigned int i;
 	int err;
 
+	if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
+		hrtimer_cancel(&enic->rx_coalesce_setting.ts_timer);
 	for (i = 0; i < enic->intr_count; i++) {
 		vnic_intr_mask(&enic->intr[i]);
 		(void)vnic_intr_masked(&enic->intr[i]); /* flush write */
@@ -2231,6 +2390,12 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	enic->notify_timer.function = enic_notify_timer;
 	enic->notify_timer.data = (unsigned long)enic;
 
+	err = enic_set_rx_coal_setting(enic);
+	if (!err) {
+		hrtimer_init(&enic->rx_coalesce_setting.ts_timer,
+			     CLOCK_REALTIME, HRTIMER_MODE_REL);
+		enic->rx_coalesce_setting.ts_timer.function = enic_hrtimer_cb;
+	}
 	INIT_WORK(&enic->reset, enic_reset);
 	INIT_WORK(&enic->change_mtu_work, enic_change_mtu_work);
 
@@ -2250,6 +2415,9 @@ static int enic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	enic->tx_coalesce_usecs = enic->config.intr_timer_usec;
+	/*rx coalesce time already got initialized. This gets used
+	 * if adaptive coal is turned off
+	 */
 	enic->rx_coalesce_usecs = enic->tx_coalesce_usecs;
 
 	if (enic_is_dynamic(enic) || enic_is_sriov_vf(enic))
diff --git a/drivers/net/ethernet/cisco/enic/vnic_cq.h b/drivers/net/ethernet/cisco/enic/vnic_cq.h
index 579315c..94cd2c4 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_cq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_cq.h
@@ -50,6 +50,11 @@ struct vnic_cq_ctrl {
 	u32 pad10;
 };
 
+struct vnic_rx_bytes_counter {
+	unsigned int small_pkt_bytes_cnt;
+	unsigned int large_pkt_bytes_cnt;
+};
+
 struct vnic_cq {
 	unsigned int index;
 	struct vnic_dev *vdev;
@@ -58,6 +63,9 @@ struct vnic_cq {
 	unsigned int to_clean;
 	unsigned int last_color;
 	unsigned int interrupt_offset;
+	struct vnic_rx_bytes_counter pkt_size_counter;
+	unsigned int cur_rx_coal_timeval;
+	ktime_t prev_ts;
 };
 
 static inline unsigned int vnic_cq_service(struct vnic_cq *cq,
-- 
1.9.2
