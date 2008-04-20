From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] ISDN cleanups (modularization prep)
Date: Sun, 20 Apr 2008 18:39:59 -0400
Message-ID: <20080420223959.GA17998@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de, Greg KH <greg@kroah.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:45277 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752674AbYDTWkB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Apr 2008 18:40:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


ISDN is the last major subsystem that uses pci_find_* rather than the
"new" PCI hotplug API.  I have [untested (no h/w)] patches that convert
these drivers over to the new PCI API in #isdn-pci.

The changes below prepare us for those changes.  Both changes submitted
here are no-behavior-change patches, simply internal cleanups that
prepare us for #isdn-pci.  If any user is impacted at all, that's a bug.

These changes have been in -mm for spell, though they are not presently
there.  Since this project was started well over a year ago (with LKML,
kkeil, and isdn4linux always CC'd), the only objections raised were
not directly related:

- "isn't ISDN dead?"  Apparently, no it's not :)

- "don't waste your time, drop these drivers and get mISDN into the
  kernel instead" -- based on discussion it does sound like mISDN should
  get into the kernel.  Until these drivers are dropped, however, my
  patches remain appropriate.

And in case people are curious, #isdn-pci isn't ready for upstream yet
for two main reasons: (1) two drivers remain unconverted, and (2) none
of the changes have been tested, even once.

Please pull from 'isdn-cleanups' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/misc-2.6.git isdn-cleanups

to receive the following updates:

 drivers/isdn/hisax/asuscom.c   |    5 +----
 drivers/isdn/hisax/avm_a1.c    |   27 +++++++++------------------
 drivers/isdn/hisax/bkm_a4t.c   |   19 ++++++++++---------
 drivers/isdn/hisax/bkm_a8.c    |   31 +++++++++++++------------------
 drivers/isdn/hisax/config.c    |   14 +++++++++-----
 drivers/isdn/hisax/gazel.c     |    5 ++---
 drivers/isdn/hisax/hfc_pci.c   |    2 --
 drivers/isdn/hisax/hfc_sx.c    |    2 --
 drivers/isdn/hisax/hisax_cfg.h |    2 ++
 drivers/isdn/hisax/isurf.c     |   13 ++++---------
 drivers/isdn/hisax/ix1_micro.c |    9 ++++-----
 drivers/isdn/hisax/mic.c       |    5 +----
 drivers/isdn/hisax/netjet.h    |    2 --
 drivers/isdn/hisax/niccy.c     |   19 ++++++++-----------
 drivers/isdn/hisax/nj_s.c      |    3 +--
 drivers/isdn/hisax/nj_u.c      |    4 ++--
 drivers/isdn/hisax/s0box.c     |   13 ++++---------
 drivers/isdn/hisax/saphir.c    |    8 +++-----
 drivers/isdn/hisax/sportster.c |   11 +++++------
 drivers/isdn/hisax/teleint.c   |    5 +----
 drivers/isdn/hisax/telespci.c  |    5 ++---
 drivers/isdn/hisax/w6692.c     |    2 --
 22 files changed, 81 insertions(+), 125 deletions(-)

Jeff Garzik (2):
      [ISDN] HiSax: modularization prep
      [ISDN] Hisax: eliminate many unnecessary references to CardType[]

diff --git a/drivers/isdn/hisax/asuscom.c b/drivers/isdn/hisax/asuscom.c
index 61e69e9..b96f318 100644
--- a/drivers/isdn/hisax/asuscom.c
+++ b/drivers/isdn/hisax/asuscom.c
@@ -20,8 +20,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
-
 static const char *Asuscom_revision = "$Revision: 1.14.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -376,8 +374,7 @@ setup_asuscom(struct IsdnCard *card)
 	cs->irq = card->para[0];
 	if (!request_region(cs->hw.asus.cfg_reg, bytecnt, "asuscom isdn")) {
 		printk(KERN_WARNING
-		       "HiSax: %s config port %x-%x already in use\n",
-		       CardType[card->typ],
+		       "HiSax: ISDNLink config port %x-%x already in use\n",
 		       cs->hw.asus.cfg_reg,
 		       cs->hw.asus.cfg_reg + bytecnt);
 		return (0);
diff --git a/drivers/isdn/hisax/avm_a1.c b/drivers/isdn/hisax/avm_a1.c
index d9028e9..eb6b432 100644
--- a/drivers/isdn/hisax/avm_a1.c
+++ b/drivers/isdn/hisax/avm_a1.c
@@ -16,7 +16,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
 static const char *avm_revision = "$Revision: 2.15.2.4 $";
 
 #define	 AVM_A1_STAT_ISAC	0x01
@@ -200,16 +199,14 @@ setup_avm_a1(struct IsdnCard *card)
 	cs->irq = card->para[0];
 	if (!request_region(cs->hw.avm.cfg_reg, 8, "avm cfg")) {
 		printk(KERN_WARNING
-		       "HiSax: %s config port %x-%x already in use\n",
-		       CardType[card->typ],
+		       "HiSax: AVM A1 config port %x-%x already in use\n",
 		       cs->hw.avm.cfg_reg,
 		       cs->hw.avm.cfg_reg + 8);
 		return (0);
 	}
 	if (!request_region(cs->hw.avm.isac + 32, 32, "HiSax isac")) {
 		printk(KERN_WARNING
-		       "HiSax: %s isac ports %x-%x already in use\n",
-		       CardType[cs->typ],
+		       "HiSax: AVM A1 isac ports %x-%x already in use\n",
 		       cs->hw.avm.isac + 32,
 		       cs->hw.avm.isac + 64);
 		release_ioregs(cs, 0);
@@ -217,16 +214,14 @@ setup_avm_a1(struct IsdnCard *card)
 	}
 	if (!request_region(cs->hw.avm.isacfifo, 1, "HiSax isac fifo")) {
 		printk(KERN_WARNING
-		       "HiSax: %s isac fifo port %x already in use\n",
-		       CardType[cs->typ],
+		       "HiSax: AVM A1 isac fifo port %x already in use\n",
 		       cs->hw.avm.isacfifo);
 		release_ioregs(cs, 1);
 		return (0);
 	}
 	if (!request_region(cs->hw.avm.hscx[0] + 32, 32, "HiSax hscx A")) {
 		printk(KERN_WARNING
-		       "HiSax: %s hscx A ports %x-%x already in use\n",
-		       CardType[cs->typ],
+		       "HiSax: AVM A1 hscx A ports %x-%x already in use\n",
 		       cs->hw.avm.hscx[0] + 32,
 		       cs->hw.avm.hscx[0] + 64);
 		release_ioregs(cs, 3);
@@ -234,16 +229,14 @@ setup_avm_a1(struct IsdnCard *card)
 	}
 	if (!request_region(cs->hw.avm.hscxfifo[0], 1, "HiSax hscx A fifo")) {
 		printk(KERN_WARNING
-		       "HiSax: %s hscx A fifo port %x already in use\n",
-		       CardType[cs->typ],
+		       "HiSax: AVM A1 hscx A fifo port %x already in use\n",
 		       cs->hw.avm.hscxfifo[0]);
 		release_ioregs(cs, 7);
 		return (0);
 	}
 	if (!request_region(cs->hw.avm.hscx[1] + 32, 32, "HiSax hscx B")) {
 		printk(KERN_WARNING
-		       "HiSax: %s hscx B ports %x-%x already in use\n",
-		       CardType[cs->typ],
+		       "HiSax: AVM A1 hscx B ports %x-%x already in use\n",
 		       cs->hw.avm.hscx[1] + 32,
 		       cs->hw.avm.hscx[1] + 64);
 		release_ioregs(cs, 0xf);
@@ -251,8 +244,7 @@ setup_avm_a1(struct IsdnCard *card)
 	}
 	if (!request_region(cs->hw.avm.hscxfifo[1], 1, "HiSax hscx B fifo")) {
 		printk(KERN_WARNING
-		       "HiSax: %s hscx B fifo port %x already in use\n",
-		       CardType[cs->typ],
+		       "HiSax: AVM A1 hscx B fifo port %x already in use\n",
 		       cs->hw.avm.hscxfifo[1]);
 		release_ioregs(cs, 0x1f);
 		return (0);
@@ -284,9 +276,8 @@ setup_avm_a1(struct IsdnCard *card)
 	printk(KERN_INFO "AVM A1: Byte at %x is %x\n",
 	       cs->hw.avm.cfg_reg, val);
 
-	printk(KERN_INFO
-	       "HiSax: %s config irq:%d cfg:0x%X\n",
-	       CardType[cs->typ], cs->irq,
+	printk(KERN_INFO "HiSax: AVM A1 config irq:%d cfg:0x%X\n",
+	       cs->irq,
 	       cs->hw.avm.cfg_reg);
 	printk(KERN_INFO
 	       "HiSax: isac:0x%X/0x%X\n",
diff --git a/drivers/isdn/hisax/bkm_a4t.c b/drivers/isdn/hisax/bkm_a4t.c
index 3d1bdc8..9ca2ee5 100644
--- a/drivers/isdn/hisax/bkm_a4t.c
+++ b/drivers/isdn/hisax/bkm_a4t.c
@@ -20,8 +20,6 @@
 #include <linux/pci.h>
 #include "bkm_ax.h"
 
-extern const char *CardType[];
-
 static const char *bkm_a4t_revision = "$Revision: 1.22.2.4 $";
 
 
@@ -284,15 +282,16 @@ static int __devinit a4t_cs_init(struct IsdnCard *card,
 	I20_REGISTER_FILE *pI20_Regs;
 
 	if (!cs->irq) {		/* IRQ range check ?? */
-		printk(KERN_WARNING "HiSax: %s: No IRQ\n", CardType[card->typ]);
+		printk(KERN_WARNING "HiSax: Telekom A4T: No IRQ\n");
 		return (0);
 	}
 	cs->hw.ax.base = (long) ioremap(pci_memaddr, 4096);
 	/* Check suspecious address */
 	pI20_Regs = (I20_REGISTER_FILE *) (cs->hw.ax.base);
 	if ((pI20_Regs->i20IntStatus & 0x8EFFFFFF) != 0) {
-		printk(KERN_WARNING "HiSax: %s address %lx-%lx suspecious\n",
-		       CardType[card->typ], cs->hw.ax.base, cs->hw.ax.base + 4096);
+		printk(KERN_WARNING "HiSax: Telekom A4T address "
+		       "%lx-%lx suspicious\n",
+		       cs->hw.ax.base, cs->hw.ax.base + 4096);
 		iounmap((void *) cs->hw.ax.base);
 		cs->hw.ax.base = 0;
 		return (0);
@@ -302,8 +301,9 @@ static int __devinit a4t_cs_init(struct IsdnCard *card,
 	cs->hw.ax.isac_ale = GCS_1;
 	cs->hw.ax.jade_ale = GCS_3;
 
-	printk(KERN_INFO "HiSax: %s: Card configured at 0x%lX IRQ %d\n",
-	       CardType[card->typ], cs->hw.ax.base, cs->irq);
+	printk(KERN_INFO "HiSax: Telekom A4T: Card configured at "
+	       "0x%lX IRQ %d\n",
+	       cs->hw.ax.base, cs->irq);
 
 	setup_isac(cs);
 	cs->readisac = &ReadISAC;
@@ -349,11 +349,12 @@ setup_bkm_a4t(struct IsdnCard *card)
 			break;
 	}
 	if (!found) {
-		printk(KERN_WARNING "HiSax: %s: Card not found\n", CardType[card->typ]);
+		printk(KERN_WARNING "HiSax: Telekom A4T: Card not found\n");
 		return (0);
 	}
 	if (!pci_memaddr) {
-		printk(KERN_WARNING "HiSax: %s: No Memory base address\n", CardType[card->typ]);
+		printk(KERN_WARNING "HiSax: Telekom A4T: "
+		       "No Memory base address\n");
 		return (0);
 	}
 
diff --git a/drivers/isdn/hisax/bkm_a8.c b/drivers/isdn/hisax/bkm_a8.c
index 99ef3b4..e1ff471 100644
--- a/drivers/isdn/hisax/bkm_a8.c
+++ b/drivers/isdn/hisax/bkm_a8.c
@@ -22,8 +22,6 @@
 
 #define	ATTEMPT_PCI_REMAPPING	/* Required for PLX rev 1 */
 
-extern const char *CardType[];
-
 static const char sct_quadro_revision[] = "$Revision: 1.22.2.4 $";
 
 static const char *sct_quadro_subtypes[] =
@@ -181,8 +179,7 @@ bkm_interrupt_ipac(int intno, void *dev_id)
 		goto Start_IPAC;
 	}
 	if (!icnt)
-		printk(KERN_WARNING "HiSax: %s (%s) IRQ LOOP\n",
-		       CardType[cs->typ],
+		printk(KERN_WARNING "HiSax: Scitel Quadro (%s) IRQ LOOP\n",
 		       sct_quadro_subtypes[cs->subtyp]);
 	writereg(cs->hw.ax.base, cs->hw.ax.data_adr, IPAC_MASK, 0xFF);
 	writereg(cs->hw.ax.base, cs->hw.ax.data_adr, IPAC_MASK, 0xC0);
@@ -296,8 +293,8 @@ setup_sct_quadro(struct IsdnCard *card)
 	if (card->para[0] >= SCT_1 && card->para[0] <= SCT_4)
 		cs->subtyp = card->para[0];
 	else {
-		printk(KERN_WARNING "HiSax: %s: Invalid subcontroller in configuration, default to 1\n",
-			CardType[card->typ]);
+		printk(KERN_WARNING "HiSax: Scitel Quadro: Invalid "
+		       "subcontroller in configuration, default to 1\n");
 		return (0);
 	}
 	if ((cs->subtyp != SCT_1) && ((sub_sys_id != PCI_DEVICE_ID_BERKOM_SCITEL_QUADRO) ||
@@ -322,16 +319,16 @@ setup_sct_quadro(struct IsdnCard *card)
 			}
 		}
 		if (!found) {
-			printk(KERN_WARNING "HiSax: %s (%s): Card not found\n",
-				CardType[card->typ],
+			printk(KERN_WARNING "HiSax: Scitel Quadro (%s): "
+				"Card not found\n",
 				sct_quadro_subtypes[cs->subtyp]);
 			return (0);
 		}
 #ifdef ATTEMPT_PCI_REMAPPING
 /* HACK: PLX revision 1 bug: PLX address bit 7 must not be set */
 		if ((pci_ioaddr1 & 0x80) && (dev_a8->revision == 1)) {
-			printk(KERN_WARNING "HiSax: %s (%s): PLX rev 1, remapping required!\n",
-				CardType[card->typ],
+			printk(KERN_WARNING "HiSax: Scitel Quadro (%s): "
+				"PLX rev 1, remapping required!\n",
 				sct_quadro_subtypes[cs->subtyp]);
 			/* Restart PCI negotiation */
 			pci_write_config_dword(dev_a8, PCI_BASE_ADDRESS_1, (u_int) - 1);
@@ -344,8 +341,7 @@ setup_sct_quadro(struct IsdnCard *card)
 #endif /* End HACK */
 	}
 	if (!pci_irq) {		/* IRQ range check ?? */
-		printk(KERN_WARNING "HiSax: %s (%s): No IRQ\n",
-		       CardType[card->typ],
+		printk(KERN_WARNING "HiSax: Scitel Quadro (%s): No IRQ\n",
 		       sct_quadro_subtypes[cs->subtyp]);
 		return (0);
 	}
@@ -355,8 +351,8 @@ setup_sct_quadro(struct IsdnCard *card)
 	pci_read_config_dword(dev_a8, PCI_BASE_ADDRESS_4, &pci_ioaddr4);
 	pci_read_config_dword(dev_a8, PCI_BASE_ADDRESS_5, &pci_ioaddr5);
 	if (!pci_ioaddr1 || !pci_ioaddr2 || !pci_ioaddr3 || !pci_ioaddr4 || !pci_ioaddr5) {
-		printk(KERN_WARNING "HiSax: %s (%s): No IO base address(es)\n",
-		       CardType[card->typ],
+		printk(KERN_WARNING "HiSax: Scitel Quadro (%s): "
+		       "No IO base address(es)\n",
 		       sct_quadro_subtypes[cs->subtyp]);
 		return (0);
 	}
@@ -411,8 +407,8 @@ setup_sct_quadro(struct IsdnCard *card)
 	/* For isac and hscx data path */
 	cs->hw.ax.data_adr = cs->hw.ax.base + 4;
 
-	printk(KERN_INFO "HiSax: %s (%s) configured at 0x%.4lX, 0x%.4lX, 0x%.4lX and IRQ %d\n",
-	       CardType[card->typ],
+	printk(KERN_INFO "HiSax: Scitel Quadro (%s) configured at "
+	       "0x%.4lX, 0x%.4lX, 0x%.4lX and IRQ %d\n",
 	       sct_quadro_subtypes[cs->subtyp],
 	       cs->hw.ax.plx_adr,
 	       cs->hw.ax.base,
@@ -432,8 +428,7 @@ setup_sct_quadro(struct IsdnCard *card)
 	cs->cardmsg = &BKM_card_msg;
 	cs->irq_func = &bkm_interrupt_ipac;
 
-	printk(KERN_INFO "HiSax: %s (%s): IPAC Version %d\n",
-		CardType[card->typ],
+	printk(KERN_INFO "HiSax: Scitel Quadro (%s): IPAC Version %d\n",
 		sct_quadro_subtypes[cs->subtyp],
 		readreg(cs->hw.ax.base, cs->hw.ax.data_adr, IPAC_ID));
 	return (1);
diff --git a/drivers/isdn/hisax/config.c b/drivers/isdn/hisax/config.c
index a0ee43c..84d75a3 100644
--- a/drivers/isdn/hisax/config.c
+++ b/drivers/isdn/hisax/config.c
@@ -1169,7 +1169,9 @@ outf_cs:
 /* Used from an exported function but calls __devinit functions.
  * Tell modpost not to warn (__ref)
  */
-static int __ref checkcard(int cardnr, char *id, int *busy_flag, struct module *lockowner)
+static int __ref checkcard(int cardnr, char *id, int *busy_flag,
+			   struct module *lockowner,
+			   hisax_setup_func_t card_setup)
 {
 	int ret;
 	struct IsdnCard *card = cards + cardnr;
@@ -1187,7 +1189,7 @@ static int __ref checkcard(int cardnr, char *id, int *busy_flag, struct module *
 	       (card->protocol == ISDN_PTYPE_NI1) ? "NI1" :
 	       "NONE", cs->iif.id, cs->myid);
 
-	ret = hisax_cs_setup_card(card);
+	ret = card_setup(card);
 	if (!ret) {
 		ll_unload(cs);
 		goto outf_cs;
@@ -1241,7 +1243,8 @@ static int HiSax_inithardware(int *busy_flag)
 			else
 				sprintf(ids, "%s%d", id, i);
 		}
-		if (checkcard(i, ids, busy_flag, THIS_MODULE)) {
+		if (checkcard(i, ids, busy_flag, THIS_MODULE,
+			      hisax_cs_setup_card)) {
 			foundcards++;
 			i++;
 		} else {
@@ -1549,7 +1552,8 @@ int hisax_init_pcmcia(void *pcm_iob, int *busy_flag, struct IsdnCard *card)
 		sprintf(ids, "HiSax%d", nrcards);
 	else
 		sprintf(ids, "HiSax");
-	if (!checkcard(nrcards, ids, busy_flag, THIS_MODULE))
+	if (!checkcard(nrcards, ids, busy_flag, THIS_MODULE,
+		       hisax_cs_setup_card))
 		goto error;
 
 	ret = nrcards;
@@ -1595,7 +1599,7 @@ int hisax_register(struct hisax_d_if *hisax_d_if, struct hisax_b_if *b_if[],
 	cards[i].protocol = protocol;
 	sprintf(id, "%s%d", name, i);
 	nrcards++;
-	retval = checkcard(i, id, NULL, hisax_d_if->owner);
+	retval = checkcard(i, id, NULL, hisax_d_if->owner, hisax_cs_setup_card);
 	if (retval == 0) { // yuck
 		cards[i].typ = 0;
 		nrcards--;
diff --git a/drivers/isdn/hisax/gazel.c b/drivers/isdn/hisax/gazel.c
index f66620a..0ea3b46 100644
--- a/drivers/isdn/hisax/gazel.c
+++ b/drivers/isdn/hisax/gazel.c
@@ -19,7 +19,6 @@
 #include "ipac.h"
 #include <linux/pci.h>
 
-extern const char *CardType[];
 static const char *gazel_revision = "$Revision: 2.19.2.4 $";
 
 #define R647      1
@@ -479,8 +478,8 @@ reserve_regions(struct IsdnCard *card, struct IsdnCardState *cs)
 	return 0;
 
       error:
-	printk(KERN_WARNING "Gazel: %s io ports 0x%x-0x%x already in use\n",
-	       CardType[cs->typ], adr, adr + len);
+	printk(KERN_WARNING "Gazel: io ports 0x%x-0x%x already in use\n",
+	       adr, adr + len);
 	return 1;
 }
 
diff --git a/drivers/isdn/hisax/hfc_pci.c b/drivers/isdn/hisax/hfc_pci.c
index fba8b62..f126566 100644
--- a/drivers/isdn/hisax/hfc_pci.c
+++ b/drivers/isdn/hisax/hfc_pci.c
@@ -22,8 +22,6 @@
 #include <linux/pci.h>
 #include <linux/interrupt.h>
 
-extern const char *CardType[];
-
 static const char *hfcpci_revision = "$Revision: 1.48.2.4 $";
 
 /* table entry in the PCI devices list */
diff --git a/drivers/isdn/hisax/hfc_sx.c b/drivers/isdn/hisax/hfc_sx.c
index 05482d2..f4a2138 100644
--- a/drivers/isdn/hisax/hfc_sx.c
+++ b/drivers/isdn/hisax/hfc_sx.c
@@ -18,8 +18,6 @@
 #include <linux/interrupt.h>
 #include <linux/isapnp.h>
 
-extern const char *CardType[];
-
 static const char *hfcsx_revision = "$Revision: 1.12.2.5 $";
 
 /***************************************/
diff --git a/drivers/isdn/hisax/hisax_cfg.h b/drivers/isdn/hisax/hisax_cfg.h
index ca3fe62..17a2fea 100644
--- a/drivers/isdn/hisax/hisax_cfg.h
+++ b/drivers/isdn/hisax/hisax_cfg.h
@@ -60,5 +60,7 @@ struct IsdnCard {
 	IsdnCardState_t	*cs;
 };
 
+typedef int (*hisax_setup_func_t)(struct IsdnCard *card);
+
 extern void	HiSax_closecard(int);
 extern int	hisax_init_pcmcia(void *, int *, IsdnCard_t *);
diff --git a/drivers/isdn/hisax/isurf.c b/drivers/isdn/hisax/isurf.c
index 55de069..ca41617 100644
--- a/drivers/isdn/hisax/isurf.c
+++ b/drivers/isdn/hisax/isurf.c
@@ -17,8 +17,6 @@
 #include "isdnl1.h"
 #include <linux/isapnp.h>
 
-extern const char *CardType[];
-
 static const char *ISurf_revision = "$Revision: 1.12.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -251,22 +249,19 @@ setup_isurf(struct IsdnCard *card)
 			return(0);
 		}
 #else
-		printk(KERN_WARNING "HiSax: %s port/mem not set\n",
-			CardType[card->typ]);
+		printk(KERN_WARNING "HiSax: Siemens I-Surf port/mem not set\n");
 		return (0);
 #endif
 	}
 	if (!request_region(cs->hw.isurf.reset, 1, "isurf isdn")) {
 		printk(KERN_WARNING
-			"HiSax: %s config port %x already in use\n",
-			CardType[card->typ],
+			"HiSax: Siemens I-Surf config port %x already in use\n",
 			cs->hw.isurf.reset);
 			return (0);
 	}
 	if (!request_region(cs->hw.isurf.phymem, ISURF_IOMEM_SIZE, "isurf iomem")) {
-		printk(KERN_WARNING
-			"HiSax: %s memory region %lx-%lx already in use\n",
-			CardType[card->typ],
+		printk(KERN_WARNING "HiSax: Siemens I-Surf memory region "
+			"%lx-%lx already in use\n",
 			cs->hw.isurf.phymem,
 			cs->hw.isurf.phymem + ISURF_IOMEM_SIZE);
 		release_region(cs->hw.isurf.reset, 1);
diff --git a/drivers/isdn/hisax/ix1_micro.c b/drivers/isdn/hisax/ix1_micro.c
index 252d79d..2d18d4f 100644
--- a/drivers/isdn/hisax/ix1_micro.c
+++ b/drivers/isdn/hisax/ix1_micro.c
@@ -24,7 +24,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
 static const char *ix1_revision = "$Revision: 2.12.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -288,15 +287,15 @@ setup_ix1micro(struct IsdnCard *card)
 	if (cs->hw.ix1.cfg_reg) {
 		if (!request_region(cs->hw.ix1.cfg_reg, 4, "ix1micro cfg")) {
 			printk(KERN_WARNING
-			  "HiSax: %s config port %x-%x already in use\n",
-			       CardType[card->typ],
+			  "HiSax: ITK ix1-micro Rev.2 config port "
+			  "%x-%x already in use\n",
 			       cs->hw.ix1.cfg_reg,
 			       cs->hw.ix1.cfg_reg + 4);
 			return (0);
 		}
 	}
-	printk(KERN_INFO "HiSax: %s config irq:%d io:0x%X\n",
-		CardType[cs->typ], cs->irq, cs->hw.ix1.cfg_reg);
+	printk(KERN_INFO "HiSax: ITK ix1-micro Rev.2 config irq:%d io:0x%X\n",
+		cs->irq, cs->hw.ix1.cfg_reg);
 	setup_isac(cs);
 	cs->readisac = &ReadISAC;
 	cs->writeisac = &WriteISAC;
diff --git a/drivers/isdn/hisax/mic.c b/drivers/isdn/hisax/mic.c
index a81d175..2539430 100644
--- a/drivers/isdn/hisax/mic.c
+++ b/drivers/isdn/hisax/mic.c
@@ -16,8 +16,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
-
 static const char *mic_revision = "$Revision: 1.12.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -210,8 +208,7 @@ setup_mic(struct IsdnCard *card)
 
 	if (!request_region(cs->hw.mic.cfg_reg, bytecnt, "mic isdn")) {
 		printk(KERN_WARNING
-		       "HiSax: %s config port %x-%x already in use\n",
-		       CardType[card->typ],
+		       "HiSax: ith mic config port %x-%x already in use\n",
 		       cs->hw.mic.cfg_reg,
 		       cs->hw.mic.cfg_reg + bytecnt);
 		return (0);
diff --git a/drivers/isdn/hisax/netjet.h b/drivers/isdn/hisax/netjet.h
index 4d89d3e..68e504d 100644
--- a/drivers/isdn/hisax/netjet.h
+++ b/drivers/isdn/hisax/netjet.h
@@ -12,8 +12,6 @@
  *
  */
 
-extern const char *CardType[];
-
 #define byteout(addr,val) outb(val,addr)
 #define bytein(addr) inb(addr)
 
diff --git a/drivers/isdn/hisax/niccy.c b/drivers/isdn/hisax/niccy.c
index bd99211..421b8e6 100644
--- a/drivers/isdn/hisax/niccy.c
+++ b/drivers/isdn/hisax/niccy.c
@@ -21,7 +21,6 @@
 #include <linux/pci.h>
 #include <linux/isapnp.h>
 
-extern const char *CardType[];
 static const char *niccy_revision = "$Revision: 1.21.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -284,14 +283,14 @@ int __devinit setup_niccy(struct IsdnCard *card)
 		cs->subtyp = NICCY_PNP;
 		cs->irq = card->para[0];
 		if (!request_region(cs->hw.niccy.isac, 2, "niccy data")) {
-			printk(KERN_WARNING "HiSax: %s data port %x-%x "
-				"already in use\n", CardType[card->typ],
+			printk(KERN_WARNING "HiSax: NICCY data port %x-%x "
+				"already in use\n",
 				cs->hw.niccy.isac, cs->hw.niccy.isac + 1);
 			return 0;
 		}
 		if (!request_region(cs->hw.niccy.isac_ale, 2, "niccy addr")) {
-			printk(KERN_WARNING "HiSax: %s address port %x-%x "
-				"already in use\n", CardType[card->typ],
+			printk(KERN_WARNING "HiSax: NICCY address port %x-%x "
+				"already in use\n",
 				cs->hw.niccy.isac_ale,
 				cs->hw.niccy.isac_ale + 1);
 			release_region(cs->hw.niccy.isac, 2);
@@ -339,15 +338,13 @@ int __devinit setup_niccy(struct IsdnCard *card)
 		cs->hw.niccy.hscx_ale = pci_ioaddr + HSCX_PCI_ADDR;
 		if (!request_region(cs->hw.niccy.isac, 4, "niccy")) {
 			printk(KERN_WARNING
-			       "HiSax: %s data port %x-%x already in use\n",
-			       CardType[card->typ],
+			       "HiSax: NICCY data port %x-%x already in use\n",
 			       cs->hw.niccy.isac, cs->hw.niccy.isac + 4);
 			return 0;
 		}
 		if (!request_region(cs->hw.niccy.cfg_reg, 0x40, "niccy pci")) {
 			printk(KERN_WARNING
-			       "HiSax: %s pci port %x-%x already in use\n",
-			       CardType[card->typ],
+			       "HiSax: NICCY pci port %x-%x already in use\n",
 			       cs->hw.niccy.cfg_reg,
 			       cs->hw.niccy.cfg_reg + 0x40);
 			release_region(cs->hw.niccy.isac, 4);
@@ -359,8 +356,8 @@ int __devinit setup_niccy(struct IsdnCard *card)
 		return 0;
 #endif				/* CONFIG_PCI_LEGACY */
 	}
-	printk(KERN_INFO "HiSax: %s %s config irq:%d data:0x%X ale:0x%X\n",
-		CardType[cs->typ], (cs->subtyp == 1) ? "PnP" : "PCI",
+	printk(KERN_INFO "HiSax: NICCY %s config irq:%d data:0x%X ale:0x%X\n",
+		(cs->subtyp == 1) ? "PnP" : "PCI",
 		cs->irq, cs->hw.niccy.isac, cs->hw.niccy.isac_ale);
 	setup_isac(cs);
 	cs->readisac = &ReadISAC;
diff --git a/drivers/isdn/hisax/nj_s.c b/drivers/isdn/hisax/nj_s.c
index a895dfe..8d36ccc 100644
--- a/drivers/isdn/hisax/nj_s.c
+++ b/drivers/isdn/hisax/nj_s.c
@@ -235,8 +235,7 @@ static int __devinit njs_cs_init_rest(struct IsdnCard *card,
 		cs->subtyp ? "TJ320" : "TJ300", cs->hw.njet.base, cs->irq);
 	if (!request_region(cs->hw.njet.base, bytecnt, "netjet-s isdn")) {
 		printk(KERN_WARNING
-		       "HiSax: %s config port %#lx-%#lx already in use\n",
-		       CardType[card->typ],
+		       "HiSax: NETjet-S config port %#lx-%#lx already in use\n",
 		       cs->hw.njet.base,
 		       cs->hw.njet.base + bytecnt);
 		return (0);
diff --git a/drivers/isdn/hisax/nj_u.c b/drivers/isdn/hisax/nj_u.c
index f017d38..d306c94 100644
--- a/drivers/isdn/hisax/nj_u.c
+++ b/drivers/isdn/hisax/nj_u.c
@@ -197,8 +197,8 @@ static int __devinit nju_cs_init_rest(struct IsdnCard *card,
 		cs->hw.njet.base, cs->irq);
 	if (!request_region(cs->hw.njet.base, bytecnt, "netspider-u isdn")) {
 		printk(KERN_WARNING
-		       "HiSax: %s config port %#lx-%#lx already in use\n",
-		       CardType[card->typ],
+		       "HiSax: NETspider-U config port %#lx-%#lx "
+		       "already in use\n",
 		       cs->hw.njet.base,
 		       cs->hw.njet.base + bytecnt);
 		return (0);
diff --git a/drivers/isdn/hisax/s0box.c b/drivers/isdn/hisax/s0box.c
index 150ef68..16d00b5 100644
--- a/drivers/isdn/hisax/s0box.c
+++ b/drivers/isdn/hisax/s0box.c
@@ -16,7 +16,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
 static const char *s0box_revision = "$Revision: 2.6.2.4 $";
 
 static inline void
@@ -231,19 +230,15 @@ setup_s0box(struct IsdnCard *card)
 	cs->hw.teles3.hscxfifo[1] = cs->hw.teles3.hscx[1] + 0x3e;
 	cs->irq = card->para[0];
 	if (!request_region(cs->hw.teles3.cfg_reg,8, "S0Box parallel I/O")) {
-		printk(KERN_WARNING
-		       "HiSax: %s ports %x-%x already in use\n",
-		       CardType[cs->typ],
+		printk(KERN_WARNING "HiSax: S0Box ports %x-%x already in use\n",
                        cs->hw.teles3.cfg_reg,
                        cs->hw.teles3.cfg_reg + 7);
 		return 0;
 	}
-	printk(KERN_INFO
-		"HiSax: %s config irq:%d isac:0x%x  cfg:0x%x\n",
-		CardType[cs->typ], cs->irq,
+	printk(KERN_INFO "HiSax: S0Box config irq:%d isac:0x%x  cfg:0x%x\n",
+		cs->irq,
 		cs->hw.teles3.isac, cs->hw.teles3.cfg_reg);
-	printk(KERN_INFO
-		"HiSax: hscx A:0x%x  hscx B:0x%x\n",
+	printk(KERN_INFO "HiSax: hscx A:0x%x  hscx B:0x%x\n",
 		cs->hw.teles3.hscx[0], cs->hw.teles3.hscx[1]);
 	setup_isac(cs);
 	cs->readisac = &ReadISAC;
diff --git a/drivers/isdn/hisax/saphir.c b/drivers/isdn/hisax/saphir.c
index c99b166..b34a81d 100644
--- a/drivers/isdn/hisax/saphir.c
+++ b/drivers/isdn/hisax/saphir.c
@@ -18,7 +18,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
 static char *saphir_rev = "$Revision: 1.10.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -260,15 +259,14 @@ setup_saphir(struct IsdnCard *card)
 	cs->irq = card->para[0];
 	if (!request_region(cs->hw.saphir.cfg_reg, 6, "saphir")) {
 		printk(KERN_WARNING
-			"HiSax: %s config port %x-%x already in use\n",
-			CardType[card->typ],
+			"HiSax: HST Saphir config port %x-%x already in use\n",
 			cs->hw.saphir.cfg_reg,
 			cs->hw.saphir.cfg_reg + 5);
 		return (0);
 	}
 
-	printk(KERN_INFO "HiSax: %s config irq:%d io:0x%X\n",
-		CardType[cs->typ], cs->irq, cs->hw.saphir.cfg_reg);
+	printk(KERN_INFO "HiSax: HST Saphir config irq:%d io:0x%X\n",
+	       cs->irq, cs->hw.saphir.cfg_reg);
 
 	setup_isac(cs);
 	cs->hw.saphir.timer.function = (void *) SaphirWatchDog;
diff --git a/drivers/isdn/hisax/sportster.c b/drivers/isdn/hisax/sportster.c
index 0220950..0a53759 100644
--- a/drivers/isdn/hisax/sportster.c
+++ b/drivers/isdn/hisax/sportster.c
@@ -18,7 +18,6 @@
 #include "hscx.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
 static const char *sportster_revision = "$Revision: 1.16.2.4 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -192,9 +191,9 @@ get_io_range(struct IsdnCardState *cs)
 	for (i=0;i<64;i++) {
 		adr = cs->hw.spt.cfg_reg + i *1024;
 		if (!request_region(adr, 8, "sportster")) {
-			printk(KERN_WARNING
-				"HiSax: %s config port %x-%x already in use\n",
-				CardType[cs->typ], adr, adr + 8);
+			printk(KERN_WARNING "HiSax: USR Sportster config port "
+				"%x-%x already in use\n",
+				adr, adr + 8);
 			break;
 		} 
 	}
@@ -247,8 +246,8 @@ setup_sportster(struct IsdnCard *card)
 			printk(KERN_WARNING "Sportster: wrong IRQ\n");
 			return(0);
 	}
-	printk(KERN_INFO "HiSax: %s config irq:%d cfg:0x%X\n",
-		CardType[cs->typ], cs->irq, cs->hw.spt.cfg_reg);
+	printk(KERN_INFO "HiSax: USR Sportster config irq:%d cfg:0x%X\n",
+		cs->irq, cs->hw.spt.cfg_reg);
 	setup_isac(cs);
 	cs->readisac = &ReadISAC;
 	cs->writeisac = &WriteISAC;
diff --git a/drivers/isdn/hisax/teleint.c b/drivers/isdn/hisax/teleint.c
index 0909662..b0ce4ae 100644
--- a/drivers/isdn/hisax/teleint.c
+++ b/drivers/isdn/hisax/teleint.c
@@ -16,8 +16,6 @@
 #include "hfc_2bs0.h"
 #include "isdnl1.h"
 
-extern const char *CardType[];
-
 static const char *TeleInt_revision = "$Revision: 1.16.2.5 $";
 
 #define byteout(addr,val) outb(val,addr)
@@ -286,8 +284,7 @@ setup_TeleInt(struct IsdnCard *card)
 	init_timer(&cs->hw.hfc.timer);
 	if (!request_region(cs->hw.hfc.addr, 2, "TeleInt isdn")) {
 		printk(KERN_WARNING
-		       "HiSax: %s config port %x-%x already in use\n",
-		       CardType[card->typ],
+		       "HiSax: TeleInt config port %x-%x already in use\n",
 		       cs->hw.hfc.addr,
 		       cs->hw.hfc.addr + 2);
 		return (0);
diff --git a/drivers/isdn/hisax/telespci.c b/drivers/isdn/hisax/telespci.c
index 4393003..28b08de 100644
--- a/drivers/isdn/hisax/telespci.c
+++ b/drivers/isdn/hisax/telespci.c
@@ -19,7 +19,6 @@
 #include "isdnl1.h"
 #include <linux/pci.h>
 
-extern const char *CardType[];
 static const char *telespci_revision = "$Revision: 2.23.2.3 $";
 
 #define ZORAN_PO_RQ_PEN	0x02000000
@@ -329,8 +328,8 @@ setup_telespci(struct IsdnCard *card)
 	/* writel(0x00800000, cs->hw.teles0.membase + 0x200); */
 
 	printk(KERN_INFO
-	       "HiSax: %s config irq:%d mem:%p\n",
-	       CardType[cs->typ], cs->irq,
+	       "HiSax: Teles PCI config irq:%d mem:%p\n",
+	       cs->irq,
 	       cs->hw.teles0.membase);
 
 	setup_isac(cs);
diff --git a/drivers/isdn/hisax/w6692.c b/drivers/isdn/hisax/w6692.c
index 39129b9..bb1c8dd 100644
--- a/drivers/isdn/hisax/w6692.c
+++ b/drivers/isdn/hisax/w6692.c
@@ -38,8 +38,6 @@ static const PCI_ENTRY id_list[] =
 #define W6692_DYNALINK 1
 #define W6692_USR      2
 
-extern const char *CardType[];
-
 static const char *w6692_revision = "$Revision: 1.18.2.4 $";
 
 #define DBUSY_TIMER_VALUE 80
