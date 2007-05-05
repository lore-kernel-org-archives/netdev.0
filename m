From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 8/11][TG3]: Add TG3_FLAG_SUPPORT_MSI flag.
Date: Fri, 04 May 2007 17:54:54 -0700
Message-ID: <1178326494.4859.24.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3411 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422954AbXEEAHi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:07:38 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Add TG3_FLAG_SUPPORT_MSI flag.

And fix up the code to always allow MSI on 5714 A2.

Call tg3_find_peer() earlier because we need that information before
we can determine whether we can set TG3_FLAG_SUPPORT_MSI or not.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 23a9477..4fe38a0 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7033,11 +7033,7 @@ static int tg3_open(struct net_device *dev)
 	if (err)
 		return err;
 
-	if ((tp->tg3_flags2 & TG3_FLG2_5750_PLUS) &&
-	    (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5750_AX) &&
-	    (GET_CHIP_REV(tp->pci_chip_rev_id) != CHIPREV_5750_BX) &&
-	    !((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714) &&
-	      (tp->pdev_peer == tp->pdev))) {
+	if (tp->tg3_flags & TG3_FLAG_SUPPORT_MSI) {
 		/* All MSI supporting chips should support tagged
 		 * status.  Assert that this is the case.
 		 */
@@ -10404,6 +10400,8 @@ static void __devinit tg3_read_fw_ver(struct tg3 *tp)
 	}
 }
 
+static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
+
 static int __devinit tg3_get_invariants(struct tg3 *tp)
 {
 	static struct pci_device_id write_reorder_chipsets[] = {
@@ -10559,6 +10557,10 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	tp->pci_hdr_type     = (cacheline_sz_reg >> 16) & 0xff;
 	tp->pci_bist         = (cacheline_sz_reg >> 24) & 0xff;
 
+	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
+	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714))
+		tp->pdev_peer = tg3_find_peer(tp);
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
@@ -10572,6 +10574,14 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		tp->tg3_flags2 |= TG3_FLG2_5705_PLUS;
 
 	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS) {
+		tp->tg3_flags |= TG3_FLAG_SUPPORT_MSI;
+		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_AX ||
+		    GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5750_BX ||
+		    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714 &&
+		     tp->pci_chip_rev_id <= CHIPREV_ID_5714_A2 &&
+		     tp->pdev_peer == tp->pdev))
+			tp->tg3_flags &= ~TG3_FLAG_SUPPORT_MSI;
+
 		if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5755 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5787 ||
 		    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5906) {
@@ -11896,10 +11906,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 		tp->rx_pending = 63;
 	}
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5714))
-		tp->pdev_peer = tg3_find_peer(tp);
-
 	err = tg3_get_device_address(tp);
 	if (err) {
 		printk(KERN_ERR PFX "Could not obtain valid ethernet address, "
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index c52acb0..dcdfc08 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -131,6 +131,7 @@
 #define  CHIPREV_ID_5752_A0_HW		 0x5000
 #define  CHIPREV_ID_5752_A0		 0x6000
 #define  CHIPREV_ID_5752_A1		 0x6001
+#define  CHIPREV_ID_5714_A2		 0x9002
 #define  CHIPREV_ID_5906_A1		 0xc001
 #define  GET_ASIC_REV(CHIP_REV_ID)	((CHIP_REV_ID) >> 12)
 #define   ASIC_REV_5700			 0x07
@@ -2221,6 +2222,7 @@ struct tg3 {
 #define TG3_FLAG_IN_RESET_TASK		0x04000000
 #define TG3_FLAG_40BIT_DMA_BUG		0x08000000
 #define TG3_FLAG_BROKEN_CHECKSUMS	0x10000000
+#define TG3_FLAG_SUPPORT_MSI		0x20000000
 #define TG3_FLAG_CHIP_RESETTING		0x40000000
 #define TG3_FLAG_INIT_COMPLETE		0x80000000
 	u32				tg3_flags2;


