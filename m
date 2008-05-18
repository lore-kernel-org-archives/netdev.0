From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: hibernate event order question
Date: Sun, 18 May 2008 14:24:34 +0200
Message-ID: <20080518122433.GA16663@yamamaya.is-a-geek.org>
References: <20080517175046.GA9032@yamamaya.is-a-geek.org> <200805181245.13899.rjw@sisk.pl> <20080518112247.GA10502@yamamaya.is-a-geek.org> <200805181332.13941.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:60487 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761781AbYERMZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 May 2008 08:25:07 -0400
Content-Disposition: inline
In-Reply-To: <200805181332.13941.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rafael J. Wysocki wrote:
> On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> > Rafael J. Wysocki wrote:
> > > On Sunday, 18 of May 2008, Tobias Diedrich wrote:
> > > > Tobias Diedrich wrote:
> > > > > > > Shouldn't there be a 'prepare for poweroff'-callback, which gets
> > > > > > > called
> > > > > > > before the system is powered off for real?
> > > > > > 
> > > > > > Yes, it should and it's called in recent kernels.
> > > > > 
> > > > > For what values of 'recent'?
> > > > > I'm running 2.6.26-rc2 here. :)
> > > > > How do I hook into this callback?
> > > > > (suspend_late maybe? Going to try that one next...)
> > > > 
> > > > Ok, this patch fixes the 'regression' introduced by the previous
> > > > patch (at least for me ;)):
> > > 
> > > Well, what exactly do you do to hibernate the box?
> > 
> > |#!/bin/sh
> > |
> > |SYSPRINTK=/proc/sys/kernel/printk
> > |OLDPRINTK=$(cat $SYSPRINTK)
> > |chvt 1
> > |# work around forcedeth wake-on-lan bug
> > |#rmmod forcedeth
> > |echo 9 > $SYSPRINTK
> > |# shutdown/reboot/platform
> > |echo shutdown > /sys/power/disk
> 
> You don't see the devices' suspend callbacks invoked before powering off
> because of this.  Change that to 'platform' (unless that breaks things).

Hmm, I think someone recommended to use shutdown since that is
supposed to be more reliable.
Anyway, I think the shutdown hook is good anyway since I suspect
that if I do a normal system shutdown with promiscous mode still on,
then wake-on-lan would also not work?
I haven't checked that though.
At least I think the shutdown hook won't hurt. :)

> I'm unable to comment on the device-specific things, but apart from this the
> patch looks okay to me except for one thing.
> > +	if (np->wolenabled) 
> > +		pci_set_power_state(pdev, PCI_D3hot);
> > +	else pci_set_power_state(pdev, PCI_D3cold);
> 
> I'm not sure if it's possible to put the device into D3cold without actually
> removing power from it.

Ok, I've cleaned it up a bit and split it up properly (I think):
http://www.tdiedrich.de/~ranma/patches/forcedeth/2.6.26-rc2/
series:
forcedeth.resume.promisc.patch
forcedeth.hibernate.wol.patch
forcedeth.swappedmac.patch
forcedeth.reorder_suspend_resume.patch



forcedeth.resume.promisc.patch:
nv_open() resets multicast settings, call nv_set_multicast(dev) to restore them.
(Maybe this should rather be moved into nv_open())

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 13:52:59.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:53:02.000000000 +0200
@@ -5823,6 +5823,7 @@
 	writel(txreg, base + NvRegTransmitPoll);
 
 	rc = nv_open(dev);
+	nv_set_multicast(dev);
 out:
 	return rc;
 }



forcedeth.hibernate.wol.patch:
When hibernating in 'shutdown' mode, after saving the image the suspend hook
is not called again.
However, if the device is in promiscous mode, wake-on-lan will not work.
This adds a shutdown hook to setup wake-on-lan before the final shutdown.

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 13:53:02.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:53:06.000000000 +0200
@@ -5827,8 +5827,23 @@
 out:
 	return rc;
 }
+
+static void nv_shutdown(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
+
+	if (netif_running(dev))
+		nv_close(dev);
+
+	pci_enable_wake(pdev, PCI_D3hot, np->wolenabled);
+	pci_enable_wake(pdev, PCI_D3cold, np->wolenabled);
+	pci_disable_device(pdev);
+	pci_set_power_state(pdev, PCI_D3hot);
+}
 #else
 #define nv_suspend NULL
+#define nv_shutdown NULL
 #define nv_resume NULL
 #endif /* CONFIG_PM */
 
@@ -5999,6 +6014,7 @@
 	.remove		= __devexit_p(nv_remove),
 	.suspend	= nv_suspend,
 	.resume		= nv_resume,
+	.shutdown	= nv_shutdown,
 };
 
 static int __init init_nic(void)



forcedeth.swappedmac.patch:
The memory mapped device configuration space is lost during hibernate.
Save and restore it (fixes 'swapped mac' problem).

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 13:53:06.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:53:10.000000000 +0200
@@ -426,6 +426,7 @@
 #define NV_PCI_REGSZ_VER1      	0x270
 #define NV_PCI_REGSZ_VER2      	0x2d4
 #define NV_PCI_REGSZ_VER3      	0x604
+#define NV_PCI_REGSZ_MAX       	0x604
 
 /* various timeout delays: all in usec */
 #define NV_TXRX_RESET_DELAY	4
@@ -784,6 +785,9 @@
 
 	/* flow control */
 	u32 pause_flags;
+
+	/* power saved state */
+	u32 saved_config_space[NV_PCI_REGSZ_MAX/4];
 };
 
 /*
@@ -5785,6 +5789,8 @@
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	int i;
 
 	if (!netif_running(dev))
 		goto out;
@@ -5794,6 +5800,10 @@
 	// Gross.
 	nv_close(dev);
 
+	/* save non-pci configuration space */
+	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+		np->saved_config_space[i] = readl(base + i*sizeof(u32));
+
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -5804,9 +5814,9 @@
 static int nv_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
+	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	int rc = 0;
-	u32 txreg;
+	int i, rc = 0;
 
 	if (!netif_running(dev))
 		goto out;
@@ -5817,10 +5827,9 @@
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
 
-	/* restore mac address reverse flag */
-	txreg = readl(base + NvRegTransmitPoll);
-	txreg |= NVREG_TRANSMITPOLL_MAC_ADDR_REV;
-	writel(txreg, base + NvRegTransmitPoll);
+	/* restore non-pci configuration space */
+	for (i = 0;i <= np->register_size/sizeof(u32); i++)
+		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
 	rc = nv_open(dev);
 	nv_set_multicast(dev);



forcedeth.reorder_suspend_resume.patch:
Match the suspend/resume code ordering in e100/e1000e more closely.
For example the configuration space should be saved on suspend even for
devices that are not up.

Index: linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c
===================================================================
--- linux-2.6.26-rc2.forcedwol.orig/drivers/net/forcedeth.c	2008-05-18 13:53:10.000000000 +0200
+++ linux-2.6.26-rc2.forcedwol/drivers/net/forcedeth.c	2008-05-18 13:54:04.000000000 +0200
@@ -5792,22 +5792,20 @@
 	u8 __iomem *base = get_hwbase(dev);
 	int i;
 
-	if (!netif_running(dev))
-		goto out;
-
+	if (netif_running(dev)) {
+		// Gross.
+		nv_close(dev);
+	}
 	netif_device_detach(dev);
 
-	// Gross.
-	nv_close(dev);
-
 	/* save non-pci configuration space */
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		np->saved_config_space[i] = readl(base + i*sizeof(u32));
 
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), np->wolenabled);
+	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-out:
 	return 0;
 }
 
@@ -5818,22 +5816,20 @@
 	u8 __iomem *base = get_hwbase(dev);
 	int i, rc = 0;
 
-	if (!netif_running(dev))
-		goto out;
-
-	netif_device_attach(dev);
-
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
+	/* ack any pending wake events, disable PME */
 	pci_enable_wake(pdev, PCI_D0, 0);
 
 	/* restore non-pci configuration space */
 	for (i = 0;i <= np->register_size/sizeof(u32); i++)
 		writel(np->saved_config_space[i], base+i*sizeof(u32));
 
-	rc = nv_open(dev);
-	nv_set_multicast(dev);
-out:
+	netif_device_attach(dev);
+	if (netif_running(dev)) {
+		rc = nv_open(dev);
+		nv_set_multicast(dev);
+	}
 	return rc;
 }
 

-- 
Tobias						PGP: http://9ac7e0bc.uguu.de
このメールは十割再利用されたビットで作られています。
