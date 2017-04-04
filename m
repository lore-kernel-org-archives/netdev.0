From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] net: ibm: emac: remove unused sysrq handler for 'c' key
Date: Mon,  3 Apr 2017 22:50:20 -0700
Message-ID: <20170404055020.30658-1-ebiggers3@gmail.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Ivan Mikhaylov <ivan@de.ibm.com>, linux-kernel@vger.kernel.org,
        Eric Biggers <ebiggers@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Since commit d6580a9f1523 ("kexec: sysrq: simplify sysrq-c handler"),
the sysrq handler for the 'c' key has been sysrq_crash_op.  Debugging
code in the ibm_emac driver also tries to register a handler for the 'c'
key, but this has no effect because register_sysrq_key() doesn't replace
existing handlers.  Since evidently no one has cared enough to fix this
in the last 8 years, and it's very rare for drivers to register sysrq
handlers (for good reason), just remove the dead code.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 drivers/net/ethernet/ibm/emac/Makefile |   1 -
 drivers/net/ethernet/ibm/emac/core.c   |   7 -
 drivers/net/ethernet/ibm/emac/debug.c  | 270 ---------------------------------
 drivers/net/ethernet/ibm/emac/debug.h  |  23 ---
 drivers/net/ethernet/ibm/emac/mal.c    |   4 -
 drivers/tty/sysrq.c                    |   2 +-
 6 files changed, 1 insertion(+), 306 deletions(-)
 delete mode 100644 drivers/net/ethernet/ibm/emac/debug.c

diff --git a/drivers/net/ethernet/ibm/emac/Makefile b/drivers/net/ethernet/ibm/emac/Makefile
index eba21835d90d..98768ba0955a 100644
--- a/drivers/net/ethernet/ibm/emac/Makefile
+++ b/drivers/net/ethernet/ibm/emac/Makefile
@@ -8,4 +8,3 @@ ibm_emac-y := mal.o core.o phy.o
 ibm_emac-$(CONFIG_IBM_EMAC_ZMII) += zmii.o
 ibm_emac-$(CONFIG_IBM_EMAC_RGMII) += rgmii.o
 ibm_emac-$(CONFIG_IBM_EMAC_TAH) += tah.o
-ibm_emac-$(CONFIG_IBM_EMAC_DEBUG) += debug.o
diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index c44036d5761a..0f9cd92fdc5e 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -3173,8 +3173,6 @@ static int emac_probe(struct platform_device *ofdev)
 		printk("%s: found %s PHY (0x%02x)\n", ndev->name,
 		       dev->phy.def->name, dev->phy.address);
 
-	emac_dbg_register(dev);
-
 	/* Life is good */
 	return 0;
 
@@ -3243,7 +3241,6 @@ static int emac_remove(struct platform_device *ofdev)
 	mal_unregister_commac(dev->mal, &dev->commac);
 	emac_put_deps(dev);
 
-	emac_dbg_unregister(dev);
 	iounmap(dev->emacp);
 
 	if (dev->wol_irq)
@@ -3326,9 +3323,6 @@ static int __init emac_init(void)
 
 	printk(KERN_INFO DRV_DESC ", version " DRV_VERSION "\n");
 
-	/* Init debug stuff */
-	emac_init_debug();
-
 	/* Build EMAC boot list */
 	emac_make_bootlist();
 
@@ -3373,7 +3367,6 @@ static void __exit emac_exit(void)
 	rgmii_exit();
 	zmii_exit();
 	mal_exit();
-	emac_fini_debug();
 
 	/* Destroy EMAC boot list */
 	for (i = 0; i < EMAC_BOOT_LIST_SIZE; i++)
diff --git a/drivers/net/ethernet/ibm/emac/debug.c b/drivers/net/ethernet/ibm/emac/debug.c
deleted file mode 100644
index a559f326bf63..000000000000
--- a/drivers/net/ethernet/ibm/emac/debug.c
+++ /dev/null
@@ -1,270 +0,0 @@
-/*
- * drivers/net/ethernet/ibm/emac/debug.c
- *
- * Driver for PowerPC 4xx on-chip ethernet controller, debug print routines.
- *
- * Copyright 2007 Benjamin Herrenschmidt, IBM Corp.
- *                <benh@kernel.crashing.org>
- *
- * Based on the arch/ppc version of the driver:
- *
- * Copyright (c) 2004, 2005 Zultys Technologies
- * Eugene Surovegin <eugene.surovegin@zultys.com> or <ebs@ebshome.net>
- *
- * This program is free software; you can redistribute  it and/or modify it
- * under  the terms of  the GNU General  Public License as published by the
- * Free Software Foundation;  either version 2 of the  License, or (at your
- * option) any later version.
- *
- */
-#include <linux/init.h>
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/netdevice.h>
-#include <linux/sysrq.h>
-#include <asm/io.h>
-
-#include "core.h"
-
-static DEFINE_SPINLOCK(emac_dbg_lock);
-
-static void emac_desc_dump(struct emac_instance *p)
-{
-	int i;
-	printk("** EMAC %s TX BDs **\n"
-	       " tx_cnt = %d tx_slot = %d ack_slot = %d\n",
-	       p->ofdev->dev.of_node->full_name,
-	       p->tx_cnt, p->tx_slot, p->ack_slot);
-	for (i = 0; i < NUM_TX_BUFF / 2; ++i)
-		printk
-		    ("bd[%2d] 0x%08x %c 0x%04x %4u - bd[%2d] 0x%08x %c 0x%04x %4u\n",
-		     i, p->tx_desc[i].data_ptr, p->tx_skb[i] ? 'V' : ' ',
-		     p->tx_desc[i].ctrl, p->tx_desc[i].data_len,
-		     NUM_TX_BUFF / 2 + i,
-		     p->tx_desc[NUM_TX_BUFF / 2 + i].data_ptr,
-		     p->tx_skb[NUM_TX_BUFF / 2 + i] ? 'V' : ' ',
-		     p->tx_desc[NUM_TX_BUFF / 2 + i].ctrl,
-		     p->tx_desc[NUM_TX_BUFF / 2 + i].data_len);
-
-	printk("** EMAC %s RX BDs **\n"
-	       " rx_slot = %d flags = 0x%lx rx_skb_size = %d rx_sync_size = %d\n"
-	       " rx_sg_skb = 0x%p\n",
-	       p->ofdev->dev.of_node->full_name,
-	       p->rx_slot, p->commac.flags, p->rx_skb_size,
-	       p->rx_sync_size, p->rx_sg_skb);
-	for (i = 0; i < NUM_RX_BUFF / 2; ++i)
-		printk
-		    ("bd[%2d] 0x%08x %c 0x%04x %4u - bd[%2d] 0x%08x %c 0x%04x %4u\n",
-		     i, p->rx_desc[i].data_ptr, p->rx_skb[i] ? 'V' : ' ',
-		     p->rx_desc[i].ctrl, p->rx_desc[i].data_len,
-		     NUM_RX_BUFF / 2 + i,
-		     p->rx_desc[NUM_RX_BUFF / 2 + i].data_ptr,
-		     p->rx_skb[NUM_RX_BUFF / 2 + i] ? 'V' : ' ',
-		     p->rx_desc[NUM_RX_BUFF / 2 + i].ctrl,
-		     p->rx_desc[NUM_RX_BUFF / 2 + i].data_len);
-}
-
-static void emac_mac_dump(struct emac_instance *dev)
-{
-	struct emac_regs __iomem *p = dev->emacp;
-	const int xaht_regs = EMAC_XAHT_REGS(dev);
-	u32 *gaht_base = emac_gaht_base(dev);
-	u32 *iaht_base = emac_iaht_base(dev);
-	int emac4sync = emac_has_feature(dev, EMAC_FTR_EMAC4SYNC);
-	int n;
-
-	printk("** EMAC %s registers **\n"
-	       "MR0 = 0x%08x MR1 = 0x%08x TMR0 = 0x%08x TMR1 = 0x%08x\n"
-	       "RMR = 0x%08x ISR = 0x%08x ISER = 0x%08x\n"
-	       "IAR = %04x%08x VTPID = 0x%04x VTCI = 0x%04x\n",
-	       dev->ofdev->dev.of_node->full_name,
-	       in_be32(&p->mr0), in_be32(&p->mr1),
-	       in_be32(&p->tmr0), in_be32(&p->tmr1),
-	       in_be32(&p->rmr), in_be32(&p->isr), in_be32(&p->iser),
-	       in_be32(&p->iahr), in_be32(&p->ialr), in_be32(&p->vtpid),
-	       in_be32(&p->vtci)
-	       );
-
-	if (emac4sync)
-		printk("MAR = %04x%08x MMAR = %04x%08x\n",
-		       in_be32(&p->u0.emac4sync.mahr),
-		       in_be32(&p->u0.emac4sync.malr),
-		       in_be32(&p->u0.emac4sync.mmahr),
-		       in_be32(&p->u0.emac4sync.mmalr)
-		       );
-
-	for (n = 0; n < xaht_regs; n++)
-		printk("IAHT%02d = 0x%08x\n", n + 1, in_be32(iaht_base + n));
-
-	for (n = 0; n < xaht_regs; n++)
-		printk("GAHT%02d = 0x%08x\n", n + 1, in_be32(gaht_base + n));
-
-	printk("LSA = %04x%08x IPGVR = 0x%04x\n"
-	       "STACR = 0x%08x TRTR = 0x%08x RWMR = 0x%08x\n"
-	       "OCTX = 0x%08x OCRX = 0x%08x\n",
-	       in_be32(&p->lsah), in_be32(&p->lsal), in_be32(&p->ipgvr),
-	       in_be32(&p->stacr), in_be32(&p->trtr), in_be32(&p->rwmr),
-	       in_be32(&p->octx), in_be32(&p->ocrx)
-	       );
-
-	if (!emac4sync) {
-		printk("IPCR = 0x%08x\n",
-		       in_be32(&p->u1.emac4.ipcr)
-		       );
-	} else {
-		printk("REVID = 0x%08x TPC = 0x%08x\n",
-		       in_be32(&p->u1.emac4sync.revid),
-		       in_be32(&p->u1.emac4sync.tpc)
-		       );
-	}
-
-	emac_desc_dump(dev);
-}
-
-static void emac_mal_dump(struct mal_instance *mal)
-{
-	int i;
-
-	printk("** MAL %s Registers **\n"
-	       "CFG = 0x%08x ESR = 0x%08x IER = 0x%08x\n"
-	       "TX|CASR = 0x%08x CARR = 0x%08x EOBISR = 0x%08x DEIR = 0x%08x\n"
-	       "RX|CASR = 0x%08x CARR = 0x%08x EOBISR = 0x%08x DEIR = 0x%08x\n",
-	       mal->ofdev->dev.of_node->full_name,
-	       get_mal_dcrn(mal, MAL_CFG), get_mal_dcrn(mal, MAL_ESR),
-	       get_mal_dcrn(mal, MAL_IER),
-	       get_mal_dcrn(mal, MAL_TXCASR), get_mal_dcrn(mal, MAL_TXCARR),
-	       get_mal_dcrn(mal, MAL_TXEOBISR), get_mal_dcrn(mal, MAL_TXDEIR),
-	       get_mal_dcrn(mal, MAL_RXCASR), get_mal_dcrn(mal, MAL_RXCARR),
-	       get_mal_dcrn(mal, MAL_RXEOBISR), get_mal_dcrn(mal, MAL_RXDEIR)
-	    );
-
-	printk("TX|");
-	for (i = 0; i < mal->num_tx_chans; ++i) {
-		if (i && !(i % 4))
-			printk("\n   ");
-		printk("CTP%d = 0x%08x ", i, get_mal_dcrn(mal, MAL_TXCTPR(i)));
-	}
-	printk("\nRX|");
-	for (i = 0; i < mal->num_rx_chans; ++i) {
-		if (i && !(i % 4))
-			printk("\n   ");
-		printk("CTP%d = 0x%08x ", i, get_mal_dcrn(mal, MAL_RXCTPR(i)));
-	}
-	printk("\n   ");
-	for (i = 0; i < mal->num_rx_chans; ++i) {
-		u32 r = get_mal_dcrn(mal, MAL_RCBS(i));
-		if (i && !(i % 3))
-			printk("\n   ");
-		printk("RCBS%d = 0x%08x (%d) ", i, r, r * 16);
-	}
-	printk("\n");
-}
-
-static struct emac_instance *__emacs[4];
-static struct mal_instance *__mals[1];
-
-void emac_dbg_register(struct emac_instance *dev)
-{
-	unsigned long flags;
-	int i;
-
-	spin_lock_irqsave(&emac_dbg_lock, flags);
-	for (i = 0; i < ARRAY_SIZE(__emacs); i++)
-		if (__emacs[i] == NULL) {
-			__emacs[i] = dev;
-			break;
-		}
-	spin_unlock_irqrestore(&emac_dbg_lock, flags);
-}
-
-void emac_dbg_unregister(struct emac_instance *dev)
-{
-	unsigned long flags;
-	int i;
-
-	spin_lock_irqsave(&emac_dbg_lock, flags);
-	for (i = 0; i < ARRAY_SIZE(__emacs); i++)
-		if (__emacs[i] == dev) {
-			__emacs[i] = NULL;
-			break;
-		}
-	spin_unlock_irqrestore(&emac_dbg_lock, flags);
-}
-
-void mal_dbg_register(struct mal_instance *mal)
-{
-	unsigned long flags;
-	int i;
-
-	spin_lock_irqsave(&emac_dbg_lock, flags);
-	for (i = 0; i < ARRAY_SIZE(__mals); i++)
-		if (__mals[i] == NULL) {
-			__mals[i] = mal;
-			break;
-		}
-	spin_unlock_irqrestore(&emac_dbg_lock, flags);
-}
-
-void mal_dbg_unregister(struct mal_instance *mal)
-{
-	unsigned long flags;
-	int i;
-
-	spin_lock_irqsave(&emac_dbg_lock, flags);
-	for (i = 0; i < ARRAY_SIZE(__mals); i++)
-		if (__mals[i] == mal) {
-			__mals[i] = NULL;
-			break;
-		}
-	spin_unlock_irqrestore(&emac_dbg_lock, flags);
-}
-
-void emac_dbg_dump_all(void)
-{
-	unsigned int i;
-	unsigned long flags;
-
-	spin_lock_irqsave(&emac_dbg_lock, flags);
-
-	for (i = 0; i < ARRAY_SIZE(__mals); ++i)
-		if (__mals[i])
-			emac_mal_dump(__mals[i]);
-
-	for (i = 0; i < ARRAY_SIZE(__emacs); ++i)
-		if (__emacs[i])
-			emac_mac_dump(__emacs[i]);
-
-	spin_unlock_irqrestore(&emac_dbg_lock, flags);
-}
-
-#if defined(CONFIG_MAGIC_SYSRQ)
-static void emac_sysrq_handler(int key)
-{
-	emac_dbg_dump_all();
-}
-
-static struct sysrq_key_op emac_sysrq_op = {
-	.handler = emac_sysrq_handler,
-	.help_msg = "emac(c)",
-	.action_msg = "Show EMAC(s) status",
-};
-
-int __init emac_init_debug(void)
-{
-	return register_sysrq_key('c', &emac_sysrq_op);
-}
-
-void __exit emac_fini_debug(void)
-{
-	unregister_sysrq_key('c', &emac_sysrq_op);
-}
-
-#else
-int __init emac_init_debug(void)
-{
-	return 0;
-}
-void __exit emac_fini_debug(void)
-{
-}
-#endif				/* CONFIG_MAGIC_SYSRQ */
diff --git a/drivers/net/ethernet/ibm/emac/debug.h b/drivers/net/ethernet/ibm/emac/debug.h
index 9c45efe4c8fe..5bdfc174a07e 100644
--- a/drivers/net/ethernet/ibm/emac/debug.h
+++ b/drivers/net/ethernet/ibm/emac/debug.h
@@ -25,32 +25,9 @@
 #include "core.h"
 
 #if defined(CONFIG_IBM_EMAC_DEBUG)
-
-struct emac_instance;
-struct mal_instance;
-
-void emac_dbg_register(struct emac_instance *dev);
-void emac_dbg_unregister(struct emac_instance *dev);
-void mal_dbg_register(struct mal_instance *mal);
-void mal_dbg_unregister(struct mal_instance *mal);
-int emac_init_debug(void) __init;
-void emac_fini_debug(void) __exit;
-void emac_dbg_dump_all(void);
-
 # define DBG_LEVEL		1
-
 #else
-
-# define emac_dbg_register(x)	do { } while(0)
-# define emac_dbg_unregister(x)	do { } while(0)
-# define mal_dbg_register(x)	do { } while(0)
-# define mal_dbg_unregister(x)	do { } while(0)
-# define emac_init_debug()	do { } while(0)
-# define emac_fini_debug()	do { } while(0)
-# define emac_dbg_dump_all()	do { } while(0)
-
 # define DBG_LEVEL		0
-
 #endif
 
 #define EMAC_DBG(d, name, fmt, arg...) \
diff --git a/drivers/net/ethernet/ibm/emac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
index cd3227b088b7..91b1a558f37d 100644
--- a/drivers/net/ethernet/ibm/emac/mal.c
+++ b/drivers/net/ethernet/ibm/emac/mal.c
@@ -695,8 +695,6 @@ static int mal_probe(struct platform_device *ofdev)
 	wmb();
 	platform_set_drvdata(ofdev, mal);
 
-	mal_dbg_register(mal);
-
 	return 0;
 
  fail6:
@@ -740,8 +738,6 @@ static int mal_remove(struct platform_device *ofdev)
 
 	mal_reset(mal);
 
-	mal_dbg_unregister(mal);
-
 	dma_free_coherent(&ofdev->dev,
 			  sizeof(struct mal_descriptor) *
 			  (NUM_TX_BUFF * mal->num_tx_chans +
diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
index c6fc7141d7b2..677f0ddc986c 100644
--- a/drivers/tty/sysrq.c
+++ b/drivers/tty/sysrq.c
@@ -446,7 +446,7 @@ static struct sysrq_key_op *sysrq_key_table[36] = {
 	 */
 	NULL,				/* a */
 	&sysrq_reboot_op,		/* b */
-	&sysrq_crash_op,		/* c & ibm_emac driver debug */
+	&sysrq_crash_op,		/* c */
 	&sysrq_showlocks_op,		/* d */
 	&sysrq_term_op,			/* e */
 	&sysrq_moom_op,			/* f */
-- 
2.12.1
