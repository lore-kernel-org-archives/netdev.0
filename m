From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] r8169: use the broken_parity_status field in pci_dev
Date: Mon, 18 Dec 2006 01:08:07 +0100
Message-ID: <20061218000807.GM23747@xi.wantstofly.org>
References: <20061217230419.GB26485@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:33097 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753280AbWLRAIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Dec 2006 19:08:10 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20061217230419.GB26485@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 18, 2006 at 12:04:19AM +0100, Francois Romieu wrote:

> The former option is removed and platform code can now specify the
> expected behavior.

Thanks a lot.

FYI, I submitted this patch for the n2100 side:


Index: linux-2.6.19/arch/arm/mach-iop32x/n2100.c
===================================================================
--- linux-2.6.19.orig/arch/arm/mach-iop32x/n2100.c
+++ linux-2.6.19/arch/arm/mach-iop32x/n2100.c
@@ -123,9 +123,26 @@ static struct hw_pci n2100_pci __initdat
 
 static int __init n2100_pci_init(void)
 {
-	if (machine_is_n2100())
+	if (machine_is_n2100()) {
+		int i;
+
 		pci_common_init(&n2100_pci);
 
+		/*
+		 * Both r8169 chips on the n2100 exhibit PCI parity
+		 * problems.  Set the ->broken_parity_status flag for
+		 * both ports so that the r8169 driver knows it should
+		 * ignore error interrupts.
+		 */
+		for (i = 1; i <= 2; i++) {
+			struct pci_dev *dev;
+
+			dev = pci_get_bus_and_slot(0, PCI_DEVFN(i, 0));
+			if (dev != NULL)
+				dev->broken_parity_status = 1;
+		}
+	}
+
 	return 0;
 }
