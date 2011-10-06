From: Madalin Bucur <madalin.bucur@freescale.com>
Subject: [PATCH 2/3] net/phy: avoid reaching an unsupported speed and duplex combination
Date: Thu, 6 Oct 2011 19:48:46 +0300
Message-ID: <1317919726-25867-1-git-send-email-madalin.bucur@freescale.com>
Reply-To: <madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <afleming@freescale.com>,
	Madalin Bucur <madalin.bucur@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:30976
	"EHLO DB3EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935709Ab1JFQsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 12:48:23 -0400
Received: from mail84-db3 (localhost.localdomain [127.0.0.1])	by
 mail84-db3-R.bigfish.com (Postfix) with ESMTP id 47C0E5E8448	for
 <netdev@vger.kernel.org>; Thu,  6 Oct 2011 16:48:22 +0000 (UTC)
Received: from DB3EHSMHS014.bigfish.com (unknown [10.3.81.240])	by
 mail84-db3.bigfish.com (Postfix) with ESMTP id 20C141670050	for
 <netdev@vger.kernel.org>; Thu,  6 Oct 2011 16:48:22 +0000 (UTC)
Received: from madalin-fedora64.ea.freescale.net
 (udp126375uds.ea.freescale.net [10.171.73.201])	by az33smr01.freescale.net
 (8.13.1/8.13.0) with ESMTP id p96GmFML004996	for <netdev@vger.kernel.org>;
 Thu, 6 Oct 2011 11:48:17 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 - phy_force_reduction() may get the interface into a speed and duplex combination 
 that is not supported by the device;
 - wait PHY_FORCE_TIMEOUT before each speed/duplex reduction in forced mode

Signed-off-by: Madalin Bucur <madalin.bucur@freescale.com>
---
 drivers/net/phy/phy.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index 79268f6..31d6519 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -6,7 +6,7 @@
  *
  * Author: Andy Fleming
  *
- * Copyright (c) 2004 Freescale Semiconductor, Inc.
+ * Copyright (c) 2004,2011 Freescale Semiconductor, Inc.
  * Copyright (c) 2006, 2007  Maciej W. Rozycki
  *
  * This program is free software; you can redistribute  it and/or modify it
@@ -479,6 +479,10 @@ static void phy_force_reduction(struct phy_device *phydev)
 
 	idx = phy_find_valid(idx, phydev->supported);
 
+	/* Avoid reaching an invalid speed and duplex combination */
+	if (!(settings[idx].setting & phydev->supported))
+		return;
+
 	phydev->speed = settings[idx].speed;
 	phydev->duplex = settings[idx].duplex;
 
@@ -869,6 +873,8 @@ void phy_state_machine(struct work_struct *work)
 				if (0 == phydev->link_timeout--) {
 					phy_force_reduction(phydev);
 					needs_aneg = 1;
+					phydev->link_timeout =
+						PHY_FORCE_TIMEOUT;
 				}
 			}
 
-- 
1.7.0.1
