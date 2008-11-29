From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8169 problems with net booting
Date: Sat, 29 Nov 2008 21:44:17 +0100
Message-ID: <20081129204416.GA6401@electric-eye.fr.zoreil.com>
References: <20081124181456.66a967d2@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Cc: netdev@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:40877 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751270AbYK2Uom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 15:44:42 -0500
Content-Disposition: inline
In-Reply-To: <20081124181456.66a967d2@lxorguk.ukuu.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Alan Cox <alan@lxorguk.ukuu.org.uk> :
> On one box here it has always been the case that now and then the boot
> with crash just after r8169 is loaded iff the BIOS network rom (ie the
> dhcp stuff) is enabled. Its erratic, hard to reproduce but I finally got
> around to looking at the driver and have a question that seems to apply
> to several network drivers
[...]
> The master bit is off when the driver is loaded it appears but surely the
> driver should do
>
> 	twiddle a few bits
> 	soft reset chip
> 	pci_set_master

You are right.

Can you try the attached patch against 2.6.28-rc6 and tell if it makes a
difference or not ?

While I did not test it in a BIOS network boot configuration it did not
crash trivially with these devices:
RTL8168b/8111b / XID 38000000
RTL8110s       / XID 04000000

Note to others: this patch needs testing with different chipsets (XID)
before being included upstream.

--
Ueimor

--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-r8169-enable-bus-mastering-after-the-chipset-is-res.patch"

>From 67a7da6ddf8d2f8ca7f0be04a8d70e77e2dc7285 Mon Sep 17 00:00:00 2001
From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sat, 29 Nov 2008 20:54:18 +0100
Subject: [PATCH] r8169: enable bus mastering after the chipset is reset

Based on a suggestion by Alan Cox.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 4b7cb38..b5a7358 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2011,8 +2011,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		}
 	}
 
-	pci_set_master(pdev);
-
 	/* ioremap MMIO region */
 	ioaddr = ioremap(pci_resource_start(pdev, region), R8169_REGS_SIZE);
 	if (!ioaddr) {
@@ -2039,6 +2037,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		msleep_interruptible(1);
 	}
 
+	pci_set_master(pdev);
+
 	/* Identify chip attached to board */
 	rtl8169_get_mac_version(tp, ioaddr);
 
-- 
1.5.6.5


--17pEHd4RhPHOinZp--
