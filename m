From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH] net: dsa: set slave MII bus PHY mask
Date: Tue, 20 Jan 2015 19:13:32 -0500
Message-ID: <1421799212-2028-2-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1421799212-2028-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S . Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421799212-2028-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When registering a mdio bus, Linux assumes than every port has a PHY and tries
to scan it. If a switch port has no PHY registered, DSA will fail to register
the slave MII bus. To fix this, set the slave MII bus PHY mask to the switch
PHYs mask.

As an example, if we use a Marvell MV88E6352 (which is a 7-port switch with no
registered PHYs for port 5 and port 6), with the following declared names:

	static struct dsa_chip_data switch_cdata = {
		[...]
		.port_names[0] = "sw0",
		.port_names[1] = "sw1",
		.port_names[2] = "sw2",
		.port_names[3] = "sw3",
		.port_names[4] = "sw4",
		.port_names[5] = "cpu",
	};

DSA will fail to create the switch instance. With the PHY mask set for the
slave MII bus, only the PHY for ports 0-4 will be scanned and the instance will
be successfully created.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/slave.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 515569f..589aafd 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -46,6 +46,7 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d:%.2x",
 			ds->index, ds->pd->sw_addr);
 	ds->slave_mii_bus->parent = ds->master_dev;
+	ds->slave_mii_bus->phy_mask = ~ds->phys_mii_mask;
 }
 
 
-- 
2.2.2
