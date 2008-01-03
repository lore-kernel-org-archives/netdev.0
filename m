From: Esa-Pekka.Pyokkimies@stonesoft.com
Subject: ethtool reporting wrong speed and duplex when link partner is forced
Date: Thu, 3 Jan 2008 08:55:03 +0200
Message-ID: <OFC54F9C4B.20A9ABF3-ONC22573C5.0025885A-C22573C5.0025FFFC@stonesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hki-smtp-2b.stonesoft.com ([84.34.144.172]:58817 "EHLO
	hki-smtp-2b.stonesoft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbYACHR7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 02:17:59 -0500
Received: from hki-smtp-2b.stonesoft.com (localhost.localdomain [127.0.0.1])
	by localhost.stonesoft.com (Postfix) with ESMTP id 583F31B566D
	for <netdev@vger.kernel.org>; Thu,  3 Jan 2008 08:55:04 +0200 (EET)
Received: from hki-notes-1.stonesoft.com (unknown [172.16.49.35])
	by hki-smtp-2b.stonesoft.com (Postfix) with ESMTP id 37E391B4D8E
	for <netdev@vger.kernel.org>; Thu,  3 Jan 2008 08:55:04 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello,

In drivers/net/mii.c, is there a reason why mii_nway_result is used to
find the speed and duplex settings when autonegation is on?  This
gives wrong result when autoneg is on, but we are making link to a
host which is forced. In this case the variable lpa is 0, and
mii_nway_result(advert & lpa) gives LPA_10HALF, which is wrong.
The real speed can be found from the BMCR register.

This is how it looks like with ethtool:

# ethtool eth1
...
        Advertised auto-negotiation: Yes
        Speed: 10Mb/s
        Duplex: Half
        Auto-negotiation: on
        Link detected: yes

# ethtool -d eth1
...
0x62: MII Basic Mode Control Register             0x3000
0x68: MII Link Partner Ability                    0x0000

And looking at mii.h we see that this implies BMCR_SPEED100 and
BMCR_ANENABLE, i.e. we are in 100 half duplex, as we should be (link
partner was forced to 100 full duplex).

Below is a quick patch you can comment. I have not yet tested this myself.

Esa-Pekka

--- 1.20/drivers/net/mii.c      2007-04-28 18:01:05 +03:00
+++ 1.21/drivers/net/mii.c      2008-01-03 08:25:42 +02:00
@@ -90,31 +90,16 @@ int mii_ethtool_gset(struct mii_if_info
        if (bmcr & BMCR_ANENABLE) {
                ecmd->advertising |= ADVERTISED_Autoneg;
                ecmd->autoneg = AUTONEG_ENABLE;
-
-               nego = mii_nway_result(advert & lpa);
-               if ((bmcr2 & (ADVERTISE_1000HALF | ADVERTISE_1000FULL)) &
-                   (lpa2 >> 2))
-                       ecmd->speed = SPEED_1000;
-               else if (nego == LPA_100FULL || nego == LPA_100HALF)
-                       ecmd->speed = SPEED_100;
-               else
-                       ecmd->speed = SPEED_10;
-               if ((lpa2 & LPA_1000FULL) || nego == LPA_100FULL ||
-                   nego == LPA_10FULL) {
-                       ecmd->duplex = DUPLEX_FULL;
-                       mii->full_duplex = 1;
-               } else {
-                       ecmd->duplex = DUPLEX_HALF;
-                       mii->full_duplex = 0;
-               }
        } else {
                ecmd->autoneg = AUTONEG_DISABLE;
-
-               ecmd->speed = ((bmcr & BMCR_SPEED1000 &&
-                               (bmcr & BMCR_SPEED100) == 0) ? SPEED_1000 :
-                              (bmcr & BMCR_SPEED100) ? SPEED_100 :
SPEED_10);
-               ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL :
DUPLEX_HA\
LF;
        }
+
+
+       ecmd->speed = ((bmcr & BMCR_SPEED1000 &&
+                       (bmcr & BMCR_SPEED100) == 0) ? SPEED_1000 :
+                      (bmcr & BMCR_SPEED100) ? SPEED_100 : SPEED_10);
+       ecmd->duplex = (bmcr & BMCR_FULLDPLX) ? DUPLEX_FULL : DUPLEX_HALF;
+

        /* ignore maxtxpkt, maxrxpkt for now */

