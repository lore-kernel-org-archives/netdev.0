From: akpm@osdl.org
Subject: [patch 2/9] tulip: NatSemi DP83840A PHY fix
Date: Thu, 27 Apr 2006 02:30:36 -0700
Message-ID: <200604270932.k3R9W4Xj025312@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, T-Bone@parisc-linux.org,
	grundler@parisc-linux.org, jgarzik@pobox.com,
	varenet@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17359 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965026AbWD0JcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:32:14 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Thibaut VARENE <T-Bone@parisc-linux.org>

Fix a problem with Tulip 21142 HP branded PCI cards (PN#: B5509-66001),
which feature a NatSemi DP83840A PHY.

Without that patch, it is impossible to properly initialize the card's PHY,
and it's thus impossible to monitor/configure it.

It's a timing/posting problem, and it is solved exactly the same way Grant
fixed it elsewhere already.

Signed-off-by: Thibaut VARENE <varenet@parisc-linux.org>
Cc: Jeff Garzik <jgarzik@pobox.com>
Acked-by: Grant Grundler <grundler@parisc-linux.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/tulip/media.c |   18 +++++++++++++++++-
 1 files changed, 17 insertions(+), 1 deletion(-)

diff -puN drivers/net/tulip/media.c~tulip-natsemi-dp83840a-phy-fix drivers/net/tulip/media.c
--- devel/drivers/net/tulip/media.c~tulip-natsemi-dp83840a-phy-fix	2006-04-10 23:21:18.000000000 -0700
+++ devel-akpm/drivers/net/tulip/media.c	2006-04-10 23:21:18.000000000 -0700
@@ -261,11 +261,27 @@ void tulip_select_media(struct net_devic
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
