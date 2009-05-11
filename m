From: Michael Buesch <mb@bu3sch.de>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Mon, 11 May 2009 23:10:08 +0200
Message-ID: <200905112310.08534.mb@bu3sch.de>
References: <200903041828.49972.m.bueker@berlin.de> <1242001754.4093.12.camel@obelisk.thedillows.org> <200905112248.44868.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Michael Riepe <michael.riepe@googlemail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?utf-8?q?B=C3=BCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:49989 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752392AbZEKVMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 17:12:45 -0400
In-Reply-To: <200905112248.44868.mb@bu3sch.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 May 2009 22:48:44 Michael Buesch wrote:
> On Monday 11 May 2009 02:29:14 David Dillow wrote:
> > > Kernel: 2.6.29.2 (x86_64)
> > > Board: Intel D945GCLF2
> > > BIOS version: LF94510J.86A.0099.2008.0731.0303
> > 
> > I'm not sure this is tied to the chip. 
> 
> Yeah maybe other chips are affected as well.
> I just want to note that my failing chip/board is an Intel D945GCLF2 board
> with onboard G-LAN, too.
> 
> The device XID is: XID 3c4000c0
> (see kernel log)
> 
> Somebody else (I think it was Rui Santos) already reported a failing chip with that XID, too.
> 

Here's a patch which blacklists MSI support by XID.
It's currently only compile-tested, because I can't reboot the machine right now.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: linux-2.6.29/drivers/net/r8169.c
===================================================================
--- linux-2.6.29.orig/drivers/net/r8169.c	2009-05-11 23:00:12.000000000 +0200
+++ linux-2.6.29/drivers/net/r8169.c	2009-05-11 23:07:32.000000000 +0200
@@ -1917,14 +1917,26 @@
 
 /* Cfg9346_Unlock assumed. */
 static unsigned rtl_try_msi(struct pci_dev *pdev, void __iomem *ioaddr,
-			    const struct rtl_cfg_info *cfg)
+			    const struct rtl_cfg_info *cfg, u32 xid)
 {
-	unsigned msi = 0;
+	unsigned i, blacklisted = 0, msi = 0;
 	u8 cfg2;
 
+	static const u32 xid_blacklist[] = {
+		/* Blacklisted devices with (currently) broken MSI support.
+		 * Devices are identified by XID. */
+		0x3c4000c0,
+	};
+
 	cfg2 = RTL_R8(Config2) & ~MSIEnable;
+	for (i = 0; i < ARRAY_SIZE(xid_blacklist); i++) {
+		if (xid == xid_blacklist[i])
+			blacklisted = 1;
+	}
 	if (cfg->features & RTL_FEATURE_MSI) {
-		if (pci_enable_msi(pdev)) {
+		if (blacklisted) {
+			dev_info(&pdev->dev, "MSI blacklisted. Back to INTx.\n");
+		} else if (pci_enable_msi(pdev)) {
 			dev_info(&pdev->dev, "no MSI. Back to INTx.\n");
 		} else {
 			cfg2 |= MSIEnable;
@@ -1974,6 +1986,7 @@
 	void __iomem *ioaddr;
 	unsigned int i;
 	int rc;
+	u32 xid;
 
 	if (netif_msg_drv(&debug)) {
 		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
@@ -2109,6 +2122,7 @@
 	}
 	tp->chipset = i;
 
+	xid = RTL_R32(TxConfig) & 0x7cf0f8ff;
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W8(Config1, RTL_R8(Config1) | PMEnable);
 	RTL_W8(Config5, RTL_R8(Config5) & PMEStatus);
@@ -2116,7 +2130,7 @@
 		tp->features |= RTL_FEATURE_WOL;
 	if ((RTL_R8(Config5) & (UWF | BWF | MWF)) != 0)
 		tp->features |= RTL_FEATURE_WOL;
-	tp->features |= rtl_try_msi(pdev, ioaddr, cfg);
+	tp->features |= rtl_try_msi(pdev, ioaddr, cfg, xid);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
 	if ((tp->mac_version <= RTL_GIGA_MAC_VER_06) &&
@@ -2175,8 +2189,6 @@
 	pci_set_drvdata(pdev, dev);
 
 	if (netif_msg_probe(tp)) {
-		u32 xid = RTL_R32(TxConfig) & 0x7cf0f8ff;
-
 		printk(KERN_INFO "%s: %s at 0x%lx, "
 		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
 		       "XID %08x IRQ %d\n",


-- 
Greetings, Michael.
