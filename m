From: Michael Trimarchi <michael@amarulasolutions.com>
Subject: [RFC][PATCH] net: stmmac: use msleep instead of udelay for gpio reset
Date: Sat, 18 Apr 2015 17:02:39 +0200
Message-ID: <1429369359-8204-1-git-send-email-michael@amarulasolutions.com>
Cc: netdev@vger.kernel.org
To: Michael Trimarchi <michael@amarulasolutions.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34864 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbbDRPCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2015 11:02:36 -0400
Received: by pabtp1 with SMTP id tp1so156981155pab.2
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2015 08:02:36 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset delay values are expressed in microsecond but most of the
time the delay is more then 2ms and up to 100ms. Use udelay
is wrong for large sleep period. This function is not used
in interrupt context according to the documentation.

Signed-off-by: Michael Trimarchi <michael@amarulasolutions.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index b735fa2..009a86a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -157,15 +157,15 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 		}
 
 		reset_gpio = data->reset_gpio;
-		active_low = data->active_low;
+		active_low = !!data->active_low;
 
 		if (!gpio_request(reset_gpio, "mdio-reset")) {
-			gpio_direction_output(reset_gpio, active_low ? 1 : 0);
-			udelay(data->delays[0]);
-			gpio_set_value(reset_gpio, active_low ? 0 : 1);
-			udelay(data->delays[1]);
-			gpio_set_value(reset_gpio, active_low ? 1 : 0);
-			udelay(data->delays[2]);
+			gpio_direction_output(reset_gpio, active_low);
+			msleep(max(1U, data->delays[0] / 1000));
+			gpio_set_value(reset_gpio, !active_low);
+			msleep(max(1U, data->delays[1] / 1000));
+			gpio_set_value(reset_gpio, active_low);
+			msleep(max(1U, data->delays[2] / 1000));
 		}
 	}
 #endif
-- 
1.9.1
