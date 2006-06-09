From: akpm@osdl.org
Subject: [patch 8/8] ipw2200 locking fix
Date: Thu, 08 Jun 2006 22:19:49 -0700
Message-ID: <200606090519.k595JnLN032035@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, yi.zhu@intel.com,
	arjan@infradead.org, deweerdt@free.fr, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:57051 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965152AbWFIFUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2006 01:20:02 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Zhu Yi <yi.zhu@intel.com>

Well, this is not 100% if when the card fires two consecutive
interrupts. Though unlikely, it's better to protect early than seeing
some "weird" bugs one day. I proposed attached patch. If you can help to
test, that will be appreciated (I cannot see the lockdep warning on my
box somehow).

Cc: Frederik Deweerdt <deweerdt@free.fr>
Cc: Arjan van de Ven <arjan@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/wireless/ipw2200.c |   41 ++++++++++++++++++++++++-------
 drivers/net/wireless/ipw2200.h |    1 
 2 files changed, 33 insertions(+), 9 deletions(-)

diff -puN drivers/net/wireless/ipw2200.c~ipw2200-locking-fix drivers/net/wireless/ipw2200.c
--- devel/drivers/net/wireless/ipw2200.c~ipw2200-locking-fix	2006-06-04 23:58:05.000000000 -0700
+++ devel-akpm/drivers/net/wireless/ipw2200.c	2006-06-04 23:58:05.000000000 -0700
@@ -533,7 +533,7 @@ static inline void ipw_clear_bit(struct 
 	ipw_write32(priv, reg, ipw_read32(priv, reg) & ~mask);
 }
 
-static inline void ipw_enable_interrupts(struct ipw_priv *priv)
+static inline void __ipw_enable_interrupts(struct ipw_priv *priv)
 {
 	if (priv->status & STATUS_INT_ENABLED)
 		return;
@@ -541,7 +541,7 @@ static inline void ipw_enable_interrupts
 	ipw_write32(priv, IPW_INTA_MASK_R, IPW_INTA_MASK_ALL);
 }
 
-static inline void ipw_disable_interrupts(struct ipw_priv *priv)
+static inline void __ipw_disable_interrupts(struct ipw_priv *priv)
 {
 	if (!(priv->status & STATUS_INT_ENABLED))
 		return;
@@ -549,6 +549,24 @@ static inline void ipw_disable_interrupt
 	ipw_write32(priv, IPW_INTA_MASK_R, ~IPW_INTA_MASK_ALL);
 }
 
+static inline void ipw_enable_interrupts(struct ipw_priv *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	__ipw_enable_interrupts(priv);
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
+static inline void ipw_disable_interrupts(struct ipw_priv *priv)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&priv->irq_lock, flags);
+	__ipw_disable_interrupts(priv);
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+}
+
 #ifdef CONFIG_IPW2200_DEBUG
 static char *ipw_error_desc(u32 val)
 {
@@ -1856,7 +1874,7 @@ static void ipw_irq_tasklet(struct ipw_p
 	unsigned long flags;
 	int rc = 0;
 
-	spin_lock_irqsave(&priv->lock, flags);
+	spin_lock_irqsave(&priv->irq_lock, flags);
 
 	inta = ipw_read32(priv, IPW_INTA_RW);
 	inta_mask = ipw_read32(priv, IPW_INTA_MASK_R);
@@ -1865,6 +1883,10 @@ static void ipw_irq_tasklet(struct ipw_p
 	/* Add any cached INTA values that need to be handled */
 	inta |= priv->isr_inta;
 
+	spin_unlock_irqrestore(&priv->irq_lock, flags);
+
+	spin_lock_irqsave(&priv->lock, flags);
+
 	/* handle all the justifications for the interrupt */
 	if (inta & IPW_INTA_BIT_RX_TRANSFER) {
 		ipw_rx(priv);
@@ -1993,10 +2015,10 @@ static void ipw_irq_tasklet(struct ipw_p
 		IPW_ERROR("Unhandled INTA bits 0x%08x\n", inta & ~handled);
 	}
 
+	spin_unlock_irqrestore(&priv->lock, flags);
+
 	/* enable all interrupts */
 	ipw_enable_interrupts(priv);
-
-	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
 #define IPW_CMD(x) case IPW_CMD_ ## x : return #x
@@ -10460,7 +10482,7 @@ static irqreturn_t ipw_isr(int irq, void
 	if (!priv)
 		return IRQ_NONE;
 
-	spin_lock(&priv->lock);
+	spin_lock(&priv->irq_lock);
 
 	if (!(priv->status & STATUS_INT_ENABLED)) {
 		/* Shared IRQ */
@@ -10482,7 +10504,7 @@ static irqreturn_t ipw_isr(int irq, void
 	}
 
 	/* tell the device to stop sending interrupts */
-	ipw_disable_interrupts(priv);
+	__ipw_disable_interrupts(priv);
 
 	/* ack current interrupts */
 	inta &= (IPW_INTA_MASK_ALL & inta_mask);
@@ -10493,11 +10515,11 @@ static irqreturn_t ipw_isr(int irq, void
 
 	tasklet_schedule(&priv->irq_tasklet);
 
-	spin_unlock(&priv->lock);
+	spin_unlock(&priv->irq_lock);
 
 	return IRQ_HANDLED;
       none:
-	spin_unlock(&priv->lock);
+	spin_unlock(&priv->irq_lock);
 	return IRQ_NONE;
 }
 
@@ -11477,6 +11499,7 @@ static int ipw_pci_probe(struct pci_dev 
 #ifdef CONFIG_IPW2200_DEBUG
 	ipw_debug_level = debug;
 #endif
+	spin_lock_init(&priv->irq_lock);
 	spin_lock_init(&priv->lock);
 	for (i = 0; i < IPW_IBSS_MAC_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&priv->ibss_mac_hash[i]);
diff -puN drivers/net/wireless/ipw2200.h~ipw2200-locking-fix drivers/net/wireless/ipw2200.h
--- devel/drivers/net/wireless/ipw2200.h~ipw2200-locking-fix	2006-06-04 23:58:05.000000000 -0700
+++ devel-akpm/drivers/net/wireless/ipw2200.h	2006-06-04 23:58:05.000000000 -0700
@@ -1173,6 +1173,7 @@ struct ipw_priv {
 	struct ieee80211_device *ieee;
 
 	spinlock_t lock;
+	spinlock_t irq_lock;
 	struct mutex mutex;
 
 	/* basic pci-network driver stuff */
_
