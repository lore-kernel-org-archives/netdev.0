From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC 5/5] net: dsa: bcm_sf2: Allow disabling tagging protocol
Date: Tue, 25 Aug 2015 15:50:15 -0700
Message-ID: <1440543015-14693-6-git-send-email-f.fainelli@gmail.com>
References: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, linux@roeck-us.net,
	jiri@resnulli.us, sfeldma@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36185 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932665AbbHYWxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 18:53:53 -0400
Received: by pacgr6 with SMTP id gr6so4825918pac.3
        for <netdev@vger.kernel.org>; Tue, 25 Aug 2015 15:53:53 -0700 (PDT)
In-Reply-To: <1440543015-14693-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the IMP port configuration to check whether tagging is enabled
(DSA_TAG_PROTO_BRCM) or disabled (DSA_TAG_PROTO_NONE) and correctly
program the relevant registers in both cases.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 289e20443d83..68abcc545231 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -159,6 +159,7 @@ static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 
 static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 {
+	bool tagging_disabled = !!(ds->tag_protocol == DSA_TAG_PROTO_NONE);
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	u32 reg, val;
 
@@ -199,21 +200,30 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 
 	/* Enable Broadcom tags for IMP port */
 	reg = core_readl(priv, CORE_BRCM_HDR_CTRL);
-	reg |= val;
+	if (!tagging_disabled)
+		reg |= val;
+	else
+		reg &= ~val;
 	core_writel(priv, reg, CORE_BRCM_HDR_CTRL);
 
 	/* Enable reception Broadcom tag for CPU TX (switch RX) to
 	 * allow us to tag outgoing frames
 	 */
 	reg = core_readl(priv, CORE_BRCM_HDR_RX_DIS);
-	reg &= ~(1 << port);
+	if (tagging_disabled)
+		reg |= 1 << port;
+	else
+		reg &= ~(1 << port);
 	core_writel(priv, reg, CORE_BRCM_HDR_RX_DIS);
 
 	/* Enable transmission of Broadcom tags from the switch (CPU RX) to
 	 * allow delivering frames to the per-port net_devices
 	 */
 	reg = core_readl(priv, CORE_BRCM_HDR_TX_DIS);
-	reg &= ~(1 << port);
+	if (tagging_disabled)
+		reg |= 1 << port;
+	else
+		reg &= ~(1 << port);
 	core_writel(priv, reg, CORE_BRCM_HDR_TX_DIS);
 
 	/* Force link status for IMP port */
-- 
2.1.0
