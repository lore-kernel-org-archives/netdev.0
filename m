From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 9/9][v2] mISDN: hfcmulti: use __iomem address space modifier
Date: Thu, 11 Dec 2008 22:36:00 +0100
Message-ID: <49419a44.09c5660a.39e6.65f7@mx.google.com>
Cc: Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759072AbYLKW4U@vger.kernel.org>
Cc: linux-kernel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Impact: make use of the __iomem address space modifier, and change u_char *,
u_short * and u_int * to void *

Fix more than 30 sparse warnings of this or similar type:

  drivers/isdn/hardware/mISDN/hfcmulti.c:261:31: warning: incorrect type in argument 2 (different address spaces)
  drivers/isdn/hardware/mISDN/hfcmulti.c:261:31:    got unsigned char [usertype] *
  drivers/isdn/hardware/mISDN/hfcmulti.c:261:31:    expected void volatile [noderef] <asn:2>*addr

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Karsten Keil <kkeil@suse.de>
---
 drivers/isdn/hardware/mISDN/hfc_multi.h |    4 +-
 drivers/isdn/hardware/mISDN/hfcmulti.c  |   44 ++++++++++++++++--------------
 2 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfc_multi.h b/drivers/isdn/hardware/mISDN/hfc_multi.h
index a33d87a..7bbf730 100644
--- a/drivers/isdn/hardware/mISDN/hfc_multi.h
+++ b/drivers/isdn/hardware/mISDN/hfc_multi.h
@@ -162,8 +162,8 @@ struct hfc_multi {
 	void		(*write_fifo)(struct hfc_multi *hc, u_char *data,
 				int len);
 	u_long		pci_origmembase, plx_origmembase, dsp_origmembase;
-	u_char		*pci_membase; /* PCI memory (MUST BE BYTE POINTER) */
-	u_char		*plx_membase; /* PLX memory */
+	void __iomem	*pci_membase; /* PCI memory */
+	void __iomem	*plx_membase; /* PLX memory */
 	u_char		*dsp_membase; /* DSP on PLX */
 	u_long		pci_iobase; /* PCI IO */
 	struct hfcm_hw	hw;	/* remember data of write-only-registers */
diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 0668072..c63e2f4 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -889,7 +889,8 @@ static inline void
 hfcmulti_resync(struct hfc_multi *locked, struct hfc_multi *newmaster, int rm)
 {
 	struct hfc_multi *hc, *next, *pcmmaster = NULL;
-	u_int *plx_acc_32, pv;
+	void __iomem *plx_acc_32;
+	u_int pv;
 	u_long flags;
 
 	spin_lock_irqsave(&HFClock, flags);
@@ -917,7 +918,7 @@ hfcmulti_resync(struct hfc_multi *locked, struct hfc_multi *newmaster, int rm)
 	/* Disable sync of all cards */
 	list_for_each_entry_safe(hc, next, &HFClist, list) {
 		if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
-			plx_acc_32 = (u_int *)(hc->plx_membase+PLX_GPIOC);
+			plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 			pv = readl(plx_acc_32);
 			pv &= ~PLX_SYNC_O_EN;
 			writel(pv, plx_acc_32);
@@ -939,7 +940,7 @@ hfcmulti_resync(struct hfc_multi *locked, struct hfc_multi *newmaster, int rm)
 			printk(KERN_DEBUG "id=%d (0x%p) = syncronized with "
 				"interface.\n", hc->id, hc);
 		/* Enable new sync master */
-		plx_acc_32 = (u_int *)(hc->plx_membase+PLX_GPIOC);
+		plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 		pv = readl(plx_acc_32);
 		pv |= PLX_SYNC_O_EN;
 		writel(pv, plx_acc_32);
@@ -969,7 +970,7 @@ hfcmulti_resync(struct hfc_multi *locked, struct hfc_multi *newmaster, int rm)
 					    "QUARTZ is automatically "
 					    "enabled by HFC-%dS\n", hc->type);
 			}
-			plx_acc_32 = (u_int *)(hc->plx_membase+PLX_GPIOC);
+			plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 			pv = readl(plx_acc_32);
 			pv |= PLX_SYNC_O_EN;
 			writel(pv, plx_acc_32);
@@ -1014,7 +1015,8 @@ plxsd_checksync(struct hfc_multi *hc, int rm)
 static void
 release_io_hfcmulti(struct hfc_multi *hc)
 {
-	u_int	*plx_acc_32, pv;
+	void __iomem *plx_acc_32;
+	u_int	pv;
 	u_long	plx_flags;
 
 	if (debug & DEBUG_HFCMULTI_INIT)
@@ -1034,7 +1036,7 @@ release_io_hfcmulti(struct hfc_multi *hc)
 			printk(KERN_DEBUG "%s: release PLXSD card %d\n",
 			    __func__, hc->id + 1);
 		spin_lock_irqsave(&plx_lock, plx_flags);
-		plx_acc_32 = (u_int *)(hc->plx_membase+PLX_GPIOC);
+		plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 		writel(PLX_GPIOC_INIT, plx_acc_32);
 		pv = readl(plx_acc_32);
 		/* Termination off */
@@ -1056,9 +1058,9 @@ release_io_hfcmulti(struct hfc_multi *hc)
 	test_and_clear_bit(HFC_CHIP_PLXSD, &hc->chip); /* prevent resync */
 	pci_write_config_word(hc->pci_dev, PCI_COMMAND, 0);
 	if (hc->pci_membase)
-		iounmap((void *)hc->pci_membase);
+		iounmap(hc->pci_membase);
 	if (hc->plx_membase)
-		iounmap((void *)hc->plx_membase);
+		iounmap(hc->plx_membase);
 	if (hc->pci_iobase)
 		release_region(hc->pci_iobase, 8);
 
@@ -1081,7 +1083,8 @@ init_chip(struct hfc_multi *hc)
 	u_long			flags, val, val2 = 0, rev;
 	int			i, err = 0;
 	u_char			r_conf_en, rval;
-	u_int			*plx_acc_32, pv;
+	void __iomem		*plx_acc_32;
+	u_int			pv;
 	u_long			plx_flags, hfc_flags;
 	int			plx_count;
 	struct hfc_multi	*pos, *next, *plx_last_hc;
@@ -1155,7 +1158,7 @@ init_chip(struct hfc_multi *hc)
 			printk(KERN_DEBUG "%s: initializing PLXSD card %d\n",
 			    __func__, hc->id + 1);
 		spin_lock_irqsave(&plx_lock, plx_flags);
-		plx_acc_32 = (u_int *)(hc->plx_membase+PLX_GPIOC);
+		plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 		writel(PLX_GPIOC_INIT, plx_acc_32);
 		pv = readl(plx_acc_32);
 		/* The first and the last cards are terminating the PCM bus */
@@ -1191,8 +1194,7 @@ init_chip(struct hfc_multi *hc)
 					"we disable termination\n",
 				    __func__, plx_last_hc->id + 1);
 			spin_lock_irqsave(&plx_lock, plx_flags);
-			plx_acc_32 = (u_int *)(plx_last_hc->plx_membase
-					+ PLX_GPIOC);
+			plx_acc_32 = plx_last_hc->plx_membase + PLX_GPIOC;
 			pv = readl(plx_acc_32);
 			pv &= ~PLX_TERM_ON;
 			writel(pv, plx_acc_32);
@@ -1241,7 +1243,7 @@ init_chip(struct hfc_multi *hc)
 	/* Speech Design PLX bridge pcm and sync mode */
 	if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
 		spin_lock_irqsave(&plx_lock, plx_flags);
-		plx_acc_32 = (u_int *)(hc->plx_membase+PLX_GPIOC);
+		plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 		pv = readl(plx_acc_32);
 		/* Connect PCM */
 		if (hc->hw.r_pcm_md0 & V_PCM_MD) {
@@ -1353,8 +1355,7 @@ controller_fail:
 			/* retry with master clock */
 			if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
 				spin_lock_irqsave(&plx_lock, plx_flags);
-				plx_acc_32 = (u_int *)(hc->plx_membase +
-					PLX_GPIOC);
+				plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 				pv = readl(plx_acc_32);
 				pv |= PLX_MASTER_EN | PLX_SLAVE_EN_N;
 				pv |= PLX_SYNC_O_EN;
@@ -1390,7 +1391,7 @@ controller_fail:
 		if (test_bit(HFC_CHIP_PCM_MASTER, &hc->chip))
 			plxsd_master = 1;
 		spin_lock_irqsave(&plx_lock, plx_flags);
-		plx_acc_32 = (u_int *)(hc->plx_membase+PLX_GPIOC);
+		plx_acc_32 = hc->plx_membase + PLX_GPIOC;
 		pv = readl(plx_acc_32);
 		pv |=  PLX_DSP_RES_N;
 		writel(pv, plx_acc_32);
@@ -2587,7 +2588,8 @@ hfcmulti_interrupt(int intno, void *dev_id)
 	struct dchannel		*dch;
 	u_char			r_irq_statech, status, r_irq_misc, r_irq_oview;
 	int			i;
-	u_short			*plx_acc, wval;
+	void __iomem		*plx_acc;
+	u_short			wval;
 	u_char			e1_syncsta, temp;
 	u_long			flags;
 
@@ -2607,7 +2609,7 @@ hfcmulti_interrupt(int intno, void *dev_id)
 
 	if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
 		spin_lock_irqsave(&plx_lock, flags);
-		plx_acc = (u_short *)(hc->plx_membase + PLX_INTCSR);
+		plx_acc = hc->plx_membase + PLX_INTCSR;
 		wval = readw(plx_acc);
 		spin_unlock_irqrestore(&plx_lock, flags);
 		if (!(wval & PLX_INTCSR_LINTI1_STATUS))
@@ -4092,7 +4094,7 @@ init_card(struct hfc_multi *hc)
 {
 	int	err = -EIO;
 	u_long	flags;
-	u_short	*plx_acc;
+	void	__iomem *plx_acc;
 	u_long	plx_flags;
 
 	if (debug & DEBUG_HFCMULTI_INIT)
@@ -4114,7 +4116,7 @@ init_card(struct hfc_multi *hc)
 
 	if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
 		spin_lock_irqsave(&plx_lock, plx_flags);
-		plx_acc = (u_short *)(hc->plx_membase+PLX_INTCSR);
+		plx_acc = hc->plx_membase + PLX_INTCSR;
 		writew((PLX_INTCSR_PCIINT_ENABLE | PLX_INTCSR_LINTI1_ENABLE),
 			plx_acc); /* enable PCI & LINT1 irq */
 		spin_unlock_irqrestore(&plx_lock, plx_flags);
@@ -4163,7 +4165,7 @@ init_card(struct hfc_multi *hc)
 error:
 	if (test_bit(HFC_CHIP_PLXSD, &hc->chip)) {
 		spin_lock_irqsave(&plx_lock, plx_flags);
-		plx_acc = (u_short *)(hc->plx_membase+PLX_INTCSR);
+		plx_acc = hc->plx_membase + PLX_INTCSR;
 		writew(0x00, plx_acc); /*disable IRQs*/
 		spin_unlock_irqrestore(&plx_lock, plx_flags);
 	}
-- 
1.5.6.3
