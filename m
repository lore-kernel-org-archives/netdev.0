From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 1/6] [TULIP]  From: Jim Gifford <maillist@jg555.com>, Grant Grundler <grundler@parisc-linux.org>, Peter Horton <pdh@colonel-panic.org>
Date: Mon, 12 Mar 2007 02:31:29 -0700
Message-ID: <20070312184216.848494000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: netdev@vger.kernel.org,
	Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
To: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:37894 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751450AbXCLSmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 14:42:13 -0400
Content-Disposition: inline; filename=tulip-fix-for-64-bit-mips.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With Grant's help I was able to get the tulip driver to work with 64 bit 
MIPS.

[VAL: I'm happy with the 1.5 ms max delay; it doesn't seem excessive.]

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Cc: Jeff Garzik <jgarzik@pobox.com>
---

 drivers/net/tulip/media.c |   22 ++++++++++++++++++++--
 drivers/net/tulip/tulip.h |    7 +++++--
 2 files changed, 25 insertions(+), 4 deletions(-)

diff -puN drivers/net/tulip/media.c~tulip-fix-for-64-bit-mips drivers/net/tulip/media.c
--- a/drivers/net/tulip/media.c~tulip-fix-for-64-bit-mips
+++ a/drivers/net/tulip/media.c
@@ -44,8 +44,10 @@ static const unsigned char comet_miireg2
 
 /* MII transceiver control section.
    Read and write the MII registers using software-generated serial
-   MDIO protocol.  See the MII specifications or DP83840A data sheet
-   for details. */
+   MDIO protocol.
+   See IEEE 802.3-2002.pdf (Section 2, Chapter "22.2.4 Management functions")
+   or DP83840A data sheet for more details.
+   */
 
 int tulip_mdio_read(struct net_device *dev, int phy_id, int location)
 {
@@ -272,13 +274,29 @@ void tulip_select_media(struct net_devic
 				int reset_length = p[2 + init_length];
 				misc_info = (u16*)(reset_sequence + reset_length);
 				if (startup) {
+					int timeout = 10;	/* max 1 ms */
 					iowrite32(mtable->csr12dir | 0x100, ioaddr + CSR12);
 					for (i = 0; i < reset_length; i++)
 						iowrite32(reset_sequence[i], ioaddr + CSR12);
+
+					/* flush posted writes */
+					ioread32(ioaddr + CSR12);
+
+					/* Sect 3.10.3 in DP83840A.pdf (p39) */
+					udelay(500);
+
+					/* Section 4.2 in DP83840A.pdf (p43) */
+					/* and IEEE 802.3 "22.2.4.1.1 Reset" */
+					while (timeout-- &&
+						(tulip_mdio_read (dev, phy_num, MII_BMCR) & BMCR_RESET))
+						udelay(100);
 				}
 				for (i = 0; i < init_length; i++)
 					iowrite32(init_sequence[i], ioaddr + CSR12);
+
+				ioread32(ioaddr + CSR12);	/* flush posted writes */
 			}
+
 			tmp_info = get_u16(&misc_info[1]);
 			if (tmp_info)
 				tp->advertising[phy_num] = tmp_info | 1;
diff -puN drivers/net/tulip/tulip.h~tulip-fix-for-64-bit-mips drivers/net/tulip/tulip.h
--- a/drivers/net/tulip/tulip.h~tulip-fix-for-64-bit-mips
+++ a/drivers/net/tulip/tulip.h
@@ -482,8 +482,11 @@ static inline void tulip_stop_rxtx(struc
 			udelay(10);
 
 		if (!i)
-			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed\n",
-					pci_name(tp->pdev));
+			printk(KERN_DEBUG "%s: tulip_stop_rxtx() failed"
+					" (CSR5 0x%x CSR6 0x%x)\n",
+					pci_name(tp->pdev),
+					ioread32(ioaddr + CSR5),
+					ioread32(ioaddr + CSR6));
 	}
 }
 
_

--
