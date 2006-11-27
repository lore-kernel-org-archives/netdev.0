From: Jens Osterkamp <jens@de.ibm.com>
Subject: [RFC][PATCH] spidernet: enable fiber autonegotiation
Date: Mon, 27 Nov 2006 15:47:07 +0100
Message-ID: <200611271547.07433.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, jklewis@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:43683 "EHLO
	mtagate3.de.ibm.com") by vger.kernel.org with ESMTP
	id S1758261AbWK0OrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Nov 2006 09:47:11 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.8/8.13.8) with ESMTP id kAREl84v134876
	for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 14:47:08 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAREoite2977908
	for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 15:50:44 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAREl8HU013096
	for <netdev@vger.kernel.org>; Mon, 27 Nov 2006 15:47:08 +0100
To: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


While experimenting with a copper passthrough module in bladecenter I found 
out that this needs autonegotiation enabled in order to work properly.
This quick hack enables it with the sideeffect of breaking other bladecenter 
switch configurations.
If anyone has any suggestions or has experimented with the same configuration, 
feel free to comment.

This patch is not meant for inclusion into mainline.

Signed-off-by: Jens Osterkamp <jens@de.ibm.com>

Index: linux-2.6.19-rc6/drivers/net/spider_net.c
===================================================================
--- linux-2.6.19-rc6.orig/drivers/net/spider_net.c
+++ linux-2.6.19-rc6/drivers/net/spider_net.c
@@ -1724,8 +1724,10 @@ spider_net_setup_phy(struct spider_net_c
  phy->mdio_read = spider_net_read_phy;
  phy->mdio_write = spider_net_write_phy;
 
+ /* reset phy, read id and setup phy struct with phy ops*/
  mii_phy_probe(phy, phy->mii_id);
 
+ /* write fix speed and duplex to BMCR */
  if (phy->def->ops->setup_forced)
   phy->def->ops->setup_forced(phy, SPEED_1000, DUPLEX_FULL);
 
Index: linux-2.6.19-rc6/drivers/net/sungem_phy.c
===================================================================
--- linux-2.6.19-rc6.orig/drivers/net/sungem_phy.c
+++ linux-2.6.19-rc6/drivers/net/sungem_phy.c
@@ -335,10 +335,6 @@ static int bcm5421_enable_fiber(struct m
  /* LEDs active in both modes, autosense prio = fiber */
  phy_write(phy, MII_NCONFIG, 0x945f);
 
- /* switch off fibre autoneg */
- phy_write(phy, MII_NCONFIG, 0xfc01);
- phy_write(phy, 0x0b, 0x0004);
-
  return 0;
 }
 
@@ -347,7 +343,7 @@ static int bcm5461_enable_fiber(struct m
  phy_write(phy, MII_NCONFIG, 0xfc0c);
  phy_write(phy, MII_BMCR, 0x4140);
  phy_write(phy, MII_NCONFIG, 0xfc0b);
- phy_write(phy, MII_BMCR, 0x0140);
+ phy_write(phy, MII_BMCR, 0x1140);
 
  return 0;
 }
