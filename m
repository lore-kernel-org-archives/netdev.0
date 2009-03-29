From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2]: ucc_geth: Fix use-after-of_node_put() in
 ucc_geth_probe().
Date: Sun, 29 Mar 2009 03:18:43 -0700 (PDT)
Message-ID: <20090329.031843.61422198.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34511
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754575AbZC2KSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2009 06:18:55 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 391C8C8C0DD
	for <netdev@vger.kernel.org>; Sun, 29 Mar 2009 03:18:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We can't put 'mdio' until after we've used it in the
fsl_pq_mdio_bus_name() call.

Also fix error return values.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ucc_geth.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 86a479f..933fcfb 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3648,15 +3648,16 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		mdio = of_get_parent(phy);
 
 		if (mdio == NULL)
-			return -1;
+			return -ENODEV;
 
 		err = of_address_to_resource(mdio, 0, &res);
-		of_node_put(mdio);
-
-		if (err)
-			return -1;
 
+		if (err) {
+			of_node_put(mdio);
+			return err;
+		}
 		fsl_pq_mdio_bus_name(bus_name, mdio);
+		of_node_put(mdio);
 		snprintf(ug_info->phy_bus_id, sizeof(ug_info->phy_bus_id),
 			"%s:%02x", bus_name, *prop);
 	}
-- 
1.6.2.1.222.g570cc

