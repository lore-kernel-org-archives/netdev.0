From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] lan78xx: Fix ladv/radv error handling in lan78xx_link_reset()
Date: Fri,  4 Sep 2015 12:47:28 +0200
Message-ID: <1441363648-20738-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "Woojung.Huh@microchip.com" <Woojung.Huh@microchip.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net/usb/lan78xx.c: In function =E2=80=98lan78xx_link_reset=E2=80=99:
net/usb/lan78xx.c:1107: warning: comparison is always false due to limi=
ted range of data type
net/usb/lan78xx.c:1111: warning: comparison is always false due to limi=
ted range of data type

Assigning return values that can be negative error codes to "u16"
variables makes them positive, ignoring the errors.  Hence use "int"
instead.

Drop the "unlikely"s (unlikely considered harmful) and propagate the
actual error values instead of overriding them to -EIO while we're at
it.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
Compile-tested only.

Many more overridden or plainly ignored errors, and lots of unlikely()
abuse to fix...
---
 drivers/net/usb/lan78xx.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index 39364a45af404388..a39518fc93aadf82 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -1049,8 +1049,7 @@ static int lan78xx_link_reset(struct lan78xx_net =
*dev)
 {
 	struct mii_if_info *mii =3D &dev->mii;
 	struct ethtool_cmd ecmd =3D { .cmd =3D ETHTOOL_GSET };
-	u16 ladv, radv;
-	int ret;
+	int ladv, radv, ret;
 	u32 buf;
=20
 	/* clear PHY interrupt status */
@@ -1104,12 +1103,12 @@ static int lan78xx_link_reset(struct lan78xx_ne=
t *dev)
 		}
=20
 		ladv =3D lan78xx_mdio_read(dev->net, mii->phy_id, MII_ADVERTISE);
-		if (unlikely(ladv < 0))
-			return -EIO;
+		if (ladv < 0)
+			return ladv;
=20
 		radv =3D lan78xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
-		if (unlikely(radv < 0))
-			return -EIO;
+		if (radv < 0)
+			return radv;
=20
 		netif_dbg(dev, link, dev->net,
 			  "speed: %u duplex: %d anadv: 0x%04x anlpa: 0x%04x",
--=20
1.9.1
