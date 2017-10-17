From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 10/58] isdn/hisax: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:54 -0700
Message-ID: <1508200182-104605-11-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Karsten Keil <isdn@linux-pingi.de>,
        Geliang Tang <geliangtang@gmail.com>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: Geliang Tang <geliangtang@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/isdn/hisax/amd7930_fn.c |  6 +++---
 drivers/isdn/hisax/arcofi.c     |  6 +++---
 drivers/isdn/hisax/diva.c       |  9 ++++-----
 drivers/isdn/hisax/elsa.c       | 10 +++++-----
 drivers/isdn/hisax/fsm.c        |  7 +++----
 drivers/isdn/hisax/hfc4s8s_l1.c |  6 +++---
 drivers/isdn/hisax/hfc_2bds0.c  |  4 ++--
 drivers/isdn/hisax/hfc_pci.c    |  9 +++++----
 drivers/isdn/hisax/hfc_sx.c     |  9 +++++----
 drivers/isdn/hisax/hfc_usb.c    | 10 ++++++----
 drivers/isdn/hisax/hfcscard.c   |  5 +++--
 drivers/isdn/hisax/icc.c        |  6 +++---
 drivers/isdn/hisax/ipacx.c      |  8 ++++----
 drivers/isdn/hisax/isac.c       |  6 +++---
 drivers/isdn/hisax/isar.c       |  9 ++++-----
 drivers/isdn/hisax/isdnl3.c     |  6 +++---
 drivers/isdn/hisax/saphir.c     |  7 +++----
 drivers/isdn/hisax/teleint.c    |  5 +++--
 drivers/isdn/hisax/w6692.c      |  7 +++----
 19 files changed, 68 insertions(+), 67 deletions(-)

diff --git a/drivers/isdn/hisax/amd7930_fn.c b/drivers/isdn/hisax/amd7930_fn.c
index dcf4c2a9fcea..77debda2221b 100644
--- a/drivers/isdn/hisax/amd7930_fn.c
+++ b/drivers/isdn/hisax/amd7930_fn.c
@@ -398,7 +398,6 @@ Amd7930_fill_Dfifo(struct IsdnCardState *cs)
 		debugl1(cs, "Amd7930: fill_Dfifo dbusytimer running");
 		del_timer(&cs->dbusytimer);
 	}
-	init_timer(&cs->dbusytimer);
 	cs->dbusytimer.expires = jiffies + ((DBUSY_TIMER_VALUE * HZ) / 1000);
 	add_timer(&cs->dbusytimer);
 
@@ -686,8 +685,9 @@ DC_Close_Amd7930(struct IsdnCardState *cs) {
 
 
 static void
-dbusy_timer_handler(struct IsdnCardState *cs)
+dbusy_timer_handler(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, dbusytimer);
 	u_long flags;
 	struct PStack *stptr;
 	WORD dtcr, der;
@@ -790,5 +790,5 @@ void Amd7930_init(struct IsdnCardState *cs)
 void setup_Amd7930(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, Amd7930_bh);
-	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
+	timer_setup(&cs->dbusytimer, dbusy_timer_handler, 0);
 }
diff --git a/drivers/isdn/hisax/arcofi.c b/drivers/isdn/hisax/arcofi.c
index 9826bad49e2c..2f784f96d439 100644
--- a/drivers/isdn/hisax/arcofi.c
+++ b/drivers/isdn/hisax/arcofi.c
@@ -23,7 +23,6 @@ add_arcofi_timer(struct IsdnCardState *cs) {
 	if (test_and_set_bit(FLG_ARCOFI_TIMER, &cs->HW_Flags)) {
 		del_timer(&cs->dc.isac.arcofitimer);
 	}
-	init_timer(&cs->dc.isac.arcofitimer);
 	cs->dc.isac.arcofitimer.expires = jiffies + ((ARCOFI_TIMER_VALUE * HZ) / 1000);
 	add_timer(&cs->dc.isac.arcofitimer);
 }
@@ -112,7 +111,8 @@ arcofi_fsm(struct IsdnCardState *cs, int event, void *data) {
 }
 
 static void
-arcofi_timer(struct IsdnCardState *cs) {
+arcofi_timer(struct timer_list *t) {
+	struct IsdnCardState *cs = from_timer(cs, t, dc.isac.arcofitimer);
 	arcofi_fsm(cs, ARCOFI_TIMEOUT, NULL);
 }
 
@@ -125,7 +125,7 @@ clear_arcofi(struct IsdnCardState *cs) {
 
 void
 init_arcofi(struct IsdnCardState *cs) {
-	setup_timer(&cs->dc.isac.arcofitimer, (void *)arcofi_timer, (long)cs);
+	timer_setup(&cs->dc.isac.arcofitimer, arcofi_timer, 0);
 	init_waitqueue_head(&cs->dc.isac.arcofi_wait);
 	test_and_set_bit(HW_ARCOFI, &cs->HW_Flags);
 }
diff --git a/drivers/isdn/hisax/diva.c b/drivers/isdn/hisax/diva.c
index 3fc94e7741ae..38bdd3f7b960 100644
--- a/drivers/isdn/hisax/diva.c
+++ b/drivers/isdn/hisax/diva.c
@@ -798,8 +798,9 @@ reset_diva(struct IsdnCardState *cs)
 #define DIVA_ASSIGN 1
 
 static void
-diva_led_handler(struct IsdnCardState *cs)
+diva_led_handler(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, hw.diva.tl);
 	int blink = 0;
 
 	if ((cs->subtyp == DIVA_IPAC_ISA) ||
@@ -828,7 +829,6 @@ diva_led_handler(struct IsdnCardState *cs)
 
 	byteout(cs->hw.diva.ctrl, cs->hw.diva.ctrl_reg);
 	if (blink) {
-		init_timer(&cs->hw.diva.tl);
 		cs->hw.diva.tl.expires = jiffies + ((blink * HZ) / 1000);
 		add_timer(&cs->hw.diva.tl);
 	}
@@ -900,7 +900,7 @@ Diva_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 	    (cs->subtyp != DIVA_IPAC_PCI) &&
 	    (cs->subtyp != DIVA_IPACX_PCI)) {
 		spin_lock_irqsave(&cs->lock, flags);
-		diva_led_handler(cs);
+		diva_led_handler(&cs->hw.diva.tl);
 		spin_unlock_irqrestore(&cs->lock, flags);
 	}
 	return (0);
@@ -978,8 +978,7 @@ static int setup_diva_common(struct IsdnCardState *cs)
 		printk(KERN_INFO "Diva: IPACX Design Id: %x\n",
 		       MemReadISAC_IPACX(cs, IPACX_ID) & 0x3F);
 	} else { /* DIVA 2.0 */
-		setup_timer(&cs->hw.diva.tl, (void *)diva_led_handler,
-			    (long)cs);
+		timer_setup(&cs->hw.diva.tl, diva_led_handler, 0);
 		cs->readisac  = &ReadISAC;
 		cs->writeisac = &WriteISAC;
 		cs->readisacfifo  = &ReadISACfifo;
diff --git a/drivers/isdn/hisax/elsa.c b/drivers/isdn/hisax/elsa.c
index 03bc5d504e22..b21c05820f44 100644
--- a/drivers/isdn/hisax/elsa.c
+++ b/drivers/isdn/hisax/elsa.c
@@ -606,8 +606,9 @@ check_arcofi(struct IsdnCardState *cs)
 #endif /* ARCOFI_USE */
 
 static void
-elsa_led_handler(struct IsdnCardState *cs)
+elsa_led_handler(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, hw.elsa.tl);
 	int blink = 0;
 
 	if (cs->subtyp == ELSA_PCMCIA || cs->subtyp == ELSA_PCMCIA_IPAC)
@@ -640,7 +641,6 @@ elsa_led_handler(struct IsdnCardState *cs)
 	} else
 		byteout(cs->hw.elsa.ctrl, cs->hw.elsa.ctrl_reg);
 	if (blink) {
-		init_timer(&cs->hw.elsa.tl);
 		cs->hw.elsa.tl.expires = jiffies + ((blink * HZ) / 1000);
 		add_timer(&cs->hw.elsa.tl);
 	}
@@ -715,7 +715,7 @@ Elsa_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 			init_modem(cs);
 		}
 #endif
-		elsa_led_handler(cs);
+		elsa_led_handler(&cs->hw.elsa.tl);
 		return (ret);
 	case (MDL_REMOVE | REQUEST):
 		cs->hw.elsa.status &= 0;
@@ -767,7 +767,7 @@ Elsa_card_msg(struct IsdnCardState *cs, int mt, void *arg)
 		else
 			cs->hw.elsa.status &= ~ELSA_BAD_PWR;
 	}
-	elsa_led_handler(cs);
+	elsa_led_handler(&cs->hw.elsa.tl);
 	return (ret);
 }
 
@@ -1147,7 +1147,7 @@ static int setup_elsa_common(struct IsdnCard *card)
 	init_arcofi(cs);
 #endif
 	setup_isac(cs);
-	setup_timer(&cs->hw.elsa.tl, (void *)elsa_led_handler, (long)cs);
+	timer_setup(&cs->hw.elsa.tl, elsa_led_handler, 0);
 	/* Teste Timer */
 	if (cs->hw.elsa.timer) {
 		byteout(cs->hw.elsa.trig, 0xff);
diff --git a/drivers/isdn/hisax/fsm.c b/drivers/isdn/hisax/fsm.c
index d63266fa8cbd..3e020ec0f65e 100644
--- a/drivers/isdn/hisax/fsm.c
+++ b/drivers/isdn/hisax/fsm.c
@@ -85,8 +85,9 @@ FsmChangeState(struct FsmInst *fi, int newstate)
 }
 
 static void
-FsmExpireTimer(struct FsmTimer *ft)
+FsmExpireTimer(struct timer_list *t)
 {
+	struct FsmTimer *ft = from_timer(ft, t, tl);
 #if FSM_TIMER_DEBUG
 	if (ft->fi->debug)
 		ft->fi->printdebug(ft->fi, "FsmExpireTimer %lx", (long) ft);
@@ -102,7 +103,7 @@ FsmInitTimer(struct FsmInst *fi, struct FsmTimer *ft)
 	if (ft->fi->debug)
 		ft->fi->printdebug(ft->fi, "FsmInitTimer %lx", (long) ft);
 #endif
-	setup_timer(&ft->tl, (void *)FsmExpireTimer, (long)ft);
+	timer_setup(&ft->tl, FsmExpireTimer, 0);
 }
 
 void
@@ -131,7 +132,6 @@ FsmAddTimer(struct FsmTimer *ft,
 		ft->fi->printdebug(ft->fi, "FsmAddTimer already active!");
 		return -1;
 	}
-	init_timer(&ft->tl);
 	ft->event = event;
 	ft->arg = arg;
 	ft->tl.expires = jiffies + (millisec * HZ) / 1000;
@@ -152,7 +152,6 @@ FsmRestartTimer(struct FsmTimer *ft,
 
 	if (timer_pending(&ft->tl))
 		del_timer(&ft->tl);
-	init_timer(&ft->tl);
 	ft->event = event;
 	ft->arg = arg;
 	ft->tl.expires = jiffies + (millisec * HZ) / 1000;
diff --git a/drivers/isdn/hisax/hfc4s8s_l1.c b/drivers/isdn/hisax/hfc4s8s_l1.c
index 9090cc1e1f29..e9bb8fb67ad0 100644
--- a/drivers/isdn/hisax/hfc4s8s_l1.c
+++ b/drivers/isdn/hisax/hfc4s8s_l1.c
@@ -591,8 +591,9 @@ bch_l2l1(struct hisax_if *ifc, int pr, void *arg)
 /* layer 1 timer function */
 /**************************/
 static void
-hfc_l1_timer(struct hfc4s8s_l1 *l1)
+hfc_l1_timer(struct timer_list *t)
 {
+	struct hfc4s8s_l1 *l1 = from_timer(l1, t, l1_timer);
 	u_long flags;
 
 	if (!l1->enabled)
@@ -1396,8 +1397,7 @@ setup_instance(hfc4s8s_hw *hw)
 		l1p = hw->l1 + i;
 		spin_lock_init(&l1p->lock);
 		l1p->hw = hw;
-		setup_timer(&l1p->l1_timer, (void *)hfc_l1_timer,
-			    (long)(l1p));
+		timer_setup(&l1p->l1_timer, hfc_l1_timer, 0);
 		l1p->st_num = i;
 		skb_queue_head_init(&l1p->d_tx_queue);
 		l1p->d_if.ifc.priv = hw->l1 + i;
diff --git a/drivers/isdn/hisax/hfc_2bds0.c b/drivers/isdn/hisax/hfc_2bds0.c
index ad8597a1a07e..86b82172e992 100644
--- a/drivers/isdn/hisax/hfc_2bds0.c
+++ b/drivers/isdn/hisax/hfc_2bds0.c
@@ -1014,7 +1014,7 @@ setstack_hfcd(struct PStack *st, struct IsdnCardState *cs)
 }
 
 static void
-hfc_dbusy_timer(struct IsdnCardState *cs)
+hfc_dbusy_timer(struct timer_list *t)
 {
 }
 
@@ -1073,6 +1073,6 @@ set_cs_func(struct IsdnCardState *cs)
 	cs->writeisacfifo = &dummyf;
 	cs->BC_Read_Reg = &ReadReg;
 	cs->BC_Write_Reg = &WriteReg;
-	setup_timer(&cs->dbusytimer, (void *)hfc_dbusy_timer, (long)cs);
+	timer_setup(&cs->dbusytimer, hfc_dbusy_timer, 0);
 	INIT_WORK(&cs->tqueue, hfcd_bh);
 }
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index f9ca35cc32b1..8e5b03161b2f 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -165,8 +165,9 @@ reset_hfcpci(struct IsdnCardState *cs)
 /* Timer function called when kernel timer expires */
 /***************************************************/
 static void
-hfcpci_Timer(struct IsdnCardState *cs)
+hfcpci_Timer(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, hw.hfcpci.timer);
 	cs->hw.hfcpci.timer.expires = jiffies + 75;
 	/* WD RESET */
 /*      WriteReg(cs, HFCD_DATA, HFCD_CTMT, cs->hw.hfcpci.ctmt | 0x80);
@@ -1095,7 +1096,7 @@ hfcpci_interrupt(int intno, void *dev_id)
 /* timer callback for D-chan busy resolution. Currently no function */
 /********************************************************************/
 static void
-hfcpci_dbusy_timer(struct IsdnCardState *cs)
+hfcpci_dbusy_timer(struct timer_list *t)
 {
 }
 
@@ -1582,7 +1583,7 @@ inithfcpci(struct IsdnCardState *cs)
 	cs->bcs[1].BC_SetStack = setstack_2b;
 	cs->bcs[0].BC_Close = close_hfcpci;
 	cs->bcs[1].BC_Close = close_hfcpci;
-	setup_timer(&cs->dbusytimer, (void *)hfcpci_dbusy_timer, (long)cs);
+	timer_setup(&cs->dbusytimer, hfcpci_dbusy_timer, 0);
 	mode_hfcpci(cs->bcs, 0, 0);
 	mode_hfcpci(cs->bcs + 1, 0, 1);
 }
@@ -1744,7 +1745,7 @@ setup_hfcpci(struct IsdnCard *card)
 	cs->BC_Write_Reg = NULL;
 	cs->irq_func = &hfcpci_interrupt;
 	cs->irq_flags |= IRQF_SHARED;
-	setup_timer(&cs->hw.hfcpci.timer, (void *)hfcpci_Timer, (long)cs);
+	timer_setup(&cs->hw.hfcpci.timer, hfcpci_Timer, 0);
 	cs->cardmsg = &hfcpci_card_msg;
 	cs->auxcmd = &hfcpci_auxcmd;
 
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 3aef8e1a90e4..d925f579bc80 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -418,8 +418,9 @@ reset_hfcsx(struct IsdnCardState *cs)
 /* Timer function called when kernel timer expires */
 /***************************************************/
 static void
-hfcsx_Timer(struct IsdnCardState *cs)
+hfcsx_Timer(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, hw.hfcsx.timer);
 	cs->hw.hfcsx.timer.expires = jiffies + 75;
 	/* WD RESET */
 /*      WriteReg(cs, HFCD_DATA, HFCD_CTMT, cs->hw.hfcsx.ctmt | 0x80);
@@ -860,7 +861,7 @@ hfcsx_interrupt(int intno, void *dev_id)
 /* timer callback for D-chan busy resolution. Currently no function */
 /********************************************************************/
 static void
-hfcsx_dbusy_timer(struct IsdnCardState *cs)
+hfcsx_dbusy_timer(struct timer_list *t)
 {
 }
 
@@ -1495,7 +1496,7 @@ int setup_hfcsx(struct IsdnCard *card)
 	} else
 		return (0);	/* no valid card type */
 
-	setup_timer(&cs->dbusytimer, (void *)hfcsx_dbusy_timer, (long)cs);
+	timer_setup(&cs->dbusytimer, hfcsx_dbusy_timer, 0);
 	INIT_WORK(&cs->tqueue, hfcsx_bh);
 	cs->readisac = NULL;
 	cs->writeisac = NULL;
@@ -1507,7 +1508,7 @@ int setup_hfcsx(struct IsdnCard *card)
 
 	cs->hw.hfcsx.b_fifo_size = 0; /* fifo size still unknown */
 	cs->hw.hfcsx.cirm = ccd_sp_irqtab[cs->irq & 0xF]; /* RAM not evaluated */
-	setup_timer(&cs->hw.hfcsx.timer, (void *)hfcsx_Timer, (long)cs);
+	timer_setup(&cs->hw.hfcsx.timer, hfcsx_Timer, 0);
 
 	reset_hfcsx(cs);
 	cs->cardmsg = &hfcsx_card_msg;
diff --git a/drivers/isdn/hisax/hfc_usb.c b/drivers/isdn/hisax/hfc_usb.c
index e8212185d386..97ecb3073045 100644
--- a/drivers/isdn/hisax/hfc_usb.c
+++ b/drivers/isdn/hisax/hfc_usb.c
@@ -343,8 +343,9 @@ handle_led(hfcusb_data *hfc, int event)
 
 /* ISDN l1 timer T3 expires */
 static void
-l1_timer_expire_t3(hfcusb_data *hfc)
+l1_timer_expire_t3(struct timer_list *t)
 {
+	hfcusb_data *hfc = from_timer(hfc, t, t3_timer);
 	hfc->d_if.ifc.l1l2(&hfc->d_if.ifc, PH_DEACTIVATE | INDICATION,
 			   NULL);
 
@@ -360,8 +361,9 @@ l1_timer_expire_t3(hfcusb_data *hfc)
 
 /* ISDN l1 timer T4 expires */
 static void
-l1_timer_expire_t4(hfcusb_data *hfc)
+l1_timer_expire_t4(struct timer_list *t)
 {
+	hfcusb_data *hfc = from_timer(hfc, t, t4_timer);
 	hfc->d_if.ifc.l1l2(&hfc->d_if.ifc, PH_DEACTIVATE | INDICATION,
 			   NULL);
 
@@ -1165,10 +1167,10 @@ hfc_usb_init(hfcusb_data *hfc)
 	hfc->old_led_state = 0;
 
 	/* init the t3 timer */
-	setup_timer(&hfc->t3_timer, (void *)l1_timer_expire_t3, (long)hfc);
+	timer_setup(&hfc->t3_timer, l1_timer_expire_t3, 0);
 
 	/* init the t4 timer */
-	setup_timer(&hfc->t4_timer, (void *)l1_timer_expire_t4, (long)hfc);
+	timer_setup(&hfc->t4_timer, l1_timer_expire_t4, 0);
 
 	/* init the background machinery for control requests */
 	hfc->ctrl_read.bRequestType = 0xc0;
diff --git a/drivers/isdn/hisax/hfcscard.c b/drivers/isdn/hisax/hfcscard.c
index 467287096918..380bbeda9c74 100644
--- a/drivers/isdn/hisax/hfcscard.c
+++ b/drivers/isdn/hisax/hfcscard.c
@@ -41,8 +41,9 @@ hfcs_interrupt(int intno, void *dev_id)
 }
 
 static void
-hfcs_Timer(struct IsdnCardState *cs)
+hfcs_Timer(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, hw.hfcD.timer);
 	cs->hw.hfcD.timer.expires = jiffies + 75;
 	/* WD RESET */
 /*	WriteReg(cs, HFCD_DATA, HFCD_CTMT, cs->hw.hfcD.ctmt | 0x80);
@@ -253,7 +254,7 @@ int setup_hfcs(struct IsdnCard *card)
 		outb(0x57, cs->hw.hfcD.addr | 1);
 	}
 	set_cs_func(cs);
-	setup_timer(&cs->hw.hfcD.timer, (void *)hfcs_Timer, (long)cs);
+	timer_setup(&cs->hw.hfcD.timer, hfcs_Timer, 0);
 	cs->cardmsg = &hfcs_card_msg;
 	cs->irq_func = &hfcs_interrupt;
 	return (1);
diff --git a/drivers/isdn/hisax/icc.c b/drivers/isdn/hisax/icc.c
index 8d1804572b32..831dd1bb81ef 100644
--- a/drivers/isdn/hisax/icc.c
+++ b/drivers/isdn/hisax/icc.c
@@ -168,7 +168,6 @@ icc_fill_fifo(struct IsdnCardState *cs)
 		debugl1(cs, "icc_fill_fifo dbusytimer running");
 		del_timer(&cs->dbusytimer);
 	}
-	init_timer(&cs->dbusytimer);
 	cs->dbusytimer.expires = jiffies + ((DBUSY_TIMER_VALUE * HZ)/1000);
 	add_timer(&cs->dbusytimer);
 	if (cs->debug & L1_DEB_ISAC_FIFO) {
@@ -580,8 +579,9 @@ DC_Close_icc(struct IsdnCardState *cs) {
 }
 
 static void
-dbusy_timer_handler(struct IsdnCardState *cs)
+dbusy_timer_handler(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, dbusytimer);
 	struct PStack *stptr;
 	int	rbch, star;
 
@@ -676,5 +676,5 @@ clear_pending_icc_ints(struct IsdnCardState *cs)
 void setup_icc(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, icc_bh);
-	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
+	timer_setup(&cs->dbusytimer, dbusy_timer_handler, 0);
 }
diff --git a/drivers/isdn/hisax/ipacx.c b/drivers/isdn/hisax/ipacx.c
index c426b4fea28a..c7086c1534bd 100644
--- a/drivers/isdn/hisax/ipacx.c
+++ b/drivers/isdn/hisax/ipacx.c
@@ -35,7 +35,7 @@
 static void ph_command(struct IsdnCardState *cs, unsigned int command);
 static inline void cic_int(struct IsdnCardState *cs);
 static void dch_l2l1(struct PStack *st, int pr, void *arg);
-static void dbusy_timer_handler(struct IsdnCardState *cs);
+static void dbusy_timer_handler(struct timer_list *t);
 static void dch_empty_fifo(struct IsdnCardState *cs, int count);
 static void dch_fill_fifo(struct IsdnCardState *cs);
 static inline void dch_int(struct IsdnCardState *cs);
@@ -198,8 +198,9 @@ dch_l2l1(struct PStack *st, int pr, void *arg)
 //----------------------------------------------------------
 //----------------------------------------------------------
 static void
-dbusy_timer_handler(struct IsdnCardState *cs)
+dbusy_timer_handler(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, dbusytimer);
 	struct PStack *st;
 	int	rbchd, stard;
 
@@ -298,7 +299,6 @@ dch_fill_fifo(struct IsdnCardState *cs)
 		debugl1(cs, "dch_fill_fifo dbusytimer running");
 		del_timer(&cs->dbusytimer);
 	}
-	init_timer(&cs->dbusytimer);
 	cs->dbusytimer.expires = jiffies + ((DBUSY_TIMER_VALUE * HZ)/1000);
 	add_timer(&cs->dbusytimer);
 
@@ -424,7 +424,7 @@ dch_init(struct IsdnCardState *cs)
 
 	cs->setstack_d      = dch_setstack;
 
-	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
+	timer_setup(&cs->dbusytimer, dbusy_timer_handler, 0);
 
 	cs->writeisac(cs, IPACX_TR_CONF0, 0x00);  // clear LDD
 	cs->writeisac(cs, IPACX_TR_CONF2, 0x00);  // enable transmitter
diff --git a/drivers/isdn/hisax/isac.c b/drivers/isdn/hisax/isac.c
index ea965f29a555..bd40e0671ded 100644
--- a/drivers/isdn/hisax/isac.c
+++ b/drivers/isdn/hisax/isac.c
@@ -171,7 +171,6 @@ isac_fill_fifo(struct IsdnCardState *cs)
 		debugl1(cs, "isac_fill_fifo dbusytimer running");
 		del_timer(&cs->dbusytimer);
 	}
-	init_timer(&cs->dbusytimer);
 	cs->dbusytimer.expires = jiffies + ((DBUSY_TIMER_VALUE * HZ)/1000);
 	add_timer(&cs->dbusytimer);
 	if (cs->debug & L1_DEB_ISAC_FIFO) {
@@ -584,8 +583,9 @@ DC_Close_isac(struct IsdnCardState *cs)
 }
 
 static void
-dbusy_timer_handler(struct IsdnCardState *cs)
+dbusy_timer_handler(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, dbusytimer);
 	struct PStack *stptr;
 	int	rbch, star;
 
@@ -677,5 +677,5 @@ void clear_pending_isac_ints(struct IsdnCardState *cs)
 void setup_isac(struct IsdnCardState *cs)
 {
 	INIT_WORK(&cs->tqueue, isac_bh);
-	setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler, (long)cs);
+	timer_setup(&cs->dbusytimer, dbusy_timer_handler, 0);
 }
diff --git a/drivers/isdn/hisax/isar.c b/drivers/isdn/hisax/isar.c
index 98b4b67ea337..d01ff116797b 100644
--- a/drivers/isdn/hisax/isar.c
+++ b/drivers/isdn/hisax/isar.c
@@ -1267,7 +1267,8 @@ isar_int_main(struct IsdnCardState *cs)
 }
 
 static void
-ftimer_handler(struct BCState *bcs) {
+ftimer_handler(struct timer_list *t) {
+	struct BCState *bcs = from_timer(bcs, t, hw.isar.ftimer);
 	if (bcs->cs->debug)
 		debugl1(bcs->cs, "ftimer flags %04lx",
 			bcs->Flag);
@@ -1902,8 +1903,6 @@ void initisar(struct IsdnCardState *cs)
 	cs->bcs[1].BC_SetStack = setstack_isar;
 	cs->bcs[0].BC_Close = close_isarstate;
 	cs->bcs[1].BC_Close = close_isarstate;
-	setup_timer(&cs->bcs[0].hw.isar.ftimer, (void *)ftimer_handler,
-		    (long)&cs->bcs[0]);
-	setup_timer(&cs->bcs[1].hw.isar.ftimer, (void *)ftimer_handler,
-		    (long)&cs->bcs[1]);
+	timer_setup(&cs->bcs[0].hw.isar.ftimer, ftimer_handler, 0);
+	timer_setup(&cs->bcs[1].hw.isar.ftimer, ftimer_handler, 0);
 }
diff --git a/drivers/isdn/hisax/isdnl3.c b/drivers/isdn/hisax/isdnl3.c
index 569ce52c567b..bb3f9ec62749 100644
--- a/drivers/isdn/hisax/isdnl3.c
+++ b/drivers/isdn/hisax/isdnl3.c
@@ -160,8 +160,9 @@ newl3state(struct l3_process *pc, int state)
 }
 
 static void
-L3ExpireTimer(struct L3Timer *t)
+L3ExpireTimer(struct timer_list *timer)
 {
+	struct L3Timer *t = from_timer(t, timer, tl);
 	t->pc->st->lli.l4l3(t->pc->st, t->event, t->pc);
 }
 
@@ -169,7 +170,7 @@ void
 L3InitTimer(struct l3_process *pc, struct L3Timer *t)
 {
 	t->pc = pc;
-	setup_timer(&t->tl, (void *)L3ExpireTimer, (long)t);
+	timer_setup(&t->tl, L3ExpireTimer, 0);
 }
 
 void
@@ -186,7 +187,6 @@ L3AddTimer(struct L3Timer *t,
 		printk(KERN_WARNING "L3AddTimer: timer already active!\n");
 		return -1;
 	}
-	init_timer(&t->tl);
 	t->event = event;
 	t->tl.expires = jiffies + (millisec * HZ) / 1000;
 	add_timer(&t->tl);
diff --git a/drivers/isdn/hisax/saphir.c b/drivers/isdn/hisax/saphir.c
index 6b2d0eccdd56..db906cb37a3f 100644
--- a/drivers/isdn/hisax/saphir.c
+++ b/drivers/isdn/hisax/saphir.c
@@ -159,8 +159,9 @@ saphir_interrupt(int intno, void *dev_id)
 }
 
 static void
-SaphirWatchDog(struct IsdnCardState *cs)
+SaphirWatchDog(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, hw.saphir.timer);
 	u_long flags;
 
 	spin_lock_irqsave(&cs->lock, flags);
@@ -268,9 +269,7 @@ int setup_saphir(struct IsdnCard *card)
 	       cs->irq, cs->hw.saphir.cfg_reg);
 
 	setup_isac(cs);
-	cs->hw.saphir.timer.function = (void *) SaphirWatchDog;
-	cs->hw.saphir.timer.data = (long) cs;
-	init_timer(&cs->hw.saphir.timer);
+	timer_setup(&cs->hw.saphir.timer, SaphirWatchDog, 0);
 	cs->hw.saphir.timer.expires = jiffies + 4 * HZ;
 	add_timer(&cs->hw.saphir.timer);
 	if (saphir_reset(cs)) {
diff --git a/drivers/isdn/hisax/teleint.c b/drivers/isdn/hisax/teleint.c
index 950399f066ef..247aa33076b1 100644
--- a/drivers/isdn/hisax/teleint.c
+++ b/drivers/isdn/hisax/teleint.c
@@ -179,8 +179,9 @@ TeleInt_interrupt(int intno, void *dev_id)
 }
 
 static void
-TeleInt_Timer(struct IsdnCardState *cs)
+TeleInt_Timer(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, hw.hfc.timer);
 	int stat = 0;
 	u_long flags;
 
@@ -278,7 +279,7 @@ int setup_TeleInt(struct IsdnCard *card)
 	cs->bcs[0].hw.hfc.send = NULL;
 	cs->bcs[1].hw.hfc.send = NULL;
 	cs->hw.hfc.fifosize = 7 * 1024 + 512;
-	setup_timer(&cs->hw.hfc.timer, (void *)TeleInt_Timer, (long)cs);
+	timer_setup(&cs->hw.hfc.timer, TeleInt_Timer, 0);
 	if (!request_region(cs->hw.hfc.addr, 2, "TeleInt isdn")) {
 		printk(KERN_WARNING
 		       "HiSax: TeleInt config port %x-%x already in use\n",
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index 6f6733b7c1e4..c4be1644f5bb 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -188,7 +188,6 @@ W6692_fill_fifo(struct IsdnCardState *cs)
 		debugl1(cs, "W6692_fill_fifo dbusytimer running");
 		del_timer(&cs->dbusytimer);
 	}
-	init_timer(&cs->dbusytimer);
 	cs->dbusytimer.expires = jiffies + ((DBUSY_TIMER_VALUE * HZ) / 1000);
 	add_timer(&cs->dbusytimer);
 	if (cs->debug & L1_DEB_ISAC_FIFO) {
@@ -684,8 +683,9 @@ DC_Close_W6692(struct IsdnCardState *cs)
 }
 
 static void
-dbusy_timer_handler(struct IsdnCardState *cs)
+dbusy_timer_handler(struct timer_list *t)
 {
+	struct IsdnCardState *cs = from_timer(cs, t, dbusytimer);
 	struct PStack *stptr;
 	int rbch, star;
 	u_long flags;
@@ -904,8 +904,7 @@ static void initW6692(struct IsdnCardState *cs, int part)
 	if (part & 1) {
 		cs->setstack_d = setstack_W6692;
 		cs->DC_Close = DC_Close_W6692;
-		setup_timer(&cs->dbusytimer, (void *)dbusy_timer_handler,
-			    (long)cs);
+		timer_setup(&cs->dbusytimer, dbusy_timer_handler, 0);
 		resetW6692(cs);
 		ph_command(cs, W_L1CMD_RST);
 		cs->dc.w6692.ph_state = W_L1CMD_RST;
-- 
2.7.4
