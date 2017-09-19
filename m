From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 09/12] net: dsa: b53: Wire-up EEE
Date: Tue, 19 Sep 2017 10:46:51 -0700
Message-ID: <20170919174654.2122-10-f.fainelli@gmail.com>
References: <20170919174654.2122-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34282 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751837AbdISRr0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 13:47:26 -0400
Received: by mail-wm0-f65.google.com with SMTP id i131so320192wma.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 10:47:25 -0700 (PDT)
In-Reply-To: <20170919174654.2122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for enabling and disabling EEE, as well as re-negotiating it in
.adjust_link() and in .port_enable().

Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index 491e4ffa8a0e..4e37ec27e496 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -523,6 +523,10 @@ static int b53_enable_port(struct dsa_switch *ds, int port,
 
 	b53_imp_vlan_setup(ds, cpu_port);
 
+	/* If EEE was enabled, restore it */
+	if (dev->ports[port].eee.eee_enabled)
+		b53_eee_enable_set(ds, port, true);
+
 	return 0;
 }
 
@@ -879,6 +883,7 @@ static void b53_adjust_link(struct dsa_switch *ds, int port,
 			    struct phy_device *phydev)
 {
 	struct b53_device *dev = ds->priv;
+	struct ethtool_eee *p = &dev->ports[port].eee;
 	u8 rgmii_ctrl = 0, reg = 0, off;
 
 	if (!phy_is_pseudo_fixed_link(phydev))
@@ -1000,6 +1005,9 @@ static void b53_adjust_link(struct dsa_switch *ds, int port,
 			b53_write8(dev, B53_CTRL_PAGE, po_reg, gmii_po);
 		}
 	}
+
+	/* Re-negotiate EEE if it was enabled already */
+	p->eee_enabled = b53_eee_init(ds, port, phydev);
 }
 
 int b53_vlan_filtering(struct dsa_switch *ds, int port, bool vlan_filtering)
@@ -1605,6 +1613,8 @@ static const struct dsa_switch_ops b53_switch_ops = {
 	.adjust_link		= b53_adjust_link,
 	.port_enable		= b53_enable_port,
 	.port_disable		= b53_disable_port,
+	.get_mac_eee		= b53_get_mac_eee,
+	.set_mac_eee		= b53_set_mac_eee,
 	.port_bridge_join	= b53_br_join,
 	.port_bridge_leave	= b53_br_leave,
 	.port_stp_state_set	= b53_br_set_stp_state,
-- 
2.9.3
