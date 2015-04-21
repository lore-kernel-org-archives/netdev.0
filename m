From: Michael Trimarchi <michael@amarulasolutions.com>
Subject: [PATCH V2] net: stmmac: use msleep instead of udelay for gpio reset
Date: Tue, 21 Apr 2015 13:16:13 +0200
Message-ID: <1429614973-6883-1-git-send-email-michael@amarulasolutions.com>
Cc: Michael Trimarchi <michael@amarulasolutions.com>,
	Fabio Estevam <festevam@gmail.com>, netdev@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36672 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501AbbDULQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 07:16:07 -0400
Received: by pabsx10 with SMTP id sx10so238119792pab.3
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 04:16:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset delay values are expressed in microsecond but most of the
time the delay is more then 2ms and up to 100ms. Use udelay
is wrong for large sleep period. This function is not used
in interrupt context according to the documentation.

Cc: Fabio Estevam <festevam@gmail.com>
Signed-off-by: Michael Trimarchi <michael@amarulasolutions.com>

---
Changes v1 -> v2:
  - remove unreleated changes
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
index b735fa2..c843fbe 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
@@ -161,11 +161,11 @@ int stmmac_mdio_reset(struct mii_bus *bus)
 
 		if (!gpio_request(reset_gpio, "mdio-reset")) {
 			gpio_direction_output(reset_gpio, active_low ? 1 : 0);
-			udelay(data->delays[0]);
-			gpio_set_value(reset_gpio, active_low ? 0 : 1);
-			udelay(data->delays[1]);
-			gpio_set_value(reset_gpio, active_low ? 1 : 0);
-			udelay(data->delays[2]);
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
