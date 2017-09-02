From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] net: dsa: bcm_sf2: Configure IMP port TC2QOS mapping
Date: Sat,  2 Sep 2017 11:06:09 -0700
Message-ID: <20170902180609.23122-5-f.fainelli@gmail.com>
References: <20170902180609.23122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36780 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752779AbdIBSGW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 14:06:22 -0400
Received: by mail-oi0-f66.google.com with SMTP id x184so2409577oia.3
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 11:06:22 -0700 (PDT)
In-Reply-To: <20170902180609.23122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Even though TC2QOS mapping is for switch egress queues, we need to
configure it correclty in order for the Broadcom tag ingress (CPU ->
switch) queue selection to work correctly since there is a 1:1 mapping
between switch egress queues and ingress queues.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 6b184bafa235..d7b53d53c116 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -103,6 +103,7 @@ static void bcm_sf2_brcm_hdr_setup(struct bcm_sf2_priv *priv, int port)
 static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 {
 	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
+	unsigned int i;
 	u32 reg, offset;
 
 	if (priv->type == BCM7445_DEVICE_ID)
@@ -129,6 +130,14 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 	reg |= MII_DUMB_FWDG_EN;
 	core_writel(priv, reg, CORE_SWITCH_CTRL);
 
+	/* Configure Traffic Class to QoS mapping, allow each priority to map
+	 * to a different queue number
+	 */
+	reg = core_readl(priv, CORE_PORT_TC2_QOS_MAP_PORT(port));
+	for (i = 0; i < SF2_NUM_EGRESS_QUEUES; i++)
+		reg |= i << (PRT_TO_QID_SHIFT * i);
+	core_writel(priv, reg, CORE_PORT_TC2_QOS_MAP_PORT(port));
+
 	bcm_sf2_brcm_hdr_setup(priv, port);
 
 	/* Force link status for IMP port */
-- 
2.11.0
