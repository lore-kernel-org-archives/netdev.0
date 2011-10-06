From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 3/3] net/phy: abort genphy_read_status when link changes during speed and duplex reading
Date: Thu, 6 Oct 2011 19:48:57 +0300
Message-ID: <1317919737-25893-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <afleming@freescale.com>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe001.messaging.microsoft.com ([213.199.154.139]:55728
	"EHLO DB3EHSOBE001.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935224Ab1JFQsd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 12:48:33 -0400
Received: from mail103-db3 (localhost.localdomain [127.0.0.1])	by
 mail103-db3-R.bigfish.com (Postfix) with ESMTP id 6360E6C83A3	for
 <netdev@vger.kernel.org>; Thu,  6 Oct 2011 16:48:32 +0000 (UTC)
Received: from DB3EHSMHS005.bigfish.com (unknown [10.3.81.251])	by
 mail103-db3.bigfish.com (Postfix) with ESMTP id 32EA4B9004F	for
 <netdev@vger.kernel.org>; Thu,  6 Oct 2011 16:48:32 +0000 (UTC)
Received: from madalin-fedora64.ea.freescale.net
 (udp126375uds.ea.freescale.net [10.171.73.201])	by az33smr01.freescale.net
 (8.13.1/8.13.0) with ESMTP id p96GmPl3005220	for <netdev@vger.kernel.org>;
 Thu, 6 Oct 2011 11:48:28 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the link changes during speed and duplex reading the values may be out of sync;
abort the update if the link state changes during the read

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/phy/phy_device.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index a1e132c..e88f49a 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -824,6 +824,16 @@ int genphy_read_status(struct phy_device *phydev)
 
 		lpa &= adv;
 
+		err = phy_read(phydev, MII_BMSR);
+
+		if (err < 0)
+			return err;
+
+		/* if the link changed while reading speed and duplex
+		 * abort the speed and duplex update */
+		if (((err & BMSR_LSTATUS) == 0) != (phydev->link == 0))
+			return 0;
+
 		phydev->speed = SPEED_10;
 		phydev->duplex = DUPLEX_HALF;
 		phydev->pause = phydev->asym_pause = 0;
-- 
1.7.0.1
