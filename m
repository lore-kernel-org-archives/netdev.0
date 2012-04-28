From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 8/8] mISDN: Add 2MBit mode for HFC E1 card
Date: Sat, 28 Apr 2012 13:43:24 +0200
Message-ID: <1335613404-10187-9-git-send-email-kkeil@linux-pingi.de>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:62579 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079Ab2D1LrX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:47:23 -0400
In-Reply-To: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <isdn@linux-pingi.de>

The new mode allows to receive and transmit full transparent
or HDLC data of all timeslots via one FIFO.
Change some register names to match the latest manual for
the E1 chip.

Signed-off-by: Karsten Keil <kkeil@linux-pingi.de>
---
 drivers/isdn/hardware/mISDN/hfc_multi.h |   79 +++---
 drivers/isdn/hardware/mISDN/hfcmulti.c  |  426 ++++++++++++++++++++++++++-----
 include/linux/mISDNif.h                 |   57 +++--
 3 files changed, 440 insertions(+), 122 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfc_multi.h b/drivers/isdn/hardware/mISDN/hfc_multi.h
index c601f88..9dc0543 100644
--- a/drivers/isdn/hardware/mISDN/hfc_multi.h
+++ b/drivers/isdn/hardware/mISDN/hfc_multi.h
@@ -12,6 +12,7 @@
 #define	DEBUG_HFCMULTI_FILL	0x00800000
 #define	DEBUG_HFCMULTI_SYNC	0x01000000
 #define	DEBUG_HFCMULTI_DTMF	0x02000000
+#define	DEBUG_HFCMULTI_TIMER	0x04000000
 #define	DEBUG_HFCMULTI_LOCK	0x80000000
 
 #define	PCI_ENA_REGIO	0x01
@@ -71,7 +72,10 @@ struct hfcm_hw {
 	u_char	r_dtmf;
 	u_char	r_st_sync;
 	u_char	r_sci_msk;
-	u_char	r_tx0, r_tx1;
+	u_char	r_tx0;
+	u_char	r_tx1;
+	u_char	r_rx_sl0_cfg0;
+	u_char	r_tx_sl0_cfg1;
 	u_char	a_st_ctrl0[8];
 	u_char	r_bert_wd_md;
 	timer_t	timer;
@@ -114,6 +118,7 @@ struct hfcm_hw {
 /* hw */
 #define	HFC_CHIP_PLXSD		14 /* whether we have a Speech-Design PLX */
 #define	HFC_CHIP_EMBSD          15 /* whether we have a SD Embedded board */
+#define HFC_CHIP_2MBITRAW	16 /* mode to access full 32 byte data */
 
 #define HFC_IO_MODE_PCIMEM	0x00 /* normal memory mapped IO */
 #define HFC_IO_MODE_REGIO	0x01 /* PCI io access */
@@ -334,24 +339,23 @@ struct hfc_multi {
 #define R_LOS0			0x22
 #define R_LOS1			0x23
 #define R_RX0			0x24
-#define R_RX_FR0		0x25
-#define R_RX_FR1		0x26
+#define R_RX_SL0_CFG0		0x25
+#define R_RX_SL0_CFG1		0x26
 #define R_TX0			0x28
 #define R_TX1			0x29
-#define R_TX_FR0		0x2C
-
-#define R_TX_FR1		0x2D
-#define R_TX_FR2		0x2E
-#define R_JATT_ATT		0x2F /* undocumented */
+#define R_TX_SL0_CFG0		0x2C
+#define R_TX_SL0		0x2D
+#define R_TX_SL0_CFG1		0x2E
+#define R_JATT_CFG		0x2F
 #define A_ST_RD_STATE		0x30
 #define A_ST_WR_STATE		0x30
-#define R_RX_OFF		0x30
+#define R_RX_OFFS		0x30
 #define A_ST_CTRL0		0x31
 #define R_SYNC_OUT		0x31
 #define A_ST_CTRL1		0x32
 #define A_ST_CTRL2		0x33
 #define A_ST_SQ_WR		0x34
-#define R_TX_OFF		0x34
+#define R_TX_OFFS		0x34
 #define R_SYNC_CTRL		0x35
 #define A_ST_CLK_DLY		0x37
 #define R_PWM0			0x38
@@ -414,8 +418,8 @@ struct hfc_multi {
 #define R_RX_SL0_0		0x25
 #define R_RX_SL0_1		0x26
 #define R_RX_SL0_2		0x27
-#define R_JATT_DIR		0x2b /* undocumented */
-#define R_SLIP			0x2c
+#define R_JATT_STA		0x2B
+#define R_SLIP			0x2C
 #define A_ST_RD_STA		0x30
 #define R_FAS_EC		0x30
 #define R_FAS_ECL		0x30
@@ -430,12 +434,12 @@ struct hfc_multi {
 #define R_E_EC			0x36
 #define R_E_ECL			0x36
 #define R_E_ECH			0x37
-#define R_SA6_SA13_EC		0x38
-#define R_SA6_SA13_ECL		0x38
-#define R_SA6_SA13_ECH		0x39
-#define R_SA6_SA23_EC		0x3A
-#define R_SA6_SA23_ECL		0x3A
-#define R_SA6_SA23_ECH		0x3B
+#define R_SA6_VAL13_EC		0x38
+#define R_SA6_VAL13_ECL		0x38
+#define R_SA6_VAL13_ECH		0x39
+#define R_SA6_VAL23_EC		0x3A
+#define R_SA6_VAL23_ECL		0x3A
+#define R_SA6_VAL23_ECH		0x3B
 #define A_ST_B1_RX		0x3C
 #define A_ST_B2_RX		0x3D
 #define A_ST_D_RX		0x3E
@@ -624,7 +628,7 @@ struct hfc_multi {
 #define V_RX_INV_CLK		0x20
 #define V_RX_INV_DATA		0x40
 #define V_AIS_ITU		0x80
-/* R_RX_FR0 */
+/* R_RX_SL0_CFG0 */
 #define V_NO_INSYNC		0x01
 #define V_AUTO_RESYNC		0x02
 #define V_AUTO_RECO		0x04
@@ -633,7 +637,7 @@ struct hfc_multi {
 #define V_XCRC_SYNC		0x20
 #define V_MF_RESYNC		0x40
 #define V_RESYNC		0x80
-/* R_RX_FR1 */
+/* R_RX_SL0_CFG1 */
 #define V_RX_MF			0x01
 #define V_RX_MF_SYNC		0x02
 #define V_RX_SL0_RAM		0x04
@@ -654,17 +658,17 @@ struct hfc_multi {
 #define V_ATX			0x20
 #define V_NTRI			0x40
 #define V_AUTO_ERR_RES		0x80
-/* R_TX_FR0 */
+/* R_TX_SL0_CFG0 */
 #define V_TRP_FAS		0x01
 #define V_TRP_NFAS		0x02
 #define V_TRP_RAL		0x04
 #define V_TRP_SA		0x08
-/* R_TX_FR1 */
+/* R_TX_SL0 */
 #define V_TX_FAS		0x01
 #define V_TX_NFAS		0x02
 #define V_TX_RAL		0x04
 #define V_TX_SA			0x08
-/* R_TX_FR2 */
+/* R_TX_SL0_CFG1 */
 #define V_TX_MF			0x01
 #define V_TRP_SL0		0x02
 #define V_TX_SL0_RAM		0x04
@@ -672,7 +676,7 @@ struct hfc_multi {
 #define V_NEG_E			0x20
 #define V_XS12_ON		0x40
 #define V_XS15_ON		0x80
-/* R_RX_OFF */
+/* R_RX_OFFS */
 #define V_RX_SZ			0x01
 #define V_RX_INIT		0x04
 /* R_SYNC_OUT */
@@ -680,7 +684,7 @@ struct hfc_multi {
 #define V_IPATS0		0x20
 #define V_IPATS1		0x40
 #define V_IPATS2		0x80
-/* R_TX_OFF */
+/* R_TX_OFFS */
 #define V_TX_SZ			0x01
 #define V_TX_INIT		0x04
 /* R_SYNC_CTRL */
@@ -1119,20 +1123,20 @@ struct hfc_register_names {
 	{"R_LOS0",		0x22},
 	{"R_LOS1",		0x23},
 	{"R_RX0",		0x24},
-	{"R_RX_FR0",		0x25},
-	{"R_RX_FR1",		0x26},
+	{"R_RX_SL0_CFG0",	0x25},
+	{"R_RX_SL0_CFG1",	0x26},
 	{"R_TX0",		0x28},
 	{"R_TX1",		0x29},
-	{"R_TX_FR0",		0x2C},
-	{"R_TX_FR1",		0x2D},
-	{"R_TX_FR2",		0x2E},
+	{"R_TX_SL0_CFG0",	0x2C},
+	{"R_TX_SL0",		0x2D},
+	{"R_TX_SL0_CFG1",	0x2E},
 	{"R_JATT_ATT",		0x2F},
-	{"A_ST_xx_STA/R_RX_OFF", 0x30},
+	{"A_ST_xx_STA/R_RX_OFFS", 0x30},
 	{"A_ST_CTRL0/R_SYNC_OUT", 0x31},
 	{"A_ST_CTRL1",		0x32},
 	{"A_ST_CTRL2",		0x33},
 	{"A_ST_SQ_WR",		0x34},
-	{"R_TX_OFF",		0x34},
+	{"R_TX_OFFS",		0x34},
 	{"R_SYNC_CTRL",		0x35},
 	{"A_ST_CLK_DLY",	0x37},
 	{"R_PWM0",		0x38},
@@ -1194,8 +1198,9 @@ struct hfc_register_names {
 	{"R_RX_SL0_0",		0x25},
 	{"R_RX_SL0_1",		0x26},
 	{"R_RX_SL0_2",		0x27},
-	{"R_JATT_DIR",		0x2b},
+	{"R_JATT_STA",		0x2b},
 	{"R_SLIP",		0x2c},
+	{"R_JATT_CFG",		0x2f},
 	{"A_ST_RD_STA",		0x30},
 	{"R_FAS_ECL",		0x30},
 	{"R_FAS_ECH",		0x31},
@@ -1205,10 +1210,10 @@ struct hfc_register_names {
 	{"R_CRC_ECH",		0x35},
 	{"R_E_ECL",		0x36},
 	{"R_E_ECH",		0x37},
-	{"R_SA6_SA13_ECL",	0x38},
-	{"R_SA6_SA13_ECH",	0x39},
-	{"R_SA6_SA23_ECL",	0x3A},
-	{"R_SA6_SA23_ECH",	0x3B},
+	{"R_SA6_VAL13_ECL",	0x38},
+	{"R_SA6_VAL13_ECH",	0x39},
+	{"R_SA6_VAL23_ECL",	0x3A},
+	{"R_SA6_VAL23_ECH",	0x3B},
 	{"A_ST_B1_RX",		0x3C},
 	{"A_ST_B2_RX",		0x3D},
 	{"A_ST_D_RX",		0x3E},
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 4301331..06be60c 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -64,7 +64,7 @@
  *
  *	HFC-E1 only bits:
  *	Bit 0     = 0x0001 = interface: 0=copper, 1=optical
- *	Bit 1     = 0x0002 = reserved (later for 32 B-channels transparent mode)
+ *	Bit 1     = 0x0002 = 32 B-channels bundle mode (one channel)
  *	Bit 2     = 0x0004 = Report LOS
  *	Bit 3     = 0x0008 = Report AIS
  *	Bit 4     = 0x0010 = Report SLIP
@@ -1269,11 +1269,10 @@ init_chip(struct hfc_multi *hc)
 		if (debug & DEBUG_HFCMULTI_INIT)
 			printk(KERN_DEBUG "%s: setting PCM into slave mode\n",
 			       __func__);
-	} else
-		if (test_bit(HFC_CHIP_PCM_MASTER, &hc->chip) && !plxsd_master) {
+	} else  if (test_bit(HFC_CHIP_PCM_MASTER, &hc->chip) && !plxsd_master) {
 			if (debug & DEBUG_HFCMULTI_INIT)
 				printk(KERN_DEBUG "%s: setting PCM into master mode\n",
-				       __func__);
+				__func__);
 			hc->hw.r_pcm_md0 |= V_PCM_MD;
 		} else {
 			if (debug & DEBUG_HFCMULTI_INIT)
@@ -1288,7 +1287,18 @@ init_chip(struct hfc_multi *hc)
 			 0x11 /* 16 Bytes TX/RX */);
 	else
 		HFC_outb(hc, R_RAM_SZ, hc->hw.r_ram_sz);
-	HFC_outb(hc, R_FIFO_MD, 0);
+	if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip) &&
+	    (hc->ctype == HFC_TYPE_E1)) {
+		if (debug & DEBUG_HFCMULTI_INIT)
+			printk(KERN_DEBUG "%s: setting 2MBit raw mode\n",
+				__func__);
+		HFC_outb(hc, R_FIFO_MD, 0x0c);
+		hc->Flen = 0x10;
+		hc->Zmin = 0x80;
+		hc->Zlen = 384;
+
+	} else
+		HFC_outb(hc, R_FIFO_MD, 0);
 	if (hc->ctype == HFC_TYPE_XHFC)
 		hc->hw.r_cirm = V_SRES | V_HFCRES | V_PCMRES | V_STRES;
 	else
@@ -1334,7 +1344,8 @@ init_chip(struct hfc_multi *hc)
 	if (hc->slots == 128)
 		HFC_outb(hc, R_PCM_MD1, 0x20);
 	HFC_outb(hc, R_PCM_MD0, hc->hw.r_pcm_md0 | 0xa0);
-	if (test_bit(HFC_CHIP_PLXSD, &hc->chip))
+	if (test_bit(HFC_CHIP_PLXSD, &hc->chip) ||
+		test_bit(HFC_CHIP_PCM_MASTER, &hc->chip))
 		HFC_outb(hc, R_PCM_MD2, V_SYNC_SRC); /* sync via SYNC_I / O */
 	else if (test_bit(HFC_CHIP_EMBSD, &hc->chip))
 		HFC_outb(hc, R_PCM_MD2, 0x10); /* V_C2O_EN */
@@ -1956,7 +1967,10 @@ hfcmulti_tx(struct hfc_multi *hc, int ch)
 	int *idxp;
 
 	bch = hc->chan[ch].bch;
-	dch = hc->chan[ch].dch;
+	if (!bch)
+		dch = hc->chan[ch].dch;
+	else
+		dch = NULL;
 	if ((!dch) && (!bch))
 		return;
 
@@ -2205,7 +2219,11 @@ hfcmulti_rx(struct hfc_multi *hc, int ch)
 	int	maxlen;
 
 	bch = hc->chan[ch].bch;
-	dch = hc->chan[ch].dch;
+	if (!bch)
+		dch = hc->chan[ch].dch;
+	else
+		dch = NULL;
+
 	if ((!dch) && (!bch))
 		return;
 	if (dch) {
@@ -2264,20 +2282,20 @@ next_frame:
 	if (Zsize <= 0)
 		return;
 
-	if (*sp == NULL) {
-		*sp = mI_alloc_skb(maxlen + 3, GFP_ATOMIC);
-		if (*sp == NULL) {
-			printk(KERN_DEBUG "%s: No mem for rx_skb\n",
-			       __func__);
-			return;
-		}
-	}
 	/* show activity */
 	if (dch)
 		hc->activity_rx |= 1 << hc->chan[ch].port;
 
 	/* empty fifo with what we have */
 	if (dch || test_bit(FLG_HDLC, &bch->Flags)) {
+		if (*sp == NULL) {
+			*sp = mI_alloc_skb(maxlen + 3, GFP_ATOMIC);
+			if (*sp == NULL) {
+				printk(KERN_DEBUG "%s: No mem for rx_skb\n",
+				    __func__);
+				return;
+			}
+		}
 		if (debug & DEBUG_HFCMULTI_FIFO)
 			printk(KERN_DEBUG "%s(card %d): fifo(%d) reading %d "
 			       "bytes (z1=%04x, z2=%04x) HDLC %s (f1=%d, f2=%d) "
@@ -2355,24 +2373,18 @@ next_frame:
 		/* there is an incomplete frame */
 	} else {
 		/* transparent */
+		if (*sp == NULL) {
+			*sp = mI_alloc_skb(Zsize, GFP_ATOMIC);
+			if (*sp == NULL) {
+				printk(KERN_DEBUG "%s: No mem for rx_skb\n",
+				    __func__);
+				return;
+			}
+		}
 		if (Zsize > skb_tailroom(*sp))
 			Zsize = skb_tailroom(*sp);
 		hc->read_fifo(hc, skb_put(*sp, Zsize), Zsize);
-		if (((*sp)->len) < MISDN_COPY_SIZE) {
-			skb = *sp;
-			*sp = mI_alloc_skb(skb->len, GFP_ATOMIC);
-			if (*sp) {
-				memcpy(skb_put(*sp, skb->len),
-				       skb->data, skb->len);
-				skb_trim(skb, 0);
-			} else {
-				printk(KERN_DEBUG "%s: No mem\n", __func__);
-				*sp = skb;
-				skb = NULL;
-			}
-		} else {
-			skb = NULL;
-		}
+		skb = NULL;
 		if (debug & DEBUG_HFCMULTI_FIFO)
 			printk(KERN_DEBUG
 			       "%s(card %d): fifo(%d) reading %d bytes "
@@ -2409,7 +2421,7 @@ signal_state_up(struct dchannel *dch, int info, char *msg)
 static inline void
 handle_timer_irq(struct hfc_multi *hc)
 {
-	int		ch, temp;
+	int		ch, temp, ch_activ = 0;
 	struct dchannel	*dch;
 	u_long		flags;
 
@@ -2443,10 +2455,33 @@ handle_timer_irq(struct hfc_multi *hc)
 		hc->e1_resync = 0;
 		spin_unlock_irqrestore(&HFClock, flags);
 	}
-
-	if (hc->ctype != HFC_TYPE_E1 || hc->e1_state == 1)
+	if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip)) {
+		ch = 0;
+		if (hc->created[hc->chan[ch].port] && hc->chan[ch].bch &&
+		    test_bit(FLG_ACTIVE, &hc->chan[ch].bch->Flags)) {
+			ch_activ++;
+			hfcmulti_tx(hc, ch);
+			hfcmulti_rx(hc, ch);
+			if (hc->chan[ch].dch &&
+			    hc->chan[ch].nt_timer > -1) {
+				dch = hc->chan[ch].dch;
+				if (!(--hc->chan[ch].nt_timer)) {
+					schedule_event(dch,
+					    FLG_PHCHANGE);
+					if (debug &
+					    DEBUG_HFCMULTI_STATE)
+						printk(KERN_DEBUG
+						    "%s: nt_timer at "
+						    "state %x\n",
+						    __func__,
+						    dch->state);
+				}
+			}
+		}
+	} else if (hc->ctype != HFC_TYPE_E1 || hc->e1_state == 1) {
 		for (ch = 0; ch <= 31; ch++) {
 			if (hc->created[hc->chan[ch].port]) {
+				ch_activ++;
 				hfcmulti_tx(hc, ch);
 				/* fifo is started when switching to rx-fifo */
 				hfcmulti_rx(hc, ch);
@@ -2467,6 +2502,11 @@ handle_timer_irq(struct hfc_multi *hc)
 				}
 			}
 		}
+	}
+	if (debug & DEBUG_HFCMULTI_TIMER)
+		printk(KERN_DEBUG "Timer IRQ id%dp%d st%d activ %d\n",
+			hc->id, hc->ports, hc->e1_state, ch_activ);
+
 	if (hc->ctype == HFC_TYPE_E1 && hc->created[0]) {
 		dch = hc->chan[hc->dnum[0]].dch;
 		/* LOS */
@@ -2515,7 +2555,7 @@ handle_timer_irq(struct hfc_multi *hc)
 						"RDI gone");
 			hc->chan[hc->dnum[0]].rdi = temp;
 		}
-		temp = HFC_inb_nodebug(hc, R_JATT_DIR);
+		temp = HFC_inb_nodebug(hc, R_JATT_STA);
 		switch (hc->chan[hc->dnum[0]].sync) {
 		case 0:
 			if ((temp & 0x60) == 0x60) {
@@ -2524,9 +2564,9 @@ handle_timer_irq(struct hfc_multi *hc)
 					       "%s: (id=%d) E1 now "
 					       "in clock sync\n",
 					       __func__, hc->id);
-				HFC_outb(hc, R_RX_OFF,
+				HFC_outb(hc, R_RX_OFFS,
 				    hc->chan[hc->dnum[0]].jitter | V_RX_INIT);
-				HFC_outb(hc, R_TX_OFF,
+				HFC_outb(hc, R_TX_OFFS,
 				    hc->chan[hc->dnum[0]].jitter | V_RX_INIT);
 				hc->chan[hc->dnum[0]].sync = 1;
 				goto check_framesync;
@@ -2660,6 +2700,8 @@ fifo_irq(struct hfc_multi *hc, int block)
 
 	r_irq_fifo_bl = HFC_inb_nodebug(hc, R_IRQ_FIFO_BL0 + block);
 	j = 0;
+	printk(KERN_DEBUG "%s: block %d fifo_bl %02x\n", __func__,
+		block, r_irq_fifo_bl);
 	while (j < 8) {
 		ch = (block << 2) + (j >> 1);
 		dch = hc->chan[ch].dch;
@@ -2870,6 +2912,52 @@ hfcmulti_dbusy_timer(struct hfc_multi *hc)
 {
 }
 
+/* special mode to transmit/revceive full frame (all timeslots) in fifo 0 */
+
+static int set_2MBit_mode(struct hfc_multi *hc, int prot)
+{
+	u8 ch, lim;
+
+	for (ch = 0; ch < 64; ch++) {
+		/* Reset all fifo */
+		HFC_outb(hc, R_FIFO, ch);
+		HFC_wait(hc);
+		HFC_outb(hc, R_INC_RES_FIFO, 6);
+	}
+
+	HFC_outb(hc, R_FIRST_FIFO, 0x0);
+	lim = 63;
+	for (ch = 0; ch < 64; ch++) {
+		HFC_outb(hc, R_FSM_IDX, ch);
+		HFC_wait(hc);
+		HFC_outb(hc, A_CHANNEL, ch);
+		HFC_outb(hc, A_FIFO_SEQ, (ch + 1) % 2);
+		if (prot == ISDN_P_B_HDLC)
+			HFC_outb(hc, A_CON_HDLC, 0x4);
+		else
+			HFC_outb(hc, A_CON_HDLC, 0x6);
+		HFC_outb(hc, A_SUBCH_CFG, 0);
+		if (ch == lim)
+			break;
+	}
+	HFC_outb(hc, A_FIFO_SEQ, 0x40);
+
+	for (ch = 0; ch < 64; ch++) {
+		u8 ach, asc, ac, afs, ais, af1, af2;
+		HFC_outb(hc, R_FIFO, ch);
+		HFC_wait(hc);
+		ach = HFC_inb(hc, A_CON_HDLC);
+		asc = HFC_inb(hc, A_SUBCH_CFG);
+		ac = HFC_inb(hc,  A_CHANNEL);
+		afs = HFC_inb(hc, A_FIFO_SEQ);
+		ais = HFC_inb(hc, A_IRQ_MSK);
+		af1 = HFC_inb(hc, A_F1);
+		af2 = HFC_inb(hc, A_F2);
+		printk(KERN_DEBUG "R_FIFO %02d: %02x/%02x/%02x/%02x/%02x %d/%d\n",
+			ch, ach, asc, ac, afs, ais, af1, af2);
+	}
+	return 0;
+}
 
 /*
  * activate/deactivate hardware for selected channels and mode
@@ -3514,12 +3602,24 @@ handle_bmsg(struct mISDNchannel *ch, struct sk_buff *skb)
 		/* activate B-channel if not already activated */
 		if (!test_and_set_bit(FLG_ACTIVE, &bch->Flags)) {
 			hc->chan[bch->slot].txpending = 0;
-			ret = mode_hfcmulti(hc, bch->slot,
-					    ch->protocol,
-					    hc->chan[bch->slot].slot_tx,
-					    hc->chan[bch->slot].bank_tx,
-					    hc->chan[bch->slot].slot_rx,
-					    hc->chan[bch->slot].bank_rx);
+			if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip)) {
+				ret = set_2MBit_mode(hc, ch->protocol);
+				/* The default content for these registers can
+				 * be changed via a MISDN_CTRL_L1_TS0_MODE ctrl
+				 * request
+				 */
+				HFC_outb(hc, R_RX_SL0_CFG0,
+					hc->hw.r_rx_sl0_cfg0);
+				HFC_outb(hc, R_TX_SL0_CFG1,
+					hc->hw.r_tx_sl0_cfg1);
+			} else {
+				ret = mode_hfcmulti(hc, bch->slot,
+					ch->protocol,
+					hc->chan[bch->slot].slot_tx,
+					hc->chan[bch->slot].bank_tx,
+					hc->chan[bch->slot].slot_rx,
+					hc->chan[bch->slot].bank_rx);
+			}
 			if (!ret) {
 				if (ch->protocol == ISDN_P_B_RAW && !hc->dtmf
 				    && test_bit(HFC_CHIP_DTMF, &hc->chip)) {
@@ -3591,11 +3691,13 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 	int			slot_rx;
 	int			bank_rx;
 	int			num;
+	u8			v1, v2;
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_HFC_OP | MISDN_CTRL_HW_FEATURES_OP
-			| MISDN_CTRL_RX_OFF | MISDN_CTRL_FILL_EMPTY;
+		cq->op = MISDN_CTRL_HFC_OP | MISDN_CTRL_HW_FEATURES_OP |
+			MISDN_CTRL_RX_OFF | MISDN_CTRL_FILL_EMPTY |
+			MISDN_CTRL_L1_TESTS;
 		break;
 	case MISDN_CTRL_RX_OFF: /* turn off / on rx stream */
 		hc->chan[bch->slot].rx_off = !!cq->p1;
@@ -3702,6 +3804,38 @@ channel_bctrl(struct bchannel *bch, struct mISDN_ctrl_req *cq)
 		else
 			ret = -EINVAL;
 		break;
+	case MISDN_CTRL_L1_TS0_MODE:
+		if (hc->ctype == HFC_TYPE_E1) {
+			v1 = hc->hw.r_rx_sl0_cfg0;
+			v2 = hc->hw.r_tx_sl0_cfg1;
+			if (cq->p1 > -1) {
+				hc->hw.r_rx_sl0_cfg0 = cq->p1 & 0xff;
+				HFC_outb(hc, R_RX_SL0_CFG0, cq->p1 & 0xff);
+				printk(KERN_DEBUG "RX_SL0_CFG0 = %x\n", cq->p1);
+			} else
+				printk(KERN_DEBUG "RX_SL0_CFG0 not modified\n");
+			if (cq->p2 > -1) {
+				hc->hw.r_tx_sl0_cfg1 = cq->p2 & 0xff;
+				HFC_outb(hc, R_TX_SL0_CFG1, cq->p2 & 0xff);
+				printk(KERN_DEBUG "TX_SL0_CFG1 = %x\n", cq->p2);
+			} else
+				printk(KERN_DEBUG "TX_SL0_CFG1 not modified\n");
+			cq->p1 = v1;
+			cq->p2 = v2;
+		} else {
+			printk(KERN_DEBUG "Not E1\n");
+			ret = -EINVAL;
+		}
+		break;
+	case MISDN_CTRL_L1_GET_SYNC_INFO:
+		cq->p1 = HFC_inb(hc, R_E1_RD_STA);
+		cq->p1 |= (HFC_inb(hc, R_SYNC_STA) << 8);
+		cq->p2 = HFC_inb(hc, R_RX_SL0_0);
+		cq->p2 |= (HFC_inb(hc, R_RX_SL0_1) << 8);
+		cq->p2 |= (HFC_inb(hc, R_RX_SL0_2) << 16);
+		cq->p3 = HFC_inb(hc, R_JATT_STA);
+		cq->p3 |= (HFC_inb(hc, R_SLIP) << 8);
+		break;
 	default:
 		printk(KERN_WARNING "%s: unknown Op %x\n",
 		       __func__, cq->op);
@@ -3776,6 +3910,12 @@ ph_state_change(struct dchannel *dch)
 		}
 		switch (dch->state) {
 		case (1):
+			if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip)) {
+				if (debug & DEBUG_HFCMULTI_STATE)
+					printk(KERN_DEBUG
+						"2 MBIT Raw state 1 reached\n");
+				break;
+			}
 			if (hc->e1_state != 1) {
 				for (i = 1; i <= 31; i++) {
 					/* reset fifos on e1 activation */
@@ -3874,6 +4014,113 @@ ph_state_change(struct dchannel *dch)
 	}
 }
 
+int init_2MBit_mode(struct hfc_multi *hc, int nr)
+{
+	u_char		r_e1_wr_sta;
+	int		pt;
+
+	if (debug & DEBUG_HFCMULTI_INIT)
+		printk(KERN_DEBUG "%s: ch%d entered\n", __func__, nr);
+
+	if (nr != 0) {
+		printk(KERN_ERR "Only ch0 supports 2MBit card%d\n", hc->id);
+		return -EINVAL;
+	}
+
+	pt = hc->chan[nr].port;
+	if (pt != 0) {
+		printk(KERN_ERR "Only port 0 in 2MBit mode %d\n", hc->id);
+		return -EINVAL;
+	}
+
+	hc->chan[nr].slot_tx = -1;
+	hc->chan[nr].slot_rx = -1;
+	hc->chan[nr].conf = -1;
+	mode_hfcmulti(hc, nr, ISDN_P_NONE, -1, 0, -1, 0);
+
+	if (test_bit(HFC_CFG_REPORT_LOS, &hc->chan[nr].cfg)) {
+		HFC_outb(hc, R_LOS0, 255); /* 2 ms */
+		HFC_outb(hc, R_LOS1, 255); /* 512 ms */
+	}
+	if (test_bit(HFC_CFG_OPTICAL, &hc->chan[nr].cfg)) {
+		HFC_outb(hc, R_RX0, 0);
+		hc->hw.r_tx0 = 0 | V_OUT_EN;
+	} else {
+		HFC_outb(hc, R_RX0, 1);
+		hc->hw.r_tx0 = 1 | V_OUT_EN;
+	}
+	hc->hw.r_tx1 = V_ATX | V_NTRI;
+	HFC_outb(hc, R_TX0, hc->hw.r_tx0);
+	HFC_outb(hc, R_TX1, hc->hw.r_tx1);
+	HFC_outb(hc, R_TX_SL0_CFG0, 0x00);
+	HFC_outb(hc, R_TX_SL0, 0xf8);
+
+	HFC_outb(hc, R_TX_SL0_CFG1, V_TX_MF | V_TX_E | V_NEG_E);
+	/* set transparent SL0 is set on ACTIVATE */
+	hc->hw.r_tx_sl0_cfg1 = V_TX_MF | V_TRP_SL0;
+
+	HFC_outb(hc, R_RX_SL0_CFG0, V_AUTO_RESYNC | V_AUTO_RECO | 0);
+
+	hc->hw.r_rx_sl0_cfg0 = 0x1;
+
+	if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dnum[0]].cfg))
+		HFC_outb(hc, R_RX_SL0_CFG1, V_RX_MF | V_RX_MF_SYNC);
+
+	/* Default TE mode and clock from interface */
+	r_e1_wr_sta = 1;
+	hc->e1_getclock = 1;
+	if (test_bit(HFC_CHIP_RX_SYNC, &hc->chip))
+		HFC_outb(hc, R_SYNC_OUT, V_SYNC_E1_RX);
+	else
+		HFC_outb(hc, R_SYNC_OUT, 0);
+
+	if (test_bit(HFC_CHIP_E1CLOCK_GET, &hc->chip))
+		hc->e1_getclock = 1;
+	if (test_bit(HFC_CHIP_E1CLOCK_PUT, &hc->chip))
+		hc->e1_getclock = 0;
+	if (test_bit(HFC_CHIP_PCM_SLAVE, &hc->chip)) {
+		/* SLAVE (clock master) */
+		if (debug & DEBUG_HFCMULTI_INIT)
+			printk(KERN_DEBUG
+			    "%s: E1 port is clock master (clock from PCM)\n",
+			    __func__);
+		HFC_outb(hc, R_SYNC_CTRL, V_EXT_CLK_SYNC | V_PCM_SYNC);
+	} else {
+		if (hc->e1_getclock) {
+			/* MASTER (clock slave) */
+			if (debug & DEBUG_HFCMULTI_INIT)
+				printk(KERN_DEBUG
+				       "%s: E1 port is clock slave (clock to PCM)\n",
+				       __func__);
+			HFC_outb(hc, R_SYNC_CTRL, 0);
+		} else {
+			/* MASTER (clock master) */
+			if (debug & DEBUG_HFCMULTI_INIT)
+				printk(KERN_DEBUG
+				       "%s: E1 port is clock master (clock from QUARTZ)\n",
+				       __func__);
+			HFC_outb(hc, R_SYNC_CTRL, V_EXT_CLK_SYNC |
+			    V_PCM_SYNC | V_JATT_OFF);
+			HFC_outb(hc, R_SYNC_OUT, 0);
+		}
+	}
+	HFC_outb(hc, R_JATT_CFG, 0x9c);
+	HFC_outb(hc, R_PWM_MD, V_PWM0_MD);
+	HFC_outb(hc, R_PWM0, 0x50);
+	HFC_outb(hc, R_PWM1, 0xff);
+
+	/* state machine setup */
+	HFC_outb(hc, R_E1_WR_STA, r_e1_wr_sta | V_E1_LD_STA);
+	udelay(10); /* wait at least 5,21us */
+	if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
+		hc->syncronized = 0;
+		plxsd_checksync(hc, 0);
+	}
+	if (debug & DEBUG_HFCMULTI_INIT)
+		printk("%s: done\n", __func__);
+	return 0;
+}
+
 /*
  * called for card mode init message
  */
@@ -3928,16 +4175,19 @@ hfcmulti_initmode(struct dchannel *dch)
 		hc->hw.r_tx1 = V_ATX | V_NTRI;
 		HFC_outb(hc, R_TX0, hc->hw.r_tx0);
 		HFC_outb(hc, R_TX1, hc->hw.r_tx1);
-		HFC_outb(hc, R_TX_FR0, 0x00);
-		HFC_outb(hc, R_TX_FR1, 0xf8);
+		HFC_outb(hc, R_TX_SL0_CFG0, 0x00);
+		HFC_outb(hc, R_TX_SL0, 0xf8);
 
-		if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dnum[0]].cfg))
-			HFC_outb(hc, R_TX_FR2, V_TX_MF | V_TX_E | V_NEG_E);
+		if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dnum[0]].cfg)) {
+			hc->hw.r_tx_sl0_cfg1 = V_TX_MF | V_TX_E | V_NEG_E;
+			HFC_outb(hc, R_TX_SL0_CFG1, hc->hw.r_tx_sl0_cfg1);
+		}
 
-		HFC_outb(hc, R_RX_FR0, V_AUTO_RESYNC | V_AUTO_RECO | 0);
+		hc->hw.r_rx_sl0_cfg0 = V_AUTO_RESYNC | V_AUTO_RECO;
+		HFC_outb(hc, R_RX_SL0_CFG0, hc->hw.r_rx_sl0_cfg0);
 
 		if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dnum[0]].cfg))
-			HFC_outb(hc, R_RX_FR1, V_RX_MF | V_RX_MF_SYNC);
+			HFC_outb(hc, R_RX_SL0_CFG1, V_RX_MF | V_RX_MF_SYNC);
 
 		if (dch->dev.D.protocol == ISDN_P_NT_E1) {
 			if (debug & DEBUG_HFCMULTI_INIT)
@@ -3987,7 +4237,7 @@ hfcmulti_initmode(struct dchannel *dch)
 				HFC_outb(hc, R_SYNC_OUT, 0);
 			}
 		}
-		HFC_outb(hc, R_JATT_ATT, 0x9c); /* undoc register */
+		HFC_outb(hc, R_JATT_CFG, 0x9c); /* undoc register */
 		HFC_outb(hc, R_PWM_MD, V_PWM0_MD);
 		HFC_outb(hc, R_PWM0, 0x50);
 		HFC_outb(hc, R_PWM1, 0xff);
@@ -4086,6 +4336,9 @@ open_dchannel(struct hfc_multi *hc, struct dchannel *dch,
 	if (debug & DEBUG_HW_OPEN)
 		printk(KERN_DEBUG "%s: dev(%d) open from %p\n", __func__,
 		       dch->dev.id, __builtin_return_address(0));
+	if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip) &&
+	    (hc->ctype == HFC_TYPE_E1)) /* No Dchannel in this mode */
+		return -EINVAL;
 	if (rq->protocol == ISDN_P_NONE)
 		return -EINVAL;
 	if ((dch->dev.D.protocol != ISDN_P_NONE) &&
@@ -4122,15 +4375,20 @@ open_bchannel(struct hfc_multi *hc, struct dchannel *dch,
 	      struct channel_req *rq)
 {
 	struct bchannel	*bch;
-	int		ch;
+	int		ret, ch;
 
 	if (!test_channelmap(rq->adr.channel, dch->dev.channelmap))
 		return -EINVAL;
 	if (rq->protocol == ISDN_P_NONE)
 		return -EINVAL;
-	if (hc->ctype == HFC_TYPE_E1)
+	if (hc->ctype == HFC_TYPE_E1) {
 		ch = rq->adr.channel;
-	else
+		if (test_bit(HFC_CHIP_2MBITRAW, &hc->chip)) {
+			ret = init_2MBit_mode(hc, ch);
+			if (ret)
+				return ret;
+		}
+	} else
 		ch = (rq->adr.channel - 1) + (dch->slot - 2);
 	bch = hc->chan[ch].bch;
 	if (!bch) {
@@ -4141,6 +4399,7 @@ open_bchannel(struct hfc_multi *hc, struct dchannel *dch,
 	if (test_and_set_bit(FLG_OPEN, &bch->Flags))
 		return -EBUSY; /* b-channel can be only open once */
 	test_and_clear_bit(FLG_FILLEMPTY, &bch->Flags);
+
 	bch->ch.protocol = rq->protocol;
 	hc->chan[ch].rx_off = 0;
 	rq->ch = &bch->ch;
@@ -4158,10 +4417,11 @@ channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 	struct hfc_multi	*hc = dch->hw;
 	int	ret = 0;
 	int	wd_mode, wd_cnt;
+	u_char	reg, reg1;
 
 	switch (cq->op) {
 	case MISDN_CTRL_GETOP:
-		cq->op = MISDN_CTRL_HFC_OP;
+		cq->op = MISDN_CTRL_HFC_OP | MISDN_CTRL_L1_TESTS;
 		break;
 	case MISDN_CTRL_HFC_WD_INIT: /* init the watchdog */
 		wd_cnt = cq->p1 & 0xf;
@@ -4191,6 +4451,42 @@ channel_dctrl(struct dchannel *dch, struct mISDN_ctrl_req *cq)
 			       __func__);
 		HFC_outb(hc, R_BERT_WD_MD, hc->hw.r_bert_wd_md | V_WD_RES);
 		break;
+	case MISDN_CTRL_L1_STATE_TEST:
+		if (hc->ctype == HFC_TYPE_E1) {
+			/* undocumented: status changes during read */
+			reg = HFC_inb_nodebug(hc, R_E1_RD_STA);
+			while (reg != (reg1 =
+				HFC_inb_nodebug(hc, R_E1_RD_STA))) {
+				if (debug & DEBUG_HFCMULTI_STATE)
+					printk(KERN_DEBUG
+					       "%s: reread STATE because %d!=%d\n",
+					       __func__, reg, reg1);
+				reg = reg1; /* repeat */
+			}
+			printk(KERN_DEBUG "Old L1 state %02x\n", reg);
+			reg &= 0x07;
+			if (cq->p1 < 0 || cq->p1 > 6) /* reset auto mode */
+				HFC_outb(hc, R_E1_WR_STA, reg);
+			else {/* force new state state */
+				reg = cq->p1 & 0x07;
+				HFC_outb(hc, R_E1_WR_STA, reg | V_E1_LD_STA);
+				printk(KERN_DEBUG "New L1 state %02x\n", reg);
+			}
+		} else
+			ret = -EINVAL;
+		break;
+	case MISDN_CTRL_L1_AIS_TEST:
+		if (hc->ctype == HFC_TYPE_E1) {
+			printk(KERN_DEBUG "Old AIS state %02x\n", hc->hw.r_tx1);
+			if (cq->p1)
+				hc->hw.r_tx1 |= V_AIS_OUT;
+			else
+				hc->hw.r_tx1 &= ~V_AIS_OUT;
+			HFC_outb(hc, R_TX1, hc->hw.r_tx1);
+			printk(KERN_DEBUG "New AIS state %02x\n", hc->hw.r_tx1);
+		} else
+			ret = -EINVAL;
+		break;
 	default:
 		printk(KERN_WARNING "%s: unknown Op %x\n",
 		       __func__, cq->op);
@@ -4843,7 +5139,18 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m, int pt)
 	dch->debug = debug;
 	mISDN_initdchannel(dch, MAX_DFRAME_LEN_L1, ph_state_change);
 	dch->hw = hc;
-	dch->dev.Dprotocols = (1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1);
+	if (port[Port_cnt] & 0x0002) {
+		if (debug & DEBUG_HFCMULTI_INIT)
+			printk(KERN_DEBUG
+			       "%s: PORT 2MBit raw mode E1: card(%d) port(%d)\n",
+			       __func__, HFC_cnt + 1, 1);
+		test_and_set_bit(HFC_CHIP_2MBITRAW, &hc->chip);
+		dch->dev.Dprotocols = (1 << ISDN_P_NONE);
+		hc->dnum[pt] = 0;
+		hc->bmask[pt] = 1;
+	} else
+		dch->dev.Dprotocols = (1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1);
+
 	dch->dev.Bprotocols = (1 << (ISDN_P_B_RAW & ISDN_P_B_MASK)) |
 	    (1 << (ISDN_P_B_HDLC & ISDN_P_B_MASK));
 	dch->dev.D.send = handle_dmsg;
@@ -4852,8 +5159,9 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m, int pt)
 	hc->chan[hc->dnum[pt]].dch = dch;
 	hc->chan[hc->dnum[pt]].port = pt;
 	hc->chan[hc->dnum[pt]].nt_timer = -1;
-	for (ch = 1; ch <= 31; ch++) {
-		if (!((1 << ch) & hc->bmask[pt])) /* skip unused channel */
+	for (ch = 0; ch <= 31; ch++) {
+		/* skip unused channel */
+		if (!((1 << ch) & hc->bmask[pt]))
 			continue;
 		bch = kzalloc(sizeof(struct bchannel), GFP_KERNEL);
 		if (!bch) {
diff --git a/include/linux/mISDNif.h b/include/linux/mISDNif.h
index f474f40..850fe1f 100644
--- a/include/linux/mISDNif.h
+++ b/include/linux/mISDNif.h
@@ -37,7 +37,7 @@
  */
 #define	MISDN_MAJOR_VERSION	1
 #define	MISDN_MINOR_VERSION	1
-#define MISDN_RELEASE		28
+#define MISDN_RELEASE		29
 
 /* primitives for information exchange
  * generell format
@@ -363,31 +363,36 @@ clear_channelmap(u_int nr, u_char *map)
 }
 
 /* CONTROL_CHANNEL parameters */
-#define MISDN_CTRL_GETOP		0x0000
-#define MISDN_CTRL_LOOP			0x0001
-#define MISDN_CTRL_CONNECT		0x0002
-#define MISDN_CTRL_DISCONNECT		0x0004
-#define MISDN_CTRL_GET_PCM_SLOTS	0x0010
-#define MISDN_CTRL_SET_PCM_SLOTS	0x0020
-#define MISDN_CTRL_SETPEER		0x0040
-#define MISDN_CTRL_UNSETPEER		0x0080
-#define MISDN_CTRL_RX_OFF		0x0100
-#define MISDN_CTRL_FILL_EMPTY		0x0200
-#define MISDN_CTRL_GETPEER		0x0400
-#define MISDN_CTRL_L1_TIMER3		0x0800
-#define MISDN_CTRL_HW_FEATURES_OP	0x2000
-#define MISDN_CTRL_HW_FEATURES		0x2001
-#define MISDN_CTRL_HFC_OP		0x4000
-#define MISDN_CTRL_HFC_PCM_CONN		0x4001
-#define MISDN_CTRL_HFC_PCM_DISC		0x4002
-#define MISDN_CTRL_HFC_CONF_JOIN	0x4003
-#define MISDN_CTRL_HFC_CONF_SPLIT	0x4004
-#define MISDN_CTRL_HFC_RECEIVE_OFF	0x4005
-#define MISDN_CTRL_HFC_RECEIVE_ON	0x4006
-#define MISDN_CTRL_HFC_ECHOCAN_ON 	0x4007
-#define MISDN_CTRL_HFC_ECHOCAN_OFF 	0x4008
-#define MISDN_CTRL_HFC_WD_INIT		0x4009
-#define MISDN_CTRL_HFC_WD_RESET		0x400A
+#define MISDN_CTRL_GETOP		0x00000000
+#define MISDN_CTRL_LOOP			0x00000001
+#define MISDN_CTRL_CONNECT		0x00000002
+#define MISDN_CTRL_DISCONNECT		0x00000004
+#define MISDN_CTRL_GET_PCM_SLOTS	0x00000010
+#define MISDN_CTRL_SET_PCM_SLOTS	0x00000020
+#define MISDN_CTRL_SETPEER		0x00000040
+#define MISDN_CTRL_UNSETPEER		0x00000080
+#define MISDN_CTRL_RX_OFF		0x00000100
+#define MISDN_CTRL_FILL_EMPTY		0x00000200
+#define MISDN_CTRL_GETPEER		0x00000400
+#define MISDN_CTRL_L1_TIMER3		0x00000800
+#define MISDN_CTRL_HW_FEATURES_OP	0x00002000
+#define MISDN_CTRL_HW_FEATURES		0x00002001
+#define MISDN_CTRL_HFC_OP		0x00004000
+#define MISDN_CTRL_HFC_PCM_CONN		0x00004001
+#define MISDN_CTRL_HFC_PCM_DISC		0x00004002
+#define MISDN_CTRL_HFC_CONF_JOIN	0x00004003
+#define MISDN_CTRL_HFC_CONF_SPLIT	0x00004004
+#define MISDN_CTRL_HFC_RECEIVE_OFF	0x00004005
+#define MISDN_CTRL_HFC_RECEIVE_ON	0x00004006
+#define MISDN_CTRL_HFC_ECHOCAN_ON	0x00004007
+#define MISDN_CTRL_HFC_ECHOCAN_OFF	0x00004008
+#define MISDN_CTRL_HFC_WD_INIT		0x00004009
+#define MISDN_CTRL_HFC_WD_RESET		0x0000400A
+#define MISDN_CTRL_L1_TESTS		0x00010000
+#define MISDN_CTRL_L1_STATE_TEST	0x00010001
+#define MISDN_CTRL_L1_AIS_TEST		0x00010002
+#define MISDN_CTRL_L1_TS0_MODE		0x00010003
+#define MISDN_CTRL_L1_GET_SYNC_INFO	0x00010004
 
 /* special PCM slot numbers */
 #define MISDN_PCM_SLOT_DISABLE	-1	/* PCM disabled */
-- 
1.7.3.4
