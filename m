From: Yoshihiro Kaneko <ykaneko0929@gmail.com>
Subject: [PATCH/RFC v3 net-next] ravb: Add dma queue interrupt support
Date: Sun, 17 Jan 2016 19:55:33 +0900
Message-ID: <1453028133-7670-1-git-send-email-ykaneko0929@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:33560 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbcAQK7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Jan 2016 05:59:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>

This patch supports the following interrupts.

- One interrupt for multiple (descriptor, error, management)
- One interrupt for emac
- Four interrupts for dma queue (best effort rx/tx, network control rx/tx)

This patch improve efficiency of the interrupt handler by adding the
interrupt handler corresponding to each interrupt source described
above. Additionally, it reduces the number of times of the access to
EthernetAVB IF.

Signed-off-by: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
---

This patch is based on the master branch of David Miller's next networking
tree.

v3 [Yoshihiro Kaneko]
* compile tested only
* As suggested by Sergei Shtylyov
  - update changelog
  drivers/net/ethernet/renesas/ravb.h:
    - add comments to the additional registers like CIE
  drivers/net/ethernet/renesas/ravb_main.c:
    - fix the initialization of the interrupt in ravb_dmac_init()
    - revert ravb_error_interrupt() because gen3 code is wrong
    - change the comment "Management" in ravb_multi_interrupt()
    - add a helper function for request_irq() in ravb_open()
    - revert ravb_close() because atomicity is not necessary here
  drivers/net/ethernet/renesas/ravb_ptp.c:
    - revert ravb_ptp_stop() because atomicity is not necessary here

v2 [Yoshihiro Kaneko]
* compile tested only
* As suggested by Sergei Shtylyov
  - add comment to CIE
  - remove comments from CIE bits
  - fix value of TIx_ALL
  - define each bits for CIE, GIE, GID, RIE0, RID0, RIE2, RID2, TIE, TID
  - reversed Christmas tree declaration ordered
  - rename _ravb_emac_interrupt() to ravb_emac_interrupt_unlocked()
  - remove unnecessary clearing of CIE
  - use a bit name corresponding to the target register, RIE0, RIE2, TIE,
    TID, RID2, GID, GIE

 drivers/net/ethernet/renesas/ravb.h      | 230 +++++++++++++++++++++++++++++++
 drivers/net/ethernet/renesas/ravb_main.c | 199 +++++++++++++++++++++++---
 drivers/net/ethernet/renesas/ravb_ptp.c  |  37 +++--
 3 files changed, 438 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/renesas/ravb.h b/drivers/net/ethernet/renesas/ravb.h
index 9fbe92a..385f06b 100644
--- a/drivers/net/ethernet/renesas/ravb.h
+++ b/drivers/net/ethernet/renesas/ravb.h
@@ -157,6 +157,7 @@ enum ravb_reg {
 	TIC	= 0x0378,
 	TIS	= 0x037C,
 	ISS	= 0x0380,
+	CIE	= 0x0384,	/* R-Car Gen3 only */
 	GCCR	= 0x0390,
 	GMTT	= 0x0394,
 	GPTC	= 0x0398,
@@ -170,6 +171,15 @@ enum ravb_reg {
 	GCT0	= 0x03B8,
 	GCT1	= 0x03BC,
 	GCT2	= 0x03C0,
+	GIE	= 0x03CC,	/* R-Car Gen3 only */
+	GID	= 0x03D0,	/* R-Car Gen3 only */
+	DIL	= 0x0440,	/* R-Car Gen3 only */
+	RIE0	= 0x0460,	/* R-Car Gen3 only */
+	RID0	= 0x0464,	/* R-Car Gen3 only */
+	RIE2	= 0x0470,	/* R-Car Gen3 only */
+	RID2	= 0x0474,	/* R-Car Gen3 only */
+	TIE	= 0x0478,	/* R-Car Gen3 only */
+	TID	= 0x047c,	/* R-Car Gen3 only */
 
 	/* E-MAC registers */
 	ECMR	= 0x0500,
@@ -556,6 +566,18 @@ enum ISS_BIT {
 	ISS_DPS15	= 0x80000000,
 };
 
+/* CIE
+ * R-Car Gen3 only
+ */
+enum CIE_BIT {
+	CIE_CRIE	= 0x00000001,
+	CIE_CTIE	= 0x00000100,
+	CIE_RQFM	= 0x00010000,
+	CIE_CL0M	= 0x00020000,
+	CIE_RFWL	= 0x00040000,
+	CIE_RFFL	= 0x00080000,
+};
+
 /* GCCR */
 enum GCCR_BIT {
 	GCCR_TCR	= 0x00000003,
@@ -592,6 +614,212 @@ enum GIS_BIT {
 	GIS_PTMF	= 0x00000004,
 };
 
+/* GIE
+ * R-Car Gen3 only
+ */
+enum GIE_BIT {
+	GIE_PTCS	= 0x00000001,
+	GIE_PTOS	= 0x00000002,
+	GIE_PTMS0	= 0x00000004,
+	GIE_PTMS1	= 0x00000008,
+	GIE_PTMS2	= 0x00000010,
+	GIE_PTMS3	= 0x00000020,
+	GIE_PTMS4	= 0x00000040,
+	GIE_PTMS5	= 0x00000080,
+	GIE_PTMS6	= 0x00000100,
+	GIE_PTMS7	= 0x00000200,
+	GIE_ATCS0	= 0x00010000,
+	GIE_ATCS1	= 0x00020000,
+	GIE_ATCS2	= 0x00040000,
+	GIE_ATCS3	= 0x00080000,
+	GIE_ATCS4	= 0x00100000,
+	GIE_ATCS5	= 0x00200000,
+	GIE_ATCS6	= 0x00400000,
+	GIE_ATCS7	= 0x00800000,
+	GIE_ATCS8	= 0x01000000,
+	GIE_ATCS9	= 0x02000000,
+	GIE_ATCS10	= 0x04000000,
+	GIE_ATCS11	= 0x08000000,
+	GIE_ATCS12	= 0x10000000,
+	GIE_ATCS13	= 0x20000000,
+	GIE_ATCS14	= 0x40000000,
+	GIE_ATCS15	= 0x80000000,
+	GIE_ALL		= 0xffff03ff,
+};
+
+/* GID
+ * R-Car Gen3 only
+ */
+enum GID_BIT {
+	GID_PTCD	= 0x00000001,
+	GID_PTOD	= 0x00000002,
+	GID_PTMD0	= 0x00000004,
+	GID_PTMD1	= 0x00000008,
+	GID_PTMD2	= 0x00000010,
+	GID_PTMD3	= 0x00000020,
+	GID_PTMD4	= 0x00000040,
+	GID_PTMD5	= 0x00000080,
+	GID_PTMD6	= 0x00000100,
+	GID_PTMD7	= 0x00000200,
+	GID_ATCD0	= 0x00010000,
+	GID_ATCD1	= 0x00020000,
+	GID_ATCD2	= 0x00040000,
+	GID_ATCD3	= 0x00080000,
+	GID_ATCD4	= 0x00100000,
+	GID_ATCD5	= 0x00200000,
+	GID_ATCD6	= 0x00400000,
+	GID_ATCD7	= 0x00800000,
+	GID_ATCD8	= 0x01000000,
+	GID_ATCD9	= 0x02000000,
+	GID_ATCD10	= 0x04000000,
+	GID_ATCD11	= 0x08000000,
+	GID_ATCD12	= 0x10000000,
+	GID_ATCD13	= 0x20000000,
+	GID_ATCD14	= 0x40000000,
+	GID_ATCD15	= 0x80000000,
+	GID_ALL		= 0xffff03ff,
+};
+
+/* RIE0
+ * R-Car Gen3 only
+ */
+enum RIE0_BIT {
+	RIE0_FRS0	= 0x00000001,
+	RIE0_FRS1	= 0x00000002,
+	RIE0_FRS2	= 0x00000004,
+	RIE0_FRS3	= 0x00000008,
+	RIE0_FRS4	= 0x00000010,
+	RIE0_FRS5	= 0x00000020,
+	RIE0_FRS6	= 0x00000040,
+	RIE0_FRS7	= 0x00000080,
+	RIE0_FRS8	= 0x00000100,
+	RIE0_FRS9	= 0x00000200,
+	RIE0_FRS10	= 0x00000400,
+	RIE0_FRS11	= 0x00000800,
+	RIE0_FRS12	= 0x00001000,
+	RIE0_FRS13	= 0x00002000,
+	RIE0_FRS14	= 0x00004000,
+	RIE0_FRS15	= 0x00008000,
+	RIE0_FRS16	= 0x00010000,
+	RIE0_FRS17	= 0x00020000,
+	RIE0_ALL	= 0x0003ffff,
+};
+
+/* RID0
+ * R-Car Gen3 only
+ */
+enum RID0_BIT {
+	RID0_FRD0	= 0x00000001,
+	RID0_FRD1	= 0x00000002,
+	RID0_FRD2	= 0x00000004,
+	RID0_FRD3	= 0x00000008,
+	RID0_FRD4	= 0x00000010,
+	RID0_FRD5	= 0x00000020,
+	RID0_FRD6	= 0x00000040,
+	RID0_FRD7	= 0x00000080,
+	RID0_FRD8	= 0x00000100,
+	RID0_FRD9	= 0x00000200,
+	RID0_FRD10	= 0x00000400,
+	RID0_FRD11	= 0x00000800,
+	RID0_FRD12	= 0x00001000,
+	RID0_FRD13	= 0x00002000,
+	RID0_FRD14	= 0x00004000,
+	RID0_FRD15	= 0x00008000,
+	RID0_FRD16	= 0x00010000,
+	RID0_FRD17	= 0x00020000,
+	RID0_ALL	= 0x0003ffff,
+};
+
+/* RIE2
+ * R-Car Gen3 only
+ */
+enum RIE2_BIT {
+	RIE2_QFS0	= 0x00000001,
+	RIE2_QFS1	= 0x00000002,
+	RIE2_QFS2	= 0x00000004,
+	RIE2_QFS3	= 0x00000008,
+	RIE2_QFS4	= 0x00000010,
+	RIE2_QFS5	= 0x00000020,
+	RIE2_QFS6	= 0x00000040,
+	RIE2_QFS7	= 0x00000080,
+	RIE2_QFS8	= 0x00000100,
+	RIE2_QFS9	= 0x00000200,
+	RIE2_QFS10	= 0x00000400,
+	RIE2_QFS11	= 0x00000800,
+	RIE2_QFS12	= 0x00001000,
+	RIE2_QFS13	= 0x00002000,
+	RIE2_QFS14	= 0x00004000,
+	RIE2_QFS15	= 0x00008000,
+	RIE2_QFS16	= 0x00010000,
+	RIE2_QFS17	= 0x00020000,
+	RIE2_RFFS	= 0x80000000,
+	RIE2_ALL	= 0x8003ffff,
+};
+
+/* RID2
+ * R-Car Gen3 only
+ */
+enum RID2_BIT {
+	RID2_QFD0	= 0x00000001,
+	RID2_QFD1	= 0x00000002,
+	RID2_QFD2	= 0x00000004,
+	RID2_QFD3	= 0x00000008,
+	RID2_QFD4	= 0x00000010,
+	RID2_QFD5	= 0x00000020,
+	RID2_QFD6	= 0x00000040,
+	RID2_QFD7	= 0x00000080,
+	RID2_QFD8	= 0x00000100,
+	RID2_QFD9	= 0x00000200,
+	RID2_QFD10	= 0x00000400,
+	RID2_QFD11	= 0x00000800,
+	RID2_QFD12	= 0x00001000,
+	RID2_QFD13	= 0x00002000,
+	RID2_QFD14	= 0x00004000,
+	RID2_QFD15	= 0x00008000,
+	RID2_QFD16	= 0x00010000,
+	RID2_QFD17	= 0x00020000,
+	RID2_RFFD	= 0x80000000,
+	RID2_ALL	= 0x8003ffff,
+};
+
+/* TIE
+ * R-Car Gen3 only
+ */
+enum TIE_BIT {
+	TIE_FTS0	= 0x00000001,
+	TIE_FTS1	= 0x00000002,
+	TIE_FTS2	= 0x00000004,
+	TIE_FTS3	= 0x00000008,
+	TIE_TFUS	= 0x00000100,
+	TIE_TFWS	= 0x00000200,
+	TIE_MFUS	= 0x00000400,
+	TIE_MFWS	= 0x00000800,
+	TIE_TDPS0	= 0x00010000,
+	TIE_TDPS1	= 0x00020000,
+	TIE_TDPS2	= 0x00040000,
+	TIE_TDPS3	= 0x00080000,
+	TIE_ALL		= 0x000f0f0f,
+};
+
+/* TID
+ * R-Car Gen3 only
+ */
+enum TID_BIT {
+	TID_FTD0	= 0x00000001,
+	TID_FTD1	= 0x00000002,
+	TID_FTD2	= 0x00000004,
+	TID_FTD3	= 0x00000008,
+	TID_TFUD	= 0x00000100,
+	TID_TFWD	= 0x00000200,
+	TID_MFUD	= 0x00000400,
+	TID_MFWD	= 0x00000800,
+	TID_TDPD0	= 0x00010000,
+	TID_TDPD1	= 0x00020000,
+	TID_TDPD2	= 0x00040000,
+	TID_TDPD3	= 0x00080000,
+	TID_ALL		= 0x000f0f0f,
+};
+
 /* ECMR */
 enum ECMR_BIT {
 	ECMR_PRM	= 0x00000001,
@@ -817,6 +1045,8 @@ struct ravb_private {
 	int duplex;
 	int emac_irq;
 	enum ravb_chip_id chip_id;
+	int rx_irqs[NUM_RX_QUEUE];
+	int tx_irqs[NUM_TX_QUEUE];
 
 	unsigned no_avb_link:1;
 	unsigned avb_link_active_low:1;
diff --git a/drivers/net/ethernet/renesas/ravb_main.c b/drivers/net/ethernet/renesas/ravb_main.c
index ac43ed9..4c4912e0 100644
--- a/drivers/net/ethernet/renesas/ravb_main.c
+++ b/drivers/net/ethernet/renesas/ravb_main.c
@@ -42,6 +42,16 @@
 		 NETIF_MSG_RX_ERR | \
 		 NETIF_MSG_TX_ERR)
 
+static const char *ravb_rx_irqs[NUM_RX_QUEUE] = {
+	"ch0", /* RAVB_BE */
+	"ch1", /* RAVB_NC */
+};
+
+static const char *ravb_tx_irqs[NUM_TX_QUEUE] = {
+	"ch18", /* RAVB_BE */
+	"ch19", /* RAVB_NC */
+};
+
 int ravb_wait(struct net_device *ndev, enum ravb_reg reg, u32 mask, u32 value)
 {
 	int i;
@@ -372,6 +382,7 @@ static void ravb_emac_init(struct net_device *ndev)
 /* Device init function for Ethernet AVB */
 static int ravb_dmac_init(struct net_device *ndev)
 {
+	struct ravb_private *priv = netdev_priv(ndev);
 	int error;
 
 	/* Set CONFIG mode */
@@ -408,6 +419,12 @@ static int ravb_dmac_init(struct net_device *ndev)
 	ravb_write(ndev, TCCR_TFEN, TCCR);
 
 	/* Interrupt init: */
+	if (priv->chip_id == RCAR_GEN3) {
+		/* Clear DIL.DPLx */
+		ravb_write(ndev, 0, DIL);
+		/* Set queue specific interrupt */
+		ravb_write(ndev, CIE_CRIE | CIE_CTIE | CIE_CL0M, CIE);
+	}
 	/* Frame receive */
 	ravb_write(ndev, RIC0_FRE0 | RIC0_FRE1, RIC0);
 	/* Disable FIFO full warning */
@@ -651,7 +668,7 @@ static int ravb_stop_dma(struct net_device *ndev)
 }
 
 /* E-MAC interrupt handler */
-static void ravb_emac_interrupt(struct net_device *ndev)
+static void ravb_emac_interrupt_unlocked(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
 	u32 ecsr, psr;
@@ -677,6 +694,18 @@ static void ravb_emac_interrupt(struct net_device *ndev)
 	}
 }
 
+static irqreturn_t ravb_emac_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct ravb_private *priv = netdev_priv(ndev);
+
+	spin_lock(&priv->lock);
+	ravb_emac_interrupt_unlocked(ndev);
+	mmiowb();
+	spin_unlock(&priv->lock);
+	return IRQ_HANDLED;
+}
+
 /* Error interrupt handler */
 static void ravb_error_interrupt(struct net_device *ndev)
 {
@@ -693,7 +722,7 @@ static void ravb_error_interrupt(struct net_device *ndev)
 		if (ris2 & RIS2_QFF0)
 			priv->stats[RAVB_BE].rx_over_errors++;
 
-		    /* Receive Descriptor Empty int */
+		/* Receive Descriptor Empty int */
 		if (ris2 & RIS2_QFF1)
 			priv->stats[RAVB_NC].rx_over_errors++;
 
@@ -755,16 +784,43 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
 
 	/* E-MAC status summary */
 	if (iss & ISS_MS) {
-		ravb_emac_interrupt(ndev);
+		ravb_emac_interrupt_unlocked(ndev);
+		result = IRQ_HANDLED;
+	}
+
+	/* Error status summary */
+	if (iss & ISS_ES) {
+		ravb_error_interrupt(ndev);
 		result = IRQ_HANDLED;
 	}
 
+	if (iss & ISS_CGIS)
+		result = ravb_ptp_interrupt(ndev);
+
+	mmiowb();
+	spin_unlock(&priv->lock);
+	return result;
+}
+
+/* Descriptor IRQ/Error/Management interrupt handler */
+static irqreturn_t ravb_multi_interrupt(int irq, void *dev_id)
+{
+	struct net_device *ndev = dev_id;
+	struct ravb_private *priv = netdev_priv(ndev);
+	irqreturn_t result = IRQ_NONE;
+	u32 iss;
+
+	spin_lock(&priv->lock);
+	/* Get interrupt status */
+	iss = ravb_read(ndev, ISS);
+
 	/* Error status summary */
 	if (iss & ISS_ES) {
 		ravb_error_interrupt(ndev);
 		result = IRQ_HANDLED;
 	}
 
+	/* gPTP interrupt status summary */
 	if (iss & ISS_CGIS)
 		result = ravb_ptp_interrupt(ndev);
 
@@ -773,6 +829,55 @@ static irqreturn_t ravb_interrupt(int irq, void *dev_id)
 	return result;
 }
 
+static irqreturn_t ravb_dmaq_interrupt(int irq, void *dev_id, int ravb_queue)
+{
+	struct net_device *ndev = dev_id;
+	struct ravb_private *priv = netdev_priv(ndev);
+	irqreturn_t result = IRQ_NONE;
+	u32 ris0, ric0, tis, tic;
+	int q = ravb_queue;
+
+	spin_lock(&priv->lock);
+
+	ris0 = ravb_read(ndev, RIS0);
+	ric0 = ravb_read(ndev, RIC0);
+	tis  = ravb_read(ndev, TIS);
+	tic  = ravb_read(ndev, TIC);
+
+	/* Timestamp updated */
+	if (tis & TIS_TFUF) {
+		ravb_write(ndev, TID_TFUD, TID);
+		ravb_get_tx_tstamp(ndev);
+		result = IRQ_HANDLED;
+	}
+
+	/* Best effort queue RX/TX */
+	if (((ris0 & ric0) & BIT(q)) ||
+	    ((tis  & tic)  & BIT(q))) {
+		if (napi_schedule_prep(&priv->napi[q])) {
+			/* Mask RX and TX interrupts */
+			ravb_write(ndev, BIT(q), RID0);
+			ravb_write(ndev, BIT(q), TID);
+			__napi_schedule(&priv->napi[q]);
+		}
+		result = IRQ_HANDLED;
+	}
+
+	mmiowb();
+	spin_unlock(&priv->lock);
+	return result;
+}
+
+static irqreturn_t ravb_be_interrupt(int irq, void *dev_id)
+{
+	return ravb_dmaq_interrupt(irq, dev_id, RAVB_BE);
+}
+
+static irqreturn_t ravb_nc_interrupt(int irq, void *dev_id)
+{
+	return ravb_dmaq_interrupt(irq, dev_id, RAVB_NC);
+}
+
 static int ravb_poll(struct napi_struct *napi, int budget)
 {
 	struct net_device *ndev = napi->dev;
@@ -812,8 +917,13 @@ static int ravb_poll(struct napi_struct *napi, int budget)
 
 	/* Re-enable RX/TX interrupts */
 	spin_lock_irqsave(&priv->lock, flags);
-	ravb_write(ndev, ravb_read(ndev, RIC0) | mask, RIC0);
-	ravb_write(ndev, ravb_read(ndev, TIC)  | mask,  TIC);
+	if (priv->chip_id == RCAR_GEN2) {
+		ravb_write(ndev, ravb_read(ndev, RIC0) | mask, RIC0);
+		ravb_write(ndev, ravb_read(ndev, TIC)  | mask, TIC);
+	} else {
+		ravb_write(ndev, mask, RIE0);
+		ravb_write(ndev, mask, TIE);
+	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -1215,29 +1325,63 @@ static const struct ethtool_ops ravb_ethtool_ops = {
 	.get_ts_info		= ravb_get_ts_info,
 };
 
+static inline int req_irq(unsigned int irq, irq_handler_t handler,
+			  struct net_device *ndev, struct device *dev,
+			  const char *ch)
+{
+	char *name;
+	int error;
+
+	name = devm_kasprintf(dev, GFP_KERNEL, "%s:%s", ndev->name, ch);
+	error = request_irq(irq, handler, IRQF_SHARED, name, ndev);
+		netdev_err(ndev, "cannot request IRQ %s\n", name);
+
+	return error;
+}
+
 /* Network device open function for Ethernet AVB */
 static int ravb_open(struct net_device *ndev)
 {
 	struct ravb_private *priv = netdev_priv(ndev);
-	int error;
+	struct platform_device *pdev = priv->pdev;
+	struct device *dev = &pdev->dev;
+	int error, i;
 
 	napi_enable(&priv->napi[RAVB_BE]);
 	napi_enable(&priv->napi[RAVB_NC]);
 
-	error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED, ndev->name,
-			    ndev);
-	if (error) {
-		netdev_err(ndev, "cannot request IRQ\n");
-		goto out_napi_off;
-	}
-
-	if (priv->chip_id == RCAR_GEN3) {
-		error = request_irq(priv->emac_irq, ravb_interrupt,
-				    IRQF_SHARED, ndev->name, ndev);
+	if (priv->chip_id == RCAR_GEN2) {
+		error = request_irq(ndev->irq, ravb_interrupt, IRQF_SHARED,
+				    ndev->name, ndev);
 		if (error) {
 			netdev_err(ndev, "cannot request IRQ\n");
-			goto out_free_irq;
+			goto out_napi_off;
 		}
+	} else {
+		error = req_irq(ndev->irq, ravb_multi_interrupt, ndev, dev,
+				"ch22:multi");
+		if (error)
+			goto out_napi_off;
+		error = req_irq(priv->emac_irq, ravb_emac_interrupt, ndev,
+				dev, "ch24:emac");
+		if (error)
+			goto out_free_irq;
+		error = req_irq(priv->rx_irqs[RAVB_BE], ravb_be_interrupt,
+				ndev, dev, "ch0:rx_be");
+		if (error)
+			goto out_free_irq;
+		error = req_irq(priv->tx_irqs[RAVB_BE], ravb_be_interrupt,
+				ndev, dev, "ch18:tx_be");
+		if (error)
+			goto out_free_irq;
+		error = req_irq(priv->rx_irqs[RAVB_NC], ravb_nc_interrupt,
+				ndev, dev, "ch1:rx_nc");
+		if (error)
+			goto out_free_irq;
+		error = req_irq(priv->tx_irqs[RAVB_NC], ravb_nc_interrupt,
+				ndev, dev, "ch19:tx_nc");
+		if (error)
+			goto out_free_irq;
 	}
 
 	/* Device init */
@@ -1268,6 +1412,10 @@ out_free_irq2:
 		free_irq(priv->emac_irq, ndev);
 out_free_irq:
 	free_irq(ndev->irq, ndev);
+	for (i = 0; i < NUM_RX_QUEUE; i++)
+		free_irq(priv->rx_irqs[i], ndev);
+	for (i = 0; i < NUM_TX_QUEUE; i++)
+		free_irq(priv->tx_irqs[i], ndev);
 out_napi_off:
 	napi_disable(&priv->napi[RAVB_NC]);
 	napi_disable(&priv->napi[RAVB_BE]);
@@ -1724,6 +1872,7 @@ static int ravb_probe(struct platform_device *pdev)
 	struct net_device *ndev;
 	int error, irq, q;
 	struct resource *res;
+	int i;
 
 	if (!np) {
 		dev_err(&pdev->dev,
@@ -1794,6 +1943,22 @@ static int ravb_probe(struct platform_device *pdev)
 			goto out_release;
 		}
 		priv->emac_irq = irq;
+		for (i = 0; i < NUM_RX_QUEUE; i++) {
+			irq = platform_get_irq_byname(pdev, ravb_rx_irqs[i]);
+			if (irq < 0) {
+				error = irq;
+				goto out_release;
+			}
+			priv->rx_irqs[i] = irq;
+		}
+		for (i = 0; i < NUM_TX_QUEUE; i++) {
+			irq = platform_get_irq_byname(pdev, ravb_tx_irqs[i]);
+			if (irq < 0) {
+				error = irq;
+				goto out_release;
+			}
+			priv->tx_irqs[i] = irq;
+		}
 	}
 
 	priv->chip_id = chip_id;
diff --git a/drivers/net/ethernet/renesas/ravb_ptp.c b/drivers/net/ethernet/renesas/ravb_ptp.c
index 7a8ce92..027223d 100644
--- a/drivers/net/ethernet/renesas/ravb_ptp.c
+++ b/drivers/net/ethernet/renesas/ravb_ptp.c
@@ -196,11 +196,18 @@ static int ravb_ptp_extts(struct ptp_clock_info *ptp,
 
 	spin_lock_irqsave(&priv->lock, flags);
 	gic = ravb_read(ndev, GIC);
-	if (on)
-		gic |= GIC_PTCE;
-	else
-		gic &= ~GIC_PTCE;
-	ravb_write(ndev, gic, GIC);
+	if (priv->chip_id == RCAR_GEN2) {
+		if (on)
+			gic |= GIC_PTCE;
+		else
+			gic &= ~GIC_PTCE;
+		ravb_write(ndev, gic, GIC);
+	} else {
+		if (on)
+			ravb_write(ndev, GIE_PTCS, GIE);
+		else
+			ravb_write(ndev, GID_PTCD, GID);
+	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
 
@@ -248,9 +255,13 @@ static int ravb_ptp_perout(struct ptp_clock_info *ptp,
 		error = ravb_ptp_update_compare(priv, (u32)start_ns);
 		if (!error) {
 			/* Unmask interrupt */
-			gic = ravb_read(ndev, GIC);
-			gic |= GIC_PTME;
-			ravb_write(ndev, gic, GIC);
+			if (priv->chip_id == RCAR_GEN2) {
+				gic = ravb_read(ndev, GIC);
+				gic |= GIC_PTME;
+				ravb_write(ndev, gic, GIC);
+			} else {
+				ravb_write(ndev, GIE_PTMS0, GIE);
+			}
 		}
 	} else	{
 		spin_lock_irqsave(&priv->lock, flags);
@@ -259,9 +270,13 @@ static int ravb_ptp_perout(struct ptp_clock_info *ptp,
 		perout->period = 0;
 
 		/* Mask interrupt */
-		gic = ravb_read(ndev, GIC);
-		gic &= ~GIC_PTME;
-		ravb_write(ndev, gic, GIC);
+		if (priv->chip_id == RCAR_GEN2) {
+			gic = ravb_read(ndev, GIC);
+			gic &= ~GIC_PTME;
+			ravb_write(ndev, gic, GIC);
+		} else {
+			ravb_write(ndev, GID_PTMD0, GID);
+		}
 	}
 	mmiowb();
 	spin_unlock_irqrestore(&priv->lock, flags);
-- 
1.9.1
