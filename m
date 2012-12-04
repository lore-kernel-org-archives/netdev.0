From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/5 net-next v2] tg3: PTP - Enable the timestamping
 feature in hardware and fill skb tx/rx timestamps
Date: Mon, 3 Dec 2012 21:37:00 -0800
Message-ID: <1354599420-3589-5-git-send-email-mchan@broadcom.com>
References: <1354599420-3589-1-git-send-email-mchan@broadcom.com>
 <1354599420-3589-2-git-send-email-mchan@broadcom.com>
 <1354599420-3589-3-git-send-email-mchan@broadcom.com>
 <1354599420-3589-4-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com,
	richardcochran@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3678 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370Ab2LDFVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2012 00:21:54 -0500
In-Reply-To: <1354599420-3589-4-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

This patch implements the hardware timestamping as described in
Documentation/networking/timestamping.txt

Update version to 3.128.

Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
Cc: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   57 +++++++++++++++++++++++++++++++---
 1 files changed, 52 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index dddb21e..23918ce 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -93,10 +93,10 @@ static inline void _tg3_flag_clear(enum TG3_FLAGS flag, unsigned long *bits)
 
 #define DRV_MODULE_NAME		"tg3"
 #define TG3_MAJ_NUM			3
-#define TG3_MIN_NUM			127
+#define TG3_MIN_NUM			128
 #define DRV_MODULE_VERSION	\
 	__stringify(TG3_MAJ_NUM) "." __stringify(TG3_MIN_NUM)
-#define DRV_MODULE_RELDATE	"November 14, 2012"
+#define DRV_MODULE_RELDATE	"December 03, 2012"
 
 #define RESET_KIND_SHUTDOWN	0
 #define RESET_KIND_INIT		1
@@ -5663,6 +5663,14 @@ static const struct ptp_clock_info tg3_ptp_caps = {
 	.enable		= tg3_ptp_enable,
 };
 
+static void tg3_hwclock_to_timestamp(struct tg3 *tp, u64 hwclock,
+				     struct skb_shared_hwtstamps *timestamp)
+{
+	memset(timestamp, 0, sizeof(struct skb_shared_hwtstamps));
+	timestamp->hwtstamp  = ns_to_ktime((hwclock & TG3_TSTAMP_MASK) +
+					   tp->ptp_adjust);
+}
+
 /* tp->lock must be held */
 static void tg3_ptp_init(struct tg3 *tp)
 {
@@ -5875,6 +5883,16 @@ static void tg3_tx(struct tg3_napi *tnapi)
 			return;
 		}
 
+		if (tnapi->tx_ring[sw_idx].len_flags & TXD_FLAG_HWTSTAMP) {
+			struct skb_shared_hwtstamps timestamp;
+			u64 hwclock = tr32(TG3_TX_TSTAMP_LSB);
+			hwclock |= (u64)tr32(TG3_TX_TSTAMP_MSB) << 32;
+
+			tg3_hwclock_to_timestamp(tp, hwclock, &timestamp);
+
+			skb_tstamp_tx(skb, &timestamp);
+		}
+
 		pci_unmap_single(tp->pdev,
 				 dma_unmap_addr(ri, mapping),
 				 skb_headlen(skb),
@@ -6142,6 +6160,7 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		dma_addr_t dma_addr;
 		u32 opaque_key, desc_idx, *post_ptr;
 		u8 *data;
+		u64 tstamp = 0;
 
 		desc_idx = desc->opaque & RXD_OPAQUE_INDEX_MASK;
 		opaque_key = desc->opaque & RXD_OPAQUE_RING_MASK;
@@ -6176,6 +6195,14 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) -
 		      ETH_FCS_LEN;
 
+		if ((desc->type_flags & RXD_FLAG_PTPSTAT_MASK) ==
+		     RXD_FLAG_PTPSTAT_PTPV1 ||
+		    (desc->type_flags & RXD_FLAG_PTPSTAT_MASK) ==
+		     RXD_FLAG_PTPSTAT_PTPV2) {
+			tstamp = tr32(TG3_RX_TSTAMP_LSB);
+			tstamp |= (u64)tr32(TG3_RX_TSTAMP_MSB) << 32;
+		}
+
 		if (len > TG3_RX_COPY_THRESH(tp)) {
 			int skb_size;
 			unsigned int frag_size;
@@ -6219,6 +6246,10 @@ static int tg3_rx(struct tg3_napi *tnapi, int budget)
 		}
 
 		skb_put(skb, len);
+		if (tstamp)
+			tg3_hwclock_to_timestamp(tp, tstamp,
+						 skb_hwtstamps(skb));
+
 		if ((tp->dev->features & NETIF_F_RXCSUM) &&
 		    (desc->type_flags & RXD_FLAG_TCPUDP_CSUM) &&
 		    (((desc->ip_tcp_csum & RXD_TCPCSUM_MASK)
@@ -7276,6 +7307,12 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		vlan = vlan_tx_tag_get(skb);
 	}
 
+	if ((unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) &&
+	    tg3_flag(tp, TX_TSTAMP_EN)) {
+		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		base_flags |= TXD_FLAG_HWTSTAMP;
+	}
+
 	len = skb_headlen(skb);
 
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
@@ -9144,9 +9181,15 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	 */
 	tp->grc_mode |= GRC_MODE_NO_TX_PHDR_CSUM;
 
-	tw32(GRC_MODE,
-	     tp->grc_mode |
-	     (GRC_MODE_IRQ_ON_MAC_ATTN | GRC_MODE_HOST_STACKUP));
+	val = GRC_MODE_IRQ_ON_MAC_ATTN | GRC_MODE_HOST_STACKUP;
+	if (tp->rxptpctl)
+		tw32(TG3_RX_PTP_CTL,
+		     tp->rxptpctl | TG3_RX_PTP_CTL_HWTS_INTERLOCK);
+
+	if (tg3_flag(tp, PTP_CAPABLE))
+		val |= GRC_MODE_TIME_SYNC_ENABLE;
+
+	tw32(GRC_MODE, tp->grc_mode | val);
 
 	/* Setup the timer prescalar register.  Clock is always 66Mhz. */
 	val = tr32(GRC_MISC_CFG);
@@ -16564,6 +16607,10 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, dev);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5719 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5720)
+		tg3_flag_set(tp, PTP_CAPABLE);
+
 	if (tg3_flag(tp, 5717_PLUS)) {
 		/* Resume a low-power mode */
 		tg3_frob_aux_power(tp, false);
-- 
1.7.1
