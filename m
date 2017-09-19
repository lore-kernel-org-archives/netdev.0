From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 04/12] net: dsa: bcm_sf2: Defer port enabling to calling port_enable
Date: Tue, 19 Sep 2017 10:46:46 -0700
Message-ID: <20170919174654.2122-5-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:37316 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdISRrO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:14 -0400
Received: by mail-wm0-f68.google.com with SMTP id f4so304246wmh.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:13 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to configure the enabled ports once in bcm_sf2_sw_setup() and
then a second time around when dsa_switch_ops::port_enable is called, just do
it when port_enable is called which is better in terms of power consumption and
correctness.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index d7b53d53c116..8acbd17bc1fd 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -890,14 +890,11 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
 	unsigned int port;
 
-	/* Enable all valid ports and disable those unused */
+	/* Disable unused ports and configure IMP port */
 	for (port = 0; port < priv->hw_params.num_ports; port++) {
-		/* IMP port receives special treatment */
-		if ((1 << port) & ds->enabled_port_mask)
-			bcm_sf2_port_setup(ds, port, NULL);
-		else if (dsa_is_cpu_port(ds, port))
+		if (dsa_is_cpu_port(ds, port))
 			bcm_sf2_imp_setup(ds, port);
-		else
+		else if (!((1 << port) & ds->enabled_port_mask))
 			bcm_sf2_port_disable(ds, port, NULL);
 	}
 
-- 
2.9.3
