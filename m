From: "Prodyut Hazarika" <phazarika@amcc.com>
Subject: [PATCH 1/2] ibm_newemac: Add Support for MAL Interrupt Coalescing
Date: Mon, 21 Sep 2009 15:47:25 -0700
Message-ID: <1253573245-1867-1-git-send-email-phazarika@amcc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Victor Gallardo <vgallardo@amcc.com>, Feng Kan <fkan@amcc.com>,
	lada.podivin@gmail.com, Loc Ho <lho@amcc.com>,
	Prodyut Hazarika <phazarika@amcc.com>, bhutchings@solarflare.com,
	linuxppc-dev@lists.ozlabs.org, davem@davemloft.net
To: <netdev@vger.kernel.org>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
Content-Class: urn:content-classes:message
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

Support for Hardware Interrupt coalescing in MAL.
Coalescing is supported on the newer revs of 460EX/GT and 405EX.
The MAL driver falls back to EOB IRQ if coalescing not supported

Signed-off-by: Prodyut Hazarika <phazarika@amcc.com>
Acked-by: Victor Gallardo <vgallardo@amcc.com>
Acked-by: Feng Kan <fkan@amcc.com>

---
 drivers/net/ibm_newemac/Kconfig |   27 ++++
 drivers/net/ibm_newemac/mal.c   |  295 
+++++++++++++++++++++++++++++++++++----
 drivers/net/ibm_newemac/mal.h   |   55 +++++++
 3 files changed, 350 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ibm_newemac/Kconfig 
b/drivers/net/ibm_newemac/Kconfig
index 78a1628..8a88173 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ibm_newemac/Kconfig
@@ -63,6 +63,33 @@ config IBM_NEW_EMAC_EMAC4
 	bool
 	default n

+config IBM_NEW_EMAC_INTR_COALESCE
+	bool "Hardware Interrupt coalescing"
+	depends on IBM_NEW_EMAC && (460EX || 460GT || 405EX)
+	default y
+	help
+	  When selected the Ethernet interrupt coalescing is selected.
+
+config IBM_NEW_EMAC_TX_COAL_COUNT
+	int "TX Coalescence frame count (packets)"
+	depends on IBM_NEW_EMAC_INTR_COALESCE
+	default "16"
+
+config IBM_NEW_EMAC_TX_COAL_TIMER
+	int "TX Coalescence timer (clock ticks)"
+	depends on IBM_NEW_EMAC_INTR_COALESCE
+	default "1000000"
+
+config IBM_NEW_EMAC_RX_COAL_COUNT
+	int "RX Coalescence frame count (packets)"
+	depends on IBM_NEW_EMAC_INTR_COALESCE
+	default "1"
+
+config IBM_NEW_EMAC_RX_COAL_TIMER
+	int "RX Coalescence timer (clock ticks)"
+	depends on IBM_NEW_EMAC_INTR_COALESCE
+	default "1000000"
+
 config IBM_NEW_EMAC_NO_FLOW_CTRL
 	bool
 	default n
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ibm_newemac/mal.c
index 2a2fc17..7dc06ad 100644
--- a/drivers/net/ibm_newemac/mal.c
+++ b/drivers/net/ibm_newemac/mal.c
@@ -31,6 +31,20 @@
 #include <asm/dcr-regs.h>

 static int mal_count;
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+static char *tx_coal_irqname[] = {
+	"TX0 COAL",
+	"TX1 COAL",
+	"TX2 COAL",
+	"TX3 COAL",
+};
+static char *rx_coal_irqname[] = {
+	"RX0 COAL",
+	"RX1 COAL",
+	"RX2 COAL",
+	"RX3 COAL",
+};
+#endif

 int __devinit mal_register_commac(struct mal_instance	*mal,
 				  struct mal_commac	*commac)
@@ -217,6 +231,86 @@ static inline void mal_disable_eob_irq(struct 
mal_instance *mal)
 	MAL_DBG2(mal, "disable_irq" NL);
 }

+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+static inline void mal_enable_coal(struct mal_instance *mal)
+{
+	unsigned int val;
+#if defined(CONFIG_405EX)
+	/* Clear the counters */
+	val = SDR0_ICC_FLUSH0 | SDR0_ICC_FLUSH1;
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX, val);
+
+	/* Set Tx/Rx Timer values */
+	mtdcri(SDR0, DCRN_SDR0_ICCTRTX0, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRTX1, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRRX0, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRRX1, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
+
+	/* Enable the Tx/Rx Coalescing interrupt */
+	val = ((CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT & COAL_FRAME_MASK)
+			<< SDR0_ICC_FTHR0_SHIFT) |
+		((CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT & COAL_FRAME_MASK)
+			<< SDR0_ICC_FTHR1_SHIFT);
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX, val);
+
+	val = ((CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT & COAL_FRAME_MASK)
+			<< SDR0_ICC_FTHR0_SHIFT) |
+		((CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT & COAL_FRAME_MASK)
+			<< SDR0_ICC_FTHR1_SHIFT);
+
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX, val);
+#elif defined(CONFIG_460EX) || defined(CONFIG_460GT)
+	/* Clear the counters */
+	val = SDR0_ICC_FLUSH;
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX0, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX1, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX0, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX1, val);
+#if defined(CONFIG_460GT)
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX2, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX3, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX2, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX3, val);
+#endif
+
+	/* Set Tx/Rx Timer values */
+	mtdcri(SDR0, DCRN_SDR0_ICCTRTX0, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRTX1, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRRX0, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRRX1, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
+#if defined(CONFIG_460GT)
+	mtdcri(SDR0, DCRN_SDR0_ICCTRTX2, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRTX3, CONFIG_IBM_NEW_EMAC_TX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRRX2, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
+	mtdcri(SDR0, DCRN_SDR0_ICCTRRX3, CONFIG_IBM_NEW_EMAC_RX_COAL_TIMER);
+#endif
+
+	/* Enable the Tx/Rx Coalescing interrupt */
+	val = (CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT & COAL_FRAME_MASK)
+			<< SDR0_ICC_FTHR_SHIFT;
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX0, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX1, val);
+#if defined(CONFIG_460GT)
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX2, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRTX3, val);
+#endif
+
+	val = (CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT & COAL_FRAME_MASK)
+			<< SDR0_ICC_FTHR_SHIFT;
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX0, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX1, val);
+#if defined(CONFIG_460GT)
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX2, val);
+	mtdcri(SDR0, DCRN_SDR0_ICCRRX3, val);
+#endif
+#endif
+	printk(KERN_INFO "MAL: Enabled Intr Coal TxCnt: %d RxCnt: %d\n",
+		CONFIG_IBM_NEW_EMAC_TX_COAL_COUNT,
+		CONFIG_IBM_NEW_EMAC_RX_COAL_COUNT);
+}
+#endif
+
 static irqreturn_t mal_serr(int irq, void *dev_instance)
 {
 	struct mal_instance *mal = dev_instance;
@@ -309,6 +403,15 @@ static irqreturn_t mal_rxeob(int irq, void 
*dev_instance)
 	return IRQ_HANDLED;
 }

+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+static irqreturn_t mal_coal(int irq, void *dev_instance)
+{
+	struct mal_instance *mal = dev_instance;
+	mal_schedule_poll(mal);
+	return IRQ_HANDLED;
+}
+#endif
+
 static irqreturn_t mal_txde(int irq, void *dev_instance)
 {
 	struct mal_instance *mal = dev_instance;
@@ -527,6 +630,10 @@ static int __devinit mal_probe(struct of_device 
*ofdev,
 	u32 cfg;
 	unsigned long irqflags;
 	irq_handler_t hdlr_serr, hdlr_txde, hdlr_rxde;
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	int num_phys_chans;
+	int coal_intr_index;
+#endif

 	mal = kzalloc(sizeof(struct mal_instance), GFP_KERNEL);
 	if (!mal) {
@@ -609,6 +716,50 @@ static int __devinit mal_probe(struct of_device 
*ofdev,
 		goto fail_unmap;
 	}

+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	/* Number of Tx channels is equal to Physical channels */
+	/* Rx channels include Virtual channels so use Tx channels */
+	BUG_ON(mal->num_tx_chans > MAL_MAX_PHYS_CHANNELS);
+	num_phys_chans = mal->num_tx_chans;
+	/* Older revs in 460EX and 460GT have coalesce bug in h/w */
+#if defined(CONFIG_460EX) || defined(CONFIG_460GT)
+	{
+		unsigned int pvr;
+		unsigned short min;
+		pvr = mfspr(SPRN_PVR);
+		min = PVR_MIN(pvr);
+		if (min < 4) {
+			printk(KERN_INFO "PVR %x Intr Coal disabled: H/W bug\n",
+					pvr);
+			mal->coalesce_disabled = 1;
+		}
+	}
+#else
+	mal->coalesce_disabled = 0;
+#endif
+	coal_intr_index = 5;
+
+	/* If device tree doesn't Interrupt coal IRQ, fall back to EOB IRQ */
+	for (i = 0; (i < num_phys_chans) && !mal->coalesce_disabled; i++) {
+		mal->txcoal_irq[i] =
+			irq_of_parse_and_map(ofdev->node, coal_intr_index++);
+		if (mal->txcoal_irq[i] == NO_IRQ) {
+			printk(KERN_INFO "MAL: No device tree IRQ "
+				"for TxCoal%d  - disabling coalescing\n", i);
+			mal->coalesce_disabled = 1;
+		}
+	}
+	for (i = 0; (i < num_phys_chans) && !mal->coalesce_disabled ; i++) {
+		mal->rxcoal_irq[i] =
+			irq_of_parse_and_map(ofdev->node, coal_intr_index++);
+		if (mal->rxcoal_irq[i] == NO_IRQ) {
+			printk(KERN_INFO "MAL: No device tree IRQ "
+				"for RxCoal%d  - disabling coalescing\n", i);
+			mal->coalesce_disabled = 1;
+		}
+	}
+#endif
+
 	INIT_LIST_HEAD(&mal->poll_list);
 	INIT_LIST_HEAD(&mal->list);
 	spin_lock_init(&mal->lock);
@@ -674,20 +825,69 @@ static int __devinit mal_probe(struct of_device 
*ofdev,
 	}

 	err = request_irq(mal->serr_irq, hdlr_serr, irqflags, "MAL SERR", mal);
-	if (err)
-		goto fail2;
+	if (err) {
+		mal->serr_irq = NO_IRQ;
+		goto failirq;
+	}
 	err = request_irq(mal->txde_irq, hdlr_txde, irqflags, "MAL TX DE", mal);
-	if (err)
-		goto fail3;
-	err = request_irq(mal->txeob_irq, mal_txeob, 0, "MAL TX EOB", mal);
-	if (err)
-		goto fail4;
+	if (err) {
+		mal->txde_irq = NO_IRQ;
+		goto failirq;
+	}
 	err = request_irq(mal->rxde_irq, hdlr_rxde, irqflags, "MAL RX DE", mal);
-	if (err)
-		goto fail5;
-	err = request_irq(mal->rxeob_irq, mal_rxeob, 0, "MAL RX EOB", mal);
-	if (err)
-		goto fail6;
+	if (err) {
+		mal->rxde_irq = NO_IRQ;
+		goto failirq;
+	}
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	for (i = 0; (i < num_phys_chans) && !mal->coalesce_disabled; i++) {
+		err = request_irq(mal->txcoal_irq[i],
+					mal_coal, 0, tx_coal_irqname[i], mal);
+		if (err) {
+			printk(KERN_INFO "MAL: TxCoal%d ReqIRQ failed "
+					" - disabling coalescing\n", i);
+			mal->txcoal_irq[i] = NO_IRQ;
+			mal->coalesce_disabled = 1;
+			break;
+		}
+	}
+	for (i = 0; (i < num_phys_chans) && !mal->coalesce_disabled; i++) {
+		err = request_irq(mal->rxcoal_irq[i],
+					mal_coal, 0, rx_coal_irqname[i], mal);
+		if (err) {
+			printk(KERN_INFO "MAL: RxCoal%d ReqIRQ failed - "
+					"disabling coalescing\n", i);
+			mal->rxcoal_irq[i] = NO_IRQ;
+			mal->coalesce_disabled = 1;
+			break;
+		}
+	}
+
+	/* Fall back to EOB IRQ if coalesce not supported */
+	if (mal->coalesce_disabled) {
+		/* Clean up any IRQs allocated for Coalescing */
+		for (i = 0; i < num_phys_chans; i++) {
+			if (mal->txcoal_irq[i] != NO_IRQ)
+				free_irq(mal->txcoal_irq[i], mal);
+			if (mal->rxcoal_irq[i] != NO_IRQ)
+				free_irq(mal->rxcoal_irq[i], mal);
+		}
+#endif
+		err = request_irq(mal->txeob_irq, mal_txeob, 0,
+					"MAL TX EOB", mal);
+		if (err) {
+			mal->txeob_irq = NO_IRQ;
+			goto failirq;
+		}
+		err = request_irq(mal->rxeob_irq, mal_rxeob, 0,
+					"MAL RX EOB", mal);
+		if (err) {
+			mal->rxeob_irq = NO_IRQ;
+			goto failirq;
+		}
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	}
+#endif

 	/* Enable all MAL SERR interrupt sources */
 	if (mal->version == 2)
@@ -695,6 +895,10 @@ static int __devinit mal_probe(struct of_device 
*ofdev,
 	else
 		set_mal_dcrn(mal, MAL_IER, MAL1_IER_EVENTS);

+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	if (mal->coalesce_disabled == 0)
+		mal_enable_coal(mal);
+#endif
 	/* Enable EOB interrupt */
 	mal_enable_eob_irq(mal);

@@ -711,15 +915,30 @@ static int __devinit mal_probe(struct of_device 
*ofdev,

 	return 0;

- fail6:
-	free_irq(mal->rxde_irq, mal);
- fail5:
-	free_irq(mal->txeob_irq, mal);
- fail4:
-	free_irq(mal->txde_irq, mal);
- fail3:
-	free_irq(mal->serr_irq, mal);
- fail2:
+ failirq:
+	if (mal->serr_irq != NO_IRQ)
+		free_irq(mal->serr_irq, mal);
+	if (mal->txde_irq != NO_IRQ)
+		free_irq(mal->txde_irq, mal);
+	if (mal->rxde_irq != NO_IRQ)
+		free_irq(mal->rxde_irq, mal);
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	if (mal->coalesce_disabled == 0) {
+		for (i = 0; i < num_phys_chans; i++) {
+			if (mal->txcoal_irq[i] != NO_IRQ)
+				free_irq(mal->txcoal_irq[i], mal);
+			if (mal->rxcoal_irq[i] != NO_IRQ)
+				free_irq(mal->rxcoal_irq[i], mal);
+		}
+	} else {
+#endif
+		if (mal->txeob_irq != NO_IRQ)
+			free_irq(mal->txeob_irq, mal);
+		if (mal->rxeob_irq != NO_IRQ)
+			free_irq(mal->rxeob_irq, mal);
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	}
+#endif
 	dma_free_coherent(&ofdev->dev, bd_size, mal->bd_virt, mal->bd_dma);
  fail_unmap:
 	dcr_unmap(mal->dcr_host, 0x100);
@@ -732,6 +951,10 @@ static int __devinit mal_probe(struct of_device 
*ofdev,
 static int __devexit mal_remove(struct of_device *ofdev)
 {
 	struct mal_instance *mal = dev_get_drvdata(&ofdev->dev);
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	int	i;
+	int	num_phys_chans;
+#endif

 	MAL_DBG(mal, "remove" NL);

@@ -748,12 +971,30 @@ static int __devexit mal_remove(struct of_device 
*ofdev)

 	dev_set_drvdata(&ofdev->dev, NULL);

-	free_irq(mal->serr_irq, mal);
-	free_irq(mal->txde_irq, mal);
-	free_irq(mal->txeob_irq, mal);
-	free_irq(mal->rxde_irq, mal);
-	free_irq(mal->rxeob_irq, mal);
-
+	if (mal->serr_irq != NO_IRQ)
+		free_irq(mal->serr_irq, mal);
+	if (mal->txde_irq != NO_IRQ)
+		free_irq(mal->txde_irq, mal);
+	if (mal->rxde_irq != NO_IRQ)
+		free_irq(mal->rxde_irq, mal);
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	num_phys_chans = mal->num_tx_chans;
+	if (mal->coalesce_disabled == 0) {
+		for (i = 0; i < num_phys_chans; i++) {
+			if (mal->txcoal_irq[i] != NO_IRQ)
+				free_irq(mal->txcoal_irq[i], mal);
+			if (mal->rxcoal_irq[i] != NO_IRQ)
+				free_irq(mal->rxcoal_irq[i], mal);
+		}
+	} else {
+#endif
+		if (mal->txeob_irq != NO_IRQ)
+			free_irq(mal->txeob_irq, mal);
+		if (mal->rxeob_irq != NO_IRQ)
+			free_irq(mal->rxeob_irq, mal);
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	}
+#endif
 	mal_reset(mal);

 	mal_dbg_unregister(mal);
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ibm_newemac/mal.h
index 9ededfb..a93c352 100644
--- a/drivers/net/ibm_newemac/mal.h
+++ b/drivers/net/ibm_newemac/mal.h
@@ -169,6 +169,56 @@ struct mal_descriptor {
 #define MAL_TX_CTRL_LAST	0x1000
 #define MAL_TX_CTRL_INTR	0x0400

+#if defined(CONFIG_405EX)
+#define DCRN_SDR0_ICCRTX	0x430B /* Int coal Tx control register */
+#define DCRN_SDR0_ICCRRX	0x430C /* Int coal Rx control register */
+#define SDR0_ICC_FTHR0_SHIFT	23
+#define SDR0_ICC_FLUSH0		22
+#define SDR0_ICC_FLUWI0		21
+#define SDR0_ICC_FTHR1_SHIFT	12
+#define SDR0_ICC_FLUSH1		11
+#define SDR0_ICC_FLUWI1		10
+#define DCRN_SDR0_ICCTRTX0	0x430D /* Int coal Tx0 count threshold */
+#define DCRN_SDR0_ICCTRTX1	0x430E /* Int coal Tx1 count threshold */
+#define DCRN_SDR0_ICCTRRX0	0x430F /* Int coal Rx0 count threshold */
+#define DCRN_SDR0_ICCTRRX1	0x4310 /* Int coal Rx1 count threshold */
+#define DCRN_SDR0_ICTSRTX0	0x4307 /* Int coal Tx0 timer status*/
+#define DCRN_SDR0_ICTSRTX1	0x4308 /* Int coal Tx1 timer status*/
+#define DCRN_SDR0_ICTSRRX0	0x4309 /* Int coal Rx0 timer status*/
+#define DCRN_SDR0_ICTSRRX1	0x430A /* Int coal Rx1 timer status*/
+#elif defined(CONFIG_460EX) || defined(CONFIG_460GT)
+#define DCRN_SDR0_ICCRTX0	0x4410 /* Int coal Tx0 control register */
+#define DCRN_SDR0_ICCRTX1	0x4411 /* Int coal Tx1 control register */
+#define DCRN_SDR0_ICCRTX2	0x4412 /* Int coal Tx2 control register */
+#define DCRN_SDR0_ICCRTX3	0x4413 /* Int coal Tx3 control register */
+#define DCRN_SDR0_ICCRRX0	0x4414 /* Int coal Rx0 control register */
+#define DCRN_SDR0_ICCRRX1	0x4415 /* Int coal Rx1 control register */
+#define DCRN_SDR0_ICCRRX2	0x4416 /* Int coal Rx2 control register */
+#define DCRN_SDR0_ICCRRX3	0x4417 /* Int coal Rx3 control register */
+#define SDR0_ICC_FTHR_SHIFT	23
+#define SDR0_ICC_FLUSH		22
+#define SDR0_ICC_FLUWI		21
+#define DCRN_SDR0_ICCTRTX0	0x4418 /* Int coal Tx0 count threshold */
+#define DCRN_SDR0_ICCTRTX1	0x4419 /* Int coal Tx1 count threshold */
+#define DCRN_SDR0_ICCTRTX2	0x441A /* Int coal Tx2 count threshold */
+#define DCRN_SDR0_ICCTRTX3	0x441B /* Int coal Tx3 count threshold */
+#define DCRN_SDR0_ICCTRRX0	0x441C /* Int coal Rx0 count threshold */
+#define DCRN_SDR0_ICCTRRX1	0x441D /* Int coal Rx1 count threshold */
+#define DCRN_SDR0_ICCTRRX2	0x441E /* Int coal Rx2 count threshold */
+#define DCRN_SDR0_ICCTRRX3	0x441F /* Int coal Rx3 count threshold */
+#define DCRN_SDR0_ICTSRTX0	0x4420 /* Int coal Tx0 timer status*/
+#define DCRN_SDR0_ICTSRTX1	0x4421 /* Int coal Tx1 timer status*/
+#define DCRN_SDR0_ICTSRTX2	0x4422 /* Int coal Tx2 timer status*/
+#define DCRN_SDR0_ICTSRTX3	0x4423 /* Int coal Tx3 timer status*/
+#define DCRN_SDR0_ICTSRRX0	0x4424 /* Int coal Rx0 timer status*/
+#define DCRN_SDR0_ICTSRRX1	0x4425 /* Int coal Rx1 timer status*/
+#define DCRN_SDR0_ICTSRRX2	0x4426 /* Int coal Rx2 timer status*/
+#define DCRN_SDR0_ICTSRRX3	0x4427 /* Int coal Rx3 timer status*/
+#endif
+
+#define COAL_FRAME_MASK		0x1FF
+#define MAL_MAX_PHYS_CHANNELS	4
+
 struct mal_commac_ops {
 	void	(*poll_tx) (void *dev);
 	int	(*poll_rx) (void *dev, int budget);
@@ -217,6 +267,11 @@ struct mal_instance {
 	struct net_device	dummy_dev;

 	unsigned int features;
+#ifdef CONFIG_IBM_NEW_EMAC_INTR_COALESCE
+	int			txcoal_irq[MAL_MAX_PHYS_CHANNELS];
+	int			rxcoal_irq[MAL_MAX_PHYS_CHANNELS];
+	int			coalesce_disabled;
+#endif
 };

 static inline u32 get_mal_dcrn(struct mal_instance *mal, int reg)
-- 
1.5.6
--------------------------------------------------------

CONFIDENTIALITY NOTICE: This e-mail message, including any attachments, is 
for the sole use of the intended recipient(s) and contains information 
that is confidential and proprietary to AppliedMicro Corporation or its 
subsidiaries. It is to be used solely for the purpose of furthering the 
parties' business relationship. All unauthorized review, use, disclosure 
or distribution is prohibited. If you are not the intended recipient, 
please contact the sender by reply e-mail and destroy all copies of the 
original message.
