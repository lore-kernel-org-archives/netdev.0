From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next-v2 4/6] net: dsa: b53: Add JOIN_ALL_VLAN support
Date: Thu, 25 Aug 2016 09:24:40 -0700
Message-ID: <1472142282-1479-6-git-send-email-f.fainelli@gmail.com>
References: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, jonas.gorski@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36558 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756764AbcHYQZQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:25:16 -0400
Received: by mail-pa0-f67.google.com with SMTP id ez1so3352385pab.3
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:25:11 -0700 (PDT)
In-Reply-To: <1472142282-1479-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to migrate the bcm_sf2 driver over to the b53 driver for most
VLAN/FDB/bridge operations, we need to add support for the "join all
VLANs" register and behavior which allows us to make a given port join
all VLANs and avoid setting specific VLAN entries when it is leaving the
bridge.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 30 ++++++++++++++++++++++++++----
 drivers/net/dsa/b53/b53_regs.h   |  3 +++
 2 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index ca13ee134562..1299104a87d4 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -1315,9 +1315,21 @@ static int b53_br_join(struct dsa_switch *ds, int port,
 		       struct net_device *bridge)
 {
 	struct b53_device *dev = ds_to_priv(ds);
+	s8 cpu_port = ds->dst->cpu_port;
 	u16 pvlan, reg;
 	unsigned int i;
 
+	/* Make this port leave the all VLANs join since we will have proper
+	 * VLAN entries from now on
+	 */
+	if (is58xx(dev)) {
+		b53_read16(dev, B53_VLAN_PAGE, B53_JOIN_ALL_VLAN_EN, &reg);
+		reg &= ~BIT(port);
+		if ((reg & BIT(cpu_port)) == BIT(cpu_port))
+			reg &= ~BIT(cpu_port);
+		b53_write16(dev, B53_VLAN_PAGE, B53_JOIN_ALL_VLAN_EN, reg);
+	}
+
 	dev->ports[port].bridge_dev = bridge;
 	b53_read16(dev, B53_PVLAN_PAGE, B53_PVLAN_PORT_MASK(port), &pvlan);
 
@@ -1350,6 +1362,7 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 	struct b53_device *dev = ds_to_priv(ds);
 	struct net_device *bridge = dev->ports[port].bridge_dev;
 	struct b53_vlan *vl = &dev->vlans[0];
+	s8 cpu_port = ds->dst->cpu_port;
 	unsigned int i;
 	u16 pvlan, reg, pvid;
 
@@ -1379,10 +1392,19 @@ static void b53_br_leave(struct dsa_switch *ds, int port)
 	else
 		pvid = 0;
 
-	b53_get_vlan_entry(dev, pvid, vl);
-	vl->members |= BIT(port) | BIT(dev->cpu_port);
-	vl->untag |= BIT(port) | BIT(dev->cpu_port);
-	b53_set_vlan_entry(dev, pvid, vl);
+	/* Make this port join all VLANs without VLAN entries */
+	if (is58xx(dev)) {
+		b53_read16(dev, B53_VLAN_PAGE, B53_JOIN_ALL_VLAN_EN, &reg);
+		reg |= BIT(port);
+		if (!(reg & BIT(cpu_port)))
+			reg |= BIT(cpu_port);
+		b53_write16(dev, B53_VLAN_PAGE, B53_JOIN_ALL_VLAN_EN, reg);
+	} else {
+		b53_get_vlan_entry(dev, pvid, vl);
+		vl->members |= BIT(port) | BIT(dev->cpu_port);
+		vl->untag |= BIT(port) | BIT(dev->cpu_port);
+		b53_set_vlan_entry(dev, pvid, vl);
+	}
 }
 
 static void b53_br_set_stp_state(struct dsa_switch *ds, int port,
diff --git a/drivers/net/dsa/b53/b53_regs.h b/drivers/net/dsa/b53/b53_regs.h
index a0b453ea34c9..dac0af4e2cd0 100644
--- a/drivers/net/dsa/b53/b53_regs.h
+++ b/drivers/net/dsa/b53/b53_regs.h
@@ -309,6 +309,9 @@
 /* Port VLAN mask (16 bit) IMP port is always 8, also on 5325 & co */
 #define B53_PVLAN_PORT_MASK(i)		((i) * 2)
 
+/* Join all VLANs register (16 bit) */
+#define B53_JOIN_ALL_VLAN_EN		0x50
+
 /*************************************************************************
  * 802.1Q Page Registers
  *************************************************************************/
-- 
2.7.4
