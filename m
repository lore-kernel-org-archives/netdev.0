From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: [PATCH] ehea: fix wrongly reported speed and port
Date: Wed, 04 May 2011 20:05:11 -0300
Message-ID: <1304550311.28342.19.camel@dream>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Breno Leitao <leitao@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:52951 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756196Ab1EDXFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 19:05:20 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p44K4oxX031622
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 17:04:50 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p44N2PpQ4530396
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 20:02:25 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p44N4xWL005896
	for <netdev@vger.kernel.org>; Wed, 4 May 2011 20:05:00 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently EHEA reports to ethtool as supporting 10M, 100M, 1G and
10G and connected to FIBRE independent of the hardware configuration.
However, when connected to FIBRE the only supported speed is 10G
full-duplex, and the other speeds and modes are only supported
when connected to twisted pair.

Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_ethtool.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 3e2e734..f3bbdce 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -55,15 +55,20 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->duplex = -1;
 	}

-	cmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_1000baseT_Full
-		       | SUPPORTED_100baseT_Full |  SUPPORTED_100baseT_Half
-		       | SUPPORTED_10baseT_Full | SUPPORTED_10baseT_Half
-		       | SUPPORTED_Autoneg | SUPPORTED_FIBRE);
-
-	cmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_Autoneg
-			 | ADVERTISED_FIBRE);
+	if (cmd->speed == SPEED_10000) {
+		cmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+		cmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
+		cmd->port = PORT_FIBRE;
+	} else {
+		cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full
+			       | SUPPORTED_100baseT_Half | SUPPORTED_10baseT_Full
+			       | SUPPORTED_10baseT_Half | SUPPORTED_Autoneg
+			       | SUPPORTED_TP);
+		cmd->advertising = (ADVERTISED_1000baseT_Full | ADVERTISED_Autoneg
+				 | ADVERTISED_TP);
+		cmd->port = PORT_TP;
+	}

-	cmd->port = PORT_FIBRE;
 	cmd->autoneg = port->autoneg == 1 ? AUTONEG_ENABLE : AUTONEG_DISABLE;

 	return 0;
-- 
1.7.1



