From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: [PATCH v4 2/7] via-velocity: Add ethtool interrupt coalescing
 support
Date: Thu, 26 Nov 2009 09:10:12 +0100
Message-ID: <20091126091012.67646c42@marrow.netinsight.se>
References: <20091120160633.77b7aee0@marrow.netinsight.se>
	<20091123152724.2871cf4d@marrow.netinsight.se>
	<20091126090429.39cb37ac@marrow.netinsight.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, davej@redhat.com, shemminger@vyatta.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:62612 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1759392AbZKZIKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 03:10:10 -0500
In-Reply-To: <20091126090429.39cb37ac@marrow.netinsight.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Partially from the upstream VIA driver). Tweaking the number of
frames-per-interrupt and timer-until-interrupt can reduce the amount of
CPU work quite a lot.

Signed-off-by: Simon Kagstrom <simon.kagstrom@netinsight.net>
---
 drivers/net/via-velocity.c |  160 +++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/via-velocity.h |    7 ++-
 2 files changed, 165 insertions(+), 2 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index b6cf3b5..85ee898 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -1259,6 +1259,66 @@ static void mii_init(struct velocity_info *vptr, u32 mii_status)
 	}
 }
 
+/**
+ * setup_queue_timers	-	Setup interrupt timers
+ *
+ * Setup interrupt frequency during suppression (timeout if the frame
+ * count isn't filled).
+ */
+static void setup_queue_timers(struct velocity_info *vptr)
+{
+	/* Only for newer revisions */
+	if (vptr->rev_id >= REV_ID_VT3216_A0) {
+		u8 txqueue_timer = 0;
+		u8 rxqueue_timer = 0;
+
+		if (vptr->mii_status & (VELOCITY_SPEED_1000 |
+				VELOCITY_SPEED_100)) {
+			txqueue_timer = vptr->options.txqueue_timer;
+			rxqueue_timer = vptr->options.rxqueue_timer;
+		}
+
+		writeb(txqueue_timer, &vptr->mac_regs->TQETMR);
+		writeb(rxqueue_timer, &vptr->mac_regs->RQETMR);
+	}
+}
+/**
+ * setup_adaptive_interrupts  -  Setup interrupt suppression
+ *
+ * @vptr velocity adapter
+ *
+ * The velocity is able to suppress interrupt during high interrupt load.
+ * This function turns on that feature.
+ */
+static void setup_adaptive_interrupts(struct velocity_info *vptr)
+{
+	struct mac_regs __iomem *regs = vptr->mac_regs;
+	u16 tx_intsup = vptr->options.tx_intsup;
+	u16 rx_intsup = vptr->options.rx_intsup;
+
+	/* Setup default interrupt mask (will be changed below) */
+	vptr->int_mask = INT_MASK_DEF;
+
+	/* Set Tx Interrupt Suppression Threshold */
+	writeb(CAMCR_PS0, &regs->CAMCR);
+	if (tx_intsup != 0) {
+		vptr->int_mask &= ~(ISR_PTXI | ISR_PTX0I | ISR_PTX1I |
+				ISR_PTX2I | ISR_PTX3I);
+		writew(tx_intsup, &regs->ISRCTL);
+	} else
+		writew(ISRCTL_TSUPDIS, &regs->ISRCTL);
+
+	/* Set Rx Interrupt Suppression Threshold */
+	writeb(CAMCR_PS1, &regs->CAMCR);
+	if (rx_intsup != 0) {
+		vptr->int_mask &= ~ISR_PRXI;
+		writew(rx_intsup, &regs->ISRCTL);
+	} else
+		writew(ISRCTL_RSUPDIS, &regs->ISRCTL);
+
+	/* Select page to interrupt hold timer */
+	writeb(0, &regs->CAMCR);
+}
 
 /**
  *	velocity_init_registers	-	initialise MAC registers
@@ -1345,7 +1405,7 @@ static void velocity_init_registers(struct velocity_info *vptr,
 		 */
 		enable_mii_autopoll(regs);
 
-		vptr->int_mask = INT_MASK_DEF;
+		setup_adaptive_interrupts(vptr);
 
 		writel(vptr->rx.pool_dma, &regs->RDBaseLo);
 		writew(vptr->options.numrx - 1, &regs->RDCSize);
@@ -1802,6 +1862,8 @@ static void velocity_error(struct velocity_info *vptr, int status)
 				BYTE_REG_BITS_OFF(TESTCFG_HBDIS, &regs->TESTCFG);
 			else
 				BYTE_REG_BITS_ON(TESTCFG_HBDIS, &regs->TESTCFG);
+
+			setup_queue_timers(vptr);
 		}
 		/*
 		 *	Get link status from PHYSR0
@@ -3223,6 +3285,100 @@ static void velocity_set_msglevel(struct net_device *dev, u32 value)
 	 msglevel = value;
 }
 
+static int get_pending_timer_val(int val)
+{
+	int mult_bits = val >> 6;
+	int mult = 1;
+
+	switch (mult_bits)
+	{
+	case 1:
+		mult = 4; break;
+	case 2:
+		mult = 16; break;
+	case 3:
+		mult = 64; break;
+	case 0:
+	default:
+		break;
+	}
+
+	return (val & 0x3f) * mult;
+}
+
+static void set_pending_timer_val(int *val, u32 us)
+{
+	u8 mult = 0;
+	u8 shift = 0;
+
+	if (us >= 0x3f) {
+		mult = 1; /* mult with 4 */
+		shift = 2;
+	}
+	if (us >= 0x3f * 4) {
+		mult = 2; /* mult with 16 */
+		shift = 4;
+	}
+	if (us >= 0x3f * 16) {
+		mult = 3; /* mult with 64 */
+		shift = 6;
+	}
+
+	*val = (mult << 6) | ((us >> shift) & 0x3f);
+}
+
+
+static int velocity_get_coalesce(struct net_device *dev,
+		struct ethtool_coalesce *ecmd)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+
+	ecmd->tx_max_coalesced_frames = vptr->options.tx_intsup;
+	ecmd->rx_max_coalesced_frames = vptr->options.rx_intsup;
+
+	ecmd->rx_coalesce_usecs = get_pending_timer_val(vptr->options.rxqueue_timer);
+	ecmd->tx_coalesce_usecs = get_pending_timer_val(vptr->options.txqueue_timer);
+
+	return 0;
+}
+
+static int velocity_set_coalesce(struct net_device *dev,
+		struct ethtool_coalesce *ecmd)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+	int max_us = 0x3f * 64;
+
+	/* 6 bits of  */
+	if (ecmd->tx_coalesce_usecs > max_us)
+		return -EINVAL;
+	if (ecmd->rx_coalesce_usecs > max_us)
+		return -EINVAL;
+
+	if (ecmd->tx_max_coalesced_frames > 0xff)
+		return -EINVAL;
+	if (ecmd->rx_max_coalesced_frames > 0xff)
+		return -EINVAL;
+
+	vptr->options.rx_intsup = ecmd->rx_max_coalesced_frames;
+	vptr->options.tx_intsup = ecmd->tx_max_coalesced_frames;
+
+	set_pending_timer_val(&vptr->options.rxqueue_timer,
+			ecmd->rx_coalesce_usecs);
+	set_pending_timer_val(&vptr->options.txqueue_timer,
+			ecmd->tx_coalesce_usecs);
+
+	/* Setup the interrupt suppression and queue timers */
+	mac_disable_int(vptr->mac_regs);
+	setup_adaptive_interrupts(vptr);
+	setup_queue_timers(vptr);
+
+	mac_write_int_mask(vptr->int_mask, vptr->mac_regs);
+	mac_clear_isr(vptr->mac_regs);
+	mac_enable_int(vptr->mac_regs);
+
+	return 0;
+}
+
 static const struct ethtool_ops velocity_ethtool_ops = {
 	.get_settings	=	velocity_get_settings,
 	.set_settings	=	velocity_set_settings,
@@ -3232,6 +3388,8 @@ static const struct ethtool_ops velocity_ethtool_ops = {
 	.get_msglevel	=	velocity_get_msglevel,
 	.set_msglevel	=	velocity_set_msglevel,
 	.get_link	=	velocity_get_link,
+	.get_coalesce	=	velocity_get_coalesce,
+	.set_coalesce	=	velocity_set_coalesce,
 	.begin		=	velocity_ethtool_up,
 	.complete	=	velocity_ethtool_down
 };
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

