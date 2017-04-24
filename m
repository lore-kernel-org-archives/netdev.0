From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/3] net: dsa: b53: Include IMP/CPU port in dumb forwarding mode
Date: Mon, 24 Apr 2017 14:27:21 -0700
Message-ID: <20170424212723.15407-2-f.fainelli@gmail.com>
References: <20170424212723.15407-1-f.fainelli@gmail.com>
Cc: andrew@lunn.ch, vivien.didelot@savoifairelinux.com,
        eric@anholt.net, jon.mason@broadcom.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35973 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S978271AbdDXV1c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 17:27:32 -0400
Received: by mail-wm0-f67.google.com with SMTP id u65so20608239wmu.3
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 14:27:32 -0700 (PDT)
In-Reply-To: <20170424212723.15407-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since Broadcom tags are not enabled in b53 (DSA_PROTO_TAG_NONE), we need
to make sure that the IMP/CPU port is included in the forwarding
decision.

Without this change, switching between non-management ports would work,
but not between management ports and non-management ports thus breaking
the default state in which DSA switch are brought up.

Fixes: 967dd82ffc52 ("net: dsa: b53: Add support for Broadcom RoboSwitch")
Reported-by: Eric Anholt <eric@anholt.net>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 10 ++++++++++
 drivers/net/dsa/b53/b53_regs.h   |  4 ++++
 2 files changed, 14 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 8cf4801994e8..ca7f3b005a29 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -326,6 +326,7 @@ static void b53_get_vlan_entry(struct b53_device *dev, u16 vid,
 
 static void b53_set_forwarding(struct b53_device *dev, int enable)
 {
+	struct dsa_switch *ds = dev->ds;
 	u8 mgmt;
 
 	b53_read8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, &mgmt);
@@ -336,6 +337,15 @@ static void b53_set_forwarding(struct b53_device *dev, int enable)
 		mgmt &= ~SM_SW_FWD_EN;
 
 	b53_write8(dev, B53_CTRL_PAGE, B53_SWITCH_MODE, mgmt);
+
+	/* Include IMP port in dumb forwarding mode when no tagging protocol is
+	 * set
+	 */
+	if (ds->ops->get_tag_protocol(ds) == DSA_TAG_PROTO_NONE) {
+		b53_read8(dev, B53_CTRL_PAGE, B53_SWITCH_CTRL, &mgmt);
+		mgmt |= B53_MII_DUMB_FWDG_EN;
+		b53_write8(dev, B53_CTRL_PAGE, B53_SWITCH_CTRL, mgmt);
+	}
 }
 
 static void b53_enable_vlan(struct b53_device *dev, bool enable)
diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index 9fd24c418fa4..f2a060e7a637 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -104,6 +104,10 @@
 #define  B53_UC_FWD_EN			BIT(6)
 #define  B53_MC_FWD_EN			BIT(7)
 
+/* Switch control (8 bit) */
+#define B53_SWITCH_CTRL			0x22
+#define  B53_MII_DUMB_FWDG_EN		BIT(6)
+
 /* (16 bit) */
 #define B53_UC_FLOOD_MASK		0x32
 #define B53_MC_FLOOD_MASK		0x34
-- 
2.9.3
