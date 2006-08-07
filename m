From: Kyle McMartin <kyle@parisc-linux.org>
Subject: [PATCH 1/9] [TULIP] Fix PHY init and reset
Date: Mon, 07 Aug 2006 20:53:24 +0000
Message-ID: <11549840122892-git-send-email-kyle@parisc-linux.org>
References: <20060807204418.GE401@athena.road.mcmartin.ca>
Reply-To: Kyle McMartin <kyle@parisc-linux.org>
Cc: grundler@parisc-linux.org, val_henson@linux.intel.com,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:63464 "EHLO hera.kernel.org")
	by vger.kernel.org with ESMTP id S932356AbWHGUxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2006 16:53:50 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060807204418.GE401@athena.road.mcmartin.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Grundler <grundler@parisc-linux.org>

A whole slew of fixes for tulip_select_media for:
 - Flush posted MMIO writes as per PCI spec
 - Polling the reset bit (bit 15) is required to determine when
   the "init" sequence can be sent.

This fixes tulip on HP PA-RISC systems, which use DP83840A and
LXT971D PHYs. Tested for several years on a variety of HP PA-RISC
systems.

[Initial work done by Grant Grundler, DS21142 support added by
Thibaut Varene.]

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Thibaut Varene <varenet@parisc-linux.org>
Signed-off-by: Kyle McMartin <kyle@parisc-linux.org>
---
 drivers/net/tulip/media.c |   40 +++++++++++++++++++++++++++++++++++++---
 1 files changed, 37 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tulip/media.c b/drivers/net/tulip/media.c
index e9bc2a9..5093d87 100644
--- a/drivers/net/tulip/media.c
+++ b/drivers/net/tulip/media.c
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
@@ -261,24 +263,56 @@ void tulip_select_media(struct net_devic
 				u16 *reset_sequence = &((u16*)(p+3))[init_length];
 				int reset_length = p[2 + init_length*2];
 				misc_info = reset_sequence + reset_length;
-				if (startup)
+				if (startup) {
+					int timeout = 10;
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
 				int reset_length = p[2 + init_length];
 				misc_info = (u16*)(reset_sequence + reset_length);
 				if (startup) {
+					int timeout = 10;
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
-- 
1.4.1.1

