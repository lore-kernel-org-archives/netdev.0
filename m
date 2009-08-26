From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 3/7] mdio: Check MDIO_STAT1_FAULT in mdio45_links_ok()
Date: Wed, 26 Aug 2009 19:16:58 +0100
Message-ID: <1251310618.27345.13.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:59916 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752590AbZHZSQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 14:16:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some PHYs will report that the link is up even though there is a fault
condition.  Therefore, check the fault flag too.  We must also read
STAT2 to reset this flag.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/mdio.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mdio.c b/drivers/net/mdio.c
index 6851bdb..7d2e610 100644
--- a/drivers/net/mdio.c
+++ b/drivers/net/mdio.c
@@ -109,13 +109,20 @@ int mdio45_links_ok(const struct mdio_if_info *mdio, u32 mmd_mask)
 		if (mmd_mask & (1 << devad)) {
 			mmd_mask &= ~(1 << devad);
 
-			/* Read twice because link state is latched and a
-			 * read moves the current state into the register */
+			/* Reset the latched status and fault flags */
 			mdio->mdio_read(mdio->dev, mdio->prtad,
 					devad, MDIO_STAT1);
+			if (devad == MDIO_MMD_PMAPMD || devad == MDIO_MMD_PCS ||
+			    devad == MDIO_MMD_PHYXS || devad == MDIO_MMD_DTEXS)
+				mdio->mdio_read(mdio->dev, mdio->prtad,
+						devad, MDIO_STAT2);
+
+			/* Check the current status and fault flags */
 			reg = mdio->mdio_read(mdio->dev, mdio->prtad,
 					      devad, MDIO_STAT1);
-			if (reg < 0 || !(reg & MDIO_STAT1_LSTATUS))
+			if (reg < 0 ||
+			    (reg & (MDIO_STAT1_FAULT | MDIO_STAT1_LSTATUS)) !=
+			    MDIO_STAT1_LSTATUS)
 				return false;
 		}
 	}

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

