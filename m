From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 1/2] dsa: use an unique and non conflicting bus name for the slave MII bus
Date: Mon, 21 Jan 2013 20:58:50 +0100
Message-ID: <1358798331-13055-2-git-send-email-florian@openwrt.org>
References: <1358798331-13055-1-git-send-email-florian@openwrt.org>
Cc: buytenh@wantstofly.org, konszert@marvell.com, davem@davemloft.net,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:43893 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755583Ab3AUUBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 15:01:38 -0500
In-Reply-To: <1358798331-13055-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The slave MII bus registered by the DSA code is using the parent MII bus
as part of its name (ds->master_mii_bus_id), in case the parent MII bus
name is already 16 characters long (such as d0072004.mdio-mi) we will
get the following WARN_ON in dsa_switch_setup() when calling
mdiobus_register():

[   79.088782] ------------[ cut here ]------------
[   79.093448] WARNING: at fs/sysfs/dir.c:536 sysfs_add_one+0x80/0xa0()
[   79.099831] sysfs: cannot create duplicate filename
'/class/mdio_bus/d0072004.mdio-mi'

This is a genuine warning, because the DSA slave MII bus will also be
named d0072004.mdio-mi, and since MII_BUS_ID_SIZE is 17 characters long
(with null-terminator) the following will truncate the slave MII bus id:

snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s-%d:%.2x",
                        ds->master_mii_bus->id, ds->pd->sw_addr);

Fix this by using dsa-<switch index->:<sw_add> which is guaranteed to be
unique.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 net/dsa/slave.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index f434558..6ebd8fb 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -41,8 +41,8 @@ void dsa_slave_mii_bus_init(struct dsa_switch *ds)
 	ds->slave_mii_bus->name = "dsa slave smi";
 	ds->slave_mii_bus->read = dsa_slave_phy_read;
 	ds->slave_mii_bus->write = dsa_slave_phy_write;
-	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s:%.2x",
-			ds->master_mii_bus->id, ds->pd->sw_addr);
+	snprintf(ds->slave_mii_bus->id, MII_BUS_ID_SIZE, "dsa-%d:%.2x",
+			ds->index, ds->pd->sw_addr);
 	ds->slave_mii_bus->parent = &ds->master_mii_bus->dev;
 }
 
-- 
1.7.10.4
