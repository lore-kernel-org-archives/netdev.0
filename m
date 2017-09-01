From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/4] net: dsa: bcm_sf2: Configure IMP port TC2QOS mapping
Date: Fri,  1 Sep 2017 16:59:14 -0700
Message-ID: <1504310354-42773-5-git-send-email-f.fainelli@gmail.com>
References: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35579 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752649AbdIBAF1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 20:05:27 -0400
Received: by mail-qk0-f193.google.com with SMTP id p67so1211340qkd.2
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 17:05:27 -0700 (PDT)
In-Reply-To: <1504310354-42773-1-git-send-email-f.fainelli@gmail.com>
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
index 3f1ad9d5d7c5..fc9f9f171e55 100644
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
+	for (i = 0; i < 8; i++)
+		reg |= i << (PRT_TO_QID_SHIFT * i);
+	core_writel(priv, reg, CORE_PORT_TC2_QOS_MAP_PORT(port));
+
 	bcm_sf2_brcm_hdr_setup(priv, port);
 
 	/* Force link status for IMP port */
-- 
1.9.1
