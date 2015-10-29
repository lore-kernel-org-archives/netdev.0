From: <shh.xie@gmail.com>
Subject: [PATCH] net: phy: fix a bug in get_phy_c45_ids
Date: Thu, 29 Oct 2015 17:09:37 +0800
Message-ID: <1446109777-14846-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <f.fainelli@gmail.com>, Shaohui Xie <Shaohui.Xie@freescale.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0078.outbound.protection.outlook.com ([207.46.100.78]:34006
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750927AbbJ2Jsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 05:48:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shaohui Xie <Shaohui.Xie@freescale.com>

When probing devices-in-package for a c45 phy, device zero is the last
device to probe, in a rare situation which driver can read a '0' from
the device zero, thus c45_ids->devices_in_package is set to '0', so the
loop condition of probing is matched, see codes below:

for (i = 1;i < num_ids && c45_ids->devices_in_package == 0;i++)

driver will run in a dead loop.

So after probing the device zero, driver should stop the probing loop.

Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
---
 drivers/net/phy/phy_device.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index 3833891..065d6d3 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -257,6 +257,10 @@ retry:		reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
 				return 0;
 			}
 		}
+
+		/* stop probe when device zero was probed. */
+		if (!i)
+			break;
 	}
 
 	/* Now probe Device Identifiers for each device present. */
-- 
2.1.0.27.g96db324
