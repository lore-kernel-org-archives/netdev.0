From: Jeff Garzik <jeff@garzik.org>
Subject: [PATCH 13/17] netdrvr irq handler cleanups
Date: Sun, 21 Oct 2007 03:52:45 -0400 (EDT)
Message-ID: <20071021075245.A92B3190418@havoc.gtf.org>
References: <lkjvxcz09835mnsdfv0983q4m1234m@havoc.gtf.org>
Cc: netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:46908 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557AbXJUHwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2007 03:52:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit a9f06dc9fb3caea2c4e9b387974c9f4956434e28
Author: Jeff Garzik <jeff@garzik.org>
Date:   Fri Oct 19 19:33:31 2007 -0400

    [netdrvr] driver irq handler cleanups
    
    * no need to use 'irq' function arg, its already stored in a data struct
    
    * whitespace cleanups
    
    * delete tests for impossible conditions
    
    * remove pointless casts from void*
    
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

 drivers/net/eexpress.c          |   11 ++++++-----
 drivers/net/irda/smsc-ircc2.c   |   17 ++++-------------
 drivers/net/irda/via-ircc.c     |   12 +++---------
 drivers/net/pcmcia/fmvj18x_cs.c |    7 +------
 drivers/net/wan/sdla.c          |    5 +++--
 5 files changed, 17 insertions(+), 35 deletions(-)

a9f06dc9fb3caea2c4e9b387974c9f4956434e28
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 9c85e50..007de3b 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -456,8 +456,9 @@ static int eexp_open(struct net_device *dev)
 	if (!dev->irq || !irqrmap[dev->irq])
 		return -ENXIO;
 
-	ret = request_irq(dev->irq,&eexp_irq,0,dev->name,dev);
-	if (ret) return ret;
+	ret = request_irq(dev->irq, &eexp_irq, 0, dev->name, dev);
+	if (ret)
+		return ret;
 
 	if (!request_region(ioaddr, EEXP_IO_EXTENT, "EtherExpress")) {
 		printk(KERN_WARNING "EtherExpress io port %x, is busy.\n"
@@ -768,7 +769,7 @@ static void eexp_cmd_clear(struct net_device *dev)
 	}
 }
 
-static irqreturn_t eexp_irq(int irq, void *dev_info)
+static irqreturn_t eexp_irq(int dummy, void *dev_info)
 {
 	struct net_device *dev = dev_info;
 	struct net_local *lp;
@@ -783,7 +784,7 @@ static irqreturn_t eexp_irq(int irq, void *dev_info)
 	old_read_ptr = inw(ioaddr+READ_PTR);
 	old_write_ptr = inw(ioaddr+WRITE_PTR);
 
-	outb(SIRQ_dis|irqrmap[irq],ioaddr+SET_IRQ);
+	outb(SIRQ_dis|irqrmap[dev->irq],ioaddr+SET_IRQ);
 
 
 	status = scb_status(dev);
@@ -851,7 +852,7 @@ static irqreturn_t eexp_irq(int irq, void *dev_info)
 
 	eexp_cmd_clear(dev);
 
-	outb(SIRQ_en|irqrmap[irq],ioaddr+SET_IRQ);
+	outb(SIRQ_en|irqrmap[dev->irq],ioaddr+SET_IRQ);
 
 #if NET_DEBUG > 6
 	printk("%s: leaving eexp_irq()\n", dev->name);
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 7e7b582..1f26da7 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -1505,22 +1505,13 @@ static void smsc_ircc_sir_receive(struct smsc_ircc_cb *self)
  *    An interrupt from the chip has arrived. Time to do some work
  *
  */
-static irqreturn_t smsc_ircc_interrupt(int irq, void *dev_id)
+static irqreturn_t smsc_ircc_interrupt(int dummy, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct smsc_ircc_cb *self;
+	struct net_device *dev = dev_id;
+	struct smsc_ircc_cb *self = netdev_priv(dev);
 	int iobase, iir, lcra, lsr;
 	irqreturn_t ret = IRQ_NONE;
 
-	if (dev == NULL) {
-		printk(KERN_WARNING "%s: irq %d for unknown device.\n",
-		       driver_name, irq);
-		goto irq_ret;
-	}
-
-	self = netdev_priv(dev);
-	IRDA_ASSERT(self != NULL, return IRQ_NONE;);
-
 	/* Serialise the interrupt handler in various CPUs, stop Tx path */
 	spin_lock(&self->lock);
 
@@ -1565,7 +1556,7 @@ static irqreturn_t smsc_ircc_interrupt(int irq, void *dev_id)
 
  irq_ret_unlock:
 	spin_unlock(&self->lock);
- irq_ret:
+
 	return ret;
 }
 
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 126ec7c..58e1287 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1346,19 +1346,13 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
  *    An interrupt from the chip has arrived. Time to do some work
  *
  */
-static irqreturn_t via_ircc_interrupt(int irq, void *dev_id)
+static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 {
-	struct net_device *dev = (struct net_device *) dev_id;
-	struct via_ircc_cb *self;
+	struct net_device *dev = dev_id;
+	struct via_ircc_cb *self = dev->priv;
 	int iobase;
 	u8 iHostIntType, iRxIntType, iTxIntType;
 
-	if (!dev) {
-		IRDA_WARNING("%s: irq %d for unknown device.\n", driver_name,
-			     irq);
-		return IRQ_NONE;
-	}
-	self = (struct via_ircc_cb *) dev->priv;
 	iobase = self->io.fir_base;
 	spin_lock(&self->lock);
 	iHostIntType = GetHostStatus(iobase);
diff --git a/drivers/net/pcmcia/fmvj18x_cs.c b/drivers/net/pcmcia/fmvj18x_cs.c
index 6284467..d251bd1 100644
--- a/drivers/net/pcmcia/fmvj18x_cs.c
+++ b/drivers/net/pcmcia/fmvj18x_cs.c
@@ -731,18 +731,13 @@ module_exit(exit_fmvj18x_cs);
 
 /*====================================================================*/
 
-static irqreturn_t fjn_interrupt(int irq, void *dev_id)
+static irqreturn_t fjn_interrupt(int dummy, void *dev_id)
 {
     struct net_device *dev = dev_id;
     local_info_t *lp = netdev_priv(dev);
     kio_addr_t ioaddr;
     unsigned short tx_stat, rx_stat;
 
-    if (lp == NULL) {
-        printk(KERN_NOTICE "fjn_interrupt(): irq %d for "
-	       "unknown device.\n", irq);
-        return IRQ_NONE;
-    }
     ioaddr = dev->base_addr;
 
     /* avoid multiple interrupts */
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 05df0a3..73e2f27 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -867,7 +867,7 @@ static void sdla_receive(struct net_device *dev)
 	spin_unlock_irqrestore(&sdla_lock, flags);
 }
 
-static irqreturn_t sdla_isr(int irq, void *dev_id)
+static irqreturn_t sdla_isr(int dummy, void *dev_id)
 {
 	struct net_device     *dev;
 	struct frad_local *flp;
@@ -879,7 +879,8 @@ static irqreturn_t sdla_isr(int irq, void *dev_id)
 
 	if (!flp->initialized)
 	{
-		printk(KERN_WARNING "%s: irq %d for uninitialized device.\n", dev->name, irq);
+		printk(KERN_WARNING "%s: irq %d for uninitialized device.\n",
+		       dev->name, dev->irq);
 		return IRQ_NONE;
 	}
 
