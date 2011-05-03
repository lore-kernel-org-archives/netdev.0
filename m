From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Subject: [PATCH] net: ehea: fix wrongly-reported supported modes
Date: Tue, 03 May 2011 16:42:25 -0300
Message-ID: <1304451745.6899.15.camel@dream>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:40032 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661Ab1ECTme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 15:42:34 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p43Gfpg0003360
	for <netdev@vger.kernel.org>; Tue, 3 May 2011 13:41:51 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p43Jdb1w4911264
	for <netdev@vger.kernel.org>; Tue, 3 May 2011 16:39:39 -0300
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p43JgBIV029923
	for <netdev@vger.kernel.org>; Tue, 3 May 2011 16:42:11 -0300
Received: from [9.12.227.105] ([9.12.227.105])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id p43JgAV5029877
	for <netdev@vger.kernel.org>; Tue, 3 May 2011 16:42:10 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently EHEA reports to ethtool as supporting 10000baseT_Full and
FIBRE independent of the hardware configuration. However, these
capabilities should be reported only if the physical port and
the medium support them, which is the case where the physical port
is connected at 10Gb.

Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea_ethtool.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 3e2e734..04716c2 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -55,15 +55,22 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->duplex = -1;
 	}

-	cmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_1000baseT_Full
-		       | SUPPORTED_100baseT_Full |  SUPPORTED_100baseT_Half
-		       | SUPPORTED_10baseT_Full | SUPPORTED_10baseT_Half
-		       | SUPPORTED_Autoneg | SUPPORTED_FIBRE);
+	cmd->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full
+		       | SUPPORTED_100baseT_Half | SUPPORTED_10baseT_Full
+		       | SUPPORTED_10baseT_Half | SUPPORTED_Autoneg);

-	cmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_Autoneg
-			 | ADVERTISED_FIBRE);
+	cmd->advertising = ADVERTISED_Autoneg;
+
+	if (cmd->speed == SPEED_10000) {
+		cmd->supported |= (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
+		cmd->advertising |= (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
+		cmd->port = PORT_FIBRE;
+	} else {
+		cmd->supported |= SUPPORTED_TP;
+		cmd->advertising |= (ADVERTISED_1000baseT_Full | ADVERTISED_TP);
+		cmd->port = PORT_TP;
+	}

-	cmd->port = PORT_FIBRE;
 	cmd->autoneg = port->autoneg == 1 ? AUTONEG_ENABLE : AUTONEG_DISABLE;

 	return 0;
-- 
1.7.1



