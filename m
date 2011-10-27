From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH 3/3] stmmac: update normal descriptor structure (v2)
Date: Thu, 27 Oct 2011 07:43:09 +0200
Message-ID: <1319694189-25223-3-git-send-email-peppe.cavallaro@st.com>
References: <1319637339-14866-1-git-send-email-peppe.cavallaro@st.com>
 <1319694189-25223-1-git-send-email-peppe.cavallaro@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kelvin Cheung <keguang.zhang@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:41764 "EHLO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751118Ab1J0Fnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 01:43:32 -0400
In-Reply-To: <1319694189-25223-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the normal descriptor structure
to work fine on new GMAC Synopsys chips.

Normal descriptors were designed on the old MAC10/100
databook 1.91 where some bits were reserved: for example
the tx checksum insertion and rx checksum offload.

The patch maintains the back-compatibility with old
MAC devices (tested on STx7109 MAC10/100) and adds new
fields that actually new GMAC devices can use.

For example, STx7109 (MAC10/100) will pass from the platform
  tx_coe = 0, enh_desc = 0, has_gmac = 0.
A platform like Loongson1B (GMAC) will pass:
  tx_coe = 1, enh_desc = 0, has_gmac = 1.

Thanks to Kelvin, he enhanced the normal descriptors for
GMAC (on MIPS Loongson1B platform).

Signed-off-by: Kelvin Cheung <keguang.zhang@gmail.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h       |    8 ++--
 drivers/net/ethernet/stmicro/stmmac/descs.h        |   31 +++++++++-------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   38 +++++++++++---------
 .../net/ethernet/stmicro/stmmac/stmmac_ethtool.c   |    8 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |    6 ++-
 5 files changed, 51 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 9100c10..2cc1192 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -49,7 +49,7 @@ struct stmmac_extra_stats {
 	unsigned long tx_underflow ____cacheline_aligned;
 	unsigned long tx_carrier;
 	unsigned long tx_losscarrier;
-	unsigned long tx_heartbeat;
+	unsigned long vlan_tag;
 	unsigned long tx_deferred;
 	unsigned long tx_vlan;
 	unsigned long tx_jabber;
@@ -58,9 +58,9 @@ struct stmmac_extra_stats {
 	unsigned long tx_ip_header_error;
 	/* Receive errors */
 	unsigned long rx_desc;
-	unsigned long rx_partial;
-	unsigned long rx_runt;
-	unsigned long rx_toolong;
+	unsigned long sa_filter_fail;
+	unsigned long overflow_error;
+	unsigned long ipc_csum_error;
 	unsigned long rx_collision;
 	unsigned long rx_crc;
 	unsigned long rx_length;
diff --git a/drivers/net/ethernet/stmicro/stmmac/descs.h b/drivers/net/ethernet/stmicro/stmmac/descs.h
index 63a03e2..9820ec8 100644
--- a/drivers/net/ethernet/stmicro/stmmac/descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/descs.h
@@ -25,33 +25,34 @@ struct dma_desc {
 	union {
 		struct {
 			/* RDES0 */
-			u32 reserved1:1;
+			u32 payload_csum_error:1;
 			u32 crc_error:1;
 			u32 dribbling:1;
 			u32 mii_error:1;
 			u32 receive_watchdog:1;
 			u32 frame_type:1;
 			u32 collision:1;
-			u32 frame_too_long:1;
+			u32 ipc_csum_error:1;
 			u32 last_descriptor:1;
 			u32 first_descriptor:1;
-			u32 multicast_frame:1;
-			u32 run_frame:1;
+			u32 vlan_tag:1;
+			u32 overflow_error:1;
 			u32 length_error:1;
-			u32 partial_frame_error:1;
+			u32 sa_filter_fail:1;
 			u32 descriptor_error:1;
 			u32 error_summary:1;
 			u32 frame_length:14;
-			u32 filtering_fail:1;
+			u32 da_filter_fail:1;
 			u32 own:1;
 			/* RDES1 */
 			u32 buffer1_size:11;
 			u32 buffer2_size:11;
-			u32 reserved2:2;
+			u32 reserved1:2;
 			u32 second_address_chained:1;
 			u32 end_ring:1;
-			u32 reserved3:5;
+			u32 reserved2:5;
 			u32 disable_ic:1;
+
 		} rx;
 		struct {
 			/* RDES0 */
@@ -91,24 +92,28 @@ struct dma_desc {
 			u32 underflow_error:1;
 			u32 excessive_deferral:1;
 			u32 collision_count:4;
-			u32 heartbeat_fail:1;
+			u32 vlan_frame:1;
 			u32 excessive_collisions:1;
 			u32 late_collision:1;
 			u32 no_carrier:1;
 			u32 loss_carrier:1;
-			u32 reserved1:3;
+			u32 payload_error:1;
+			u32 frame_flushed:1;
+			u32 jabber_timeout:1;
 			u32 error_summary:1;
-			u32 reserved2:15;
+			u32 ip_header_error:1;
+			u32 time_stamp_status:1;
+			u32 reserved1:13;
 			u32 own:1;
 			/* TDES1 */
 			u32 buffer1_size:11;
 			u32 buffer2_size:11;
-			u32 reserved3:1;
+			u32 time_stamp_enable:1;
 			u32 disable_padding:1;
 			u32 second_address_chained:1;
 			u32 end_ring:1;
 			u32 crc_disable:1;
-			u32 reserved4:2;
+			u32 checksum_insertion:2;
 			u32 first_segment:1;
 			u32 last_segment:1;
 			u32 interrupt:1;
diff --git a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
index f7e8ba7..fda5d2b 100644
--- a/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
+++ b/drivers/net/ethernet/stmicro/stmmac/norm_desc.c
@@ -50,11 +50,12 @@ static int ndesc_get_tx_status(void *data, struct stmmac_extra_stats *x,
 			stats->collisions += p->des01.tx.collision_count;
 		ret = -1;
 	}
-	if (unlikely(p->des01.tx.heartbeat_fail)) {
-		x->tx_heartbeat++;
-		stats->tx_heartbeat_errors++;
-		ret = -1;
+
+	if (p->des01.etx.vlan_frame) {
+		CHIP_DBG(KERN_INFO "GMAC TX status: VLAN frame\n");
+		x->tx_vlan++;
 	}
+
 	if (unlikely(p->des01.tx.deferred))
 		x->tx_deferred++;
 
@@ -68,12 +69,12 @@ static int ndesc_get_tx_len(struct dma_desc *p)
 
 /* This function verifies if each incoming frame has some errors
  * and, if required, updates the multicast statistics.
- * In case of success, it returns csum_none because the device
- * is not able to compute the csum in HW. */
+ * In case of success, it returns good_frame because the GMAC device
+ * is supposed to be able to compute the csum in HW. */
 static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 			       struct dma_desc *p)
 {
-	int ret = csum_none;
+	int ret = good_frame;
 	struct net_device_stats *stats = (struct net_device_stats *)data;
 
 	if (unlikely(p->des01.rx.last_descriptor == 0)) {
@@ -86,12 +87,12 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 	if (unlikely(p->des01.rx.error_summary)) {
 		if (unlikely(p->des01.rx.descriptor_error))
 			x->rx_desc++;
-		if (unlikely(p->des01.rx.partial_frame_error))
-			x->rx_partial++;
-		if (unlikely(p->des01.rx.run_frame))
-			x->rx_runt++;
-		if (unlikely(p->des01.rx.frame_too_long))
-			x->rx_toolong++;
+		if (unlikely(p->des01.rx.sa_filter_fail))
+			x->sa_filter_fail++;
+		if (unlikely(p->des01.rx.overflow_error))
+			x->overflow_error++;
+		if (unlikely(p->des01.rx.ipc_csum_error))
+			x->ipc_csum_error++;
 		if (unlikely(p->des01.rx.collision)) {
 			x->rx_collision++;
 			stats->collisions++;
@@ -113,10 +114,10 @@ static int ndesc_get_rx_status(void *data, struct stmmac_extra_stats *x,
 		x->rx_mii++;
 		ret = discard_frame;
 	}
-	if (p->des01.rx.multicast_frame) {
-		x->rx_multicast++;
-		stats->multicast++;
-	}
+#ifdef STMMAC_VLAN_TAG_USED
+	if (p->des01.rx.vlan_tag)
+		x->vlan_tag++;
+#endif
 	return ret;
 }
 
@@ -184,6 +185,9 @@ static void ndesc_prepare_tx_desc(struct dma_desc *p, int is_fs, int len,
 {
 	p->des01.tx.first_segment = is_fs;
 	norm_set_tx_desc_len(p, len);
+
+	if (likely(csum_flag))
+		p->des01.tx.checksum_insertion = cic_full;
 }
 
 static void ndesc_clear_tx_ic(struct dma_desc *p)
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
index 406404f..e8eff09 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c
@@ -50,7 +50,7 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(tx_underflow),
 	STMMAC_STAT(tx_carrier),
 	STMMAC_STAT(tx_losscarrier),
-	STMMAC_STAT(tx_heartbeat),
+	STMMAC_STAT(vlan_tag),
 	STMMAC_STAT(tx_deferred),
 	STMMAC_STAT(tx_vlan),
 	STMMAC_STAT(rx_vlan),
@@ -59,9 +59,9 @@ static const struct stmmac_stats stmmac_gstrings_stats[] = {
 	STMMAC_STAT(tx_payload_error),
 	STMMAC_STAT(tx_ip_header_error),
 	STMMAC_STAT(rx_desc),
-	STMMAC_STAT(rx_partial),
-	STMMAC_STAT(rx_runt),
-	STMMAC_STAT(rx_toolong),
+	STMMAC_STAT(sa_filter_fail),
+	STMMAC_STAT(overflow_error),
+	STMMAC_STAT(ipc_csum_error),
 	STMMAC_STAT(rx_collision),
 	STMMAC_STAT(rx_crc),
 	STMMAC_STAT(rx_length),
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index f77eaa6..451aa60 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -813,6 +813,7 @@ static u32 stmmac_get_synopsys_id(struct stmmac_priv *priv)
 static int stmmac_get_hw_features(struct stmmac_priv *priv)
 {
 	u32 hw_cap = 0;
+
 	if (priv->hw->dma->get_hw_feature) {
 		hw_cap = priv->hw->dma->get_hw_feature(priv->ioaddr);
 
@@ -938,6 +939,7 @@ static int stmmac_open(struct net_device *dev)
 
 	stmmac_get_hw_features(priv);
 
+	priv->rx_coe = priv->hw->mac->rx_coe(priv->ioaddr);
 	if (priv->rx_coe)
 		pr_info("stmmac: Rx Checksum Offload Engine supported\n");
 	if (priv->plat->tx_coe)
@@ -1275,8 +1277,8 @@ static int stmmac_rx(struct stmmac_priv *priv, int limit)
 #endif
 			skb->protocol = eth_type_trans(skb, priv->dev);
 
-			if (unlikely(status == csum_none)) {
-				/* always for the old mac 10/100 */
+			if (unlikely(!priv->rx_coe)) {
+				/* No RX COE for old mac10/100 devices */
 				skb_checksum_none_assert(skb);
 				netif_receive_skb(skb);
 			} else {
-- 
1.7.4.4
