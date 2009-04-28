From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/3] ixgbe: enable HW RSC for 82599
Date: Tue, 28 Apr 2009 01:42:37 -0700
Message-ID: <20090428084236.32710.14750.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:56433 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751150AbZD1Imy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:42:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch enables hardware receive side coalescing for 82599 hardware.
82599 can merge multiple frames from the same TCP/IP flow into a single
structure that can span one ore more descriptors.  The accumulated data is
arranged similar to how jumbo frames are arranged with the exception that
other packets can be interlaced inbetween.  To overcome this issue a next
pointer is included in the written back descriptor which indicates the next
descriptor in the writeback sequence.

This feature sets the NETIF_F_LRO flag and clearing it via the ethtool set
flags operation will also disable hardware RSC.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    4 +
 drivers/net/ixgbe/ixgbe_ethtool.c |   24 +++++++
 drivers/net/ixgbe/ixgbe_main.c    |  121 ++++++++++++++++++++++++++++++++++---
 drivers/net/ixgbe/ixgbe_type.h    |   15 +++++
 4 files changed, 152 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index c26433d..4b44a8e 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -147,6 +147,7 @@ struct ixgbe_ring {
 
 	u16 work_limit;                /* max work per interrupt */
 	u16 rx_buf_len;
+	u64 rsc_count;                 /* stat for coalesced packets */
 };
 
 enum ixgbe_ring_f_enum {
@@ -294,6 +295,8 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
 #define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 24)
 #define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 25)
+#define IXGBE_FLAG_RSC_CAPABLE                  (u32)(1 << 26)
+#define IXGBE_FLAG_RSC_ENABLED                  (u32)(1 << 27)
 
 /* default to trying for four seconds */
 #define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
@@ -325,6 +328,7 @@ struct ixgbe_adapter {
 	struct timer_list sfp_timer;
 	struct work_struct multispeed_fiber_task;
 	struct work_struct sfp_config_module_task;
+	u64 rsc_count;
 	u32 wol;
 	u16 eeprom_version;
 };
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index a499b6b..d822c92 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -67,6 +67,7 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"rx_over_errors", IXGBE_STAT(net_stats.rx_over_errors)},
 	{"rx_crc_errors", IXGBE_STAT(net_stats.rx_crc_errors)},
 	{"rx_frame_errors", IXGBE_STAT(net_stats.rx_frame_errors)},
+	{"hw_rsc_count", IXGBE_STAT(rsc_count)},
 	{"rx_fifo_errors", IXGBE_STAT(net_stats.rx_fifo_errors)},
 	{"rx_missed_errors", IXGBE_STAT(net_stats.rx_missed_errors)},
 	{"tx_aborted_errors", IXGBE_STAT(net_stats.tx_aborted_errors)},
@@ -1127,6 +1128,27 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int ixgbe_set_flags(struct net_device *netdev, u32 data)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	ethtool_op_set_flags(netdev, data);
+
+	if (!(adapter->flags & IXGBE_FLAG_RSC_CAPABLE))
+		return 0;
+
+	/* if state changes we need to update adapter->flags and reset */
+	if ((!!(data & ETH_FLAG_LRO)) != 
+	    (!!(adapter->flags & IXGBE_FLAG_RSC_ENABLED))) {
+		adapter->flags ^= IXGBE_FLAG_RSC_ENABLED;
+		if (netif_running(netdev))
+			ixgbe_reinit_locked(adapter);
+		else
+			ixgbe_reset(adapter);
+	}
+	return 0;
+
+}
 
 static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_settings           = ixgbe_get_settings,
@@ -1161,7 +1183,7 @@ static const struct ethtool_ops ixgbe_ethtool_ops = {
 	.get_coalesce           = ixgbe_get_coalesce,
 	.set_coalesce           = ixgbe_set_coalesce,
 	.get_flags              = ethtool_op_get_flags,
-	.set_flags              = ethtool_op_set_flags,
+	.set_flags              = ixgbe_set_flags,
 };
 
 void ixgbe_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ad43181..599808b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -622,6 +622,40 @@ static inline u16 ixgbe_get_pkt_info(union ixgbe_adv_rx_desc *rx_desc)
 	return rx_desc->wb.lower.lo_dword.hs_rss.pkt_info;
 }
 
+static inline u32 ixgbe_get_rsc_count(union ixgbe_adv_rx_desc *rx_desc)
+{
+	return (le32_to_cpu(rx_desc->wb.lower.lo_dword.data) &
+	        IXGBE_RXDADV_RSCCNT_MASK) >>
+	        IXGBE_RXDADV_RSCCNT_SHIFT;
+}
+
+/**
+ * ixgbe_transform_rsc_queue - change rsc queue into a full packet
+ * @skb: pointer to the last skb in the rsc queue
+ *
+ * This function changes a queue full of hw rsc buffers into a completed
+ * packet.  It uses the ->prev pointers to find the first packet and then
+ * turns it into the frag list owner.
+ **/
+static inline struct sk_buff *ixgbe_transform_rsc_queue(struct sk_buff *skb)
+{
+	unsigned int frag_list_size = 0;
+
+	while (skb->prev) {
+		struct sk_buff *prev = skb->prev;
+		frag_list_size += skb->len;
+		skb->prev = NULL;
+		skb = prev;
+	}
+
+	skb_shinfo(skb)->frag_list = skb->next;
+	skb->next = NULL;
+	skb->len += frag_list_size;
+	skb->data_len += frag_list_size;
+	skb->truesize += frag_list_size;
+	return skb;
+}
+
 static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
                                struct ixgbe_ring *rx_ring,
                                int *work_done, int work_to_do)
@@ -631,7 +665,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 	union ixgbe_adv_rx_desc *rx_desc, *next_rxd;
 	struct ixgbe_rx_buffer *rx_buffer_info, *next_buffer;
 	struct sk_buff *skb;
-	unsigned int i;
+	unsigned int i, rsc_count = 0;
 	u32 len, staterr;
 	u16 hdr_info;
 	bool cleaned = false;
@@ -697,20 +731,38 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		i++;
 		if (i == rx_ring->count)
 			i = 0;
-		next_buffer = &rx_ring->rx_buffer_info[i];
 
 		next_rxd = IXGBE_RX_DESC_ADV(*rx_ring, i);
 		prefetch(next_rxd);
-
 		cleaned_count++;
+
+		if (adapter->flags & IXGBE_FLAG_RSC_CAPABLE)
+			rsc_count = ixgbe_get_rsc_count(rx_desc);
+
+		if (rsc_count) {
+			u32 nextp = (staterr & IXGBE_RXDADV_NEXTP_MASK) >>
+				     IXGBE_RXDADV_NEXTP_SHIFT;
+			next_buffer = &rx_ring->rx_buffer_info[nextp];
+			rx_ring->rsc_count += (rsc_count - 1);
+		} else {
+			next_buffer = &rx_ring->rx_buffer_info[i];
+		}
+
 		if (staterr & IXGBE_RXD_STAT_EOP) {
+			if (skb->prev)
+				skb = ixgbe_transform_rsc_queue(skb);
 			rx_ring->stats.packets++;
 			rx_ring->stats.bytes += skb->len;
 		} else {
-			rx_buffer_info->skb = next_buffer->skb;
-			rx_buffer_info->dma = next_buffer->dma;
-			next_buffer->skb = skb;
-			next_buffer->dma = 0;
+			if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED) {
+				rx_buffer_info->skb = next_buffer->skb;
+				rx_buffer_info->dma = next_buffer->dma;
+				next_buffer->skb = skb;
+				next_buffer->dma = 0;
+			} else {
+				skb->next = next_buffer->skb;
+				skb->next->prev = skb;
+			}
 			adapter->non_eop_descs++;
 			goto next_desc;
 		}
@@ -740,7 +792,7 @@ next_desc:
 
 		/* use prefetched values */
 		rx_desc = next_rxd;
-		rx_buffer_info = next_buffer;
+		rx_buffer_info = &rx_ring->rx_buffer_info[i];
 
 		staterr = le32_to_cpu(rx_desc->wb.upper.status_error);
 	}
@@ -1736,6 +1788,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	u32 fctrl, hlreg0;
 	u32 reta = 0, mrqc = 0;
 	u32 rdrxctl;
+	u32 rscctrl;
 	int rx_buf_len;
 
 	/* Decide whether to use packet split mode or not */
@@ -1753,7 +1806,8 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(0), psrtype);
 		}
 	} else {
-		if (netdev->mtu <= ETH_DATA_LEN)
+		if (!(adapter->flags & IXGBE_FLAG_RSC_ENABLED) &&
+		    (netdev->mtu <= ETH_DATA_LEN))
 			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 		else
 			rx_buf_len = ALIGN(max_frame, 1024);
@@ -1875,8 +1929,38 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	if (hw->mac.type == ixgbe_mac_82599EB) {
 		rdrxctl = IXGBE_READ_REG(hw, IXGBE_RDRXCTL);
 		rdrxctl |= IXGBE_RDRXCTL_CRCSTRIP;
+		rdrxctl &= ~IXGBE_RDRXCTL_RSCFRSTSIZE;
 		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
 	}
+
+	if (adapter->flags & IXGBE_FLAG_RSC_ENABLED) {
+		/* Enable 82599 HW-RSC */
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			j = adapter->rx_ring[i].reg_idx;
+			rscctrl = IXGBE_READ_REG(hw, IXGBE_RSCCTL(j));
+			rscctrl |= IXGBE_RSCCTL_RSCEN;
+			/*
+			 *  if packet split is enabled we can only support up
+			 *  to max frags + 1 descriptors.
+			 */
+			if (adapter->flags & IXGBE_FLAG_RX_PS_ENABLED)
+#if (MAX_SKB_FRAGS < 3)
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
+#elif (MAX_SKB_FRAGS < 7)
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
+#elif (MAX_SKB_FRAGS < 15)
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
+#else
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+#endif
+			else
+				rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
+			IXGBE_WRITE_REG(hw, IXGBE_RSCCTL(j), rscctrl);
+		}
+		/* Disable RSC for ACK packets */
+		IXGBE_WRITE_REG(hw, IXGBE_RSCDBU,
+		   (IXGBE_RSCDBU_RSCACKDIS | IXGBE_READ_REG(hw, IXGBE_RSCDBU)));
+	}
 }
 
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -2445,8 +2529,13 @@ static void ixgbe_clean_rx_ring(struct ixgbe_adapter *adapter,
 			rx_buffer_info->dma = 0;
 		}
 		if (rx_buffer_info->skb) {
-			dev_kfree_skb(rx_buffer_info->skb);
+			struct sk_buff *skb = rx_buffer_info->skb;
 			rx_buffer_info->skb = NULL;
+			do {
+				struct sk_buff *this = skb;
+				skb = skb->prev;
+				dev_kfree_skb(this);
+			} while (skb);
 		}
 		if (!rx_buffer_info->page)
 			continue;
@@ -3187,8 +3276,11 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 	adapter->ring_feature[RING_F_DCB].indices = IXGBE_MAX_DCB_INDICES;
 	if (hw->mac.type == ixgbe_mac_82598EB)
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
-	else if (hw->mac.type == ixgbe_mac_82599EB)
+	else if (hw->mac.type == ixgbe_mac_82599EB) {
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
+		adapter->flags |= IXGBE_FLAG_RSC_CAPABLE;
+		adapter->flags |= IXGBE_FLAG_RSC_ENABLED;
+	}
 
 #ifdef CONFIG_IXGBE_DCB
 	/* Configure DCB traffic classes */
@@ -3772,9 +3864,13 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 
 	if (hw->mac.type == ixgbe_mac_82599EB) {
+		u64 rsc_count = 0;
 		for (i = 0; i < 16; i++)
 			adapter->hw_rx_no_dma_resources +=
 			                     IXGBE_READ_REG(hw, IXGBE_QPRDC(i));
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			rsc_count += adapter->rx_ring[i].rsc_count;
+		adapter->rsc_count = rsc_count;
 	}
 
 	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
@@ -4749,6 +4845,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+	if (adapter->flags & IXGBE_FLAG_RSC_ENABLED)
+		netdev->features |= NETIF_F_LRO;
+
 	/* make sure the EEPROM is good */
 	if (hw->eeprom.ops.validate_checksum(hw, NULL) < 0) {
 		dev_err(&pdev->dev, "The EEPROM Checksum Is Not Valid\n");
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 375f0d4..bdfdf3b 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -443,6 +443,21 @@
 
 #define IXGBE_SECTXCTRL_STORE_FORWARD_ENABLE    0x4
 
+/* HW RSC registers */
+#define IXGBE_RSCCTL(_i) (((_i) < 64) ? (0x0102C + ((_i) * 0x40)) : \
+                          (0x0D02C + ((_i - 64) * 0x40)))
+#define IXGBE_RSCDBU      0x03028
+#define IXGBE_RSCCTL_RSCEN          0x01
+#define IXGBE_RSCCTL_MAXDESC_1      0x00
+#define IXGBE_RSCCTL_MAXDESC_4      0x04
+#define IXGBE_RSCCTL_MAXDESC_8      0x08
+#define IXGBE_RSCCTL_MAXDESC_16     0x0C
+#define IXGBE_RXDADV_RSCCNT_SHIFT     17
+#define IXGBE_GPIE_RSC_DELAY_SHIFT    11
+#define IXGBE_RXDADV_RSCCNT_MASK    0x001E0000
+#define IXGBE_RSCDBU_RSCACKDIS      0x00000080
+#define IXGBE_RDRXCTL_RSCFRSTSIZE   0x003E0000
+
 /* DCB registers */
 #define IXGBE_RTRPCS      0x02430
 #define IXGBE_RTTDCS      0x04900

