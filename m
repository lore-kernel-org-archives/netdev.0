From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] net: phy: dp83867: Fix for automatically detected PHYs
Date: Fri,  3 Feb 2017 19:52:37 +0300
Message-ID: <20170203165237.22452-1-abrodkin@synopsys.com>
Cc: linux-snps-arc@lists.infradead.org, linux-kernel@vger.kernel.org,
        Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Sekhar Nori <nsekhar@ti.com>,
        "David S . Miller" <davem@davemloft.net>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Current implemntation returns ENODEV if device tree node for
phy is absent. But in reality there're many boards with the one
and only PHY on board and MACs that may find a PHY by querying
MDIO bus. One good example is STMMAC.

So that's what I saw:
--- Booing --------------->8-------------------------
libphy: Fixed MDIO Bus: probed
stmmaceth f0008000.ethernet: no reset control found
stmmac - user ID: 0x10, Synopsys ID: 0x37
stmmaceth f0008000.ethernet: Ring mode enabled
stmmaceth f0008000.ethernet: DMA HW capability register supported
stmmaceth f0008000.ethernet: Normal descriptors
stmmaceth f0008000.ethernet: RX Checksum Offload Engine supported
stmmaceth f0008000.ethernet: COE Type 2
stmmaceth f0008000.ethernet: TX Checksum insertion supported
stmmaceth f0008000.ethernet: Enable RX Mitigation via HW Watchdog Timer
libphy: stmmac: probed
stmmaceth f0008000.ethernet (unnamed net_device) (uninitialized): PHY ID 2000a231 at 0 IRQ POLL (stmmac-0:00) active

--- Bringing up eth0 ----->8-------------------------
Starting network: stmmaceth f0008000.ethernet eth0: device MAC address b6:43:6b:1d:50:cf
stmmaceth f0008000.ethernet eth0: Could not attach to PHY
stmmaceth f0008000.ethernet eth0: stmmac_open: Cannot attach to PHY (error: -19)
ip: SIOCSIFFLAGS: No such device
-------------------------->8-------------------------

Note PHY is detected properly but right after that we're getting -ENODEV.
That makes no sense at all.

So let's silently exit with 0 if there's no DT node for the PHY.
That's what I'm seeing now:
-------------------------->8-------------------------
Starting network: stmmaceth f0008000.ethernet eth0: device MAC address de:1f:a9:f7:8d:88
stmmaceth f0008000.ethernet eth0: fail to init PTP.
IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
udhcpc: started, v1.25.1
udhcpc: sending discover
udhcpc: sending discover
stmmaceth f0008000.ethernet eth0: Link is Up - 100Mbps/Full - flow control off
IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
udhcpc: sending discover
Link is Up - 100/Full
udhcpc: sending select for x.x.x.x
udhcpc: lease of x.x.x.x obtained, lease time 3600
deleting routers
adding dns x.x.x.x
-------------------------->8-------------------------

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>
Cc: Murali Karicheri <m-karicheri2@ti.com>
Cc: Sekhar Nori <nsekhar@ti.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Grygorii Strashko <grygorii.strashko@ti.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/phy/dp83867.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
index ca1b462..c44259b 100644
--- a/drivers/net/phy/dp83867.c
+++ b/drivers/net/phy/dp83867.c
@@ -120,7 +120,7 @@ static int dp83867_of_init(struct phy_device *phydev)
 	int ret;
 
 	if (!of_node)
-		return -ENODEV;
+		return 0;
 
 	dp83867->io_impedance = -EINVAL;
 
-- 
2.10.2
