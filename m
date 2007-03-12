From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 3/6] [TULIP]  fix for Lite-On 82c168 PNIC
Date: Mon, 12 Mar 2007 02:31:31 -0700
Message-ID: <20070312184217.818534000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: netdev@vger.kernel.org, Val Henson <val_henson@linux.intel.com>,
	Guido Classen <classeng@clagi.de>,
	Grant Grundler <grundler@parisc-linux.org>
To: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:37894 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751560AbXCLSmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 14:42:15 -0400
Content-Disposition: inline; filename=tulip-fix-for-lite-on
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Guido Classen <classeng@clagi.de>

This small patch fixes two issues with the Lite-On 82c168 PNIC adapters.
I've tested it with two cards in different machines both chip rev 17

The first is the wrong register address CSR6 for writing the MII register
which instead is 0xB8 (this may get a symbol too?) (see similar exisiting code
at line 437) in tulip_core.c

[Double-checked by Val Henson; yes, 0xB8 is correct register for
autonegotiate on this card.]

At least by my cards, the the bit 31 from the MII register seems to be
somewhat unstable. This results in reading wrong values from the Phy-Registers
und prevents the card from correct initialization. I've added a litte delay
and an second test of the bit. If the bit is stil cleared the read/write
process has definitely finished.

[Original patch slightly massaged by Val Henson]

Signed-off-by: Val Henson <val_henson@linux.intel.com>
Cc: Guido Classen <classeng@clagi.de>
Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Cc: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/media.c      |   31 +++++++++++++++++++++++++++----
 drivers/net/tulip/tulip_core.c |    4 ++--
 2 files changed, 29 insertions(+), 6 deletions(-)

--- pristine-linux.orig/drivers/net/tulip/tulip_core.c
+++ pristine-linux/drivers/net/tulip/tulip_core.c
@@ -1689,8 +1689,8 @@ static int __devinit tulip_init_one (str
 			tp->nwayset = 0;
 			iowrite32(csr6_ttm | csr6_ca, ioaddr + CSR6);
 			iowrite32(0x30, ioaddr + CSR12);
-			iowrite32(0x0001F078, ioaddr + CSR6);
-			iowrite32(0x0201F078, ioaddr + CSR6); /* Turn on autonegotiation. */
+			iowrite32(0x0001F078, ioaddr + 0xB8);
+			iowrite32(0x0201F078, ioaddr + 0xB8); /* Turn on autonegotiation. */
 		}
 		break;
 	case MX98713:
--- pristine-linux.orig/drivers/net/tulip/media.c
+++ pristine-linux/drivers/net/tulip/media.c
@@ -76,8 +76,20 @@ int tulip_mdio_read(struct net_device *d
 		ioread32(ioaddr + 0xA0);
 		while (--i > 0) {
 			barrier();
-			if ( ! ((retval = ioread32(ioaddr + 0xA0)) & 0x80000000))
-				break;
+			if ( ! ((retval = ioread32(ioaddr + 0xA0))
+                                & 0x80000000)) {
+				/*
+				 * Possible bug in 82c168 rev 17 -
+                                 * sometimes bit 31 is unstable and
+                                 * clears before actually finished.
+                                 * Delay and check if bit 31 is still
+                                 * cleared before believing it.
+				 */
+                                udelay(10);
+                                if ( ! ((retval = ioread32(ioaddr + 0xA0))
+                                        & 0x80000000))
+                                        break;
+                        }
 		}
 		spin_unlock_irqrestore(&tp->mii_lock, flags);
 		return retval & 0xffff;
@@ -136,8 +148,19 @@ void tulip_mdio_write(struct net_device 
 		iowrite32(cmd, ioaddr + 0xA0);
 		do {
 			barrier();
-			if ( ! (ioread32(ioaddr + 0xA0) & 0x80000000))
-				break;
+			if ( ! (ioread32(ioaddr + 0xA0) & 0x80000000)) {
+				/*
+				 * Possible bug in 82c168 rev 17 -
+                                 * sometimes bit 31 is unstable and
+                                 * clears before actually finished.
+                                 * Delay and check if bit 31 is still
+                                 * cleared before believing it.
+				 */
+                                udelay(10);
+                                if ( ! (ioread32(ioaddr + 0xA0)
+                                        & 0x80000000))
+                                        break;
+                        }
 		} while (--i > 0);
 		spin_unlock_irqrestore(&tp->mii_lock, flags);
 		return;

--
