From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: [PATCH 6/9] staging: slicoss: avoid PCI write posting
Date: Fri, 22 Jul 2016 23:09:16 +0200
Message-ID: <1469221759-17652-7-git-send-email-LinoSanfilippo@gmx.de>
References: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Lino Sanfilippo <LinoSanfilippo@gmx.de>
To: liodot@gmail.com, charrer@alacritech.com,
	gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469221759-17652-1-git-send-email-LinoSanfilippo@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce the function slic_flush_write() which reads from the HOSTID
register and can be used to avoid PCI write posting. Use the function at
several critical places in the code.

Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/staging/slicoss/slic.h    |  5 +++++
 drivers/staging/slicoss/slicoss.c | 19 ++++++++++++++++++-
 2 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/staging/slicoss/slic.h b/drivers/staging/slicoss/slic.h
index 08d9f5b..230d30b 100644
--- a/drivers/staging/slicoss/slic.h
+++ b/drivers/staging/slicoss/slic.h
@@ -511,6 +511,11 @@ static inline void slic_write64(struct adapter *adapter, unsigned int reg,
 	spin_unlock_irqrestore(&adapter->bit64reglock, flags);
 }
 
+static inline void slic_flush_write(struct adapter *adapter)
+{
+	ioread32(adapter->regs + SLIC_REG_HOSTID);
+}
+
 #define UPDATE_STATS(largestat, newstat, oldstat)                        \
 {                                                                        \
 	if ((newstat) < (oldstat))                                       \
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index edae0f7..0c2f86a0 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -268,6 +268,7 @@ static void slic_link_config(struct adapter *adapter,
 				 */
 				phy_config = (MIICR_REG_PCR | PCR_POWERDOWN);
 				slic_reg32_write(wphy, phy_config, FLUSH);
+				slic_flush_write(adapter);
 				/*
 				 * wait, Marvell says 1 sec,
 				 * try to get away with 10 ms
@@ -360,7 +361,7 @@ static void slic_link_config(struct adapter *adapter,
 		/* power down phy to break link (this may not work)  */
 		phy_config = (MIICR_REG_PCR | (PCR_POWERDOWN | speed | duplex));
 		slic_reg32_write(wphy, phy_config, FLUSH);
-
+		slic_flush_write(adapter);
 		/* wait, Marvell says 1 sec, try to get away with 10 ms */
 		mdelay(10);
 
@@ -448,6 +449,8 @@ static int slic_card_download_gbrcv(struct adapter *adapter)
 	/* download finished */
 	release_firmware(fw);
 	slic_reg32_write(&slic_regs->slic_rcv_wcs, SLIC_RCVWCS_FINISH, FLUSH);
+	slic_flush_write(adapter);
+
 	return 0;
 }
 
@@ -551,6 +554,7 @@ static int slic_card_download(struct adapter *adapter)
 	/* Everything OK, kick off the card */
 	mdelay(10);
 	slic_reg32_write(&slic_regs->slic_wcs, SLIC_WCS_START, FLUSH);
+	slic_flush_write(adapter);
 
 	/*
 	 * stall for 20 ms, long enough for ucode to init card
@@ -591,11 +595,13 @@ static void slic_soft_reset(struct adapter *adapter)
 {
 	if (adapter->card->state == CARD_UP) {
 		slic_reg32_write(&adapter->slic_regs->slic_quiesce, 0, FLUSH);
+		slic_flush_write(adapter);
 		mdelay(1);
 	}
 
 	slic_reg32_write(&adapter->slic_regs->slic_reset, SLIC_RESET_MAGIC,
 			 FLUSH);
+	slic_flush_write(adapter);
 	mdelay(1);
 }
 
@@ -934,6 +940,7 @@ static void slic_upr_start(struct adapter *adapter)
 		slic_reg32_write(&slic_regs->slic_ping, 1, FLUSH);
 		break;
 	}
+	slic_flush_write(adapter);
 }
 
 static int slic_upr_request(struct adapter *adapter,
@@ -2153,6 +2160,7 @@ static irqreturn_t slic_interrupt(int irq, void *dev_id)
 	if ((adapter->pshmem) && (adapter->pshmem->isr)) {
 		slic_reg32_write(&adapter->slic_regs->slic_icr,
 				 ICR_INT_MASK, FLUSH);
+		slic_flush_write(adapter);
 		isr = adapter->isrcopy = adapter->pshmem->isr;
 		adapter->pshmem->isr = 0;
 		adapter->num_isrs++;
@@ -2337,6 +2345,7 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 	}
 
 	slic_reg32_write(&slic_regs->slic_icr, ICR_INT_OFF, FLUSH);
+	slic_flush_write(adapter);
 	mdelay(1);
 
 	if (!adapter->isp_initialized) {
@@ -2390,11 +2399,13 @@ static int slic_if_init(struct adapter *adapter, unsigned long *flags)
 	slic_reg32_write(&slic_regs->slic_icr, ICR_INT_ON, FLUSH);
 
 	slic_link_config(adapter, LINK_AUTOSPEED, LINK_AUTOD);
+	slic_flush_write(adapter);
 	rc = slic_link_event_handler(adapter);
 	if (rc) {
 		/* disable interrupts then clear pending events */
 		slic_reg32_write(&slic_regs->slic_icr, ICR_INT_OFF, FLUSH);
 		slic_reg32_write(&slic_regs->slic_isr, 0, FLUSH);
+		slic_flush_write(adapter);
 		if (adapter->pingtimerset) {
 			del_timer(&adapter->pingtimer);
 			adapter->pingtimerset = 0;
@@ -2523,6 +2534,7 @@ static int slic_entry_halt(struct net_device *dev)
 #ifdef AUTOMATIC_RESET
 	slic_reg32_write(&slic_regs->slic_reset_iface, 0, FLUSH);
 #endif
+	slic_flush_write(adapter);
 	/*
 	 *  Reset the adapter's cmd queues
 	 */
@@ -2714,6 +2726,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 		memset(peeprom, 0, sizeof(struct slic_eeprom));
 
 		slic_reg32_write(&slic_regs->slic_icr, ICR_INT_OFF, FLUSH);
+		slic_flush_write(adapter);
 		mdelay(1);
 		pshmem = (struct slic_shmem *)(unsigned long)
 			 adapter->phys_shmem;
@@ -2742,6 +2755,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 						0, FLUSH);
 					slic_reg32_write(&slic_regs->slic_isr,
 							 0, FLUSH);
+					slic_flush_write(adapter);
 
 					slic_upr_request_complete(adapter, 0);
 					break;
@@ -2750,6 +2764,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 				adapter->pshmem->isr = 0;
 				slic_reg32_write(&slic_regs->slic_isr,
 						 0, FLUSH);
+				slic_flush_write(adapter);
 			} else {
 				mdelay(1);
 				i++;
@@ -2760,6 +2775,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 						&slic_regs->slic_isp, 0,
 						&slic_regs->slic_addr_upper,
 						0, FLUSH);
+					slic_flush_write(adapter);
 					status = -EINVAL;
 					goto card_init_err;
 				}
@@ -2840,6 +2856,7 @@ static int slic_card_init(struct sliccard *card, struct adapter *adapter)
 			slic_reg64_write(adapter, &slic_regs->slic_isp, 0,
 					 &slic_regs->slic_addr_upper,
 					 0, FLUSH);
+			slic_flush_write(adapter);
 			dev_err(&adapter->pcidev->dev, "EEPROM invalid.\n");
 			return -EINVAL;
 		}
-- 
1.9.1
