From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 2/8] amd-xgbe: Add hardware timestamp support
Date: Tue, 29 Jul 2014 08:57:19 -0500
Message-ID: <20140729135719.2791.71997.stgit@tlendack-t1.amdoffice.net>
References: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1blp0181.outbound.protection.outlook.com ([207.46.163.181]:55714
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753634AbaG2N50 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 09:57:26 -0400
In-Reply-To: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for Tx and Rx hardware timestamping.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 Documentation/devicetree/bindings/net/amd-xgbe.txt |   16 +
 drivers/net/ethernet/amd/Kconfig                   |    1 
 drivers/net/ethernet/amd/xgbe/Makefile             |    3 
 drivers/net/ethernet/amd/xgbe/xgbe-common.h        |   71 ++++
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c          |    9 
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c           |  143 +++++++-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c           |  372 ++++++++++++++++++--
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c       |   35 ++
 drivers/net/ethernet/amd/xgbe/xgbe-main.c          |   21 +
 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c           |  285 +++++++++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h               |   56 +++
 11 files changed, 954 insertions(+), 58 deletions(-)
 create mode 100644 drivers/net/ethernet/amd/xgbe/xgbe-ptp.c

diff --git a/Documentation/devicetree/bindings/net/amd-xgbe.txt b/Documentation/devicetree/bindings/net/amd-xgbe.txt
index f6db1ba..41354f7 100644
--- a/Documentation/devicetree/bindings/net/amd-xgbe.txt
+++ b/Documentation/devicetree/bindings/net/amd-xgbe.txt
@@ -8,10 +8,14 @@ Required properties:
 - interrupt-parent: Should be the phandle for the interrupt controller
   that services interrupts for this device
 - interrupts: Should contain the amd-xgbe interrupt
-- clocks: Should be the DMA clock for the amd-xgbe device (used for
-  calculating the correct Rx interrupt watchdog timer value on a DMA
-  channel for coalescing)
-- clock-names: Should be the name of the DMA clock, "dma_clk"
+- clocks:
+   - DMA clock for the amd-xgbe device (used for calculating the
+     correct Rx interrupt watchdog timer value on a DMA channel
+     for coalescing)
+   - PTP clock for the amd-xgbe device
+- clock-names: Should be the names of the clocks
+   - "dma_clk" for the DMA clock
+   - "ptp_clk" for the PTP clock
 - phy-handle: See ethernet.txt file in the same directory
 - phy-mode: See ethernet.txt file in the same directory
 
@@ -27,8 +31,8 @@ Example:
 		      <0 0xe0780000 0 0x80000>;
 		interrupt-parent = <&gic>;
 		interrupts = <0 325 4>;
-		clocks = <&xgbe_clk>;
-		clock-names = "dma_clk";
+		clocks = <&xgbe_dma_clk>, <&xgbe_ptp_clk>;
+		clock-names = "dma_clk", "ptp_clk";
 		phy-handle = <&phy>;
 		phy-mode = "xgmii";
 		mac-address = [ 02 a1 a2 a3 a4 a5 ];
diff --git a/drivers/net/ethernet/amd/Kconfig b/drivers/net/ethernet/amd/Kconfig
index 6e314db..98ef8ff 100644
--- a/drivers/net/ethernet/amd/Kconfig
+++ b/drivers/net/ethernet/amd/Kconfig
@@ -184,6 +184,7 @@ config AMD_XGBE
 	select AMD_XGBE_PHY
 	select BITREVERSE
 	select CRC32
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports the AMD 10GbE Ethernet device found on an
 	  AMD SoC.
diff --git a/drivers/net/ethernet/amd/xgbe/Makefile b/drivers/net/ethernet/amd/xgbe/Makefile
index 26cf9af..66c49b4 100644
--- a/drivers/net/ethernet/amd/xgbe/Makefile
+++ b/drivers/net/ethernet/amd/xgbe/Makefile
@@ -1,6 +1,7 @@
 obj-$(CONFIG_AMD_XGBE) += amd-xgbe.o
 
 amd-xgbe-objs := xgbe-main.o xgbe-drv.o xgbe-dev.o \
-		 xgbe-desc.o xgbe-ethtool.o xgbe-mdio.o
+		 xgbe-desc.o xgbe-ethtool.o xgbe-mdio.o \
+		 xgbe-ptp.o
 
 amd-xgbe-$(CONFIG_DEBUG_FS) += xgbe-debugfs.o
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-common.h b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
index 7ec80ac..646702c 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-common.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-common.h
@@ -307,6 +307,16 @@
 #define MAC_MACA0LR			0x0304
 #define MAC_MACA1HR			0x0308
 #define MAC_MACA1LR			0x030c
+#define MAC_TSCR			0x0d00
+#define MAC_SSIR			0x0d04
+#define MAC_STSR			0x0d08
+#define MAC_STNR			0x0d0c
+#define MAC_STSUR			0x0d10
+#define MAC_STNUR			0x0d14
+#define MAC_TSAR			0x0d18
+#define MAC_TSSR			0x0d20
+#define MAC_TXSNR			0x0d30
+#define MAC_TXSSR			0x0d34
 
 #define MAC_QTFCR_INC			4
 #define MAC_MACA_INC			4
@@ -373,12 +383,16 @@
 #define MAC_HWF2R_TXCHCNT_WIDTH		4
 #define MAC_HWF2R_TXQCNT_INDEX		6
 #define MAC_HWF2R_TXQCNT_WIDTH		4
+#define MAC_IER_TSIE_INDEX		12
+#define MAC_IER_TSIE_WIDTH		1
 #define MAC_ISR_MMCRXIS_INDEX		9
 #define MAC_ISR_MMCRXIS_WIDTH		1
 #define MAC_ISR_MMCTXIS_INDEX		10
 #define MAC_ISR_MMCTXIS_WIDTH		1
 #define MAC_ISR_PMTIS_INDEX		4
 #define MAC_ISR_PMTIS_WIDTH		1
+#define MAC_ISR_TSIS_INDEX		12
+#define MAC_ISR_TSIS_WIDTH		1
 #define MAC_MACA1HR_AE_INDEX		31
 #define MAC_MACA1HR_AE_WIDTH		1
 #define MAC_PFR_HMC_INDEX		2
@@ -423,10 +437,48 @@
 #define MAC_RFCR_RFE_WIDTH		1
 #define MAC_RQC0R_RXQ0EN_INDEX		0
 #define MAC_RQC0R_RXQ0EN_WIDTH		2
+#define MAC_SSIR_SNSINC_INDEX		8
+#define MAC_SSIR_SNSINC_WIDTH		8
+#define MAC_SSIR_SSINC_INDEX		16
+#define MAC_SSIR_SSINC_WIDTH		8
 #define MAC_TCR_SS_INDEX		29
 #define MAC_TCR_SS_WIDTH		2
 #define MAC_TCR_TE_INDEX		0
 #define MAC_TCR_TE_WIDTH		1
+#define MAC_TSCR_AV8021ASMEN_INDEX	28
+#define MAC_TSCR_AV8021ASMEN_WIDTH	1
+#define MAC_TSCR_SNAPTYPSEL_INDEX	16
+#define MAC_TSCR_SNAPTYPSEL_WIDTH	2
+#define MAC_TSCR_TSADDREG_INDEX		5
+#define MAC_TSCR_TSADDREG_WIDTH		1
+#define MAC_TSCR_TSCFUPDT_INDEX		1
+#define MAC_TSCR_TSCFUPDT_WIDTH		1
+#define MAC_TSCR_TSCTRLSSR_INDEX	9
+#define MAC_TSCR_TSCTRLSSR_WIDTH	1
+#define MAC_TSCR_TSENA_INDEX		0
+#define MAC_TSCR_TSENA_WIDTH		1
+#define MAC_TSCR_TSENALL_INDEX		8
+#define MAC_TSCR_TSENALL_WIDTH		1
+#define MAC_TSCR_TSEVNTENA_INDEX	14
+#define MAC_TSCR_TSEVNTENA_WIDTH	1
+#define MAC_TSCR_TSINIT_INDEX		2
+#define MAC_TSCR_TSINIT_WIDTH		1
+#define MAC_TSCR_TSIPENA_INDEX		11
+#define MAC_TSCR_TSIPENA_WIDTH		1
+#define MAC_TSCR_TSIPV4ENA_INDEX	13
+#define MAC_TSCR_TSIPV4ENA_WIDTH	1
+#define MAC_TSCR_TSIPV6ENA_INDEX	12
+#define MAC_TSCR_TSIPV6ENA_WIDTH	1
+#define MAC_TSCR_TSMSTRENA_INDEX	15
+#define MAC_TSCR_TSMSTRENA_WIDTH	1
+#define MAC_TSCR_TSVER2ENA_INDEX	10
+#define MAC_TSCR_TSVER2ENA_WIDTH	1
+#define MAC_TSCR_TXTSSTSM_INDEX		24
+#define MAC_TSCR_TXTSSTSM_WIDTH		1
+#define MAC_TSSR_TXTSC_INDEX		15
+#define MAC_TSSR_TXTSC_WIDTH		1
+#define MAC_TXSNR_TXTSSTSMIS_INDEX	31
+#define MAC_TXSNR_TXTSSTSMIS_WIDTH	1
 #define MAC_VLANHTR_VLHT_INDEX		0
 #define MAC_VLANHTR_VLHT_WIDTH		16
 #define MAC_VLANIR_VLTI_INDEX		20
@@ -778,9 +830,19 @@
 #define RX_PACKET_ATTRIBUTES_VLAN_CTAG_WIDTH	1
 #define RX_PACKET_ATTRIBUTES_INCOMPLETE_INDEX	2
 #define RX_PACKET_ATTRIBUTES_INCOMPLETE_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_INDEX	3
+#define RX_PACKET_ATTRIBUTES_CONTEXT_NEXT_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_CONTEXT_INDEX	4
+#define RX_PACKET_ATTRIBUTES_CONTEXT_WIDTH	1
+#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_INDEX	5
+#define RX_PACKET_ATTRIBUTES_RX_TSTAMP_WIDTH	1
 
 #define RX_NORMAL_DESC0_OVT_INDEX		0
 #define RX_NORMAL_DESC0_OVT_WIDTH		16
+#define RX_NORMAL_DESC3_CDA_INDEX		27
+#define RX_NORMAL_DESC3_CDA_WIDTH		1
+#define RX_NORMAL_DESC3_CTXT_INDEX		30
+#define RX_NORMAL_DESC3_CTXT_WIDTH		1
 #define RX_NORMAL_DESC3_ES_INDEX		15
 #define RX_NORMAL_DESC3_ES_WIDTH		1
 #define RX_NORMAL_DESC3_ETLT_INDEX		16
@@ -794,12 +856,19 @@
 #define RX_NORMAL_DESC3_PL_INDEX		0
 #define RX_NORMAL_DESC3_PL_WIDTH		14
 
+#define RX_CONTEXT_DESC3_TSA_INDEX		4
+#define RX_CONTEXT_DESC3_TSA_WIDTH		1
+#define RX_CONTEXT_DESC3_TSD_INDEX		6
+#define RX_CONTEXT_DESC3_TSD_WIDTH		1
+
 #define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_INDEX	0
 #define TX_PACKET_ATTRIBUTES_CSUM_ENABLE_WIDTH	1
 #define TX_PACKET_ATTRIBUTES_TSO_ENABLE_INDEX	1
 #define TX_PACKET_ATTRIBUTES_TSO_ENABLE_WIDTH	1
 #define TX_PACKET_ATTRIBUTES_VLAN_CTAG_INDEX	2
 #define TX_PACKET_ATTRIBUTES_VLAN_CTAG_WIDTH	1
+#define TX_PACKET_ATTRIBUTES_PTP_INDEX		3
+#define TX_PACKET_ATTRIBUTES_PTP_WIDTH		1
 
 #define TX_CONTEXT_DESC2_MSS_INDEX		0
 #define TX_CONTEXT_DESC2_MSS_WIDTH		15
@@ -816,6 +885,8 @@
 #define TX_NORMAL_DESC2_HL_B1L_WIDTH		14
 #define TX_NORMAL_DESC2_IC_INDEX		31
 #define TX_NORMAL_DESC2_IC_WIDTH		1
+#define TX_NORMAL_DESC2_TTSE_INDEX		30
+#define TX_NORMAL_DESC2_TTSE_WIDTH		1
 #define TX_NORMAL_DESC2_VTIR_INDEX		14
 #define TX_NORMAL_DESC2_VTIR_WIDTH		2
 #define TX_NORMAL_DESC3_CIC_INDEX		16
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index a9ce56d..1c5d62e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -359,6 +359,15 @@ static void xgbe_unmap_skb(struct xgbe_prv_data *pdata,
 	rdata->len = 0;
 	rdata->interrupt = 0;
 	rdata->mapped_as_page = 0;
+
+	if (rdata->state_saved) {
+		rdata->state_saved = 0;
+		rdata->state.incomplete = 0;
+		rdata->state.context_next = 0;
+		rdata->state.skb = NULL;
+		rdata->state.len = 0;
+		rdata->state.error = 0;
+	}
 }
 
 static int xgbe_map_tx_skb(struct xgbe_channel *channel, struct sk_buff *skb)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 699cff5..098a746 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -131,7 +131,7 @@ static unsigned int xgbe_usec_to_riwt(struct xgbe_prv_data *pdata,
 
 	DBGPR("-->xgbe_usec_to_riwt\n");
 
-	rate = clk_get_rate(pdata->sysclock);
+	rate = clk_get_rate(pdata->sysclk);
 
 	/*
 	 * Convert the input usec value to the watchdog timer value. Each
@@ -154,7 +154,7 @@ static unsigned int xgbe_riwt_to_usec(struct xgbe_prv_data *pdata,
 
 	DBGPR("-->xgbe_riwt_to_usec\n");
 
-	rate = clk_get_rate(pdata->sysclock);
+	rate = clk_get_rate(pdata->sysclk);
 
 	/*
 	 * Convert the input watchdog timer value to the usec value. Each
@@ -492,8 +492,12 @@ static void xgbe_enable_mtl_interrupts(struct xgbe_prv_data *pdata)
 
 static void xgbe_enable_mac_interrupts(struct xgbe_prv_data *pdata)
 {
-	/* No MAC interrupts to be enabled */
-	XGMAC_IOWRITE(pdata, MAC_IER, 0);
+	unsigned int mac_ier = 0;
+
+	/* Enable Timestamp interrupt */
+	XGMAC_SET_BITS(mac_ier, MAC_IER, TSIE, 1);
+
+	XGMAC_IOWRITE(pdata, MAC_IER, mac_ier);
 
 	/* Enable all counter interrupts */
 	XGMAC_IOWRITE_BITS(pdata, MMC_RIER, ALL_INTERRUPTS, 0xff);
@@ -1012,6 +1016,107 @@ static void xgbe_rx_desc_init(struct xgbe_channel *channel)
 	DBGPR("<--rx_desc_init\n");
 }
 
+static void xgbe_update_tstamp_addend(struct xgbe_prv_data *pdata,
+				      unsigned int addend)
+{
+	/* Set the addend register value and tell the device */
+	XGMAC_IOWRITE(pdata, MAC_TSAR, addend);
+	XGMAC_IOWRITE_BITS(pdata, MAC_TSCR, TSADDREG, 1);
+
+	/* Wait for addend update to complete */
+	while (XGMAC_IOREAD_BITS(pdata, MAC_TSCR, TSADDREG))
+		udelay(5);
+}
+
+static void xgbe_set_tstamp_time(struct xgbe_prv_data *pdata, unsigned int sec,
+				 unsigned int nsec)
+{
+	/* Set the time values and tell the device */
+	XGMAC_IOWRITE(pdata, MAC_STSUR, sec);
+	XGMAC_IOWRITE(pdata, MAC_STNUR, nsec);
+	XGMAC_IOWRITE_BITS(pdata, MAC_TSCR, TSINIT, 1);
+
+	/* Wait for time update to complete */
+	while (XGMAC_IOREAD_BITS(pdata, MAC_TSCR, TSINIT))
+		udelay(5);
+}
+
+static u64 xgbe_get_tstamp_time(struct xgbe_prv_data *pdata)
+{
+	u64 nsec;
+
+	nsec = XGMAC_IOREAD(pdata, MAC_STSR);
+	nsec *= NSEC_PER_SEC;
+	nsec += XGMAC_IOREAD(pdata, MAC_STNR);
+
+	return nsec;
+}
+
+static u64 xgbe_get_tx_tstamp(struct xgbe_prv_data *pdata)
+{
+	unsigned int tx_snr;
+	u64 nsec;
+
+	tx_snr = XGMAC_IOREAD(pdata, MAC_TXSNR);
+	if (XGMAC_GET_BITS(tx_snr, MAC_TXSNR, TXTSSTSMIS))
+		return 0;
+
+	nsec = XGMAC_IOREAD(pdata, MAC_TXSSR);
+	nsec *= NSEC_PER_SEC;
+	nsec += tx_snr;
+
+	return nsec;
+}
+
+static void xgbe_get_rx_tstamp(struct xgbe_packet_data *packet,
+			       struct xgbe_ring_desc *rdesc)
+{
+	u64 nsec;
+
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_CONTEXT_DESC3, TSA) &&
+	    !XGMAC_GET_BITS_LE(rdesc->desc3, RX_CONTEXT_DESC3, TSD)) {
+		nsec = le32_to_cpu(rdesc->desc1);
+		nsec <<= 32;
+		nsec |= le32_to_cpu(rdesc->desc0);
+		if (nsec != 0xffffffffffffffffULL) {
+			packet->rx_tstamp = nsec;
+			XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+				       RX_TSTAMP, 1);
+		}
+	}
+}
+
+static int xgbe_config_tstamp(struct xgbe_prv_data *pdata,
+			      unsigned int mac_tscr)
+{
+	/* Set one nano-second accuracy */
+	XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSCTRLSSR, 1);
+
+	/* Set fine timestamp update */
+	XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSCFUPDT, 1);
+
+	/* Overwrite earlier timestamps */
+	XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TXTSSTSM, 1);
+
+	XGMAC_IOWRITE(pdata, MAC_TSCR, mac_tscr);
+
+	/* Exit if timestamping is not enabled */
+	if (!XGMAC_GET_BITS(mac_tscr, MAC_TSCR, TSENA))
+		return 0;
+
+	/* Initialize time registers */
+	XGMAC_IOWRITE_BITS(pdata, MAC_SSIR, SSINC, XGBE_TSTAMP_SSINC);
+	XGMAC_IOWRITE_BITS(pdata, MAC_SSIR, SNSINC, XGBE_TSTAMP_SNSINC);
+	xgbe_update_tstamp_addend(pdata, pdata->tstamp_addend);
+	xgbe_set_tstamp_time(pdata, 0, 0);
+
+	/* Initialize the timecounter */
+	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc,
+			 ktime_to_ns(ktime_get_real()));
+
+	return 0;
+}
+
 static void xgbe_pre_xmit(struct xgbe_channel *channel)
 {
 	struct xgbe_prv_data *pdata = channel->pdata;
@@ -1110,6 +1215,10 @@ static void xgbe_pre_xmit(struct xgbe_channel *channel)
 		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, VTIR,
 				  TX_NORMAL_DESC2_VLAN_INSERT);
 
+	/* Timestamp enablement check */
+	if (XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES, PTP))
+		XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, TTSE, 1);
+
 	/* Set IC bit based on Tx coalescing settings */
 	XGMAC_SET_BITS_LE(rdesc->desc2, TX_NORMAL_DESC2, IC, 1);
 	if (tx_coalesce && (!tx_frames ||
@@ -1245,6 +1354,25 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 	xgbe_dump_rx_desc(ring, rdesc, ring->cur);
 #endif
 
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, CTXT)) {
+		/* Timestamp Context Descriptor */
+		xgbe_get_rx_tstamp(packet, rdesc);
+
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       CONTEXT, 1);
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       CONTEXT_NEXT, 0);
+		return 0;
+	}
+
+	/* Normal Descriptor, be sure Context Descriptor bit is off */
+	XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES, CONTEXT, 0);
+
+	/* Indicate if a Context Descriptor is next */
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, CDA))
+		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
+			       CONTEXT_NEXT, 1);
+
 	/* Get the packet length */
 	rdata->len = XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, PL);
 
@@ -2313,5 +2441,12 @@ void xgbe_init_function_ptrs_dev(struct xgbe_hw_if *hw_if)
 	hw_if->rx_mmc_int = xgbe_rx_mmc_int;
 	hw_if->read_mmc_stats = xgbe_read_mmc_stats;
 
+	/* For PTP config */
+	hw_if->config_tstamp = xgbe_config_tstamp;
+	hw_if->update_tstamp_addend = xgbe_update_tstamp_addend;
+	hw_if->set_tstamp_time = xgbe_set_tstamp_time;
+	hw_if->get_tstamp_time = xgbe_get_tstamp_time;
+	hw_if->get_tx_tstamp = xgbe_get_tx_tstamp;
+
 	DBGPR("<--xgbe_init_function_ptrs\n");
 }
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 344e6b1..47a1e25 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -121,6 +121,7 @@
 #include <net/busy_poll.h>
 #include <linux/clk.h>
 #include <linux/if_ether.h>
+#include <linux/net_tstamp.h>
 
 #include "xgbe.h"
 #include "xgbe-common.h"
@@ -202,7 +203,7 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 	struct xgbe_hw_if *hw_if = &pdata->hw_if;
 	struct xgbe_channel *channel;
 	unsigned int dma_isr, dma_ch_isr;
-	unsigned int mac_isr;
+	unsigned int mac_isr, mac_tssr;
 	unsigned int i;
 
 	/* The DMA interrupt status register also reports MAC and MTL
@@ -255,6 +256,17 @@ static irqreturn_t xgbe_isr(int irq, void *data)
 
 		if (XGMAC_GET_BITS(mac_isr, MAC_ISR, MMCRXIS))
 			hw_if->rx_mmc_int(pdata);
+
+		if (XGMAC_GET_BITS(mac_isr, MAC_ISR, TSIS)) {
+			mac_tssr = XGMAC_IOREAD(pdata, MAC_TSSR);
+
+			if (XGMAC_GET_BITS(mac_tssr, MAC_TSSR, TXTSC)) {
+				/* Read Tx Timestamp to clear interrupt */
+				pdata->tx_tstamp =
+					hw_if->get_tx_tstamp(pdata);
+				schedule_work(&pdata->tx_tstamp_work);
+			}
+		}
 	}
 
 	DBGPR("  DMA_ISR = %08x\n", XGMAC_IOREAD(pdata, DMA_ISR));
@@ -668,6 +680,197 @@ static void xgbe_restart(struct work_struct *work)
 	rtnl_unlock();
 }
 
+static void xgbe_tx_tstamp(struct work_struct *work)
+{
+	struct xgbe_prv_data *pdata = container_of(work,
+						   struct xgbe_prv_data,
+						   tx_tstamp_work);
+	struct skb_shared_hwtstamps hwtstamps;
+	u64 nsec;
+	unsigned long flags;
+
+	if (pdata->tx_tstamp) {
+		nsec = timecounter_cyc2time(&pdata->tstamp_tc,
+					    pdata->tx_tstamp);
+
+		memset(&hwtstamps, 0, sizeof(hwtstamps));
+		hwtstamps.hwtstamp = ns_to_ktime(nsec);
+		skb_tstamp_tx(pdata->tx_tstamp_skb, &hwtstamps);
+	}
+
+	dev_kfree_skb_any(pdata->tx_tstamp_skb);
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+	pdata->tx_tstamp_skb = NULL;
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+}
+
+static int xgbe_get_hwtstamp_settings(struct xgbe_prv_data *pdata,
+				      struct ifreq *ifreq)
+{
+	if (copy_to_user(ifreq->ifr_data, &pdata->tstamp_config,
+			 sizeof(pdata->tstamp_config)))
+		return -EFAULT;
+
+	return 0;
+}
+
+static int xgbe_set_hwtstamp_settings(struct xgbe_prv_data *pdata,
+				      struct ifreq *ifreq)
+{
+	struct hwtstamp_config config;
+	unsigned int mac_tscr;
+
+	if (copy_from_user(&config, ifreq->ifr_data, sizeof(config)))
+		return -EFAULT;
+
+	if (config.flags)
+		return -EINVAL;
+
+	mac_tscr = 0;
+
+	switch (config.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		break;
+
+	case HWTSTAMP_TX_ON:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	default:
+		return -ERANGE;
+	}
+
+	switch (config.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		break;
+
+	case HWTSTAMP_FILTER_ALL:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENALL, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2, UDP, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+	/* PTP v1, UDP, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, SNAPTYPSEL, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2, UDP, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+	/* PTP v1, UDP, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2, UDP, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+	/* PTP v1, UDP, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSMSTRENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* 802.AS1, Ethernet, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, AV8021ASMEN, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, SNAPTYPSEL, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* 802.AS1, Ethernet, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, AV8021ASMEN, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* 802.AS1, Ethernet, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, AV8021ASMEN, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSMSTRENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2/802.AS1, any layer, any kind of event packet */
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, SNAPTYPSEL, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2/802.AS1, any layer, Sync packet */
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	/* PTP v2/802.AS1, any layer, Delay_req packet */
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSVER2ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV4ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSIPV6ENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSMSTRENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSEVNTENA, 1);
+		XGMAC_SET_BITS(mac_tscr, MAC_TSCR, TSENA, 1);
+		break;
+
+	default:
+		return -ERANGE;
+	}
+
+	pdata->hw_if.config_tstamp(pdata, mac_tscr);
+
+	memcpy(&pdata->tstamp_config, &config, sizeof(config));
+
+	return 0;
+}
+
+static void xgbe_prep_tx_tstamp(struct xgbe_prv_data *pdata,
+				struct sk_buff *skb,
+				struct xgbe_packet_data *packet)
+{
+	unsigned long flags;
+
+	if (XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES, PTP)) {
+		spin_lock_irqsave(&pdata->tstamp_lock, flags);
+		if (pdata->tx_tstamp_skb) {
+			/* Another timestamp in progress, ignore this one */
+			XGMAC_SET_BITS(packet->attributes,
+				       TX_PACKET_ATTRIBUTES, PTP, 0);
+		} else {
+			pdata->tx_tstamp_skb = skb_get(skb);
+			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
+		}
+		spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+	}
+
+	if (!XGMAC_GET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES, PTP))
+		skb_tx_timestamp(skb);
+}
+
 static void xgbe_prep_vlan(struct sk_buff *skb, struct xgbe_packet_data *packet)
 {
 	if (vlan_tx_tag_present(skb))
@@ -711,7 +914,8 @@ static int xgbe_is_tso(struct sk_buff *skb)
 	return 1;
 }
 
-static void xgbe_packet_info(struct xgbe_ring *ring, struct sk_buff *skb,
+static void xgbe_packet_info(struct xgbe_prv_data *pdata,
+			     struct xgbe_ring *ring, struct sk_buff *skb,
 			     struct xgbe_packet_data *packet)
 {
 	struct skb_frag_struct *frag;
@@ -753,6 +957,11 @@ static void xgbe_packet_info(struct xgbe_ring *ring, struct sk_buff *skb,
 			       VLAN_CTAG, 1);
 	}
 
+	if ((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+	    (pdata->tstamp_config.tx_type == HWTSTAMP_TX_ON))
+		XGMAC_SET_BITS(packet->attributes, TX_PACKET_ATTRIBUTES,
+			       PTP, 1);
+
 	for (len = skb_headlen(skb); len;) {
 		packet->rdesc_count++;
 		len -= min_t(unsigned int, len, XGBE_TX_MAX_BUF_SIZE);
@@ -776,26 +985,33 @@ static int xgbe_open(struct net_device *netdev)
 
 	DBGPR("-->xgbe_open\n");
 
-	/* Enable the clock */
-	ret = clk_prepare_enable(pdata->sysclock);
+	/* Enable the clocks */
+	ret = clk_prepare_enable(pdata->sysclk);
 	if (ret) {
-		netdev_alert(netdev, "clk_prepare_enable failed\n");
+		netdev_alert(netdev, "dma clk_prepare_enable failed\n");
 		return ret;
 	}
 
+	ret = clk_prepare_enable(pdata->ptpclk);
+	if (ret) {
+		netdev_alert(netdev, "ptp clk_prepare_enable failed\n");
+		goto err_sysclk;
+	}
+
 	/* Calculate the Rx buffer size before allocating rings */
 	ret = xgbe_calc_rx_buf_size(netdev, netdev->mtu);
 	if (ret < 0)
-		goto err_clk;
+		goto err_ptpclk;
 	pdata->rx_buf_size = ret;
 
 	/* Allocate the ring descriptors and buffers */
 	ret = desc_if->alloc_ring_resources(pdata);
 	if (ret)
-		goto err_clk;
+		goto err_ptpclk;
 
-	/* Initialize the device restart work struct */
+	/* Initialize the device restart and Tx timestamp work struct */
 	INIT_WORK(&pdata->restart_work, xgbe_restart);
+	INIT_WORK(&pdata->tx_tstamp_work, xgbe_tx_tstamp);
 
 	/* Request interrupts */
 	ret = devm_request_irq(pdata->dev, netdev->irq, xgbe_isr, 0,
@@ -824,8 +1040,11 @@ err_start:
 err_irq:
 	desc_if->free_ring_resources(pdata);
 
-err_clk:
-	clk_disable_unprepare(pdata->sysclock);
+err_ptpclk:
+	clk_disable_unprepare(pdata->ptpclk);
+
+err_sysclk:
+	clk_disable_unprepare(pdata->sysclk);
 
 	return ret;
 }
@@ -853,8 +1072,9 @@ static int xgbe_close(struct net_device *netdev)
 		pdata->irq_number = 0;
 	}
 
-	/* Disable the clock */
-	clk_disable_unprepare(pdata->sysclock);
+	/* Disable the clocks */
+	clk_disable_unprepare(pdata->ptpclk);
+	clk_disable_unprepare(pdata->sysclk);
 
 	DBGPR("<--xgbe_close\n");
 
@@ -890,7 +1110,7 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 
 	/* Calculate preliminary packet info */
 	memset(packet, 0, sizeof(*packet));
-	xgbe_packet_info(ring, skb, packet);
+	xgbe_packet_info(pdata, ring, skb, packet);
 
 	/* Check that there are enough descriptors available */
 	if (packet->rdesc_count > xgbe_tx_avail_desc(ring)) {
@@ -914,6 +1134,8 @@ static int xgbe_xmit(struct sk_buff *skb, struct net_device *netdev)
 		goto tx_netdev_return;
 	}
 
+	xgbe_prep_tx_tstamp(pdata, skb, packet);
+
 	/* Configure required descriptor fields for transmission */
 	hw_if->pre_xmit(channel);
 
@@ -968,6 +1190,27 @@ static int xgbe_set_mac_address(struct net_device *netdev, void *addr)
 	return 0;
 }
 
+static int xgbe_ioctl(struct net_device *netdev, struct ifreq *ifreq, int cmd)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+	int ret;
+
+	switch (cmd) {
+	case SIOCGHWTSTAMP:
+		ret = xgbe_get_hwtstamp_settings(pdata, ifreq);
+		break;
+
+	case SIOCSHWTSTAMP:
+		ret = xgbe_set_hwtstamp_settings(pdata, ifreq);
+		break;
+
+	default:
+		ret = -EOPNOTSUPP;
+	}
+
+	return ret;
+}
+
 static int xgbe_change_mtu(struct net_device *netdev, int mtu)
 {
 	struct xgbe_prv_data *pdata = netdev_priv(netdev);
@@ -1109,6 +1352,7 @@ static const struct net_device_ops xgbe_netdev_ops = {
 	.ndo_set_rx_mode	= xgbe_set_rx_mode,
 	.ndo_set_mac_address	= xgbe_set_mac_address,
 	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= xgbe_ioctl,
 	.ndo_change_mtu		= xgbe_change_mtu,
 	.ndo_get_stats64	= xgbe_get_stats64,
 	.ndo_vlan_rx_add_vid	= xgbe_vlan_rx_add_vid,
@@ -1202,8 +1446,9 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 	struct xgbe_packet_data *packet;
 	struct net_device *netdev = pdata->netdev;
 	struct sk_buff *skb;
-	unsigned int incomplete, error;
-	unsigned int cur_len, put_len, max_len;
+	struct skb_shared_hwtstamps *hwtstamps;
+	unsigned int incomplete, error, context_next, context;
+	unsigned int len, put_len, max_len;
 	int received = 0;
 
 	DBGPR("-->xgbe_rx_poll: budget=%d\n", budget);
@@ -1212,22 +1457,33 @@ static int xgbe_rx_poll(struct xgbe_channel *channel, int budget)
 	if (!ring)
 		return 0;
 
+	rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
 	packet = &ring->packet_data;
 	while (received < budget) {
 		DBGPR("  cur = %d\n", ring->cur);
 
-		/* Clear the packet data information */
-		memset(packet, 0, sizeof(*packet));
-		skb = NULL;
-		error = 0;
-		cur_len = 0;
+		/* First time in loop see if we need to restore state */
+		if (!received && rdata->state_saved) {
+			incomplete = rdata->state.incomplete;
+			context_next = rdata->state.context_next;
+			skb = rdata->state.skb;
+			error = rdata->state.error;
+			len = rdata->state.len;
+		} else {
+			memset(packet, 0, sizeof(*packet));
+			incomplete = 0;
+			context_next = 0;
+			skb = NULL;
+			error = 0;
+			len = 0;
+		}
 
 read_again:
+		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
+
 		if (ring->dirty > (XGBE_RX_DESC_CNT >> 3))
 			xgbe_rx_refresh(channel);
 
-		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
-
 		if (hw_if->dev_read(channel))
 			break;
 
@@ -1242,9 +1498,15 @@ read_again:
 		incomplete = XGMAC_GET_BITS(packet->attributes,
 					    RX_PACKET_ATTRIBUTES,
 					    INCOMPLETE);
+		context_next = XGMAC_GET_BITS(packet->attributes,
+					      RX_PACKET_ATTRIBUTES,
+					      CONTEXT_NEXT);
+		context = XGMAC_GET_BITS(packet->attributes,
+					 RX_PACKET_ATTRIBUTES,
+					 CONTEXT);
 
 		/* Earlier error, just drain the remaining data */
-		if (incomplete && error)
+		if ((incomplete || context_next) && error)
 			goto read_again;
 
 		if (error || packet->errors) {
@@ -1254,30 +1516,37 @@ read_again:
 			continue;
 		}
 
-		put_len = rdata->len - cur_len;
-		if (skb) {
-			if (pskb_expand_head(skb, 0, put_len, GFP_ATOMIC)) {
-				DBGPR("pskb_expand_head error\n");
-				if (incomplete) {
-					error = 1;
-					goto read_again;
+		if (!context) {
+			put_len = rdata->len - len;
+			if (skb) {
+				if (pskb_expand_head(skb, 0, put_len,
+						     GFP_ATOMIC)) {
+					DBGPR("pskb_expand_head error\n");
+					if (incomplete) {
+						error = 1;
+						goto read_again;
+					}
+
+					dev_kfree_skb(skb);
+					continue;
 				}
-
-				dev_kfree_skb(skb);
-				continue;
+				memcpy(skb_tail_pointer(skb), rdata->skb->data,
+				       put_len);
+			} else {
+				skb = rdata->skb;
+				rdata->skb = NULL;
 			}
-			memcpy(skb_tail_pointer(skb), rdata->skb->data,
-			       put_len);
-		} else {
-			skb = rdata->skb;
-			rdata->skb = NULL;
+			skb_put(skb, put_len);
+			len += put_len;
 		}
-		skb_put(skb, put_len);
-		cur_len += put_len;
 
-		if (incomplete)
+		if (incomplete || context_next)
 			goto read_again;
 
+		/* Stray Context Descriptor? */
+		if (!skb)
+			continue;
+
 		/* Be sure we don't exceed the configured MTU */
 		max_len = netdev->mtu + ETH_HLEN;
 		if (!(netdev->features & NETIF_F_HW_VLAN_CTAG_RX) &&
@@ -1304,6 +1573,16 @@ read_again:
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
 					       packet->vlan_ctag);
 
+		if (XGMAC_GET_BITS(packet->attributes,
+				   RX_PACKET_ATTRIBUTES, RX_TSTAMP)) {
+			u64 nsec;
+
+			nsec = timecounter_cyc2time(&pdata->tstamp_tc,
+						    packet->rx_tstamp);
+			hwtstamps = skb_hwtstamps(skb);
+			hwtstamps->hwtstamp = ns_to_ktime(nsec);
+		}
+
 		skb->dev = netdev;
 		skb->protocol = eth_type_trans(skb, netdev);
 		skb_record_rx_queue(skb, channel->queue_index);
@@ -1313,6 +1592,17 @@ read_again:
 		napi_gro_receive(&pdata->napi, skb);
 	}
 
+	/* Check if we need to save state before leaving */
+	if (received && (incomplete || context_next)) {
+		rdata = XGBE_GET_DESC_DATA(ring, ring->cur);
+		rdata->state_saved = 1;
+		rdata->state.incomplete = incomplete;
+		rdata->state.context_next = context_next;
+		rdata->state.skb = skb;
+		rdata->state.len = len;
+		rdata->state.error = error;
+	}
+
 	DBGPR("<--xgbe_rx_poll: received = %d\n", received);
 
 	return received;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index f740526..4961666 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -116,6 +116,7 @@
 
 #include <linux/spinlock.h>
 #include <linux/phy.h>
+#include <linux/net_tstamp.h>
 
 #include "xgbe.h"
 #include "xgbe-common.h"
@@ -480,6 +481,39 @@ static int xgbe_set_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int xgbe_get_ts_info(struct net_device *netdev,
+			    struct ethtool_ts_info *ts_info)
+{
+	struct xgbe_prv_data *pdata = netdev_priv(netdev);
+
+	ts_info->so_timestamping = SOF_TIMESTAMPING_TX_SOFTWARE |
+				   SOF_TIMESTAMPING_RX_SOFTWARE |
+				   SOF_TIMESTAMPING_SOFTWARE |
+				   SOF_TIMESTAMPING_TX_HARDWARE |
+				   SOF_TIMESTAMPING_RX_HARDWARE |
+				   SOF_TIMESTAMPING_RAW_HARDWARE;
+
+	if (pdata->ptp_clock)
+		ts_info->phc_index = ptp_clock_index(pdata->ptp_clock);
+	else
+		ts_info->phc_index = -1;
+
+	ts_info->tx_types = (1 << HWTSTAMP_TX_OFF) | (1 << HWTSTAMP_TX_ON);
+	ts_info->rx_filters = (1 << HWTSTAMP_FILTER_NONE) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_EVENT) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_EVENT) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_EVENT) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_SYNC) |
+			      (1 << HWTSTAMP_FILTER_PTP_V2_DELAY_REQ) |
+			      (1 << HWTSTAMP_FILTER_ALL);
+
+	return 0;
+}
+
 static const struct ethtool_ops xgbe_ethtool_ops = {
 	.get_settings = xgbe_get_settings,
 	.set_settings = xgbe_set_settings,
@@ -492,6 +526,7 @@ static const struct ethtool_ops xgbe_ethtool_ops = {
 	.get_strings = xgbe_get_strings,
 	.get_ethtool_stats = xgbe_get_ethtool_stats,
 	.get_sset_count = xgbe_get_sset_count,
+	.get_ts_info = xgbe_get_ts_info,
 };
 
 struct ethtool_ops *xgbe_get_ethtool_ops(void)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index e56c3d4..ca6a6af 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -245,6 +245,7 @@ static int xgbe_probe(struct platform_device *pdev)
 
 	spin_lock_init(&pdata->lock);
 	mutex_init(&pdata->xpcs_mutex);
+	spin_lock_init(&pdata->tstamp_lock);
 
 	/* Set and validate the number of descriptors for a ring */
 	BUILD_BUG_ON_NOT_POWER_OF_2(XGBE_TX_DESC_CNT);
@@ -265,10 +266,18 @@ static int xgbe_probe(struct platform_device *pdev)
 	}
 
 	/* Obtain the system clock setting */
-	pdata->sysclock = devm_clk_get(dev, NULL);
-	if (IS_ERR(pdata->sysclock)) {
-		dev_err(dev, "devm_clk_get failed\n");
-		ret = PTR_ERR(pdata->sysclock);
+	pdata->sysclk = devm_clk_get(dev, XGBE_DMA_CLOCK);
+	if (IS_ERR(pdata->sysclk)) {
+		dev_err(dev, "dma devm_clk_get failed\n");
+		ret = PTR_ERR(pdata->sysclk);
+		goto err_io;
+	}
+
+	/* Obtain the PTP clock setting */
+	pdata->ptpclk = devm_clk_get(dev, XGBE_PTP_CLOCK);
+	if (IS_ERR(pdata->ptpclk)) {
+		dev_err(dev, "ptp devm_clk_get failed\n");
+		ret = PTR_ERR(pdata->ptpclk);
 		goto err_io;
 	}
 
@@ -420,6 +429,8 @@ static int xgbe_probe(struct platform_device *pdev)
 		goto err_reg_netdev;
 	}
 
+	xgbe_ptp_register(pdata);
+
 	xgbe_debugfs_init(pdata);
 
 	netdev_notice(netdev, "net device enabled\n");
@@ -452,6 +463,8 @@ static int xgbe_remove(struct platform_device *pdev)
 
 	xgbe_debugfs_exit(pdata);
 
+	xgbe_ptp_unregister(pdata);
+
 	unregister_netdev(netdev);
 
 	xgbe_mdio_unregister(pdata);
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
new file mode 100644
index 0000000..37e64cf
--- /dev/null
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ptp.c
@@ -0,0 +1,285 @@
+/*
+ * AMD 10Gb Ethernet driver
+ *
+ * This file is available to you under your choice of the following two
+ * licenses:
+ *
+ * License 1: GPLv2
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ *
+ * This file is free software; you may copy, redistribute and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation, either version 2 of the License, or (at
+ * your option) any later version.
+ *
+ * This file is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ *
+ * License 2: Modified BSD
+ *
+ * Copyright (c) 2014 Advanced Micro Devices, Inc.
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *     * Redistributions of source code must retain the above copyright
+ *       notice, this list of conditions and the following disclaimer.
+ *     * Redistributions in binary form must reproduce the above copyright
+ *       notice, this list of conditions and the following disclaimer in the
+ *       documentation and/or other materials provided with the distribution.
+ *     * Neither the name of Advanced Micro Devices, Inc. nor the
+ *       names of its contributors may be used to endorse or promote products
+ *       derived from this software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
+ * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
+ * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
+ * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
+ * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
+ * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ * This file incorporates work covered by the following copyright and
+ * permission notice:
+ *     The Synopsys DWC ETHER XGMAC Software Driver and documentation
+ *     (hereinafter "Software") is an unsupported proprietary work of Synopsys,
+ *     Inc. unless otherwise expressly agreed to in writing between Synopsys
+ *     and you.
+ *
+ *     The Software IS NOT an item of Licensed Software or Licensed Product
+ *     under any End User Software License Agreement or Agreement for Licensed
+ *     Product with Synopsys or any supplement thereto.  Permission is hereby
+ *     granted, free of charge, to any person obtaining a copy of this software
+ *     annotated with this license and the Software, to deal in the Software
+ *     without restriction, including without limitation the rights to use,
+ *     copy, modify, merge, publish, distribute, sublicense, and/or sell copies
+ *     of the Software, and to permit persons to whom the Software is furnished
+ *     to do so, subject to the following conditions:
+ *
+ *     The above copyright notice and this permission notice shall be included
+ *     in all copies or substantial portions of the Software.
+ *
+ *     THIS SOFTWARE IS BEING DISTRIBUTED BY SYNOPSYS SOLELY ON AN "AS IS"
+ *     BASIS AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
+ *     TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
+ *     PARTICULAR PURPOSE ARE HEREBY DISCLAIMED. IN NO EVENT SHALL SYNOPSYS
+ *     BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *     CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *     SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ *     INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ *     CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ *     ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
+ *     THE POSSIBILITY OF SUCH DAMAGE.
+ */
+
+#include <linux/clk.h>
+#include <linux/clocksource.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/net_tstamp.h>
+
+#include "xgbe.h"
+#include "xgbe-common.h"
+
+
+static cycle_t xgbe_cc_read(const struct cyclecounter *cc)
+{
+	struct xgbe_prv_data *pdata = container_of(cc,
+						   struct xgbe_prv_data,
+						   tstamp_cc);
+	u64 nsec;
+
+	nsec = pdata->hw_if.get_tstamp_time(pdata);
+
+	return nsec;
+}
+
+static int xgbe_adjfreq(struct ptp_clock_info *info, s32 delta)
+{
+	struct xgbe_prv_data *pdata = container_of(info,
+						   struct xgbe_prv_data,
+						   ptp_clock_info);
+	unsigned long flags;
+	u64 adjust;
+	u32 addend, diff;
+	unsigned int neg_adjust = 0;
+
+	if (delta < 0) {
+		neg_adjust = 1;
+		delta = -delta;
+	}
+
+	adjust = pdata->tstamp_addend;
+	adjust *= delta;
+	diff = div_u64(adjust, 1000000000UL);
+
+	addend = (neg_adjust) ? pdata->tstamp_addend - diff :
+				pdata->tstamp_addend + diff;
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	pdata->hw_if.update_tstamp_addend(pdata, addend);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	return 0;
+}
+
+static int xgbe_adjtime(struct ptp_clock_info *info, s64 delta)
+{
+	struct xgbe_prv_data *pdata = container_of(info,
+						   struct xgbe_prv_data,
+						   ptp_clock_info);
+	unsigned long flags;
+	u64 nsec;
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	nsec = timecounter_read(&pdata->tstamp_tc);
+
+	nsec += delta;
+	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc, nsec);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	return 0;
+}
+
+static int xgbe_gettime(struct ptp_clock_info *info, struct timespec *ts)
+{
+	struct xgbe_prv_data *pdata = container_of(info,
+						   struct xgbe_prv_data,
+						   ptp_clock_info);
+	unsigned long flags;
+	u64 nsec;
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	nsec = timecounter_read(&pdata->tstamp_tc);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	*ts = ns_to_timespec(nsec);
+
+	return 0;
+}
+
+static int xgbe_settime(struct ptp_clock_info *info, const struct timespec *ts)
+{
+	struct xgbe_prv_data *pdata = container_of(info,
+						   struct xgbe_prv_data,
+						   ptp_clock_info);
+	unsigned long flags;
+	u64 nsec;
+
+	nsec = timespec_to_ns(ts);
+
+	spin_lock_irqsave(&pdata->tstamp_lock, flags);
+
+	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc, nsec);
+
+	spin_unlock_irqrestore(&pdata->tstamp_lock, flags);
+
+	return 0;
+}
+
+static int xgbe_enable(struct ptp_clock_info *info,
+		       struct ptp_clock_request *request, int on)
+{
+	return -EOPNOTSUPP;
+}
+
+void xgbe_ptp_register(struct xgbe_prv_data *pdata)
+{
+	struct ptp_clock_info *info = &pdata->ptp_clock_info;
+	struct ptp_clock *clock;
+	struct cyclecounter *cc = &pdata->tstamp_cc;
+	u64 dividend;
+
+	snprintf(info->name, sizeof(info->name), "%s",
+		 netdev_name(pdata->netdev));
+	info->owner = THIS_MODULE;
+	info->max_adj = clk_get_rate(pdata->ptpclk);
+	info->adjfreq = xgbe_adjfreq;
+	info->adjtime = xgbe_adjtime;
+	info->gettime = xgbe_gettime;
+	info->settime = xgbe_settime;
+	info->enable = xgbe_enable;
+
+	clock = ptp_clock_register(info, pdata->dev);
+	if (IS_ERR(clock)) {
+		dev_err(pdata->dev, "ptp_clock_register failed\n");
+		return;
+	}
+
+	pdata->ptp_clock = clock;
+
+	/* Calculate the addend:
+	 *   addend = 2^32 / (PTP ref clock / 50Mhz)
+	 *          = (2^32 * 50Mhz) / PTP ref clock
+	 */
+	dividend = 50000000;
+	dividend <<= 32;
+	pdata->tstamp_addend = div_u64(dividend, clk_get_rate(pdata->ptpclk));
+
+	/* Setup the timecounter */
+	cc->read = xgbe_cc_read;
+	cc->mask = CLOCKSOURCE_MASK(64);
+	cc->mult = 1;
+	cc->shift = 0;
+
+	timecounter_init(&pdata->tstamp_tc, &pdata->tstamp_cc,
+			 ktime_to_ns(ktime_get_real()));
+
+	/* Disable all timestamping to start */
+	XGMAC_IOWRITE(pdata, MAC_TCR, 0);
+	pdata->tstamp_config.tx_type = HWTSTAMP_TX_OFF;
+	pdata->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
+}
+
+void xgbe_ptp_unregister(struct xgbe_prv_data *pdata)
+{
+	if (pdata->ptp_clock)
+		ptp_clock_unregister(pdata->ptp_clock);
+}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 9e24b29..8b6ad3e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -123,6 +123,9 @@
 #include <linux/phy.h>
 #include <linux/if_vlan.h>
 #include <linux/bitops.h>
+#include <linux/ptp_clock_kernel.h>
+#include <linux/clocksource.h>
+#include <linux/net_tstamp.h>
 
 
 #define XGBE_DRV_NAME		"amd-xgbe"
@@ -164,6 +167,16 @@
 #define XGBE_PHY_NAME		"amd_xgbe_phy"
 #define XGBE_PRTAD		0
 
+/* Device-tree clock names */
+#define XGBE_DMA_CLOCK		"dma_clk"
+#define XGBE_PTP_CLOCK		"ptp_clk"
+
+/* Timestamp support - values based on 50MHz PTP clock
+ *   50MHz => 20 nsec
+ */
+#define XGBE_TSTAMP_SSINC	20
+#define XGBE_TSTAMP_SNSINC	0
+
 /* Driver PMT macros */
 #define XGMAC_DRIVER_CONTEXT	1
 #define XGMAC_IOCTL_CONTEXT	2
@@ -214,6 +227,8 @@ struct xgbe_packet_data {
 	unsigned short mss;
 
 	unsigned short vlan_ctag;
+
+	u64 rx_tstamp;
 };
 
 /* Common Rx and Tx descriptor mapping */
@@ -242,6 +257,20 @@ struct xgbe_ring_data {
 	unsigned int interrupt;		/* Interrupt indicator */
 
 	unsigned int mapped_as_page;
+
+	/* Incomplete receive save location.  If the budget is exhausted
+	 * or the last descriptor (last normal descriptor or a following
+	 * context descriptor) has not been DMA'd yet the current state
+	 * of the receive processing needs to be saved.
+	 */
+	unsigned int state_saved;
+	struct {
+		unsigned int incomplete;
+		unsigned int context_next;
+		struct sk_buff *skb;
+		unsigned int len;
+		unsigned int error;
+	} state;
 };
 
 struct xgbe_ring {
@@ -467,6 +496,14 @@ struct xgbe_hw_if {
 	void (*rx_mmc_int)(struct xgbe_prv_data *);
 	void (*tx_mmc_int)(struct xgbe_prv_data *);
 	void (*read_mmc_stats)(struct xgbe_prv_data *);
+
+	/* For Timestamp config */
+	int (*config_tstamp)(struct xgbe_prv_data *, unsigned int);
+	void (*update_tstamp_addend)(struct xgbe_prv_data *, unsigned int);
+	void (*set_tstamp_time)(struct xgbe_prv_data *, unsigned int sec,
+				unsigned int nsec);
+	u64 (*get_tstamp_time)(struct xgbe_prv_data *);
+	u64 (*get_tx_tstamp)(struct xgbe_prv_data *);
 };
 
 struct xgbe_desc_if {
@@ -607,8 +644,21 @@ struct xgbe_prv_data {
 	/* Filtering support */
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 
-	/* System clock value used for Rx watchdog */
-	struct clk *sysclock;
+	/* Device clocks */
+	struct clk *sysclk;
+	struct clk *ptpclk;
+
+	/* Timestamp support */
+	spinlock_t tstamp_lock;
+	struct ptp_clock_info ptp_clock_info;
+	struct ptp_clock *ptp_clock;
+	struct hwtstamp_config tstamp_config;
+	struct cyclecounter tstamp_cc;
+	struct timecounter tstamp_tc;
+	unsigned int tstamp_addend;
+	struct work_struct tx_tstamp_work;
+	struct sk_buff *tx_tstamp_skb;
+	u64 tx_tstamp;
 
 	/* Hardware features of the device */
 	struct xgbe_hw_features hw_feat;
@@ -639,6 +689,8 @@ struct ethtool_ops *xgbe_get_ethtool_ops(void);
 int xgbe_mdio_register(struct xgbe_prv_data *);
 void xgbe_mdio_unregister(struct xgbe_prv_data *);
 void xgbe_dump_phy_registers(struct xgbe_prv_data *);
+void xgbe_ptp_register(struct xgbe_prv_data *);
+void xgbe_ptp_unregister(struct xgbe_prv_data *);
 void xgbe_dump_tx_desc(struct xgbe_ring *, unsigned int, unsigned int,
 		       unsigned int);
 void xgbe_dump_rx_desc(struct xgbe_ring *, struct xgbe_ring_desc *,
