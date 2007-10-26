From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH] Remove always-true tests in irq handlers
Date: Fri, 26 Oct 2007 05:40:24 -0400 (EDT)
Message-ID: <53d6c8049d4c3999a9d33d73e385d6161b5de2b7.1193390974.git.jeff@garzik.org>
References: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Cc: akpm@linux-foundation.org, tony.luck@intel.com,
	linux-ia64@vger.kernel.org, netdev@vger.kernel.org,
	ralf@linux-mips.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:47630 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754216AbXJZJkl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2007 05:40:41 -0400
In-Reply-To: <9799624f63e093aa915947aea8fb1b8a5df959a1.1193390973.git.jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In these drivers, dev_id is always non-NULL.

Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
---
 arch/ia64/hp/sim/simeth.c                   |    5 -----
 arch/mips/pmc-sierra/msp71xx/msp_hwbutton.c |    5 +----
 drivers/net/cpmac.c                         |    3 ---
 drivers/net/ucc_geth.c                      |    3 ---
 drivers/net/wan/farsync.c                   |   11 +++--------
 5 files changed, 4 insertions(+), 23 deletions(-)

diff --git a/arch/ia64/hp/sim/simeth.c b/arch/ia64/hp/sim/simeth.c
index 08b117e..9898feb 100644
--- a/arch/ia64/hp/sim/simeth.c
+++ b/arch/ia64/hp/sim/simeth.c
@@ -497,11 +497,6 @@ simeth_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
 
-	if ( dev == NULL ) {
-		printk(KERN_WARNING "simeth: irq %d for unknown device\n", irq);
-		return IRQ_NONE;
-	}
-
 	/*
 	 * very simple loop because we get interrupts only when receiving
 	 */
diff --git a/arch/mips/pmc-sierra/msp71xx/msp_hwbutton.c b/arch/mips/pmc-sierra/msp71xx/msp_hwbutton.c
index ab96a2d..11769b5 100644
--- a/arch/mips/pmc-sierra/msp71xx/msp_hwbutton.c
+++ b/arch/mips/pmc-sierra/msp71xx/msp_hwbutton.c
@@ -126,9 +126,6 @@ static irqreturn_t hwbutton_handler(int irq, void *data)
 	struct hwbutton_interrupt *hirq = data;
 	unsigned long cic_ext = *CIC_EXT_CFG_REG;
 
-	if (irq != hirq->irq)
-		return IRQ_NONE;
-
 	if (CIC_EXT_IS_ACTIVE_HI(cic_ext, hirq->eirq)) {
 		/* Interrupt: pin is now HI */
 		CIC_EXT_SET_ACTIVE_LO(cic_ext, hirq->eirq);
@@ -164,7 +161,7 @@ static int msp_hwbutton_register(struct hwbutton_interrupt *hirq)
 	*CIC_EXT_CFG_REG = cic_ext;
 
 	return request_irq(hirq->irq, hwbutton_handler, IRQF_DISABLED,
-				hirq->name, (void *)hirq);
+			   hirq->name, hirq);
 }
 
 static int __init msp_hwbutton_setup(void)
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 6fd95a2..91d1596 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -661,9 +661,6 @@ static irqreturn_t cpmac_irq(int irq, void *dev_id)
 	int queue;
 	u32 status;
 
-	if (!dev)
-		return IRQ_NONE;
-
 	priv = netdev_priv(dev);
 
 	status = cpmac_read(priv->regs, CPMAC_MAC_INT_VECTOR);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 9741d61..2243d34 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3621,9 +3621,6 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 
 	ugeth_vdbg("%s: IN", __FUNCTION__);
 
-	if (!ugeth)
-		return IRQ_NONE;
-
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
 
diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index 12dae8e..cf27bf4 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -1498,9 +1498,9 @@ do_bottom_half_rx(struct fst_card_info *card)
  *      Dev_id is our fst_card_info pointer
  */
 static irqreturn_t
-fst_intr(int irq, void *dev_id)
+fst_intr(int dummy, void *dev_id)
 {
-	struct fst_card_info *card;
+	struct fst_card_info *card = dev_id;
 	struct fst_port_info *port;
 	int rdidx;		/* Event buffer indices */
 	int wridx;
@@ -1509,17 +1509,12 @@ fst_intr(int irq, void *dev_id)
 	unsigned int do_card_interrupt;
 	unsigned int int_retry_count;
 
-	if ((card = dev_id) == NULL) {
-		dbg(DBG_INTR, "intr: spurious %d\n", irq);
-		return IRQ_NONE;
-	}
-
 	/*
 	 * Check to see if the interrupt was for this card
 	 * return if not
 	 * Note that the call to clear the interrupt is important
 	 */
-	dbg(DBG_INTR, "intr: %d %p\n", irq, card);
+	dbg(DBG_INTR, "intr: %d %p\n", card->irq, card);
 	if (card->state != FST_RUNNING) {
 		printk_err
 		    ("Interrupt received for card %d in a non running state (%d)\n",
-- 
1.5.2.4

