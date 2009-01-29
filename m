From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/20] sfc: Fix reporting of PHY id
Date: Thu, 29 Jan 2009 19:20:47 +0000
Message-ID: <1233256847.3656.41.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:47201 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751965AbZA2TUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:20:50 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shuffle bits of the OUI into the conventional written order.

Replace PHY id component macros with functions.

Zero-pad PHY id components in log messages.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/mdio_10g.c |   15 +++++++++++++++
 drivers/net/sfc/mdio_10g.h |    8 ++++----
 drivers/net/sfc/xfp_phy.c  |    6 +++---
 3 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 4462fb5..9f5ec3e 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -17,6 +17,21 @@
 #include "boards.h"
 #include "workarounds.h"
 
+unsigned mdio_id_oui(u32 id)
+{
+	unsigned oui = 0;
+	int i;
+
+	/* The bits of the OUI are designated a..x, with a=0 and b variable.
+	 * In the id register c is the MSB but the OUI is conventionally
+	 * written as bytes h..a, p..i, x..q.  Reorder the bits accordingly. */
+	for (i = 0; i < 22; ++i)
+		if (id & (1 << (i + 10)))
+			oui |= 1 << (i ^ 7);
+
+	return oui;
+}
+
 int mdio_clause45_reset_mmd(struct efx_nic *port, int mmd,
 			    int spins, int spintime)
 {
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 8ba4977..7014d22 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -70,10 +70,10 @@
 #define MDIO_MMDREG_STAT1_LPABLE_LBN	(1)
 #define MDIO_MMDREG_STAT1_LPABLE_WIDTH	(1)
 
-/* Bits in ID reg */
-#define MDIO_ID_REV(_id32)	(_id32 & 0xf)
-#define MDIO_ID_MODEL(_id32)	((_id32 >> 4) & 0x3f)
-#define MDIO_ID_OUI(_id32)	(_id32 >> 10)
+/* Bits in combined ID regs */
+static inline unsigned mdio_id_rev(u32 id) { return id & 0xf; }
+static inline unsigned mdio_id_model(u32 id) { return (id >> 4) & 0x3f; }
+extern unsigned mdio_id_oui(u32 id);
 
 /* Bits in MMDREG_DEVS0/1. Someone thoughtfully layed things out
  * so the 'bit present' bit number of an MMD is the number of
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index 5d1c7f8..2df467d 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -88,9 +88,9 @@ static int xfp_phy_init(struct efx_nic *efx)
 		return -ENOMEM;
 	efx->phy_data = phy_data;
 
-	EFX_INFO(efx, "PHY ID reg %x (OUI %x model %x revision %x)\n",
-		 devid, MDIO_ID_OUI(devid), MDIO_ID_MODEL(devid),
-		 MDIO_ID_REV(devid));
+	EFX_INFO(efx, "PHY ID reg %x (OUI %06x model %02x revision %x)\n",
+		 devid, mdio_id_oui(devid), mdio_id_model(devid),
+		 mdio_id_rev(devid));
 
 	phy_data->phy_mode = efx->phy_mode;
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

