From: Leann Ogasawara <ogasawara@osdl.org>
Subject: Re: [janitor] depca: release resources on errors
Date: Thu, 29 Jan 2004 18:14:13 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1075428853.24801.51.camel@ibm-d.pdx.osdl.net>
References: <20040124223109.1c134ca1.rddunlap@osdl.org>
	 <4013F096.4090705@pobox.com> <20040125193017.450d6ff8.rddunlap@osdl.org>
	 <401496AA.4000404@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Randy Dunlap <rddunlap@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <401496AA.4000404@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 2004-01-25 at 20:25, Jeff Garzik wrote:
[snip]
> > dgrs: add iounmap()s to failure paths -- still missed (*Leann)
> 
> this wants fixing as well

Updated and rediffed janitor cleanup for drivers/net/dgrs.c against
netdev-2.6.  I don't have the hardware to fully test, but module
compiled/loaded/unloaded fine.  Feedback appreciated.  Thanks,

Leann

===== drivers/net/dgrs.c 1.23 vs edited =====
--- 1.23/drivers/net/dgrs.c	Thu Jan  8 08:44:05 2004
+++ edited/drivers/net/dgrs.c	Thu Jan 29 17:13:05 2004
@@ -327,8 +327,11 @@
 	 */
 	priv0->vplxdma[PLX_DMA0_MODE/4] = 0xFFFFFFFF;
 	x = priv0->vplxdma[PLX_DMA0_MODE/4];
-	if (x != 0x00001FFF)
+	if (x != 0x00001FFF) {
+		iounmap((void *) priv0->vplxdma);
+		priv0->vplxdma = NULL;
 		return (0);
+	}
 
 	return (1);
 }
@@ -989,6 +992,7 @@
 {
 	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
 	int		is;
+	int		ret;
 	unsigned long	i;
 
 	static int	iv2is[16] = {
@@ -1004,7 +1008,8 @@
 	if (!priv0->vmem)
 	{
 		printk("%s: cannot map in board memory\n", dev0->name);
-		return -ENXIO;
+		ret = -ENXIO;
+		goto err_out;
 	}
 
 	/*
@@ -1020,7 +1025,8 @@
 		if (!is)
 		{
 			printk("%s: Illegal IRQ %d\n", dev0->name, dev0->irq);
-			return -ENXIO;
+			ret = -ENXIO;
+			goto err_iounmap_vmem;
 		}
 		OUTB(dev0->base_addr + ES4H_AS_31_24,
 			(uchar) (dev0->mem_start >> 24) );
@@ -1047,10 +1053,9 @@
 	memcpy(priv0->vmem, dgrs_code, dgrs_ncode);	/* Load code */
 	if (memcmp(priv0->vmem, dgrs_code, dgrs_ncode))
 	{
-		iounmap(priv0->vmem);
-		priv0->vmem = NULL;
 		printk("%s: download compare failed\n", dev0->name);
-		return -ENXIO;
+		ret = -ENXIO;
+		goto err_iounmap_vplxdma;
 	}
 
 	/*
@@ -1101,7 +1106,8 @@
 	if (priv0->bcomm->bc_status < BC_RUN)
 	{
 		printk("%s: board not operating\n", dev0->name);
-		return -ENXIO;
+		ret = -ENXIO;
+		goto err_iounmap_vplxdma;
 	}
 
 	priv0->port = (PORT *) S2H(priv0->bcomm->bc_port);
@@ -1139,6 +1145,19 @@
 	}
 
 	return (0);
+
+ err_iounmap_vplxdma:
+	if (priv0->vplxdma) {
+		iounmap((void *) priv0->vplxdma);
+		priv0->vplxdma = NULL;
+	}
+
+ err_iounmap_vmem:
+	iounmap(priv0->vmem);
+
+ err_out:
+	priv0->vmem = NULL;
+	return ret;
 }
 
 /*
@@ -1175,7 +1194,7 @@
 	{
 		printk("%s: Illegal Ethernet Address\n", dev->name);
 		rc = -ENXIO;
-		goto err_out;
+		goto err_iounmap;
 	}
 
 	/*
@@ -1187,7 +1206,7 @@
 	
 	rc = request_irq(dev->irq, &dgrs_intr, SA_SHIRQ, "RightSwitch", dev);
 	if (rc)
-		goto err_out;
+		goto err_iounmap;
 
 	priv->intrcnt = 0;
 	for (i = jiffies + 2*HZ + HZ/2; time_after(i, jiffies); )
@@ -1218,6 +1237,15 @@
 
 err_free_irq:
 	free_irq(dev->irq, dev);
+
+err_iounmap:
+	if (priv->vplxdma) {
+		iounmap((void *) priv->vplxdma);
+		priv->vplxdma = NULL;
+	}
+	iounmap(priv->vmem);
+	priv->vmem = NULL;
+
 err_out:
        	return rc;
 }
@@ -1331,13 +1359,21 @@
 
  fail:	
 	while (i >= 0) {
-		struct net_device *d = priv->devtbl[i--];
+		struct net_device *d = priv->devtbl[--i];
 		unregister_netdev(d);
 		free_netdev(d);
 	}
 
  err2:
 	free_irq(dev->irq, dev);
+	if (priv->vplxdma) {
+		iounmap((void *) priv->vplxdma);
+		priv->vplxdma = NULL;
+	}
+
+	iounmap(priv->vmem);
+	priv->vmem = NULL;
+
  err1:
 	free_netdev(dev);
  err0:
@@ -1364,15 +1400,10 @@
 	if (priv->vmem)
 		iounmap(priv->vmem);
 	if (priv->vplxdma)
-		iounmap((uchar *) priv->vplxdma);
+		iounmap((void *) priv->vplxdma);
 
 	if (dev->irq)
 		free_irq(dev->irq, dev);
-
-	for (i = 1; i < priv->nports; ++i) {
-		if (priv->devtbl[i])
-			unregister_netdev(priv->devtbl[i]);
-	}
 }
 
 #ifdef CONFIG_PCI
    
