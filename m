From: Dong Aisheng <b29396@freescale.com>
Subject: [PATCH 6/7] can: m_can: update to support CAN FD features
Date: Wed, 29 Oct 2014 18:45:26 +0800
Message-ID: <1414579527-31100-6-git-send-email-b29396@freescale.com>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <mkl@pengutronix.de>, <wg@grandegger.com>,
	<varkabhadram@gmail.com>, <netdev@vger.kernel.org>,
	<socketcan@hartkopp.net>, <b29396@freescale.com>,
	<linux-arm-kernel@lists.infradead.org>
To: <linux-can@vger.kernel.org>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1414579527-31100-1-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bosch M_CAN is CAN FD capable device.
This patch implements the CAN FD features include up to 64 bytes
payload and bitrate switch function.

Signed-off-by: Dong Aisheng <b29396@freescale.com>
---
 drivers/net/can/m_can/m_can.c | 138 +++++++++++++++++++++++++++++++++---------
 1 file changed, 110 insertions(+), 28 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 6160b9c..219e0e3 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -105,14 +105,36 @@ enum m_can_mram_cfg {
 	MRAM_CFG_NUM,
 };
 
+/* Fast Bit Timing & Prescaler Register (FBTP) */
+#define FBTR_FBRP_MASK		0x1f
+#define FBTR_FBRP_SHIFT		16
+#define FBTR_FTSEG1_SHIFT	8
+#define FBTR_FTSEG1_MASK	(0xf << FBTR_FTSEG1_SHIFT)
+#define FBTR_FTSEG2_SHIFT	4
+#define FBTR_FTSEG2_MASK	(0x7 << FBTR_FTSEG2_SHIFT)
+#define FBTR_FSJW_SHIFT		0
+#define FBTR_FSJW_MASK		0x3
+
 /* Test Register (TEST) */
 #define TEST_LBCK	BIT(4)
 
 /* CC Control Register(CCCR) */
-#define CCCR_TEST	BIT(7)
-#define CCCR_MON	BIT(5)
-#define CCCR_CCE	BIT(1)
-#define CCCR_INIT	BIT(0)
+#define CCCR_TEST		BIT(7)
+#define CCCR_CMR_MASK		0x3
+#define CCCR_CMR_SHIFT		10
+#define CCCR_CMR_CANFD		0x1
+#define CCCR_CMR_CANFD_BRS	0x2
+#define CCCR_CMR_CAN		0x3
+#define CCCR_CME_MASK		0x3
+#define CCCR_CME_SHIFT		8
+#define CCCR_CME_CAN		0
+#define CCCR_CME_CANFD		0x1
+#define CCCR_CME_CANFD_BRS	0x2
+#define CCCR_TEST		BIT(7)
+#define CCCR_MON		BIT(5)
+#define CCCR_CCE		BIT(1)
+#define CCCR_INIT		BIT(0)
+#define CCCR_CANFD		0x10
 
 /* Bit Timing & Prescaler Register (BTP) */
 #define BTR_BRP_MASK		0x3ff
@@ -204,6 +226,7 @@ enum m_can_mram_cfg {
 
 /* Rx Buffer / FIFO Element Size Configuration (RXESC) */
 #define M_CAN_RXESC_8BYTES	0x0
+#define M_CAN_RXESC_64BYTES	0x777
 
 /* Tx Buffer Configuration(TXBC) */
 #define TXBC_NDTB_OFF		16
@@ -211,6 +234,7 @@ enum m_can_mram_cfg {
 
 /* Tx Buffer Element Size Configuration(TXESC) */
 #define TXESC_TBDS_8BYTES	0x0
+#define TXESC_TBDS_64BYTES	0x7
 
 /* Tx Event FIFO Con.guration (TXEFC) */
 #define TXEFC_EFS_OFF		16
@@ -219,11 +243,11 @@ enum m_can_mram_cfg {
 /* Message RAM Configuration (in bytes) */
 #define SIDF_ELEMENT_SIZE	4
 #define XIDF_ELEMENT_SIZE	8
-#define RXF0_ELEMENT_SIZE	16
-#define RXF1_ELEMENT_SIZE	16
+#define RXF0_ELEMENT_SIZE	72
+#define RXF1_ELEMENT_SIZE	72
 #define RXB_ELEMENT_SIZE	16
 #define TXE_ELEMENT_SIZE	8
-#define TXB_ELEMENT_SIZE	16
+#define TXB_ELEMENT_SIZE	72
 
 /* Message RAM Elements */
 #define M_CAN_FIFO_ID		0x0
@@ -231,11 +255,17 @@ enum m_can_mram_cfg {
 #define M_CAN_FIFO_DATA(n)	(0x8 + ((n) << 2))
 
 /* Rx Buffer Element */
+/* R0 */
 #define RX_BUF_ESI		BIT(31)
 #define RX_BUF_XTD		BIT(30)
 #define RX_BUF_RTR		BIT(29)
+/* R1 */
+#define RX_BUF_ANMF		BIT(31)
+#define RX_BUF_EDL		BIT(21)
+#define RX_BUF_BRS		BIT(20)
 
 /* Tx Buffer Element */
+/* R0 */
 #define TX_BUF_XTD		BIT(30)
 #define TX_BUF_RTR		BIT(29)
 
@@ -327,11 +357,12 @@ static inline void m_can_disable_all_interrupts(const struct m_can_priv *priv)
 	m_can_write(priv, M_CAN_ILE, 0x0);
 }
 
-static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
+static void m_can_read_fifo(const struct net_device *dev, struct canfd_frame *cf,
 			    u32 rxfs)
 {
 	struct m_can_priv *priv = netdev_priv(dev);
 	u32 id, fgi;
+	int i;
 
 	/* calculate the fifo get index for where to read data */
 	fgi = (rxfs & RXFS_FGI_MASK) >> RXFS_FGI_OFF;
@@ -341,15 +372,23 @@ static void m_can_read_fifo(const struct net_device *dev, struct can_frame *cf,
 	else
 		cf->can_id = (id >> 18) & CAN_SFF_MASK;
 
+	if (id & RX_BUF_ESI) {
+		cf->flags |= CANFD_ESI;
+		netdev_dbg(dev, "ESI Error\n");
+	}
+
 	if (id & RX_BUF_RTR) {
 		cf->can_id |= CAN_RTR_FLAG;
 	} else {
 		id = m_can_fifo_read(priv, fgi, M_CAN_FIFO_DLC);
-		cf->can_dlc = get_can_dlc((id >> 16) & 0x0F);
-		*(u32 *)(cf->data + 0) = m_can_fifo_read(priv, fgi,
-							 M_CAN_FIFO_DATA(0));
-		*(u32 *)(cf->data + 4) = m_can_fifo_read(priv, fgi,
-							 M_CAN_FIFO_DATA(1));
+		cf->len = can_dlc2len(get_canfd_dlc((id >> 16) & 0x0F));
+
+		if (id & RX_BUF_BRS)
+			cf->flags |= CANFD_BRS;
+
+		for (i = 0; i < cf->len; i += 4)
+			*(u32 *)(cf->data + i) =
+				m_can_fifo_read(priv, fgi, M_CAN_FIFO_DATA(i / 4));
 	}
 
 	/* acknowledge rx fifo 0 */
@@ -361,7 +400,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
 	struct m_can_priv *priv = netdev_priv(dev);
 	struct net_device_stats *stats = &dev->stats;
 	struct sk_buff *skb;
-	struct can_frame *frame;
+	struct canfd_frame *frame;
 	u32 pkts = 0;
 	u32 rxfs;
 
@@ -375,7 +414,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
 		if (rxfs & RXFS_RFL)
 			netdev_warn(dev, "Rx FIFO 0 Message Lost\n");
 
-		skb = alloc_can_skb(dev, &frame);
+		skb = alloc_canfd_skb(dev, &frame);
 		if (!skb) {
 			stats->rx_dropped++;
 			return pkts;
@@ -384,7 +423,7 @@ static int m_can_do_rx_poll(struct net_device *dev, int quota)
 		m_can_read_fifo(dev, frame, rxfs);
 
 		stats->rx_packets++;
-		stats->rx_bytes += frame->can_dlc;
+		stats->rx_bytes += frame->len;
 
 		netif_receive_skb(skb);
 
@@ -744,10 +783,23 @@ static const struct can_bittiming_const m_can_bittiming_const = {
 	.brp_inc = 1,
 };
 
+static const struct can_bittiming_const m_can_data_bittiming_const = {
+	.name = KBUILD_MODNAME,
+	.tseg1_min = 2,		/* Time segment 1 = prop_seg + phase_seg1 */
+	.tseg1_max = 16,
+	.tseg2_min = 1,		/* Time segment 2 = phase_seg2 */
+	.tseg2_max = 8,
+	.sjw_max = 4,
+	.brp_min = 1,
+	.brp_max = 32,
+	.brp_inc = 1,
+};
+
 static int m_can_set_bittiming(struct net_device *dev)
 {
 	struct m_can_priv *priv = netdev_priv(dev);
 	const struct can_bittiming *bt = &priv->can.bittiming;
+	const struct can_bittiming *dbt = &priv->can.data_bittiming;
 	u16 brp, sjw, tseg1, tseg2;
 	u32 reg_btp;
 
@@ -758,7 +810,17 @@ static int m_can_set_bittiming(struct net_device *dev)
 	reg_btp = (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
 			(tseg1 << BTR_TSEG1_SHIFT) | (tseg2 << BTR_TSEG2_SHIFT);
 	m_can_write(priv, M_CAN_BTP, reg_btp);
-	netdev_dbg(dev, "setting BTP 0x%x\n", reg_btp);
+
+	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
+		brp = dbt->brp - 1;
+		sjw = dbt->sjw - 1;
+		tseg1 = dbt->prop_seg + dbt->phase_seg1 - 1;
+		tseg2 = dbt->phase_seg2 - 1;
+		reg_btp = (brp << FBTR_FBRP_SHIFT) | (sjw << FBTR_FSJW_SHIFT) |
+				(tseg1 << FBTR_FTSEG1_SHIFT) |
+				(tseg2 << FBTR_FTSEG2_SHIFT);
+		m_can_write(priv, M_CAN_FBTP, reg_btp);
+	}
 
 	return 0;
 }
@@ -778,8 +840,8 @@ static void m_can_chip_config(struct net_device *dev)
 
 	m_can_config_endisable(priv, true);
 
-	/* RX Buffer/FIFO Element Size 8 bytes data field */
-	m_can_write(priv, M_CAN_RXESC, M_CAN_RXESC_8BYTES);
+	/* RX Buffer/FIFO Element Size 64 bytes data field */
+	m_can_write(priv, M_CAN_RXESC, M_CAN_RXESC_64BYTES);
 
 	/* Accept Non-matching Frames Into FIFO 0 */
 	m_can_write(priv, M_CAN_GFC, 0x0);
@@ -788,8 +850,8 @@ static void m_can_chip_config(struct net_device *dev)
 	m_can_write(priv, M_CAN_TXBC, (1 << TXBC_NDTB_OFF) |
 		    priv->mcfg[MRAM_TXB].off);
 
-	/* only support 8 bytes firstly */
-	m_can_write(priv, M_CAN_TXESC, TXESC_TBDS_8BYTES);
+	/* support 64 bytes payload */
+	m_can_write(priv, M_CAN_TXESC, TXESC_TBDS_64BYTES);
 
 	m_can_write(priv, M_CAN_TXEFC, (1 << TXEFC_EFS_OFF) |
 		    priv->mcfg[MRAM_TXE].off);
@@ -804,7 +866,8 @@ static void m_can_chip_config(struct net_device *dev)
 		    RXFC_FWM_1 | priv->mcfg[MRAM_RXF1].off);
 
 	cccr = m_can_read(priv, M_CAN_CCCR);
-	cccr &= ~(CCCR_TEST | CCCR_MON);
+	cccr &= ~(CCCR_TEST | CCCR_MON | (CCCR_CMR_MASK << CCCR_CMR_SHIFT) |
+		(CCCR_CME_MASK << CCCR_CME_SHIFT));
 	test = m_can_read(priv, M_CAN_TEST);
 	test &= ~TEST_LBCK;
 
@@ -816,6 +879,9 @@ static void m_can_chip_config(struct net_device *dev)
 		test |= TEST_LBCK;
 	}
 
+	if (priv->can.ctrlmode & CAN_CTRLMODE_FD)
+		cccr |= CCCR_CME_CANFD_BRS << CCCR_CME_SHIFT;
+
 	m_can_write(priv, M_CAN_CCCR, cccr);
 	m_can_write(priv, M_CAN_TEST, test);
 
@@ -880,11 +946,13 @@ static struct net_device *alloc_m_can_dev(void)
 
 	priv->dev = dev;
 	priv->can.bittiming_const = &m_can_bittiming_const;
+	priv->can.data_bittiming_const = &m_can_data_bittiming_const;
 	priv->can.do_set_mode = m_can_set_mode;
 	priv->can.do_get_berr_counter = m_can_get_berr_counter;
 	priv->can.ctrlmode_supported = CAN_CTRLMODE_LOOPBACK |
 					CAN_CTRLMODE_LISTENONLY |
-					CAN_CTRLMODE_BERR_REPORTING;
+					CAN_CTRLMODE_BERR_REPORTING |
+					CAN_CTRLMODE_FD;
 
 	return dev;
 }
@@ -967,8 +1035,9 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
 				    struct net_device *dev)
 {
 	struct m_can_priv *priv = netdev_priv(dev);
-	struct can_frame *cf = (struct can_frame *)skb->data;
-	u32 id;
+	struct canfd_frame *cf = (struct canfd_frame *)skb->data;
+	u32 id, cccr;
+	int i;
 
 	if (can_dropped_invalid_skb(dev, skb))
 		return NETDEV_TX_OK;
@@ -987,11 +1056,24 @@ static netdev_tx_t m_can_start_xmit(struct sk_buff *skb,
 
 	/* message ram configuration */
 	m_can_fifo_write(priv, 0, M_CAN_FIFO_ID, id);
-	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, cf->can_dlc << 16);
-	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(0), *(u32 *)(cf->data + 0));
-	m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(1), *(u32 *)(cf->data + 4));
+	m_can_fifo_write(priv, 0, M_CAN_FIFO_DLC, can_len2dlc(cf->len) << 16);
+
+	for (i = 0; i < cf->len; i += 4)
+		m_can_fifo_write(priv, 0, M_CAN_FIFO_DATA(i / 4),
+				 *(u32 *)(cf->data + i));
+
 	can_put_echo_skb(skb, dev, 0);
 
+	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
+		cccr = m_can_read(priv, M_CAN_CCCR);
+		cccr &= ~(CCCR_CMR_MASK << CCCR_CMR_SHIFT);
+		if (cf->flags & CANFD_BRS
+			cccr |= CCCR_CMR_CANFD_BRS << CCCR_CMR_SHIFT;
+		else
+			cccr |= CCCR_CMR_CANFD << CCCR_CMR_SHIFT;
+		m_can_write(priv, M_CAN_CCCR, cccr);
+	}
+
 	/* enable first TX buffer to start transfer  */
 	m_can_write(priv, M_CAN_TXBTIE, 0x1);
 	m_can_write(priv, M_CAN_TXBAR, 0x1);
-- 
1.9.1

