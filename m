From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] isdn: use setup_timer
Date: Thu, 23 Mar 2017 21:15:57 +0800
Message-ID: <83245247f4fd11e0d1d3f3d948595dc26465d05e.1490262844.git.geliangtang@gmail.com>
Cc: Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
        Armin Schindler <mac@melware.de>,
        "David S. Miller" <davem@davemloft.net>,
        Arnd Bergmann <arnd@arndb.de>,
        Andrew Morton <akpm@linux-foundation.org>,
        Cosmin-Gabriel Samoila <gabrielcsmo@gmail.com>,
        Peter Hurley <peter@hurleysoftware.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33547 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751554AbdCWNQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:16:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use setup_timer() instead of init_timer() to simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 drivers/isdn/divert/isdn_divert.c       |  9 +++------
 drivers/isdn/hardware/eicon/divasi.c    |  5 ++---
 drivers/isdn/hardware/mISDN/hfcmulti.c  | 10 ++++------
 drivers/isdn/hardware/mISDN/hfcpci.c    |  9 +++------
 drivers/isdn/hardware/mISDN/mISDNipac.c |  5 ++---
 drivers/isdn/hardware/mISDN/mISDNisar.c | 10 ++++------
 drivers/isdn/hardware/mISDN/w6692.c     |  5 ++---
 drivers/isdn/hisax/amd7930_fn.c         |  4 +---
 drivers/isdn/hisax/arcofi.c             |  4 +---
 drivers/isdn/hisax/diva.c               |  5 ++---
 drivers/isdn/hisax/elsa.c               |  4 +---
 drivers/isdn/hisax/fsm.c                |  4 +---
 drivers/isdn/hisax/hfc4s8s_l1.c         |  5 ++---
 drivers/isdn/hisax/hfc_2bds0.c          |  4 +---
 drivers/isdn/hisax/hfc_pci.c            |  8 ++------
 drivers/isdn/hisax/hfc_sx.c             |  8 ++------
 drivers/isdn/hisax/hfc_usb.c            |  8 ++------
 drivers/isdn/hisax/hfcscard.c           |  4 +---
 drivers/isdn/hisax/icc.c                |  4 +---
 drivers/isdn/hisax/ipacx.c              |  4 +---
 drivers/isdn/hisax/isac.c               |  4 +---
 drivers/isdn/hisax/isar.c               | 10 ++++------
 drivers/isdn/hisax/isdnl3.c             |  4 +---
 drivers/isdn/hisax/teleint.c            |  4 +---
 drivers/isdn/hisax/w6692.c              |  5 ++---
 drivers/isdn/i4l/isdn_ppp.c             |  5 ++---
 drivers/isdn/i4l/isdn_tty.c             |  5 ++---
 drivers/isdn/mISDN/dsp_core.c           |  4 +---
 drivers/isdn/mISDN/fsm.c                |  4 +---
 drivers/isdn/mISDN/l1oip_core.c         |  4 +---
 30 files changed, 54 insertions(+), 114 deletions(-)

diff --git a/drivers/isdn/divert/isdn_divert.c b/drivers/isdn/divert/isdn_divert.c
index 50749a7..060d357 100644
--- a/drivers/isdn/divert/isdn_divert.c
+++ b/drivers/isdn/divert/isdn_divert.c
@@ -157,10 +157,8 @@ int cf_command(int drvid, int mode,
 	/* allocate mem for information struct */
 	if (!(cs = kmalloc(sizeof(struct call_struc), GFP_ATOMIC)))
 		return (-ENOMEM); /* no memory */
-	init_timer(&cs->timer);
+	setup_timer(&cs->timer, deflect_timer_expire, (ulong)cs);
 	cs->info[0] = '\0';
-	cs->timer.function = deflect_timer_expire;
-	cs->timer.data = (ulong) cs; /* pointer to own structure */
 	cs->ics.driver = drvid;
 	cs->ics.command = ISDN_CMD_PROT_IO; /* protocol specific io */
 	cs->ics.arg = DSS1_CMD_INVOKE; /* invoke supplementary service */
@@ -452,10 +450,9 @@ static int isdn_divert_icall(isdn_ctrl *ic)
 					return (0); /* no external deflection needed */
 			if (!(cs = kmalloc(sizeof(struct call_struc), GFP_ATOMIC)))
 				return (0); /* no memory */
-			init_timer(&cs->timer);
+			setup_timer(&cs->timer, deflect_timer_expire,
+				    (ulong)cs);
 			cs->info[0] = '\0';
-			cs->timer.function = deflect_timer_expire;
-			cs->timer.data = (ulong) cs; /* pointer to own structure */
 
 			cs->ics = *ic; /* copy incoming data */
 			if (!cs->ics.parm.setup.phone[0]) strcpy(cs->ics.parm.setup.phone, "0");
diff --git a/drivers/isdn/hardware/eicon/divasi.c b/drivers/isdn/hardware/eicon/divasi.c
index cb88090..c610495 100644
--- a/drivers/isdn/hardware/eicon/divasi.c
+++ b/drivers/isdn/hardware/eicon/divasi.c
@@ -300,9 +300,8 @@ static int um_idi_open_adapter(struct file *file, int adapter_nr)
 	p_os = (diva_um_idi_os_context_t *) diva_um_id_get_os_context(e);
 	init_waitqueue_head(&p_os->read_wait);
 	init_waitqueue_head(&p_os->close_wait);
-	init_timer(&p_os->diva_timer_id);
-	p_os->diva_timer_id.function = (void *) diva_um_timer_function;
-	p_os->diva_timer_id.data = (unsigned long) p_os;
+	setup_timer(&p_os->diva_timer_id, (void *)diva_um_timer_function,
+		    (unsigned long)p_os);
 	p_os->aborted = 0;
 	p_os->adapter_nr = adapter_nr;
 	return (1);
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 480c2d7..961c07e 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -3878,9 +3878,8 @@ hfcmulti_initmode(struct dchannel *dch)
 		if (hc->dnum[pt]) {
 			mode_hfcmulti(hc, dch->slot, dch->dev.D.protocol,
 				      -1, 0, -1, 0);
-			dch->timer.function = (void *) hfcmulti_dbusy_timer;
-			dch->timer.data = (long) dch;
-			init_timer(&dch->timer);
+			setup_timer(&dch->timer, (void *)hfcmulti_dbusy_timer,
+				    (long)dch);
 		}
 		for (i = 1; i <= 31; i++) {
 			if (!((1 << i) & hc->bmask[pt])) /* skip unused chan */
@@ -3986,9 +3985,8 @@ hfcmulti_initmode(struct dchannel *dch)
 		hc->chan[i].slot_rx = -1;
 		hc->chan[i].conf = -1;
 		mode_hfcmulti(hc, i, dch->dev.D.protocol, -1, 0, -1, 0);
-		dch->timer.function = (void *) hfcmulti_dbusy_timer;
-		dch->timer.data = (long) dch;
-		init_timer(&dch->timer);
+		setup_timer(&dch->timer, (void *)hfcmulti_dbusy_timer,
+			    (long)dch);
 		hc->chan[i - 2].slot_tx = -1;
 		hc->chan[i - 2].slot_rx = -1;
 		hc->chan[i - 2].conf = -1;
diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index ff48da6..5dc246d 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -1717,9 +1717,8 @@ static void
 inithfcpci(struct hfc_pci *hc)
 {
 	printk(KERN_DEBUG "inithfcpci: entered\n");
-	hc->dch.timer.function = (void *) hfcpci_dbusy_timer;
-	hc->dch.timer.data = (long) &hc->dch;
-	init_timer(&hc->dch.timer);
+	setup_timer(&hc->dch.timer, (void *)hfcpci_dbusy_timer,
+		    (long)&hc->dch);
 	hc->chanlimit = 2;
 	mode_hfcpci(&hc->bch[0], 1, -1);
 	mode_hfcpci(&hc->bch[1], 2, -1);
@@ -2044,9 +2043,7 @@ setup_hw(struct hfc_pci *hc)
 	Write_hfc(hc, HFCPCI_INT_M1, hc->hw.int_m1);
 	/* At this point the needed PCI config is done */
 	/* fifos are still not enabled */
-	hc->hw.timer.function = (void *) hfcpci_Timer;
-	hc->hw.timer.data = (long) hc;
-	init_timer(&hc->hw.timer);
+	setup_timer(&hc->hw.timer, (void *)hfcpci_Timer, (long)hc);
 	/* default PCM master */
 	test_and_set_bit(HFC_CFG_MASTER, &hc->cfg);
 	return 0;
diff --git a/drivers/isdn/hardware/mISDN/mISDNipac.c b/drivers/isdn/hardware/mISDN/mISDNipac.c
index 77dec28..6742b0d 100644
--- a/drivers/isdn/hardware/mISDN/mISDNipac.c
+++ b/drivers/isdn/hardware/mISDN/mISDNipac.c
@@ -796,9 +796,8 @@ isac_init(struct isac_hw *isac)
 	}
 	isac->mon_tx = NULL;
 	isac->mon_rx = NULL;
-	isac->dch.timer.function = (void *) dbusy_timer_handler;
-	isac->dch.timer.data = (long)isac;
-	init_timer(&isac->dch.timer);
+	setup_timer(&isac->dch.timer, (void *)dbusy_timer_handler,
+		    (long)isac);
 	isac->mocr = 0xaa;
 	if (isac->type & IPAC_TYPE_ISACX) {
 		/* Disable all IRQ */
diff --git a/drivers/isdn/hardware/mISDN/mISDNisar.c b/drivers/isdn/hardware/mISDN/mISDNisar.c
index feafa91..5b07859 100644
--- a/drivers/isdn/hardware/mISDN/mISDNisar.c
+++ b/drivers/isdn/hardware/mISDN/mISDNisar.c
@@ -1635,13 +1635,11 @@ init_isar(struct isar_hw *isar)
 	}
 	if (isar->version != 1)
 		return -EINVAL;
-	isar->ch[0].ftimer.function = &ftimer_handler;
-	isar->ch[0].ftimer.data = (long)&isar->ch[0];
-	init_timer(&isar->ch[0].ftimer);
+	setup_timer(&isar->ch[0].ftimer, &ftimer_handler,
+		    (long)&isar->ch[0]);
 	test_and_set_bit(FLG_INITIALIZED, &isar->ch[0].bch.Flags);
-	isar->ch[1].ftimer.function = &ftimer_handler;
-	isar->ch[1].ftimer.data = (long)&isar->ch[1];
-	init_timer(&isar->ch[1].ftimer);
+	setup_timer(&isar->ch[1].ftimer, &ftimer_handler,
+		    (long)&isar->ch[1]);
 	test_and_set_bit(FLG_INITIALIZED, &isar->ch[1].bch.Flags);
 	return 0;
 }
diff --git a/drivers/isdn/hardware/mISDN/w6692.c b/drivers/isdn/hardware/mISDN/w6692.c
index 3b067ea..3052c83 100644
--- a/drivers/isdn/hardware/mISDN/w6692.c
+++ b/drivers/isdn/hardware/mISDN/w6692.c
@@ -852,9 +852,8 @@ static void initW6692(struct w6692_hw *card)
 {
 	u8	val;
 
-	card->dch.timer.function = (void *)dbusy_timer_handler;
-	card->dch.timer.data = (u_long)&card->dch;
-	init_timer(&card->dch.timer);
+	setup_timer(&card->dch.timer, (void *)dbusy_timer_handler,
+		    (u_long)&card->dch);
 	w6692_mode(&card->bc[0], ISDN_P_NONE);
 	w6692_mode(&card->bc[1], ISDN_P_NONE);
 	WriteW6692(card, W_D_CTL, 0x00);
diff --git a/drivers/isdn/hisax/amd7930_fn.c b/drivers/isdn/hisax/amd7930_fn.c
index 36817e0..3a4c2f9 100644
--- a/drivers/isdn/hisax/amd7930_fn.c
+++ b/drivers/isdn/hisax/amd7930_fn.c
@@ -789,7 +789,5 @@ void Amd7930_init(struct IsdnCardState *cs)
 void setup_Amd7930(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, Amd7930_bh);
-	cs->dbusytimer.function = (void *) dbusy_timer_handler;
-	cs->dbusytimer.data = (long) cs;
-	init_timer(&cs->dbusytimer);
+	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
 }
diff --git a/drivers/isdn/hisax/arcofi.c b/drivers/isdn/hisax/arcofi.c
index 29ec2df..9826bad 100644
--- a/drivers/isdn/hisax/arcofi.c
+++ b/drivers/isdn/hisax/arcofi.c
@@ -125,9 +125,7 @@ clear_arcofi(struct IsdnCardState *cs) {
 
 void
 init_arcofi(struct IsdnCardState *cs) {
-	cs->dc.isac.arcofitimer.function = (void *) arcofi_timer;
-	cs->dc.isac.arcofitimer.data = (long) cs;
-	init_timer(&cs->dc.isac.arcofitimer);
+	setup_timer(&cs->dc.isac.arcofitimer, (void *)arcofi_timer, (long)cs);
 	init_waitqueue_head(&cs->dc.isac.arcofi_wait);
 	test_and_set_bit(HW_ARCOFI, &cs->HW_Flags);
 }
diff --git a/drivers/isdn/hisax/diva.c b/drivers/isdn/hisax/diva.c
index 4fc90de..079336e 100644
--- a/drivers/isdn/hisax/diva.c
+++ b/drivers/isdn/hisax/diva.c
@@ -976,9 +976,8 @@ static int setup_diva_common(struct IsdnCardState *cs)
 		printk(KERN_INFO "Diva: IPACX Design Id: %x\n",
 		       MemReadISAC_IPACX(cs, IPACX_ID) & 0x3F);
 	} else { /* DIVA 2.0 */
-		cs->hw.diva.tl.function = (void *) diva_led_handler;
-		cs->hw.diva.tl.data = (long) cs;
-		init_timer(&cs->hw.diva.tl);
+		setup_timer(&cs->hw.diva.tl, (void *)diva_led_handler,
+			    (long)cs);
 		cs->readisac  = &ReadISAC;
 		cs->writeisac = &WriteISAC;
 		cs->readisacfifo  = &ReadISACfifo;
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index d8ef64d..03bc5d5 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -1147,9 +1147,7 @@ static int setup_elsa_common(struct IsdnCard *card)
 	init_arcofi(cs);
 #endif
 	setup_isac(cs);
-	cs->hw.elsa.tl.function = (void *) elsa_led_handler;
-	cs->hw.elsa.tl.data = (long) cs;
-	init_timer(&cs->hw.elsa.tl);
+	setup_timer(&cs->hw.elsa.tl, (void *)elsa_led_handler, (long)cs);
 	/* Teste Timer */
 	if (cs->hw.elsa.timer) {
 		byteout(cs->hw.elsa.trig, 0xff);
diff --git a/drivers/isdn/hisax/fsm.c b/drivers/isdn/hisax/fsm.c
index c7a9471..d63266f 100644
--- a/drivers/isdn/hisax/fsm.c
+++ b/drivers/isdn/hisax/fsm.c
@@ -98,13 +98,11 @@ void
 FsmInitTimer(struct FsmInst *fi, struct FsmTimer *ft)
 {
 	ft->fi = fi;
-	ft->tl.function = (void *) FsmExpireTimer;
-	ft->tl.data = (long) ft;
 #if FSM_TIMER_DEBUG
 	if (ft->fi->debug)
 		ft->fi->printdebug(ft->fi, "FsmInitTimer %lx", (long) ft);
 #endif
-	init_timer(&ft->tl);
+	setup_timer(&ft->tl, (void *)FsmExpireTimer, (long)ft);
 }
 
 void
diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index e034ed8..90f051c 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -1396,9 +1396,8 @@ setup_instance(hfc4s8s_hw *hw)
 		l1p = hw->l1 + i;
 		spin_lock_init(&l1p->lock);
 		l1p->hw = hw;
-		l1p->l1_timer.function = (void *) hfc_l1_timer;
-		l1p->l1_timer.data = (long) (l1p);
-		init_timer(&l1p->l1_timer);
+		setup_timer(&l1p->l1_timer, (void *)hfc_l1_timer,
+			    (long)(l1p));
 		l1p->st_num = i;
 		skb_queue_head_init(&l1p->d_tx_queue);
 		l1p->d_if.ifc.priv = hw->l1 + i;
diff --git a/drivers/isdn/hisax/hfc_2bds0.c b/drivers/isdn/hisax/hfc_2bds0.c
index a756e5c..ad8597a 100644
--- a/drivers/isdn/hisax/hfc_2bds0.c
+++ b/drivers/isdn/hisax/hfc_2bds0.c
@@ -1073,8 +1073,6 @@ set_cs_func(struct IsdnCardState *cs)
 	cs->writeisacfifo = &dummyf;
 	cs->BC_Read_Reg = &ReadReg;
 	cs->BC_Write_Reg = &WriteReg;
-	cs->dbusytimer.function = (void *) hfc_dbusy_timer;
-	cs->dbusytimer.data = (long) cs;
-	init_timer(&cs->dbusytimer);
+	setup_timer(&cs->dbusytimer, (void *)hfc_dbusy_timer, (long)cs);
 	INIT_WORK(&cs->tqueue, hfcd_bh);
 }
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index 90449e1..f9ca35c 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -1582,9 +1582,7 @@ inithfcpci(struct IsdnCardState *cs)
 	cs->bcs[1].BC_SetStack = setstack_2b;
 	cs->bcs[0].BC_Close = close_hfcpci;
 	cs->bcs[1].BC_Close = close_hfcpci;
-	cs->dbusytimer.function = (void *) hfcpci_dbusy_timer;
-	cs->dbusytimer.data = (long) cs;
-	init_timer(&cs->dbusytimer);
+	setup_timer(&cs->dbusytimer, (void *)hfcpci_dbusy_timer, (long)cs);
 	mode_hfcpci(cs->bcs, 0, 0);
 	mode_hfcpci(cs->bcs + 1, 0, 1);
 }
@@ -1746,9 +1744,7 @@ setup_hfcpci(struct IsdnCard *card)
 	cs->BC_Write_Reg = NULL;
 	cs->irq_func = &hfcpci_interrupt;
 	cs->irq_flags |= IRQF_SHARED;
-	cs->hw.hfcpci.timer.function = (void *) hfcpci_Timer;
-	cs->hw.hfcpci.timer.data = (long) cs;
-	init_timer(&cs->hw.hfcpci.timer);
+	setup_timer(&cs->hw.hfcpci.timer, (void *)hfcpci_Timer, (long)cs);
 	cs->cardmsg = &hfcpci_card_msg;
 	cs->auxcmd = &hfcpci_auxcmd;
 
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 13b2151..3aef8e1 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -1495,9 +1495,7 @@ int setup_hfcsx(struct IsdnCard *card)
 	} else
 		return (0);	/* no valid card type */
 
-	cs->dbusytimer.function = (void *) hfcsx_dbusy_timer;
-	cs->dbusytimer.data = (long) cs;
-	init_timer(&cs->dbusytimer);
+	setup_timer(&cs->dbusytimer, (void *)hfcsx_dbusy_timer, (long)cs);
 	INIT_WORK(&cs->tqueue, hfcsx_bh);
 	cs->readisac = NULL;
 	cs->writeisac = NULL;
@@ -1507,11 +1505,9 @@ int setup_hfcsx(struct IsdnCard *card)
 	cs->BC_Write_Reg = NULL;
 	cs->irq_func = &hfcsx_interrupt;
 
-	cs->hw.hfcsx.timer.function = (void *) hfcsx_Timer;
-	cs->hw.hfcsx.timer.data = (long) cs;
 	cs->hw.hfcsx.b_fifo_size = 0; /* fifo size still unknown */
 	cs->hw.hfcsx.cirm = ccd_sp_irqtab[cs->irq & 0xF]; /* RAM not evaluated */
-	init_timer(&cs->hw.hfcsx.timer);
+	setup_timer(&cs->hw.hfcsx.timer, (void *)hfcsx_Timer, (long)cs);
 
 	reset_hfcsx(cs);
 	cs->cardmsg = &hfcsx_card_msg;
diff --git a/drivers/isdn/hisax/hfc_usb.c b/drivers/isdn/hisax/hfc_usb.c
index 678bd52..6dbd1f1 100644
--- a/drivers/isdn/hisax/hfc_usb.c
+++ b/drivers/isdn/hisax/hfc_usb.c
@@ -1165,14 +1165,10 @@ hfc_usb_init(hfcusb_data *hfc)
 	hfc->old_led_state = 0;
 
 	/* init the t3 timer */
-	init_timer(&hfc->t3_timer);
-	hfc->t3_timer.data = (long) hfc;
-	hfc->t3_timer.function = (void *) l1_timer_expire_t3;
+	setup_timer(&hfc->t3_timer, (void *)l1_timer_expire_t3, (long)hfc);
 
 	/* init the t4 timer */
-	init_timer(&hfc->t4_timer);
-	hfc->t4_timer.data = (long) hfc;
-	hfc->t4_timer.function = (void *) l1_timer_expire_t4;
+	setup_timer(&hfc->t4_timer, (void *)l1_timer_expire_t4, (long)hfc);
 
 	/* init the background machinery for control requests */
 	hfc->ctrl_read.bRequestType = 0xc0;
diff --git a/drivers/isdn/hisax/hfcscard.c b/drivers/isdn/hisax/hfcscard.c
index 394da64..4672870 100644
--- a/drivers/isdn/hisax/hfcscard.c
+++ b/drivers/isdn/hisax/hfcscard.c
@@ -253,9 +253,7 @@ int setup_hfcs(struct IsdnCard *card)
 		outb(0x57, cs->hw.hfcD.addr | 1);
 	}
 	set_cs_func(cs);
-	cs->hw.hfcD.timer.function = (void *) hfcs_Timer;
-	cs->hw.hfcD.timer.data = (long) cs;
-	init_timer(&cs->hw.hfcD.timer);
+	setup_timer(&cs->hw.hfcD.timer, (void *)hfcs_Timer, (long)cs);
 	cs->cardmsg = &hfcs_card_msg;
 	cs->irq_func = &hfcs_interrupt;
 	return (1);
diff --git a/drivers/isdn/hisax/icc.c b/drivers/isdn/hisax/icc.c
index 96d1df0..c7c3797 100644
--- a/drivers/isdn/hisax/icc.c
+++ b/drivers/isdn/hisax/icc.c
@@ -676,7 +676,5 @@ clear_pending_icc_ints(struct IsdnCardState *cs)
 void setup_icc(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, icc_bh);
-	cs->dbusytimer.function = (void *) dbusy_timer_handler;
-	cs->dbusytimer.data = (long) cs;
-	init_timer(&cs->dbusytimer);
+	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
 }
diff --git a/drivers/isdn/hisax/ipacx.c b/drivers/isdn/hisax/ipacx.c
index 9cc26b4..43effe7 100644
--- a/drivers/isdn/hisax/ipacx.c
+++ b/drivers/isdn/hisax/ipacx.c
@@ -424,9 +424,7 @@ dch_init(struct IsdnCardState *cs)
 
 	cs->setstack_d      = dch_setstack;
 
-	cs->dbusytimer.function = (void *) dbusy_timer_handler;
-	cs->dbusytimer.data = (long) cs;
-	init_timer(&cs->dbusytimer);
+	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
 
 	cs->writeisac(cs, IPACX_TR_CONF0, 0x00);  // clear LDD
 	cs->writeisac(cs, IPACX_TR_CONF2, 0x00);  // enable transmitter
diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index df7e05c..4273b45 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -677,7 +677,5 @@ void clear_pending_isac_ints(struct IsdnCardState *cs)
 void setup_isac(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, isac_bh);
-	cs->dbusytimer.function = (void *) dbusy_timer_handler;
-	cs->dbusytimer.data = (long) cs;
-	init_timer(&cs->dbusytimer);
+	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
 }
diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index f4956c7..0dc60b2 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -1902,10 +1902,8 @@ void initisar(struct IsdnCardState *cs)
 	cs->bcs[1].BC_SetStack = setstack_isar;
 	cs->bcs[0].BC_Close = close_isarstate;
 	cs->bcs[1].BC_Close = close_isarstate;
-	cs->bcs[0].hw.isar.ftimer.function = (void *) ftimer_handler;
-	cs->bcs[0].hw.isar.ftimer.data = (long) &cs->bcs[0];
-	init_timer(&cs->bcs[0].hw.isar.ftimer);
-	cs->bcs[1].hw.isar.ftimer.function = (void *) ftimer_handler;
-	cs->bcs[1].hw.isar.ftimer.data = (long) &cs->bcs[1];
-	init_timer(&cs->bcs[1].hw.isar.ftimer);
+	setup_timer(&cs->bcs[0].hw.isar.ftimer, (void *)ftimer_handler,
+		    (long)&cs->bcs[0]);
+	setup_timer(&cs->bcs[1].hw.isar.ftimer, (void *)ftimer_handler,
+		    (long)&cs->bcs[1]);
 }
diff --git a/drivers/isdn/hisax/isdnl3.c b/drivers/isdn/hisax/isdnl3.c
index c754706..569ce52 100644
--- a/drivers/isdn/hisax/isdnl3.c
+++ b/drivers/isdn/hisax/isdnl3.c
@@ -169,9 +169,7 @@ void
 L3InitTimer(struct l3_process *pc, struct L3Timer *t)
 {
 	t->pc = pc;
-	t->tl.function = (void *) L3ExpireTimer;
-	t->tl.data = (long) t;
-	init_timer(&t->tl);
+	setup_timer(&t->tl, (void *)L3ExpireTimer, (long)t);
 }
 
 void
diff --git a/drivers/isdn/hisax/teleint.c b/drivers/isdn/hisax/teleint.c
index bf64754..950399f 100644
--- a/drivers/isdn/hisax/teleint.c
+++ b/drivers/isdn/hisax/teleint.c
@@ -278,9 +278,7 @@ int setup_TeleInt(struct IsdnCard *card)
 	cs->bcs[0].hw.hfc.send = NULL;
 	cs->bcs[1].hw.hfc.send = NULL;
 	cs->hw.hfc.fifosize = 7 * 1024 + 512;
-	cs->hw.hfc.timer.function = (void *) TeleInt_Timer;
-	cs->hw.hfc.timer.data = (long) cs;
-	init_timer(&cs->hw.hfc.timer);
+	setup_timer(&cs->hw.hfc.timer, (void *)TeleInt_Timer, (long)cs);
 	if (!request_region(cs->hw.hfc.addr, 2, "TeleInt isdn")) {
 		printk(KERN_WARNING
 		       "HiSax: TeleInt config port %x-%x already in use\n",
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index a858955..c99f0ec 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -901,9 +901,8 @@ static void initW6692(struct IsdnCardState *cs, int part)
 	if (part & 1) {
 		cs->setstack_d = setstack_W6692;
 		cs->DC_Close = DC_Close_W6692;
-		cs->dbusytimer.function = (void *) dbusy_timer_handler;
-		cs->dbusytimer.data = (long) cs;
-		init_timer(&cs->dbusytimer);
+		setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler,
+			    (long)cs);
 		resetW6692(cs);
 		ph_command(cs, W_L1CMD_RST);
 		cs->dc.w6692.ph_state = W_L1CMD_RST;
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 9c1e8ad..d07dd51 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -2370,9 +2370,8 @@ static struct ippp_ccp_reset_state *isdn_ppp_ccp_reset_alloc_state(struct ippp_s
 		rs->state = CCPResetIdle;
 		rs->is = is;
 		rs->id = id;
-		init_timer(&rs->timer);
-		rs->timer.data = (unsigned long)rs;
-		rs->timer.function = isdn_ppp_ccp_timer_callback;
+		setup_timer(&rs->timer, isdn_ppp_ccp_timer_callback,
+			    (unsigned long)rs);
 		is->reset->rs[id] = rs;
 	}
 	return rs;
diff --git a/drivers/isdn/i4l/isdn_tty.c b/drivers/isdn/i4l/isdn_tty.c
index 1b16955..ddd8207 100644
--- a/drivers/isdn/i4l/isdn_tty.c
+++ b/drivers/isdn/i4l/isdn_tty.c
@@ -1812,9 +1812,8 @@ isdn_tty_modem_init(void)
 		info->isdn_channel = -1;
 		info->drv_index = -1;
 		info->xmit_size = ISDN_SERIAL_XMIT_SIZE;
-		init_timer(&info->nc_timer);
-		info->nc_timer.function = isdn_tty_modem_do_ncarrier;
-		info->nc_timer.data = (unsigned long) info;
+		setup_timer(&info->nc_timer, isdn_tty_modem_do_ncarrier,
+			    (unsigned long)info);
 		skb_queue_head_init(&info->xmit_queue);
 #ifdef CONFIG_ISDN_AUDIO
 		skb_queue_head_init(&info->dtmf_queue);
diff --git a/drivers/isdn/mISDN/dsp_core.c b/drivers/isdn/mISDN/dsp_core.c
index 9b85295..880e9d3 100644
--- a/drivers/isdn/mISDN/dsp_core.c
+++ b/drivers/isdn/mISDN/dsp_core.c
@@ -1092,9 +1092,7 @@ dspcreate(struct channel_req *crq)
 	ndsp->pcm_bank_tx = -1;
 	ndsp->hfc_conf = -1; /* current conference number */
 	/* set tone timer */
-	ndsp->tone.tl.function = (void *)dsp_tone_timeout;
-	ndsp->tone.tl.data = (long) ndsp;
-	init_timer(&ndsp->tone.tl);
+	setup_timer(&ndsp->tone.tl, (void *)dsp_tone_timeout, (long)ndsp);
 
 	if (dtmfthreshold < 20 || dtmfthreshold > 500)
 		dtmfthreshold = 200;
diff --git a/drivers/isdn/mISDN/fsm.c b/drivers/isdn/mISDN/fsm.c
index 26477d4..78fc5d5 100644
--- a/drivers/isdn/mISDN/fsm.c
+++ b/drivers/isdn/mISDN/fsm.c
@@ -110,13 +110,11 @@ void
 mISDN_FsmInitTimer(struct FsmInst *fi, struct FsmTimer *ft)
 {
 	ft->fi = fi;
-	ft->tl.function = (void *) FsmExpireTimer;
-	ft->tl.data = (long) ft;
 #if FSM_TIMER_DEBUG
 	if (ft->fi->debug)
 		ft->fi->printdebug(ft->fi, "mISDN_FsmInitTimer %lx", (long) ft);
 #endif
-	init_timer(&ft->tl);
+	setup_timer(&ft->tl, (void *)FsmExpireTimer, (long)ft);
 }
 EXPORT_SYMBOL(mISDN_FsmInitTimer);
 
diff --git a/drivers/isdn/mISDN/l1oip_core.c b/drivers/isdn/mISDN/l1oip_core.c
index 6ceca7d..6be2041 100644
--- a/drivers/isdn/mISDN/l1oip_core.c
+++ b/drivers/isdn/mISDN/l1oip_core.c
@@ -1443,9 +1443,7 @@ init_card(struct l1oip *hc, int pri, int bundle)
 	hc->keep_tl.expires = jiffies + 2 * HZ; /* two seconds first time */
 	add_timer(&hc->keep_tl);
 
-	hc->timeout_tl.function = (void *)l1oip_timeout;
-	hc->timeout_tl.data = (ulong)hc;
-	init_timer(&hc->timeout_tl);
+	setup_timer(&hc->timeout_tl, (void *)l1oip_timeout, (ulong)hc);
 	hc->timeout_on = 0; /* state that we have timer off */
 
 	return 0;
-- 
2.9.3
