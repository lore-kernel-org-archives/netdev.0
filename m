From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Road Runner HIPPI driver (rrunner)
Date: Fri, 12 Sep 2003 15:25:06 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912152506.693fe997.shemminger@osdl.org>
References: <20030912144208.2886e2b9.shemminger@osdl.org>
	<3F62437F.9080202@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@wildopensource.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F62437F.9080202@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Okay, how about this..

--- linux-2.5/drivers/net/rrunner.c	2003-08-20 11:19:42.000000000 -0700
+++ linux-2.5-net/drivers/net/rrunner.c	2003-09-12 15:22:32.714314883 -0700
@@ -124,7 +124,6 @@ static int __devinit rr_init_one(struct 
 	rrpriv->pci_dev = pdev;
 
 	spin_lock_init(&rrpriv->lock);
-	sprintf(rrpriv->name, "RoadRunner serial HIPPI");
 
 	dev->irq = pdev->irq;
 	dev->open = &rr_open;
@@ -228,7 +227,7 @@ static int __devinit rr_init_one(struct 
 		pci_set_drvdata(pdev, NULL);
 	}
  out2:
-	kfree(dev);
+	free_netdev(dev);
  out3:
 	return ret;
 }
@@ -236,9 +235,10 @@ static int __devinit rr_init_one(struct 
 static void __devexit rr_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct rr_private *rr = (struct rr_private *)dev->priv;
 
 	if (dev) {
+		struct rr_private *rr = dev->priv;
+
 		if (!(readl(&rr->regs->HostCtrl) & NIC_HALTED)){
 			printk(KERN_ERR "%s: trying to unload running NIC\n",
 			       dev->name);
@@ -1201,8 +1201,7 @@ static int rr_open(struct net_device *de
 	readl(&regs->HostCtrl);
 	spin_unlock_irqrestore(&rrpriv->lock, flags);
 
-	if (request_irq(dev->irq, rr_interrupt, SA_SHIRQ, rrpriv->name, dev))
-	{
+	if (request_irq(dev->irq, rr_interrupt, SA_SHIRQ, dev->name, dev)) {
 		printk(KERN_WARNING "%s: Requested IRQ %d is busy\n",
 		       dev->name, dev->irq);
 		ecode = -EAGAIN;
@@ -1222,7 +1221,6 @@ static int rr_open(struct net_device *de
 
 	netif_start_queue(dev);
 
-	MOD_INC_USE_COUNT;
 	return ecode;
 
  error:
@@ -1414,7 +1412,6 @@ static int rr_close(struct net_device *d
 	free_irq(dev->irq, dev);
 	spin_unlock_irqrestore(&rrpriv->lock, flags);
 
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
@@ -1727,7 +1724,7 @@ static struct pci_driver rr_driver = {
 	.name		= "rrunner",
 	.id_table	= rr_pci_tbl,
 	.probe		= rr_init_one,
-	.remove		= rr_remove_one,
+	.remove		= __devexit_p(rr_remove_one),
 };
 
 static int __init rr_init_module(void)
--- linux-2.5/drivers/net/rrunner.h	2003-06-16 20:47:08.000000000 -0700
+++ linux-2.5-net/drivers/net/rrunner.h	2003-09-12 14:40:51.000000000 -0700
@@ -820,7 +820,6 @@ struct rr_private
 	u32			tx_full;
 	u32			fw_rev;
 	volatile short		fw_running;
-	char			name[24];	/* The assigned name */
 	struct net_device_stats stats;
 	struct pci_dev		*pci_dev;
 };
