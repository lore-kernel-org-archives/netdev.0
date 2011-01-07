From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] sky2: fix limited auto negotiation
Date: Thu, 6 Jan 2011 20:40:36 -0800
Message-ID: <20110106204036.1e45e982@nehalam>
References: <AANLkTimGZbDNeRccp4SkgOsJsLXjyKNq+ma4UvW=-5GG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mohsen Hariri <m.hariri@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:43688 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753518Ab1AGEko (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 23:40:44 -0500
In-Reply-To: <AANLkTimGZbDNeRccp4SkgOsJsLXjyKNq+ma4UvW=-5GG@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sky2 driver would always try all possible supported speeds even
if the user only asked for a limited set of speed/duplex combinations.

Reported-by: Mohsen Hariri <m.hariri@gmail.com>
Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2011-01-04 08:46:31.796080594 -0800
+++ b/drivers/net/sky2.c	2011-01-06 20:09:25.660684849 -0800
@@ -3411,18 +3411,15 @@ static u32 sky2_supported_modes(const st
 		u32 modes = SUPPORTED_10baseT_Half
 			| SUPPORTED_10baseT_Full
 			| SUPPORTED_100baseT_Half
-			| SUPPORTED_100baseT_Full
-			| SUPPORTED_Autoneg | SUPPORTED_TP;
+			| SUPPORTED_100baseT_Full;
 
 		if (hw->flags & SKY2_HW_GIGABIT)
 			modes |= SUPPORTED_1000baseT_Half
 				| SUPPORTED_1000baseT_Full;
 		return modes;
 	} else
-		return  SUPPORTED_1000baseT_Half
-			| SUPPORTED_1000baseT_Full
-			| SUPPORTED_Autoneg
-			| SUPPORTED_FIBRE;
+		return SUPPORTED_1000baseT_Half
+			| SUPPORTED_1000baseT_Full;
 }
 
 static int sky2_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
@@ -3436,9 +3433,11 @@ static int sky2_get_settings(struct net_
 	if (sky2_is_copper(hw)) {
 		ecmd->port = PORT_TP;
 		ecmd->speed = sky2->speed;
+		ecmd->supported |=  SUPPORTED_Autoneg | SUPPORTED_TP;
 	} else {
 		ecmd->speed = SPEED_1000;
 		ecmd->port = PORT_FIBRE;
+		ecmd->supported |=  SUPPORTED_Autoneg | SUPPORTED_FIBRE;
 	}
 
 	ecmd->advertising = sky2->advertising;
@@ -3455,8 +3454,19 @@ static int sky2_set_settings(struct net_
 	u32 supported = sky2_supported_modes(hw);
 
 	if (ecmd->autoneg == AUTONEG_ENABLE) {
+		if (ecmd->advertising & ~supported)
+			return -EINVAL;
+
+		if (sky2_is_copper(hw))
+			sky2->advertising = ecmd->advertising |
+					    ADVERTISED_TP |
+					    ADVERTISED_Autoneg;
+		else
+			sky2->advertising = ecmd->advertising |
+					    ADVERTISED_FIBRE |
+					    ADVERTISED_Autoneg;
+
 		sky2->flags |= SKY2_FLAG_AUTO_SPEED;
-		ecmd->advertising = supported;
 		sky2->duplex = -1;
 		sky2->speed = -1;
 	} else {
@@ -3500,8 +3510,6 @@ static int sky2_set_settings(struct net_
 		sky2->flags &= ~SKY2_FLAG_AUTO_SPEED;
 	}
 
-	sky2->advertising = ecmd->advertising;
-
 	if (netif_running(dev)) {
 		sky2_phy_reinit(sky2);
 		sky2_set_multicast(dev);
