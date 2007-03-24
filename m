From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 1/3]: Eliminate the unused TG3_FLAG_SPLIT_MODE flag.
Date: Fri, 23 Mar 2007 16:12:57 -0800
Message-ID: <1174695177.4834.8.camel@dell>
References: <20070322204635.GA27152@strauss.suse.de>
 <1174601067.9753.42.camel@dell> <20070322232048.GC3333@sykes.suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, "Bernhard Walle" <bwalle@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2745 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992640AbXCWX3K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 19:29:10 -0400
In-Reply-To: <20070322232048.GC3333@sykes.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Eliminate the unused TG3_FLAG_SPLIT_MODE flag.

This flag to support multiple PCIX split completions was never used
because of hardware bugs.  This will make room for a new flag.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8c8f9f4..ab87bb1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6321,8 +6321,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		      RDMAC_MODE_ADDROFLOW_ENAB | RDMAC_MODE_FIFOOFLOW_ENAB |
 		      RDMAC_MODE_FIFOURUN_ENAB | RDMAC_MODE_FIFOOREAD_ENAB |
 		      RDMAC_MODE_LNGREAD_ENAB);
-	if (tp->tg3_flags & TG3_FLAG_SPLIT_MODE)
-		rdmac_mode |= RDMAC_MODE_SPLIT_ENABLE;
 
 	/* If statement applies to 5705 and 5750 PCI devices only */
 	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
@@ -6495,9 +6493,6 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		} else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) {
 			val &= ~(PCIX_CAPS_SPLIT_MASK | PCIX_CAPS_BURST_MASK);
 			val |= (PCIX_CAPS_MAX_BURST_CPIOB << PCIX_CAPS_BURST_SHIFT);
-			if (tp->tg3_flags & TG3_FLAG_SPLIT_MODE)
-				val |= (tp->split_mode_max_reqs <<
-					PCIX_CAPS_SPLIT_SHIFT);
 		}
 		tw32(TG3PCI_X_CAPS, val);
 	}
@@ -10863,14 +10858,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	grc_misc_cfg = tr32(GRC_MISC_CFG);
 	grc_misc_cfg &= GRC_MISC_CFG_BOARD_ID_MASK;
 
-	/* Broadcom's driver says that CIOBE multisplit has a bug */
-#if 0
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704 &&
-	    grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5704CIOBE) {
-		tp->tg3_flags |= TG3_FLAG_SPLIT_MODE;
-		tp->split_mode_max_reqs = SPLIT_MODE_5704_MAX_REQ;
-	}
-#endif
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
 	    (grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788 ||
 	     grc_misc_cfg == GRC_MISC_CFG_BOARD_ID_5788M))
@@ -11968,14 +11955,12 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		       i == 5 ? '\n' : ':');
 
 	printk(KERN_INFO "%s: RXcsums[%d] LinkChgREG[%d] "
-	       "MIirq[%d] ASF[%d] Split[%d] WireSpeed[%d] "
-	       "TSOcap[%d] \n",
+	       "MIirq[%d] ASF[%d] WireSpeed[%d] TSOcap[%d]\n",
 	       dev->name,
 	       (tp->tg3_flags & TG3_FLAG_RX_CHECKSUMS) != 0,
 	       (tp->tg3_flags & TG3_FLAG_USE_LINKCHG_REG) != 0,
 	       (tp->tg3_flags & TG3_FLAG_USE_MI_INTERRUPT) != 0,
 	       (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) != 0,
-	       (tp->tg3_flags & TG3_FLAG_SPLIT_MODE) != 0,
 	       (tp->tg3_flags2 & TG3_FLG2_NO_ETH_WIRE_SPEED) == 0,
 	       (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE) != 0);
 	printk(KERN_INFO "%s: dma_rwctrl[%08x] dma_mask[%d-bit]\n",
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 086892d..5df8f76 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2223,7 +2223,6 @@ struct tg3 {
 #define TG3_FLAG_40BIT_DMA_BUG		0x08000000
 #define TG3_FLAG_BROKEN_CHECKSUMS	0x10000000
 #define TG3_FLAG_GOT_SERDES_FLOWCTL	0x20000000
-#define TG3_FLAG_SPLIT_MODE		0x40000000
 #define TG3_FLAG_INIT_COMPLETE		0x80000000
 	u32				tg3_flags2;
 #define TG3_FLG2_RESTART_TIMER		0x00000001
@@ -2262,9 +2261,6 @@ struct tg3 {
 #define TG3_FLG2_NO_FWARE_REPORTED	0x40000000
 #define TG3_FLG2_PHY_ADJUST_TRIM	0x80000000
 
-	u32				split_mode_max_reqs;
-#define SPLIT_MODE_5704_MAX_REQ		3
-
 	struct timer_list		timer;
 	u16				timer_counter;
 	u16				timer_multiplier;


