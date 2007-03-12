From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 2/6] [TULIP]  From: Thibaut VARENE <T-Bone@parisc-linux.org>
Date: Mon, 12 Mar 2007 02:31:30 -0700
Message-ID: <20070312184217.409509000@linux.intel.com>
References: <20070312093128.577087000@linux.intel.com>
Cc: netdev@vger.kernel.org, Thibaut VARENE <varenet@parisc-linux.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	Valerie Henson <val_henson@linux.intel.com>
To: Jeff Garzik <jeff@garzik.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:37894 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751448AbXCLSmO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 14:42:14 -0400
Content-Disposition: inline; filename=tulip-natsemi-dp83840a-phy-fix.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix a problem with Tulip 21142 HP branded PCI cards (PN#: B5509-66001),
which feature a NatSemi DP83840A PHY.

Without that patch, it is impossible to properly initialize the card's PHY,
and it's thus impossible to monitor/configure it.

[VAL: I'm happy with the 1.5 ms max delay; it doesn't seem excessive.]

Signed-off-by: Thibaut VARENE <varenet@parisc-linux.org>
Cc: Jeff Garzik <jgarzik@pobox.com>
Acked-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tulip/media.c |   18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff -puN drivers/net/tulip/media.c~tulip-natsemi-dp83840a-phy-fix drivers/net/tulip/media.c
--- a/drivers/net/tulip/media.c~tulip-natsemi-dp83840a-phy-fix
+++ a/drivers/net/tulip/media.c
@@ -263,11 +263,27 @@ void tulip_select_media(struct net_devic
 				u16 *reset_sequence = &((u16*)(p+3))[init_length];
 				int reset_length = p[2 + init_length*2];
 				misc_info = reset_sequence + reset_length;
-				if (startup)
+				if (startup) {
+					int timeout = 10;	/* max 1 ms */
 					for (i = 0; i < reset_length; i++)
 						iowrite32(get_u16(&reset_sequence[i]) << 16, ioaddr + CSR15);
+
+					/* flush posted writes */
+					ioread32(ioaddr + CSR15);
+
+					/* Sect 3.10.3 in DP83840A.pdf (p39) */
+					udelay(500);
+
+					/* Section 4.2 in DP83840A.pdf (p43) */
+					/* and IEEE 802.3 "22.2.4.1.1 Reset" */
+					while (timeout-- &&
+						(tulip_mdio_read (dev, phy_num, MII_BMCR) & BMCR_RESET))
+						udelay(100);
+				}
 				for (i = 0; i < init_length; i++)
 					iowrite32(get_u16(&init_sequence[i]) << 16, ioaddr + CSR15);
+
+				ioread32(ioaddr + CSR15);	/* flush posted writes */
 			} else {
 				u8 *init_sequence = p + 2;
 				u8 *reset_sequence = p + 3 + init_length;
_

--
