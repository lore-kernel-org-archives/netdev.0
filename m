From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 1/3] net: hns: fixed the setting overtime bug
Date: Fri, 4 Mar 2016 12:38:14 +0800
Message-ID: <1457066296-66202-2-git-send-email-lisheng011@huawei.com>
References: <1457066296-66202-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <kenneth-lee-2012@foxmail.com>,
	<xuwei5@hisilicon.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>, <linuxarm@huawei.com>
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>,
	<salil.mehta@huawei.com>, <liguozhu@huawei.com>,
	<huangdaode@hisilicon.com>, <lisheng011@huawei.com>,
	<yankejian@huawei.com>, <arnd@arndb.de>,
	<andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
	<chenny.xu@huawei.com>, <ivecera@redhat.com>,
	<fengguang.wu@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1457066296-66202-1-git-send-email-lisheng011@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In V2 chip,we can set overtime reg is for each port,
that is differents from for all port in V1.
This patch will modify some functions: set/get the reg.

Signed-off-by: Lisheng <lisheng011@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  60 +++-----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 180 ++++++++++------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h |  23 +--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |   1 +
 4 files changed, 114 insertions(+), 150 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index a0070d0..4d657f5 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -159,11 +159,6 @@ struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 		ae_handle->qs[i]->tx_ring.q = ae_handle->qs[i];
 
 		ring_pair_cb->used_by_vf = 1;
-		if (port_idx < DSAF_SERVICE_PORT_NUM_PER_DSAF)
-			ring_pair_cb->port_id_in_dsa = port_idx;
-		else
-			ring_pair_cb->port_id_in_dsa = 0;
-
 		ring_pair_cb++;
 	}
 
@@ -449,59 +444,46 @@ static int hns_ae_set_pauseparam(struct hnae_handle *handle,
 static void hns_ae_get_coalesce_usecs(struct hnae_handle *handle,
 				      u32 *tx_usecs, u32 *rx_usecs)
 {
-	int port;
-
-	port = hns_ae_map_eport_to_dport(handle->eport_id);
+	struct ring_pair_cb *ring_pair =
+		container_of(handle->qs[0], struct ring_pair_cb, q);
 
-	*tx_usecs = hns_rcb_get_coalesce_usecs(
-		hns_ae_get_dsaf_dev(handle->dev),
-		hns_dsaf_get_comm_idx_by_port(port));
-	*rx_usecs = hns_rcb_get_coalesce_usecs(
-		hns_ae_get_dsaf_dev(handle->dev),
-		hns_dsaf_get_comm_idx_by_port(port));
+	*tx_usecs = hns_rcb_get_coalesce_usecs(ring_pair->rcb_common,
+					       ring_pair->port_id_in_comm);
+	*rx_usecs = hns_rcb_get_coalesce_usecs(ring_pair->rcb_common,
+					       ring_pair->port_id_in_comm);
 }
 
 static void hns_ae_get_rx_max_coalesced_frames(struct hnae_handle *handle,
 					       u32 *tx_frames, u32 *rx_frames)
 {
-	int port;
+	struct ring_pair_cb *ring_pair =
+		container_of(handle->qs[0], struct ring_pair_cb, q);
 
-	assert(handle);
-
-	port = hns_ae_map_eport_to_dport(handle->eport_id);
-
-	*tx_frames = hns_rcb_get_coalesced_frames(
-		hns_ae_get_dsaf_dev(handle->dev), port);
-	*rx_frames = hns_rcb_get_coalesced_frames(
-		hns_ae_get_dsaf_dev(handle->dev), port);
+	*tx_frames = hns_rcb_get_coalesced_frames(ring_pair->rcb_common,
+						  ring_pair->port_id_in_comm);
+	*rx_frames = hns_rcb_get_coalesced_frames(ring_pair->rcb_common,
+						  ring_pair->port_id_in_comm);
 }
 
 static void hns_ae_set_coalesce_usecs(struct hnae_handle *handle,
 				      u32 timeout)
 {
-	int port;
+	struct ring_pair_cb *ring_pair =
+		container_of(handle->qs[0], struct ring_pair_cb, q);
 
-	assert(handle);
-
-	port = hns_ae_map_eport_to_dport(handle->eport_id);
-
-	hns_rcb_set_coalesce_usecs(hns_ae_get_dsaf_dev(handle->dev),
-				   port, timeout);
+	(void)hns_rcb_set_coalesce_usecs(
+		ring_pair->rcb_common, ring_pair->port_id_in_comm, timeout);
 }
 
 static int  hns_ae_set_coalesce_frames(struct hnae_handle *handle,
 				       u32 coalesce_frames)
 {
-	int port;
-	int ret;
+	struct ring_pair_cb *ring_pair =
+		container_of(handle->qs[0], struct ring_pair_cb, q);
 
-	assert(handle);
-
-	port = hns_ae_map_eport_to_dport(handle->eport_id);
-
-	ret = hns_rcb_set_coalesced_frames(hns_ae_get_dsaf_dev(handle->dev),
-					   port, coalesce_frames);
-	return ret;
+	return hns_rcb_set_coalesced_frames(
+		ring_pair->rcb_common,
+		ring_pair->port_id_in_comm, coalesce_frames);
 }
 
 void hns_ae_update_stats(struct hnae_handle *handle,
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index 1218880..106af93 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -215,9 +215,9 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
 		dsaf_write_dev(q, RCB_RING_RX_RING_BD_LEN_REG,
 			       bd_size_type);
 		dsaf_write_dev(q, RCB_RING_RX_RING_BD_NUM_REG,
-			       ring_pair->port_id_in_dsa);
+			       ring_pair->port_id_in_comm);
 		dsaf_write_dev(q, RCB_RING_RX_RING_PKTLINE_REG,
-			       ring_pair->port_id_in_dsa);
+			       ring_pair->port_id_in_comm);
 	} else {
 		dsaf_write_dev(q, RCB_RING_TX_RING_BASEADDR_L_REG,
 			       (u32)dma);
@@ -227,9 +227,9 @@ static void hns_rcb_ring_init(struct ring_pair_cb *ring_pair, int ring_type)
 		dsaf_write_dev(q, RCB_RING_TX_RING_BD_LEN_REG,
 			       bd_size_type);
 		dsaf_write_dev(q, RCB_RING_TX_RING_BD_NUM_REG,
-			       ring_pair->port_id_in_dsa);
+			       ring_pair->port_id_in_comm);
 		dsaf_write_dev(q, RCB_RING_TX_RING_PKTLINE_REG,
-			       ring_pair->port_id_in_dsa);
+			       ring_pair->port_id_in_comm);
 	}
 }
 
@@ -256,50 +256,16 @@ static void hns_rcb_set_port_desc_cnt(struct rcb_common_cb *rcb_common,
 		       desc_cnt);
 }
 
-/**
- *hns_rcb_set_port_coalesced_frames - set rcb port coalesced frames
- *@rcb_common: rcb_common device
- *@port_idx:port index
- *@coalesced_frames:BD num for coalesced frames
- */
-static int  hns_rcb_set_port_coalesced_frames(struct rcb_common_cb *rcb_common,
-					      u32 port_idx,
-					      u32 coalesced_frames)
+static void hns_rcb_set_port_timeout(
+	struct rcb_common_cb *rcb_common, u32 port_idx, u32 timeout)
 {
-	if (coalesced_frames >= rcb_common->desc_num ||
-	    coalesced_frames > HNS_RCB_MAX_COALESCED_FRAMES)
-		return -EINVAL;
-
-	dsaf_write_dev(rcb_common, RCB_CFG_PKTLINE_REG + port_idx * 4,
-		       coalesced_frames);
-	return 0;
-}
-
-/**
- *hns_rcb_get_port_coalesced_frames - set rcb port coalesced frames
- *@rcb_common: rcb_common device
- *@port_idx:port index
- * return coaleseced frames value
- */
-static u32 hns_rcb_get_port_coalesced_frames(struct rcb_common_cb *rcb_common,
-					     u32 port_idx)
-{
-	if (port_idx >= HNS_RCB_SERVICE_NW_ENGINE_NUM)
-		port_idx = 0;
-
-	return dsaf_read_dev(rcb_common,
-			     RCB_CFG_PKTLINE_REG + port_idx * 4);
-}
-
-/**
- *hns_rcb_set_timeout - set rcb port coalesced time_out
- *@rcb_common: rcb_common device
- *@time_out:time for coalesced time_out
- */
-static void hns_rcb_set_timeout(struct rcb_common_cb *rcb_common,
-				u32 timeout)
-{
-	dsaf_write_dev(rcb_common, RCB_CFG_OVERTIME_REG, timeout);
+	if (AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver))
+		dsaf_write_dev(rcb_common, RCB_CFG_OVERTIME_REG,
+			       timeout * HNS_RCB_CLK_FREQ_MHZ);
+	else
+		dsaf_write_dev(rcb_common,
+			       RCB_PORT_CFG_OVERTIME_REG + port_idx * 4,
+			       timeout);
 }
 
 static int hns_rcb_common_get_port_num(struct rcb_common_cb *rcb_common)
@@ -361,10 +327,11 @@ int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common)
 
 	for (i = 0; i < port_num; i++) {
 		hns_rcb_set_port_desc_cnt(rcb_common, i, rcb_common->desc_num);
-		(void)hns_rcb_set_port_coalesced_frames(
-			rcb_common, i, rcb_common->coalesced_frames);
+		(void)hns_rcb_set_coalesced_frames(
+			rcb_common, i, HNS_RCB_DEF_COALESCED_FRAMES);
+		hns_rcb_set_port_timeout(
+			rcb_common, i, HNS_RCB_DEF_COALESCED_USECS);
 	}
-	hns_rcb_set_timeout(rcb_common, rcb_common->timeout);
 
 	dsaf_write_dev(rcb_common, RCB_COM_CFG_ENDIAN_REG,
 		       HNS_RCB_COMMON_ENDIAN);
@@ -460,7 +427,8 @@ static void hns_rcb_ring_pair_get_cfg(struct ring_pair_cb *ring_pair_cb)
 	hns_rcb_ring_get_cfg(&ring_pair_cb->q, TX_RING);
 }
 
-static int hns_rcb_get_port(struct rcb_common_cb *rcb_common, int ring_idx)
+static int hns_rcb_get_port_in_comm(
+	struct rcb_common_cb *rcb_common, int ring_idx)
 {
 	int comm_index = rcb_common->comm_index;
 	int port;
@@ -470,7 +438,7 @@ static int hns_rcb_get_port(struct rcb_common_cb *rcb_common, int ring_idx)
 		q_num = (int)rcb_common->max_q_per_vf * rcb_common->max_vfn;
 		port = ring_idx / q_num;
 	} else {
-		port = HNS_RCB_SERVICE_NW_ENGINE_NUM + comm_index - 1;
+		port = 0; /* config debug-ports port_id_in_comm to 0*/
 	}
 
 	return port;
@@ -518,7 +486,8 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 		ring_pair_cb->index = i;
 		ring_pair_cb->q.io_base =
 			RCB_COMM_BASE_TO_RING_BASE(rcb_common->io_base, i);
-		ring_pair_cb->port_id_in_dsa = hns_rcb_get_port(rcb_common, i);
+		ring_pair_cb->port_id_in_comm =
+			hns_rcb_get_port_in_comm(rcb_common, i);
 		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX] =
 		is_ver1 ? irq_of_parse_and_map(np, base_irq_idx + i * 2) :
 			  platform_get_irq(pdev, base_irq_idx + i * 3 + 1);
@@ -534,82 +503,95 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
 /**
  *hns_rcb_get_coalesced_frames - get rcb port coalesced frames
  *@rcb_common: rcb_common device
- *@comm_index:port index
- *return coalesced_frames
+ *@port_idx:port id in comm
+ *
+ *Returns: coalesced_frames
  */
-u32 hns_rcb_get_coalesced_frames(struct dsaf_device *dsaf_dev, int port)
+u32 hns_rcb_get_coalesced_frames(
+	struct rcb_common_cb *rcb_common, u32 port_idx)
 {
-	int comm_index =  hns_dsaf_get_comm_idx_by_port(port);
-	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
-
-	return hns_rcb_get_port_coalesced_frames(rcb_comm, port);
+	return dsaf_read_dev(rcb_common, RCB_CFG_PKTLINE_REG + port_idx * 4);
 }
 
 /**
  *hns_rcb_get_coalesce_usecs - get rcb port coalesced time_out
  *@rcb_common: rcb_common device
- *@comm_index:port index
- *return time_out
+ *@port_idx:port id in comm
+ *
+ *Returns: time_out
  */
-u32 hns_rcb_get_coalesce_usecs(struct dsaf_device *dsaf_dev, int comm_index)
+u32 hns_rcb_get_coalesce_usecs(
+	struct rcb_common_cb *rcb_common, u32 port_idx)
 {
-	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
-
-	return rcb_comm->timeout;
+	if (AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver))
+		return dsaf_read_dev(rcb_common, RCB_CFG_OVERTIME_REG) /
+		       HNS_RCB_CLK_FREQ_MHZ;
+	else
+		return dsaf_read_dev(rcb_common,
+				     RCB_PORT_CFG_OVERTIME_REG + port_idx * 4);
 }
 
 /**
  *hns_rcb_set_coalesce_usecs - set rcb port coalesced time_out
  *@rcb_common: rcb_common device
- *@comm_index: comm :index
- *@etx_usecs:tx time for coalesced time_out
- *@rx_usecs:rx time for coalesced time_out
+ *@port_idx:port id in comm
+ *@timeout:tx/rx time for coalesced time_out
+ *
+ * Returns:
+ * Zero for success, or an error code in case of failure
  */
-void hns_rcb_set_coalesce_usecs(struct dsaf_device *dsaf_dev,
-				int port, u32 timeout)
+int hns_rcb_set_coalesce_usecs(
+	struct rcb_common_cb *rcb_common, u32 port_idx, u32 timeout)
 {
-	int comm_index =  hns_dsaf_get_comm_idx_by_port(port);
-	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
+	u32 old_timeout = hns_rcb_get_coalesce_usecs(rcb_common, port_idx);
 
-	if (rcb_comm->timeout == timeout)
-		return;
+	if (timeout == old_timeout)
+		return 0;
 
-	if (comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
-		dev_err(dsaf_dev->dev,
-			"error: not support coalesce_usecs setting!\n");
-		return;
+	if (AE_IS_VER1(rcb_common->dsaf_dev->dsaf_ver)) {
+		if (rcb_common->comm_index == HNS_DSAF_COMM_SERVICE_NW_IDX) {
+			dev_err(rcb_common->dsaf_dev->dev,
+				"error: not support coalesce_usecs setting!\n");
+			return -EINVAL;
+		}
 	}
-	rcb_comm->timeout = timeout;
-	hns_rcb_set_timeout(rcb_comm, rcb_comm->timeout);
+	if (timeout > HNS_RCB_MAX_COALESCED_USECS) {
+		dev_err(rcb_common->dsaf_dev->dev,
+			"error: not support coalesce %dus!\n", timeout);
+		return -EINVAL;
+	}
+	hns_rcb_set_port_timeout(rcb_common, port_idx, timeout);
+	return 0;
 }
 
 /**
  *hns_rcb_set_coalesced_frames - set rcb coalesced frames
  *@rcb_common: rcb_common device
- *@tx_frames:tx BD num for coalesced frames
- *@rx_frames:rx BD num for coalesced frames
- *Return 0 on success, negative on failure
+ *@port_idx:port id in comm
+ *@coalesced_frames:tx/rx BD num for coalesced frames
+ *
+ * Returns:
+ * Zero for success, or an error code in case of failure
  */
-int hns_rcb_set_coalesced_frames(struct dsaf_device *dsaf_dev,
-				 int port, u32 coalesced_frames)
+int hns_rcb_set_coalesced_frames(
+	struct rcb_common_cb *rcb_common, u32 port_idx, u32 coalesced_frames)
 {
-	int comm_index =  hns_dsaf_get_comm_idx_by_port(port);
-	struct rcb_common_cb *rcb_comm = dsaf_dev->rcb_common[comm_index];
-	u32 coalesced_reg_val;
-	int ret;
-
-	coalesced_reg_val = hns_rcb_get_port_coalesced_frames(rcb_comm, port);
+	u32 old_waterline = hns_rcb_get_coalesced_frames(rcb_common, port_idx);
 
-	if (coalesced_reg_val == coalesced_frames)
+	if (coalesced_frames == old_waterline)
 		return 0;
 
-	if (coalesced_frames >= HNS_RCB_MIN_COALESCED_FRAMES) {
-		ret = hns_rcb_set_port_coalesced_frames(rcb_comm, port,
-							coalesced_frames);
-		return ret;
-	} else {
+	if (coalesced_frames >= rcb_common->desc_num ||
+	    coalesced_frames > HNS_RCB_MAX_COALESCED_FRAMES ||
+	    coalesced_frames < HNS_RCB_MIN_COALESCED_FRAMES) {
+		dev_err(rcb_common->dsaf_dev->dev,
+			"error: not support coalesce_frames setting!\n");
 		return -EINVAL;
 	}
+
+	dsaf_write_dev(rcb_common, RCB_CFG_PKTLINE_REG + port_idx * 4,
+		       coalesced_frames);
+	return 0;
 }
 
 /**
@@ -749,8 +731,6 @@ int hns_rcb_common_get_cfg(struct dsaf_device *dsaf_dev,
 	rcb_common->dsaf_dev = dsaf_dev;
 
 	rcb_common->desc_num = dsaf_dev->desc_num;
-	rcb_common->coalesced_frames = HNS_RCB_DEF_COALESCED_FRAMES;
-	rcb_common->timeout = HNS_RCB_MAX_TIME_OUT;
 
 	hns_rcb_get_queue_mode(dsaf_mode, comm_index, &max_vfn, &max_q_per_vf);
 	rcb_common->max_vfn = max_vfn;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
index 81fe9f8..eb61014 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
@@ -38,7 +38,9 @@ struct rcb_common_cb;
 #define HNS_RCB_MAX_COALESCED_FRAMES		1023
 #define HNS_RCB_MIN_COALESCED_FRAMES		1
 #define HNS_RCB_DEF_COALESCED_FRAMES		50
-#define HNS_RCB_MAX_TIME_OUT			0x500
+#define HNS_RCB_CLK_FREQ_MHZ			350
+#define HNS_RCB_MAX_COALESCED_USECS		0x3ff
+#define HNS_RCB_DEF_COALESCED_USECS		3
 
 #define HNS_RCB_COMMON_ENDIAN			1
 
@@ -82,7 +84,7 @@ struct ring_pair_cb {
 
 	int virq[HNS_RCB_IRQ_NUM_PER_QUEUE];
 
-	u8 port_id_in_dsa;
+	u8 port_id_in_comm;
 	u8 used_by_vf;
 
 	struct hns_ring_hw_stats hw_stats;
@@ -97,8 +99,6 @@ struct rcb_common_cb {
 
 	u8 comm_index;
 	u32 ring_num;
-	u32 coalesced_frames; /* frames  threshold of  rx interrupt   */
-	u32 timeout; /* time threshold of  rx interrupt  */
 	u32 desc_num; /*  desc num per queue*/
 
 	struct ring_pair_cb ring_pair_cb[0];
@@ -125,13 +125,14 @@ void hns_rcbv2_int_clr_hw(struct hnae_queue *q, u32 flag);
 void hns_rcb_init_hw(struct ring_pair_cb *ring);
 void hns_rcb_reset_ring_hw(struct hnae_queue *q);
 void hns_rcb_wait_fbd_clean(struct hnae_queue **qs, int q_num, u32 flag);
-
-u32 hns_rcb_get_coalesced_frames(struct dsaf_device *dsaf_dev, int comm_index);
-u32 hns_rcb_get_coalesce_usecs(struct dsaf_device *dsaf_dev, int comm_index);
-void hns_rcb_set_coalesce_usecs(struct dsaf_device *dsaf_dev,
-				int comm_index, u32 timeout);
-int hns_rcb_set_coalesced_frames(struct dsaf_device *dsaf_dev,
-				 int comm_index, u32 coalesce_frames);
+u32 hns_rcb_get_coalesced_frames(
+	struct rcb_common_cb *rcb_common, u32 port_idx);
+u32 hns_rcb_get_coalesce_usecs(
+	struct rcb_common_cb *rcb_common, u32 port_idx);
+int hns_rcb_set_coalesce_usecs(
+	struct rcb_common_cb *rcb_common, u32 port_idx, u32 timeout);
+int hns_rcb_set_coalesced_frames(
+	struct rcb_common_cb *rcb_common, u32 port_idx, u32 coalesced_frames);
 void hns_rcb_update_stats(struct hnae_queue *queue);
 
 void hns_rcb_get_stats(struct hnae_queue *queue, u64 *data);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
index f0c4f9b..943c1fd 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h
@@ -403,6 +403,7 @@
 #define RCB_CFG_OVERTIME_REG			0x9300
 #define RCB_CFG_PKTLINE_INT_NUM_REG		0x9304
 #define RCB_CFG_OVERTIME_INT_NUM_REG		0x9308
+#define RCB_PORT_CFG_OVERTIME_REG		0x9430
 
 #define RCB_RING_RX_RING_BASEADDR_L_REG		0x00000
 #define RCB_RING_RX_RING_BASEADDR_H_REG		0x00004
-- 
1.9.1
