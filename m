From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: Hot-plug for pcnet32 ?
Date: Mon, 19 Jan 2004 08:14:08 -0800 (PST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200401191614.i0JGE9p10337@dyn318364bld.beaverton.ibm.com>
References: <200401180928.27635.deller@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linas@austin.ibm.com, tsbogend@alpha.franken.de, carstenl@mips.com,
	yoder1@us.ibm.com, go@turbolinux.co.jp, jamey@crl.dec.com,
	kaf@fc.hp.com, linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: deller@gmx.de (Helge Deller)
In-Reply-To: <200401180928.27635.deller@gmx.de> from "Helge Deller" at Jan 18, 2004 09:28:27 AM
List-Id: netdev.vger.kernel.org

> 
> > Any chance that anyone is thinking of adding hot-plug support
> > to the pcnet32 driver? 
> 
> You want to give me a hotplug machine ? :-)
> 
> Best regards,
> Helge
> -
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 

Here is a repeat of a patch to enable PCI Hot Plug for pcnet32.


--- linux-2.6.0/drivers/net/pcnet32.c	Wed Dec 10 10:43:25 2003
+++ linux-2.6.0p/drivers/net/pcnet32.c	Wed Dec 10 14:59:40 2003
@@ -806,8 +806,12 @@
     dev->tx_timeout = pcnet32_tx_timeout;
     dev->watchdog_timeo = (5*HZ);
 
-    lp->next = pcnet32_dev;
-    pcnet32_dev = dev;
+    if (pdev)
+	pci_set_drvdata(pdev, dev);
+    else {
+	lp->next = pcnet32_dev;
+	pcnet32_dev = dev;
+    }
 
     /* Fill in the generic fields of the device structure. */
     register_netdev(dev);
@@ -1703,9 +1707,25 @@
     mod_timer (&(lp->watchdog_timer), PCNET32_WATCHDOG_TIMEOUT);
 }
 
+static void __devexit pcnet32_remove_one(struct pci_dev *pdev)
+{
+    struct net_device *dev = pci_get_drvdata(pdev);
+
+    if (dev) {
+	struct pcnet32_private *lp = dev->priv;
+
+	unregister_netdev(dev);
+	release_region(dev->base_addr, PCNET32_TOTAL_SIZE);
+	pci_free_consistent(lp->pci_dev, sizeof(*lp), lp, lp->dma_addr);
+	free_netdev(dev);
+	pci_set_drvdata(pdev, NULL);
+    }
+}
+
 static struct pci_driver pcnet32_driver = {
     .name	= DRV_NAME,
     .probe	= pcnet32_probe_pci,
+    .remove	= __devexit_p(pcnet32_remove_one),
     .id_table	= pcnet32_pci_tbl,
 };
 

-- 
Don Fry
brazilnut@us.ibm.com
