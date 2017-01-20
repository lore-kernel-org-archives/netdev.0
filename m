From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 5/7] net: dsa: bcm_sf2: Allow non-IMP ports to have Broadcom tags enabled
Date: Fri, 20 Jan 2017 12:36:32 -0800
Message-ID: <20170120203634.2773-6-f.fainelli@gmail.com>
References: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34359 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753661AbdATUgs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:48 -0500
Received: by mail-pf0-f196.google.com with SMTP id y143so6039367pfb.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:48 -0800 (PST)
In-Reply-To: <20170120203634.2773-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parse the "brcm,use-bcm-hdr" boolean property during ports
identification to fill a bitmask of ports that should have Broadcom tags
enabled. This is needed in some configurations where per-packet metadata
can be exchanged using Broadcom tags between the switch and an on-chip
acceleration device.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 .../devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt          | 8 ++++++++
 drivers/net/dsa/bcm_sf2.c                                         | 7 +++++++
 drivers/net/dsa/bcm_sf2.h                                         | 3 +++
 3 files changed, 18 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt b/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
index e1b2c3e32859..9a734d808aa7 100644
--- a/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
+++ b/Documentation/devicetree/bindings/net/brcm,bcm7445-switch-v4.0.txt
@@ -41,6 +41,13 @@ Optional properties:
   Admission Control Block supports reporting the number of packets in-flight in a
   switch queue
 
+Port subnodes:
+
+Optional properties:
+
+- brcm,use-bcm-hdr: boolean property, if present, indicates that the switch
+  port has Broadcom tags enabled (per-packet metadata)
+
 Example:
 
 switch_top@f0b00000 {
@@ -114,6 +121,7 @@ switch_top@f0b00000 {
 			port@0 {
 				label = "gphy";
 				reg = <0>;
+				brcm,use-bcm-hdr;
 			};
 			...
 		};
diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 571e112c8e34..8eecfd227e06 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -236,6 +236,10 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	reg &= ~P_TXQ_PSM_VDD(port);
 	core_writel(priv, reg, CORE_MEM_PSM_VDD_CTRL);
 
+	/* Enable Broadcom tags for that port if requested */
+	if (priv->brcm_tag_mask & BIT(port))
+		bcm_sf2_brcm_hdr_setup(priv, port);
+
 	/* Clear the Rx and Tx disable bits and set to no spanning tree */
 	core_writel(priv, 0, CORE_G_PCTL_PORT(port));
 
@@ -515,6 +519,9 @@ static void bcm_sf2_identify_ports(struct bcm_sf2_priv *priv,
 
 		if (mode == PHY_INTERFACE_MODE_MOCA)
 			priv->moca_port = port_num;
+
+		if (of_property_read_bool(port, "brcm,use-bcm-hdr"))
+			priv->brcm_tag_mask |= 1 << port_num;
 	}
 }
 
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index a1430866bd79..6e1f74e4d471 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -100,6 +100,9 @@ struct bcm_sf2_priv {
 	struct device_node		*master_mii_dn;
 	struct mii_bus			*slave_mii_bus;
 	struct mii_bus			*master_mii_bus;
+
+	/* Bitmask of ports needing BRCM tags */
+	unsigned int			brcm_tag_mask;
 };
 
 static inline struct bcm_sf2_priv *bcm_sf2_to_priv(struct dsa_switch *ds)
-- 
2.9.3
