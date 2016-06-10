From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/5] net: dsa: b53: Add BCM7445 quirk
Date: Thu,  9 Jun 2016 18:23:54 -0700
Message-ID: <1465521837-30193-3-git-send-email-f.fainelli@gmail.com>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, davem@davemloft.net,
	jon.mason@broadcom.com, hemal.shah@broadcom.com,
	bandaru.viswanath@broadcom.com, michael.chan@broadcom.com,
	jogo@openwrt.org, cphealy@gmail.com, ardeleanalex@gmail.com,
	jiri@mellanox.com, idosch@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36406 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcFJBYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 21:24:07 -0400
Received: by mail-pa0-f65.google.com with SMTP id fg1so3863949pad.3
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 18:24:07 -0700 (PDT)
In-Reply-To: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Broadcom BCM7445 STB chip has an issued in its revision D0 which was
previously worked around in drivers/net/dsa/bcm_sf2.c where we may
end-up double programming the integrated BCM7445 switch (bcm_sf2) and an
external Broadcom switch such as BCM53125, since these are mostly
register compatible.

Add a small quirk which just defers probing until we are sitting on the
slave DSA MDIO bus, which will allow us to intercept reads/writes and
funnel them through the SF2 internal MDIO master (which happens to
disconnect its pseudo PHY).

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_mdio.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_mdio.c b/drivers/net/dsa/b53/b53_mdio.c
index c6cf7cf57cc3..aa87c3fffdac 100644
--- a/drivers/net/dsa/b53/b53_mdio.c
+++ b/drivers/net/dsa/b53/b53_mdio.c
@@ -316,6 +316,17 @@ static int b53_mdio_probe(struct mdio_device *mdiodev)
 		return -ENODEV;
 	}
 
+	/* First probe will come from SWITCH_MDIO controller on the 7445D0
+	 * switch, which will conflict with the 7445 integrated switch
+	 * pseudo-phy (we end-up programming both). In that case, we return
+	 * -EPROBE_DEFER for the first time we get here, and wait until we come
+	 * back with the slave MDIO bus which has the correct indirection
+	 * layer setup
+	 */
+	if (of_machine_is_compatible("brcm,bcm7445d0") &&
+	    strcmp(mdiodev->bus->name, "sf2 slave mii"))
+		return -EPROBE_DEFER;
+
 	dev = b53_switch_alloc(&mdiodev->dev, &b53_mdio_ops, mdiodev->bus);
 	if (!dev)
 		return -ENOMEM;
-- 
2.7.4
