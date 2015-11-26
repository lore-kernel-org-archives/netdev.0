From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net v2] gianfar: Don't use NO_IRQ to check return value of irq_of_parse_and_map()
Date: Thu, 26 Nov 2015 16:01:45 +0200
Message-ID: <1448546505-9509-1-git-send-email-claudiu.manoil@freescale.com>
References: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0132.outbound.protection.outlook.com ([157.56.110.132]:22567
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751277AbbKZOgo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Nov 2015 09:36:44 -0500
In-Reply-To: <1448539186-5756-1-git-send-email-broonie@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>

This driver can be built on arm64 but relies on NO_IRQ to check the return
value of irq_of_parse_and_map() which fails to build on arm64 because the
architecture does not provide a NO_IRQ. Fix this to correctly check the
return value of irq_of_parse_and_map().

Even on ARM systems where the driver was previously used the check was
broken since on ARM NO_IRQ is -1 but irq_of_parse_and_map() returns 0 on
error.

Signed-off-by: Mark Brown <broonie@kernel.org>
Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2: even better, do the obvious tx handling fix

 drivers/net/ethernet/freescale/gianfar.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 3e6b9b4..5fdd2e7 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -642,14 +642,14 @@ static int gfar_parse_group(struct device_node *np,
 		return -ENOMEM;
 
 	gfar_irq(grp, TX)->irq = irq_of_parse_and_map(np, 0);
+	if (!gfar_irq(grp, TX)->irq)
+		return -EINVAL;
 
 	/* If we aren't the FEC we have multiple interrupts */
 	if (model && strcasecmp(model, "FEC")) {
 		gfar_irq(grp, RX)->irq = irq_of_parse_and_map(np, 1);
 		gfar_irq(grp, ER)->irq = irq_of_parse_and_map(np, 2);
-		if (gfar_irq(grp, TX)->irq == NO_IRQ ||
-		    gfar_irq(grp, RX)->irq == NO_IRQ ||
-		    gfar_irq(grp, ER)->irq == NO_IRQ)
+		if (!gfar_irq(grp, RX)->irq || !gfar_irq(grp, ER)->irq)
 			return -EINVAL;
 	}
 
-- 
1.7.11.7
