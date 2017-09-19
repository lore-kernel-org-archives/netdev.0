From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 03/12] net: dsa: b53: Defer port enabling to calling port_enable
Date: Tue, 19 Sep 2017 10:46:45 -0700
Message-ID: <20170919174654.2122-4-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35492 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdISRrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:11 -0400
Received: by mail-wr0-f195.google.com with SMTP id n64so184160wrb.2
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:11 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to configure the enabled ports once in b53_setup() and then a
second time around when dsa_switch_ops::port_enable is called, just do it when
port_enable is called which is better in terms of power consumption and
correctness.

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index d8bc54cfcfbe..3297af6aab8a 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -815,12 +815,13 @@ static int b53_setup(struct dsa_switch *ds)
 	if (ret)
 		dev_err(ds->dev, "failed to apply configuration\n");
 
+	/* Configure IMP/CPU port, disable unused ports. Enabled
+	 * ports will be configured with .port_enable
+	 */
 	for (port = 0; port < dev->num_ports; port++) {
-		if (BIT(port) & ds->enabled_port_mask)
-			b53_enable_port(ds, port, NULL);
-		else if (dsa_is_cpu_port(ds, port))
+		if (dsa_is_cpu_port(ds, port))
 			b53_enable_cpu_port(dev, port);
-		else
+		else if (!(BIT(port) & ds->enabled_port_mask))
 			b53_disable_port(ds, port, NULL);
 	}
 
-- 
2.9.3
