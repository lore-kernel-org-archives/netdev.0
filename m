From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: b53: Have b53_hdr_setup() enable/disable tagging
Date: Mon, 30 Oct 2017 15:17:20 -0700
Message-ID: <20171030221721.31757-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Have b53_hdr_setup() check what kind of tagging protocol is configured
(Broadcom or none) and apply the correct settings in both cases.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index fa37f501f10b..a7ca62ba27b7 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -545,6 +545,7 @@ EXPORT_SYMBOL(b53_disable_port);
 
 void b53_brcm_hdr_setup(struct dsa_switch *ds, int port)
 {
+	bool tag_en = !!(ds->ops->get_tag_protocol(ds) == DSA_TAG_PROTO_BRCM);
 	struct b53_device *dev = ds->priv;
 	u8 hdr_ctl, val;
 	u16 reg;
@@ -567,7 +568,10 @@ void b53_brcm_hdr_setup(struct dsa_switch *ds, int port)
 
 	/* Enable Broadcom tags for IMP port */
 	b53_read8(dev, B53_MGMT_PAGE, B53_BRCM_HDR, &hdr_ctl);
-	hdr_ctl |= val;
+	if (tag_en)
+		hdr_ctl |= val;
+	else
+		hdr_ctl &= ~val;
 	b53_write8(dev, B53_MGMT_PAGE, B53_BRCM_HDR, hdr_ctl);
 
 	/* Registers below are only accessible on newer devices */
@@ -578,14 +582,20 @@ void b53_brcm_hdr_setup(struct dsa_switch *ds, int port)
 	 * allow us to tag outgoing frames
 	 */
 	b53_read16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_RX_DIS, &reg);
-	reg &= ~BIT(port);
+	if (tag_en)
+		reg &= ~BIT(port);
+	else
+		reg |= BIT(port);
 	b53_write16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_RX_DIS, reg);
 
 	/* Enable transmission of Broadcom tags from the switch (CPU RX) to
 	 * allow delivering frames to the per-port net_devices
 	 */
 	b53_read16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_TX_DIS, &reg);
-	reg &= ~BIT(port);
+	if (tag_en)
+		reg &= ~BIT(port);
+	else
+		reg |= BIT(port);
 	b53_write16(dev, B53_MGMT_PAGE, B53_BRCM_HDR_TX_DIS, reg);
 }
 EXPORT_SYMBOL(b53_brcm_hdr_setup);
-- 
2.9.3
