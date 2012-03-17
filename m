From: Karsten Keil <isdn@linux-pingi.de>
Subject: [PATCH 07/28] mISDN: Added support for fragmentation of E1 interfaces of hfcmulti driver.
Date: Sat, 17 Mar 2012 11:01:12 +0100
Message-ID: <20120423170549.D5C099FB78@pingi6.linux-pingi.de>
Cc: netdev@vger.kernel.org, isdn4linux@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.10]:52841 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754192Ab2DWRIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 13:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <jolly@eversberg.eu>

Fragmentation is usefull if multiple devices are connected to an E1
interface. Each fragment will have a subset of the available timeslots.
These devices require a cascde connection or a multiplexer.

Signed-off-by: Andreas Eversberg <jolly@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hardware/mISDN/hfc_multi.h |    6 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c  |  396 ++++++++++++++++++-------------
 2 files changed, 236 insertions(+), 166 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfc_multi.h b/drivers/isdn/hardware/mISDN/hfc_multi.h
index 09e4e77..c601f88 100644
--- a/drivers/isdn/hardware/mISDN/hfc_multi.h
+++ b/drivers/isdn/hardware/mISDN/hfc_multi.h
@@ -208,7 +208,10 @@ struct hfc_multi {
 	u_long		ledstate; /* save last state of leds */
 	int		opticalsupport; /* has the e1 board */
 					/* an optical Interface */
-	int		dslot;	/* channel # of d-channel (E1) default 16 */
+
+	u_int		bmask[32]; /* bitmask of bchannels for port */
+	u_char		dnum[32]; /* array of used dchannel numbers for port */
+	u_char		created[32]; /* what port is created */
 	u_int		activity_tx; /* if there is data TX / RX */
 	u_int		activity_rx; /* bitmask according to port number */
 				     /* (will be cleared after */
@@ -234,7 +237,6 @@ struct hfc_multi {
 	 * the bch->channel is equvalent to the hfc-channel
 	 */
 	struct hfc_chan	chan[32];
-	u_char		created[8]; /* what port is created */
 	signed char	slot_owner[256]; /* owner channel of slot */
 };
 
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 876f7d0..4301331 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -103,14 +103,26 @@
  *	Omit this value, if all cards are interconnected or none is connected.
  *	If unsure, don't give this parameter.
  *
- * dslot:
- *	NOTE: only one dslot value must be given for every card.
- *	Also this value must be given for non-E1 cards. If omitted, the E1
- *	card has D-channel on time slot 16, which is default.
- *	If 1..15 or 17..31, an alternate time slot is used for D-channel.
- *	In this case, the application must be able to handle this.
- *	If -1 is given, the D-channel is disabled and all 31 slots can be used
- *	for B-channel. (only for specific applications)
+ * dmask and bmask:
+ *	NOTE: One dmask value must be given for every HFC-E1 card.
+ *	If omitted, the E1 card has D-channel on time slot 16, which is default.
+ *	dmask is a 32 bit mask. The bit must be set for an alternate time slot.
+ *	If multiple bits are set, multiple virtual card fragments are created.
+ *	For each bit set, a bmask value must be given. Each bit on the bmask
+ *	value stands for a B-channel. The bmask may not overlap with dmask or
+ *	with other bmask values for that card.
+ *	Example: dmask=0x00020002 bmask=0x0000fffc,0xfffc0000
+ *		This will create one fragment with D-channel on slot 1 with
+ *		B-channels on slots 2..15, and a second fragment with D-channel
+ *		on slot 17 with B-channels on slot 18..31. Slot 16 is unused.
+ *	If bit 0 is set (dmask=0x00000001) the D-channel is on slot 0 and will
+ *	not function.
+ *	Example: dmask=0x00000001 bmask=0xfffffffe
+ *		This will create a port with all 31 usable timeslots as
+ *		B-channels.
+ *	If no bits are set on bmask, no B-channel is created for that fragment.
+ *	Example: dmask=0xfffffffe bmask=0,0,0,0.... (31 0-values for bmask)
+ *		This will create 31 ports with one D-channel only.
  *	If you don't know how to use it, you don't need it!
  *
  * iomode:
@@ -172,6 +184,7 @@
 
 #define	MAX_CARDS	8
 #define	MAX_PORTS	(8 * MAX_CARDS)
+#define	MAX_FRAGS	(32 * MAX_CARDS)
 
 static LIST_HEAD(HFClist);
 static spinlock_t HFClock; /* global hfc list lock */
@@ -203,7 +216,8 @@ static int nt_t1_count[] = { 3840, 1920, 960, 480, 240, 120, 60, 30  };
 
 static uint	type[MAX_CARDS];
 static int	pcm[MAX_CARDS];
-static int	dslot[MAX_CARDS];
+static uint	dmask[MAX_CARDS];
+static uint	bmask[MAX_FRAGS];
 static uint	iomode[MAX_CARDS];
 static uint	port[MAX_PORTS];
 static uint	debug;
@@ -218,7 +232,7 @@ static uint	clockdelay_nt = CLKDEL_NT;
 #define HWID_MINIP16	3
 static uint	hwid = HWID_NONE;
 
-static int	HFC_cnt, Port_cnt, PCM_cnt = 99;
+static int	HFC_cnt, E1_cnt, bmask_cnt, Port_cnt, PCM_cnt = 99;
 
 MODULE_AUTHOR("Andreas Eversberg");
 MODULE_LICENSE("GPL");
@@ -231,7 +245,8 @@ module_param(clockdelay_te, uint, S_IRUGO | S_IWUSR);
 module_param(clockdelay_nt, uint, S_IRUGO | S_IWUSR);
 module_param_array(type, uint, NULL, S_IRUGO | S_IWUSR);
 module_param_array(pcm, int, NULL, S_IRUGO | S_IWUSR);
-module_param_array(dslot, int, NULL, S_IRUGO | S_IWUSR);
+module_param_array(dmask, uint, NULL, S_IRUGO | S_IWUSR);
+module_param_array(bmask, uint, NULL, S_IRUGO | S_IWUSR);
 module_param_array(iomode, uint, NULL, S_IRUGO | S_IWUSR);
 module_param_array(port, uint, NULL, S_IRUGO | S_IWUSR);
 module_param(hwid, uint, S_IRUGO | S_IWUSR); /* The hardware ID */
@@ -1619,9 +1634,9 @@ hfcmulti_leds(struct hfc_multi *hc)
 		led[1] = 0;
 		led[2] = 0;
 		led[3] = 0;
-		dch = hc->chan[hc->dslot].dch;
+		dch = hc->chan[hc->dnum[0]].dch;
 		if (dch) {
-			if (hc->chan[hc->dslot].los)
+			if (hc->chan[hc->dnum[0]].los)
 				led[1] = 1;
 			if (hc->e1_state != 1) {
 				led[0] = 1;
@@ -2453,55 +2468,55 @@ handle_timer_irq(struct hfc_multi *hc)
 			}
 		}
 	if (hc->ctype == HFC_TYPE_E1 && hc->created[0]) {
-		dch = hc->chan[hc->dslot].dch;
-		if (test_bit(HFC_CFG_REPORT_LOS, &hc->chan[hc->dslot].cfg)) {
-			/* LOS */
-			temp = HFC_inb_nodebug(hc, R_SYNC_STA) & V_SIG_LOS;
-			if (!temp && hc->chan[hc->dslot].los)
+		dch = hc->chan[hc->dnum[0]].dch;
+		/* LOS */
+		temp = HFC_inb_nodebug(hc, R_SYNC_STA) & V_SIG_LOS;
+		hc->chan[hc->dnum[0]].los = temp;
+		if (test_bit(HFC_CFG_REPORT_LOS, &hc->chan[hc->dnum[0]].cfg)) {
+			if (!temp && hc->chan[hc->dnum[0]].los)
 				signal_state_up(dch, L1_SIGNAL_LOS_ON,
 						"LOS detected");
-			if (temp && !hc->chan[hc->dslot].los)
+			if (temp && !hc->chan[hc->dnum[0]].los)
 				signal_state_up(dch, L1_SIGNAL_LOS_OFF,
 						"LOS gone");
-			hc->chan[hc->dslot].los = temp;
 		}
-		if (test_bit(HFC_CFG_REPORT_AIS, &hc->chan[hc->dslot].cfg)) {
+		if (test_bit(HFC_CFG_REPORT_AIS, &hc->chan[hc->dnum[0]].cfg)) {
 			/* AIS */
 			temp = HFC_inb_nodebug(hc, R_SYNC_STA) & V_AIS;
-			if (!temp && hc->chan[hc->dslot].ais)
+			if (!temp && hc->chan[hc->dnum[0]].ais)
 				signal_state_up(dch, L1_SIGNAL_AIS_ON,
 						"AIS detected");
-			if (temp && !hc->chan[hc->dslot].ais)
+			if (temp && !hc->chan[hc->dnum[0]].ais)
 				signal_state_up(dch, L1_SIGNAL_AIS_OFF,
 						"AIS gone");
-			hc->chan[hc->dslot].ais = temp;
+			hc->chan[hc->dnum[0]].ais = temp;
 		}
-		if (test_bit(HFC_CFG_REPORT_SLIP, &hc->chan[hc->dslot].cfg)) {
+		if (test_bit(HFC_CFG_REPORT_SLIP, &hc->chan[hc->dnum[0]].cfg)) {
 			/* SLIP */
 			temp = HFC_inb_nodebug(hc, R_SLIP) & V_FOSLIP_RX;
-			if (!temp && hc->chan[hc->dslot].slip_rx)
+			if (!temp && hc->chan[hc->dnum[0]].slip_rx)
 				signal_state_up(dch, L1_SIGNAL_SLIP_RX,
 						" bit SLIP detected RX");
-			hc->chan[hc->dslot].slip_rx = temp;
+			hc->chan[hc->dnum[0]].slip_rx = temp;
 			temp = HFC_inb_nodebug(hc, R_SLIP) & V_FOSLIP_TX;
-			if (!temp && hc->chan[hc->dslot].slip_tx)
+			if (!temp && hc->chan[hc->dnum[0]].slip_tx)
 				signal_state_up(dch, L1_SIGNAL_SLIP_TX,
 						" bit SLIP detected TX");
-			hc->chan[hc->dslot].slip_tx = temp;
+			hc->chan[hc->dnum[0]].slip_tx = temp;
 		}
-		if (test_bit(HFC_CFG_REPORT_RDI, &hc->chan[hc->dslot].cfg)) {
+		if (test_bit(HFC_CFG_REPORT_RDI, &hc->chan[hc->dnum[0]].cfg)) {
 			/* RDI */
 			temp = HFC_inb_nodebug(hc, R_RX_SL0_0) & V_A;
-			if (!temp && hc->chan[hc->dslot].rdi)
+			if (!temp && hc->chan[hc->dnum[0]].rdi)
 				signal_state_up(dch, L1_SIGNAL_RDI_ON,
 						"RDI detected");
-			if (temp && !hc->chan[hc->dslot].rdi)
+			if (temp && !hc->chan[hc->dnum[0]].rdi)
 				signal_state_up(dch, L1_SIGNAL_RDI_OFF,
 						"RDI gone");
-			hc->chan[hc->dslot].rdi = temp;
+			hc->chan[hc->dnum[0]].rdi = temp;
 		}
 		temp = HFC_inb_nodebug(hc, R_JATT_DIR);
-		switch (hc->chan[hc->dslot].sync) {
+		switch (hc->chan[hc->dnum[0]].sync) {
 		case 0:
 			if ((temp & 0x60) == 0x60) {
 				if (debug & DEBUG_HFCMULTI_SYNC)
@@ -2510,10 +2525,10 @@ handle_timer_irq(struct hfc_multi *hc)
 					       "in clock sync\n",
 					       __func__, hc->id);
 				HFC_outb(hc, R_RX_OFF,
-					 hc->chan[hc->dslot].jitter | V_RX_INIT);
+				    hc->chan[hc->dnum[0]].jitter | V_RX_INIT);
 				HFC_outb(hc, R_TX_OFF,
-					 hc->chan[hc->dslot].jitter | V_RX_INIT);
-				hc->chan[hc->dslot].sync = 1;
+				    hc->chan[hc->dnum[0]].jitter | V_RX_INIT);
+				hc->chan[hc->dnum[0]].sync = 1;
 				goto check_framesync;
 			}
 			break;
@@ -2524,7 +2539,7 @@ handle_timer_irq(struct hfc_multi *hc)
 					       "%s: (id=%d) E1 "
 					       "lost clock sync\n",
 					       __func__, hc->id);
-				hc->chan[hc->dslot].sync = 0;
+				hc->chan[hc->dnum[0]].sync = 0;
 				break;
 			}
 		check_framesync:
@@ -2535,7 +2550,7 @@ handle_timer_irq(struct hfc_multi *hc)
 					       "%s: (id=%d) E1 "
 					       "now in frame sync\n",
 					       __func__, hc->id);
-				hc->chan[hc->dslot].sync = 2;
+				hc->chan[hc->dnum[0]].sync = 2;
 			}
 			break;
 		case 2:
@@ -2545,7 +2560,7 @@ handle_timer_irq(struct hfc_multi *hc)
 					       "%s: (id=%d) E1 lost "
 					       "clock & frame sync\n",
 					       __func__, hc->id);
-				hc->chan[hc->dslot].sync = 0;
+				hc->chan[hc->dnum[0]].sync = 0;
 				break;
 			}
 			temp = HFC_inb_nodebug(hc, R_SYNC_STA);
@@ -2555,7 +2570,7 @@ handle_timer_irq(struct hfc_multi *hc)
 					       "%s: (id=%d) E1 "
 					       "lost frame sync\n",
 					       __func__, hc->id);
-				hc->chan[hc->dslot].sync = 1;
+				hc->chan[hc->dnum[0]].sync = 1;
 			}
 			break;
 		}
@@ -2696,7 +2711,7 @@ hfcmulti_interrupt(int intno, void *dev_id)
 	int			i;
 	void __iomem		*plx_acc;
 	u_short			wval;
-	u_char			e1_syncsta, temp;
+	u_char			e1_syncsta, temp, temp2;
 	u_long			flags;
 
 	if (!hc) {
@@ -2771,7 +2786,7 @@ hfcmulti_interrupt(int intno, void *dev_id)
 		if (r_irq_misc & V_STA_IRQ) {
 			if (hc->ctype == HFC_TYPE_E1) {
 				/* state machine */
-				dch = hc->chan[hc->dslot].dch;
+				dch = hc->chan[hc->dnum[0]].dch;
 				e1_syncsta = HFC_inb_nodebug(hc, R_SYNC_STA);
 				if (test_bit(HFC_CHIP_PLXSD, &hc->chip)
 				    && hc->e1_getclock) {
@@ -2781,23 +2796,26 @@ hfcmulti_interrupt(int intno, void *dev_id)
 						hc->syncronized = 0;
 				}
 				/* undocumented: status changes during read */
-				dch->state = HFC_inb_nodebug(hc, R_E1_RD_STA);
-				while (dch->state != (temp =
+				temp = HFC_inb_nodebug(hc, R_E1_RD_STA);
+				while (temp != (temp2 =
 						      HFC_inb_nodebug(hc, R_E1_RD_STA))) {
 					if (debug & DEBUG_HFCMULTI_STATE)
 						printk(KERN_DEBUG "%s: reread "
 						       "STATE because %d!=%d\n",
-						       __func__, temp,
-						       dch->state);
-					dch->state = temp; /* repeat */
+						    __func__, temp, temp2);
+					temp = temp2; /* repeat */
 				}
-				dch->state = HFC_inb_nodebug(hc, R_E1_RD_STA)
-					& 0x7;
-				schedule_event(dch, FLG_PHCHANGE);
+				/* broadcast state change to all fragments */
 				if (debug & DEBUG_HFCMULTI_STATE)
 					printk(KERN_DEBUG
 					       "%s: E1 (id=%d) newstate %x\n",
-					       __func__, hc->id, dch->state);
+					    __func__, hc->id, temp & 0x7);
+				for (i = 0; i < hc->ports; i++) {
+					dch = hc->chan[hc->dnum[i]].dch;
+					dch->state = temp & 0x7;
+					schedule_event(dch, FLG_PHCHANGE);
+				}
+
 				if (test_bit(HFC_CHIP_PLXSD, &hc->chip))
 					plxsd_checksync(hc, 0);
 			}
@@ -3870,31 +3888,37 @@ hfcmulti_initmode(struct dchannel *dch)
 	if (debug & DEBUG_HFCMULTI_INIT)
 		printk(KERN_DEBUG "%s: entered\n", __func__);
 
+	i = dch->slot;
+	pt = hc->chan[i].port;
 	if (hc->ctype == HFC_TYPE_E1) {
-		hc->chan[hc->dslot].slot_tx = -1;
-		hc->chan[hc->dslot].slot_rx = -1;
-		hc->chan[hc->dslot].conf = -1;
-		if (hc->dslot) {
-			mode_hfcmulti(hc, hc->dslot, dch->dev.D.protocol,
+		/* E1 */
+		hc->chan[hc->dnum[pt]].slot_tx = -1;
+		hc->chan[hc->dnum[pt]].slot_rx = -1;
+		hc->chan[hc->dnum[pt]].conf = -1;
+		if (hc->dnum[pt]) {
+			mode_hfcmulti(hc, dch->slot, dch->dev.D.protocol,
 				      -1, 0, -1, 0);
 			dch->timer.function = (void *) hfcmulti_dbusy_timer;
 			dch->timer.data = (long) dch;
 			init_timer(&dch->timer);
 		}
 		for (i = 1; i <= 31; i++) {
-			if (i == hc->dslot)
+			if (!((1 << i) & hc->bmask[pt])) /* skip unused chan */
 				continue;
 			hc->chan[i].slot_tx = -1;
 			hc->chan[i].slot_rx = -1;
 			hc->chan[i].conf = -1;
 			mode_hfcmulti(hc, i, ISDN_P_NONE, -1, 0, -1, 0);
 		}
-		/* E1 */
-		if (test_bit(HFC_CFG_REPORT_LOS, &hc->chan[hc->dslot].cfg)) {
+	}
+	if (hc->ctype == HFC_TYPE_E1 && pt == 0) {
+		/* E1, port 0 */
+		dch = hc->chan[hc->dnum[0]].dch;
+		if (test_bit(HFC_CFG_REPORT_LOS, &hc->chan[hc->dnum[0]].cfg)) {
 			HFC_outb(hc, R_LOS0, 255); /* 2 ms */
 			HFC_outb(hc, R_LOS1, 255); /* 512 ms */
 		}
-		if (test_bit(HFC_CFG_OPTICAL, &hc->chan[hc->dslot].cfg)) {
+		if (test_bit(HFC_CFG_OPTICAL, &hc->chan[hc->dnum[0]].cfg)) {
 			HFC_outb(hc, R_RX0, 0);
 			hc->hw.r_tx0 = 0 | V_OUT_EN;
 		} else {
@@ -3907,12 +3931,12 @@ hfcmulti_initmode(struct dchannel *dch)
 		HFC_outb(hc, R_TX_FR0, 0x00);
 		HFC_outb(hc, R_TX_FR1, 0xf8);
 
-		if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dslot].cfg))
+		if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dnum[0]].cfg))
 			HFC_outb(hc, R_TX_FR2, V_TX_MF | V_TX_E | V_NEG_E);
 
 		HFC_outb(hc, R_RX_FR0, V_AUTO_RESYNC | V_AUTO_RECO | 0);
 
-		if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dslot].cfg))
+		if (test_bit(HFC_CFG_CRC4, &hc->chan[hc->dnum[0]].cfg))
 			HFC_outb(hc, R_RX_FR1, V_RX_MF | V_RX_MF_SYNC);
 
 		if (dch->dev.D.protocol == ISDN_P_NT_E1) {
@@ -3975,13 +3999,14 @@ hfcmulti_initmode(struct dchannel *dch)
 			hc->syncronized = 0;
 			plxsd_checksync(hc, 0);
 		}
-	} else {
-		i = dch->slot;
+	}
+	if (hc->ctype != HFC_TYPE_E1) {
+		/* ST */
 		hc->chan[i].slot_tx = -1;
 		hc->chan[i].slot_rx = -1;
 		hc->chan[i].conf = -1;
 		mode_hfcmulti(hc, i, dch->dev.D.protocol, -1, 0, -1, 0);
-		dch->timer.function = (void *)hfcmulti_dbusy_timer;
+		dch->timer.function = (void *) hfcmulti_dbusy_timer;
 		dch->timer.data = (long) dch;
 		init_timer(&dch->timer);
 		hc->chan[i - 2].slot_tx = -1;
@@ -3992,8 +4017,6 @@ hfcmulti_initmode(struct dchannel *dch)
 		hc->chan[i - 1].slot_rx = -1;
 		hc->chan[i - 1].conf = -1;
 		mode_hfcmulti(hc, i - 1, ISDN_P_NONE, -1, 0, -1, 0);
-		/* ST */
-		pt = hc->chan[i].port;
 		/* select interface */
 		HFC_outb(hc, R_ST_SEL, pt);
 		/* undocumented: delay after R_ST_SEL */
@@ -4571,6 +4594,8 @@ release_port(struct hfc_multi *hc, struct dchannel *dch)
 		}
 		/* free channels */
 		for (i = 0; i <= 31; i++) {
+			if (!((1 << i) & hc->bmask[pt])) /* skip unused chan */
+				continue;
 			if (hc->chan[i].bch) {
 				if (debug & DEBUG_HFCMULTI_INIT)
 					printk(KERN_DEBUG
@@ -4626,7 +4651,8 @@ release_port(struct hfc_multi *hc, struct dchannel *dch)
 	spin_unlock_irqrestore(&hc->lock, flags);
 
 	if (debug & DEBUG_HFCMULTI_INIT)
-		printk(KERN_DEBUG "%s: free port %d channel D\n", __func__, pt);
+		printk(KERN_DEBUG "%s: free port %d channel D(%d)\n", __func__,
+			pt+1, ci);
 	mISDN_freedchannel(dch);
 	kfree(dch);
 
@@ -4648,15 +4674,19 @@ release_card(struct hfc_multi *hc)
 	if (hc->iclock)
 		mISDN_unregister_clock(hc->iclock);
 
-	/* disable irq */
+	/* disable and free irq */
 	spin_lock_irqsave(&hc->lock, flags);
 	disable_hwirq(hc);
 	spin_unlock_irqrestore(&hc->lock, flags);
 	udelay(1000);
+	if (hc->irq) {
+		if (debug & DEBUG_HFCMULTI_INIT)
+			printk(KERN_DEBUG "%s: free irq %d (hc=%p)\n",
+			    __func__, hc->irq, hc);
+		free_irq(hc->irq, hc);
+		hc->irq = 0;
 
-	/* dimm leds */
-	if (hc->leds)
-		hfcmulti_leds(hc);
+	}
 
 	/* disable D-channels & B-channels */
 	if (debug & DEBUG_HFCMULTI_INIT)
@@ -4667,15 +4697,11 @@ release_card(struct hfc_multi *hc)
 			release_port(hc, hc->chan[ch].dch);
 	}
 
-	/* release hardware & irq */
-	if (hc->irq) {
-		if (debug & DEBUG_HFCMULTI_INIT)
-			printk(KERN_DEBUG "%s: free irq %d\n",
-			       __func__, hc->irq);
-		free_irq(hc->irq, hc);
-		hc->irq = 0;
+	/* dimm leds */
+	if (hc->leds)
+		hfcmulti_leds(hc);
 
-	}
+	/* release hardware */
 	release_io_hfcmulti(hc);
 
 	if (debug & DEBUG_HFCMULTI_INIT)
@@ -4693,61 +4719,9 @@ release_card(struct hfc_multi *hc)
 		       __func__);
 }
 
-static int
-init_e1_port(struct hfc_multi *hc, struct hm_map *m)
+static void
+init_e1_port_hw(struct hfc_multi *hc, struct hm_map *m)
 {
-	struct dchannel	*dch;
-	struct bchannel	*bch;
-	int		ch, ret = 0;
-	char		name[MISDN_MAX_IDLEN];
-
-	dch = kzalloc(sizeof(struct dchannel), GFP_KERNEL);
-	if (!dch)
-		return -ENOMEM;
-	dch->debug = debug;
-	mISDN_initdchannel(dch, MAX_DFRAME_LEN_L1, ph_state_change);
-	dch->hw = hc;
-	dch->dev.Dprotocols = (1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1);
-	dch->dev.Bprotocols = (1 << (ISDN_P_B_RAW & ISDN_P_B_MASK)) |
-		(1 << (ISDN_P_B_HDLC & ISDN_P_B_MASK));
-	dch->dev.D.send = handle_dmsg;
-	dch->dev.D.ctrl = hfcm_dctrl;
-	dch->dev.nrbchan = (hc->dslot) ? 30 : 31;
-	dch->slot = hc->dslot;
-	hc->chan[hc->dslot].dch = dch;
-	hc->chan[hc->dslot].port = 0;
-	hc->chan[hc->dslot].nt_timer = -1;
-	for (ch = 1; ch <= 31; ch++) {
-		if (ch == hc->dslot) /* skip dchannel */
-			continue;
-		bch = kzalloc(sizeof(struct bchannel), GFP_KERNEL);
-		if (!bch) {
-			printk(KERN_ERR "%s: no memory for bchannel\n",
-			       __func__);
-			ret = -ENOMEM;
-			goto free_chan;
-		}
-		hc->chan[ch].coeff = kzalloc(512, GFP_KERNEL);
-		if (!hc->chan[ch].coeff) {
-			printk(KERN_ERR "%s: no memory for coeffs\n",
-			       __func__);
-			ret = -ENOMEM;
-			kfree(bch);
-			goto free_chan;
-		}
-		bch->nr = ch;
-		bch->slot = ch;
-		bch->debug = debug;
-		mISDN_initbchannel(bch, MAX_DATA_MEM);
-		bch->hw = hc;
-		bch->ch.send = handle_bmsg;
-		bch->ch.ctrl = hfcm_bctrl;
-		bch->ch.nr = ch;
-		list_add(&bch->ch.list, &dch->dev.bchannels);
-		hc->chan[ch].bch = bch;
-		hc->chan[ch].port = 0;
-		set_channelmap(bch->nr, dch->dev.channelmap);
-	}
 	/* set optical line type */
 	if (port[Port_cnt] & 0x001) {
 		if (!m->opticalsupport)  {
@@ -4763,7 +4737,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 				       __func__,
 				       HFC_cnt + 1, 1);
 			test_and_set_bit(HFC_CFG_OPTICAL,
-					 &hc->chan[hc->dslot].cfg);
+			    &hc->chan[hc->dnum[0]].cfg);
 		}
 	}
 	/* set LOS report */
@@ -4773,7 +4747,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 			       "LOS report: card(%d) port(%d)\n",
 			       __func__, HFC_cnt + 1, 1);
 		test_and_set_bit(HFC_CFG_REPORT_LOS,
-				 &hc->chan[hc->dslot].cfg);
+		    &hc->chan[hc->dnum[0]].cfg);
 	}
 	/* set AIS report */
 	if (port[Port_cnt] & 0x008) {
@@ -4782,7 +4756,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 			       "AIS report: card(%d) port(%d)\n",
 			       __func__, HFC_cnt + 1, 1);
 		test_and_set_bit(HFC_CFG_REPORT_AIS,
-				 &hc->chan[hc->dslot].cfg);
+		    &hc->chan[hc->dnum[0]].cfg);
 	}
 	/* set SLIP report */
 	if (port[Port_cnt] & 0x010) {
@@ -4792,7 +4766,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 			       "card(%d) port(%d)\n",
 			       __func__, HFC_cnt + 1, 1);
 		test_and_set_bit(HFC_CFG_REPORT_SLIP,
-				 &hc->chan[hc->dslot].cfg);
+		    &hc->chan[hc->dnum[0]].cfg);
 	}
 	/* set RDI report */
 	if (port[Port_cnt] & 0x020) {
@@ -4802,7 +4776,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 			       "card(%d) port(%d)\n",
 			       __func__, HFC_cnt + 1, 1);
 		test_and_set_bit(HFC_CFG_REPORT_RDI,
-				 &hc->chan[hc->dslot].cfg);
+		    &hc->chan[hc->dnum[0]].cfg);
 	}
 	/* set CRC-4 Mode */
 	if (!(port[Port_cnt] & 0x100)) {
@@ -4811,7 +4785,7 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 			       " card(%d) port(%d)\n",
 			       __func__, HFC_cnt + 1, 1);
 		test_and_set_bit(HFC_CFG_CRC4,
-				 &hc->chan[hc->dslot].cfg);
+		    &hc->chan[hc->dnum[0]].cfg);
 	} else {
 		if (debug & DEBUG_HFCMULTI_INIT)
 			printk(KERN_DEBUG "%s: PORT turn off CRC4"
@@ -4843,20 +4817,85 @@ init_e1_port(struct hfc_multi *hc, struct hm_map *m)
 	}
 	/* set elastic jitter buffer */
 	if (port[Port_cnt] & 0x3000) {
-		hc->chan[hc->dslot].jitter = (port[Port_cnt]>>12) & 0x3;
+		hc->chan[hc->dnum[0]].jitter = (port[Port_cnt]>>12) & 0x3;
 		if (debug & DEBUG_HFCMULTI_INIT)
 			printk(KERN_DEBUG
 			       "%s: PORT set elastic "
 			       "buffer to %d: card(%d) port(%d)\n",
-			       __func__, hc->chan[hc->dslot].jitter,
+			    __func__, hc->chan[hc->dnum[0]].jitter,
 			       HFC_cnt + 1, 1);
 	} else
-		hc->chan[hc->dslot].jitter = 2; /* default */
-	snprintf(name, MISDN_MAX_IDLEN - 1, "hfc-e1.%d", HFC_cnt + 1);
+		hc->chan[hc->dnum[0]].jitter = 2; /* default */
+}
+
+static int
+init_e1_port(struct hfc_multi *hc, struct hm_map *m, int pt)
+{
+	struct dchannel	*dch;
+	struct bchannel	*bch;
+	int		ch, ret = 0;
+	char		name[MISDN_MAX_IDLEN];
+	int		bcount = 0;
+
+	dch = kzalloc(sizeof(struct dchannel), GFP_KERNEL);
+	if (!dch)
+		return -ENOMEM;
+	dch->debug = debug;
+	mISDN_initdchannel(dch, MAX_DFRAME_LEN_L1, ph_state_change);
+	dch->hw = hc;
+	dch->dev.Dprotocols = (1 << ISDN_P_TE_E1) | (1 << ISDN_P_NT_E1);
+	dch->dev.Bprotocols = (1 << (ISDN_P_B_RAW & ISDN_P_B_MASK)) |
+	    (1 << (ISDN_P_B_HDLC & ISDN_P_B_MASK));
+	dch->dev.D.send = handle_dmsg;
+	dch->dev.D.ctrl = hfcm_dctrl;
+	dch->slot = hc->dnum[pt];
+	hc->chan[hc->dnum[pt]].dch = dch;
+	hc->chan[hc->dnum[pt]].port = pt;
+	hc->chan[hc->dnum[pt]].nt_timer = -1;
+	for (ch = 1; ch <= 31; ch++) {
+		if (!((1 << ch) & hc->bmask[pt])) /* skip unused channel */
+			continue;
+		bch = kzalloc(sizeof(struct bchannel), GFP_KERNEL);
+		if (!bch) {
+			printk(KERN_ERR "%s: no memory for bchannel\n",
+			    __func__);
+			ret = -ENOMEM;
+			goto free_chan;
+		}
+		hc->chan[ch].coeff = kzalloc(512, GFP_KERNEL);
+		if (!hc->chan[ch].coeff) {
+			printk(KERN_ERR "%s: no memory for coeffs\n",
+			    __func__);
+			ret = -ENOMEM;
+			kfree(bch);
+			goto free_chan;
+		}
+		bch->nr = ch;
+		bch->slot = ch;
+		bch->debug = debug;
+		mISDN_initbchannel(bch, MAX_DATA_MEM);
+		bch->hw = hc;
+		bch->ch.send = handle_bmsg;
+		bch->ch.ctrl = hfcm_bctrl;
+		bch->ch.nr = ch;
+		list_add(&bch->ch.list, &dch->dev.bchannels);
+		hc->chan[ch].bch = bch;
+		hc->chan[ch].port = pt;
+		set_channelmap(bch->nr, dch->dev.channelmap);
+		bcount++;
+	}
+	dch->dev.nrbchan = bcount;
+	if (pt == 0)
+		init_e1_port_hw(hc, m);
+	if (hc->ports > 1)
+		snprintf(name, MISDN_MAX_IDLEN - 1, "hfc-e1.%d-%d",
+				HFC_cnt + 1, pt+1);
+	else
+		snprintf(name, MISDN_MAX_IDLEN - 1, "hfc-e1.%d", HFC_cnt + 1);
 	ret = mISDN_register_device(&dch->dev, &hc->pci_dev->dev, name);
 	if (ret)
 		goto free_chan;
-	hc->created[0] = 1;
+	hc->created[pt] = 1;
 	return ret;
 free_chan:
 	release_port(hc, dch);
@@ -4989,7 +5028,8 @@ hfcmulti_init(struct hm_map *m, struct pci_dev *pdev,
 	struct hfc_multi	*hc;
 	u_long		flags;
 	u_char		dips = 0, pmj = 0; /* dip settings, port mode Jumpers */
-	int		i;
+	int		i, ch;
+	u_int		maskcheck;
 
 	if (HFC_cnt >= MAX_CARDS) {
 		printk(KERN_ERR "too many cards (max=%d).\n",
@@ -5023,18 +5063,36 @@ hfcmulti_init(struct hm_map *m, struct pci_dev *pdev,
 	hc->id = HFC_cnt;
 	hc->pcm = pcm[HFC_cnt];
 	hc->io_mode = iomode[HFC_cnt];
-	if (dslot[HFC_cnt] < 0 && hc->ctype == HFC_TYPE_E1) {
-		hc->dslot = 0;
-		printk(KERN_INFO "HFC-E1 card has disabled D-channel, but "
-		       "31 B-channels\n");
-	}
-	if (dslot[HFC_cnt] > 0 && dslot[HFC_cnt] < 32
-	    && hc->ctype == HFC_TYPE_E1) {
-		hc->dslot = dslot[HFC_cnt];
-		printk(KERN_INFO "HFC-E1 card has alternating D-channel on "
-		       "time slot %d\n", dslot[HFC_cnt]);
-	} else
-		hc->dslot = 16;
+	if (hc->ctype == HFC_TYPE_E1 && dmask[E1_cnt]) {
+		/* fragment card */
+		pt = 0;
+		maskcheck = 0;
+		for (ch = 0; ch <= 31; ch++) {
+			if (!((1 << ch) & dmask[E1_cnt]))
+				continue;
+			hc->dnum[pt] = ch;
+			hc->bmask[pt] = bmask[bmask_cnt++];
+			if ((maskcheck & hc->bmask[pt])
+			 || (dmask[E1_cnt] & hc->bmask[pt])) {
+				printk(KERN_INFO
+				       "HFC-E1 #%d has overlapping B-channels on fragment #%d\n",
+				       E1_cnt + 1, pt);
+				return -EINVAL;
+			}
+			maskcheck |= hc->bmask[pt];
+			printk(KERN_INFO
+			       "HFC-E1 #%d uses D-channel on slot %d and a B-channel map of 0x%08x\n",
+				E1_cnt + 1, ch, hc->bmask[pt]);
+			pt++;
+		}
+		hc->ports = pt;
+	}
+	if (hc->ctype == HFC_TYPE_E1 && !dmask[E1_cnt]) {
+		/* default card layout */
+		hc->dnum[0] = 16;
+		hc->bmask[0] = 0xfffefffe;
+		hc->ports = 1;
+	}
 
 	/* set chip specific features */
 	hc->masterclk = -1;
@@ -5117,23 +5175,33 @@ hfcmulti_init(struct hm_map *m, struct pci_dev *pdev,
 			goto free_card;
 		}
 		if (hc->ctype == HFC_TYPE_E1)
-			ret_err = init_e1_port(hc, m);
+			ret_err = init_e1_port(hc, m, pt);
 		else
 			ret_err = init_multi_port(hc, pt);
 		if (debug & DEBUG_HFCMULTI_INIT)
 			printk(KERN_DEBUG
-			       "%s: Registering D-channel, card(%d) port(%d)"
+			    "%s: Registering D-channel, card(%d) port(%d) "
 			       "result %d\n",
-			       __func__, HFC_cnt + 1, pt, ret_err);
+			    __func__, HFC_cnt + 1, pt + 1, ret_err);
 
 		if (ret_err) {
 			while (pt) { /* release already registered ports */
 				pt--;
-				release_port(hc, hc->chan[(pt << 2) + 2].dch);
+				if (hc->ctype == HFC_TYPE_E1)
+					release_port(hc,
+						hc->chan[hc->dnum[pt]].dch);
+				else
+					release_port(hc,
+						hc->chan[(pt << 2) + 2].dch);
 			}
 			goto free_card;
 		}
-		Port_cnt++;
+		if (hc->ctype != HFC_TYPE_E1)
+			Port_cnt++; /* for each S0 port */
+	}
+	if (hc->ctype == HFC_TYPE_E1) {
+		Port_cnt++; /* for each E1 port */
+		E1_cnt++;
 	}
 
 	/* disp switches */
-- 
1.7.3.4
