From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: [PATCH] phy: fix phy_id detection also for broken hardware.
Date: Thu, 20 Nov 2008 16:57:36 +0100
Message-ID: <1227196656-4361-1-git-send-email-peppe.cavallaro@st.com>
Cc: davem@davemloft.net, giulio.benetti@micronovasrl.com,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog106.obsmtp.com ([207.126.144.121]:60075 "EHLO
	eu1sys200aog106.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755409AbYKTQBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 11:01:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the case when the phy_ids is mostly Fs and in some case 0x0
due to broken hardware.

Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/phy/phy_device.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 8fb1fac..effa489 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -227,8 +227,17 @@ struct phy_device * get_phy_device(struct mii_bus *bus, int addr)
 	if (r)
 		return ERR_PTR(r);
 
-	/* If the phy_id is all Fs or all 0s, there is no device there */
-	if ((0xffff == phy_id) || (0x00 == phy_id))
+	/* If the phy_id is mostly Fs, there is no device there */
+	if ((phy_id & 0x1fffffff) == 0x1fffffff)
+		return NULL;
+
+	/*
+	 * Broken hardware is sometimes missing the pull down resistor on the
+	 * MDIO line, which results in reads to non-existent devices returning
+	 * 0 rather than 0xffff. Catch this here and treat 0 as a non-existent
+	 * device as well.
+	 */ 
+	if (phy_id == 0)
 		return NULL;
 
 	dev = phy_device_create(bus, addr, phy_id);
-- 
1.5.6.5

