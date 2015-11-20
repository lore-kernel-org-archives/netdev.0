From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 2/2] dsa: mv88e6xxx.c: Hardware reset the chip if available
Date: Fri, 20 Nov 2015 03:56:24 +0100
Message-ID: <1447988184-9562-3-git-send-email-andrew@lunn.ch>
References: <1447988184-9562-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, preid@electromag.com.au,
	Neil Armstrong <narmstrong@baylibre.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37948 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964794AbbKTC4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Nov 2015 21:56:40 -0500
In-Reply-To: <1447988184-9562-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device tree binding now allows a gpio to be specified which is
attached to the switch chips reset line. If it is defined, perform
a hardware reset on the switch during setup.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index b06dba05594a..75e245c4235e 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -19,6 +19,7 @@
 #include <linux/list.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
+#include <linux/gpio/consumer.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
 #include <net/switchdev.h>
@@ -2323,6 +2324,7 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
 	u16 is_reset = (ppu_active ? 0x8800 : 0xc800);
+	struct gpio_desc *gpiod = ds->pd->reset;
 	unsigned long timeout;
 	int ret;
 	int i;
@@ -2336,6 +2338,14 @@ int mv88e6xxx_switch_reset(struct dsa_switch *ds, bool ppu_active)
 	/* Wait for transmit queues to drain. */
 	usleep_range(2000, 4000);
 
+	/* If there is a gpio connected to the reset pin, toggle it */
+	if (gpiod) {
+		gpiod_set_value_cansleep(gpiod, 1);
+		usleep_range(10000, 20000);
+		gpiod_set_value_cansleep(gpiod, 0);
+		usleep_range(10000, 20000);
+	}
+
 	/* Reset the switch. Keep the PPU active if requested. The PPU
 	 * needs to be active to support indirect phy register access
 	 * through global registers 0x18 and 0x19.
-- 
2.6.2
