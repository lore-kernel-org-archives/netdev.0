From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH 3/7] via-velocity: Enable support for adaptive interrupt
 supression
Date: Fri, 20 Nov 2009 16:12:17 +0100
Message-ID: <20091120161217.45e611a6@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:42331 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1753999AbZKTPQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 10:16:43 -0500
In-Reply-To: <20091120160633.77b7aee0@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(From the upstream VIA driver). This reduces the amount of interrupts
under load and improves performance by quite a bit by reducing the
amount of work for the CPU.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |   70 +++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/via-velocity.h |    7 ++++-
 2 files changed, 75 insertions(+), 2 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index 944a678..932339b 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -364,6 +364,26 @@ static int rx_copybreak = 200;
 module_param(rx_copybreak, int, 0644);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 
+#define TXQUEUE_TIMER_DEF     0x59
+#define TXQUEUE_TIMER_MIN     0x00
+#define TXQUEUE_TIMER_MAX     0xFF
+VELOCITY_PARAM(txqueue_timer, "Tx Queue Empty defer timer");
+
+#define RXQUEUE_TIMER_DEF     0x14
+#define RXQUEUE_TIMER_MIN     0x00
+#define RXQUEUE_TIMER_MAX     0xFF
+VELOCITY_PARAM(rxqueue_timer, "Rx Queue Empty defer timer");
+
+#define TX_INTSUP_DEF       0x1F
+#define TX_INTSUP_MIN       0x01
+#define TX_INTSUP_MAX       0x3F
+VELOCITY_PARAM(tx_intsup, "Tx Interrupt Suppression Threshold");
+
+#define RX_INTSUP_DEF       0x1F
+#define RX_INTSUP_MIN       0x01
+#define RX_INTSUP_MAX       0x3F
+VELOCITY_PARAM(rx_intsup, "Rx Interrupt Suppression Threshold");
+
 #ifdef CONFIG_PM
 static DEFINE_SPINLOCK(velocity_dev_list_lock);
 static LIST_HEAD(velocity_dev_list);
@@ -517,6 +537,10 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 	velocity_set_int_opt((int *) &opts->spd_dpx, speed_duplex[index], MED_LNK_MIN, MED_LNK_MAX, MED_LNK_DEF, "Media link mode", devname);
 	velocity_set_int_opt((int *) &opts->wol_opts, wol_opts[index], WOL_OPT_MIN, WOL_OPT_MAX, WOL_OPT_DEF, "Wake On Lan options", devname);
 	velocity_set_int_opt((int *) &opts->int_works, int_works[index], INT_WORKS_MIN, INT_WORKS_MAX, INT_WORKS_DEF, "Interrupt service works", devname);
+	velocity_set_int_opt((int *) &opts->txqueue_timer, txqueue_timer[index], TXQUEUE_TIMER_MIN, TXQUEUE_TIMER_MAX, TXQUEUE_TIMER_DEF, "TX queue empty defer timer", devname);
+	velocity_set_int_opt((int *) &opts->rxqueue_timer, rxqueue_timer[index], RXQUEUE_TIMER_MIN, RXQUEUE_TIMER_MAX, RXQUEUE_TIMER_DEF, "RX queue empty defer timer", devname);
+	velocity_set_int_opt((int *) &opts->tx_intsup, tx_intsup[index], TX_INTSUP_MIN, TX_INTSUP_MAX, TX_INTSUP_DEF, "TX interrupt suppression threshold", devname);
+	velocity_set_int_opt((int *) &opts->rx_intsup, rx_intsup[index], RX_INTSUP_MIN, RX_INTSUP_MAX, RX_INTSUP_DEF, "RX interrupt suppression threshold", devname);
 	opts->numrx = (opts->numrx & ~3);
 }
 
@@ -1259,6 +1283,35 @@ static void mii_init(struct velocity_info *vptr, u32 mii_status)
 	}
 }
 
+/**
+ * enable_adaptive_interrupts  -  Turn on interrupt suppression
+ *
+ * @vptr velocity adapter
+ *
+ * The velocity is able to supress interrupt during high interrupt load.
+ * This function turns on that feature.
+ */
+static void enable_adaptive_interrupts(struct velocity_info *vptr)
+{
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+
+	vptr->int_mask = INT_MASK_DEF;
+
+	/* Set Tx Interrupt Suppression Threshold */
+	writeb(CAMCR_PS0, &regs->CAMCR);
+	writew(vptr->options.tx_intsup, &regs->ISRCTL);
+
+	/* Set Rx Interrupt Suppression Threshold */
+	writeb(CAMCR_PS1, &regs->CAMCR);
+	writew(vptr->options.rx_intsup, &regs->ISRCTL);
+
+	/* Select page to interrupt hold timer */
+	writeb(0, &regs->CAMCR);
+
+	/* Modify int mask */
+	vptr->int_mask &= ~(ISR_PTXI | ISR_PTX0I | ISR_PTX1I | ISR_PTX2I |
+			ISR_PTX3I | ISR_PRXI);
+}
 
 /**
  *	velocity_init_registers	-	initialise MAC registers
@@ -1345,7 +1398,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		 */
 		enable_mii_autopoll(regs);
 
-		vptr->int_mask = INT_MASK_DEF;
+		enable_adaptive_interrupts(vptr);
 
 		writel(vptr->rx.pool_dma, &regs->RDBaseLo);
 		writew(vptr->options.numrx - 1, &regs->RDCSize);
@@ -1802,6 +1855,21 @@ static void velocity_error(struct velocity_info *vptr, int status)
 				BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
 			else
 				BYTE_REG_BITS_ON(TESTCFG_HBDIS, &regs->TESTCFG);
+
+			/* Adaptive interrupts */
+			if (vptr->rev_id >= REV_ID_VT3216_A0) {
+				u8 txqueue_timer = 0;
+				u8 rxqueue_timer = 0;
+
+				if (vptr->mii_status & (VELOCITY_SPEED_1000 |
+						VELOCITY_SPEED_100)) {
+					txqueue_timer = vptr->options.txqueue_timer;
+					rxqueue_timer = vptr->options.rxqueue_timer;
+				}
+
+				writeb(txqueue_timer, &regs->TQETMR);
+				writeb(rxqueue_timer, &regs->RQETMR);
+			}
 		}
 		/*
 		 *	Get link status from PHYSR0
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 2f00c13..6091946 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1005,7 +1005,8 @@ struct mac_regs {
 
 	volatile __le32 RDBaseLo;	/* 0x38 */
 	volatile __le16 RDIdx;		/* 0x3C */
-	volatile __le16 reserved_3E;
+	volatile u8 TQETMR;		/* 0x3E, VT3216 and above only */
+	volatile u8 RQETMR;		/* 0x3F, VT3216 and above only */
 
 	volatile __le32 TDBaseLo[4];	/* 0x40 */
 
@@ -1491,6 +1492,10 @@ struct velocity_opt {
 	int rx_bandwidth_hi;
 	int rx_bandwidth_lo;
 	int rx_bandwidth_en;
+	int rxqueue_timer;
+	int txqueue_timer;
+	int tx_intsup;
+	int rx_intsup;
 	u32 flags;
 };
 
-- 
1.6.0.4

