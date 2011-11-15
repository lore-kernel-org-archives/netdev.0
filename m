From: Grant Grundler <grundler@chromium.org>
Subject: [PATCH 2/5] net-next:asix:poll in asix_get_phyid in case phy not ready
Date: Tue, 15 Nov 2011 09:12:40 -0800
Message-ID: <1321377163-26308-2-git-send-email-grundler@chromium.org>
References: <1321377163-26308-1-git-send-email-grundler@chromium.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Allan Chou <allan@asix.com.tw>,
	Freddy Xin <freddy@asix.com.tw>,
	Grant Grundler <grundler@google.com>,
	Grant Grundler <grundler@chromium.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:50392 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab1KORTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 12:19:07 -0500
In-Reply-To: <1321377163-26308-1-git-send-email-grundler@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@google.com>

Sometimes the phy isn't ready after reset...poll and pray it will be soon.

Signed-off-by: Freddy Xin <freddy@asix.com.tw>
Signed-off-by: Grant Grundler <grundler@chromium.org>
---
 drivers/net/usb/asix.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 873860d..b4675e8 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -652,9 +652,17 @@ static u32 asix_get_phyid(struct usbnet *dev)
 {
 	int phy_reg;
 	u32 phy_id;
+	int i;
 
-	phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
-	if (phy_reg < 0)
+	/* Poll for the rare case the FW or phy isn't ready yet.  */
+	for (i = 0; i < 100; i++) {
+		phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
+		if (phy_reg != 0 && phy_reg != 0xFFFF)
+			break;
+		mdelay(1);
+	}
+
+	if (phy_reg <= 0 || phy_reg == 0xFFFF)
 		return 0;
 
 	phy_id = (phy_reg & 0xffff) << 16;
-- 
1.7.3.1
