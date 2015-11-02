From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH net-next 1/6] net: dsa: mv88e6060: remove poll_link
 callback
Date: Mon, 2 Nov 2015 11:57:06 +0100
Message-ID: <56374182.8040000@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As of mv88e6xxx remove the poll_link callback since the link
state change polling is now handled by the phylib.

Tested on a mv88e6060 B0 device with a TI DM816X SoC.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6060.c | 49 ---------------------------------------------
 1 file changed, 49 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 9093577..6885ef5 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -225,54 +225,6 @@ mv88e6060_phy_write(struct dsa_switch *ds, int port, int regnum, u16 val)
 	return reg_write(ds, addr, regnum, val);
 }

-static void mv88e6060_poll_link(struct dsa_switch *ds)
-{
-	int i;
-
-	for (i = 0; i < DSA_MAX_PORTS; i++) {
-		struct net_device *dev;
-		int uninitialized_var(port_status);
-		int link;
-		int speed;
-		int duplex;
-		int fc;
-
-		dev = ds->ports[i];
-		if (dev == NULL)
-			continue;
-
-		link = 0;
-		if (dev->flags & IFF_UP) {
-			port_status = reg_read(ds, REG_PORT(i), 0x00);
-			if (port_status < 0)
-				continue;
-
-			link = !!(port_status & 0x1000);
-		}
-
-		if (!link) {
-			if (netif_carrier_ok(dev)) {
-				netdev_info(dev, "link down\n");
-				netif_carrier_off(dev);
-			}
-			continue;
-		}
-
-		speed = (port_status & 0x0100) ? 100 : 10;
-		duplex = (port_status & 0x0200) ? 1 : 0;
-		fc = ((port_status & 0xc000) == 0xc000) ? 1 : 0;
-
-		if (!netif_carrier_ok(dev)) {
-			netdev_info(dev,
-				    "link up, %d Mb/s, %s duplex, flow control %sabled\n",
-				    speed,
-				    duplex ? "full" : "half",
-				    fc ? "en" : "dis");
-			netif_carrier_on(dev);
-		}
-	}
-}
-
 static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.tag_protocol	= DSA_TAG_PROTO_TRAILER,
 	.probe		= mv88e6060_probe,
@@ -280,7 +232,6 @@ static struct dsa_switch_driver mv88e6060_switch_driver = {
 	.set_addr	= mv88e6060_set_addr,
 	.phy_read	= mv88e6060_phy_read,
 	.phy_write	= mv88e6060_phy_write,
-	.poll_link	= mv88e6060_poll_link,
 };

 static int __init mv88e6060_init(void)
-- 
1.9.1
