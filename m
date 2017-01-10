From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 8/8] ARM: orion: Register DSA switch as a MDIO device
Date: Tue, 10 Jan 2017 12:12:35 -0800
Message-ID: <20170110201235.21771-9-f.fainelli@gmail.com>
References: <20170110201235.21771-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Stuart Yoder <stuart.yoder@nxp.com>,
        Ingo Tuchscherer <ingo.tuchscherer@linux.vnet.ibm.com>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM/Marvell
        Dove/MV78xx0/Orion SOC support),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35165 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967216AbdAJUN0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:13:26 -0500
In-Reply-To: <20170110201235.21771-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Utilize the ability to pass board specific MDIO bus information towards a
particular MDIO device thus allowing us to provide the per-port switch layout
to the Marvell 88E6XXX switch driver.

Since we would end-up with conflicting registration paths, do not register the
"dsa" platform device anymore.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 arch/arm/plat-orion/common.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/arch/arm/plat-orion/common.c b/arch/arm/plat-orion/common.c
index 272f49b2c68f..1d8f4ad1ac9a 100644
--- a/arch/arm/plat-orion/common.c
+++ b/arch/arm/plat-orion/common.c
@@ -22,6 +22,7 @@
 #include <linux/platform_data/dma-mv_xor.h>
 #include <linux/platform_data/usb-ehci-orion.h>
 #include <plat/common.h>
+#include <linux/phy.h>
 
 /* Create a clkdev entry for a given device/clk */
 void __init orion_clkdev_add(const char *con_id, const char *dev_id,
@@ -470,15 +471,27 @@ void __init orion_ge11_init(struct mv643xx_eth_platform_data *eth_data,
 /*****************************************************************************
  * Ethernet switch
  ****************************************************************************/
+static __initdata const char *orion_ge00_mvmdio_bus_name = "orion-mii";
+static __initdata struct mdio_board_info
+		  orion_ge00_switch_board_info[DSA_MAX_SWITCHES];
+
 void __init orion_ge00_switch_init(struct dsa_platform_data *d)
 {
+	struct mdio_board_info *bd;
 	int i;
 
 	d->netdev = &orion_ge00.dev;
-	for (i = 0; i < d->nr_chips; i++)
-		d->chip[i].host_dev = &orion_ge_mvmdio.dev;
+	for (i = 0; i < d->nr_chips; i++) {
+		bd = &orion_ge00_switch_board_info[i];
+		bd->bus_id = orion_ge00_mvmdio_bus_name;
+		bd->mdio_addr = d->chip[i].sw_addr;
+		strcpy(bd->modalias, "mv88e6085");
+		bd->platform_data = d;
+	}
+
+	mdiobus_register_board_info(orion_ge00_switch_board_info,
+				    ARRAY_SIZE(orion_ge00_switch_board_info));
 
-	platform_device_register_data(NULL, "dsa", 0, d, sizeof(d));
 }
 
 /*****************************************************************************
-- 
2.9.3
